extends Node3D
var frames: int = 0
var focus_test_armed: bool = false
var controller_focus_expected: bool = false
var controller_button_release_observed: bool = false
var controller_axis_release_observed: bool = false

class AliasStamp:
    extends Control
    var counter: int = 0
    func _process(_delta: float) -> void:
        counter = (counter + 1) & 65535
        queue_redraw()
    func _ready() -> void:
        get_viewport().size_changed.connect(queue_redraw)
    func _draw() -> void:
        var size := get_viewport_rect().size
        var cell := size.x * 0.6 / 16.0
        for bit in range(16):
            var color := Color.WHITE if counter & (1 << bit) else Color.BLACK
            draw_rect(Rect2(size.x * 0.2 + bit * cell, 4, cell, 24), color)
            draw_rect(Rect2(size.x * 0.2 + bit * cell, size.y - 28, cell, 24), color)

class ResizeProbe:
    extends Control
    func _process(_delta: float) -> void:
        queue_redraw()
    func _draw() -> void:
        var size := get_viewport_rect().size
        for corner in [Vector2(0,0),Vector2(size.x-20,0),Vector2(0,size.y-20),size-Vector2(20,20)]:
            draw_rect(Rect2(corner,Vector2(20,20)),Color.MAGENTA)
    func _input(event: InputEvent) -> void:
        if event is InputEventKey and event.keycode == KEY_F10 and event.pressed:
            var size := get_viewport_rect().size
            print("GODOT_NODE_VIEWPORT width=",int(size.x)," height=",int(size.y)," paused=",int(get_tree().paused))

class PauseProbe:
    extends Node
    var paused_ticks: int = 0
    func _process(_delta: float) -> void:
        if get_tree().paused:
            paused_ticks += 1
    func _input(event: InputEvent) -> void:
        if event is InputEventKey and event.keycode == KEY_F9 and event.pressed:
            if not get_tree().paused or paused_ticks == 0:
                push_error("Preboot pause lost or PROCESS_MODE_ALWAYS stopped")
            else:
                print("GODOT_NODE_PREBOOT_PAUSE paused=1 ticking=1")


func _ready() -> void:
    if OS.get_environment("DORA_GODOT_TEST_RESIZE") == "1":
        var probe := ResizeProbe.new()
        probe.process_mode = Node.PROCESS_MODE_ALWAYS
        probe.z_index = 4096
        add_child(probe)
    if OS.get_environment("DORA_GODOT_TEST_ALIASES") == "1":
        var stamp := AliasStamp.new()
        stamp.z_index = 4095
        add_child(stamp)
    if OS.get_environment("DORA_GODOT_TEST_AUDIO") == "1":
        # Deterministic stereo signal; all samples originate inside Godot.
        var data := PackedByteArray()
        data.resize(48000 * 4)
        for i in range(48000):
            data.encode_s16(i * 4, int(sin(TAU * 440.0 * i / 48000.0) * 4096.0))
            data.encode_s16(i * 4 + 2, int(sin(TAU * 660.0 * i / 48000.0) * 4096.0))
        var stream := AudioStreamWAV.new()
        stream.format = AudioStreamWAV.FORMAT_16_BITS
        stream.mix_rate = 48000
        stream.stereo = true
        stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
        stream.loop_end = 48000
        stream.data = data
        var player := AudioStreamPlayer.new()
        player.stream = stream
        add_child(player)
        player.play()
        print("GODOT_NODE_AUDIO tone=440,660 rate=48000 channels=2")
    var probe := PauseProbe.new()
    probe.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(probe)
    TestState.boots += 1
    if get_node("/root/Main") != self or get_tree().current_scene != self:
        push_error("Embedded SceneTree root/current_scene changed")
    print("GODOT_NODE_SCENE boots=", TestState.boots, " root_path_ok=1")
    $Cube.material_override = $Cube.material_override.duplicate()
    $UI/Entry.text_changed.connect(func(text: String) -> void:
        print("GODOT_NODE_TEXT value=", text))
    if OS.get_environment("DORA_GODOT_TEST_IME") == "1":
        $UI/Entry.call_deferred("grab_focus")
        call_deferred("_report_ime_focus")

func _report_ime_focus() -> void:
    await get_tree().process_frame
    print("GODOT_NODE_IME_FOCUS active=", int($UI/Entry.has_focus()))

func _process(delta: float) -> void:
    frames += 1
    $Cube.rotate_y(delta * 0.9)

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        if focus_test_armed:
            if Input.is_key_pressed(KEY_F8) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
                push_error("Embedded focus loss did not release held input")
            else:
                print("GODOT_NODE_FOCUS released=1")
            focus_test_armed = false
        if controller_focus_expected:
            if Input.is_joy_button_pressed(7, JOY_BUTTON_A) or absf(Input.get_joy_axis(7, JOY_AXIS_LEFT_X)) > 0.001 or not controller_button_release_observed or not controller_axis_release_observed:
                push_error("Embedded focus loss did not release held controller input")
            else:
                print("GODOT_NODE_CONTROLLER_FOCUS released=1")
            controller_focus_expected = false

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_F8 and event.pressed:
        focus_test_armed = true
    if event is InputEventMouseButton:
        if Input.is_mouse_button_pressed(event.button_index) != event.pressed:
            push_error("Embedded mouse state differs from dispatched event")
        if event.pressed:
            print("GODOT_NODE_INPUT_STATE mouse=", int(Input.is_mouse_button_pressed(event.button_index)))
    if event is InputEventKey and event.keycode == KEY_SPACE:
        if Input.is_key_pressed(KEY_SPACE) != event.pressed or Input.is_action_pressed("ui_accept") != event.pressed:
            push_error("Embedded key/action state differs from dispatched event")
        if event.pressed:
            print("GODOT_NODE_INPUT_STATE key=", int(Input.is_key_pressed(KEY_SPACE)), " action=", int(Input.is_action_pressed("ui_accept")))
    if event is InputEventMouseButton and event.pressed:
        print("GODOT_NODE_POINTER x=", int(event.position.x), " y=", int(event.position.y))
    if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
        $Cube.material_override.albedo_color = Color(1.0, 0.15, 0.12)
        print("GODOT_NODE_KEY space=1")
    if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A:
        if controller_focus_expected and not event.pressed:
            controller_button_release_observed = true
        print("GODOT_NODE_CONTROLLER_BUTTON device=", event.device, " pressed=", int(event.pressed), " state=", int(Input.is_joy_button_pressed(event.device, JOY_BUTTON_A)))
    if event is InputEventJoypadMotion and event.axis == JOY_AXIS_LEFT_X:
        if is_equal_approx(event.axis_value, 0.5):
            controller_focus_expected = true
            controller_button_release_observed = false
            controller_axis_release_observed = false
        elif controller_focus_expected and is_zero_approx(event.axis_value):
            controller_axis_release_observed = true
        print("GODOT_NODE_CONTROLLER_AXIS device=", event.device, " value=", snappedf(event.axis_value, 0.01))

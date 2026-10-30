extends Node2D
var frame: int = 0
var key_down: bool = false
var controller_focus_expected: bool = false
var controller_button_release_observed: bool = false
var controller_axis_release_observed: bool = false
func _ready() -> void:
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
    print("DORA_WEB_GODOT_BOOT")
func _process(_delta: float) -> void:
    frame += 1
    queue_redraw()
func _draw() -> void:
    var size := get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.15, 0.25, 0.8))
    draw_rect(Rect2(0, 0, 24, 24), Color.RED)
    draw_rect(Rect2(size.x-24, 0, 24, 24), Color.GREEN)
    draw_rect(Rect2(0, size.y-24, 24, 24), Color.BLUE)
    draw_rect(Rect2(size-Vector2(24,24), Vector2(24,24)), Color.WHITE)
    draw_rect(Rect2(size*0.5-Vector2(32,32), Vector2(64,64)), Color.RED if key_down else Color.YELLOW)
    var cell := size.x*0.6/16.0
    for bit in range(16):
        var color := Color.WHITE if frame & (1 << bit) else Color.BLACK
        draw_rect(Rect2(size.x*0.2+bit*cell, 4, cell, 24), color)
        draw_rect(Rect2(size.x*0.2+bit*cell, size.y-28, cell, 24), color)
func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT and controller_focus_expected:
        if Input.is_joy_button_pressed(7, JOY_BUTTON_A) or absf(Input.get_joy_axis(7, JOY_AXIS_LEFT_X)) > 0.001 or not controller_button_release_observed or not controller_axis_release_observed:
            push_error("Embedded Web focus loss did not release held controller input")
        else:
            print("DORA_WEB_GODOT_CONTROLLER_FOCUS released=1")
        controller_focus_expected = false
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_SPACE:
        key_down = event.pressed
        queue_redraw()
        print("DORA_WEB_GODOT_KEY ", int(event.pressed), " state=", int(Input.is_key_pressed(KEY_SPACE)))
    if event is InputEventMouseButton and event.pressed:
        print("DORA_WEB_GODOT_POINTER ", int(event.position.x), ",", int(event.position.y))
    if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A:
        if controller_focus_expected and not event.pressed:
            controller_button_release_observed = true
        print("DORA_WEB_GODOT_CONTROLLER_BUTTON device=", event.device, " pressed=", int(event.pressed), " state=", int(Input.is_joy_button_pressed(event.device, JOY_BUTTON_A)))
    if event is InputEventJoypadMotion and event.axis == JOY_AXIS_LEFT_X:
        if is_equal_approx(event.axis_value, 0.5):
            controller_focus_expected = true
            controller_button_release_observed = false
            controller_axis_release_observed = false
        elif controller_focus_expected and is_zero_approx(event.axis_value):
            controller_axis_release_observed = true
        print("DORA_WEB_GODOT_CONTROLLER_AXIS device=", event.device, " value=", snappedf(event.axis_value, 0.01))

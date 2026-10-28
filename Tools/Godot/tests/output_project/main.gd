extends Control
var phase: int = 0
var elapsed: float = 0.0
var hits: int = 0
var pending_sizes: Array[Vector2i] = []
var indicator: ColorRect
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    var button := Button.new()
    button.position = Vector2(64,48)
    button.size = Vector2(32,24)
    button.pressed.connect(func():
        hits += 1
        indicator.color = Color.GREEN
        print("GODOT_OUTPUT_BUTTON phase=",phase," hits=",hits))
    add_child(button)
    indicator = ColorRect.new()
    indicator.position = Vector2(64,48)
    indicator.size = Vector2(32,24)
    indicator.color = Color.RED
    indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(indicator)
    print("GODOT_OUTPUT_READY")
func _process(delta: float) -> void:
    if not pending_sizes.is_empty():
        get_tree().root.size = pending_sizes.pop_front()
        print("GODOT_OUTPUT_BOUNCE width=",get_tree().root.size.x," height=",get_tree().root.size.y)
    elapsed += delta
    queue_redraw()
func _draw() -> void:
    var size := get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO,size),Color(0.1,0.2,0.3,0.5))
    draw_rect(Rect2(8,8,12,12),Color.MAGENTA)
    draw_rect(Rect2(size-Vector2(20,20),Vector2(12,12)),Color.YELLOW)
    draw_rect(Rect2(180+fmod(elapsed*32,100),100,8,8),Color.RED)
    # Premultiplied output must retain half-alpha and additive RGB through resolve.
    draw_rect(Rect2(32,100,16,16),Color(1,0,0,0.5))
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        print("GODOT_OUTPUT_INPUT phase=",phase," x=",event.position.x," y=",event.position.y)
    if not event is InputEventKey or not event.pressed:
        return
    var next := int(event.keycode-KEY_F1)+1
    if next<1 or next>8:
        return
    phase = next
    indicator.color = Color.RED
    var root := get_tree().root
    root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
    root.content_scale_size = Vector2i(320,180)
    root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
    match phase:
        1:
            root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
            root.size = Vector2i(800,450)
        2:
            root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
            root.size = Vector2i(800,600)
        3:
            root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
            root.size = Vector2i(800,600)
        4:
            root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
            root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
        5:
            root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
            root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
        6:
            root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
            root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
            root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
            root.size = Vector2i(720,480)
        7:
            root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
            root.size = Vector2i(640,360)
        8:
            root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
            root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
            root.size = Vector2i(800,450)
            pending_sizes = [Vector2i(400,300),Vector2i(720,480),Vector2i(640,360),Vector2i(720,480)]
    print("GODOT_OUTPUT_PHASE phase=",phase," width=",root.size.x," height=",root.size.y," mode=",root.content_scale_mode)

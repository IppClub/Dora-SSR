extends Node2D
var armed := false
func _ready() -> void:
    print("GODOT_DOM_BOOT")
    $LineEdit.text_changed.connect(func(value: String) -> void: print("GODOT_DOM_LINE text=",value))
    $LineEdit.call_deferred("grab_focus")
    call_deferred("report_line_focus")
func report_line_focus() -> void:
    print("GODOT_DOM_IME_FOCUS active=",int($LineEdit.has_focus()))
func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.1,0.25,0.4,1))
    draw_rect(Rect2(108,78,24,24), Color.YELLOW)
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        print("GODOT_DOM_POINTER button=",int(event.button_index)," pressed=",int(event.pressed)," x=",event.position.x," y=",event.position.y," shift=",int(event.shift_pressed))
    if event is InputEventKey:
        if event.keycode == KEY_A:
            print("GODOT_DOM_KEY A pressed=",int(event.pressed)," shift=",int(event.shift_pressed)," ctrl=",int(event.ctrl_pressed)," state=",int(Input.is_key_pressed(KEY_A)))
        if event.keycode == KEY_F8 and event.pressed:
            armed=true
            print("GODOT_DOM_ARMED")
        if event.unicode > 0:
            print("GODOT_DOM_TEXT codepoint=",event.unicode)
func _notification(what: int) -> void:
    if what==NOTIFICATION_APPLICATION_FOCUS_OUT and armed:
        print("GODOT_DOM_FOCUS released=",int(not Input.is_key_pressed(KEY_A) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)))
        armed=false

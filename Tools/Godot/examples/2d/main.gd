extends Node2D

var elapsed := 0.0
var alternate := false

func _ready() -> void:
    var title := Label.new()
    title.text = "Godot 2D inside Dora"
    title.position = Vector2(24, 20)
    title.add_theme_font_size_override("font_size", 26)
    add_child(title)
    var hint := Label.new()
    hint.text = "Click to change the ball color"
    hint.position = Vector2(24, 60)
    hint.add_theme_font_size_override("font_size", 18)
    add_child(hint)

func _process(delta: float) -> void:
    elapsed += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(20, 110, 600, 220), Color(0.06, 0.11, 0.17))
    for index in range(13):
        var x := 32.0 + index * 48.0
        draw_line(Vector2(x, 120), Vector2(x, 320), Color(0.12, 0.19, 0.26))
    var ball_position := Vector2(320 + sin(elapsed * 1.4) * 220, 220 + cos(elapsed * 2.0) * 55)
    var color := Color(1, 0.6, 0.2) if alternate else Color(0.12, 0.85, 0.65)
    draw_circle(ball_position, 28, color)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        alternate = not alternate
        queue_redraw()

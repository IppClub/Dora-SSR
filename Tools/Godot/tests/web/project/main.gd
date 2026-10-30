extends Node2D
var frame := 0
func _process(_delta: float) -> void:
    frame += 1
    queue_redraw()
func _draw() -> void:
    draw_rect(Rect2(0, 0, 64, 64), Color8(frame % 256, (frame * 3) % 256, 111))
    draw_rect(Rect2(0, 0, 8, 8), Color.RED)
    draw_rect(Rect2(56, 0, 8, 8), Color.GREEN)
    draw_rect(Rect2(0, 56, 8, 8), Color.BLUE)
    draw_rect(Rect2(56, 56, 8, 8), Color.WHITE)

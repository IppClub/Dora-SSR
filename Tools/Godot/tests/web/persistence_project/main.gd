extends Node2D

func _ready() -> void:
    var value := 0
    if FileAccess.file_exists("user://counter.txt"):
        var input := FileAccess.open("user://counter.txt", FileAccess.READ)
        if input:
            value = input.get_as_text().to_int()
    value += 1
    var output := FileAccess.open("user://counter.txt", FileAccess.WRITE)
    if not output:
        push_error("Cannot write Godot user storage")
        return
    output.store_string(str(value))
    output.close()
    JavaScriptBridge.force_fs_sync()
    print("GODOT_PERSIST value=", value)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.08, 0.18, 0.28, 1.0))

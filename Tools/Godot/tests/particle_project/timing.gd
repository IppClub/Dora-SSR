extends Control
var expected_time: float = 0.0
var panel: ColorRect
func _ready() -> void:
    panel = ColorRect.new()
    panel.position = Vector2(128,64)
    panel.size = Vector2(384,64)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var shader := Shader.new()
    shader.code = """
shader_type canvas_item;
render_mode unshaded;
uniform highp float expected_time = 0.0;
void fragment() {
    highp float t = UV.y < 0.5 ? TIME : expected_time;
    highp uint code = uint(floor(t * 64.0)) & 65535u;
    highp uint bit = uint(floor(UV.x * 16.0));
    float value = float((code >> bit) & 1u);
    COLOR = vec4(vec3(value),1.0);
}
"""
    var material := ShaderMaterial.new()
    material.shader = shader
    panel.material = material
    add_child(panel)
    print("GODOT_TIMING_READY delay_ms=60 root_always=1")
func _process(delta: float) -> void:
    expected_time += delta
    panel.material.set_shader_parameter("expected_time",expected_time)
    # Deliberately drive fewer than 60 Godot render frames per wall second.
    OS.delay_msec(60)
func _input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed:
        return
    match event.keycode:
        KEY_F1: Engine.time_scale = 1.0
        KEY_F2: Engine.time_scale = 0.25
        KEY_F3: Engine.time_scale = 2.0
        KEY_F4: Engine.time_scale = 0.0
        KEY_F5:
            print("GODOT_TIMING_DRAWN value=",Engine.get_frames_drawn()," scale=",Engine.time_scale," paused=",int(get_tree().paused))
    if event.keycode != KEY_F5:
        print("GODOT_TIMING_SCALE value=",Engine.time_scale)

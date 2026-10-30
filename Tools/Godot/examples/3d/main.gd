extends Node3D

var cube: MeshInstance3D

func _ready() -> void:
    cube = MeshInstance3D.new()
    cube.mesh = BoxMesh.new()
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.12, 0.85, 0.65)
    material.roughness = 0.55
    cube.material_override = material
    add_child(cube)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-40, -30, 0)
    light.light_energy = 1.8
    add_child(light)
    var camera := Camera3D.new()
    camera.position = Vector3(0, 1.2, 3.8)
    add_child(camera)
    camera.look_at(Vector3.ZERO)
    camera.current = true
    var environment := WorldEnvironment.new()
    environment.environment = Environment.new()
    environment.environment.background_mode = Environment.BG_COLOR
    environment.environment.background_color = Color(0.025, 0.045, 0.08)
    environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.environment.ambient_light_color = Color(0.6, 0.7, 0.85)
    environment.environment.ambient_light_energy = 0.5
    add_child(environment)
    var title := Label.new()
    title.text = "Godot 3D inside Dora"
    title.position = Vector2(24, 20)
    title.add_theme_font_size_override("font_size", 26)
    var overlay := CanvasLayer.new()
    add_child(overlay)
    overlay.add_child(title)

func _process(delta: float) -> void:
    cube.rotate_y(delta * 0.9)
    cube.rotate_x(delta * 0.35)

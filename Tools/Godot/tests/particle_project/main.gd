extends "res://timing.gd"
var standard_time: float = 0.0

func make_particle(y: float, lifetime_seconds: float) -> GPUParticles2D:
    var particle := GPUParticles2D.new()
    particle.position = Vector2(64,y)
    particle.amount = 1
    particle.lifetime = lifetime_seconds
    particle.explosiveness = 1.0
    particle.randomness = 0.0
    particle.use_fixed_seed = true
    particle.seed = 1234
    particle.fixed_fps = 0
    particle.interpolate = false
    particle.fract_delta = true
    particle.local_coords = true
    particle.visibility_rect = Rect2(-16,-16,512,32)
    particle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var image := Image.create(8,8,false,Image.FORMAT_RGBA8)
    image.fill(Color.WHITE)
    particle.texture = ImageTexture.create_from_image(image)
    return particle

func _ready() -> void:
    super._ready()
    # Preserve the two timing-oracle rows and add a third independent clock for
    # the pausable standard emitter. The custom emitter inherits Always mode.
    panel.size = Vector2(384,96)
    var clock_shader := Shader.new()
    clock_shader.code = """
shader_type canvas_item;
render_mode unshaded;
uniform highp float expected_time = 0.0;
uniform highp float standard_time = 0.0;
void fragment() {
    highp float t = UV.y < (1.0/3.0) ? TIME : (UV.y < (2.0/3.0) ? expected_time : standard_time);
    highp uint code = uint(floor(t * 64.0)) & 65535u;
    highp uint bit = uint(floor(UV.x * 16.0));
    float value = float((code >> bit) & 1u);
    COLOR = vec4(vec3(value),1.0);
}
"""
    panel.material.shader = clock_shader
    var custom := make_particle(180,600)
    var shader := Shader.new()
    shader.code = """
shader_type particles;
render_mode disable_force, disable_velocity;
void start() {
    TRANSFORM = mat4(1.0);
    COLOR = vec4(0.0,1.0,1.0,1.0);
}
void process() {
    TRANSFORM[3].x = mod(TRANSFORM[3].x + DELTA * 8.0,448.0);
}
"""
    var material := ShaderMaterial.new()
    material.shader = shader
    custom.process_material = material
    add_child(custom)
    var standard := make_particle(260,40)
    standard.process_mode = Node.PROCESS_MODE_PAUSABLE
    var process := ParticleProcessMaterial.new()
    process.direction = Vector3(1,0,0)
    process.spread = 0.0
    process.gravity = Vector3.ZERO
    process.initial_velocity_min = 4.0
    process.initial_velocity_max = 4.0
    process.color = Color(1,1,0,1)
    standard.process_material = process
    add_child(standard)
    print("GODOT_PARTICLE_READY count=2 shader_delta=1 standard_material=1")

func _process(delta: float) -> void:
    if not get_tree().paused:
        standard_time += delta
    super._process(delta)
    panel.material.set_shader_parameter("standard_time",standard_time)
    queue_redraw()

func _draw() -> void:
    # Independent CPU integration, rendered as red reference markers. Neither
    # marker uses shader TIME, a particle buffer or GPU feedback.
    draw_rect(Rect2(60+fmod(expected_time*8.0,448.0),216,8,8),Color.RED)
    draw_rect(Rect2(60+fmod(standard_time,40.0)*4.0,296,8,8),Color.RED)

export type GodotProjectType = "Godot 2D" | "Godot 3D";

export interface ProjectTemplateFile {
	name: string;
	content: string;
}

export function isGodotProjectType(type: string): type is GodotProjectType {
	return type === "Godot 2D" || type === "Godot 3D";
}

// Native Godot resources and procedural graphics work without an editor import.
export function getGodotProjectTemplate(type: GodotProjectType, name: string): ProjectTemplateFile[] {
	const is3D = type === "Godot 3D";
	return [
		{ name: "project.godot", content: `config_version=5

[application]
config/name=${JSON.stringify(name)}
run/main_scene="res://main.tscn"

[display]
window/size/viewport_width=640
window/size/viewport_height=360
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="mobile"
renderer/rendering_method.mobile="mobile"
environment/defaults/default_clear_color=Color(0.025,0.045,0.08,1)
` },
		{ name: "main.tscn", content: `[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://main.gd" id="1"]

[node name="Main" type="${is3D ? "Node3D" : "Node2D"}"]
script = ExtResource("1")
` },
		{ name: "main.gd", content: is3D ? SCRIPT_3D : SCRIPT_2D },
		// Keep the Dora launcher last, so incomplete projects have no runnable entry.
		{ name: "init.ts", content: HOST_ENTRY },
	];
}

const SCRIPT_2D = `extends Node2D

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
`;

const SCRIPT_3D = `extends Node3D

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
`;

const HOST_ENTRY = `// @preview-file on clear
import { App, Content, Director, GodotNode, Path, View } from 'Dora';

// Godot sources and this Dora host entry share one project directory.
const reason = GodotNode.getUnsupportedReason();
if (reason !== "") {
	print(\`Godot unavailable: \${reason}\`);
} else {
	const project = Path.getPath(Content.getFullPath("project.godot"));
	const game = GodotNode(project, "", 640, 360, 3);
	if (game === undefined) {
		print("Cannot create GodotNode; check the project path and runtime.");
	} else {
		game.addTo(Director.ui);
		const started = App.runningTime;
		let ready = false;
		game.onUpdate(() => {
			const scale = Math.min(View.size.width / 640, View.size.height / 360);
			game.scaleX = scale;
			game.scaleY = scale;
			if (game.lastError !== "") {
				print(\`Godot runtime error: \${game.lastError}\`);
				game.removeFromParent();
				return true;
			}
			if (!ready && game.running) {
				ready = true;
				print("Godot project ready");
			} else if (!ready && App.runningTime - started > 60) {
				print("Godot project startup timed out");
				game.removeFromParent();
				return true;
			}
			return false;
		});
	}
}
`;

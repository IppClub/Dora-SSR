export const godotFileTypes = [
	{ name: "GDScript", extension: ".gd", description: "gdscript" },
	{ name: "Godot 2D Scene", extension: ".tscn", description: "godotScene2D" },
	{ name: "Godot 3D Scene", extension: ".tscn", description: "godotScene3D" },
	{ name: "Godot Resource", extension: ".tres", description: "godotResource" },
	{ name: "Godot Shader", extension: ".gdshader", description: "godotShader" },
	{ name: "Godot Shader Include", extension: ".gdshaderinc", description: "godotShaderInclude" },
] as const;

export type GodotFileType = typeof godotFileTypes[number]["name"];

export function getGodotFileTemplate(extension: string, name: string, type?: GodotFileType): string | undefined {
	switch (extension) {
		case ".gd": return "extends Node\n\n\nfunc _ready() -> void:\n\tpass\n";
		case ".tscn": return `[gd_scene format=3]\n\n[node name=${JSON.stringify(name)} type="${type === "Godot 3D Scene" ? "Node3D" : "Node2D"}"]\n`;
		case ".tres": return '[gd_resource type="Resource" format=3]\n\n[resource]\n';
		case ".gdshader": return "shader_type canvas_item;\n\nvoid fragment() {\n\tCOLOR = texture(TEXTURE, UV);\n}\n";
		case ".gdshaderinc": return "// Shared Godot shader functions.\n";
		default: return undefined;
	}
}

export function getGodotFileLanguage(file: string): "gdscript" | "godot-resource" | "godot-shader" | undefined {
	switch (file.slice(file.lastIndexOf(".")).toLowerCase()) {
		case ".gd": return "gdscript";
		case ".tscn": case ".tres": case ".godot": return "godot-resource";
		case ".gdshader": case ".gdshaderinc": return "godot-shader";
		default: return undefined;
	}
}

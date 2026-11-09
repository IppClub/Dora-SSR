import godotLogo from './3rdParty/GodotIcons/Godot.svg';
import gdscript from './3rdParty/GodotIcons/GDScript.svg';
import node2D from './3rdParty/GodotIcons/Node2D.svg';
import node3D from './3rdParty/GodotIcons/Node3D.svg';
import packedScene from './3rdParty/GodotIcons/PackedScene.svg';
import resource from './3rdParty/GodotIcons/Object.svg';
import shader from './3rdParty/GodotIcons/Shader.svg';
import shaderInclude from './3rdParty/GodotIcons/ShaderInclude.svg';
import type { GodotFileType } from './GodotFiles';

export { godotLogo };

export const godotTypeIcons: Record<GodotFileType, string> = {
	'GDScript': gdscript,
	'Godot 2D Scene': node2D,
	'Godot 3D Scene': node3D,
	'Godot Resource': resource,
	'Godot Shader': shader,
	'Godot Shader Include': shaderInclude,
};

export function getGodotFileIcon(file: string): string | undefined {
	switch (file.slice(file.lastIndexOf('.')).toLowerCase()) {
		case '.godot': return godotLogo;
		case '.gd': return gdscript;
		case '.tscn': return packedScene;
		case '.tres': return resource;
		case '.gdshader': return shader;
		case '.gdshaderinc': return shaderInclude;
		default: return undefined;
	}
}

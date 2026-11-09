// @preview-file off clear
import { Content, Path, Log } from 'Dora';
import { checkGodotFile } from 'Agent/Tool/GodotCheck';
import type { BuildMessage } from 'Agent/Tool/Build';

export const GODOT_RUNTIME_VERSION = '4.7.2';
const activeProjects = new Set<string>();
export type GodotBuildResult = BuildMessage & { messages: BuildMessage[] };

export function findGodotProject(workDir: string, target: string): string | undefined {
	workDir = Path(workDir);
	target = Path(target);
	let dir = Content.isdir(target) ? target : Path.getPath(target);
	while (dir === workDir || dir.startsWith(`${workDir}/`)) {
		if (Content.exist(Path(dir, 'project.godot'))) return dir;
		if (dir === workDir) break;
		const parent = Path.getPath(dir);
		if (parent === dir) break;
		dir = parent;
	}
	return undefined;
}


// Build uses exactly the same bundled runtime compiler as live editor checks.
// Imported asset generation is separate; it is not silently delegated to an
// installed editor or reported as successful by this static validation pass.
export async function buildGodotProject(project: string, cancelled?: () => boolean): Promise<GodotBuildResult> {
	project = Path(project);
	const file = Path(project, 'project.godot');
	const completed: BuildMessage[] = [];
	const finish = (result: BuildMessage): GodotBuildResult => ({ ...result, messages: result.success ? completed : [...completed, result] });
	if (activeProjects.has(project)) return finish({ success: false, file, failureKind: 'tool', message: 'A Godot build is already running for this project.' });
	activeProjects.add(project);
	try {
		const [format] = string.match(Content.load(file) ?? '', 'config_version%s*=%s*(%d+)');
		if (format !== '5') return finish({ success: false, file, message: 'Expected a Godot 4 project (config_version=5).' });
		const main = Content.load(file) ?? '';
		if (main.split('\n').some(line => line.trim().startsWith('config/features') && line.includes('"C#"'))
			|| Content.glob(project, ['**/*.gdextension', '!**/.*/**', '!**/node_modules/**']).length > 0)
			return finish({ success: false, file, message: 'Dora Godot projects do not support C#/Mono or native GDExtension sidecars.' });
		for (const relative of ['project.godot', ...Content.glob(project, ['**/*.gd', '**/*.tscn', '**/*.tres', '**/*.gdshader', '**/*.gdshaderinc', '!**/.*/**', '!**/node_modules/**', '!**/build/**', '!**/dist/**'])]) {
			if (cancelled?.() === true) return finish({ success: false, file, interrupted: true, failureKind: 'tool', message: 'Godot build canceled.' });
			const target = Path(project, relative);
			const content = Content.load(target);
			if (content === undefined) return finish({ success: false, file: target, message: 'Cannot read Godot source file.' });
			const checked = await checkGodotFile(project, target, content, false);
			if (checked.skipped) return finish({ success: false, file: target, failureKind: 'tool', message: 'Godot check was superseded by a newer editor request; retry the build.' });
			if (!checked.success) return finish({ success: false, file: target,
				failureKind: checked.info?.some(item => item[0] === 'tool') ? 'tool' : undefined,
				message: (checked.info ?? []).map(item => `res://${Path.getRelative(item[1], project)}:${item[2]}:${item[3]}: ${item[4]}`).join('\n') || 'Embedded Godot compiler check failed.' });
			completed.push({ success: true, file: target, message: 'Godot validation passed (bundled runtime).' });
			// User-visible build output must not be filtered by Agent debug levels.
			Log('Info', `Built Godot ${Path(Path.getFilename(project), relative)}`);
		}
		return finish({ success: true, file, message: `${completed.length} Godot file(s) passed validation.` });
	} finally {
		activeProjects.delete(project);
	}
}

// @preview-file off clear
import { App, Content, Director, Path, Process, once, sleep } from 'Dora';
import { ensureDirPath } from 'Agent/Tool/Workspace';
import { sendWebIDERefreshTree } from 'Agent/Tool/WebIDESync';
import type { BuildMessage } from 'Agent/Tool/Build';

// Keep in sync with the runtime's pinned Source/3rdParty/Godot/UPSTREAM.json.
export const GODOT_EDITOR_VERSION = '4.7.2';
const TIMEOUT_SECONDS = 120;
const OUTPUT_LIMIT = 32768;
const activeProjects = new Set<string>();

declare const _studio_agent_tool_begin: unknown;

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

interface CommandResult {
	success: boolean;
	output: string;
	interrupted?: boolean;
	toolFailure?: boolean;
}

// Only the trusted build tool can start this fixed editor command. No shell,
// project-provided command line, or Process handle is exposed to the model.
function runEditor(program: string, args: string[], project: string, cancelled?: () => boolean): CommandResult {
	const handle = Process.spawn({ program, args, cwd: project, env: { NO_COLOR: '1' } });
	if (handle === undefined) return { success: false, output: `Cannot start Godot editor: ${program}`, toolFailure: true };
	let stdoutOffset = 0, stderrOffset = 0, output = '', diagnosticError = false;
	const deadline = App.runningTime + TIMEOUT_SECONDS;
	try {
		Process.write(handle);
		while (true) {
			const result = Process.read(handle, stdoutOffset, stderrOffset);
			stdoutOffset = result.stdoutOffset;
			stderrOffset = result.stderrOffset;
			output += result.stdout + result.stderr;
			if (output.includes('ERROR:') || output.includes('SCRIPT ERROR:')) diagnosticError = true;
			if (output.length > OUTPUT_LIMIT) {
				return { success: false, output: `${output.slice(0, OUTPUT_LIMIT)}\nGodot output exceeded the build diagnostic limit.`, toolFailure: true };
			}
			if (cancelled?.() === true) return { success: false, output: 'Godot build canceled.', interrupted: true, toolFailure: true };
			if (!result.running) return {
				success: result.exit.exitCode === 0 && !diagnosticError,
				output: output.trim() || `Godot editor exited with code ${result.exit.exitCode ?? 'unknown'}.`,
			};
			if (App.runningTime >= deadline) return { success: false, output: `${output}\nGodot editor timed out.`, toolFailure: true };
			sleep(0.02);
		}
	} finally {
		// stop is harmless after exit; always reap the handle, including exceptions.
		Process.stop(handle, 'kill-tree');
		Process.destroy(handle);
	}
}

function editorCandidates(): string[] {
	const configured = os.getenv('DORA_GODOT_EDITOR');
	if (configured !== undefined && configured.trim() !== '') {
		return [configured.endsWith('.app') ? Path(configured, 'Contents/MacOS/Godot') : configured];
	}
	return App.platform === 'macOS'
		? ['/Applications/Godot.app/Contents/MacOS/Godot', 'godot', 'godot4']
		: ['godot', 'godot4'];
}

const VALIDATE_SCRIPT = `extends SceneTree

var failed := false

func _initialize() -> void:
    inspect_directory("res://")
    var main_scene := str(ProjectSettings.get_setting("application/run/main_scene", ""))
    if main_scene.is_empty() or not ResourceLoader.exists(main_scene):
        push_error("Godot project main scene is missing: " + main_scene)
        failed = true
    elif not ResourceLoader.load(main_scene) is PackedScene:
        push_error("Godot project main scene must be a PackedScene: " + main_scene)
        failed = true
    quit(1 if failed else 0)

func inspect_directory(path: String) -> void:
    var directory := DirAccess.open(path)
    if directory == null:
        push_error("Cannot inspect Godot directory: " + path)
        failed = true
        return
    for file in directory.get_files():
        var extension := file.get_extension().to_lower()
        if extension in ["gd", "tscn", "tres", "gdshader"]:
            var resource_path := path.path_join(file)
            if ResourceLoader.load(resource_path) == null:
                push_error("Cannot load Godot resource: " + resource_path)
                failed = true
    for child in directory.get_directories():
        if not child.begins_with(".") and not child in ["node_modules", "build", "dist"]:
            inspect_directory(path.path_join(child))
`;

function validateGodotProject(project: string, cancelled?: () => boolean): BuildMessage {
	const file = Path(project, 'project.godot');
	const settings = Content.load(file) ?? '';
	const [format] = string.match(settings, 'config_version%s*=%s*(%d+)');
	if (format !== '5') {
		return { success: false, file, message: 'Expected a Godot 4 project (config_version=5); automatic project conversion is not part of build.' };
	}
	if (settings.split('\n').some(line => line.trim().startsWith('config/features') && line.includes('"C#"'))
		|| Content.glob(project, ['**/*.gdextension', '!**/.*/**', '!**/node_modules/**']).length > 0) {
		return { success: false, file, message: 'Dora Godot projects do not support Godot C#/Mono or native GDExtension sidecars.' };
	}
	let editor: string | undefined;
	let lastFailure = '';
	for (const candidate of editorCandidates()) {
		const version = runEditor(candidate, ['--version'], project, cancelled);
		if (version.interrupted) { return { success: false, file, message: version.output, interrupted: true, failureKind: 'tool' }; }
		if (version.success && version.output.startsWith(`${GODOT_EDITOR_VERSION}.stable`)) { editor = candidate; break; }
		lastFailure = `${candidate}: ${version.output}`;
	}
	if (editor === undefined) {
		return { success: false, file, failureKind: 'tool', message: `Set DORA_GODOT_EDITOR to a Godot ${GODOT_EDITOR_VERSION} stable editor executable. ${lastFailure}` };
	}
	const dir = Path(project, '.agent/godot');
	const script = Path(dir, 'validate.gd');
	if (!ensureDirPath(dir) || !Content.save(script, VALIDATE_SCRIPT)) {
		return { success: false, file, failureKind: 'tool', message: 'Cannot prepare Godot resource validation script.' };
	}
	const imported = runEditor(editor, ['--headless', '--quiet', '--path', project, '--editor', '--import'], project, cancelled);
	Content.save(Path(dir, 'import.log'), imported.output);
	sendWebIDERefreshTree();
	if (!imported.success) {
		return { success: false, file, message: imported.output, interrupted: imported.interrupted, failureKind: imported.toolFailure ? 'tool' : undefined };
	}
	const checked = runEditor(editor, ['--headless', '--quiet', '--path', project, '--script', script], project, cancelled);
	Content.save(Path(dir, 'validate.log'), checked.output);
	return checked.success ? { success: true, file } : { success: false, file, message: checked.output, interrupted: checked.interrupted, failureKind: checked.toolFailure ? 'tool' : undefined };
}

export function buildGodotProject(project: string, cancelled?: () => boolean): Promise<BuildMessage> {
	project = Path(project);
	const file = Path(project, 'project.godot');
	if (typeof _studio_agent_tool_begin === 'function') {
		return Promise.resolve({ success: false, file, failureKind: 'tool', message: 'Godot game development is not supported in Dora Studio. Use the desktop Dora Web IDE.' });
	}
	if (App.platform !== 'macOS' && App.platform !== 'Windows' && App.platform !== 'Linux') {
		return Promise.resolve({ success: false, file, failureKind: 'tool', message: 'Godot import and validation require a desktop Dora host with a matching Godot editor; this runtime has no editor build service.' });
	}
	if (activeProjects.has(project)) return Promise.resolve({ success: false, file, failureKind: 'tool', message: 'A Godot build is already running for this project. Wait for it to complete before retrying.' });
	return new Promise(resolve => {
		activeProjects.add(project);
		try {
			Director.systemScheduler.schedule(once(() => {
				let result: BuildMessage;
				try {
					result = validateGodotProject(project, cancelled);
				} catch (error) {
					result = { success: false, file, failureKind: 'tool', message: `Godot build failed: ${tostring(error)}` };
				} finally {
					activeProjects.delete(project);
				}
				resolve(result);
			}));
		} catch (error) {
			activeProjects.delete(project);
			resolve({ success: false, file, failureKind: 'tool', message: `Cannot schedule Godot build: ${tostring(error)}` });
		}
	});
}

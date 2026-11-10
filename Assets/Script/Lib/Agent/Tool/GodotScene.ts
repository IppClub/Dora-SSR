// @preview-file off clear
import { Content, Director, GodotNode, Path, once, sleep } from 'Dora';
import { safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import { resolveWorkspaceDirectoryPath, resolveWorkspaceFilePath } from 'Agent/Tool/Workspace';
import { findGodotProject } from 'Agent/Tool/GodotBuild';

declare const _studio_agent_tool_begin: unknown;
export interface GodotSceneResult {
	success: boolean;
	path?: string;
	message?: string;
	line?: number;
	nodes?: Record<string, unknown>[];
	resources?: Record<string, unknown>[];
	subresources?: Record<string, unknown>[];
	connections?: Record<string, unknown>[];
	warnings?: string[];
	nodeCount?: number;
	matchedNodeCount?: number;
	truncated?: boolean;
}

async function inspect(workDir: string, options: Record<string, unknown>, isCancelled: () => boolean): Promise<GodotSceneResult> {
	const path = typeof options.path === 'string' ? options.path.trim() : '';
	const failure = (message: string): GodotSceneResult => ({success: false, path, message});
	if (typeof _studio_agent_tool_begin === 'function') return failure('Godot development is not supported in Dora Studio. Use desktop Dora.');
	if (isCancelled()) return failure('Static scene inspection cancelled.');
	const file = resolveWorkspaceFilePath(workDir, path);
	if (file === undefined || !Content.exist(file) || Content.isdir(file)) return failure('path must identify an existing workspace-relative .tscn file.');
	if (Path.getExt(file).toLowerCase() !== 'tscn') return failure('Static inspection supports .tscn text scenes; binary .scn is not supported.');
	let project: string | undefined;
	if (options.project !== undefined) {
		if (typeof options.project !== 'string') return failure('project must be a workspace-relative directory.');
		const directory = resolveWorkspaceDirectoryPath(workDir, options.project);
		if (directory.success === false) return failure(directory.message);
		project = directory.path;
	} else project = findGodotProject(workDir, file);
	if (project === undefined || !Content.exist(Path(project, 'project.godot'))) return failure('No enclosing Godot source project was found.');
	const relative = Path.getRelative(file, project).split('\\').join('/');
	if (relative === '..' || relative.startsWith('../') || Content.isAbsolutePath(relative)) return failure('Scene must be inside the selected Godot project.');
	const [version] = string.match(Content.load(Path(project, 'project.godot')) ?? '', 'config_version%s*=%s*(%d+)');
	if (version !== '5') return failure('Only Godot 4 source projects are supported.');
	if (GodotNode === undefined || typeof GodotNode.inspectSceneAsync !== 'function') return failure('Rebuild Dora with the bundled static scene inspection bridge.');
	const query: Record<string, unknown> = {maxNodes: 128, maxProperties: 64};
	for (const key of ['maxNodes', 'maxProperties']) {
		const value = options[key];
		const minimum = key === 'maxNodes' ? 1 : 0, maximum = key === 'maxNodes' ? 512 : 128;
		if (value !== undefined && (typeof value !== 'number' || !Number.isFinite(value) || math.floor(value) !== value || value < minimum || value > maximum)) return failure(`${key} must be an integer from ${minimum} to ${maximum}.`);
		if (value !== undefined) query[key] = value;
	}
	if (options.nodePath !== undefined) {
		if (typeof options.nodePath !== 'string') return failure('nodePath must be a scene-relative node path.');
		query.nodePath = options.nodePath;
	}
	const resolvedProject = project;
	const [encoded] = safeJsonEncode(query);
	if (!encoded) return failure('Cannot encode scene inspection options.');
	return new Promise(resolve => {
		Director.systemScheduler.schedule(once(() => {
			if (isCancelled()) {resolve(failure('Static scene inspection cancelled.'));return;}
			let result: GodotSceneResult | undefined;
			try {
				GodotNode.inspectSceneAsync(resolvedProject, file, encoded, (available, text) => {
					if (!available) {result = failure(text);return;}
					const [decoded] = safeJsonDecode(text);
					const value = decoded as GodotSceneResult;
					result = type(value) === 'table' && type(value.success) === 'boolean'
						&& (value.success ? Array.isArray(value.nodes) && Array.isArray(value.resources) && Array.isArray(value.connections) : type(value.message) === 'string')
						? {...value, path} : failure('Invalid response from bundled Godot scene inspector.');
				});
				while (result === undefined) sleep(0.02);
				resolve(isCancelled() ? failure('Static scene inspection cancelled.') : result);
			} catch (error) {resolve(failure(tostring(error)));}
		}));
	});
}

export function createGodotSceneInjection(req: {
	workDir: string;
	isCancelled: (this: void) => boolean;
	print: (this: void, line: string) => void;
	onResult: (this: void, result: GodotSceneResult) => void;
}): (this: void, options?: unknown) => GodotSceneResult {
	return options => {
		let result: GodotSceneResult | undefined;
		if (type(options) !== 'table') result = {success: false, message: 'inspectGodotScene expects {path, project?, nodePath?, maxNodes?, maxProperties?}.'};
		else inspect(req.workDir, options as Record<string, unknown>, () => req.isCancelled()).then(value => {result = value;}, error => {result = {success: false, message: tostring(error)};});
		while (result === undefined) sleep();
		const [encoded] = safeJsonEncode(result);
		if (encoded) req.print(encoded);
		req.onResult(result);
		return result;
	};
}

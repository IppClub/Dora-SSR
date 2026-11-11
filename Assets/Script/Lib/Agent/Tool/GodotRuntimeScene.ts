// @preview-file off clear
import { Content, Director, GodotNode, Path, once, sleep } from 'Dora';
import { safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import { resolveWorkspaceDirectoryPath } from 'Agent/Tool/Workspace';

declare const _studio_agent_tool_begin: unknown;
export interface GodotRuntimeSceneResult {
	success: boolean;
	message?: string;
	nodePath?: string;
	nodes?: Record<string, unknown>[];
	returnedNodeCount?: number;
	visitedNodeCount?: number;
	truncated?: boolean;
	maxNodes?: number;
	maxBytes?: number;
}
async function inspect(workDir: string, options: Record<string, unknown>, isCancelled: () => boolean): Promise<GodotRuntimeSceneResult> {
	const failure = (message: string): GodotRuntimeSceneResult => ({success: false, message});
	if (typeof _studio_agent_tool_begin === 'function') return failure('Godot development is not supported in Dora Studio. Use desktop Dora.');
	if (isCancelled()) return failure('Live scene inspection cancelled.');
	for (const key of Object.keys(options)) if (!['project', 'nodePath', 'nodeType', 'maxNodes', 'properties'].includes(key)) return failure(`Unknown live scene option: ${key}`);
	if (options.project !== undefined && typeof options.project !== 'string') return failure('project must be a workspace-relative directory.');
	const directory = resolveWorkspaceDirectoryPath(workDir, options.project as string ?? '.');
	if (directory.success === false) return failure(directory.message);
	if (!Content.exist(Path(directory.path, 'project.godot'))) return failure('project must identify a Godot source project directory.');
	if (GodotNode === undefined || typeof GodotNode.inspectRuntimeSceneAsync !== 'function') return failure('Rebuild Dora with the bundled live scene inspection bridge.');
	const query: Record<string, unknown> = {nodePath: '.', maxNodes: 128};
	if (options.nodePath !== undefined) {
		if (typeof options.nodePath !== 'string' || options.nodePath.length > 1024) return failure('nodePath must be a relative path of at most 1024 characters.');
		query.nodePath = options.nodePath;
	}
	if (options.nodeType !== undefined) {
		if (typeof options.nodeType !== 'string' || options.nodeType.length < 1 || options.nodeType.length > 64) return failure('nodeType must be an exact native class name of 1 to 64 characters.');
		query.nodeType = options.nodeType;
	}
	if (options.maxNodes !== undefined) {
		const n = options.maxNodes;
		if (typeof n !== 'number' || !Number.isFinite(n) || math.floor(n) !== n || n < 1 || n > 256) return failure('maxNodes must be an integer from 1 to 256.');
		query.maxNodes = n;
	}
	if (options.properties !== undefined) {
		const names = options.properties;
		if (!Array.isArray(names) || names.length > 32 || names.some(name => typeof name !== 'string' || name.length < 1 || name.length > 128)) return failure('properties must contain at most 32 property names of 1 to 128 characters.');
		query.properties = names;
	}
	const [encoded] = safeJsonEncode(query);
	if (!encoded || encoded.length > 8192) return failure('Live scene query exceeds 8 KiB.');
	return new Promise(resolve => {
		Director.systemScheduler.schedule(once(() => {
			if (isCancelled()) {resolve(failure('Live scene inspection cancelled.'));return;}
			let result: GodotRuntimeSceneResult | undefined;
			try {
				GodotNode.inspectRuntimeSceneAsync(directory.path, encoded, (available, text) => {
					if (!available) {result = failure(text);return;}
					if (text.length > 128 * 1024) {result = failure('Live scene response exceeds 128 KiB.');return;}
					const [decoded] = safeJsonDecode(text);
					const value = decoded as GodotRuntimeSceneResult;
					result = type(value) === 'table' && type(value.success) === 'boolean'
						&& (value.success ? Array.isArray(value.nodes) : type(value.message) === 'string')
						? value : failure('Invalid response from bundled live scene inspector.');
				});
				while (result === undefined) sleep(0.02);
				resolve(isCancelled() ? failure('Live scene inspection cancelled.') : result);
			} catch (error) {resolve(failure(tostring(error)));}
		}));
	});
}
export function createGodotRuntimeSceneInjection(req: {
	workDir: string;
	isCancelled: (this: void) => boolean;
	print: (this: void, line: string) => void;
	onResult: (this: void, result: GodotRuntimeSceneResult) => void;
}): (this: void, options?: unknown) => GodotRuntimeSceneResult {
	return options => {
		let result: GodotRuntimeSceneResult | undefined;
		if (options !== undefined && type(options) !== 'table') result = {success: false, message: 'inspectGodotRuntimeScene expects {project?, nodePath?, nodeType?, maxNodes?, properties?}.'};
		else inspect(req.workDir, options as Record<string, unknown> ?? {}, () => req.isCancelled()).then(value => {result = value;}, error => {result = {success: false, message: tostring(error)};});
		while (result === undefined) sleep();
		const [encoded] = safeJsonEncode(result);
		if (encoded) req.print(encoded);
		req.onResult(result);
		return result;
	};
}

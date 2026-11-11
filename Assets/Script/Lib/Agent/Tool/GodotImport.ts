// @preview-file off clear
import { App, Content, Director, GodotNode, Path, once, sleep } from 'Dora';
import { safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import { resolveWorkspaceDirectoryPath, resolveWorkspaceFilePath } from 'Agent/Tool/Workspace';

declare const _studio_agent_tool_begin: unknown;
export interface GodotAssetImportSettings {
	mipmaps?: boolean;
	loop?: boolean;
	loopOffsetSeconds?: number;
}
export interface GodotImportResult {
	success: boolean;
	path: string;
	status: 'imported' | 'skipped' | 'failed';
	message: string;
	output?: string;
	settings?: GodotAssetImportSettings;
}

export interface GodotImportBatchResult {
	success: boolean;
	message?: string;
	cancelled?: boolean;
	requestedCount: number;
	importedCount: number;
	skippedCount: number;
	failedCount: number;
	results: GodotImportResult[];
}

function batchFailure(message: string): GodotImportBatchResult {
	return {success: false, message, requestedCount: 0, importedCount: 0, skippedCount: 0, failedCount: 0, results: []};
}

export async function importGodotAssets(workDir: string, project: string, paths: string[], force = false,
	isCancelled: () => boolean = () => false, settings: Record<string, GodotAssetImportSettings> = {}): Promise<GodotImportBatchResult> {
	const results: GodotImportResult[] = [];
	const failed = (path: string, message: string): GodotImportResult => ({success: false, path, status: 'failed', message});
	const directory = resolveWorkspaceDirectoryPath(workDir, project);
	let unavailable: string | undefined;
	if (typeof _studio_agent_tool_begin === 'function') unavailable = 'Godot development is not supported in Dora Studio. Use desktop Dora.';
	else if (App.platform !== 'Windows' && App.platform !== 'macOS' && App.platform !== 'Linux') unavailable = 'Embedded Godot asset importing is available on desktop only.';
	else if (directory.success === false) unavailable = directory.message;
	else if (!Content.exist(Path(directory.path, 'project.godot'))) unavailable = 'project must identify a Godot source project directory.';
	else if (GodotNode === undefined || typeof GodotNode.importAssetAsync !== 'function') unavailable = 'Rebuild Dora with the embedded Godot asset-import bridge.';
	if (unavailable !== undefined || directory.success === false) return batchFailure(unavailable ?? 'Invalid Godot project directory.');
	const projectSettings = Content.load(Path(directory.path, 'project.godot')) ?? '';
	const [version] = string.match(projectSettings, 'config_version%s*=%s*(%d+)');
	if (version !== '5') return batchFailure('Only Godot 4 source projects are supported.');
	for (const path of paths) {
		if (isCancelled()) break;
		const file = resolveWorkspaceFilePath(workDir, path);
		const relative = file === undefined ? '..' : Path.getRelative(file, directory.path).split('\\').join('/');
		if (file === undefined || relative === '..' || relative.startsWith('../') || Content.isAbsolutePath(relative)) {
			results.push(failed(path, 'Asset path must be inside the selected project and workspace.'));
			continue;
		}
		const result = await new Promise<GodotImportResult>(resolve => {
			Director.systemScheduler.schedule(once(() => {
				let result: GodotImportResult | undefined;
				try {
					const [options] = safeJsonEncode({force, ...(settings[path] !== undefined ? {settings: settings[path]} : {})}, false, false);
					if (!options) {resolve(failed(path, 'Cannot encode asset import settings.')); return;}
					GodotNode.importAssetAsync(directory.path, file, options, (available, text) => {
						if (!available) { result = failed(path, text); return; }
						const [decoded] = safeJsonDecode(text);
						const value = decoded as GodotImportResult;
						result = type(value) === 'table' && type(value.success) === 'boolean' && type(value.message) === 'string'
							&& (value.status === 'imported' || value.status === 'skipped' || value.status === 'failed')
							? {...value, path} as GodotImportResult : failed(path, 'Invalid response from embedded Godot importer.');
					});
					while (result === undefined) sleep(0.02);
					resolve(result);
				} catch (error) { resolve(failed(path, tostring(error))); }
			}));
		});
		results.push(result);
	}
	return {
		success: results.length === paths.length && results.every(result => result.success),
		cancelled: isCancelled(),
		requestedCount: paths.length,
		importedCount: results.filter(result => result.status === 'imported').length,
		skippedCount: results.filter(result => result.status === 'skipped').length,
		failedCount: results.filter(result => !result.success).length,
		results,
	};
}

/** Synchronous Lua injection; yields the command coroutine while native work runs. */
export function createGodotImportInjection(req: {
	workDir: string;
	isCancelled: () => boolean;
	print: (this: void, line: string) => void;
	onResult: (this: void, result: GodotImportBatchResult) => void;
}): (this: void, options?: unknown) => GodotImportBatchResult {
	return options => {
		const complete = (result: GodotImportBatchResult): GodotImportBatchResult => {
			const [encoded] = safeJsonEncode(result);
			if (encoded) req.print(encoded);
			req.onResult(result);
			return result;
		};
		if (type(options) !== 'table') return complete(batchFailure('importGodotAssets expects {project, paths, force?, settings?}.'));
		const opts = options as Record<string, unknown>;
		const project = typeof opts.project === 'string' ? opts.project.trim() : '.';
		const paths = opts.paths;
		if (project === '' || !Array.isArray(paths) || paths.length < 1 || paths.length > 64
			|| paths.some(path => typeof path !== 'string' || path.trim() === '')) {
			return complete(batchFailure('Supply a project and 1 to 64 explicit workspace-relative asset paths.'));
		}
		if (opts.force !== undefined && typeof opts.force !== 'boolean') return complete(batchFailure('force must be boolean.'));
		const settings: Record<string, GodotAssetImportSettings> = {};
		if (opts.settings !== undefined) {
			if (type(opts.settings) !== 'table') return complete(batchFailure('settings must map requested asset paths to setting objects.'));
			const supplied = opts.settings as Record<string, unknown>;
			for (const path of Object.keys(supplied)) {
				if (!(paths as string[]).includes(path) || type(supplied[path]) !== 'table') return complete(batchFailure('Each settings key must be an exact path in paths, with a setting object.'));
				const values = supplied[path] as Record<string, unknown>;
				for (const key of Object.keys(values)) {
					const value = values[key];
					if (key === 'mipmaps' || key === 'loop') {
						if (typeof value !== 'boolean') return complete(batchFailure(`${key} must be boolean.`));
					} else if (key === 'loopOffsetSeconds') {
						if (typeof value !== 'number' || !Number.isFinite(value) || value < 0) return complete(batchFailure('loopOffsetSeconds must be a finite non-negative number.'));
					} else return complete(batchFailure(`Unknown import setting: ${key}.`));
				}
				settings[path] = values as GodotAssetImportSettings;
			}
		}
		let result: GodotImportBatchResult | undefined;
		importGodotAssets(req.workDir, project, paths as string[], opts.force === true, () => req.isCancelled(), settings)
			.then(value => {result = value;}, error => {result = batchFailure(tostring(error));});
		while (result === undefined) sleep();
		return complete(result);
	};
}

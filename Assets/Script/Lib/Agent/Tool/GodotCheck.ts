// @preview-file off clear
import { Content, Director, GodotNode, Path, once, sleep } from 'Dora';
import { safeJsonDecode } from 'Agent/Utils';

type Diagnostic = ['syntax' | 'tool', string, number, number, string];
export interface GodotCheckResult {
	success: boolean;
	skipped?: boolean;
	info?: Diagnostic[];
}

const pending = new Map<string, number>();
const active = new Set<string>();
let sequence = 0;
declare const _studio_agent_tool_begin: unknown;

// Current editor contents go directly to the bundled runtime's native parser.
// No subprocess, editor executable, project copy or source-file write.
export function checkGodotFile(project: string, file: string, content: string, coalesce = true): Promise<GodotCheckResult> {
	const failure = (message: string): GodotCheckResult => ({ success: false, info: [['tool', file, 1, 0, message]] });
	if (typeof _studio_agent_tool_begin === 'function') return Promise.resolve(failure('Godot game development is not supported in Dora Studio. Use the desktop Dora Web IDE.'));
	project = Path.getPath(Path(project, 'project.godot'));
	file = Path(file, '');
	const relative = Path.getRelative(file, project).split('\\').join('/');
	if (relative === '' || relative === '.' || relative === '..' || relative.startsWith('../') || Content.isAbsolutePath(relative))
		return Promise.resolve(failure('Godot check target is outside the project.'));
	const settings = Content.load(Path(project, 'project.godot')) ?? '';
	const [format] = string.match(settings, 'config_version%s*=%s*(%d+)');
	if (format !== '5') return Promise.resolve(failure('Embedded checks require a Godot 4 project (config_version=5).'));
	if (settings.split('\n').some(line => line.trim().startsWith('config/features') && line.includes('"C#"'))
		|| Content.glob(project, ['**/*.gdextension', '!**/.*/**', '!**/node_modules/**']).length > 0)
		return Promise.resolve(failure('Embedded checks do not load Godot C#/Mono or native GDExtension sidecars.'));
	if (GodotNode === undefined || typeof GodotNode.checkCodeAsync !== 'function') return Promise.resolve(failure('This Dora host has no embedded Godot compiler API; rebuild Dora.'));
	const id = ++sequence;
	if (coalesce) pending.set(project, id);
	const cancelled = () => coalesce && pending.get(project) !== id;
	return new Promise(resolve => {
		Director.systemScheduler.schedule(once(() => {
			while (active.has(project) && !cancelled()) sleep(0.02);
			if (cancelled()) { resolve({ success: true, skipped: true }); return; }
			active.add(project);
			try {
				let result: GodotCheckResult | undefined;
				GodotNode.checkCodeAsync(project, file, content, (available, text) => {
					if (!available) { result = failure(text); return; }
					const [decoded] = safeJsonDecode(text);
					result = type(decoded) === 'table' && type((decoded as GodotCheckResult).success) === 'boolean'
						? decoded as GodotCheckResult : failure('Invalid diagnostics from embedded Godot compiler.');
				});
				// The callback owns the request until the render-thread check completes.
				while (result === undefined) sleep(0.02);
				resolve(cancelled() ? { success: true, skipped: true } : result);
			} catch (error) {
				resolve(cancelled() ? { success: true, skipped: true } : failure(tostring(error)));
			} finally {
				active.delete(project);
			}
		}));
	});
}

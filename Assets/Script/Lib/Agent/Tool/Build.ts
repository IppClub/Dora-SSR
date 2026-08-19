// @preview-file off clear
import { Content, Path, Director, once, Node, emit, wait, App, HttpServer } from 'Dora';
import { Log, safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import { sendWebIDEFileUpdate } from 'Agent/Tool/WebIDESync';
import {
	resolveWorkspaceSearchPath,
	toWorkspaceRelativePath,
	listFiles,
	codeExtensions,
} from 'Agent/Tool/Workspace';

export type BuildMessage = {
	success: true;
	file: string;
} | {
	success: false;
	file: string;
	message: string;
	interrupted?: boolean;
};

export type BuildResult = {
	success: true;
	message: string;
	total: number;
	passed: number;
	failed: 0;
	messages: BuildMessage[];
} | {
	success: false;
	message: string;
	total?: number;
	passed?: number;
	failed?: number;
	messages?: BuildMessage[];
	interrupted?: boolean;
};

function isDtsFile(path: string): boolean {
	return Path.getExt(Path.getName(path)) === "d";
}

function isTiledEditorContent(content: string): boolean {
	return content.trim().startsWith("<?xml");
}

type SupportedBuildKind = "ts" | "xml" | "teal" | "lua" | "yue" | "yarn";

function getSupportedBuildKind(path: string): SupportedBuildKind | undefined {
	switch (Path.getExt(path)) {
		case "ts": case "tsx": return "ts";
		case "xml": return "xml";
		case "tl": return "teal";
		case "lua": return "lua";
		case "yue": return "yue";
		case "yarn": return "yarn";
		default: return undefined;
	}
}

function encodeJSON(obj: object): string | undefined {
	const [text] = safeJsonEncode(obj);
	return text;
}

async function runSingleNonTsBuild(file: string): Promise<BuildMessage> {
	return new Promise<BuildMessage>((resolve) => {
		const moduleName = "Script.Dev.WebServer";
		const { buildAsync } = require(moduleName);
		Director.systemScheduler.schedule(once(() => {
			const result = buildAsync(file);
			resolve(result);
		}));
	})
}

let transpileRequestSeq = 0;
const TRANSPILE_READY_TIMEOUT_SECONDS = 5;
const TRANSPILE_BUILD_TIMEOUT_SECONDS = 30;

export async function runSingleTsTranspile(
	file: string,
	content: string,
	projectRoot?: string,
	isCancelled?: () => boolean,
): Promise<BuildMessage> {
	let done = false;
	let ready = false;
	transpileRequestSeq += 1;
	const requestId = `agent-build-${transpileRequestSeq}`;
	let result: BuildMessage = {
		success: false,
		file,
		message: "Web IDE not connected",
	};
	if (HttpServer.wsConnectionCount === 0) {
		return result;
	}
	const listener = Node();
	listener.gslot("AppWS", (event) => {
		if (event.type !== "Receive") return;
		const [res] = safeJsonDecode(event.msg);
		if (!res || Array.isArray(res)) return;
		const payload = res as AnyTable;
		if (payload.id !== requestId) return;
		if (payload.name === "TranspileTSProbe") {
			ready = true;
			return;
		}
		if (payload.name !== "TranspileTS") return;
		if (payload.success) {
			const luaFile = Path.replaceExt(file, "lua");
			if (Content.save(luaFile, tostring(payload.luaCode))) {
				result = { success: true, file };
			} else {
				result = { success: false, file, message: `failed to save ${luaFile}` };
			}
		} else {
			result = { success: false, file, message: tostring(payload.message) };
		}
		done = true;
	});
	const probePayload = encodeJSON({ name: "TranspileTSProbe", id: requestId });
	const buildPayload = encodeJSON({
		name: "TranspileTS",
		id: requestId,
		file,
		content,
		projectRoot,
	});
	if (!probePayload || !buildPayload) {
		listener.removeFromParent();
		return { success: false, file, message: "failed to encode transpile request" };
	}
	await new Promise<void>(resolve => {
		Director.systemScheduler.schedule(once(() => {
			emit("AppWS", "Send", probePayload);
			const readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS;
			wait(() => ready
				|| HttpServer.wsConnectionCount === 0
				|| App.runningTime >= readyDeadline
				|| isCancelled?.() === true);
			if (!ready) {
				listener.removeFromParent();
				if (isCancelled?.() === true) {
					result = { success: false, file, message: "build canceled", interrupted: true };
				} else if (HttpServer.wsConnectionCount === 0) {
					result = { success: false, file, message: "Web IDE disconnected" };
				} else {
					result = { success: false, file, message: "TypeScript transpiler is not ready" };
				}
				resolve();
				return;
			}
			emit("AppWS", "Send", buildPayload);
			const buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS;
			wait(() => done
				|| HttpServer.wsConnectionCount === 0
				|| App.runningTime >= buildDeadline
				|| isCancelled?.() === true);
			if (!done) {
				listener.removeFromParent();
				if (isCancelled?.() === true) {
					result = { success: false, file, message: "build canceled", interrupted: true };
				} else if (HttpServer.wsConnectionCount === 0) {
					result = { success: false, file, message: "Web IDE disconnected" };
				} else {
					result = { success: false, file, message: "TypeScript transpile timed out" };
				}
			}
			resolve();
		}));
	});
	return result;
}

function finalizeBuildResult(workDir: string, messages: BuildMessage[]): BuildResult {
	const normalized = messages.map(m => m.success
		? ({ ...m, file: toWorkspaceRelativePath(workDir, m.file) })
		: ({ ...m, file: toWorkspaceRelativePath(workDir, m.file) }));
	const total = normalized.length;
	let failed = 0;
	for (let i = 0; i < normalized.length; i++) {
		if (!normalized[i].success) failed += 1;
	}
	const passed = total - failed;
	if (failed > 0) {
		const interrupted = normalized.some(message => !message.success && message.interrupted === true);
		return {
			success: false,
			message: interrupted ? "Build canceled." : `Build failed: ${failed}/${total} file(s) failed.`,
			total,
			passed,
			failed,
			messages: normalized,
			interrupted: interrupted || undefined,
		};
	}
	return {
		success: true,
		message: `Build passed: ${passed}/${total} file(s).`,
		total,
		passed,
		failed: 0,
		messages: normalized,
	};
}

export async function build(req: { workDir: string; path: string; isCancelled?: () => boolean }): Promise<BuildResult> {
	if (req.isCancelled?.() === true) {
		return { success: false, message: "Build canceled.", interrupted: true };
	}
	const targetRel = req.path ?? "";
	const target = resolveWorkspaceSearchPath(req.workDir, targetRel);
	if (!target) {
		return { success: false, message: "invalid path or workDir" };
	}
	if (!Content.exist(target)) {
		return { success: false, message: "path not existed" };
	}
	const messages: BuildMessage[] = [];
	if (!Content.isdir(target)) {
		const kind = getSupportedBuildKind(target);
		if (!kind) {
			return { success: false, message: "expecting a ts/tsx, tl, lua, yue or yarn file" };
		}
		if (kind === "ts") {
			const content = Content.load(target);
			if (content === undefined) {
				return { success: false, message: "failed to read file" };
			}
			if (isTiledEditorContent(content)) {
				Log("Info", `[build] skip tiled editor file=${target}`);
				return finalizeBuildResult(req.workDir, messages);
			}
			if (!sendWebIDEFileUpdate(target, true, content)) {
				return { success: false, message: "failed to encode UpdateFile request" };
			}
			if (!isDtsFile(target)) {
				messages.push(await runSingleTsTranspile(target, content, req.workDir, req.isCancelled));
			}
		} else {
			messages.push(await runSingleNonTsBuild(target));
		}
		Log("Info", `[build] file=${target} messages=${messages.length}`);
		return finalizeBuildResult(req.workDir, messages);
	}
	const listResult = listFiles({
		workDir: req.workDir,
		path: targetRel,
		globs: codeExtensions.map(e => `**/*${e}`),
		maxEntries: 10000
	});

	const relFiles = listResult.success ? listResult.files : [];
	const tsFileData: Record<string, string> = {};
	const buildQueue: { file: string; kind: SupportedBuildKind }[] = [];
	for (const rel of relFiles) {
		const file = Content.isAbsolutePath(rel) ? rel : Path(target, rel);
		const kind = getSupportedBuildKind(file);
		if (!kind) continue;
		buildQueue.push({ file, kind });
		if (kind !== "ts") {
			continue;
		}
		const content = Content.load(file);
		if (content === undefined) {
			messages.push({ success: false, file, message: "failed to read file" });
			continue;
		}
		if (isTiledEditorContent(content)) {
			Log("Info", `[build] skip tiled editor file=${file}`);
			continue;
		}
		tsFileData[file] = content;
	}
	for (let i = 0; i < buildQueue.length; i++) {
		if (req.isCancelled?.() === true) {
			return { success: false, message: "Build canceled.", messages, interrupted: true };
		}
		const { file, kind } = buildQueue[i];
		if (kind === "ts") {
			const content = tsFileData[file];
			if (content === undefined || isDtsFile(file)) {
				continue;
			}
			if (!sendWebIDEFileUpdate(file, true, content)) {
				messages.push({ success: false, file, message: "failed to encode UpdateFile request" });
				continue;
			}
			messages.push(await runSingleTsTranspile(file, content, req.workDir, req.isCancelled));
			continue;
		}
		messages.push(await runSingleNonTsBuild(file));
	}
	if (messages.length === 0) {
		Log("Info", `[build] dir=${target} messages=0 no buildable code files found`);
		return { success: false, message: "No code files were found to build." };
	}
	Log("Info", `[build] dir=${target} messages=${messages.length}`);
	return finalizeBuildResult(req.workDir, messages);
}

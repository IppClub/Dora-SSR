// @preview-file off clear
import { Content, HttpServer, emit } from 'Dora';
import { Log, safeJsonEncode } from 'Agent/Utils';
import { resolveWorkspaceFilePath } from 'Agent/Tool/Workspace';

function encodePayload(value: object): string | undefined {
	const [text] = safeJsonEncode(value);
	return text;
}

export function sendWebIDEFileUpdate(file: string, exists: boolean, content: string): boolean {
	if (HttpServer.wsConnectionCount === 0) return true;
	const payload = encodePayload({ name: "UpdateFile", file, exists, content });
	if (!payload) return false;
	emit("AppWS", "Send", payload);
	return true;
}

export function sendWebIDERefreshTree(): boolean {
	if (HttpServer.wsConnectionCount === 0) return true;
	const payload = encodePayload({ name: "RefreshTree" });
	if (!payload) return false;
	emit("AppWS", "Send", payload);
	return true;
}

export function syncWebIDEFile(file: string, warningScope = "Agent.Tools"): boolean {
	if (!Content.exist(file)) return sendWebIDEFileUpdate(file, false, "");
	if (Content.isdir(file)) return sendWebIDERefreshTree();
	let content = "";
	try {
		const [, isBinary] = Content.getAttr(file);
		if (!isBinary) {
			const loaded = Content.load(file);
			content = typeof loaded === "string" ? loaded : "";
		}
	} catch (e) {
		Log("Warn", `[${warningScope}] failed to inspect file for Web IDE update file=${file}: ${tostring(e)}`);
	}
	return sendWebIDEFileUpdate(file, true, content);
}

export function syncWorkspaceFile(workDir: string, path: string, warningScope = "Agent.Tools"): boolean {
	const target = resolveWorkspaceFilePath(workDir, path);
	if (!target) return false;
	return syncWebIDEFile(target, warningScope);
}

export function refreshWorkspaceTree(workDir: string, path?: string, warningScope = "Agent.Tools"): boolean {
	const normalized = typeof path === "string" ? path.trim() : "";
	if (normalized === "") return sendWebIDERefreshTree();
	return syncWorkspaceFile(workDir, normalized, warningScope);
}

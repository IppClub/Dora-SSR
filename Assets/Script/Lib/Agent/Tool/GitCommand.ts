// @preview-file off clear
import { Content, DB, Path, Director, Git } from 'Dora';
import { Log, safeJsonEncode } from 'Agent/Utils';
import type { ExecuteCommandMode, ExecuteCommandProgress, ExecuteCommandResult } from 'Agent/Tool/CommandTypes';
import { toCommandString as toStr, truncateCommandOutput } from 'Agent/Tool/CommandShared';
import { isHttpUrl, isSafePublicHttpUrl } from 'Agent/Tool/NetworkSafety';
import { getAgentDownloadTempRoot, cleanupPath } from 'Agent/Tool/Operation';
import { refreshWorkspaceTree } from 'Agent/Tool/WebIDESync';
import {
	resolveWorkspaceFilePath,
	resolveWorkspaceDirectoryPath,
	ensureDirPath,
} from 'Agent/Tool/Workspace';

function quoteGitArg(value: string): string {
	const [plain] = string.match(value, "^[%w%._%-%/]+$");
	if (plain !== undefined) {
		return value;
	}
	let [escaped] = string.gsub(value, "\\", "\\\\");
	[escaped] = string.gsub(escaped, '"', '\\"');
	return `"${escaped}"`;
}

function shellSplit(command: string): string[] {
	const args: string[] = [];
	let current = "";
	let quote = "";
	let escaped = false;
	for (let i = 0; i < command.length; i++) {
		const ch = command.charAt(i);
		if (escaped) {
			current += ch;
			escaped = false;
			continue;
		}
		if (ch === "\\") {
			escaped = true;
			continue;
		}
		if (quote !== "") {
			if (ch === quote) {
				quote = "";
			} else {
				current += ch;
			}
			continue;
		}
		if (ch === "'" || ch === '"') {
			quote = ch;
			continue;
		}
		if (ch === " " || ch === "\t" || ch === "\n" || ch === "\r") {
			if (current !== "") {
				args.push(current);
				current = "";
			}
			continue;
		}
		current += ch;
	}
	if (escaped) {
		current += "\\";
	}
	if (current !== "") {
		args.push(current);
	}
	return args;
}

function normalizeGitCommand(command: string): string {
	const trimmed = command.trim();
	return trimmed.slice(0, 4).toLowerCase() === "git "
		? trimmed.slice(4).trim()
		: trimmed;
}

function gitDefaultTargetFromUrl(url: string): string {
	let target = url;
	const hashIndex = target.indexOf("#");
	if (hashIndex >= 0) target = target.slice(0, hashIndex);
	const queryIndex = target.indexOf("?");
	if (queryIndex >= 0) target = target.slice(0, queryIndex);
	[target] = string.gsub(target, "/+$", "");
	const [name] = string.match(target, "([^/]+)$");
	if (name !== undefined && name !== "") target = name;
	if (target.toLowerCase().endsWith(".git")) {
		target = target.slice(0, target.length - 4);
	}
	return target !== "" ? target : "repo";
}

function parseGitCloneCommand(command: string): {
	success: true;
	url: string;
	target: string;
	ref?: string;
	depth?: string;
} | {
	success: false;
	message: string;
} | undefined {
	const args = shellSplit(normalizeGitCommand(command));
	if (args.length === 0 || args[0] !== "clone") return undefined;
	let url = "";
	let target = "";
	let ref: string | undefined;
	let depth: string | undefined;
	for (let i = 1; i < args.length; i++) {
		const arg = args[i];
		if (arg === "-b" || arg === "--branch") {
			i += 1;
			if (i >= args.length) return { success: false, message: `${arg} requires a value` };
			ref = args[i];
			continue;
		}
		if (arg === "--depth") {
			i += 1;
			if (i >= args.length) return { success: false, message: "--depth requires a value" };
			depth = args[i];
			continue;
		}
		if (arg.startsWith("--depth=")) {
			depth = arg.slice("--depth=".length);
			continue;
		}
		if (arg.startsWith("-")) {
			return { success: false, message: `unsupported clone option: ${arg}` };
		}
		if (url === "") {
			url = arg;
			continue;
		}
		if (target === "") {
			target = arg;
			continue;
		}
		return { success: false, message: `unexpected clone argument: ${arg}` };
	}
	if (url === "") return { success: false, message: "git clone requires a URL" };
	if (!isHttpUrl(url)) return { success: false, message: "git clone only supports http:// and https:// URLs" };
	if (!isSafePublicHttpUrl(url)) return { success: false, message: "git clone rejects local, private, metadata, and literal-IP destinations" };
	if (target === "") target = gitDefaultTargetFromUrl(url);
	return {
		success: true,
		url,
		target,
		ref,
		depth: depth !== undefined && depth !== "" ? depth : "1",
	};
}

function getGitHeadCommit(repoPath: string): string | undefined {
	const headPath = Path(repoPath, ".git", "HEAD");
	if (!Content.exist(headPath)) return undefined;
	const head = toStr(Content.load(headPath)).trim();
	const [ref] = string.match(head, "^ref:%s*(.-)%s*$");
	if (ref !== undefined && ref !== "") {
		const refPath = Path(repoPath, ".git", ref);
		if (Content.exist(refPath)) {
			const commit = toStr(Content.load(refPath)).trim();
			return commit !== "" ? commit : undefined;
		}
		return undefined;
	}
	return head !== "" ? head : undefined;
}

function runGitAndWait(
	repoPath: string,
	command: string,
	onStatus?: (status: Record<string, unknown>) => void,
	isCancelled?: () => boolean,
	timeout = 600,
): Promise<{ success: boolean; message?: string; status?: Record<string, unknown>; interrupted?: boolean }> {
	return new Promise(resolve => {
		let status: Record<string, unknown> | undefined;
		let jobId = 0;
		let settled = false;
		let canceled = false;
		const finish = (result: { success: boolean; message?: string; status?: Record<string, unknown>; interrupted?: boolean }) => {
			if (settled) return;
			settled = true;
			resolve(result);
		};
		const finishFromStatus = () => {
			const state = toStr(status?.state);
			if (state === "done") {
				finish({ success: true, status });
				return true;
			}
			if (state === "error" || state === "canceled") {
				const errorMessage = toStr(status?.error);
				const statusMessage = toStr(status?.message);
				finish({
					success: false,
					message: errorMessage !== "" ? errorMessage : (statusMessage !== "" ? statusMessage : (state === "canceled" ? "git command canceled" : "git command failed")),
					status,
					interrupted: state === "canceled",
				});
				return true;
			}
			return false;
		};
		jobId = Git.run(repoPath, command, (nextStatus) => {
			status = nextStatus as unknown as Record<string, unknown>;
			if (onStatus) onStatus(status);
			return finishFromStatus();
		}, "");
		if (jobId === undefined || jobId <= 0) {
			finish({ success: false, message: "failed to start git command" });
			return;
		}
		if (!status) {
			const [kind] = string.match(command, "^(%S+)");
			status = {
				id: jobId,
				state: "queued",
				kind: toStr(kind),
				repoPath,
				progress: 0,
				message: "queued",
			};
		}
		if (onStatus) onStatus(status);
		const startedAt = os.time();
		let lastEmitAt = startedAt;
		Director.systemScheduler.schedule(() => {
			if (settled) return true;
			if (!canceled && isCancelled && isCancelled()) {
				canceled = true;
				Git.cancel(jobId);
				finish({ success: false, message: "git command canceled", status, interrupted: true });
				return true;
			}
			if (finishFromStatus()) return true;
			const nowTime = os.time();
			if (nowTime - startedAt >= timeout) {
				Git.cancel(jobId);
				finish({ success: false, message: "git command timed out", status });
				return true;
			}
			if (onStatus && status && nowTime > lastEmitAt) {
				lastEmitAt = nowTime;
				onStatus(status);
			}
			return false;
		});
	});
}

function encodeJSON(obj: object): string | undefined {
	const [text] = safeJsonEncode(obj);
	return text;
}

function formatGitStatusOutput(status?: Record<string, unknown>): string {
	if (!status) return "";
	const lines: string[] = [];
	const state = toStr(status.state);
	const kind = toStr(status.kind);
	const message = toStr(status.message);
	const errorMessage = toStr(status.error);
	if (kind !== "" || state !== "") {
		lines.push([kind, state].filter(item => item !== "").join(": "));
	}
	if (message !== "") lines.push(message);
	if (errorMessage !== "") lines.push(errorMessage);
	const data = status.data;
	if (data !== undefined) {
		const dataText = encodeJSON(data as object);
		lines.push(dataText !== undefined ? dataText : tostring(data));
	}
	return truncateCommandOutput(lines.join("\n"));
}

function emitGitProgress(
	mode: ExecuteCommandMode,
	operationId: string,
	onProgress: ((progress: ExecuteCommandProgress) => void) | undefined,
	status: Record<string, unknown>,
) {
	if (!onProgress) return;
	const progress = typeof status.progress === "number" ? status.progress as number : undefined;
	const kind = toStr(status.kind);
	const message = toStr(status.message);
	const state = toStr(status.state);
	const jobId = typeof status.id === "number" ? status.id as number : undefined;
	onProgress({
		state: "running",
		mode,
		operationId,
		stage: kind !== "" ? kind : "git",
		message: message !== "" ? message : (state !== "" ? state : "running"),
		progress,
		jobId,
		gitState: state !== "" ? state : undefined,
		gitKind: kind !== "" ? kind : undefined,
	});
}

async function cloneGitToTarget(req: {
	workDir: string;
	command: string;
	operationId: string;
	timeoutSeconds: number;
	onProgress?: (progress: ExecuteCommandProgress) => void;
	isCancelled?: () => boolean;
}): Promise<ExecuteCommandResult | undefined> {
	const parsed = parseGitCloneCommand(req.command);
	if (parsed === undefined) return undefined;
	if (!parsed.success) {
		return { success: false, mode: "git", output: "", message: parsed.message, phase: "validate" };
	}
	const target = resolveWorkspaceFilePath(req.workDir, parsed.target);
	if (!target) {
		return { success: false, mode: "git", output: "", message: "invalid clone target path", phase: "validate" };
	}
	if (Content.exist(target)) {
		return { success: false, mode: "git", output: "", message: "target already exists", phase: "validate" };
	}
	const targetParent = Path.getPath(target);
	if (!ensureDirPath(targetParent)) {
		return { success: false, mode: "git", output: "", message: "failed to create target parent directory" };
	}
	const tempRoot = getAgentDownloadTempRoot();
	if (!ensureDirPath(tempRoot)) {
		return { success: false, mode: "git", output: "", message: "failed to create agent download temp directory" };
	}
	const tempPath = Path(tempRoot, `${req.operationId}.repo`);
	Content.remove(tempPath);
	const depth = parsed.depth ?? "1";
	const command = [
		"clone",
		quoteGitArg(parsed.url),
		quoteGitArg(Path.getFilename(tempPath)),
		...(parsed.ref !== undefined && parsed.ref !== "" ? ["-b", quoteGitArg(parsed.ref)] : []),
		...(depth !== "" ? ["--depth", quoteGitArg(depth)] : []),
	].join(" ");
	req.onProgress?.({
		state: "pending",
		mode: "git",
		operationId: req.operationId,
		stage: "clone",
		message: "clone pending",
		progress: 0,
	});
	const gitRes = await runGitAndWait(
		tempRoot,
		command,
		status => emitGitProgress("git", req.operationId, req.onProgress, status),
		req.isCancelled,
		req.timeoutSeconds,
	);
	if (!gitRes.success) {
		const cleanupError = cleanupPath(tempPath);
		return {
			success: false,
			mode: "git",
			output: formatGitStatusOutput(gitRes.status),
			message: gitRes.message ?? "git clone failed",
			interrupted: gitRes.interrupted || req.isCancelled?.() === true,
			cleanupError,
		};
	}
	if (!Content.move(tempPath, target)) {
		const cleanupError = cleanupPath(tempPath);
		return { success: false, mode: "git", output: formatGitStatusOutput(gitRes.status), message: "failed to move cloned repository into target path", cleanupError };
	}
	if (!refreshWorkspaceTree(req.workDir)) {
		Log("Warn", `[execute_command] failed to refresh Web IDE tree after clone target=${target}`);
	}
	const commit = getGitHeadCommit(target);
	const output = [
		formatGitStatusOutput(gitRes.status),
		`cloned ${parsed.url} to ${parsed.target}`,
		commit !== undefined ? `commit ${commit}` : "",
	].filter(item => item !== "").join("\n");
	return { success: true, mode: "git", output: truncateCommandOutput(output) };
}

function loadGitProfile(): { name: string; email: string } | undefined {
	let rows: unknown[][] | undefined;
	try {
		rows = DB.query("select name, email from GitProfile where id = 1 limit 1") as unknown[][];
	} catch {
		return undefined;
	}
	if (!rows || !rows[0]) return undefined;
	const name = toStr(rows[0][0]);
	const email = toStr(rows[0][1]);
	if (name === "" && email === "") return undefined;
	return { name, email };
}

function applyGitProfileToCommit(command: string): string {
	const args = shellSplit(command);
	if (args[0] !== "commit") return command;
	let hasName = false;
	let hasEmail = false;
	for (const arg of args) {
		if (arg === "--author-name") hasName = true;
		if (arg === "--author-email") hasEmail = true;
	}
	if (hasName && hasEmail) return command;
	const profile = loadGitProfile();
	if (!profile) return command;
	const additions: string[] = [];
	if (!hasName && profile.name !== "") {
		additions.push("--author-name", quoteGitArg(profile.name));
	}
	if (!hasEmail && profile.email !== "") {
		additions.push("--author-email", quoteGitArg(profile.email));
	}
	if (additions.length === 0) return command;
	return `${command} ${additions.join(" ")}`;
}

export async function executeGitCommand(req: {
	workDir: string;
	command: string;
	cwd?: string;
	timeoutSeconds: number;
	operationId: string;
	onProgress?: (progress: ExecuteCommandProgress) => void;
	isCancelled?: () => boolean;
}): Promise<ExecuteCommandResult> {
	let command = normalizeGitCommand(req.command ?? "");
	if (command === "") {
		return { success: false, mode: "git", output: "", message: "missing command", phase: "validate" };
	}
	const commandArgs = shellSplit(command);
	if (commandArgs.length === 0 || commandArgs[0].startsWith("-")) {
		return {
			success: false,
			mode: "git",
			output: "",
			message: "top-level Git options such as -C, --git-dir, and --work-tree are not supported; use the project-relative cwd parameter",
			phase: "validate",
		};
	}
	const cloneResult = await cloneGitToTarget({
		workDir: req.workDir,
		command,
		operationId: req.operationId,
		timeoutSeconds: req.timeoutSeconds,
		onProgress: req.onProgress,
		isCancelled: req.isCancelled,
	});
	if (cloneResult !== undefined) return cloneResult;
	const cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd);
	if (!cwd.success) {
		return { success: false, mode: "git", output: "", cwd: req.cwd, message: cwd.message, phase: "validate" };
	}
	command = applyGitProfileToCommit(command);
	req.onProgress?.({
		state: "pending",
		mode: "git",
		operationId: req.operationId,
		stage: "git",
		message: "git command pending",
		progress: 0,
	});
	const gitRes = await runGitAndWait(
		cwd.path,
		command,
		status => emitGitProgress("git", req.operationId, req.onProgress, status),
		() => req.isCancelled?.() === true,
		req.timeoutSeconds,
	);
	const output = formatGitStatusOutput(gitRes.status);
	if (!gitRes.success) {
		return {
			success: false,
			mode: "git",
			output,
			cwd: cwd.relative,
			message: gitRes.message ?? "git command failed",
			interrupted: gitRes.interrupted || req.isCancelled?.() === true,
		};
	}
	if (!refreshWorkspaceTree(req.workDir)) {
		Log("Warn", `[execute_command] failed to refresh Web IDE tree after Git command workDir=${req.workDir} cwd=${cwd.relative}`);
	}
	return { success: true, mode: "git", cwd: cwd.relative, output };
}

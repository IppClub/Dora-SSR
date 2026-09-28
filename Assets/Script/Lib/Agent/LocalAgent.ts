// @preview-file off clear
import { App, Content, DB, Director, Node, Path, Process, sleep } from "Dora";
import { safeJsonDecode, safeJsonEncode, sanitizeUTF8 } from "Agent/Utils";

export type LocalAgentProvider = "opencode" | "codex" | "zcode";

export interface LocalAgentConfig {
	id: number;
	name: string;
	provider: LocalAgentProvider;
	executable: string;
	extraArgs: string[];
	verifiedAt?: number;
	verifiedVersion?: string;
	verifiedFingerprint?: string;
}

export interface LocalAgentEvent {
	kind: "assistant" | "activity" | "command" | "stderr" | "status";
	text: string;
	resumeId?: string;
	raw?: Record<string, unknown>;
}

export interface LocalAgentRunResult {
	success: boolean;
	exitCode: number;
	message: string;
	resumeId?: string;
	stopped?: boolean;
}

export interface LocalAgentRunControl {
	stop(): void;
}

const CONFIG_TABLE = "LocalAgentConfig";
const SESSION_TABLE = "LocalAgentSession";
const SKILL_VERSION = 4;
const SKILL_MARKER = `<!-- dora-managed-skill:v${SKILL_VERSION} -->`;
const supportedPlatforms = ["Windows", "macOS", "Linux"];

function encodeJson(value: unknown): string {
	const [text] = safeJsonEncode(value);
	return text ?? "";
}

function quoteCommandArg(value: string): string {
	if (App.platform === "Windows") return `'${value.split("'").join("''")}'`;
	return `'${value.split("'").join("'\"'\"'")}'`;
}

function buildDoraCLICommand(): string | undefined {
	const executablePath = App.executablePath;
	const assetPath = Content.assetPath;
	if (executablePath === "" || assetPath === "") return undefined;
	const command = `${quoteCommandArg(executablePath)} --asset ${quoteCommandArg(assetPath)} cli`;
	return App.platform === "Windows" ? `& ${command}` : command;
}

interface DoraCommandEnvironment {
	command: string;
	env?: Record<string, string>;
	shim: boolean;
}

function waitForProcess(handle: number, timeoutSeconds: number): number | undefined {
	const startedAt = App.runningTime;
	while (App.runningTime - startedAt < timeoutSeconds) {
		const result = Process.read(handle);
		if (!result.running) {
			const exitCode = result.exit.exitCode;
			Process.destroy(handle);
			return exitCode;
		}
		sleep(0.02);
	}
	Process.stop(handle, "kill-tree");
	Process.destroy(handle);
	return undefined;
}

function prepareDoraCommandEnvironment(): DoraCommandEnvironment | undefined {
	const fallback = buildDoraCLICommand();
	if (!fallback) return undefined;
	const executablePath = App.executablePath;
	const assetPath = Content.assetPath;
	const shimDir = Path(Content.writablePath, ".agent", "local-agent-bin");
	if (!Content.exist(shimDir) && !Content.mkdir(shimDir)) return {command: fallback, shim: false};
	const windows = App.platform === "Windows";
	const shimPath = Path(shimDir, windows ? "dora.cmd" : "dora");
	const shimContent = windows
		? `@echo off\r\n"${executablePath.split("%").join("%%")}" --asset "${assetPath.split("%").join("%%")}" %*\r\n`
		: `#!/bin/sh\nexec ${quoteCommandArg(executablePath)} --asset ${quoteCommandArg(assetPath)} "$@"\n`;
	if (!Content.save(shimPath, shimContent)) return {command: fallback, shim: false};
	if (!windows) {
		const chmod = Process.spawn({program: "/bin/chmod", args: ["700", shimPath]});
		if (chmod === undefined || waitForProcess(chmod, 5) !== 0) return {command: fallback, shim: false};
	}
	const inheritedPath = os.getenv("PATH") ?? "";
	const separator = windows ? ";" : ":";
	return {
		command: "dora cli",
		shim: true,
		env: {
			PATH: inheritedPath === "" ? shimDir : `${shimDir}${separator}${inheritedPath}`,
			DORA_EXECUTABLE_PATH: executablePath,
			DORA_ASSET_PATH: assetPath,
		},
	};
}

function buildSkillContent(): string {
	return `---
name: dora-engine-coding
description: Build and validate games for the Dora SSR engine using the local Dora CLI.
---
${SKILL_MARKER}

# Dora Engine coding

Work inside the current Dora project. Dora games run in the Dora runtime, not a browser or Node.js: do not generate DOM, Canvas, browser-only, or Node-only runtime code.

- Dora injects a project-scoped \`dora\` command into this Agent process. Use \`dora cli\` directly; do not search for Dora, create aliases, or guess installation paths.
- Inspect the project before editing. The usual entry is \`init.lua\`, \`init.ts\`, \`init.yue\`, or another project entry selected by the user.
- Do not guess Dora APIs. Use \`dora cli doc search <query>\` and \`dora cli doc read <name>\` to verify them.
- Edit source files with your own file tools. TypeScript is transpiled to Lua by Dora; keep imports compatible with the Dora module declarations.
- Validate compilation with \`dora cli build <path>\`.
- Inspect the engine with \`dora cli agent status -p <project>\` and logs with \`dora cli agent log -n 200\`.
- Run a controlled game check with \`dora cli agent preview -p <project> --entry init.lua --capture-at 0.5,2\`. Preview requests are FIFO and can interrupt a user-run game because Agent validation has priority.
- Treat stdout from \`dora cli agent\` as one JSON result. stderr is diagnostic output.
- \`dora cli agent\` only accesses engine tools. It never starts Dora Agent or another third-party Agent; do not construct nested Agent scheduling.

Finish by reporting the files changed and the exact build/preview evidence you obtained.
`;
}

function ensureTables() {
	DB.exec(`CREATE TABLE IF NOT EXISTS ${CONFIG_TABLE}(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		provider TEXT NOT NULL,
		executable TEXT NOT NULL,
		extra_args TEXT NOT NULL DEFAULT '[]',
		verified_at INTEGER,
		verified_version TEXT NOT NULL DEFAULT '',
		verified_fingerprint TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	)`);
	DB.exec(`CREATE TABLE IF NOT EXISTS ${SESSION_TABLE}(
		dora_session_id INTEGER PRIMARY KEY,
		config_id INTEGER NOT NULL,
		provider TEXT NOT NULL,
		resume_id TEXT NOT NULL DEFAULT '',
		generation INTEGER NOT NULL DEFAULT 1,
		abandoned_at INTEGER,
		updated_at INTEGER NOT NULL
	)`);
}

function rowToConfig(row: (string | number | boolean)[]): LocalAgentConfig | undefined {
	const provider = tostring(row[2]) as LocalAgentProvider;
	if (provider !== "opencode" && provider !== "codex" && provider !== "zcode") return undefined;
	const [decoded] = safeJsonDecode(tostring(row[4] ?? "[]"));
	const extraArgs = Array.isArray(decoded) ? decoded.filter(value => typeof value === "string") as string[] : [];
	const verifiedAt = tonumber(row[5]);
	return {
		id: tonumber(row[0]) ?? 0,
		name: tostring(row[1]),
		provider,
		executable: tostring(row[3]),
		extraArgs,
		verifiedAt: verifiedAt && verifiedAt > 0 ? verifiedAt : undefined,
		verifiedVersion: tostring(row[6] ?? "") || undefined,
		verifiedFingerprint: tostring(row[7] ?? "") || undefined,
	};
}

export function isLocalAgentSupported(): boolean {
	return supportedPlatforms.includes(App.platform);
}

export function listConfigs(): LocalAgentConfig[] {
	ensureTables();
	const rows = DB.query(`SELECT id,name,provider,executable,extra_args,verified_at,verified_version,verified_fingerprint FROM ${CONFIG_TABLE} ORDER BY id`) ?? [];
	const result: LocalAgentConfig[] = [];
	for (let i = 0; i < rows.length; i++) {
		const config = rowToConfig(rows[i]);
		if (config) result.push(config);
	}
	return result;
}

export function getConfig(id: unknown): LocalAgentConfig | undefined {
	const configId = tonumber(id);
	return configId ? listConfigs().find(item => item.id === configId) : undefined;
}

function normalizeProvider(value: unknown): LocalAgentProvider | undefined {
	return value === "opencode" || value === "codex" || value === "zcode" ? value : undefined;
}

function normalizeArgs(value: unknown): string[] {
	if (!Array.isArray(value)) return [];
	return value.filter(item => typeof item === "string").map(item => sanitizeUTF8(item as string));
}

export function saveConfig(input: Record<string, unknown>): {success: true; id: number} | {success: false; message: string} {
	ensureTables();
	const provider = normalizeProvider(input.provider);
	const name = typeof input.name === "string" ? sanitizeUTF8(input.name).trim() : "";
	const executable = typeof input.executable === "string" ? sanitizeUTF8(input.executable).trim() : "";
	if (!provider || name === "" || executable === "") return {success: false, message: "invalid local Agent config"};
	const extraArgs = normalizeArgs(input.extraArgs);
	const encodedArgs = encodeJson(extraArgs);
	const id = tonumber(input.id);
	const t = os.time();
	if (id && id > 0) {
		const old = getConfig(id);
		if (!old) return {success: false, message: "local Agent config not found"};
		const changed = old.provider !== provider || old.executable !== executable || encodeJson(old.extraArgs) !== encodedArgs;
		DB.exec(`UPDATE ${CONFIG_TABLE} SET name=?,provider=?,executable=?,extra_args=?,verified_at=?,verified_version=?,verified_fingerprint=?,updated_at=? WHERE id=?`, [
			name, provider, executable, encodedArgs,
			changed ? 0 : (old.verifiedAt ?? 0),
			changed ? "" : (old.verifiedVersion ?? ""),
			changed ? "" : (old.verifiedFingerprint ?? ""),
			t, id,
		]);
		return {success: true, id};
	}
	DB.exec(`INSERT INTO ${CONFIG_TABLE}(name,provider,executable,extra_args,created_at,updated_at) VALUES(?,?,?,?,?,?)`, [name, provider, executable, encodedArgs, t, t]);
	const rows = DB.query("SELECT last_insert_rowid()") ?? [];
	return {success: true, id: tonumber(rows[0]?.[0]) ?? 0};
}

export function deleteConfig(id: unknown): {success: boolean; message?: string} {
	ensureTables();
	const configId = tonumber(id);
	if (!configId) return {success: false, message: "invalid local Agent config id"};
	DB.exec(`DELETE FROM ${CONFIG_TABLE} WHERE id=?`, [configId]);
	return {success: true};
}

interface SpawnSpec { program: string; args: string[]; cwd: string; env?: Record<string, string>; }

function buildSpec(config: LocalAgentConfig, cwd: string, prompt: string, resumeId?: string): SpawnSpec {
	let args: string[];
	if (config.provider === "codex") {
		args = resumeId
			? ["exec", "resume", "--json", "--dangerously-bypass-approvals-and-sandbox", ...config.extraArgs, resumeId, prompt]
			: ["exec", "--json", "--dangerously-bypass-approvals-and-sandbox", "-C", cwd, ...config.extraArgs, prompt];
	} else if (config.provider === "opencode") {
		args = ["run", "--format", "json", "--auto", "--dir", cwd, ...config.extraArgs];
		if (resumeId) args.push("--session", resumeId);
		args.push(prompt);
	} else {
		args = ["--prompt", prompt, "--json", "--mode", "yolo", "--cwd", cwd, ...config.extraArgs];
		if (resumeId) args.push("--resume", resumeId);
	}
	return {program: config.executable, args, cwd};
}

function getString(record: Record<string, unknown>, ...keys: string[]): string | undefined {
	for (let i = 0; i < keys.length; i++) {
		const value = record[keys[i]];
		if (typeof value === "string" && value !== "") return value;
	}
	return undefined;
}

function parseRecord(provider: LocalAgentProvider, record: Record<string, unknown>): LocalAgentEvent[] {
	const events: LocalAgentEvent[] = [];
	const eventType = getString(record, "type", "event", "kind") ?? "activity";
	let resumeId = getString(record, "thread_id", "threadId", "session_id", "sessionId", "sessionID");
	const item = record.item;
	if (item && typeof item === "object") {
		const itemRecord = item as Record<string, unknown>;
		resumeId = resumeId ?? getString(itemRecord, "thread_id", "session_id", "sessionId", "sessionID");
		const itemType = getString(itemRecord, "type", "kind") ?? eventType;
		let handledTool = false;
		if (provider === "codex" && itemType === "mcp_tool_call") {
			const server = getString(itemRecord, "server") ?? "mcp";
			const tool = getString(itemRecord, "tool") ?? "tool";
			const status = getString(itemRecord, "status") ?? eventType;
			const details = [`${server}.${tool} (${status})`];
			if (itemRecord.arguments !== undefined) details.push(`arguments: ${encodeJson(itemRecord.arguments)}`);
			if (itemRecord.result !== undefined && itemRecord.result !== null) details.push(`result:\n${typeof itemRecord.result === "string" ? itemRecord.result : encodeJson(itemRecord.result)}`);
			if (itemRecord.error !== undefined && itemRecord.error !== null) details.push(`error:\n${typeof itemRecord.error === "string" ? itemRecord.error : encodeJson(itemRecord.error)}`);
			events.push({kind: "command", text: details.join("\n"), resumeId, raw: record});
			handledTool = true;
		}
		if (!handledTool) {
			const text = getString(itemRecord, "text", "content", "message", "command", "aggregated_output");
			if (text) {
				const kind = itemType.includes("agent") || itemType.includes("text") || itemType.includes("message") ? "assistant"
					: itemType.includes("command") || itemType.includes("tool") ? "command" : "activity";
				events.push({kind, text, resumeId, raw: record});
			}
		}
	}
	const part = record.part;
	if (part && typeof part === "object") {
		const partRecord = part as Record<string, unknown>;
		resumeId = resumeId ?? getString(partRecord, "sessionID", "sessionId", "session_id");
		let handledTool = false;
		if (provider === "opencode" && eventType === "tool_use" && partRecord.state && typeof partRecord.state === "object") {
			const state = partRecord.state as Record<string, unknown>;
			const tool = getString(partRecord, "tool") ?? "tool";
			const status = getString(state, "status");
			const details = [`${tool}${status ? ` (${status})` : ""}`];
			if (state.input && typeof state.input === "object") details.push(`input: ${encodeJson(state.input)}`);
			const output = getString(state, "output");
			if (output) details.push(`output:\n${output}`);
			events.push({kind: "command", text: details.join("\n"), resumeId, raw: record});
			handledTool = true;
		}
		if (!handledTool) {
			const text = getString(partRecord, "text", "content", "message", "command");
			if (text) events.push({kind: eventType.includes("tool") ? "command" : "assistant", text, resumeId, raw: record});
		}
	}
	const text = getString(record, "text", "content", "message", "output", "result", "response");
	if (text && events.length === 0) {
		const kind = provider === "zcode" && typeof record.response === "string" ? "assistant"
			: eventType.includes("command") || eventType.includes("tool") ? "command"
			: eventType.includes("assistant") || eventType.includes("message") || eventType.includes("text") ? "assistant" : "activity";
		events.push({kind, text, resumeId, raw: record});
	}
	if (resumeId && events.length === 0) events.push({kind: "status", text: `${provider} session ${resumeId}`, resumeId, raw: record});
	return events;
}

function parseLines(provider: LocalAgentProvider, buffer: string, onEvent: (event: LocalAgentEvent) => void): string {
	const lines = buffer.split("\n");
	const rest = lines.pop() ?? "";
	for (let i = 0; i < lines.length; i++) {
		const line = sanitizeUTF8(lines[i]).trim();
		if (line === "") continue;
		const [decoded] = safeJsonDecode(line);
		if (decoded && typeof decoded === "object" && !Array.isArray(decoded)) {
			const events = parseRecord(provider, decoded as Record<string, unknown>);
			if (events.length > 0) for (let e = 0; e < events.length; e++) onEvent(events[e]);
			else onEvent({kind: "activity", text: line, raw: decoded as Record<string, unknown>});
		} else {
			onEvent({kind: "activity", text: line});
		}
	}
	return rest;
}

function parseCompleteOutput(provider: LocalAgentProvider, output: string, onEvent: (event: LocalAgentEvent) => void) {
	const text = sanitizeUTF8(output).trim();
	if (text === "") return;
	const [decoded] = safeJsonDecode(text);
	if (decoded && typeof decoded === "object" && !Array.isArray(decoded)) {
		const events = parseRecord(provider, decoded as Record<string, unknown>);
		if (events.length > 0) {
			for (let i = 0; i < events.length; i++) onEvent(events[i]);
			return;
		}
	}
	parseLines(provider, `${text}\n`, onEvent);
}

function ensureSkill(projectRoot: string): {success: boolean; state: "installed" | "current" | "custom" | "failed"; message?: string} {
	const skillContent = buildSkillContent();
	const dir = Path(projectRoot, ".agents", "skills", "dora-engine-coding");
	const target = Path(dir, "SKILL.md");
	if (Content.exist(target)) {
		const existing = Content.load(target);
		if (existing === skillContent) return {success: true, state: "current"};
		if (!existing.includes("<!-- dora-managed-skill:v")) {
			return {success: true, state: "custom", message: "custom Dora skill preserved"};
		}
	}
	if (!Content.exist(dir) && !Content.mkdir(dir)) return {success: false, state: "failed", message: "failed to create Dora skill directory"};
	const temp = `${target}.tmp`;
	if (!Content.save(temp, skillContent) || !Content.move(temp, target)) {
		if (Content.exist(temp)) Content.remove(temp);
		return {success: false, state: "failed", message: "failed to install Dora skill"};
	}
	return {success: true, state: "installed"};
}

function getExternalSession(doraSessionId: number, config: LocalAgentConfig): {resumeId?: string; generation: number} {
	ensureTables();
	const rows = DB.query(`SELECT config_id,provider,resume_id,generation FROM ${SESSION_TABLE} WHERE dora_session_id=?`, [doraSessionId]) ?? [];
	if (rows.length > 0 && tonumber(rows[0][0]) === config.id && tostring(rows[0][1]) === config.provider) {
		return {resumeId: tostring(rows[0][2]) || undefined, generation: tonumber(rows[0][3]) ?? 1};
	}
	DB.exec(`INSERT INTO ${SESSION_TABLE}(dora_session_id,config_id,provider,resume_id,generation,updated_at) VALUES(?,?,?,?,1,?) ON CONFLICT(dora_session_id) DO UPDATE SET config_id=excluded.config_id,provider=excluded.provider,resume_id='',generation=generation+1,abandoned_at=?,updated_at=excluded.updated_at`, [doraSessionId, config.id, config.provider, "", os.time(), os.time()]);
	return {generation: 1};
}

function saveResumeId(doraSessionId: number, config: LocalAgentConfig, resumeId: string) {
	DB.exec(`UPDATE ${SESSION_TABLE} SET resume_id=?,updated_at=? WHERE dora_session_id=? AND config_id=?`, [resumeId, os.time(), doraSessionId, config.id]);
}

function isMissingExternalSession(text: string): boolean {
	const lower = text.toLowerCase();
	return lower.includes("session not found")
		|| lower.includes("thread not found")
		|| lower.includes("unknown session")
		|| lower.includes("invalid session")
		|| lower.includes("no conversation found");
}

export function abandonSession(doraSessionId: unknown): {success: boolean; message?: string} {
	ensureTables();
	const id = tonumber(doraSessionId);
	if (!id) return {success: false, message: "invalid Dora session id"};
	DB.exec(`UPDATE ${SESSION_TABLE} SET resume_id='',generation=generation+1,abandoned_at=?,updated_at=? WHERE dora_session_id=?`, [os.time(), os.time(), id]);
	return {success: true};
}

export function getSessionInfo(doraSessionId: unknown): Record<string, unknown> | undefined {
	ensureTables();
	const id = tonumber(doraSessionId);
	if (!id) return undefined;
	const rows = DB.query(`SELECT config_id,provider,resume_id,generation,abandoned_at,updated_at FROM ${SESSION_TABLE} WHERE dora_session_id=?`, [id]) ?? [];
	if (rows.length === 0) return undefined;
	return {configId: rows[0][0], provider: rows[0][1], resumeId: rows[0][2], generation: rows[0][3], abandonedAt: rows[0][4], updatedAt: rows[0][5]};
}

export function run(
	doraSessionId: number,
	config: LocalAgentConfig,
	projectRoot: string,
	prompt: string,
	onEvent: (event: LocalAgentEvent) => void,
	onDone: (result: LocalAgentRunResult) => void,
): LocalAgentRunControl {
	let stopRequested = false;
	let handle: number | undefined;
	const skill = ensureSkill(projectRoot);
	if (!skill.success) {
		onDone({success: false, exitCode: -1, message: skill.message ?? "failed to install Dora skill"});
		return {stop() { stopRequested = true; }};
	}
	const external = getExternalSession(doraSessionId, config);
	onEvent({
		kind: "status",
		text: config.provider === "zcode"
			? `Started ${config.name} (${config.provider}); its CLI returns the structured message when the task completes`
			: `Started ${config.name} (${config.provider})`,
	});
	// Game previews clear ordinary Routine jobs. Keep process supervision on a
	// system UI node so a local Agent can call Dora CLI without orphaning its turn.
	const monitorHost = Node();
	monitorHost.addTo(Director.systemUI);
	const finish = (result: LocalAgentRunResult) => {
		onDone(result);
		monitorHost.removeFromParent(false);
	};
	monitorHost.once(() => {
		const doraCommand = prepareDoraCommandEnvironment();
		if (!doraCommand) {
			finish({success: false, exitCode: -1, message: "failed to resolve Dora executable or Asset path"});
			return;
		}
		if (!doraCommand.shim) onEvent({kind: "status", text: "Dora command shim was unavailable; using the absolute Dora CLI command for this turn"});
		let resumeId = external.resumeId;
		let retriedMissingSession = false;
		while (true) {
			const commandPrompt = doraCommand.shim
				? `Dora CLI is available in this Agent environment as \`dora cli\`.\n\n${prompt}`
				: `For this turn, invoke Dora CLI only with this exact prefix (do not use a bare dora command):\n${doraCommand.command}\n\n${prompt}`;
			const skillPrompt = resumeId ? commandPrompt : `Use the dora-engine-coding skill for this task.\n\n${commandPrompt}`;
			const spec = buildSpec(config, projectRoot, skillPrompt, resumeId);
			spec.env = doraCommand.env;
			handle = Process.spawn(spec);
			if (handle === undefined) {
				finish({success: false, exitCode: -1, message: `failed to start ${config.executable}`});
				return;
			}
			Process.write(handle);
			let stdoutOffset = 0;
			let stderrOffset = 0;
			let stdoutBuffer = "";
			let stderrBuffer = "";
			let diagnostic = "";
			let lastActivity = App.runningTime;
			const startedAt = App.runningTime;
			let lastProgressNotice = App.runningTime;
			let retryFresh = false;
			const emitEvent = (event: LocalAgentEvent) => {
				if (event.resumeId && event.resumeId !== resumeId) {
					resumeId = event.resumeId;
					saveResumeId(doraSessionId, config, resumeId);
				}
				onEvent(event);
			};
			while (true) {
				const chunk = Process.read(handle, stdoutOffset, stderrOffset);
				stdoutOffset = chunk.stdoutOffset;
				stderrOffset = chunk.stderrOffset;
				if (chunk.stdout !== "") {
					lastActivity = App.runningTime;
					diagnostic = (diagnostic + chunk.stdout).slice(-32768);
					stdoutBuffer = config.provider === "zcode"
						? stdoutBuffer + chunk.stdout
						: parseLines(config.provider, stdoutBuffer + chunk.stdout, emitEvent);
				}
				if (chunk.stderr !== "") {
					lastActivity = App.runningTime;
					diagnostic = (diagnostic + chunk.stderr).slice(-32768);
					stderrBuffer += chunk.stderr;
					const lines = stderrBuffer.split("\n");
					stderrBuffer = lines.pop() ?? "";
					for (let i = 0; i < lines.length; i++) if (lines[i].trim() !== "") onEvent({kind: "stderr", text: sanitizeUTF8(lines[i])});
				}
				if (!chunk.running) {
					if (stdoutBuffer.trim() !== "") parseCompleteOutput(config.provider, stdoutBuffer, emitEvent);
					if (stderrBuffer.trim() !== "") onEvent({kind: "stderr", text: sanitizeUTF8(stderrBuffer)});
					const exitCode = chunk.exit.exitCode ?? -1;
					Process.destroy(handle);
					handle = undefined;
					if (exitCode !== 0 && external.resumeId && !retriedMissingSession && isMissingExternalSession(diagnostic)) {
						retriedMissingSession = true;
						resumeId = undefined;
						saveResumeId(doraSessionId, config, "");
						onEvent({kind: "status", text: "Stored local Agent session is unavailable; retrying once with a new session"});
						retryFresh = true;
						break;
					}
					finish({success: exitCode === 0 && !stopRequested, exitCode, message: exitCode === 0 ? "completed" : `local Agent exited with code ${exitCode}`, resumeId, stopped: stopRequested});
					return;
				}
				if (stopRequested) {
					Process.stop(handle, "interrupt");
					sleep(1.5);
					const after = Process.read(handle, stdoutOffset, stderrOffset);
					if (after.running) Process.stop(handle, "kill-tree");
				}
				if (config.provider === "zcode" && App.runningTime - lastProgressNotice >= 30) {
					lastProgressNotice = App.runningTime;
					const elapsed = math.floor(App.runningTime - startedAt);
					onEvent({kind: "status", text: `ZCode is still running (${elapsed}s); waiting for its buffered response`});
				}
				const inactivityTimeout = config.provider === "zcode" ? 1800 : 900;
				if (App.runningTime - lastActivity > inactivityTimeout) {
					stopRequested = true;
					onEvent({kind: "stderr", text: `local Agent stopped after ${math.floor(inactivityTimeout / 60)} minutes without output`});
				}
				sleep(0.05);
			}
			if (!retryFresh) return;
		}
	});
	return {stop() { stopRequested = true; if (handle !== undefined) Process.stop(handle, "interrupt"); }};
}

function runProbe(config: LocalAgentConfig, args: string[], cwd: string, timeoutSeconds: number): {exitCode: number; stdout: string; stderr: string} {
	const handle = Process.spawn({program: config.executable, args, cwd});
	if (handle === undefined) return {exitCode: -1, stdout: "", stderr: "failed to start executable"};
	Process.write(handle);
	let stdoutOffset = 0;
	let stderrOffset = 0;
	let stdout = "";
	let stderr = "";
	const started = App.runningTime;
	while (true) {
		const chunk = Process.read(handle, stdoutOffset, stderrOffset);
		stdoutOffset = chunk.stdoutOffset;
		stderrOffset = chunk.stderrOffset;
		stdout += chunk.stdout;
		stderr += chunk.stderr;
		if (!chunk.running) {
			const exitCode = chunk.exit.exitCode ?? -1;
			Process.destroy(handle);
			return {exitCode, stdout, stderr};
		}
		if (App.runningTime - started >= timeoutSeconds) {
			Process.stop(handle, "kill-tree");
			Process.destroy(handle);
			return {exitCode: -1, stdout, stderr: `${stderr}\nprobe timed out`};
		}
		sleep(0.05);
	}
}

export function verifyConfig(id: unknown, projectRoot?: unknown): Record<string, unknown> {
	if (!isLocalAgentSupported()) return {success: false, code: "UNSUPPORTED_PLATFORM", message: "local Agent is only available on desktop platforms"};
	const config = getConfig(id);
	if (!config) return {success: false, code: "NOT_FOUND", message: "local Agent config not found"};
	const verifyBase = typeof projectRoot === "string" && Content.exist(projectRoot) && Content.isdir(projectRoot) ? projectRoot : Content.writablePath;
	const cwd = Path(verifyBase, `.dora-local-agent-verify-${config.id}-${os.time()}-${math.floor(App.runningTime * 1000)}`);
	if (!Content.mkdir(cwd)) return {success: false, code: "VERIFY_SETUP_FAILED", message: "failed to create local Agent verification directory"};
	const finish = (result: Record<string, unknown>) => {
		Content.remove(cwd);
		return result;
	};
	const versionArgs = config.provider === "zcode" ? ["version"] : ["--version"];
	const versionProbe = runProbe(config, versionArgs, cwd, 15);
	if (versionProbe.exitCode !== 0) return finish({success: false, code: "DETECT_FAILED", message: versionProbe.stderr || versionProbe.stdout || "version probe failed"});
	const version = (versionProbe.stdout || versionProbe.stderr).trim().split("\n")[0];
	const prompt = "Reply with exactly DORA_LOCAL_AGENT_OK and do not edit files or run tools.";
	const spec = buildSpec(config, cwd, prompt);
	const probe = runProbe(config, spec.args, cwd, 180);
	const output = `${probe.stdout}\n${probe.stderr}`;
	if (probe.exitCode !== 0 || !output.includes("DORA_LOCAL_AGENT_OK")) return finish({success: false, code: "VERIFY_FAILED", version, message: output.slice(0, 4000) || `Agent exited with code ${probe.exitCode}`});
	const fingerprint = `${config.provider}:${config.executable}:${encodeJson(config.extraArgs)}`;
	DB.exec(`UPDATE ${CONFIG_TABLE} SET verified_at=?,verified_version=?,verified_fingerprint=?,updated_at=? WHERE id=?`, [os.time(), version, fingerprint, os.time(), config.id]);
	return finish({success: true, version, verifiedAt: os.time()});
}

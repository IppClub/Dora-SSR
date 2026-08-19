import { App, Path, Content } from 'Dora';
import * as AgentUtils from 'Agent/Utils';
import type { Message } from 'Agent/Utils';
import { sendWebIDEFileUpdate } from 'Agent/Tool/WebIDESync';

export interface AgentStepDebugContext {
	workingDir: string;
	sessionId?: number;
	taskId: number;
	step: number;
}

function canWriteStepLLMDebug(shared: AgentStepDebugContext, stepId = shared.step + 1): boolean {
	return App.debugging === true
		&& shared.sessionId !== undefined
		&& shared.sessionId > 0
		&& shared.taskId > 0
		&& stepId > 0;
}

function ensureDirRecursive(dir: string): boolean {
	if (!dir) return false;
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent !== "" && parent !== dir && !Content.exist(parent) && !ensureDirRecursive(parent)) {
		return false;
	}
	return Content.mkdir(dir);
}

export function encodeDebugJSON(value: unknown): string {
	const [text, err] = AgentUtils.safeJsonEncode(value as object);
	return text ?? `{ "error": "json_encode_failed", "message": "${tostring(err)}" }`;
}

function getStepLLMDebugDir(shared: AgentStepDebugContext): string {
	return Path(
		shared.workingDir,
		".agent",
		tostring(shared.sessionId as number),
		tostring(shared.taskId),
	);
}

function getStepLLMDebugPath(shared: AgentStepDebugContext, stepId: number, seq: number, kind: "in" | "out"): string {
	return Path(getStepLLMDebugDir(shared), `${tostring(stepId)}_${tostring(seq)}_${kind}.md`);
}

function getLatestStepLLMDebugSeq(shared: AgentStepDebugContext, stepId: number): number {
	if (!canWriteStepLLMDebug(shared, stepId)) return 0;
	const dir = getStepLLMDebugDir(shared);
	if (!Content.exist(dir) || !Content.isdir(dir)) return 0;
	let latest = 0;
	for (const file of Content.getFiles(dir)) {
		const name = Path.getFilename(file);
		const [seqText] = string.match(name, `^${tostring(stepId)}_(%d+)_in%.md$`);
		if (seqText !== undefined) {
			latest = math.max(latest, tonumber(seqText) as number);
			continue;
		}
		const [legacyMatch] = string.match(name, `^${tostring(stepId)}_in%.md$`);
		if (legacyMatch !== undefined) {
			latest = math.max(latest, 1);
		}
	}
	return latest;
}

function writeStepLLMDebugFile(path: string, content: string): boolean {
	if (!Content.save(path, content)) {
		AgentUtils.Log("Warn", `[CodingAgent] failed to save LLM debug file: ${path}`);
		return false;
	}
	sendWebIDEFileUpdate(path, true, content);
	return true;
}

function createStepLLMDebugPair(shared: AgentStepDebugContext, stepId: number, inContent: string): number {
	if (!canWriteStepLLMDebug(shared, stepId)) return 0;
	const dir = getStepLLMDebugDir(shared);
	if (!ensureDirRecursive(dir)) {
		AgentUtils.Log("Warn", `[CodingAgent] failed to create LLM debug dir: ${dir}`);
		return 0;
	}
	const seq = getLatestStepLLMDebugSeq(shared, stepId) + 1;
	const inPath = getStepLLMDebugPath(shared, stepId, seq, "in");
	const outPath = getStepLLMDebugPath(shared, stepId, seq, "out");
	if (!writeStepLLMDebugFile(inPath, inContent)) {
		return 0;
	}
	writeStepLLMDebugFile(outPath, "");
	return seq;
}

function updateLatestStepLLMDebugOutput(shared: AgentStepDebugContext, stepId: number, content: string): void {
	if (!canWriteStepLLMDebug(shared, stepId)) return;
	const dir = getStepLLMDebugDir(shared);
	if (!ensureDirRecursive(dir)) {
		AgentUtils.Log("Warn", `[CodingAgent] failed to create LLM debug dir: ${dir}`);
		return;
	}
	const latestSeq = getLatestStepLLMDebugSeq(shared, stepId);
	if (latestSeq <= 0) {
		const outPath = getStepLLMDebugPath(shared, stepId, 1, "out");
		writeStepLLMDebugFile(outPath, content);
		return;
	}
	const outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out");
	writeStepLLMDebugFile(outPath, content);
}

export function saveStepLLMDebugInput(shared: AgentStepDebugContext, stepId: number, phase: string, messages: Message[], options: Record<string, unknown>): void {
	if (!canWriteStepLLMDebug(shared, stepId)) return;
	const sections: string[] = [
		"# LLM Input",
		`session_id: ${tostring(shared.sessionId as number)}`,
		`task_id: ${tostring(shared.taskId)}`,
		`step_id: ${tostring(stepId)}`,
		`phase: ${phase}`,
		`timestamp: ${os.date("!%Y-%m-%dT%H:%M:%SZ")}`,
		"## Options",
		"```json",
		encodeDebugJSON(options),
		"```",
	];
	const firstMessage = messages.length > 0 ? messages[0] : undefined;
	if (firstMessage && firstMessage.role === "system" && typeof firstMessage.content === "string") {
		sections.push("# System Prompt");
		sections.push(firstMessage.content);
	}
	for (let i = 0; i < messages.length; i++) {
		const message = messages[i];
		sections.push(`## Message ${i + 1}`);
		sections.push(encodeDebugJSON(message));
	}
	createStepLLMDebugPair(shared, stepId, sections.join("\n"));
}

export function saveStepLLMDebugOutput(shared: AgentStepDebugContext, stepId: number, phase: string, text: string, meta?: Record<string, unknown>): void {
	if (!canWriteStepLLMDebug(shared, stepId)) return;
	const sections = [
		"# LLM Output",
		`session_id: ${tostring(shared.sessionId as number)}`,
		`task_id: ${tostring(shared.taskId)}`,
		`step_id: ${tostring(stepId)}`,
		`phase: ${phase}`,
		`timestamp: ${os.date("!%Y-%m-%dT%H:%M:%SZ")}`,
		...(meta ? ["## Meta", "```json", encodeDebugJSON(meta), "```"] : []),
		"## Content",
		text,
	];
	updateLatestStepLLMDebugOutput(shared, stepId, sections.join("\n"));
}

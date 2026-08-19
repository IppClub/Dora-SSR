// @preview-file off clear
import * as AgentConfig from 'Agent/Config';
import { normalizeQuestionnaire } from 'Agent/Questionnaire';
import * as AgentUtils from 'Agent/Utils';
import type { AgentToolInputValidator, AgentToolName, AgentToolSemanticValidationResult } from 'Agent/Tool/Types';

function getDecisionPath(input: Record<string, unknown>): string {
	if (typeof input.path === "string") return input.path.trim();
	if (typeof input.target_file === "string") return input.target_file.trim();
	return "";
}

export interface AgentFileEditInput {
	index: number;
	path: string;
	oldStr: string;
	newStr: string;
}

export function getAgentFileEditInputs(input: Record<string, unknown>): AgentFileEditInput[] {
	if (Array.isArray(input.edits)) {
		const commonPath = typeof input.path === "string" ? input.path.trim() : "";
		const edits: AgentFileEditInput[] = [];
		for (let i = 0; i < input.edits.length; i++) {
			const item = input.edits[i] as Record<string, unknown>;
			edits.push({
				index: i,
				path: typeof item.path === "string" && item.path.trim() !== "" ? item.path.trim() : commonPath,
				oldStr: typeof item.old_str === "string" ? item.old_str : "",
				newStr: typeof item.new_str === "string" ? item.new_str : "",
			});
		}
		return edits;
	}
	return [{
		index: 0,
		path: typeof input.path === "string" ? input.path.trim() : "",
		oldStr: typeof input.old_str === "string" ? input.old_str : "",
		newStr: typeof input.new_str === "string" ? input.new_str : "",
	}];
}

function clampInteger(value: unknown, fallback: number, minValue: number, maxValue?: number): number {
	let num = Number(value);
	if (!Number.isFinite(num)) num = fallback;
	num = math.floor(num);
	if (num < minValue) num = minValue;
	if (maxValue !== undefined && num > maxValue) num = maxValue;
	return num;
}

function parseReadLine(value: unknown, fallback: number, name: "startLine" | "endLine"):
	| { success: true; value: number }
	| { success: false; message: string } {
	let num = Number(value);
	if (!Number.isFinite(num)) num = fallback;
	num = math.floor(num);
	if (num === 0) return { success: false, message: `${name} cannot be 0` };
	return { success: true, value: num };
}

function getFinishMessage(input: Record<string, unknown>): string {
	const candidates = [input.message, input.response, input.summary];
	for (let i = 0; i < candidates.length; i++) {
		if (typeof candidates[i] === "string" && (candidates[i] as string).trim() !== "") {
			return (candidates[i] as string).trim();
		}
	}
	return "";
}

export function validateAgentToolInput(tool: AgentToolName, input: Record<string, unknown>): AgentToolSemanticValidationResult {
	const value = { ...input };
	if (tool === "finish") {
		const message = getFinishMessage(value);
		if (message === "") return { success: false, message: "finish requires params.message" };
		const completion = AgentUtils.normalizeAgentCompletionReport(value);
		value.message = message;
		value.outcome = completion.outcome;
		value.validation = completion.validation;
		value.knownIssues = completion.knownIssues;
		value.assumptions = completion.assumptions;
		value.learningCandidates = completion.learningCandidates;
		return { success: true, value };
	}
	if (tool === "ask_user") {
		const normalized = normalizeQuestionnaire(value);
		return normalized.success
			? { success: true, value: normalized.schema as unknown as Record<string, unknown> }
			: normalized;
	}
	if (tool === "read_file") {
		if (!Array.isArray(value.reads) || value.reads.length < 1) return { success: false, message: "read_file requires a non-empty reads array" };
		const source = value.reads as Record<string, unknown>[];
		const reads: Record<string, unknown>[] = [];
		for (let i = 0; i < source.length; i++) {
			const item = source[i];
			const path = typeof item.path === "string" ? item.path.trim() : "";
			if (path === "") return { success: false, message: `read_file requires path at index ${i}` };
			const start = parseReadLine(item.startLine, 1, "startLine");
			if (start.success === false) return { success: false, message: `${start.message} at index ${i}` };
			const end = parseReadLine(item.endLine, start.value < 0 ? -1 : AgentConfig.AGENT_LIMITS.readFileDefaultLimit, "endLine");
			if (end.success === false) return { success: false, message: `${end.message} at index ${i}` };
			reads.push({ path, startLine: start.value, endLine: end.value });
		}
		value.reads = reads;
		return { success: true, value };
	}
	if (tool === "edit_file") {
		const hasBatch = Array.isArray(value.edits);
		const hasLegacyPayload = value.old_str !== undefined || value.new_str !== undefined;
		if ((hasBatch && hasLegacyPayload) || (!hasBatch && !hasLegacyPayload)) {
			return { success: false, message: "edit_file requires path + old_str + new_str, edits, or path + edits; do not mix edits with top-level old_str/new_str" };
		}
		const edits = getAgentFileEditInputs(value);
		if (edits.length < 1) {
			return { success: false, message: "edit_file edits must not be empty" };
		}
		if (!hasBatch) {
			if (edits[0].path === "") return { success: false, message: "edit_file requires path" };
			if (edits[0].oldStr === edits[0].newStr) return { success: false, message: "edit_file requires old_str and new_str to differ" };
		}
		if (hasBatch) {
			value.edits = edits.map(edit => ({ path: edit.path, old_str: edit.oldStr, new_str: edit.newStr }));
		} else {
			value.path = edits[0].path;
			value.old_str = edits[0].oldStr;
			value.new_str = edits[0].newStr;
		}
		return { success: true, value };
	}
	if (tool === "delete_file") {
		const target = getDecisionPath(value);
		if (target === "") return { success: false, message: "delete_file requires target_file" };
		value.target_file = target;
		return { success: true, value };
	}
	if (tool === "grep_files" || tool === "search_dora_doc") {
		const pattern = typeof value.pattern === "string" ? value.pattern.trim() : "";
		if (pattern === "") return { success: false, message: `${tool} requires pattern` };
		value.pattern = pattern;
		if (tool === "grep_files") {
			value.limit = clampInteger(value.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1);
			value.offset = clampInteger(value.offset, 0, 0);
		} else {
			const docType = typeof value.docType === "string" ? value.docType : "dora-api";
			if (docType !== "dora-api" && docType !== "dora-tutorial" && docType !== "love-api" && docType !== "tic80-api") {
				return { success: false, message: "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api" };
			}
			value.docType = docType;
			value.limit = clampInteger(value.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax);
		}
		return { success: true, value };
	}
	if (tool === "glob_files") {
		value.maxEntries = clampInteger(value.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1);
		return { success: true, value };
	}
	if (tool === "build") {
		if (!Array.isArray(value.paths)) return { success: false, message: "build requires a non-empty paths array" };
		const paths = (value.paths as unknown[]).map(item => typeof item === "string" ? item.trim() : "");
		if (paths.length < 1 || paths.some(path => path === "")) return { success: false, message: "build paths must contain non-empty paths" };
		value.paths = paths;
		return { success: true, value };
	}
	if (tool === "fetch_url") {
		const url = typeof value.url === "string" ? value.url.trim() : "";
		const target = typeof value.target === "string" ? value.target.trim() : "";
		if (url === "") return { success: false, message: "fetch_url requires url" };
		if (target === "") return { success: false, message: "fetch_url requires target" };
		value.url = url;
		value.target = target;
		return { success: true, value };
	}
	if (tool === "execute_command") {
		const mode = typeof value.mode === "string" ? value.mode.trim() : "";
		if (mode !== "lua" && mode !== "git") return { success: false, message: "execute_command requires mode: lua or git" };
		value.mode = mode;
		if (mode === "lua") {
			const code = typeof value.code === "string" ? value.code : "";
			if (code.trim() === "") return { success: false, message: "execute_command lua mode requires code" };
			value.code = code;
		} else {
			const command = typeof value.command === "string" ? value.command.trim() : "";
			if (command === "") return { success: false, message: "execute_command git mode requires command" };
			value.command = command;
			if (typeof value.cwd === "string") value.cwd = value.cwd.trim();
		}
		value.timeoutSeconds = clampInteger(value.timeoutSeconds, mode === "lua" ? 30 : 600, 1, mode === "lua" ? 120 : 1800);
		return { success: true, value };
	}
	if (tool === "list_sub_agents") {
		if (typeof value.status === "string" && value.status.trim() !== "") value.status = value.status.trim();
		value.limit = clampInteger(value.limit, 5, 1);
		value.offset = clampInteger(value.offset, 0, 0);
		if (typeof value.query === "string") value.query = value.query.trim();
		return { success: true, value };
	}
	if (tool === "spawn_sub_agent") {
		const prompt = typeof value.prompt === "string" ? value.prompt.trim() : "";
		const title = typeof value.title === "string" ? value.title.trim() : "";
		if (prompt === "") return { success: false, message: "spawn_sub_agent requires prompt" };
		if (title === "") return { success: false, message: "spawn_sub_agent requires title" };
		value.prompt = prompt;
		value.title = title;
		if (typeof value.expectedOutput === "string") value.expectedOutput = value.expectedOutput.trim();
		if (Array.isArray(value.filesHint)) {
			value.filesHint = value.filesHint.filter(item => typeof item === "string").map(item => AgentUtils.sanitizeUTF8(item as string));
		}
		return { success: true, value };
	}
	return { success: true, value };
}

export const AGENT_TOOL_VALIDATORS: Partial<Record<AgentToolName, AgentToolInputValidator>> = {
	read_file: value => validateAgentToolInput("read_file", value),
	edit_file: value => validateAgentToolInput("edit_file", value),
	delete_file: value => validateAgentToolInput("delete_file", value),
	grep_files: value => validateAgentToolInput("grep_files", value),
	search_dora_doc: value => validateAgentToolInput("search_dora_doc", value),
	glob_files: value => validateAgentToolInput("glob_files", value),
	build: value => validateAgentToolInput("build", value),
	fetch_url: value => validateAgentToolInput("fetch_url", value),
	execute_command: value => validateAgentToolInput("execute_command", value),
	list_sub_agents: value => validateAgentToolInput("list_sub_agents", value),
	spawn_sub_agent: value => validateAgentToolInput("spawn_sub_agent", value),
	ask_user: value => validateAgentToolInput("ask_user", value),
	finish: value => validateAgentToolInput("finish", value),
};

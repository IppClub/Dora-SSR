import * as AgentUtils from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import * as AgentToolRegistry from 'Agent/AgentToolRegistry';
import type { AgentRole, AgentToolName } from 'Agent/AgentToolRegistry';
import { getAgentDecisionPath } from 'Agent/AgentRuntimePolicy';

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object";
}

function isArray(value: unknown): value is unknown[] {
	return Array.isArray(value);
}

function hasXMLParam(params: Record<string, unknown>, name: string): boolean {
	return params[name] !== undefined;
}

function inferToolNameFromXMLParams(params: Record<string, unknown>): AgentToolName | undefined {
	if (hasXMLParam(params, "old_str") || hasXMLParam(params, "new_str")) {
		return "edit_file";
	}
	if (hasXMLParam(params, "target_file")) {
		return "delete_file";
	}
	if (hasXMLParam(params, "startLine") || hasXMLParam(params, "endLine")) {
		if (hasXMLParam(params, "path")) return "read_file";
		return undefined;
	}
	if (hasXMLParam(params, "docType") || hasXMLParam(params, "programmingLanguage")) {
		if (hasXMLParam(params, "pattern")) return "search_dora_doc";
		return undefined;
	}
	if (hasXMLParam(params, "groupByFile") || hasXMLParam(params, "caseSensitive")) {
		if (hasXMLParam(params, "pattern")) return "grep_files";
		return undefined;
	}
	if (hasXMLParam(params, "globs")) {
		if (hasXMLParam(params, "pattern")) return "grep_files";
		return "glob_files";
	}
	if (hasXMLParam(params, "maxEntries")) {
		return "glob_files";
	}
	if (hasXMLParam(params, "message") || hasXMLParam(params, "response") || hasXMLParam(params, "summary")) {
		return "finish";
	}
	if (hasXMLParam(params, "title") || hasXMLParam(params, "prompt") || hasXMLParam(params, "expectedOutput") || hasXMLParam(params, "filesHint")) {
		return "spawn_sub_agent";
	}
	if (hasXMLParam(params, "status") || hasXMLParam(params, "query")) {
		return "list_sub_agents";
	}
	return undefined;
}

export function parseDSMLAttribute(source: string, offset: number, name: string): { success: true; value: string; next: number } | { success: false; message: string } {
	const attrOpen = `${name}="`;
	const attrStart = source.indexOf(attrOpen, offset);
	if (attrStart < 0) return { success: false, message: `missing ${name} attribute` };
	const valueStart = attrStart + attrOpen.length;
	const valueEnd = source.indexOf('"', valueStart);
	if (valueEnd < 0) return { success: false, message: `unterminated ${name} attribute` };
	return {
		success: true,
		value: source.slice(valueStart, valueEnd),
		next: valueEnd + 1,
	};
}

function extractDSMLReason(text: string, invokeStart: number, tool: AgentToolName): string {
	const toolCallsStart = text.indexOf("<｜｜DSML｜｜tool_calls>");
	const before = toolCallsStart >= 0 && toolCallsStart < invokeStart
		? text.slice(0, toolCallsStart).trim()
		: text.slice(0, invokeStart).trim();
	if (before !== "" && before.indexOf("<｜｜DSML") < 0) return before;
	if (tool === "finish") return "";
	return "Converted provider-native tool call syntax to XML.";
}

export function parseDSMLToolCallObjectFromText(text: string): { success: true; obj: Record<string, unknown> } | { success: false; message: string } {
	const invokeOpen = '<｜｜DSML｜｜invoke name="';
	const invokeStart = text.indexOf(invokeOpen);
	if (invokeStart < 0) return { success: false, message: "missing DSML invoke" };
	const nameStart = invokeStart + invokeOpen.length;
	const nameEnd = text.indexOf('"', nameStart);
	if (nameEnd < 0) return { success: false, message: "unterminated DSML invoke name" };
	const toolName = text.slice(nameStart, nameEnd);
	if (!AgentToolRegistry.isKnownToolName(toolName)) {
		return { success: false, message: `unknown DSML tool: ${toolName}` };
	}
	const invokeOpenEnd = text.indexOf(">", nameEnd);
	if (invokeOpenEnd < 0) return { success: false, message: "unterminated DSML invoke open tag" };
	const invokeClose = "</｜｜DSML｜｜invoke>";
	const invokeEnd = text.indexOf(invokeClose, invokeOpenEnd + 1);
	if (invokeEnd < 0) return { success: false, message: "missing DSML invoke close tag" };

	const body = text.slice(invokeOpenEnd + 1, invokeEnd);
	const params: Record<string, unknown> = {};
	const paramOpen = "<｜｜DSML｜｜parameter";
	const paramClose = "</｜｜DSML｜｜parameter>";
	let pos = 0;
	while (pos < body.length) {
		const start = body.indexOf(paramOpen, pos);
		if (start < 0) break;
		const openEnd = body.indexOf(">", start + paramOpen.length);
		if (openEnd < 0) return { success: false, message: "unterminated DSML parameter open tag" };
		const name = parseDSMLAttribute(body, start + paramOpen.length, "name");
		if (!name.success) return name;
		const close = body.indexOf(paramClose, openEnd + 1);
		if (close < 0) return { success: false, message: "missing DSML parameter close tag" };
		params[name.value] = body.slice(openEnd + 1, close);
		pos = close + paramClose.length;
	}
	return {
		success: true,
		obj: {
			tool: toolName,
			reason: extractDSMLReason(text, invokeStart, toolName),
			params,
		},
	};
}

export function parseXMLToolCallObjectFromText(text: string): { success: true; obj: Record<string, unknown> } | { success: false; message: string } {
	const children = AgentUtils.parseXMLObjectFromText(text, "tool_call");
	let rawObj: Record<string, unknown> | undefined;
	if (children.success) {
		rawObj = children.obj;
	} else {
		const dsml = parseDSMLToolCallObjectFromText(text);
		if (dsml.success) return dsml;
		const toolStart = text.indexOf("<tool>");
		const paramsCloseToken = "</params>";
		if (toolStart >= 0) {
			const paramsClose = text.indexOf(paramsCloseToken, toolStart);
			if (paramsClose >= toolStart) {
				const bareCandidate = text.slice(toolStart, paramsClose + paramsCloseToken.length).trim();
				const bare = AgentUtils.parseSimpleXMLChildren(bareCandidate);
				if (bare.success && typeof bare.obj.tool === "string" && typeof bare.obj.params === "string") {
					rawObj = bare.obj;
				}
			}
		}
		if (rawObj === undefined) {
			const paramsOpen = text.indexOf("<params>");
			if (paramsOpen < 0) return children;
			const paramsCloseOnly = text.indexOf(paramsCloseToken, paramsOpen);
			if (paramsCloseOnly < paramsOpen) return children;
			const paramsTextOnly = text.slice(paramsOpen + "<params>".length, paramsCloseOnly);
			const paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly);
			if (!paramsOnly.success) return children;
			const inferredTool = inferToolNameFromXMLParams(paramsOnly.obj);
			if (inferredTool === undefined) return children;
			return {
				success: true,
				obj: {
					tool: inferredTool,
					reason: inferredTool === "finish" ? undefined : "Inferred tool from XML params.",
					params: paramsOnly.obj,
				},
			};
		}
	}
	if (rawObj === undefined) return children;
	const paramsText = typeof rawObj.params === "string" ? rawObj.params as string : "";
	const params = paramsText !== ""
		? AgentUtils.parseSimpleXMLChildren(paramsText)
		: { success: true as const, obj: {} as Record<string, unknown> };
	if (!params.success) {
		return { success: false, message: params.message };
	}
	return {
		success: true,
		obj: {
			tool: rawObj.tool,
			reason: rawObj.reason,
			params: params.obj,
		},
	};
}

export type DecisionSuccess = {
	success: true;
	tool: AgentToolName;
	params: Record<string, unknown>;
	toolCallId?: string;
	reason?: string;
	reasoningContent?: string;
	truncatedEditRecovery?: Tools.TruncatedEditRecoveryNotice;
};
export type DecisionBatchSuccess = {
	success: true;
	kind: "batch";
	decisions: DecisionSuccess[];
	content?: string;
	reasoningContent?: string;
};
export type DecisionLoopContinue = {
	success: true;
	kind: "continue";
	reason: "length";
	content?: string;
	reasoningContent?: string;
};
export type DecisionPlainTextCompletion = {
	success: true;
	kind: "plain_text_completion";
	content: string;
	reasoningContent?: string;
};
export type DecisionResult = DecisionSuccess | DecisionBatchSuccess | DecisionLoopContinue | DecisionPlainTextCompletion | DecisionFailure;
export type DecisionFailure = { success: false; message: string; raw?: string };

export function isDecisionBatchSuccess(result: DecisionSuccess | DecisionBatchSuccess): result is DecisionBatchSuccess {
	return (result as DecisionBatchSuccess).kind === "batch";
}

export function isDecisionLoopContinue(result: DecisionResult): result is DecisionLoopContinue {
	return result.success === true && (result as DecisionLoopContinue).kind === "continue";
}

export function isDecisionPlainTextCompletion(result: DecisionResult): result is DecisionPlainTextCompletion {
	return result.success === true && (result as DecisionPlainTextCompletion).kind === "plain_text_completion";
}

export function classifyToolCallingTurnWithoutCalls(
	role: AgentRole,
	finishReason: string,
	messageContent?: string,
	reasoningContent?: string,
): DecisionLoopContinue | DecisionPlainTextCompletion | DecisionFailure | undefined {
	if (finishReason === "length") {
		return {
			success: true,
			kind: "continue",
			reason: "length",
			content: messageContent,
			reasoningContent,
		};
	}
	const content = messageContent?.trim() ?? "";
	if (content === "") return undefined;
	if (role === "sub") {
		return {
			success: false,
			message: "sub agents must call finish with structured completion metadata; plain-text completion is not accepted",
			raw: content,
		};
	}
	return {
		success: true,
		kind: "plain_text_completion",
		content,
		reasoningContent,
	};
}

export function parseDecisionObject(rawObj: Record<string, unknown>): DecisionSuccess | DecisionFailure {
	if (typeof rawObj.tool !== "string") return { success: false, message: "missing tool" };
	const tool = rawObj.tool;
	if (!AgentToolRegistry.isKnownToolName(tool)) {
		return { success: false, message: `unknown tool: ${tool}` };
	}
	const reason = typeof rawObj.reason === "string"
		? rawObj.reason.trim()
		: undefined;
	if (tool !== "finish" && (!reason || reason === "")) {
		return { success: false, message: `${tool} requires top-level reason` };
	}
	const params = isRecord(rawObj.params) ? rawObj.params : {};
	return {
		success: true,
		tool,
		params,
		reason,
	};
}

export function parseDecisionToolCall(functionName: string, rawObj: unknown): DecisionSuccess | DecisionFailure {
	if (!AgentToolRegistry.isKnownToolName(functionName)) {
		return { success: false, message: `unknown tool: ${functionName}` };
	}
	if (rawObj === undefined) {
		return { success: true, tool: functionName, params: {} };
	}
	if (!isRecord(rawObj)) {
		return { success: false, message: `invalid ${functionName} arguments` };
	}
	return {
		success: true,
		tool: functionName,
		params: rawObj,
	};
}

export function parseToolCallArguments(functionName: string, argsText: string): Record<string, unknown> | DecisionFailure {
	const trimmedArgs = argsText.trim();
	if (trimmedArgs === "") {
		return {};
	}
	const [rawObj, err] = AgentUtils.safeJsonDecode(trimmedArgs);
	if (err !== undefined || rawObj === undefined) {
		return {
			success: false,
			message: `invalid ${functionName} arguments: ${tostring(err)}`,
			raw: argsText,
		};
	}
	const [encodedRaw] = AgentUtils.safeJsonEncode(rawObj as object);
	if (encodedRaw === "null" || !isRecord(rawObj) || trimmedArgs[0] === "[") {
		return {
			success: false,
			message: `invalid ${functionName} arguments`,
			raw: argsText,
		};
	}
	return rawObj;
}

export const getDecisionPath = getAgentDecisionPath;

export function validateDecision(
	tool: AgentToolName,
	params: Record<string, unknown>
): { success: true; params: Record<string, unknown> } | { success: false; message: string } {
	const definition = AgentToolRegistry.getToolDefinition(tool);
	if (definition === undefined) return { success: false, message: `unknown tool: ${tool}` };
	const validateInput = definition.validateInput;
	const validation = validateInput?.(params);
	if (validation === undefined) return { success: true, params };
	return validation.success
		? { success: true, params: validation.value }
		: validation;
}

export function validateCompletionForRole(
	role: AgentRole,
	tool: AgentToolName,
	params: Record<string, unknown>
): { success: true } | { success: false; message: string } {
	if (tool !== "finish") return { success: true };
	if (role !== "sub") return { success: false, message: "finish is reserved for sub agents" };
	if (params.outcome !== "completed" && params.outcome !== "partial" && params.outcome !== "blocked") {
		return { success: false, message: "sub-agent finish requires params.outcome" };
	}
	const requiredArrays = ["validation", "knownIssues", "assumptions", "learningCandidates"];
	for (let i = 0; i < requiredArrays.length; i++) {
		const name = requiredArrays[i];
		if (!isArray(params[name])) {
			return { success: false, message: `sub-agent finish requires params.${name} as an array` };
		}
	}
	return { success: true };
}

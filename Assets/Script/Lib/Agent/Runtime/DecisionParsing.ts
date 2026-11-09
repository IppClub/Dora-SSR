import * as AgentUtils from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import * as AgentToolRegistry from 'Agent/Tool/Registry';
import type { AgentRole, AgentToolName } from 'Agent/Tool/Registry';
import { getAgentDecisionPath } from 'Agent/Runtime/Policy';

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object";
}

function isArray(value: unknown): value is unknown[] {
	return Array.isArray(value);
}

export type DecisionSuccess = {
	success: true;
	tool: AgentToolName;
	params: Record<string, unknown>;
	toolCallId?: string;
	providerToolName?: string;
	providerArguments?: string;
	preExecutionFailure?: { code: string; message: string };
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
export type DecisionFailure = { success: false; message: string; raw?: string; requestFailed?: boolean };

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

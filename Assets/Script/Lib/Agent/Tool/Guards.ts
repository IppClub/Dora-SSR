// @preview-file off clear
import * as AgentRuntimePolicy from 'Agent/Runtime/Policy';
import { getAgentFileEditInputs } from 'Agent/Tool/Validation';
import type { AgentFileEditInput } from 'Agent/Tool/Validation';
import type { AgentToolDefinition, AgentToolExecutionContext } from 'Agent/Tool/Types';

export interface AgentToolGuardRequest {
	definition: AgentToolDefinition;
	context: AgentToolExecutionContext;
	input: Record<string, unknown>;
}

export interface AgentToolGuardDenial {
	denied: true;
	code: string;
	message: string;
}

export type AgentToolGuardResult = AgentToolGuardDenial | undefined;
export type AgentToolGuard = (request: AgentToolGuardRequest) => AgentToolGuardResult;

function deny(code: string, message: string): AgentToolGuardDenial {
	return { denied: true, code, message };
}

const roleGuard: AgentToolGuard = request => {
	if (request.definition.roles.indexOf(request.context.role) >= 0) return undefined;
	return deny("TOOL_ROLE_DENIED", `${request.definition.name} is not available to ${request.context.role} agents`);
};

const workModeGuard: AgentToolGuard = request => {
	if (request.definition.workModes.indexOf(request.context.workMode) >= 0) return undefined;
	return deny("TOOL_MODE_DENIED", `${request.definition.name} is not available in ${request.context.workMode} mode`);
};

const disabledToolGuard: AgentToolGuard = request => {
	if (request.context.disabledAgentTools.indexOf(request.definition.name) < 0) return undefined;
	return deny("TOOL_DISABLED", `${request.definition.name} is disabled for this task`);
};

const planPathGuard: AgentToolGuard = request => {
	if (request.context.workMode !== "plan") return undefined;
	if (request.definition.name !== "edit_file" && request.definition.name !== "delete_file") return undefined;
	if (request.definition.name === "edit_file") {
		if (Array.isArray(request.input.edits)) return undefined;
		for (const edit of getAgentFileEditInputs(request.input)) {
			const denial = getAgentFileEditPlanGuardDenial(request.context, edit);
			if (denial !== undefined) return denial;
		}
		return undefined;
	}
	const path = AgentRuntimePolicy.normalizeAgentPath(
		AgentRuntimePolicy.getAgentDecisionPath(request.input)
	);
	if (AgentRuntimePolicy.isAgentPlanPath(path)) return undefined;
	return deny("PLAN_PATH_DENIED", `${request.definition.name} in Plan mode may only write under ${AgentRuntimePolicy.AGENT_PLAN_DIR}`);
};

const protectedDocumentGuard: AgentToolGuard = request => {
	if (request.definition.name !== "delete_file") return undefined;
	const path = AgentRuntimePolicy.normalizeAgentPath(
		AgentRuntimePolicy.getAgentDecisionPath(request.input)
	);
	if (path === AgentRuntimePolicy.AGENT_PLAN_FILE || path === AgentRuntimePolicy.AGENT_PROGRESS_FILE) {
		return deny("PROTECTED_AGENT_DOCUMENT", `${path} is a fixed living document and cannot be deleted`);
	}
	if (AgentRuntimePolicy.isMainAgentMemoryPath(path)) {
		return deny("PROTECTED_AGENT_MEMORY", "Files under .agent/main are managed Agent memory and cannot be deleted with delete_file");
	}
	return undefined;
};

export function getAgentFileEditPlanGuardDenial(
	context: AgentToolExecutionContext,
	edit: AgentFileEditInput,
): AgentToolGuardDenial | undefined {
	const path = AgentRuntimePolicy.normalizeAgentPath(edit.path);
	if (context.workMode === "plan" && !AgentRuntimePolicy.isAgentPlanPath(path)) {
		return deny("PLAN_PATH_DENIED", `edit_file operation ${edit.index + 1} in Plan mode may only write under ${AgentRuntimePolicy.AGENT_PLAN_DIR}`);
	}
	return undefined;
}

export const BUILT_IN_AGENT_TOOL_GUARDS: AgentToolGuard[] = [
	roleGuard,
	workModeGuard,
	disabledToolGuard,
	planPathGuard,
	protectedDocumentGuard,
];

export function runAgentToolGuards(
	request: AgentToolGuardRequest,
	guards: AgentToolGuard[] = BUILT_IN_AGENT_TOOL_GUARDS
): AgentToolGuardResult {
	for (const guard of guards) {
		const result = guard(request);
		if (result !== undefined) return result;
	}
	return undefined;
}

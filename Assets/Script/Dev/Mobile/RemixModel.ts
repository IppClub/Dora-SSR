import type { AgentQuestion, AgentQuestionnaireAnswers } from "Agent/Questionnaire";
import type { AgentSessionStepItem } from "Agent/Session";

export type RemixPhase = "idle" | "planning" | "plan-ready" | "working" | "waiting" | "done" | "failed" | "stopped";

// Match Web IDE: only an explicitly enabled main-session plan mode is active.
// Plan files and previous task status are not mode preferences.
export const resolveRemixWorkMode = (session?: { kind: string; workMode?: string }): "plan" | "code" =>
	session?.kind === "main" && session.workMode === "plan" ? "plan" : "code";

export interface RemixSessionState {
	status: "IDLE" | "RUNNING" | "WAITING_USER" | "DONE" | "FAILED" | "STOPPED";
	workMode: "plan" | "code";
	hasActivePlan: boolean;
}

export const resolveRemixPhase = (state: RemixSessionState): RemixPhase => {
	if (state.status === "FAILED") return "failed";
	if (state.status === "STOPPED") return "stopped";
	if (state.status === "WAITING_USER") return "waiting";
	if (state.status === "RUNNING") return state.workMode === "plan" ? "planning" : "working";
	if (state.status === "DONE") return state.workMode === "plan" ? "plan-ready" : "done";
	return "idle";
};

export const canLeaveRemix = (status: RemixSessionState["status"]) =>
	status !== "RUNNING" && status !== "WAITING_USER";

export const canPlayRemix = (status: RemixSessionState["status"]) => status === "DONE";

export const isQuestionAnswered = (
	question: AgentQuestion,
	selectedOptionIds: string[],
	text: string,
) => !question.required || (question.type === "text" ? text.trim() !== "" : selectedOptionIds.length > 0);

export const buildQuestionnaireAnswers = (
	questions: AgentQuestion[],
	selections: Record<string, string[]>,
	texts: Record<string, string>,
): AgentQuestionnaireAnswers => questions.map(question => {
	const text = (texts[question.id] ?? "").trim();
	const selectedOptionIds = selections[question.id] ?? [];
	if (!question.required && text === "" && selectedOptionIds.length === 0) {
		return { questionId: question.id, status: "skipped" };
	}
	return question.type === "text"
		? { questionId: question.id, status: "answered", text }
		: { questionId: question.id, status: "answered", selectedOptionIds };
});

export const compactAgentActivity = (tool: string, reason: string, zh: boolean, active = true) => {
	const label = tool === "search_files" || tool === "search_dora_doc"
		? (zh ? (active ? "正在查找资料" : "查找资料") : (active ? "Searching" : "Search"))
		: tool === "read_file"
			? (zh ? (active ? "正在阅读项目" : "阅读项目") : (active ? "Reading project" : "Read project"))
			: tool === "edit_file" || tool === "write_file"
				? (zh ? (active ? "正在修改作品" : "修改作品") : (active ? "Editing game" : "Edit game"))
				: tool === "build"
					? (zh ? (active ? "正在验证作品" : "验证作品") : (active ? "Validating game" : "Validate game"))
					: (zh ? (active ? "正在处理" : "处理") : (active ? "Working" : "Process"));
	const clean = reason.trim();
	return clean === "" ? label : `${label} · ${clean.slice(0, 72)}`;
};

type RemixThinkingStep = Pick<AgentSessionStepItem, "id" | "taskId" | "step" | "tool" | "status" | "reason" | "reasoningContent">;

export const resolveRemixThinkingStatus = (
	steps: RemixThinkingStep[],
	currentTaskId: number | undefined,
): string | undefined => {
	if (currentTaskId === undefined) return undefined;
	let current: RemixThinkingStep | undefined;
	for (const step of steps) {
		if (step.taskId !== currentTaskId) continue;
		if (!current || step.step > current.step || (step.step === current.step && step.id > current.id)) current = step;
	}
	if (!current || current.tool !== "message" || current.status !== "RUNNING"
		|| string.match(current.reason, "^%s*$")[0] === undefined) return undefined;
	let reasoning = string.gsub(current.reasoningContent, "\r\n", "\n")[0];
	reasoning = string.gsub(reasoning, "\r", "\n")[0];
	reasoning = string.gsub(reasoning, "[ \t\n]+$", "")[0];
	const lastLine = string.match(reasoning, "([^\n]+)$")[0] ?? "";
	if (lastLine === "") return undefined;
	return lastLine;
};

import { Content } from "Dora";
import {
	buildQuestionnaireAnswers,
	canLeaveRemix,
	canPlayRemix,
	compactAgentActivity,
	isQuestionAnswered,
	resolveRemixPhase,
	resolveRemixWorkMode,
} from "Dev/Mobile/RemixModel";
import type { AgentQuestion } from "Agent/Questionnaire";

const resultPath = "/tmp/dora-mobile-remix-model.result";
const expect = (condition: boolean, message: string) => { if (!condition) throw new Error(message); };

try {
	expect(resolveRemixWorkMode() === "code", "Missing session must default to code");
	expect(resolveRemixWorkMode({ kind: "main" }) === "code", "Missing preference must default to code");
	expect(resolveRemixWorkMode({ kind: "main", workMode: "invalid" }) === "code", "Invalid preference must default to code");
	expect(resolveRemixWorkMode({ kind: "main", workMode: "plan" }) === "plan", "Saved plan mode must be restored");
	expect(resolveRemixWorkMode({ kind: "main", workMode: "code" }) === "code", "Saved code mode must be restored");
	expect(resolveRemixWorkMode({ kind: "sub", workMode: "plan" }) === "code", "Sub sessions must match Web IDE code mode");
	expect(resolveRemixPhase({ status: "RUNNING", workMode: "plan", hasActivePlan: false }) === "planning", "plan phase mismatch");
	expect(resolveRemixPhase({ status: "DONE", workMode: "plan", hasActivePlan: true }) === "plan-ready", "plan-ready phase mismatch");
	expect(resolveRemixPhase({ status: "DONE", workMode: "plan", hasActivePlan: false }) === "plan-ready", "plan completion must not require a plan file");
	expect(resolveRemixPhase({ status: "IDLE", workMode: "plan", hasActivePlan: true }) === "idle", "old plan files must not gate a new request");
	expect(resolveRemixPhase({ status: "RUNNING", workMode: "code", hasActivePlan: true }) === "working", "code phase mismatch");
	expect(resolveRemixPhase({ status: "WAITING_USER", workMode: "plan", hasActivePlan: false }) === "waiting", "waiting phase mismatch");
	expect(resolveRemixPhase({ status: "FAILED", workMode: "code", hasActivePlan: true }) === "failed", "failed phase mismatch");
	expect(resolveRemixPhase({ status: "STOPPED", workMode: "code", hasActivePlan: true }) === "stopped", "stopped phase mismatch");
	expect(resolveRemixPhase({ status: "DONE", workMode: "code", hasActivePlan: false }) === "done", "done phase mismatch");
	expect(resolveRemixPhase({ status: "IDLE", workMode: "plan", hasActivePlan: false }) === "idle", "idle phase mismatch");
	expect(!canLeaveRemix("RUNNING") && !canLeaveRemix("WAITING_USER"), "active session must block leaving");
	expect(canLeaveRemix("STOPPED") && canLeaveRemix("FAILED") && canLeaveRemix("DONE"), "terminal session must allow leaving");
	expect(canPlayRemix("DONE") && !canPlayRemix("RUNNING") && !canPlayRemix("STOPPED"), "play gate mismatch");

	const textQuestion: AgentQuestion = { id: "name", prompt: "Name", type: "text", required: true, allowOther: false };
	const choiceQuestion: AgentQuestion = {
		id: "style",
		prompt: "Style",
		type: "single_choice",
		required: true,
		allowOther: true,
		options: [{ id: "fast", label: "Fast" }, { id: "calm", label: "Calm" }],
	};
	const optionalQuestion: AgentQuestion = { id: "notes", prompt: "Notes", type: "text", required: false, allowOther: false };
	expect(!isQuestionAnswered(textQuestion, [], "   "), "blank required text must be rejected");
	expect(isQuestionAnswered(textQuestion, [], " Dora "), "required text must be accepted");
	expect(!isQuestionAnswered(choiceQuestion, [], ""), "empty required choice must be rejected");
	expect(isQuestionAnswered(choiceQuestion, ["fast"], ""), "required choice must be accepted");
	const answers = buildQuestionnaireAnswers(
		[textQuestion, choiceQuestion, optionalQuestion],
		{ style: ["fast"] },
		{ name: " Dora ", notes: "   " },
	);
	expect(answers.length === 3, "questionnaire answer count mismatch");
	expect(answers[0].status === "answered" && answers[0].text === "Dora", "text answer normalization mismatch");
	expect(answers[1].status === "answered" && answers[1].selectedOptionIds?.[0] === "fast", "choice answer mismatch");
	expect(answers[2].status === "skipped", "optional blank answer must be skipped");

	expect(compactAgentActivity("edit_file", "update player speed", false).slice(0, 12) === "Editing game", "activity summary mismatch");
	expect(compactAgentActivity("search_files", "", true) === "正在查找资料", "search activity label mismatch");
	expect(compactAgentActivity("build", "", false) === "Validating game", "build activity label mismatch");
	expect(compactAgentActivity("unknown", "", false) === "Working", "fallback activity label mismatch");
	expect(compactAgentActivity("read_file", "x".repeat(100), false).length === "Reading project · ".length + 72, "activity reason must be truncated");
	Content.save(resultPath, "passed");
} catch (error) {
	Content.save(resultPath, `failed: ${error}`);
}

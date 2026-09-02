import { React, reference, toNode } from "DoraX";
import { App, DB, Director, Ease, HttpServer, Label, Move, Node, sleep, TextAlign, thread, Vec2 } from "Dora";
import * as AgentSession from "Agent/Session";
import { getActiveLLMConfig, getLLMConfig, getLLMConfigSummaries, safeJsonEncode } from "Agent/Utils";
import type { LLMConfig, LLMConfigSummary } from "Agent/Utils";
import type { AgentQuestionnaireAnswers } from "Agent/Questionnaire";
import { buildQuestionnaireAnswers, canLeaveRemix, isQuestionAnswered, resolveRemixPhase, resolveRemixThinkingStatus, resolveRemixWorkMode } from "Dev/Mobile/RemixModel";
import { DoraMascot, type DoraMascotState } from "Dev/Mobile/Mascot";
import { mobileFontScale } from "Dev/Mobile/Accessibility";
import { resolveFeedGesture } from "Dev/Mobile/FeedModel";
import { createRemixTranscript, remixDisplayRevision, type RemixTranscriptAction } from "Dev/Mobile/RemixTranscript";
import { REMIX_HISTORY_ROUNDS } from "Dev/Mobile/RemixHistory";
import { createTextInput, inputLength, inputSlice } from "Dev/Mobile/TextInput";
import { startMobileLLMManager } from "Dev/Mobile/LLMSetup";
import { RoundedSurface, VerticalGradient } from "Dev/Mobile/Visual";

interface RemixEntry {
	id: string;
	title: string;
	workDir?: string;
	fileName?: string;
}

type MobileLLMConfigResult = { success: true; id: number; config: LLMConfig } | { success: false; message: string };

export interface MobileRemixServices {
	createSession(this: void, projectRoot: string, title: string): { success: true; session: AgentSession.AgentSessionItem } | { success: false; message: string };
	getSession(this: void, sessionId: number): AgentSession.AgentSessionDetailResult;
	setWorkMode(this: void, sessionId: number, workMode: "plan" | "code"): { success: boolean; message?: string };
	sendPrompt(this: void, sessionId: number, prompt: string, disabledAgentTools: undefined, workMode: "plan" | "code", llmConfigId: number, llmConfig: LLMConfig): AgentSession.AgentSessionSendResult;
	respondQuestionnaire(this: void, sessionId: number, questionnaireId: number, answers: AgentQuestionnaireAnswers, llmConfigId: number): AgentSession.AgentSessionSendResult;
	stopSessionTask(this: void, sessionId: number): unknown;
	continuePrompt?(this: void, sessionId: number, disabledAgentTools?: unknown, llmConfigId?: number): AgentSession.AgentSessionSendResult;
	getActiveLLMConfig(this: void): MobileLLMConfigResult;
	getLLMConfig(this: void, configId: number): MobileLLMConfigResult;
	getLLMConfigSummaries(this: void): LLMConfigSummary[];
}

export interface RemixOptions {
	entry: RemixEntry;
	onBack: (this: void) => void;
	onPlay: (this: void, entry: RemixEntry) => void;
	onProjectChanged?: (this: void, entry: RemixEntry) => void;
	services?: MobileRemixServices;
}

const fontName = "sarasa-mono-sc-regular";
const colors = { background: 0xff0b0d12, panel: 0xff171c26, text: 0xfff4f1e8, muted: 0xffa8afbd, brand: 0xffffcc33, border: 0xff343b48, danger: 0xffff6b6b };
// One layout rhythm for both composer rows, in logical (not framebuffer) pixels.
const composerGap = 12;
const composerBottom = 76;
const composerHeight = 60;
const composerActionWidth = 82;
const modeBottom = composerBottom + composerHeight + composerGap;
const composerTop = modeBottom + 40;
const transcriptBottom = composerTop + composerGap;
const statusHeight = 64;

const ellipsizeSingleLine = (text: string, width: number, fontSize: number) => {
	if (text === "") return "";
	const measure = Label(fontName, fontSize, true);
	if (!measure) return text;
	measure.visible = false;
	measure.textWidth = -1;
	const fits = (value: string) => { measure.text = value; return measure.width <= width; };
	if (fits(text)) { measure.cleanup(); return text; }
	let low = 0, high = inputLength(text);
	while (low < high) {
		const middle = math.floor((low + high + 1) / 2);
		if (fits(`${inputSlice(text, 0, middle)}…`)) low = middle;
		else high = middle - 1;
	}
	const result = `${inputSlice(text, 0, low)}…`;
	measure.cleanup();
	return result;
};

function ActionButton(props: { x: number; y: number; width: number; height?: number; text: string; tag?: string; primary?: boolean; danger?: boolean; disabled?: boolean; onTapped(): void }) {
	const height = props.height ?? 46;
	return <node tag={props.tag} x={props.x} y={props.y} width={props.width} height={height} anchorX={0} anchorY={0} opacity={props.disabled ? 0.45 : 1} touchEnabled={!props.disabled} swallowTouches={true} onTapped={props.onTapped}>
		<RoundedSurface width={props.width} height={height} radius={14}
			topColor={props.danger ? 0xffff8585 : props.primary ? 0xffffdf6b : 0xff293140}
			bottomColor={props.danger ? 0xffdf4e56 : props.primary ? 0xffffbd2e : 0xff171d27}
			borderWidth={1} borderColor={props.danger ? colors.danger : props.primary ? 0xffffdd63 : colors.border} shadow={props.primary || props.danger} />
		<label x={props.width / 2} y={height / 2} fontName={fontName} fontSize={15} text={props.text} color3={props.primary ? 0x17130a : 0xf4f1e8} />
	</node>;
}

function ChoiceButton(props: { x: number; y: number; width: number; text: string; tag?: string; selected: boolean; disabled?: boolean; onTapped(): void }) {
	return <node tag={props.tag} x={props.x} y={props.y} width={props.width} height={40} anchorX={0} anchorY={0} opacity={props.disabled ? 0.45 : 1} touchEnabled={!props.disabled} swallowTouches={true} onTapped={props.onTapped}>
		<RoundedSurface width={props.width} height={40} radius={12}
			topColor={props.selected ? 0xffffdf6b : 0xff202836}
			bottomColor={props.selected ? 0xffffbd2e : 0xff10151d}
			borderWidth={1} borderColor={props.selected ? 0xffffdd63 : colors.border} />
		<draw-node tag={props.tag ? `${props.tag}-radio` : undefined} x={17} y={20}>
			<dot-shape radius={7} color={props.selected ? 0xff17130a : 0xffa8afbd} />
			<dot-shape radius={5} color={props.selected ? 0xffffcf48 : 0xff171c26} />
			{props.selected ? <draw-node tag={props.tag ? `${props.tag}-radio-dot` : undefined}><dot-shape radius={2.5} color={0xff17130a} /></draw-node> : undefined}
		</draw-node>
		<label x={32} y={20} anchorX={0} fontName={fontName} fontSize={14} text={props.text} textWidth={props.width - 44} alignment={TextAlign.Left} color3={props.selected ? 0x17130a : 0xf4f1e8} />
	</node>;
}

export function startMobileRemix(options: RemixOptions) {
	const onBack = options.onBack;
	const onPlay = options.onPlay;
	const services: MobileRemixServices = options.services ?? {
		createSession: AgentSession.createSession,
		getSession: id => AgentSession.getSession(id, { recentRounds: REMIX_HISTORY_ROUNDS, currentTaskStepsOnly: true }),
		setWorkMode: AgentSession.setWorkMode,
		sendPrompt: AgentSession.sendPrompt,
		respondQuestionnaire: AgentSession.respondQuestionnaire,
		stopSessionTask: AgentSession.stopSessionTask,
		continuePrompt: AgentSession.continuePrompt,
		getActiveLLMConfig,
		getLLMConfig,
		getLLMConfigSummaries,
	};
	const zh = string.match(App.locale, "^zh")[0] !== undefined;
	const projectRoot = options.entry.workDir ?? "";
	const created = services.createSession(projectRoot, options.entry.title);
	let sessionId = created.success ? created.session.id : 0;
	let detail: AgentSession.AgentSessionDetailResult = sessionId > 0
		? services.getSession(sessionId)
		: { success: false, message: created.success ? "session unavailable" : created.message };
	let draft = "";
	let error = created.success ? "" : created.message;
	let pollElapsed = 0;
	let stopRequested = false;
	let selectedLLMConfigId = 0;
	let questionnaireId = 0;
	let questionIndex = 0;
	let llmConfigs = services.getLLMConfigSummaries();
	let taskLLMConfigId = 0;
	let needsLLMSetup = false;
	const questionnaireSelections: Record<string, string[]> = {};
	const questionnaireTexts: Record<string, string> = {};
	let inputRef = reference<Node.Type>();
	let disposed = false;
	let dismissedComposition = false;
	let swipeBackPending = false;
	let swipeDragging = false;
	let swipeRevision = 0;
	let projectChangeNotified = false;
	const currentQuestion = () => detail.success ? detail.pendingQuestionnaire?.schema.questions[questionIndex] : undefined;
	const promptInput = createTextInput({
		fontSize: math.floor(16 * mobileFontScale),
		getText: () => { const question = currentQuestion(); return question ? (questionnaireTexts[question.id] ?? "") : draft; },
		setText: text => { const question = currentQuestion(); if (question) questionnaireTexts[question.id] = text; else draft = text; },
		getPlaceholder: () => {
			const question = currentQuestion();
			return question?.placeholder ?? (question ? (zh ? "输入回答…" : "Type an answer…") : (zh ? "输入修改要求…" : "Describe a change…"));
		},
		isEnabled: () => !disposed && host.parent !== undefined && host.visible && HttpServer.wsConnectionCount === 0,
		onReturn: modified => { if (modified && !currentQuestion()) { send(); return true; } return false; },
	});
	const blurInput = promptInput.blur;
	const rememberedRows = DB.query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") as unknown[][] | undefined;
	const rememberedId = rememberedRows && rememberedRows.length > 0 ? tonumber(rememberedRows[0][0]) : undefined;
	if (rememberedId && llmConfigs.some(item => item.id === rememberedId)) selectedLLMConfigId = rememberedId;
	else if (llmConfigs.length > 0) selectedLLMConfigId = llmConfigs[0].id;
	else {
		const activeConfig = services.getActiveLLMConfig();
		if (activeConfig.success) selectedLLMConfigId = activeConfig.id;
		else needsLLMSetup = true;
	}

	const host = Node();
	host.tag = "mobile-remix";
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI);
	const transcript = createRemixTranscript();
	let displayRevision = "";
	let shellRevision = "";
	let inputLayout = "";
	let mascotAnimationState: DoraMascotState | undefined;
	let mascotAnimationStartedAt = App.runningTime;
	let compactHeaderStatusActive = false;
	let errorLabel: Label.Type | undefined;
	let layoutTranscriptBottom = transcriptBottom;
	const getLayoutArea = () => App.safeArea;
	const getTranscriptBottom = () => layoutTranscriptBottom + (errorLabel ? errorLabel.height + composerGap : 0);
	const hasTranscriptContent = () => detail.success && (detail.messages.length > 0 || detail.steps.length > 0);
	const getHeaderY = (safe: { x: number; y: number; width: number; height: number }) => {
		const landscapeTopLift = safe.width >= 760 && safe.height < 500 ? 28 : 0;
		return safe.y + safe.height - 56 + landscapeTopLift;
	};
	const useCompactHeaderStatus = (safe: { width: number; height: number }) => safe.width >= 760 && safe.height < 500 && hasTranscriptContent();
	const useCompactStandaloneStatus = (safe: { height: number }) => safe.height >= 500 && hasTranscriptContent();
	const getTranscriptHeight = (safe: { x: number; y: number; width: number; height: number }) => {
		const statusInset = useCompactHeaderStatus(safe) ? composerGap
			: statusHeight + composerGap * 2 - (useCompactStandaloneStatus(safe) ? 24 : 0);
		const available = math.max(40, getHeaderY(safe) - safe.y - getTranscriptBottom() - statusInset);
		return safe.width >= 760 && safe.height < 500 && !hasTranscriptContent() ? 8 : available;
	};
	const getShellRevision = () => detail.success ? safeJsonEncode([
		detail.session.status, detail.session.workMode, detail.hasActivePlan, detail.pendingQuestionnaire ?? false,
		detail.session.currentTaskStatus ?? "", detail.session.currentTaskFinalizing ?? false, stopRequested, hasTranscriptContent(),
		resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) ?? "",
	])[0] ?? "" : detail.message;
	const updateTranscript = () => {
		const safe = getLayoutArea();
		transcript.update(detail, math.max(60, safe.width - 32), getTranscriptHeight(safe), mobileFontScale, zh, getTranscriptActions());
		displayRevision = remixDisplayRevision(detail);
	};

	const hasActiveTask = () => detail.success && (detail.session.status === "RUNNING" || detail.session.status === "WAITING_USER"
		|| detail.session.currentTaskStatus === "RUNNING" || detail.session.currentTaskStatus === "WAITING_USER"
		|| detail.session.currentTaskFinalizing === true || detail.pendingQuestionnaire !== undefined);
	const notifyProjectChanged = () => {
		if (projectChangeNotified || !detail.success || !options.onProjectChanged) return;
		if (!detail.steps.some(step => step.files !== undefined && step.files.length > 0)) return;
		projectChangeNotified = true;
		options.onProjectChanged(options.entry);
	};
	const refresh = () => {
		if (sessionId > 0) detail = services.getSession(sessionId);
		if (detail.success && !hasActiveTask()) stopRequested = false;
		if (detail.success && detail.pendingQuestionnaire && detail.pendingQuestionnaire.id !== questionnaireId) {
			questionnaireId = detail.pendingQuestionnaire.id;
			questionIndex = 0;
		}
	};
	const canSubmit = () => detail.success && canLeaveRemix(detail.session.status)
		&& detail.session.currentTaskStatus !== "RUNNING" && detail.session.currentTaskStatus !== "WAITING_USER"
		&& !detail.session.currentTaskFinalizing && !detail.pendingQuestionnaire;
	const resolveLLMConfig = () => selectedLLMConfigId > 0 ? services.getLLMConfig(selectedLLMConfigId) : services.getActiveLLMConfig();
	const configureLLM = () => {
		if (!host.visible || HttpServer.wsConnectionCount > 0) return;
		blurInput();
		startMobileLLMManager({
			coveredNode: host,
			selectedId: selectedLLMConfigId,
			taskRunning: hasActiveTask(),
			runningId: taskLLMConfigId,
			onSelected: id => {
				if (disposed || !host.parent) return;
				llmConfigs = services.getLLMConfigSummaries();
				selectedLLMConfigId = id;
				needsLLMSetup = llmConfigs.length === 0;
				error = "";
				render();
			},
			onClose: () => { if (!disposed && host.parent) render(); },
		});
	};
	const changeWorkMode = (workMode: "plan" | "code") => {
		if (!host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		if (!canSubmit() || !detail.success) return;
		if (resolveRemixWorkMode(detail.session) === workMode) return;
		const result = services.setWorkMode(sessionId, workMode);
		error = result.success ? "" : (result.message ?? (zh ? "切换模式失败" : "Could not change mode"));
		refresh();
		render();
	};
	const send = () => {
		if (!host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		if (!canSubmit() || !detail.success || promptInput.isComposing()) return;
		const workMode = resolveRemixWorkMode(detail.session);
		// Lua's generated JS trim includes multibyte whitespace in a byte character
		// class and can strip trailing Chinese bytes. Trim ASCII whitespace only.
		const text = string.match(draft, "^%s*(.-)%s*$")[0] ?? "";
		if (sessionId <= 0 || text === "") return;
		const config = resolveLLMConfig();
		if (!config.success) {
			error = zh ? "请先完成 AI 快速配置" : "Complete the quick AI setup first";
			render();
			configureLLM();
			return;
		}
		selectedLLMConfigId = config.id;
		const result = services.sendPrompt(sessionId, text, undefined, workMode, config.id, config.config);
		if (!result.success) error = result.message;
		else { taskLLMConfigId = config.id; draft = ""; error = ""; }
		refresh();
		render();
	};
	const continueTask = () => {
		if (!host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		if (!detail.success || hasActiveTask() || (detail.session.currentTaskStatus !== "FAILED" && detail.session.currentTaskStatus !== "STOPPED")
			|| detail.session.currentTaskId === undefined) return;
		const config = resolveLLMConfig();
		if (!config.success) {
			error = zh ? "请先完成 AI 快速配置" : "Complete the quick AI setup first";
			render();
			configureLLM();
			return;
		}
		if (!services.continuePrompt) {
			error = zh ? "当前版本不支持继续会话" : "Continuing this session is unavailable";
			render();
			return;
		}
		selectedLLMConfigId = config.id;
		const result = services.continuePrompt(sessionId, undefined, config.id);
		error = result.success ? "" : result.message;
		if (result.success) { taskLLMConfigId = config.id; stopRequested = false; }
		refresh();
		render();
	};
	const startDevelopment = () => {
		if (!host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		if (!detail.success || hasActiveTask() || detail.session.workMode !== "plan" || !detail.hasActivePlan) return;
		const modeResult = services.setWorkMode(sessionId, "code");
		if (!modeResult.success) {
			error = modeResult.message ?? (zh ? "切换执行模式失败" : "Could not switch to Code mode");
			render();
			return;
		}
		const config = resolveLLMConfig();
		if (!config.success) {
			error = zh ? "请先完成 AI 快速配置" : "Complete the quick AI setup first";
			refresh();
			render();
			configureLLM();
			return;
		}
		selectedLLMConfigId = config.id;
		const prompt = zh
			? "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。"
			: "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated.";
		const result = services.sendPrompt(sessionId, prompt, undefined, "code", config.id, config.config);
		error = result.success ? "" : result.message;
		if (result.success) taskLLMConfigId = config.id;
		refresh();
		render();
	};
	const getTranscriptActions = (): RemixTranscriptAction[] => {
		if (!detail.success || !hasTranscriptContent() || hasActiveTask() || detail.messages.every(message => message.role !== "assistant")) return [];
		const actions: RemixTranscriptAction[] = [];
		if ((detail.session.currentTaskStatus === "FAILED" || detail.session.currentTaskStatus === "STOPPED") && detail.session.currentTaskId !== undefined)
			actions.push({ id: "continue", text: zh ? "继续" : "Continue", onTapped: continueTask });
		if (detail.session.kind === "main" && detail.session.workMode === "plan" && detail.hasActivePlan)
			actions.push({ id: "start-development", text: zh ? "开始开发" : "Start development", primary: true, onTapped: startDevelopment });
		return actions;
	};
	const stop = () => {
		if (!host.visible || HttpServer.wsConnectionCount > 0) return;
		refresh();
		// A stale Stop control must never submit the draft after a task finishes.
		if (!hasActiveTask() || !detail.success || detail.session.currentTaskFinalizing || stopRequested) return;
		const result = services.stopSessionTask(sessionId) as { success?: boolean; message?: string } | undefined;
		if (result?.success === false) error = result.message ?? (zh ? "停止失败" : "Could not stop");
		else { stopRequested = true; error = ""; }
		refresh();
		render();
	};
	const advanceQuestionnaire = () => {
		if (!host.visible || HttpServer.wsConnectionCount > 0) return;
		if (!detail.success || !detail.pendingQuestionnaire) return;
		const pending = detail.pendingQuestionnaire;
		const questions = pending.schema.questions;
		const question = questions[questionIndex];
		if (!question) return;
		const selected = questionnaireSelections[question.id] ?? [];
		const text = (questionnaireTexts[question.id] ?? "").trim();
		if (!isQuestionAnswered(question, selected, text)) {
			error = zh ? "请先完成当前必答问题" : "Answer the required question first";
			render();
			return;
		}
		if (questionIndex + 1 < questions.length) {
			questionIndex++;
			error = "";
			render();
			return;
		}
		const answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts);
		if (selectedLLMConfigId <= 0) {
			error = zh ? "没有可用的模型配置" : "No model configuration is available";
			render();
			return;
		}
		const result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId);
		if (!result.success) error = result.message;
		else { taskLLMConfigId = selectedLLMConfigId; error = ""; }
		refresh();
		render();
	};
	const goBack = () => {
		if (swipeBackPending || !host.visible || HttpServer.wsConnectionCount > 0) return;
		if (detail.success && !canLeaveRemix(detail.session.status)) {
			error = zh ? "Agent 工作中，请先停止再返回" : "Stop the Agent before going back";
			render();
			return;
		}
		blurInput();
		notifyProjectChanged();
		host.visible = false;
		host.removeFromParent(true);
		onBack();
	};

	const render = () => {
		errorLabel = undefined;
		// Resizing/rebuilding cancels any old gesture and its delayed completion.
		swipeRevision++;
		swipeDragging = false;
		swipeBackPending = false;
		const layout = `${App.safeArea.width}:${App.safeArea.height}`;
		// Work/status updates must not detach the active IME node or discard composition.
		const keptInput = layout === inputLayout && !(detail.success && detail.pendingQuestionnaire)
			&& inputRef.current?.tag === "remix-input" ? inputRef.current : undefined;
		keptInput?.removeFromParent(false);
		transcript.node.removeFromParent(false);
		const restoreInputFocus = promptInput.isFocused();
		if (!keptInput) {
			promptInput.unmount();
			inputRef = reference<Node.Type>();
		}
		host.removeAllChildren();
		inputLayout = layout;
		host.scaleX = App.devicePixelRatio;
		host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const safe = getLayoutArea();
		const left = safe.x;
		const bottom = safe.y;
		const shortLandscape = safe.width >= 760 && safe.height < 500;
		const state = detail.success ? detail.session : undefined;
		const workMode = resolveRemixWorkMode(state);
		const stopping = hasActiveTask();
		const hasActivePlan = detail.success ? detail.hasActivePlan : false;
		const phase = state ? resolveRemixPhase({ status: state.status, workMode, hasActivePlan }) : "failed";
		const layoutComposerBottom = 24;
		const layoutComposerHeight = composerHeight;
		const layoutModeBottom = layoutComposerBottom + layoutComposerHeight + composerGap;
		const layoutComposerTop = layoutModeBottom + 40;
		layoutTranscriptBottom = layoutComposerTop + composerGap;
		const contentWidth = safe.width - 32;
		const inputWidth = contentWidth - composerActionWidth - composerGap;
		const inlinePlay = phase === "done";
		const modeWidth = inlinePlay
			? shortLandscape ? math.min(170, math.floor((contentWidth - composerGap * 2 - 120) / 2)) : math.floor((contentWidth - composerGap * 2) / 3)
			: math.floor((contentWidth - composerGap) / 2);
		const modeStartX = left + 16;
		const modeCodeWidth = inlinePlay && shortLandscape ? modeWidth
			: inlinePlay ? math.floor((contentWidth - composerGap * 2) / 3)
			: contentWidth - modeWidth - composerGap;
		const playWidth = inlinePlay ? contentWidth - modeWidth - modeCodeWidth - composerGap * 2 : 0;
		const playX = modeStartX + modeWidth + composerGap + modeCodeWidth + composerGap;
		const questionnaire = detail.success ? detail.pendingQuestionnaire : undefined;
		const question = questionnaire?.schema.questions[questionIndex];
		const fontScale = mobileFontScale;
		const headerY = getHeaderY(safe);
		const compactHeaderStatus = useCompactHeaderStatus(safe);
		compactHeaderStatusActive = compactHeaderStatus;
		const headerStatusWidth = 168;
		const modelButtonWidth = shortLandscape ? 92 : 72;
		const headerSettingsX = left + safe.width - 104 - modelButtonWidth;
		const headerStatusX = headerSettingsX - 8 - headerStatusWidth;
		const headerTitleWidth = compactHeaderStatus
			? math.max(120, headerStatusX - (left + 16) - composerGap)
			: math.max(120, headerSettingsX - (left + 16) - composerGap);
		const selectedConfig = llmConfigs.find(item => item.id === selectedLLMConfigId);
		const switchPending = hasActiveTask() && taskLLMConfigId > 0 && taskLLMConfigId !== selectedLLMConfigId;
		const modelName = selectedConfig?.name ?? (zh ? "配置 AI" : "Set up AI");
		const modelNameLimit = shortLandscape ? 10 : 6;
		const shortModelName = inputLength(modelName) > modelNameLimit ? `${inputSlice(modelName, 0, modelNameLimit)}…` : modelName;
		const modelLabel = ellipsizeSingleLine(`${switchPending ? (zh ? "下一轮·" : "Next·") : ""}${shortModelName}`, modelButtonWidth - 14, 11);
		const thinkingText = resolveRemixThinkingStatus(detail.success ? detail.steps : [], state?.currentTaskId);
		const statusText = thinkingText !== undefined ? (zh ? "正在思考" : "Thinking") : (phase === "planning" ? (zh ? "Dora 正在整理方案…" : "Dora is planning…")
			: phase === "working" ? (zh ? "Dora 正在 Remix…" : "Dora is remixing…")
			: phase === "plan-ready" ? (zh ? "计划对话已完成" : "Planning conversation complete")
			: phase === "waiting" ? (zh ? "需要你的确认" : "Waiting for you")
			: phase === "done" ? (zh ? "Remix 已完成" : "Remix complete")
			: phase === "failed" ? (zh ? "执行失败，可以修改要求后重试" : "Failed; revise and retry")
			: (zh ? "告诉 Dora 你想怎样改这个游戏" : "Tell Dora how to change this game"));
		const mascotState: DoraMascotState = phase === "planning" ? "thinking"
			: phase === "working" ? "working"
			: phase === "waiting" ? "waiting"
			: phase === "done" || phase === "plan-ready" ? "success"
			: phase === "failed" ? "failed"
			: "idle";
		if (mascotAnimationState !== mascotState) {
			mascotAnimationState = mascotState;
			mascotAnimationStartedAt = App.runningTime;
		}
		const emptyLandscape = shortLandscape && !hasTranscriptContent();
		const emptyStatusBottom = bottom + layoutModeBottom + 40 + composerGap;
		const emptyStatusTop = headerY - composerGap - statusHeight;
		const messageTop = emptyLandscape
			? (emptyStatusBottom + emptyStatusTop) / 2 + statusHeight / 2
			: headerY - composerGap - statusHeight / 2;
		const mascotSize = shortLandscape ? 42 : 52;
		const compactStandaloneStatus = useCompactStandaloneStatus(safe);
		const standaloneStatusContentLift = shortLandscape ? 0 : compactStandaloneStatus ? 26 : 14;
		const mascotX = shortLandscape ? left + 40 : left + 66;
		const statusTextX = shortLandscape ? left + 76 : left + 104;
		const statusTextWidth = shortLandscape ? math.max(120, left + 16 + contentWidth - statusTextX) : contentWidth - 84;
		const renderedStatusX = compactHeaderStatus ? 36 : statusTextX;
		const renderedStatusY = compactHeaderStatus ? 22 : statusHeight / 2 + standaloneStatusContentLift;
		const renderedStatusWidth = compactHeaderStatus ? headerStatusWidth - 36 : statusTextWidth;
		const thinkingFontSize = compactHeaderStatus ? math.floor(10 * fontScale) : math.floor(12 * fontScale);
		const thinkingRightPadding = compactHeaderStatus ? 8 : 20;
		const renderedThinkingText = thinkingText === undefined ? "" : ellipsizeSingleLine(thinkingText, renderedStatusWidth - thinkingRightPadding, thinkingFontSize);
		let swipeStart = Vec2.zero;
		let swipeAxis: "none" | "horizontal" | "vertical" = "none";
		const pageRef = reference<Node.Type>();
		const hitsTranscriptButton = (node: Node.Type, world: Vec2.Type): boolean => {
			if (!node.visible) return false;
			if (node.tag === "remix-copy" || node.tag === "remix-latest" || node.tag === "remix-action-continue" || node.tag === "remix-action-start-development") {
				const p = node.convertToNodeSpace(world);
				if (p.x >= 0 && p.y >= 0 && p.x <= node.width && p.y <= node.height) return true;
			}
			let hit = false;
			node.eachChild(child => { hit = hitsTranscriptButton(child, world); return hit; });
			return hit;
		};
		const scene = toNode(<node tag="remix-scene" x={-width / 2} y={-height / 2} width={width} height={height} anchorX={0} anchorY={0}>
			{/* Observe before swallowing children, without consuming their first tap/drag. */}
			<node tag="remix-focus-observer" order={1000} width={width} height={height} anchorX={0} anchorY={0}
				touchEnabled={true} swallowTouches={false} swallowMouseWheel={false} onTapFilter={touch => {
					touch.enabled = false;
					if (swipeBackPending || !host.visible || HttpServer.wsConnectionCount > 0) return;
					const input = inputRef.current;
					const point = input?.convertToNodeSpace(touch.worldLocation);
					const inside = input && point && point.x >= 0 && point.y >= 0 && point.x <= input.width && point.y <= input.height;
					dismissedComposition = !inside && promptInput.isComposing();
					if (!inside) blurInput();
					// Do not turn input editing, header/button taps, or questionnaires into navigation.
					if (!inside && !questionnaire && touch.first !== false
						&& touch.location.y >= bottom + layoutTranscriptBottom && touch.location.y < bottom + safe.height - 64
						&& !hitsTranscriptButton(transcript.node, touch.worldLocation)) {
						touch.enabled = true;
					}
				}}
				onTapBegan={touch => {
					swipeStart = touch.location; swipeAxis = "none"; swipeDragging = true;
					pageRef.current?.stopAllActions();
				}}
				onTapMoved={touch => {
					const delta = touch.location.sub(swipeStart);
					if (swipeAxis === "none" && math.max(math.abs(delta.x), math.abs(delta.y)) >= 12)
						swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 ? "horizontal" : "vertical";
					// The observer stays stationary, so moving the page never changes gesture coordinates.
					if (pageRef.current) pageRef.current.x = swipeAxis === "horizontal" ? math.min(0, delta.x) * 0.18 : 0;
				}}
				onTapEnded={touch => {
					const delta = touch.location.sub(swipeStart);
					swipeDragging = false;
					if (swipeBackPending) return;
					const requested = swipeAxis !== "vertical" && resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) === "play";
					const leaving = requested && (!detail.success || canLeaveRemix(detail.session.status));
					const page = pageRef.current;
					if (!page || (!requested && page.x === 0)) return;
					const duration = leaving || App.reducedMotion ? 0 : 0.16;
					const revision = swipeRevision;
					swipeBackPending = true;
					// Hold the release offset until removal; resetting before the deferred switch flashes a rebound frame.
					if (!leaving) page.perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad));
					// Also defer zero-duration completion: native TapEnded is followed by Tapped on this node.
					thread(() => {
						sleep(duration);
						if (disposed || revision !== swipeRevision || !host.parent) return;
						swipeBackPending = false;
						if (requested && host.visible && HttpServer.wsConnectionCount === 0) { refresh(); goBack(); }
						else page.position = Vec2.zero;
					});
				}} />
			<VerticalGradient width={width} height={height} topColor={0xff111725} bottomColor={0xff080a0f} />
			<node tag="remix-page" ref={pageRef}>
			<clip-node x={left + 16} y={headerY} width={headerTitleWidth} height={44} anchorX={0} anchorY={0}
				stencil={<draw-node x={headerTitleWidth / 2} y={22}><rect-shape width={headerTitleWidth} height={44} fillColor={0xffffffff} /></draw-node>}>
				<label tag="remix-title" x={0} y={22} anchorX={0} fontName={fontName} fontSize={20} text={`REMIX · ${options.entry.title}`} color3={0xf4f1e8} />
			</clip-node>
			<node tag="remix-back" x={left + safe.width - 96} y={headerY} width={80} height={44}
				anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={goBack}>
				<label x={80} y={22} anchorX={1} fontName={fontName} fontSize={18} text={zh ? "返回 ›" : "Back ›"} color3={0xffcc33} />
			</node>
			<node tag="remix-model-config" x={headerSettingsX} y={headerY + 6} width={modelButtonWidth} height={32}
				anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={configureLLM}>
				<RoundedSurface width={modelButtonWidth} height={32} radius={16} topColor={0x332c3442} bottomColor={0x33121921}
					borderWidth={1} borderColor={needsLLMSetup ? colors.brand : colors.border} />
				<label x={modelButtonWidth / 2} y={16} fontName={fontName} fontSize={11} text={modelLabel} color3={needsLLMSetup || switchPending ? 0xffcc33 : 0xa8afbd} />
				{needsLLMSetup ? <draw-node x={modelButtonWidth - 4} y={28}><dot-shape radius={3} color={0xffffcc33} /></draw-node> : undefined}
			</node>
			<node tag="remix-status" x={compactHeaderStatus ? headerStatusX : 0} y={compactHeaderStatus ? headerY : messageTop - statusHeight / 2}
				width={compactHeaderStatus ? headerStatusWidth : width} height={compactHeaderStatus ? 44 : statusHeight} anchorX={0} anchorY={0}>
				<DoraMascot state={mascotState} x={compactHeaderStatus ? 16 : mascotX} y={compactHeaderStatus ? 20 : statusHeight / 2 - 2 + standaloneStatusContentLift}
					size={compactHeaderStatus ? 30 : mascotSize} animationStartedAt={mascotAnimationStartedAt} />
				<clip-node tag="remix-status-clip" x={renderedStatusX} y={renderedStatusY - 22} width={renderedStatusWidth} height={44} anchorX={0} anchorY={0}
					stencil={<draw-node x={renderedStatusWidth / 2} y={22}><rect-shape width={renderedStatusWidth} height={44} fillColor={0xffffffff} /></draw-node>}>
					<label tag="remix-status-text" x={0} y={22} anchorX={0} fontName={fontName}
						fontSize={compactHeaderStatus ? math.floor(13 * fontScale) : math.floor(15 * fontScale)} text={statusText}
						textWidth={-1} alignment={TextAlign.Left} color3={phase === "failed" ? 0xff6b6b : 0xffcc33} />
					<label tag="remix-thinking-text" x={0} y={6} anchorX={0} fontName={fontName}
						fontSize={thinkingFontSize} text={renderedThinkingText}
						textWidth={-1} alignment={TextAlign.Left} color3={colors.muted} />
				</clip-node>
			</node>
			{questionnaire && question ? <node tag="remix-questionnaire" x={left + 16} y={bottom + 164} width={contentWidth} height={safe.height - 330} anchorX={0} anchorY={0}>
				<RoundedSurface width={contentWidth} height={safe.height - 330} radius={20} topColor={0xff222b3a} bottomColor={0xff121720} borderWidth={1} borderColor={0xff414b5d} shadow={true} />
				<label x={16} y={safe.height - 360} anchorX={0} fontName={fontName} fontSize={13} text={`${questionIndex + 1} / ${questionnaire.schema.questions.length} · ${questionnaire.schema.title}`} textWidth={contentWidth - 32} alignment={TextAlign.Left} color3={0xffcc33} />
				<label x={16} y={safe.height - 405} anchorX={0} fontName={fontName} fontSize={16} text={question.prompt} textWidth={contentWidth - 32} alignment={TextAlign.Left} color3={0xf4f1e8} />
				{question.type !== "text" ? (question.options ?? []).slice(0, 8).map((option, optionIndex) => <ChoiceButton
					tag={`remix-question-${question.id}-option-${option.id}`}
					x={16} y={safe.height - 460 - optionIndex * 43} width={contentWidth - 32}
					text={`${(questionnaireSelections[question.id] ?? []).indexOf(option.id) >= 0 ? "●" : "○"} ${option.label}${option.recommended ? (zh ? "（推荐）" : " (recommended)") : ""}`}
					selected={(questionnaireSelections[question.id] ?? []).indexOf(option.id) >= 0}
					onTapped={() => {
						const selected = questionnaireSelections[question.id] ?? [];
						questionnaireSelections[question.id] = question.type === "single_choice"
							? [option.id]
							: selected.indexOf(option.id) >= 0 ? selected.filter(id => id !== option.id) : [...selected, option.id];
						render();
					}}
				/>) : <node tag="remix-question-input" ref={inputRef} x={16} y={safe.height - 510} width={contentWidth - 32} height={92} anchorX={0} anchorY={0}
					onMount={promptInput.mount} />}
				{questionIndex > 0 ? <ActionButton x={16} y={12} width={92} text={zh ? "上一步" : "Back"} onTapped={() => { questionIndex--; render(); }} /> : undefined}
				<ActionButton tag="remix-question-submit" x={questionIndex > 0 ? 120 : 16} y={12} width={contentWidth - (questionIndex > 0 ? 136 : 32)}
					text={questionIndex + 1 === questionnaire.schema.questions.length ? (zh ? "提交回答" : "Submit") : (zh ? "下一步" : "Next")}
					primary={true} onTapped={() => { if (!dismissedComposition) advanceQuestionnaire(); dismissedComposition = false; }} />
			</node> : undefined}
			{error !== "" ? <label tag="remix-error" x={left + 20} y={bottom + (questionnaire ? 144 : layoutComposerTop + composerGap)} anchorX={0} anchorY={0} fontName={fontName} fontSize={13} text={error} textWidth={contentWidth} alignment={TextAlign.Left} color3={0xff6b6b} onMount={label => { errorLabel = label; }} /> : undefined}
			{questionnaire === undefined ? <node>
				<ChoiceButton tag="remix-mode-plan" x={modeStartX} y={bottom + layoutModeBottom} width={modeWidth} text={zh ? "计划" : "Plan"} selected={workMode === "plan"} disabled={!canSubmit()} onTapped={() => changeWorkMode("plan")} />
				<ChoiceButton tag="remix-mode-code" x={modeStartX + modeWidth + composerGap} y={bottom + layoutModeBottom} width={modeCodeWidth} text={zh ? "执行" : "Code"} selected={workMode === "code"} disabled={!canSubmit()} onTapped={() => changeWorkMode("code")} />
			</node> : undefined}
			{questionnaire === undefined && !keptInput ? <node tag="remix-input" ref={inputRef} x={left + 16} y={bottom + layoutComposerBottom} width={inputWidth} height={layoutComposerHeight} anchorX={0} anchorY={0}
				onMount={promptInput.mount} /> : undefined}
			{stopping || questionnaire === undefined ? <ActionButton tag={stopping ? "remix-stop" : "remix-send"}
				x={left + 16 + inputWidth + composerGap} y={bottom + layoutComposerBottom} width={composerActionWidth} height={layoutComposerHeight}
				text={stopping ? (state?.currentTaskFinalizing ? (zh ? "收尾中" : "Finishing") : stopRequested ? (zh ? "停止中" : "Stopping") : (zh ? "停止" : "Stop")) : (zh ? "发送" : "Send")}
				primary={!stopping} danger={stopping} disabled={stopping ? stopRequested || state?.currentTaskFinalizing === true : !canSubmit()}
				onTapped={() => { if (stopping) stop(); else if (!dismissedComposition) send(); dismissedComposition = false; }} /> : undefined}
			{phase === "done" ? <ActionButton tag="remix-play" x={playX} y={bottom + layoutModeBottom} width={playWidth} height={40} text={zh ? "立即试玩" : "Play now"} primary={true} onTapped={() => { if (!host.visible || HttpServer.wsConnectionCount > 0) return; blurInput(); notifyProjectChanged(); host.visible = false; onPlay(options.entry); }} /> : undefined}
			</node>
		</node>);
		if (scene) {
			host.addChild(scene);
			if (keptInput) {
				keptInput.position = Vec2(left + 16, bottom + layoutComposerBottom);
				keptInput.width = inputWidth;
				keptInput.height = layoutComposerHeight;
				pageRef.current?.addChild(keptInput);
			}
			if (!questionnaire) {
				transcript.node.position = Vec2(left + 16, bottom + getTranscriptBottom());
				pageRef.current?.addChild(transcript.node);
				updateTranscript();
			}
		}
		if (restoreInputFocus && inputRef.current && !keptInput) promptInput.focus(false);
		if (keptInput) promptInput.refresh();
		shellRevision = getShellRevision();
		displayRevision = remixDisplayRevision(detail);
	};

	host.schedule(dt => {
		pollElapsed += dt;
		if (pollElapsed < 0.25) return false;
		pollElapsed = 0;
		refresh();
		if (swipeDragging || swipeBackPending) return false;
		const next = remixDisplayRevision(detail);
		if (shellRevision !== getShellRevision() || compactHeaderStatusActive !== useCompactHeaderStatus(getLayoutArea())) render();
		else if (displayRevision !== next) updateTranscript();
		return false;
	});
	host.onAppChange(setting => { if (setting === "Size" || setting === "Locale") render(); });
	host.onAppEvent(event => {
		if (event === "BackButton") { if (promptInput.isFocused()) blurInput(); else goBack(); }
		else if (event === "WillEnterBackground" || event === "DidEnterBackground") blurInput();
	});
	host.onCleanup(() => { disposed = true; blurInput(); });
	host.slot("SuspendLocalUI", blurInput);
	host.slot("ResumeLocalUI", () => { refresh(); render(); });
	render();
	if (needsLLMSetup) thread(() => { sleep(0); if (!disposed && host.parent) configureLLM(); });
	return host;
}

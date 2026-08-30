import { React, reference, toNode } from "DoraX";
import { App, DB, Director, Ease, HttpServer, Keyboard, KeyName, Label, Move, Node, sleep, TextAlign, thread, Vec2 } from "Dora";
import * as AgentSession from "Agent/Session";
import { getActiveLLMConfig, getLLMConfig, getLLMConfigSummaries, safeJsonEncode } from "Agent/Utils";
import type { LLMConfig, LLMConfigSummary } from "Agent/Utils";
import type { AgentQuestionnaireAnswers } from "Agent/Questionnaire";
import { buildQuestionnaireAnswers, canLeaveRemix, isQuestionAnswered, resolveRemixPhase, resolveRemixWorkMode } from "Dev/Mobile/RemixModel";
import { DoraMascot, type DoraMascotState } from "Dev/Mobile/Mascot";
import { mobileFontScale } from "Dev/Mobile/Accessibility";
import { resolveFeedGesture } from "Dev/Mobile/FeedModel";
import { createRemixTranscript, remixDisplayRevision } from "Dev/Mobile/RemixTranscript";
import { REMIX_HISTORY_ROUNDS } from "Dev/Mobile/RemixHistory";
import { createRemixInputView, inputLength, inputSlice, insertInputText } from "Dev/Mobile/RemixInput";

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
	getActiveLLMConfig(this: void): MobileLLMConfigResult;
	getLLMConfig(this: void, configId: number): MobileLLMConfigResult;
	getLLMConfigSummaries(this: void): LLMConfigSummary[];
}

export interface RemixOptions {
	entry: RemixEntry;
	onBack: (this: void) => void;
	onPlay: (this: void, entry: RemixEntry) => void;
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
const statusTopInset = 56 + composerGap;
const statusHeight = 64;
const transcriptTopInset = statusTopInset + statusHeight + composerGap;

function ActionButton(props: { x: number; y: number; width: number; height?: number; text: string; tag?: string; primary?: boolean; danger?: boolean; disabled?: boolean; onTapped(): void }) {
	const color = props.danger ? colors.danger : props.primary ? colors.brand : colors.panel;
	const height = props.height ?? 46;
	return <node tag={props.tag} x={props.x} y={props.y} width={props.width} height={height} anchorX={0} anchorY={0} opacity={props.disabled ? 0.45 : 1} touchEnabled={!props.disabled} swallowTouches={true} onTapped={props.onTapped}>
		<draw-node x={props.width / 2} y={height / 2}><rect-shape width={props.width} height={height} fillColor={color} borderWidth={1} borderColor={props.primary || props.danger ? color : colors.border} /></draw-node>
		<label x={props.width / 2} y={height / 2} fontName={fontName} fontSize={15} text={props.text} color3={props.primary ? 0x17130a : 0xf4f1e8} />
	</node>;
}

function ChoiceButton(props: { x: number; y: number; width: number; text: string; tag?: string; selected: boolean; disabled?: boolean; onTapped(): void }) {
	return <node tag={props.tag} x={props.x} y={props.y} width={props.width} height={40} anchorX={0} anchorY={0} opacity={props.disabled ? 0.45 : 1} touchEnabled={!props.disabled} swallowTouches={true} onTapped={props.onTapped}>
		<draw-node x={props.width / 2} y={20}><rect-shape width={props.width} height={40} fillColor={props.selected ? colors.brand : colors.background} borderWidth={1} borderColor={props.selected ? colors.brand : colors.border} /></draw-node>
		<label x={12} y={20} anchorX={0} fontName={fontName} fontSize={14} text={props.text} textWidth={props.width - 24} alignment={TextAlign.Left} color3={props.selected ? 0x17130a : 0xf4f1e8} />
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
	const llmConfigs = services.getLLMConfigSummaries();
	let modelPickerOpen = false;
	const questionnaireSelections: Record<string, string[]> = {};
	const questionnaireTexts: Record<string, string> = {};
	let inputRef = reference<Node.Type>();
	let inputLabel: Label.Type | undefined;
	let inputFocused = false;
	let focusRevision = 0;
	let disposed = false;
	let refreshInputDisplay = () => {};
	let dismissedComposition = false;
	let swipeBackPending = false;
	let swipeDragging = false;
	let swipeRevision = 0;
	let composingText = "";
	let inputCursor = 0;
	let compositionCursor = 0;
	let inputView: ReturnType<typeof createRemixInputView> | undefined;
	const clearInputFocus = () => {
		focusRevision++;
		inputFocused = false;
		composingText = "";
		compositionCursor = 0;
		if (inputRef.current) inputRef.current.keyboardEnabled = false;
		refreshInputDisplay();
	};
	const blurInput = () => {
		if (inputFocused) inputRef.current?.detachIME();
		// Also cancel a pending attach, for which DetachIME is not emitted yet.
		clearInputFocus();
	};
	const updateIMEPos = (next?: (this: void) => void) => {
		const input = inputRef.current;
		const label = inputLabel;
		if (!input || !label) return;
		const revision = focusRevision;
		const caret = inputView?.caretPosition() ?? Vec2(12, 8);
		input.convertToWindowSpace(Vec2(math.max(12, math.min(input.width - 12, caret.x)), math.max(8, math.min(input.height - 8, caret.y))), pos => {
			if (disposed || revision !== focusRevision || inputRef.current !== input) return;
			Keyboard.updateIMEPosHint(pos);
			next?.();
		});
	};
	const updateInputLabel = (text: string, placeholder: string) => {
		const label = inputLabel;
		if (!label) return;
		inputView?.update(text, placeholder, inputFocused, inputCursor + compositionCursor);
		if (inputFocused) updateIMEPos();
	};
	const rememberedRows = DB.query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") as unknown[][] | undefined;
	const rememberedId = rememberedRows && rememberedRows.length > 0 ? tonumber(rememberedRows[0][0]) : undefined;
	if (rememberedId && llmConfigs.some(item => item.id === rememberedId)) selectedLLMConfigId = rememberedId;
	else if (llmConfigs.length === 1) selectedLLMConfigId = llmConfigs[0].id;
	else if (llmConfigs.length > 1) modelPickerOpen = true;
	else {
		const activeConfig = services.getActiveLLMConfig();
		if (activeConfig.success) selectedLLMConfigId = activeConfig.id;
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
	let errorLabel: Label.Type | undefined;
	const getTranscriptBottom = () => transcriptBottom + (errorLabel ? errorLabel.height + composerGap : 0);
	const getShellRevision = () => detail.success ? safeJsonEncode([
		detail.session.status, detail.session.workMode, detail.hasActivePlan, detail.pendingQuestionnaire ?? false,
		detail.session.currentTaskStatus ?? "", detail.session.currentTaskFinalizing ?? false, stopRequested,
	])[0] ?? "" : detail.message;
	const updateTranscript = () => {
		const safe = App.safeArea;
		transcript.update(detail, math.max(60, safe.width - 32), math.max(40, safe.height - getTranscriptBottom() - transcriptTopInset), mobileFontScale, zh);
		displayRevision = remixDisplayRevision(detail);
	};

	const hasActiveTask = () => detail.success && (detail.session.status === "RUNNING" || detail.session.status === "WAITING_USER"
		|| detail.session.currentTaskStatus === "RUNNING" || detail.session.currentTaskStatus === "WAITING_USER"
		|| detail.session.currentTaskFinalizing === true || detail.pendingQuestionnaire !== undefined);
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
		if (!canSubmit() || !detail.success || composingText !== "") return;
		const workMode = resolveRemixWorkMode(detail.session);
		// Lua's generated JS trim includes multibyte whitespace in a byte character
		// class and can strip trailing Chinese bytes. Trim ASCII whitespace only.
		const text = string.match(draft, "^%s*(.-)%s*$")[0] ?? "";
		if (sessionId <= 0 || text === "") return;
		const config = selectedLLMConfigId > 0 ? services.getLLMConfig(selectedLLMConfigId) : services.getActiveLLMConfig();
		if (!config.success) {
			error = zh ? "请先在桌面 Web IDE 中配置并启用一个模型" : "Configure and activate a model in Web IDE first";
			render();
			return;
		}
		selectedLLMConfigId = config.id;
		const result = services.sendPrompt(sessionId, text, undefined, workMode, config.id, config.config);
		if (!result.success) error = result.message;
		else { draft = ""; inputCursor = 0; error = ""; }
		refresh();
		render();
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
	const selectModel = (id: number) => {
		selectedLLMConfigId = id;
		modelPickerOpen = false;
		DB.exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", [id]);
		error = "";
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
		else error = "";
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
		const keptInput = layout === inputLayout && !modelPickerOpen && !(detail.success && detail.pendingQuestionnaire)
			&& inputRef.current?.tag === "remix-input" ? inputRef.current : undefined;
		keptInput?.removeFromParent(false);
		transcript.node.removeFromParent(false);
		const restoreInputFocus = inputFocused;
		if (!keptInput) {
			blurInput();
			inputRef = reference<Node.Type>();
			inputLabel = undefined;
			inputView = undefined;
		}
		host.removeAllChildren();
		inputLayout = layout;
		host.scaleX = App.devicePixelRatio;
		host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const safe = App.safeArea;
		const left = safe.x;
		const bottom = safe.y;
		const contentWidth = safe.width - 32;
		const inputWidth = contentWidth - composerActionWidth - composerGap;
		const modeWidth = math.floor((contentWidth - composerGap) / 2);
		const state = detail.success ? detail.session : undefined;
		const workMode = resolveRemixWorkMode(state);
		const stopping = hasActiveTask();
		const hasActivePlan = detail.success ? detail.hasActivePlan : false;
		const phase = state ? resolveRemixPhase({ status: state.status, workMode, hasActivePlan }) : "failed";
		const questionnaire = detail.success ? detail.pendingQuestionnaire : undefined;
		const question = questionnaire?.schema.questions[questionIndex];
		const focusInput = (reopen = true) => {
			if (disposed || !host.visible || HttpServer.wsConnectionCount > 0) return;
			focusRevision++;
			// Follow Dora-Example/TextInput: transform the actual node, then reconnect.
			updateIMEPos(() => {
				if (!host.visible || HttpServer.wsConnectionCount > 0) return;
				if (reopen) inputRef.current?.detachIME();
				inputRef.current?.attachIME();
				updateIMEPos();
			});
		};
		const inputPlaceholder = question?.placeholder ?? (question ? (zh ? "输入回答…" : "Type an answer…") : (zh ? "输入修改要求…" : "Describe a change…"));
		const getInputText = () => question ? (questionnaireTexts[question.id] ?? "") : draft;
		refreshInputDisplay = () => updateInputLabel(getInputText(), inputPlaceholder);
		const setInputText = (text: string, cursor = inputLength(text)) => {
			if (question) questionnaireTexts[question.id] = text;
			else draft = text;
			inputCursor = cursor;
			updateInputLabel(text, inputPlaceholder);
		};
		const attachInput = () => {
			inputFocused = true;
			composingText = "";
			compositionCursor = 0;
			if (inputRef.current) inputRef.current.keyboardEnabled = true;
			updateInputLabel(getInputText(), inputPlaceholder);
		};
		const detachInput = clearInputFocus;
		const textInput = (text: string) => {
			if (!host.visible || HttpServer.wsConnectionCount > 0) return;
			composingText = "";
			compositionCursor = 0;
			const normalized = string.gsub(string.gsub(text, "\r\n", "\n")[0], "\r", "\n")[0];
			setInputText(insertInputText(getInputText(), inputCursor, normalized), inputCursor + inputLength(normalized));
		};
		const textEditing = (text: string, start?: number) => {
			if (!host.visible || HttpServer.wsConnectionCount > 0) return;
			composingText = text;
			compositionCursor = math.max(0, math.min(inputLength(text), start ?? inputLength(text)));
			updateInputLabel(insertInputText(getInputText(), inputCursor, text), inputPlaceholder);
		};
		const keyInput = (key: KeyName) => {
			if (!host.visible || HttpServer.wsConnectionCount > 0) return;
			if (key === KeyName.Escape) { blurInput(); return; }
			// Composition belongs to the IME; do not delete committed text underneath it.
			if (composingText !== "") return;
			const value = getInputText();
			if (key === KeyName.BackSpace && inputCursor > 0) setInputText(inputSlice(value, 0, inputCursor - 1) + inputSlice(value, inputCursor), inputCursor - 1);
			else if (key === KeyName.Delete && inputCursor < inputLength(value)) setInputText(inputSlice(value, 0, inputCursor) + inputSlice(value, inputCursor + 1), inputCursor);
			else if (key === KeyName.Left || key === KeyName.Right || key === KeyName.Home || key === KeyName.End || key === KeyName.Up || key === KeyName.Down) {
				inputCursor = key === KeyName.Home ? 0 : key === KeyName.End ? inputLength(value)
					: key === KeyName.Up || key === KeyName.Down ? inputView?.verticalIndex(inputCursor, key === KeyName.Up ? -1 : 1) ?? inputCursor
					: math.max(0, math.min(inputLength(value), inputCursor + (key === KeyName.Left ? -1 : 1)));
				updateInputLabel(value, inputPlaceholder);
			}
			else if (key === KeyName.Return) {
				if (!question && (Keyboard.isKeyPressed(KeyName.LCtrl) || Keyboard.isKeyPressed(KeyName.RCtrl) || Keyboard.isKeyPressed(KeyName.LGui) || Keyboard.isKeyPressed(KeyName.RGui))) send();
				else textInput("\n");
			}
		};
		const fontScale = mobileFontScale;
		const mountInput = (node: Node.Type) => {
			inputView = createRemixInputView(node, math.floor(16 * fontScale));
			inputLabel = inputView.label;
			inputCursor = math.min(inputCursor, inputLength(getInputText()));
			updateInputLabel(insertInputText(getInputText(), inputCursor, composingText), inputPlaceholder);
		};
		let dragDistance = 0;
		const tapInput = (touch?: { location: Vec2.Type }) => {
			if (dragDistance > 5 || !host.visible || HttpServer.wsConnectionCount > 0) return;
			if (touch && composingText === "") inputCursor = inputView?.indexAt(touch.location) ?? inputCursor;
			updateInputLabel(insertInputText(getInputText(), inputCursor, composingText), inputPlaceholder);
			if (!inputFocused) focusInput();
		};
		const pickerHeight = math.min(420, safe.height - 280);
		const statusText = phase === "planning" ? (zh ? "Dora 正在整理方案…" : "Dora is planning…")
			: phase === "working" ? (zh ? "Dora 正在 Remix…" : "Dora is remixing…")
			: phase === "plan-ready" ? (zh ? "计划对话已完成" : "Planning conversation complete")
			: phase === "waiting" ? (zh ? "需要你的确认" : "Waiting for you")
			: phase === "done" ? (zh ? "Remix 已完成" : "Remix complete")
			: phase === "failed" ? (zh ? "执行失败，可以修改要求后重试" : "Failed; revise and retry")
			: (zh ? "告诉 Dora 你想怎样改这个游戏" : "Tell Dora how to change this game");
		const mascotState: DoraMascotState = phase === "planning" ? "thinking"
			: phase === "working" ? "working"
			: phase === "waiting" ? "waiting"
			: phase === "done" || phase === "plan-ready" ? "success"
			: phase === "failed" ? "failed"
			: "idle";
		const messageTop = bottom + safe.height - statusTopInset - statusHeight / 2;
		let swipeStart = Vec2.zero;
		let swipeAxis: "none" | "horizontal" | "vertical" = "none";
		const pageRef = reference<Node.Type>();
		const hitsTranscriptButton = (node: Node.Type, world: Vec2.Type): boolean => {
			if (!node.visible) return false;
			if (node.tag === "remix-copy" || node.tag === "remix-latest") {
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
					dismissedComposition = !inside && composingText !== "";
					if (!inside) blurInput();
					// Do not turn input editing, header/button taps, or questionnaires into navigation.
					if (!inside && !questionnaire && !modelPickerOpen && touch.first !== false
						&& touch.location.y >= bottom + transcriptBottom && touch.location.y < bottom + safe.height - 64
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
			<draw-node x={width / 2} y={height / 2}><rect-shape width={width} height={height} fillColor={colors.background} /></draw-node>
			<node tag="remix-page" ref={pageRef}>
			<clip-node x={left + 16} y={bottom + safe.height - 56} width={safe.width - 124} height={44} anchorX={0} anchorY={0}
				stencil={<draw-node x={(safe.width - 124) / 2} y={22}><rect-shape width={safe.width - 124} height={44} fillColor={0xffffffff} /></draw-node>}>
				<label tag="remix-title" x={0} y={22} anchorX={0} fontName={fontName} fontSize={20} text={`REMIX · ${options.entry.title}`} color3={0xf4f1e8} />
			</clip-node>
			<node tag="remix-back" x={left + safe.width - 96} y={bottom + safe.height - 56} width={80} height={44}
				anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={goBack}>
				<label x={80} y={22} anchorX={1} fontName={fontName} fontSize={18} text={zh ? "返回 ›" : "Back ›"} color3={0xffcc33} />
			</node>
			<node tag="remix-status" y={messageTop - statusHeight / 2} width={width} height={statusHeight} anchorX={0} anchorY={0}>
				<DoraMascot state={mascotState} x={left + 66} y={statusHeight / 2 - 2} size={52} />
				<label x={left + 104} y={statusHeight / 2} anchorX={0} fontName={fontName} fontSize={math.floor(15 * fontScale)} text={statusText} textWidth={contentWidth - 84} alignment={TextAlign.Left} color3={phase === "failed" ? 0xff6b6b : 0xffcc33} />
			</node>
			{questionnaire && question ? <node tag="remix-questionnaire" x={left + 16} y={bottom + 164} width={contentWidth} height={safe.height - 330} anchorX={0} anchorY={0}>
				<draw-node x={contentWidth / 2} y={(safe.height - 330) / 2}><rect-shape width={contentWidth} height={safe.height - 330} fillColor={colors.panel} borderWidth={1} borderColor={colors.border} /></draw-node>
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
				/>) : <node ref={inputRef} x={16} y={safe.height - 510} width={contentWidth - 32} height={92} anchorX={0} anchorY={0}
					touchEnabled={true} swallowTouches={true} onTapped={tapInput} onMount={mountInput}
					onTapBegan={() => { dragDistance = 0; }} onTapMoved={touch => { dragDistance += math.abs(touch.delta.y); inputView?.scroll(touch.delta.y); }}
					onMouseWheel={delta => inputView?.scroll(-delta.y * 20)}
					onAttachIME={attachInput} onDetachIME={detachInput}
					onTextInput={textInput} onTextEditing={textEditing} onKeyDown={keyInput}>
					<draw-node x={(contentWidth - 32) / 2} y={46}><rect-shape width={contentWidth - 32} height={92} fillColor={colors.background} borderWidth={1} borderColor={colors.border} /></draw-node>
				</node>}
				{questionIndex > 0 ? <ActionButton x={16} y={12} width={92} text={zh ? "上一步" : "Back"} onTapped={() => { questionIndex--; render(); }} /> : undefined}
				<ActionButton tag="remix-question-submit" x={questionIndex > 0 ? 120 : 16} y={12} width={contentWidth - (questionIndex > 0 ? 136 : 32)}
					text={questionIndex + 1 === questionnaire.schema.questions.length ? (zh ? "提交回答" : "Submit") : (zh ? "下一步" : "Next")}
					primary={true} onTapped={() => { if (!dismissedComposition) advanceQuestionnaire(); dismissedComposition = false; }} />
			</node> : undefined}
			{modelPickerOpen ? <node x={left + 16} y={bottom + 164} width={contentWidth} height={pickerHeight} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}>
				<draw-node x={contentWidth / 2} y={pickerHeight / 2}><rect-shape width={contentWidth} height={pickerHeight} fillColor={colors.panel} borderWidth={1} borderColor={colors.border} /></draw-node>
				<label x={16} y={pickerHeight - 34} anchorX={0} fontName={fontName} fontSize={17} text={zh ? "选择 Remix 使用的模型" : "Choose a model for Remix"} textWidth={contentWidth - 32} alignment={TextAlign.Left} color3={0xf4f1e8} />
				{llmConfigs.slice(0, 8).map((item, i) => <ChoiceButton x={16} y={pickerHeight - 90 - i * 43} width={contentWidth - 32}
					text={`${item.name} · ${item.model}`} selected={item.id === selectedLLMConfigId} onTapped={() => selectModel(item.id)} />)}
			</node> : undefined}
			{error !== "" ? <label tag="remix-error" x={left + 20} y={bottom + (questionnaire || modelPickerOpen ? 144 : composerTop + composerGap)} anchorX={0} anchorY={0} fontName={fontName} fontSize={13} text={error} textWidth={contentWidth} alignment={TextAlign.Left} color3={0xff6b6b} onMount={label => { errorLabel = label; }} /> : undefined}
			{questionnaire === undefined && !modelPickerOpen ? <node>
				<ChoiceButton tag="remix-mode-plan" x={left + 16} y={bottom + modeBottom} width={modeWidth} text={zh ? "计划" : "Plan"} selected={workMode === "plan"} disabled={!canSubmit()} onTapped={() => changeWorkMode("plan")} />
				<ChoiceButton tag="remix-mode-code" x={left + 16 + modeWidth + composerGap} y={bottom + modeBottom} width={contentWidth - modeWidth - composerGap} text={zh ? "执行" : "Code"} selected={workMode === "code"} disabled={!canSubmit()} onTapped={() => changeWorkMode("code")} />
			</node> : undefined}
			{questionnaire === undefined && !modelPickerOpen && !keptInput ? <node tag="remix-input" ref={inputRef} x={left + 16} y={bottom + composerBottom} width={inputWidth} height={composerHeight} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}
				onTapped={tapInput} onMount={mountInput}
				onTapBegan={() => { dragDistance = 0; }} onTapMoved={touch => { dragDistance += math.abs(touch.delta.y); inputView?.scroll(touch.delta.y); }}
				onMouseWheel={delta => inputView?.scroll(-delta.y * 20)}
				onAttachIME={attachInput} onDetachIME={detachInput}
				onTextInput={textInput} onTextEditing={textEditing} onKeyDown={keyInput}>
				<draw-node x={inputWidth / 2} y={composerHeight / 2}><rect-shape width={inputWidth} height={composerHeight} fillColor={colors.panel} borderWidth={1} borderColor={colors.border} /></draw-node>
			</node> : undefined}
			{stopping || (questionnaire === undefined && !modelPickerOpen) ? <ActionButton tag={stopping ? "remix-stop" : "remix-send"}
				x={left + 16 + inputWidth + composerGap} y={bottom + composerBottom} width={composerActionWidth} height={composerHeight}
				text={stopping ? (state?.currentTaskFinalizing ? (zh ? "收尾中" : "Finishing") : stopRequested ? (zh ? "停止中" : "Stopping") : (zh ? "停止" : "Stop")) : (zh ? "发送" : "Send")}
				primary={!stopping} danger={stopping} disabled={stopping ? stopRequested || state?.currentTaskFinalizing === true : !canSubmit()}
				onTapped={() => { if (stopping) stop(); else if (!dismissedComposition) send(); dismissedComposition = false; }} /> : undefined}
			{phase === "done" ? <ActionButton tag="remix-play" x={left + 16} y={bottom + 18} width={contentWidth} text={zh ? "立即试玩" : "Play now"} primary={true} onTapped={() => { if (!host.visible || HttpServer.wsConnectionCount > 0) return; blurInput(); host.visible = false; onPlay(options.entry); }} /> : undefined}
			</node>
		</node>);
		if (scene) {
			host.addChild(scene);
			if (keptInput) pageRef.current?.addChild(keptInput);
			if (!questionnaire && !modelPickerOpen) {
				transcript.node.position = Vec2(left + 16, bottom + getTranscriptBottom());
				pageRef.current?.addChild(transcript.node);
				updateTranscript();
			}
		}
		if (restoreInputFocus && inputRef.current && !keptInput) focusInput(false);
		if (keptInput) updateInputLabel(insertInputText(draft, inputCursor, composingText), inputPlaceholder);
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
		if (shellRevision !== getShellRevision()) render();
		else if (displayRevision !== next) updateTranscript();
		return false;
	});
	host.onAppChange(setting => { if (setting === "Size" || setting === "Locale") render(); });
	host.onAppEvent(event => {
		if (event === "BackButton") { if (inputFocused) blurInput(); else goBack(); }
		else if (event === "WillEnterBackground" || event === "DidEnterBackground") blurInput();
	});
	host.onCleanup(() => { disposed = true; blurInput(); });
	host.slot("SuspendLocalUI", blurInput);
	host.slot("ResumeLocalUI", () => { refresh(); render(); });
	render();
	return host;
}

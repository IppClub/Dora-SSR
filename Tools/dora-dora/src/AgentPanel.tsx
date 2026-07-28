import React, { useEffect, useLayoutEffect, useMemo, useState } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import IconButton from '@mui/material/IconButton';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import * as Service from './Service';
import { Color } from './Theme';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import { BsArrowDown } from 'react-icons/bs';
import AgentMessageList from './AgentMessageList';
import AgentComposer from './AgentComposer';
import AgentStepList from './AgentStepList';
import AgentChangeSetSummaryCard from './AgentChangeSetSummary';
import AgentQuestionnaire from './AgentQuestionnaire';
import doraAgent from './dora-agent.png';
import {
	agentCollectionToArray,
	applyCheckpointCollectionPatches,
	applyMessageCollectionPatches,
	applyStepCollectionPatches,
	createCheckpointCollection,
	createMessageCollection,
	createStepCollection,
	isImmediateAgentPatch,
	reconcileCheckpointCollection,
	reconcileMessageCollection,
	reconcileStepCollection,
} from './AgentPatchBatch';
import {
	deleteAgentSessionSnapshot,
	getAgentSessionSnapshot,
	setAgentSessionSnapshot,
} from './AgentSessionSnapshot';
import { getAgentTailRenderWindow } from './AgentRenderWindow';
import { resolveAgentAutoScrollState } from './AgentAutoScroll';

const AGENT_LLM_CONFIG_STORAGE_KEY = "dora.agent.llmConfigId";

interface AgentPanelProps {
	active?: boolean;
	compact?: boolean;
	sessionId: number;
	projectRoot: string;
	title: string;
	height: number;
	showHeader?: boolean;
	initialPrompt?: string;
	addAlert?: (msg: string, type: "success" | "info" | "warning" | "error") => void;
	onInitialPromptConsumed?: () => void;
	onRollbackComplete?: (projectRoot: string) => void;
	onOpenFile?: (filePath: string) => void;
	onRepositoryFilesChanged?: (projectRoot: string) => void | Promise<void>;
	onOpenLLMConfig?: () => void;
}

function normalizeList<T>(value: unknown): T[] {
	if (Array.isArray(value)) return value as T[];
	if (value && typeof value === "object") {
		return Object.keys(value as Record<string, T>)
			.sort((a, b) => Number(a) - Number(b))
			.map(key => (value as Record<string, T>)[key]);
	}
	return [];
}

function getToolStepText(step: Service.AgentSessionStep): string {
	const parts = [
		step.reason,
		step.reasoningContent,
		step.params ? JSON.stringify(step.params) : "",
		step.result ? JSON.stringify(step.result) : "",
	];
	return parts.join("\n");
}

function getFiniteNumber(value: unknown): number | undefined {
	return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

export default function AgentPanel(props: AgentPanelProps) {
	const HISTORY_VISIBLE_ROUNDS = 10;
	const CURRENT_STEPS_VISIBLE_COUNT = 80;
	const FETCH_URL_TOOL = "fetch_url";
	const EXECUTE_COMMAND_TOOL = "execute_command";
	const { t } = useTranslation();
	const { active = true, compact = false, sessionId, projectRoot, title, height, showHeader = true, initialPrompt, addAlert, onInitialPromptConsumed, onRollbackComplete, onOpenFile, onOpenLLMConfig } = props;
	const [initialSnapshot] = useState(() => getAgentSessionSnapshot(sessionId));
	const [selectedSessionId, setSelectedSessionId] = useState(sessionId);
	const [hydratingSessionId, setHydratingSessionId] = useState<number | null>(
		initialSnapshot ? null : sessionId
	);
	const [prompt, setPrompt] = useState("");
	const [loading, setLoading] = useState(false);
	const [stoppingTaskId, setStoppingTaskId] = useState<number | null>(null);
	const [continueLoadingTaskId, setContinueLoadingTaskId] = useState<number | null>(null);
	const [finishHandoffLoadingTaskId, setFinishHandoffLoadingTaskId] = useState<number | null>(null);
	const [rollingBack, setRollingBack] = useState<number | null>(null);
	const [session, setSession] = useState<Service.AgentSession | null>(initialSnapshot?.session ?? null);
	const [relatedSessions, setRelatedSessions] = useState<Service.AgentSession[]>(initialSnapshot?.relatedSessions ?? []);
	const [spawnInfo, setSpawnInfo] = useState<Service.AgentSessionSpawnInfo | null>(initialSnapshot?.spawnInfo ?? null);
	const [messageCollection, setMessageCollection] = useState(() => createMessageCollection(initialSnapshot?.messages ?? []));
	const [stepCollection, setStepCollection] = useState(() => createStepCollection(initialSnapshot?.steps ?? []));
	const [checkpointCollection, setCheckpointCollection] = useState(() => createCheckpointCollection(initialSnapshot?.checkpoints ?? []));
	const messages = useMemo(() => agentCollectionToArray(messageCollection), [messageCollection]);
	const steps = useMemo(() => agentCollectionToArray(stepCollection), [stepCollection]);
	const checkpoints = useMemo(() => agentCollectionToArray(checkpointCollection), [checkpointCollection]);
	const [pendingQuestionnaire, setPendingQuestionnaire] = useState<Service.AgentQuestionnaire | null>(initialSnapshot?.pendingQuestionnaire ?? null);
	const [questionnaireSubmitting, setQuestionnaireSubmitting] = useState(false);
	const [questionnaireCancelId, setQuestionnaireCancelId] = useState<number | null>(null);
	const [workMode, setWorkMode] = useState<"code" | "plan">(initialSnapshot?.workMode ?? "code");
	const [hasActivePlan, setHasActivePlan] = useState(initialSnapshot?.hasActivePlan ?? false);
	const [diffs, setDiffs] = useState<Record<number, Service.AgentCheckpointDiffFile[]>>({});
	const [taskDiffs, setTaskDiffs] = useState<Record<number, Service.AgentCheckpointDiffFile[]>>({});
	const [diffLoadingId, setDiffLoadingId] = useState<number | null>(null);
	const [taskDiffLoadingId, setTaskDiffLoadingId] = useState<number | null>(null);
	const [openedDiffId, setOpenedDiffId] = useState<number | null>(null);
	const [openedTaskDiffId, setOpenedTaskDiffId] = useState<number | null>(null);
	const [visibleHistoryRounds, setVisibleHistoryRounds] = useState(HISTORY_VISIBLE_ROUNDS);
	const [visibleCurrentStepCount, setVisibleCurrentStepCount] = useState(CURRENT_STEPS_VISIBLE_COUNT);
	const [isFollowingOutput, setIsFollowingOutput] = useState(true);
	const [llmConfigMissing, setLLMConfigMissing] = useState(false);
	const [llmConfigs, setLLMConfigs] = useState<Service.LLMConfigItem[]>([]);
	const [selectedLLMConfigId, setSelectedLLMConfigId] = useState<number | undefined>(() => {
		const value = Number(window.localStorage.getItem(AGENT_LLM_CONFIG_STORAGE_KEY));
		return Number.isFinite(value) && value > 0 ? value : undefined;
	});
	// Engine-side Lua/Git commands are bounded by the Agent command sandbox and
	// are required for real build/runtime validation. Keep network fetch opt-in,
	// but make local validation available in every new main session.
	const [disabledAgentTools, setDisabledAgentTools] = useState<string[]>([FETCH_URL_TOOL]);
	const scrollRef = React.useRef<HTMLElement | null>(null);
	const contentRef = React.useRef<HTMLDivElement | null>(null);
	const isFollowingOutputRef = React.useRef(true);
	const lastScrollTopRef = React.useRef(0);
	const lastScrollHeightRef = React.useRef(0);
	const consumedInitialPromptRef = React.useRef("");
	const sessionPatchRevisionRef = React.useRef(0);
	const onOpenFileRef = React.useRef(onOpenFile);
	onOpenFileRef.current = onOpenFile;
	const handleOpenFile = React.useCallback((filePath: string) => {
		onOpenFileRef.current?.(filePath);
	}, []);
	const stableOnOpenFile = onOpenFile ? handleOpenFile : undefined;

	const selectSession = React.useCallback((nextSessionId: number) => {
		setSelectedSessionId(nextSessionId);
		const snapshot = getAgentSessionSnapshot(nextSessionId);
		if (!snapshot) {
			setHydratingSessionId(nextSessionId);
			return;
		}
		setHydratingSessionId(null);
		setSession(snapshot.session);
		setRelatedSessions(snapshot.relatedSessions);
		setSpawnInfo(snapshot.spawnInfo);
		setMessageCollection(createMessageCollection(snapshot.messages));
		setStepCollection(createStepCollection(snapshot.steps));
		setCheckpointCollection(createCheckpointCollection(snapshot.checkpoints));
		setPendingQuestionnaire(snapshot.pendingQuestionnaire);
		setWorkMode(snapshot.workMode);
		setHasActivePlan(snapshot.hasActivePlan);
	}, []);

	useEffect(() => {
		if (session?.id !== selectedSessionId) return;
		setAgentSessionSnapshot(selectedSessionId, {
			session,
			relatedSessions,
			spawnInfo,
			messages,
			steps,
			checkpoints,
			pendingQuestionnaire,
			workMode,
			hasActivePlan,
		});
	}, [
		checkpoints,
		hasActivePlan,
		messages,
		pendingQuestionnaire,
		relatedSessions,
		selectedSessionId,
		session,
		spawnInfo,
		steps,
		workMode,
	]);

	const orderedRelatedSessions = useMemo(() => {
		return [...relatedSessions].sort((a, b) => {
			if (a.kind !== b.kind) return a.kind === "main" ? -1 : 1;
			return a.id - b.id;
		});
	}, [relatedSessions]);
	const fetchUrlEnabled = disabledAgentTools.indexOf(FETCH_URL_TOOL) < 0;
	const executeCommandEnabled = disabledAgentTools.indexOf(EXECUTE_COMMAND_TOOL) < 0;
	const setFetchUrlEnabled = React.useCallback((enabled: boolean) => {
		setDisabledAgentTools(prev => {
			const disabled = prev.indexOf(FETCH_URL_TOOL) >= 0;
			if (enabled && disabled) return prev.filter(tool => tool !== FETCH_URL_TOOL);
			if (!enabled && !disabled) return [...prev, FETCH_URL_TOOL];
			return prev;
		});
	}, []);
	const setExecuteCommandEnabled = React.useCallback((enabled: boolean) => {
		setDisabledAgentTools(prev => {
			const disabled = prev.indexOf(EXECUTE_COMMAND_TOOL) >= 0;
			if (enabled && disabled) return prev.filter(tool => tool !== EXECUTE_COMMAND_TOOL);
			if (!enabled && !disabled) return [...prev, EXECUTE_COMMAND_TOOL];
			return prev;
		});
	}, []);

	const tabLabelMap = useMemo(() => {
		const map = new Map<number, string>();
		let subIndex = 1;
		for (const item of orderedRelatedSessions) {
			if (item.kind === "main") {
				map.set(item.id, "main");
			} else {
				map.set(item.id, String(subIndex));
				subIndex += 1;
			}
		}
		return map;
	}, [orderedRelatedSessions]);

	const resolveLLMConfigId = React.useCallback(async () => {
		try {
			const res = await Service.listLLMConfigs();
			if (!res.success) {
				return selectedLLMConfigId;
			}
			const items = res.items ?? [];
			setLLMConfigs(items);
			const storedId = Number(window.localStorage.getItem(AGENT_LLM_CONFIG_STORAGE_KEY));
			const nextId = items.some(item => item.id === selectedLLMConfigId)
				? selectedLLMConfigId
				: (items.some(item => item.id === storedId) ? storedId : items[0]?.id);
			setSelectedLLMConfigId(nextId);
			setLLMConfigMissing(nextId === undefined);
			if (nextId !== undefined) window.localStorage.setItem(AGENT_LLM_CONFIG_STORAGE_KEY, String(nextId));
			return nextId;
		} catch {
			return selectedLLMConfigId;
		}
	}, [selectedLLMConfigId]);

	useEffect(() => {
		const refreshConfigs = () => void resolveLLMConfigId();
		refreshConfigs();
		window.addEventListener('llm-configs-changed', refreshConfigs);
		return () => window.removeEventListener('llm-configs-changed', refreshConfigs);
	}, [resolveLLMConfigId]);

	const selectLLMConfig = React.useCallback((configId: number) => {
		setSelectedLLMConfigId(configId);
		setLLMConfigMissing(false);
		window.localStorage.setItem(AGENT_LLM_CONFIG_STORAGE_KEY, String(configId));
	}, []);

	const scrollToBottom = React.useCallback((behavior: ScrollBehavior = "auto") => {
		const container = scrollRef.current;
		if (!container) return;
		const targetScrollTop = Math.max(0, container.scrollHeight - container.clientHeight);
		if (Math.abs(container.scrollTop - targetScrollTop) <= 1) return;
		container.scrollTo({ top: targetScrollTop, behavior });
	}, []);

	const syncBottomState = React.useCallback(() => {
		const container = scrollRef.current;
		if (!container) return true;
		const distanceToBottom = container.scrollHeight - container.scrollTop - container.clientHeight;
		const nextState = resolveAgentAutoScrollState({
			followingOutput: isFollowingOutputRef.current,
			previousScrollTop: lastScrollTopRef.current,
			previousScrollHeight: lastScrollHeightRef.current,
			scrollTop: container.scrollTop,
			scrollHeight: container.scrollHeight,
			distanceToBottom,
		});
		lastScrollTopRef.current = container.scrollTop;
		lastScrollHeightRef.current = container.scrollHeight;
		isFollowingOutputRef.current = nextState.followingOutput;
		setIsFollowingOutput(nextState.followingOutput);
		return nextState.followingOutput;
	}, []);

	const resumeFollowingOutput = React.useCallback((behavior: ScrollBehavior = "auto") => {
		isFollowingOutputRef.current = true;
		setIsFollowingOutput(true);
		scrollToBottom(behavior);
	}, [scrollToBottom]);

	const refresh = React.useCallback(async (statusOnly = false, targetSessionId = selectedSessionId, ignoreIfPatched = false) => {
		const patchRevision = sessionPatchRevisionRef.current;
		if (statusOnly) {
			const res = await Service.agentTaskStatus({ sessionId: targetSessionId });
			if (ignoreIfPatched && sessionPatchRevisionRef.current !== patchRevision) return;
			if (res.success) {
				setSession(res.session);
				setWorkMode(res.session.kind === "main" ? res.session.workMode : "code");
				setRelatedSessions(normalizeList<Service.AgentSession>(res.relatedSessions));
				setSpawnInfo(res.spawnInfo ?? null);
				setMessageCollection(prev => reconcileMessageCollection(prev, normalizeList<Service.AgentSessionMessage>(res.messages)));
				setStepCollection(prev => reconcileStepCollection(prev, normalizeList<Service.AgentSessionStep>(res.steps)));
				setCheckpointCollection(prev => reconcileCheckpointCollection(prev, normalizeList<Service.AgentCheckpointItem>(res.checkpoints)));
				setPendingQuestionnaire(res.pendingQuestionnaire ?? null);
				setHasActivePlan(res.hasActivePlan);
				return;
			}
			if (res.message === "session not found" && targetSessionId !== sessionId) {
				selectSession(sessionId);
				void refresh(false, sessionId);
				return;
			}
			addAlert?.(res.message, "error");
			return;
		}
		const res = await Service.agentSessionGet({ sessionId: targetSessionId });
		if (ignoreIfPatched && sessionPatchRevisionRef.current !== patchRevision) return;
		if (res.success) {
			setSession(res.session);
			setWorkMode(res.session.kind === "main" ? res.session.workMode : "code");
			setRelatedSessions(normalizeList<Service.AgentSession>(res.relatedSessions));
			setSpawnInfo(res.spawnInfo ?? null);
			setMessageCollection(prev => reconcileMessageCollection(prev, normalizeList<Service.AgentSessionMessage>(res.messages)));
			setStepCollection(prev => reconcileStepCollection(prev, normalizeList<Service.AgentSessionStep>(res.steps)));
			setCheckpointCollection(prev => reconcileCheckpointCollection(prev, normalizeList<Service.AgentCheckpointItem>(res.checkpoints)));
			setPendingQuestionnaire(res.pendingQuestionnaire ?? null);
			setHasActivePlan(res.hasActivePlan);
			return;
		}
		if (res.message === "session not found" && targetSessionId !== sessionId) {
			selectSession(sessionId);
			void refresh(false, sessionId);
			return;
		}
		addAlert?.(res.message, "error");
	}, [addAlert, selectedSessionId, selectSession, sessionId]);

	useEffect(() => {
		selectSession(sessionId);
	}, [selectSession, sessionId]);

	useEffect(() => {
		if (
			stoppingTaskId !== null
			&& (
				session?.currentTaskId !== stoppingTaskId
				|| session.currentTaskStatus !== "RUNNING"
			)
		) {
			setStoppingTaskId(null);
		}
	}, [session?.currentTaskId, session?.currentTaskStatus, stoppingTaskId]);

	useEffect(() => {
		if (!active) return;
		let cancelled = false;
		const targetSessionId = selectedSessionId;
		void refresh(false, targetSessionId).finally(() => {
			if (cancelled) return;
			setHydratingSessionId(current =>
				current === targetSessionId ? null : current
			);
		});
		return () => {
			cancelled = true;
		};
	}, [active, refresh, selectedSessionId]);

	useEffect(() => {
		if (!active) return;
		let queuedPatches: Service.AgentSessionPatch[] = [];
		let flushTimer: number | null = null;
		const flushPatches = () => {
			if (flushTimer !== null) {
				window.clearTimeout(flushTimer);
				flushTimer = null;
			}
			const patches = queuedPatches;
			queuedPatches = [];
			if (patches.length === 0) return;

			if (patches.some(patch => patch.sessionDeleted)) {
				deleteAgentSessionSnapshot(selectedSessionId);
				selectSession(sessionId);
				void refresh(false, sessionId);
				return;
			}

			let nextRelatedSessions: Service.AgentSession[] | undefined;
			let nextSpawnInfo: Service.AgentSessionSpawnInfo | null | undefined;
			let hasSpawnInfo = false;
			let nextSession: Service.AgentSession | undefined;
			let mergedMetrics: Service.AgentMetrics | undefined;
			let nextQuestionnaire: Service.AgentQuestionnaire | null | undefined;
			let hasQuestionnaire = false;
			let nextHasActivePlan: boolean | undefined;
			let hasMessagePatch = false;
			let hasStepPatch = false;
			let hasCheckpointPatch = false;
			for (const patch of patches) {
				if (patch.relatedSessions) nextRelatedSessions = normalizeList<Service.AgentSession>(patch.relatedSessions);
				if ("spawnInfo" in patch) {
					nextSpawnInfo = patch.spawnInfo ?? null;
					hasSpawnInfo = true;
				}
				if (patch.session) nextSession = patch.session;
				if (patch.metrics) mergedMetrics = { ...(mergedMetrics ?? {}), ...patch.metrics };
				if ("pendingQuestionnaire" in patch) {
					nextQuestionnaire = patch.pendingQuestionnaire || null;
					hasQuestionnaire = true;
				}
				if (typeof patch.hasActivePlan === "boolean") nextHasActivePlan = patch.hasActivePlan;
				if (patch.message) hasMessagePatch = true;
				if (patch.step || (patch.removedStepIds?.length ?? 0) > 0) hasStepPatch = true;
				if (patch.checkpoint || patch.checkpoints) hasCheckpointPatch = true;
			}
			if (nextRelatedSessions) setRelatedSessions(nextRelatedSessions);
			if (hasSpawnInfo) setSpawnInfo(nextSpawnInfo ?? null);
			if (nextSession || mergedMetrics) {
				setSession(prev => {
					const base = nextSession ?? prev;
					if (!base || !mergedMetrics) return base;
					return {
						...base,
						metrics: {
							...(base.metrics ?? {}),
							...mergedMetrics,
						},
					};
				});
				if (nextSession) setWorkMode(nextSession.kind === "main" ? nextSession.workMode : "code");
			}
			if (hasQuestionnaire) setPendingQuestionnaire(nextQuestionnaire ?? null);
			if (nextHasActivePlan !== undefined) setHasActivePlan(nextHasActivePlan);
			if (hasMessagePatch) setMessageCollection(prev => applyMessageCollectionPatches(prev, patches));
			if (hasStepPatch) setStepCollection(prev => applyStepCollectionPatches(prev, patches));
			if (hasCheckpointPatch) setCheckpointCollection(prev => applyCheckpointCollectionPatches(prev, patches));
		};
		const onPatch = (patch: Service.AgentSessionPatch) => {
			if (patch.sessionId !== selectedSessionId) return;
			sessionPatchRevisionRef.current += 1;
			queuedPatches.push(patch);
			if (isImmediateAgentPatch(patch)) {
				flushPatches();
			} else if (flushTimer === null) {
				flushTimer = window.setTimeout(flushPatches, 50);
			}
		};
		Service.addAgentSessionPatchListener(onPatch);
		return () => {
			Service.removeAgentSessionPatchListener(onPatch);
			if (flushTimer !== null) window.clearTimeout(flushTimer);
			queuedPatches = [];
		};
	}, [active, refresh, selectSession, selectedSessionId, sessionId]);

	useEffect(() => {
		setVisibleHistoryRounds(HISTORY_VISIBLE_ROUNDS);
	}, [selectedSessionId]);

	const hasAnyRunningSession = useMemo(() => {
		return orderedRelatedSessions.some(item => item.currentTaskStatus === "RUNNING");
	}, [orderedRelatedSessions]);

	useEffect(() => {
		if (!active || !hasAnyRunningSession) return;
		const timer = window.setInterval(() => {
			void refresh(true, selectedSessionId, true);
		}, 3000);
		return () => window.clearInterval(timer);
	}, [active, hasAnyRunningSession, refresh, selectedSessionId]);

	const lastMessage = messages[messages.length - 1];
	const lastStep = steps[steps.length - 1];
	const latestUserMessageId = useMemo(() => {
		for (let i = messages.length - 1; i >= 0; i--) {
			if (messages[i].role === "user") {
				return messages[i].id;
			}
		}
		return undefined;
	}, [messages]);

	useLayoutEffect(() => {
		if (!active || !isFollowingOutputRef.current) return;
		scrollToBottom("auto");
	}, [
		active,
		scrollToBottom,
		messages.length,
		lastMessage?.id,
		lastMessage?.updatedAt,
		lastMessage?.content,
		steps.length,
		lastStep?.id,
		lastStep?.updatedAt,
		lastStep?.status,
	]);

	useEffect(() => {
		if (!active) return;
		const container = scrollRef.current;
		if (!container) return;
		const onScroll = () => {
			const nextIsNearBottom = syncBottomState();
			if (nextIsNearBottom && visibleHistoryRounds !== HISTORY_VISIBLE_ROUNDS) {
				setVisibleHistoryRounds(HISTORY_VISIBLE_ROUNDS);
			}
		};
		onScroll();
		container.addEventListener("scroll", onScroll, { passive: true });
		return () => container.removeEventListener("scroll", onScroll);
	}, [active, syncBottomState, visibleHistoryRounds]);

	useEffect(() => {
		if (!active) return;
		const content = contentRef.current;
		if (!content || typeof ResizeObserver === "undefined") return;
		const observer = new ResizeObserver(() => {
			if (!isFollowingOutputRef.current) return;
			// ResizeObserver runs before paint. Keep the bottom aligned here so
			// async Markdown and Collapse growth cannot become visible for one
			// frame before the scroll position catches up.
			scrollToBottom("auto");
		});
		observer.observe(content);
		return () => observer.disconnect();
	}, [active, scrollToBottom]);

	useLayoutEffect(() => {
		isFollowingOutputRef.current = true;
		lastScrollTopRef.current = 0;
		lastScrollHeightRef.current = 0;
		setIsFollowingOutput(true);
		scrollToBottom("auto");
	}, [scrollToBottom, selectedSessionId]);

	const latestSteps = useMemo(() => {
		const taskId = session?.currentTaskId;
		if (!taskId) return steps;
		return steps.filter(step => step.taskId === taskId);
	}, [session?.currentTaskId, steps]);

	const continuableTaskId = useMemo(() => {
		if (session?.currentTaskStatus !== "FAILED" && session?.currentTaskStatus !== "STOPPED") {
			return null;
		}
		const taskId = session?.currentTaskId;
		if (!taskId) {
			return null;
		}
		return taskId;
	}, [session?.currentTaskId, session?.currentTaskStatus]);

	const activeTaskId = useMemo(() => {
		if (session?.currentTaskId) return session.currentTaskId;
		const taskIds = [
			...messages.map(message => message.taskId ?? 0),
			...steps.map(step => step.taskId ?? 0),
		].filter(taskId => taskId > 0);
		return taskIds.length > 0 ? Math.max(...taskIds) : null;
	}, [messages, steps, session?.currentTaskId]);

	useEffect(() => {
		setVisibleCurrentStepCount(CURRENT_STEPS_VISIBLE_COUNT);
	}, [activeTaskId]);

	const messageGroups = useMemo(() => {
		if (!activeTaskId) {
			return {
				historyMessages: messages,
				currentPromptMessages: [] as Service.AgentSessionMessage[],
				currentSummaryMessages: [] as Service.AgentSessionMessage[],
			};
		}
		return {
			historyMessages: messages.filter(message => message.taskId !== activeTaskId),
			currentPromptMessages: messages.filter(message => message.taskId === activeTaskId && message.role === "user"),
			currentSummaryMessages: messages.filter(message => message.taskId === activeTaskId && message.role === "assistant"),
		};
	}, [activeTaskId, messages]);

	const showSummaryShimmer = useMemo(() => {
		return activeTaskId != null && session?.currentTaskStatus === "RUNNING";
	}, [activeTaskId, session?.currentTaskStatus]);

	const historyGroups = useMemo(() => {
		const groups: Service.AgentSessionMessage[][] = [];
		let currentGroup: Service.AgentSessionMessage[] = [];
		let currentKey: string | null = null;
		for (const message of messageGroups.historyMessages) {
			const key = message.taskId && message.taskId > 0 ? `task:${message.taskId}` : `legacy:${message.id}`;
			if (currentKey !== key) {
				if (currentGroup.length > 0) groups.push(currentGroup);
				currentGroup = [message];
				currentKey = key;
			} else {
				currentGroup.push(message);
			}
		}
		if (currentGroup.length > 0) groups.push(currentGroup);
		const questionnaireMessagesByTask = new Map<number, Service.AgentSessionMessage[]>();
		for (const step of steps) {
			if (
				step.taskId === activeTaskId
				|| step.tool !== "questionnaire_answer"
				|| (step.result?.status !== "answered" && step.result?.status !== "dismissed")
				|| typeof step.result.displayText !== "string"
				|| step.result.displayText.trim() === ""
			) {
				continue;
			}
			const messagesForTask = questionnaireMessagesByTask.get(step.taskId) ?? [];
			messagesForTask.push({
				id: -step.id,
				sessionId: step.sessionId,
				taskId: step.taskId,
				role: "user",
				content: step.result.displayText,
				createdAt: step.createdAt,
				updatedAt: step.updatedAt,
			});
			questionnaireMessagesByTask.set(step.taskId, messagesForTask);
		}
		for (const messagesForTask of questionnaireMessagesByTask.values()) {
			messagesForTask.sort((a, b) => a.createdAt - b.createdAt || a.id - b.id);
		}
		return groups.map(group => {
			const taskId = group[0]?.taskId;
			const questionnaireMessages = taskId ? questionnaireMessagesByTask.get(taskId) : undefined;
			if (!questionnaireMessages || questionnaireMessages.length === 0) return group;
			const firstAssistantIndex = group.findIndex(message => message.role === "assistant");
			if (firstAssistantIndex < 0) return [...group, ...questionnaireMessages];
			return [
				...group.slice(0, firstAssistantIndex),
				...questionnaireMessages,
				...group.slice(firstAssistantIndex),
			];
		});
	}, [activeTaskId, messageGroups.historyMessages, steps]);

	const hiddenHistoryGroupCount = useMemo(() => {
		return Math.max(0, historyGroups.length - visibleHistoryRounds);
	}, [historyGroups.length, visibleHistoryRounds]);

	const hiddenHistoryRevealCount = Math.min(HISTORY_VISIBLE_ROUNDS, hiddenHistoryGroupCount);

	const visibleHistoryMessages = useMemo(() => {
		if (historyGroups.length <= visibleHistoryRounds) {
			return messageGroups.historyMessages;
		}
		return historyGroups.slice(-visibleHistoryRounds).flat();
	}, [historyGroups, messageGroups.historyMessages, visibleHistoryRounds]);

	const visibleSummaryMessages = useMemo(() => {
		return messageGroups.currentSummaryMessages;
	}, [messageGroups.currentSummaryMessages]);

	const currentStepWindow = useMemo(() => {
		return getAgentTailRenderWindow(
			latestSteps,
			visibleCurrentStepCount,
			CURRENT_STEPS_VISIBLE_COUNT,
		);
	}, [latestSteps, visibleCurrentStepCount]);

	const currentTaskChangeSet = useMemo<Service.AgentChangeSetSummary | null>(() => {
		if (!activeTaskId || checkpoints.length === 0) return null;
		const currentCheckpoints = checkpoints.filter(checkpoint => checkpoint.taskId === activeTaskId);
		if (currentCheckpoints.length === 0) return null;
		const filesByPath = new Map<string, Service.AgentChangeSetFileItem>();
		for (const step of latestSteps) {
			if (step.taskId !== activeTaskId || !step.checkpointId || !step.files) continue;
			for (const file of step.files) {
				const op = file.op === "create" || file.op === "delete" || file.op === "write" ? file.op : "write";
				const existing = filesByPath.get(file.path);
				if (existing) {
					existing.op = op;
					existing.checkpointCount += 1;
					existing.checkpointIds.push(step.checkpointId);
				} else {
					filesByPath.set(file.path, {
						path: file.path,
						op,
						checkpointCount: 1,
						checkpointIds: [step.checkpointId],
					});
				}
			}
		}
		const files = [...filesByPath.values()].sort((a, b) => a.path.localeCompare(b.path));
		const sortedCheckpoints = [...currentCheckpoints].sort((a, b) => b.seq - a.seq);
		return {
			success: true,
			taskId: activeTaskId,
			checkpointCount: currentCheckpoints.length,
			filesChanged: files.length,
			files,
			latestCheckpointId: sortedCheckpoints[0]?.id,
			latestCheckpointSeq: sortedCheckpoints[0]?.seq,
		};
	}, [activeTaskId, checkpoints, latestSteps]);

	const contextStats = useMemo(() => {
		const backendContext = session?.metrics?.context;
		const backendUsage = session?.metrics?.usage;
		const actualUsage = backendUsage
			&& getFiniteNumber(backendUsage.inputTokens) !== undefined
			&& getFiniteNumber(backendUsage.outputTokens) !== undefined
			? {
				inputTokens: getFiniteNumber(backendUsage.inputTokens) as number,
				outputTokens: getFiniteNumber(backendUsage.outputTokens) as number,
				cachedInputTokens: getFiniteNumber(backendUsage.cachedInputTokens),
				requestCount: getFiniteNumber(backendUsage.requestCount),
			}
			: undefined;
		const backendUsedTokens = getFiniteNumber(backendContext?.usedTokens);
		const backendMaxTokens = getFiniteNumber(backendContext?.maxTokens);
		if (backendUsedTokens !== undefined && backendMaxTokens !== undefined && backendMaxTokens > 0) {
			return {
				usedTokens: backendUsedTokens,
				maxTokens: backendMaxTokens,
				contextRatio: Math.max(0, Math.min(1, getFiniteNumber(backendContext?.ratio) ?? (backendUsedTokens / backendMaxTokens))),
				actualUsage,
			};
		}
		const totalChars = messages.reduce((sum, message) => sum + (message.content?.length ?? 0), 0)
			+ latestSteps.reduce((sum, step) => sum + getToolStepText(step).length, 0);
		const usedTokens = Math.max(0, Math.ceil(totalChars / 4));
		const contextWindow = getFiniteNumber(backendContext?.contextWindow) ?? 64000;
		const maxTokens = contextWindow;
		const contextRatio = maxTokens > 0 ? Math.min(1, usedTokens / maxTokens) : 0;
		return {
			usedTokens,
			maxTokens,
			contextRatio,
			actualUsage,
		};
	}, [latestSteps, messages, session?.metrics]);

	const checkpointMap = useMemo(() => {
		return new Map(checkpoints.map(checkpoint => [checkpoint.id, checkpoint]));
	}, [checkpoints]);

	const stopProjectRunBeforeAgent = React.useCallback(async () => {
		const status = await Service.runStatus();
		if (!status.success) {
			addAlert?.(status.message ?? t("agent.runStatusFailed"), "error");
			return false;
		}
		if (!status.running || status.projectRoot !== projectRoot) {
			return true;
		}
		const stopRes = await Service.stop();
		if (!stopRes.success) {
			addAlert?.(t("agent.stopProjectRunFailed"), "error");
			return false;
		}
		addAlert?.(t("agent.stoppedProjectRun"), "info");
		return true;
	}, [addAlert, projectRoot, t]);

	const sendPromptText = React.useCallback(async (text: string, targetSessionId = selectedSessionId, requestedWorkMode = workMode) => {
		if (text === "" || loading || continueLoadingTaskId !== null) return;
		setLoading(true);
		try {
			const llmConfigId = await resolveLLMConfigId();
			if (llmConfigId === undefined) {
				addAlert?.(t("agent.noLLMConfigAlert"), "error");
				return;
			}
			const canStartAgent = requestedWorkMode === "plan" ? true : await stopProjectRunBeforeAgent();
			if (!canStartAgent) {
				return;
			}
			const res = await Service.agentSessionSend({
				sessionId: targetSessionId,
				prompt: text,
				llmConfigId,
				disabledAgentTools,
				workMode: requestedWorkMode,
			});
			if (!res.success) {
				if (res.message.includes("LLM config")) {
					setLLMConfigMissing(true);
					addAlert?.(t("agent.noLLMConfigAlert"), "error");
					return;
				}
				addAlert?.(res.message, "error");
				return;
			}
			setLLMConfigMissing(false);
			setPrompt("");
			await refresh(true, targetSessionId);
			return true;
		} finally {
			setLoading(false);
		}
	}, [addAlert, resolveLLMConfigId, continueLoadingTaskId, loading, disabledAgentTools, refresh, selectedSessionId, stopProjectRunBeforeAgent, t, workMode]);

	const resendPromptText = React.useCallback(async (message: Service.AgentSessionMessage, text: string) => {
		if (text === "" || loading || continueLoadingTaskId !== null || session?.currentTaskStatus === "RUNNING") return false;
		setLoading(true);
		try {
			const llmConfigId = await resolveLLMConfigId();
			if (llmConfigId === undefined) {
				addAlert?.(t("agent.noLLMConfigAlert"), "error");
				return false;
			}
			const canStartAgent = workMode === "plan" ? true : await stopProjectRunBeforeAgent();
			if (!canStartAgent) {
				return false;
			}
			const res = await Service.agentSessionResend({
				sessionId: selectedSessionId,
				messageId: message.id,
				prompt: text,
				llmConfigId,
				disabledAgentTools,
				workMode,
			});
			if (!res.success) {
				if (res.message.includes("LLM config")) {
					setLLMConfigMissing(true);
					addAlert?.(t("agent.noLLMConfigAlert"), "error");
					return false;
				}
				addAlert?.(res.message, "error");
				return false;
			}
			setLLMConfigMissing(false);
			await refresh(true, selectedSessionId);
			return true;
		} finally {
			setLoading(false);
		}
	}, [addAlert, resolveLLMConfigId, continueLoadingTaskId, loading, disabledAgentTools, refresh, selectedSessionId, session?.currentTaskStatus, stopProjectRunBeforeAgent, t, workMode]);

	const submitQuestionnaire = React.useCallback(async (answers: Service.AgentQuestionnaireAnswer[]) => {
		if (!pendingQuestionnaire || questionnaireSubmitting) return;
		setQuestionnaireSubmitting(true);
		try {
			const llmConfigId = await resolveLLMConfigId();
			if (llmConfigId === undefined) {
				addAlert?.(t("agent.noLLMConfigAlert"), "error");
				return;
			}
			const res = await Service.agentQuestionnaireRespond({
				sessionId: selectedSessionId,
				questionnaireId: pendingQuestionnaire.id,
				answers,
				llmConfigId,
			});
			if (!res.success) {
				addAlert?.(res.message, "error");
				return;
			}
			window.sessionStorage.removeItem(`agent-questionnaire:${pendingQuestionnaire.id}`);
			setPendingQuestionnaire(null);
			setWorkMode("plan");
			await refresh(true, selectedSessionId);
		} finally {
			setQuestionnaireSubmitting(false);
		}
	}, [addAlert, resolveLLMConfigId, pendingQuestionnaire, questionnaireSubmitting, refresh, selectedSessionId, t]);

	const cancelQuestionnaire = React.useCallback(async () => {
		if (!pendingQuestionnaire || questionnaireSubmitting) return;
		setQuestionnaireSubmitting(true);
		try {
			const llmConfigId = await resolveLLMConfigId();
			if (llmConfigId === undefined) {
				addAlert?.(t("agent.noLLMConfigAlert"), "error");
				return;
			}
			const res = await Service.agentQuestionnaireCancel({
				sessionId: selectedSessionId,
				questionnaireId: pendingQuestionnaire.id,
				llmConfigId,
			});
			if (!res.success) {
				addAlert?.(res.message, "error");
				return;
			}
			window.sessionStorage.removeItem(`agent-questionnaire:${pendingQuestionnaire.id}`);
			setQuestionnaireCancelId(null);
			setPendingQuestionnaire(null);
			setWorkMode("plan");
			await refresh(true, selectedSessionId);
		} finally {
			setQuestionnaireSubmitting(false);
		}
	}, [addAlert, resolveLLMConfigId, pendingQuestionnaire, questionnaireSubmitting, refresh, selectedSessionId, t]);

	const changeWorkMode = React.useCallback(async (planMode: boolean) => {
		if (loading || session?.currentTaskStatus === "RUNNING" || session?.currentTaskStatus === "WAITING_USER") return;
		const nextMode = planMode ? "plan" : "code";
		setLoading(true);
		try {
			const res = await Service.agentSessionSetMode({ sessionId: selectedSessionId, workMode: nextMode });
			if (!res.success) {
				addAlert?.(res.message, "error");
				return;
			}
			setSession(res.session);
			setWorkMode(res.session.workMode);
		} finally {
			setLoading(false);
		}
	}, [addAlert, loading, selectedSessionId, session?.currentTaskStatus]);

	const startDevelopment = React.useCallback(async () => {
		if (loading || session?.currentTaskStatus === "RUNNING" || session?.currentTaskStatus === "WAITING_USER") return;
		const modeResult = await Service.agentSessionSetMode({ sessionId: selectedSessionId, workMode: "code" });
		if (!modeResult.success) {
			addAlert?.(modeResult.message, "error");
			return;
		}
		setSession(modeResult.session);
		setWorkMode("code");
		await sendPromptText(t("agent.plan.startPrompt"), selectedSessionId, "code");
	}, [addAlert, loading, selectedSessionId, sendPromptText, session?.currentTaskStatus, t]);

	const onSend = async () => {
		const text = prompt.trim();
		await sendPromptText(text, selectedSessionId);
	};

	useEffect(() => {
		const text = initialPrompt?.trim() ?? "";
		const key = `${sessionId}:${text}`;
		if (text === "" || consumedInitialPromptRef.current === key) return;
		consumedInitialPromptRef.current = key;
		void (async () => {
			const success = await sendPromptText(text, sessionId);
			if (success) {
				onInitialPromptConsumed?.();
			}
		})();
	}, [initialPrompt, onInitialPromptConsumed, sendPromptText, sessionId]);

	const onContinueTask = async () => {
		const taskId = continuableTaskId;
		if (!taskId || loading || continueLoadingTaskId !== null || session?.currentTaskStatus === "RUNNING") return;
		setContinueLoadingTaskId(taskId);
		try {
			const llmConfigId = await resolveLLMConfigId();
			if (llmConfigId === undefined) {
				addAlert?.(t("agent.noLLMConfigAlert"), "error");
				return;
			}
			const canStartAgent = workMode === "plan" ? true : await stopProjectRunBeforeAgent();
			if (!canStartAgent) {
				return;
			}
			const res = await Service.agentSessionContinue({
				sessionId: selectedSessionId,
				llmConfigId,
				disabledAgentTools,
			});
			if (!res.success) {
				if (res.message.includes("LLM config")) {
					setLLMConfigMissing(true);
					addAlert?.(t("agent.noLLMConfigAlert"), "error");
					return;
				}
				addAlert?.(res.message, "error");
				return;
			}
			setLLMConfigMissing(false);
			await refresh(true, selectedSessionId);
		} finally {
			setContinueLoadingTaskId(null);
		}
	};

	const onFinishHandoff = async () => {
		const taskId = continuableTaskId;
		if (!taskId || session?.kind !== "sub" || loading || continueLoadingTaskId !== null || finishHandoffLoadingTaskId !== null || session.currentTaskStatus === "RUNNING") return;
		setFinishHandoffLoadingTaskId(taskId);
		try {
			const llmConfigId = await resolveLLMConfigId();
			if (llmConfigId === undefined) {
				addAlert?.(t("agent.noLLMConfigAlert"), "error");
				return;
			}
			const res = await Service.agentSessionFinishHandoff({ sessionId: selectedSessionId, llmConfigId });
			if (!res.success) {
				if (res.message.includes("LLM config")) {
					setLLMConfigMissing(true);
					addAlert?.(t("agent.noLLMConfigAlert"), "error");
					return;
				}
				addAlert?.(res.message, "error");
				return;
			}
			setLLMConfigMissing(false);
			await refresh(true, selectedSessionId);
		} finally {
			setFinishHandoffLoadingTaskId(null);
		}
	};

	const onStop = async () => {
		const taskId = session?.currentTaskId;
		if (!taskId || stoppingTaskId !== null) return;
		setStoppingTaskId(taskId);
		const res = await Service.agentTaskStop({ sessionId: selectedSessionId });
		if (!res.success) {
			setStoppingTaskId(null);
			addAlert?.(res.message ?? t("agent.stopFailed"), "error");
			return;
		}
	};

	const onToggleDiff = React.useCallback(async (step: Service.AgentSessionStep) => {
		if (!step.checkpointId) return;
		if (openedDiffId === step.checkpointId) {
			setOpenedDiffId(null);
			return;
		}
		setOpenedDiffId(step.checkpointId);
		if (diffs[step.checkpointId]) return;
		setDiffLoadingId(step.checkpointId);
		try {
			const res = await Service.agentCheckpointDiff({
				sessionId: selectedSessionId,
				checkpointId: step.checkpointId,
			});
			if (!res.success) {
				addAlert?.(res.message, "error");
				return;
			}
			setDiffs(prev => ({ ...prev, [step.checkpointId!]: res.files }));
		} finally {
			setDiffLoadingId(null);
		}
	}, [addAlert, diffs, openedDiffId, selectedSessionId]);

	const onRollback = React.useCallback(async (step: Service.AgentSessionStep) => {
		const seq = step.checkpointSeq;
		const checkpointId = step.checkpointId;
		if (!seq || !checkpointId || rollingBack !== null) return;
		setRollingBack(seq);
		try {
			const res = await Service.agentCheckpointRollback({
				sessionId: selectedSessionId,
				checkpointId,
			});
			if (!res.success) {
				addAlert?.(res.message, "error");
				return;
			}
			addAlert?.(t("agent.rollbackDone", { seq: Math.max(0, seq - 1) }), "success");
			await refresh(true);
			onRollbackComplete?.(projectRoot);
		} finally {
			setRollingBack(null);
		}
	}, [addAlert, onRollbackComplete, projectRoot, refresh, rollingBack, selectedSessionId, t]);

	const onToggleTaskDiff = React.useCallback(async (taskId: number) => {
		if (openedTaskDiffId === taskId) {
			setOpenedTaskDiffId(null);
			return;
		}
		setOpenedTaskDiffId(taskId);
		if (taskDiffs[taskId]) return;
		setTaskDiffLoadingId(taskId);
		try {
			const res = await Service.agentTaskDiff({ sessionId: selectedSessionId, taskId });
			if (!res.success) {
				addAlert?.(res.message, "error");
				return;
			}
			setTaskDiffs(prev => ({ ...prev, [taskId]: res.files }));
		} finally {
			setTaskDiffLoadingId(null);
		}
	}, [addAlert, openedTaskDiffId, selectedSessionId, taskDiffs]);

	const onRollbackTaskChangeSet = React.useCallback(async (taskId: number) => {
		if (rollingBack !== null) return;
		setRollingBack(-taskId);
		try {
			const res = await Service.agentTaskRollback({
				sessionId: selectedSessionId,
				taskId,
			});
			if (!res.success) {
				addAlert?.(res.message, "error");
				return;
			}
			addAlert?.(t("agent.changeSetRollbackDone"), "success");
			await refresh(true);
			onRollbackComplete?.(projectRoot);
		} finally {
			setRollingBack(null);
		}
	}, [addAlert, onRollbackComplete, projectRoot, refresh, rollingBack, selectedSessionId, t]);
	const onRollbackRef = React.useRef(onRollback);
	onRollbackRef.current = onRollback;
	const handleRollback = React.useCallback((step: Service.AgentSessionStep) => {
		void onRollbackRef.current(step);
	}, []);
	const onRollbackTaskChangeSetRef = React.useRef(onRollbackTaskChangeSet);
	onRollbackTaskChangeSetRef.current = onRollbackTaskChangeSet;
	const handleRollbackTaskChangeSet = React.useCallback((taskId: number) => {
		void onRollbackTaskChangeSetRef.current(taskId);
	}, []);

	const tabButtons = useMemo(() => {
		return orderedRelatedSessions.map(item => {
			const selected = item.id === selectedSessionId;
			const running = item.currentTaskStatus === "RUNNING";
			return (
				<Button
					key={item.id}
					size="small"
					variant="outlined"
					onClick={() => selectSession(item.id)}
					sx={{
						minWidth: 38,
						height: 28,
						px: 1.1,
						borderRadius: 1.5,
						borderColor: selected ? `${Color.Theme}66` : Color.Line,
						backgroundColor: selected ? Color.ThemeMuted : "transparent",
						color: selected ? Color.Theme : Color.TextSecondary,
						"&:hover": {
							borderColor: selected ? `${Color.Theme}88` : Color.LineStrong,
							backgroundColor: selected ? `${Color.Theme}2a` : Color.SurfaceHover,
						},
					}}
				>
					{tabLabelMap.get(item.id) ?? (item.kind === "main" ? "main" : "sub")}
					{running ? " *" : ""}
				</Button>
			);
		});
	}, [orderedRelatedSessions, selectedSessionId, selectSession, tabLabelMap]);
	const isSessionHydrating = hydratingSessionId === selectedSessionId;
	const showEmptyState = !isSessionHydrating
		&& messages.length === 0
		&& steps.length === 0
		&& !showSummaryShimmer
		&& pendingQuestionnaire === null;
	const emptyStateMinHeight = Math.max(260, height - 390);

	return (
		<Box
			data-agent-session-id={session?.id}
			data-agent-task-status={session?.currentTaskStatus ?? session?.status}
			data-agent-session-hydrating={isSessionHydrating ? "true" : "false"}
			data-agent-compact={compact ? "true" : "false"}
			sx={{ display: "flex", flexDirection: "column", height, position: "relative" }}
		>
			{showHeader ? (
				<Box sx={{ px: 1, py: 1, borderBottom: `0.5px solid ${Color.Line}`, backgroundColor: Color.BackgroundDark }}>
					<Stack direction="row" spacing={0.75} alignItems="center" justifyContent="space-between">
						<Box>
							<Typography variant="subtitle1" sx={{ color: Color.TextPrimary }}>Dora</Typography>
							<Typography variant="caption" sx={{ color: Color.TextSecondary }}>
								{session?.title ?? title}
								{session ? ` · ${tabLabelMap.get(session.id) ?? (session.kind === "main" ? "main" : "sub")}` : ""}
							</Typography>
						</Box>
						<Chip
							size="small"
							label={t(`agent.taskStatus.${(session?.currentTaskStatus ?? session?.status ?? "IDLE").toLowerCase()}`)}
							sx={{ color: Color.TextPrimary, borderColor: Color.Line }}
							variant="outlined"
						/>
					</Stack>
					<Typography variant="caption" sx={{ color: Color.TextSecondary, mt: 0.25, display: "block" }}>
						{projectRoot}
					</Typography>
					<Stack direction="row" spacing={1} sx={{ mt: 1 }} useFlexGap>
						{session ? (
							<Chip
								size="small"
								label={session.kind === "main" ? "main agent" : "sub agent"}
								variant="outlined"
								sx={{ color: Color.TextSecondary, borderColor: Color.Line }}
							/>
						) : null}
					</Stack>
					</Box>
				) : null}
			{orderedRelatedSessions.length > 1 ? (
				<Stack
					direction="row"
					spacing={0.75}
					alignItems="center"
					sx={{
						px: 3,
						py: 1,
						borderBottom: `1px solid ${Color.Line}`,
						backgroundColor: Color.Background,
						flexShrink: 0,
					}}
				>
					<Typography variant="caption" sx={{ color: Color.TextSecondary, mr: 0.5 }}>
						{t("agent.sessions")}
					</Typography>
					{tabButtons}
				</Stack>
			) : null}
			<MacScrollbar
				ref={scrollRef}
				data-agent-scroll-container="true"
				skin="dark"
				// The panel owns bottom anchoring while output is streaming.
				// Disable Chromium's independent anchor correction so the two
				// systems do not pull the viewport in opposite directions.
				style={{ flex: 1, minHeight: 0, overflowAnchor: "none" }}
			>
				<Box ref={contentRef} sx={{ px: compact ? 1.5 : 3, py: compact ? 1.25 : 3, width: "100%", maxWidth: 1040, mx: "auto", boxSizing: "border-box" }}>
					<Stack spacing={compact ? 2.25 : 4} sx={{ visibility: isSessionHydrating ? "hidden" : "visible" }}>
						{showEmptyState ? (
							<Box
								sx={{
									minHeight: emptyStateMinHeight,
									display: "flex",
									alignItems: "center",
									justifyContent: "center",
									textAlign: "center",
								}}
							>
								<Stack spacing={2.25} alignItems="center" sx={{ maxWidth: 620 }}>
									<Box
										component="img"
										src={doraAgent}
										alt=""
										aria-hidden
										sx={{
											width: 68,
											height: 68,
											objectFit: "contain",
											imageRendering: "pixelated",
											filter: `drop-shadow(0 8px 16px ${Color.Theme}20)`,
										}}
									/>
									<Box>
										<Typography variant="h5" sx={{ color: Color.TextPrimary, fontWeight: 650, letterSpacing: "-0.02em", mb: 0.75 }}>
											{t("agent.emptyTitle")}
										</Typography>
										<Typography variant="body2" sx={{ color: Color.TextSecondary, lineHeight: 1.7 }}>
											{t("agent.emptyDescription")}
										</Typography>
									</Box>
									<Stack direction="row" spacing={1} useFlexGap flexWrap="wrap" justifyContent="center">
										{[
											t("agent.suggestionUnderstand"),
											t("agent.suggestionRun"),
											t("agent.suggestionFeature"),
										].map(suggestion => (
											<Button
												key={suggestion}
												size="small"
												variant="outlined"
												onClick={() => setPrompt(suggestion)}
												sx={{
													color: Color.TextSecondary,
													borderColor: Color.Line,
													backgroundColor: Color.BackgroundDark,
													px: 1.5,
													"&:hover": {
														color: Color.TextPrimary,
														borderColor: Color.LineStrong,
														backgroundColor: Color.SurfaceHover,
													},
												}}
											>
												{suggestion}
											</Button>
										))}
									</Stack>
								</Stack>
							</Box>
						) : null}
						{session?.kind === "sub" && spawnInfo ? (
							<Box
								sx={{
									border: `1px solid ${Color.Line}`,
									backgroundColor: "rgba(255,255,255,0.02)",
									borderRadius: 2,
									px: 2,
									py: 1.5,
								}}
							>
								<Typography variant="overline" sx={{ color: Color.TextSecondary, letterSpacing: "0.08em", display: "block", mb: 1 }}>
									Delegated Task
								</Typography>
								<Typography variant="body2" sx={{ color: Color.TextPrimary, whiteSpace: "pre-wrap", lineHeight: 1.7 }}>
									{spawnInfo.goal || spawnInfo.prompt}
								</Typography>
								{spawnInfo.expectedOutput ? (
									<Typography variant="body2" sx={{ color: Color.TextSecondary, whiteSpace: "pre-wrap", lineHeight: 1.6, mt: 0.75 }}>
										Expected: {spawnInfo.expectedOutput}
									</Typography>
								) : null}
								{spawnInfo.filesHint && spawnInfo.filesHint.length > 0 ? (
									<Typography variant="caption" sx={{ color: Color.TextSecondary, display: "block", mt: 0.75 }}>
										Files: {spawnInfo.filesHint.join(", ")}
									</Typography>
								) : null}
							</Box>
						) : null}
						{messageGroups.historyMessages.length > 0 ? (
							<Box>
								{hiddenHistoryGroupCount > 0 ? (
									<Button
										variant="text"
										size="small"
										onClick={() => setVisibleHistoryRounds(prev => prev + HISTORY_VISIBLE_ROUNDS)}
										sx={{
											mb: 1.5,
											px: 0,
											minWidth: 0,
											justifyContent: "flex-start",
											color: Color.TextSecondary,
											textTransform: "none",
											"&:hover": {
												backgroundColor: "transparent",
												color: Color.TextPrimary,
											},
										}}
									>
										{t("agent.showEarlierHistory", { count: hiddenHistoryRevealCount })}
									</Button>
								) : null}
								<AgentMessageList
									messages={visibleHistoryMessages}
									editableMessageId={latestUserMessageId}
									editDisabled={loading || continueLoadingTaskId !== null || session?.currentTaskStatus === "RUNNING"}
									onResendPrompt={resendPromptText}
								/>
							</Box>
						) : null}
						{messageGroups.currentPromptMessages.length > 0 ? (
							<Box>
								<AgentMessageList
									messages={messageGroups.currentPromptMessages}
									editableMessageId={latestUserMessageId}
									editDisabled={loading || continueLoadingTaskId !== null || session?.currentTaskStatus === "RUNNING"}
									onResendPrompt={resendPromptText}
								/>
							</Box>
						) : null}
						{latestSteps.length > 0 ? (
							<Box>
								<Typography variant="overline" sx={{ color: Color.TextSecondary, letterSpacing: "0.08em", display: "block", mb: 1.25 }}>{t("agent.steps")}</Typography>
								{currentStepWindow.hiddenCount > 0 ? (
									<Button
										variant="text"
										size="small"
										onClick={() => setVisibleCurrentStepCount(prev => prev + CURRENT_STEPS_VISIBLE_COUNT)}
										sx={{
											mb: 1.5,
											px: 0,
											minWidth: 0,
											justifyContent: "flex-start",
											color: Color.TextSecondary,
											textTransform: "none",
											"&:hover": {
												backgroundColor: "transparent",
												color: Color.TextPrimary,
											},
										}}
									>
										{t("agent.showEarlierSteps", { count: currentStepWindow.revealCount })}
									</Button>
								) : null}
								<AgentStepList
									steps={currentStepWindow.items}
									checkpointMap={checkpointMap}
									diffs={diffs}
									taskDiffs={taskDiffs}
									diffLoadingId={diffLoadingId}
									taskDiffLoadingId={taskDiffLoadingId}
									openedDiffId={openedDiffId}
									openedTaskDiffId={openedTaskDiffId}
									running={session?.currentTaskStatus === "RUNNING"}
									rollingBack={rollingBack}
									onToggleDiff={onToggleDiff}
									onToggleTaskDiff={onToggleTaskDiff}
									onRollback={handleRollback}
									onRollbackTaskChangeSet={handleRollbackTaskChangeSet}
									onOpenFile={stableOnOpenFile}
								/>
							</Box>
						) : null}
						{showSummaryShimmer || visibleSummaryMessages.length > 0 || continuableTaskId ? (
							<Box>
								{visibleSummaryMessages.length > 0 || continuableTaskId ? (
									<Typography variant="overline" sx={{ color: Color.TextSecondary, letterSpacing: "0.08em", display: "block", mb: 1.25 }}>{t("agent.summary")}</Typography>
								) : null}
								{visibleSummaryMessages.length > 0 ? (
									<AgentMessageList
										messages={visibleSummaryMessages}
										streamingMessageId={session?.currentTaskStatus === "RUNNING"
											? visibleSummaryMessages[visibleSummaryMessages.length - 1]?.id
											: undefined}
										editableMessageId={latestUserMessageId}
										editDisabled={loading || continueLoadingTaskId !== null || finishHandoffLoadingTaskId !== null || session?.currentTaskStatus === "RUNNING"}
										onResendPrompt={resendPromptText}
									/>
								) : null}
								{visibleSummaryMessages.length > 0 && currentTaskChangeSet && currentTaskChangeSet.filesChanged > 0 ? (
									<AgentChangeSetSummaryCard
										changeSet={currentTaskChangeSet}
										diffs={taskDiffs[currentTaskChangeSet.taskId] ?? []}
										diffOpen={openedTaskDiffId === currentTaskChangeSet.taskId}
										diffLoading={taskDiffLoadingId === currentTaskChangeSet.taskId}
										rollbackLoading={rollingBack === -currentTaskChangeSet.taskId}
										running={session?.currentTaskStatus === "RUNNING"}
										rollbackLabel={t("agent.rollbackThisRunChanges")}
										onToggleDiff={() => void onToggleTaskDiff(currentTaskChangeSet.taskId)}
										onRollback={() => void onRollbackTaskChangeSet(currentTaskChangeSet.taskId)}
										onOpenFile={onOpenFile}
									/>
								) : null}
								{continuableTaskId ? (
									<Stack direction="row" spacing={1} alignItems="center" sx={{ mt: 1.5 }}>
										<Button
											size="small"
											variant="outlined"
											onClick={() => void onContinueTask()}
											disabled={loading || session?.currentTaskStatus === "RUNNING" || continueLoadingTaskId !== null || finishHandoffLoadingTaskId !== null}
											sx={{
												color: Color.TextSecondary,
												borderColor: Color.Line,
												borderRadius: 999,
												"&.Mui-disabled": {
													color: Color.TextSecondary,
													borderColor: Color.Line,
												},
												"&:hover": {
													borderColor: Color.Line,
													backgroundColor: "rgba(255,255,255,0.03)",
												},
											}}
										>
											{t("agent.continueTask")}
										</Button>
										{continueLoadingTaskId === continuableTaskId ? <CircularProgress size={16} /> : null}
										{session?.kind === "sub" ? (
											<Button
												size="small"
												variant="outlined"
												onClick={() => void onFinishHandoff()}
												disabled={loading || session.currentTaskStatus === "RUNNING" || continueLoadingTaskId !== null || finishHandoffLoadingTaskId !== null}
												sx={{
													color: Color.Warning,
													borderColor: `${Color.Warning}66`,
													borderRadius: 999,
													"&.Mui-disabled": {
														color: Color.TextSecondary,
														borderColor: Color.Line,
													},
													"&:hover": {
														borderColor: Color.Warning,
														backgroundColor: `${Color.Warning}12`,
													},
												}}
											>
												{t("agent.finishAndHandoff")}
											</Button>
										) : null}
										{finishHandoffLoadingTaskId === continuableTaskId ? <CircularProgress size={16} /> : null}
										{workMode === "plan" && hasActivePlan && session?.kind === "main" && visibleSummaryMessages.length > 0 && !showSummaryShimmer ? (
											<Button
												size="small"
												variant="outlined"
												disabled={loading || session.currentTaskStatus === "RUNNING" || session.currentTaskStatus === "WAITING_USER"}
												onClick={() => void startDevelopment()}
												sx={{
													color: Color.TextSecondary,
													borderColor: Color.Line,
													borderRadius: 999,
													"&.Mui-disabled": {
														color: Color.TextSecondary,
														borderColor: Color.Line,
													},
													"&:hover": {
														borderColor: Color.Line,
														backgroundColor: "rgba(255,255,255,0.03)",
													},
												}}
											>
												{t("agent.plan.start")}
											</Button>
										) : null}
									</Stack>
								) : null}
								{showSummaryShimmer ? (
									<Typography
										data-agent-thinking="true"
										variant="body1"
										sx={{
											mt: visibleSummaryMessages.length > 0 ? 1.5 : 0,
											color: "rgba(255,255,255,0.45)",
											display: "inline-block",
											fontWeight: 500,
											backgroundImage: "linear-gradient(90deg, rgba(255,255,255,0.28) 0%, rgba(255,255,255,0.92) 45%, rgba(255,255,255,0.28) 100%)",
											backgroundSize: "200% 100%",
											backgroundClip: "text",
											WebkitBackgroundClip: "text",
											WebkitTextFillColor: "transparent",
											animation: "agent-summary-shimmer 5s linear infinite",
											"@keyframes agent-summary-shimmer": {
												"0%": { backgroundPosition: "200% 0" },
												"100%": { backgroundPosition: "-200% 0" },
											},
										}}
									>
										{t("agent.thinking")}
									</Typography>
								) : null}
								{workMode === "plan" && hasActivePlan && session?.kind === "main" && visibleSummaryMessages.length > 0 && !showSummaryShimmer && !continuableTaskId ? (
									<Stack direction="row" spacing={1} alignItems="center" sx={{ mt: 1.5 }}>
										<Button
											size="small"
											variant="outlined"
											disabled={loading || session.currentTaskStatus === "RUNNING" || session.currentTaskStatus === "WAITING_USER"}
											onClick={() => void startDevelopment()}
											sx={{
												color: Color.TextSecondary,
												borderColor: Color.Line,
												borderRadius: 999,
												"&.Mui-disabled": {
													color: Color.TextSecondary,
													borderColor: Color.Line,
												},
												"&:hover": {
													borderColor: Color.Line,
													backgroundColor: "rgba(255,255,255,0.03)",
												},
											}}
										>
											{t("agent.plan.start")}
										</Button>
									</Stack>
								) : null}
							</Box>
						) : null}
						{llmConfigMissing && session?.currentTaskStatus !== "RUNNING" ? (
							<Box
								sx={{
									border: `1px solid ${Color.Warning}44`,
									backgroundColor: `${Color.Warning}14`,
									borderRadius: 2,
									px: 2,
									py: 1.5,
								}}
							>
								<Stack direction="row" spacing={2} alignItems="center" justifyContent="space-between">
									<Box sx={{ minWidth: 0 }}>
										<Typography variant="subtitle2" sx={{ color: Color.TextPrimary, mb: 0.5 }}>
											{t("agent.noLLMConfigTitle")}
										</Typography>
										<Typography variant="body2" sx={{ color: Color.TextSecondary }}>
											{t("agent.noLLMConfigDescription")}
										</Typography>
									</Box>
									<Button
										variant="outlined"
										size="small"
										onClick={onOpenLLMConfig}
										sx={{
											flexShrink: 0,
											borderColor: Color.Line,
											color: Color.TextPrimary,
										}}
									>
										{t("agent.openLLMConfig")}
									</Button>
								</Stack>
							</Box>
						) : null}
					</Stack>
				</Box>
			</MacScrollbar>
			{pendingQuestionnaire ? (
				<AgentQuestionnaire
					questionnaire={pendingQuestionnaire}
					submitting={questionnaireSubmitting}
					onSubmit={answers => void submitQuestionnaire(answers)}
					onCancel={() => setQuestionnaireCancelId(pendingQuestionnaire.id)}
				/>
			) : <>
				<AgentComposer
					compact={compact}
					prompt={prompt}
					loading={loading || continueLoadingTaskId !== null || finishHandoffLoadingTaskId !== null || stoppingTaskId !== null}
						running={session?.currentTaskStatus === "RUNNING"}
						stopping={stoppingTaskId !== null}
						canStop={session?.currentTaskStatus === "RUNNING" && session?.currentTaskFinalizing !== true && stoppingTaskId === null}
						contextRatio={contextStats.contextRatio}
					usedTokens={contextStats.usedTokens}
					maxTokens={contextStats.maxTokens}
					actualUsage={contextStats.actualUsage}
					fetchUrlEnabled={fetchUrlEnabled}
					executeCommandEnabled={executeCommandEnabled}
					planMode={workMode === "plan"}
					llmConfigs={llmConfigs}
					llmConfigId={selectedLLMConfigId}
					onPromptChange={setPrompt}
					onSend={() => void onSend()}
					onStop={() => void onStop()}
					onFetchUrlEnabledChange={session?.kind === "main" ? setFetchUrlEnabled : undefined}
					onExecuteCommandEnabledChange={session?.kind === "main" ? setExecuteCommandEnabled : undefined}
					onPlanModeChange={session?.kind === "main" ? value => void changeWorkMode(value) : undefined}
					onLLMConfigChange={selectLLMConfig}
				/>
			</>}
			<Dialog
				open={questionnaireCancelId !== null && questionnaireCancelId === pendingQuestionnaire?.id}
				onClose={() => {
					if (!questionnaireSubmitting) setQuestionnaireCancelId(null);
				}}
				fullWidth
				maxWidth="xs"
			>
				<DialogTitle>{t("agent.questionnaire.cancelTitle")}</DialogTitle>
				<DialogContent>
					<DialogContentText color={Color.TextPrimary}>
						{t("agent.questionnaire.cancelConfirm")}
					</DialogContentText>
				</DialogContent>
				<DialogActions>
					<Button disabled={questionnaireSubmitting} onClick={() => setQuestionnaireCancelId(null)}>
						{t("agent.questionnaire.keepAnswering")}
					</Button>
					<Button
						color="error"
						variant="contained"
						disabled={questionnaireSubmitting}
						onClick={() => void cancelQuestionnaire()}
					>
						{questionnaireSubmitting ? <CircularProgress size={16} color="inherit" /> : t("agent.questionnaire.confirmClose")}
					</Button>
				</DialogActions>
			</Dialog>
			{!isFollowingOutput ? (
				<Tooltip title={t("agent.scrollToBottom")}>
					<IconButton
						onClick={() => resumeFollowingOutput("smooth")}
						sx={{
							position: "absolute",
							right: compact ? 12 : 24,
							bottom: compact ? 104 : 168,
							width: compact ? 40 : undefined,
							height: compact ? 40 : undefined,
							zIndex: 2,
							backgroundColor: "rgba(255,255,255,0.08)",
							backdropFilter: "blur(10px)",
							color: "rgba(255,255,255,0.72)",
							border: `0.5px solid ${Color.Line}`,
							"&:hover": {
								backgroundColor: "rgba(255,255,255,0.14)",
								color: Color.TextPrimary,
							},
						}}
					>
						<BsArrowDown size={18} />
					</IconButton>
				</Tooltip>
			) : null}
		</Box>
	);
}

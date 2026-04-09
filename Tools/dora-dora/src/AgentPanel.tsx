import React, { useEffect, useLayoutEffect, useMemo, useState } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
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

interface AgentPanelProps {
	sessionId: number;
	projectRoot: string;
	title: string;
	height: number;
	showHeader?: boolean;
	addAlert?: (msg: string, type: "success" | "info" | "warning" | "error") => void;
	onRollbackComplete?: (projectRoot: string) => void;
	onOpenFile?: (filePath: string) => void;
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

function upsertById<T extends { id: number }>(items: T[], nextItem: T): T[] {
	const next = [...items];
	const index = next.findIndex(item => item.id === nextItem.id);
	if (index >= 0) {
		next[index] = nextItem;
	} else {
		next.push(nextItem);
	}
	return next;
}

export default function AgentPanel(props: AgentPanelProps) {
	const HISTORY_VISIBLE_ROUNDS = 10;
	const { t } = useTranslation();
	const { sessionId, projectRoot, title, height, showHeader = true, addAlert, onRollbackComplete, onOpenFile, onOpenLLMConfig } = props;
	const [prompt, setPrompt] = useState("");
	const [loading, setLoading] = useState(false);
	const [rollingBack, setRollingBack] = useState<number | null>(null);
	const [session, setSession] = useState<Service.AgentSession | null>(null);
	const [messages, setMessages] = useState<Service.AgentSessionMessage[]>([]);
	const [steps, setSteps] = useState<Service.AgentSessionStep[]>([]);
	const [checkpoints, setCheckpoints] = useState<Service.AgentCheckpointItem[]>([]);
	const [diffs, setDiffs] = useState<Record<number, Service.AgentCheckpointDiffFile[]>>({});
	const [diffLoadingId, setDiffLoadingId] = useState<number | null>(null);
	const [openedDiffId, setOpenedDiffId] = useState<number | null>(null);
	const [visibleHistoryRounds, setVisibleHistoryRounds] = useState(HISTORY_VISIBLE_ROUNDS);
	const [isNearBottom, setIsNearBottom] = useState(true);
	const [llmConfigMissing, setLLMConfigMissing] = useState(false);
	const scrollRef = React.useRef<HTMLElement | null>(null);
	const contentRef = React.useRef<HTMLDivElement | null>(null);
	const isNearBottomRef = React.useRef(true);
	const autoScrollTimerRef = React.useRef<number | null>(null);
	const autoScrollRafRef = React.useRef<number | null>(null);

	const checkLLMConfigReady = React.useCallback(async () => {
		try {
			const res = await Service.listLLMConfigs();
			if (!res.success) {
				return true;
			}
			const hasActiveConfig = (res.items ?? []).some(item => Boolean(item.active));
			setLLMConfigMissing(!hasActiveConfig);
			return hasActiveConfig;
		} catch {
			return true;
		}
	}, []);

	const scrollToBottom = React.useCallback((behavior: ScrollBehavior = "auto") => {
		const applyScroll = () => {
			const container = scrollRef.current;
			if (!container) return;
			container.scrollTo({ top: container.scrollHeight, behavior });
		};
		applyScroll();
		window.requestAnimationFrame(() => {
			applyScroll();
			window.requestAnimationFrame(() => {
				applyScroll();
			});
		});
	}, []);

	const cancelAutoScroll = React.useCallback(() => {
		if (autoScrollTimerRef.current !== null) {
			window.clearTimeout(autoScrollTimerRef.current);
			autoScrollTimerRef.current = null;
		}
		if (autoScrollRafRef.current !== null) {
			window.cancelAnimationFrame(autoScrollRafRef.current);
			autoScrollRafRef.current = null;
		}
	}, []);

	const scheduleStickyBottomSync = React.useCallback((behavior: ScrollBehavior = "auto") => {
		if (!isNearBottomRef.current) return;
		cancelAutoScroll();
		const start = window.performance.now();
		const tick = () => {
			if (!isNearBottomRef.current) {
				cancelAutoScroll();
				return;
			}
			scrollToBottom(behavior);
			if (window.performance.now() - start < 400) {
				autoScrollRafRef.current = window.requestAnimationFrame(tick);
			} else {
				autoScrollRafRef.current = null;
			}
		};
		tick();
		autoScrollTimerRef.current = window.setTimeout(() => {
			if (isNearBottomRef.current) {
				scrollToBottom(behavior);
			}
			autoScrollTimerRef.current = null;
		}, 500);
	}, [cancelAutoScroll, scrollToBottom]);

	const syncBottomState = React.useCallback(() => {
		const container = scrollRef.current;
		if (!container) return true;
		const distanceToBottom = container.scrollHeight - container.scrollTop - container.clientHeight;
		const nextIsNearBottom = distanceToBottom <= 8;
		isNearBottomRef.current = nextIsNearBottom;
		setIsNearBottom(nextIsNearBottom);
		return nextIsNearBottom;
	}, []);

	const refresh = React.useCallback(async (statusOnly = false) => {
		if (statusOnly) {
			const res = await Service.agentTaskStatus({ sessionId });
			if (res.success) {
				setSession(res.session);
				setMessages(normalizeList<Service.AgentSessionMessage>(res.messages));
				setSteps(normalizeList<Service.AgentSessionStep>(res.steps));
				setCheckpoints(normalizeList<Service.AgentCheckpointItem>(res.checkpoints));
				return;
			}
			addAlert?.(res.message, "error");
			return;
		}
		const res = await Service.agentSessionGet({ sessionId });
		if (res.success) {
			setSession(res.session);
			setMessages(normalizeList<Service.AgentSessionMessage>(res.messages));
			setSteps(normalizeList<Service.AgentSessionStep>(res.steps));
			return;
		}
		addAlert?.(res.message, "error");
	}, [addAlert, sessionId]);

	useEffect(() => {
		void refresh(false);
	}, [refresh]);

	useEffect(() => {
		const onPatch = (patch: Service.AgentSessionPatch) => {
			if (patch.sessionId !== sessionId) return;
			if (patch.session) {
				setSession(patch.session);
			}
			if (patch.message) {
				setMessages(prev => upsertById(prev, patch.message!).sort((a, b) => a.id - b.id));
			}
			if (patch.step) {
				setSteps(prev => upsertById(prev, patch.step!).sort((a, b) => {
					const taskDelta = (b.taskId ?? 0) - (a.taskId ?? 0);
					if (taskDelta !== 0) return taskDelta;
					return a.step - b.step;
				}));
			}
			if (patch.removedStepIds && patch.removedStepIds.length > 0) {
				setSteps(prev => prev.filter(step => !patch.removedStepIds!.includes(step.id)));
			}
			if (patch.checkpoints) {
				setCheckpoints(normalizeList<Service.AgentCheckpointItem>(patch.checkpoints));
			}
		};
		Service.addAgentSessionPatchListener(onPatch);
		return () => {
			Service.removeAgentSessionPatchListener(onPatch);
		};
	}, [sessionId]);

	useEffect(() => {
		void checkLLMConfigReady();
	}, [checkLLMConfigReady]);

	useEffect(() => {
		setVisibleHistoryRounds(HISTORY_VISIBLE_ROUNDS);
	}, [sessionId]);

	useEffect(() => {
		if (session?.currentTaskStatus !== "RUNNING") return;
		const timer = window.setInterval(() => {
			void refresh(true);
		}, 3000);
		return () => window.clearInterval(timer);
	}, [refresh, session?.currentTaskStatus]);

	const lastMessage = messages[messages.length - 1];
	const lastStep = steps[steps.length - 1];

	useLayoutEffect(() => {
		if (!isNearBottom) return;
		scheduleStickyBottomSync("auto");
		return cancelAutoScroll;
	}, [
		cancelAutoScroll,
		isNearBottom,
		scheduleStickyBottomSync,
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
	}, [syncBottomState, visibleHistoryRounds]);

	useEffect(() => {
		const content = contentRef.current;
		if (!content || typeof ResizeObserver === "undefined") return;
		const observer = new ResizeObserver(() => {
			if (!isNearBottomRef.current) return;
			scheduleStickyBottomSync("auto");
		});
		observer.observe(content);
		return () => observer.disconnect();
	}, [scheduleStickyBottomSync]);

	useEffect(() => {
		const content = contentRef.current;
		if (!content || typeof MutationObserver === "undefined") return;
		const observer = new MutationObserver(() => {
			if (!isNearBottomRef.current) return;
			scheduleStickyBottomSync("auto");
		});
		observer.observe(content, {
			childList: true,
			subtree: true,
			characterData: true,
		});
		return () => observer.disconnect();
	}, [scheduleStickyBottomSync]);

	useEffect(() => {
		return () => {
			cancelAutoScroll();
		};
	}, [cancelAutoScroll]);

	const latestSteps = useMemo(() => {
		const taskId = session?.currentTaskId;
		if (!taskId) return steps;
		return steps.filter(step => step.taskId === taskId);
	}, [steps, session?.currentTaskId]);

	const activeTaskId = useMemo(() => {
		if (session?.currentTaskId) return session.currentTaskId;
		const taskIds = [
			...messages.map(message => message.taskId ?? 0),
			...steps.map(step => step.taskId ?? 0),
		].filter(taskId => taskId > 0);
		return taskIds.length > 0 ? Math.max(...taskIds) : null;
	}, [messages, steps, session?.currentTaskId]);

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
		return groups;
	}, [messageGroups.historyMessages]);

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

	const checkpointMap = useMemo(() => {
		return new Map(checkpoints.map(checkpoint => [checkpoint.seq, checkpoint]));
	}, [checkpoints]);

	const onSend = async () => {
		const text = prompt.trim();
		if (text === "" || loading) return;
		setLoading(true);
		try {
			const llmReady = await checkLLMConfigReady();
			if (!llmReady) {
				addAlert?.(t("agent.noLLMConfigAlert"), "error");
				return;
			}
			const res = await Service.agentSessionSend({
				sessionId,
				prompt: text
			});
			if (!res.success) {
				if (res.message === "no active LLM config") {
					setLLMConfigMissing(true);
					addAlert?.(t("agent.noLLMConfigAlert"), "error");
					return;
				}
				addAlert?.(res.message, "error");
				return;
			}
			setLLMConfigMissing(false);
			setPrompt("");
			await refresh(true);
		} finally {
			setLoading(false);
		}
	};

	const onStop = async () => {
		const res = await Service.agentTaskStop({ sessionId });
		if (!res.success) {
			addAlert?.(res.message ?? t("agent.stopFailed"), "error");
			return;
		}
		await refresh(true);
	};

	const onToggleDiff = async (step: Service.AgentSessionStep) => {
		if (!step.checkpointId) return;
		if (openedDiffId === step.checkpointId) {
			setOpenedDiffId(null);
			return;
		}
		setOpenedDiffId(step.checkpointId);
		if (diffs[step.checkpointId]) return;
		setDiffLoadingId(step.checkpointId);
		try {
			const res = await Service.agentCheckpointDiff({ checkpointId: step.checkpointId });
			if (!res.success) {
				addAlert?.(res.message, "error");
				return;
			}
			setDiffs(prev => ({ ...prev, [step.checkpointId!]: res.files }));
		} finally {
			setDiffLoadingId(null);
		}
	};

	const onRollback = async (step: Service.AgentSessionStep) => {
		const seq = step.checkpointSeq;
		const checkpointId = step.checkpointId;
		if (!seq || !checkpointId || rollingBack !== null) return;
		setRollingBack(seq);
		try {
			const res = await Service.agentCheckpointRollback({
				sessionId,
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
	};

	return (
		<Box sx={{ display: "flex", flexDirection: "column", height, position: "relative" }}>
			{showHeader ? (
				<Box sx={{ px: 1, py: 1, borderBottom: `0.5px solid ${Color.Line}`, backgroundColor: Color.BackgroundDark }}>
					<Stack direction="row" spacing={0.75} alignItems="center" justifyContent="space-between">
						<Box>
							<Typography variant="subtitle1" sx={{ color: Color.TextPrimary }}>Dora</Typography>
							<Typography variant="caption" sx={{ color: Color.TextSecondary }}>{title}</Typography>
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
				</Box>
			) : null}
			<MacScrollbar ref={scrollRef} skin="dark" style={{ flex: 1, minHeight: 0 }}>
				<Box ref={contentRef} sx={{ px: 3, py: 3 }}>
					<Stack spacing={4}>
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
								<AgentMessageList messages={visibleHistoryMessages} />
							</Box>
						) : null}
						{messageGroups.currentPromptMessages.length > 0 ? (
							<Box>
								<AgentMessageList messages={messageGroups.currentPromptMessages} />
							</Box>
						) : null}
						{latestSteps.length > 0 ? (
							<Box>
								<Typography variant="overline" sx={{ color: Color.TextSecondary, letterSpacing: "0.08em", display: "block", mb: 1.25 }}>{t("agent.steps")}</Typography>
								<AgentStepList
									steps={latestSteps}
									checkpointMap={checkpointMap}
									diffs={diffs}
									diffLoadingId={diffLoadingId}
									openedDiffId={openedDiffId}
									running={session?.currentTaskStatus === "RUNNING"}
									rollingBack={rollingBack}
									onToggleDiff={(step) => void onToggleDiff(step)}
									onRollback={(seq) => void onRollback(seq)}
									onOpenFile={onOpenFile}
								/>
							</Box>
						) : null}
						{showSummaryShimmer || visibleSummaryMessages.length > 0 ? (
							<Box>
								{visibleSummaryMessages.length > 0 ? (
									<Typography variant="overline" sx={{ color: Color.TextSecondary, letterSpacing: "0.08em", display: "block", mb: 1.25 }}>{t("agent.summary")}</Typography>
								) : null}
								{visibleSummaryMessages.length > 0 ? (
									<AgentMessageList messages={visibleSummaryMessages} />
								) : null}
								{showSummaryShimmer ? (
									<Typography
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
							</Box>
						) : null}
					</Stack>
				</Box>
			</MacScrollbar>
			<AgentComposer
				prompt={prompt}
				loading={loading}
				running={session?.currentTaskStatus === "RUNNING"}
				onPromptChange={setPrompt}
				onSend={() => void onSend()}
				onStop={() => void onStop()}
			/>
			{!isNearBottom ? (
				<Tooltip title={t("agent.scrollToBottom")}>
					<IconButton
						onClick={() => scrollToBottom("smooth")}
						sx={{
							position: "absolute",
							right: 24,
							bottom: 168,
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

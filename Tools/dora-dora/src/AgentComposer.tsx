import React from 'react';
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import DownloadIcon from '@mui/icons-material/Download';
import TerminalIcon from '@mui/icons-material/Terminal';
import ChecklistIcon from '@mui/icons-material/Checklist';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import { BsFillSendFill, BsStopFill } from 'react-icons/bs';
import { Color } from './Theme';

const AGENT_USER_PROMPT_MAX_CHARS = 12000;
const CONTEXT_USAGE_LOW_COLOR = "rgba(255,255,255,0.42)";


interface AgentComposerProps {
	prompt: string;
	loading: boolean;
	running: boolean;
	canStop?: boolean;
	tabButtons?: React.ReactNode;
	contextRatio?: number;
	usedTokens?: number;
	maxTokens?: number;
	actualUsage?: {
		inputTokens: number;
		outputTokens: number;
		cachedInputTokens?: number;
		requestCount?: number;
	};
	fetchUrlEnabled?: boolean;
	executeCommandEnabled?: boolean;
	planMode?: boolean;
	llmConfigs?: Array<{ id: number; name: string }>;
	llmConfigId?: number;
	onPromptChange: (value: string) => void;
	onSend: () => void;
	onStop: () => void;
	onFetchUrlEnabledChange?: (value: boolean) => void;
	onExecuteCommandEnabledChange?: (value: boolean) => void;
	onPlanModeChange?: (value: boolean) => void;
	onLLMConfigChange?: (value: number) => void;
}

function formatCompactNumber(value: number): string {
	if (!Number.isFinite(value)) return "0";
	if (value >= 1000000) return `${(value / 1000000).toFixed(1)}m`;
	if (value >= 1000) return `${(value / 1000).toFixed(1)}k`;
	return String(Math.max(0, Math.round(value)));
}

function ContextUsageRing(props: {
	ratio?: number;
	usedTokens?: number;
	maxTokens?: number;
	actualUsage?: AgentComposerProps["actualUsage"];
}) {
	const { t } = useTranslation();
	const usedTokens = props.usedTokens ?? 0;
	const maxTokens = props.maxTokens ?? 64000;
	const ratio = Math.max(0, Math.min(1, props.ratio ?? (maxTokens > 0 ? usedTokens / maxTokens : 0)));
	const percent = Math.round(ratio * 100);
	const hasUsage = usedTokens > 0 || props.ratio !== undefined;
	const color = hasUsage ? Color.Theme + "cc" : CONTEXT_USAGE_LOW_COLOR;
	const trackColor = hasUsage ? "rgba(255,255,255,0.12)" : "rgba(255,255,255,0.08)";
	const contextTitle = t("agent.contextEstimateTitle", {
		used: formatCompactNumber(usedTokens),
		max: formatCompactNumber(maxTokens),
		percent,
	});
	const actualTitle = props.actualUsage
		? t(props.actualUsage.cachedInputTokens !== undefined
			? "agent.actualUsageWithCacheTitle"
			: "agent.actualUsageTitle", {
			input: formatCompactNumber(props.actualUsage.inputTokens),
			output: formatCompactNumber(props.actualUsage.outputTokens),
			cached: formatCompactNumber(props.actualUsage.cachedInputTokens ?? 0),
			cachePercent: props.actualUsage.inputTokens > 0
				? Math.round(((props.actualUsage.cachedInputTokens ?? 0) / props.actualUsage.inputTokens) * 100)
				: 0,
			requests: formatCompactNumber(props.actualUsage.requestCount ?? 0),
		})
		: "";
	const title = actualTitle !== "" ? `${contextTitle}\n${actualTitle}` : contextTitle;
	return (
		<Tooltip title={<span style={{ whiteSpace: "pre-line" }}>{title}</span>}>
			<Box
				aria-label={title}
				sx={{
					width: 26,
					height: 26,
					borderRadius: "50%",
					background: `conic-gradient(${color} ${percent * 3.6}deg, ${trackColor} 0deg)`,
					display: "grid",
					placeItems: "center",
					boxShadow: `0 0 14px ${color}22`,
					cursor: "default",
				}}
			>
				<Box
					sx={{
						width: 20,
						height: 20,
						borderRadius: "50%",
						backgroundColor: "rgba(24,24,24,0.62)",
						backdropFilter: "blur(8px)",
						WebkitBackdropFilter: "blur(8px)",
						display: "grid",
						placeItems: "center",
						border: "1px solid rgba(255,255,255,0.08)",
						color,
						fontSize: 9,
						fontWeight: 800,
						lineHeight: 1,
						userSelect: "none",
					}}
				>
					{percent}
				</Box>
			</Box>
		</Tooltip>
	);
}

export default function AgentComposer(props: AgentComposerProps) {
	const { t } = useTranslation();
	const {
		prompt,
		loading,
		running,
		canStop = true,
		tabButtons,
		contextRatio,
		usedTokens,
		maxTokens,
		actualUsage,
		fetchUrlEnabled = false,
		executeCommandEnabled = false,
		planMode = false,
		llmConfigs = [],
		llmConfigId,
		onPromptChange,
		onSend,
		onStop,
		onFetchUrlEnabledChange,
		onExecuteCommandEnabledChange,
		onPlanModeChange,
		onLLMConfigChange,
	} = props;
	const disabledInput = loading || running;
	const actionDisabled = running ? !canStop : loading || prompt.trim() === "";
	const showActionButton = running || prompt.trim() !== "";
	const toolToggleDisabled = loading || running;
	const fetchUrlToggleDisabled = toolToggleDisabled || onFetchUrlEnabledChange === undefined;
	const executeCommandToggleDisabled = toolToggleDisabled || onExecuteCommandEnabledChange === undefined;
	const showTopControls = tabButtons !== undefined || onFetchUrlEnabledChange !== undefined || onExecuteCommandEnabledChange !== undefined || onPlanModeChange !== undefined;
	const showFetchUrlButton = onFetchUrlEnabledChange !== undefined && !planMode;
	const showExecuteCommandButton = onExecuteCommandEnabledChange !== undefined && !planMode;
	const showPlanModeButton = onPlanModeChange !== undefined;
	const textAreaRef = React.useRef<HTMLTextAreaElement | null>(null);
	const scrollRef = React.useRef<HTMLElement | null>(null);
	const isComposingRef = React.useRef(false);
	const selectedLLMConfigName = llmConfigs.find(item => item.id === llmConfigId)?.name ?? t("agent.selectModel");

	React.useLayoutEffect(() => {
		const textarea = textAreaRef.current;
		if (textarea == null) return;
		const scrollContainer = scrollRef.current;
		const previousScrollHeight = scrollContainer?.scrollHeight ?? 0;
		const previousScrollTop = scrollContainer?.scrollTop ?? 0;
		const wasNearBottom = scrollContainer != null
			? previousScrollHeight - (previousScrollTop + scrollContainer.clientHeight) < 24
			: false;
		textarea.style.height = "0px";
		textarea.style.height = `${Math.max(textarea.scrollHeight, 36)}px`;
		if (scrollContainer != null) {
			if (wasNearBottom) {
				scrollContainer.scrollTop = scrollContainer.scrollHeight;
			} else {
				const nextScrollHeight = scrollContainer.scrollHeight;
				scrollContainer.scrollTop = previousScrollTop + Math.max(0, nextScrollHeight - previousScrollHeight);
			}
		}
	}, [prompt]);

	const fetchUrlButton = (
		<Tooltip title={t("agent.networkToolsToggle")}>
			<span>
				<IconButton
					onClick={() => onFetchUrlEnabledChange?.(!fetchUrlEnabled)}
					disabled={fetchUrlToggleDisabled}
					sx={{
						width: 30,
						height: 30,
						borderRadius: 999,
						border: `1px solid ${fetchUrlEnabled ? `${Color.Theme}7d` : 'rgba(255, 255, 255, 0.14)'}`,
						backgroundColor: fetchUrlEnabled ? `${Color.Theme}14` : 'rgba(24, 24, 24, 0.46)',
						backdropFilter: "blur(10px)",
						color: fetchUrlEnabled ? `${Color.Theme}d6` : Color.TextSecondary,
						boxShadow: fetchUrlEnabled ? `0 0 0 1px ${Color.Theme}1a inset` : "none",
						'&:hover': {
							borderColor: fetchUrlEnabled ? `${Color.Theme}b3` : 'rgba(255, 255, 255, 0.22)',
							backgroundColor: fetchUrlEnabled ? `${Color.Theme}1c` : 'rgba(255, 255, 255, 0.08)',
						},
						"&.Mui-disabled": {
							borderColor: fetchUrlEnabled ? `${Color.Theme}7d` : 'rgba(255, 255, 255, 0.1)',
							backgroundColor: fetchUrlEnabled ? `${Color.Theme}14` : 'rgba(24, 24, 24, 0.38)',
							color: fetchUrlEnabled ? `${Color.Theme}d6` : "rgba(255, 255, 255, 0.34)",
							opacity: 1,
						},
					}}
					aria-pressed={fetchUrlEnabled}
					aria-label={t("agent.fetchUrl.toggle")}
				>
					<DownloadIcon sx={{ fontSize: 18, display: "block" }} />
				</IconButton>
			</span>
		</Tooltip>
	);
	const executeCommandButton = (
		<Tooltip title={t("agent.executeCommandToggle")}>
			<span>
				<IconButton
					onClick={() => onExecuteCommandEnabledChange?.(!executeCommandEnabled)}
					disabled={executeCommandToggleDisabled}
					sx={{
						width: 30,
						height: 30,
						borderRadius: 999,
						border: `1px solid ${executeCommandEnabled ? `${Color.Theme}7d` : 'rgba(255, 255, 255, 0.14)'}`,
						backgroundColor: executeCommandEnabled ? `${Color.Theme}14` : 'rgba(24, 24, 24, 0.46)',
						backdropFilter: "blur(10px)",
						color: executeCommandEnabled ? `${Color.Theme}d6` : Color.TextSecondary,
						boxShadow: executeCommandEnabled ? `0 0 0 1px ${Color.Theme}1a inset` : "none",
						'&:hover': {
							borderColor: executeCommandEnabled ? `${Color.Theme}b3` : 'rgba(255, 255, 255, 0.22)',
							backgroundColor: executeCommandEnabled ? `${Color.Theme}1c` : 'rgba(255, 255, 255, 0.08)',
						},
						"&.Mui-disabled": {
							borderColor: executeCommandEnabled ? `${Color.Theme}7d` : 'rgba(255, 255, 255, 0.1)',
							backgroundColor: executeCommandEnabled ? `${Color.Theme}14` : 'rgba(24, 24, 24, 0.38)',
							color: executeCommandEnabled ? `${Color.Theme}d6` : "rgba(255, 255, 255, 0.34)",
							opacity: 1,
						},
					}}
					aria-pressed={executeCommandEnabled}
					aria-label={t("agent.executeCommand")}
				>
					<TerminalIcon sx={{ fontSize: 18, display: "block" }} />
				</IconButton>
			</span>
		</Tooltip>
	);
	const planModeButton = (
		<Tooltip title={t("agent.planModeToggle")}>
			<span>
				<IconButton
					onClick={() => onPlanModeChange?.(!planMode)}
					disabled={toolToggleDisabled}
					aria-pressed={planMode}
					aria-label={t("agent.planMode")}
					sx={{
						width: 30,
						height: 30,
						borderRadius: 999,
						border: `1px solid ${planMode ? `${Color.Theme}7d` : 'rgba(255, 255, 255, 0.14)'}`,
						backgroundColor: planMode ? `${Color.Theme}14` : 'rgba(24, 24, 24, 0.46)',
						color: planMode ? `${Color.Theme}d6` : Color.TextSecondary,
						boxShadow: planMode ? `0 0 0 1px ${Color.Theme}1a inset` : "none",
						'&:hover': {
							borderColor: planMode ? `${Color.Theme}b3` : 'rgba(255, 255, 255, 0.22)',
							backgroundColor: planMode ? `${Color.Theme}1c` : 'rgba(255, 255, 255, 0.08)',
						},
						"&.Mui-disabled": {
							borderColor: planMode ? `${Color.Theme}7d` : 'rgba(255, 255, 255, 0.1)',
							backgroundColor: planMode ? `${Color.Theme}14` : 'rgba(24, 24, 24, 0.38)',
							color: planMode ? `${Color.Theme}d6` : "rgba(255, 255, 255, 0.34)",
							opacity: 1,
						},
					}}
				>
					<ChecklistIcon sx={{ fontSize: 18 }} />
				</IconButton>
			</span>
		</Tooltip>
	);

	return (
		<Box sx={{ px: 2, pt: 0, pb: 2, backgroundColor: Color.Background, position: "relative", flexShrink: 0, overflow: "visible" }}>
			{showTopControls ? (
				<Stack
					direction="row"
					spacing={1}
					alignItems="center"
					sx={{
						position: "absolute",
						top: -36,
						left: 16,
						right: 24,
						zIndex: 3,
						pointerEvents: "none",
					}}
				>
					<Stack
						direction="row"
						spacing={0.75}
						useFlexGap
						sx={{
							flex: "1 1 auto",
							minWidth: 0,
							flexWrap: "wrap",
							justifyContent: "flex-end",
							pointerEvents: "auto",
						}}
					>
						{showPlanModeButton ? planModeButton : null}
						{showFetchUrlButton ? fetchUrlButton : null}
						{showExecuteCommandButton ? executeCommandButton : null}
						{tabButtons}
					</Stack>
					<Box sx={{ flex: "0 0 auto", pointerEvents: "auto" }}>
				<ContextUsageRing ratio={contextRatio} usedTokens={usedTokens} maxTokens={maxTokens} actualUsage={actualUsage} />
					</Box>
				</Stack>
			) : null}
			<Box sx={{ border: `0.5px solid ${Color.Line}`, borderRadius: 4, backgroundColor: Color.BackgroundDark, position: "relative", minHeight: 90 }}>
				<Box sx={{ position: "absolute", inset: 0 }}>
					<MacScrollbar ref={scrollRef} skin="dark" style={{ width: "100%", height: "100%" }}>
						<textarea
							ref={textAreaRef}
							value={prompt}
							maxLength={AGENT_USER_PROMPT_MAX_CHARS}
							disabled={disabledInput}
							onChange={event => onPromptChange(event.target.value.slice(0, AGENT_USER_PROMPT_MAX_CHARS))}
							onCompositionStart={() => {
								isComposingRef.current = true;
							}}
							onCompositionEnd={event => {
								isComposingRef.current = false;
								onPromptChange(event.currentTarget.value);
							}}
							onKeyDown={event => {
								if (isComposingRef.current || event.nativeEvent.isComposing) {
									return;
								}
								if (event.key === "Enter" && !event.shiftKey) {
									event.preventDefault();
									if (!actionDisabled) {
										if (running && canStop) {
											onStop();
										} else {
											onSend();
										}
									}
								}
							}}
							placeholder={t(planMode ? "agent.planPromptPlaceholder" : "agent.promptPlaceholder")}
							style={{
								display: "block",
								width: "100%",
								minHeight: "100%",
								padding: "12px 16px 48px 16px",
								border: "none",
								outline: "none",
								resize: "none",
								overflow: "hidden",
								backgroundColor: "transparent",
								color: Color.TextPrimary,
								font: "inherit",
								lineHeight: "1.7",
								boxSizing: "border-box",
							}}
						/>
					</MacScrollbar>
				</Box>
				{showActionButton ? (
					<Tooltip title={running ? t("menu.stop") : t("agent.send")}>
						<span style={{ position: "absolute", left: 16, bottom: 10, zIndex: 1 }}>
							<IconButton
								onClick={running ? (canStop ? onStop : undefined) : onSend}
								disabled={actionDisabled}
								sx={{
									backgroundColor: 'rgba(255, 255, 255, 0.04)',
									color: running ? Color.Theme : 'rgba(255, 255, 255, 0.55)',
									'&:hover': {
										backgroundColor: 'rgba(255, 255, 255, 0.08)',
									},
									"&.Mui-disabled": {
										backgroundColor: "transparent",
										color: Color.TextSecondary,
									},
								}}
							>
								{running ? <BsStopFill size={20} /> : <BsFillSendFill size={18} />}
							</IconButton>
						</span>
					</Tooltip>
				) : null}
				<Tooltip title={t("agent.modelForNextRun")}>
					<Select
						value={llmConfigId ?? ""}
						displayEmpty
						disabled={loading || llmConfigs.length === 0 || onLLMConfigChange === undefined}
						onChange={event => onLLMConfigChange?.(Number(event.target.value))}
						renderValue={() => selectedLLMConfigName}
						variant="standard"
						disableUnderline
						size="small"
						inputProps={{ "aria-label": t("agent.modelForNextRun") }}
						sx={{
							position: "absolute",
							right: 16,
							bottom: 11,
							zIndex: 1,
							maxWidth: "60%",
							minWidth: 120,
							fontSize: 12,
							color: Color.TextSecondary,
							"& .MuiSelect-select": { py: 0.25, pr: "22px !important", textAlign: "right" },
							"& .MuiSelect-icon": { color: Color.TextSecondary },
						}}
					>
						{llmConfigs.map(item => <MenuItem key={item.id} value={item.id}>{item.name}</MenuItem>)}
					</Select>
				</Tooltip>
			</Box>
		</Box>
	);
}

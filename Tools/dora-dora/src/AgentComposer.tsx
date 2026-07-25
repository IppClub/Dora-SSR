/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import IconButton from '@mui/material/IconButton';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import ChecklistIcon from '@mui/icons-material/Checklist';
import DownloadIcon from '@mui/icons-material/Download';
import TerminalIcon from '@mui/icons-material/Terminal';
import { useTranslation } from 'react-i18next';
import { BsFillSendFill, BsStopFill } from 'react-icons/bs';
import { Color } from './Theme';

const AGENT_USER_PROMPT_MAX_CHARS = 12000;
const CONTEXT_USAGE_LOW_COLOR = "rgba(255,255,255,0.42)";

interface AgentComposerProps {
	prompt: string;
	loading: boolean;
	running: boolean;
	stopping?: boolean;
	canStop?: boolean;
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
					width: 28,
					height: 28,
					borderRadius: "50%",
					background: `conic-gradient(${color} ${percent * 3.6}deg, ${trackColor} 0deg)`,
					display: "grid",
					placeItems: "center",
					cursor: "default",
				}}
			>
				<Box
					sx={{
						width: 22,
						height: 22,
						borderRadius: "50%",
						backgroundColor: Color.BackgroundDark,
						display: "grid",
						placeItems: "center",
						border: `1px solid ${Color.Line}`,
						color,
						fontSize: 8,
						fontWeight: 700,
						lineHeight: 1,
						userSelect: "none",
					}}
				>
					{percent}%
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
		stopping = false,
		canStop = true,
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
	const toolToggleDisabled = loading || running;
	const textAreaRef = React.useRef<HTMLTextAreaElement | null>(null);
	const isComposingRef = React.useRef(false);
	const [modelMenuOpen, setModelMenuOpen] = React.useState(false);
	const [modelTooltipOpen, setModelTooltipOpen] = React.useState(false);
	const [inputFocused, setInputFocused] = React.useState(false);
	const selectedLLMConfigName = llmConfigs.find(item => item.id === llmConfigId)?.name ?? t("agent.selectModel");

	React.useLayoutEffect(() => {
		const textarea = textAreaRef.current;
		if (textarea == null) return;
		textarea.style.height = "0px";
		const nextHeight = Math.max(64, Math.min(textarea.scrollHeight, 220));
		textarea.style.height = `${nextHeight}px`;
		textarea.style.overflowY = textarea.scrollHeight > 220 ? "auto" : "hidden";
	}, [prompt]);

	const toolButtonSx = (enabled: boolean) => ({
		height: 30,
		minWidth: 0,
		px: 1,
		borderRadius: 1.5,
		backgroundColor: enabled ? Color.ThemeMuted : "transparent",
		color: enabled ? Color.Theme : Color.TextSecondary,
		"&:hover": {
			backgroundColor: enabled ? `${Color.Theme}2a` : Color.SurfaceHover,
		},
		"&.Mui-disabled": {
			backgroundColor: enabled ? Color.ThemeMuted : "transparent",
			color: enabled ? `${Color.Theme}aa` : "rgba(255,255,255,0.3)",
			opacity: 1,
		},
	});

	return (
		<Box sx={{ px: 2, pt: 1, pb: 2, backgroundColor: Color.Background, flexShrink: 0 }}>
			<Box
				sx={{
					width: "100%",
					maxWidth: 980,
					mx: "auto",
					border: `1px solid ${inputFocused ? `${Color.Theme}88` : Color.Line}`,
					borderRadius: 3,
					backgroundColor: Color.BackgroundDark,
					overflow: "hidden",
					transition: "border-color 140ms ease",
				}}
			>
				<textarea
					ref={textAreaRef}
					value={prompt}
					maxLength={AGENT_USER_PROMPT_MAX_CHARS}
					disabled={disabledInput}
					onFocus={() => setInputFocused(true)}
					onBlur={() => setInputFocused(false)}
					onChange={event => onPromptChange(event.target.value.slice(0, AGENT_USER_PROMPT_MAX_CHARS))}
					onCompositionStart={() => {
						isComposingRef.current = true;
					}}
					onCompositionEnd={event => {
						isComposingRef.current = false;
						onPromptChange(event.currentTarget.value);
					}}
					onKeyDown={event => {
						if (isComposingRef.current || event.nativeEvent.isComposing) return;
						if (event.key === "Enter" && !event.shiftKey) {
							event.preventDefault();
							if (!actionDisabled) {
								if (running && canStop) onStop();
								else onSend();
							}
						}
					}}
					placeholder={t(planMode ? "agent.planPromptPlaceholder" : "agent.promptPlaceholder")}
					style={{
						display: "block",
						width: "100%",
						minHeight: 64,
						maxHeight: 220,
						padding: "14px 16px 8px",
						border: "none",
						outline: "none",
						resize: "none",
						overflow: "hidden",
						backgroundColor: "transparent",
						color: Color.TextPrimary,
						font: "inherit",
						lineHeight: "1.65",
						boxSizing: "border-box",
					}}
				/>
				<Stack direction="row" spacing={1} alignItems="center" justifyContent="space-between" sx={{ px: 1, pb: 1, minHeight: 38 }}>
					<Stack direction="row" spacing={0.25} alignItems="center" sx={{ minWidth: 0 }}>
						{onPlanModeChange ? (
							<Tooltip title={t("agent.planModeToggle")}>
								<span>
									<Button
										size="small"
										startIcon={<ChecklistIcon sx={{ fontSize: "16px !important" }} />}
										onClick={() => onPlanModeChange(!planMode)}
										disabled={toolToggleDisabled}
										aria-pressed={planMode}
										sx={toolButtonSx(planMode)}
									>
										{t(planMode ? "agent.planMode" : "agent.planModeInactive")}
									</Button>
								</span>
							</Tooltip>
						) : null}
						{onFetchUrlEnabledChange && !planMode ? (
							<Tooltip title={t("agent.networkToolsToggle")}>
								<span>
									<Button
										size="small"
										startIcon={<DownloadIcon sx={{ fontSize: "16px !important" }} />}
										onClick={() => onFetchUrlEnabledChange(!fetchUrlEnabled)}
										disabled={toolToggleDisabled}
										aria-pressed={fetchUrlEnabled}
										sx={toolButtonSx(fetchUrlEnabled)}
									>
										{t("agent.networkAccess")}
									</Button>
								</span>
							</Tooltip>
						) : null}
						{onExecuteCommandEnabledChange && !planMode ? (
							<Tooltip title={t("agent.executeCommandToggle")}>
								<span>
									<Button
										size="small"
										startIcon={<TerminalIcon sx={{ fontSize: "16px !important" }} />}
										onClick={() => onExecuteCommandEnabledChange(!executeCommandEnabled)}
										disabled={toolToggleDisabled}
										aria-pressed={executeCommandEnabled}
										sx={toolButtonSx(executeCommandEnabled)}
									>
										{t("agent.executeCommand")}
									</Button>
								</span>
							</Tooltip>
						) : null}
					</Stack>
					<Stack direction="row" spacing={1} alignItems="center" sx={{ flexShrink: 0 }}>
						<ContextUsageRing ratio={contextRatio} usedTokens={usedTokens} maxTokens={maxTokens} actualUsage={actualUsage} />
						<Tooltip
							title={t("agent.modelForNextRun")}
							disableFocusListener
							open={modelTooltipOpen && !modelMenuOpen}
							onOpen={() => {
								if (!modelMenuOpen) setModelTooltipOpen(true);
							}}
							onClose={() => setModelTooltipOpen(false)}
						>
							<Select
								value={llmConfigId ?? ""}
								displayEmpty
								disabled={llmConfigs.length === 0 || onLLMConfigChange === undefined}
								onOpen={() => {
									setModelTooltipOpen(false);
									setModelMenuOpen(true);
								}}
								onClose={() => setModelMenuOpen(false)}
								onChange={event => onLLMConfigChange?.(Number(event.target.value))}
								renderValue={() => selectedLLMConfigName}
								variant="standard"
								disableUnderline
								size="small"
								MenuProps={{
									PaperProps: {
										sx: {
											minWidth: 120,
											borderRadius: "6px",
											backgroundColor: Color.Background,
											backgroundImage: "none",
											border: `1px solid ${Color.Line}`,
										},
									},
								}}
								inputProps={{ "aria-label": t("agent.modelForNextRun") }}
								sx={{
									maxWidth: 180,
									minWidth: 96,
									fontSize: 12,
									color: Color.TextSecondary,
									"& .MuiSelect-select": { py: 0.25, pr: "22px !important" },
									"& .MuiSelect-icon": { color: Color.TextSecondary },
								}}
							>
								{llmConfigs.map(item => <MenuItem key={item.id} value={item.id}>{item.name}</MenuItem>)}
							</Select>
						</Tooltip>
						<Tooltip title={stopping ? t("agent.stopping") : running ? t("menu.stop") : t("agent.send")}>
							<span>
								<IconButton
									aria-label={stopping ? t("agent.stopping") : running ? t("menu.stop") : t("agent.send")}
									onClick={running ? (canStop ? onStop : undefined) : onSend}
									disabled={actionDisabled}
									sx={{
										width: 32,
										height: 32,
										borderRadius: 1.75,
										backgroundColor: running ? `${Color.Warning}20` : Color.Theme,
										color: running ? Color.Warning : Color.BackgroundDark,
										"&:hover": {
											backgroundColor: running ? `${Color.Warning}32` : "#ffd15f",
										},
										"&.Mui-disabled": {
											backgroundColor: stopping ? `${Color.Theme}14` : Color.DisabledBackground,
											color: stopping ? Color.Theme : Color.DisabledText,
										},
									}}
								>
									{stopping
										? <CircularProgress color="inherit" size={18} thickness={5} />
										: running
											? <BsStopFill size={18} />
											: <BsFillSendFill size={16} />}
								</IconButton>
							</span>
						</Tooltip>
					</Stack>
				</Stack>
			</Box>
		</Box>
	);
}

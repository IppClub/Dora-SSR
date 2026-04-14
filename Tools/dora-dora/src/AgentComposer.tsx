import React from 'react';
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import { BsFillSendFill, BsStopFill } from 'react-icons/bs';
import { Color } from './Theme';

const AGENT_USER_PROMPT_MAX_CHARS = 12000;

interface AgentComposerProps {
	prompt: string;
	loading: boolean;
	running: boolean;
	tabButtons?: React.ReactNode;
	onPromptChange: (value: string) => void;
	onSend: () => void;
	onStop: () => void;
}

export default function AgentComposer(props: AgentComposerProps) {
	const { t } = useTranslation();
	const { prompt, loading, running, tabButtons, onPromptChange, onSend, onStop } = props;
	const disabledInput = loading || running;
	const actionDisabled = running ? false : loading || prompt.trim() === "";
	const showActionButton = running || prompt.trim() !== "";
	const textAreaRef = React.useRef<HTMLTextAreaElement | null>(null);
	const scrollRef = React.useRef<HTMLElement | null>(null);
	const isComposingRef = React.useRef(false);

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

	return (
		<Box sx={{ px: 2, pt: 0, pb: 2, backgroundColor: Color.Background, position: "relative", flexShrink: 0, overflow: "visible" }}>
			{tabButtons ? (
				<Stack
					direction="row"
					spacing={0.75}
					useFlexGap
					sx={{
						position: "absolute",
						top: -36,
						right: 24,
						zIndex: 3,
						maxWidth: "calc(100% - 32px)",
						flexWrap: "wrap",
						justifyContent: "flex-end",
						pointerEvents: "auto",
					}}
				>
					{tabButtons}
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
									if (running) {
										onStop();
									} else {
										onSend();
									}
								}
							}
						}}
						placeholder={t("agent.promptPlaceholder")}
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
							onClick={running ? onStop : onSend}
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
			</Box>
		</Box>
	);
}

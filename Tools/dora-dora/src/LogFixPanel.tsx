import { useEffect, useRef, useState } from 'react';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import CloseIcon from '@mui/icons-material/Close';
import SendIcon from '@mui/icons-material/Send';
import { Box, IconButton, Tooltip } from '@mui/material';
import { useTranslation } from 'react-i18next';
import { MacScrollbar } from 'mac-scrollbar';
import { Color } from './Theme';

interface LogFixPanelProps {
	defaultPrompt: string;
	onClose: () => void;
	onSend: (prompt: string) => void;
}

export default function LogFixPanel(props: LogFixPanelProps) {
	const { t } = useTranslation();
	const textareaRef = useRef<HTMLTextAreaElement | null>(null);
	const isComposingRef = useRef(false);
	const [prompt, setPrompt] = useState(props.defaultPrompt);

	useEffect(() => {
		setPrompt(props.defaultPrompt);
	}, [props.defaultPrompt]);

	useEffect(() => {
		textareaRef.current?.focus();
	}, []);

	useEffect(() => {
		const textarea = textareaRef.current;
		if (textarea == null) return;
		textarea.style.height = "0px";
		textarea.style.height = `${Math.max(textarea.scrollHeight, 116)}px`;
	}, [prompt]);

	const normalizedPrompt = prompt.trim();

	const sendPrompt = () => {
		if (normalizedPrompt === "") return;
		props.onSend(normalizedPrompt);
	};

	return (
		<Box
			data-log-fix-panel
			sx={{
				width: 340,
				maxWidth: "min(340px, calc(100vw - 32px))",
				p: 1,
				borderRadius: 1.5,
				border: `1px solid ${Color.Theme}66`,
				backgroundColor: "rgba(24, 24, 24, 0.98)",
				boxShadow: "0 12px 30px rgba(0, 0, 0, 0.42)",
			}}
		>
			<Box sx={{ display: "flex", alignItems: "flex-start", gap: 1 }}>
				<AutoAwesomeIcon sx={{ color: Color.Theme, fontSize: 18, mt: 1 }} />
				<Box
					sx={{
						flex: 1,
						minWidth: 0,
						height: 116,
						border: `1px solid ${Color.Line}`,
						borderRadius: 1,
						backgroundColor: Color.BackgroundDark,
						overflow: "hidden",
					}}
				>
					<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
						<textarea
							ref={textareaRef}
							value={prompt}
							onChange={event => setPrompt(event.target.value)}
							onCompositionStart={() => {
								isComposingRef.current = true;
							}}
							onCompositionEnd={() => {
								isComposingRef.current = false;
							}}
							onKeyDown={event => {
								if (isComposingRef.current || event.nativeEvent.isComposing) {
									return;
								}
								if (event.key === "Escape") {
									event.preventDefault();
									props.onClose();
									return;
								}
								if (event.key === "Enter" && !event.shiftKey) {
									event.preventDefault();
									sendPrompt();
								}
							}}
							style={{
								display: "block",
								width: "100%",
								padding: "8px 10px",
								border: "none",
								outline: "none",
								resize: "none",
								overflow: "hidden",
								backgroundColor: "transparent",
								color: Color.TextPrimary,
								fontFamily: "Roboto,Helvetica,Arial,sans-serif",
								fontSize: 13,
								lineHeight: 1.45,
								boxSizing: "border-box",
							}}
						/>
					</MacScrollbar>
				</Box>
				<Box sx={{ height: 116, display: "flex", flexDirection: "column", justifyContent: "space-between", alignItems: "center" }}>
					<Tooltip title={t("action.close")}>
						<IconButton
							size="small"
							onClick={props.onClose}
							sx={{
								color: Color.TextSecondary,
								"&:hover": {
									color: Color.TextPrimary,
									backgroundColor: Color.Line,
								},
							}}
						>
							<CloseIcon fontSize="small" />
						</IconButton>
					</Tooltip>
					<Tooltip title={t("log.fixSend")}>
						<IconButton
							size="small"
							disabled={normalizedPrompt === ""}
							onClick={sendPrompt}
							sx={{
								color: Color.Theme,
								border: `1px solid ${Color.Theme}55`,
								backgroundColor: "rgba(34, 28, 14, 0.88)",
								"&:hover": {
									color: "#ffd66a",
									borderColor: Color.Theme,
									backgroundColor: "rgba(65, 48, 18, 0.96)",
								},
								"&.Mui-disabled": {
									color: Color.TextSecondary,
									borderColor: Color.Line,
								},
							}}
						>
							<SendIcon fontSize="small" />
						</IconButton>
					</Tooltip>
				</Box>
			</Box>
		</Box>
	);
}

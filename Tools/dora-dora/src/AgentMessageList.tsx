import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import CloseIcon from '@mui/icons-material/Close';
import EditIcon from '@mui/icons-material/Edit';
import SendIcon from '@mui/icons-material/Send';
import { useTranslation } from 'react-i18next';
import { MacScrollbar } from 'mac-scrollbar';
import type { AgentSessionMessage } from './Service';
import { Color } from './Theme';
import './github-markdown-dark.css';

const Markdown = React.lazy(() => import('./Markdown'));

interface AgentMessageListProps {
	messages: AgentSessionMessage[];
	editableMessageId?: number;
	editDisabled?: boolean;
	onResendPrompt?: (message: AgentSessionMessage, prompt: string) => Promise<boolean | undefined>;
}

export default function AgentMessageList(props: AgentMessageListProps) {
	const { t } = useTranslation();
	const { messages } = props;
	const textareaRef = React.useRef<HTMLTextAreaElement | null>(null);
	const isComposingRef = React.useRef(false);
	const [editingMessageId, setEditingMessageId] = React.useState<number | null>(null);
	const [editingPrompt, setEditingPrompt] = React.useState("");
	const [sending, setSending] = React.useState(false);

	const startEdit = (message: AgentSessionMessage) => {
		setEditingMessageId(message.id);
		setEditingPrompt(message.content);
	};

	const cancelEdit = () => {
		isComposingRef.current = false;
		setEditingMessageId(null);
		setEditingPrompt("");
	};

	const sendEdit = async (message: AgentSessionMessage) => {
		const prompt = editingPrompt.trim();
		if (prompt === "" || sending) return;
		setSending(true);
		try {
			const success = await props.onResendPrompt?.(message, prompt);
			if (success) {
				cancelEdit();
			}
		} finally {
			setSending(false);
		}
	};

	const handleEditKeyDown = (event: React.KeyboardEvent<HTMLTextAreaElement>, message: AgentSessionMessage) => {
		if (isComposingRef.current || event.nativeEvent.isComposing) {
			return;
		}
		if (event.key === "Escape") {
			event.preventDefault();
			cancelEdit();
			return;
		}
		if (event.key === "Enter" && !event.shiftKey) {
			event.preventDefault();
			void sendEdit(message);
		}
	};

	React.useEffect(() => {
		const textarea = textareaRef.current;
		if (textarea == null) return;
		textarea.style.height = "0px";
		textarea.style.height = `${Math.max(textarea.scrollHeight, 78)}px`;
	}, [editingPrompt, editingMessageId]);

	return (
		<Stack spacing={2}>
			{messages.map(message => {
				const editable = message.role === "user" && message.displayContent === undefined && message.id === props.editableMessageId && !props.editDisabled && props.onResendPrompt !== undefined;
				const editing = editingMessageId === message.id;
				const visibleContent = message.displayContent ?? message.content;
				return (
					<Box key={message.id} sx={{
						display: "flex",
						justifyContent: message.role === "user" ? "flex-end" : "flex-start",
						minWidth: 0,
					}}>
						<Box sx={{
							position: "relative",
							maxWidth: message.role === "user" ? "78%" : "100%",
							width: message.role === "user" ? "auto" : "100%",
							minWidth: 0,
							pb: editable && !editing ? 2.25 : 0,
							border: message.role === "user" ? "none" : undefined,
							"&:hover .agent-message-edit-button": {
								opacity: 1,
								pointerEvents: "auto",
							},
						}}>
							<Box sx={{
								borderRadius: message.role === "user" ? 3 : 0,
								px: message.role === "user" ? 2 : 0,
								py: message.role === "user" ? 1.5 : 0,
								backgroundColor: message.role === "user" ? "rgba(255,255,255,0.06)" : "transparent",
								boxShadow: message.role === "user" ? "inset 0 1px 0 rgba(255,255,255,0.02)" : "none",
							}}>
								{message.role === "assistant" ? (
									<Box
										sx={{
											p: 0,
											width: '100%',
											maxWidth: '100%',
											minWidth: 0,
											minHeight: 0,
											backgroundColor: "transparent",
											color: Color.TextPrimary,
											fontSize: 16,
											lineHeight: 1.75,
											'& .markdown-body p': { whiteSpace: 'pre-wrap' },
											'& .markdown-body > :first-of-type': { marginTop: 0 },
											'& .markdown-body > :last-child': { marginBottom: 0 },
										}}
									>
										<React.Suspense fallback={null}>
											<Markdown content={message.content} contentPadding={0} />
										</React.Suspense>
									</Box>
								) : editing ? (
									<Box sx={{
										width: "min(620px, 70vw)",
										minWidth: "min(360px, 70vw)",
									}}>
										<Box sx={{ maxHeight: 180, overflow: "hidden" }}>
											<MacScrollbar skin="dark" style={{ width: "100%", maxHeight: 180 }}>
												<textarea
													ref={textareaRef}
													value={editingPrompt}
													onChange={event => setEditingPrompt(event.target.value)}
													onCompositionStart={() => {
														isComposingRef.current = true;
													}}
													onCompositionEnd={() => {
														isComposingRef.current = false;
													}}
													onKeyDown={event => handleEditKeyDown(event, message)}
													autoFocus
													style={{
														display: "block",
														width: "100%",
														border: "none",
														outline: "none",
														resize: "none",
														overflow: "hidden",
														backgroundColor: "transparent",
														color: Color.TextPrimary,
														font: "inherit",
														lineHeight: 1.6,
														boxSizing: "border-box",
													}}
												/>
											</MacScrollbar>
										</Box>
										<Stack direction="row" spacing={1} justifyContent="flex-end" sx={{ mt: 0.75 }}>
											<Button
												size="small"
												variant="outlined"
												startIcon={<CloseIcon fontSize="small" />}
												onClick={cancelEdit}
												disabled={sending}
												sx={{
													color: Color.TextSecondary,
													borderColor: Color.Line,
													borderRadius: 999,
													minWidth: 72,
													height: 34,
													px: 1.5,
													"&:hover": {
														borderColor: Color.TextSecondary,
														backgroundColor: "rgba(255,255,255,0.04)",
													},
												}}
											>
												{t("action.cancel")}
											</Button>
											<Button
												size="small"
												variant="contained"
												startIcon={<SendIcon fontSize="small" />}
												onClick={() => void sendEdit(message)}
												disabled={sending || editingPrompt.trim() === ""}
												sx={{
													color: Color.BackgroundDark,
													backgroundColor: Color.TextPrimary,
													borderRadius: 999,
													minWidth: 82,
													height: 34,
													px: 1.75,
													boxShadow: "0 2px 8px rgba(0,0,0,0.24)",
													"&:hover": {
														backgroundColor: "#fff",
														boxShadow: "0 3px 10px rgba(0,0,0,0.28)",
													},
												}}
											>
												{t("agent.send")}
											</Button>
										</Stack>
									</Box>
								) : (
									<Typography variant="body1" sx={{ color: Color.TextPrimary, whiteSpace: "pre-wrap", lineHeight: 1.6 }}>
										{visibleContent}
									</Typography>
								)}
							</Box>
							{editable && !editing ? (
								<Tooltip title={t("agent.editPrompt")}>
									<IconButton
										size="small"
										className="agent-message-edit-button"
										onClick={() => startEdit(message)}
										sx={{
											position: "absolute",
											right: 4,
											bottom: -10,
											width: 24,
											height: 24,
											opacity: 0,
											pointerEvents: "none",
											color: "rgba(238,238,238,0.68)",
											backgroundColor: "transparent",
											transition: "opacity 120ms ease, color 120ms ease",
											"& .MuiSvgIcon-root": {
												fontSize: 18,
											},
											"&:hover": {
												color: "rgba(238,238,238,0.92)",
												backgroundColor: "transparent",
											},
										}}
									>
										<EditIcon fontSize="small" />
									</IconButton>
								</Tooltip>
							) : null}
						</Box>
					</Box>
				);
			})}
		</Stack>
	);
}

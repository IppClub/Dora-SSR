import React from 'react';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import type { AgentSessionMessage } from './Service';
import { Color } from './Theme';
import './github-markdown-dark.css';

interface AgentMessageListProps {
	messages: AgentSessionMessage[];
}

export default function AgentMessageList(props: AgentMessageListProps) {
	const { messages } = props;
	return (
		<Stack spacing={2}>
			{messages.map(message => (
				<Box key={message.id} sx={{
					display: "flex",
					justifyContent: message.role === "user" ? "flex-end" : "flex-start",
				}}>
					<Box sx={{
						maxWidth: message.role === "user" ? "78%" : "100%",
						border: message.role === "user" ? "none" : undefined,
						borderRadius: message.role === "user" ? 3 : 0,
						px: message.role === "user" ? 2 : 0,
						py: message.role === "user" ? 1.5 : 0,
						backgroundColor: message.role === "user" ? "rgba(255,255,255,0.06)" : "transparent",
						boxShadow: message.role === "user" ? "inset 0 1px 0 rgba(255,255,255,0.02)" : "none",
					}}>
						{message.role === "assistant" ? (
						<Box
							className="markdown-body"
							sx={{
								p: 0,
								width: 'auto',
								minHeight: 0,
								backgroundColor: "transparent",
								color: Color.TextPrimary,
								fontSize: 16,
								lineHeight: 1.75,
								'& p': { whiteSpace: 'pre-wrap' },
								'& > :first-of-type': { marginTop: 0 },
								'& > :last-child': { marginBottom: 0 },
							}}
						>
							<ReactMarkdown remarkPlugins={[remarkGfm]}>
								{message.content}
							</ReactMarkdown>
						</Box>
					) : (
						<Typography variant="body1" sx={{ color: Color.TextPrimary, whiteSpace: "pre-wrap", lineHeight: 1.6 }}>
							{message.content}
						</Typography>
					)}
					</Box>
				</Box>
			))}
		</Stack>
	);
}

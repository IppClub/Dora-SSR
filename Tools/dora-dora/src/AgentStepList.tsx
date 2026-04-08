import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Collapse from '@mui/material/Collapse';
import CircularProgress from '@mui/material/CircularProgress';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useTranslation } from 'react-i18next';
import type { AgentCheckpointDiffFile, AgentCheckpointItem, AgentSessionStep } from './Service';
import { Color } from './Theme';
import AgentFileDiff from './AgentFileDiff';
import Markdown from './Markdown';
import './github-markdown-dark.css';

interface AgentStepListProps {
	steps: AgentSessionStep[];
	checkpointMap: Map<number, AgentCheckpointItem>;
	diffs: Record<number, AgentCheckpointDiffFile[]>;
	diffLoadingId: number | null;
	openedDiffId: number | null;
	running: boolean;
	rollingBack: number | null;
	onToggleDiff: (step: AgentSessionStep) => void;
	onRollback: (step: AgentSessionStep) => void;
	onOpenFile?: (filePath: string) => void;
}

type ParamItem = {
	label: string;
	value?: string;
};

const stepActionButtonSx = {
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
} as const;

function formatLineLabel(
	line: number,
	t: (key: string, options?: Record<string, unknown>) => string
): string {
	return line < 0
		? t("agent.lineFromEnd", { count: Math.abs(line) })
		: String(line);
}

function formatLineRange(
	startLine: number,
	endLine: number,
	t: (key: string, options?: Record<string, unknown>) => string
): string {
	return `${formatLineLabel(startLine, t)} - ${formatLineLabel(endLine, t)}`;
}

function summarizeToolParams(step: AgentSessionStep, t: (key: string, options?: Record<string, unknown>) => string): ParamItem[] {
	const params = step.params ?? {};
	const items: ParamItem[] = [];
	const push = (label: string, value?: string) => {
		if (value === undefined || value === "") return;
		items.push({ label, value });
	};
	const pushFlag = (label: string, enabled: boolean) => {
		if (!enabled) return;
		items.push({ label });
	};
	switch (step.tool) {
		case "read_file": {
			const path = typeof params.path === "string" ? params.path : "";
			const startLine = typeof params.startLine === "number" ? params.startLine : 1;
			const endLine = typeof params.endLine === "number"
				? params.endLine
				: (startLine < 0 ? -1 : 300);
			push(t("agent.paramLabels.file"), path);
			push(t("agent.paramLabels.lines"), formatLineRange(startLine, endLine, t));
			return items;
		}
		case "glob_files": {
			let path = typeof params.path === "string" ? params.path : ".";
			if (path === ".") {
				path = t("agent.workspace");
			}
			const globs = Array.isArray(params.globs)
				? (params.globs as unknown[]).filter(item => typeof item === "string").join(", ")
				: "";
			push(t("agent.paramLabels.basePath"), path);
			push(t("agent.paramLabels.fileFilter"), globs);
			return items;
		}
		case "grep_files": {
			let path = typeof params.path === "string" ? params.path : ".";
			if (path === ".") {
				path = t("agent.workspace");
			}
			const pattern = typeof params.pattern === "string" ? params.pattern : "";
			const useRegex = params.useRegex === true;
			const caseSensitive = params.caseSensitive === true;
			const limit = typeof params.limit === "number" ? params.limit : undefined;
			const offset = typeof params.offset === "number" ? params.offset : undefined;
			const groupByFile = params.groupByFile === true;
			const globs = Array.isArray(params.globs)
				? (params.globs as unknown[]).filter(item => typeof item === "string").join(", ")
				: "";
			push(t("agent.paramLabels.basePath"), path);
			push(t("agent.paramLabels.contentPattern"), pattern);
			push(t("agent.paramLabels.fileFilter"), globs);
			pushFlag(t("agent.regex"), useRegex);
			pushFlag(t("agent.caseSensitive"), caseSensitive);
			pushFlag(t("agent.groupByFile"), groupByFile);
			if (limit !== undefined) push(t("agent.paramLabels.limit"), String(limit));
			if (offset !== undefined && offset > 0) push(t("agent.paramLabels.offset"), String(offset));
			return items;
		}
		case "search_dora_api": {
			const pattern = typeof params.pattern === "string" ? params.pattern : "";
			const docSource = typeof params.docSource === "string" ? params.docSource : "api";
			const programmingLanguage = typeof params.programmingLanguage === "string"
				? params.programmingLanguage
				: "";
			const limit = typeof params.limit === "number"
				? params.limit
				: (typeof params.topK === "number" ? params.topK : undefined);
			const useRegex = params.useRegex === true;
			const caseSensitive = params.caseSensitive === true;
			push(t("agent.paramLabels.pattern"), pattern);
			push(t("agent.paramLabels.docType"), t(`agent.docSources.${docSource}`, { defaultValue: docSource }));
			push(t("agent.paramLabels.language"), programmingLanguage);
			if (limit !== undefined) push(t("agent.paramLabels.limit"), String(limit));
			pushFlag(t("agent.regex"), useRegex);
			pushFlag(t("agent.caseSensitive"), caseSensitive);
			return items;
		}
		case "build": {
			const path = typeof params.path === "string" ? params.path : "";
			push(t("agent.paramLabels.buildTarget"), path !== "" ? path : t("agent.workspace"));
			return items;
		}
		case "compress_memory": {
			const round = typeof params.round === "number" ? params.round : undefined;
			const pendingMessages = typeof params.pendingMessages === "number" ? params.pendingMessages : undefined;
			if (round !== undefined) push(t("agent.paramLabels.round"), String(round));
			if (pendingMessages !== undefined) push(t("agent.paramLabels.messages"), String(pendingMessages));
			return items;
		}
		default:
			return items;
	}
}

function getBuildItems(step: AgentSessionStep): { file: string; message: string; success: boolean }[] {
	const result = step.result;
	if (!result || typeof result !== "object" || !Array.isArray((result as { messages?: unknown[] }).messages)) {
		return [];
	}
	return ((result as { messages: Array<Record<string, unknown>> }).messages ?? [])
		.filter(message => message && typeof message.file === "string")
		.map(message => ({
			file: message.file as string,
			message: typeof message.message === "string" ? message.message as string : "",
			success: message.success === true,
		}));
}

export default function AgentStepList(props: AgentStepListProps) {
	const { t } = useTranslation();
	const [openedBuildErrors, setOpenedBuildErrors] = React.useState<Record<number, boolean>>({});
	const {
		steps,
		checkpointMap,
		diffs,
		diffLoadingId,
		openedDiffId,
		running,
		rollingBack,
		onToggleDiff,
		onRollback,
		onOpenFile,
	} = props;
	return (
		<Stack spacing={2}>
			{steps.map(step => {
				const paramItems = summarizeToolParams(step, t);
				const canViewDiff = step.tool !== "delete_file";
				const buildItems = step.tool === "build" ? getBuildItems(step) : [];
				const showBuildResults = buildItems.length > 0;
				const buildErrorsOpened = openedBuildErrors[step.id] === true;
				const hasReasoning = step.reasoningContent.trim() !== "";
				const primaryContent = step.reason || (hasReasoning ? step.reasoningContent : "");
				const historyEntryPreview = step.tool === "compress_memory" && typeof step.result?.historyEntryPreview === "string"
					? step.result.historyEntryPreview
					: "";
				const isCompressionStep = step.tool === "compress_memory";
				return (
				<Box key={step.id} sx={{
					borderLeft: `2px solid ${isCompressionStep ? "rgba(255,196,110,0.32)" : Color.Line}`,
					pl: 1.5,
					py: 0.25,
				}}>
					<Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap" useFlexGap>
						<Typography variant="caption" sx={{ color: Color.TextSecondary }}>
							{step.step}
						</Typography>
						<Chip
							size="small"
							label={t(`agent.toolNames.${step.tool}`, { defaultValue: step.tool })}
							variant="outlined"
							sx={{
								borderColor: isCompressionStep ? "rgba(255,196,110,0.32)" : Color.Line,
								color: isCompressionStep ? "rgb(255,214,153)" : Color.TextPrimary,
							}}
						/>
						{step.status !== "DONE" ? (
							<Chip size="small" label={step.status} variant="outlined" sx={{ borderColor: Color.Line, color: Color.TextSecondary }} />
						) : null}
					</Stack>
					{primaryContent !== "" ? (
						<Box
							sx={{
								mt: 1,
								padding: 0,
								width: 'auto',
								minHeight: 0,
								backgroundColor: "transparent",
								color: Color.TextPrimary,
								fontSize: 16,
								lineHeight: 1.65,
								'& .markdown-body p': { whiteSpace: 'pre-wrap' },
								'& .markdown-body > :first-of-type': { marginTop: 0 },
								'& .markdown-body > :last-child': { marginBottom: 0 },
							}}
						>
							<Markdown content={primaryContent} contentPadding={0} />
						</Box>
					) : null}
					{historyEntryPreview !== "" ? (
						<Typography variant="body2" sx={{ color: Color.TextSecondary, whiteSpace: "pre-wrap", lineHeight: 1.6, mt: 0.75 }}>
							{historyEntryPreview}
						</Typography>
					) : null}
					{paramItems.length > 0 ? (
						<Typography variant="caption" sx={{ color: Color.TextSecondary, display: "block", mt: step.reason ? 0.75 : 1, lineHeight: 1.6 }}>
							{paramItems.map((item, index) => (
								<React.Fragment key={`${item.label}:${item.value ?? ""}:${index}`}>
									{index > 0 ? " · " : null}
									{item.value !== undefined ? `${item.label}: ${item.value}` : item.label}
								</React.Fragment>
							))}
						</Typography>
					) : null}
					{showBuildResults ? (
						<Box sx={{ mt: 1.25 }}>
							<Button
								size="small"
								variant="text"
								onClick={() => setOpenedBuildErrors(prev => ({ ...prev, [step.id]: !buildErrorsOpened }))}
								sx={{
									px: 0,
									minWidth: 0,
									color: Color.TextSecondary,
									textTransform: "none",
									"&:hover": {
										backgroundColor: "transparent",
										color: Color.TextPrimary,
									},
								}}
							>
								{buildErrorsOpened
									? t("agent.hideBuildResults", { count: buildItems.length })
									: t("agent.showBuildResults", { count: buildItems.length })}
							</Button>
							<Collapse in={buildErrorsOpened} timeout="auto" unmountOnExit>
								<Stack spacing={1} sx={{ mt: 1 }}>
									{buildItems.map((item, index) => (
										<Box
											key={`${item.file}:${index}`}
											sx={{
												border: `0.5px solid ${Color.Line}`,
												borderRadius: 2,
												px: 1.25,
												py: 1,
												backgroundColor: "rgba(255,255,255,0.02)",
											}}
										>
											<Stack direction="row" spacing={1} alignItems="center" sx={{ mb: item.message !== "" ? 0.5 : 0 }}>
												<Chip
													size="small"
													label={item.success ? t("agent.buildItemStatus.success") : t("agent.buildItemStatus.failed")}
													variant="outlined"
													sx={{
														height: 22,
														borderColor: item.success ? "rgba(120,200,140,0.35)" : Color.Line,
														color: item.success ? "rgb(140,220,160)" : Color.TextSecondary,
													}}
												/>
												<Typography variant="caption" sx={{ color: Color.TextSecondary, display: "block" }}>
													{item.file}
												</Typography>
											</Stack>
											{item.message !== "" ? (
												<Typography variant="body2" sx={{ color: Color.TextPrimary, whiteSpace: "pre-wrap", lineHeight: 1.6 }}>
													{item.message}
												</Typography>
											) : null}
										</Box>
									))}
								</Stack>
							</Collapse>
						</Box>
					) : null}
					{step.checkpointSeq ? (
						<Box sx={{ mt: 1.25 }}>
							<Typography variant="caption" sx={{ color: Color.TextSecondary, display: "block", mb: 1 }}>
								{t("agent.checkpointLabel", { seq: step.checkpointSeq })}{" "}
								{step.files?.map((file, index) => (
									<React.Fragment key={`${file.path}:${index}`}>
										{index > 0 ? ", " : null}
										{onOpenFile ? (
											<Box
												component="button"
												type="button"
												onClick={() => onOpenFile(file.path)}
												sx={{
													display: "inline",
													p: 0,
													m: 0,
													border: "none",
													background: "none",
													color: Color.TextSecondary,
													cursor: "pointer",
													font: "inherit",
													textDecoration: "underline",
													textUnderlineOffset: "2px",
													"&:hover": {
														color: Color.TextPrimary,
													},
												}}
											>
												{file.path}
											</Box>
										) : file.path}
									</React.Fragment>
								))}
							</Typography>
							<Stack direction="row" spacing={1} alignItems="center">
								{canViewDiff ? (
									<Button
										size="small"
										variant="outlined"
										onClick={() => onToggleDiff(step)}
										disabled={diffLoadingId === step.checkpointId}
										sx={stepActionButtonSx}
									>
										{openedDiffId === step.checkpointId ? t("agent.hideDiff") : t("agent.viewDiff")}
									</Button>
								) : null}
								<Button
									size="small"
									variant="outlined"
									color="warning"
									onClick={() => onRollback(step)}
									disabled={running || rollingBack === step.checkpointSeq}
									sx={stepActionButtonSx}
								>
									{t("agent.rollback")}
								</Button>
								{checkpointMap.get(step.checkpointSeq)?.status ? (
									<Chip
										size="small"
										label={t(`agent.checkpointStatus.${checkpointMap.get(step.checkpointSeq)?.status?.toLowerCase()}`)}
										variant="outlined"
									/>
								) : null}
								{canViewDiff && diffLoadingId === step.checkpointId ? <CircularProgress size={16} /> : null}
							</Stack>
							{canViewDiff && openedDiffId === step.checkpointId ? (
								<Box sx={{ mt: 1.25 }}>
									<Stack spacing={1}>
										{(diffs[step.checkpointId!] ?? []).map(file => (
											<AgentFileDiff key={`${file.path}:${file.op}`} file={file} />
										))}
									</Stack>
								</Box>
							) : null}
						</Box>
					) : null}
				</Box>
			)})}
		</Stack>
	);
}

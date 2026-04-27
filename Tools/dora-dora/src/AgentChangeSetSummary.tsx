import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import Collapse from '@mui/material/Collapse';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useTranslation } from 'react-i18next';
import type { AgentChangeSetSummary, AgentCheckpointDiffFile } from './Service';
import AgentFileDiff from './AgentFileDiff';
import { Color } from './Theme';

interface AgentChangeSetSummaryProps {
	changeSet: AgentChangeSetSummary;
	diffs: AgentCheckpointDiffFile[];
	diffOpen: boolean;
	diffLoading: boolean;
	rollbackLoading: boolean;
	running: boolean;
	rollbackLabel: string;
	onToggleDiff: () => void;
	onRollback: () => void;
	onOpenFile?: (filePath: string) => void;
}

const actionButtonSx = {
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

function normalizeList<T>(value: unknown): T[] {
	if (Array.isArray(value)) return value as T[];
	if (value && typeof value === "object") {
		return Object.keys(value as Record<string, T>)
			.sort((a, b) => Number(a) - Number(b))
			.map(key => (value as Record<string, T>)[key]);
	}
	return [];
}

export default function AgentChangeSetSummaryCard(props: AgentChangeSetSummaryProps) {
	const { t } = useTranslation();
	const {
		changeSet,
		diffs,
		diffOpen,
		diffLoading,
		rollbackLoading,
		running,
		rollbackLabel,
		onToggleDiff,
		onRollback,
		onOpenFile,
	} = props;
	const files = normalizeList<typeof changeSet.files[number]>(changeSet.files);
	const diffFiles = normalizeList<AgentCheckpointDiffFile>(diffs);
	return (
		<Box sx={{
			mt: 1.25,
			border: `0.5px solid ${Color.Line}`,
			borderRadius: 2,
			px: 1.25,
			py: 1,
			backgroundColor: "rgba(255,255,255,0.02)",
		}}>
			<Stack spacing={1}>
				<Stack direction="row" spacing={1} alignItems="center" useFlexGap flexWrap="wrap">
					<Chip
						size="small"
						label={t("agent.changeSet")}
						variant="outlined"
						sx={{ height: 22, borderColor: "rgba(120,170,255,0.35)", color: "rgb(140,188,255)" }}
					/>
					<Typography variant="body2" sx={{ color: Color.TextPrimary }}>
						{t("agent.filesChanged", { count: changeSet.filesChanged })}
					</Typography>
					<Typography variant="caption" sx={{ color: Color.TextSecondary }}>
						{t("agent.checkpointsChanged", { count: changeSet.checkpointCount })}
					</Typography>
				</Stack>
				{files.length > 0 ? (
					<Typography variant="caption" sx={{ color: Color.TextSecondary, display: "block", lineHeight: 1.6 }}>
						{files.map((file, index) => (
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
				) : null}
				<Stack direction="row" spacing={1} alignItems="center">
					<Button
						size="small"
						variant="outlined"
						onClick={onToggleDiff}
						disabled={diffLoading}
						sx={actionButtonSx}
					>
						{diffOpen ? t("agent.hideDiff") : t("agent.viewDiff")}
					</Button>
					<Button
						size="small"
						variant="outlined"
						color="warning"
						onClick={onRollback}
						disabled={running || rollbackLoading}
						sx={actionButtonSx}
					>
						{rollbackLabel}
					</Button>
					{diffLoading ? <CircularProgress size={16} /> : null}
				</Stack>
				<Collapse in={diffOpen} timeout="auto" unmountOnExit>
					<Stack spacing={1} sx={{ mt: 0.25 }}>
						{diffFiles.map(file => (
							<AgentFileDiff key={`${file.path}:${file.op}`} file={file} />
						))}
					</Stack>
				</Collapse>
			</Stack>
		</Box>
	);
}

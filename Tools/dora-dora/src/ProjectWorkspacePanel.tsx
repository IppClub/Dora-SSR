import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import AgentPanel from './AgentPanel';
import DoraUpload from './Upload';
import { Color } from './Theme';

type WorkspaceView = "agent" | "upload";

interface ProjectWorkspacePanelProps {
	title: string;
	height: number;
	uploadPath: string;
	displayPath?: string;
	agentSessionId?: number;
	view?: WorkspaceView;
	addAlert?: (msg: string, type: "success" | "info" | "warning" | "error") => void;
	onRollbackComplete?: (projectRoot: string) => void;
	onUploaded: (path: string, file: string, open: boolean) => void;
	onViewChange?: (view: WorkspaceView) => void;
	onOpenFile?: (filePath: string) => void;
	onOpenLLMConfig?: () => void;
}

export default function ProjectWorkspacePanel(props: ProjectWorkspacePanelProps) {
	const { t } = useTranslation();
	const {
		title,
		height,
		uploadPath,
		displayPath,
		agentSessionId,
		view,
		addAlert,
		onRollbackComplete,
		onUploaded,
		onViewChange,
		onOpenFile,
		onOpenLLMConfig,
	} = props;
	const hasAgent = agentSessionId !== undefined;
	const [internalView, setInternalView] = React.useState<WorkspaceView>(() => {
		if (view) return view;
		return hasAgent ? "agent" : "upload";
	});

	const currentView = view ?? internalView;

	React.useEffect(() => {
		if (view) {
			setInternalView(view);
			return;
		}
		setInternalView(hasAgent ? "agent" : "upload");
	}, [view, hasAgent, agentSessionId, uploadPath]);

	const contentHeight = Math.max(height - 78, 0);
	const handleViewChange = (nextView: WorkspaceView) => {
		setInternalView(nextView);
		onViewChange?.(nextView);
	};

	return (
		<Box sx={{ display: "flex", flexDirection: "column", height }}>
			<Box sx={{ px: 3, py: 2, borderBottom: `0.5px solid ${Color.Line}`, background: `linear-gradient(180deg, ${Color.BackgroundDark} 0%, ${Color.Background} 100%)` }}>
				<Stack direction="row" spacing={1.5} alignItems="center" justifyContent="space-between">
					<Box sx={{ minWidth: 0 }}>
						<Typography variant="h5" sx={{ color: Color.TextPrimary, fontWeight: 600, letterSpacing: "-0.02em" }}>
							<Stack direction="row" spacing={1} alignItems="center" sx={{ minWidth: 0 }}>
								<span>{title}</span>
								{hasAgent ? (
									<Chip
										size="small"
										label={t("agent.project")}
										variant="outlined"
										sx={{ color: Color.TextSecondary, borderColor: Color.Line, height: 28, borderRadius: 999 }}
									/>
								) : null}
							</Stack>
						</Typography>
						<Typography variant="body2" sx={{ color: Color.TextSecondary, display: "block", mt: 0.4 }}>
							{displayPath ?? uploadPath}
						</Typography>
					</Box>
					<Stack direction="row" spacing={1}>
						{hasAgent ? (
							<Button
								size="small"
								variant={currentView === "agent" ? "contained" : "outlined"}
								disableRipple
								onClick={() => handleViewChange("agent")}
								sx={{
									color: currentView === "agent" ? Color.BackgroundDark : Color.TextPrimary,
									borderColor: Color.Line,
									backgroundColor: currentView === "agent" ? Color.Theme : "transparent",
									borderRadius: 3,
									px: 1.5,
									minWidth: 0,
									"&:hover": {
										borderColor: Color.Line,
										backgroundColor: currentView === "agent" ? Color.Theme : "transparent",
									},
								}}
							>
								{t("agent.dora")}
							</Button>
						) : null}
						<Button
							size="small"
							variant={currentView === "upload" ? "contained" : "outlined"}
							onClick={() => handleViewChange("upload")}
							disableRipple
							sx={{
								color: currentView === "upload" ? Color.BackgroundDark : Color.TextPrimary,
								borderColor: Color.Line,
								backgroundColor: currentView === "upload" ? Color.Theme : "transparent",
								borderRadius: 3,
								px: 1.5,
								minWidth: 0,
								"&:hover": {
									borderColor: Color.Line,
									backgroundColor: currentView === "upload" ? Color.Theme : "transparent",
								},
							}}
						>
							{t("menu.upload")}
						</Button>
					</Stack>
				</Stack>
			</Box>
			<Box sx={{ flex: 1, minHeight: 0 }}>
				{currentView === "agent" && hasAgent ? (
					<AgentPanel
						sessionId={agentSessionId}
						projectRoot={uploadPath}
						title={title}
						height={contentHeight}
						showHeader={false}
						addAlert={addAlert}
						onRollbackComplete={onRollbackComplete}
						onOpenFile={onOpenFile}
						onOpenLLMConfig={onOpenLLMConfig}
					/>
				) : (
					<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
						<Box sx={{ minHeight: "100%", py: 1 }}>
							<DoraUpload
								onUploaded={onUploaded}
								title={title}
								path={uploadPath}
								hideTitle
							/>
						</Box>
					</MacScrollbar>
				)}
			</Box>
		</Box>
	);
}

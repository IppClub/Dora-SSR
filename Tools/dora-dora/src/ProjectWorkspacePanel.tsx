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
import GitPanel from './GitPanel';
import { Color } from './Theme';

type WorkspaceView = "agent" | "upload" | "git";

interface ProjectWorkspacePanelProps {
	title: string;
	height: number;
	uploadPath: string;
	displayPath?: string;
	agentSessionId?: number;
	agentInitialPrompt?: string;
	view?: WorkspaceView;
	addAlert?: (msg: string, type: "success" | "info" | "warning" | "error") => void;
	onAgentInitialPromptConsumed?: () => void;
	onRollbackComplete?: (projectRoot: string) => void;
	onUploaded: (path: string, file: string, open: boolean) => void;
	onViewChange?: (view: WorkspaceView) => void;
	onOpenFile?: (filePath: string) => void;
	onOpenProject?: (projectPath: string) => void;
	onRepositoryFilesChanged?: (projectRoot: string) => void;
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
		agentInitialPrompt,
		view,
		addAlert,
		onAgentInitialPromptConsumed,
		onRollbackComplete,
		onUploaded,
		onViewChange,
		onOpenFile,
		onOpenProject,
		onRepositoryFilesChanged,
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

	const contentHeight = Math.max(height - 48, 0);
	const handleViewChange = (nextView: WorkspaceView) => {
		setInternalView(nextView);
		onViewChange?.(nextView);
	};

	return (
		<Box sx={{ display: "flex", flexDirection: "column", height }}>
			<Box sx={{ px: 2, py: 1.5, borderBottom: `0.5px solid ${Color.Line}`, background: `linear-gradient(180deg, ${Color.BackgroundDark} 0%, ${Color.Background} 100%)` }}>
				<Stack direction="row" spacing={1.5} alignItems="center" justifyContent="space-between" sx={{ minWidth: 0 }}>
					<Box sx={{ minWidth: 0, flex: 1 }}>
						<Stack direction="row" spacing={1} alignItems="center" sx={{ minWidth: 0 }}>
							<Typography variant="h5" noWrap sx={{ color: Color.TextPrimary, fontWeight: 600, letterSpacing: "-0.02em", minWidth: 0, flexShrink: 1 }}>
								{title}
							</Typography>
							{hasAgent ? (
								<Chip
									size="small"
									label={t("agent.project")}
									variant="outlined"
									sx={{ color: Color.TextSecondary, borderColor: Color.Line, height: 28, borderRadius: 999, flexShrink: 0 }}
								/>
							) : null}
							<Typography variant="body2" noWrap sx={{ color: Color.TextSecondary, minWidth: 0, flex: 1 }}>
								{displayPath ?? uploadPath}
							</Typography>
						</Stack>
					</Box>
					<Stack direction="row" spacing={1} sx={{ flexShrink: 0 }}>
						{hasAgent ? (
							<Button
								size="small"
								variant={currentView === "agent" ? "contained" : "outlined"}
								onClick={() => handleViewChange("agent")}
								sx={{
									color: currentView === "agent" ? Color.BackgroundDark : Color.TextPrimary,
									borderColor: Color.Line,
									backgroundColor: currentView === "agent" ? Color.Theme : "transparent",
									borderRadius: 3,
									px: 1.5,
									minWidth: 0,
									whiteSpace: "nowrap",
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
							sx={{
								color: currentView === "upload" ? Color.BackgroundDark : Color.TextPrimary,
								borderColor: Color.Line,
								backgroundColor: currentView === "upload" ? Color.Theme : "transparent",
								borderRadius: 3,
								px: 1.5,
								minWidth: 0,
								whiteSpace: "nowrap",
								"&:hover": {
									borderColor: Color.Line,
									backgroundColor: currentView === "upload" ? Color.Theme : "transparent",
								},
							}}
						>
							{t("menu.upload")}
						</Button>
						<Button
							size="small"
							variant={currentView === "git" ? "contained" : "outlined"}
							onClick={() => handleViewChange("git")}
							sx={{
								color: currentView === "git" ? Color.BackgroundDark : Color.TextPrimary,
								borderColor: Color.Line,
								backgroundColor: currentView === "git" ? Color.Theme : "transparent",
								borderRadius: 3,
								px: 1.5,
								minWidth: 0,
								whiteSpace: "nowrap",
								"&:hover": {
									borderColor: Color.Line,
									backgroundColor: currentView === "git" ? Color.Theme : "transparent",
								},
							}}
						>
							Git
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
						initialPrompt={agentInitialPrompt}
						addAlert={addAlert}
						onInitialPromptConsumed={onAgentInitialPromptConsumed}
						onRollbackComplete={onRollbackComplete}
						onOpenFile={onOpenFile}
						onOpenLLMConfig={onOpenLLMConfig}
					/>
				) : currentView === "git" ? (
					<GitPanel
						projectRoot={uploadPath}
						displayPath={displayPath}
						height={contentHeight}
						addAlert={addAlert}
						onOpenFile={onOpenFile}
						onOpenProject={onOpenProject}
						onRepositoryFilesChanged={onRepositoryFilesChanged}
					/>
				) : (
					<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
						<Box sx={{ minHeight: "100%", py: 3, }}>
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

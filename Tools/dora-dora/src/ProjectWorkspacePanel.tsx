import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import { Color } from './Theme';

const AgentPanel = React.lazy(() => import('./AgentPanel'));
const DoraUpload = React.lazy(() => import('./Upload'));
const GitPanel = React.lazy(() => import('./GitPanel'));

type WorkspaceView = "agent" | "upload" | "git";

function PanelFallback() {
	return (
		<Box sx={{
			width: "100%",
			height: "100%",
			backgroundColor: Color.Background,
		}} />
	);
}

interface ProjectWorkspacePanelProps {
	active?: boolean;
	title: string;
	height: number;
	uploadPath: string;
	displayPath?: string;
	isWorkspaceRoot?: boolean;
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
	onRepositoryFilesChanged?: (projectRoot: string) => void | Promise<void>;
	onOpenLLMConfig?: () => void;
}

export default function ProjectWorkspacePanel(props: ProjectWorkspacePanelProps) {
	const { t } = useTranslation();
	const {
		active = true,
		title,
		height,
		uploadPath,
		displayPath,
		isWorkspaceRoot,
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
	const [mountedViews, setMountedViews] = React.useState<Set<WorkspaceView>>(
		() => new Set([currentView]),
	);
	const headerHeight = 52;
	const fullDisplayPath = displayPath ?? uploadPath;
	const normalizedDisplayPath = fullDisplayPath.replace(/\/+$/, "");
	const parentSeparatorIndex = normalizedDisplayPath.lastIndexOf("/");
	const contextualDisplayPath = parentSeparatorIndex > 0
		? normalizedDisplayPath.slice(0, parentSeparatorIndex)
		: normalizedDisplayPath;

	React.useEffect(() => {
		if (view) {
			setInternalView(view);
			return;
		}
		setInternalView(hasAgent ? "agent" : "upload");
	}, [view, hasAgent, agentSessionId, uploadPath]);

	React.useEffect(() => {
		setMountedViews(previous => {
			if (previous.has(currentView)) return previous;
			const next = new Set(previous);
			next.add(currentView);
			return next;
		});
	}, [currentView]);

	const contentHeight = Math.max(height - headerHeight, 0);
	const handleViewChange = (nextView: WorkspaceView) => {
		setInternalView(nextView);
		onViewChange?.(nextView);
	};
	const workspaceTabs: Array<{ value: WorkspaceView; label: string }> = [
		...(hasAgent ? [{ value: "agent" as const, label: t("agent.workspaceAgent") }] : []),
		{ value: "upload", label: t("agent.workspaceFiles") },
		{ value: "git", label: "Git" },
	];

	return (
		<Box sx={{ display: "flex", flexDirection: "column", height }}>
			<Box sx={{
				height: headerHeight,
				px: 2,
				borderBottom: `1px solid ${Color.Line}`,
				backgroundColor: Color.BackgroundDark,
				display: "flex",
				alignItems: "center",
				flexShrink: 0,
			}}>
				<Stack direction="row" spacing={2} alignItems="center" justifyContent="space-between" sx={{ minWidth: 0, width: "100%" }}>
					<Box sx={{ minWidth: 0, flex: 1 }}>
						<Stack direction="row" spacing={1.25} alignItems="baseline" sx={{ minWidth: 0 }}>
							<Typography variant="subtitle1" noWrap sx={{ color: Color.TextPrimary, fontWeight: 650, letterSpacing: "-0.01em", minWidth: 0, flexShrink: 1 }}>
								{title}
							</Typography>
							<Typography variant="caption" noWrap title={fullDisplayPath} sx={{ color: Color.TextSecondary, minWidth: 0, flex: 1 }}>
								{contextualDisplayPath}
							</Typography>
						</Stack>
					</Box>
					<Stack
						direction="row"
						spacing={0.5}
						sx={{
							flexShrink: 0,
							p: 0.5,
							border: `1px solid ${Color.Line}`,
							borderRadius: 2,
							backgroundColor: Color.Background,
						}}
					>
						{workspaceTabs.map(tab => (
							<Button
								key={tab.value}
								data-workspace-view={tab.value}
								size="small"
								variant="text"
								onClick={() => handleViewChange(tab.value)}
								aria-pressed={currentView === tab.value}
								sx={{
									height: 30,
									color: currentView === tab.value ? Color.Theme : Color.TextSecondary,
									backgroundColor: currentView === tab.value ? Color.ThemeMuted : "transparent",
									borderRadius: 1.25,
									px: 1.4,
									minWidth: 52,
									whiteSpace: "nowrap",
									"&:hover": {
										color: currentView === tab.value ? Color.Theme : Color.TextPrimary,
										backgroundColor: currentView === tab.value ? Color.ThemeMuted : Color.SurfaceHover,
									},
								}}
							>
								{tab.label}
							</Button>
						))}
					</Stack>
				</Stack>
			</Box>
			<Box sx={{ flex: 1, minHeight: 0 }}>
				{hasAgent && (currentView === "agent" || mountedViews.has("agent")) ? (
					<Box sx={{ display: currentView === "agent" ? "block" : "none", height: "100%" }}>
						<React.Suspense fallback={<PanelFallback />}>
							<AgentPanel
								active={active && currentView === "agent"}
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
								onRepositoryFilesChanged={onRepositoryFilesChanged}
								onOpenLLMConfig={onOpenLLMConfig}
							/>
						</React.Suspense>
					</Box>
				) : null}
				{active && currentView === "git" ? (
					<React.Suspense fallback={<PanelFallback />}>
						<GitPanel
							projectRoot={uploadPath}
							displayPath={displayPath}
							height={contentHeight}
							isWorkspaceRoot={isWorkspaceRoot}
							addAlert={addAlert}
							onOpenFile={onOpenFile}
							onOpenProject={onOpenProject}
							onRepositoryFilesChanged={onRepositoryFilesChanged}
						/>
					</React.Suspense>
				) : active && currentView === "upload" ? (
					<React.Suspense fallback={<PanelFallback />}>
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
					</React.Suspense>
				) : null}
			</Box>
		</Box>
	);
}

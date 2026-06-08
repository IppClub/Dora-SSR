import React from 'react';
import Autocomplete from '@mui/material/Autocomplete';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Checkbox from '@mui/material/Checkbox';
import Chip from '@mui/material/Chip';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Divider from '@mui/material/Divider';
import FormControlLabel from '@mui/material/FormControlLabel';
import IconButton from '@mui/material/IconButton';
import LinearProgress from '@mui/material/LinearProgress';
import Menu from '@mui/material/Menu';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import TextField from '@mui/material/TextField';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { DiffEditor } from '@monaco-editor/react';
import { MacScrollbar } from 'mac-scrollbar';
import AddIcon from '@mui/icons-material/Add';
import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown';
import CallSplitIcon from '@mui/icons-material/CallSplit';
import DeleteIcon from '@mui/icons-material/Delete';
import FolderIcon from '@mui/icons-material/Folder';
import InsertDriveFileIcon from '@mui/icons-material/InsertDriveFile';
import LocalOfferIcon from '@mui/icons-material/LocalOffer';
import MoreHorizIcon from '@mui/icons-material/MoreHoriz';
import RefreshIcon from '@mui/icons-material/Refresh';
import SettingsIcon from '@mui/icons-material/Settings';
import UploadIcon from '@mui/icons-material/Upload';
import DownloadIcon from '@mui/icons-material/Download';
import * as Service from './Service';
import { Color } from './Theme';
import { EditorTheme } from './Editor';

interface GitPanelProps {
	projectRoot: string;
	displayPath?: string;
	height: number;
	addAlert?: (msg: string, type: "success" | "info" | "warning" | "error") => void;
	onOpenFile?: (filePath: string) => void;
	onOpenProject?: (projectPath: string) => void;
}

type ChangeSection = "unstaged" | "staged";
type GitPreviewMode = "local" | "commits";
type CommitDetailTab = "commit" | "changes";

interface GitFileItem extends Service.GitFileStatus {
	section: ChangeSection;
	status: string;
}

interface GitRow {
	key: string;
	path: string;
	name: string;
	depth: number;
	type: "dir" | "file";
	status?: string;
	file?: GitFileItem;
}

interface GitRemoteBranchRow {
	key: string;
	name: string;
	depth: number;
	type: "dir" | "branch";
	branch?: Service.GitBranchInfo;
}

interface GitJobViewState {
	jobId: number;
	command: string;
	startedAt: number;
	status?: Service.GitStatus;
}

interface PendingCredentialSelection {
	command: string;
	host?: string;
	credentials: Service.GitCredentialMeta[];
}

interface SelectedRemoteBranch {
	remote: string;
	name: string;
}

interface CommitRefChip {
	key: string;
	label: string;
	type: "branch" | "remote" | "tag";
	current?: boolean;
}

interface GitDialogField {
	name: string;
	label: string;
	value?: string | boolean;
	required?: boolean;
	type?: string;
	checkbox?: boolean;
	placeholder?: string;
	options?: string[] | ((values: Record<string, string | boolean>) => string[]);
}

interface GitActionDialogState {
	title: string;
	detail?: string;
	submitLabel?: string;
	fields: GitDialogField[];
	onSubmit: (values: Record<string, string | boolean>) => void;
}

interface GitConfirmDialogState {
	title: string;
	detail?: string;
	command?: string;
	submitLabel?: string;
	danger?: boolean;
	onConfirm: () => void;
}

interface GitDiffPreviewState {
	path: string;
	staged: boolean;
	loading: boolean;
	mode?: "diff" | "empty" | "binary" | "large";
	oldText?: string;
	newText?: string;
	oldSize?: number;
	newSize?: number;
	message?: string;
}

const terminalStates = new Set<Service.GitJobState>(["done", "error", "canceled"]);

const panelBorder = "#2b2b2b";
const panelBg = "#1a1a1a";
const surfaceBg = "#181818";
const buttonBg = "#303030";
const mutedText = "#8f9aa6";
const primaryText = "#d7d7d7";
const accent = "#fac03d";
const accentSoft = "rgba(250, 192, 61, 0.16)";

const disabledButtonSx = {
	color: "rgba(215, 215, 215, 0.42)",
	borderColor: "#3a3a3a",
	backgroundColor: "#2a2a2a",
};

const statusChipSx = (status: string) => ({
	height: 18,
	minWidth: 24,
	borderRadius: 0.75,
	color: Color.BackgroundDark,
	backgroundColor: statusColor(status),
	fontSize: 11,
	fontWeight: 700,
});

const toolButtonSx = {
	height: 30,
	minWidth: 30,
	border: `1px solid ${panelBorder}`,
	borderRadius: 0,
	backgroundColor: buttonBg,
	color: primaryText,
	px: 1,
	"&:hover": { backgroundColor: "#383838", borderColor: "#444" },
	"&.Mui-disabled": disabledButtonSx,
};

const commitButtonSx = {
	height: 32,
	minWidth: 112,
	borderRadius: 0,
	border: `1px solid ${accent}`,
	color: "#171717",
	backgroundColor: accent,
	fontWeight: 700,
	"&:hover": { backgroundColor: "#ffd05a", borderColor: "#ffd05a" },
	"&.Mui-disabled": disabledButtonSx,
};

const iconButtonSx = {
	width: 30,
	height: 30,
	border: `1px solid ${panelBorder}`,
	borderRadius: 0,
	backgroundColor: buttonBg,
	color: primaryText,
	"&:hover": { backgroundColor: "#383838", borderColor: "#444" },
	"&.Mui-disabled": disabledButtonSx,
};

const panelSx = {
	border: `1px solid ${panelBorder}`,
	backgroundColor: panelBg,
	minHeight: 0,
};

const dialogContentSx = {
	display: "flex",
	flexDirection: "column",
	gap: 1.25,
	background: surfaceBg,
	pt: "20px !important",
};

const trimSlash = (value: string) => value.replace(/[\\/]+$/, "");
const joinPath = (base: string, child: string) => `${trimSlash(base)}/${child.replace(/^[\\/]+/, "")}`;

const quoteArg = (value: string) => {
	if (/^[\w./:-]+$/.test(value)) return value;
	return `"${value.replace(/\\/g, "\\\\").replace(/"/g, "\\\"")}"`;
};

const formatBytes = (value?: number) => {
	if (value === undefined || value === null) return "-";
	if (value < 1024) return `${value} B`;
	const units = ["KB", "MB", "GB"];
	let size = value / 1024;
	let unit = units[0];
	for (let index = 1; index < units.length && size >= 1024; index++) {
		size /= 1024;
		unit = units[index];
	}
	return `${size.toFixed(size >= 10 ? 1 : 2)} ${unit}`;
};

const formatCommitTime = (value: string) => {
	const date = new Date(value);
	if (Number.isNaN(date.getTime())) return value;
	const now = new Date();
	const sameYear = date.getFullYear() === now.getFullYear();
	return new Intl.DateTimeFormat(undefined, {
		month: "short",
		day: "numeric",
		...(sameYear ? {} : { year: "numeric" }),
		hour: "2-digit",
		minute: "2-digit",
		hour12: false,
	}).format(date);
};

const diffMessage = (data: Service.GitFileDiffResponse["data"]) => {
	if (!data) return undefined;
	if (data.message) return data.message;
	if (data.binary) return `Binary file: ${formatBytes(data.oldSize)} -> ${formatBytes(data.newSize)}`;
	return undefined;
};

const diffPreviewMessage = (preview: GitDiffPreviewState | null, hasPath: boolean) => {
	if (!hasPath || !preview || preview.loading) return "";
	return preview.message ?? (preview.mode === "empty" ? "No diff" : "");
};

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

const isGitRepoBusy = (res: Service.GitFileDiffResponse) => (
	!res.success && /repo path is already used by job/i.test(res.message ?? "")
);

const isGitBusyMessage = (message?: string) => /repo path is already used by job/i.test(message ?? "");

const isTransientSummaryFailure = (res: Service.GitSummaryResponse) => {
	if (!res.success) return isGitBusyMessage(res.message);
	if (res.isRepo) return false;
	return isGitBusyMessage(res.message) || isGitBusyMessage(res.status?.message) || isGitBusyMessage(res.status?.error);
};

const loadPreviewDiff = async (
	load: () => Promise<Service.GitFileDiffResponse>,
	isCanceled: () => boolean,
) => {
	let last: Service.GitFileDiffResponse | undefined;
	for (let attempt = 0; attempt < 8; attempt++) {
		if (isCanceled()) break;
		const res = await load();
		last = res;
		if (!isGitRepoBusy(res) || isCanceled()) return res;
		await delay(120 + attempt * 80);
	}
	return last ?? { success: false, message: "Failed to load preview" };
};

const statusLabel = (code: string) => {
	switch (code) {
		case "A": return "A";
		case "M": return "M";
		case "D": return "D";
		case "?": return "U";
		case "R": return "R";
		case "C": return "C";
		case "!": return "!";
		default: return code.trim() || "?";
	}
};

const statusColor = (code: string) => {
	switch (code) {
		case "A":
		case "?": return "#56d364";
		case "D": return "#ff6b6b";
		case "M": return "#f2b84b";
		default: return Color.Warning;
	}
};

const getLanguageForGitFile = (filePath: string) => {
	const ext = filePath.toLowerCase().split('.').pop() ?? "";
	switch (ext) {
		case "lua": return "lua";
		case "tl": return "tl";
		case "yue": return "yue";
		case "ts":
		case "tsx": return "typescript";
		case "xml": return "xml";
		case "md": return "markdown";
		case "wa": return "wa";
		case "yarn": return "yarn";
		case "mod": return "ini";
		case "json": return "json";
		default: return "txt";
	}
};

const getStatusFiles = (summary?: Service.GitSummaryResponse): Service.GitFileStatus[] => {
	if (!summary || !summary.success || !summary.status?.data?.files) return [];
	return summary.status.data.files as Service.GitFileStatus[];
};

const asArray = <T,>(value: T[] | unknown): T[] => Array.isArray(value) ? value : [];

const splitFiles = (files: Service.GitFileStatus[]) => {
	const unstaged: GitFileItem[] = [];
	const staged: GitFileItem[] = [];
	for (const file of files) {
		const staging = file.staging === "" ? " " : file.staging;
		const worktree = file.worktree === "" ? " " : file.worktree;
		if (staging !== " " && staging !== "?") {
			staged.push({ ...file, section: "staged", status: staging });
		}
		if (worktree !== " " || staging === "?") {
			unstaged.push({ ...file, section: "unstaged", status: staging === "?" ? "?" : worktree });
		}
	}
	return { unstaged, staged };
};

const selectedPathsSafe = (selectedSet: Set<string>, source: GitFileItem[]) => {
	const paths = new Set<string>();
	for (const key of selectedSet) {
		const [, type, rowPath] = key.split(/:(dir|file):/);
		if (!rowPath) continue;
		if (type === "file") {
			paths.add(rowPath);
		} else {
			for (const file of source) {
				if (file.path === rowPath || file.path.startsWith(`${rowPath}/`)) paths.add(file.path);
			}
		}
	}
	return Array.from(paths);
};

const collectParentDirs = (files: Array<{ path: string }>) => {
	const dirs = new Set<string>();
	for (const file of files) {
		const parts = file.path.split(/[\\/]+/);
		for (let i = 1; i < parts.length; i++) dirs.add(parts.slice(0, i).join("/"));
	}
	return dirs;
};

const buildRows = (files: GitFileItem[], expanded: Set<string>, section: ChangeSection): GitRow[] => {
	const dirs = new Set<string>();
	for (const file of files) {
		const parts = file.path.split(/[\\/]+/);
		for (let i = 1; i < parts.length; i++) {
			dirs.add(parts.slice(0, i).join("/"));
		}
	}
	const rows: GitRow[] = [];
	const visit = (prefix: string, depth: number) => {
		const dirChildren = Array.from(dirs)
			.filter(dir => {
				const parent = dir.includes("/") ? dir.slice(0, dir.lastIndexOf("/")) : "";
				return parent === prefix;
			})
			.sort();
		for (const dir of dirChildren) {
			const name = dir.includes("/") ? dir.slice(dir.lastIndexOf("/") + 1) : dir;
			rows.push({ key: `${section}:dir:${dir}`, path: dir, name, depth, type: "dir" });
			if (expanded.has(dir)) visit(dir, depth + 1);
		}
		const fileChildren = files
			.filter(file => {
				const parent = file.path.includes("/") ? file.path.slice(0, file.path.lastIndexOf("/")) : "";
				return parent === prefix;
			})
			.sort((a, b) => a.path.localeCompare(b.path));
		for (const file of fileChildren) {
			const name = file.path.includes("/") ? file.path.slice(file.path.lastIndexOf("/") + 1) : file.path;
			rows.push({ key: `${section}:file:${file.path}`, path: file.path, name, depth, type: "file", status: file.status, file });
		}
	};
	visit("", 0);
	return rows;
};

interface GitFileTreeProps {
	rows: GitRow[];
	emptyMessage?: string;
	containerSx?: Record<string, unknown>;
	scrollbarStyle?: React.CSSProperties;
	expanded?: Set<string>;
	preventShiftSelection?: boolean;
	isRowSelected: (row: GitRow) => boolean;
	isRowInteractive?: (row: GitRow) => boolean;
	onRowClick: (row: GitRow, index: number, event: React.MouseEvent<HTMLDivElement>) => void;
	onToggleDir?: (path: string) => void;
}

const GitFileTree = (props: GitFileTreeProps) => {
	const {
		rows,
		emptyMessage = "No files",
		containerSx,
		scrollbarStyle,
		expanded,
		preventShiftSelection = false,
		isRowSelected,
		isRowInteractive = () => true,
		onRowClick,
		onToggleDir,
	} = props;
	return (
		<Box sx={containerSx}>
			<MacScrollbar skin="dark" style={scrollbarStyle ?? { height: "100%" }}>
				{rows.length === 0 ? (
					<Typography variant="body2" sx={{ color: mutedText, p: 1.5, fontSize: 13 }}>{emptyMessage}</Typography>
				) : rows.map((row, index) => {
					const selectedRow = isRowSelected(row);
					const interactive = isRowInteractive(row);
					return (
						<Box
							key={row.key}
							onMouseDown={(event) => {
								if (preventShiftSelection && event.shiftKey) event.preventDefault();
							}}
							onClick={(event) => onRowClick(row, index, event)}
							sx={{
								display: "flex",
								alignItems: "center",
								height: 28,
								px: 1,
								pl: 1 + row.depth * 2,
								gap: 0.75,
								cursor: interactive ? "pointer" : "default",
								color: primaryText,
								backgroundColor: selectedRow ? accentSoft : "transparent",
								userSelect: "none",
								"&:hover": { backgroundColor: interactive ? (selectedRow ? "rgba(250, 192, 61, 0.22)" : "#222") : "transparent" },
							}}
						>
							{row.type === "dir" ? (
								<Box
									onClick={(event) => {
										if (!onToggleDir) return;
										event.stopPropagation();
										onToggleDir(row.path);
									}}
									sx={{
										width: 18,
										height: 24,
										display: "flex",
										alignItems: "center",
										justifyContent: "center",
										cursor: onToggleDir ? "pointer" : "default",
										color: Color.TextSecondary,
										"&:hover": { color: onToggleDir ? accent : Color.TextSecondary },
									}}
								>
									<ArrowDropDownIcon sx={{ fontSize: 18, transform: onToggleDir && !expanded?.has(row.path) ? "rotate(-90deg)" : "none" }} />
								</Box>
							) : <Box sx={{ width: 18 }} />}
							{row.type === "dir" ? <FolderIcon sx={{ fontSize: 16, color: Color.TextSecondary }} /> : <InsertDriveFileIcon sx={{ fontSize: 15, color: Color.TextSecondary }} />}
							{row.status ? <Chip label={statusLabel(row.status)} size="small" sx={statusChipSx(row.status)} /> : null}
							<Typography variant="body2" noWrap sx={{ minWidth: 0, flex: 1, fontSize: 12, fontWeight: selectedRow ? 700 : 500 }}>{row.name}</Typography>
						</Box>
					);
				})}
			</MacScrollbar>
		</Box>
	);
};

interface GitDiffPreviewProps {
	path: string;
	preview: GitDiffPreviewState | null;
}

const GitDiffPreview = (props: GitDiffPreviewProps) => {
	const { path, preview } = props;
	const message = diffPreviewMessage(preview, path !== "");
	return (
		<Box sx={{ flex: 1, minHeight: 0, background: "#222", overflow: "hidden" }}>
			{path && preview && !preview.loading && preview.mode === "diff" ? (
				<DiffEditor
					height="100%"
					theme={EditorTheme}
					language={getLanguageForGitFile(path)}
					loading={null}
					original={preview.oldText ?? ""}
					modified={preview.newText ?? ""}
					options={{
						readOnly: true,
						renderSideBySide: true,
						useInlineViewWhenSpaceIsLimited: true,
						automaticLayout: true,
						minimap: { enabled: false },
						scrollBeyondLastLine: false,
						wordWrap: "off",
						fontSize: 13,
						lineNumbers: "on",
						renderOverviewRuler: false,
						originalEditable: false,
						diffWordWrap: "off",
						ignoreTrimWhitespace: false,
						renderWhitespace: "all",
						diffAlgorithm: "advanced",
						stickyScroll: { enabled: false },
						hideUnchangedRegions: {
							enabled: true,
							contextLineCount: 3,
							minimumLineCount: 3,
							revealLineCount: 10,
						},
					}}
				/>
			) : (
				<MacScrollbar skin="dark" style={{ height: "100%" }}>
					<Box sx={{ p: 2 }}>
						{message ? (
							<Typography variant="body2" sx={{ color: mutedText, mt: 1 }}>{message}</Typography>
						) : null}
					</Box>
				</MacScrollbar>
			)}
		</Box>
	);
};

const buildRemoteBranchRows = (remote: string, branches: Service.GitBranchInfo[]): GitRemoteBranchRow[] => {
	const rows: GitRemoteBranchRow[] = [];
	const folders = new Set<string>();
	for (const branch of branches) {
		const parts = branch.name.split("/").filter(Boolean);
		if (parts.length === 0) continue;
		let folderPath = "";
		for (let index = 0; index < parts.length - 1; index++) {
			folderPath = folderPath ? `${folderPath}/${parts[index]}` : parts[index];
			const key = `${remote}/${folderPath}`;
			if (folders.has(key)) continue;
			folders.add(key);
			rows.push({ key, name: parts[index], depth: index, type: "dir" });
		}
		rows.push({
			key: `${remote}/${branch.name}`,
			name: parts[parts.length - 1],
			depth: Math.max(0, parts.length - 1),
			type: "branch",
			branch,
		});
	}
	return rows;
};

export default function GitPanel(props: GitPanelProps) {
	const { projectRoot, displayPath, height, addAlert, onOpenFile, onOpenProject } = props;
	const [summary, setSummary] = React.useState<Service.GitSummaryResponse | null>(null);
	const [loading, setLoading] = React.useState(false);
	const [job, setJob] = React.useState<GitJobViewState | null>(null);
	const [commitMessage, setCommitMessage] = React.useState("");
	const [commitDescription, setCommitDescription] = React.useState("");
	const [previewMode, setPreviewMode] = React.useState<GitPreviewMode>("local");
	const [selectedCommitHash, setSelectedCommitHash] = React.useState<string | null>(null);
	const [commitDetailTab, setCommitDetailTab] = React.useState<CommitDetailTab>("commit");
	const [selectedCommitFilePath, setSelectedCommitFilePath] = React.useState<string>("");
	const [selectedBranchName, setSelectedBranchName] = React.useState<string | null>(null);
	const [selectedRemoteName, setSelectedRemoteName] = React.useState<string | null>(null);
	const [selectedRemoteBranch, setSelectedRemoteBranch] = React.useState<SelectedRemoteBranch | null>(null);
	const [selectedTagName, setSelectedTagName] = React.useState<string | null>(null);
	const [expanded, setExpanded] = React.useState<Set<string>>(new Set());
	const [commitExpanded, setCommitExpanded] = React.useState<Set<string>>(new Set());
	const [selected, setSelected] = React.useState<Record<ChangeSection, Set<string>>>({ unstaged: new Set(), staged: new Set() });
	const [lastRow, setLastRow] = React.useState<Record<ChangeSection, number | null>>({ unstaged: null, staged: null });
	const [cloneUrl, setCloneUrl] = React.useState("");
	const [cloneDir, setCloneDir] = React.useState("");
	const [cloneBranch, setCloneBranch] = React.useState("");
	const [cloneDepth, setCloneDepth] = React.useState("");
	const [settingsOpen, setSettingsOpen] = React.useState(false);
	const [settingsTab, setSettingsTab] = React.useState<"profile" | "credentials">("profile");
	const [profile, setProfile] = React.useState<Service.GitProfile>({ name: "", email: "" });
	const [credentials, setCredentials] = React.useState<Service.GitCredentialMeta[]>([]);
	const [credentialForm, setCredentialForm] = React.useState({ host: "", label: "", type: "token" as "basic" | "token", username: "", secret: "" });
	const [pendingCredential, setPendingCredential] = React.useState<PendingCredentialSelection | null>(null);
	const [moreAnchor, setMoreAnchor] = React.useState<{ section: ChangeSection; anchor: HTMLElement } | null>(null);
	const [actionDialog, setActionDialog] = React.useState<GitActionDialogState | null>(null);
	const [confirmDialog, setConfirmDialog] = React.useState<GitConfirmDialogState | null>(null);
	const [dialogValues, setDialogValues] = React.useState<Record<string, string | boolean>>({});
	const [diffPreview, setDiffPreview] = React.useState<GitDiffPreviewState | null>(null);
	const [commitDiffPreview, setCommitDiffPreview] = React.useState<GitDiffPreviewState | null>(null);
	const pendingCredentialDoneRef = React.useRef<((status: Service.GitStatus) => void) | undefined>(undefined);

	const files = React.useMemo(() => splitFiles(getStatusFiles(summary ?? undefined)), [summary]);
	const unstagedRows = React.useMemo(() => buildRows(files.unstaged, expanded, "unstaged"), [files.unstaged, expanded]);
	const stagedRows = React.useMemo(() => buildRows(files.staged, expanded, "staged"), [files.staged, expanded]);
	const stagedCount = files.staged.length;
	const localChangeCount = files.unstaged.length + files.staged.length;
	const isRepo = !!summary?.success && summary.isRepo;
	const repoName = React.useMemo(() => {
		const source = trimSlash(displayPath ?? projectRoot);
		const parts = source.split(/[\\/]+/);
		return parts[parts.length - 1] || "Repository";
	}, [displayPath, projectRoot]);
	const commitList = React.useMemo(() => (
		summary?.success ? asArray<Service.GitLogCommit>(summary.historyStatus?.data?.commits).slice(0, 100) : []
	), [summary]);
	const tagList = React.useMemo(() => (
		summary?.success ? asArray<Service.GitTagInfo>(summary.tagStatus?.data?.tags) : []
	), [summary]);
	const refsByHash = React.useMemo(() => {
		const map = new Map<string, CommitRefChip[]>();
		if (!summary?.success) return map;
		for (const branch of summary.branches ?? []) {
			if (!branch.hash || branch.unborn) continue;
			const list = map.get(branch.hash) ?? [];
			list.push({
				key: branch.remote ? `remote:${branch.remote}/${branch.name}` : `branch:${branch.name}`,
				label: branch.remote ? `${branch.remote}/${branch.name}` : branch.name,
				type: branch.remote ? "remote" : "branch",
				current: !branch.remote && branch.current,
			});
			map.set(branch.hash, list);
		}
		for (const tag of tagList) {
			const list = map.get(tag.hash) ?? [];
			list.push({ key: `tag:${tag.name}`, label: tag.name, type: "tag" });
			map.set(tag.hash, list);
		}
		for (const list of map.values()) {
			list.sort((a, b) => {
				const order = (item: CommitRefChip) => item.type === "tag" ? 0 : item.type === "branch" ? (item.current ? 1 : 2) : 3;
				return order(a) - order(b) || a.label.localeCompare(b.label);
			});
		}
		return map;
	}, [summary, tagList]);
	const selectedTag = React.useMemo(() => (
		selectedTagName ? tagList.find(tag => tag.name === selectedTagName) : undefined
	), [selectedTagName, tagList]);
	const commitHashKey = commitList.map(commit => commit.hash).join("|");
	const selectedCommit = React.useMemo(() => (
		commitList.find(commit => commit.hash === selectedCommitHash) ?? commitList[0] ?? null
	), [commitList, selectedCommitHash]);
	const selectedCommitFiles = React.useMemo(() => (
		asArray<Service.GitCommitFile>(selectedCommit?.files)
	), [selectedCommit]);
	const commitExpandedDefault = React.useMemo(() => collectParentDirs(selectedCommitFiles), [selectedCommitFiles]);
	const commitExpandedKey = React.useMemo(() => Array.from(commitExpandedDefault).sort().join("|"), [commitExpandedDefault]);
	const commitFileRows = React.useMemo(() => {
		const files = selectedCommitFiles.map(file => ({
			path: file.path,
			staging: file.status,
			worktree: " ",
			section: "staged" as const,
			status: file.status,
		}));
		return buildRows(files, commitExpanded, "staged");
	}, [commitExpanded, selectedCommitFiles]);
	const localBranches = React.useMemo(() => (
		summary?.success ? (summary.branches ?? []).filter(branch => !branch.remote) : []
	), [summary]);
	const remoteBranchesByRemote = React.useMemo(() => {
		const groups = new Map<string, Service.GitBranchInfo[]>();
		if (!summary?.success) return groups;
		for (const branch of summary.branches ?? []) {
			if (!branch.remote) continue;
			const list = groups.get(branch.remote) ?? [];
			list.push(branch);
			groups.set(branch.remote, list);
		}
		for (const list of groups.values()) {
			list.sort((a, b) => a.name.localeCompare(b.name));
		}
		return groups;
	}, [summary]);
	const remoteBranchRowsByRemote = React.useMemo(() => {
		const rows = new Map<string, GitRemoteBranchRow[]>();
		for (const [remote, branches] of remoteBranchesByRemote) {
			rows.set(remote, buildRemoteBranchRows(remote, branches));
		}
		return rows;
	}, [remoteBranchesByRemote]);
	const selectedBranch = React.useMemo(() => (
		selectedBranchName ? localBranches.find(branch => branch.name === selectedBranchName) : undefined
	), [localBranches, selectedBranchName]);
	const selectedRemote = React.useMemo(() => (
		summary?.success && selectedRemoteName ? summary.remotes?.find(remote => remote.name === selectedRemoteName) : undefined
	), [selectedRemoteName, summary]);
	const remoteNames = React.useMemo(() => (
		summary?.success ? asArray<Service.GitRemoteInfo>(summary.remotes).map(remote => remote.name) : []
	), [summary]);
	const remoteBranchNames = React.useCallback((remoteName: string) => {
		const names = (remoteBranchesByRemote.get(remoteName) ?? []).map(branch => branch.name);
		return Array.from(new Set(names)).sort((a, b) => a.localeCompare(b));
	}, [remoteBranchesByRemote]);
	const preferredRemoteBranch = React.useCallback((remoteName: string, currentValue = "") => {
		const names = remoteBranchNames(remoteName);
		if (currentValue && names.includes(currentValue)) return currentValue;
		if (summary?.success && summary.currentBranch && names.includes(summary.currentBranch)) return summary.currentBranch;
		return names[0] ?? currentValue;
	}, [remoteBranchNames, summary]);
	const selectedUnstagedPath = selectedPathsSafe(selected.unstaged, files.unstaged)[0] ?? "";
	const selectedStagedPath = selectedPathsSafe(selected.staged, files.staged)[0] ?? "";
	const selectedLocalPath = selectedUnstagedPath || selectedStagedPath;
	const selectedLocalStaged = selectedStagedPath !== "";
	React.useEffect(() => {
		if (commitList.length === 0) {
			if (selectedCommitHash !== null) setSelectedCommitHash(null);
			return;
		}
		if (!selectedCommitHash || !commitList.some(commit => commit.hash === selectedCommitHash)) {
			setSelectedCommitHash(commitList[0].hash);
		}
	}, [commitHashKey, commitList, selectedCommitHash]);

	React.useEffect(() => {
		const firstPath = selectedCommitFiles[0]?.path ?? "";
		if (!selectedCommit || selectedCommitFiles.length === 0) {
			if (selectedCommitFilePath !== "") setSelectedCommitFilePath("");
			return;
		}
		if (!selectedCommitFiles.some(file => file.path === selectedCommitFilePath)) {
			setSelectedCommitFilePath(firstPath);
		}
	}, [selectedCommit, selectedCommitFilePath, selectedCommitFiles]);

	React.useEffect(() => {
		setCommitExpanded(new Set(commitExpandedDefault));
	}, [commitExpandedDefault, commitExpandedKey, selectedCommit?.hash]);

	React.useEffect(() => {
		if (!selectedCommit || !selectedCommitFilePath) {
			setCommitDiffPreview(null);
			return;
		}
		let canceled = false;
		setCommitDiffPreview({ path: selectedCommitFilePath, staged: false, loading: true });
		loadPreviewDiff(
			() => Service.gitCommitFileDiff({ repoPath: projectRoot, commit: selectedCommit.hash, path: selectedCommitFilePath }),
			() => canceled,
		)
			.then(res => {
				if (canceled) return;
				if (!res.success) {
					setCommitDiffPreview({ path: selectedCommitFilePath, staged: false, loading: false, message: res.message ?? "Failed to load commit diff" });
					return;
				}
				const data = res.data ?? res.status?.data ?? {};
				setCommitDiffPreview({
					path: selectedCommitFilePath,
					staged: false,
					loading: false,
					mode: data.mode ?? "empty",
					oldText: data.oldText ?? "",
					newText: data.newText ?? "",
					oldSize: data.oldSize,
					newSize: data.newSize,
					message: diffMessage(data),
				});
			})
			.catch(() => {
				if (!canceled) setCommitDiffPreview({ path: selectedCommitFilePath, staged: false, loading: false, message: "Failed to load commit diff" });
			});
		return () => {
			canceled = true;
		};
	}, [projectRoot, selectedCommit, selectedCommitFilePath]);

	React.useEffect(() => {
		if (!summary?.success) {
			setSelectedBranchName(null);
			setSelectedRemoteName(null);
			setSelectedRemoteBranch(null);
			setSelectedTagName(null);
			return;
		}
		if (selectedBranchName && !localBranches.some(branch => branch.name === selectedBranchName)) {
			setSelectedBranchName(null);
		}
		if (selectedRemoteName && !summary.remotes?.some(remote => remote.name === selectedRemoteName)) {
			setSelectedRemoteName(null);
		}
		if (selectedRemoteBranch) {
			const exists = (summary.branches ?? []).some(branch => (
				branch.remote === selectedRemoteBranch.remote && branch.name === selectedRemoteBranch.name
			));
			if (!exists) setSelectedRemoteBranch(null);
		}
		if (selectedTagName && !tagList.some(tag => tag.name === selectedTagName)) {
			setSelectedTagName(null);
		}
	}, [localBranches, selectedBranchName, selectedRemoteBranch, selectedRemoteName, selectedTagName, summary, tagList]);

	React.useEffect(() => {
		if (!selectedLocalPath) {
			setDiffPreview(null);
			return;
		}
		let canceled = false;
		setDiffPreview({ path: selectedLocalPath, staged: selectedLocalStaged, loading: true });
		loadPreviewDiff(
			() => Service.gitFileDiff({ repoPath: projectRoot, path: selectedLocalPath, staged: selectedLocalStaged }),
			() => canceled,
		)
			.then(res => {
				if (canceled) return;
				if (!res.success) {
					setDiffPreview({ path: selectedLocalPath, staged: selectedLocalStaged, loading: false, message: res.message ?? "Failed to load preview" });
					return;
				}
				const data = res.data ?? res.status?.data ?? {};
				setDiffPreview({
					path: selectedLocalPath,
					staged: selectedLocalStaged,
					loading: false,
					mode: data.mode ?? "empty",
					oldText: data.oldText ?? "",
					newText: data.newText ?? "",
					oldSize: data.oldSize,
					newSize: data.newSize,
					message: diffMessage(data),
				});
			})
			.catch(() => {
				if (!canceled) setDiffPreview({ path: selectedLocalPath, staged: selectedLocalStaged, loading: false, message: "Failed to load preview" });
			});
		return () => {
			canceled = true;
		};
	}, [projectRoot, selectedLocalPath, selectedLocalStaged]);

	const showAlert = React.useCallback((message: string, type: "success" | "info" | "warning" | "error" = "info") => {
		addAlert?.(message, type);
	}, [addAlert]);

	const openActionDialog = React.useCallback((state: GitActionDialogState) => {
		const values: Record<string, string | boolean> = {};
		for (const field of state.fields) values[field.name] = field.value ?? (field.checkbox ? false : "");
		setDialogValues(values);
		setActionDialog(state);
	}, []);

	const closeActionDialog = React.useCallback(() => {
		setActionDialog(null);
		setDialogValues({});
	}, []);

	const submitActionDialog = React.useCallback(() => {
		if (!actionDialog) return;
		for (const field of actionDialog.fields) {
			if (field.required && !field.checkbox && String(dialogValues[field.name] ?? "").trim() === "") return;
		}
		actionDialog.onSubmit(dialogValues);
		closeActionDialog();
	}, [actionDialog, closeActionDialog, dialogValues]);

	const openConfirmDialog = React.useCallback((state: GitConfirmDialogState) => {
		setConfirmDialog(state);
	}, []);

	const submitConfirmDialog = React.useCallback(() => {
		if (!confirmDialog) return;
		confirmDialog.onConfirm();
		setConfirmDialog(null);
	}, [confirmDialog]);

	const refresh = React.useCallback(async () => {
		setLoading(true);
		try {
			const res = await Service.gitSummary({ repoPath: projectRoot });
			setSummary(prev => {
				if (isTransientSummaryFailure(res) && prev?.success && prev.isRepo) return prev;
				return res;
			});
			if (res.success && res.status?.data?.files) {
				const statusFiles = res.status.data.files as Service.GitFileStatus[];
				setExpanded(prev => {
					const nextExpanded = new Set(prev);
					for (const file of statusFiles) {
						const parts = file.path.split(/[\\/]+/);
						for (let i = 1; i < parts.length; i++) nextExpanded.add(parts.slice(0, i).join("/"));
					}
					return nextExpanded;
				});
			}
		} catch (err) {
			void err;
			showAlert("Failed to refresh Git state", "error");
		} finally {
			setLoading(false);
		}
	}, [projectRoot, showAlert]);

	React.useEffect(() => {
		setSummary(null);
		setSelectedCommitHash(null);
		setSelectedCommitFilePath("");
		setCommitDiffPreview(null);
		setSelectedBranchName(null);
		setSelectedRemoteName(null);
		setSelectedRemoteBranch(null);
		setSelected({ unstaged: new Set(), staged: new Set() });
		setLastRow({ unstaged: null, staged: null });
		setDiffPreview(null);
	}, [projectRoot]);

	React.useEffect(() => {
		void refresh();
	}, [refresh]);

	const loadSettings = React.useCallback(async () => {
		const [profileRes, authRes] = await Promise.all([Service.gitProfileGet(), Service.gitAuthList()]);
		if (profileRes.success && profileRes.profile) setProfile(profileRes.profile);
		if (authRes.success) setCredentials(asArray<Service.GitCredentialMeta>(authRes.items));
	}, []);

	React.useEffect(() => {
		void loadSettings();
	}, [loadSettings]);

	const openSettings = React.useCallback((tab: "profile" | "credentials" = "profile") => {
		setSettingsTab(tab);
		setSettingsOpen(true);
		void loadSettings();
	}, [loadSettings]);

	const pollJob = React.useCallback((jobId: number, command: string, onDone?: (status: Service.GitStatus) => void) => {
		setJob({ jobId, command, startedAt: Date.now() });
		const timer = window.setInterval(async () => {
			const res = await Service.gitStatus({ jobId });
			if (!res.success) {
				window.clearInterval(timer);
				showAlert(res.message ?? "Git job status failed", "error");
				return;
			}
			setJob(current => current?.jobId === jobId ? { ...current, status: res.status } : current);
			if (terminalStates.has(res.status.state)) {
				window.clearInterval(timer);
				if (res.status.state === "done") {
					showAlert(`${command} completed`, "success");
				} else if (res.status.state === "error") {
					showAlert(res.status.error ?? res.status.message ?? `${command} failed`, "error");
				}
				onDone?.(res.status);
				void refresh();
			}
		}, 600);
	}, [refresh, showAlert]);

	const runCommand = React.useCallback(async (command: string, onDone?: (status: Service.GitStatus) => void, authId?: number) => {
		const res = await Service.gitRun({ repoPath: projectRoot, command, authId });
		if (!res.success) {
			const credentialItems = asArray<Service.GitCredentialMeta>(res.credentials);
			if (res.needsCredentialSelection && credentialItems.length > 0) {
				pendingCredentialDoneRef.current = onDone;
				setPendingCredential({ command, host: res.host, credentials: credentialItems });
				return;
			}
			showAlert(res.message ?? `Failed to start ${command}`, "error");
			return;
		}
		pollJob(res.jobId, command, onDone);
	}, [pollJob, projectRoot, showAlert]);

	const runPendingCredential = React.useCallback((authId: number) => {
		if (!pendingCredential) return;
		const { command } = pendingCredential;
		const onDone = pendingCredentialDoneRef.current;
		pendingCredentialDoneRef.current = undefined;
		setPendingCredential(null);
		void runCommand(command, onDone, authId);
	}, [pendingCredential, runCommand]);

	const cancelJob = React.useCallback(async () => {
		if (!job || (job.status && terminalStates.has(job.status.state))) return;
		const res = await Service.gitCancel({ jobId: job.jobId });
		if (!res.success) {
			showAlert(res.message ?? "Failed to cancel Git job", "error");
			return;
		}
		setJob(current => current?.jobId === job.jobId ? {
			...current,
			status: {
				...(current.status ?? {
					id: job.jobId,
					kind: "status",
					repoPath: projectRoot,
				}),
				state: "canceled",
				progress: current.status?.progress ?? 0,
				message: "canceled",
			},
		} : current);
	}, [job, projectRoot, showAlert]);

	const selectedPaths = React.useCallback((section: ChangeSection) => {
		const source = section === "unstaged" ? files.unstaged : files.staged;
		const selectedSet = selected[section];
		const paths = new Set<string>();
		for (const key of selectedSet) {
			const [, type, rowPath] = key.split(/:(dir|file):/);
			if (!rowPath) continue;
			if (type === "file") {
				paths.add(rowPath);
			} else {
				for (const file of source) {
					if (file.path === rowPath || file.path.startsWith(`${rowPath}/`)) paths.add(file.path);
				}
			}
		}
		return Array.from(paths);
	}, [files.staged, files.unstaged, selected]);

	const onRowClick = React.useCallback((section: ChangeSection, row: GitRow, index: number, rows: GitRow[], event: React.MouseEvent) => {
		setSelected(prev => {
			const next = new Set(prev[section]);
			if (event.shiftKey && lastRow[section] !== null) {
				next.clear();
				const start = Math.min(lastRow[section] ?? index, index);
				const end = Math.max(lastRow[section] ?? index, index);
				for (let i = start; i <= end; i++) next.add(rows[i].key);
			} else {
				next.clear();
				next.add(row.key);
			}
			return {
				unstaged: section === "unstaged" ? next : new Set<string>(),
				staged: section === "staged" ? next : new Set<string>(),
			};
		});
		setLastRow(prev => ({ ...prev, [section]: index }));
	}, [lastRow]);

	const toggleRowExpanded = React.useCallback((path: string) => {
		setExpanded(prev => {
			const next = new Set(prev);
			if (next.has(path)) next.delete(path);
			else next.add(path);
			return next;
		});
	}, []);

	const toggleCommitRowExpanded = React.useCallback((path: string) => {
		setCommitExpanded(prev => {
			const next = new Set(prev);
			if (next.has(path)) next.delete(path);
			else next.add(path);
			return next;
		});
	}, []);

	const stageSelected = React.useCallback(() => {
		const paths = selectedPaths("unstaged");
		if (paths.length === 0) return;
		void runCommand(`add ${paths.map(quoteArg).join(" ")}`);
	}, [runCommand, selectedPaths]);

	const unstageSelected = React.useCallback(() => {
		const paths = selectedPaths("staged");
		if (paths.length === 0) return;
		void runCommand(`restore --staged ${paths.map(quoteArg).join(" ")}`);
	}, [runCommand, selectedPaths]);

	const discardSelected = React.useCallback(async () => {
		const paths = selectedPaths("unstaged");
		if (paths.length === 0) return;
		const tracked = files.unstaged.filter(file => paths.includes(file.path) && file.status !== "?").map(file => file.path);
		const untracked = files.unstaged.filter(file => paths.includes(file.path) && file.status === "?").map(file => file.path);
		const commands = [
			tracked.length > 0 ? `restore --worktree ${tracked.map(quoteArg).join(" ")}` : "",
			untracked.length > 0 ? `delete untracked ${untracked.map(quoteArg).join(" ")}` : "",
		].filter(Boolean);
		const rawCommand = commands.join(" && ");
		openConfirmDialog({
			title: "Discard Changes",
			detail: `${paths.length} selected path(s) in ${displayPath ?? projectRoot}`,
			command: rawCommand,
			submitLabel: "Discard",
			danger: true,
			onConfirm: async () => {
				if (tracked.length > 0) void runCommand(`restore --worktree ${tracked.map(quoteArg).join(" ")}`);
				if (untracked.length > 0) {
					const res = await Service.gitDiscardUntracked({ repoPath: projectRoot, paths: untracked });
					if (res.success) {
						showAlert(`Removed ${res.removed?.length ?? 0} untracked file(s)`, "success");
						void refresh();
					} else {
						showAlert(res.message ?? "Failed to discard untracked files", "error");
					}
				}
			}
		});
	}, [displayPath, files.unstaged, openConfirmDialog, projectRoot, refresh, runCommand, selectedPaths, showAlert]);

	const commit = React.useCallback(() => {
		const subject = commitMessage.trim();
		const description = commitDescription.trim();
		const message = description ? `${subject}\n\n${description}` : subject;
		if (message === "" || stagedCount === 0) return;
		const missingProfile = profile.name.trim() === "" || profile.email.trim() === "";
		if (missingProfile) {
			openConfirmDialog({
				title: "Missing Git Profile",
				detail: "Author name or email is empty. Configure the profile before committing, or continue with the runtime default author.",
				command: `commit -m ${quoteArg(message)}`,
				submitLabel: "Continue",
				onConfirm: () => {
					void runCommand(`commit -m ${quoteArg(message)}`, () => {
						setCommitMessage("");
						setCommitDescription("");
					});
				},
			});
			return;
		}
		const author = [
			profile.name.trim() ? `--author-name ${quoteArg(profile.name.trim())}` : "",
				profile.email.trim() ? `--author-email ${quoteArg(profile.email.trim())}` : "",
			].filter(Boolean).join(" ");
			void runCommand(`commit -m ${quoteArg(message)} ${author}`.trim(), () => {
				setCommitMessage("");
				setCommitDescription("");
			});
		}, [commitDescription, commitMessage, openConfirmDialog, profile.email, profile.name, runCommand, stagedCount]);

	const initRepo = React.useCallback(() => {
		void runCommand("init");
	}, [runCommand]);

	const cloneRepo = React.useCallback(async () => {
		const url = cloneUrl.trim();
		const dir = cloneDir.trim();
		const branch = cloneBranch.trim();
		const depth = cloneDepth.trim();
		if (url === "") return;
		if (depth !== "" && !/^[1-9]\d*$/.test(depth)) {
			showAlert("Clone depth must be a positive integer", "warning");
			return;
		}
		if (dir !== "") {
			const target = joinPath(projectRoot, dir);
			const existRes = await Service.exist({ file: target });
			if (existRes.success) {
				const listRes = await Service.list({ path: target });
				if (listRes.success && (listRes.files?.length ?? 0) > 0) {
					showAlert("Clone target directory is not empty", "warning");
					return;
				}
			}
		}
		const command = `clone ${quoteArg(url)}${dir ? ` ${quoteArg(dir)}` : ""}${branch ? ` -b ${quoteArg(branch)}` : ""}${depth ? ` --depth ${depth}` : ""}`;
		void runCommand(command, status => {
			const clonedPath = status.data?.path ?? (dir ? joinPath(projectRoot, dir) : "");
			if (clonedPath) onOpenProject?.(clonedPath);
		});
	}, [cloneBranch, cloneDepth, cloneDir, cloneUrl, onOpenProject, projectRoot, runCommand, showAlert]);

	const runFetch = React.useCallback(() => {
		if (!summary?.success || !summary.isRepo) return;
		const defaultRemote = summary.defaultRemote?.name ?? remoteNames[0] ?? "origin";
		openActionDialog({
			title: "Fetch Remote",
			detail: displayPath ?? projectRoot,
			submitLabel: "Fetch",
			fields: [
				{ name: "remote", label: "Remote", value: defaultRemote, required: true, options: remoteNames },
				{ name: "force", label: "Force", value: false, checkbox: true },
				{ name: "prune", label: "Prune", value: false, checkbox: true },
			],
			onSubmit: values => {
				const remote = String(values.remote ?? "").trim();
				if (!remote) return;
				const options = [
					values.force === true ? "-f" : "",
					values.prune === true ? "-p" : "",
				].filter(Boolean).join(" ");
				void runCommand(`fetch${options ? ` ${options}` : ""} ${quoteArg(remote)}`);
			},
		});
	}, [displayPath, openActionDialog, projectRoot, remoteNames, runCommand, summary]);

	const runPullPush = React.useCallback((kind: "pull" | "push") => {
		if (!summary?.success || !summary.isRepo) return;
		const defaultRemote = summary.defaultRemote?.name ?? remoteNames[0] ?? "origin";
		const defaultBranch = preferredRemoteBranch(defaultRemote, summary.currentBranch ?? "");
		openActionDialog({
			title: kind === "pull" ? "Pull Branch" : "Push Branch",
			detail: displayPath ?? projectRoot,
			submitLabel: kind === "pull" ? "Pull" : "Push",
				fields: [
					{ name: "remote", label: "Remote", value: defaultRemote, required: true, options: remoteNames },
					{
						name: "branch",
						label: kind === "pull" ? "Remote branch" : "Remote branch",
						value: defaultBranch,
						required: true,
						options: values => remoteBranchNames(String(values.remote ?? "")),
					},
						...(kind === "push" ? [
							{ name: "setUpstream", label: "Set upstream", value: false, checkbox: true },
							{ name: "force", label: "Force", value: false, checkbox: true },
						] : [
							{ name: "force", label: "Force", value: false, checkbox: true },
						]),
					],
					onSubmit: values => {
						const remote = String(values.remote ?? "").trim();
						const branch = String(values.branch ?? "").trim();
						if (!remote || !branch) return;
						const setUpstream = kind === "push" && values.setUpstream === true;
						const force = values.force === true;
						const options = [
							setUpstream ? "-u" : "",
							force ? "-f" : "",
						].filter(Boolean).join(" ");
						const command = `${kind}${options ? ` ${options}` : ""} ${quoteArg(remote)} ${quoteArg(branch)}`;
						if (force) {
							const forceTitle = kind === "push" ? "Force Push" : "Force Pull";
							openConfirmDialog({
								title: forceTitle,
								detail: kind === "push"
									? `This will overwrite ${remote}/${branch} with the local branch history.`
									: `This will force update local refs while pulling ${remote}/${branch}.`,
								command,
								submitLabel: forceTitle,
								danger: true,
								onConfirm: () => {
									void runCommand(command);
							},
						});
						return;
					}
					void runCommand(command);
				},
			});
		}, [displayPath, openActionDialog, openConfirmDialog, preferredRemoteBranch, projectRoot, remoteBranchNames, remoteNames, runCommand, summary]);

	const saveProfile = React.useCallback(async () => {
		const res = await Service.gitProfileSave(profile);
		showAlert(res.success ? "Git profile saved" : (res.message ?? "Failed to save Git profile"), res.success ? "success" : "error");
	}, [profile, showAlert]);

	const saveCredential = React.useCallback(async () => {
		const res = await Service.gitAuthSave({
			host: credentialForm.host.trim(),
			label: credentialForm.label.trim(),
			type: credentialForm.type,
			username: credentialForm.username.trim(),
			password: credentialForm.type === "basic" ? credentialForm.secret : undefined,
			token: credentialForm.type === "token" ? credentialForm.secret : undefined,
		});
		if (!res.success) {
			showAlert(res.message ?? "Failed to save credential", "error");
			return;
		}
		setCredentialForm({ host: "", label: "", type: "token", username: "", secret: "" });
		await loadSettings();
		showAlert("Git credential saved", "success");
	}, [credentialForm, loadSettings, showAlert]);

	const runSecondary = React.useCallback((command: string, confirmText?: string, danger = false) => {
		if (confirmText) {
			openConfirmDialog({
				title: confirmText,
				detail: displayPath ?? projectRoot,
				command,
				submitLabel: danger ? "Confirm" : "Run",
				danger,
				onConfirm: () => { void runCommand(command); },
			});
			return;
		}
		void runCommand(command);
	}, [displayPath, openConfirmDialog, projectRoot, runCommand]);

	const renderRows = (section: ChangeSection, rows: GitRow[]) => (
		<GitFileTree
			rows={rows}
			containerSx={{ overflow: "hidden", minHeight: 0, flex: 1 }}
			expanded={expanded}
			preventShiftSelection
			isRowSelected={row => selected[section].has(row.key)}
			onRowClick={(row, index, event) => onRowClick(section, row, index, rows, event)}
			onToggleDir={toggleRowExpanded}
		/>
	);

	const modeButton = (mode: GitPreviewMode, label: string) => (
		<Button
			size="small"
			fullWidth
			onClick={() => setPreviewMode(mode)}
			sx={{
				justifyContent: "flex-start",
				height: 28,
				borderRadius: 1,
				px: 1.25,
				color: previewMode === mode ? primaryText : mutedText,
				backgroundColor: previewMode === mode ? "#444" : "transparent",
				textTransform: "none",
				fontWeight: previewMode === mode ? 700 : 500,
				"&:hover": { backgroundColor: previewMode === mode ? "#4a4a4a" : "#242424" },
			}}
		>
			{label}
		</Button>
	);

	const branchActionButtons = (
		<Stack direction="row" spacing={0.75} flexWrap="wrap" useFlexGap>
			<Button size="small" sx={toolButtonSx} onClick={() => openActionDialog({
				title: "Create Branch",
				submitLabel: "Create",
				fields: [{ name: "name", label: "Branch name", required: true }],
				onSubmit: values => {
					const name = String(values.name ?? "").trim();
					if (name) runSecondary(`branch ${quoteArg(name)}`);
				},
			})}>Create</Button>
			{selectedBranch ? (
				<>
					<Button size="small" sx={toolButtonSx} onClick={() => runSecondary(`checkout ${quoteArg(selectedBranch.name)}`, "Checkout Branch")} disabled={selectedBranch.current}>Checkout</Button>
					<Button size="small" sx={toolButtonSx} onClick={() => runSecondary(`branch -d ${quoteArg(selectedBranch.name)}`, "Delete Branch", true)} disabled={selectedBranch.current}>Delete</Button>
				</>
			) : null}
		</Stack>
	);

	const remoteActionButtons = (
		<Stack direction="row" spacing={0.75} flexWrap="wrap" useFlexGap>
			<Button size="small" sx={toolButtonSx} onClick={() => openActionDialog({
				title: "Add Remote",
				submitLabel: "Add",
				fields: [
					{ name: "name", label: "Remote name", value: "origin", required: true },
					{ name: "url", label: "Remote URL", required: true },
				],
				onSubmit: values => {
					const name = String(values.name ?? "").trim();
					const url = String(values.url ?? "").trim();
					if (name && url) {
						if (summary?.success && summary.remotes?.some(remote => remote.name === name)) {
							showAlert(`Remote "${name}" already exists`, "warning");
							return;
						}
						runSecondary(`remote add ${quoteArg(name)} ${quoteArg(url)}`);
					}
				},
			})}>Add</Button>
			{selectedRemote ? (
				<>
					<Button size="small" sx={toolButtonSx} onClick={() => openActionDialog({
						title: `Edit Remote: ${selectedRemote.name}`,
						submitLabel: "Save",
						fields: [{ name: "url", label: "Remote URL", value: selectedRemote.urls?.[0] ?? "", required: true }],
						onSubmit: values => {
							const url = String(values.url ?? "").trim();
							if (url) runSecondary(`remote set-url ${quoteArg(selectedRemote.name)} ${quoteArg(url)}`, "Set Remote URL");
						},
					})}>Edit</Button>
					<Button size="small" sx={toolButtonSx} onClick={() => runSecondary(`remote remove ${quoteArg(selectedRemote.name)}`, "Remove Remote", true)}>Remove</Button>
				</>
			) : null}
			{selectedRemoteBranch ? (
				<Button size="small" sx={toolButtonSx} onClick={() => openActionDialog({
					title: `Checkout ${selectedRemoteBranch.remote}/${selectedRemoteBranch.name}`,
					submitLabel: "Checkout",
					fields: [{ name: "branch", label: "Local branch name", value: selectedRemoteBranch.name, required: true }],
					onSubmit: values => {
						const branch = String(values.branch ?? "").trim();
						if (!branch) return;
						if (localBranches.some(item => item.name === branch)) {
							showAlert(`Branch "${branch}" already exists`, "warning");
							return;
						}
						runSecondary(`checkout -b ${quoteArg(branch)} ${quoteArg(`${selectedRemoteBranch.remote}/${selectedRemoteBranch.name}`)}`, "Checkout Remote Branch");
					},
				})}>Checkout</Button>
			) : null}
		</Stack>
	);

	const tagActionButtons = (
		<Stack direction="row" spacing={0.75} flexWrap="wrap" useFlexGap>
			<Button size="small" sx={toolButtonSx} onClick={() => openActionDialog({
				title: "Create Tag",
				submitLabel: "Create",
				fields: [{ name: "name", label: "Tag name", required: true }],
				onSubmit: values => {
					const name = String(values.name ?? "").trim();
					if (name) runSecondary(`tag ${quoteArg(name)}`);
				},
			})}>Create</Button>
			{selectedTag ? (
				<Button size="small" sx={toolButtonSx} onClick={() => runSecondary(`tag -d ${quoteArg(selectedTag.name)}`, "Delete Tag", true)}>Delete</Button>
			) : null}
		</Stack>
	);

	const renderCommitRefChip = (ref: CommitRefChip, active: boolean) => {
		const isTag = ref.type === "tag";
		const Icon = isTag ? LocalOfferIcon : CallSplitIcon;
		const activeColor = isTag ? "#171717" : primaryText;
		const inactiveColor = isTag ? accent : primaryText;
		return (
			<Chip
				key={ref.key}
				icon={<Icon sx={{ fontSize: "14px !important" }} />}
				label={ref.label}
				size="small"
				sx={{
					height: 20,
					borderRadius: 0,
					border: `1px solid ${active ? accent : "rgba(250, 192, 61, 0.58)"}`,
					color: active ? activeColor : inactiveColor,
					backgroundColor: active
						? (isTag ? accent : "rgba(250, 192, 61, 0.18)")
						: (isTag ? "rgba(250, 192, 61, 0.12)" : "rgba(250, 192, 61, 0.08)"),
					transition: "none",
					"& .MuiChip-label": { px: 0.6, fontSize: 12, fontWeight: 700 },
					"& .MuiChip-icon": { color: active ? activeColor : inactiveColor, ml: 0.5, transition: "none" },
				}}
			/>
		);
	};

	const sidebar = (
		<Box sx={{ ...panelSx, overflow: "hidden", display: "flex", flexDirection: "column", minHeight: 0 }}>
			<Box sx={{ p: 1.25, borderBottom: `1px solid ${panelBorder}` }}>
				<Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ mb: 1 }}>
					<Typography variant="subtitle1" noWrap sx={{ color: primaryText, fontWeight: 700 }}>Status</Typography>
				</Stack>
				<Stack spacing={0.25}>
					{modeButton("local", `Local Changes (${localChangeCount})`)}
					{modeButton("commits", "All Commits")}
				</Stack>
			</Box>
			<MacScrollbar skin="dark" style={{ flex: 1, minHeight: 0 }}>
				<Stack spacing={1.25} sx={{ p: 1 }}>
					<Box>
						<Typography variant="caption" sx={{ color: primaryText, fontWeight: 700 }}>Branches</Typography>
						<Stack spacing={0.25} sx={{ mt: 0.5 }}>
							{localBranches.map(branch => (
								<Button
									key={branch.name}
									size="small"
									onClick={() => {
										setSelectedBranchName(branch.name);
										setSelectedRemoteName(null);
										setSelectedRemoteBranch(null);
										setSelectedTagName(null);
									}}
									sx={{
										justifyContent: "flex-start",
										height: 26,
										px: 0.75,
										borderRadius: 1,
										color: branch.current || selectedBranchName === branch.name ? primaryText : Color.TextSecondary,
										background: selectedBranchName === branch.name ? accentSoft : "transparent",
										textTransform: "none",
										fontWeight: branch.current || selectedBranchName === branch.name ? 700 : 500,
										"&:hover": { background: selectedBranchName === branch.name ? "rgba(250, 192, 61, 0.22)" : "#242424" },
									}}
								>
									{branch.current ? "✓ " : ""}{branch.name}{branch.unborn ? " (unborn)" : ""}
								</Button>
							))}
						</Stack>
						<Box sx={{ mt: 0.75 }}>{branchActionButtons}</Box>
					</Box>
					<Box>
						<Typography variant="caption" sx={{ color: primaryText, fontWeight: 700 }}>Remotes</Typography>
						<Stack spacing={0.25} sx={{ mt: 0.5 }}>
							{summary?.success && summary.remotes?.map(remote => (
								<Box key={remote.name}>
									<Stack
										direction="row"
										alignItems="center"
										spacing={0.5}
										onClick={() => {
											setSelectedBranchName(null);
											setSelectedRemoteName(remote.name);
											setSelectedRemoteBranch(null);
											setSelectedTagName(null);
										}}
										sx={{
											height: 26,
											px: 0.75,
											cursor: "pointer",
											background: selectedRemoteName === remote.name ? accentSoft : "transparent",
											"&:hover": { background: selectedRemoteName === remote.name ? "rgba(250, 192, 61, 0.22)" : "#242424" },
										}}
									>
										<ArrowDropDownIcon sx={{ fontSize: 18, color: mutedText }} />
										<Typography variant="body2" noWrap sx={{ color: primaryText, fontSize: 13, fontWeight: 700 }}>{remote.name}</Typography>
									</Stack>
									<Stack spacing={0.1}>
										{(remoteBranchRowsByRemote.get(remote.name) ?? []).map(row => {
											const selectedBranch = row.type === "branch" && selectedRemoteBranch?.remote === remote.name && selectedRemoteBranch.name === row.branch?.name;
											return (
												<Stack
													key={row.key}
													direction="row"
													alignItems="center"
													spacing={0.6}
													onClick={() => {
														if (row.type === "branch" && row.branch) {
															setSelectedBranchName(null);
															setSelectedRemoteName(null);
															setSelectedRemoteBranch({ remote: remote.name, name: row.branch.name });
															setSelectedTagName(null);
														}
													}}
													sx={{
														height: 24,
														pl: 3 + row.depth * 1.4,
														pr: 0.75,
														color: Color.TextSecondary,
														cursor: row.type === "branch" ? "pointer" : "default",
														background: selectedBranch ? accentSoft : "transparent",
														"&:hover": { background: row.type === "branch" ? (selectedBranch ? "rgba(250, 192, 61, 0.22)" : "#242424") : "transparent" },
													}}
												>
													{row.type === "dir" ? <FolderIcon sx={{ fontSize: 15 }} /> : <CallSplitIcon sx={{ fontSize: 14 }} />}
													<Typography variant="body2" noWrap sx={{ color: primaryText, fontSize: 12, fontWeight: row.type === "dir" ? 700 : 500 }}>{row.name}</Typography>
												</Stack>
											);
										})}
									</Stack>
								</Box>
							))}
						</Stack>
						<Box sx={{ mt: 0.75 }}>{remoteActionButtons}</Box>
					</Box>
				<Box>
					<Typography variant="caption" sx={{ color: primaryText, fontWeight: 700 }}>Tags</Typography>
					<Stack spacing={0.25} sx={{ mt: 0.75 }}>
						{tagList.length === 0 ? (
							<Typography variant="body2" sx={{ color: mutedText, fontSize: 12 }}>No tags</Typography>
						) : tagList.map(tag => {
							const selected = selectedTagName === tag.name;
							return (
							<Stack
								key={tag.name}
								direction="row"
								alignItems="center"
								spacing={0.75}
								onClick={() => {
									setSelectedBranchName(null);
									setSelectedRemoteName(null);
									setSelectedRemoteBranch(null);
									setSelectedTagName(tag.name);
									setSelectedCommitHash(tag.hash);
									setPreviewMode("commits");
								}}
								sx={{
									height: 26,
									px: 0.75,
									cursor: "pointer",
									color: primaryText,
									background: selected ? accentSoft : "transparent",
									"&:hover": { backgroundColor: selected ? "rgba(250, 192, 61, 0.22)" : "#242424" },
								}}
							>
								<LocalOfferIcon sx={{ fontSize: 15, color: selected ? accent : Color.TextSecondary }} />
								<Typography variant="body2" noWrap sx={{ minWidth: 0, fontSize: 12, fontWeight: selected ? 700 : 600 }}>{tag.name}</Typography>
							</Stack>
							);
						})}
					</Stack>
					<Box sx={{ mt: 0.75 }}>{tagActionButtons}</Box>
				</Box>
				</Stack>
			</MacScrollbar>
		</Box>
	);

	const commitForm = (
		<Box sx={{ borderTop: `1px solid ${panelBorder}`, background: "#202020", p: 1 }}>
			<Stack spacing={0.75}>
				<TextField
					size="small"
					fullWidth
					placeholder="Commit subject"
					value={commitMessage}
					onChange={(event) => setCommitMessage(event.target.value)}
				/>
				<TextField
					size="small"
					fullWidth
					placeholder="Description"
					value={commitDescription}
					onChange={(event) => setCommitDescription(event.target.value)}
					multiline
					minRows={2}
					maxRows={4}
				/>
					<Stack direction="row" alignItems="center" justifyContent="flex-end">
						<Button variant="contained" onClick={commit} disabled={stagedCount === 0 || commitMessage.trim() === ""} sx={commitButtonSx}>Commit</Button>
					</Stack>
			</Stack>
		</Box>
	);

	const localChangesView = (
		<Box sx={{ display: "grid", gridTemplateColumns: "380px minmax(0, 1fr)", minHeight: 0, flex: 1, border: `1px solid ${panelBorder}`, background: panelBg }}>
			<Box sx={{ borderRight: `1px solid ${panelBorder}`, display: "flex", flexDirection: "column", minHeight: 0 }}>
				<Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ height: 36, px: 1, background: "#262626", borderBottom: `1px solid ${panelBorder}` }}>
					<Typography variant="subtitle2" sx={{ color: primaryText }}>Unstaged</Typography>
					<Stack direction="row" spacing={0.75}>
						<Button size="small" sx={toolButtonSx} onClick={stageSelected} disabled={selected.unstaged.size === 0}>Stage</Button>
						<IconButton size="small" sx={{ ...iconButtonSx, width: 28, height: 28 }} onClick={(event) => setMoreAnchor({ section: "unstaged", anchor: event.currentTarget })}><MoreHorizIcon fontSize="small" /></IconButton>
					</Stack>
				</Stack>
				<Box sx={{ flex: 1, minHeight: 0 }}>{renderRows("unstaged", unstagedRows)}</Box>
				<Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ height: 36, px: 1, background: "#262626", borderTop: `1px solid ${panelBorder}`, borderBottom: `1px solid ${panelBorder}` }}>
					<Typography variant="subtitle2" sx={{ color: primaryText }}>Staged</Typography>
					<Button size="small" sx={toolButtonSx} onClick={unstageSelected} disabled={selected.staged.size === 0}>Unstage</Button>
				</Stack>
				<Box sx={{ flex: 1, minHeight: 0 }}>{renderRows("staged", stagedRows)}</Box>
			</Box>
			<Box sx={{ display: "flex", flexDirection: "column", minHeight: 0 }}>
				<Box sx={{ height: 36, px: 1.25, display: "flex", alignItems: "center", justifyContent: "space-between", borderBottom: `1px solid ${panelBorder}`, background: "#202020" }}>
					<Typography variant="body2" noWrap sx={{ color: primaryText }}>{selectedLocalPath || "Local Changes"}</Typography>
					<Stack direction="row" spacing={0.75}>
						<Button size="small" sx={toolButtonSx} onClick={discardSelected} disabled={selected.unstaged.size === 0}>Discard</Button>
						<Button size="small" sx={toolButtonSx} onClick={() => selectedLocalPath && onOpenFile?.(selectedLocalPath)} disabled={!selectedLocalPath}>Open</Button>
					</Stack>
				</Box>
				<GitDiffPreview path={selectedLocalPath} preview={diffPreview} />
				{commitForm}
			</Box>
		</Box>
	);

	const allCommitsView = (
		<Box sx={{ display: "grid", gridTemplateRows: "minmax(240px, 42%) minmax(0, 1fr)", minHeight: 0, flex: 1, border: `1px solid ${panelBorder}`, background: panelBg }}>
			<Box sx={{ minHeight: 0, overflow: "hidden", borderBottom: `1px solid ${panelBorder}` }}>
				<MacScrollbar skin="dark" style={{ height: "100%" }}>
					{commitList.length === 0 ? (
						<Typography variant="body2" sx={{ color: mutedText, p: 2 }}>No commits</Typography>
					) : commitList.map((commitItem, index) => {
						const active = selectedCommit?.hash === commitItem.hash;
						const commitRefs = refsByHash.get(commitItem.hash) ?? [];
						return (
							<Box
								key={commitItem.hash}
								onClick={() => setSelectedCommitHash(commitItem.hash)}
								sx={{
									display: "grid",
									gridTemplateColumns: "44px minmax(360px, 1fr) 96px 88px 132px",
									alignItems: "center",
									height: 28,
									px: 1,
									gap: 1,
									cursor: "pointer",
									color: active ? primaryText : primaryText,
									background: active ? accentSoft : "transparent",
									boxShadow: active ? `inset 3px 0 0 ${accent}` : "none",
									"&:hover": { background: active ? "rgba(250, 192, 61, 0.22)" : "#242424" },
								}}
								>
									<Box sx={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
										<Box sx={{ width: 10, height: 10, borderRadius: "50%", background: index === 0 ? accent : "#8f9aa6", boxShadow: `0 0 0 2px ${active ? "rgba(250, 192, 61, 0.38)" : "#333"}` }} />
									</Box>
									<Stack direction="row" alignItems="center" spacing={0.5} sx={{ minWidth: 0, overflow: "hidden" }}>
										{commitRefs.map(ref => renderCommitRefChip(ref, active))}
										<Typography variant="body2" noWrap sx={{ minWidth: 0, fontWeight: active ? 700 : 500, fontSize: 13 }}>{commitItem.message}</Typography>
									</Stack>
									<Typography variant="body2" noWrap sx={{ fontSize: 13, color: active ? primaryText : Color.TextSecondary }}>{commitItem.author}</Typography>
									<Typography variant="body2" noWrap sx={{ fontFamily: "monospace", fontSize: 13, color: active ? primaryText : Color.TextSecondary }}>{commitItem.hash.slice(0, 8)}</Typography>
									<Typography variant="body2" noWrap title={commitItem.when} sx={{ fontSize: 13, color: active ? primaryText : Color.TextSecondary }}>{formatCommitTime(commitItem.when)}</Typography>
							</Box>
						);
					})}
				</MacScrollbar>
			</Box>
			<Box sx={{ minHeight: 0, display: "flex", flexDirection: "column" }}>
				<Tabs value={commitDetailTab} onChange={(_, value) => setCommitDetailTab(value)} sx={{ minHeight: 34, borderBottom: `1px solid ${panelBorder}`, "& .MuiTab-root": { minHeight: 34, py: 0.5 } }}>
					<Tab value="commit" label="Commit" />
					<Tab value="changes" label="Changes" />
				</Tabs>
				{commitDetailTab === "commit" ? (
					<MacScrollbar skin="dark" style={{ flex: 1, minHeight: 0 }}>
						<Box sx={{ p: 2 }}>
							{selectedCommit ? (
								<>
									<Stack direction="row" spacing={1.5} alignItems="center" sx={{ mb: 1.5 }}>
										<Box sx={{ width: 44, height: 44, borderRadius: 1, background: "#333", border: `1px solid ${panelBorder}` }} />
										<Box sx={{ minWidth: 0 }}>
											<Typography variant="subtitle1" noWrap sx={{ color: primaryText, fontWeight: 700 }}>{selectedCommit.author}</Typography>
											<Typography variant="caption" noWrap sx={{ display: "block", color: mutedText }}>{selectedCommit.email} · {selectedCommit.when}</Typography>
										</Box>
									</Stack>
									<Stack spacing={1.25}>
										<Typography variant="h6" sx={{ color: primaryText, fontSize: 18 }}>{selectedCommit.message}</Typography>
										<Stack spacing={0.5}>
											<Typography variant="body2" sx={{ color: mutedText }}>SHA <Box component="span" sx={{ color: primaryText, fontFamily: "monospace" }}>{selectedCommit.hash}</Box></Typography>
											<Typography variant="body2" sx={{ color: mutedText }}>Branch <Box component="span" sx={{ color: primaryText }}>{summary?.success ? summary.currentBranch ?? "detached" : "-"}</Box></Typography>
										</Stack>
										<Stack direction="row" spacing={0.75}>
											<Button size="small" sx={toolButtonSx} onClick={() => runSecondary(`checkout ${quoteArg(selectedCommit.hash)}`, "Checkout Commit")}>Checkout</Button>
											<Button size="small" sx={toolButtonSx} onClick={() => runSecondary(`reset --hard ${quoteArg(selectedCommit.hash)} --confirm`, "Reset Hard", true)}>Reset</Button>
										</Stack>
									</Stack>
								</>
							) : (
								<Typography variant="body2" sx={{ color: mutedText }}>No commit selected</Typography>
							)}
						</Box>
					</MacScrollbar>
				) : selectedCommit ? (
					<Box sx={{ flex: 1, minHeight: 0, display: "grid", gridTemplateColumns: "320px minmax(0, 1fr)" }}>
						<Box sx={{ minHeight: 0, borderRight: `1px solid ${panelBorder}`, display: "flex", flexDirection: "column" }}>
							<Box sx={{ height: 34, display: "grid", gridTemplateColumns: "minmax(0, 1fr) 74px 120px", alignItems: "center", gap: 1, px: 1, borderBottom: `1px solid ${panelBorder}`, background: "#202020" }}>
								<Typography variant="body2" noWrap sx={{ color: primaryText, fontWeight: 700 }}>{selectedCommit.author}</Typography>
								<Typography variant="body2" noWrap sx={{ color: mutedText, fontFamily: "monospace" }}>{selectedCommit.hash.slice(0, 7)}</Typography>
								<Typography variant="body2" noWrap sx={{ color: mutedText }}>{selectedCommit.when}</Typography>
							</Box>
							<GitFileTree
								rows={commitFileRows}
								containerSx={{ flex: 1, minHeight: 0 }}
								scrollbarStyle={{ height: "100%" }}
								expanded={commitExpanded}
								isRowSelected={row => row.type === "file" && row.path === selectedCommitFilePath}
								isRowInteractive={row => row.type === "file"}
								onRowClick={row => {
									if (row.type === "file") setSelectedCommitFilePath(row.path);
								}}
								onToggleDir={toggleCommitRowExpanded}
							/>
						</Box>
						<Box sx={{ minHeight: 0, display: "flex", flexDirection: "column" }}>
							<Box sx={{ height: 34, display: "flex", alignItems: "center", px: 1.25, borderBottom: `1px solid ${panelBorder}`, background: "#202020" }}>
								<Typography variant="body2" noWrap sx={{ color: primaryText }}>{selectedCommitFilePath || "Changes"}</Typography>
							</Box>
							<GitDiffPreview path={selectedCommitFilePath} preview={commitDiffPreview} />
						</Box>
					</Box>
				) : (
					<Box sx={{ flex: 1, p: 2 }}>
						<Typography variant="body2" sx={{ color: mutedText }}>No commit selected</Typography>
					</Box>
				)}
			</Box>
		</Box>
	);

	const jobRunning = !!job && (!job.status || !terminalStates.has(job.status.state));
	const jobState = job?.status?.state ?? "idle";
	const jobStatusText = job ? (job.status?.error ?? job.status?.message ?? job.status?.state ?? "queued") : "No Git task running";
	const jobCard = (
		<Box
			sx={{
				position: "absolute",
				left: "50%",
				top: "50%",
				transform: "translate(-50%, -50%)",
				width: 360,
				height: 34,
				border: `1px solid ${panelBorder}`,
				backgroundColor: "#242424",
				display: "grid",
				gridTemplateColumns: "16px minmax(0, 1fr) 22px",
				gridTemplateRows: "1fr 2px",
				alignItems: "center",
				columnGap: 0.75,
				px: 1,
				zIndex: 1,
			}}
		>
			<Box
				sx={{
					width: 8,
					height: 8,
					justifySelf: "center",
					backgroundColor: jobRunning ? accent : (jobState === "error" ? Color.Error : "#6f7680"),
				}}
			/>
			<Box sx={{ minWidth: 0, display: "flex", alignItems: "baseline", justifyContent: "center", gap: 0.75 }}>
				<Typography variant="body2" noWrap sx={{ color: job ? primaryText : mutedText, fontSize: 12, fontWeight: job ? 700 : 600, lineHeight: 1 }}>
					{job?.command ?? "No Git task running"}
				</Typography>
				{job ? (
					<Typography
						variant="caption"
						noWrap
						sx={{
							color: job.status?.state === "error" ? Color.Error : mutedText,
							fontSize: 11,
							lineHeight: 1,
							textTransform: "lowercase",
						}}
					>
						{jobStatusText}
					</Typography>
				) : null}
			</Box>
			<Box sx={{ display: "flex", justifyContent: "center" }}>
				{job ? (
					<IconButton
						size="small"
						onClick={cancelJob}
						disabled={!jobRunning}
					sx={{
						width: 20,
						height: 20,
						borderRadius: 0,
						color: "#b9b9b9",
						backgroundColor: "#2e2e2e",
						"&:hover": { color: primaryText, backgroundColor: "#3a3a3a" },
						"&.Mui-disabled": { color: "rgba(215, 215, 215, 0.24)", backgroundColor: "transparent" },
					}}
					>
						×
					</IconButton>
				) : null}
			</Box>
			{jobRunning ? (
				<LinearProgress
					variant={job?.status?.progress !== undefined ? "determinate" : "indeterminate"}
					value={job?.status?.progress !== undefined ? Math.max(0, Math.min(100, job.status.progress * 100)) : undefined}
					sx={{
						gridColumn: "1 / -1",
						alignSelf: "end",
						height: 2,
						mx: -1,
						backgroundColor: "#242424",
						"& .MuiLinearProgress-bar": { backgroundColor: accent },
					}}
				/>
			) : null}
		</Box>
	);

	const normalView = (
		<Box sx={{ display: "grid", gridTemplateRows: "58px minmax(0, 1fr)", gap: 1, minHeight: 0, flex: 1 }}>
			<Box sx={{ ...panelSx, px: 1, position: "relative", display: "flex", alignItems: "center" }}>
				<Stack direction="row" alignItems="center" sx={{ gap: 1, justifySelf: "start" }}>
					<Tooltip title="Refresh Repository"><IconButton size="small" sx={iconButtonSx} onClick={refresh}><RefreshIcon fontSize="small" /></IconButton></Tooltip>
					<Button size="small" sx={toolButtonSx} onClick={runFetch}>Fetch</Button>
					<Button size="small" sx={toolButtonSx} startIcon={<DownloadIcon />} onClick={() => runPullPush("pull")}>Pull</Button>
					<Button size="small" sx={toolButtonSx} startIcon={<UploadIcon />} onClick={() => runPullPush("push")}>Push</Button>
				</Stack>
				{jobCard}
				<Stack direction="row" alignItems="center" sx={{ gap: 1, ml: "auto" }}>
					<Tooltip title="Git Settings"><IconButton size="small" sx={iconButtonSx} onClick={() => openSettings("profile")}><SettingsIcon fontSize="small" /></IconButton></Tooltip>
				</Stack>
			</Box>
			<Box sx={{ display: "grid", gridTemplateColumns: "300px minmax(0, 1fr)", gap: 1, minHeight: 0 }}>
				{sidebar}
				{previewMode === "local" ? localChangesView : allCommitsView}
			</Box>
		</Box>
	);

	const setupView = (
		<Stack spacing={1.25} sx={{ ...panelSx, maxWidth: 760, p: 1.25 }}>
			<Stack direction="row" alignItems="center" justifyContent="space-between">
				<Box>
					<Typography variant="subtitle2" sx={{ color: primaryText }}>Repository Setup</Typography>
					<Typography variant="caption" noWrap sx={{ display: "block", color: mutedText, maxWidth: 560 }}>{displayPath ?? projectRoot}</Typography>
				</Box>
				<Button variant="contained" onClick={initRepo} sx={{ height: 32, borderRadius: 0, color: "#171717", backgroundColor: accent, "&:hover": { backgroundColor: "#ffd05a" } }}>Init</Button>
			</Stack>
			<Divider sx={{ borderColor: panelBorder }} />
			<Stack spacing={1.25}>
				<TextField size="small" label="Clone URL" value={cloneUrl} onChange={(event) => setCloneUrl(event.target.value)} />
				<Stack direction="row" spacing={1}>
					<TextField size="small" label="Target folder" value={cloneDir} onChange={(event) => setCloneDir(event.target.value)} sx={{ flex: 1 }} />
					<TextField size="small" label="Branch" value={cloneBranch} onChange={(event) => setCloneBranch(event.target.value)} sx={{ flex: 1 }} />
					<TextField
						size="small"
						label="Depth"
						value={cloneDepth}
						onChange={(event) => setCloneDepth(event.target.value.replace(/[^\d]/g, ""))}
						placeholder="Full"
						sx={{ width: 112 }}
					/>
				</Stack>
				<Button startIcon={<DownloadIcon />} variant="outlined" sx={toolButtonSx} onClick={cloneRepo} disabled={cloneUrl.trim() === ""}>Clone Repository</Button>
			</Stack>
		</Stack>
	);

	const detectingView = (
		<Stack spacing={1.25} sx={{ ...panelSx, maxWidth: 520, p: 1.5 }}>
			<Typography variant="subtitle2" sx={{ color: primaryText }}>Checking Git Repository</Typography>
			<Typography variant="body2" sx={{ color: mutedText }}>{displayPath ?? projectRoot}</Typography>
		</Stack>
	);

	return (
		<Box sx={{ height, pb: 1, display: "flex", flexDirection: "column", backgroundColor: "#141414", color: Color.TextPrimary }}>
			{loading ? <LinearProgress sx={{ height: 2 }} /> : <Box sx={{ height: 2 }} />}
			<Box sx={{ flex: 1, minHeight: 0, p: 1, display: "flex", flexDirection: "column" }}>
				{summary === null || (loading && summary.success && !summary.isRepo) ? detectingView : isRepo ? normalView : setupView}
			</Box>
			<Menu open={!!moreAnchor} anchorEl={moreAnchor?.anchor ?? null} onClose={() => setMoreAnchor(null)}>
				<MenuItem onClick={() => { setMoreAnchor(null); runSecondary("clean -f", "Clean Untracked Files", true); }}>Clean Untracked</MenuItem>
			</Menu>
			<Dialog open={actionDialog !== null} onClose={closeActionDialog} maxWidth="sm" fullWidth>
				<DialogTitle>{actionDialog?.title}</DialogTitle>
				<DialogContent sx={dialogContentSx}>
					{actionDialog?.detail ? <Typography variant="caption" noWrap sx={{ color: mutedText }}>{actionDialog.detail}</Typography> : null}
					{actionDialog?.fields.map(field => field.checkbox ? (
						<FormControlLabel
							key={field.name}
							control={
								<Checkbox
									checked={dialogValues[field.name] === true}
									onChange={(event) => setDialogValues(prev => ({ ...prev, [field.name]: event.target.checked }))}
								/>
							}
							label={field.label}
							sx={{ color: primaryText }}
						/>
						) : field.options ? (
						<Autocomplete
							key={field.name}
							freeSolo
							options={typeof field.options === "function" ? field.options(dialogValues) : field.options}
							value={String(dialogValues[field.name] ?? "")}
							inputValue={String(dialogValues[field.name] ?? "")}
							onChange={(_, value) => {
								setDialogValues(prev => {
									const next = { ...prev, [field.name]: value ?? "" };
									if (actionDialog?.title === "Remote" && field.name === "name" && typeof value === "string") {
										const remote = summary?.success ? summary.remotes?.find(item => item.name === value) : undefined;
										if (remote) next.url = remote.urls?.[0] ?? "";
									}
									if ((actionDialog?.title === "Pull Branch" || actionDialog?.title === "Push Branch") && field.name === "remote" && typeof value === "string") {
										next.branch = preferredRemoteBranch(value, String(prev.branch ?? ""));
									}
									return next;
								});
							}}
							onInputChange={(_, value, reason) => setDialogValues(prev => {
								const next = { ...prev, [field.name]: value };
								if ((actionDialog?.title === "Pull Branch" || actionDialog?.title === "Push Branch") && field.name === "remote" && reason !== "reset") {
									next.branch = preferredRemoteBranch(value, String(prev.branch ?? ""));
								}
								return next;
							})}
							sx={{
								"& .MuiAutocomplete-clearIndicator": {
									color: primaryText,
									opacity: 1,
									"&:hover": { color: accent, backgroundColor: "rgba(250, 192, 61, 0.12)" },
								},
							}}
							renderInput={params => (
								<TextField
									{...params}
									size="small"
									label={field.label}
									required={field.required}
									placeholder={field.placeholder}
								/>
							)}
						/>
					) : (
						<TextField
							key={field.name}
							size="small"
							label={field.label}
							type={field.type}
							required={field.required}
							placeholder={field.placeholder}
							value={String(dialogValues[field.name] ?? "")}
							onChange={(event) => setDialogValues(prev => ({ ...prev, [field.name]: event.target.value }))}
						/>
					))}
				</DialogContent>
				<DialogActions>
					<Button onClick={closeActionDialog}>Cancel</Button>
					<Button onClick={submitActionDialog} sx={{ color: accent }}>{actionDialog?.submitLabel ?? "Run"}</Button>
				</DialogActions>
			</Dialog>
			<Dialog open={confirmDialog !== null} onClose={() => setConfirmDialog(null)} maxWidth="sm" fullWidth>
				<DialogTitle>{confirmDialog?.title}</DialogTitle>
				<DialogContent sx={dialogContentSx}>
					{confirmDialog?.detail ? <Typography variant="body2" sx={{ color: primaryText }}>{confirmDialog.detail}</Typography> : null}
					{confirmDialog?.command ? (
						<Box sx={{ border: `1px solid ${panelBorder}`, background: "#101010", color: mutedText, p: 1, fontFamily: "monospace", fontSize: 12, whiteSpace: "pre-wrap", overflowWrap: "anywhere" }}>
							{confirmDialog.command}
						</Box>
					) : null}
				</DialogContent>
				<DialogActions>
					<Button onClick={() => setConfirmDialog(null)}>Cancel</Button>
					<Button onClick={submitConfirmDialog} sx={{ color: confirmDialog?.danger ? Color.Error : accent }}>{confirmDialog?.submitLabel ?? "Confirm"}</Button>
				</DialogActions>
			</Dialog>
			<Dialog open={settingsOpen} onClose={() => setSettingsOpen(false)} maxWidth="sm" fullWidth>
				<DialogTitle>Git Settings</DialogTitle>
				<DialogContent sx={dialogContentSx}>
					<Tabs value={settingsTab} onChange={(_, value) => setSettingsTab(value)} sx={{ mb: 2 }}>
						<Tab value="profile" label="Profile" />
						<Tab value="credentials" label="Credentials" />
					</Tabs>
					{settingsTab === "profile" ? (
						<Stack spacing={1.5}>
							<TextField size="small" label="Author name" value={profile.name} onChange={(event) => setProfile(prev => ({ ...prev, name: event.target.value }))} />
							<TextField size="small" label="Author email" value={profile.email} onChange={(event) => setProfile(prev => ({ ...prev, email: event.target.value }))} />
							<Button sx={toolButtonSx} onClick={saveProfile}>Save Profile</Button>
						</Stack>
					) : (
						<Stack spacing={1.5}>
							{credentials.map(item => (
								<Stack key={item.id} direction="row" spacing={1} alignItems="center" sx={{ border: `1px solid ${panelBorder}`, background: panelBg, p: 0.75 }}>
									<Typography variant="body2" sx={{ flex: 1 }}>{item.host} · {item.label} · {item.type} {item.username ? `· ${item.username}` : ""}</Typography>
									<IconButton size="small" sx={iconButtonSx} onClick={async () => { await Service.gitAuthDelete({ id: item.id }); await loadSettings(); }}><DeleteIcon fontSize="small" /></IconButton>
								</Stack>
								))}
								<Stack direction="row" spacing={1}>
									<TextField
										size="small"
										label="Host"
										placeholder="github.com"
										value={credentialForm.host}
										onChange={(event) => setCredentialForm(prev => ({ ...prev, host: event.target.value }))}
										sx={{ flex: 1 }}
									/>
									<TextField size="small" label="Label" value={credentialForm.label} onChange={(event) => setCredentialForm(prev => ({ ...prev, label: event.target.value }))} sx={{ flex: 1 }} />
								</Stack>
							<Stack direction="row" spacing={1}>
									<Select size="small" value={credentialForm.type} onChange={(event) => {
										const type = event.target.value as "basic" | "token";
										setCredentialForm(prev => ({ ...prev, type, username: type === "token" ? "" : prev.username }));
									}} sx={{ width: 120 }}>
										<MenuItem value="token">Token</MenuItem>
										<MenuItem value="basic">Basic</MenuItem>
									</Select>
									{credentialForm.type === "basic" ? (
										<TextField size="small" label="Username" value={credentialForm.username} onChange={(event) => setCredentialForm(prev => ({ ...prev, username: event.target.value }))} sx={{ flex: 1 }} />
									) : null}
									<TextField size="small" label={credentialForm.type === "token" ? "Token" : "Password"} type="password" value={credentialForm.secret} onChange={(event) => setCredentialForm(prev => ({ ...prev, secret: event.target.value }))} sx={{ flex: 1 }} />
								</Stack>
							<Button sx={toolButtonSx} onClick={saveCredential}>Save Credential</Button>
						</Stack>
					)}
				</DialogContent>
				<DialogActions>
					<Button onClick={() => setSettingsOpen(false)}>Close</Button>
				</DialogActions>
			</Dialog>
			<Dialog open={pendingCredential !== null} onClose={() => { setPendingCredential(null); pendingCredentialDoneRef.current = undefined; }} maxWidth="sm" fullWidth>
				<DialogTitle>Select Git Credential</DialogTitle>
				<DialogContent sx={dialogContentSx}>
					<Stack spacing={1.25}>
						<Typography variant="body2" sx={{ color: Color.TextSecondary }}>
							{pendingCredential?.host ? `Host: ${pendingCredential.host}` : "This command needs a credential."}
						</Typography>
						<Typography variant="caption" noWrap sx={{ color: Color.TextSecondary }}>
							{pendingCredential?.command}
						</Typography>
						{pendingCredential?.credentials.map(item => (
							<Button
								key={item.id}
								variant="outlined"
								onClick={() => runPendingCredential(item.id)}
								sx={{ justifyContent: "flex-start" }}
							>
								{item.label} · {item.type}{item.username ? ` · ${item.username}` : ""}
							</Button>
						))}
					</Stack>
				</DialogContent>
				<DialogActions>
					<Button onClick={() => { setPendingCredential(null); pendingCredentialDoneRef.current = undefined; }}>Cancel</Button>
					<Button onClick={() => { setPendingCredential(null); openSettings("credentials"); }}>Git Settings</Button>
				</DialogActions>
			</Dialog>
		</Box>
	);
}

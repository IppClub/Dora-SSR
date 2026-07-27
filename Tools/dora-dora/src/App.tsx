/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { ChangeEvent, Suspense, memo, useCallback, useEffect, useMemo, useRef, useState } from 'react';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import CssBaseline from '@mui/material/CssBaseline';
import IconButton from '@mui/material/IconButton';
import Fullscreen from '@mui/icons-material/Fullscreen';
import FullscreenExit from '@mui/icons-material/FullscreenExit';
import type * as Monaco from 'monaco-editor/esm/vs/editor/editor.api';
import FileTree, { TreeDataType, TreeMenuEvent } from "./FileTree";
import FileTabBar, { TabMenuEvent, TabStatus } from './FileTabBar';
import Info from './Info';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import { AlertColor, Button, Collapse, DialogActions, DialogContent, DialogContentText, InputAdornment, TextField, Container, Link, Typography, Checkbox, FormControlLabel, Tooltip, Stack, MenuItem } from '@mui/material';
import NewFileDialog, { DoraFileType } from './NewFileDialog';
import logo from './logo.svg';
import { TransitionGroup } from 'react-transition-group';
import * as Service from './Service';
import { AppBar, DrawerHeader, Entry, Main, PlayControl, PlayControlMode, StyledStack } from './Frame';
import { Color } from './Theme';
import { MacScrollbar } from 'mac-scrollbar';
import 'mac-scrollbar/dist/mac-scrollbar.css';
import FileFilter, { FilterOption } from './FileFilter';
import FileSearchPanel from './FileSearch';
import FirstProjectTour, { firstProjectExampleCode } from './FirstProjectTour';
import { useTranslation } from 'react-i18next';
import { Image, Splitter } from 'antd';
import type { YarnEditorData } from './YarnEditor';
import * as Yarn from './YarnConvert';
import type { CodeWireData } from './CodeWire';
import { AutoTypings } from './3rdParty/monaco-editor-auto-typings';
import { TbSwitchVertical } from "react-icons/tb";
import SearchIcon from '@mui/icons-material/Search';
import KeyboardShortcuts from './KeyboardShortcuts';
import BottomLog from './BottomLog';
import Modal from '@mui/material/Modal';
import { EditorTheme, setInferDefinitionCommand } from './EditorRuntimeState';
import CodeIcon from '@mui/icons-material/Code';
import AccountTreeIcon from '@mui/icons-material/AccountTree';
import VisibilityIcon from '@mui/icons-material/Visibility';
import FolderOpenIcon from '@mui/icons-material/FolderOpen';
import FormatListBulletedIcon from '@mui/icons-material/FormatListBulleted';
import LLMConfigDialog from './LLMConfigDialog';
import ProjectWorkspacePanel from './ProjectWorkspacePanel';
import { createEmptyActionDocument, writeLegacyModel } from './ActionEditor';
import { createParticleDocument, writeParticleDocumentToXml } from './ParticleEditor';
import { LogFixRequest } from './LogFix';
import { getExtraLib, toFilePath, toTypeScriptFileName } from './MonacoPath';
import {
	getFileSearchIndexSize,
	hasFileSearchIndex,
	initializeFileSearchIndex,
	invalidateFileSearchIndex,
	moveFileSearchIndex,
	updateFileSearchIndex,
} from './FileSearchIndex';
import type { FileSearchEntry, FileSearchSnapshot } from './FileSearchProtocol';
import { getMonacoRuntime, getMonacoTypeScript, peekMonacoRuntime } from './MonacoRuntimeAccess';

const SpinePlayer = React.lazy(() => import('./SpinePlayer'));
const Markdown = React.lazy(() => import('./Markdown'));
const LogView = React.lazy(() => import('./LogView'));
const Blockly = React.lazy(() => import('./Blockly'));
const YarnEditor = React.lazy(() => import('./YarnEditor'));
const CodeWire = React.lazy(() => import('./CodeWire'));
const TIC80Editor = React.lazy(() => import('./TIC80Editor'));
const ActionEditor = React.lazy(() => import('./ActionEditor/ActionEditor'));
const ActionClipPreview = React.lazy(() => import('./ActionEditor/ActionClipPreview'));
const BodyEditor = React.lazy(() => import('./BodyEditor/BodyEditor'));
const ParticleEditor = React.lazy(() => import('./ParticleEditor/ParticleEditor'));
const MonacoEditorRuntime = React.lazy(() => import('./MonacoEditorRuntime'));

const { path } = Info;
const monaco = new Proxy({} as typeof Monaco, {
	get: (_target, property) => Reflect.get(getMonacoRuntime(), property),
});

let lastEditorActionTime = Date.now();
let lastUploadedTime = Date.now();
let isSaving = false;

document.addEventListener("contextmenu", (event) => {
	const target = event.target instanceof Element ? event.target : null;
	if (target?.closest("input, textarea, [contenteditable='true'], .monaco-editor")) {
		return;
	}
	event.preventDefault();
});

let contentModified = false;
let waitingForDownload = false;

let saveEditingInfo: () => void = () => { };
let lastSaveEditingInfoTime = Date.now();
const saveEditingInfoInterval = 10000;
let lastEditingInfo: Service.EditingInfo | null = null;

const areEditingInfosEqual = (a: Service.EditingInfo | null, b: Service.EditingInfo | null): boolean => {
	if (a === null && b === null) return true;
	if (a === null || b === null) return false;

	if (a.index !== b.index) return false;
	if (a.files.length !== b.files.length) return false;

	for (let i = 0; i < a.files.length; i++) {
		const fileA = a.files[i];
		const fileB = b.files[i];

		if (fileA.key !== fileB.key) return false;
		if (fileA.title !== fileB.title) return false;
		if (fileA.mdEditing !== fileB.mdEditing) return false;
		if (fileA.yarnTextEditing !== fileB.yarnTextEditing) return false;
		if (fileA.bodyTextEditing !== fileB.bodyTextEditing) return false;
		if (fileA.particleTextEditing !== fileB.particleTextEditing) return false;
		if (fileA.readOnly !== fileB.readOnly) return false;
		if (fileA.folder !== fileB.folder) return false;
		if (fileA.agentSessionId !== fileB.agentSessionId) return false;
		if (fileA.workspaceView !== fileB.workspaceView) return false;

		if (fileA.position && fileB.position) {
			if (fileA.position.lineNumber !== fileB.position.lineNumber) return false;
			if (fileA.position.column !== fileB.position.column) return false;
		} else if (fileA.position !== fileB.position) {
			return false;
		}
	}
	return true;
};

setInterval(() => {
	const now = Date.now();
	if (now - lastSaveEditingInfoTime >= saveEditingInfoInterval) {
		saveEditingInfo();
		lastSaveEditingInfoTime = now;
	}
}, saveEditingInfoInterval);

window.onbeforeunload = (event: BeforeUnloadEvent) => {
	if (Info.version !== undefined) {
		saveEditingInfo();
		if (contentModified) {
			event.returnValue = "Please save before leaving!";
			return "Please save before leaving!";
		}
	}
};

const isChildFolder = (child: string, parent: string) => {
	if (!child.startsWith(parent)) return false;
	if (path.relative(parent, child).startsWith("..")) {
		return false;
	}
	return true;
};

const normalizeBatchPaths = (keys: string[]) => {
	const sorted = [...new Set(keys)].sort((a, b) => a.length - b.length);
	const result: string[] = [];
	for (const key of sorted) {
		if (result.some(parent => isChildFolder(key, parent))) continue;
		result.push(key);
	}
	return result;
};

const replaceBatchPath = (key: string, changes: Service.AssetBatchChange[]) => {
	const sorted = [...changes].sort((a, b) => b.old.length - a.old.length);
	for (const change of sorted) {
		if (change.new === undefined || !isChildFolder(key, change.old)) continue;
		const relative = path.relative(change.old, key);
		return relative === "" ? change.new : path.join(change.new, relative);
	}
	return key;
};

const isSingleBuildFile = (key: string) => {
	const ext = path.extname(key).toLowerCase();
	const name = path.basename(key, ext);
	if (path.extname(name) !== "") return false;
	return ext === ".yue" ||
		ext === ".tl" ||
		ext === ".ts" ||
		ext === ".tsx" ||
		ext === ".xml" ||
		ext === ".wa" ||
		ext === ".mod";
};

const findTreeNode = (node: TreeDataType, key: string): TreeDataType | null => {
	if (node.key === key) return node;
	if (node.children !== undefined) {
		for (let i = 0; i < node.children.length; i++) {
			const found = findTreeNode(node.children[i], key);
			if (found !== null) {
				return found;
			}
		}
	}
	return null;
};

const splitRelativePath = (root: string, target: string): string[] | null => {
	if (!isChildFolder(target, root)) return null;
	const relativePath = path.relative(root, target);
	if (relativePath === "") return [];
	return relativePath.split(/[\\/]+/).filter(Boolean);
};

const appendExpandedKey = (expanded: string[], key: string): string[] => {
	if (expanded.includes(key)) return expanded;
	return [...expanded, key];
};

const removeExpandedPath = (expanded: string[], removedPath: string): string[] => {
	return expanded.filter(key => !isChildFolder(key, removedPath));
};

const expandDirPath = (rootKey: string, dirPath: string, expanded: string[]): string[] => {
	const parts = splitRelativePath(rootKey, dirPath);
	if (parts === null || parts.length === 0) return expanded;
	let nextExpanded = expanded;
	let currentPath = rootKey;
	for (let i = 0; i < parts.length; i++) {
		currentPath = path.join(currentPath, parts[i]);
		nextExpanded = appendExpandedKey(nextExpanded, currentPath);
	}
	return nextExpanded;
};

const removeTreeNode = (node: TreeDataType, key: string): { root: TreeDataType; removedNode: TreeDataType | null } => {
	if (node.children === undefined) {
		return { root: node, removedNode: null };
	}
	const nextChildren: TreeDataType[] = [];
	for (let i = 0; i < node.children.length; i++) {
		const child = node.children[i];
		if (child.key === key) {
			for (let j = i + 1; j < node.children.length; j++) {
				nextChildren.push(node.children[j]);
			}
			return {
				root: { ...node, children: nextChildren },
				removedNode: child,
			};
		}
		const result = removeTreeNode(child, key);
		nextChildren.push(result.root);
		if (result.removedNode !== null) {
			for (let j = i + 1; j < node.children.length; j++) {
				nextChildren.push(node.children[j]);
			}
			return {
				root: { ...node, children: nextChildren },
				removedNode: result.removedNode,
			};
		}
	}
	return { root: node, removedNode: null };
};

const updateTreeNode = (
	node: TreeDataType,
	key: string,
	updater: (node: TreeDataType) => TreeDataType
): { root: TreeDataType; node: TreeDataType | null } => {
	if (node.key === key) {
		const nextNode = updater(node);
		return { root: nextNode, node: nextNode };
	}
	if (node.children === undefined) {
		return { root: node, node: null };
	}
	let foundNode: TreeDataType | null = null;
	const nextChildren = node.children.map((child) => {
		const result = updateTreeNode(child, key, updater);
		if (result.node !== null) {
			foundNode = result.node;
		}
		return result.root;
	});
	if (foundNode === null) {
		return { root: node, node: null };
	}
	return {
		root: { ...node, children: nextChildren },
		node: foundNode,
	};
};

const replaceTreeNodeChildren = (
	root: TreeDataType,
	key: string,
	children: TreeDataType[]
): { root: TreeDataType; node: TreeDataType | null } => {
	return updateTreeNode(root, key, (node) => ({
		...node,
		children,
		isLeaf: children.length === 0,
	}));
};

const ensureDirNode = (root: TreeDataType, dirPath: string): { root: TreeDataType; node: TreeDataType | null; created: boolean } => {
	if (!root.dir) return { root, node: null, created: false };
	if (root.key === dirPath) {
		return { root, node: root, created: false };
	}
	const parts = splitRelativePath(root.key, dirPath);
	if (parts === null) {
		return { root, node: null, created: false };
	}
	if (parts.length === 0) {
		return { root, node: root, created: false };
	}
	if (root.children === undefined) {
		return { root, node: null, created: false };
	}
	const [part, ...rest] = parts;
	const childKey = path.join(root.key, part);
	const children = root.children;
	const childIndex = children.findIndex(child => child.key === childKey);
	if (childIndex < 0) {
		const newChild: TreeDataType = {
			key: childKey,
			title: path.basename(childKey),
			dir: true,
			children: [],
		};
		if (rest.length === 0) {
			return {
				root: { ...root, children: [...children, newChild] },
				node: newChild,
				created: true,
			};
		}
		const nested = ensureDirNode(newChild, dirPath);
		return {
			root: { ...root, children: [...children, nested.root] },
			node: nested.node,
			created: true,
		};
	}
	const child = children[childIndex];
	if (!child.dir) {
		return { root, node: null, created: false };
	}
	const result = ensureDirNode(child, dirPath);
	if (result.node === null) {
		return { root, node: null, created: false };
	}
	if (!result.created && result.root === child) {
		return { root, node: result.node, created: false };
	}
	const nextChildren = [...children];
	nextChildren[childIndex] = result.root;
	return {
		root: { ...root, children: nextChildren },
		node: result.node,
		created: result.created,
	};
};

const ensureFileNode = (root: TreeDataType, file: string): { root: TreeDataType; node: TreeDataType | null; created: boolean } => {
	const existing = findTreeNode(root, file);
	if (existing !== null) {
		return { root, node: existing, created: false };
	}
	const parentPath = path.dirname(file);
	const dirResult = ensureDirNode(root, parentPath);
	if (dirResult.node === null) {
		return { root, node: null, created: false };
	}
	const newNode: TreeDataType = {
		key: file,
		title: path.basename(file),
		dir: false,
	};
	const insertResult = updateTreeNode(dirResult.root, parentPath, (node) => ({
		...node,
		children: [...(node.children ?? []), newNode],
	}));
	if (insertResult.node === null) {
		return { root, node: null, created: false };
	}
	return {
		root: insertResult.root,
		node: newNode,
		created: true,
	};
};

interface EditingFile {
	key: string;
	title: string;
	content: string;
	contentModified: string | null;
	folder: boolean;
	onMount: (editor: Monaco.editor.IStandaloneCodeEditor) => void;
	onUnmount?: (editor: Monaco.editor.IStandaloneCodeEditor) => void;
	editor?: Monaco.editor.IStandaloneCodeEditor;
	viewState?: Monaco.editor.ICodeEditorViewState | null;
	position?: Monaco.IPosition;
	mdEditing?: boolean;
	yarnTextEditing?: boolean;
	bodyTextEditing?: boolean;
	particleTextEditing?: boolean;
	yarnData?: YarnEditorData;
	codeWireData?: CodeWireData;
	visualSnapshotPending?: boolean;
	visualSnapshotRevision?: number;
	ticDirty?: boolean;
	blocklyData?: string;
	previewVersion?: number;
	sortIndex?: number;
	readOnly?: boolean;
	status: TabStatus;
	agentSessionId?: number;
	agentInitialPrompt?: string;
	workspaceView?: "agent" | "upload" | "git";
};

interface Modified {
	key: string;
	content: string;
	blocklyCode?: string;
};

type FolderProjectType = "TypeScript" | "TSX" | "Teal" | "Lua" | "YueScript";

const folderProjectTypes: FolderProjectType[] = ["TypeScript", "TSX", "Teal", "Lua", "YueScript"];

const getFolderProjectExtension = (type: FolderProjectType) => {
	switch (type) {
		case "TypeScript": return ".ts";
		case "TSX": return ".tsx";
		case "Teal": return ".tl";
		case "Lua": return ".lua";
		case "YueScript": return ".yue";
	}
};

const getNewFileTemplate = (ext: string) => {
	let content = "";
	let position: Monaco.IPosition | undefined;
	switch (ext) {
		case ".lua":
			content = "-- @preview-file on clear\n\n";
			position = {
				lineNumber: 3,
				column: 1
			};
			break;
		case ".tl":
			content = "-- @preview-file on clear\n\n";
			position = {
				lineNumber: 3,
				column: 1
			};
			break;
		case ".yue":
			content = "-- @preview-file on clear\n_ENV = Dora\nimport global\n\n";
			position = {
				lineNumber: 5,
				column: 1
			};
			break;
		case ".tsx":
			content = "// @preview-file on clear nolog\nimport { React, toNode, useRef } from 'DoraX';\nimport {} from 'Dora';\n\n";
			position = {
				lineNumber: 5,
				column: 1
			};
			break;
		case ".ts":
			content = "// @preview-file on clear\nimport {} from 'Dora';\n\n";
			position = {
				lineNumber: 4,
				column: 1
			};
			break;
		case ".xml":
			content = "<!-- @preview-file on clear nolog -->\n<Dora>\n\t\n</Dora>\n";
			position = {
				lineNumber: 3,
				column: 2
			};
			break;
		case ".bl":
			content = '{"blocks":{"blocks":[{"type":"comment_block","fields":{"NOTE":"@preview-file on clear"}}]}}';
			break;
		case ".yarn":
			content = `title: Start\ntags:\nposition: 50,50\ncolorID: 0\n---\nHello World!\n===\n`;
			break;
		case ".model":
			content = writeLegacyModel(createEmptyActionDocument());
			break;
		case ".b.lua":
			content = `return {"Array"}`;
			break;
		case ".par":
			content = writeParticleDocumentToXml(createParticleDocument("fire"));
			break;
		default:
			break;
	}
	return { content, position };
};

const isBodyLuaFile = (filePath: string) => filePath.toLowerCase().endsWith(".b.lua");

const editorBackground = <div style={{ width: '100%', height: '100%', backgroundColor: '#1a1a1a' }} />;
const narrowSplitBreakpoint = 490;

const Editor = memo((props: {
	hidden?: boolean,
	width: number, height: number,
	language: string,
	editingFile: EditingFile,
	readOnly: boolean,
	minimap: boolean,
	tourTarget?: boolean,
	onMount: (editor: Monaco.editor.IStandaloneCodeEditor) => void,
	onUnmount: (editor: Monaco.editor.IStandaloneCodeEditor) => void,
	onModified: (editingFile: EditingFile, content: string, lastChange?: Monaco.editor.IModelContentChange) => void,
	onValidate: (markers: Monaco.editor.IMarker[], key: string) => void,
}) => {
	const {
		hidden,
		width,
		height,
		language,
		editingFile,
		readOnly,
		minimap,
		tourTarget,
		onMount,
		onUnmount,
		onModified,
		onValidate
	} = props;
	const doValidate = useCallback((markers: Monaco.editor.IMarker[]) => {
		onValidate(markers, editingFile.key);
	}, [onValidate, editingFile.key]);
	const onChange = useCallback((content: string | undefined, ev: Monaco.editor.IModelContentChangedEvent) => {
		if (content === undefined) return;
		onModified(editingFile, content, ev.changes.at(-1));
	}, [onModified, editingFile]);
	return (
		<div
			hidden={hidden}
			data-first-project-editor={tourTarget ? "true" : undefined}
			style={{ width, height }}
		>
			<Suspense fallback={editorBackground}>
				<MonacoEditorRuntime
					width={width}
					height={height}
					language={language}
					theme={EditorTheme}
					onMount={onMount}
					onUnmount={onUnmount}
					loading={editorBackground}
					onChange={onChange}
					onValidate={language === "typescript" ? doValidate : undefined}
					filePath={editingFile.key}
					options={{
						readOnly,
						padding: { top: 20 },
						wordWrap: 'on',
						wordBreak: 'keepAll',
						selectOnLineNumbers: true,
						matchBrackets: 'near',
						fontSize: 18,
						useTabStops: false,
						insertSpaces: false,
						renderWhitespace: 'all',
						tabSize: 2,
						minimap: {
							enabled: minimap,
						},
						definitionLinkOpensInPeek: true,
					}}
				/>
			</Suspense>
		</div>
	);
});
Editor.displayName = 'Editor';

interface UpdateFileEvent {
	file: string;
	exists: boolean;
	content: string;
}

const previewFileExts = new Set([".png", ".jpg", ".jpeg", ".clip", ".par"]);

const appendCacheKey = (url: string, key?: number) => {
	if (key === undefined) return url;
	return `${url}${url.includes("?") ? "&" : "?"}v=${key}`;
};

const transitionProps = {
	appear: false,
	enter: false,
	exit: false
};

let writablePath = "";
let assetPath = "";
let configuredTypeScriptSearchPathKey = "";
let typeScriptSearchPathUpdateId = 0;

const configureTypeScriptSearchPaths = (nextAssetPath: string, projectSourceRoot = "") => {
	if (nextAssetPath === "") return;
	const runtime = peekMonacoRuntime();
	if (runtime === null) return;
	const searchRoots = [
		projectSourceRoot,
		path.join(nextAssetPath, "Script", "Lib"),
	].filter(root => root !== "");
	const nextSearchPathKey = searchRoots.join("\n");
	if (nextSearchPathKey === configuredTypeScriptSearchPathKey) return;
	configuredTypeScriptSearchPathKey = nextSearchPathKey;
	const monacoTypescript = getMonacoTypeScript();
	const compilerOptions = { ...monacoTypescript.typescriptDefaults.getCompilerOptions() };
	delete compilerOptions.baseUrl;
	monacoTypescript.typescriptDefaults.setCompilerOptions({
		...compilerOptions,
		paths: {
			"*": searchRoots.map(root => `${monaco.Uri.file(root).toString()}/*`),
		},
	});
};

let monacoDeclarationsPromise: Promise<void> | null = null;

const initializeMonacoDeclarations = () => {
	if (monacoDeclarationsPromise !== null) return monacoDeclarationsPromise;
	const monacoTypescript = getMonacoTypeScript();
	monacoTypescript.typescriptDefaults.setExtraLibs([]);
	monacoDeclarationsPromise = Promise.all([
		Service.read({ path: "es6-subset.d.ts" }),
		Service.read({ path: "lua.d.ts" }),
		Service.read({ path: "Dora.d.ts" }),
	]).then(([es6, lua, dora]) => {
		if (es6.success) {
			monacoTypescript.typescriptDefaults.addExtraLib(es6.content, toTypeScriptFileName(es6.fullPath));
		}
		if (lua.success) {
			monacoTypescript.typescriptDefaults.addExtraLib(lua.content, toTypeScriptFileName(lua.fullPath));
		}
		if (dora.success) {
			monacoTypescript.typescriptDefaults.addExtraLib(dora.content, toTypeScriptFileName(dora.fullPath));
		}
	}).catch(() => {
		// Declaration loading must not prevent the editor itself from mounting.
	});
	return monacoDeclarationsPromise;
};

const getProjectSourceRoot = async (projectFile: string) => {
	const rootRes = await Service.projectRoot({ path: projectFile, isDir: false });
	if (!rootRes.success || !rootRes.found || !rootRes.projectRoot) return "";
	const scriptDir = path.join(rootRes.projectRoot, "Script");
	const scriptRes = await Service.list({ path: scriptDir });
	return scriptRes.success ? scriptDir : rootRes.projectRoot;
};

const getAlertAccentColor = (type: AlertColor) => {
	switch (type) {
		case "success": return "#4caf50";
		case "warning": return Color.Warning;
		case "error": return Color.Error;
		default: return "#29a7e8";
	}
};

export default function PersistentDrawerLeft() {
	const { t } = useTranslation();
	const [alerts, setAlerts] = useState<{
		msg: string,
		key: string,
		type: AlertColor,
		openLog?: boolean,
		actionLabel?: string,
		onAction?: () => void,
		count: number,
		pulse: number,
	}[]>([]);
	const alertTimersRef = useRef(new Map<string, number>());
	const [isWaSaving, setIsWaSaving] = useState(false);
	const [drawerOpen, setDrawerOpen] = useState(() => window.innerWidth >= narrowSplitBreakpoint);
	const [tabIndex, setTabIndex] = useState<number | null>(null);
	const [files, setFiles] = useState<EditingFile[]>([]);

	const [treeData, setTreeData] = useState<TreeDataType[]>([]);
	const [expandedKeys, setExpandedKeys] = useState<string[]>([]);
	const [selectedKeys, setSelectedKeys] = useState<string[]>([]);
	const [treeScrollRequest, setTreeScrollRequest] = useState(0);
	const [selectedNode, setSelectedNode] = useState<TreeDataType | null>(null);
	const [multiSelectMode, setMultiSelectMode] = useState(false);
	const [checkedKeys, setCheckedKeys] = useState<string[]>([]);
	const [batchTargetMode, setBatchTargetMode] = useState<"copy" | "move" | null>(null);
	const [batchOperationRunning, setBatchOperationRunning] = useState(false);
	const [keyEvent, setKeyEvent] = useState<KeyboardEvent | null>(null);

	const [openNewFile, setOpenNewFile] = useState<TreeDataType | null>(null);

	const [popupInfo, setPopupInfo] = useState<
		{
			title: string,
			msg: string,
			raw?: boolean,
			cancelable?: boolean,
			selectable?: boolean,
			confirmed?: () => void,
		} | null>(null);

	const [fileInfo, setFileInfo] = useState<
		{
			title: "file.new" | "file.newFolder" | "file.rename",
			node?: TreeDataType,
			name: string,
			ext: string,
			project?: boolean,
			projectType?: FolderProjectType,
		} | null>(null);
	const [firstProjectTourOpen, setFirstProjectTourOpen] = useState(false);
	const [firstProjectTourCurrent, setFirstProjectTourCurrent] = useState(0);
	const [firstProjectTourCreating, setFirstProjectTourCreating] = useState(false);
	const [firstProjectTourCompleted, setFirstProjectTourCompleted] = useState(Info.webIDETourCompleted);
	const [firstProjectTourFile, setFirstProjectTourFile] = useState<string | null>(null);

	const [jumpToFile, setJumpToFile] = useState<{
		key: string;
		title: string;
		row: number;
		col: number;
	} | null>(null);

	const [openFilter, setOpenFilter] = useState(false);
	const [leftDockTab, setLeftDockTab] = useState<"explorer" | "search" | "tools">("explorer");
	const [filterOptionCount, setFilterOptionCount] = useState(0);
	const [filterOptionsLoading, setFilterOptionsLoading] = useState(false);
	const filterOptionsRequestRef = useRef<{
		key: string;
		epoch: number;
		promise: Promise<number | null>;
	} | null>(null);
	const fileSearchInvalidationEpochRef = useRef(0);
	const [openLLMConfig, setOpenLLMConfig] = useState(false);
	const [toolEntries, setToolEntries] = useState<Service.EntryLaunchInfo[]>([]);
	const [gameEntries, setGameEntries] = useState<Service.EntryLaunchInfo[]>([]);
	const [entryView, setEntryView] = useState<"tool" | "game">("tool");
	const [entryFilter, setEntryFilter] = useState("");
	const [drawerWidth, setDrawerWidth] = useState(Math.max(170, Info.drawerWidth ?? 300));
	const [isResizing, setIsResizing] = useState(false);
	const [winSize, setWinSize] = useState({
		width: window.innerWidth,
		height: window.innerHeight
	});
	const windowWidthRef = useRef(window.innerWidth);
	const statusBarHeight = 26;
	const narrowLayout = winSize.width < narrowSplitBreakpoint;
	const effectiveDrawerWidth = narrowLayout
		? Math.floor(winSize.width * 0.82)
		: drawerWidth;
	const editorWidth = winSize.width - (drawerOpen && !narrowLayout ? drawerWidth : 0);
	const editorHeight = winSize.height - 48 - statusBarHeight;
	const showFullLogo = drawerWidth > 235;
	const onSplitterResizeEnd = useCallback((sizes: number[]) => {
		setIsResizing(false);
		if (!drawerOpen || sizes[0] === undefined) return;
		const nextWidth = Math.max(170, Math.round(sizes[0]));
		setDrawerWidth(nextWidth);
		Service.command({
			code: `require('Script.Dev.Entry').getConfig().drawerWidth = ${nextWidth}`,
			log: false
		});
	}, [drawerOpen]);

	const [openLog, setOpenLog] = useState<{ title: string, stopOnClose: boolean } | null>(null);
	const [openBottomLog, setOpenBottomLog] = useState(false);
	const [waitForSave, setWaitForSave] = useState(false);
	const [isEditorActioning, setIsEditorActioning] = useState(false);
	const [isProjectBuilding, setIsProjectBuilding] = useState(false);
	const filesRef = useRef(files);
	const treeDataRef = useRef(treeData);
	const expandedKeysRef = useRef(expandedKeys);
	const selectedKeysRef = useRef(selectedKeys);
	const tabIndexRef = useRef(tabIndex);
	const currentTypeScriptModelRef = useRef<Monaco.editor.ITextModel | null>(null);
	const pendingUpdateFilesRef = useRef(new Map<string, UpdateFileEvent>());
	const updateFileFlushTimerRef = useRef<number | null>(null);
	const loadingTreeNodesRef = useRef(new Map<string, Promise<TreeDataType[] | null>>());

	const updateCachedFileSearch = useCallback((file: string, exists: boolean) => {
		updateFileSearchIndex(file, exists);
		setFilterOptionCount(getFileSearchIndexSize());
	}, []);

	const moveCachedFileSearch = useCallback((oldPath: string, newPath: string) => {
		moveFileSearchIndex(oldPath, newPath);
	}, []);

	const notifiedAgentTaskEndKeysRef = useRef(new Set<string>());
	const openFileInTabRef = useRef<(key: string, title: string, folder: boolean, position?: Monaco.IPosition, readOnly?: boolean) => void>(() => { });

	const removeAlert = useCallback((key: string) => {
		const timer = alertTimersRef.current.get(key);
		if (timer !== undefined) {
			window.clearTimeout(timer);
			alertTimersRef.current.delete(key);
		}
		setAlerts((prevState) => prevState.filter(a => a.key !== key));
	}, []);

	const addAlert = useCallback((msg: string, type: AlertColor, openLog?: boolean, action?: { label: string; onClick: () => void }) => {
		const key = `${type}:${openLog ? "1" : "0"}:${msg}`;
		const prevTimer = alertTimersRef.current.get(key);
		if (prevTimer !== undefined) {
			window.clearTimeout(prevTimer);
		}
		setAlerts((prevState) => {
			const index = prevState.findIndex(item => item.key === key);
			const nextState = [...prevState];
			if (index >= 0) {
				const item = nextState[index];
				nextState.splice(index, 1);
				nextState.push({
					...item,
					count: item.count + 1,
					pulse: item.pulse + 1,
					openLog: item.openLog || openLog,
					actionLabel: action?.label ?? item.actionLabel,
					onAction: action?.onClick ?? item.onAction,
				});
			} else {
				nextState.push({
					msg,
					key,
					type,
					openLog,
					actionLabel: action?.label,
					onAction: action?.onClick,
					count: 1,
					pulse: 0,
				});
			}
			const visible = nextState.slice(-3);
			for (const item of nextState.slice(0, -3)) {
				const timer = alertTimersRef.current.get(item.key);
				if (timer !== undefined) {
					window.clearTimeout(timer);
					alertTimersRef.current.delete(item.key);
				}
			}
			return visible;
		});
		const timer = window.setTimeout(() => {
			alertTimersRef.current.delete(key);
			setAlerts((prevState) => prevState.filter(a => a.key !== key));
		}, 5000);
		alertTimersRef.current.set(key, timer);
	}, []);

	useEffect(() => {
		const alertTimers = alertTimersRef.current;
		return () => {
			for (const timer of alertTimers.values()) {
				window.clearTimeout(timer);
			}
			alertTimers.clear();
		};
	}, []);

	const [disconnected, setDisconnected] = useState(true);

	filesRef.current = files;
	treeDataRef.current = treeData;
	expandedKeysRef.current = expandedKeys;
	selectedKeysRef.current = selectedKeys;
	tabIndexRef.current = tabIndex;

	const fetchAssetChildren = useCallback((key: string): Promise<TreeDataType[] | null> => {
		const pending = loadingTreeNodesRef.current.get(key);
		if (pending !== undefined) return pending;
		const request = Service.assetChildren(key).then((res) => {
			return res.success ? res.children : null;
		}).catch(() => {
			return null;
		}).finally(() => {
			loadingTreeNodesRef.current.delete(key);
		});
		loadingTreeNodesRef.current.set(key, request);
		return request;
	}, []);

	const hydrateExpandedTree = useCallback(async (root: TreeDataType, expanded: string[]) => {
		const expandedSet = new Set(expanded);
		const hydrateNode = async (node: TreeDataType): Promise<TreeDataType> => {
			if (!node.dir || !expandedSet.has(node.key)) return node;
			let children = node.children;
			if (children === undefined && !node.builtin && node.key !== root.key) {
				children = await fetchAssetChildren(node.key) ?? undefined;
			}
			if (children === undefined) return node;
			const nextChildren = await Promise.all(children.map(hydrateNode));
			return {
				...node,
				children: nextChildren,
				isLeaf: nextChildren.length === 0,
			};
		};
		return hydrateNode(root);
	}, [fetchAssetChildren]);

	const loadAssets = useCallback((expanded = expandedKeysRef.current) => {
		fileSearchInvalidationEpochRef.current += 1;
		invalidateFileSearchIndex();
		setFilterOptionCount(0);
		return Service.assets().then(async (res: TreeDataType) => {
			res.root = true;
			res.title = t("tree.assets");
			const hydrated = await hydrateExpandedTree(res, expanded);
			treeDataRef.current = [hydrated];
			setTreeData([hydrated]);
			return hydrated;
		}).catch(() => {
			addAlert(t("alert.assetLoad"), "error");
			return null;
		});
	}, [addAlert, hydrateExpandedTree, t]);

	const loadTreeNode = useCallback(async (data: TreeDataType) => {
		if (!data.dir || data.builtin) return;
		const currentRoot = treeDataRef.current.at(0);
		if (currentRoot === undefined || currentRoot.key === data.key) return;
		const currentNode = findTreeNode(currentRoot, data.key);
		if (currentNode === null || currentNode.children !== undefined) return;
		const children = await fetchAssetChildren(data.key);
		if (children === null) {
			addAlert(t("alert.assetLoad"), "error");
			return;
		}
		const latestRoot = treeDataRef.current.at(0);
		if (latestRoot === undefined) return;
		const updated = replaceTreeNodeChildren(latestRoot, data.key, children);
		if (updated.node === null) return;
		treeDataRef.current = [updated.root];
		setTreeData([updated.root]);
	}, [addAlert, fetchAssetChildren, t]);

	const refreshTreeDirectory = useCallback(async (dir: string, force = false) => {
		const currentRoot = treeDataRef.current.at(0);
		if (currentRoot === undefined) return null;
		if (dir === currentRoot.key) {
			return loadAssets();
		}
		const currentNode = findTreeNode(currentRoot, dir);
		if (currentNode === null || (currentNode.children === undefined && !force)) return currentNode;
		const children = await fetchAssetChildren(dir);
		if (children === null) return null;
		const latestRoot = treeDataRef.current.at(0);
		if (latestRoot === undefined) return null;
		const updated = replaceTreeNodeChildren(latestRoot, dir, children);
		if (updated.node === null) return null;
		treeDataRef.current = [updated.root];
		setTreeData([updated.root]);
		return updated.node;
	}, [fetchAssetChildren, loadAssets]);

	const revealTreeNode = useCallback(async (target: string) => {
		let root = treeDataRef.current.at(0);
		if (root === undefined) return;
		let changed = false;
		if (isChildFolder(target, root.key)) {
			const parts = splitRelativePath(root.key, target);
			if (parts !== null) {
				let currentPath = root.key;
				for (let i = 0; i < parts.length - 1; i++) {
					currentPath = path.join(currentPath, parts[i]);
					const node = findTreeNode(root, currentPath);
					if (node === null) break;
					if (node.children === undefined) {
						const children = await fetchAssetChildren(node.key);
						if (children === null) break;
						const updated = replaceTreeNodeChildren(root, node.key, children);
						if (updated.node === null) break;
						root = updated.root;
						changed = true;
					}
				}
			}
		}
		if (changed) {
			treeDataRef.current = [root];
			setTreeData([root]);
		}
		const targetNode = findTreeNode(root, target);
		if (targetNode === null) return;
		setSelectedKeys([target]);
		setSelectedNode(targetNode);
		let nextExpanded = expandedKeysRef.current;
		const expandParents = (node: TreeDataType, ancestors: string[]): boolean => {
			if (node.key === target) {
				for (const key of ancestors) {
					nextExpanded = appendExpandedKey(nextExpanded, key);
				}
				return true;
			}
			for (const child of node.children ?? []) {
				if (expandParents(child, node.dir ? [...ancestors, node.key] : ancestors)) return true;
			}
			return false;
		};
		expandParents(root, []);
		if (nextExpanded !== expandedKeysRef.current) {
			expandedKeysRef.current = nextExpanded;
			setExpandedKeys(nextExpanded);
		}
		setTreeScrollRequest(value => value + 1);
	}, [fetchAssetChildren]);

	const scheduleGitAssetsRefresh = useCallback((): Promise<void> => {
		return loadAssets().then(() => { });
	}, [loadAssets]);

	useEffect(() => {
		const handleRefreshTree = () => {
			void scheduleGitAssetsRefresh();
		};
		Service.addRefreshTreeListener(handleRefreshTree);
		return () => {
			Service.removeRefreshTreeListener(handleRefreshTree);
		};
	}, [scheduleGitAssetsRefresh]);




	const loadEntries = useCallback(() => {
		return Service.entryList().then((res) => {
			if (res.success) {
				setToolEntries(res.tools ?? []);
				setGameEntries(res.games ?? []);
			}
			return res;
		}).catch(() => {
			return null;
		});
	}, []);
	const visibleEntries = useMemo(() => {
		const entries = entryView === "tool" ? toolEntries : gameEntries;
		const filter = entryFilter.trim().toLowerCase();
		if (filter.length === 0) return entries;
		return entries.filter((entry) => entry.name.toLowerCase().includes(filter));
	}, [entryFilter, entryView, gameEntries, toolEntries]);

	useEffect(() => {
		if (Info.version === undefined) {
			addAlert(t("alert.getInfo"), "error");
			return;
		}
		addAlert(t("alert.platform", { platform: Info.platform }), "success");
		document.addEventListener("keydown", (event: KeyboardEvent) => {
			if (event.key === "Escape") {
				setKeyEvent(event);
				return;
			}
			if (event.ctrlKey || event.altKey || event.metaKey) {
				switch (event.key) {
					case 'N': case 'n':
					case 'D': case 'd':
					case 'S': case 's':
					case 'W': case 'w':
					case 'R': case 'r':
					case 'B': case 'b':
					case 'P': case 'p':
					case 'Q': case 'q':
					case '.': {
						event.preventDefault();
						setKeyEvent(event);
						break;
					}
					default: {
						const index = Number.parseInt(event.key);
						if (!Number.isNaN(index) && index >= 1 && index <= 9) {
							event.preventDefault();
							setKeyEvent(event);
						}
						break;
					}
				}
			}
		}, true);
		window.addEventListener("resize", () => {
			const nextSize = {
				width: window.innerWidth,
				height: window.innerHeight
			};
			if (
				windowWidthRef.current >= narrowSplitBreakpoint &&
				nextSize.width < narrowSplitBreakpoint
			) {
				setDrawerOpen(false);
			}
			windowWidthRef.current = nextSize.width;
			setWinSize(nextSize);
		});
		Service.addWSOpenListener(() => {
			addAlert(t("log.open"), "success");
			setDisconnected(false);
		});
		Service.addWSCloseListener(() => {
			addAlert(t("log.close"), "error");
			setDisconnected(true);
		});
		Service.openWebSocket();
		Promise.all([
			loadAssets(),
			loadEntries(),
		]).then(([res]) => {
			if (res !== null) {
				setExpandedKeys([res.key]);
			}
			Service.editingInfo().then(res => {
				const fileParam = new URLSearchParams(window.location.search).get("file");
				if (fileParam !== null && fileParam !== "") {
					const normalizedFile = decodeURIComponent(fileParam);
					const editingInfo: Service.EditingInfo = {
						index: 0,
						files: [{
							key: normalizedFile,
							title: path.basename(normalizedFile),
							folder: false,
							position: { lineNumber: 1, column: 1 },
						}],
					};
					void openEditingInfoFiles(editingInfo);
				} else if (res.success && res.editingInfo) {
					const editingInfo: Service.EditingInfo = JSON.parse(res.editingInfo);
					void openEditingInfoFiles(editingInfo);
				}
			});
		});
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	writablePath = treeData.at(0)?.key ?? "";
	assetPath = treeData.at(0)?.children?.at(0)?.key ?? "";

	const getWorkspaceDisplayPath = (targetPath: string, trailingSep = false) => {
		const builtin = assetPath !== "" && isChildFolder(targetPath, assetPath);
		const basePath = builtin ? assetPath : writablePath;
		const rootLabel = builtin ? t("tree.builtin") : t("tree.assets");
		const relativePath = basePath !== "" ? path.relative(basePath, targetPath) : "";
		const segments = relativePath.split(/[\\/]+/).filter(Boolean);
		const displayPath = segments.length > 0 ? [rootLabel, ...segments].join("/") : rootLabel;
		return trailingSep && segments.length > 0 ? displayPath + path.sep : displayPath;
	};

	useEffect(() => {
		configureTypeScriptSearchPaths(assetPath);
	}, [treeData]);

	const setModified = useCallback((modified: Modified) => {
		setFiles(prev => {
			let changed = false;
			prev.forEach(file => {
				if (file.key === modified.key) {
					if (modified.content !== file.content || file.yarnData || file.codeWireData) {
						file.contentModified = modified.content;
						if (modified.blocklyCode !== undefined) {
							file.blocklyData = modified.blocklyCode;
						}
						changed = true;
					} else if (file.contentModified !== null) {
						file.contentModified = null;
						changed = true;
					}
				}
			});
			if (changed) {
				return [...prev];
			}
			return prev;
		});
	}, []);

	contentModified = files.find(file => file.contentModified !== null) !== undefined;

	const checkFileReadonly = useCallback((key: string, withPrompt: boolean) => {
		if (Info.engineDev) return false;
		if (key === "" || assetPath === "") return true;
		if (isChildFolder(key, assetPath)) {
			if (withPrompt) {
				addAlert(t("alert.builtin"), "info");
			}
			return true;
		}
		return false;
	}, [addAlert, t]);

	const onModified = useCallback((editingFile: EditingFile, content: string, lastChange?: Monaco.editor.IModelContentChange) => {
		const editor = editingFile.editor;
		if (editor === undefined) return;
		const model = editor.getModel();
		if (model === null) return;
		if (!checkFileReadonly(editingFile.key, false) && !editingFile.readOnly) {
			// Keep the tab snapshot in sync before the debounced validation runs.
			// Otherwise a quick tab round-trip can remount the editor with the
			// previous snapshot and overwrite the retained Monaco model.
			editingFile.contentModified = content !== editingFile.content ? content : null;
			lastEditorActionTime = Date.now();
			setIsEditorActioning(true);
			new Promise((resolve) => {
				setTimeout(resolve, 500);
			}).then(() => {
				if (Date.now() - lastEditorActionTime >= 500) {
					setModified({ key: editingFile.key, content });
					checkFile(editingFile, content, model, lastChange);
					setIsEditorActioning(false);
				}
			});
		}
	}, [checkFileReadonly, setModified]);

	const handleDrawerOpen = () => {
		setDrawerOpen(open => !open);
	};

	const switchTab = useCallback(async (newValue: number | null, fileToFocus?: EditingFile) => {
		if (tabIndex !== null) {
			files[tabIndex]?.editor?.updateOptions({
				stickyScroll: {
					enabled: false,
				}
			});
		}
		setTabIndex(newValue);
		if (newValue === null) return;
		if (fileToFocus !== undefined) {
			await revealTreeNode(fileToFocus.key);
		}
	}, [files, revealTreeNode, tabIndex]);

	const tabBarOnChange = useCallback((newValue: number) => {
		switchTab(newValue, files[newValue]);
	}, [switchTab, files]);

	const currentFile = tabIndex !== null ? files.at(tabIndex) : undefined;
	const currentFileKey = currentFile?.key;
	const firstProjectTourEditingFile = firstProjectTourFile === null
		? undefined
		: files.find(file => file.key === firstProjectTourFile);
	const firstProjectTourExampleReady = (
		firstProjectTourEditingFile?.contentModified
		?? firstProjectTourEditingFile?.content
		?? ""
	).includes(firstProjectExampleCode);
	const insertFirstProjectExample = useCallback(() => {
		const editor = firstProjectTourEditingFile?.editor;
		const model = editor?.getModel();
		if (editor === undefined || model === null || model === undefined) return;
		const content = model.getValue();
		if (content.includes(firstProjectExampleCode)) {
			editor.focus();
			return;
		}
		const separator = content.length === 0
			? ""
			: content.endsWith("\n\n")
				? ""
				: content.endsWith("\n")
					? "\n"
					: "\n\n";
		const lineNumber = model.getLineCount();
		const column = model.getLineMaxColumn(lineNumber);
		editor.executeEdits("first-project-tour", [{
			range: {
				startLineNumber: lineNumber,
				startColumn: column,
				endLineNumber: lineNumber,
				endColumn: column,
			},
			text: `${separator}${firstProjectExampleCode}`,
			forceMoveMarkers: true,
		}]);
		editor.setPosition(model.getPositionAt(model.getValueLength()));
		editor.focus();
	}, [firstProjectTourEditingFile]);
	const previousLeftDockTabRef = useRef(leftDockTab);
	useEffect(() => {
		const previousTab = previousLeftDockTabRef.current;
		previousLeftDockTabRef.current = leftDockTab;
		if (
			leftDockTab !== "explorer"
			|| previousTab === "explorer"
			|| currentFileKey === undefined
		) {
			return;
		}
		void revealTreeNode(currentFileKey);
	}, [currentFileKey, leftDockTab, revealTreeNode]);
	const revalidateActiveTypeScriptModel = useCallback((model: Monaco.editor.ITextModel) => {
		const ext = path.extname(model.uri.fsPath).toLowerCase();
		if (ext !== ".ts" && ext !== ".tsx") return;
		const searchPathUpdateId = ++typeScriptSearchPathUpdateId;
		void (async () => {
			const projectSourceRoot = await getProjectSourceRoot(model.uri.fsPath);
			if (
				searchPathUpdateId !== typeScriptSearchPathUpdateId ||
				model.isDisposed() ||
				currentTypeScriptModelRef.current !== model
			) return;
			configureTypeScriptSearchPaths(assetPath, projectSourceRoot);
			const { revalidateModel } = await import('./TranspileTS');
			if (
				searchPathUpdateId !== typeScriptSearchPathUpdateId ||
				model.isDisposed() ||
				currentTypeScriptModelRef.current !== model
			) return;
			void revalidateModel(model);
		})();
	}, []);
	const openAgentSessionTab = useCallback(async (
		targetPath: string,
		isDir: boolean,
		options?: { silentWhenNotFound?: boolean; }
	) => {
		const rootRes = await Service.agentProjectRoot({ path: targetPath, isDir });
		if (!rootRes.success) {
			addAlert(rootRes.message ?? t("alert.read"), "error");
			return false;
		}
		if (!rootRes.found || !rootRes.projectRoot) {
			if (!options?.silentWhenNotFound) {
				addAlert(rootRes.message ?? t("agent.fileNotInProject"), "info");
			}
			return false;
		}
		const createRes = await Service.agentSessionCreate({
			projectRoot: rootRes.projectRoot,
			title: rootRes.title,
		});
		if (!createRes.success) {
			addAlert(createRes.message, "error");
			return false;
		}
		const normalizedTitle = rootRes.title ?? path.basename(rootRes.projectRoot);
		const tabKey = rootRes.projectRoot;
		const existingIndex = files.findIndex(file => file.key === tabKey);
		if (existingIndex >= 0) {
			const updatedFile: EditingFile = {
				...files[existingIndex],
				title: normalizedTitle,
				folder: true,
				agentSessionId: createRes.session.id,
				workspaceView: "agent",
			};
			setFiles(prev => prev.map((file, index) => index === existingIndex ? updatedFile : file));
			switchTab(existingIndex, updatedFile);
			return true;
		}
		const newFile: EditingFile = {
			key: tabKey,
			title: normalizedTitle,
			content: "",
			contentModified: null,
			folder: true,
			status: "normal",
			onMount: () => { },
			agentSessionId: createRes.session.id,
			workspaceView: "agent",
		};
		setFiles(prev => {
			const next = [...prev, newFile];
			switchTab(next.length - 1, newFile);
			return next;
		});
		return true;
	}, [addAlert, files, switchTab, t]);

	const persistFirstProjectTourCompletion = useCallback(async () => {
		try {
			const res = await Service.info({ webIDETourCompleted: true });
			if (!res.webIDETourCompleted) {
				throw new Error("Failed to persist the Web IDE tour status");
			}
			Info.webIDETourCompleted = true;
			setFirstProjectTourCompleted(true);
			return true;
		} catch {
			addAlert(t("onboarding.saveFailed"), "error");
			return false;
		}
	}, [addAlert, t]);

	const completeFirstProjectTour = useCallback(() => {
		void persistFirstProjectTourCompletion().then((completed) => {
			if (!completed) return;
			setFirstProjectTourOpen(false);
			setFirstProjectTourCreating(false);
			setFirstProjectTourFile(null);
			setFileInfo(null);
		});
	}, [persistFirstProjectTourCompletion]);

	const openProjectWorkspaceTab = useCallback((projectPath: string, workspaceView: "upload" | "git" = "upload") => {
		const normalizedTitle = path.basename(projectPath);
		const existingIndex = files.findIndex(file => file.key === projectPath);
		if (existingIndex >= 0) {
			const updatedFile: EditingFile = {
				...files[existingIndex],
				title: normalizedTitle,
				folder: true,
				workspaceView,
			};
			setFiles(prev => prev.map((file, index) => index === existingIndex ? updatedFile : file));
			switchTab(existingIndex, updatedFile);
			return;
		}
		const newFile: EditingFile = {
			key: projectPath,
			title: normalizedTitle,
			content: "",
			contentModified: null,
			folder: true,
			status: "normal",
			onMount: () => { },
			workspaceView,
		};
		setFiles(prev => {
			const next = [...prev, newFile];
			switchTab(next.length - 1, newFile);
			return next;
		});
	}, [files, switchTab]);

	const onFixLog = useCallback(async (request: LogFixRequest) => {
		setOpenLog(null);
		setOpenBottomLog(false);
		if (currentFile === undefined) {
			addAlert(t("log.fixNoProject"), "info");
			return;
		}
		const runningSessionRes = await Service.agentRunningTasks();
		if (!runningSessionRes.success) {
			addAlert(runningSessionRes.message, "error", true);
			return;
		}
		const runningSession = runningSessionRes.sessions?.[0];
		if (runningSession !== undefined) {
			addAlert(t("log.fixAgentRunning", { title: runningSession.title }), "info");
			return;
		}
		const rootRes = await Service.agentProjectRoot({ path: currentFile.key, isDir: currentFile.folder });
		if (!rootRes.success) {
			addAlert(rootRes.message ?? t("log.fixNoProject"), "error");
			return;
		}
		if (!rootRes.found || !rootRes.projectRoot) {
			addAlert(rootRes.message ?? t("log.fixNoProject"), "info");
			return;
		}
		try {
			await Service.stop();
		} catch {
			addAlert(t("alert.stopFailed"), "error");
			return;
		}
		const createRes = await Service.agentSessionCreate({
			projectRoot: rootRes.projectRoot,
			title: rootRes.title,
		});
		if (!createRes.success) {
			addAlert(createRes.message, "error");
			return;
		}
		const initialPrompt = request.message;
		const normalizedTitle = rootRes.title ?? path.basename(rootRes.projectRoot);
		const tabKey = rootRes.projectRoot;
		const existingIndex = files.findIndex(file => file.key === tabKey);
		if (existingIndex >= 0) {
			const updatedFile: EditingFile = {
				...files[existingIndex],
				title: normalizedTitle,
				folder: true,
				agentSessionId: createRes.session.id,
				agentInitialPrompt: initialPrompt,
				workspaceView: "agent",
			};
			setFiles(prev => prev.map((file, index) => index === existingIndex ? updatedFile : file));
			switchTab(existingIndex, updatedFile);
			return;
		}
		const newFile: EditingFile = {
			key: tabKey,
			title: normalizedTitle,
			content: "",
			contentModified: null,
			folder: true,
			status: "normal",
			onMount: () => { },
			agentSessionId: createRes.session.id,
			agentInitialPrompt: initialPrompt,
			workspaceView: "agent",
		};
		setFiles(prev => {
			const next = [...prev, newFile];
			switchTab(next.length - 1, newFile);
			return next;
		});
	}, [addAlert, currentFile, files, switchTab, t]);
	useEffect(() => {
		if (currentFile !== undefined) {
			const ext = path.extname(currentFile.key).toLowerCase();
			if (ext !== ".ts" && ext !== ".tsx") {
				currentTypeScriptModelRef.current = null;
			}
			if (ext === ".yarn" && !currentFile.yarnTextEditing) {
				requestAnimationFrame(() => {
					currentFile.yarnData?.refreshLayout();
					currentFile.yarnData?.warpToFocusedNode();
					setTimeout(() => {
						currentFile.yarnData?.refreshLayout();
					}, 160);
				});
				return;
			}
			const { editor } = currentFile;
			if (editor === undefined) return;
			editor.focus();
			editor.updateOptions({
				stickyScroll: {
					enabled: true,
				},
			});
			if (currentFile.position) {
				const { position } = currentFile;
				currentFile.position = undefined;
				setFiles(prev => [...prev]);
				setTimeout(() => {
					editor.setPosition(position);
					editor.revealPositionInCenter(position);
				}, 100);
			}
			const model = editor.getModel();
			if (model === null) {
				currentTypeScriptModelRef.current = null;
				return;
			}
			if (!checkFileReadonly(currentFile.key, false) && !currentFile.readOnly) {
				checkFile(currentFile, currentFile.contentModified ?? currentFile.content, model);
			}
			if (ext === ".ts" || ext === ".tsx") {
				currentTypeScriptModelRef.current = model;
				revalidateActiveTypeScriptModel(model);
			} else if (currentTypeScriptModelRef.current === model) {
				currentTypeScriptModelRef.current = null;
			}
		} else {
			currentTypeScriptModelRef.current = null;
		}
	}, [currentFile, currentFile?.editor, checkFileReadonly, revalidateActiveTypeScriptModel]);

	const onEditorDidMount = useCallback((file: EditingFile) => async (editor: Monaco.editor.IStandaloneCodeEditor) => {
		file.editor = editor;
		if (file.viewState) {
			editor.restoreViewState(file.viewState);
		}
		setFiles(prev => [...prev]);
		let inferLang: "lua" | "tl" | "yue" | null = null;
		const ext = path.extname(file.key).toLowerCase().substring(1);
		switch (ext) {
			case "lua": case "tl": case "yue":
				inferLang = ext;
				break;
		}
		if (ext === "wa") {
			const { key } = file;
			editor.addAction({
				id: "dora-action-format",
				label: t("editor.format"),
				keybindings: [
					monaco.KeyCode.KeyK | monaco.KeyMod.CtrlCmd,
					monaco.KeyCode.KeyK | monaco.KeyMod.WinCtrl,
				],
				contextMenuGroupId: "navigation",
				contextMenuOrder: 2,
				run: async function () {
					const model = editor.getModel();
					if (model === null) return;
					const wres = await Service.write({ path: key, content: model.getValue() });
					if (!wres.success) return;
					const res = await Service.formatWa({ file: key });
					if (res.success) {
						model.pushStackElement();
						model.pushEditOperations(null, [{
							text: res.code,
							range: model.getFullModelRange()
						}], () => { return null });
					}
				}
			});
		}
		if (inferLang !== null) {
			const lang = inferLang;
			type InferDefinitionTarget = {
				file: string;
				title?: string;
				lineNumber: number;
				column: number;
			};
			const openInferDefinition = (
				target: InferDefinitionTarget | null | undefined,
				ed: Monaco.editor.ICodeEditor = editor,
			) => {
				if (target === null || target === undefined) return;
				const currentModel = ed.getModel();
				if (currentModel !== null && path.relative(currentModel.uri.fsPath, target.file) === "") {
					const pos = {
						lineNumber: target.lineNumber,
						column: target.column,
					};
					ed.setPosition(pos);
					ed.revealPositionInCenterIfOutsideViewport(pos);
					ed.focus();
					return;
				}
				openFileInTabRef.current(
					target.file,
					target.title ?? path.basename(target.file),
					false,
					{ lineNumber: target.lineNumber, column: target.column },
				);
			};
			const inferDefinitionCommand = editor.addCommand(0, (_accessor, target?: InferDefinitionTarget) => {
				openInferDefinition(target);
			});
			const inferModel = editor.getModel();
			if (inferDefinitionCommand !== null && inferModel !== null) {
				const modelUri = inferModel.uri.toString();
				setInferDefinitionCommand(modelUri, inferDefinitionCommand);
				editor.onDidDispose(() => {
					setInferDefinitionCommand(modelUri, null);
				});
			}
			editor.addAction({
				id: "dora-action-definition",
				label: t("editor.goToDefinition"),
				keybindings: [
					monaco.KeyCode.F12 | monaco.KeyMod.CtrlCmd,
					monaco.KeyCode.F12 | monaco.KeyMod.WinCtrl,
				],
				contextMenuGroupId: "navigation",
				contextMenuOrder: 1,
				run: function (ed) {
					const position = ed.getPosition();
					if (position === null) return;
					const model = ed.getModel();
					if (model === null) return;
					const word = model.getWordAtPosition(position);
					if (word === null) return;
					const line: string = model.getValueInRange({
						startLineNumber: position.lineNumber,
						startColumn: 1,
						endLineNumber: position.lineNumber,
						endColumn: word.endColumn,
					});
					Service.infer({
						lang, line,
						file: file.key,
						row: position.lineNumber,
						content: model.getValue()
					}).then(function (res) {
						if (!res.success) return;
						if (!res.infered) return;
						if (res.infered.key !== undefined) {
							openInferDefinition({
								file: res.infered.key,
								title: path.basename(res.infered.file),
								lineNumber: res.infered.row,
								column: res.infered.col,
							}, ed);
						} else if (res.infered.row > 0 && res.infered.col > 0) {
							openInferDefinition({
								file: model.uri.fsPath,
								lineNumber: res.infered.row,
								column: res.infered.col,
							}, ed);
						}
					});
				},
			});
			const readOnly = file.readOnly || checkFileReadonly(file.key, false);
			if (!readOnly && (lang === "tl" || lang === "lua")) {
				editor.addAction({
					id: "dora-action-require",
					label: t("editor.require"),
					keybindings: [
						monaco.KeyCode.F1 | monaco.KeyMod.CtrlCmd,
						monaco.KeyCode.F1 | monaco.KeyMod.WinCtrl,
					],
					contextMenuGroupId: "navigation",
					contextMenuOrder: 2,
					run: function (ed) {
						const position = ed.getPosition();
						if (position === null) return;
						const model = ed.getModel();
						if (model === null) return;
						const word = model.getWordAtPosition(position);
						if (word === null) return;
						model.pushEditOperations(null, [{
							text: `local ${word.word} <const> = require("${word.word}")\n`,
							range: {
								startLineNumber: 1,
								startColumn: 0,
								endLineNumber: 1,
								endColumn: 0
							}
						}], () => { return null });
					},
				});
			}
		}
		const model = editor.getModel();
		if (model) {
			const expectedContent = file.contentModified ?? file.content;
			if (model.getValue() !== expectedContent) {
				model.setValue(expectedContent);
			}
		}
		if (ext === "tsx" || ext === "ts") {
			await initializeMonacoDeclarations();
			configureTypeScriptSearchPaths(assetPath);
			const monacoTypescript = getMonacoTypeScript();
			if (ext === "tsx") {
				import('./languages/jsx-monaco').then(({ jsxSyntaxHighlight }) => {
					const { highlighter, dispose } = jsxSyntaxHighlight.highlighterBuilder({
						editor,
					});
					highlighter();
					editor.onDidChangeModelContent(() => {
						highlighter();
					})
					editor.onDidDispose(() => {
						dispose();
					});
				});
			}
			const model = editor.getModel();
			if (model === null) {
				return;
			}
			const projFile = model.uri.fsPath;
			const projectSourceRoot = await getProjectSourceRoot(projFile);
			configureTypeScriptSearchPaths(assetPath, projectSourceRoot);
			let revalidateTimer: number | undefined;
			const scheduleModelRevalidation = () => {
				if (editor.getModel() !== model || currentTypeScriptModelRef.current !== model) return;
				if (revalidateTimer !== undefined) {
					window.clearTimeout(revalidateTimer);
				}
				revalidateTimer = window.setTimeout(() => {
					revalidateTimer = undefined;
					if (editor.getModel() !== model || currentTypeScriptModelRef.current !== model) return;
					revalidateActiveTypeScriptModel(model);
				}, 500);
			};
			const revalidateContentChange = editor.onDidChangeModelContent(scheduleModelRevalidation);
			editor.onDidDispose(() => {
				if (revalidateTimer !== undefined) {
					window.clearTimeout(revalidateTimer);
					revalidateTimer = undefined;
				}
				revalidateContentChange.dispose();
			});
			type TypeScriptDefinitionTarget = {
				file: string;
				lineNumber: number;
				column: number;
			};
			type TypeScriptDisplayPart = {
				text: string;
			};
			type TypeScriptQuickInfo = {
				displayParts?: TypeScriptDisplayPart[];
				documentation?: TypeScriptDisplayPart[];
				textSpan?: {
					start: number;
					length: number;
				};
			};
			const displayPartsToString = (parts: TypeScriptDisplayPart[] | undefined) => {
				return parts?.map((part) => part.text).join("").trim() ?? "";
			};
			const getPositionAtOffset = (content: string, offset: number): Monaco.IPosition => {
				const clampedOffset = Math.max(0, Math.min(offset, content.length));
				const prefix = content.slice(0, clampedOffset);
				const lines = prefix.split(/\r\n|\r|\n/);
				return {
					lineNumber: lines.length,
					column: lines[lines.length - 1].length + 1,
				};
			};
			const normalizeDefinitionFile = async (fileName: string) => {
				const targetFile = toFilePath(fileName);
				if (path.isAbsolute(targetFile)) return targetFile;
				const res = await Service.read({ path: targetFile, projFile, projectRoot: projectSourceRoot });
				if (res.success) return res.fullPath;
				return path.join(path.dirname(projFile), targetFile);
			};
			const resolveTypeScriptDefinitionTarget = async (
				sourceModel: Monaco.editor.ITextModel,
				position: Monaco.IPosition,
			): Promise<TypeScriptDefinitionTarget | null> => {
				const getWorker = await monacoTypescript.getTypeScriptWorker();
				const worker = await getWorker(sourceModel.uri);
				const definitions = await worker.getDefinitionAtPosition(
					sourceModel.uri.toString(),
					sourceModel.getOffsetAt(position),
				) as { fileName: string; textSpan: { start: number; length: number } }[] | undefined;
				const definition = definitions?.find((item) => item.fileName !== undefined && item.textSpan !== undefined);
				if (definition === undefined) return null;
				const targetFile = await normalizeDefinitionFile(definition.fileName);
				if (targetFile === "") return null;
				const targetUri = monaco.Uri.file(targetFile);
				const targetModel = monaco.editor.getModel(targetUri);
				if (targetModel !== null) {
					return {
						file: targetFile,
						...targetModel.getPositionAt(definition.textSpan.start),
					};
				}
				const res = await Service.read({ path: targetFile, projFile, projectRoot: projectSourceRoot });
				if (!res.success) return null;
				return {
					file: targetFile,
					...getPositionAtOffset(res.content, definition.textSpan.start),
				};
			};
			const openTypeScriptDefinition = (
				target: TypeScriptDefinitionTarget | null | undefined,
				ed: Monaco.editor.ICodeEditor = editor,
			) => {
				if (target === null || target === undefined) return;
				const currentModel = ed.getModel();
				if (currentModel !== null && path.relative(currentModel.uri.fsPath, target.file) === "") {
					const pos = {
						lineNumber: target.lineNumber,
						column: target.column,
					};
					ed.setPosition(pos);
					ed.revealPositionInCenterIfOutsideViewport(pos);
					return;
				}
				openFileInTabRef.current(
					target.file,
					path.basename(target.file),
					false,
					{ lineNumber: target.lineNumber, column: target.column },
				);
			};
			const openTypeScriptDefinitionCommand = editor.addCommand(0, (_accessor, target?: TypeScriptDefinitionTarget) => {
				openTypeScriptDefinition(target);
			});
			let definitionHoverProvider: Monaco.IDisposable | null = null;
			if (openTypeScriptDefinitionCommand !== null) {
				const sourceUri = model.uri.toString();
				definitionHoverProvider = monaco.languages.registerHoverProvider("typescript", {
					provideHover: async (hoverModel, position) => {
						if (hoverModel.uri.toString() !== sourceUri) return undefined;
						const getWorker = await monacoTypescript.getTypeScriptWorker();
						const worker = await getWorker(hoverModel.uri);
						const quickInfo = await worker.getQuickInfoAtPosition(
							hoverModel.uri.toString(),
							hoverModel.getOffsetAt(position),
						) as TypeScriptQuickInfo | undefined;
						const target = await resolveTypeScriptDefinitionTarget(hoverModel, position);
						if (quickInfo === undefined && target === null) return undefined;
						const contents: Monaco.IMarkdownString[] = [];
						const display = displayPartsToString(quickInfo?.displayParts);
						if (display !== "") {
							contents.push({
								value: "```typescript\n" + display + "\n```",
							});
						}
						const documentation = displayPartsToString(quickInfo?.documentation);
						if (documentation !== "") {
							contents.push({
								value: documentation,
							});
						}
						if (target === null) {
							return {
								contents,
							};
						}
						const label = `${path.basename(target.file)}:${target.lineNumber}:${target.column}`;
						const commandUri = `command:${openTypeScriptDefinitionCommand}?${encodeURIComponent(JSON.stringify([target]))}`;
						contents.push({
							value: `[${label}](${commandUri})`,
							isTrusted: true,
						});
						const hoverRangeStart = quickInfo?.textSpan !== undefined ? hoverModel.getPositionAt(quickInfo.textSpan.start) : undefined;
						const hoverRangeEnd = quickInfo?.textSpan !== undefined ? hoverModel.getPositionAt(quickInfo.textSpan.start + quickInfo.textSpan.length) : undefined;
						return {
							range: hoverRangeStart !== undefined && hoverRangeEnd !== undefined
								? new monaco.Range(
									hoverRangeStart.lineNumber,
									hoverRangeStart.column,
									hoverRangeEnd.lineNumber,
									hoverRangeEnd.column,
								)
								: undefined,
							contents,
						};
					},
				});
				editor.onDidDispose(() => {
					definitionHoverProvider?.dispose();
				});
			}
			editor.addAction({
				id: "dora-action-typescript-definition",
				label: t("editor.goToDefinition"),
				keybindings: [
					monaco.KeyCode.F12 | monaco.KeyMod.CtrlCmd,
					monaco.KeyCode.F12 | monaco.KeyMod.WinCtrl,
				],
				contextMenuGroupId: "navigation",
				contextMenuOrder: 1,
				run: async function (ed) {
					const position = ed.getPosition();
					const currentModel = ed.getModel();
					if (position === null || currentModel === null) return;
					openTypeScriptDefinition(await resolveTypeScriptDefinitionTarget(currentModel, position), ed);
				},
			});
			const autoTyping = await AutoTypings.create(editor, {
				monaco: monaco as any,
				debounceDuration: 2000,
				sourceCache: {
					resolveFile: async (uri: string) => {
						const file = toFilePath(uri);
						const baseName = path.basename(file);
						const baseNameLower = baseName.toLowerCase();
						if (baseNameLower.startsWith('dora.') && baseName !== 'Dora.d.ts') {
							return undefined;
						} else if (baseNameLower.startsWith('es6-subset.')) {
							return undefined;
						} else if (baseNameLower.startsWith('lua.')) {
							return undefined;
						}
						const lib = getExtraLib(uri);
						if (lib !== undefined) return { content: lib.content, fullPath: file };
						const model = monaco.editor.getModel(monaco.Uri.file(file));
						if (model !== null) return { content: model.getValue(), fullPath: model.uri.fsPath };
						const res = await Service.read({ path: file, projFile, projectRoot: projectSourceRoot });
						if (res.success) {
							return { content: res.content, fullPath: res.fullPath };
						}
						return undefined;
					},
					isFileAvailable: async (uri: string) => {
						const file = toFilePath(uri);
						const baseName = path.basename(file);
						const baseNameLower = baseName.toLowerCase();
						if (baseNameLower.startsWith('dora.') && baseName !== 'Dora.d.ts') {
							return false;
						} else if (baseNameLower.startsWith('es6-subset.')) {
							return false;
						} else if (baseNameLower.startsWith('lua.')) {
							return false;
						}
						const lib = getExtraLib(uri);
						if (lib !== undefined) return true;
						const model = monaco.editor.getModel(monaco.Uri.file(file));
						if (model !== null) return true;
						const res = await Service.exist({ file, projFile, projectRoot: projectSourceRoot });
						return res.success;
					},
					getFile: async (uri: string) => {
						const file = toFilePath(uri);
						const lib = getExtraLib(uri);
						if (lib !== undefined) return lib.content;
						const model = monaco.editor.getModel(monaco.Uri.file(file));
						if (model !== null) return model.getValue();
						const res = await Service.read({ path: file, projFile, projectRoot: projectSourceRoot });
						if (res.success) {
							return res.content;
						}
						return undefined;
					}
				}
			});
			await autoTyping.resolveContents();
			const { revalidateModel } = await import('./TranspileTS');
			void revalidateModel(model);
		}
	}, [t, checkFileReadonly, revalidateActiveTypeScriptModel]);
	const onEditorWillUnmount = useCallback((file: EditingFile) => (editor: Monaco.editor.IStandaloneCodeEditor) => {
		if (file.editor !== editor) return;
		file.viewState = editor.saveViewState();
		file.editor = undefined;
	}, []);
	const switchTabRef = useRef(switchTab);
	const onEditorDidMountRef = useRef(onEditorDidMount);
	switchTabRef.current = switchTab;
	onEditorDidMountRef.current = onEditorDidMount;

	const openFile = useCallback((key: string, title: string, folder: boolean) => {
		return new Promise<EditingFile>((resolve, reject) => {
			if (folder) {
				if (checkFileReadonly(key, true)) {
					reject("file readonly");
					return;
				}
				const newFile: EditingFile = {
					key,
					title,
					folder: true,
					content: "",
					contentModified: null,
					status: "normal",
					onMount: () => { }
				};
				newFile.onMount = onEditorDidMount(newFile);
				resolve(newFile);
				return;
			}
			const ext = path.extname(title).toLowerCase();
			switch (ext) {
				case ".png":
				case ".jpg":
				case ".skel":
				case ".tic": {
					const newFile: EditingFile = {
						key,
						title,
						content: "",
						contentModified: null,
						folder: false,
						status: "normal",
						onMount: () => { },
					};
					newFile.onMount = onEditorDidMount(newFile);
					resolve(newFile);
					break;
				}
				case ".bl":
				case ".lua":
				case ".tl":
				case ".yue":
				case ".xml":
				case ".clip":
				case ".md":
				case ".yarn":
				case ".vs":
				case ".model":
				case ".par":
				case ".ts":
				case ".tsx":
				case ".wa":
				case ".mod": {
					Service.read({ path: key }).then((res) => {
						if (res.success && res.content !== undefined) {
							const { content } = res;
							const newFile: EditingFile = {
								key,
								title,
								content,
								contentModified: null,
								folder: false,
								status: "normal",
								onMount: () => { },
							};
							newFile.onMount = onEditorDidMount(newFile);
							resolve(newFile);
						} else {
							reject("file read error");
						}
					}).catch(() => {
						addAlert(t("alert.read", { title }), "error");
						reject("file read error");
					});
					break;
				}
				default: {
					Service.stat({ path: key }).then((res) => {
						let unsuppored = true;
						if (res.success) {
							if (res.size > 1024 * 1024) {
								addAlert(t("alert.largeFile", { title }), "error");
								reject("file read error");
							} else if (!res.isBinary) {
								unsuppored = false;
								Service.read({ path: key }).then((res) => {
									if (res.success && res.content !== undefined) {
										const { content } = res;
										const newFile: EditingFile = {
											key,
											title,
											content,
											contentModified: null,
											folder: false,
											status: "normal",
											onMount: () => { },
										};
										newFile.onMount = onEditorDidMount(newFile);
										resolve(newFile);
									} else {
										reject("file read error");
									}
								}).catch(() => {
									addAlert(t("alert.read", { title }), "error");
									reject("file read error");
								});
							}
						}
						if (unsuppored) {
							addAlert(t("alert.unsuppored", { title }), "warning");
							reject("unknown file type");
						}
					}).catch(() => {
						addAlert(t("alert.unsuppored", { title }), "warning");
						reject("unknown file type");
					});
					break;
				}
			}
		});
	}, [addAlert, checkFileReadonly, onEditorDidMount, t]);

	const openEditingInfoFiles = useCallback((editingInfo: Service.EditingInfo) => {
		let targetIndex = editingInfo.index;
		return Promise.all(editingInfo.files.map(async (file, i) => {
			try {
				const newFile = await openFile(file.key, file.title, file.folder);
				newFile.position = file.position;
				newFile.mdEditing = file.mdEditing;
				newFile.yarnTextEditing = file.yarnTextEditing;
				newFile.bodyTextEditing = file.bodyTextEditing;
				newFile.particleTextEditing = file.particleTextEditing;
				newFile.readOnly = file.readOnly;
				newFile.agentSessionId = file.agentSessionId;
				newFile.workspaceView = file.workspaceView ?? (file.agentSessionId !== undefined ? "agent" : (file.folder ? "upload" : undefined));
				newFile.sortIndex = i;
				return newFile;
			} catch {
				addAlert(t("alert.read", { title: file.title }), "error");
				return null;
			}
		})).then(async (files) => {
			const filteredFiles = files.filter(file => file !== null);
			const result = filteredFiles.sort((a, b) => {
				const indexA = a.sortIndex ?? 0;
				const indexB = b.sortIndex ?? 0;
				if (indexA < indexB) {
					return -1;
				} else if (indexA > indexB) {
					return 1;
				} else {
					return 0;
				}
			});
			setFiles(result);
			if (targetIndex >= result.length) {
				targetIndex = result.length - 1;
			}
			if (targetIndex < 0) {
				targetIndex = 0;
			}
			await switchTab(targetIndex, result[targetIndex]);
		}).catch(() => {
			addAlert(t("alert.open"), "error");
		});
	}, [addAlert, openFile, switchTab, t]);

	const openFileInTab = useCallback((key: string, title: string, folder: boolean, position?: Monaco.IPosition, readOnly?: boolean) => {
		let index: number | null = null;
		const file = files.find((file, i) => {
			if (path.relative(file.key, key) === "") {
				index = i;
				return true;
			}
			return false;
		});
		if (index === null) {
			openFile(key, title, folder).then((newFile) => {
				newFile.readOnly = readOnly;
				if (position !== undefined) {
					newFile.position = position;
					const ext = path.extname(title).toLowerCase();
					switch (ext) {
						case ".yarn": newFile.yarnTextEditing = true; break;
						case ".md": newFile.mdEditing = true; break;
						case ".lua": newFile.bodyTextEditing = isBodyLuaFile(title); break;
						case ".par": newFile.particleTextEditing = false; break;
					}
				}
				setFiles(files => {
					const newFiles = [...files, newFile];
					const lastIndex = newFiles.length - 1;
					switchTab(lastIndex, newFiles[lastIndex]);
					return newFiles;
				});
			}).catch(() => { });
		} else {
			switchTab(index, file);
			if (file && position) {
				file.position = position;
				const ext = path.extname(title).toLowerCase();
				switch (ext) {
					case ".yarn": file.yarnTextEditing = true; break;
					case ".md": file.mdEditing = true; break;
					case ".lua": file.bodyTextEditing = isBodyLuaFile(title); break;
					case ".par": file.particleTextEditing = false; break;
				}
				setFiles([...files]);
			}
		}
	}, [switchTab, files, openFile]);
	openFileInTabRef.current = openFileInTab;

	useEffect(() => {
		const handleOpenFile = (message: Service.OpenFileMessage) => {
			if (message.file === "") return;
			openFileInTab(
				message.file,
				message.title ?? path.basename(message.file),
				message.folder === true,
				message.position ?? { lineNumber: 1, column: 1 },
				message.readOnly === true,
			);
		};
		Service.addOpenFileListener(handleOpenFile);
		return () => {
			Service.removeOpenFileListener(handleOpenFile);
		};
	}, [openFileInTab]);

	useEffect(() => {
		const applyUpdateFileBatch = (events: UpdateFileEvent[]) => {
			if (events.length === 0) return;
			let nextRoot = treeDataRef.current.at(0);
			if (nextRoot === undefined) return;
			let nextExpanded = expandedKeysRef.current;
			let nextFiles = filesRef.current;
			let treeChanged = false;
			let expandedChanged = false;
			let filesChanged = false;
			let clearSelection = false;
			let removedActiveTab = false;

			for (let i = 0; i < events.length; i++) {
				const { file, exists, content } = events[i];
				if (!exists) {
					const removeResult = removeTreeNode(nextRoot, file);
					const removedNode = removeResult.removedNode;
					for (const model of monaco.editor.getModels()) {
						if (isChildFolder(model.uri.fsPath, file)) {
							model.dispose();
						}
					}
					if (nextRoot.key !== file && removedNode !== null) {
						nextRoot = removeResult.root;
						treeChanged = true;
					}
					const filteredExpanded = removeExpandedPath(nextExpanded, file);
					if (filteredExpanded.length !== nextExpanded.length) {
						nextExpanded = filteredExpanded;
						expandedChanged = true;
					}
					if (selectedKeysRef.current.some(key => isChildFolder(key, file))) {
						clearSelection = true;
					}
					const filteredFiles = nextFiles.filter(f => !isChildFolder(f.key, file));
					if (filteredFiles.length !== nextFiles.length) {
						const currentTabIndex = tabIndexRef.current;
						const currentTabKey = currentTabIndex !== null ? nextFiles[currentTabIndex]?.key : undefined;
						removedActiveTab = removedActiveTab || (currentTabKey !== undefined && isChildFolder(currentTabKey, file));
						nextFiles = filteredFiles;
						filesChanged = true;
					}
					continue;
				}

				const ensureResult = ensureFileNode(nextRoot, file);
				if (ensureResult.node !== null && ensureResult.created) {
					nextRoot = ensureResult.root;
					treeChanged = true;
					const expandedDir = expandDirPath(nextRoot.key, path.dirname(file), nextExpanded);
					if (expandedDir !== nextExpanded) {
						nextExpanded = expandedDir;
						expandedChanged = true;
					}
				}

				const existingIndex = nextFiles.findIndex(f => f.key === file);
				if (existingIndex >= 0) {
					if (path.extname(file).toLowerCase() === ".model") {
						continue;
					}
					const ext = path.extname(file).toLowerCase();
					const refreshPreview = previewFileExts.has(ext);
					nextFiles = nextFiles.map((item, index) => {
						if (index !== existingIndex) return item;
						return {
							...item,
							title: path.basename(file),
							content,
							contentModified: null,
							status: "normal" as TabStatus,
							previewVersion: refreshPreview ? (item.previewVersion ?? 0) + 1 : item.previewVersion,
						};
					});
					filesChanged = true;
				} else {
					const ext = path.extname(file).toLowerCase();
					if (previewFileExts.has(ext)) {
						nextFiles = nextFiles.map((item) => {
							if (!isBodyLuaFile(item.key) && path.extname(item.key).toLowerCase() !== ".par") return item;
							return {
								...item,
								previewVersion: (item.previewVersion ?? 0) + 1,
							};
						});
						filesChanged = true;
					}
				}
			}

			if (treeChanged) {
				treeDataRef.current = [nextRoot];
				setTreeData([nextRoot]);
			}
			if (expandedChanged) {
				expandedKeysRef.current = nextExpanded;
				setExpandedKeys(nextExpanded);
			}
			if (clearSelection) {
				setSelectedKeys([]);
				setSelectedNode(null);
			}
			if (filesChanged) {
				filesRef.current = nextFiles;
				setFiles(nextFiles);
				if (removedActiveTab) {
					if (nextFiles.length === 0) {
						switchTabRef.current(null);
					} else {
						const prevTabIndex = tabIndexRef.current;
						const fallbackIndex = Math.min(prevTabIndex ?? 0, nextFiles.length - 1);
						switchTabRef.current(fallbackIndex, nextFiles[fallbackIndex]);
					}
				}
			}
		};

		const pendingUpdateFiles = pendingUpdateFilesRef.current;
		const flushUpdateFileQueue = () => {
			updateFileFlushTimerRef.current = null;
			const events = [...pendingUpdateFiles.values()];
			pendingUpdateFiles.clear();
			applyUpdateFileBatch(events);
		};

		const handleUpdateFile = (file: string, exists: boolean, content: string) => {
			updateCachedFileSearch(file, exists);
			pendingUpdateFiles.set(file, { file, exists, content });
			if (updateFileFlushTimerRef.current !== null) return;
			updateFileFlushTimerRef.current = window.setTimeout(flushUpdateFileQueue, 500);
		};

		Service.addUpdateFileListener(handleUpdateFile);
		return () => {
			if (updateFileFlushTimerRef.current !== null) {
				window.clearTimeout(updateFileFlushTimerRef.current);
				updateFileFlushTimerRef.current = null;
			}
			pendingUpdateFiles.clear();
			Service.removeUpdateFileListener(handleUpdateFile);
		};
	}, [updateCachedFileSearch]);

	useEffect(() => {
		const terminalStatuses = new Set(["DONE", "FAILED", "STOPPED"]);
		const onPatch = (patch: Service.AgentSessionPatch) => {
			const session = patch.session;
			const taskStatus = session?.currentTaskStatus;
			const taskId = session?.currentTaskId;
			if (!session || !taskId || !taskStatus || !terminalStatuses.has(taskStatus)) {
				return;
			}
			const notifyKey = `${session.id}:${taskId}:${taskStatus}`;
			if (notifiedAgentTaskEndKeysRef.current.has(notifyKey)) {
				return;
			}
			notifiedAgentTaskEndKeysRef.current.add(notifyKey);
			const activeFile = tabIndexRef.current !== null ? filesRef.current[tabIndexRef.current] : undefined;
			const activeView = activeFile?.workspaceView ?? (activeFile?.agentSessionId !== undefined ? "agent" : undefined);
			const activeSessionTabOpen = activeView === "agent"
				&& (activeFile?.agentSessionId === session.id || activeFile?.agentSessionId === session.rootSessionId);
			if (activeSessionTabOpen) {
				return;
			}
			addAlert(t("alert.agentTaskDone", { title: session.title }), "info", false, {
				label: t("agent.open"),
				onClick: () => {
					void openAgentSessionTab(session.projectRoot, true);
				},
			});
		};
		Service.addAgentSessionPatchListener(onPatch);
		return () => {
			Service.removeAgentSessionPatchListener(onPatch);
		};
	}, [addAlert, openAgentSessionTab, t]);

	useEffect(() => {
		if (jumpToFile !== null) {
			openFileInTab(jumpToFile.key, jumpToFile.title, false, {
				lineNumber: jumpToFile.row,
				column: jumpToFile.col
			});
			setJumpToFile(null);
		}
	}, [jumpToFile, openFileInTab]);

	const onSelect = useCallback((nodes: TreeDataType[]) => {
		setSelectedKeys(nodes.map(n => n.key));
		if (nodes.length === 0) {
			setSelectedNode(null);
			return;
		}
		const { key, title, dir } = nodes[0];
		setSelectedNode(nodes[0]);
		if (dir) {
			void (async () => {
				const rootRes = await Service.agentProjectRoot({ path: key, isDir: true });
				if (rootRes.success && rootRes.found && rootRes.projectRoot === key) {
					const opened = await openAgentSessionTab(key, true, { silentWhenNotFound: true });
					if (
						opened
						&& firstProjectTourOpen
						&& firstProjectTourCurrent === 11
						&& firstProjectTourFile !== null
						&& key === path.dirname(firstProjectTourFile)
					) {
						completeFirstProjectTour();
					}
					return;
				}
				openFileInTab(key, title, true);
			})();
			return;
		}
		openFileInTab(key, title, dir);
	}, [
		completeFirstProjectTour,
		firstProjectTourCurrent,
		firstProjectTourFile,
		firstProjectTourOpen,
		openAgentSessionTab,
		openFileInTab,
	]);

	const onExpand = useCallback((keys: string[], info?: { node: TreeDataType; expanded: boolean }) => {
		const rootNode = treeData.at(0);
		if (rootNode === undefined) return;
		const changedKey = info?.node.key;
		if (changedKey === rootNode.key) {
			if (contentModified) {
				addAlert(t("alert.reloading"), "warning");
				return;
			}
			saveEditingInfo();
			const editingInfo = lastEditingInfo;
			const selectedKey = selectedKeysRef.current.at(0);
			setCheckedKeys([]);
			setBatchTargetMode(null);
			setFiles([]);
			void switchTab(null);
			loadAssets().then(async (res) => {
				if (res !== null) {
					addAlert(t("alert.reloaded"), "success");
					if (editingInfo !== null) {
						await openEditingInfoFiles(editingInfo);
					}
					const refreshedRoot = treeDataRef.current.at(0);
					const refreshedSelection = selectedKey !== undefined && refreshedRoot !== undefined
						? findTreeNode(refreshedRoot, selectedKey)
						: null;
					if (refreshedSelection !== null) {
						setSelectedKeys([refreshedSelection.key]);
						setSelectedNode(refreshedSelection);
					} else {
						setSelectedKeys([]);
						setSelectedNode(null);
					}
				}
			});
			return;
		}
		setExpandedKeys(keys);
	}, [addAlert, loadAssets, switchTab, openEditingInfoFiles, t, treeData]);

	const onAgentRollbackComplete = useCallback((projectRoot: string) => {
		void loadAssets();
		void (async () => {
			const nextFiles: EditingFile[] = [];
			let nextTabIndex = tabIndex;
			for (let i = 0; i < files.length; i++) {
				const file = files[i];
				if (file.agentSessionId || file.folder || file.contentModified !== null || !isChildFolder(file.key, projectRoot)) {
					nextFiles.push(file);
					continue;
				}
				const exists = await Service.exist({ file: file.key });
				if (!exists.success) {
					if (tabIndex !== null && i < tabIndex) {
						nextTabIndex = (nextTabIndex ?? 0) - 1;
					} else if (tabIndex === i) {
						nextTabIndex = null;
					}
					continue;
				}
				const res = await Service.read({ path: file.key });
				if (res.success && res.content !== undefined) {
					file.content = res.content;
					file.contentModified = null;
					const model = file.editor?.getModel();
					if (model && model.getValue() !== res.content) {
						model.setValue(res.content);
					}
				}
				nextFiles.push(file);
			}
			setFiles([...nextFiles]);
			if (nextTabIndex !== null) {
				if (nextTabIndex >= nextFiles.length) {
					nextTabIndex = nextFiles.length - 1;
				}
				if (nextTabIndex >= 0 && nextFiles[nextTabIndex]) {
					switchTab(nextTabIndex, nextFiles[nextTabIndex]);
				} else if (nextFiles.length === 0) {
					switchTab(null);
				}
			} else if (nextFiles.length === 0) {
				switchTab(null);
			}
		})();
	}, [files, loadAssets, switchTab, tabIndex]);

	const getRunningAgentSessionForProject = useCallback(async (projectRoot: string) => {
		const runningSessionRes = await Service.agentRunningTasks();
		if (!runningSessionRes.success) {
			return runningSessionRes;
		}
		return {
			success: true as const,
			session: runningSessionRes.sessions?.find(item => item.projectRoot === projectRoot),
		};
	}, []);

	const onPlayControlRun = useCallback(async (mode: "Run" | "Run This", noLog?: boolean, bottomLog?: boolean) => {
		if (isEditorActioning) {
			return;
		}
		let key: string | null = null;
		let title: string | null = null;
		let dir = false;
		if (tabIndex !== null) {
			const file = files.at(tabIndex);
			if (file !== undefined) {
				key = file.key;
				title = file.title;
				dir = file.folder;
				if (path.extname(title).toLowerCase() === ".md") {
					file.mdEditing = false;
					setFiles([...files]);
					return;
				}
			}
		}
		if (key === null || title === null) {
			if (selectedNode === null) {
				addAlert(t("alert.runNoTarget"), "info");
				return;
			}
			key = selectedNode.key;
			title = selectedNode.title;
			dir = selectedNode.dir;
		}
		let asProj = mode === "Run";
		if (dir) {
			if (mode === "Run This") {
				addAlert(t("alert.runThisNoFolder"), "info");
				return;
			}
			key = path.join(key, "init");
			asProj = true;
		}
		const ext = path.extname(key).toLowerCase();
		if ((ext === ".model" || ext === ".par") && !asProj) {
			addAlert(t("alert.modelRunCurrentUnsupported", { title }), "info");
			return;
		}
		switch (ext) {
			case ".lua":
			case ".yue":
			case ".tl":
			case ".ts":
			case ".tsx":
			case ".xml":
			case ".wasm":
			case ".yarn":
			case ".vs":
			case ".bl":
			case ".wa":
			case ".mod":
			case ".model":
			case ".par":
			case "": {
				if (ext === ".yarn" && !asProj) {
					break;
				}
				if ((ext === ".wa") && !asProj) {
					break;
				}
				if (ext === ".mod" && !asProj) {
					asProj = true;
				}
				const rootRes = await Service.projectRoot({ path: key, isDir: false });
				if (rootRes.success && rootRes.found && rootRes.projectRoot) {
					const runningAgentRes = await getRunningAgentSessionForProject(rootRes.projectRoot);
					if (!runningAgentRes.success) {
						addAlert(runningAgentRes.message, "error", true);
						return;
					}
					if (runningAgentRes.session !== undefined) {
						addAlert(t("alert.agentRunning", { title: runningAgentRes.session.title }), "info");
						return;
					}
				}
				setOpenBottomLog(bottomLog ?? false);
				Service.run({ file: key, asProj }).then((res) => {
					if (res.success) {
						addAlert(t("alert.run", { title: res.target ?? title }), "success");
						if (!noLog) setOpenLog({
							title: res.target ?? title ?? "Running",
							stopOnClose: true
						});
					} else {
						addAlert(t("alert.runFailed", { title: res.target ?? title }), "error");
					}
					if (!noLog && res.err !== undefined) {
						setPopupInfo({
							title: res.target ?? title ?? "",
							msg: res.err,
							raw: true
						});
					}
				}).catch(() => {
					addAlert(t("alert.runFailed", { title }), "error");
				})
				return;
			}
		}
		addAlert(t("alert.runFailed", { title }), "info");
	}, [addAlert, files, getRunningAgentSessionForProject, tabIndex, t, selectedNode, isEditorActioning]);

	const onLaunchToolEntry = useCallback((entry: Service.EntryLaunchInfo) => {
		Service.run({ file: entry.file, asProj: entry.asProj }).then((res) => {
			if (res.success) {
				addAlert(t("alert.run", { title: res.target ?? entry.name }), "success");
			} else {
				addAlert(t("alert.runFailed", { title: res.target ?? entry.name }), "error");
			}
			if (res.err !== undefined) {
				setPopupInfo({
					title: res.target ?? entry.name,
					msg: res.err,
					raw: true
				});
			}
		}).catch(() => {
			addAlert(t("alert.runFailed", { title: entry.name }), "error");
		});
	}, [addAlert, t]);

	const onOpenEntryWorkDir = useCallback(async (entry: Service.EntryLaunchInfo) => {
		const workDir = path.dirname(entry.file);
		if (await openAgentSessionTab(workDir, true, { silentWhenNotFound: true })) {
			return;
		}
		openFileInTab(workDir, path.basename(workDir), true);
	}, [openAgentSessionTab, openFileInTab]);

	const saveFileInTab = useCallback((file: EditingFile, preview: boolean) => {
		return new Promise<EditingFile[]>((resolve, reject) => {
			const saveFile = (extraFile?: EditingFile) => {
				const filesToSave = extraFile !== undefined ? [file, extraFile] : [file];
				if (file.contentModified !== null) {
					const readOnly = checkFileReadonly(file.key, true);
					if (readOnly) {
						addAlert(t("alert.builtin"), "warning");
						resolve(filesToSave);
						return;
					}
					const { contentModified } = file;
					Service.write({ path: file.key, content: contentModified }).then((res) => {
						if (res.success) {
							file.content = contentModified;
							file.contentModified = null;
							const ext = path.extname(file.key).toLowerCase();
							if (ext === '.yue' || ext === '.tl' || ext === '.xml') {
								const { key } = file;
								const extname = path.extname(key);
								const name = path.basename(key, extname);
								const dir = path.dirname(key);
								const luaFile = path.join(dir, name + ".lua");
								const fileInTab = files.find(f => path.relative(f.key, luaFile) === "");
								if (fileInTab !== undefined) {
									const resultCodes = res.resultCodes === undefined ? "" : res.resultCodes;
									fileInTab.content = resultCodes;
									setTimeout(() => {
										const model = monaco.editor.getModel(monaco.Uri.file(luaFile));
										if (model) {
											model.setValue(resultCodes);
										}
									}, 10);
									resolve([file, fileInTab]);
								} else {
									resolve(filesToSave);
								}
							} else if (ext === '.wa') {
								setIsWaSaving(true);
								Service.buildWa({ path: file.key }).then((res) => {
									if (!res.success) {
										addAlert(res.message, "error", true);
										Service.command({ code: `Log "Error", "${res.message.replace(/[\\"]/g, "\\$&")}"`, log: false });
									}
								}).finally(() => {
									setIsWaSaving(false);
									resolve(filesToSave);
								});
							} else {
								resolve(filesToSave);
							}
							switch (ext) {
								case ".ts": case ".tsx": case ".lua": case ".tl": case ".yue": case ".xml": case ".bl": {
									let index = contentModified.search(/@preview-file on\b/);
									if (preview && index >= 0) {
										let lineEnd: number | undefined = contentModified.indexOf("\n", index);
										if (lineEnd === -1) {
											lineEnd = undefined;
										}
										const line = contentModified.substring(index, lineEnd);
										if (line.search(/\bclear\b/) >= 0) {
											Service.clearLog();
										}
										const bottomLog = line.search(/\bnolog\b/) < 0;
										onPlayControlRun("Run This", true, bottomLog);
									} else {
										index = contentModified.search(/@preview-project on\b/);
										if (preview && index >= 0) {
											let lineEnd: number | undefined = contentModified.indexOf("\n", index);
											if (lineEnd === -1) {
												lineEnd = undefined;
											}
											const line = contentModified.substring(index, lineEnd);
											if (line.search(/\bclear\b/) >= 0) {
												Service.clearLog();
											}
											const bottomLog = line.search(/\bnolog\b/) < 0;
											onPlayControlRun("Run", true, bottomLog);
										}
									}
									break;
								}
							}
						} else {
							addAlert(t("alert.saveCurrent"), "error");
							reject("failed to save file");
						}
					}).catch(() => {
						addAlert(t("alert.saveCurrent"), "error");
						reject("failed to save file");
					});
				} else {
					resolve(filesToSave);
				}
			};
			if (file.yarnData !== undefined) {
				file.yarnData.getJSONData().then((value) => {
					const text = Yarn.convertYarnJsonToText(JSON.parse(value));
					file.contentModified = text;
					saveFile();
				}).catch(() => {
					addAlert(t("alert.saveCurrent"), "error");
					reject("failed to save file");
				})
			} else if (file.codeWireData !== undefined) {
				const { codeWireData } = file;
				const vscript = codeWireData.getVisualScript();
				if (file.contentModified !== null || file.content !== vscript) {
					file.contentModified = vscript;
					const tealCode = codeWireData.getScript();
					const extname = path.extname(file.key);
					const name = path.basename(file.key, extname);
					const tlFile = path.join(path.dirname(file.key), name + ".tl");
					const fileInTab = files.find(f => path.relative(f.key, tlFile) === "");
					if (fileInTab !== undefined) {
						fileInTab.content = tealCode;
						const model = monaco.editor.getModel(monaco.Uri.file(tlFile));
						if (model) {
							model.setValue(tealCode);
						}
					}
					Service.write({ path: tlFile, content: tealCode }).then((res) => {
						if (!res.success) {
							addAlert(t("alert.saveCurrent"), "error");
							reject("failed to save file");
						}
					}).then(() => {
						saveFile(fileInTab);
						Service.check({ file: tlFile, content: tealCode }).then((res) => {
							if (res.success && tealCode !== "") {
								codeWireData.reportVisualScriptError("");
							} else if (res.info !== undefined) {
								const lines = tealCode.split("\n");
								const message = [];
								for (const err of res.info) {
									const [, filename, row, , msg] = err;
									let node = "";
									if (path.relative(filename, tlFile) === "" && 1 <= row && row <= lines.length) {
										const ends = lines[row - 1].match(/-- (\d+)$/);
										if (ends !== null) {
											node = "node " + ends[1] + ", ";
										}
									}
									message.push(node + "line " + row + ": " + msg);
								}
								codeWireData.reportVisualScriptError(message.join("<br>"));
							}
						});
					}).catch(() => {
						addAlert(t("alert.saveCurrent"), "error");
						reject("failed to save file");
					});
				}
			} else if (file.blocklyData !== undefined) {
				const { key, blocklyData } = file;
				const extname = path.extname(key);
				const name = path.basename(key, extname);
				const luaFile = path.join(path.dirname(key), name + ".lua");
				const fileInTab = files.find(f => path.relative(f.key, luaFile) === "");
				if (fileInTab !== undefined) {
					fileInTab.content = blocklyData;
					const model = monaco.editor.getModel(monaco.Uri.file(luaFile));
					if (model) {
						model.setValue(blocklyData);
					}
				}
				Service.write({ path: luaFile, content: blocklyData }).then((res) => {
					if (res.success) {
						saveFile();
					}
				});
			} else {
				const ext = path.extname(file.key).toLowerCase();
				if (file.contentModified !== null && (ext === '.ts' || ext === '.tsx') && !file.key.toLocaleLowerCase().endsWith(".d.ts")) {
					const { key, contentModified, editor } = file;
					const model = editor?.getModel();
					import('./TranspileTS').then(async ({ transpileTypescript, setModelMarkers }) => {
						try {
							const res = await transpileTypescript(key, contentModified);
							const { luaCode, success, diagnostics, extraError } = res;
							if (!success) {
								if (extraError) {
									addAlert(t("alert.failedTS"), "error", true);
								}
								preview = false;
							}
							if (model) {
								await setModelMarkers(model, diagnostics);
							}
							if (luaCode === undefined) {
								saveFile();
								return;
							}
							const extname = path.extname(file.key);
							const name = path.basename(file.key, extname);
							const luaFile = path.join(path.dirname(file.key), name + ".lua");
							const fileInTab = files.find(f => path.relative(f.key, luaFile) === "");
							if (fileInTab !== undefined) {
								fileInTab.content = luaCode;
								const model = monaco.editor.getModel(monaco.Uri.file(luaFile));
								if (model) {
									model.setValue(luaCode);
								}
							}
							Service.write({ path: luaFile, content: luaCode }).then((res) => {
								if (res.success) {
									saveFile(fileInTab);
								} else {
									addAlert(t("alert.saveCurrent"), "error");
									reject("failed to save file");
								}
							}).catch(() => {
								addAlert(t("alert.saveCurrent"), "error");
								reject("failed to save file");
							});
						} catch (error) {
							console.error("failed to transpile TypeScript file", error);
							addAlert(t("alert.failedTS"), "error", true);
							saveFile();
						}
					});
				} else {
					saveFile();
				}
			}
		});
	}, [addAlert, t, onPlayControlRun, checkFileReadonly, files]);

	const saveAllTabs = useCallback(async () => {
		if (isSaving) {
			return false;
		}
		isSaving = true;
		const filesToSave = files.filter(file => file.contentModified !== null);
		try {
			const filesChanged = await Promise.all(filesToSave.map(file => {
				return saveFileInTab(file, false);
			}));
			const flatFilesChanged = filesChanged.flat();
			setFiles(prev => prev.map(file => {
				const changed = flatFilesChanged.find(f => f.key === file.key);
				return changed !== undefined ? changed : file;
			}));
			isSaving = false;
			return true;
		} catch (reason) {
			console.error(reason);
			isSaving = false;
			return false;
		}
	}, [saveFileInTab, files]);

	const closeCurrentTab = useCallback(() => {
		if (tabIndex !== null) {
			let currentIndex = tabIndex;
			const closeTab = () => {
				const newFiles = files.filter((_, index) => index !== currentIndex);
				if (newFiles.length === 0) {
					switchTab(null);
				} else {
					if (currentIndex >= newFiles.length) {
						currentIndex = newFiles.length - 1;
					}
					switchTab(currentIndex, newFiles[currentIndex]);
				}
				setFiles(newFiles);
			};
			if (files[tabIndex].contentModified !== null) {
				setPopupInfo({
					title: t("popup.closingTab"),
					msg: t("popup.closingNoSave"),
					cancelable: true,
					confirmed: closeTab,
				});
				return;
			}
			setTimeout(closeTab, 10);
		}
	}, [switchTab, t, files, tabIndex]);

	const closeAllTabs = useCallback(() => {
		const closeTabs = () => {
			setFiles([]);
			switchTab(null);
		};
		if (contentModified) {
			setPopupInfo({
				title: t("popup.closingTab"),
				msg: t("popup.closingNoSave"),
				cancelable: true,
				confirmed: closeTabs,
			});
			return;
		}
		closeTabs();
	}, [switchTab, t]);

	const closeOtherTabs = useCallback(() => {
		const closeTabs = () => {
			const newFiles = files.filter((_, index) => index === tabIndex);
			setFiles(newFiles);
			switchTab(0, newFiles[0]);
		};
		const otherModified = files.filter((_, index) => index !== tabIndex).find((file) => file.contentModified !== null) !== undefined;
		if (otherModified) {
			setPopupInfo({
				title: t("popup.closingTab"),
				msg: t("popup.closingNoSave"),
				cancelable: true,
				confirmed: closeTabs,
			});
			return;
		}
		closeTabs();
	}, [files, switchTab, t, tabIndex]);

	const handleAlertClose = () => {
		if (popupInfo?.confirmed !== undefined) {
			popupInfo.confirmed();
		}
		setPopupInfo(null);
	};

	const handleAlertCancel = () => {
		setPopupInfo(null);
	};

	const deleteFile = useCallback((data: TreeDataType) => {
		const rootNode = treeDataRef.current.at(0);
		if (rootNode === undefined) return;
		if (rootNode.key === data.key) {
			addAlert(t("alert.deleteRoot"), "info");
			return;
		}
		setPopupInfo({
			title: t("menu.delete"),
			msg: t(data.dir ? 'file.deleteFolder' : 'file.deleteFile', { name: data.title }),
			cancelable: true,
			confirmed: () => {
				void (async () => {
					const removeDeletedPathFromUI = async () => {
						updateCachedFileSearch(data.key, false);
						const currentRoot = treeDataRef.current.at(0);
						if (currentRoot !== undefined) {
							const removeResult = removeTreeNode(currentRoot, data.key);
							const nextExpanded = removeExpandedPath(expandedKeysRef.current, data.key);
							treeDataRef.current = [removeResult.root];
							expandedKeysRef.current = nextExpanded;
							setExpandedKeys(nextExpanded);
							setTreeData([removeResult.root]);
						}
						for (const model of monaco.editor.getModels()) {
							if (isChildFolder(model.uri.fsPath, data.key)) {
								model.dispose();
							}
						}
						const previousFiles = filesRef.current;
						const newFiles = previousFiles.filter(f => !isChildFolder(f.key, data.key));
						if (newFiles.length !== previousFiles.length) {
							filesRef.current = newFiles;
							setFiles(newFiles);
							const activeIndex = tabIndexRef.current;
							const activeKey = activeIndex !== null ? previousFiles[activeIndex]?.key : undefined;
							if (activeKey !== undefined && isChildFolder(activeKey, data.key)) {
								if (newFiles.length === 0) {
									switchTab(null);
								} else {
									const nextIndex = Math.min(activeIndex ?? 0, newFiles.length - 1);
									switchTab(nextIndex, newFiles[nextIndex]);
								}
							}
						}
						if (selectedKeysRef.current.some(key => isChildFolder(key, data.key))) {
							setSelectedKeys([]);
							setSelectedNode(null);
						}
						await refreshTreeDirectory(path.dirname(data.key), true);
					};
					try {
						let deleted = false;
						try {
							const res = await Service.deleteFile({ path: data.key });
							deleted = res.success;
						} catch {
							// The server may remove the path before a later cleanup step
							// causes the request to fail. Reconcile against the disk below.
						}
						if (!deleted) {
							const existRes = await Service.exist({ file: data.key });
							deleted = !existRes.success;
						}
						if (!deleted) {
							addAlert(t("alert.delete"), "error");
							return;
						}
						await removeDeletedPathFromUI();
						addAlert(t("alert.deleted", { title: data.title }), "success");
					} catch {
						addAlert(t("alert.delete"), "error");
					}
				})();
			},
		});
	}, [addAlert, refreshTreeDirectory, t, switchTab, updateCachedFileSearch]);

	const buildTreeData = useCallback(async (data: TreeDataType) => {
		const { key } = data;
		let built = false;
		const buildFile = async (key: string, buildFolder: boolean) => {
			const preferLog = buildFolder;
			if (checkFileReadonly(key, false)) return;
			let title: string;
			if (isChildFolder(key, writablePath)) {
				title = path.relative(writablePath, key);
			} else {
				title = path.relative(assetPath, key);
			}
			const ext = path.extname(key).toLowerCase();
			const name = path.basename(key, ext);
			if (path.extname(name) === ".d") return;
			const dir = path.dirname(key);
			const luaFile = path.join(dir, name + ".lua");
			const fileInTab = files.find(f => path.relative(f.key, luaFile) === "");
			try {
				if (ext === '.wa' && !buildFolder) {
					built = true;
					setIsWaSaving(true);
					try {
						const res = await Service.buildWa({ path: key });
						if (res.success) {
							addAlert(t("alert.build", { title }), "success");
						} else {
							addAlert(res.message, "error", true);
							await Service.command({ code: `Log "Error", "${res.message.replace(/[\\"]/g, "\\$&")}"`, log: false });
						}
					} finally {
						setIsWaSaving(false);
					}
				} else if (buildFolder && ext === '.mod') {
					built = true;
					setIsWaSaving(true);
					try {
						const res = await Service.buildWa({ path: key });
						if (res.success) {
							Service.command({ code: `Log "Info", "Built ${title.replace(/[\\"]/g, "\\$&")}"`, log: false });
						} else {
							await Service.command({ code: `Log "Error", "${res.message.replace(/[\\"]/g, "\\$&")}"`, log: false });
						}
					} finally {
						setIsWaSaving(false);
					}
				} else if (!buildFolder && ext === '.mod') {
					built = true;
					setIsWaSaving(true);
					try {
						const res = await Service.buildWa({ path: key });
						if (res.success) {
							addAlert(t("alert.build", { title }), "success");
						} else {
							addAlert(res.message, "error", true);
							await Service.command({ code: `Log "Error", "${res.message.replace(/[\\"]/g, "\\$&")}"`, log: false });
						}
					} finally {
						setIsWaSaving(false);
					}
				} else if ((ext === '.ts' || ext === '.tsx') && !key.toLocaleLowerCase().endsWith(".d.ts")) {
					built = true;
					const res = await Service.read({ path: key });
					if (res.success && res.content !== undefined) {
						if (/^[\s\n\r]*<\?xml/.test(res.content)) {
							return;
						}
						const { transpileTypescript, addDiagnosticToLog } = await import('./TranspileTS');
						const { luaCode, diagnostics } = await transpileTypescript(key, res.content);
						if (diagnostics.length > 0) {
							await addDiagnosticToLog(key, diagnostics);
							if (!preferLog) {
								addAlert(t("alert.failedCompile", { title }), "warning");
							}
							return;
						}
						if (luaCode !== undefined) {
							if (fileInTab !== undefined) {
								fileInTab.content = luaCode;
								const model = monaco.editor.getModel(monaco.Uri.file(luaFile));
								if (model) {
									model.setValue(luaCode);
								}
							}
							const res = await Service.write({ path: luaFile, content: luaCode });
							if (res.success) {
								if (preferLog) {
									Service.command({ code: `Log "Info", "Built ${title.replace(/[\\"]/g, "\\$&")}"`, log: false });
								} else {
									addAlert(t("alert.build", { title }), "success");
								}
							} else {
								if (preferLog) {
									Service.command({ code: `Log "Error", "Failed to save ${title.replace(/[\\"]/g, "\\$&")}"`, log: false });
								} else {
									addAlert(t("alert.saveCurrent"), "error");
								}
							}
						}
					}
				} else if (ext === '.yue' || ext === '.tl' || ext === '.xml') {
					const res = await Service.build({ path: key });
					built = true;
					if (res.success) {
						if (preferLog) {
							Service.command({ code: `Log "Info", "Built ${title.replace(/[\\"]/g, "\\$&")}"`, log: false });
						} else {
							addAlert(t("alert.build", { title }), "success");
						}
						if (fileInTab !== undefined) {
							const resultCodes = res.resultCodes === undefined ? "" : res.resultCodes;
							fileInTab.content = resultCodes;
							setTimeout(() => {
								const model = monaco.editor.getModel(monaco.Uri.file(luaFile));
								if (model) {
									model.setValue(resultCodes);
								}
							}, 10);
						}
					} else {
						if (preferLog) {
							Service.command({ code: `Log "Error", "Failed to build ${title.replace(/[\\"]/g, "\\$&")}"`, log: false });
						} else {
							addAlert(t("alert.failedCompile", { title }), "warning");
						}
					}
				}
			} catch (e) {
				built = true;
				console.error(e);
				if (preferLog) {
					const errorMessage = e instanceof Error ? e.message : String(e);
					const message = `Failed to build ${title}: ${errorMessage}`.replace(/[\\"]/g, "\\$&").replace(/\r?\n/g, "\\n");
					Service.command({ code: `Log "Error", "${message}"`, log: false });
				} else {
					addAlert(t("alert.failedCompile", { title }), "warning");
				}
			}
		};
		if (data.dir) {
			const { title } = data;
			setOpenLog({
				title: t("menu.build") + " " + title,
				stopOnClose: false
			});
			if (isSaving) {
				addAlert(t("alert.waitForJob"), "info");
				return;
			}
			isSaving = true;
			try {
				const listRes = await Service.assetFiles(data.key);
				if (listRes.success) {
					for (const file of listRes.files) {
						await buildFile(file, true);
					}
				}
				await new Promise(resolve => setTimeout(resolve, 100));
				Service.command({ code: `Log "Info", "${t(built ? "alert.buildDone" : "alert.noBuild", { title }).replace(/[\\"]/g, "\\$&")}"`, log: false });
			} finally {
				isSaving = false;
			}
		} else {
			await buildFile(key, false);
		}
	}, [addAlert, checkFileReadonly, files, t]);

	const buildCurrentProject = useCallback(async () => {
		if (isProjectBuilding || isSaving) {
			addAlert(t("alert.waitForJob"), "info");
			return;
		}
		if (currentFile === undefined) {
			addAlert(t("alert.buildProjectNoFile"), "info");
			return;
		}
		const rootRes = await Service.projectRoot({ path: currentFile.key, isDir: currentFile.folder });
		let buildTarget: TreeDataType | null = null;
		if (rootRes.success && rootRes.found && rootRes.projectRoot) {
			const runningAgentRes = await getRunningAgentSessionForProject(rootRes.projectRoot);
			if (!runningAgentRes.success) {
				addAlert(runningAgentRes.message, "error", true);
				return;
			}
			if (runningAgentRes.session !== undefined) {
				addAlert(t("alert.buildProjectAgentRunning", { title: runningAgentRes.session.title }), "info");
				return;
			}
			buildTarget = {
				key: rootRes.projectRoot,
				title: path.basename(rootRes.projectRoot),
				dir: true,
			};
		} else {
			if (!rootRes.success) {
				addAlert(rootRes.message ?? t("alert.buildProjectNoRoot"), "error");
				return;
			}
			if (currentFile.folder || !isSingleBuildFile(currentFile.key)) {
				addAlert(rootRes.message ?? t("alert.buildProjectNoRoot"), "info");
				return;
			}
			buildTarget = {
				key: currentFile.key,
				title: currentFile.title,
				dir: false,
			};
		}
		if (buildTarget === null) return;
		setIsProjectBuilding(true);
		try {
			try {
				const stopRes = await Service.stop();
				if (stopRes.success) {
					addAlert(t("alert.stopped"), "success");
					if (openLog?.stopOnClose) {
						setOpenLog(null);
					}
				}
			} catch {
				addAlert(t("alert.stopFailed"), "error");
				return;
			}
			await buildTreeData(buildTarget);
		} finally {
			setIsProjectBuilding(false);
		}
	}, [addAlert, buildTreeData, currentFile, getRunningAgentSessionForProject, isProjectBuilding, openLog?.stopOnClose, t]);

	const onTreeMenuClick = useCallback((event: TreeMenuEvent, data?: TreeDataType) => {
		if (isSaving) {
			addAlert(t("alert.waitForJob"), "info");
			return;
		}
		if (event === "Cancel") return;
		if (data === undefined) return;
		switch (event) {
			case "New": {
				setOpenNewFile(data);
				if (
					firstProjectTourOpen
					&& firstProjectTourCurrent === 2
					&& data.key === treeDataRef.current.at(0)?.key
				) {
					setFirstProjectTourCurrent(3);
				}
				break;
			}
			case "Upload": {
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				let { key, title } = data;
				if (!data.dir) {
					key = path.dirname(key);
					title = path.basename(key);
					if (path.relative(key, rootNode.key) === "") {
						title = "Assets";
					}
				}
				const file = files.find(f => path.relative(f.key, key) === "");
				if (file !== undefined) {
					const index = files.indexOf(file);
					switchTab(index, file);
					break;
				}
				openFileInTab(key, title, true, undefined, false);
				break;
			}
			case "Dora": {
				void openAgentSessionTab(data.key, data.dir);
				break;
			}
			case "Download":
			case "Obfuscate": {
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				const { key, title } = data;
				if (!isChildFolder(key, rootNode.key)) {
					addAlert(t("alert.downloadFailed"), "error");
					break;
				}
				const downloadFile = (filename: string) => {
					const downloadPath = path.relative(writablePath, filename).replace("\\", "/");
					const x = new XMLHttpRequest();
					x.open("GET", Service.addr("/" + downloadPath), true);
					x.responseType = 'blob';
					x.onload = function () {
						const url = window.URL.createObjectURL(x.response);
						const a = document.createElement('a');
						a.href = url;
						a.download = title;
						a.click();
					}
					x.send();
				};
				if (!data.dir) {
					downloadFile(key);
				} else {
					if (waitingForDownload) {
						addAlert(t("alert.downloadWait"), "info");
						break;
					}
					waitingForDownload = true;
					addAlert(t("alert.downloadStart"), "info");
					const zipFile = path.join(writablePath, ".download", title + ".zip");
					Service.zip({ zipFile, path: key, obfuscated: event === "Obfuscate" }).then(res => {
						waitingForDownload = false;
						if (res.success) {
							downloadFile(zipFile);
						} else {
							addAlert(t("alert.downloadFailed"), "error");
						}
					}).catch(() => {
						addAlert(t("alert.downloadFailed"), "error");
						waitingForDownload = false;
					});
				}
				break;
			}
			case "Rename": {
				if (contentModified) {
					addAlert(t("alert.renameSave"), "info");
					break;
				}
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				if (rootNode.key === data.key) {
					addAlert(t("alert.renameRoot"), "info");
					break;
				}
				if (data !== undefined) {
					const extname = data.dir ? "" : path.extname(data.title);
					const name = data.dir ? data.title : path.basename(data.title, extname);
					const ext = extname.toLowerCase();
					setFileInfo({
						title: "file.rename",
						node: data,
						name,
						ext,
					});
				}
				break;
			}
			case "Delete": {
				deleteFile(data);
				break;
			}
			case "Unzip": {
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				const { key, title } = data;
				const extname = path.extname(key);
				const name = path.basename(key, extname);
				const dir = path.dirname(key);
				addAlert(t("alert.startUnzip", { title }), "info");
				Service.unzip({ zipFile: key, path: path.join(dir, name) }).then((res) => {
					if (res.success) {
						fileSearchInvalidationEpochRef.current += 1;
						invalidateFileSearchIndex();
						setFilterOptionCount(0);
						addAlert(t("alert.doneUnzip", { title }), "success");
					} else {
						addAlert(t("alert.failedUnzip", { title }), "error");
					}
					void refreshTreeDirectory(dir, true);
				})
				break;
			}
			case "Pack Atlas": {
				if (!data.dir) break;
				const title = data.title;
				const resourceBasePath = isChildFolder(data.key, assetPath) ? assetPath : writablePath;
				isSaving = true;
				import('./ActionEditor/ActionAtlasPacker').then(({ packActionClipsDirectoryPath }) => {
					return packActionClipsDirectoryPath(data.key, resourceBasePath);
				}).then(({ clip, result }) => {
					addAlert(t("alert.packedAtlas", {
						title,
						texture: path.basename(clip.texturePath ?? ""),
						clip: path.basename(clip.clipPath ?? ""),
						count: result.rects.length,
					}), "success");
				}).catch((error) => {
					addAlert(error instanceof Error ? error.message : t("alert.failedPackAtlas", { title }), "error", true);
				}).finally(() => {
					isSaving = false;
				});
				break;
			}
			case "Declaration": {
				const { key } = data;
				Service.read({ path: key }).then((res) => {
					if (res.success && res.content !== undefined) {
						import('./TranspileTS').then(async ({ getDeclarationFile }) => {
							const declaration = await getDeclarationFile(key, res.content);
							if (declaration !== null) {
								const uri = monaco.Uri.file(declaration.fileName);
								const model = monaco.editor.getModel(uri);
								if (model !== null) {
									model.setValue(declaration.content);
								}
								Service.exist({ file: declaration.fileName }).then((res) => {
									const fileExists = res.success;
									Service.write({ path: declaration.fileName, content: declaration.content }).then((res) => {
										if (res.success) {
											// do nothing
										} else {
											addAlert(t("alert.noDeclaration", { title: path.basename(key) }), "error");
										}
									});
									if (!fileExists) {
										const rootNode = treeDataRef.current.at(0);
										if (rootNode === undefined) return;
										const ensureResult = ensureFileNode(rootNode, declaration.fileName);
										if (ensureResult.node === null) return;
										const nextExpanded = expandDirPath(rootNode.key, path.dirname(declaration.fileName), expandedKeysRef.current);
										treeDataRef.current = [ensureResult.root];
										setTreeData([ensureResult.root]);
										if (nextExpanded !== expandedKeysRef.current) {
											expandedKeysRef.current = nextExpanded;
											setExpandedKeys(nextExpanded);
										}
										setSelectedKeys([declaration.fileName]);
										setSelectedNode(ensureResult.node);
										const index = files.length;
										const newItem: EditingFile = {
											key: declaration.fileName,
											title: path.basename(declaration.fileName),
											folder: false,
											content: declaration.content,
											contentModified: null,
											status: "normal",
											onMount: () => { },
										};
										newItem.onMount = onEditorDidMount(newItem);
										setFiles([...files, newItem]);
										switchTab(index, newItem);
									} else {
										openFileInTab(declaration.fileName, path.basename(declaration.fileName), false, undefined, false);
									}
								}).catch(() => {
									addAlert(t("alert.noDeclaration", { title: path.basename(key) }), "error");
								});
							} else {
								addAlert(t("alert.noDeclaration", { title: path.basename(key) }), "error");
							}
						});
					}
				});
				break;
			}
			case "Update Dora": {
				const { key, title } = data;
				const doraPath = path.join(path.dirname(key), "vendor", "dora");
				Service.updateDora({ path: key }).then((res) => {
					if (res.success) {
						const prevFiles = filesRef.current;
						const prevTabIndex = tabIndexRef.current;
						const currentTabKey = prevTabIndex !== null ? prevFiles[prevTabIndex]?.key : undefined;
						const nextFiles = prevFiles.filter(file => !isChildFolder(file.key, doraPath));
						if (nextFiles.length !== prevFiles.length) {
							filesRef.current = nextFiles;
							setFiles(nextFiles);
							if (currentTabKey !== undefined) {
								const nextIndex = nextFiles.findIndex(file => file.key === currentTabKey);
								if (nextIndex >= 0) {
									if (nextIndex !== prevTabIndex) {
										switchTabRef.current(nextIndex, nextFiles[nextIndex]);
									}
								} else if (nextFiles.length === 0) {
									switchTabRef.current(null);
								} else {
									const fallbackIndex = Math.min(prevTabIndex ?? 0, nextFiles.length - 1);
									switchTabRef.current(fallbackIndex, nextFiles[fallbackIndex]);
								}
							}
						}
						addAlert(t("alert.updateDora", { title }), "success");
					} else {
						addAlert(res.message, "error", true);
					}
				}).catch(() => {
					addAlert(t("alert.failedUpdateDora", { title }), "error");
				});
				break;
			}
			case "Build": {
				void buildTreeData(data);
				break;
			}
			case "View Compiled": {
				const { key, title } = data;
				const extname = path.extname(key);
				const name = path.basename(key, extname);
				const dir = path.dirname(key);
				const luaFile = path.join(dir, name + ".lua");
				Service.read({ path: luaFile }).then((res) => {
					if (res.success && res.content !== undefined) {
						openFileInTab(luaFile, name + ".lua", false, undefined, true);
					} else {
						addAlert(t("alert.notGenerated", { title }), "warning");
					}
				}).catch(() => {
					addAlert(t("alert.read", { title: name + ".lua" }), "error");
				});
				break;
			}
			case "Copy Path": {
				let relativePath: string;
				if (isChildFolder(data.key, writablePath)) {
					relativePath = path.relative(writablePath, data.key);
				} else {
					relativePath = path.relative(assetPath, data.key);
				}
				if (navigator.clipboard && navigator.clipboard.writeText) {
					navigator.clipboard.writeText(relativePath).then(() => {
						addAlert(t("alert.copied", { title: data.title }), "success");
					}).catch(() => {
						addAlert(t("alert.copy"), "error");
					});
				} else {
					setPopupInfo({
						title: t("alert.tocopy", { title: data.title }),
						msg: relativePath,
						selectable: true,
						raw: true
					});
				}
				break;
			}
		}
	}, [addAlert, buildTreeData, refreshTreeDirectory, t, files, deleteFile, treeData, openFileInTab, onEditorDidMount, switchTab, openAgentSessionTab, firstProjectTourOpen, firstProjectTourCurrent]);

	const onNewFileClose = (item?: DoraFileType) => {
		let ext: string | null = null;
		switch (item) {
			case "Lua": ext = ".lua"; break;
			case "Teal": ext = ".tl"; break;
			case "YueScript": ext = ".yue"; break;
			case "Dora XML": ext = ".xml"; break;
			case "Dora Animation": ext = ".model"; break;
			case "Dora Body": ext = ".b.lua"; break;
			case "Dora Particle": ext = ".par"; break;
			case "Markdown": ext = ".md"; break;
			case "Yarn": ext = ".yarn"; break;
			case "Visual Script": ext = ".vs"; break;
			case "Blockly": ext = ".bl"; break;
			case "Wa": ext = ".wa"; break;
			case "TIC80": ext = ".tic"; break;
			case "Folder": ext = ""; break;
			case "TypeScript": ext = ".tsx"; break;
		}
		if (ext !== null) {
			setFileInfo({
				title: ext === "" ? "file.newFolder" : "file.new",
				node: openNewFile !== null ? openNewFile : undefined,
				name: "",
				ext,
				projectType: ext === "" ? "TypeScript" : undefined,
			});
			if (
				item === "Folder"
				&& firstProjectTourOpen
				&& firstProjectTourCurrent === 3
			) {
				setFirstProjectTourCurrent(4);
			}
		} else if (firstProjectTourOpen && firstProjectTourCurrent === 3) {
			setFirstProjectTourCurrent(1);
		}
		setOpenNewFile(null);
	};

	const startFirstProjectTour = useCallback(() => {
		setFirstProjectTourCreating(false);
		setFirstProjectTourCurrent(0);
		setFirstProjectTourFile(null);
		setFirstProjectTourOpen(true);
	}, []);

	const interruptFirstProjectTour = useCallback(() => {
		setFirstProjectTourOpen(false);
		setFirstProjectTourCreating(false);
		setFirstProjectTourFile(null);
		setOpenNewFile(null);
		setFileInfo(null);
	}, []);

	const locateFirstProjectAgent = useCallback(() => {
		if (firstProjectTourFile === null) return;
		const projectPath = path.dirname(firstProjectTourFile);
		setDrawerOpen(true);
		setLeftDockTab("explorer");
		window.requestAnimationFrame(() => {
			void revealTreeNode(projectPath).finally(() => {
				window.requestAnimationFrame(() => setFirstProjectTourCurrent(11));
			});
		});
	}, [firstProjectTourFile, revealTreeNode]);

	const exploreFirstProjectAgent = useCallback(() => {
		void persistFirstProjectTourCompletion().then((completed) => {
			if (!completed) return;
			if (openLog === null) {
				locateFirstProjectAgent();
				return;
			}
			setFirstProjectTourCurrent(10);
		});
	}, [locateFirstProjectAgent, openLog, persistFirstProjectTourCompletion]);

	const beginFirstProjectTour = useCallback(() => {
		const target = treeDataRef.current.at(0);
		if (target === undefined) {
			addAlert(t("alert.open"), "error");
			return;
		}
		setDrawerOpen(true);
		setLeftDockTab("explorer");
		void revealTreeNode(target.key);
		setFirstProjectTourCurrent(1);
	}, [addAlert, revealTreeNode, t]);

	const handleFilenameClose = (callbacks?: {
		onCreated?: (openedFile: string) => void;
		onFailed?: () => void;
	}) => {
		if (fileInfo && fileInfo.node !== undefined) {
			const trimmedName = fileInfo.name.trim();
			if (trimmedName === "") {
				setFileInfo(null);
				callbacks?.onFailed?.();
				return;
			}
			const target = fileInfo.node;
			if (fileInfo.title === "file.rename") {
				const newName = trimmedName + fileInfo.ext;
				if (newName === target.title) {
					setFileInfo(null);
					return;
				}
				const oldFile = target.key;
				const newFile = path.join(path.dirname(target.key), newName);
				const doRename = () => {
					return Service.rename({ old: oldFile, new: newFile }).then((res) => {
						if (!res.success) {
							addAlert(t("alert.renameFailed"), "error");
							return;
						}
						moveCachedFileSearch(oldFile, newFile);
						const uri = monaco.Uri.file(oldFile);
						const model = monaco.editor.getModel(uri);
						if (model !== null) {
							model.dispose();
						}
						if (target.dir) {
							addAlert(t("alert.renamed", { oldFile: path.basename(oldFile), newFile: path.basename(newFile) }), "success");
							return;
						}
						const file = files.find(f => path.relative(f.key, oldFile) === "");
						if (file !== undefined) {
							file.key = newFile;
							file.title = newName;
							setFiles([...files]);
						}
						const rootNode = treeDataRef.current.at(0);
						if (rootNode === undefined) return;
						const renamed = updateTreeNode(rootNode, target.key, (node) => ({
							...node,
							key: newFile,
							title: newName,
						}));
						treeDataRef.current = [renamed.root];
						setTreeData([renamed.root]);
						if (renamed.node !== null) {
							setSelectedNode(renamed.node);
							setSelectedKeys([newFile]);
						} else {
							setSelectedNode(null);
							setSelectedKeys([]);
						}
						addAlert(t("alert.renamed", { oldFile: path.basename(oldFile), newFile: path.basename(newFile) }), "success");
					}).catch(() => {
						addAlert(t("alert.renameFailed"), "error");
					});
				};
				if (target.dir) {
					updateDir(oldFile, newFile).then((res) => {
						doRename().then(async () => {
							if (res === undefined) return;
							expandedKeysRef.current = res.newExpanded;
							setFiles(res.newFiles);
							setExpandedKeys(res.newExpanded);
							setSelectedNode(null);
							setSelectedKeys([]);
							await refreshTreeDirectory(path.dirname(oldFile));
						});
					});
				} else {
					doRename();
					setSelectedNode(null);
					setSelectedKeys([]);
				}
			} else {
				const dir = target.dir ?
					target.key : path.dirname(target.key);
				const { ext } = fileInfo;
				const projectPath = path.join(dir, trimmedName);
				if (ext === ".wa" && fileInfo.project) {
					Service.createWa({ path: projectPath }).then((res) => {
						if (!res.success) {
							addAlert(t("alert.newFailed"), "error");
							Service.command({ code: `Log "Error", "Failed to create Wa project, due to ${res.message}"`, log: false });
						} else {
							loadAssets().then(() => {
								const target = path.join(projectPath, "src", "main.wa");
								openFileInTab(target, "main.wa", false, undefined, false);
								setIsWaSaving(true);
								Service.buildWa({ path: target }).then((res) => {
									if (!res.success) {
										addAlert(res.message, "error", true);
										Service.command({ code: `Log "Error", "${res.message.replace(/[\\"]/g, "\\$&")}"`, log: false });
									}
								}).finally(() => {
									setIsWaSaving(false);
								});
							});
						}
					});
					setFileInfo(null);
					return;
				}
				const newName = trimmedName + ext;
				const newFile = path.join(dir, newName);
				const folder = fileInfo.title === "file.newFolder";
				const template = getNewFileTemplate(ext);
				let { content } = template;
				const { position } = template;
				if (ext === ".model") {
					content = writeLegacyModel(createEmptyActionDocument(newFile, `${trimmedName}.clip`));
				}
				const initExt = folder && fileInfo.project ? getFolderProjectExtension(fileInfo.projectType ?? "TypeScript") : null;
				const initFile = initExt ? path.join(newFile, `init${initExt}`) : null;
				const initTemplate = initExt ? getNewFileTemplate(initExt) : null;
				(async () => {
					const res = await Service.newFile({ path: newFile, content, folder });
					if (!res.success) {
						addAlert(t(`alert.new${res.message}`), "error");
						callbacks?.onFailed?.();
						return;
					}
					if (initFile !== null && initTemplate !== null) {
						const initRes = await Service.newFile({
							path: initFile,
							content: initTemplate.content,
							folder: false
						});
						if (!initRes.success) {
							addAlert(t(`alert.new${initRes.message}`), "error");
							callbacks?.onFailed?.();
							return;
						}
					}
					if (initFile !== null) {
						updateCachedFileSearch(initFile, true);
					} else if (!folder) {
						updateCachedFileSearch(newFile, true);
					}
					await refreshTreeDirectory(dir, true);
					const openedFile = initFile ?? newFile;
					const openedName = path.basename(openedFile);
					const openedFolder = folder && initFile === null;
					const newItem: EditingFile = {
						key: openedFile,
						title: openedName,
						folder: openedFolder,
						position: initTemplate?.position ?? position,
						content: initTemplate?.content ?? content,
						contentModified: null,
						status: "normal",
						onMount: () => { },
					};
					if (path.extname(openedName) === ".md") {
						newItem.mdEditing = true;
					}
					newItem.onMount = onEditorDidMount(newItem);
					setFiles([...files, newItem]);
					switchTab(files.length, newItem);
					callbacks?.onCreated?.(openedFile);
				})().then(() => {
					if (ext === ".tic") {
						fetch('/tic80/cart.tic')
							.then(res => {
								if (!res.ok) throw new Error('Failed to download cart.tic');
								return res.blob();
							})
							.then(blob => {
								const formData = new FormData();
								formData.append('file', blob, newFile);
								const uploadPath = Service.addr(`/upload?path=${encodeURIComponent(newFile)}`);
								return fetch(uploadPath, {
									method: 'POST',
									body: formData
								});
							})
							.then(res => {
								if (!res.ok) {
									addAlert(t("alert.newFailed"), "error");
								}
							})
							.catch(() => {
								addAlert(t("alert.newFailed"), "error");
							});
					}
				}).catch(() => {
					addAlert(t("alert.newFailed"), "error");
					callbacks?.onFailed?.();
				});
			}
		}
		setFileInfo(null);
	};

	const onFilenameChange = (event: ChangeEvent<HTMLTextAreaElement | HTMLInputElement>) => {
		if (fileInfo) {
			setFileInfo({ ...fileInfo, name: event.target.value });
		}
	};

	const handleFilenameCancel = () => {
		setFileInfo(null);
		if (
			firstProjectTourOpen
			&& firstProjectTourCurrent >= 4
			&& firstProjectTourCurrent <= 6
		) {
			setFirstProjectTourCreating(false);
			setFirstProjectTourCurrent(1);
		}
	};

	const createFirstProject = () => {
		const pendingFileInfo = fileInfo;
		setFirstProjectTourCreating(true);
		handleFilenameClose({
			onCreated: (openedFile) => {
				setFirstProjectTourCreating(false);
				setFirstProjectTourFile(openedFile);
				setFirstProjectTourCurrent(7);
			},
			onFailed: () => {
				setFirstProjectTourCreating(false);
				setFirstProjectTourCurrent(6);
				if (pendingFileInfo !== null) setFileInfo(pendingFileInfo);
			},
		});
	};

	const updateDir = useCallback((oldDir: string, newDir: string) => {
		const replacePrefix = (key: string) => {
			if (!isChildFolder(key, oldDir)) return key;
			const relative = path.relative(oldDir, key);
			return relative === "" ? newDir : path.join(newDir, relative);
		};
		const newFiles = files.map(file => {
			const nextKey = replacePrefix(file.key);
			if (nextKey === file.key) return file;
			const nextFile = {
				...file,
				key: nextKey,
				title: file.folder ? path.basename(nextKey) : file.title,
			};
			if (nextFile.contentModified !== null) {
				nextFile.content = nextFile.contentModified;
			}
			return nextFile;
		});
		const newExpanded = expandedKeys.map(replacePrefix);
		return Promise.resolve({ newFiles, newExpanded });
	}, [expandedKeys, files]);

	const onDrop = useCallback((self: TreeDataType, target: TreeDataType) => {
		if (contentModified) {
			addAlert(t("alert.movingNoSave"), "info");
			return;
		}
		if (checkFileReadonly(self.key, true)) return;
		if (checkFileReadonly(target.key, true)) return;
		const rootNode = treeData.at(0);
		if (rootNode === undefined) return;
		let targetName = target.title;
		let targetParent = target.key;
		if (!target.dir) {
			targetParent = path.dirname(target.key);
			if (path.relative(targetParent, rootNode.key) === "") {
				targetName = rootNode.title;
			} else {
				targetName = path.basename(targetParent);
			}
		}
		if (path.relative(targetParent, path.dirname(self.key)) === "") {
			return;
		}
		setPopupInfo({
			title: t("popup.moving"),
			msg: t("popup.movingInfo", { from: self.title, to: targetName }),
			cancelable: true,
			confirmed: () => {
				const newFile = path.join(targetParent, path.basename(self.key));
				const doRename = () => {
					return Service.rename({ old: self.key, new: newFile }).then((res) => {
						if (res.success) {
							moveCachedFileSearch(self.key, newFile);
							addAlert(t("alert.moved", { from: self.title, to: targetName }), "success");
							return true;
						}
						addAlert(t("alert.movingFailed", { from: self.title, to: targetName }), "error");
						return false;
					}).catch(() => {
						addAlert(t("alert.movingFailed", { from: self.title, to: targetName }), "error");
						return false;
					});
				};
				if (self.dir) {
					updateDir(self.key, newFile).then((res) => {
						if (res === undefined) return;
						doRename().then(async (success) => {
							if (!success) return;
							filesRef.current = res.newFiles;
							expandedKeysRef.current = res.newExpanded;
							setFiles(res.newFiles);
							setExpandedKeys(res.newExpanded);
							await refreshTreeDirectory(path.dirname(self.key), true);
							await refreshTreeDirectory(targetParent, true);
							if (tabIndex !== null && tabIndex < res.newFiles.length && res.newFiles[tabIndex].key === newFile) {
								switchTab(tabIndex, res.newFiles[tabIndex]);
							}
						});
					});
				} else {
					doRename().then(async (success) => {
						if (!success) return;
						const nextFiles = files.map(file => file.key === self.key ? {
							...file,
							key: newFile,
							title: path.basename(newFile),
						} : file);
						filesRef.current = nextFiles;
						setFiles(nextFiles);
						await refreshTreeDirectory(path.dirname(self.key), true);
						await refreshTreeDirectory(targetParent, true);
						const nextExpanded = expandedKeys.filter(k => k !== self.key);
						expandedKeysRef.current = nextExpanded;
						setExpandedKeys(nextExpanded);
						if (tabIndex !== null && tabIndex < nextFiles.length && nextFiles[tabIndex].key === newFile) {
							switchTab(tabIndex, nextFiles[tabIndex]);
						}
					});
				}
			}
		});
	}, [addAlert, checkFileReadonly, expandedKeys, files, moveCachedFileSearch, refreshTreeDirectory, updateDir, t, treeData, switchTab, tabIndex]);

	const runBatchOperation = useCallback(async (
		operation: Service.AssetBatchOperation,
		target?: string
	) => {
		if (batchOperationRunning) return;
		const sources = normalizeBatchPaths(checkedKeys).filter(key =>
			key !== writablePath && isChildFolder(key, writablePath)
		);
		if (sources.length === 0) return;
		setBatchOperationRunning(true);
		try {
			const res = await Service.assetBatch(operation, sources, target);
			fileSearchInvalidationEpochRef.current += 1;
			invalidateFileSearchIndex();
			setFilterOptionCount(0);
			const changes = res.changes ?? [];
			if (operation === "delete" && changes.length > 0) {
				const removedPaths = changes.map(change => change.old);
				for (const model of monaco.editor.getModels()) {
					if (removedPaths.some(removed => isChildFolder(model.uri.fsPath, removed))) {
						model.dispose();
					}
				}
				const prevFiles = filesRef.current;
				const prevTabIndex = tabIndexRef.current;
				const activeKey = prevTabIndex !== null ? prevFiles[prevTabIndex]?.key : undefined;
				const nextFiles = prevFiles.filter(file =>
					!removedPaths.some(removed => isChildFolder(file.key, removed))
				);
				filesRef.current = nextFiles;
				setFiles(nextFiles);
				if (activeKey !== undefined) {
					const nextActiveIndex = nextFiles.findIndex(file => file.key === activeKey);
					if (nextActiveIndex >= 0) {
						if (nextActiveIndex !== prevTabIndex) setTabIndex(nextActiveIndex);
					} else if (nextFiles.length === 0) {
						void switchTab(null);
					} else {
						const fallbackIndex = Math.min(prevTabIndex ?? 0, nextFiles.length - 1);
						void switchTab(fallbackIndex, nextFiles[fallbackIndex]);
					}
				}
				let nextExpanded = expandedKeysRef.current;
				for (const removed of removedPaths) {
					nextExpanded = removeExpandedPath(nextExpanded, removed);
				}
				expandedKeysRef.current = nextExpanded;
				setExpandedKeys(nextExpanded);
				const nextSelected = selectedKeysRef.current.filter(key =>
					!removedPaths.some(removed => isChildFolder(key, removed))
				);
				selectedKeysRef.current = nextSelected;
				setSelectedKeys(nextSelected);
			} else if (operation === "move" && changes.length > 0) {
				const nextFiles = filesRef.current.map(file => {
					const nextKey = replaceBatchPath(file.key, changes);
					return nextKey === file.key ? file : {
						...file,
						key: nextKey,
						title: file.folder ? path.basename(nextKey) : file.title,
					};
				});
				filesRef.current = nextFiles;
				setFiles(nextFiles);
				const nextExpanded = expandedKeysRef.current.map(key => replaceBatchPath(key, changes));
				expandedKeysRef.current = nextExpanded;
				setExpandedKeys(nextExpanded);
				const nextSelected = selectedKeysRef.current.map(key => replaceBatchPath(key, changes));
				selectedKeysRef.current = nextSelected;
				setSelectedKeys(nextSelected);
			}

			const affectedDirectories = [...new Set(
				res.affectedDirectories ?? [
					...sources.map(source => path.dirname(source)),
					...(target === undefined ? [] : [target]),
				]
			)];
			for (const dir of affectedDirectories) {
				await refreshTreeDirectory(dir, true);
			}
			const root = treeDataRef.current.at(0);
			const selectedKey = selectedKeysRef.current.at(0);
			setSelectedNode(root !== undefined && selectedKey !== undefined
				? findTreeNode(root, selectedKey)
				: null
			);
			setCheckedKeys([]);
			setBatchTargetMode(null);
			if (res.success) {
				addAlert(t(`alert.batch${operation === "delete" ? "Deleted" : operation === "copy" ? "Copied" : "Moved"}`, {
					count: changes.length,
				}), "success");
			} else {
				addAlert(res.message ?? t("alert.batchFailed"), "error");
			}
		} catch {
			addAlert(t("alert.batchFailed"), "error");
		} finally {
			setBatchOperationRunning(false);
		}
	}, [addAlert, batchOperationRunning, checkedKeys, refreshTreeDirectory, switchTab, t]);

	const onToggleMultiSelect = useCallback(() => {
		setMultiSelectMode(value => !value);
		setCheckedKeys([]);
		setBatchTargetMode(null);
	}, []);

	const onCheckTreeNodes = useCallback((keys: string[]) => {
		setCheckedKeys(keys.filter(key => key !== writablePath && isChildFolder(key, writablePath)));
	}, []);

	const onBatchAction = useCallback((action: "delete" | "copy" | "move") => {
		if (batchOperationRunning) return;
		const sources = normalizeBatchPaths(checkedKeys);
		if (sources.length === 0) return;
		if (contentModified) {
			addAlert(t("alert.batchSave"), "info");
			return;
		}
		if (action === "delete") {
			setPopupInfo({
				title: t("tree.deleteSelected", { count: sources.length }),
				msg: t("tree.confirmDeleteSelected", { count: sources.length }),
				cancelable: true,
				confirmed: () => {
					void runBatchOperation("delete");
				},
			});
			return;
		}
		setBatchTargetMode(action);
	}, [addAlert, batchOperationRunning, checkedKeys, runBatchOperation, t]);

	const onBatchTarget = useCallback((target: TreeDataType) => {
		if (batchTargetMode === null || batchOperationRunning) return;
		if (!target.dir || !isChildFolder(target.key, writablePath)) {
			addAlert(t("alert.batchInvalidTarget"), "info");
			return;
		}
		const sources = normalizeBatchPaths(checkedKeys);
		if (sources.some(source => isChildFolder(target.key, source))) {
			addAlert(t("alert.batchInvalidTarget"), "info");
			return;
		}
		const operation = batchTargetMode;
		setPopupInfo({
			title: t(operation === "copy" ? "tree.copySelected" : "tree.moveSelected", {
				count: sources.length,
			}),
			msg: t(operation === "copy" ? "tree.confirmCopySelected" : "tree.confirmMoveSelected", {
				count: sources.length,
				target: target.title,
			}),
			cancelable: true,
			confirmed: () => {
				void runBatchOperation(operation, target.key);
			},
		});
	}, [addAlert, batchOperationRunning, batchTargetMode, checkedKeys, runBatchOperation, t]);

	const onCancelBatchTarget = useCallback(() => {
		setBatchTargetMode(null);
	}, []);

	const onUploaded = useCallback((dir: string, file: string, open: boolean) => {
		const key = path.join(dir, file);
		updateCachedFileSearch(key, true);
		const newFiles = files.filter(f => path.relative(f.key, key) !== "");
		if (file.length !== newFiles.length) {
			setFiles(newFiles);
			if (tabIndex && tabIndex > newFiles.length) {
				const newIndex = newFiles.length > 0 ? newFiles.length - 1 : null;
				if (newIndex === null) {
					switchTab(newIndex);
				} else {
					switchTab(newIndex, newFiles[newIndex]);
				}
			}
		}
		if (open) {
			refreshTreeDirectory(dir, true).then(() => {
				if (open) {
					openFileInTab(key, file, false);
				}
			});
		} else {
			lastUploadedTime = Date.now();
			setTimeout(() => {
				if (Date.now() - lastUploadedTime >= 2000) {
					void refreshTreeDirectory(dir, true);
				}
			}, 2000);
		}
	}, [tabIndex, refreshTreeDirectory, switchTab, files, openFileInTab, updateCachedFileSearch]);

	const onWorkspaceViewChange = useCallback((fileKey: string, view: "agent" | "upload" | "git") => {
		setFiles(prev => prev.map(file => file.key === fileKey ? { ...file, workspaceView: view } : file));
	}, []);

	const onAgentInitialPromptConsumed = useCallback((fileKey: string) => {
		setFiles(prev => prev.map(file => file.key === fileKey ? { ...file, agentInitialPrompt: undefined } : file));
	}, []);

	const checkFile = (file: EditingFile, content: string, model: Monaco.editor.ITextModel, lastChange?: Monaco.editor.IModelContentChange) => {
		const ext = path.extname(file.key).toLowerCase();
		if (ext === ".yarn") {
			// Yarn file validation
			Service.checkYarnFile({ code: content }).then((res) => {
				let status: TabStatus = "normal";
				const markers: Monaco.editor.IMarkerData[] = [];
				if (!res.success) {
					status = "error";
					const message = res.message;
					let startLineNumber = res.line;
					let startColumn = res.column;
					let endLineNumber = res.line;
					let endColumn = res.column + 1;
					if (startLineNumber === 0) {
						startLineNumber = 1;
						endLineNumber = 1;
					}
					if (startColumn <= 1) {
						startColumn = model.getLineFirstNonWhitespaceColumn(startLineNumber);
						endColumn = model.getLineLastNonWhitespaceColumn(startLineNumber);
					}
					markers.push({
						severity: monaco.MarkerSeverity.Error,
						message: message,
						startLineNumber,
						startColumn,
						endLineNumber,
						endColumn,
					});
				}
				if (file.status !== status) {
					file.status = status;
					setFiles(prev => [...prev]);
				}
				monaco.editor.setModelMarkers(model, model.getLanguageId(), markers);
			}).catch((reason) => {
				console.error(`failed to check yarn file, due to: ${reason}`);
			});
			return;
		}
		switch (ext) {
			case ".lua": case ".tl": case ".yue": case ".xml": break;
			default: return;
		}
		Service.check({ file: file.key, content }).then((res) => {
			let status: TabStatus = "normal";
			const markers: Monaco.editor.IMarkerData[] = [];
			if (!res.success && res.info !== undefined) {
				for (let i = 0; i < res.info.length; i++) {
					const [errType, filename, row, col, msg] = res.info[i];
					if (!path.isAbsolute(filename) || path.relative(filename, file.key) !== "") {
						status = "error";
						let severity = monaco.MarkerSeverity.Info;
						switch (errType) {
							case "parsing":
							case "syntax":
							case "type":
								status = "error";
								severity = monaco.MarkerSeverity.Error;
								break;
							case "warning":
								if (status !== "error") {
									status = "warning";
									severity = monaco.MarkerSeverity.Warning;
								}
								break;
							case "crash":
								status = "error";
								severity = monaco.MarkerSeverity.Error;
								break;
						}
						markers.push({
							severity,
							message: filename + ': ' + msg,
							startLineNumber: 1,
							startColumn: 1,
							endLineNumber: 1,
							endColumn: 1,
						});
						continue;
					}
					let startLineNumber = row;
					let startColumn = col;
					let endLineNumber = row;
					let endColumn = col;
					if (row === 0) {
						startLineNumber = 1;
						endLineNumber = 1;
					}
					if (col === 0) {
						startColumn = model.getLineFirstNonWhitespaceColumn(row);
						endColumn = model.getLineLastNonWhitespaceColumn(row);
					}
					switch (errType) {
						case "parsing":
						case "syntax":
						case "type":
							status = "error";
							markers.push({
								severity: monaco.MarkerSeverity.Error,
								message: msg,
								startLineNumber,
								startColumn,
								endLineNumber,
								endColumn,
							});
							break;
						case "warning":
							if (status !== "error") {
								status = "warning";
							}
							markers.push({
								severity: monaco.MarkerSeverity.Warning,
								message: msg,
								startLineNumber,
								startColumn,
								endLineNumber,
								endColumn,
							});
							break;
						case "crash":
							status = "error";
							if (lastChange !== undefined) {
								markers.push({
									severity: monaco.MarkerSeverity.Error,
									message: "compiler crashes",
									startLineNumber: lastChange.range.startLineNumber,
									startColumn: lastChange.range.startColumn,
									endLineNumber: lastChange.range.endLineNumber,
									endColumn: lastChange.range.endColumn,
								});
							} else {
								markers.push({
									severity: monaco.MarkerSeverity.Error,
									message: "compiler crashes",
									startLineNumber: 1,
									startColumn: 1,
									endLineNumber: 1,
									endColumn: 1,
								});
							}
							break;
						default:
							break;
					}
				}
			}
			if (file.status !== status) {
				file.status = status;
				setFiles(prev => [...prev]);
			}
			monaco.editor.setModelMarkers(model, model.getLanguageId(), markers);
		}).catch((reason) => {
			console.error(`failed to check file, due to: ${reason}`);
		});
	};

	const onStopRunning = useCallback(() => {
		setOpenBottomLog(false);
		if (tabIndex !== null) {
			const file = files.at(tabIndex);
			if (file !== undefined) {
				const title = file.title;
				if (path.extname(title).toLowerCase() === ".md") {
					file.mdEditing = true;
					if (file.editor !== undefined) {
						const editor = file.editor;
						setTimeout(() => {
							editor.focus();
						}, 100);
					}
					setFiles([...files]);
					return;
				}
			}
		}
		Service.stop().then((res) => {
			if (res.success) {
				addAlert(t("alert.stopped"), "success");
				if (openLog !== null) {
					setOpenLog(null);
				}
			} else {
				addAlert(t("alert.stopNone"), "info");
			}
		}).catch(() => {
			addAlert(t("alert.stopFailed"), "error");
		});
	}, [addAlert, openLog, t, tabIndex, files]);

	const onPlayControlClick = useCallback((mode: PlayControlMode, noLog?: boolean) => {
		if (mode === "First Project Tour") {
			startFirstProjectTour();
			return;
		}
		if (mode === "LLM Config") {
			setOpenLLMConfig(true);
			return;
		}
		if (mode === "Go to File") {
			setOpenFilter(true);
			return;
		} else if (mode === "View Log") {
			if (openLog === null) {
				setOpenLog({
					title: t("menu.viewLog"),
					stopOnClose: false
				});
			}
			return;
		}
		if (isProjectBuilding && (mode === "Run" || mode === "Run This")) {
			addAlert(t("alert.waitForJob"), "info");
			return;
		}
		if (isSaving) {
			let isMD = false;
			if (tabIndex !== null) {
				const file = files.at(tabIndex);
				if (file !== undefined) {
					isMD = path.extname(file.title).toLowerCase() === ".md";
				}
			}
			if (!isMD) {
				addAlert(t("alert.waitForJob"), "info");
			}
			return;
		}
		saveAllTabs().then((success) => {
			if (!success) {
				return;
			}
			switch (mode) {
				case "Run": case "Run This": {
					onPlayControlRun(mode, noLog);
					if (
						mode === "Run"
						&& firstProjectTourOpen
						&& firstProjectTourCurrent === 8
						&& firstProjectTourFile !== null
						&& currentFileKey === firstProjectTourFile
					) {
						setFirstProjectTourCurrent(9);
					}
					return;
				}
				case "Stop": {
					onStopRunning();
					return;
				}
			}
		});
	}, [addAlert, openLog, t, onStopRunning, saveAllTabs, onPlayControlRun, files, tabIndex, isProjectBuilding, startFirstProjectTour, firstProjectTourOpen, firstProjectTourCurrent, firstProjectTourFile, currentFileKey]);

	const saveCurrentTab = useCallback(async () => {
		if (tabIndex === null) return;
		if (isEditorActioning) {
			setWaitForSave(true);
			return;
		}
		if (isSaving) {
			return;
		}
		isSaving = true;
		const file = files[tabIndex];
		try {
			const filesChanged = await saveFileInTab(file, true);
			setFiles(prev => prev.map(f => {
				const changed = filesChanged.find(c => c.key === f.key);
				return changed !== undefined ? changed : f;
			}));
		} catch (reason) {
			console.error(`failed to save current tab, due to: ${reason}`);
		} finally {
			isSaving = false;
		}
	}, [saveFileInTab, isEditorActioning, tabIndex, files]);

	useEffect(() => {
		if (waitForSave && !isEditorActioning) {
			saveCurrentTab();
			setWaitForSave(false);
		}
	}, [waitForSave, isEditorActioning, saveCurrentTab]);

	const onTabMenuClick = useCallback((event: TabMenuEvent) => {
		switch (event) {
			case "Save": saveCurrentTab(); break;
			case "SaveAll": saveAllTabs(); break;
			case "Close": closeCurrentTab(); break;
			case "CloseAll": closeAllTabs(); break;
			case "CloseOthers": closeOtherTabs(); break;
		}
	}, [saveCurrentTab, saveAllTabs, closeCurrentTab, closeAllTabs, closeOtherTabs]);

	const onTabClose = useCallback((key: string) => {
		let targetIndex = files.findIndex(f => f.key === key);
		if (targetIndex !== -1 && tabIndex !== null) {
			const isCurrent = tabIndex === targetIndex;
			const closeTab = () => {
				const newFiles = files.filter((_, index) => index !== targetIndex);
				setFiles(newFiles);
				if (isCurrent) {
					if (newFiles.length === 0) {
						switchTab(null);
					} else {
						if (targetIndex >= newFiles.length) {
							targetIndex = newFiles.length - 1;
						}
						switchTab(targetIndex, newFiles[targetIndex]);
					}
				} else {
					if (targetIndex < tabIndex) {
						setTabIndex(tabIndex - 1);
					}
				}
			};
			if (files[targetIndex].contentModified !== null) {
				setPopupInfo({
					title: t("popup.closingTab"),
					msg: t("popup.closingNoSave"),
					cancelable: true,
					confirmed: closeTab,
				});
				return;
			}
			setTimeout(closeTab, 10);
		}
	}, [switchTab, t, files, tabIndex]);

	const onKeyDown = (event: KeyboardEvent) => {
		if (disconnected) {
			return;
		}
		if (event.key === "Escape") {
			if (multiSelectMode) {
				onToggleMultiSelect();
			}
			return;
		}
		if (event.ctrlKey || event.altKey || event.metaKey) {
			switch (event.key) {
				case 'N': case 'n': {
					if (!event.shiftKey) break;
					if (selectedNode === null) {
						addAlert(t("alert.newNoTarget"), "info");
						break;
					} else if (checkFileReadonly(selectedNode.key, true)) {
						break;
					}
					setOpenNewFile(selectedNode);
					break;
				}
				case 'D': case 'd': {
					if (!event.shiftKey) break;
					if (multiSelectMode && checkedKeys.length > 0) {
						onBatchAction("delete");
						break;
					}
					if (selectedNode === null) {
						addAlert(t("alert.deleteNoTarget"), "info");
						break;
					} else if (checkFileReadonly(selectedNode.key, true)) {
						break;
					}
					deleteFile(selectedNode);
					break;
				}
				case 'S': case 's': {
					if (event.shiftKey) {
						saveAllTabs();
					} else {
						saveCurrentTab();
					}
					break;
				}
				case 'W': case 'w': {
					if (event.shiftKey) {
						closeAllTabs();
					} else {
						closeCurrentTab();
					}
					break;
				}
				case 'R': case 'r': {
					const shift = event.shiftKey;
					onPlayControlClick(shift ? "Run This" : "Run");
					break;
				}
				case 'B': case 'b': {
					if (event.shiftKey) break;
					event.preventDefault();
					void buildCurrentProject();
					break;
				}
				case 'P': case 'p': {
					setOpenFilter(true);
					break;
				}
				case 'Q': case 'q': {
					onStopRunning();
					break;
				}
				case '.': {
					if (openLog !== null) {
						setOpenLog(null);
					} else {
						onPlayControlClick("View Log");
					}
					break;
				}
				default: {
					const index = Number.parseInt(event.key);
					if (!Number.isNaN(index) && index >= 1 && index <= 9 && index <= files.length) {
						switchTab(index - 1);
					}
					break;
				}
			}
		}
	};

	if (keyEvent !== null) {
		setKeyEvent(null);
		onKeyDown(keyEvent);
	}

	const onJumpLink = useCallback((link: string, fromFile: string) => {
		const key = path.join(path.dirname(fromFile), ...link.split("[\\/]"));
		const title = path.basename(key);
		openFileInTab(key, title, false);
	}, [openFileInTab]);

	const ensureFileSearchIndex = useCallback((): Promise<number | null> => {
		const rootNode = treeDataRef.current.at(0);
		if (rootNode === undefined || writablePath === "") {
			return Promise.resolve(null);
		}
		const currentWritablePath = writablePath;
		const currentAssetPath = assetPath;
		const key = `${currentWritablePath}\0${currentAssetPath}`;
		if (hasFileSearchIndex(key)) {
			return Promise.resolve(getFileSearchIndexSize());
		}
		const epoch = fileSearchInvalidationEpochRef.current;
		let request = filterOptionsRequestRef.current;
		if (request === null || request.key !== key || request.epoch !== epoch) {
			const promise: Promise<number | null> = Service.assetFiles(currentWritablePath).then(async (res) => {
				if (!res.success) return null;
				const entries: FileSearchEntry[] = [];
				const chunkSize = 2000;
				for (let start = 0; start < res.files.length; start += chunkSize) {
					const end = Math.min(start + chunkSize, res.files.length);
					for (let i = start; i < end; i++) {
						const file = res.files[i];
						entries.push({
							rootId: 0,
							relativePath: path.relative(currentWritablePath, file),
						});
					}
					if (end < res.files.length) {
						await new Promise<void>(resolve => window.setTimeout(resolve, 0));
					}
				}
				const { engineDev } = Info;
				const toolPath = path.join(assetPath, "Script", "Tools");
				const visitBuiltin = (node: TreeDataType) => {
					if (!node.dir) {
						const isToolFile = isChildFolder(node.key, toolPath) && path.dirname(node.key) === toolPath;
						if (engineDev || isToolFile) {
							entries.push({
								rootId: 1,
								relativePath: path.relative(currentAssetPath, node.key),
							});
						}
					}
					for (const child of node.children ?? []) {
						visitBuiltin(child);
					}
				};
				const builtinRoot = rootNode.children?.find(node => node.builtin);
				if (builtinRoot !== undefined) {
					visitBuiltin(builtinRoot);
				}
				if (fileSearchInvalidationEpochRef.current !== epoch) return null;
				const snapshot: FileSearchSnapshot = {
					key,
					roots: [
						{
							id: 0,
							kind: "workspace",
							absolutePath: currentWritablePath,
							label: rootNode.title,
						},
						{
							id: 1,
							kind: "builtin",
							absolutePath: currentAssetPath,
							label: builtinRoot?.title ?? t("tree.builtin"),
						},
					],
					entries,
				};
				await initializeFileSearchIndex(snapshot);
				return entries.length;
			}).catch(() => null);
			request = {
				key,
				epoch,
				promise,
			};
			filterOptionsRequestRef.current = request;
			void promise.finally(() => {
				if (filterOptionsRequestRef.current?.promise === promise) {
					filterOptionsRequestRef.current = null;
				}
			});
		}
		return request.promise;
	}, [t]);

	useEffect(() => {
		if (!openFilter) return;
		const rootNode = treeDataRef.current.at(0);
		if (rootNode === undefined || writablePath === "") {
			setOpenFilter(false);
			return;
		}
		const key = `${writablePath}\0${assetPath}`;
		if (hasFileSearchIndex(key)) {
			setFilterOptionCount(getFileSearchIndexSize());
			setFilterOptionsLoading(false);
			return;
		}
		setFilterOptionCount(0);
		setFilterOptionsLoading(true);
		let cancelled = false;
		void ensureFileSearchIndex().then((count) => {
			if (cancelled) return;
			setFilterOptionsLoading(false);
			if (count === null) {
				setOpenFilter(false);
				return;
			}
			setFilterOptionCount(count);
		});
		return () => {
			cancelled = true;
		};
	}, [ensureFileSearchIndex, openFilter]);

	useEffect(() => {
		const rootNode = treeData.at(0);
		if (rootNode === undefined || writablePath === "") return;
		const key = `${writablePath}\0${assetPath}`;
		if (hasFileSearchIndex(key)) return;
		let cancelled = false;
		const warmIndex = () => {
			if (cancelled) return;
			void ensureFileSearchIndex().then((count) => {
				if (cancelled || count === null) return;
				setFilterOptionCount(count);
			});
		};
		if (typeof window.requestIdleCallback === "function") {
			const idleId = window.requestIdleCallback(warmIndex, { timeout: 2000 });
			return () => {
				cancelled = true;
				window.cancelIdleCallback(idleId);
			};
		}
		const timer = window.setTimeout(warmIndex, 800);
		return () => {
			cancelled = true;
			window.clearTimeout(timer);
		};
	}, [ensureFileSearchIndex, treeData]);

	const spineLoadFailed = useCallback((message: string) => {
		addAlert(message, 'error');
	}, [addAlert]);

	saveEditingInfo = () => {
		const editingInfo: Service.EditingInfo = {
			index: tabIndex ?? 0,
			files: files.map(f => {
				const { key, title, mdEditing, yarnTextEditing, bodyTextEditing, particleTextEditing, editor, readOnly, agentSessionId, workspaceView } = f;
				let { position } = f;
				const { folder = false } = f;
				if (position === undefined && editor !== undefined) {
					position = editor.getPosition() ?? undefined;
				}
				return { key, title, mdEditing, yarnTextEditing, bodyTextEditing, particleTextEditing, position, readOnly, folder, agentSessionId, workspaceView };
			})
		};
		if (areEditingInfosEqual(editingInfo, lastEditingInfo)) {
			return;
		}
		lastEditingInfo = editingInfo;
		Service.editingInfo({
			editingInfo: editingInfo.files.length > 0 ? JSON.stringify(editingInfo) : ""
		}).catch(reason => {
			console.error(`failed to save editing info, due to: ${reason}`);
		});
	};

	const onCloseLog = useCallback(() => {
		const continueFirstProjectTour = firstProjectTourOpen && firstProjectTourCurrent === 10;
		if (openLog?.stopOnClose) onStopRunning();
		setOpenLog(null);
		if (continueFirstProjectTour) locateFirstProjectAgent();
	}, [
		firstProjectTourCurrent,
		firstProjectTourOpen,
		locateFirstProjectAgent,
		openLog,
		onStopRunning,
	]);

	const onValidate = useCallback((markers: Monaco.editor.IMarker[], key: string) => {
		if (checkFileReadonly(key, false)) return;
		const file = files.find(f => f.key === key);
		if (file === undefined) return;
		let status: TabStatus = "normal";
		let severity = 0;
		for (const marker of markers) {
			if (marker.severity > severity) {
				severity = marker.severity;
			}
		}
		if (severity > 0) {
			switch (severity) {
				case monaco.MarkerSeverity.Error:
					status = "error";
					break;
				case monaco.MarkerSeverity.Warning:
					status = "warning";
					break;
				default:
					status = "normal";
					break;
			}
		}
		if (file.editor !== undefined) {
			const filtered = markers.filter(marker => {
				return marker.owner !== 'tstl' && marker.code !== "2497" && marker.code !== "2666";
			});
			if (filtered.length !== markers.length) {
				const model = file.editor.getModel();
				if (model) {
					monaco.editor.setModelMarkers(model, model.getLanguageId(), filtered);
				}
			}
		}
		if (file.status !== status) {
			file.status = status;
			setFiles([...files]);
		}
	}, [files, checkFileReadonly]);

	const onFileFilterClose = useCallback((value: FilterOption | null) => {
		setOpenFilter(false);
		setFilterOptionsLoading(false);
		if (value === null) {
			return;
		}
		openFileInTab(value.fileKey, value.title, false);
	}, [openFileInTab]);

	useEffect(() => {
		if (!openFilter) return;
		const closeOnOutsidePointer = (event: PointerEvent) => {
			const paper = document.querySelector('[data-file-filter-dialog="true"] .MuiDialog-paper');
			if (
				paper !== null
				&& event.target instanceof Node
				&& !paper.contains(event.target)
			) {
				onFileFilterClose(null);
			}
		};
		document.addEventListener("pointerdown", closeOnOutsidePointer, true);
		return () => document.removeEventListener("pointerdown", closeOnOutsidePointer, true);
	}, [onFileFilterClose, openFilter]);

	const onSearchOpenFile = useCallback((file: string, line: number, column: number) => {
		if (tabIndex !== null && files[tabIndex]?.key === file) {
			const editor = files[tabIndex]?.editor;
			if (editor === undefined) return;
			const pos = {
				lineNumber: line,
				column: column,
			};
			editor.setPosition(pos);
			editor.revealPositionInCenterIfOutsideViewport(pos);
			editor.focus();
			return;
		}
		setJumpToFile({
			key: file,
			title: path.basename(file),
			row: line,
			col: column,
		});
	}, [setJumpToFile, tabIndex, files]);

	const onAgentOpenFile = useCallback((projectRoot: string, filePath: string) => {
		const targetPath = path.isAbsolute(filePath) ? filePath : path.join(projectRoot, filePath);
		openFileInTab(targetPath, path.basename(targetPath), false);
	}, [openFileInTab]);

	const onGitOpenProject = useCallback((projectPath: string) => {
		openProjectWorkspaceTab(projectPath, "git");
	}, [openProjectWorkspaceTab]);

	return (
		<Entry>
			<Dialog
				data-file-filter-dialog="true"
				maxWidth="lg"
				open={openFilter}
				onClose={() => onFileFilterClose(null)}
				onPointerDown={(event) => {
					const target = event.target;
					if (target instanceof Element && target.closest(".MuiDialog-paper") === null) {
						onFileFilterClose(null);
					}
				}}
				transitionDuration={0}
				slotProps={{
					transition: transitionProps,
					backdrop: {
						onMouseDown: () => onFileFilterClose(null),
						onClick: () => onFileFilterClose(null),
					},
				}}
			>
				<DialogContent>
					{openFilter ?
						<FileFilter optionCount={filterOptionCount} loading={filterOptionsLoading} onClose={onFileFilterClose} /> : null
					}
				</DialogContent>
			</Dialog>
			<LogView openName={openLog === null ? null : openLog.title} height={editorHeight * 0.9} onClose={onCloseLog} onFixLog={onFixLog} />
			<Dialog
				maxWidth="lg"
				open={popupInfo !== null}
				aria-labelledby="alert-dialog-title"
				aria-describedby="alert-dialog-description"
				transitionDuration={0}
				slotProps={{ transition: transitionProps }}
			>
				<DialogTitle id="alert-dialog-title">
					{popupInfo?.title}
				</DialogTitle>
				<MacScrollbar skin='dark' style={{ height: '100%' }}>
					<DialogContent>
						<DialogContentText
							component="span"
							id="alert-dialog-description"
						>
							{popupInfo?.selectable ?
								<TextField
									fullWidth
									hiddenLabel
									multiline
									autoComplete="off"
									variant="outlined"
									id="popupText"
									defaultValue={popupInfo?.msg}
									slotProps={{
										input: {
											readOnly: true,
										}
									}}
									onFocus={(event) => event.target.setSelectionRange(0, event.target.value.length)}
								/>
								: popupInfo?.raw ?
									<pre>{popupInfo?.msg}</pre>
									: popupInfo?.msg
							}
						</DialogContentText>
					</DialogContent>
				</MacScrollbar>
				<DialogActions>
					<Button
						onClick={handleAlertClose}
						autoFocus={popupInfo?.cancelable === undefined}
					>
						{t(popupInfo?.cancelable !== undefined ?
							"action.confirm" : "action.ok")
						}
					</Button>
					{popupInfo?.cancelable !== undefined ?
						<Button onClick={handleAlertCancel}>
							{t("action.cancel")}
						</Button> : null
					}
				</DialogActions>
			</Dialog>
			<Dialog
				open={fileInfo !== null}
				aria-labelledby="filename-dialog-title"
				aria-describedby="filename-dialog-description"
				transitionDuration={0}
				slotProps={{
					transition: transitionProps,
					paper: {
						"data-first-project-dialog": "true",
					},
				}}
			>
				<DialogTitle id="filename-dialog-title">
					{t(fileInfo?.title ?? "")}
				</DialogTitle>
				<DialogContent>
					<Box display="flex" flexDirection="column" gap={2}>
						<TextField
							autoFocus
							autoComplete="off"
							label={(
								fileInfo?.title === "file.new" ?
									t("file.enterFile") : undefined
							) ?? (
									fileInfo?.title === "file.newFolder" ?
										t("file.enterFolder") : undefined
								)
							}
							defaultValue={fileInfo?.name ?? ""}
							id="filename-adornment"
							sx={{
								m: 1,
								width: '25ch',
							}}
							slotProps={{
								htmlInput: {
									"data-first-project-name": "true",
								},
								input: {
									endAdornment:
										<InputAdornment position="end">
											{fileInfo?.ext === undefined
												? undefined
												: (fileInfo.ext !== ".ts" && fileInfo.ext !== ".tsx")
													? (fileInfo.ext === ".wa" && fileInfo.project ? undefined : fileInfo.ext)
													: <div style={{ color: Color.Secondary }}>
														{fileInfo.ext}
														<IconButton
															size='small'
															aria-label="toggle tsx"
															edge="end"
															color='primary'
															onClick={() => {
																setFileInfo({ ...fileInfo, ext: fileInfo.ext === '.ts' ? '.tsx' : '.ts' });
															}}
														>
															<TbSwitchVertical />
														</IconButton>
													</div>
											}
										</InputAdornment>,
								}
							}}
							onChange={onFilenameChange}
						/>
						{fileInfo?.ext === ".wa" && fileInfo.title === "file.new" ?
							<FormControlLabel
								style={{ marginLeft: 5 }}
								label={t("file.projectNamed", { name: "Wa" })}
								control={
									<Checkbox
										checked={fileInfo?.project}
										onChange={(event) => {
											if (fileInfo === null) return;
											const newFileInfo = { ...fileInfo, project: event.target.checked };
											setFileInfo(newFileInfo);
										}}
									/>
								}
							/> : null
						}
						{fileInfo?.title === "file.newFolder" ?
							<>
								<FormControlLabel
									data-first-project-checkbox="true"
									style={{ marginLeft: 5 }}
									label={t("file.project")}
									control={
										<Checkbox
											checked={fileInfo?.project}
											onChange={(event) => {
												if (fileInfo === null) return;
												setFileInfo({ ...fileInfo, project: event.target.checked });
												if (
													event.target.checked
													&& firstProjectTourOpen
													&& firstProjectTourCurrent === 5
												) {
													setFirstProjectTourCurrent(6);
												}
											}}
										/>
									}
								/>
								{fileInfo.project ?
									<TextField
										select
										label={t("file.projectType")}
										value={fileInfo.projectType ?? "TypeScript"}
										sx={{
											m: 1,
											width: '25ch',
										}}
										onChange={(event) => {
											if (fileInfo === null) return;
											setFileInfo({ ...fileInfo, projectType: event.target.value as FolderProjectType });
										}}
									>
										{folderProjectTypes.map((projectType) =>
											<MenuItem key={projectType} value={projectType}>{projectType}</MenuItem>
										)}
									</TextField>
									: null}
							</> : null
						}
					</Box>
				</DialogContent>
				<DialogActions>
					<Button
						data-first-project-create="true"
						disabled={
							firstProjectTourOpen
							&& firstProjectTourCurrent >= 4
							&& firstProjectTourCurrent <= 6
							&& (
								(fileInfo?.name.trim().length ?? 0) === 0
								|| fileInfo?.project !== true
							)
						}
						onClick={() => {
							if (
								firstProjectTourOpen
								&& firstProjectTourCurrent >= 4
								&& firstProjectTourCurrent <= 6
							) {
								createFirstProject();
							} else {
								handleFilenameClose();
							}
						}}
					>
						{t("action.ok")}
					</Button>
					<Button onClick={handleFilenameCancel}>
						{t("action.cancel")}
					</Button>
				</DialogActions>
			</Dialog>
			<NewFileDialog open={openNewFile !== null} onClose={onNewFileClose} />
			<LLMConfigDialog open={openLLMConfig} onClose={() => setOpenLLMConfig(false)} />
			<FirstProjectTour
				open={firstProjectTourOpen}
				current={firstProjectTourCurrent}
				creating={firstProjectTourCreating}
				projectNameReady={(fileInfo?.name.trim().length ?? 0) > 0}
				exampleCodeReady={firstProjectTourExampleReady}
				canInsertExample={firstProjectTourEditingFile?.editor !== undefined}
				onStart={beginFirstProjectTour}
				onProjectNameReady={() => setFirstProjectTourCurrent(5)}
				onInsertExample={insertFirstProjectExample}
				onExampleCodeReady={() => setFirstProjectTourCurrent(8)}
				onSkip={completeFirstProjectTour}
				onFinish={completeFirstProjectTour}
				onExploreAgent={exploreFirstProjectAgent}
				onClose={interruptFirstProjectTour}
			/>
			<Box sx={{ display: "flex", width: '100%', height: '100%' }}>
				<CssBaseline />
				<AppBar
					position="fixed"
					open={drawerOpen && !narrowLayout}
					drawerWidth={drawerWidth}
					isResizing={isResizing}
				>
					<Toolbar disableGutters variant='dense' sx={{
						backgroundColor: Color.BackgroundDark,
						width: "100%",
						color: Color.Primary,
						minHeight: 48,
						pl: 2.2
					}}>
						<IconButton
							color="inherit"
							aria-label="open drawer"
							onClick={handleDrawerOpen}
							edge="start"
							sx={{
								width: 36,
								height: 36,
								borderRadius: 1.5,
								color: Color.Secondary,
								backgroundColor: 'transparent',
								'&:hover': {
									backgroundColor: Color.Line,
								},
							}}
						>
							{drawerOpen ? <Fullscreen /> : <FullscreenExit />}
						</IconButton>
						<Box sx={{ flex: 1, minWidth: 0, m: 0, p: 0 }}>
							<FileTabBar
								index={tabIndex}
								items={files.map(file => (
									file.agentSessionId !== undefined && file.key === writablePath
										? { ...file, title: t("tree.assets") }
										: file
								))}
								onChange={tabBarOnChange}
								onMenuClick={onTabMenuClick}
								onTabClose={onTabClose}
							/>
						</Box>
					</Toolbar>
				</AppBar>
				<Splitter
					orientation="horizontal"
					lazy
					onResizeStart={() => setIsResizing(true)}
					onResize={() => undefined}
					onResizeEnd={onSplitterResizeEnd}
					classNames={{
						dragger: {
							default: 'dora-splitter-dragger',
						},
					}}
					styles={{
						dragger: {
							default: {
								zIndex: 1000,
								backgroundColor: 'transparent',
								backgroundImage: `linear-gradient(to right, transparent calc(50% - 0.5px), ${Color.Line} calc(50% - 0.5px), ${Color.Line} calc(50% + 0.5px), transparent calc(50% + 0.5px))`,
								transition: 'background-image 0.15s ease',
							},
							active: {
								backgroundColor: 'transparent',
								backgroundImage: `linear-gradient(to right, transparent calc(50% - 0.5px), ${Color.Theme} calc(50% - 0.5px), ${Color.Theme} calc(50% + 0.5px), transparent calc(50% + 0.5px))`,
							},
						},
					}}
					style={{ width: '100%', height: '100%' }}
				>
					<Splitter.Panel
						className="dora-resource-panel"
						size={drawerOpen ? effectiveDrawerWidth : 0}
						min={drawerOpen ? (narrowLayout ? effectiveDrawerWidth : 170) : 0}
						max={narrowLayout ? effectiveDrawerWidth : "50%"}
						resizable={drawerOpen && !narrowLayout}
						destroyOnHidden={false}
						style={{
							overflow: 'hidden',
							backgroundColor: Color.BackgroundDark,
							color: Color.TextPrimary,
							...(narrowLayout ? {
								position: 'absolute',
								inset: '0 auto 0 0',
								zIndex: 3,
								width: drawerOpen ? effectiveDrawerWidth : 0,
								maxWidth: '82vw',
								boxShadow: drawerOpen ? '12px 0 28px rgba(0, 0, 0, 0.42)' : 'none',
							} : {}),
						}}
					>
					<div style={{
						display: 'flex',
						flexDirection: 'column',
						width: narrowLayout ? '100%' : drawerWidth,
						height: '100%'
					}}>
						<div style={{
							display: 'flex',
							alignItems: 'center',
							justifyContent: 'space-between',
							gap: 8,
							padding: '8px 10px',
							background: Color.BackgroundDark,
							borderBottom: `0.5px solid ${Color.Line}`
						}}>
							<Tooltip title={t("menu.version", { version: Info.version ?? "" })}>
								<a
									href={Info.locale.match(/^zh/) ? 'https://ippclub.gitee.io/Dora-SSR/zh-Hans/docs/api/intro' : 'https://dora-ssr.net/docs/api/intro'}
									target="_blank"
									rel="noreferrer"
									style={{
										display: 'flex',
										alignItems: 'center',
										gap: 6,
										textDecoration: 'none'
									}}
								>
									{showFullLogo ? (
										<img
											src={logo}
											alt="logo"
											height={32}
										/>
									) : (
										<div style={{ width: 32, height: 32, overflow: 'hidden' }}>
											<img
												src={logo}
												alt="logo"
												height={32}
											/>
										</div>
									)}
								</a>
							</Tooltip>
							<Stack direction="row" spacing={1} alignItems="center">
								<Tooltip title={t("menu.explorer")}>
									<IconButton
										size="small"
										color="inherit"
										aria-pressed={leftDockTab === "explorer"}
										onClick={() => setLeftDockTab("explorer")}
										sx={{
											backgroundColor: leftDockTab === "explorer" ? Color.Theme + "11" : "transparent",
											border: `1px solid ${leftDockTab === "explorer" ? Color.Theme + "55" : Color.Line}`,
											borderRadius: 1.5,
										}}
									>
										<AccountTreeIcon fontSize="small" />
									</IconButton>
								</Tooltip>
								<Tooltip title={t("menu.entries")}>
									<IconButton
										size="small"
										color="inherit"
										aria-pressed={leftDockTab === "tools"}
										onClick={() => {
											setLeftDockTab("tools");
											loadEntries();
										}}
										sx={{
											backgroundColor: leftDockTab === "tools" ? Color.Theme + "11" : "transparent",
											border: `1px solid ${leftDockTab === "tools" ? Color.Theme + "55" : Color.Line}`,
											borderRadius: 1.5,
										}}
									>
										<FormatListBulletedIcon fontSize="small" />
									</IconButton>
								</Tooltip>
								<Tooltip title={t("menu.searchFiles")}>
									<IconButton
										size="small"
										color="inherit"
										aria-pressed={leftDockTab === "search"}
										onClick={() => setLeftDockTab("search")}
										sx={{
											backgroundColor: leftDockTab === "search" ? Color.Theme + "11" : "transparent",
											border: `1px solid ${leftDockTab === "search" ? Color.Theme + "55" : Color.Line}`,
											borderRadius: 1.5,
										}}
									>
										<SearchIcon fontSize="small" />
									</IconButton>
								</Tooltip>
								{narrowLayout ? (
									<Tooltip title={t("action.close")}>
										<IconButton
											size="small"
											color="inherit"
											aria-label="close drawer"
											onClick={handleDrawerOpen}
											sx={{
												border: `1px solid ${Color.Line}`,
												borderRadius: 1.5,
											}}
										>
											<Fullscreen fontSize="small" />
										</IconButton>
									</Tooltip>
								) : null}
							</Stack>
						</div>
						<div style={{ flex: 1, minHeight: 0, padding: 0 }} hidden={leftDockTab !== "explorer"}>
							<FileTree
								selectedKeys={selectedKeys}
								checkedKeys={checkedKeys}
								expandedKeys={expandedKeys}
								treeData={treeData}
								firstProjectTourTargetKey={
									firstProjectTourCurrent === 11 && firstProjectTourFile !== null
										? path.dirname(firstProjectTourFile)
										: undefined
								}
								firstProjectTourWorkspaceRightClickOnly={
									firstProjectTourOpen && firstProjectTourCurrent === 1
								}
								scrollRequest={treeScrollRequest}
								resizing={isResizing}
								multiSelectMode={multiSelectMode}
								batchTargetMode={batchTargetMode}
								onMenuClick={onTreeMenuClick}
								onContextMenuOpen={(data) => {
									if (
										firstProjectTourOpen
										&& firstProjectTourCurrent === 1
										&& data.key === treeDataRef.current.at(0)?.key
									) {
										setFirstProjectTourCurrent(2);
									}
								}}
								onSelect={onSelect}
								onCheck={onCheckTreeNodes}
								onToggleMultiSelect={onToggleMultiSelect}
								onBatchAction={onBatchAction}
								onBatchTarget={onBatchTarget}
								onCancelBatchTarget={onCancelBatchTarget}
								onExpand={onExpand}
								loadData={loadTreeNode}
								onDrop={onDrop}
							/>
						</div>
						<div style={{ flex: 1, minHeight: 0, padding: 0 }} hidden={leftDockTab !== "search"}>
							<FileSearchPanel
								open={leftDockTab === "search"}
								searchPath={writablePath}
								onOpenFile={onSearchOpenFile}
							/>
						</div>
						<div style={{
							flex: 1,
							minHeight: 0,
							padding: 0,
							display: leftDockTab === "tools" ? 'flex' : 'none',
							flexDirection: 'column',
							overflow: 'hidden'
						}}>
							<Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ m: 1.5, mb: 1, flexShrink: 0 }}>
								<Stack direction="row" spacing={0.5}>
									<Button
										size="small"
										variant="outlined"
										onClick={() => setEntryView("tool")}
										sx={{
											textTransform: "none",
											minWidth: 0,
											color: Color.Primary,
											backgroundColor: entryView === "tool" ? Color.Theme + "11" : "transparent",
											borderColor: entryView === "tool" ? Color.Theme + "55" : Color.Line,
											borderRadius: 1.5,
											"&:hover": {
												backgroundColor: entryView === "tool" ? Color.Theme + "11" : "transparent",
												borderColor: entryView === "tool" ? Color.Theme + "55" : Color.Line,
											},
										}}
									>
										{t("menu.tools")}
									</Button>
									<Button
										size="small"
										variant="outlined"
										onClick={() => setEntryView("game")}
										sx={{
											textTransform: "none",
											minWidth: 0,
											color: Color.Primary,
											backgroundColor: entryView === "game" ? Color.Theme + "11" : "transparent",
											borderColor: entryView === "game" ? Color.Theme + "55" : Color.Line,
											borderRadius: 1.5,
											"&:hover": {
												backgroundColor: entryView === "game" ? Color.Theme + "11" : "transparent",
												borderColor: entryView === "game" ? Color.Theme + "55" : Color.Line,
											},
										}}
									>
										{t("menu.projects")}
									</Button>
								</Stack>
								<Button size="small" onClick={() => loadEntries()}>
									{t("menu.reload")}
								</Button>
							</Stack>
							<TextField
								size="small"
								value={entryFilter}
								placeholder={t("menu.filterEntries")}
								onChange={(event) => setEntryFilter(event.target.value)}
								sx={{ mx: 1.5, mb: 1, flexShrink: 0 }}
							/>
							<MacScrollbar skin='dark' style={{ flex: 1, minHeight: 0 }}>
								<Stack spacing={1} sx={{ pl: 1.5, pr: 2, pb: 1.5 }}>
									{visibleEntries.length === 0 ? (
										<Typography variant="body2" sx={{ opacity: 0.7 }}>
											{t(entryView === "tool" ? "menu.noTools" : "menu.noProjects")}
										</Typography>
									) : visibleEntries.map((entry) => (
										<Stack key={`${entry.file}-${entry.name}`} direction="row" spacing={0.75} alignItems="stretch">
											<Button
												variant="outlined"
												size="small"
												fullWidth
												onClick={() => onLaunchToolEntry(entry)}
												sx={{
													justifyContent: "flex-start",
													textTransform: "none",
													borderColor: Color.Line,
													color: Color.Primary,
													minWidth: 0,
													overflow: "hidden",
												}}
											>
												<Typography variant="body2" noWrap sx={{ minWidth: 0 }}>
													{entry.name}
												</Typography>
											</Button>
											{entryView === "game" ? (
												<Tooltip title={t("menu.openProjectFolder")}>
													<span>
														<IconButton
															size="small"
															onClick={() => onOpenEntryWorkDir(entry)}
															sx={{
																width: 34,
																height: 34,
																border: `1px solid ${Color.Line}`,
																borderRadius: 1,
																color: Color.TextSecondary
															}}
														>
															<FolderOpenIcon fontSize="small" />
														</IconButton>
													</span>
												</Tooltip>
											) : null}
										</Stack>
									))}
								</Stack>
							</MacScrollbar>
						</div>
					</div>
					</Splitter.Panel>
					<Splitter.Panel
						className="dora-content-panel"
						min={narrowLayout ? 0 : 320}
						style={{
							overflow: 'hidden',
							...(narrowLayout ? {
								flexBasis: '100%',
								width: '100%',
								maxWidth: '100%',
							} : {}),
						}}
					>
					<Box sx={{ position: 'relative', width: '100%', height: '100%', overflow: 'hidden' }}>
				<>{
					files.map((file, index) => {
						const active = tabIndex === index;
						if (file.agentSessionId) {
							return <Main
								open
								key={file.key}
								hidden={!active}
								drawerWidth={0}
							>
								<DrawerHeader />
								<ProjectWorkspacePanel
									active={active}
									title={file.title}
									height={editorHeight}
									uploadPath={file.key}
									displayPath={getWorkspaceDisplayPath(file.key)}
									isWorkspaceRoot={file.key === writablePath}
									agentSessionId={file.agentSessionId}
									agentInitialPrompt={file.agentInitialPrompt}
									view={file.workspaceView ?? "agent"}
									addAlert={addAlert}
									onAgentInitialPromptConsumed={() => onAgentInitialPromptConsumed(file.key)}
									onRollbackComplete={onAgentRollbackComplete}
									onUploaded={onUploaded}
									onViewChange={(view) => onWorkspaceViewChange(file.key, view)}
									onOpenFile={(filePath) => onAgentOpenFile(file.key, filePath)}
									onOpenProject={onGitOpenProject}
									onRepositoryFilesChanged={scheduleGitAssetsRefresh}
									onOpenLLMConfig={() => setOpenLLMConfig(true)}
								/>
							</Main>;
						}
						const ext = file.folder ? "" : path.extname(file.title);
						let language: "lua" | "tl" | "yue" | "typescript" | "xml" | "markdown" | "wa" | "yarn" | "ini" | "txt" | null = null;
						let image = false;
						let spine = false;
						let yarn = false;
						let visualScript = false;
						let blockly = false;
						let tic80 = false;
						let actionModel = false;
						let actionClip = false;
						let bodyLua = false;
						let particle = false;
						switch (ext.toLowerCase()) {
							case ".lua":
								if (isBodyLuaFile(file.title) && !file.bodyTextEditing) {
									bodyLua = true;
								} else {
									language = "lua";
								}
								break;
							case ".tl": language = "tl"; break;
							case ".yue": language = "yue"; break;
							case ".ts": case ".tsx": language = "typescript"; break;
							case ".xml": language = "xml"; break;
							case ".clip": actionClip = true; break;
							case ".par":
								if (!file.particleTextEditing) {
									particle = true;
								} else {
									language = "xml";
								}
								break;
							case ".md": language = "markdown"; break;
							case ".wa": language = "wa"; break;
							case ".mod": language = "ini"; break;
							case ".jpg": image = true; break;
							case ".png": image = true; break;
							case ".skel": spine = true; break;
							case ".yarn": yarn = true; language = "yarn"; break;
							case ".bl": blockly = true; break;
							case ".vs": visualScript = true; break;
							case ".tic": tic80 = true; break;
							case ".model": actionModel = true; break;
							default:
								if (!file.folder) language = "txt";
								break
						}
						const markdown = language === "markdown";
						const hidden = (markdown && !file.mdEditing) || (yarn && !file.yarnTextEditing);
						const readOnly = file.readOnly || checkFileReadonly(file.key, false);
						let parentPath;
						if (isChildFolder(file.key, assetPath)) {
							parentPath = assetPath;
						} else {
							parentPath = writablePath;
						}
						return <Main
							open
							key={file.key}
							hidden={!active}
							drawerWidth={0}
						>
							<DrawerHeader />
							{bodyLua ?
								<Suspense fallback={<div />}>
									<BodyEditor
										filePath={file.key}
										resourceBasePath={parentPath}
										sourceContent={file.contentModified ?? file.content}
										width={editorWidth}
										height={editorHeight}
										active={tabIndex === index}
										readOnly={readOnly}
										refreshKey={file.previewVersion ?? 0}
										addAlert={addAlert}
										onOpenAsText={() => {
											file.bodyTextEditing = true;
											setFiles([...files]);
										}}
										onChange={(content) => {
											setModified({ key: file.key, content });
										}}
									/>
								</Suspense> : null
							}
							{particle ?
								<Suspense fallback={<div />}>
									<ParticleEditor
										filePath={file.key}
										resourceBasePath={parentPath}
										sourceContent={file.contentModified ?? file.content}
										width={editorWidth}
										height={editorHeight}
										active={tabIndex === index}
										readOnly={readOnly}
										refreshKey={file.previewVersion ?? 0}
										addAlert={addAlert}
										onOpenAsText={() => {
											file.particleTextEditing = true;
											setFiles([...files]);
										}}
										onChange={(content) => {
											setModified({ key: file.key, content });
										}}
									/>
								</Suspense> : null
							}
							{actionModel ?
								<Suspense fallback={<div />}>
									<ActionEditor
										filePath={file.key}
										resourceBasePath={parentPath}
										sourceContent={file.contentModified ?? file.content}
										width={editorWidth}
										height={editorHeight}
										active={tabIndex === index}
										readOnly={readOnly}
										onChange={(content) => {
											setModified({ key: file.key, content });
										}}
										onLoadFailed={(message) => {
											addAlert(message, "error", true);
										}}
									/>
								</Suspense> : null
							}
							{actionClip ?
								<div style={{ display: 'flex', position: 'relative', width: '100%', maxWidth: '100%', minWidth: 0, overflow: 'hidden' }}>
									<MacScrollbar skin='dark' style={{ height: editorHeight, width: '100%', maxWidth: '100%', minWidth: 0 }}>
										<Suspense fallback={<div />}>
											<ActionClipPreview
												key={`${file.key}:${file.previewVersion ?? 0}`}
												filePath={file.key}
												resourceBasePath={parentPath}
												sourceContent={file.contentModified ?? file.content}
												refreshKey={file.previewVersion ?? 0}
												width={editorWidth}
												height={editorHeight}
												addAlert={addAlert}
											/>
										</Suspense>
									</MacScrollbar>
								</div> : null
							}
							{yarn && !file.yarnTextEditing ?
								<div style={{ display: 'flex', position: 'relative' }}>
									<Suspense fallback={<div />}>
										<YarnEditor
											title={file.key}
											defaultValue={file.contentModified ?? file.content}
											width={editorWidth}
											height={editorHeight}
											onLoad={(data) => {
												file.yarnData = data;
											}}
											onUnload={(data) => {
												if (file.yarnData === data) {
													file.yarnData = undefined;
												}
											}}
											onChange={() => {
												const data = file.yarnData;
												if (data === undefined) return;
												const revision = (file.visualSnapshotRevision ?? 0) + 1;
												file.visualSnapshotRevision = revision;
												file.visualSnapshotPending = true;
												setModified({ key: file.key, content: "" });
												void data.getJSONData().then(value => {
													if (file.visualSnapshotRevision !== revision) return;
													const text = Yarn.convertYarnJsonToText(JSON.parse(value));
													file.visualSnapshotPending = false;
													setModified({ key: file.key, content: text });
												}).catch(() => {
													// Keep the live iframe pinned when a recoverable snapshot cannot be produced.
												});
											}}
											onKeydown={(e) => {
												setKeyEvent(e);
											}}
										/>
									</Suspense>
									<div hidden={readOnly} style={{
										position: 'absolute',
										left: '20px',
										bottom: '75px',
										zIndex: 100
									}}>
										<Stack direction="row" spacing={1}>
											<Tooltip title={t('yarn.editCode')}>
												<IconButton
													onClick={async () => {
														try {
															const value = await file.yarnData?.getJSONData();
															if (value !== undefined) {
																const text = Yarn.convertYarnJsonToText(JSON.parse(value));
																const model = file.editor?.getModel();
																if (model && model.getValue() !== text) {
																	model.pushStackElement();
																	model.pushEditOperations(null, [{
																		text,
																		range: model.getFullModelRange()
																	}], () => { return null });
																	model.pushStackElement();
																}
																file.contentModified = text !== file.content ? text : null;
															}
															file.yarnTextEditing = true;
															file.yarnData = undefined;
															setFiles([...files]);
															requestAnimationFrame(() => {
																file.editor?.focus();
															});
														} catch {
															addAlert(t("alert.saveCurrent"), "error");
														}
													}}
													sx={{
														backgroundColor: 'rgba(50, 50, 50, 0.7)',
														color: 'rgba(255, 255, 255, 0.4)',
														'&:hover': {
															backgroundColor: 'rgba(70, 70, 70, 0.9)',
														}
													}}
												>
													<CodeIcon />
												</IconButton>
											</Tooltip>
										</Stack>
									</div>
								</div> : null
							}
							{visualScript ?
								<Suspense fallback={<div />}>
									<CodeWire
										key={file.key}
										title={file.key}
										defaultValue={file.contentModified ?? file.content}
										width={editorWidth}
										height={editorHeight}
										onLoad={(data) => {
											file.codeWireData = data;
										}}
										onUnload={(data) => {
											if (file.codeWireData === data) {
												if (file.contentModified !== null) {
													file.contentModified = data.getVisualScript();
												}
												file.codeWireData = undefined;
											}
										}}
										onChange={() => {
											const content = file.codeWireData?.getVisualScript();
											if (content !== undefined) {
												setModified({ key: file.key, content });
											}
										}}
										onKeydown={(e) => {
											setKeyEvent(e);
										}}
									/>
								</Suspense> : null
							}
							{blockly ?
								<Blockly
									width={editorWidth}
									height={tabIndex === index ? editorHeight : 0}
									file={file.key}
									readOnly={readOnly}
									initialJson={file.contentModified ?? file.content}
									onSave={saveCurrentTab}
									onChange={(json, blocklyCode) => {
										setModified({ key: file.key, content: json, blocklyCode });
										const extname = path.extname(file.key);
										const name = path.basename(file.key, extname);
										const luaFile = path.join(path.dirname(file.key), name + ".lua");
										const model = monaco.editor.getModel(monaco.Uri.file(luaFile));
										if (model) {
											model.setValue(blocklyCode);
										} else {
											monaco.editor.createModel(blocklyCode, "lua", monaco.Uri.file(luaFile));
										}
									}}
								/> : null
							}
							{tic80 ?
								(() => {
									return (
										<Suspense fallback={<div />}>
											<TIC80Editor
												title={file.key}
												filePath={file.key}
												resPath={path.relative(parentPath, file.key)}
												defaultValue={file.content}
												width={editorWidth}
												height={editorHeight}
												onDirty={() => {
													if (file.ticDirty === true) return;
													file.ticDirty = true;
													setFiles(previous => previous.includes(file) ? [...previous] : previous);
												}}
												onSaved={() => {
													if (file.ticDirty !== true) return;
													file.ticDirty = false;
													setFiles(previous => previous.includes(file) ? [...previous] : previous);
												}}
												onKeydown={(e) => {
													setKeyEvent(e);
												}}
												addAlert={addAlert}
											/>
										</Suspense>
									);
								})() : null
							}
							{markdown ?
								<div style={{ display: 'flex', position: 'relative', width: '100%', maxWidth: '100%', minWidth: 0, overflow: 'hidden' }}>
									<MacScrollbar skin='dark' hidden={file.mdEditing} style={{ height: editorHeight, width: '100%', maxWidth: '100%', minWidth: 0 }}>
										<Markdown
											fileKey={file.key}
											path={Service.addr("/" + path.relative(parentPath, path.dirname(file.key)).replace("\\", "/"))}
											content={file.contentModified ?? file.content}
											onClick={onJumpLink}
										/>
										{readOnly ? null : <Stack direction="row" spacing={1} style={{ position: 'absolute', left: '20px', bottom: '20px', zIndex: 100 }}>
											<Tooltip title={t('markdown.editText')}>
												<IconButton
													onClick={() => {
														file.mdEditing = true;
														setFiles([...files]);
													}}
													sx={{
														backgroundColor: 'rgba(50, 50, 50, 0.7)',
														color: 'rgba(255, 255, 255, 0.4)',
														'&:hover': {
															backgroundColor: 'rgba(70, 70, 70, 0.9)',
														}
													}}
												>
													<CodeIcon />
												</IconButton>
											</Tooltip>
										</Stack>}
									</MacScrollbar>
								</div> : null
							}
							{image ?
								<MacScrollbar skin='dark' style={{ height: editorHeight }}>
									<Container maxWidth="lg">
										<DrawerHeader />
										<Image src={
											appendCacheKey(Service.addr("/" + path
												.relative(parentPath, file.key)
												.replace("\\", "/")), file.previewVersion)
										} preview={false} />
									</Container>
								</MacScrollbar> : null
							}
							{(() => {
								if (spine && tabIndex === index) {
									const skelFile = path.relative(parentPath, file.key);
									const coms = path.parse(skelFile);
									const atlasFile = path.join(coms.dir, coms.name + ".atlas");
									return (
										<MacScrollbar skin='dark' style={{ height: editorHeight }}>
											<Container maxWidth="lg">
												<DrawerHeader />
												<Suspense fallback={<div />}>
													<SpinePlayer
														skelFile={skelFile}
														atlasFile={atlasFile}
														onLoadFailed={spineLoadFailed}
													/>
												</Suspense>
											</Container>
										</MacScrollbar>
									);
								}
								return null;
							})()}
							{(() => {
								if (language) {
									const editorComponent = <Editor
										key={file.key}
										hidden={hidden}
										editingFile={file}
										width={editorWidth}
										height={editorHeight}
										language={language}
										minimap={!isResizing}
										onMount={file.onMount}
										onUnmount={onEditorWillUnmount(file)}
										onModified={onModified}
										onValidate={onValidate}
										readOnly={readOnly}
										tourTarget={
											firstProjectTourOpen
											&& firstProjectTourFile === file.key
											&& firstProjectTourCurrent === 7
										}
									/>;
									if (yarn) {
										if (!file.yarnTextEditing) {
											return (
												<div style={{ display: 'flex', position: 'relative' }}>
													{editorComponent}
												</div>
											);
										}
										return (
											<div style={{ display: 'flex', position: 'relative' }}>
												{editorComponent}
												<div hidden={readOnly} style={{
													position: 'absolute',
													left: '20px',
													bottom: '75px',
													zIndex: 100
												}}>
													<Stack direction="row" spacing={1}>
														<Tooltip title={t('yarn.editVisual')}>
															<IconButton
																onClick={() => {
																	if (file.editor) {
																		const model = file.editor.getModel();
																		if (model) {
																			const text = model.getValue();
																			setTimeout(() => {
																				file.content = text;
																				file.yarnTextEditing = false;
																				setFiles([...files]);
																			}, 200);
																		}
																	}
																}}
																sx={{
																	backgroundColor: 'rgba(50, 50, 50, 0.7)',
																	color: 'rgba(255, 255, 255, 0.4)',
																	'&:hover': {
																		backgroundColor: 'rgba(70, 70, 70, 0.9)',
																	}
																}}
															>
																<AccountTreeIcon />
															</IconButton>
														</Tooltip>
													</Stack>
												</div>
											</div>
										);
									}
									if (markdown) {
										if (!file.mdEditing) {
											return (
												<div style={{ display: 'flex', position: 'relative' }}>
													{editorComponent}
												</div>
											);
										}
										return (
											<div style={{ display: 'flex', position: 'relative' }}>
												{editorComponent}
												<div hidden={readOnly} style={{
													position: 'absolute',
													left: '20px',
													bottom: '20px',
													zIndex: 100
												}}>
													<Stack direction="row" spacing={1}>
														<Tooltip title={t('markdown.view')}>
															<IconButton
																onClick={() => {
																	setTimeout(() => {
																		file.mdEditing = false;
																		setFiles([...files]);
																	}, 200);
																}}
																sx={{
																	backgroundColor: 'rgba(50, 50, 50, 0.7)',
																	color: 'rgba(255, 255, 255, 0.4)',
																	'&:hover': {
																		backgroundColor: 'rgba(70, 70, 70, 0.9)',
																	}
																}}
															>
																<VisibilityIcon />
															</IconButton>
														</Tooltip>
													</Stack>
												</div>
											</div>
										);
									}
									return editorComponent;
								} else if (file.folder) {
									return (
										<ProjectWorkspacePanel
											title={file.title}
											height={editorHeight}
											uploadPath={file.key}
											isWorkspaceRoot={file.key === writablePath}
											displayPath={getWorkspaceDisplayPath(file.key, true)}
											agentInitialPrompt={file.agentInitialPrompt}
											view={file.workspaceView ?? "upload"}
											addAlert={addAlert}
											onAgentInitialPromptConsumed={() => onAgentInitialPromptConsumed(file.key)}
											onUploaded={onUploaded}
											onViewChange={(view) => onWorkspaceViewChange(file.key, view)}
											onOpenFile={(filePath) => onAgentOpenFile(file.key, filePath)}
											onOpenProject={onGitOpenProject}
											onRepositoryFilesChanged={scheduleGitAssetsRefresh}
											onOpenLLMConfig={() => setOpenLLMConfig(true)}
										/>
									);
								}
								return null;
							})()}
						</Main>
					})
				}
				</>
				{files.length > 0 ? null :
					<KeyboardShortcuts
						left={drawerOpen && !narrowLayout ? drawerWidth : 0}
						top={48}
						bottom={statusBarHeight}
						onGoToFile={() => setOpenFilter(true)}
						onNewFile={() => {
							const target = selectedNode ?? treeData.at(0);
							if (target !== undefined) setOpenNewFile(target);
						}}
						onOpenProjects={() => {
							if (!drawerOpen) handleDrawerOpen();
							setLeftDockTab("tools");
							setEntryView("game");
						}}
					/>
				}
				<div style={{ position: 'fixed', left: winSize.width - editorWidth, bottom: statusBarHeight, width: editorWidth, zIndex: 998, transition: 'all 0.2s' }} hidden={!openBottomLog}>
					<BottomLog active={openBottomLog} height={editorHeight * 0.3} onFixLog={onFixLog} />
				</div>
				<Box sx={{
					position: 'fixed',
					left: winSize.width - editorWidth,
					bottom: 0,
					width: editorWidth,
					height: statusBarHeight,
					zIndex: 999,
					display: 'flex',
					alignItems: 'center',
					justifyContent: 'space-between',
					px: 1,
					backgroundColor: Color.BackgroundDark,
					color: Color.TextSecondary,
					fontSize: 12,
					lineHeight: `${statusBarHeight}px`,
				}}>
					<Box sx={{
						minWidth: 0,
						overflow: 'hidden',
						textOverflow: 'ellipsis',
						whiteSpace: 'nowrap',
					}}>
					</Box>
					<Box sx={{ display: 'flex', alignItems: 'center', height: '100%', flexShrink: 0 }}>
						<PlayControl
							compact
							onClick={onPlayControlClick}
							showFirstProjectTour={!firstProjectTourCompleted}
							buildProjectAction={{
								onClick: () => void buildCurrentProject(),
							}}
						/>
					</Box>
				</Box>
				<div style={{ zIndex: 1200 }}>
					<StyledStack>
						<TransitionGroup>
							{alerts.map((item) => (
								<Collapse key={item.key} timeout='auto'>
									<Box sx={{
										display: 'flex',
										alignItems: 'center',
										gap: 1,
										width: '100%',
										minHeight: 40,
										mb: 0.75,
										pr: 0.5,
										backgroundColor: 'rgba(24, 24, 24, 0.94)',
										border: `1px solid ${Color.Line}`,
										borderLeft: `3px solid ${getAlertAccentColor(item.type)}`,
										boxShadow: '0 8px 24px rgba(0, 0, 0, 0.28)',
										color: Color.TextPrimary,
									}}>
										<Box sx={{
											flex: 1,
											minWidth: 0,
											py: 0.75,
											pl: 1.25,
											fontSize: 13,
											lineHeight: 1.35,
											whiteSpace: 'pre-wrap',
											overflowWrap: 'anywhere',
											wordBreak: 'break-word',
										}}>
											{item.msg}
											{item.count > 1 ? (
												<Box
													key={`${item.key}:${item.pulse}`}
													component="span"
													className="dora-alert-count-pulse"
													sx={{
														ml: 0.75,
														color: Color.Theme,
														fontWeight: 700,
														display: 'inline-block',
													}}
												>
													x{item.count}
												</Box>
											) : null}
											{item.openLog ? (
												<Link color="inherit" underline="hover" onClick={() => onPlayControlClick("View Log")} sx={{ ml: 1, color: Color.Theme, cursor: 'pointer', fontSize: 12 }}>
													{t("menu.viewLog")}
												</Link>
											) : null}
											{item.onAction && item.actionLabel ? (
												<Link color="inherit" underline="hover" onClick={() => {
													item.onAction?.();
													removeAlert(item.key);
												}} sx={{ ml: 1, color: Color.Theme, cursor: 'pointer', fontSize: 12 }}>
													{item.actionLabel}
												</Link>
											) : null}
										</Box>
										<IconButton
											size="small"
											aria-label="close alert"
											onClick={() => removeAlert(item.key)}
											sx={{
												width: 28,
												height: 28,
												flexShrink: 0,
												color: Color.TextSecondary,
												borderRadius: 1,
												'&:hover': {
													backgroundColor: Color.Line,
													color: Color.TextPrimary,
												},
											}}
										>
											x
										</IconButton>
									</Box>
								</Collapse>
							))}
						</TransitionGroup>
					</StyledStack>
				</div>
				<Modal
					open={disconnected}
					disableAutoFocus
					disableEnforceFocus
					disablePortal
					disableScrollLock
					disableEscapeKeyDown
					hideBackdrop={false}
					style={{
						display: 'flex',
						alignItems: 'center',
						justifyContent: 'center',
						backgroundColor: 'rgba(0, 0, 0, 0.7)',
					}}
				>
					<Box sx={{
						backgroundColor: Color.BackgroundDark,
						border: `1px solid ${Color.Line}`,
						borderRadius: 1,
						p: 4,
						textAlign: 'center',
						color: Color.Primary,
					}}>
						<Typography variant="h6" component="div" gutterBottom>
							{t("alert.disconnected")}
						</Typography>
						<Typography variant="body2" color="text.secondary">
							{t("alert.reconnecting")}
						</Typography>
					</Box>
				</Modal>
					</Box>
					</Splitter.Panel>
				</Splitter>
			</Box>
			<Box
				sx={{
					pointerEvents: 'none',
					position: 'fixed',
					left: (drawerOpen && !narrowLayout ? drawerWidth : 0) + 20,
					bottom: 20,
					zIndex: 1200,
					opacity: isWaSaving ? 1 : 0,
					transition: 'opacity 0.5s ease-in-out 0.5s',
					backgroundColor: 'rgba(15, 15, 15, 0.7)',
					padding: '8px 16px',
					borderRadius: '4px',
					animation: isWaSaving ? 'blink 1.5s infinite' : 'none',
					'@keyframes blink': {
						'0%': { opacity: 0.7 },
						'50%': { opacity: 1 },
						'100%': { opacity: 0.7 }
					}
				}}
			>
				<Typography sx={{ color: 'white' }}>
					{t("alert.saving")}
				</Typography>
			</Box>
		</Entry>
	);
}

import React, { ChangeEvent, useEffect, useState } from 'react';
import Box from '@mui/material/Box';
import { styled } from '@mui/material/styles';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import Drawer from '@mui/material/Drawer';
import MuiAppBar, { AppBarProps as MuiAppBarProps } from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Divider from '@mui/material/Divider';
import CssBaseline from '@mui/material/CssBaseline';
import IconButton from '@mui/material/IconButton';
import Fullscreen from '@mui/icons-material/Fullscreen';
import FullscreenExit from '@mui/icons-material/FullscreenExit';
import MonacoEditor from "react-monaco-editor";
import FileTree, { TreeDataType, TreeMenuEvent } from "./FileTree";
import FileTabBar, { TabMenuEvent } from './FileTabBar';
import * as Path from './Path';
import Post from './Post';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import { Alert, AlertColor, Button, Collapse, DialogActions, DialogContent, DialogContentText, InputAdornment, TextField } from '@mui/material';
import NewFileDialog, { DoraFileType } from './NewFileDialog';
import logo from './logo.svg';
import DoraUpload from './Upload';
import Stack from '@mui/system/Stack';
import { TransitionGroup } from 'react-transition-group';
import * as monaco from 'monaco-editor';
import * as yuescript from './languages/yuescript';
import * as teal from './languages/teal';

monaco.editor.defineTheme("dora-dark", {
	base: "vs-dark",
	inherit: true,
	rules: [
		{
			token: "invalid",
			foreground: "f44747",
			fontStyle: 'italic',
		},
		{
			token: "self.call",
			foreground: "dcdcaa",
		},
		{
			token: "operator",
			foreground: "cc76d1",
		}
	],
	colors: {},
})
monaco.languages.register({id: 'tl'});
monaco.languages.setLanguageConfiguration("tl", teal.config);
monaco.languages.setMonarchTokensProvider("tl", teal.language);
monaco.languages.registerCompletionItemProvider("tl", {
	triggerCharacters: [".", ":"],
	provideCompletionItems: function(model, position) {
		const line: string = model.getValueInRange({
			startLineNumber: position.lineNumber,
			startColumn: 1,
			endLineNumber: position.lineNumber,
			endColumn: position.column,
		});
		const word = model.getWordUntilPosition(position);
		const range: monaco.IRange = {
			startLineNumber: position.lineNumber,
			endLineNumber: position.lineNumber,
			startColumn: word.startColumn,
			endColumn: word.endColumn,
		};
		return Post("/complete", {lang: "tl", line, row: position.lineNumber, content: model.getValue()}).then((res: {success: boolean, suggestions?: [string, string, boolean][]}) => {
			if (!res.success) return {suggestions:[]};
			if (res.suggestions === undefined) return {suggestions:[]};
			return {
				suggestions: res.suggestions.map((item) => {
					const [name, desc, func] = item;
					return {
						label: name,
						kind: func ?
							monaco.languages.CompletionItemKind.Function :
							monaco.languages.CompletionItemKind.Variable,
						document: desc,
						detail: desc,
						insertText: name,
						range: range,
					};
				}),
			};
		});
	},
});
interface TealInfered {
	desc: string;
	file: string;
	row: number;
	col: number;
	key?: string;
};
monaco.languages.registerHoverProvider("tl", {
	provideHover: function(model, position) {
		const word = model.getWordAtPosition(position);
		if (word === null) return {contents:[]};
		const line: string = model.getValueInRange({
			startLineNumber: position.lineNumber,
			startColumn: 1,
			endLineNumber: position.lineNumber,
			endColumn: word.endColumn,
		});
		return Post("/infer", {
			lang: "tl", line,
			row: position.lineNumber,
			content: model.getValue()
		}).then(function (res: {success: boolean, infered?: TealInfered}) {
			if (!res.success) return {contents:[]};
			if (res.infered === undefined) return {contents:[]};
			const contents = [
				{
					value: "```\n" + res.infered.desc + "\n```",
				},
			];
			if (res.infered.row !== 0 && res.infered.col !== 0) {
				if (res.infered.file === "") {
					res.infered.file = "current file";
				}
				contents.push({
					value: `${res.infered.file}:${res.infered.row}:${res.infered.col}`
				});
			}
			return {
				range: new monaco.Range(
					position.lineNumber,
					word.startColumn,
					position.lineNumber,
					word.endColumn
				),
				contents,
			};
		});
	},
});

monaco.languages.register({ id: 'yue' });
monaco.languages.setLanguageConfiguration("yue", yuescript.config);
monaco.languages.setMonarchTokensProvider("yue", yuescript.language);

let lastEditorActionTime = Date.now();

let path = Path.posix;

document.addEventListener("contextmenu", (event) => {
	event.preventDefault();
});

let contentModified = false;

window.onbeforeunload = (event: BeforeUnloadEvent) => {
	if (contentModified) {
		event.returnValue = "Please save before leaving!";
		return "Please save before leaving!";
	}
};

const theme = createTheme({
	palette: {
		background: {
			default: '#3a3a3a',
			paper: '#2a2a2a',
		},
		primary: {
			main: '#fff',
		},
		secondary: {
			main: '#fffa',
		},
		text: {
			primary: '#fff',
			secondary: '#fffa',
		},
		action: {
			hover: '#fbc40066',
			focus: '#fbc40044',
			active: '#fbc40022',
		}
	}
});

const drawerWidth = 240;

const Main = styled('main', { shouldForwardProp: (prop) => prop !== 'open' })<{
	open?: boolean;
}>(({ theme, open }) => ({
	flexGrow: 1,
	padding: theme.spacing(0),
	transition: theme.transitions.create('margin', {
		easing: theme.transitions.easing.sharp,
		duration: theme.transitions.duration.leavingScreen,
	}),
	marginLeft: `-${drawerWidth}px`,
	...(open && {
		transition: theme.transitions.create('margin', {
			easing: theme.transitions.easing.easeOut,
			duration: theme.transitions.duration.enteringScreen,
		}),
		marginLeft: 0,
	}),
}));

const StyledStack = styled(Stack, { shouldForwardProp: (prop) => prop !== 'open' })<{
	open?: boolean;
}>(({ theme, open }) => ({
	width: '350px',
	bottom: 5,
	flexGrow: 1,
	position: 'fixed',
	padding: theme.spacing(0),
	transition: theme.transitions.create('left', {
		easing: theme.transitions.easing.sharp,
		duration: theme.transitions.duration.leavingScreen,
	}),
	left: 5,
	...(open && {
		transition: theme.transitions.create('left', {
			easing: theme.transitions.easing.easeOut,
			duration: theme.transitions.duration.enteringScreen,
		}),
		left: drawerWidth + 5,
	}),
}));

interface AppBarProps extends MuiAppBarProps {
	open?: boolean;
}

const AppBar = styled(MuiAppBar, {
	shouldForwardProp: (prop) => prop !== 'open',
})<AppBarProps>(({ theme, open }) => ({
	transition: theme.transitions.create(['margin', 'width'], {
		easing: theme.transitions.easing.sharp,
		duration: theme.transitions.duration.leavingScreen,
	}),
	...(open && {
		width: `calc(100% - ${drawerWidth}px)`,
		marginLeft: `${drawerWidth}px`,
		transition: theme.transitions.create(['margin', 'width'], {
			easing: theme.transitions.easing.easeOut,
			duration: theme.transitions.duration.enteringScreen,
		}),
	}),
}));

const DrawerHeader = styled('div')(({ theme }) => ({
	display: 'flex',
	alignItems: 'center',
	padding: theme.spacing(0),
	...theme.mixins.toolbar,
	justifyContent: 'flex-end',
}));

interface EditingFile {
	key: string;
	title: string;
	content: string;
	contentModified: string | null;
	uploading: boolean;
	editor?: monaco.editor.IStandaloneCodeEditor;
	position?: monaco.IPosition;
};

interface EditingTab {
	key: string;
	title: string;
	modified: boolean;
};

interface Modified {
	key: string;
	content: string;
};

export default function PersistentDrawerLeft() {
	const [alerts, setAlerts] = useState<{
		msg: string,
		key: string,
		type: AlertColor,
	}[]>([]);
	const [drawerOpen, setDrawerOpen] = useState(true);
	const [tabIndex, setTabIndex] = useState<number | null>(null);
	const [files, setFiles] = useState<EditingFile[]>([]);
	const [tabs, setTabs] = useState<EditingTab[]>([]);
	const [modified, setModified] = useState<Modified | null>(null);

	const [treeData, setTreeData] = useState<TreeDataType[]>([]);
	const [expandedKeys, setExpandedKeys] = useState<string[]>([]);
	const [selectedKeys, setSelectedKeys] = useState<string[]>([]);

	const [openNewFile, setOpenNewFile] = useState<TreeDataType | null>(null);

	const [popupInfo, setPopupInfo] = useState<
		{
			title: string,
			msg: string,
			cancelable?: boolean,
			confirmed?: () => void,
		} | null>(null);

	const [fileInfo, setFileInfo] = useState<
		{
			title: "New File" | "New Folder" | "Rename",
			node?: TreeDataType,
			name: string,
			ext: string,
		} | null>(null);

	const [jumpToFile, setJumpToFile] = useState<{
		key: string,
		title: string,
		row: number,
		col: number
	}| null>(null);

	const addAlert = (msg: string, type: AlertColor) => {
		const key = msg + Date.now().toString();
		alerts.push({
			msg,
			key,
			type
		});
		setAlerts([...alerts]);
		setTimeout(() => {
			setAlerts((prevState) => {
				return prevState.filter(a => a.key !== key);
			});
		}, 5000);
	};

	const loadAssets = () => {
		return Post('/assets').then((res: TreeDataType) => {
			res.root = true;
			if (res.children === undefined) {
				res.children = [{
					key: '...',
					dir: false,
					title: '...',
				}];
			}
			setTreeData([res]);
			return res;
		}).catch(() => {
			addAlert("failed to read assets", "error");
			return null;
		});
	};

	useEffect(() => {
		Post("/info").then((res: {platform: "Windows" | "macOS" | "iOS" | "Android" | "Linux"}) => {
			if (res.platform === "Windows") {
				path = Path.win32;
			}
		}).catch(() => {
			addAlert("failed to get basic info", "error");
		}).then(() => {
			return loadAssets();
		}).then((res) => {
			if (res !== null) {
				setExpandedKeys([res.key]);
			}
		});
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	contentModified = tabs.find(tab => tab.modified) !== undefined;

	const updateTabs = (targetFiles: EditingFile[]) => {
		setTabs(targetFiles.map((file) => (
			{
				key: file.key,
				title: file.title,
				modified: file.contentModified !== null
			}
		)));
	};

	if (modified !== null) {
		setModified(null);
		files.forEach(file => {
			if (file.key === modified.key) {
				file.contentModified = modified.content;
			}
		});
		updateTabs(files);
	}

	const handleDrawerOpen = () => {
		setDrawerOpen(!drawerOpen);
	};

	const handleChange = (newValue: number) => {
		setTabIndex(newValue);
	};

	const openFileInTab = (key: string, title: string, position?: monaco.IPosition) => {
		let index: number | null = null;
		const file = files.find((file, i) => {
			if (file.key === key) {
				index = i;
				return true;
			}
			return false;
		});
		if (file && file.editor && position) {
			const editor = file.editor;
			setTimeout(() => {
				editor.focus();
				editor.setPosition(position);
				editor.revealPositionInCenter(position);
			}, 100);
		}
		if (index === null) {
			Post('/read', {path: key}).then((res: {content: string, success: boolean}) => {
				if (res.success) {
					files.push({
						key,
						title,
						content: res.content,
						contentModified: null,
						uploading: false,
						position,
					});
					setFiles(files);
					updateTabs(files);
					setTabIndex(files.length - 1);
				}
			});
		} else {
			setTabIndex(index);
		}
	};

	if (jumpToFile !== null) {
		setJumpToFile(null);
		openFileInTab(jumpToFile.key, jumpToFile.title, {
			lineNumber: jumpToFile.row,
			column: jumpToFile.col
		});
	}

	const onSelect = (nodes: TreeDataType[]) => {
		setSelectedKeys(nodes.map(n => n.key));
		if (nodes.length === 0) return;
		const {key, title} = nodes[0];
		const ext = path.extname(title);
		switch (ext.toLowerCase()) {
			case ".lua":
			case ".tl":
			case ".yue":
			case ".xml":
			case ".md": {
				openFileInTab(key, title);
				break;
			}
			default:
				break
		}
	};

	const onExpand = (keys: string[]) => {
		const rootNode = treeData.at(0);
		if (rootNode === undefined) return;
		let changedKey: string | undefined = undefined;
		if (expandedKeys.length > keys.length) {
			changedKey = expandedKeys.filter(ek => (keys.find(k => k === ek) === undefined)).at(0);
		} else {
			changedKey = keys.filter(k => (expandedKeys.find(ek => ek === k) === undefined)).at(0);
		}
		if (changedKey === rootNode.key) {
			if (contentModified) {
				addAlert("please save before reloading assets", "warning");
				return;
			}
			loadAssets().then(() => {
				setFiles([]);
				setTabs([]);
				setTabIndex(null);
				setSelectedKeys([]);
				addAlert("assets reloaded", "success");
			}).catch(() => {
				addAlert("failed to reload assets", "error");
			});
			return;
		} else if (rootNode.children?.at(0)?.key === '...') {
			setExpandedKeys([]);
			return;
		}
		setExpandedKeys(keys);
	};

	const saveCurrentTab = () => {
		if (tabIndex === null) return;
		const file = files[tabIndex];
		if (file.contentModified !== null) {
			Post("/write", {path: file.key, content: file.contentModified}).then((res: {success: boolean}) => {
				if (res.success) {
					file.contentModified = null;
					updateTabs(files);
				}
			});
		}
	};

	const saveAllTabs = () => {
		const filesToSave: number[] = [];
		files.forEach((file, index) => {
			if (file.contentModified !== null) {
				filesToSave.push(index);
			}
		});
		filesToSave.forEach(index => {
			const file = files[index];
			if (file.contentModified !== null) {
				Post("/write", {path: file.key, content: file.contentModified}).then((res: {success: boolean}) => {
					if (res.success) {
						file.contentModified = null;
						updateTabs(files);
					}
				});
			}
		})
	};

	const closeCurrentTab = () => {
		if (tabIndex !== null) {
			const closeTab = () => {
				const newFiles = files.filter((_, index) => index !== tabIndex);
				setFiles(newFiles);
				updateTabs(newFiles);
				if (newFiles.length === 0) {
					setTabIndex(null);
				} else if (tabIndex > 0) {
					setTabIndex(tabIndex - 1);
				}
			};
			if (files[tabIndex].contentModified !== null) {
				setPopupInfo({
					title: "Closing Tab",
					msg: "close tab without saving",
					cancelable: true,
					confirmed: closeTab,
				});
				return;
			}
			closeTab();
		}
	};

	const closeAllTabs = () => {
		const closeTabs = () => {
			setFiles([]);
			updateTabs([]);
			setTabIndex(null);
		};
		if (contentModified) {
			setPopupInfo({
				title: "Closing Tabs",
				msg: "close tabs without saving",
				cancelable: true,
				confirmed: closeTabs,
			});
			return;
		}
		closeTabs();
	};

	const closeOtherTabs = () => {
		const closeTabs = () => {
			const newFiles = files.filter((_, index) => index === tabIndex);
			setFiles(newFiles);
			updateTabs(newFiles);
			setTabIndex(0);
		};
		const otherModified = files.filter((_, index) => index !== tabIndex).find((file) => file.contentModified !== null) !== undefined;
		if (otherModified) {
			setPopupInfo({
				title: "Closing Tabs",
				msg: "close tabs without saving",
				cancelable: true,
				confirmed: closeTabs,
			});
			return;
		}
		closeTabs();
	};

	const onKeyDown = (event: React.KeyboardEvent) => {
		if (event.metaKey || event.ctrlKey) {
			switch (event.key) {
				case 's': {
					event.preventDefault();
					if (event.shiftKey) {
						saveAllTabs();
					} else {
						saveCurrentTab();
					}
					break;
				}
				case 'w': {
					event.preventDefault();
					closeCurrentTab();
					break;
				}
			}
		}
	};

	const handleAlertClose = () => {
		if (popupInfo?.confirmed !== undefined) {
			popupInfo.confirmed();
		}
		setPopupInfo(null);
	};

	const handleAlertCancel = () => {
		setPopupInfo(null);
	};

	const onTabMenuClick = (event: TabMenuEvent) => {
		switch (event) {
			case "Save": saveCurrentTab(); break;
			case "SaveAll": saveAllTabs(); break;
			case "Close": closeCurrentTab(); break;
			case "CloseAll": closeAllTabs(); break;
			case "CloseOther": closeOtherTabs(); break;
		}
	};

	const onTreeMenuClick = (event: TreeMenuEvent, data?: TreeDataType)=> {
		switch (event) {
			case "New": {
				if (data === undefined) break;
				setOpenNewFile(data);
				break;
			}
			case "Upload": {
				if (data === undefined) break;
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				let {key, title} = data;
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
					setTabIndex(index);
					break;
				}
				files.push({
					key,
					title,
					content: "",
					contentModified: null,
					uploading: true,
				});
				setFiles(files);
				updateTabs(files);
				setTabIndex(files.length - 1);
				break;
			}
			case "Rename": {
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				if (rootNode.key === data?.key) {
					addAlert("can not rename root folder", "info");
					break;
				}
				if (data !== undefined) {
					const ext = path.extname(data.title).toLowerCase();
					const name = path.basename(data.title, ext);
					setFileInfo({
						title: "Rename",
						node: data,
						name,
						ext,
					});
				}
				break;
			}
			case "Delete": {
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				if (rootNode.key === data?.key) {
					addAlert("can not delete root folder", "info");
					break;
				}
				if (data !== undefined) {
					setPopupInfo({
						title: "Delete",
						msg: `deleting ${data.dir ? 'folder' : 'file'} ${data.title}`,
						cancelable: true,
						confirmed: () => {
							Post("/delete", {path: data.key}).then((res: {success: boolean}) => {
								if (!res.success) return;
								const visitData = (node: TreeDataType) => {
									if (node.key === data.key) return "find";
									if (node.children) {
										for (let i = 0; i < node.children.length; i++) {
											const res = visitData(node.children[i]);
											if (res === "find") {
												node.children = node.children?.filter(n => n.key !== data.key);
												return "stop";
											} else if (res === "stop") {
												return "stop";
											}
										}
									}
									return "continue";
								};
								visitData(rootNode);
								if (rootNode.children && rootNode.children.length === 0) {
									rootNode.children = [{
										key: '...',
										dir: false,
										title: '...',
									}];
									setExpandedKeys([]);
								}
								if (files.find(f => f.key === data.key) !== undefined) {
									setFiles(files.filter(f => f.key !== data.key));
									const newTabs = tabs.filter(t => t.key !== data.key);
									setTabs(newTabs);
									if (tabIndex !== null && tabIndex >= newTabs.length) {
										setTabIndex(newTabs.length - 1);
									}
								}
								setTreeData([rootNode]);
							}).catch(() => {
								addAlert("failed to delete item", "error");
							}).then(() => {
								addAlert(`deleted "${data.title}"`, "success");
							});
						},
					})
				}
				break;
			}
		}
	};

	const onNewFileClose = (item?: DoraFileType) => {
		let ext: string | null = null;
		switch (item) {
			case "Lua": ext = ".lua"; break;
			case "Teal": ext = ".tl"; break;
			case "Yuescript": ext = ".yue"; break;
			case "Dora Xml": ext = ".xml"; break;
			case "Folder": ext = ""; break;
		}
		if (ext !== null) {
			setFileInfo({
				title: ext === "" ? "New Folder" : "New File",
				node: openNewFile !== null ? openNewFile : undefined,
				name: "",
				ext
			});
		}
		setOpenNewFile(null);
	};

	const handleFilenameClose = () => {
		if (fileInfo && fileInfo.node !== undefined) {
			const target = fileInfo.node;
			if (fileInfo.title === "Rename") {
				const newName = fileInfo.name + fileInfo.ext;
				if (newName === target.title) {
					setFileInfo(null);
					return;
				}
				const oldFile = target.key;
				const newFile = path.join(path.dirname(target.key), newName);
				const doRename = () => {
					return Post("/rename", {old: oldFile, new: newFile}).then((res: {success: boolean}) => {
						if (!res.success) {
							addAlert("failed to rename item", "error");
							return;
						}
						if (target.dir) {
							return loadAssets();
						}
						const file = files.find(f => path.relative(f.key, oldFile) === "");
						if (file !== undefined) {
							file.key = newFile;
							file.title = newName;
							setFiles([...files]);
							const tab = tabs.find(t => path.relative(t.key, oldFile) === "");
							if (tab !== undefined) {
								tab.key = newFile;
								tab.title = newName;
								setTabs([...tabs]);
							}
						}
						const rootNode = treeData.at(0);
						if (rootNode === undefined) return;
						const visitData = (node: TreeDataType) => {
							if (node.key === target.key) {
								node.key = newFile;
								node.title = newName;
								return true;
							}
							if (node.children) {
								for (let i = 0; i < node.children.length; i++) {
									if (visitData(node.children[i])) {
										return true;
									}
								}
							}
							return false;
						};
						visitData(rootNode);
						setTreeData([rootNode]);
					}).catch(() => {
						addAlert("failed to rename item", "error");
					}).then(() => {
						addAlert(`renamed "${path.basename(oldFile)}" to "${path.basename(newFile)}"`, "success");
					});
				};
				if (target.dir) {
					updateDir(oldFile, newFile).then((res) => {
						doRename().then(() => {
							if (res === undefined) return;
							setFiles(res.newFiles);
							updateTabs(res.newFiles);
							setExpandedKeys(res.newExpanded);
						});
					});
				} else {
					doRename();
				}
			} else {
				const dir = target.dir ?
					target.key : path.dirname(target.key);
				const {ext} = fileInfo;
				const newName = fileInfo.name + fileInfo.ext;
				const newFile = path.join(dir, newName);
				Post("/new", {path: newFile}).then((res: {success: boolean}) => {
					if (!res.success) {
						addAlert("failed to create item", "error");
						return;
					}
					const rootNode = treeData.at(0);
					if (rootNode === undefined) return;
					const visitData = (node: TreeDataType) => {
						if (node.key === target.key) return "find";
						if (node.children) {
							for (let i = 0; i < node.children.length; i++) {
								const res = visitData(node.children[i]);
								if (res === "find") {
									const child = node.children[i];
									let parent = child;
									if (child.dir) {
										if (child.children === undefined) {
											child.children = [];
										}
										child.children.push({
											key: newFile,
											title: newName,
											dir: ext === "",
										});
									} else {
										parent = node;
										node.children.push({
											key: newFile,
											title: newName,
											dir: ext === "",
										});
									}
									if (expandedKeys.find(k => parent.key === k) === undefined) {
										expandedKeys.push(parent.key);
										setExpandedKeys(expandedKeys);
									}
									return "stop";
								} else if (res === "stop") {
									return "stop";
								}
							}
						}
						return "continue";
					};
					if (visitData(rootNode) === "find") {
						if (rootNode.children === undefined) {
							rootNode.children = [];
						}
						rootNode.children.push({
							key: newFile,
							title: newName,
							dir: ext === "",
						});
						if (expandedKeys.find(k => rootNode.key === k) === undefined) {
							expandedKeys.push(rootNode.key);
							setExpandedKeys(expandedKeys);
						}
					}
					if (rootNode && rootNode.children?.at(0)?.key === '...') {
						rootNode.children?.splice(0, 1);
						setExpandedKeys([...expandedKeys]);
					}
					setTreeData([rootNode]);
					setSelectedKeys([newFile]);
					if (ext !== '') {
						files.push({
							key: newFile,
							title: newName,
							content: "",
							contentModified: null,
							uploading: false,
						});
						setFiles(files);
						updateTabs(files);
						setTabIndex(files.length - 1);
					}
				}).catch(() => {
					addAlert("failed to create item", "error");
				});;
			}
		}
		setFileInfo(null);
	};

	const onFilenameChange = (event: ChangeEvent<HTMLTextAreaElement | HTMLInputElement>) => {
		if (fileInfo) {
			fileInfo.name = event.target.value;
			setFileInfo(fileInfo);
		}
	};

	const handleFilenameCancel = () => {
		setFileInfo(null);
	};

	const updateDir = (oldDir: string, newDir: string) => {
		return Post("/list", {path: oldDir}).then((res: {success: boolean, files: string[]}) => {
			if (res.success) {
				const affected = res.files.map(f => [path.join(oldDir, f), path.join(newDir, f)]);
				affected.push([oldDir, newDir]);
				const newFiles = files.map(f => {
					affected.some(x => {
						if (x[0] === f.key) {
							f.key = x[1];
							if (f.uploading) {
								f.title = path.basename(f.key);
							}
							if (f.contentModified !== null) {
								f.content = f.contentModified;
							}
							return true;
						}
						return false;
					});
					return f;
				});
				const newExpanded = expandedKeys.map(k => {
					const it = affected.find(x => {
						if (x[0] === k) {
							return true;
						}
						return false;
					});
					if (it !== undefined) {
						return it[1];
					}
					return k;
				});
				return {newFiles, newExpanded};
			}
		});
	};

	const onDrop = (self: TreeDataType, target: TreeDataType) => {
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
			title: 'Moving Item',
			msg: `move "${self.title}" to folder "${targetName}"`,
			cancelable: true,
			confirmed: () => {
				const newFile = path.join(targetParent, path.basename(self.key));
				const doRename = () => {
					return Post("/rename", {old: self.key, new: newFile}).then((res: {success: boolean}) => {
						if (res.success) {
							return loadAssets();
						}
						addAlert(`failed to move "${self.title}" to folder "${targetName}"`, "error");
					});
				};
				if (self.dir) {
					updateDir(self.key, newFile).then((res) => {
						if (res === undefined) return;
						doRename().then(() => {
							setFiles(res.newFiles);
							updateTabs(res.newFiles);
							setExpandedKeys(res.newExpanded);
						});
					});
				} else {
					doRename().then(() => {
						setExpandedKeys(expandedKeys.filter(k => k !== self.key));
					});
				}
			}
		});
	};

	const onUploaded = (dir: string, file: string) => {
		const key = path.join(dir, file);
		const newFiles = files.filter(f => path.relative(f.key, key) !== "");
		if (file.length !== newFiles.length) {
			setFiles(newFiles);
			updateTabs(newFiles);
			if (tabIndex && tabIndex > newFiles.length) {
				const newIndex = newFiles.length > 0 ? newFiles.length - 1 : null;
				setTabIndex(newIndex);
			}
		}
		loadAssets();
	};

	type TealError = "parsing" | "syntax" | "type" | "warning" | "crash";

	const onEditorDidMount = (file: EditingFile) => (editor: monaco.editor.IStandaloneCodeEditor) => {
		file.editor = editor;
		if (file.position) {
			const position = file.position;
			setTimeout(() => {
				editor.focus();
				editor.setPosition(position);
				editor.revealPositionInCenter(position);
			}, 100);
			file.position = undefined;
		}
		setFiles([...files]);
		editor.addAction({
			id: "dora-action-definition",
			label: "Go to Definition",
			keybindings: [
				monaco.KeyCode.F12 | monaco.KeyMod.CtrlCmd,
				monaco.KeyCode.F12 | monaco.KeyMod.WinCtrl,
			],
			contextMenuGroupId: "navigation",
			contextMenuOrder: 1.5,
			run: function(ed) {
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
				Post("/infer", {
					lang: "tl", line,
					row: position.lineNumber,
					content: model.getValue()
				}).then(function(res: {success: boolean, infered?: TealInfered}) {
					if (!res.success) return;
					if (!res.infered) return;
					if (res.infered.key !== undefined) {
						setJumpToFile({
							key: res.infered.key,
							title: path.basename(res.infered.file),
							row: res.infered.row,
							col: res.infered.col,
						});
					} else {
						const pos = {
							lineNumber: res.infered.row,
							column: res.infered.col,
						};
						editor.setPosition(pos);
						editor.revealPositionInCenterIfOutsideViewport(pos);
					}
				});
			},
		});
		const model = editor.getModel();
		if (model) {
			model.onDidChangeContent((e) => {
				lastEditorActionTime = Date.now();
				const modified = model.getValue();
				const lastChange = e.changes.at(-1);
				let key: string | null = null;
				if (tabIndex !== null) {
					key = files[tabIndex].key;
				}
				new Promise((resolve) => {
					setTimeout(resolve, 500);
				}).then(() => {
					if (Date.now() - lastEditorActionTime >= 500) {
						if (key !== null) {
							return Post("/check", {file: key, content: modified});
						}
					}
				}).then((res?: {
					success: boolean,
					info?: [TealError, string, number, number, string][]
				}) => {
					if (res === undefined) return;
					const markers: monaco.editor.IMarkerData[] = [];
					if (!res.success && res.info !== undefined) {
						for (let i = 0; i < res.info.length; i++) {
							const [errType, filename, row, col, msg] = res.info[i];
							if (key === null || !path.isAbsolute(filename) || path.relative(filename, key) !== "") continue;
							switch (errType) {
								case "parsing":
								case "syntax":
								case "type":
									markers.push({
										severity: monaco.MarkerSeverity.Error,
										message: msg,
										startLineNumber: row,
										startColumn: col,
										endLineNumber: row,
										endColumn: col,
									});
									break;
								case "warning":
									markers.push({
										severity: monaco.MarkerSeverity.Warning,
										message: msg,
										startLineNumber: row,
										startColumn: col,
										endLineNumber: row,
										endColumn: col,
									});
									break;
								case "crash":
									if (lastChange !== undefined) {
										markers.push({
											severity: monaco.MarkerSeverity.Error,
											message: "compiler crashes",
											startLineNumber: lastChange.range.startLineNumber,
											startColumn: lastChange.range.startColumn,
											endLineNumber: lastChange.range.endLineNumber,
											endColumn: lastChange.range.endColumn,
										});
									}
									break;
								default:
									break;
							}
						}
					}
					monaco.editor.setModelMarkers(model, "owner", markers);
				});
			});
		}
	};

	return (
		<ThemeProvider theme={theme}>
			<Dialog
				open={popupInfo !== null}
				aria-labelledby="alert-dialog-title"
				aria-describedby="alert-dialog-description"
			>
				<DialogTitle id="alert-dialog-title">
					{popupInfo?.title}
				</DialogTitle>
				<DialogContent>
					<DialogContentText id="alert-dialog-description">
						{popupInfo?.msg}
					</DialogContentText>
				</DialogContent>
				<DialogActions>
					<Button
						onClick={handleAlertClose}
						autoFocus={popupInfo?.cancelable === undefined}
					>
						{popupInfo?.cancelable !== undefined ?
							"Confirm" : "OK"
						}
					</Button>
					{popupInfo?.cancelable !== undefined ?
						<Button onClick={handleAlertCancel}>
							Cancel
						</Button> : null
					}
				</DialogActions>
			</Dialog>
			<Dialog
				open={fileInfo !== null}
				aria-labelledby="filename-dialog-title"
				aria-describedby="filename-dialog-description"
			>
				<DialogTitle id="filename-dialog-title">
					{fileInfo?.title}
				</DialogTitle>
				<DialogContent>
					<TextField
						label={(
							fileInfo?.title === "New File" ?
								"Enter a file name" : undefined
							) ?? (
							fileInfo?.title === "New Folder" ?
								"Enter a folder name" : undefined
							)
						}
						defaultValue={fileInfo?.name ?? ""}
						id="filename-adornment"
						sx={{
							m: 1,
							width: '25ch',
							"& .MuiOutlinedInput-notchedOutline": {
								borderColor: '#fffa',
							}
						}}
						InputProps={{
							endAdornment:
								<InputAdornment position="end">
									{fileInfo?.ext}
								</InputAdornment>,
						}}
						onChange={onFilenameChange}
					/>
				</DialogContent>
				<DialogActions>
					<Button onClick={handleFilenameClose}>
						OK
					</Button>
					<Button onClick={handleFilenameCancel}>
						Cancel
					</Button>
				</DialogActions>
			</Dialog>
			<NewFileDialog open={openNewFile !== null} onClose={onNewFileClose}/>
			<Box sx={{display: "flex", width: '100%', height: '100%'}} onKeyDown={onKeyDown}>
				<CssBaseline/>
				<AppBar
					position="fixed"
					open={drawerOpen}
				>
					<Toolbar style={{
						backgroundColor: "#2a2a2a",
						width: "100%",
						height: "30px",
						color: "#fff"
					}}>
						<IconButton
							color="inherit"
							aria-label="open drawer"
							onClick={handleDrawerOpen}
							edge="start"
						>
							{ drawerOpen ? <Fullscreen/> : <FullscreenExit/> }
						</IconButton>
						<FileTabBar
							index={tabIndex}
							items={tabs}
							onChange={handleChange}
							onMenuClick={onTabMenuClick}
						/>
					</Toolbar>
				</AppBar>
				<Drawer
					sx={{
						width: drawerWidth,
						flexShrink: 0,
						'& .MuiDrawer-paper': {
							width: drawerWidth,
							boxSizing: 'border-box',
						},
					}}
					variant="persistent"
					anchor="left"
					open={drawerOpen}
				>
					<img src={logo} alt="logo"
						width="100%" height="200px"
						style={{
							padding: "20px",
							alignItems: "center"
						}}
					/>
					<Divider style={{backgroundColor:'#fff2'}}/>
					<FileTree
						selectedKeys={selectedKeys}
						expandedKeys={expandedKeys}
						treeData={treeData}
						onMenuClick={onTreeMenuClick}
						onSelect={onSelect}
						onExpand={onExpand}
						onDrop={onDrop}
					/>
				</Drawer>
				{
					files.map((file, index) => {
						const ext = path.extname(file.title);
						let language = null;
						switch (ext.toLowerCase()) {
							case ".lua": language = "lua"; break;
							case ".tl": language = "tl"; break;
							case ".yue": language = "yue"; break;
							case ".xml": language = "xml"; break;
							case ".md": language = "markdown"; break;
						}
						return <Main
							open={drawerOpen}
							key={file.key}
							hidden={tabIndex !== index}
						>
							<DrawerHeader/>
							{(() => {
								if (language) {
									let width = 0;
									if (tabIndex === index) {
										width = window.innerWidth - (drawerOpen ? drawerWidth : 0);
									}
									return (
										<MonacoEditor
											width={width}
											height={window.innerHeight - 64}
											language={language}
											theme="dora-dark"
											value={file.content}
											editorDidMount={onEditorDidMount(file)}
											onChange={(content: string) => {
												setModified({key: file.key, content});
											}}
											options={{
												wordWrap: 'on',
												wordBreak: 'keepAll',
												selectOnLineNumbers: true,
												matchBrackets: 'near',
												fontSize: 18,
												useTabStops: false,
												insertSpaces: false,
												renderWhitespace: 'all',
											}}
										/>
									);
								} else if (file.uploading) {
									const rootNode = treeData.at(0);
									if (rootNode === undefined) return null;
									let target = path.relative(rootNode.key, file.key);
									target = path.join("Assets", target);
									return (
										<div style={{width: '100%', height: '100%'}}>
											<DrawerHeader/>
											<DoraUpload onUploaded={onUploaded} title={target + path.sep} path={file.key}/>
										</div>
									);
								}
								return null;
							})()}
						</Main>
					})
				}
				<StyledStack open={drawerOpen}>
					<TransitionGroup>
						{alerts.map((item) => (
							<Collapse key={item.key}>
								<Alert onClose={() => {
									const newAlerts = alerts.filter(a => a.key !== item.key);
									setAlerts(newAlerts);
								}} severity={item.type} color={item.type} style={{margin: 5}}>
									{item.msg}
								</Alert>
							</Collapse>
						))}
					</TransitionGroup>
				</StyledStack>
			</Box>
		</ThemeProvider>
	);
}

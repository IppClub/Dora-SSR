import React, { ChangeEvent, useEffect, useState } from 'react';
import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import Toolbar from '@mui/material/Toolbar';
import Divider from '@mui/material/Divider';
import CssBaseline from '@mui/material/CssBaseline';
import IconButton from '@mui/material/IconButton';
import Fullscreen from '@mui/icons-material/Fullscreen';
import FullscreenExit from '@mui/icons-material/FullscreenExit';
import MonacoEditor, { loader } from "@monaco-editor/react";
import FileTree, { TreeDataType, TreeMenuEvent } from "./FileTree";
import FileTabBar, { TabMenuEvent, TabStatus } from './FileTabBar';
import * as Path from './Path';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import { Alert, AlertColor, Button, Collapse, DialogActions, DialogContent, DialogContentText, InputAdornment, TextField } from '@mui/material';
import NewFileDialog, { DoraFileType } from './NewFileDialog';
import logo from './logo.svg';
import DoraUpload from './Upload';
import { TransitionGroup } from 'react-transition-group';
import * as monaco from 'monaco-editor';
import * as Service from './Service';
import './Editor';
import { AppBar, DrawerHeader, drawerWidth, Entry, Main, PlayControl, PlayControlMode, StyledStack } from './Frame';
import { MacScrollbar } from 'mac-scrollbar';
import 'mac-scrollbar/dist/mac-scrollbar.css';

loader.config({ monaco });

let lastEditorActionTime = Date.now();
let lastUploadedTime = Date.now();

export let path = Path.posix;

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

interface EditingFile {
	key: string;
	title: string;
	content: string;
	contentModified: string | null;
	uploading: boolean;
	editor?: monaco.editor.IStandaloneCodeEditor;
	position?: monaco.IPosition;
	status: TabStatus;
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
	const [modified, setModified] = useState<Modified | null>(null);

	const [treeData, setTreeData] = useState<TreeDataType[]>([]);
	const [expandedKeys, setExpandedKeys] = useState<string[]>([]);
	const [selectedKeys, setSelectedKeys] = useState<string[]>([]);
	const [selectedNode, setSelectedNode] = useState<TreeDataType | null>(null);
	const [keyEvent, setKeyEvent] = useState<KeyboardEvent | null>(null);

	const [openNewFile, setOpenNewFile] = useState<TreeDataType | null>(null);

	const [popupInfo, setPopupInfo] = useState<
		{
			title: string,
			msg: string,
			raw?: boolean,
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
		setAlerts((prevState) => {
			return [...prevState, {
				msg,
				key,
				type
			}];
		});
		setTimeout(() => {
			setAlerts((prevState) => {
				return prevState.filter(a => a.key !== key);
			});
		}, 5000);
	};

	const loadAssets = () => {
		return Service.assets().then((res: TreeDataType) => {
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
			addAlert("failed to load assets", "error");
			return null;
		});
	};

	useEffect(() => {
		Service.info().then((res) => {
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
		document.addEventListener("keydown", (event: KeyboardEvent) => {
			if (event.ctrlKey || event.altKey || event.metaKey) {
				switch (event.key) {
					case 'N': case 'n':
					case 'D': case 'd':
					case 'S': case 's':
					case 'W': case 'w':
					case 'R': case 'r':
					case 'Q': case 'q': {
						event.preventDefault();
						setKeyEvent(event);
						break;
					}
				}
			}
		}, false);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	if (modified !== null) {
		setModified(null);
		files.forEach(file => {
			if (file.key === modified.key) {
				if (modified.content !== file.content) {
					file.contentModified = modified.content;
				} else {
					file.contentModified = null;
				}
			}
		});
		setFiles([...files]);
	}

	contentModified = files.find(file => file.contentModified !== null) !== undefined;

	const handleDrawerOpen = () => {
		setDrawerOpen(!drawerOpen);
	};

	const switchTab = (newValue: number | null, fileToFocus?: EditingFile) => {
		setTabIndex(newValue);
		if (newValue === null) return;
		if (fileToFocus !== undefined) {
			setTimeout(() => {
				const {editor} = fileToFocus;
				if (editor === undefined) return;
				editor.focus();
				const model = editor.getModel();
				if (model === null) return;
				checkFile(fileToFocus, fileToFocus.contentModified ?? fileToFocus.content, model);
			}, 100);
		}
	};

	const tabBarOnChange = (newValue: number) => {
		switchTab(newValue, files[newValue]);
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
			Service.read({path: key}).then((res) => {
				if (res.success && res.content !== undefined) {
					const index = files.push({
						key,
						title,
						content: res.content,
						contentModified: null,
						uploading: false,
						position,
						status: "normal",
					}) - 1;
					setFiles([...files]);
					switchTab(index, files[index]);
				}
			}).catch(() => {
				addAlert(`failed to read ${title}`, "error");
			});
		} else {
			switchTab(index, file);
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
		if (nodes.length === 0) {
			setSelectedNode(null);
			return;
		}
		const {key, title} = nodes[0];
		setSelectedNode(nodes[0]);
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
			loadAssets().then((res) => {
				if (res !== null) {
					setFiles([]);
					switchTab(null);
					setSelectedKeys([]);
					addAlert("assets reloaded", "success");
				}
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
			const {contentModified} = file;
			Service.write({path: file.key, content: contentModified}).then((res) => {
				if (res.success) {
					file.content = contentModified;
					file.contentModified = null;
					setFiles([...files]);
				} else {
					addAlert("failed to save current file", "error");
				}
			}).catch(() => {
				addAlert("failed to save current file", "error");
			});
		}
	};

	const saveAllTabs = () => {
		const filesToSave = files.filter(file => file.contentModified !== null);
		return new Promise<boolean>((resolve) => {
			const fileCount = filesToSave.length;
			if (fileCount === 0) {
				resolve(true);
				return;
			}
			let failed = false;
			let count = 0;
			filesToSave.forEach(file => {
				const content = file.contentModified;
				if (content === null) {
					count++;
					if (count === fileCount) {
						resolve(true);
					}
					return;
				}
				Service.write({path: file.key, content}).then((res) => {
					if (res.success) {
						file.content = content;
						file.contentModified = null;
						setFiles(prev => [...prev]);
						count++;
						if (count === fileCount) {
							resolve(true);
						}
					} else {
						addAlert(`failed to save ${file.title}`, "error");
						if (!failed) {
							failed = true;
							resolve(false);
						}
					}
				}).catch(() => {
					addAlert(`failed to save ${file.title}`, "error");
					if (!failed) {
						failed = true;
						resolve(false);
					}
				});
			});
		});
	};

	const closeCurrentTab = () => {
		if (tabIndex !== null) {
			const closeTab = () => {
				const newFiles = files.filter((_, index) => index !== tabIndex);
				if (newFiles.length === 0) {
					switchTab(null);
				} else if (tabIndex > 0) {
					switchTab(tabIndex - 1, newFiles[tabIndex - 1]);
				} else {
					switchTab(tabIndex, newFiles[tabIndex]);
				}
				setFiles(newFiles);
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
			switchTab(null);
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
			switchTab(0, newFiles[0]);
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
			case "CloseOthers": closeOtherTabs(); break;
		}
	};

	const deleteFile = (data: TreeDataType) => {
		const rootNode = treeData.at(0);
		if (rootNode === undefined) return;
		if (rootNode.key === data.key) {
			addAlert("can not delete root folder", "info");
			return;
		}
		setPopupInfo({
			title: "Delete",
			msg: `deleting ${data.dir ? 'folder' : 'file'} ${data.title}`,
			cancelable: true,
			confirmed: () => {
				Service.deleteFile({path: data.key}).then((res) => {
					if (!res.success) return;
					const visitData = (node: TreeDataType) => {
						if (data.key === node.key) return "find";
						if (node.children !== undefined) {
							for (let i = 0; i < node.children.length; i++) {
								const res = visitData(node.children[i]);
								if (res === "find") {
									node.children = node.children.filter(n => n.key !== data.key);
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
						const newFiles = files.filter(f => f.key !== data.key);
						setFiles(newFiles);
						if (tabIndex !== null && tabIndex >= newFiles.length) {
							switchTab(newFiles.length - 1, newFiles[newFiles.length - 1]);
						}
					}
					setTreeData([rootNode]);
				}).then(() => {
					addAlert(`deleted "${data.title}"`, "success");
				}).catch(() => {
					addAlert("failed to delete item", "error");
				});
			},
		});
	};

	const onTreeMenuClick = (event: TreeMenuEvent, data?: TreeDataType)=> {
		if (data === undefined) return;
		switch (event) {
			case "New": {
				setOpenNewFile(data);
				break;
			}
			case "Upload": {
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
					switchTab(index, file);
					break;
				}
				const index = files.push({
					key,
					title,
					content: "",
					contentModified: null,
					uploading: true,
					status: "normal",
				}) - 1;
				setFiles([...files]);
				switchTab(index, files[index]);
				break;
			}
			case "Rename": {
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				if (rootNode.key === data.key) {
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
				deleteFile(data);
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
					return Service.rename({old: oldFile, new: newFile}).then((res) => {
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
					}).then(() => {
						addAlert(`renamed "${path.basename(oldFile)}" to "${path.basename(newFile)}"`, "success");
					}).catch(() => {
						addAlert("failed to rename item", "error");
					});
				};
				if (target.dir) {
					updateDir(oldFile, newFile).then((res) => {
						doRename().then(() => {
							if (res === undefined) return;
							setFiles(res.newFiles);
							setExpandedKeys(res.newExpanded);
							setSelectedNode(null);
							setSelectedKeys([]);
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
				const {ext} = fileInfo;
				const newName = fileInfo.name + fileInfo.ext;
				const newFile = path.join(dir, newName);
				Service.newFile({path: newFile}).then((res) => {
					if (!res.success) {
						addAlert("failed to create item", "error");
						return;
					}
					const rootNode = treeData.at(0);
					if (rootNode === undefined) return;
					const newNode: TreeDataType = {
						key: newFile,
						title: newName,
						dir: ext === "",
					};
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
										child.children.push(newNode);
									} else {
										parent = node;
										node.children.push(newNode);
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
						rootNode.children.push(newNode);
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
					setSelectedNode(newNode);
					if (ext !== '') {
						const index = files.push({
							key: newFile,
							title: newName,
							content: "",
							contentModified: null,
							uploading: false,
							status: "normal",
						}) - 1;
						setFiles([...files]);
						switchTab(index, files[index]);
					}
				}).catch(() => {
					addAlert("failed to create item", "error");
				});
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
		return Service.list({path: oldDir}).then((res) => {
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
					return Service.rename({old: self.key, new: newFile}).then((res) => {
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
							setExpandedKeys(res.newExpanded);
							setSelectedNode(null);
							setSelectedKeys([]);
						});
					});
				} else {
					doRename().then(() => {
						setExpandedKeys(expandedKeys.filter(k => k !== self.key));
							setSelectedNode(null);
							setSelectedKeys([]);
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
			if (tabIndex && tabIndex > newFiles.length) {
				const newIndex = newFiles.length > 0 ? newFiles.length - 1 : null;
				if (newIndex === null) {
					switchTab(newIndex);
				} else {
					switchTab(newIndex, newFiles[newIndex]);
				}
			}
		}
		lastUploadedTime = Date.now();
		setTimeout(() => {
			if (Date.now() - lastUploadedTime >= 2000) {
				loadAssets();
			}
		}, 2000);
	};

	const checkFile = (file: EditingFile, content: string, model: monaco.editor.ITextModel, lastChange?: monaco.editor.IModelContentChange) => {
		Service.check({file: file.key, content}).then((res) => {
			let status: TabStatus = "normal";
			const markers: monaco.editor.IMarkerData[] = [];
			if (!res.success && res.info !== undefined) {
				for (let i = 0; i < res.info.length; i++) {
					const [errType, filename, row, col, msg] = res.info[i];
					if (!path.isAbsolute(filename) || path.relative(filename, file.key) !== "") continue;
					let startLineNumber = row;
					let startColumn = col;
					let endLineNumber = row;
					let endColumn = col;
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
			file.status = status;
			setFiles(prev => [...prev]);
			monaco.editor.setModelMarkers(model, "owner", markers);
		}).catch(() => {
			console.error("failed to check file");
		});
	};

	const onEditorDidMount = (file: EditingFile) => (editor: monaco.editor.IStandaloneCodeEditor) => {
		file.editor = editor;
		setTimeout(() => {
			editor.focus();
			if (file.position) {
				const position = file.position;
				editor.setPosition(position);
				editor.revealPositionInCenter(position);
				file.position = undefined;
				setFiles((prev) => [...prev]);
			}
			const model = editor.getModel();
			if (model === null) return;
			checkFile(file, model.getValue(), model);
		}, 100);
		let inferLang: "lua" | "tl" | "yue" | null = null;
		const ext = path.extname(file.key).toLowerCase().substring(1);
		switch (ext) {
			case "lua": case "tl": case "yue":
				inferLang = ext;
				break;
			default: return;
		}
		if (inferLang !== null) {
			const lang = inferLang;
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
					Service.infer({
						lang, line,
						row: position.lineNumber,
						content: model.getValue()
					}).then(function(res) {
						if (!res.success) return;
						if (!res.infered) return;
						if (res.infered.key !== undefined) {
							setJumpToFile({
								key: res.infered.key,
								title: path.basename(res.infered.file),
								row: res.infered.row,
								col: res.infered.col,
							});
						} else if (res.infered.row > 0 && res.infered.col > 0) {
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
		}
		const model = editor.getModel();
		if (model) {
			model.onDidChangeContent((e) => {
				switch (path.extname(file.key).toLowerCase()) {
					case ".lua": case ".tl": case ".yue": break;
					default: return;
				}
				lastEditorActionTime = Date.now();
				const modified = model.getValue();
				const lastChange = e.changes.at(-1);
				new Promise((resolve) => {
					setTimeout(resolve, 500);
				}).then(() => {
					if (Date.now() - lastEditorActionTime >= 500) {
						checkFile(file, modified, model, lastChange);
					}
				});
			});
		}
	};

	const onStopRunning = () => {
		Service.stop().then((res) => {
			if (res.success) {
				addAlert("stopped running", "success");
			} else {
				addAlert("nothing to stop", "info");
			}
		}).catch(() => {
			addAlert("failed to stop running", "error");
		});
	};

	const onPlayControlClick = (mode: PlayControlMode) => {
		switch (mode) {
			case "Run": case "Run This": {
				if (selectedNode === null) {
					addAlert("please select a file to run", "info");
					return;
				}
				let file = selectedNode.key;
				let asProj = mode === "Run";
				if (selectedNode.dir) {
					file = path.join(file, "init.lua");
					asProj = true;
				}
				const ext = path.extname(file).toLowerCase();
				switch (ext) {
					case ".lua":
					case ".yue":
					case ".tl":
					case ".xml":
						Service.run({file, asProj}).then((res) => {
							if (res.success) {
								addAlert(`${res.target ?? selectedNode.title} is running`, "success");
							} else {
								addAlert(`failed to run ${res.target ?? selectedNode.title}`, "error");
							}
							if (res.err !== undefined) {
								setPopupInfo({
									title: res.target ?? selectedNode.title,
									msg: res.err,
									raw: true
								});
							}
						}).catch(() => {
							addAlert(`failed to run from ${selectedNode.title}`, "error");
						})
						break;
					default:
						addAlert(`can not run from ${selectedNode.title}`, "info");
						break;
				}
				break;
			}
			case "Stop": {
				onStopRunning();
				break;
			}
		}
	};

	const onKeyDown = (event: KeyboardEvent) => {
		if (event.ctrlKey || event.altKey || event.metaKey) {
			switch (event.key) {
				case 'N': case 'n': {
					if (!event.shiftKey) break;
					if (selectedNode === null) {
						addAlert("select a file tree node before creating new file", "info");
						break;
					}
					setOpenNewFile(selectedNode);
					break;
				}
				case 'D': case 'd': {
					if (!event.shiftKey) break;
					if (selectedNode === null) {
						addAlert("select a file tree node to delete", "info");
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
					saveAllTabs().then((success) => {
						if (success) {
							onPlayControlClick(shift ? "Run This" : "Run");
						}
					})
					break;
				}
				case 'Q': case 'q': {
					onStopRunning();
					break;
				}
			}
		}
	};

	if (keyEvent !== null) {
		setKeyEvent(null);
		onKeyDown(keyEvent);
	}

	return (
		<Entry>
			<Dialog
				maxWidth="lg"
				open={popupInfo !== null}
				aria-labelledby="alert-dialog-title"
				aria-describedby="alert-dialog-description"
			>
				<DialogTitle id="alert-dialog-title">
					{popupInfo?.title}
				</DialogTitle>
				<MacScrollbar skin='dark'>
					<DialogContent>
						<DialogContentText
							component="span"
							id="alert-dialog-description"
						>
							{popupInfo?.raw ?
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
						autoFocus
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
			<Box sx={{display: "flex", width: '100%', height: '100%'}}>
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
							items={files}
							onChange={tabBarOnChange}
							onMenuClick={onTabMenuClick}
						/>
					</Toolbar>
				</AppBar>
				<Drawer
					sx={{
						zIndex: 1,
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
					<img
						src={logo}
						alt="logo"
						width="100%"
						height="200px"
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
											defaultValue={file.content}
											onMount={onEditorDidMount(file)}
											loading={<div style={{width: '100%', height: '100%', backgroundColor:'#1a1a1a'}}/>}
											onChange={(content: string | undefined) => {
												if (content === undefined) return;
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
				<PlayControl onClick={onPlayControlClick}/>
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
		</Entry>
	);
}

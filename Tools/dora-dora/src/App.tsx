/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { ChangeEvent, Suspense, memo, useCallback, useEffect, useState } from 'react';
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
import Info from './Info';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import { Alert, AlertColor, Button, Collapse, DialogActions, DialogContent, DialogContentText, InputAdornment, TextField, Container } from '@mui/material';
import NewFileDialog, { DoraFileType } from './NewFileDialog';
import logo from './logo.svg';
import DoraUpload from './Upload';
import { TransitionGroup } from 'react-transition-group';
import * as monaco from 'monaco-editor';
import * as Service from './Service';
import { AppBar, DrawerHeader, drawerWidth, Entry, Main, PlayControl, PlayControlMode, StyledStack, Color } from './Frame';
import { MacScrollbar } from 'mac-scrollbar';
import 'mac-scrollbar/dist/mac-scrollbar.css';
import FileFilter, { FilterOption } from './FileFilter';
import { useTranslation } from 'react-i18next';
import { Image } from 'antd';
import YarnEditor, { YarnEditorData } from './YarnEditor';
import CodeWire, { CodeWireData } from './CodeWire';
import LogView from './LogView';
import { AutoTypings } from './3rdParty/monaco-editor-auto-typings';
import { TbSwitchVertical } from "react-icons/tb";
import './Editor';

const SpinePlayer = React.lazy(() => import('./SpinePlayer'));
const Markdown = React.lazy(() => import('./Markdown'));

const { path } = Info;

loader.config({ monaco });

let lastEditorActionTime = Date.now();
let lastUploadedTime = Date.now();

document.addEventListener("contextmenu", (event) => {
	event.preventDefault();
});

let contentModified = false;
let waitingForDownload = false;
let beforeUnload: () => void = () => {};

window.onbeforeunload = (event: BeforeUnloadEvent) => {
	if (Info.version !== undefined) {
		beforeUnload();
		if (contentModified) {
			event.returnValue = "Please save before leaving!";
			return "Please save before leaving!";
		}
	}
};

interface EditingFile {
	key: string;
	title: string;
	content: string;
	contentModified: string | null;
	uploading: boolean;
	onMount: (editor: monaco.editor.IStandaloneCodeEditor) => void;
	editor?: monaco.editor.IStandaloneCodeEditor;
	position?: monaco.IPosition;
	mdEditing?: boolean;
	yarnData?: YarnEditorData;
	codeWireData?: CodeWireData;
	sortIndex?: number;
	status: TabStatus;
};

interface Modified {
	key: string;
	content: string;
};

const editorBackground = <div style={{width: '100%', height: '100%', backgroundColor:'#1a1a1a'}}/>;

const Editor = memo((props: {
	hidden: boolean,
	width: number, height: number,
	language: string,
	fileKey: string,
	file: EditingFile,
	readOnly: boolean,
	onMount: (editor: monaco.editor.IStandaloneCodeEditor) => void,
	onModified: (key: string, content: string) => void,
	onValidate: (markers: monaco.editor.IMarker[], key: string) => void,
}) => {
	const {
		hidden,
		width,
		height,
		language,
		fileKey,
		file,
		readOnly,
		onMount,
		onModified,
		onValidate
	} = props;
	return <div hidden={hidden}>
		<MonacoEditor
			width={width}
			height={height}
			language={language}
			theme="dora-dark"
			defaultValue={file.content}
			onMount={onMount}
			loading={editorBackground}
			onChange={(content: string | undefined) => {
				if (content === undefined) return;
				onModified(fileKey, content);
			}}
			onValidate={language === "typescript" ? (markers) => {onValidate(markers, fileKey);} : undefined}
			path={monaco.Uri.file(fileKey).toString()}
			options={{
				readOnly,
				wordWrap: 'on',
				wordBreak: 'keepAll',
				selectOnLineNumbers: true,
				matchBrackets: 'near',
				fontSize: 18,
				useTabStops: false,
				insertSpaces: false,
				renderWhitespace: 'all',
				tabSize: 2,
			}}
		/>
	</div>;
});

export default function PersistentDrawerLeft() {
	const {t} = useTranslation();
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
			title: "file.new" | "file.newFolder" | "file.rename",
			node?: TreeDataType,
			name: string,
			ext: string,
		} | null>(null);

	const [jumpToFile, setJumpToFile] = useState<{
		key: string,
		title: string,
		row: number,
		col: number,
		mdEditing?: boolean,
	}| null>(null);

	const [openFilter, setOpenFilter] = useState(false);
	const [filterOptions, setFilterOptions] = useState<FilterOption[] | null>(null);

	const [winSize, setWinSize] = useState({
		width: window.innerWidth - (drawerOpen ? drawerWidth : 0),
		height: window.innerHeight - 64
	});

	const [openLog, setOpenLog] = useState<{title: string, stopOnClose: boolean} | null>(null);

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

	const loadAssets = useCallback(() => {
		return Service.assets().then((res: TreeDataType) => {
			res.root = true;
			res.title = t("tree.assets");
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
			addAlert(t("alert.assetLoad"), "error");
			return null;
		});
	}, [t]);

	useEffect(() => {
		if (Info.version === undefined) {
			addAlert(t("alert.getInfo"), "error");
			return;
		}
		addAlert(t("alert.platform", {platform: Info.platform}), "success");
		loadAssets().then((res) => {
			if (res !== null) {
				setExpandedKeys([res.key]);
			}
		}).then(() => {
			Service.editingInfo().then((res: {success: boolean, editingInfo?: string}) => {
				if (res.success && res.editingInfo) {
					const editingInfo: Service.EditingInfo = JSON.parse(res.editingInfo);
					editingInfo.files.forEach((file, i) => {
						openFileInTab(file.key, file.title, file.position, file.mdEditing, i, editingInfo.index);
					});
				}
			});
		});
		document.addEventListener("keydown", (event: KeyboardEvent) => {
			if (event.ctrlKey || event.altKey || event.metaKey) {
				switch (event.key) {
					case 'N': case 'n':
					case 'D': case 'd':
					case 'S': case 's':
					case 'W': case 'w':
					case 'R': case 'r':
					case 'P': case 'p':
					case 'Q': case 'q':
					case '.': {
						event.preventDefault();
						setKeyEvent(event);
						break;
					}
				}
			}
		}, false);
		window.addEventListener("resize", () => {
			setDrawerOpen(open => {
				setWinSize({
					width: window.innerWidth - (open ? drawerWidth : 0),
					height: window.innerHeight - 64
				});
				return open;
			});
		});
		Service.addAlertListener((label: string, type: AlertColor) => {
			addAlert(t(label), type);
		});
		Service.addWSOpenListener(() => {
			addAlert(t("log.open"), "success");
		});
		Service.addWSCloseListener(() => {
			addAlert(t("log.close"), "error");
		});
		Service.openWebSocket();
		monaco.languages.typescript.typescriptDefaults.setExtraLibs([]);
		Service.read({path: "es6-subset.d.ts"}).then(res => {
			if (res.content !== undefined) {
				monaco.languages.typescript.typescriptDefaults.addExtraLib(res.content, "es6-subset.d.ts");
			}
		});
		Service.read({path: "lua.d.ts"}).then(res => {
			if (res.content !== undefined) {
				monaco.languages.typescript.typescriptDefaults.addExtraLib(res.content, "lua.d.ts");
			}
		});
		Service.read({path: "dora.d.ts"}).then(res => {
			if (res.content !== undefined) {
				monaco.languages.typescript.typescriptDefaults.addExtraLib(res.content, "dora.d.ts");
			}
		});
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	if (modified !== null) {
		setModified(null);
		files.forEach(file => {
			if (file.key === modified.key) {
				if (modified.content !== file.content || file.yarnData || file.codeWireData) {
					file.contentModified = modified.content;
				} else {
					file.contentModified = null;
				}
			}
		});
		setFiles([...files]);
	}

	contentModified = files.find(file => file.contentModified !== null) !== undefined;

	const onModified = useCallback((key: string, content: string) => {
		setModified({key, content});
	}, []);

	const assetPath = treeData.at(0)?.key ?? "";

	const checkFileReadonly = useCallback((key: string) => {
		if (!key.startsWith(assetPath)) {
			addAlert(t("alert.builtin"), "info");
			return true;
		}
		return false;
	}, [assetPath, t]);

	const handleDrawerOpen = () => {
		setDrawerOpen(!drawerOpen);
		setWinSize({
			width: window.innerWidth - (!drawerOpen ? drawerWidth : 0),
			height: window.innerHeight - 64
		});
	};

	const switchTab = useCallback((newValue: number | null, fileToFocus?: EditingFile) => {
		setTabIndex(newValue);
		if (newValue === null) return;
		if (fileToFocus !== undefined) {
			setTimeout(() => {
				const {editor} = fileToFocus;
				if (editor !== undefined) {
					editor.focus();
					const model = editor.getModel();
					if (model === null) return;
					if (fileToFocus.position) {
						const position = fileToFocus.position;
						editor.setPosition(position);
						editor.revealPositionInCenter(position);
						fileToFocus.position = undefined;
						setFiles(prev => [...prev]);
					}
					checkFile(fileToFocus, fileToFocus.contentModified ?? fileToFocus.content, model);
					const ext = path.extname(fileToFocus.key).toLowerCase();
					if (ext === ".ts" || ext === ".tsx") {
						import('./TranspileTS').then(({revalidateModel}) => {
							revalidateModel(model);
						});
					}
					return;
				}
				fileToFocus.yarnData?.warpToFocusedNode();
			}, 100);
		}
	}, []);

	const tabBarOnChange = useCallback((newValue: number) => {
		setFiles(files => {
			switchTab(newValue, files[newValue]);
			return files;
		})
	}, [switchTab]);

	const onEditorDidMount = useCallback((file: EditingFile) => async (editor: monaco.editor.IStandaloneCodeEditor) => {
		file.editor = editor;
		if (file.position !== undefined) {
			editor.setPosition(file.position);
		}
		setFiles(prev => [...prev]);
		let inferLang: "lua" | "tl" | "yue" | null = null;
		const ext = path.extname(file.key).toLowerCase().substring(1);
		switch (ext) {
			case "lua": case "tl": case "yue":
				inferLang = ext;
				break;
		}
		if (inferLang !== null) {
			const lang = inferLang;
			editor.addAction({
				id: "dora-action-definition",
				label: t("editor.goToDefinition"),
				keybindings: [
					monaco.KeyCode.F12 | monaco.KeyMod.CtrlCmd,
					monaco.KeyCode.F12 | monaco.KeyMod.WinCtrl,
				],
				contextMenuGroupId: "navigation",
				contextMenuOrder: 1,
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
						file: file.key,
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
			if (lang === "tl" || lang === "lua") {
				editor.addAction({
					id: "dora-action-require",
					label: t("editor.require"),
					keybindings: [
						monaco.KeyCode.F1 | monaco.KeyMod.CtrlCmd,
						monaco.KeyCode.F1 | monaco.KeyMod.WinCtrl,
					],
					contextMenuGroupId: "navigation",
					contextMenuOrder: 2,
					run: function(ed) {
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
						}], () => {return null});
					},
				});
			}
		}
		const model = editor.getModel();
		if (model) {
			model.onDidChangeContent((e) => {
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
		if (ext === "tsx" || ext === "ts") {
			if (ext === "tsx") {
				import('./languages/jsx-monaco').then(({jsxSyntaxHighlight}) => {
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
			await AutoTypings.create(editor, {
				debounceDuration: 2000,
				sourceCache: {
					isFileAvailable: async (uri: string) => {
						const res = await Service.exist({file: uri.startsWith("file:") ? monaco.Uri.parse(uri).fsPath : uri});
						return res.success;
					},
					getFile: async (uri: string) => {
						const res = await Service.read({path: uri.startsWith("file:") ? monaco.Uri.parse(uri).fsPath : uri});
						return res.content;
					}
				}
			});
		}
	}, [t]);

	const openFileInTab = useCallback((key: string, title: string, position?: monaco.IPosition, mdEditing?: boolean, sortIndex?: number, targetIndex?: number) => {
		setFiles(files => {
			let index: number | null = null;
			const file = files.find((file, i) => {
				if (path.relative(file.key, key) === "") {
					index = i;
					return true;
				}
				return false;
			});
			if (file) {
				file.mdEditing = mdEditing;
				if (file.editor && position) {
					const editor = file.editor;
					setTimeout(() => {
						editor.focus();
						editor.setPosition(position);
						editor.revealPositionInCenter(position);
					}, 100);
				}
			}
			if (index === null) {
				const sortedFiles = (prev: EditingFile[], index: number) => {
					if (sortIndex !== undefined) {
						const result = prev.sort((a, b) => {
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
						if (targetIndex !== undefined && result.length > targetIndex && result[targetIndex].sortIndex === targetIndex) {
							switchTab(targetIndex, result[targetIndex]);
						}
						return [...result];
					} else {
						switchTab(index, prev[index]);
						return [...prev];
					}
				};
				const ext = path.extname(title).toLowerCase();
				switch (ext) {
					case "": {
						if (checkFileReadonly(key)) {
							break;
						}
						setFiles(prev => {
							const index = prev.length;
							const newFile: EditingFile = {
								key,
								title,
								content: "",
								contentModified: null,
								uploading: true,
								sortIndex,
								status: "normal",
								onMount: () => {}
							};
							newFile.onMount = onEditorDidMount(newFile);
							return sortedFiles([...prev, newFile], index);
						});
						break;
					}
					case ".png":
					case ".jpg":
					case ".skel": {
						setFiles(prev => {
							const index = prev.length;
							const newFile: EditingFile = {
								key,
								title,
								content: "",
								contentModified: null,
								uploading: false,
								position,
								mdEditing,
								sortIndex,
								status: "normal",
								onMount: () => {},
							};
							newFile.onMount = onEditorDidMount(newFile);
							return sortedFiles([...prev, newFile], index);
						});
						break;
					}
					case ".lua":
					case ".tl":
					case ".yue":
					case ".xml":
					case ".md":
					case ".yarn":
					case ".vs":
					case ".ts":
					case ".tsx": {
						Service.read({path: key}).then((res) => {
							if (res.success && res.content !== undefined) {
								const content = res.content;
								setFiles(prev => {
									const index = prev.length;
									const newFile: EditingFile = {
										key,
										title,
										content,
										contentModified: null,
										uploading: false,
										position,
										mdEditing,
										sortIndex,
										status: "normal",
										onMount: () => {},
									};
									newFile.onMount = onEditorDidMount(newFile);
									return sortedFiles([...prev, newFile], index);
								});
							}
						}).catch(() => {
							addAlert(t("alert.read", {title}), "error");
						});
						break;
					}
				}
			} else if (targetIndex === undefined) {
				switchTab(index, file);
			}
			return files;
		});
	}, [checkFileReadonly, onEditorDidMount, switchTab, t]);

	if (jumpToFile !== null) {
		setJumpToFile(null);
		openFileInTab(jumpToFile.key, jumpToFile.title, {
			lineNumber: jumpToFile.row,
			column: jumpToFile.col
		}, jumpToFile.mdEditing);
	}

	const onSelect = (nodes: TreeDataType[]) => {
		setSelectedKeys(nodes.map(n => n.key));
		if (nodes.length === 0) {
			setSelectedNode(null);
			return;
		}
		const {key, title} = nodes[0];
		setSelectedNode(nodes[0]);
		openFileInTab(key, title);
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
				addAlert(t("alert.reloading"), "warning");
				return;
			}
			loadAssets().then((res) => {
				if (res !== null) {
					setFiles([]);
					switchTab(null);
					setSelectedKeys([]);
					addAlert(t("alert.reloaded"), "success");
				}
			});
			return;
		} else if (rootNode.children?.at(0)?.key === '...') {
			setExpandedKeys([]);
			return;
		}
		setExpandedKeys(keys);
	};

	const saveAllTabs = useCallback(() => {
		return new Promise<boolean>((resolve) => {
			setFiles(files => {
				const filesToSave = files.filter(file => file.contentModified !== null);
				const fileCount = filesToSave.length;
				if (fileCount === 0) {
					resolve(true);
					return files;
				}
				let failed = false;
				let count = 0;
				filesToSave.forEach(file => {
					let {contentModified} = file;
					if (contentModified === null) {
						count++;
						if (count === fileCount) {
							resolve(true);
						}
						return;
					}
					const readOnly = !file.key.startsWith(assetPath);
					if (readOnly) {
						addAlert(t("alert.builtin"), "warning");
						return;
					}
					const saveFile = (content: string) => {
						return Service.write({path: file.key, content}).then((res) => {
							if (res.success) {
								file.content = content;
								file.contentModified = null;
								setFiles(prev => [...prev]);
								count++;
								if (count === fileCount) {
									resolve(true);
								}
							} else {
								addAlert(t("alert.save", {title: file.title}), "error");
								if (!failed) {
									failed = true;
									resolve(false);
								}
							}
						}).catch(() => {
							addAlert(t("alert.save", {title: file.title}), "error");
							if (!failed) {
								failed = true;
								resolve(false);
							}
						});
					};
					if (file.yarnData !== undefined) {
						file.yarnData.getJSONData().then((value: string) => {
							saveFile(value);
						}).catch(() => {
							addAlert(t("alert.save", {title: file.title}), "error");
						})
					} else if (file.codeWireData !== undefined) {
						let {codeWireData} = file;
						const vscript = codeWireData.getVisualScript();
						if (file.contentModified !== null || file.content !== vscript) {
							let tealCode = codeWireData.getScript();
							const extname = path.extname(file.key);
							const name = path.basename(file.key, extname);
							const tlFile = path.join(path.dirname(file.key), name + ".tl");
							const fileInTab = files.find(f => path.relative(f.key, tlFile) === "");
							Service.write({path: tlFile, content: tealCode}).then((res) => {
								if (res.success) {
									if (fileInTab !== undefined) {
										setFiles(prev => {
											const newTabs = prev.filter(f => f.key !== fileInTab.key);
											const newIndex = newTabs.findIndex(t => t.key === file.key);
											if (newIndex >= 0) {
												setTabIndex(newIndex);
											}
											return newTabs;
										});
									}
								} else {
									addAlert(t("alert.save", {title: file.title}), "error");
								}
							}).then(() => {
								saveFile(vscript);
								Service.check({file: tlFile, content: tealCode}).then((res) => {
									if (res.success) {
										codeWireData.reportVisualScriptError("");
									}
									if (res.info !== undefined) {
										const lines = tealCode.split("\n");
										const message = [];
										for (let err of res.info) {
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
								addAlert(t("alert.save", {title: file.title}), "error");
							});
						}
					} else {
						const ext = path.extname(file.key).toLowerCase();
						if (ext === '.ts' || ext === '.tsx') {
							const content = contentModified;
							import('./TranspileTS').then(({transpileTypescript}) => {
								transpileTypescript(file.key, content).then(luaCode => {
									if (luaCode !== undefined) {
										const extname = path.extname(file.key);
										const name = path.basename(file.key, extname);
										const luaFile = path.join(path.dirname(file.key), name + ".lua");
										const fileInTab = files.find(f => path.relative(f.key, luaFile) === "");
										Service.write({path: luaFile, content: luaCode}).then((res) => {
											if (res.success) {
												saveFile(content);
												if (fileInTab !== undefined) {
													setFiles(prev => {
														const newTabs = prev.filter(f => f.key !== fileInTab.key);
														const newIndex = newTabs.findIndex(t => t.key === file.key);
														if (newIndex >= 0) {
															setTabIndex(newIndex);
														}
														return newTabs;
													});
												}
											} else {
												addAlert(t("alert.saveCurrent"), "error");
											}
										});
									}
								});
							});
						} else {
							saveFile(contentModified);
						}
					}
					return files;
				});
				return files;
			});
		});
	}, [t, assetPath]);

	const closeCurrentTab = () => {
		if (tabIndex !== null) {
			const closeTab = () => {
				setFiles(prev => {
					const newFiles = prev.filter((_, index) => index !== tabIndex);
					if (newFiles.length === 0) {
						switchTab(null);
					} else if (tabIndex > 0) {
						switchTab(tabIndex - 1, newFiles[tabIndex - 1]);
					} else {
						switchTab(tabIndex, newFiles[tabIndex]);
					}
					return newFiles;
				});
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
				title: t("popup.closingTab"),
				msg: t("popup.closingNoSave"),
				cancelable: true,
				confirmed: closeTabs,
			});
			return;
		}
		closeTabs();
	};

	const closeOtherTabs = () => {
		const closeTabs = () => {
			setFiles(prev => {
				const newFiles = prev.filter((_, index) => index === tabIndex);
				setFiles(newFiles);
				switchTab(0, newFiles[0]);
				return newFiles;
			});
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
			addAlert(t("alert.deleteRoot"), "info");
			return;
		}
		setPopupInfo({
			title: t("menu.delete"),
			msg: t(data.dir ? 'file.deleteFolder' : 'file.deleteFile', {name: data.title}),
			cancelable: true,
			confirmed: () => {
				Service.deleteFile({path: data.key}).then((res) => {
					if (!res.success) return;
					const uri = monaco.Uri.parse(data.key);
					const model = monaco.editor.getModel(uri);
					if (model !== null) {
						model.dispose();
					}
					const filesNotInTabs = new Set<string>();
					if (data.dir) {
						const getEveryFileUnder = (node: TreeDataType) => {
							filesNotInTabs.add(node.key);
							if (node.children !== undefined) {
								for (let i = 0; i < node.children.length; i++) {
									getEveryFileUnder(node.children[i]);
								}
							}
						};
						getEveryFileUnder(data);
					}
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
					const newFiles = files.filter(f => path.relative(f.key, data.key) !== "" && !filesNotInTabs.has(f.key));
					if (newFiles.length !== files.length) {
						setFiles(newFiles);
						if (tabIndex !== null && tabIndex >= newFiles.length) {
							switchTab(newFiles.length - 1, newFiles[newFiles.length - 1]);
						}
					}
					setTreeData([rootNode]);
				}).then(() => {
					addAlert(t("alert.deleted", {title: data.title}), "success");
				}).catch(() => {
					addAlert(t("alert.delete"), "error");
				});
			},
		});
	};

	const onTreeMenuClick = (event: TreeMenuEvent, data?: TreeDataType)=> {
		if (event === "Cancel") return;
		if (data === undefined) return;
		if (checkFileReadonly(data.key)) return;
		switch (event) {
			case "New": {
				setOpenNewFile(data);
				break;
			}
			case "Download": {
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				const {key, title} = data;
				const downloadFile = (filename: string) => {
					const assetPath = path.relative(rootNode.key, filename).replace("\\", "/");
					const x = new XMLHttpRequest();
					x.open("GET", Service.addr("/" + assetPath), true);
					x.responseType = 'blob';
					x.onload = function() {
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
					addAlert(t("alert.downloadStart"), "info");
					const zipFile = path.join(rootNode.key, ".download", title + ".zip");
					waitingForDownload = true;
					Service.zip({zipFile, path: key}).then(res => {
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
					const extname = path.extname(data.title);
					const name = path.basename(data.title, extname);
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
				const {key, title} = data;
				const extname = path.extname(key);
				const name = path.basename(key, extname);
				const dir = path.dirname(key);
				addAlert(t("alert.startUnzip", {title}), "info");
				Service.unzip({zipFile: key, path: path.join(dir, name)}).then((res)=> {
					if (res.success) {
						addAlert(t("alert.doneUnzip", {title}), "success");
					} else {
						addAlert(t("alert.failedUnzip", {title}), "error");
					}
					loadAssets();
				})
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
			case "Markdown": ext = ".md"; break;
			case "Yarn": ext = ".yarn"; break;
			case "Visual Script": ext = ".vs"; break;
			case "Folder": ext = ""; break;
			case "Typescript": ext = ".tsx"; break;
		}
		if (ext !== null) {
			setFileInfo({
				title: ext === "" ? "file.newFolder" : "file.new",
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
			if (fileInfo.title === "file.rename") {
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
							addAlert(t("alert.renameFailed"), "error");
							return;
						}
						const uri = monaco.Uri.parse(oldFile);
						const model = monaco.editor.getModel(uri);
						if (model !== null) {
							model.dispose();
						}
						if (target.dir) {
							loadAssets().then(() => {
								addAlert(t("alert.renamed", {oldFile: path.basename(oldFile), newFile: path.basename(newFile)}), "success");
							});
							return;
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
						addAlert(t("alert.renamed", {oldFile: path.basename(oldFile), newFile: path.basename(newFile)}), "success");
					}).catch(() => {
						addAlert(t("alert.renameFailed"), "error");
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
				const newName = fileInfo.name + ext;
				const newFile = path.join(dir, newName);
				let content = "";
				let position: monaco.IPosition | undefined = undefined;
				switch (ext) {
					case ".yue":
						content = "_ENV = Dora!\n\n";
						position = {
							lineNumber: 3,
							column: 1
						};
						break;
					case ".tsx":
						content = "// @preview-file off\nimport { React, toNode, useRef } from 'dora-x';\nimport {} from 'dora';\n\n";
						position = {
							lineNumber: 5,
							column: 1
						};
						break;
					case ".ts":
						content = "import {} from 'dora';\n\n";
						position = {
							lineNumber: 3,
							column: 1
						};
						break;
					default:
						break;
				}
				Service.newFile({path: newFile, content}).then((res) => {
					if (!res.success) {
						addAlert(t("alert.newFailed"), "error");
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
						const index = files.length;
						if (ext === ".md") {
							files[index].mdEditing = true;
						}
						const newItem: EditingFile = {
							key: newFile,
							title: newName,
							position,
							content,
							contentModified: null,
							uploading: false,
							status: "normal",
							onMount: () => {},
						};
						newItem.onMount = onEditorDidMount(newItem);
						setFiles([...files, newItem]);
						switchTab(index, newItem);
					}
				}).catch(() => {
					addAlert(t("alert.newFailed"), "error");
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
				const affected = res.files ? res.files.map(f => [path.join(oldDir, f), path.join(newDir, f)]) : [];
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
		if (contentModified) {
			addAlert(t("alert.movingNoSave"), "info");
			return;
		}
		if (checkFileReadonly(self.key)) return;
		if (checkFileReadonly(target.key)) return;
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
			msg: t("popup.movingInfo", {from: self.title, to: targetName}),
			cancelable: true,
			confirmed: () => {
				const newFile = path.join(targetParent, path.basename(self.key));
				const doRename = () => {
					return Service.rename({old: self.key, new: newFile}).then((res) => {
						if (res.success) {
							loadAssets().then(() => {
								addAlert(t("alert.moved", {from: self.title, to: targetName}), "success");
							});
							return;
						}
						addAlert(t("alert.movingFailed", {from: self.title, to: targetName}), "error");
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
						const file = files.find(f => path.relative(f.key, self.key) === "");
						if (file !== undefined) {
							file.key = newFile;
							setFiles(prev => [...prev]);
						}
						setExpandedKeys(expandedKeys.filter(k => k !== self.key));
						setSelectedNode(null);
						setSelectedKeys([]);
					});
				}
			}
		});
	};

	const onUploaded = useCallback((dir: string, file: string) => {
		setFiles(files => {
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
			return files;
		})
	}, [tabIndex, loadAssets, switchTab]);

	const checkFile = (file: EditingFile, content: string, model: monaco.editor.ITextModel, lastChange?: monaco.editor.IModelContentChange) => {
		switch (path.extname(file.key).toLowerCase()) {
			case ".lua": case ".tl": case ".yue": case ".xml": break;
			default: return;
		}
		Service.check({file: file.key, content}).then((res) => {
			let status: TabStatus = "normal";
			const markers: monaco.editor.IMarkerData[] = [];
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
							message: filename + ': '+ msg,
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
			file.status = status;
			setFiles(prev => [...prev]);
			monaco.editor.setModelMarkers(model, model.getLanguageId(), markers);
		}).catch((reason) => {
			console.error(`failed to check file, due to: ${reason}`);
		});
	};

	const onStopRunning = useCallback(() => {
		if (tabIndex !== null) {
			setFiles(files => {
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
						return [...files];
					}
				}
				return files;
			});
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
	}, [openLog, t, tabIndex]);

	const onPlayControlClick = useCallback((mode: PlayControlMode, noLog?: boolean) => {
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
		saveAllTabs().then((success) => {
			if (!success) {
				return;
			}
			switch (mode) {
				case "Run": case "Run This": {
					setFiles(files => {
						let key: string | null = null;
						let title: string | null = null;
						let dir = false;
						if (tabIndex !== null) {
							const file = files.at(tabIndex);
							if (file !== undefined) {
								key = file.key;
								title = file.title;
								dir = file.uploading;
								if (path.extname(title).toLowerCase() === ".md") {
									file.mdEditing = false;
									return [...files];
								}
							}
						}
						if (key === null || title === null) {
							if (selectedNode === null) {
								addAlert(t("alert.runNoTarget"), "info");
								return files;
							}
							key = selectedNode.key;
							title = selectedNode.title;
							dir = selectedNode.dir;
						}
						let asProj = mode === "Run";
						if (dir) {
							key = path.join(key, "init");
							asProj = true;
						}
						const ext = path.extname(key).toLowerCase();
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
							case "": {
								if (ext === ".yarn" && !asProj) {
									break;
								}
								Service.run({file: key, asProj}).then((res) => {
									if (res.success) {
										addAlert(t("alert.run", {title: res.target ?? title}), "success");
										if (!noLog) setOpenLog({
											title: res.target ?? title ?? "Running",
											stopOnClose: true
										});
									} else {
										addAlert(t("alert.runFailed", {title: res.target ?? title}), "error");
									}
									if (!noLog && res.err !== undefined) {
										setPopupInfo({
											title: res.target ?? title ?? "",
											msg: res.err,
											raw: true
										});
									}
								}).catch(() => {
									addAlert(t("alert.runFailed", {title}), "error");
								})
								return files;
							}
						}
						addAlert(t("alert.runFailed", {title}), "info");
						return files;
					});
					return;
				}
				case "Stop": {
					onStopRunning();
					return;
				}
			}
		})
	}, [tabIndex, selectedNode, openLog, t, onStopRunning, saveAllTabs]);

	const saveCurrentTab = useCallback(() => {
		if (tabIndex === null) return;
		setFiles(files => {
			const file = files[tabIndex];
			const saveFile = () => {
				if (file.contentModified !== null) {
					const readOnly = !file.key.startsWith(assetPath);
					if (readOnly) {
						addAlert(t("alert.builtin"), "warning");
						return;
					}
					const {contentModified} = file;
					Service.write({path: file.key, content: contentModified}).then((res) => {
						if (res.success) {
							file.content = contentModified;
							file.contentModified = null;
							setFiles(prev => [...prev]);
							const ext = path.extname(file.key).toLowerCase();
							switch (ext) {
								case ".ts": case ".tsx": case ".lua": case ".tl": case ".yue": {
									if (contentModified.search(/@preview-file on\b/) >= 0) {
										onPlayControlClick("Run This", true);
									} else if (contentModified.search(/@preview-project on\b/) >= 0) {
										onPlayControlClick("Run", true);
									}
									break;
								}
							}
						} else {
							addAlert(t("alert.saveCurrent"), "error");
						}
					}).catch(() => {
						addAlert(t("alert.saveCurrent"), "error");
					});
				}
			};
			if (file.yarnData !== undefined) {
				file.yarnData.getJSONData().then((value) => {
					file.contentModified = value;
					saveFile();
				}).catch(() => {
					addAlert(t("alert.saveCurrent"), "error");
				})
			} else if (file.codeWireData !== undefined) {
				let {codeWireData} = file;
				const vscript = codeWireData.getVisualScript();
				if (file.contentModified !== null || file.content !== vscript) {
					file.contentModified = vscript;
					let tealCode = codeWireData.getScript();
					const extname = path.extname(file.key);
					const name = path.basename(file.key, extname);
					const tlFile = path.join(path.dirname(file.key), name + ".tl");
					const fileInTab = files.find(f => path.relative(f.key, tlFile) === "");
					Service.write({path: tlFile, content: tealCode}).then((res) => {
						if (res.success) {
							if (fileInTab !== undefined) {
								setFiles(prev => {
									const newTabs = prev.filter(f => f.key !== fileInTab.key);
									const newIndex = newTabs.findIndex(t => t.key === file.key);
									if (newIndex >= 0) {
										setTabIndex(newIndex);
									}
									return newTabs;
								});
							}
						} else {
							addAlert(t("alert.saveCurrent"), "error");
						}
					}).then(() => {
						saveFile();
						Service.check({file: tlFile, content: tealCode}).then((res) => {
							if (res.success && tealCode !== "") {
								codeWireData.reportVisualScriptError("");
							} else if (res.info !== undefined) {
								const lines = tealCode.split("\n");
								const message = [];
								for (let err of res.info) {
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
					});
				}
			} else {
				const ext = path.extname(file.key).toLowerCase();
				if (file.contentModified !== null && (ext === '.ts' || ext === '.tsx') && !file.key.toLocaleLowerCase().endsWith(".d.ts")) {
					const {key, contentModified} = file;
					import('./TranspileTS').then(({transpileTypescript}) => {
						transpileTypescript(key, contentModified).then(luaCode => {
							if (luaCode !== undefined) {
								const extname = path.extname(file.key);
								const name = path.basename(file.key, extname);
								const luaFile = path.join(path.dirname(file.key), name + ".lua");
								const fileInTab = files.find(f => path.relative(f.key, luaFile) === "");
								Service.write({path: luaFile, content: luaCode}).then((res) => {
									if (res.success) {
										saveFile();
										if (fileInTab !== undefined) {
											setFiles(prev => {
												const newTabs = prev.filter(f => f.key !== fileInTab.key);
												const newIndex = newTabs.findIndex(t => t.key === file.key);
												if (newIndex >= 0) {
													setTabIndex(newIndex);
												}
												return newTabs;
											});
										}
									} else {
										addAlert(t("alert.saveCurrent"), "error");
									}
								});
							}
						});
					});
				} else {
					saveFile();
				}
			}
			return files;
		});
	}, [t, tabIndex, assetPath, onPlayControlClick]);

	const onKeyDown = (event: KeyboardEvent) => {
		if (event.ctrlKey || event.altKey || event.metaKey) {
			switch (event.key) {
				case 'N': case 'n': {
					if (!event.shiftKey) break;
					if (selectedNode === null) {
						addAlert(t("alert.newNoTarget"), "info");
						break;
					} else if (checkFileReadonly(selectedNode.key)) {
						break;
					}
					setOpenNewFile(selectedNode);
					break;
				}
				case 'D': case 'd': {
					if (!event.shiftKey) break;
					if (selectedNode === null) {
						addAlert(t("alert.deleteNoTarget"), "info");
						break;
					} else if (checkFileReadonly(selectedNode.key)) {
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
				case 'P': case 'p': {
					setOpenFilter(true);
					break;
				}
				case 'Q': case 'q': {
					onStopRunning();
					break;
				}
				case '.': {
					onPlayControlClick("View Log");
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
		openFileInTab(key, title);
	}, [openFileInTab]);

	if (openFilter) {
		setOpenFilter(false);
		const rootNode = treeData.at(0);
		if (rootNode !== undefined) {
			const filterOptions: FilterOption[] = [];
			const visitNode = (node: TreeDataType) => {
				if (!node.dir) {
					if (node.key.startsWith(rootNode.key)) {
						filterOptions.push({
							title: node.title,
							key: node.key,
							path: node.key.substring(rootNode.key.length),
						});
					}
				}
				const {children} = node;
				if (children !== undefined) {
					for (let i = 0; i < children.length; i++) {
						visitNode(children[i]);
					}
				}
			};
			visitNode(rootNode);
			setFilterOptions(filterOptions);
		}
	}

	const spineLoadFailed = useCallback((message: string) => {
		addAlert(message, 'error');
	}, []);

	beforeUnload = () => {
		const editingInfo: Service.EditingInfo = {
			index: tabIndex ?? 0,
			files: files.map(f => {
				const {key, title, mdEditing, editor} = f;
				let position: monaco.Position | null = null;
				if (editor !== undefined) {
					position = editor.getPosition();
				}
				return {key, title, mdEditing, position: position ? position : undefined};
			})
		};
		Service.editingInfo({
			editingInfo: editingInfo.files.length > 0 ? JSON.stringify(editingInfo) : ""
		}).catch(reason => {
			console.error(`failed to save editing info, due to: ${reason}`);
		});
	};

	const onCloseLog = useCallback(() => {
		if (openLog?.stopOnClose) onStopRunning();
		setOpenLog(null);
	}, [openLog, onStopRunning]);

	const onValidate = useCallback((markers: monaco.editor.IMarker[], key: string) => {
		setFiles(files => {
			const file = files.find(f => f.key === key);
			if (file === undefined) return files;
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
					return marker.code !== "2497" && marker.code !== "2666";
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
				return [...files];
			}
			return files;
		});
	}, []);

	return (
		<Entry>
			<Dialog
				maxWidth="lg"
				open={filterOptions !== null}
			>
				<DialogContent>
					{filterOptions !== null ?
						<FileFilter options={filterOptions} onClose={value => {
							setFilterOptions(null);
							if (value === null) {
								return;
							}
							setFilterOptions(null);
							openFileInTab(value.key, value.title);
						}}/> : null
					}
				</DialogContent>
			</Dialog>
			<LogView openName={openLog === null ? null : openLog.title} height={winSize.height * 0.7} onClose={onCloseLog}/>
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
			>
				<DialogTitle id="filename-dialog-title">
					{t(fileInfo?.title ?? "")}
				</DialogTitle>
				<DialogContent>
					<TextField
						autoFocus
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
							"& .MuiOutlinedInput-notchedOutline": {
								borderColor: Color.Secondary,
							}
						}}
						InputProps={{
							endAdornment:
								<InputAdornment position="end">
									{fileInfo?.ext === undefined
									? undefined
									: (fileInfo.ext !== ".ts" && fileInfo.ext !== ".tsx")
									? fileInfo.ext
									: <div style={{color: Color.Secondary}}>
											{fileInfo.ext}
											<IconButton
												size='small'
												aria-label="toggle tsx"
												edge="end"
												color='primary'
												onClick={() => {
													setFileInfo({...fileInfo, ext: fileInfo.ext === '.ts' ? '.tsx' : '.ts'});
												}}
											>
												<TbSwitchVertical/>
											</IconButton>
										</div>
									}
								</InputAdornment>,
						}}
						onChange={onFilenameChange}
					/>
				</DialogContent>
				<DialogActions>
					<Button onClick={handleFilenameClose}>
						{t("action.ok")}
					</Button>
					<Button onClick={handleFilenameCancel}>
						{t("action.cancel")}
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
						backgroundColor: Color.BackgroundSecondary,
						width: "100%",
						height: "30px",
						color: Color.Primary
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
						height="180px"
						style={{
							padding: "20px",
							textAlign: "center"
						}}
					/>
					<Divider style={{backgroundColor: '#0002'}}/>
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
				<>{
					files.map((file, index) => {
						const ext = path.extname(file.title);
						let language: "lua" | "tl" | "yue" | "typescript" | "xml" | "markdown" | null = null;
						let image = false;
						let spine = false;
						let yarn = false;
						let visualScript = false;
						switch (ext.toLowerCase()) {
							case ".lua": language = "lua"; break;
							case ".tl": language = "tl"; break;
							case ".yue": language = "yue"; break;
							case ".ts": case ".tsx": language = "typescript"; break;
							case ".xml": language = "xml"; break;
							case ".md": language = "markdown"; break;
							case ".jpg": image = true; break;
							case ".png": image = true; break;
							case ".skel": spine = true; break;
							case ".yarn": yarn = true; break;
							case ".vs": visualScript = true; break;
						}
						const markdown = language === "markdown";
						const readOnly = !file.key.startsWith(treeData.at(0)?.key ?? "");
						let parentPath;
						if (readOnly) {
							parentPath = treeData.at(0)?.children?.at(0)?.key ?? "";
						} else {
							parentPath = treeData.at(0)?.key ?? "";
						}
						return <Main
							open={drawerOpen}
							key={file.key}
							hidden={tabIndex !== index}
						>
							<DrawerHeader/>
							{yarn ?
								<YarnEditor
									title={file.key}
									defaultValue={file.content}
									width={winSize.width}
									height={winSize.height}
									onLoad={(data) => {
										file.yarnData = data;
									}}
									onChange={() => {
										setModified({key: file.key, content: ""});
									}}
									onKeydown={(e) => {
										setKeyEvent(e);
									}}
								/> : null
							}
							{visualScript ?
								<CodeWire
									key={file.key}
									title={file.key}
									defaultValue={file.content}
									width={winSize.width}
									height={winSize.height}
									onLoad={(data) => {
										file.codeWireData = data;
									}}
									onChange={() => {
										setModified({key: file.key, content: ""});
									}}
									onKeydown={(e) => {
										setKeyEvent(e);
									}}
								/> : null
							}
							{markdown ?
								<MacScrollbar skin='dark' hidden={file.mdEditing} style={{height: winSize.height}}>
									<Markdown
										fileKey={file.key}
										path={Service.addr("/" + path.relative(parentPath, path.dirname(file.key)).replace("\\", "/"))}
										content={file.contentModified ?? file.content}
										onClick={onJumpLink}
									/>
								</MacScrollbar> : null
							}
							{image ?
								<MacScrollbar skin='dark' style={{height: winSize.height}}>
									<Container maxWidth="lg">
										<DrawerHeader/>
										<Image src={
											Service.addr("/" + path
												.relative(parentPath, file.key)
												.replace("\\", "/"))
											} preview={false}/>
									</Container>
								</MacScrollbar> : null
							}
							{(() => {
								if (spine && tabIndex === index) {
									const skelFile = path.relative(parentPath, file.key);
									const coms = path.parse(skelFile);
									const atlasFile = path.join(coms.dir, coms.name + ".atlas");
									return (
										<MacScrollbar skin='dark' style={{height: winSize.height}}>
											<Container maxWidth="lg">
												<DrawerHeader/>
												<Suspense fallback={<div/>}>
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
									let width = 0;
									if (tabIndex === index) {
										width = winSize.width;
									}
									if (file.key === undefined) {
										return null;
									}
									return <Editor
										key={file.key}
										hidden={markdown && !file.mdEditing}
										fileKey={file.key}
										width={width}
										height={winSize.height}
										file={file}
										language={language}
										onMount={file.onMount}
										onModified={onModified}
										onValidate={onValidate}
										readOnly={readOnly}
									/>;
								} else if (file.uploading) {
									const rootNode = treeData.at(0);
									if (rootNode === undefined) return null;
									let target = path.relative(rootNode.key, file.key);
									target = path.join(t("tree.assets"), target);
									return (
										<MacScrollbar key={file.key} skin='dark' style={{height: winSize.height}}>
											<DrawerHeader/>
											<DoraUpload onUploaded={onUploaded} title={target + path.sep} path={file.key}/>
										</MacScrollbar>
									);
								}
								return null;
							})()}
						</Main>
					})
				}
				</>
				<PlayControl width={winSize.width} onClick={onPlayControlClick}/>
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

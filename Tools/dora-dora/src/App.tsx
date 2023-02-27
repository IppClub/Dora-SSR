import { ChangeEvent, useEffect, useState } from 'react';
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
import path from 'path';
import Post from './Post';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import { Button, DialogActions, DialogContent, DialogContentText, InputAdornment, TextField } from '@mui/material';
import NewFileDialog, { DoraFileType } from './NewFileDialog';

import logo from './logo.svg';

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
	const [drawerOpen, setDrawerOpen] = useState(true);
	const [tabIndex, setTabIndex] = useState<number | null>(null);
	const [files, setFiles] = useState<EditingFile[]>([]);
	const [tabs, setTabs] = useState<EditingTab[]>([]);
	const [modified, setModified] = useState<Modified | null>(null);

	const [treeData, setTreeData] = useState<TreeDataType[]>([]);
	const [expandedKeys, setExpandedKeys] = useState<string[]>([]);
	const [selectedKeys, setSelectedKeys] = useState<string[]>([]);

	const [openNewFile, setOpenNewFile] = useState<TreeDataType | null>(null);

	const [alertMsg, setAlertMsg] = useState<
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

	const loadAssets = () => {
		return Post('/assets').then((res: TreeDataType) => {
			res.root = true;
			if (res.children !== undefined) {
				setExpandedKeys([res.key]);
			} else {
				res.children = [{
					key: '...',
					dir: false,
					title: '...',
				}];
			}
			setTreeData([res]);
		}).catch(() => {
			setAlertMsg({
				title: "Assets",
				msg: "failed to read assets",
			});
		});
	};

	useEffect(() => {
		loadAssets();
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

	const onSelect = (nodes: TreeDataType[]) => {
		setSelectedKeys(nodes.map(n => n.key));
		if (nodes.length === 0) return;
		const {key, title} = nodes[0];
		const ext = path.extname(title);
		switch (ext.toLowerCase()) {
			case ".lua":
			case ".tl":
			case ".yue":
			case ".xml": {
				let index: number | null = null;
				files.find((file, i) => {
					if (file.key === key) {
						index = i;
						return true;
					}
					return false;
				});
				if (index === null) {
					Post('/read', {path: key}).then((res: {content: string, success: boolean}) => {
						if (res.success) {
							files.push({key: key, title: title, content: res.content, contentModified: null});
							setFiles(files);
							updateTabs(files);
							setTabIndex(files.length - 1);
						}
					});
				} else {
					setTabIndex(index);
				}
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
				setAlertMsg({
					title: "Assets",
					msg: "please save before reloading assets"
				});
				return;
			}
			loadAssets().then(() => {
				setFiles([]);
				setTabs([]);
				setTabIndex(null);
				setAlertMsg({
					title: "Assets",
					msg: "assets reloaded"
				});
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
			if (files[tabIndex].contentModified !== null) {
				setAlertMsg({
					title: "Closing Tab",
					msg: "please save before closing"
				});
				return;
			}
			const newFiles = files.filter((_, index) => index !== tabIndex);
			setFiles(newFiles);
			updateTabs(newFiles);
			if (newFiles.length === 0) {
				setTabIndex(null);
			} else if (tabIndex > 0) {
				setTabIndex(tabIndex - 1);
			}
		}
	};

	const closeAllTabs = () => {
		if (contentModified) {
			setAlertMsg({
				title: "Closing Tabs",
				msg: "please save before closing"
			});
			return;
		}
		setFiles([]);
		updateTabs([]);
		setTabIndex(null);
	};

	const closeOtherTabs = () => {
		const otherModified = files.filter((_, index) => index !== tabIndex).find((file) => file.contentModified !== null) !== undefined;
		if (otherModified) {
			setAlertMsg({
				title: "Closing Tabs",
				msg: "please save before closing"
			});
			return;
		}
		const newFiles = files.filter((_, index) => index === tabIndex);
		setFiles(newFiles);
		updateTabs(newFiles);
		setTabIndex(0);
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
		if (alertMsg?.confirmed !== undefined) {
			alertMsg.confirmed();
		}
		setAlertMsg(null);
	};

	const handleAlertCancel = () => {
		setAlertMsg(null);
	};

	const onTabMenuClick = (event: TabMenuEvent) => {
		switch (event) {
			case "Save": {
				saveCurrentTab();
				break;
			}
			case "SaveAll": {
				saveAllTabs();
				break;
			}
			case "Close": {
				closeCurrentTab();
				break;
			}
			case "CloseAll": {
				closeAllTabs();
				break;
			}
			case "CloseOther": {
				closeOtherTabs();
				break;
			}
		}
	};

	const onTreeMenuClick = (event: TreeMenuEvent, data?: TreeDataType)=> {
		switch (event) {
			case "New": {
				if (data !== undefined) {
					setOpenNewFile(data);
				}
				break;
			}
			case "Rename": {
				const rootNode = treeData.at(0);
				if (rootNode === undefined) break;
				if (rootNode.key === data?.key) {
					setAlertMsg({
						title: "Rename",
						msg: "can not rename root folder",
					});
					break;
				}
				if (data !== undefined) {
					if (tabs.find(tab => tab.key === data.key && tab.modified) !== undefined) {
						setAlertMsg({
							title: "Rename",
							msg: "please save before renaming",
						});
						break;
					}
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
					setAlertMsg({
						title: "Delete",
						msg: "can not delete root folder",
					});
					break;
				}
				if (data !== undefined) {
					setAlertMsg({
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
								setAlertMsg({
									title: "Delete",
									msg: "failed to delete item",
								});
							});;
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
			case "Lua": {
				ext = ".lua";
				break;
			}
			case "Teal": {
				ext = ".tl";
				break;
			}
			case "Yuescript": {
				ext = ".yue";
				break;
			}
			case "Dora Xml": {
				ext = ".xml";
				break;
			}
			case "Folder": {
				ext = "";
				break;
			}
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
				Post("/rename", {old: oldFile, new: newFile}).then((res: {success: boolean}) => {
					if (!res.success) {
						setAlertMsg({
							title: "Rename",
							msg: "failed to rename item",
						})
						return;
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
					const file = files.find(f => f.key === oldFile);
					if (file !== undefined) {
						file.key = newFile;
						file.title = newName;
						setFiles(files.map(f => f));
						const tab = tabs.find(t => t.key === oldFile);
						if (tab !== undefined) {
							tab.key = newFile;
							tab.title = newName;
							setTabs(tabs.map(t => t));
						}
					}
				}).catch(() => {
					setAlertMsg({
						title: "Rename",
						msg: "failed to rename item",
					});
				});
			} else {
				const dir = target.dir ?
					target.key : path.dirname(target.key);
				const {ext} = fileInfo;
				const newName = fileInfo.name + fileInfo.ext;
				const newFile = path.join(dir, newName);
				Post("/new", {path: newFile}).then((res: {success: boolean}) => {
					if (!res.success) {
						setAlertMsg({
							title: "New Item",
							msg: "failed to create item",
						});
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
						setExpandedKeys(expandedKeys.map(k => k));
					}
					setTreeData([rootNode]);
					setSelectedKeys([newFile]);
					files.push({key: newFile, title: newName, content: "", contentModified: null});
					setFiles(files);
					updateTabs(files);
					setTabIndex(files.length - 1);
				}).catch(() => {
					setAlertMsg({
						title: "New Item",
						msg: "failed to create item",
					});
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

	return (
		<ThemeProvider theme={theme}>
			<Dialog
				open={alertMsg !== null}
				aria-labelledby="alert-dialog-title"
				aria-describedby="alert-dialog-description"
			>
				<DialogTitle id="alert-dialog-title">
					{alertMsg?.title}
				</DialogTitle>
				<DialogContent>
					<DialogContentText id="alert-dialog-description">
						{alertMsg?.msg}
					</DialogContentText>
				</DialogContent>
				<DialogActions>
					<Button
						onClick={handleAlertClose}
						autoFocus={alertMsg?.cancelable === undefined}
					>
						{alertMsg?.cancelable !== undefined ?
							"Confirm" : "OK"
						}
					</Button>
					{
						alertMsg?.cancelable !== undefined ?
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
			<Box sx={{display: "flex"}} onKeyDown={onKeyDown}>
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
					<Divider/>
					<FileTree
						selectedKeys={selectedKeys}
						expandedKeys={expandedKeys}
						treeData={treeData}
						onMenuClick={onTreeMenuClick}
						onSelect={onSelect}
						onExpand={onExpand}
					/>
				</Drawer>
				{
					files.map((file, index) => {
						const ext = path.extname(file.title);
						let language = null;
						switch (ext.toLowerCase()) {
							case ".lua": {
								language = "lua";
								break;
							}
							case ".tl": {
								language = "tl";
								break;
							}
							case ".yue": {
								language = "yue";
								break;
							}
							case ".xml": {
								language = "xml";
								break;
							}
						}
						if (language) {
							let width = 0;
							if (tabIndex === index) {
								width = window.innerWidth - (drawerOpen ? drawerWidth : 0);
							}
							return <Main
									open={drawerOpen}
									key={file.key}
									hidden={tabIndex !== index}
								>
								<DrawerHeader/>
								<MonacoEditor
									width={width}
									height={window.innerHeight - 64}
									language={language}
									theme="vs-dark"
									value={file.content}
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
							</Main>;
						}
						return null;
					})
				}
			</Box>
		</ThemeProvider>
	);
}

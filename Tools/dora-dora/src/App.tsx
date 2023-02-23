import { useState } from 'react';
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
import FileTree, { TreeMenuEvent } from "./FileTree";
import FileTabBar, { TabMenuEvent } from './FileTabBar';
import path from 'path';
import Post from './Post';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import { Button, DialogActions, DialogContent, DialogContentText } from '@mui/material';
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
	const [openNewFile, setOpenNewFile] = useState(false);
	const [drawerOpen, setDrawerOpen] = useState(true);
	const [tabIndex, setTabIndex] = useState<number | null>(null);
	const [files, setFiles] = useState<EditingFile[]>([]);
	const [tabs, setTabs] = useState<EditingTab[]>([]);
	const [modified, setModified] = useState<Modified | null>(null);
	const [alertMsg, setAlertMsg] = useState<{title: string, msg: string} | null>(null);

	contentModified = tabs.find((tab) => tab.modified) !== undefined;

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
		files.forEach((file) => {
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

	const onSelect = (key: string, title: string) => {
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
		filesToSave.forEach((index) => {
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
					msg: "Please save before closing"
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
				msg: "Please save before closing"
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
				msg: "Please save before closing"
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

	const onTreeMenuClick = (event: TreeMenuEvent)=> {
		switch (event) {
			case "New": {
				setOpenNewFile(true);
				break;
			}
			case "Rename": {
				break;
			}
			case "Delete": {
				break;
			}
		}
	};

	const onNewFileClose = (item?: DoraFileType) => {
		setOpenNewFile(false);
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
		}
		if (ext !== null) {
			console.log(ext);
		}
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
					<Button onClick={handleAlertClose} autoFocus>
						OK
					</Button>
				</DialogActions>
			</Dialog>
			<NewFileDialog open={openNewFile} onClose={onNewFileClose}/>
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
					<FileTree onMenuClick={onTreeMenuClick} onSelect={onSelect}/>
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

/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { styled, ThemeProvider } from '@mui/material/styles';
import MuiAppBar, { AppBarProps as MuiAppBarProps } from '@mui/material/AppBar';
import Stack from '@mui/system/Stack';
import { Box, Divider, IconButton, ListItemIcon, ListItemText } from '@mui/material';
import ArrowDropDown from '@mui/icons-material/ArrowDropDown';
import { BsFillFileEarmarkPlayFill, BsFillPlayFill, BsFillStopFill, BsSearch, BsTerminal, BsGear } from 'react-icons/bs';
import { memo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { theme, Color } from './Theme';
import { StyledMenu, StyledMenuItem } from './Menu';

export const Separator = () => <Divider style={{ backgroundColor: Color.Line }} />;

interface EntryProp {
	children?: React.ReactNode;
}
export const Entry = (prop: EntryProp) => {
	return <ThemeProvider theme={theme} children={prop.children} />
};

export const Main = styled('main', { shouldForwardProp: (prop) => prop !== 'open' && prop !== 'drawerWidth' })<{
	open?: boolean;
	drawerWidth: number;
}>(({ theme, open, drawerWidth }) => ({
	flexGrow: 1,
	minWidth: 0,
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

export const StyledStack = styled(Stack)(({ theme }) => ({
	zIndex: 999,
	width: 'fit-content',
	top: 55,
	flexGrow: 1,
	position: 'fixed',
	padding: theme.spacing(0),
	transition: theme.transitions.create('right', {
		easing: theme.transitions.easing.sharp,
		duration: theme.transitions.duration.leavingScreen,
	}),
	right: 5,
}));

export interface AppBarProps extends MuiAppBarProps {
	open?: boolean;
	drawerWidth: number;
	isResizing: boolean;
}

export const AppBar = styled(MuiAppBar, {
	shouldForwardProp: (prop) => prop !== 'open' && prop !== 'drawerWidth' && prop !== 'isResizing',
})<AppBarProps>(({ theme, open, drawerWidth, isResizing }) => ({
	zIndex: 2,
	transition: isResizing ? undefined : theme.transitions.create(['width'], {
		easing: theme.transitions.easing.sharp,
		duration: theme.transitions.duration.leavingScreen,
	}),
	...(open && {
		width: `calc(100% - ${drawerWidth}px)`,
		marginLeft: `${drawerWidth}px`,
		transition: isResizing ? undefined : theme.transitions.create(['width'], {
			easing: theme.transitions.easing.easeOut,
			duration: theme.transitions.duration.enteringScreen,
		}),
	}),
}));

export const DrawerHeader = styled('div')(({ theme }) => ({
	display: 'flex',
	alignItems: 'center',
	padding: theme.spacing(0),
	minHeight: 48,
	justifyContent: 'flex-end',
}));

export type PlayControlMode = "Run" | "Run This" | "Stop" | "Go to File" | "View Log" | "LLM Config";

export interface PlayControlProp {
	onClick: (mode: PlayControlMode, noLog?: boolean) => void;
}

export const PlayControl = memo((prop: PlayControlProp) => {
	const [anchorEl, setAnchorEl] = useState<Element | null>(null);
	const { t } = useTranslation();
	const open = Boolean(anchorEl);

	const close = () => {
		setAnchorEl(null);
	};
	const runMode = (mode: PlayControlMode) => () => {
		close();
		prop.onClick(mode);
	};
	const actions: { mode: PlayControlMode; icon: React.ReactNode; name: string; shortcut?: string }[] = [
		{ mode: "Run This", icon: <BsFillFileEarmarkPlayFill />, name: t("menu.runThis"), shortcut: "Mod+Shift+R" },
		{ mode: "View Log", icon: <BsTerminal />, name: t("menu.viewLog"), shortcut: "Mod+." },
		{ mode: "Go to File", icon: <BsSearch />, name: t("menu.goToFile"), shortcut: "Mod+P" },
		{ mode: "LLM Config", icon: <BsGear />, name: t("menu.llmConfig") },
	];
	return <Box style={{
		backgroundColor: "#0000",
		width: "116px",
		height: "48px",
		color: Color.Primary,
		flexShrink: 0,
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
	}}>
		<IconButton
			color="secondary"
			aria-label="run"
			disableRipple
			onClick={runMode("Run")}
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
			<BsFillPlayFill />
		</IconButton>
		<IconButton
			color="secondary"
			aria-label="stop"
			disableRipple
			onClick={runMode("Stop")}
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
			<BsFillStopFill />
		</IconButton>
		<IconButton
			color="secondary"
			aria-label="more run actions"
			aria-expanded={open}
			disableRipple
			onClick={(event) => setAnchorEl(event.currentTarget)}
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
			<ArrowDropDown fontSize="small" />
		</IconButton>
		<StyledMenu
			anchorEl={anchorEl}
			autoFocus={false}
			keepMounted
			open={open}
			onClose={close}
			anchorOrigin={{
				vertical: 'bottom',
				horizontal: 'left',
			}}
			transformOrigin={{
				vertical: 'top',
				horizontal: 'left',
			}}
			sx={{
				'& .MuiPaper-root': {
					marginTop: 0.5,
				},
			}}
		>
			{actions.map((action) => (
				<StyledMenuItem key={action.mode} onClick={runMode(action.mode)}>
					<ListItemIcon>{action.icon}</ListItemIcon>
					<ListItemText primary={action.name} />
					{action.shortcut ? <div style={{ fontSize: 10, color: Color.TextSecondary }}>{action.shortcut}</div> : null}
				</StyledMenuItem>
			))}
		</StyledMenu>
	</Box>;
});

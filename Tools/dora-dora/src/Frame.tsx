/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { styled, ThemeProvider } from '@mui/material/styles';
import MuiAppBar, { AppBarProps as MuiAppBarProps } from '@mui/material/AppBar';
import Stack from '@mui/system/Stack';
import { Box, Divider, IconButton, Tooltip } from '@mui/material';
import { BsFillFileEarmarkPlayFill, BsFillPlayFill, BsFillStopFill, BsSearch, BsTerminal, BsGear } from 'react-icons/bs';
import { memo } from 'react';
import { useTranslation } from 'react-i18next';
import { theme, Color } from './Theme';

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
	width: 300,
	top: 60,
	flexGrow: 1,
	position: 'fixed',
	padding: theme.spacing(0),
	transition: theme.transitions.create('right', {
		easing: theme.transitions.easing.sharp,
		duration: theme.transitions.duration.leavingScreen,
	}),
	right: 12,
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
	compact?: boolean;
}

export const PlayControl = memo((prop: PlayControlProp) => {
	const { t } = useTranslation();
	const buttonSize = prop.compact ? 26 : 36;
	const controlWidth = prop.compact ? undefined : 116;
	const controlHeight = prop.compact ? 26 : 48;
	const buttonRadius = prop.compact ? 1 : 1.5;
	const iconSize = prop.compact ? 16 : undefined;
	const iconStyle = { fontSize: iconSize };
	const buttonSx = {
		width: buttonSize,
		height: buttonSize,
		padding: 0,
		borderRadius: buttonRadius,
		color: Color.Secondary,
		backgroundColor: 'transparent',
		'&:hover': {
			backgroundColor: Color.Line,
		},
		'& svg': {
			width: iconSize,
			height: iconSize,
		},
	};

	const actions: { mode: PlayControlMode; icon: React.ReactNode; name: string; shortcut?: string }[] = [
		{ mode: "Run", icon: <BsFillPlayFill style={iconStyle} />, name: t("menu.run"), shortcut: "Mod+R" },
		{ mode: "Stop", icon: <BsFillStopFill style={iconStyle} />, name: t("menu.stop"), shortcut: "Mod+Q" },
		{ mode: "Run This", icon: <BsFillFileEarmarkPlayFill style={iconStyle} />, name: t("menu.runThis"), shortcut: "Mod+Shift+R" },
		{ mode: "View Log", icon: <BsTerminal style={iconStyle} />, name: t("menu.viewLog"), shortcut: "Mod+." },
		{ mode: "Go to File", icon: <BsSearch style={iconStyle} />, name: t("menu.goToFile"), shortcut: "Mod+P" },
		{ mode: "LLM Config", icon: <BsGear style={iconStyle} />, name: t("menu.llmConfig") },
	];
	return <Box style={{
		backgroundColor: "#0000",
		width: controlWidth === undefined ? "auto" : `${controlWidth}px`,
		height: `${controlHeight}px`,
		color: Color.Primary,
		flexShrink: 0,
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
	}}>
		{actions.map((action) => (
			<Tooltip key={action.mode} title={action.shortcut ? `${action.name} ${action.shortcut}` : action.name}>
				<IconButton
					color="secondary"
					aria-label={action.name}
					onClick={() => prop.onClick(action.mode)}
					sx={buttonSx}
				>
					{action.icon}
				</IconButton>
			</Tooltip>
		))}
	</Box>;
});

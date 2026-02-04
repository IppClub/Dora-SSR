/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { styled, ThemeProvider } from '@mui/material/styles';
import MuiAppBar, { AppBarProps as MuiAppBarProps } from '@mui/material/AppBar';
import Stack from '@mui/system/Stack';
import { Divider, IconButton, ListItemIcon, ListItemText, Toolbar } from '@mui/material';
import SportsEsports from '@mui/icons-material/SportsEsports';
import { BsFillFileEarmarkPlayFill, BsPlayCircle, BsStopCircle, BsSearch, BsTerminal, BsGear } from 'react-icons/bs';
import { StyledMenu, StyledMenuItem } from './Menu';
import { memo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import Info from './Info';
import { theme, Color } from './Theme';

export const Separator = () => <Divider style={{backgroundColor: Color.Line}}/>;

interface EntryProp {
	children?: React.ReactNode;
}
export const Entry = (prop: EntryProp) => {
	return <ThemeProvider theme={theme} children={prop.children}/>
};

export const Main = styled('main', { shouldForwardProp: (prop) => prop !== 'open' && prop !== 'drawerWidth' })<{
	open?: boolean;
	drawerWidth: number;
}>(({ theme, open, drawerWidth }) => ({
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
	width: number;
	onClick: (mode: PlayControlMode, noLog?: boolean) => void;
}

export const PlayControl = memo((prop: PlayControlProp) => {
	const [open, setOpen] = useState(false);
	const [anchorEl, setAnchorEl] = useState<Element | null>(null);
	const [playButtonDisabled, setPlayButtonDisabled] = useState(false);
	const {t} = useTranslation();

	const onClose = (mode?: PlayControlMode) => () => {
		setOpen(false);
		if (mode !== undefined) {
			prop.onClick(mode);
		}
		setTimeout(() => {
			setPlayButtonDisabled(false);
		}, 500);
	};
	const onClick = (e: React.MouseEvent) => {
		if (!playButtonDisabled) {
			setOpen(true);
			setAnchorEl(e.currentTarget);
			setPlayButtonDisabled(true);
		}
	};
	return <Toolbar style={{
		backgroundColor: "#0000",
		width: "65px",
		height: "65px",
		color: Color.Primary,
		bottom: 0,
		right: prop.width * 0.1,
		flexGrow: 1,
		position: 'fixed',
	}}>
		<StyledMenu
			keepMounted
			anchorOrigin={{
				vertical: 'bottom',
				horizontal: 'right',
			}}
			anchorEl={anchorEl}
			autoFocus={false}
			open={open}
			onClose={onClose()}
		>
			{Info.version ?
				<p style={{textAlign: "center", opacity: 0.6, fontSize: "12px", margin: '5px'}}>{t("menu.version", {version: Info.version})}</p> : null
			}
			<StyledMenuItem onClick={onClose("LLM Config")}>
				<ListItemIcon>
					<BsGear/>
				</ListItemIcon>
				<ListItemText primary={ t("menu.llmConfig") }/>
			</StyledMenuItem>
			<StyledMenuItem onClick={onClose("Go to File")}>
				<ListItemIcon>
					<BsSearch/>
				</ListItemIcon>
				<ListItemText primary={ t("menu.goToFile") }/>
				<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+P</div>
			</StyledMenuItem>
			<StyledMenuItem onClick={onClose("View Log")}>
				<ListItemIcon>
					<BsTerminal/>
				</ListItemIcon>
				<ListItemText primary={ t("menu.viewLog") }/>
				<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+.</div>
			</StyledMenuItem>
			<StyledMenuItem onClick={onClose("Stop")}>
				<ListItemIcon>
					<BsStopCircle/>
				</ListItemIcon>
				<ListItemText primary={ t("menu.stop") }/>
				<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+Q</div>
			</StyledMenuItem>
			<StyledMenuItem onClick={onClose("Run This")}>
				<ListItemIcon>
					<BsFillFileEarmarkPlayFill/>
				</ListItemIcon>
				<ListItemText primary={ t("menu.runThis") }/>
				<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+Shift+R</div>
			</StyledMenuItem>
			<StyledMenuItem onClick={onClose("Run")}>
				<ListItemIcon>
					<BsPlayCircle/>
				</ListItemIcon>
				<ListItemText primary={ t("menu.run") }/>
				<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+R</div>
			</StyledMenuItem>
		</StyledMenu>
		<IconButton
			color="secondary"
			aria-label="execute"
			onClick={onClick}
			onMouseEnter={onClick}
			edge="start"
		>
			<SportsEsports fontSize='medium'/>
		</IconButton>
	</Toolbar>;
});

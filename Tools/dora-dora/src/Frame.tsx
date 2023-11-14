import { styled, ThemeProvider } from '@mui/material/styles';
import { createTheme } from '@mui/material/styles';
import MuiAppBar, { AppBarProps as MuiAppBarProps } from '@mui/material/AppBar';
import Stack from '@mui/system/Stack';
import { IconButton, ListItemIcon, ListItemText, Toolbar } from '@mui/material';
import SportsEsports from '@mui/icons-material/SportsEsports';
import { BsFillFileEarmarkPlayFill, BsPlayCircle, BsStopCircle, BsSearch, BsTerminal } from 'react-icons/bs';
import { StyledMenu, StyledMenuItem } from './Menu';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import Info from './Info';

export namespace Color {
	export const Background = '#3a3a3a';
	export const BackgroundSecondary = '#2a2a2a';

	export const Primary = '#ccc';
	export const Secondary = '#ccca';

	export const TextPrimary = '#eee';
	export const TextSecondary = '#eee8';

	export const Theme = '#fbc400';
};

const theme = createTheme({
	palette: {
		background: {
			default: Color.Background,
			paper: Color.BackgroundSecondary,
		},
		primary: {
			main: Color.Primary,
		},
		secondary: {
			main: Color.Secondary,
		},
		text: {
			primary: Color.TextPrimary,
			secondary: Color.TextSecondary,
		},
		action: {
			hover: Color.Theme + '66',
			focus: Color.Theme + '44',
			active: Color.Theme + '22',
		}
	}
});

interface EntryProp {
	children?: React.ReactNode;
}
export const Entry = (prop: EntryProp) => {
	return <ThemeProvider theme={theme} children={prop.children}/>
};

export const drawerWidth = 240;

export const Main = styled('main', { shouldForwardProp: (prop) => prop !== 'open' })<{
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

export const StyledStack = styled(Stack, { shouldForwardProp: (prop) => prop !== 'open' })<{
	open?: boolean;
}>(({ theme, open }) => ({
	zIndex: 999,
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

export interface AppBarProps extends MuiAppBarProps {
	open?: boolean;
}

export const AppBar = styled(MuiAppBar, {
	shouldForwardProp: (prop) => prop !== 'open',
})<AppBarProps>(({ theme, open }) => ({
	zIndex: 2,
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

export const DrawerHeader = styled('div')(({ theme }) => ({
	display: 'flex',
	alignItems: 'center',
	padding: theme.spacing(0),
	...theme.mixins.toolbar,
	justifyContent: 'flex-end',
}));

export type PlayControlMode = "Run" | "Run This" | "Stop" | "Go to File" | "View Log";

export interface PlayControlProp {
	width: number;
	onClick: (mode: PlayControlMode) => void;
}

export const PlayControl = (prop: PlayControlProp) => {
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
				<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+P</div>
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
	</Toolbar>
};
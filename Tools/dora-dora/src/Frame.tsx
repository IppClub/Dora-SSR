import { styled, ThemeProvider } from '@mui/material/styles';
import { createTheme } from '@mui/material/styles';
import MuiAppBar, { AppBarProps as MuiAppBarProps } from '@mui/material/AppBar';
import Stack from '@mui/system/Stack';
import { IconButton, ListItemIcon, ListItemText, Toolbar } from '@mui/material';
import SportsEsports from '@mui/icons-material/SportsEsports';
import { AiFillPlayCircle } from 'react-icons/ai';
import { BsFillFileEarmarkPlayFill } from 'react-icons/bs';
import { MdOutlineFileOpen } from 'react-icons/md';
import { StyledMenu, StyledMenuItem } from './Menu';
import { useState } from 'react';

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


export type PlayControlMode = "Run" | "Run This" | "Set Entry";

export interface PlayControlProp {
	onClick: (mode: PlayControlMode) => void;
}

export const PlayControl = (prop: PlayControlProp) => {
	const [open, setOpen] = useState(false);
	const [anchorEl, setAnchorEl] = useState<Element | null>(null);
	const onClose = (mode?: PlayControlMode) => () => {
		setOpen(false);
		if (mode !== undefined) {
			prop.onClick(mode);
		}
	};
	const onClick = (e: React.MouseEvent) => {
		setOpen(true);
		setAnchorEl(e.currentTarget);
	};
	return <Toolbar style={{
		backgroundColor: "#0000",
		width: "65px",
		height: "65px",
		color: "#fff",
		bottom: 0,
		right: 120,
		flexGrow: 1,
		position: 'fixed',
	}}>
		<StyledMenu
			keepMounted
			anchorOrigin={{
				vertical: 'top',
				horizontal: 'left',
			}}
			anchorEl={anchorEl}
			autoFocus={false}
			open={open}
			onClose={onClose()}
		>
			{/*
			<StyledMenuItem>
				<ListItemIcon>
					<AiFillPlayCircle/>
				</ListItemIcon>
				<ListItemText primary="Run" onClick={onClose("Run")}/>
			</StyledMenuItem>
			*/}
			<StyledMenuItem>
				<ListItemIcon>
					<BsFillFileEarmarkPlayFill/>
				</ListItemIcon>
				<ListItemText primary="Run This" onClick={onClose("Run This")}/>
			</StyledMenuItem>
			{/*
			<StyledMenuItem>
				<ListItemIcon>
					<MdOutlineFileOpen/>
				</ListItemIcon>
				<ListItemText primary="Set Entry" onClick={onClose("Set Entry")}/>
			</StyledMenuItem>
			*/}
		</StyledMenu>
		<IconButton
			color="secondary"
			aria-label="execute"
			onClick={onClick}
			edge="start"
		>
			<SportsEsports fontSize='medium'/>
		</IconButton>
	</Toolbar>
};
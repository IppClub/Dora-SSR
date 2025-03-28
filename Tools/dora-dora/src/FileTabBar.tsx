/* Copyright (c) 2017-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { memo, useState } from 'react';
import { styled } from '@mui/material/styles';
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';
import Box from '@mui/material/Box';
import { StyledMenu, StyledMenuItem } from './Menu';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import { IoIosClose } from "react-icons/io";
import {
	AiOutlineClose,
	AiOutlineSave,
	AiFillSave,
	AiFillCloseCircle,
	AiOutlineCloseCircle,
} from 'react-icons/ai';
import { useTranslation } from 'react-i18next';
import { Color } from './Frame';
import { IconButton, Tooltip } from '@mui/material';

export type TabStatus = "normal" | "warning" | "error";

interface TabItem {
	key: string;
	title: string;
	contentModified: string | null;
	status: TabStatus;
}

export interface FileTabBarProps {
	index: number | null;
	items: TabItem[];
	onChange: (index: number) => void;
	onMenuClick: (event: TabMenuEvent) => void;
	onTabClose: (key: string) => void;
};

interface StyledTabsProps {
	children?: React.ReactNode;
	value: number | false;
	scrollButtons?: boolean;
	onChange?: (event: React.SyntheticEvent, newValue: number) => void;
}

export const StyledTabs = styled((props: StyledTabsProps) => (
	<Tabs
		variant='scrollable'
		selectionFollowsFocus
		{...props}
		TabIndicatorProps={{
			children: <span className="MuiTabs-indicatorSpan"/>
		}}
	/>
))({
	margin: 0,
	'& .MuiTabs-indicator': {
		display: 'flex',
		justifyContent: 'center',
		backgroundColor: 'transparent',
	},
	'& .MuiTabs-indicatorSpan': {
		maxWidth: 40,
		width: '100%',
		backgroundColor: Color.Theme,
	},
});

interface StyledTabProps {
	label: string;
	tooltip: string;
	status: TabStatus;
	onContextMenu: (event: React.MouseEvent) => void;
	onTabClose?: (key: string) => void;
}

export const StyledTab = styled((props: StyledTabProps) => {
	const {tooltip, onTabClose} = props;
	const newProps = {...props};
	delete newProps.onTabClose;
	return (
		<div>
			<Tooltip arrow title={props.tooltip}>
				<Tab disableRipple style={{textWrap: 'nowrap'}} {...newProps}/>
			</Tooltip>
			<IconButton size='small' color="secondary" sx={{marginLeft: -3, opacity: 0.6}}
				onPointerDown={() => {
					if (onTabClose) {
						onTabClose(tooltip);
					}
				}}>
				<IoIosClose/>
			</IconButton>
		</div>
	);
})(({ theme, status }) => {
	let color = Color.Secondary;
	let selectedColor = Color.Primary;
	switch (status) {
		case "error":
			color = "rgba(233, 133, 116, 0.7)";
			selectedColor = "rgb(233, 133, 116)";
			break;
		case "warning":
			color = "rgba(200, 177, 136, 0.7)";
			selectedColor = "rgb(200, 177, 136)";
			break;
	}
	return {
		textTransform: 'none',
		fontWeight: theme.typography.fontWeightRegular,
		fontSize: theme.typography.pxToRem(15),
		marginRight: theme.spacing(1),
		color,
		'&.Mui-selected': {
			color: selectedColor,
		},
		'&.Mui-focusVisible': {
			backgroundColor: 'rgba(100, 95, 228, 0.32)',
		},
	};
});

export type TabMenuEvent =
	"Save" |
	"SaveAll" |
	"Close" |
	"CloseOthers" |
	"CloseAll";

export default memo(function FileTabBar(props: FileTabBarProps) {
	const {index, items = [], onChange, onMenuClick, onTabClose} = props;
	const [anchorEl, setAnchorEl] = useState<Element | null>(null);
	const [value, setValue] = useState<number | false>(false);
	const {t} = useTranslation();

	if (index !== null && index !== value) {
		setValue(index);
	} else if (index === null && value !== false) {
		setValue(false);
	}

	const handleChange = (_event: React.ChangeEvent<{}>, newValue: number) => {
		setValue(newValue);
		onChange(newValue);
	};

	const onContextMenu = (event: React.MouseEvent) => {
		setAnchorEl(event.currentTarget);
	};

	const handleClose = (event: TabMenuEvent) => {
		setAnchorEl(null);
		onMenuClick(event);
	};

	return (
		<Box width={'100%'}>
			<StyledTabs
				value={value}
				scrollButtons={items.length > 0}
				onChange={handleChange}
				aria-label="styled tabs"
			>
				{
					items.map((item, index) =>
						<StyledTab
							onContextMenu={onContextMenu}
							onTabClose={onTabClose}
							key={item.key}
							tooltip={item.key}
							label={(index < 9 ? index + 1 + '.' : '') + (item.contentModified !== null ? '*' + item.title : item.title)}
							status={item.status}
						/>
					)
				}
			</StyledTabs>
			<StyledMenu
				id="dora-menu"
				anchorEl={anchorEl}
				keepMounted
				autoFocus={false}
				open={Boolean(anchorEl)}
				onClose={handleClose}
			>
				<StyledMenuItem onClick={() => handleClose('Save')}>
					<ListItemIcon>
						<AiOutlineSave/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.save") }/>
					<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+S</div>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose('SaveAll')}>
					<ListItemIcon>
						<AiFillSave/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.saveAll") }/>
					<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+Shift+S</div>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose('Close')}>
					<ListItemIcon>
						<AiOutlineClose/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.close") }/>
					<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+W</div>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose('CloseAll')}>
					<ListItemIcon>
						<AiFillCloseCircle/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.closeAll") }/>
					<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+Shift+W</div>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose('CloseOthers')}>
					<ListItemIcon>
						<AiOutlineCloseCircle/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.closeOthers") }/>
				</StyledMenuItem>
			</StyledMenu>
		</Box>
	);
}, (prevProps, nextProps) => {
	return prevProps.index === nextProps.index &&
		prevProps.items.length === nextProps.items.length &&
		prevProps.onChange === nextProps.onChange &&
		prevProps.onMenuClick === nextProps.onMenuClick &&
		prevProps.items.every((item, index) => {
			const nextItem = nextProps.items[index];
			return item.key === nextItem.key &&
				item.title === nextItem.title &&
				item.contentModified === nextItem.contentModified &&
				item.status === nextItem.status;
		});
});


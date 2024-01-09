/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { memo, useState } from 'react';
import { StyledMenu, StyledMenuItem } from './Menu';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Refresh from '@mui/icons-material/Refresh';
import {
	AiFillCaretRight,
	AiFillCaretDown,
	AiOutlineFolder,
	AiOutlineFolderOpen,
	AiOutlineFile,
	AiOutlineFileAdd,
	AiOutlineDelete,
	AiOutlineEdit,
	AiOutlineDownload,
	AiFillFileZip,
} from 'react-icons/ai';
import { FcImageFile } from 'react-icons/fc';
import { SiWebassembly } from 'react-icons/si';
import Tree from 'rc-tree';
import "./rctree.css";
import { TreeNodeProps } from "rc-tree/lib/TreeNode";
import { DataNode, EventDataNode, Key } from "rc-tree/lib/interface";
import { NodeDragEventParams } from 'rc-tree/lib/contextTypes';
import luaLogo from './lua.png';
import yueLogo from './yuescript.png';
import tealLogo from './teal.png';
import typescriptLogo from './typescript.png';
import spineLogo from './spine.png';
import { DiCode } from 'react-icons/di';
import { TbSql } from 'react-icons/tb';
import { SiNodered } from 'react-icons/si';
import { VscMarkdown } from 'react-icons/vsc';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import Info from './Info';
import { Color } from './Frame';

export interface TreeDataType extends DataNode {
	key: string;
	dir: boolean;
	root?: boolean;
	title: string;
	children?: TreeDataType[];
};

const switcherIcon = (props: TreeNodeProps) => {
	if (props.data !== undefined) {
		const data = props.data as TreeDataType;
		if (data.root) {
			return <Refresh sx={{
				width: 14,
				height: 14,
			}}/>;
		}
		if (!data.dir) {
			return null;
		} else if (data.children === undefined) {
			return null;
		}
	}
	if (props.expanded) {
		return <AiFillCaretDown/>;
	}
	return <AiFillCaretRight/>;
};

const fileIcon = (props: TreeNodeProps) => {
	if (props.data !== undefined) {
		const data = props.data as TreeDataType;
		if (data.dir) {
			if (props.expanded) {
				return <AiOutlineFolderOpen/>;
			} else {
				return <AiOutlineFolder/>;
			}
		} else {
			switch (Info.path.extname(data.key).toLowerCase()) {
				case ".lua":
					return <img src={luaLogo} alt="lua" width="14px" height="14px"/>;
				case ".tl":
					return <img src={tealLogo} alt="teal" width="12px" height="12px"/>;
				case ".yue":
					return <img src={yueLogo} alt="yue" width="14px" height="14px"/>;
				case ".tsx":
				case ".ts":
					return <img src={typescriptLogo} alt="typescript" width="12px" height="12px"/>;
				case ".xml":
					return <DiCode size={14}/>;
				case ".db":
					return <TbSql size={14}/>;
				case ".md":
					return <VscMarkdown size={14}/>;
				case ".png":
				case ".jpg":
					return <FcImageFile size={14}/>;
				case ".wasm":
					return <SiWebassembly size={12}/>;
				case ".skel":
					return <img src={spineLogo} alt="spine" width="14px" height="14px"/>;
				case ".yarn":
					return <img src="yarn-editor/icon_96x96.png" alt="yarn" width="14px" height="14px"/>;
				case ".vs":
					return <SiNodered size={12}/>;
				case ".zip":
					return <AiFillFileZip color='fac03d'/>;
			}
		}
	}
	return <AiOutlineFile/>;
};

const treeStyle = `
	.rc-tree-child-tree {
		display: block;
	}
	.rc-node-motion {
		transition: all .3s;
		overflow-y: hidden;
		overflow-x: hidden;
	}
`;

const motion = {
	motionName: 'rc-node-motion',
	motionAppear: false,
	onAppearStart: () => ({ height: 0 }),
	onAppearActive: (node: HTMLElement) => ({ height: node.scrollHeight - 25 }),
	onLeaveStart: (node: HTMLElement) => ({ height: node.offsetHeight }),
	onLeaveActive: () => ({ height: 0 }),
};

export type TreeMenuEvent = "New" | "Rename" | "Delete" | "Download" | "Cancel" | "Unzip";

export interface FileTreeProps {
	selectedKeys: string[];
	expandedKeys: string[];
	treeData: TreeDataType[];
	onSelect: (selectedNodes: TreeDataType[]) => void;
	onMenuClick: (event: TreeMenuEvent, data?: TreeDataType) => void;
	onExpand: (key: string[]) => void;
	onDrop: (self: TreeDataType, target: TreeDataType) => void;
};

export default memo(function FileTree(props: FileTreeProps) {
	const {treeData, expandedKeys, selectedKeys} = props;
	const [anchorItem, setAnchorItem] = useState<null | {target: Element, data: TreeDataType}>(null);
	const {t} = useTranslation();

	function onRightClick(info: {
		event: React.MouseEvent;
		node: EventDataNode<TreeDataType>;
	}) {
		setAnchorItem({target: info.event.currentTarget, data: info.node});
	}

	const handleClose = (event: TreeMenuEvent, data?: TreeDataType) => {
		props.onMenuClick(event, data);
		setAnchorItem(null);
	};

	const onSelect = (keys: Key[], info: {selectedNodes: TreeDataType[]}) => {
		props.onSelect(info.selectedNodes);
	};

	const onExpand = (keys: Key[]) => {
		props.onExpand(keys.map(k => k.toString()));
	};

	const onDrop = (info: NodeDragEventParams<TreeDataType> & {
		dragNode: EventDataNode<TreeDataType>;
		dragNodesKeys: Key[];
		dropPosition: number;
		dropToGap: boolean;
	}) => {
		props.onDrop(info.dragNode, info.node);
	};

	return (
		<MacScrollbar
			skin='dark'
			style={{
				paddingLeft: '10px',
				color: Color.Primary,
				fontSize: '14px',
			}}
		>
			<style dangerouslySetInnerHTML={{ __html: treeStyle }}/>
			<StyledMenu
				id="dora-menu"
				anchorEl={anchorItem?.target}
				keepMounted
				autoFocus={false}
				open={Boolean(anchorItem?.target)}
				onClose={() => handleClose("Cancel", anchorItem?.data)}
			>
				<StyledMenuItem onClick={() => handleClose("New", anchorItem?.data)}>
					<ListItemIcon>
						<AiOutlineFileAdd/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.new") }/>
					<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+Shift+N</div>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose("Delete", anchorItem?.data)}>
					<ListItemIcon>
						<AiOutlineDelete/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.delete") }/>
					<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+Shift+D</div>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose("Rename", anchorItem?.data)}>
					<ListItemIcon>
						<AiOutlineEdit/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.rename") }/>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose("Download", anchorItem?.data)}>
					<ListItemIcon>
						<AiOutlineDownload/>
					</ListItemIcon>
					<ListItemText primary={ t("menu.download") }/>
				</StyledMenuItem>
				{anchorItem && Info.path.extname(anchorItem.data.key).toLowerCase() === ".zip" ?
					<StyledMenuItem onClick={() => handleClose("Unzip", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineFolderOpen/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.extract") }/>
					</StyledMenuItem>	: null
				}
			</StyledMenu>
			<Tree
				onRightClick={onRightClick}
				showIcon
				showLine
				virtual
				icon={fileIcon}
				switcherIcon={switcherIcon}
				motion={motion}
				draggable
				onDrop={onDrop}
				expandedKeys={expandedKeys}
				treeData={treeData}
				onSelect={onSelect}
				onExpand={onExpand}
				selectedKeys={selectedKeys}
				dropIndicatorRender={() => <div/>}
			/>
		</MacScrollbar>
	);
});

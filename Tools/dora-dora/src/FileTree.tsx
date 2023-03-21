import React, { useState } from 'react';
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
	AiOutlineUpload,
} from 'react-icons/ai';
import Tree from 'rc-tree';
import "./rctree.css";
import { TreeNodeProps } from "rc-tree/lib/TreeNode";
import { DataNode, EventDataNode, Key } from "rc-tree/lib/interface";
import { NodeDragEventParams } from 'rc-tree/lib/contextTypes';
import { Path } from './Path';
import luaLogo from './lua.png';
import yueLogo from './yuescript.png';
import tealLogo from './teal.png';
import { DiCode } from 'react-icons/di';
import { MacScrollbar } from 'mac-scrollbar';
import 'mac-scrollbar/dist/mac-scrollbar.css';

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
			const App: {path: Path} = require("./App");
			switch (App.path.extname(data.key).toLowerCase()) {
				case ".lua":
					return <img src={luaLogo} alt="lua" width="14px" height="14px"/>;
				case ".tl":
					return <img src={tealLogo} alt="teal" width="14px" height="14px"/>;
				case ".yue":
					return <img src={yueLogo} alt="yue" width="14px" height="14px"/>;
				case ".xml":
					return <DiCode size={14}/>;
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

export type TreeMenuEvent = "New" | "Rename" | "Upload" | "Delete" | "Cancel";

export interface FileTreeProps {
	selectedKeys: string[];
	expandedKeys: string[];
	treeData: TreeDataType[];
	onSelect: (selectedNodes: TreeDataType[]) => void;
	onMenuClick: (event: TreeMenuEvent, data?: TreeDataType) => void;
	onExpand: (key: string[]) => void;
	onDrop: (self: TreeDataType, target: TreeDataType) => void;
};

export default function FileTree(props: FileTreeProps) {
	const {treeData, expandedKeys, selectedKeys} = props;
	const [anchorItem, setAnchorItem] = useState<null | {target: Element, data: TreeDataType}>(null);

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
				color: '#fff',
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
					<ListItemText primary="New"/>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose("Upload", anchorItem?.data)}>
					<ListItemIcon>
						<AiOutlineUpload/>
					</ListItemIcon>
					<ListItemText primary="Upload"/>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose("Rename", anchorItem?.data)}>
					<ListItemIcon>
						<AiOutlineEdit/>
					</ListItemIcon>
					<ListItemText primary="Rename"/>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose("Delete", anchorItem?.data)}>
					<ListItemIcon>
						<AiOutlineDelete/>
					</ListItemIcon>
					<ListItemText primary="Delete"/>
				</StyledMenuItem>
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
};

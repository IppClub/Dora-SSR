import React, { useState, useEffect } from 'react';
import { StyledMenu, StyledMenuItem } from './Menu';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import {
	AiFillCaretRight,
	AiFillCaretDown,
	AiOutlineFolder,
	AiOutlineFolderOpen,
	AiOutlineFile,
	AiOutlineFileAdd,
	AiOutlineDelete,
	AiOutlineEdit,
} from 'react-icons/ai';
import Tree from 'rc-tree';
import "./rctree.css";
import { TreeNodeProps } from "rc-tree/lib/TreeNode";
import { EventDataNode, Key } from "rc-tree/lib/interface";
import Post from './Post';

const switcherIcon = (props: TreeNodeProps) => {
	if (props.isLeaf) {
		return null;
	} else {
		if (props.expanded) {
			return <AiFillCaretDown/>;
		}
		return <AiFillCaretRight/>;
	}
};

const fileIcon = (props: TreeNodeProps) => {
	if (props.data?.children) {
		if (props.expanded) {
			return <AiOutlineFolderOpen/>;
		} else {
			return <AiOutlineFolder/>;
		}
	} else {
		return <AiOutlineFile/>;
	}
};

const treeStyle = `
	.rc-tree-child-tree {
		display: block;
	}
	.rc-node-motion {
		transition: all .3s;
		overflow-y: hidden;
	}
`;

const motion = {
	motionName: 'rc-node-motion',
	motionAppear: false,
	onAppearStart: () => ({ height: 0 }),
	onAppearActive: (node: HTMLElement) => ({ height: node.scrollHeight }),
	onLeaveStart: (node: HTMLElement) => ({ height: node.offsetHeight }),
	onLeaveActive: () => ({ height: 0 }),
 };

interface TreeDataType {
	key: string;
	title: string;
	children?: TreeDataType[]
};

export type TreeMenuEvent = "New" | "Rename" | "Delete";

export interface FileTreeProps {
	onSelect: (key: string, title: string) => void;
	onMenuClick: (event: TreeMenuEvent) => void;
};

export default function FileTree(props: FileTreeProps) {
	const [treeData, setTreeData] = useState<TreeDataType[]>([]);
	const [anchorEl, setAnchorEl] = useState<null | Element>(null);

	useEffect(() => {
		Post('/assets').then((value: TreeDataType[])=>{
			setTreeData(value);
		})
	}, []);

	function onRightClick(info: {
		event: React.MouseEvent;
		node: EventDataNode<TreeDataType>;
	}) {
		setAnchorEl(info.event.currentTarget);
	}

	const handleClose = (event: TreeMenuEvent) => {
		props.onMenuClick(event);
		setAnchorEl(null);
	};

	const onSelect = (_keys: Key[], info: {selectedNodes: TreeDataType[]}) => {
		const node = info.selectedNodes[0];
		props.onSelect(node.key, node.title);
	};

	return (
		<div
			style={{
				paddingLeft: '10px',
				color: '#fff',
				fontSize: '14px',
				width: '100%',
				height: '100%',
				overflow: 'scroll'
			}}
		>
			<style dangerouslySetInnerHTML={{ __html: treeStyle }}/>
			<StyledMenu
				id="dora-menu"
				anchorEl={anchorEl}
				keepMounted
				open={Boolean(anchorEl)}
				onClose={handleClose}
			>
				<StyledMenuItem onClick={() => handleClose("New")}>
					<ListItemIcon>
						<AiOutlineFileAdd/>
					</ListItemIcon>
					<ListItemText primary="New"/>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose("Rename")}>
					<ListItemIcon>
						<AiOutlineEdit/>
					</ListItemIcon>
					<ListItemText primary="Rename"/>
				</StyledMenuItem>
				<StyledMenuItem onClick={() => handleClose("Delete")}>
					<ListItemIcon>
						<AiOutlineDelete/>
					</ListItemIcon>
					<ListItemText primary="Delete"/>
				</StyledMenuItem>
			</StyledMenu>
			<Tree
				onRightClick={onRightClick}
				showIcon={true}
				showLine={true}
				icon={fileIcon}
				switcherIcon={switcherIcon}
				motion={motion}
				draggable
				treeData={treeData}
				onSelect={onSelect}
			/>
		</div>
	);
};
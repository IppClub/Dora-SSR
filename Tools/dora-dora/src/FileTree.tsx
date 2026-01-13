/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

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
	AiOutlineSetting,
	AiFillFileZip,
	AiOutlineUpload,
} from 'react-icons/ai';
import { RiListIndefinite } from "react-icons/ri";
import { RxClipboardCopy } from "react-icons/rx";
import { GoFileCode, GoChecklist } from "react-icons/go";
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
import blocklyLogo from './blockly.png';
import spineLogo from './spine.png';
import waLogo from './wa.svg';
import tic80Logo from './tic80.png';
import { DiCode } from 'react-icons/di';
import { TbMoodConfuzed, TbSql } from 'react-icons/tb';
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
	builtin?: boolean;
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
				case ".bl":
					return <img src={blocklyLogo} alt="blockly" width="12px" height="12px"/>;
				case ".vs":
					return <SiNodered size={12}/>;
				case ".zip":
					return <AiFillFileZip color='fac03d'/>;
				case ".wa":
					return <img src={waLogo} alt="wa" width="12px" height="12px"/>;
				case ".tic":
					return <img src={tic80Logo} alt="tic80" width="14px" height="14px"/>;
				case ".mod":
					return <AiOutlineSetting size={14}/>;
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

export type TreeMenuEvent = "New" | "Rename" | "Delete" | "Upload" | "Download" | "Cancel" | "Unzip" | "View Compiled" | "Copy Path" | "Build" | "Obfuscate" | "Declaration";

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
	const [menuOpen, setMenuOpen] = useState(false);
	const {t} = useTranslation();

	function onRightClick(info: {
		event: React.MouseEvent;
		node: EventDataNode<TreeDataType>;
	}) {
		setAnchorItem({target: info.event.currentTarget, data: info.node});
		setMenuOpen(true);
	}

	const handleClose = (event: TreeMenuEvent, data?: TreeDataType) => {
		props.onMenuClick(event, data);
		setMenuOpen(false);
	};

	const onSelect = (_keys: Key[], info: {selectedNodes: TreeDataType[]}) => {
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

	const ext = anchorItem ? Info.path.extname(anchorItem.data.key).toLowerCase() : "";
	const isRoot = anchorItem?.data.root ?? false;
	const isBuiltin = anchorItem?.data.builtin ?? false;
	const enableNew = (isRoot || !isBuiltin) || Info.engineDev;
	const enableDelete = (!isRoot && !isBuiltin) || Info.engineDev;
	const enableRename = (!isRoot && !isBuiltin) || Info.engineDev;
	const enableUpload = isRoot || !isBuiltin;
	const enableDownload = isRoot || !isBuiltin;
	const enableCopyPath = (!isRoot || isBuiltin) || Info.engineDev;
	const enableUnzip = !isRoot && !isBuiltin;
	const enableBuild = (isRoot || !isBuiltin) || Info.engineDev;
	const enableObfuscate = (isRoot || !isBuiltin) || Info.engineDev;
	const enableViewCompiled = (!isRoot && !isBuiltin) || Info.engineDev;
	const enableDeclaration = (!isRoot && !isBuiltin && (ext === ".ts" || ext === ".tsx")) || Info.engineDev;

	return (
		<MacScrollbar
			skin='dark'
			style={{
				color: Color.Primary,
				fontSize: '14px',
				width: 'calc(100% - 4px)',
				height: '100%',
			}}
		>
			<style dangerouslySetInnerHTML={{ __html: treeStyle }}/>
			<StyledMenu
				id="dora-menu"
				anchorEl={anchorItem?.target}
				keepMounted
				autoFocus={false}
				open={menuOpen}
				onClose={() => handleClose("Cancel", anchorItem?.data)}
				slotProps={{
					transition: {
						onExited: () => setAnchorItem(null),
					},
				}}
			>
				{enableNew ?
					<StyledMenuItem onClick={() => handleClose("New", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineFileAdd/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.new") }/>
						<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+Shift+N</div>
					</StyledMenuItem> : null
				}
				{enableDelete ?
					<StyledMenuItem onClick={() => handleClose("Delete", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineDelete/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.delete") }/>
						<div style={{fontSize: 10, color: Color.TextSecondary}}>Mod+Shift+D</div>
					</StyledMenuItem> : null
				}
				{enableRename ?
					<StyledMenuItem onClick={() => handleClose("Rename", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineEdit/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.rename") }/>
					</StyledMenuItem> : null
				}
				{enableUpload ?
					<StyledMenuItem onClick={() => handleClose("Upload", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineUpload/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.upload") }/>
					</StyledMenuItem> : null
				}
				{enableDownload ?
					<StyledMenuItem onClick={() => handleClose("Download", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineDownload/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.download") }/>
					</StyledMenuItem> : null
				}
				{enableCopyPath ?
					<StyledMenuItem onClick={() => handleClose("Copy Path", anchorItem?.data)}>
						<ListItemIcon>
							<RxClipboardCopy/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.copyPath") }/>
					</StyledMenuItem> : null
				}
				{enableUnzip && anchorItem && ext === ".zip" ?
					<StyledMenuItem onClick={() => handleClose("Unzip", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineFolderOpen/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.extract") }/>
					</StyledMenuItem> : null
				}
				{enableBuild && anchorItem &&
					((Info.path.extname(
						Info.path.basename(anchorItem.data.key, ext)
					) === "" &&
					(
						ext === ".yue" ||
						ext === ".tl" ||
						ext === ".ts" ||
						ext === ".tsx" ||
						ext === ".xml" ||
						ext === ".wa" ||
						ext === ".mod"
					)) || anchorItem.data.dir) ?
					<StyledMenuItem onClick={() => handleClose("Build", anchorItem?.data)}>
						<ListItemIcon>
							<GoChecklist/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.build") }/>
					</StyledMenuItem> : null
				}
				{enableDeclaration && anchorItem ?
					<StyledMenuItem onClick={() => handleClose("Declaration", anchorItem.data)}>
						<ListItemIcon>
							<RiListIndefinite/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.declaration") }/>
					</StyledMenuItem> : null
				}
				{enableObfuscate && anchorItem && anchorItem.data.dir ?
					<StyledMenuItem onClick={() => handleClose("Obfuscate", anchorItem?.data)}>
						<ListItemIcon>
							<TbMoodConfuzed/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.obfuscate") }/>
					</StyledMenuItem> : null
				}
				{enableViewCompiled && anchorItem &&
					Info.path.extname(
						Info.path.basename(anchorItem.data.key, ext)
					) === "" &&
					(
						ext === ".yue" ||
						ext === ".tl" ||
						ext === ".ts" ||
						ext === ".tsx" ||
						ext === ".xml"
					) ?
					<StyledMenuItem onClick={() => handleClose("View Compiled", anchorItem?.data)}>
						<ListItemIcon>
							<GoFileCode/>
						</ListItemIcon>
						<ListItemText primary={ t("menu.viewCompiled", {lang: "Lua"}) }/>
					</StyledMenuItem> : null
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
}, (prev, next) => {
	if (prev.selectedKeys.length !== next.selectedKeys.length) {
		return false;
	}
	prev.selectedKeys.sort();
	next.selectedKeys.sort();
	for (let i = 0; i < prev.selectedKeys.length; i++) {
		if (prev.selectedKeys[i] !== next.selectedKeys[i]) {
			return false;
		}
	}
	if (prev.expandedKeys.length !== next.expandedKeys.length) {
		return false;
	}
	prev.expandedKeys.sort();
	next.expandedKeys.sort();
	for (let i = 0; i < prev.expandedKeys.length; i++) {
		if (prev.expandedKeys[i] !== next.expandedKeys[i]) {
			return false;
		}
	}
	return prev.treeData === next.treeData &&
		prev.onSelect === next.onSelect &&
		prev.onMenuClick === next.onMenuClick &&
		prev.onExpand === next.onExpand &&
		prev.onDrop === next.onDrop;
});

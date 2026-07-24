/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { memo, useEffect, useMemo, useRef, useState } from 'react';
import { StyledMenu, StyledMenuItem } from './Menu';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Refresh from '@mui/icons-material/Refresh';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import {
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
	AiOutlineComment,
} from 'react-icons/ai';
import { RiListIndefinite } from "react-icons/ri";
import { RxClipboardCopy } from "react-icons/rx";
import { GoFileCode, GoChecklist } from "react-icons/go";
import { FcImageFile } from 'react-icons/fc';
import { SiWebassembly } from 'react-icons/si';
import { BsGrid3X3Gap } from 'react-icons/bs';
import { CaretDownFilled } from '@ant-design/icons';
import { ConfigProvider, Tree, theme as antdTheme } from 'antd';
import type { TreeDataNode, TreeNodeProps, TreeProps } from 'antd';
import luaLogo from './lua.png';
import yueLogo from './yuescript.png';
import tealLogo from './teal.png';
import typescriptLogo from './typescript.png';
import blocklyLogo from './blockly.png';
import spineLogo from './spine.png';
import waLogo from './wa.svg';
import tic80Logo from './tic80.png';
import yarnLogo from './yarn.png';
import doraAnimationLogo from './dora-animation.png';
import doraBodyLogo from './dora-body.png';
import { DiCode } from 'react-icons/di';
import { TbMoodConfuzed, TbSql } from 'react-icons/tb';
import { SiNodered } from 'react-icons/si';
import { VscMarkdown } from 'react-icons/vsc';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import Info from './Info';
import { Color } from './Theme';

export interface TreeDataType extends TreeDataNode {
	key: string;
	dir: boolean;
	root?: boolean;
	builtin?: boolean;
	title: string;
	children?: TreeDataType[];
};

const buildVisibleTreeData = (
	nodes: TreeDataType[],
	expandedKeys: ReadonlySet<string>
): TreeDataType[] => nodes.map((node) => {
	if (!node.dir) {
		return node.isLeaf ? node : { ...node, isLeaf: true };
	}
	if (node.children === undefined || node.children.length === 0) {
		return node;
	}
	return {
		...node,
		isLeaf: false,
		children: expandedKeys.has(node.key)
			? buildVisibleTreeData(node.children, expandedKeys)
			: undefined,
	};
});

const collectLoadedKeys = (nodes: TreeDataType[], loadedKeys: string[]) => {
	for (const node of nodes) {
		if (node.dir && node.children !== undefined) {
			loadedKeys.push(node.key);
			collectLoadedKeys(node.children, loadedKeys);
		}
	}
};

const switcherIcon = (props: TreeNodeProps) => {
	if (props.isLeaf) return null;
	if ((props.data as TreeDataType | undefined)?.root) {
		return <Refresh sx={{ fontSize: 14 }} />;
	}
	return (
		<CaretDownFilled style={{
			fontSize: 10,
			transform: `rotate(${props.expanded ? 0 : -90}deg)`,
			transition: 'transform 0.3s',
		}} />
	);
};

const fileIcon = (props: TreeNodeProps) => {
	if (props.data !== undefined) {
		const data = props.data as TreeDataType;
		if (data.dir) {
			if (props.expanded && data.children !== undefined && data.children.length > 0) {
				return <AiOutlineFolderOpen />;
			} else {
				return <AiOutlineFolder />;
			}
		} else {
			if (data.key.toLowerCase().endsWith(".b.lua")) {
				return <img src={doraBodyLogo} alt="body" width="14px" height="14px" style={{ objectFit: 'contain' }} />;
			}
			switch (Info.path.extname(data.key).toLowerCase()) {
				case ".lua":
					return <img src={luaLogo} alt="lua" width="14px" height="14px" />;
				case ".tl":
					return <img src={tealLogo} alt="teal" width="12px" height="12px" />;
				case ".yue":
					return <img src={yueLogo} alt="yue" width="14px" height="14px" />;
				case ".tsx":
				case ".ts":
					return <img src={typescriptLogo} alt="typescript" width="12px" height="12px" />;
				case ".xml":
					return <DiCode size={14} />;
				case ".model":
					return <img src={doraAnimationLogo} alt="model" width="14px" height="14px" style={{ objectFit: 'contain' }} />;
				case ".par":
					return <AutoAwesomeIcon sx={{ fontSize: 14, color: "#fac03d" }} />;
				case ".clip":
					return <BsGrid3X3Gap size={13} color="#5cc8ff" />;
				case ".db":
					return <TbSql size={14} />;
				case ".md":
					return <VscMarkdown size={14} />;
				case ".png":
				case ".jpg":
					return <FcImageFile size={14} />;
				case ".wasm":
					return <SiWebassembly size={12} />;
				case ".skel":
					return <img src={spineLogo} alt="spine" width="14px" height="14px" />;
				case ".yarn":
					return <img src={yarnLogo} alt="yarn" width="14px" height="14px" />;
				case ".bl":
					return <img src={blocklyLogo} alt="blockly" width="12px" height="12px" />;
				case ".vs":
					return <SiNodered size={12} />;
				case ".zip":
					return <AiFillFileZip color='fac03d' />;
				case ".wa":
					return <img src={waLogo} alt="wa" width="12px" height="12px" />;
				case ".tic":
					return <img src={tic80Logo} alt="tic80" width="14px" height="14px" />;
				case ".mod":
					return <AiOutlineSetting size={14} />;
			}
		}
	}
	return <AiOutlineFile />;
};

export type TreeMenuEvent = "New" | "Rename" | "Delete" | "Upload" | "Download" | "Cancel" | "Unzip" | "Pack Atlas" | "View Compiled" | "Copy Path" | "Build" | "Obfuscate" | "Declaration" | "Update Dora" | "Dora";

export interface FileTreeProps {
	selectedKeys: string[];
	expandedKeys: string[];
	treeData: TreeDataType[];
	scrollRequest: number;
	onSelect: (selectedNodes: TreeDataType[]) => void;
	onMenuClick: (event: TreeMenuEvent, data?: TreeDataType) => void;
	onExpand: (key: string[], info?: { node: TreeDataType; expanded: boolean }) => void;
	loadData: (node: TreeDataType) => Promise<void>;
	onDrop: (self: TreeDataType, target: TreeDataType) => void;
};

export default memo(function FileTree(props: FileTreeProps) {
	const { treeData, expandedKeys, selectedKeys, scrollRequest } = props;
	const visibleTreeData = useMemo(
		() => buildVisibleTreeData(treeData, new Set(expandedKeys)),
		[treeData, expandedKeys]
	);
	const loadedKeys = useMemo(() => {
		const keys: string[] = [];
		collectLoadedKeys(treeData, keys);
		return keys;
	}, [treeData]);
	const scrollContainerRef = useRef<HTMLElement>(null);
	const [anchorItem, setAnchorItem] = useState<null | { target: Element, data: TreeDataType }>(null);
	const [menuOpen, setMenuOpen] = useState(false);
	const { t } = useTranslation();

	useEffect(() => {
		if (scrollRequest === 0) return;
		const frame = window.requestAnimationFrame(() => {
			const selectedItem = scrollContainerRef.current?.querySelector<HTMLElement>(
				'[role="treeitem"][aria-selected="true"]'
			);
			selectedItem?.scrollIntoView({
				block: "nearest",
				inline: "nearest",
			});
		});
		return () => window.cancelAnimationFrame(frame);
	}, [scrollRequest]);

	const onRightClick: NonNullable<TreeProps<TreeDataType>["onRightClick"]> = (info) => {
		setAnchorItem({ target: info.event.currentTarget, data: info.node });
		setMenuOpen(true);
	};

	const handleClose = (event: TreeMenuEvent, data?: TreeDataType) => {
		props.onMenuClick(event, data);
		setMenuOpen(false);
	};

	const onSelect: NonNullable<TreeProps<TreeDataType>["onSelect"]> = (_keys, info) => {
		props.onSelect(info.selectedNodes);
	};

	const onExpand: NonNullable<TreeProps<TreeDataType>["onExpand"]> = (keys, info) => {
		props.onExpand(
			keys.map(k => k.toString()),
			{ node: info.node, expanded: info.expanded }
		);
	};

	const onDrop: NonNullable<TreeProps<TreeDataType>["onDrop"]> = (info) => {
		props.onDrop(info.dragNode, info.node);
	};

	const loadData: NonNullable<TreeProps<TreeDataType>["loadData"]> = (node) => {
		return props.loadData(node);
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
	const enablePackAtlas = anchorItem?.data.dir === true && ext === ".clips" && (((!isRoot && !isBuiltin) || Info.engineDev));
	const enableBuild = (isRoot || !isBuiltin) || Info.engineDev;
	const enableObfuscate = (isRoot || !isBuiltin) || Info.engineDev;
	const enableViewCompiled = (!isRoot && !isBuiltin) || Info.engineDev;
	const enableDeclaration =
		anchorItem?.data.dir !== true &&
		(ext === ".ts" || ext === ".tsx") &&
		((!isRoot && !isBuiltin) || Info.engineDev);
	const enableUpdateDora = ext === ".mod" && (((!isRoot && !isBuiltin) || Info.engineDev));

	return (
		<MacScrollbar
			ref={scrollContainerRef}
			skin='dark'
			style={{
				color: Color.Primary,
				fontSize: '14px',
				width: 'calc(100% - 4px)',
				height: '100%',
			}}
		>
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
							<AiOutlineFileAdd />
						</ListItemIcon>
						<ListItemText primary={t("menu.new")} />
						<div style={{ fontSize: 10, color: Color.TextSecondary }}>Mod+Shift+N</div>
					</StyledMenuItem> : null
				}
				{enableDelete ?
					<StyledMenuItem onClick={() => handleClose("Delete", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineDelete />
						</ListItemIcon>
						<ListItemText primary={t("menu.delete")} />
						<div style={{ fontSize: 10, color: Color.TextSecondary }}>Mod+Shift+D</div>
					</StyledMenuItem> : null
				}
				{enableRename ?
					<StyledMenuItem onClick={() => handleClose("Rename", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineEdit />
						</ListItemIcon>
						<ListItemText primary={t("menu.rename")} />
					</StyledMenuItem> : null
				}
				{enableUpload ?
					<StyledMenuItem onClick={() => handleClose("Upload", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineUpload />
						</ListItemIcon>
						<ListItemText primary={t("menu.upload")} />
					</StyledMenuItem> : null
				}
				{enableDownload ?
					<StyledMenuItem onClick={() => handleClose("Download", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineDownload />
						</ListItemIcon>
						<ListItemText primary={t("menu.download")} />
					</StyledMenuItem> : null
				}
				{enableCopyPath ?
					<StyledMenuItem onClick={() => handleClose("Copy Path", anchorItem?.data)}>
						<ListItemIcon>
							<RxClipboardCopy />
						</ListItemIcon>
						<ListItemText primary={t("menu.copyPath")} />
					</StyledMenuItem> : null
				}
				{enableUnzip && anchorItem && ext === ".zip" ?
					<StyledMenuItem onClick={() => handleClose("Unzip", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineFolderOpen />
						</ListItemIcon>
						<ListItemText primary={t("menu.extract")} />
					</StyledMenuItem> : null
				}
				{enablePackAtlas && anchorItem ?
					<StyledMenuItem onClick={() => handleClose("Pack Atlas", anchorItem.data)}>
						<ListItemIcon>
							<BsGrid3X3Gap />
						</ListItemIcon>
						<ListItemText primary={t("menu.packAtlas")} />
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
							<GoChecklist />
						</ListItemIcon>
						<ListItemText primary={t("menu.build")} />
					</StyledMenuItem> : null
				}
				{enableDeclaration && anchorItem ?
					<StyledMenuItem onClick={() => handleClose("Declaration", anchorItem.data)}>
						<ListItemIcon>
							<RiListIndefinite />
						</ListItemIcon>
						<ListItemText primary={t("menu.declaration")} />
					</StyledMenuItem> : null
				}
				{enableUpdateDora && anchorItem ?
					<StyledMenuItem onClick={() => handleClose("Update Dora", anchorItem.data)}>
						<ListItemIcon>
							<Refresh />
						</ListItemIcon>
						<ListItemText primary={t("menu.updateDora")} />
					</StyledMenuItem> : null
				}
				{enableObfuscate && anchorItem && anchorItem.data.dir ?
					<StyledMenuItem onClick={() => handleClose("Obfuscate", anchorItem?.data)}>
						<ListItemIcon>
							<TbMoodConfuzed />
						</ListItemIcon>
						<ListItemText primary={t("menu.obfuscate")} />
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
							<GoFileCode />
						</ListItemIcon>
						<ListItemText primary={t("menu.viewCompiled", { lang: "Lua" })} />
					</StyledMenuItem> : null
				}
				{anchorItem ?
					<StyledMenuItem onClick={() => handleClose("Dora", anchorItem?.data)}>
						<ListItemIcon>
							<AiOutlineComment />
						</ListItemIcon>
						<ListItemText primary="Dora!" />
					</StyledMenuItem> : null
				}
			</StyledMenu>
			<ConfigProvider
				theme={{
					algorithm: antdTheme.darkAlgorithm,
					token: {
						colorPrimary: Color.Theme,
						colorBgContainer: "transparent",
						colorText: Color.Primary,
						paddingXS: 4,
					},
					components: {
						Tree: {
							titleHeight: 24,
							indentSize: 18,
							nodeHoverBg: Color.Theme + "22",
							nodeHoverColor: Color.TextPrimary,
							nodeSelectedBg: Color.Theme + "66",
							nodeSelectedColor: Color.TextPrimary,
						},
					},
				}}
			>
				<Tree<TreeDataType>
					onRightClick={onRightClick}
					showIcon
					showLine
					virtual
					motion={false}
					icon={fileIcon}
					switcherIcon={switcherIcon}
					switcherLoadingIcon={<CaretDownFilled style={{ fontSize: 10 }} />}
					draggable={{ icon: false }}
					onDrop={onDrop}
					expandedKeys={expandedKeys}
					treeData={visibleTreeData}
					onSelect={onSelect}
					onExpand={onExpand}
					loadData={loadData}
					loadedKeys={loadedKeys}
					onLoad={() => { }}
					selectedKeys={selectedKeys}
					dropIndicatorRender={() => <div />}
					styles={{
						item: {
							whiteSpace: "nowrap",
						},
						itemIcon: {
							display: "inline-flex",
							alignItems: "center",
							justifyContent: "center",
							width: 14,
							flexShrink: 0,
							marginInlineEnd: 4,
							verticalAlign: "top",
						},
						itemTitle: {
							whiteSpace: "nowrap",
						},
					}}
					style={{
						background: "transparent",
						padding: 10,
					}}
				/>
			</ConfigProvider>
		</MacScrollbar>
	);
}, (prev, next) => {
	if (prev.selectedKeys.length !== next.selectedKeys.length) {
		return false;
	}
	const prevSelectedKeys = [...prev.selectedKeys].sort();
	const nextSelectedKeys = [...next.selectedKeys].sort();
	for (let i = 0; i < prevSelectedKeys.length; i++) {
		if (prevSelectedKeys[i] !== nextSelectedKeys[i]) {
			return false;
		}
	}
	if (prev.expandedKeys.length !== next.expandedKeys.length) {
		return false;
	}
	const prevExpandedKeys = [...prev.expandedKeys].sort();
	const nextExpandedKeys = [...next.expandedKeys].sort();
	for (let i = 0; i < prevExpandedKeys.length; i++) {
		if (prevExpandedKeys[i] !== nextExpandedKeys[i]) {
			return false;
		}
	}
	return prev.treeData === next.treeData &&
		prev.scrollRequest === next.scrollRequest &&
		prev.onSelect === next.onSelect &&
		prev.onMenuClick === next.onMenuClick &&
		prev.onExpand === next.onExpand &&
		prev.loadData === next.loadData &&
		prev.onDrop === next.onDrop;
});

/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { memo, useEffect, useMemo, useRef, useState } from 'react';
import { StyledMenu, StyledMenuItem } from './Menu';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import GlobalStyles from '@mui/material/GlobalStyles';
import IconButton from '@mui/material/IconButton';
import Tooltip from '@mui/material/Tooltip';
import Badge from '@mui/material/Badge';
import Stack from '@mui/material/Stack';
import Refresh from '@mui/icons-material/Refresh';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import CheckBoxOutlineBlankIcon from '@mui/icons-material/CheckBoxOutlineBlank';
import CheckBoxIcon from '@mui/icons-material/CheckBox';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import ContentCopyIcon from '@mui/icons-material/ContentCopy';
import DriveFileMoveIcon from '@mui/icons-material/DriveFileMove';
import CloseIcon from '@mui/icons-material/Close';
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
	const disableCheckbox = node.root || node.builtin;
	if (!node.dir) {
		if (node.isLeaf && !disableCheckbox) return node;
		return { ...node, isLeaf: true, disableCheckbox };
	}
	if (node.children === undefined || node.children.length === 0) {
		return disableCheckbox ? { ...node, disableCheckbox } : node;
	}
	return {
		...node,
		disableCheckbox,
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
	checkedKeys: string[];
	expandedKeys: string[];
	treeData: TreeDataType[];
	firstProjectTourTargetKey?: string;
	firstProjectTourWorkspaceRightClickOnly?: boolean;
	scrollRequest: number;
	resizing: boolean;
	multiSelectMode: boolean;
	batchTargetMode: "copy" | "move" | null;
	onSelect: (selectedNodes: TreeDataType[]) => void;
	onCheck: (checkedKeys: string[]) => void;
	onToggleMultiSelect: () => void;
	onBatchAction: (action: "delete" | "copy" | "move") => void;
	onBatchTarget: (target: TreeDataType) => void;
	onCancelBatchTarget: () => void;
	onMenuClick: (event: TreeMenuEvent, data?: TreeDataType) => void;
	onContextMenuOpen?: (data: TreeDataType) => void;
	onExpand: (key: string[], info?: { node: TreeDataType; expanded: boolean }) => void;
	loadData: (node: TreeDataType) => Promise<void>;
	onDrop: (self: TreeDataType, target: TreeDataType) => void;
};

export default memo(function FileTree(props: FileTreeProps) {
	const {
		treeData,
		expandedKeys,
		selectedKeys,
		checkedKeys,
		scrollRequest,
		resizing,
		multiSelectMode,
		batchTargetMode,
	} = props;
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
	const treeRef = useRef<React.ComponentRef<typeof Tree>>(null);
	const [anchorItem, setAnchorItem] = useState<null | { target: Element, data: TreeDataType }>(null);
	const [menuOpen, setMenuOpen] = useState(false);
	const [suppressResizeScrollbar, setSuppressResizeScrollbar] = useState(false);
	const { t } = useTranslation();

	useEffect(() => {
		if (resizing) {
			setSuppressResizeScrollbar(true);
			return;
		}
		if (!suppressResizeScrollbar) return;
		const timer = window.setTimeout(() => {
			setSuppressResizeScrollbar(false);
		}, 1000);
		return () => window.clearTimeout(timer);
	}, [resizing, suppressResizeScrollbar]);

	useEffect(() => {
		if (scrollRequest === 0) return;
		const frame = window.requestAnimationFrame(() => {
			const selectedKey = selectedKeys.at(0);
			if (selectedKey !== undefined) {
				treeRef.current?.scrollTo({
					key: selectedKey,
					align: "auto",
				});
			}
			const selectedItem = scrollContainerRef.current?.querySelector<HTMLElement>(
				'[role="treeitem"][aria-selected="true"]'
			);
			selectedItem?.scrollIntoView({
				block: "nearest",
				inline: "nearest",
			});
		});
		return () => window.cancelAnimationFrame(frame);
	}, [scrollRequest, selectedKeys]);

	useEffect(() => {
		const container = scrollContainerRef.current;
		if (container === null) return;
		const removeNodeTooltips = () => {
			for (const node of container.querySelectorAll<HTMLElement>(
				".ant-tree-node-content-wrapper[title]"
			)) {
				node.removeAttribute("title");
			}
		};
		removeNodeTooltips();
		const observer = new MutationObserver(removeNodeTooltips);
		observer.observe(container, {
			childList: true,
			subtree: true,
			attributes: true,
			attributeFilter: ["title"],
		});
		return () => observer.disconnect();
	}, []);

	const onRightClick: NonNullable<TreeProps<TreeDataType>["onRightClick"]> = (info) => {
		if (multiSelectMode) return;
		if (info.node.key === props.firstProjectTourTargetKey) return;
		setAnchorItem({ target: info.event.currentTarget, data: info.node });
		setMenuOpen(true);
	};

	const handleClose = (event: TreeMenuEvent, data?: TreeDataType) => {
		props.onMenuClick(event, data);
		setMenuOpen(false);
	};

	const onSelect: NonNullable<TreeProps<TreeDataType>["onSelect"]> = (_keys, info) => {
		if (
			props.firstProjectTourWorkspaceRightClickOnly
			&& info.node.root
			&& !info.node.builtin
		) {
			return;
		}
		if (batchTargetMode !== null) {
			if (info.node.dir) props.onBatchTarget(info.node);
			return;
		}
		if (multiSelectMode) {
			const key = info.node.key.toString();
			props.onCheck(checkedKeys.includes(key)
				? checkedKeys.filter(item => item !== key)
				: [...checkedKeys, key]
			);
			return;
		}
		props.onSelect(
			info.node.key === props.firstProjectTourTargetKey
				? [info.node]
				: info.selectedNodes
		);
	};

	const onCheck: NonNullable<TreeProps<TreeDataType>["onCheck"]> = (keys, info) => {
		if (batchTargetMode !== null) {
			if (info.node.dir) props.onBatchTarget(info.node);
			return;
		}
		const checked = Array.isArray(keys) ? keys : keys.checked;
		props.onCheck(checked.map(key => key.toString()));
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
		<div style={{ position: "relative", width: "100%", height: "100%" }}>
			<MacScrollbar
				ref={scrollContainerRef}
				className={suppressResizeScrollbar ? "dora-resource-tree-scrollbar-resizing" : undefined}
				onScroll={() => {
					if (!resizing) setSuppressResizeScrollbar(false);
				}}
				skin='dark'
				style={{
					color: Color.Primary,
					fontSize: '14px',
					width: '100%',
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
						onEntered: () => {
							if (anchorItem !== null) {
								props.onContextMenuOpen?.(anchorItem.data);
							}
						},
						onExited: () => setAnchorItem(null),
					},
				}}
			>
				{enableNew ?
					<StyledMenuItem
						data-first-project-new="true"
						onClick={() => handleClose("New", anchorItem?.data)}
					>
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
				<GlobalStyles styles={{
					".dora-resource-tree.ant-tree-show-line .ant-tree-indent-unit::before": {
						insetInlineEnd: "6px !important",
					},
					".dora-resource-tree.ant-tree-show-line .ant-tree-switcher-leaf-line::before": {
						insetInlineStart: "11px !important",
					},
					".dora-resource-tree .ant-tree-node-content-wrapper": {
						borderRadius: "5px !important",
						transition: "background-color 120ms ease, box-shadow 120ms ease",
					},
					".dora-resource-tree .ant-tree-node-content-wrapper.ant-tree-node-selected": {
						boxShadow: `inset 2px 0 0 ${Color.Theme}`,
					},
				}} />
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
								titleHeight: 26,
								indentSize: 18,
								nodeHoverBg: Color.SurfaceHover,
								nodeHoverColor: Color.TextPrimary,
								nodeSelectedBg: Color.ThemeMuted,
								nodeSelectedColor: Color.TextPrimary,
							},
					},
				}}
			>
				<Tree<TreeDataType>
					ref={treeRef}
					className="dora-resource-tree"
					onRightClick={onRightClick}
					showIcon
					showLine
					virtual
					motion={false}
					checkable={multiSelectMode}
					checkStrictly
					checkedKeys={checkedKeys}
					icon={fileIcon}
					switcherIcon={switcherIcon}
					switcherLoadingIcon={<CaretDownFilled style={{ fontSize: 10 }} />}
					draggable={multiSelectMode ? false : { icon: false }}
					onDrop={onDrop}
					expandedKeys={expandedKeys}
					treeData={visibleTreeData}
					onSelect={onSelect}
					onCheck={onCheck}
					onExpand={onExpand}
					loadData={loadData}
					loadedKeys={loadedKeys}
					onLoad={() => { }}
					selectedKeys={selectedKeys}
					titleRender={(node) => (
						<span
							data-first-project-workspace-root={node.root && !node.builtin ? "true" : undefined}
							data-first-project-agent-target={
								node.key === props.firstProjectTourTargetKey ? "true" : undefined
							}
						>
							{node.title}
						</span>
					)}
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
			<Stack
				direction="row"
				alignItems="center"
				spacing={0.25}
				sx={{
					position: "absolute",
					right: 20,
					bottom: 18,
					zIndex: 2,
					padding: batchTargetMode !== null ? 0.5 : 0,
					borderRadius: 1.5,
					color: Color.Primary,
					backgroundColor: "rgba(35, 35, 35, 0.72)",
					border: `1px solid ${multiSelectMode ? Color.Theme + "88" : Color.Line}`,
					backdropFilter: "blur(4px)",
					opacity: multiSelectMode ? 1 : 0.58,
					transition: "opacity 0.2s",
					"&:hover": {
						opacity: 1,
					},
				}}
			>
				{batchTargetMode !== null ?
					<>
						<span style={{ padding: "0 6px", fontSize: 12, whiteSpace: "nowrap" }}>
							{t(batchTargetMode === "copy" ? "tree.selectCopyTarget" : "tree.selectMoveTarget")}
						</span>
						<Tooltip title={t("action.cancel")}>
							<IconButton
								size="small"
								color="inherit"
								aria-label={t("action.cancel")}
								onClick={props.onCancelBatchTarget}
							>
								<CloseIcon fontSize="small" />
							</IconButton>
						</Tooltip>
					</>
					:
					<>
						{multiSelectMode && checkedKeys.length > 0 ?
							<>
								<Tooltip title={t("tree.copySelected", { count: checkedKeys.length })}>
									<IconButton
										size="small"
											color="inherit"
											aria-label={t("tree.copySelected", { count: checkedKeys.length })}
											onClick={() => props.onBatchAction("copy")}
											sx={{ width: 30, height: 30 }}
										>
											<ContentCopyIcon sx={{ fontSize: 18 }} />
									</IconButton>
								</Tooltip>
								<Tooltip title={t("tree.moveSelected", { count: checkedKeys.length })}>
									<IconButton
										size="small"
											color="inherit"
											aria-label={t("tree.moveSelected", { count: checkedKeys.length })}
											onClick={() => props.onBatchAction("move")}
											sx={{ width: 30, height: 30 }}
										>
										<DriveFileMoveIcon fontSize="small" />
									</IconButton>
								</Tooltip>
								<Tooltip title={t("tree.deleteSelected", { count: checkedKeys.length })}>
									<IconButton
										size="small"
											color="inherit"
											aria-label={t("tree.deleteSelected", { count: checkedKeys.length })}
											onClick={() => props.onBatchAction("delete")}
											sx={{ width: 30, height: 30 }}
										>
										<DeleteOutlineIcon fontSize="small" />
									</IconButton>
								</Tooltip>
							</> : null
						}
						<Tooltip title={t(multiSelectMode ? "tree.exitMultiSelect" : "tree.enterMultiSelect")}>
								<IconButton
									size="small"
									color={multiSelectMode ? "primary" : "inherit"}
									aria-label={t(multiSelectMode ? "tree.exitMultiSelect" : "tree.enterMultiSelect")}
									onClick={props.onToggleMultiSelect}
									sx={{
										width: 30,
										height: 30,
									}}
								>
								<Badge
									color="primary"
									badgeContent={multiSelectMode ? checkedKeys.length : 0}
									max={99}
								>
									{multiSelectMode ?
										<CheckBoxIcon fontSize="small" /> :
										<CheckBoxOutlineBlankIcon fontSize="small" />
									}
								</Badge>
							</IconButton>
						</Tooltip>
					</>
				}
			</Stack>
		</div>
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
	if (prev.checkedKeys.length !== next.checkedKeys.length) {
		return false;
	}
	const prevCheckedKeys = [...prev.checkedKeys].sort();
	const nextCheckedKeys = [...next.checkedKeys].sort();
	for (let i = 0; i < prevCheckedKeys.length; i++) {
		if (prevCheckedKeys[i] !== nextCheckedKeys[i]) {
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
		prev.firstProjectTourTargetKey === next.firstProjectTourTargetKey &&
		prev.firstProjectTourWorkspaceRightClickOnly === next.firstProjectTourWorkspaceRightClickOnly &&
		prev.scrollRequest === next.scrollRequest &&
		prev.resizing === next.resizing &&
		prev.multiSelectMode === next.multiSelectMode &&
		prev.batchTargetMode === next.batchTargetMode &&
		prev.onSelect === next.onSelect &&
		prev.onCheck === next.onCheck &&
		prev.onToggleMultiSelect === next.onToggleMultiSelect &&
		prev.onBatchAction === next.onBatchAction &&
		prev.onBatchTarget === next.onBatchTarget &&
		prev.onCancelBatchTarget === next.onCancelBatchTarget &&
		prev.onMenuClick === next.onMenuClick &&
		prev.onExpand === next.onExpand &&
		prev.loadData === next.loadData &&
		prev.onDrop === next.onDrop;
});

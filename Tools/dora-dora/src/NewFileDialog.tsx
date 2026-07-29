/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import DialogTitle from '@mui/material/DialogTitle';
import Dialog from '@mui/material/Dialog';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import useMediaQuery from '@mui/material/useMediaQuery';
import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';

import luaLogo from './lua.png';
import yueLogo from './yuescript.png';
import tealLogo from './teal.png';
import blocklyLogo from './blockly.png';
import typescriptLogo from './typescript.png';
import yarnLogo from './yarn.png';
import waLogo from './wa.svg';
import vscLogo from './vsc.png';
import tic80Logo from './tic80.png';
import doraAnimationLogo from './dora-animation.png';
import doraBodyLogo from './dora-body.png';
import { AiFillFolderAdd } from 'react-icons/ai';
import { DiCode } from 'react-icons/di';
import { VscMarkdown } from 'react-icons/vsc';
import { useTranslation } from 'react-i18next';
import { DialogActions } from '@mui/material';
import Grid from '@mui/material/Grid';

export type DoraFileType = "Lua" | "YueScript" | "Teal" | "TypeScript" | "Dora XML" | "Dora Animation" | "Dora Body" | "Dora Particle" | "Markdown" | "Yarn" | "Visual Script" | "Blockly" | "Folder" | "Wa" | "TIC80"

interface FileType {
	icon: React.ReactNode;
	name: DoraFileType;
	label?: string;
	desc: string;
	padding: string;
}

const fileTypes: FileType[] = [
	{
		icon: <AiFillFolderAdd size={50} style={{ marginLeft: '0px' }} />,
		name: "Folder",
		label: "file.typeFolder",
		desc: "file.folder",
		padding: '20px'
	},
	{
		icon: <img src={luaLogo} alt="Lua" width="55px" height="55px" style={{ marginLeft: '-2.5px' }} />,
		name: "Lua",
		desc: "file.lua",
		padding: '20px'
	},
	{
		icon: <img src={yueLogo} alt="YueScript" width="60px" height="60px" style={{ marginLeft: '-5px' }} />,
		name: "YueScript",
		label: "file.typeYueScript",
		desc: "file.yuescript",
		padding: '10px'
	},
	{
		icon: <img src={tealLogo} alt="Teal" width="42px" height="42px" style={{ marginLeft: '5px' }} />,
		name: "Teal",
		desc: "file.teal",
		padding: '20px'
	},
	{
		icon: <img src={typescriptLogo} alt="TypeScript" width="55px" height="55px" style={{ marginLeft: '-2.5px' }} />,
		name: "TypeScript",
		desc: "file.typescript",
		padding: '20px'
	},
	{
		icon: <DiCode size={65} style={{ marginLeft: '-3px' }} />,
		name: "Dora XML",
		desc: "file.xml",
		padding: '13px'
	},
	{
		icon: <img src={doraAnimationLogo} alt="Dora Animation" width="50px" height="50px" style={{ marginLeft: '0px', objectFit: 'contain' }} />,
		name: "Dora Animation",
		label: "file.typeAnimation",
		desc: "file.model",
		padding: '18px'
	},
	{
		icon: <img src={doraBodyLogo} alt="Dora Body" width="52px" height="52px" style={{ marginLeft: '-1px', objectFit: 'contain' }} />,
		name: "Dora Body",
		label: "file.typeBody",
		desc: "file.body",
		padding: '17px'
	},
	{
		icon: <AutoAwesomeIcon sx={{ fontSize: 52, color: "#fac03d", marginLeft: "-1px" }} />,
		name: "Dora Particle",
		label: "file.typeParticle",
		desc: "file.particle",
		padding: '17px'
	},
	{
		icon: <img src={yarnLogo} alt="Yarn" width="55px" height="55px" style={{ marginLeft: '0px' }} />,
		name: "Yarn",
		desc: "file.yarn",
		padding: '15px'
	},
	{
		icon: <VscMarkdown size={50} style={{ marginLeft: '5px' }} />,
		name: "Markdown",
		desc: "file.markdown",
		padding: '15px'
	},
	{
		icon: <img src={vscLogo} alt="Visual Script" width="40px" height="40px" style={{ marginLeft: '8px' }} />,
		name: "Visual Script",
		desc: "file.visualScript",
		padding: '22px'
	},
	{
		icon: <img src={blocklyLogo} alt="Blockly" width="40px" height="40px" style={{ marginLeft: '8px' }} />,
		name: "Blockly",
		desc: "file.blockly",
		padding: '22px'
	},
	{
		icon: <img src={waLogo} alt="Wa" width="40px" height="40px" style={{ marginLeft: '4px' }} />,
		name: "Wa",
		desc: "file.wa",
		padding: '22px'
	},
	{
		icon: <img src={tic80Logo} alt="TIC80" width="45px" height="45px" style={{ marginLeft: '5px' }} />,
		name: "TIC80",
		desc: "file.tic",
		padding: '20px'
	},
];

export interface NewFileDialogProps {
	open: boolean;
	onClose: (value?: DoraFileType) => void;
}

const transitionProps = {
	appear: false,
	enter: false,
	exit: false
};

function NewFileDialog(props: NewFileDialogProps) {
	const { t } = useTranslation();
	const { onClose, open } = props;
	const compact = useMediaQuery('(max-width: 600px)');
	const veryNarrow = useMediaQuery('(max-width: 350px)');

	const handleClose = () => {
		onClose(undefined);
	};

	const handleListItemClick = (value: DoraFileType) => {
		onClose(value);
	};

	return (
		<Dialog
			maxWidth="md"
			fullWidth
			onClose={handleClose}
			open={open}
			transitionDuration={0}
			slotProps={{
				transition: transitionProps,
				paper: {
					"data-first-project-new-dialog": "true",
					sx: compact ? {
						width: "calc(100% - 24px)",
						maxHeight: "calc(var(--dora-viewport-height, 100dvh) - 24px)",
						m: 1.5,
					} : undefined,
				},
			}}>
			<DialogTitle sx={{
				display: "flex",
				alignItems: "center",
				justifyContent: "space-between",
				...(compact ? {
					position: "sticky",
					top: 0,
					zIndex: 1,
					py: 1,
					backgroundColor: "background.paper",
				} : {}),
			}}>
				{t("file.new")}
				<IconButton
					aria-label={t("action.close")}
					onClick={handleClose}
					size="small"
					sx={{ ml: 1, color: "text.secondary" }}
				>
					<CloseIcon fontSize="small" />
				</IconButton>
			</DialogTitle>
			<Grid container columns={{ xs: 2, sm: 2, md: 3 }} sx={compact ? { px: 0.75, pb: 0.75 } : undefined}>
				{
					fileTypes.map((fileType) => (
						<Grid key={fileType.name} size={1}>
							<ListItem sx={compact ? { p: 0.5 } : undefined}>
								<ListItemButton
									data-first-project-folder={fileType.name === "Folder" ? "true" : undefined}
									sx={{
										height: veryNarrow ? 64 : compact ? 82 : 90,
										minWidth: 0,
										px: compact ? 1 : 2,
										"& > img, & > svg": compact ? {
											width: veryNarrow ? 32 : 36,
											height: veryNarrow ? 32 : 36,
											flexShrink: 0,
										} : undefined,
									}}
									onClick={() => handleListItemClick(fileType.name)}
									key={fileType.name}
								>
									{fileType.icon}
									<ListItemText
										primary={fileType.label ? t(fileType.label) : fileType.name}
										secondary={t(fileType.desc)}
										sx={{
											pl: compact ? 1 : fileType.padding,
											minWidth: 0,
											m: 0,
											"& .MuiListItemText-primary": compact ? {
												fontSize: veryNarrow ? 12.5 : 13,
												lineHeight: 1.3,
											} : undefined,
											"& .MuiListItemText-secondary": compact ? {
												display: veryNarrow ? "none" : "-webkit-box",
												overflow: "hidden",
												WebkitBoxOrient: "vertical",
												WebkitLineClamp: 2,
												fontSize: 11,
												lineHeight: 1.3,
											} : undefined,
										}}
									/>
								</ListItemButton>
							</ListItem>
						</Grid>
					))
				}
			</Grid>
			<DialogActions />
		</Dialog>
	);
}

export default NewFileDialog;

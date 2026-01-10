/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import DialogTitle from '@mui/material/DialogTitle';
import Dialog from '@mui/material/Dialog';

import luaLogo from './lua.png';
import yueLogo from './yuescript.png';
import tealLogo from './teal.png';
import blocklyLogo from './blockly.png';
import typescriptLogo from './typescript.png';
import yarnLogo from './yarn.png';
import waLogo from './wa.svg';
import vscLogo from './vsc.png';
import { AiFillFolderAdd } from 'react-icons/ai';
import { DiCode } from 'react-icons/di';
import { VscMarkdown } from 'react-icons/vsc';
import { useTranslation } from 'react-i18next';
import { DialogActions } from '@mui/material';
import Grid from '@mui/material/Grid';

export type DoraFileType = "Lua" | "YueScript" | "Teal" | "TypeScript" | "Dora XML" | "Markdown" | "Yarn" | "Visual Script" | "Blockly" | "Folder" | "Wa"

interface FileType {
	icon: React.ReactNode;
	name: DoraFileType;
	desc: string;
	padding: string;
}

const fileTypes: FileType[] = [
	{
		icon: <img src={luaLogo} alt="Lua" width="55px" height="55px" style={{marginLeft: '-2.5px'}}/>,
		name: "Lua",
		desc: "file.lua",
		padding: '20px'
	},
	{
		icon: <img src={yueLogo} alt="YueScript" width="60px" height="60px" style={{marginLeft: '-5px'}}/>,
		name: "YueScript",
		desc: "file.yuescript",
		padding: '10px'
	},
	{
		icon: <img src={tealLogo} alt="Teal" width="42px" height="42px" style={{marginLeft: '5px'}}/>,
		name: "Teal",
		desc: "file.teal",
		padding: '20px'
	},
	{
		icon: <img src={typescriptLogo} alt="TypeScript" width="55px" height="55px" style={{marginLeft: '-2.5px'}}/>,
		name: "TypeScript",
		desc: "file.typescript",
		padding: '20px'
	},
	{
		icon: <DiCode size={65} style={{marginLeft: '-3px'}}/>,
		name: "Dora XML",
		desc: "file.xml",
		padding: '13px'
	},
	{
		icon: <img src={yarnLogo} alt="Yarn" width="55px" height="55px" style={{marginLeft: '0px'}}/>,
		name: "Yarn",
		desc: "file.yarn",
		padding: '15px'
	},
	{
		icon: <VscMarkdown size={50} style={{marginLeft: '5px'}}/>,
		name: "Markdown",
		desc: "file.markdown",
		padding: '15px'
	},
	{
		icon: <img src={vscLogo} alt="Visual Script" width="40px" height="40px" style={{marginLeft: '8px'}}/>,
		name: "Visual Script",
		desc: "file.visualScript",
		padding: '22px'
	},
	{
		icon: <img src={blocklyLogo} alt="Blockly" width="40px" height="40px" style={{marginLeft: '8px'}}/>,
		name: "Blockly",
		desc: "file.blockly",
		padding: '22px'
	},
	{
		icon: <img src={waLogo} alt="Wa" width="40px" height="40px" style={{marginLeft: '4px'}}/>,
		name: "Wa",
		desc: "file.wa",
		padding: '22px'
	},
	{
		icon: <AiFillFolderAdd size={50} style={{marginLeft: '0px'}}/>,
		name: "Folder",
		desc: "file.folder",
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

	const handleClose = () => {
		onClose(undefined);
	};

	const handleListItemClick = (value: DoraFileType) => {
		onClose(value);
	};

	return (
		<Dialog
			maxWidth="md"
			onClose={handleClose}
			open={open}
			transitionDuration={0}
			slotProps={{transition: transitionProps}}>
			<DialogTitle>{t("file.new")}</DialogTitle>
			<Grid container columns={{ sm: 2, md: 3 }}>
			{
				fileTypes.map((fileType) => (
					<Grid key={fileType.name} size={1}>
						<ListItem>
							<ListItemButton sx={{height:"90px"}}
								onClick={() => handleListItemClick(fileType.name)}
								key={fileType.name}
							>
								{ fileType.icon }
								<ListItemText primary={fileType.name} secondary={t(fileType.desc)} sx={{paddingLeft: fileType.padding}}/>
							</ListItemButton>
						</ListItem>
					</Grid>
				))
			}
			</Grid>
			<DialogActions/>
		</Dialog>
	);
}

export default NewFileDialog;
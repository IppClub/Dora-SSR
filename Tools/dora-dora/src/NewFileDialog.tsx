/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

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
import typescriptLogo from './typescript.png';
import { AiFillFolderAdd } from 'react-icons/ai';
import { SiNodered } from 'react-icons/si';
import { DiCode } from 'react-icons/di';
import { VscMarkdown } from 'react-icons/vsc';
import { useTranslation } from 'react-i18next';
import { DialogActions, Grid } from '@mui/material';

export type DoraFileType = "Lua" | "Yuescript" | "Teal" | "Typescript" | "Dora XML" | "Markdown" | "Yarn" | "Visual Script" | "Folder"

interface FileType {
	icon: React.ReactNode;
	name: DoraFileType;
	desc: string;
	padding: string;
}

const fileTypes: FileType[] = [
	{
		icon: <img src={luaLogo} alt="Lua" width="50px" height="50px" style={{marginLeft: '0px'}}/>,
		name: "Lua",
		desc: "file.lua",
		padding: '20px'
	},
	{
		icon: <img src={yueLogo} alt="Yuescript" width="60px" height="60px" style={{marginLeft: '-5px'}}/>,
		name: "Yuescript",
		desc: "file.yuescript",
		padding: '10px'
	},
	{
		icon: <img src={tealLogo} alt="Teal" width="45px" height="45px" style={{marginLeft: '5px'}}/>,
		name: "Teal",
		desc: "file.teal",
		padding: '20px'
	},
	{
		icon: <img src={typescriptLogo} alt="Typescript" width="40px" height="40px" style={{marginLeft: '5px'}}/>,
		name: "Typescript",
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
		icon: <img src="/yarn-editor/icon_512x512.png" alt="Yarn" width="50px" height="50px" style={{marginLeft: '0px'}}/>,
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
		icon: <SiNodered size={60} style={{marginLeft: '5px', width: '60px'}}/>,
		name: "Visual Script",
		desc: "file.visualScript",
		padding: '25px'
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
		<Dialog maxWidth="sm" onClose={handleClose} open={open}>
			<DialogTitle>{t("file.new")}</DialogTitle>
			<Grid container columns={2}>
			{
				fileTypes.map((fileType) => (
					<Grid key={fileType.name} xs={1} item>
						<ListItem>
							<ListItemButton sx={{height:"80px"}}
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
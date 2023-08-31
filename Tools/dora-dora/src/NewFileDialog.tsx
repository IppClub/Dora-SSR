import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import DialogTitle from '@mui/material/DialogTitle';
import Dialog from '@mui/material/Dialog';

import luaLogo from './lua.png';
import yueLogo from './yuescript.png';
import tealLogo from './teal.png';
import { AiFillFolderAdd } from 'react-icons/ai';
import { SiNodered } from 'react-icons/si';
import { DiCode } from 'react-icons/di';
import { VscMarkdown } from 'react-icons/vsc';
import { useTranslation } from 'react-i18next';
import { DialogActions, Grid } from '@mui/material';

export type DoraFileType = "Lua" | "Yuescript" | "Teal" | "Dora Xml" | "Markdown" | "Yarn" | "Visual Script" | "Folder"

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
		icon: <img src={yueLogo} alt="Yuescript" width="60px" height="60px" style={{marginLeft: '0px'}}/>,
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
		icon: <DiCode size={60} style={{marginLeft: '0px'}}/>,
		name: "Dora Xml",
		desc: "file.xml",
		padding: '15px'
	},
	{
		icon: <img src="yarn-editor/icon_512x512.png" alt="Yuescript" width="50px" height="50px" style={{marginLeft: '0px'}}/>,
		name: "Yarn",
		desc: "file.yarn",
		padding: '20px'
	},
	{
		icon: <VscMarkdown size={45} style={{marginLeft: '10px'}}/>,
		name: "Markdown",
		desc: "file.markdown",
		padding: '15px'
	},
	{
		icon: <SiNodered size={60} style={{marginLeft: '5px'}}/>,
		name: "Visual Script",
		desc: "file.visualScript",
		padding: '30px'
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
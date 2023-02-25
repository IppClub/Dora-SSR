import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import DialogTitle from '@mui/material/DialogTitle';
import Dialog from '@mui/material/Dialog';

import luaLogo from './lua.png';
import yueLogo from './yuescript.png';
import tealLogo from './teal.png';
import xmlLogo from './xml.png';
import { AiFillFolderAdd } from 'react-icons/ai';

export type DoraFileType = "Lua" | "Yuescript" | "Teal" | "Dora Xml" | "Folder"

interface FileType {
	icon: React.ReactNode;
	name: DoraFileType;
	desc: string;
	padding: string;
}

const fileTypes: FileType[] = [
	{
		icon: <img src={luaLogo} alt="Lua" width="50px" height="50px"/>,
		name: "Lua",
		desc: "lightweight, high-level, multi-paradigm language ",
		padding: '20px'
	},
	{
		icon: <img src={yueLogo} alt="Yuescript" width="60px" height="60px"/>,
		name: "Yuescript",
		desc: "expressive, extremely concise language",
		padding: '10px'
	},
	{
		icon: <img src={tealLogo} alt="Teal" width="50px" height="50px"/>,
		name: "Teal",
		desc: "a typed dialect of Lua",
		padding: '20px'
	},
	{
		icon: <img src={xmlLogo} alt="Xml" width="50px" height="50px"/>,
		name: "Dora Xml",
		desc: "write game node trees in Xml format",
		padding: '20px'
	},
	{
		icon: <AiFillFolderAdd size={50}/>,
		name: "Folder",
		desc: "create a file folder",
		padding: '20px'
	},
];

export interface NewFileDialogProps {
	open: boolean;
	onClose: (value?: DoraFileType) => void;
}

function NewFileDialog(props: NewFileDialogProps) {
	const { onClose, open } = props;

	const handleClose = () => {
		onClose(undefined);
	};

	const handleListItemClick = (value: DoraFileType) => {
		onClose(value);
	};

	return (
		<Dialog onClose={handleClose} open={open}>
			<DialogTitle sx={{ backgroundColor: '#3a3a3a' }}>New File</DialogTitle>
			<List sx={{ pt: 0, backgroundColor: '#3a3a3a' }}>
			{
				fileTypes.map((fileType) => (
					<ListItem key={fileType.name} disableGutters>
						<ListItemButton
							onClick={() => handleListItemClick(fileType.name)}
							key={fileType.name}
						>
								{ fileType.icon }
							<ListItemText primary={fileType.name} secondary={fileType.desc} style={{paddingLeft: fileType.padding}}/>
						</ListItemButton>
					</ListItem>
				))
			}
			</List>
		</Dialog>
	);
}

export default NewFileDialog;
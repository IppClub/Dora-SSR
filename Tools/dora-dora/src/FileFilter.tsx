import { Autocomplete, TextField } from '@mui/material';
import { matchSorter } from 'match-sorter';
import { useTranslation } from 'react-i18next';
import { Color } from './Frame';

export interface FilterOption {
	title: string;
	key: string;
	path: string;
}

export interface FileFilterProps {
	options: FilterOption[];
	onClose: (option: FilterOption | null) => void;
}

const FileFilter = (props: FileFilterProps) => {
	const {t} = useTranslation();
	const filterOptions = (options: FilterOption[], state: { inputValue: string }) => {
		return matchSorter(
			options,
			state.inputValue,
			{
				keys: ['title'],
			}
		);
	};
	return <Autocomplete
		forcePopupIcon={false}
		fullWidth
		openOnFocus
		disableListWrap
		filterOptions={filterOptions}
		options={props.options}
		getOptionLabel={(option) => option.key}
		renderInput={(params) => <TextField
			autoFocus
			sx={{
				m: 1,
				width: '50ch',
				"& .MuiOutlinedInput-notchedOutline": {
					borderColor: Color.Secondary
				}
			}} {...params} label={t("popup.goToFile")}/>}
		renderOption={(props, option) => {
			return (
				<li {...props}>
					{option.title}&emsp;&emsp;
					<p style={{textAlign: 'right', color: Color.TextSecondary, fontSize: '12px'}}>{option.path}</p>
				</li>
			);
		}}
		onChange={(_, value, reason) => {
			if (value !== null && reason === "selectOption") {
				props.onClose(value);
			}
		}}
		onClose={(_, reason) => {
			if (reason !== "selectOption") {
				props.onClose(null);
			}
		}}
	/>;
}

export default FileFilter;

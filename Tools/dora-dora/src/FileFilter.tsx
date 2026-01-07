/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Autocomplete, TextField } from '@mui/material';
import { matchSorter } from 'match-sorter';
import { useTranslation } from 'react-i18next';
import { Color } from './Frame';

export interface FilterOption {
	title: string;
	fileKey: string;
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
		getOptionLabel={(option) => option.fileKey}
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
			delete props.key;
			return (
				<li key={option.fileKey} {...props as Omit<typeof props, "key">}>
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

/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { forwardRef, useEffect, useLayoutEffect, useRef, useState } from 'react';
import type { HTMLAttributes } from 'react';
import { Autocomplete, CircularProgress, TextField } from '@mui/material';
import { styled } from '@mui/material/styles';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import { Color } from './Theme';
import { searchFileIndex } from './FileSearchIndex';
import type { FilterOption } from './FileSearchProtocol';

export type { FilterOption } from './FileSearchProtocol';

export interface FileFilterProps {
	optionCount: number;
	loading?: boolean;
	onClose: (option: FilterOption | null) => void;
}

const maxResults = 100;
const maxDiagnosticSamples = 200;

const updateSearchInputDiagnostics = (samples: number[]) => {
	const diagnostics = document.querySelector<HTMLElement>("[data-dora-perf-diagnostics]");
	if (diagnostics === null) return;
	const sorted = [...samples].sort((a, b) => a - b);
	const percentile = (ratio: number) => (
		sorted[Math.min(sorted.length - 1, Math.ceil(sorted.length * ratio) - 1)] ?? 0
	);
	diagnostics.dataset.doraPerfSearchInputCount = String(samples.length);
	diagnostics.dataset.doraPerfSearchInputP50 = percentile(0.5).toFixed(2);
	diagnostics.dataset.doraPerfSearchInputP95 = percentile(0.95).toFixed(2);
	diagnostics.dataset.doraPerfSearchInputMax = (sorted.at(-1) ?? 0).toFixed(2);
};

interface MacScrollbarListboxProps extends HTMLAttributes<HTMLElement> {
	ownerState?: unknown;
	sx?: unknown;
}

const MacScrollbarListboxBase = forwardRef<HTMLElement, MacScrollbarListboxProps>((props, ref) => {
	const { ownerState: _, sx: __, style, ...listboxProps } = props;
	return (
		<MacScrollbar
			{...listboxProps}
			ref={ref}
			as="ul"
			skin="dark"
			suppressScrollX
			style={style}
		/>
	);
});
MacScrollbarListboxBase.displayName = "MacScrollbarListboxBase";

const MacScrollbarListbox = styled(MacScrollbarListboxBase)({
	listStyle: 'none',
	margin: 0,
	padding: '8px 0',
	maxHeight: '50vh',
	overflow: 'auto',
	position: 'relative',
	'& .MuiAutocomplete-option': {
		minHeight: 48,
		display: 'flex',
		overflow: 'hidden',
		justifyContent: 'flex-start',
		alignItems: 'center',
		cursor: 'pointer',
		padding: '6px 16px',
		boxSizing: 'border-box',
		outline: 0,
		WebkitTapHighlightColor: 'transparent',
		'@media (min-width: 600px)': {
			minHeight: 'auto',
		},
		'&:hover': {
			backgroundColor: Color.ThemeMuted,
		},
		'&.Mui-focused:not(.dora-file-filter-highlighted)': {
			backgroundColor: 'transparent',
		},
		'&.Mui-focusVisible:not(.dora-file-filter-highlighted)': {
			backgroundColor: 'transparent',
		},
		'&[aria-selected="true"]': {
			backgroundColor: Color.Theme + '2e',
		},
		'&.dora-file-filter-highlighted': {
			backgroundColor: Color.Theme + '44',
		},
	},
});
MacScrollbarListbox.displayName = "MacScrollbarListbox";

const FileFilter = (props: FileFilterProps) => {
	const { t } = useTranslation();
	const highlightedOption = useRef<FilterOption | null>(null);
	const searchRevision = useRef(0);
	const inputStartedAt = useRef<number | null>(null);
	const inputLatencySamples = useRef<number[]>([]);
	const [inputValue, setInputValue] = useState("");
	const [results, setResults] = useState<FilterOption[]>([]);
	const [highlightedIndex, setHighlightedIndex] = useState(-1);
	const [searchLoading, setSearchLoading] = useState(false);

	useEffect(() => {
		updateSearchInputDiagnostics([]);
	}, []);

	useLayoutEffect(() => {
		const startedAt = inputStartedAt.current;
		inputStartedAt.current = null;
		if (startedAt === null) return;
		const samples = inputLatencySamples.current;
		samples.push(performance.now() - startedAt);
		if (samples.length > maxDiagnosticSamples) {
			samples.splice(0, samples.length - maxDiagnosticSamples);
		}
		updateSearchInputDiagnostics(samples);
	}, [inputValue]);

	useLayoutEffect(() => {
		const option = highlightedIndex < 0
			? null
			: document.querySelector<HTMLElement>(
				`[data-file-filter-option-index="${highlightedIndex}"]`,
			);
		option?.scrollIntoView({ block: "nearest" });
	}, [highlightedIndex, results]);

	useEffect(() => {
		const input = inputValue.trim();
		const revision = ++searchRevision.current;
		highlightedOption.current = null;
		setHighlightedIndex(-1);
		if (input === "") {
			setResults([]);
			setSearchLoading(false);
			return;
		}
		if (props.loading) {
			setResults([]);
			setSearchLoading(false);
			return;
		}
		setResults([]);
		setSearchLoading(true);
		const timer = window.setTimeout(() => {
			void searchFileIndex(input, maxResults).then(options => {
				if (revision !== searchRevision.current) return;
				highlightedOption.current = options[0] ?? null;
				setHighlightedIndex(options.length > 0 ? 0 : -1);
				setResults(options);
				setSearchLoading(false);
			});
		}, 50);
		return () => {
			window.clearTimeout(timer);
		};
	}, [inputValue, props.loading]);

	return <Autocomplete
		forcePopupIcon={false}
		fullWidth
		disableListWrap
		open={inputValue.trim() !== ""}
		inputValue={inputValue}
		onInputChange={(_, value, reason) => {
			if (reason === "input") {
				inputStartedAt.current = performance.now();
				highlightedOption.current = null;
				setHighlightedIndex(-1);
				setResults([]);
				setSearchLoading(value.trim() !== "" && !props.loading);
			}
			setInputValue(value);
		}}
		filterOptions={(options) => options}
		options={results}
		loading={props.loading || searchLoading}
		slots={{
			listbox: MacScrollbarListbox,
		}}
		noOptionsText={t("popup.searchFilesEmpty")}
		getOptionLabel={(option) => option.fileKey}
		onHighlightChange={(_, option, reason) => {
			if (option === null || reason === "keyboard") return;
			const index = results.indexOf(option);
			if (index < 0) return;
			highlightedOption.current = option;
			setHighlightedIndex(index);
		}}
		onKeyDown={(event) => {
			if (event.key === "Escape") {
				(event as typeof event & { defaultMuiPrevented?: boolean }).defaultMuiPrevented = true;
				event.preventDefault();
				event.stopPropagation();
				props.onClose(null);
				return;
			}
			if ((event.key === "ArrowDown" || event.key === "ArrowUp") && results.length > 0) {
				(event as typeof event & { defaultMuiPrevented?: boolean }).defaultMuiPrevented = true;
				event.preventDefault();
				event.stopPropagation();
				setHighlightedIndex(current => {
					const next = event.key === "ArrowDown"
						? Math.min(results.length - 1, current < 0 ? 0 : current + 1)
						: Math.max(0, current < 0 ? 0 : current - 1);
					highlightedOption.current = results[next] ?? null;
					return next;
				});
				return;
			}
			const selectedOption = results[highlightedIndex] ?? highlightedOption.current;
			if (event.key === "Enter" && selectedOption !== null) {
				(event as typeof event & { defaultMuiPrevented?: boolean }).defaultMuiPrevented = true;
				event.preventDefault();
				event.stopPropagation();
				props.onClose(selectedOption);
			}
		}}
		renderInput={(params) => <TextField
			autoFocus
			sx={{
				m: 1,
				width: '50ch',
			}}
			{...params}
			slotProps={{
				htmlInput: {
					...params.inputProps,
					"data-file-filter-input": "true",
					"data-file-filter-option-count": props.optionCount,
					"data-file-filter-result-count": results.length,
					"aria-activedescendant": highlightedIndex < 0
						? undefined
						: `${params.inputProps.id}-option-${highlightedIndex}`,
				},
				input: {
					...params.InputProps,
					endAdornment: <>
						{props.loading || searchLoading ? <CircularProgress color="inherit" size={18} /> : null}
						{params.InputProps.endAdornment}
					</>,
				},
			}}
			label={t("popup.goToFile")}
		/>}
		renderOption={(props, option, state) => {
			const { key, className, ...liProps } = props;
			const highlighted = state.index === highlightedIndex;
			return (
				<li
					key={option.fileKey}
					{...liProps}
					className={`${className ?? ""}${highlighted ? " dora-file-filter-highlighted" : ""}`}
					data-file-filter-option-index={state.index}
					aria-selected={highlighted}
				>
					{option.title}&emsp;&emsp;
					<p style={{ textAlign: 'right', color: Color.TextSecondary, fontSize: '12px' }}>{option.path}</p>
				</li>
			);
		}}
		onChange={(_, value, reason) => {
			if (value !== null && reason === "selectOption") {
				props.onClose(value);
			}
		}}
	/>;
}

export default FileFilter;

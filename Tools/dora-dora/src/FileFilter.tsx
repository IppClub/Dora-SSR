/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { forwardRef, useEffect, useLayoutEffect, useRef, useState } from 'react';
import type { HTMLAttributes, MutableRefObject } from 'react';
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
	const { ownerState: _, sx: __, style, onWheel, ...listboxProps } = props;
	const listboxRef = useRef<HTMLElement | null>(null);

	useLayoutEffect(() => {
		const node = listboxRef.current;
		const mutableRef = typeof ref === "function" || ref === null
			? null
			: ref as MutableRefObject<HTMLElement | null>;
		if (typeof ref === "function") {
			ref(node);
		} else if (mutableRef !== null) {
			mutableRef.current = node;
		}
		return () => {
			if (typeof ref === "function") {
				ref(null);
			} else if (mutableRef !== null) {
				mutableRef.current = null;
			}
		};
	}, [ref]);

	useLayoutEffect(() => {
		const updateMaxHeight = () => {
			const listbox = listboxRef.current;
			if (listbox === null) return;
			const viewport = window.visualViewport;
			const viewportHeight = viewport?.height ?? window.innerHeight;
			const viewportBottom = (viewport?.offsetTop ?? 0) + viewportHeight;
			const availableHeight = Math.max(0, viewportBottom - listbox.getBoundingClientRect().top - 12);
			listbox.style.maxHeight = `${Math.min(viewportHeight * 0.5, availableHeight)}px`;
		};
		const frame = requestAnimationFrame(updateMaxHeight);
		window.addEventListener("resize", updateMaxHeight);
		window.visualViewport?.addEventListener("resize", updateMaxHeight);
		window.visualViewport?.addEventListener("scroll", updateMaxHeight);
		return () => {
			cancelAnimationFrame(frame);
			window.removeEventListener("resize", updateMaxHeight);
			window.visualViewport?.removeEventListener("resize", updateMaxHeight);
			window.visualViewport?.removeEventListener("scroll", updateMaxHeight);
		};
	}, []);

	return (
		<MacScrollbar
			{...listboxProps}
			ref={listboxRef}
			as="ul"
			skin="dark"
			suppressScrollX
			onWheel={(event) => {
				onWheel?.(event);
				if (event.defaultPrevented) return;
				const listbox = event.currentTarget;
				const maxScrollTop = Math.max(0, listbox.scrollHeight - listbox.clientHeight);
				const reachedTop = event.deltaY < 0 && listbox.scrollTop <= 0;
				const reachedBottom = event.deltaY > 0 && listbox.scrollTop >= maxScrollTop - 1;
				if (reachedTop || reachedBottom) {
					event.preventDefault();
				}
				event.stopPropagation();
			}}
			style={{ ...style, overscrollBehavior: 'contain' }}
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
		height: 64,
		minHeight: 64,
		maxHeight: 64,
		display: 'flex',
		overflow: 'hidden',
		justifyContent: 'flex-start',
		alignItems: 'center',
		gap: 16,
		cursor: 'pointer',
		padding: '6px 16px',
		boxSizing: 'border-box',
		outline: 0,
		WebkitTapHighlightColor: 'transparent',
		'&:hover': {
			backgroundColor: Color.ThemeMuted,
		},
		'&.Mui-focused': {
			backgroundColor: Color.Theme + '44',
		},
		'&.Mui-focusVisible': {
			backgroundColor: Color.Theme + '44',
		},
		'&[aria-selected="true"]': {
			backgroundColor: Color.Theme + '2e',
		},
		'& .dora-file-filter-title': {
			flex: '0 0 auto',
			whiteSpace: 'nowrap',
		},
		'& .dora-file-filter-path': {
			flex: '1 1 auto',
			minWidth: 0,
			overflow: 'hidden',
			color: Color.TextSecondary,
			display: '-webkit-box',
			fontSize: 12,
			lineHeight: '18px',
			textAlign: 'right',
			whiteSpace: 'normal',
			wordBreak: 'break-all',
			WebkitBoxOrient: 'vertical',
			WebkitLineClamp: 2,
		},
	},
});
MacScrollbarListbox.displayName = "MacScrollbarListbox";

const FileFilter = (props: FileFilterProps) => {
	const { t } = useTranslation();
	const searchRevision = useRef(0);
	const inputStartedAt = useRef<number | null>(null);
	const inputLatencySamples = useRef<number[]>([]);
	const [inputValue, setInputValue] = useState("");
	const [results, setResults] = useState<FilterOption[]>([]);
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

	useEffect(() => {
		const input = inputValue.trim();
		const revision = ++searchRevision.current;
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
				setResults(options);
				setSearchLoading(false);
			});
		}, 50);
		return () => {
			window.clearTimeout(timer);
		};
	}, [inputValue, props.loading]);

	return <Autocomplete
		autoHighlight
		forcePopupIcon={false}
		fullWidth
		disableListWrap
		open={inputValue.trim() !== ""}
		inputValue={inputValue}
		onInputChange={(_, value, reason) => {
			if (reason === "input") {
				inputStartedAt.current = performance.now();
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
		onKeyDown={(event) => {
			if (event.key === "Escape") {
				(event as typeof event & { defaultMuiPrevented?: boolean }).defaultMuiPrevented = true;
				event.preventDefault();
				event.stopPropagation();
				props.onClose(null);
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
			const { key: _, ...liProps } = props;
			return (
				<li
					key={option.fileKey}
					{...liProps}
					data-file-filter-option-index={state.index}
				>
					<span className="dora-file-filter-title">{option.title}</span>
					<span className="dora-file-filter-path" title={option.path}>{option.path}</span>
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

/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { useEffect, useId, useLayoutEffect, useRef, useState } from 'react';
import type { KeyboardEvent } from 'react';
import { Box, CircularProgress, TextField, Typography } from '@mui/material';
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

const FileFilter = (props: FileFilterProps) => {
	const { t } = useTranslation();
	const listboxId = useId();
	const listboxRef = useRef<HTMLElement | null>(null);
	const searchRevision = useRef(0);
	const inputStartedAt = useRef<number | null>(null);
	const inputLatencySamples = useRef<number[]>([]);
	const [inputValue, setInputValue] = useState("");
	const [results, setResults] = useState<FilterOption[]>([]);
	const [searchLoading, setSearchLoading] = useState(false);
	const [selectedIndex, setSelectedIndex] = useState(0);

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
			setSelectedIndex(0);
			return;
		}
		if (props.loading) {
			setResults([]);
			setSearchLoading(false);
			setSelectedIndex(0);
			return;
		}
		setResults([]);
		setSearchLoading(true);
		setSelectedIndex(0);
		const timer = window.setTimeout(() => {
			void searchFileIndex(input, maxResults).then(options => {
				if (revision !== searchRevision.current) return;
				setResults(options);
				setSearchLoading(false);
				setSelectedIndex(0);
			});
		}, 50);
		return () => {
			window.clearTimeout(timer);
		};
	}, [inputValue, props.loading]);

	useLayoutEffect(() => {
		const listbox = listboxRef.current;
		if (listbox === null || results.length === 0) return;
		listbox
			.querySelector<HTMLElement>(`[data-file-filter-option-index="${selectedIndex}"]`)
			?.scrollIntoView({ block: "nearest" });
	}, [results, selectedIndex]);

	const selectOption = (index: number) => {
		const option = results[index];
		if (option !== undefined) {
			props.onClose(option);
		}
	};

	const onInputKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
		switch (event.key) {
			case "ArrowDown":
				event.preventDefault();
				event.stopPropagation();
				if (results.length > 0) {
					setSelectedIndex(index => Math.min(results.length - 1, index + 1));
				}
				break;
			case "ArrowUp":
				event.preventDefault();
				event.stopPropagation();
				if (results.length > 0) {
					setSelectedIndex(index => Math.max(0, index - 1));
				}
				break;
			case "Home":
				if (results.length === 0) break;
				event.preventDefault();
				event.stopPropagation();
				setSelectedIndex(0);
				break;
			case "End":
				if (results.length === 0) break;
				event.preventDefault();
				event.stopPropagation();
				setSelectedIndex(results.length - 1);
				break;
			case "Enter":
				if (results.length === 0) break;
				event.preventDefault();
				event.stopPropagation();
				selectOption(selectedIndex);
				break;
			case "Escape":
				event.preventDefault();
				event.stopPropagation();
				props.onClose(null);
				break;
		}
	};

	const queryActive = inputValue.trim() !== "";
	const loading = props.loading || searchLoading;

	return (
		<Box
			sx={{
				display: "flex",
				flexDirection: "column",
				width: "100%",
				maxHeight: "calc(var(--dora-viewport-height, 100dvh) - 16px)",
				overflow: "hidden",
			}}
		>
			<Box sx={{ p: { xs: 1, sm: 1.5 } }}>
				<TextField
					autoFocus
					fullWidth
					value={inputValue}
					onChange={(event) => {
						inputStartedAt.current = performance.now();
						const value = event.target.value;
						setResults([]);
						setSelectedIndex(0);
						setSearchLoading(value.trim() !== "" && !props.loading);
						setInputValue(value);
					}}
					onKeyDown={onInputKeyDown}
					label={t("popup.goToFile")}
					sx={{
						"& .MuiInputBase-root": {
							minHeight: { xs: 52, sm: 56 },
						},
					}}
					slotProps={{
						htmlInput: {
							"data-file-filter-input": "true",
							"data-file-filter-option-count": props.optionCount,
							"data-file-filter-result-count": results.length,
							"aria-controls": queryActive ? listboxId : undefined,
							"aria-activedescendant": results.length > 0
								? `${listboxId}-option-${selectedIndex}`
								: undefined,
							autoComplete: "off",
						},
						input: {
							endAdornment: loading ? <CircularProgress color="inherit" size={18} /> : null,
						},
					}}
				/>
			</Box>
			{queryActive ? (
				<MacScrollbar
					ref={listboxRef}
					id={listboxId}
					role="listbox"
					aria-label={t("popup.goToFile")}
					skin="dark"
					suppressScrollX
					style={{
						width: "100%",
						maxHeight: "min(440px, calc(var(--dora-viewport-height, 100dvh) - 104px))",
						minHeight: results.length > 0 ? 64 : 56,
						overflowX: "hidden",
						overscrollBehavior: "contain",
						touchAction: "pan-y",
						WebkitOverflowScrolling: "touch",
					}}
				>
					{results.length > 0 ? results.map((option, index) => {
						const selected = index === selectedIndex;
						return (
							<Box
								key={option.fileKey}
								id={`${listboxId}-option-${index}`}
								component="button"
								type="button"
								role="option"
								aria-selected={selected}
								data-file-filter-option-index={index}
								onMouseMove={() => setSelectedIndex(index)}
								onClick={() => selectOption(index)}
								sx={{
									width: "100%",
									minHeight: { xs: 64, sm: 56 },
									display: "flex",
									flexDirection: { xs: "column", sm: "row" },
									alignItems: { xs: "flex-start", sm: "center" },
									justifyContent: "flex-start",
									gap: { xs: 0.25, sm: 2 },
									px: { xs: 1.5, sm: 2 },
									py: { xs: 1, sm: 0.75 },
									border: "none",
									borderRadius: 0,
									outline: 0,
									backgroundColor: selected ? `${Color.Theme}2e` : "transparent",
									color: Color.TextPrimary,
									font: "inherit",
									textAlign: "left",
									cursor: "pointer",
									boxSizing: "border-box",
									WebkitTapHighlightColor: "transparent",
									"&:hover": {
										backgroundColor: selected ? `${Color.Theme}38` : Color.ThemeMuted,
									},
									"&:focus-visible": {
										backgroundColor: `${Color.Theme}44`,
									},
								}}
							>
								<Typography
									component="span"
									sx={{
										flex: { sm: "0 1 auto" },
										maxWidth: "100%",
										color: Color.TextPrimary,
										fontSize: { xs: 15, sm: 16 },
										lineHeight: 1.4,
										whiteSpace: "nowrap",
										overflow: "hidden",
										textOverflow: "ellipsis",
									}}
								>
									{option.title}
								</Typography>
								<Typography
									component="span"
									title={option.path}
									sx={{
										flex: "1 1 auto",
										minWidth: 0,
										maxWidth: "100%",
										color: Color.TextSecondary,
										fontSize: 12,
										lineHeight: "18px",
										textAlign: { xs: "left", sm: "right" },
										whiteSpace: "nowrap",
										overflow: "hidden",
										textOverflow: "ellipsis",
									}}
								>
									{option.path}
								</Typography>
							</Box>
						);
					}) : (
						<Box sx={{
							minHeight: 56,
							display: "flex",
							alignItems: "center",
							justifyContent: "center",
							px: 2,
							color: Color.TextSecondary,
						}}>
							<Typography variant="body2">
								{loading ? t("popup.searchFilesSearching") : t("popup.searchFilesEmpty")}
							</Typography>
						</Box>
					)}
				</MacScrollbar>
			) : null}
		</Box>
	);
};

export default FileFilter;

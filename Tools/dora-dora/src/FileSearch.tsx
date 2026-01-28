/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Box, IconButton, InputAdornment, ListItemButton, ListItemText, Stack, TextField, Tooltip, Typography } from '@mui/material';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import * as Service from './Service';
import { Color } from './Frame';
import Info from './Info';

const { path } = Info;

const codeExtensions = [".lua", ".tl", ".yue", ".ts", ".tsx", ".xml", ".md", ".yarn", ".vs", ".wa", ".mod"];
const extensionLevels: Record<string, number> = {
	vs: 2,
	bl: 2,
	ts: 1,
	tsx: 1,
	tl: 1,
	yue: 1,
	xml: 1,
	lua: 0,
};

export interface FileSearchDialogProps {
	open: boolean;
	searchPath: string;
	onOpenFile: (file: string, line: number, column: number) => void;
}

const FileSearchPanel = (props: FileSearchDialogProps) => {
	const { t } = useTranslation();
	const [query, setQuery] = useState("");
	const [results, setResults] = useState<Service.SearchFilesResult[]>([]);
	const [searching, setSearching] = useState(false);
	const [useRegex, setUseRegex] = useState(false);
	const [caseSensitive, setCaseSensitive] = useState(false);
	const activeSearchIdRef = useRef(0);
	const searchSeqRef = useRef(0);
	const bufferedResultsRef = useRef<Service.SearchFilesResult[]>([]);
	const flushTimerRef = useRef<number | null>(null);
	const listRef = useRef<HTMLDivElement | null>(null);
	const scrollRafRef = useRef<number | null>(null);
	const [scrollTop, setScrollTop] = useState(0);
	const [listHeight, setListHeight] = useState(0);

	// Destructure props for use in callbacks
	const { searchPath, open, onOpenFile } = props;

	const flushBufferedResults = useCallback(() => {
		if (bufferedResultsRef.current.length === 0) {
			flushTimerRef.current = null;
			return;
		}
		const batch = bufferedResultsRef.current;
		bufferedResultsRef.current = [];
		setResults(prev => [...prev, ...batch]);
		flushTimerRef.current = null;
	}, []);

	const scheduleFlush = useCallback(() => {
		if (flushTimerRef.current !== null) return;
		flushTimerRef.current = window.setTimeout(() => {
			flushBufferedResults();
		}, 500);
	}, [flushBufferedResults]);

	const stopActiveSearch = useCallback(() => {
		const activeId = activeSearchIdRef.current;
		if (activeId !== 0) {
			Service.stopSearchFiles(activeId);
		}
		activeSearchIdRef.current = 0;
	}, []);

	useEffect(() => {
		const onResult = (message: Service.SearchFilesResultMessage) => {
			if (message.id !== activeSearchIdRef.current) return;
			bufferedResultsRef.current.push(message.result);
			scheduleFlush();
		};
		const onDone = (message: Service.SearchFilesDoneMessage) => {
			if (message.id !== activeSearchIdRef.current) return;
			flushBufferedResults();
			setSearching(false);
		};
		Service.addSearchFilesResultListener(onResult);
		Service.addSearchFilesDoneListener(onDone);
		return () => {
			Service.removeSearchFilesResultListener(onResult);
			Service.removeSearchFilesDoneListener(onDone);
		};
	}, [flushBufferedResults, scheduleFlush]);

	useEffect(() => {
		if (!open) {
			setQuery("");
			stopActiveSearch();
			setSearching(false);
			setResults([]);
			bufferedResultsRef.current = [];
			if (flushTimerRef.current !== null) {
				clearTimeout(flushTimerRef.current);
				flushTimerRef.current = null;
			}
			if (scrollRafRef.current !== null) {
				cancelAnimationFrame(scrollRafRef.current);
				scrollRafRef.current = null;
			}
			setScrollTop(0);
		}
	}, [open, stopActiveSearch]);

	useEffect(() => {
		const updateHeight = () => {
			if (!listRef.current) return;
			setListHeight(listRef.current.clientHeight);
		};
		updateHeight();
		window.addEventListener('resize', updateHeight);
		return () => {
			window.removeEventListener('resize', updateHeight);
		};
	}, []);

	useEffect(() => {
		if (!open) return;
		const handle = requestAnimationFrame(() => {
			if (!listRef.current) return;
			setListHeight(listRef.current.clientHeight);
		});
		return () => {
			cancelAnimationFrame(handle);
		};
	}, [open]);

	const runSearch = useCallback(() => {
		const rawPattern = query.trim();
		if (rawPattern.length === 0) {
			setSearching(false);
			setResults([]);
			return;
		}
		const pattern = rawPattern;
		const useRegexEffective = useRegex;
		stopActiveSearch();
		bufferedResultsRef.current = [];
		if (flushTimerRef.current !== null) {
			clearTimeout(flushTimerRef.current);
			flushTimerRef.current = null;
		}
		const id = ++searchSeqRef.current;
		activeSearchIdRef.current = id;
		setResults([]);
		setSearching(true);
		Service.searchFiles({
			id,
			path: searchPath,
			exts: codeExtensions,
			extensionLevels,
			pattern,
			useRegex: useRegexEffective,
			caseSensitive,
			includeContent: true,
			contentWindow: 20,
			excludes: [".git", ".svn", ".hg", ".www", ".build", ".cache", ".upload", ".download"],
		});
	}, [searchPath, query, useRegex, caseSensitive, stopActiveSearch]);

	const statusText = useMemo(() => {
		if (searching) return t("popup.searchFilesSearching");
		if (results.length === 0) return t("popup.searchFilesEmpty");
		return t("popup.searchFilesResults", { count: results.length });
	}, [searching, results.length, t]);

	const formatSnippet = useCallback((content: string) => {
		const trimmed = content.replace(/\s+/g, " ").trim();
		return "..." + trimmed + "...";
	}, []);

	const toDisplayPath = useCallback((file: string) => {
		if (!searchPath) return file;
		const rel = path.relative(searchPath, file);
		if (rel.startsWith("..")) return file;
		return rel === "" ? file : rel;
	}, [searchPath]);

	const itemHeight = 86;
	const overscan = 8;
	const totalHeight = results.length * itemHeight;
	const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight) - overscan);
	const endIndex = Math.min(results.length, Math.ceil((scrollTop + listHeight) / itemHeight) + overscan);
	const visibleResults = results.slice(startIndex, endIndex);

	const onScroll = useCallback((event: React.UIEvent<HTMLDivElement>) => {
		const nextTop = event.currentTarget.scrollTop;
		if (scrollRafRef.current !== null) {
			cancelAnimationFrame(scrollRafRef.current);
		}
		scrollRafRef.current = requestAnimationFrame(() => {
			setScrollTop(nextTop);
		});
	}, []);

	return (
		<Stack spacing={1.5} sx={{ height: '100%', minHeight: 0 }}>
			<Stack direction="row" spacing={1} alignItems="center" sx={{ paddingTop: 2, paddingLeft: 1, paddingRight: 1 }}>
				{open ?
					<TextField
						autoFocus={open}
						fullWidth
						label={t("popup.searchFiles")}
						placeholder={t("popup.searchFilesPlaceholder")}
						value={query}
						onChange={(event) => setQuery(event.target.value)}
						onKeyDown={(event) => {
							if (event.key === "Enter") {
								runSearch();
							}
						}}
						sx={{
							"& .MuiInputBase-root": {
								backgroundColor: Color.BackgroundDark,
							},
							"& .MuiOutlinedInput-notchedOutline": {
								borderColor: Color.Line,
							},
							"&:hover .MuiOutlinedInput-notchedOutline": {
								borderColor: Color.TextSecondary,
							},
						}}
						slotProps={{
							input: {
								endAdornment: (
									<InputAdornment position="end">
										<Stack direction="row" spacing={0.5} alignItems="center">
											<Tooltip title={t("popup.searchFilesCaseSensitive")}>
												<IconButton
													size="small"
													onClick={() => setCaseSensitive(prev => !prev)}
													disableRipple
													sx={{
														width: 28,
														height: 28,
														borderRadius: 1,
														border: `1px solid ${caseSensitive ? Color.Theme + "88" : Color.Line}`,
														color: caseSensitive ? Color.TextPrimary : Color.TextSecondary,
														backgroundColor: caseSensitive ? Color.Theme + "11" : "transparent",
													}}
												>
													<Typography variant="caption">Aa</Typography>
												</IconButton>
											</Tooltip>
											<Tooltip title={t("popup.searchFilesRegex")}>
												<IconButton
													size="small"
													onClick={() => setUseRegex(prev => !prev)}
													disableRipple
													sx={{
														width: 28,
														height: 28,
														borderRadius: 1,
														border: `1px solid ${useRegex ? Color.Theme + "88" : Color.Line}`,
														color: useRegex ? Color.TextPrimary : Color.TextSecondary,
														backgroundColor: useRegex ? Color.Theme + "11" : "transparent",
													}}
												>
													<Typography variant="caption">.*</Typography>
												</IconButton>
											</Tooltip>
										</Stack>
									</InputAdornment>
								)
							}
						}}
					/> : null
				}
			</Stack>
			<Box>
				<Typography variant="caption" color={Color.TextSecondary} sx={{ paddingLeft: 2 }}>
					{statusText}
				</Typography>
			</Box>
			<MacScrollbar
				skin="dark"
				ref={listRef}
				onScroll={onScroll}
				style={{ flex: 1, minHeight: 0 }}
			>
				<div style={{ position: 'relative', height: totalHeight }}>
					{visibleResults.map((result, idx) => {
						const index = startIndex + idx;
						const fileName = path.basename(result.file);
						const displayPath = toDisplayPath(result.file);
						const snippet = result.content ? formatSnippet(result.content) : "";
						return (
							<div
								key={`${result.file}-${result.pos}-${index}`}
								style={{
									position: 'absolute',
									top: index * itemHeight,
									left: 0,
									right: 0,
								}}
							>
								<ListItemButton
									onClick={() => onOpenFile(result.file, result.line, result.column)}
									sx={{
										alignItems: 'flex-start',
										borderBottom: `1px solid ${Color.Line}`,
										minHeight: itemHeight,
										maxHeight: itemHeight,
										overflow: 'hidden',
									}}
								>
									<ListItemText
										disableTypography
										primary={
											<Stack direction="row" spacing={1} alignItems="center">
												<Typography variant="body2" color={Color.TextPrimary} noWrap>
													{fileName}
												</Typography>
												<Typography variant="caption" color={Color.TextSecondary}>
													{result.line}:{result.column}
												</Typography>
											</Stack>
										}
										secondary={
											<Stack spacing={0.5}>
												<Typography variant="caption" color={Color.TextSecondary} noWrap>
													{displayPath}
												</Typography>
												{snippet.length > 0 ? (
													<Typography variant="caption" color={Color.TextPrimary} noWrap>
														{snippet}
													</Typography>
												) : null}
											</Stack>
										}
									/>
								</ListItemButton>
							</div>
						);
					})}
				</div>
			</MacScrollbar>
		</Stack>
	);
};

export default FileSearchPanel;

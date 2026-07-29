/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { LazyLog } from 'react-lazylog';
import * as Service from './Service';
import { FormEvent, memo, useEffect, useRef, useState } from 'react';
import { Box, Button, Dialog, DialogActions, DialogContent, FormControl, TextField, Tooltip } from '@mui/material';
import useMediaQuery from '@mui/material/useMediaQuery';
import { useTranslation } from 'react-i18next';
import { Entry, Separator } from './Frame';
import { Color } from './Theme';
import { BsTerminal } from 'react-icons/bs';
import InsertChartIcon from '@mui/icons-material/InsertChart';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import { ProfilerInfo } from './ProfilerInfo';
import { Checkbox, ConfigProvider, Descriptions, Radio, theme } from 'antd';
import type { DescriptionsProps, RadioChangeEvent } from 'antd';
import { CheckboxChangeEvent } from 'antd/es/checkbox';
import { MacScrollbar } from 'mac-scrollbar';
import { Line, LineConfig, Pie, PieConfig } from '@ant-design/plots';
import { Table, Divider } from 'antd';
import type { TableColumnsType } from 'antd';
import Info from './Info';
import { LogFixRequest, buildLogFixMessage, logFixLineClassName } from './LogFix';
import LogFixPanel from './LogFixPanel';
import { useBatchedLog } from './useBatchedLog';

export interface LogViewProps {
	openName: string | null;
	height: number;
	onClose: () => void;
	onFixLog?: (request: LogFixRequest) => void;
	allowBackgroundInteraction?: boolean;
};

interface LoaderDataType {
	key: React.Key;
	order: number;
	time: number;
	depth: number;
	moduleName: string;
};

let baseLine: number[] = [];

const getTableColumns = (t: (key: string) => string): TableColumnsType<LoaderDataType> => {
	return [
		{
			title: t('pro.order'),
			dataIndex: 'order',
			showSorterTooltip: { target: 'full-header' },
			defaultSortOrder: 'descend',
			sorter: (a, b) => a.order - b.order,
			sortDirections: ['ascend', 'descend'],
		},
		{
			title: t('pro.time'),
			dataIndex: 'time',
			sorter: (a, b) => a.time - b.time,
			sortDirections: ['ascend', 'descend'],
			render: (_, { time }) => <>{time} ms</>,
		},
		{
			title: t('pro.depth'),
			dataIndex: 'depth',
			sorter: (a, b) => a.depth - b.depth,
			sortDirections: ['ascend', 'descend'],
			render: (_, { depth }) => <>{Array.from({ length: depth }, (_, index) => <p style={{ display: 'inline-block', padding: 0, margin: 0 }} key={index}>&emsp;</p>)}{depth + 1}</>,
		},
		{
			title: t('pro.module'),
			dataIndex: 'moduleName',
		},
	];
};

const formatPart = (text: string) => {
	return <span>{
		text.split(/\[(error|warning|info)\]/).map((part, index) => {
			if (index % 2 === 1) {
				return <span key={index}>[<span style={{ color: part === 'error' ? Color.Error : part === 'warning' ? Color.Warning : Color.Info }}>{part}</span>]</span>;
			}
			return <span key={index}>{part}</span>;
		})
	}</span>;
};

const transitionProps = {
	appear: false,
	enter: false,
	exit: false
};

const LogView = memo((props: LogViewProps) => {
	const { t } = useTranslation();
	const compactLayout = useMediaQuery('(max-width: 760px), (max-height: 520px)');
	const portraitLayout = useMediaQuery('(max-width: 760px) and (orientation: portrait)');
	const logContainerRef = useRef<HTMLDivElement | null>(null);
	const logSnapshot = useBatchedLog();
	const text = logSnapshot.text === "" ? t("log.wait") : logSnapshot.text;
	const [command, setCommand] = useState("");
	const [history, setHistory] = useState<string[]>([]);
	const [historyIndex, setHistoryIndex] = useState<number>(-1);
	const [toggleProfiler, setToggleProfiler] = useState(compactLayout ? false : Info.webProfiler);
	const [profilerInfo, setProfilerInfo] = useState<ProfilerInfo | null>(null);
	const [tableColumns, setTableColumns] = useState<TableColumnsType<LoaderDataType>>(getTableColumns(t));
	const [logHeight, setLogHeight] = useState(1);
	const previousOpenNameRef = useRef<string | null>(null);
	const [fixTarget, setFixTarget] = useState<{
		lineNumber: number;
		top: number;
		left: number;
		message: string;
		panelOpen: boolean;
	} | null>(null);

	useEffect(() => {
		setTableColumns(getTableColumns(t));
	}, [t]);

	useEffect(() => {
		const wasClosed = previousOpenNameRef.current === null;
		const isOpen = props.openName !== null;
		if (compactLayout && wasClosed && isOpen) {
			setToggleProfiler(false);
		}
		previousOpenNameRef.current = props.openName;
	}, [compactLayout, props.openName]);

	useEffect(() => {
		const profilerListener = (info: ProfilerInfo) => {
			if (!toggleProfiler) {
				return;
			}
			if (info.loaderCosts === undefined) {
				info.loaderCosts = profilerInfo?.loaderCosts ?? [];
				baseLine = info.plotCount > 0 ? Array.from({ length: info.plotCount + 1 }, (_, index) => index) : [];
			}
			setProfilerInfo(info);
		};
		Service.addProfilerListener(profilerListener);
		return () => {
			Service.removeProfilerListener(profilerListener);
		};
	}, [t, profilerInfo?.loaderCosts, toggleProfiler]);

	const onClear = () => {
		Service.clearLog();
	};

	const onReload = async () => {
		try {
			const res = await Service.saveLog();
			if (res.success) {
				const assetPath = res.path;
				const x = new XMLHttpRequest();
				x.open("GET", Service.addr("/" + assetPath), true);
				x.responseType = 'text';
				x.onload = function () {
					Service.clearLog();
					Service.addLog(x.response);
				};
				x.send();
			}
		} catch (err) {
			console.error(err);
		}
	};

	const maxHistoryLength = 20;

	const onSubmit = (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault();
		if (command !== "") {
			setHistory(prev => {
				const newHistory = [...prev, command];
				if (newHistory.length > maxHistoryLength) {
					return newHistory.slice(-maxHistoryLength);
				}
				return newHistory;
			});
			setHistoryIndex(history.length >= maxHistoryLength ? maxHistoryLength : history.length + 1);
			setCommand("");
			Service.command({ code: command, log: true }).then().catch((err) => {
				console.error(err);
			});
		}
	};

	const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
		if (event.key === 'ArrowUp' || event.key === 'ArrowDown') {
			event.preventDefault();
			let newIndex = historyIndex;
			if (event.key === 'ArrowUp') {
				newIndex = newIndex > 0 ? newIndex - 1 : 0;
			} else if (event.key === 'ArrowDown') {
				newIndex = newIndex < history.length - 1 ? newIndex + 1 : history.length - 1;
			}
			if (newIndex >= 0 && newIndex < history.length) {
				setCommand(history[newIndex]);
				setHistoryIndex(newIndex);
			} else if (newIndex === history.length) {
				setCommand("");
				setHistoryIndex(newIndex);
			}
		}
	};

	const onToggleProfiler = () => {
		Service.command({ code: `Director.profilerSending = ${toggleProfiler ? 'false' : 'true'}`, log: false }).then(() => {
			setToggleProfiler(!toggleProfiler);
		}).catch((err) => {
			console.error(err);
		});
	};

	const onTargetFPSChange = (e: RadioChangeEvent) => {
		if (profilerInfo !== null) {
			profilerInfo.targetFPS = e.target.value;
			Service.command({ code: `App.targetFPS = ${profilerInfo.targetFPS}`, log: false }).then(() => {
				setProfilerInfo({ ...profilerInfo });
			}).catch((err) => {
				console.error(err);
			});
		}
	};

	const onFixedFPSChange = (e: RadioChangeEvent) => {
		if (profilerInfo !== null) {
			profilerInfo.fixedFPS = e.target.value;
			Service.command({ code: `Director.scheduler.fixedFPS = ${profilerInfo.fixedFPS}`, log: false }).then(() => {
				setProfilerInfo({ ...profilerInfo });
			}).catch((err) => {
				console.error(err);
			});
		}
	};

	const onVSyncChange = (e: CheckboxChangeEvent) => {
		if (profilerInfo !== null) {
			profilerInfo.vSync = e.target.checked;
			Service.command({ code: `View.vsync = ${profilerInfo.vSync ? 'true' : 'false'}`, log: false }).then(() => {
				setProfilerInfo({ ...profilerInfo });
			}).catch((err) => {
				console.error(err);
			});
		}
	};

	const onFPSLimitedChange = (e: CheckboxChangeEvent) => {
		if (profilerInfo !== null) {
			profilerInfo.fpsLimited = e.target.checked;
			Service.command({ code: `App.fpsLimited = ${profilerInfo.fpsLimited ? 'true' : 'false'}`, log: false }).then(() => {
				setProfilerInfo({ ...profilerInfo });
			}).catch((err) => {
				console.error(err);
			});
		}
	};

	const showFixButton = (event: MouseEvent, container: HTMLElement) => {
		if (!props.onFixLog) return;
		const target = event.target as HTMLElement | null;
		if (target?.closest("[data-log-fix-button],[data-log-fix-panel]")) return;
		const lineElement = target?.closest(`.${logFixLineClassName}`) as HTMLElement | null;
		const lineNumberText = lineElement?.querySelector("a[id]")?.getAttribute("id");
		const lineNumber = Number(lineNumberText);
		if (!lineElement || !Number.isFinite(lineNumber) || lineNumber <= 0) {
			setFixTarget(null);
			return;
		}
		const message = buildLogFixMessage(text, lineNumber);
		if (message === "") {
			setFixTarget(null);
			return;
		}
		const containerRect = container.getBoundingClientRect();
		const lineRect = lineElement.getBoundingClientRect();
		setFixTarget({
			lineNumber,
			message,
			top: Math.max(4, lineRect.top - containerRect.top - 2),
			left: Math.min(Math.max(8, event.clientX - containerRect.left + 8), Math.max(8, containerRect.width - 64)),
			panelOpen: false,
		});
	};

	useEffect(() => {
		const container = logContainerRef.current;
		if (!container) return;
		const updateHeight = () => {
			const nextHeight = Math.max(1, Math.floor(container.getBoundingClientRect().height));
			setLogHeight(current => current === nextHeight ? current : nextHeight);
		};
		const observer = new ResizeObserver(updateHeight);
		observer.observe(container);
		const frame = requestAnimationFrame(updateHeight);
		return () => {
			cancelAnimationFrame(frame);
			observer.disconnect();
		};
	}, [compactLayout, props.openName, toggleProfiler]);

	useEffect(() => {
		const container = logContainerRef.current;
		if (!container) return;
		const onMouseDown = (event: MouseEvent) => {
			showFixButton(event, container);
		};
		const onScroll = (event: Event) => {
			if ((event.target as HTMLElement | null)?.closest("[data-log-fix-panel]")) return;
			setFixTarget(current => current?.panelOpen ? current : null);
		};
		container.addEventListener("mousedown", onMouseDown, true);
		container.addEventListener("scroll", onScroll, true);
		return () => {
			container.removeEventListener("mousedown", onMouseDown, true);
			container.removeEventListener("scroll", onScroll, true);
		};
	});

	let basicItems: DescriptionsProps['items'];
	let timeItems: DescriptionsProps['items'];
	let objectItems: DescriptionsProps['items'];
	let memoryItems: DescriptionsProps['items'];
	let lineConfig: LineConfig | null = null;
	let pieConfig: PieConfig | null = null;
	let totalLoaderCost: number = 0;
	if (profilerInfo !== null) {
		basicItems = [
			{
				key: '1',
				label: <Tooltip title={t('pro.rendererTip')}>
					<div>{t("pro.renderer")}</div>
				</Tooltip>,
				children: profilerInfo.renderer,
			},
			{
				key: '2',
				label: <Tooltip title={t('pro.multiThreadedTip')}>
					<div>{t("pro.multiThreaded")}</div>
				</Tooltip>,
				children: profilerInfo.multiThreaded ? 'Yes' : 'No',
			},
			{
				key: '3',
				label: <Tooltip title={t('pro.backBufferTip')}>
					<div>{t("pro.backBuffer")}</div>
				</Tooltip>,
				children: profilerInfo.backBufferX + ' x ' + profilerInfo.backBufferY,
			},
			{
				key: '4',
				label: <Tooltip title={t('pro.drawCallTip')}>
					<div>{t("pro.drawCall")}</div>
				</Tooltip>,
				children: profilerInfo.drawCall,
			},
			{
				key: '5',
				label: <Tooltip title={t('pro.triTip')}>
					<div>{t("pro.tri")}</div>
				</Tooltip>,
				children: profilerInfo.tri,
			},
			{
				key: '6',
				label: <Tooltip title={t('pro.lineTip')}>
					<div>{t("pro.line")}</div>
				</Tooltip>,
				children: profilerInfo.line,
			},
			{
				key: '7',
				label: <Tooltip title={t('pro.visualSizeTip')}>
					<div>{t("pro.visualSize")}</div>
				</Tooltip>,
				children: profilerInfo.visualSizeX + ' x ' + profilerInfo.visualSizeY,
			},
			{
				key: '8',
				label: <Tooltip title={t('pro.vSyncTip')}>
					<div>{t("pro.vSync")}</div>
				</Tooltip>,
				children: <Checkbox checked={profilerInfo?.vSync} onChange={onVSyncChange} />,
			},
			{
				key: '9',
				label: <Tooltip title={t('pro.fpsLimitedTip')}>
					<div>{t("pro.fpsLimited")}</div>
				</Tooltip>,
				children: <Checkbox checked={profilerInfo?.fpsLimited} onChange={onFPSLimitedChange} />,
			},
			{
				key: '10',
				label: <Tooltip title={t('pro.fpsTip')}>
					<div>{t("pro.fps")}</div>
				</Tooltip>,
				children: (
					<Radio.Group onChange={onTargetFPSChange} value={profilerInfo.targetFPS}>
						<Radio value={30}>30</Radio>
						<br />
						<Radio value={45}>45</Radio>
						<br />
						<Radio value={60}>60</Radio>
						{profilerInfo.maxTargetFPS > 60 &&
							<><br /><Radio value={profilerInfo.maxTargetFPS}>{profilerInfo.maxTargetFPS}</Radio></>
						}
					</Radio.Group>
				),
			},
			{
				key: '11',
				label: <Tooltip title={t('pro.currentFPSTip')}>
					<div>{t("pro.currentFPS")}</div>
				</Tooltip>,
				children: profilerInfo.currentFPS,
			},
			{
				key: '12',
				label: <Tooltip title={t('pro.fixedFPSTip')}>
					<div>{t("pro.fixedFPS")}</div>
				</Tooltip>,
				children: (
					<Radio.Group onChange={onFixedFPSChange} value={profilerInfo.fixedFPS}>
						<Radio value={30}>30</Radio>
						<br />
						<Radio value={45}>45</Radio>
						<br />
						<Radio value={60}>60</Radio>
						{profilerInfo.maxTargetFPS > 60 &&
							<><br /><Radio value={profilerInfo.maxTargetFPS}>{profilerInfo.maxTargetFPS}</Radio></>
						}
					</Radio.Group>
				),
			},
		];
		timeItems = [
			{
				key: '1',
				label: <Tooltip title={t('pro.avgCPUTip')}>
					<div>{t("pro.avgCPU")}</div>
				</Tooltip>,
				children: profilerInfo.avgCPU + ' ms',
			},
			{
				key: '2',
				label: <Tooltip title={t('pro.avgGPUTip')}>
					<div>{t("pro.avgGPU")}</div>
				</Tooltip>,
				children: profilerInfo.avgGPU + ' ms',
			},
		];
		objectItems = [
			{
				key: '1',
				label: <Tooltip title={t('pro.cppObjectTip')}>
					<div>{t("pro.cppObject")}</div>
				</Tooltip>,
				children: profilerInfo.cppObject,
			},
			{
				key: '2',
				label: <Tooltip title={t('pro.luaObjectTip')}>
					<div>{t("pro.luaObject")}</div>
				</Tooltip>,
				children: profilerInfo.luaObject,
			},
			{
				key: '3',
				label: <Tooltip title={t('pro.luaCallbackTip')}>
					<div>{t("pro.luaCallback")}</div>
				</Tooltip>,
				children: profilerInfo.luaCallback,
			},
			{
				key: '4',
				label: <Tooltip title={t('pro.texturesTip')}>
					<div>{t("pro.textures")}</div>
				</Tooltip>,
				children: profilerInfo.textures,
			},
			{
				key: '5',
				label: <Tooltip title={t('pro.fontsTip')}>
					<div>{t("pro.fonts")}</div>
				</Tooltip>,
				children: profilerInfo.fonts,
			},
			{
				key: '6',
				label: <Tooltip title={t('pro.audiosTip')}>
					<div>{t("pro.audios")}</div>
				</Tooltip>,
				children: profilerInfo.audios,
			},
		];
		memoryItems = [
			{
				key: '1',
				label: <Tooltip title={t('pro.memoryPoolTip')}>
					<div>{t("pro.memoryPool")}</div>
				</Tooltip>,
				children: profilerInfo.memoryPool / 1024 + ' KB',
			},
			{
				key: '2',
				label: <Tooltip title={t('pro.luaMemoryTip')}>
					<div>{t("pro.luaMemory")}</div>
				</Tooltip>,
				children: (profilerInfo.luaMemory / 1024 / 1024).toFixed(2) + ' MB',
			},
			{
				key: '3',
				label: <Tooltip title={t('pro.tealMemoryTip')}>
					<div>{t("pro.tealMemory")}</div>
				</Tooltip>,
				children: (profilerInfo.tealMemory / 1024 / 1024).toFixed(2) + ' MB',
			},
			{
				key: '4',
				label: <Tooltip title={t('pro.wasmMemoryTip')}>
					<div>{t("pro.wasmMemory")}</div>
				</Tooltip>,
				children: (profilerInfo.wasmMemory / 1024 / 1024).toFixed(2) + ' MB',
			},
			{
				key: '5',
				label: <Tooltip title={t('pro.textureMemoryTip')}>
					<div>{t("pro.textureMemory")}</div>
				</Tooltip>,
				children: (profilerInfo.textureMemory / 1024 / 1024).toFixed(2) + ' MB',
			},
			{
				key: '6',
				label: <Tooltip title={t('pro.fontMemoryTip')}>
					<div>{t("pro.fontMemory")}</div>
				</Tooltip>,
				children: (profilerInfo.fontMemory / 1024 / 1024).toFixed(2) + ' MB',
			},
			{
				key: '7',
				label: <Tooltip title={t('pro.audioMemoryTip')}>
					<div>{t("pro.audioMemory")}</div>
				</Tooltip>,
				children: (profilerInfo.audioMemory / 1024 / 1024).toFixed(2) + ' MB',
			},
		];
		lineConfig = {
			data: baseLine.map((_, index) => {
				return { time: baseLine.length - index, value: 1000 / profilerInfo.targetFPS, category: 'Base' };
			}).concat(profilerInfo.cpuTimePeeks.map((value, index) => {
				return { time: profilerInfo.cpuTimePeeks.length - index, value: value, category: 'CPU' };
			})).concat(profilerInfo.gpuTimePeeks.map((value, index) => {
				return { time: profilerInfo.gpuTimePeeks.length - index, value: value, category: 'GPU' };
			})).concat(profilerInfo.deltaTimePeeks.map((value, index) => {
				return { time: profilerInfo.deltaTimePeeks.length - index, value: value, category: 'Delta' };
			})),
			xField: 'time',
			yField: 'value',
			legend: { size: false },
			colorField: 'category',
			title: {
				title: t("pro.frameTimePeaks"),
				style: {
					titleFontSize: 14,
					titleFill: Color.TextPrimary,
				},
			},
			autoFit: true,
			theme: "classicDark",
			animate: false,
			tooltip: false,
			marginLeft: 0,
			marginRight: 10,
		};
		let totalCost = 0;
		for (const cost of profilerInfo.updateCosts) {
			totalCost += cost.value;
		}
		pieConfig = {
			data: profilerInfo.updateCosts.filter(cost => cost.value > 0).map((cost) => {
				return { type: cost.name, value: Math.round(cost.value * 100 / totalCost) };
			}),
			angleField: 'value',
			colorField: 'type',
			label: {
				text: 'value',
				style: {
					fontWeight: 'bold',
				},
			},
			legend: {
				color: {
					title: false,
					position: 'top',
					rowPadding: 5,
				},
			},
			title: {
				title: t("pro.cpuTimePercent"),
				style: {
					titleFontSize: 14,
					titleFill: Color.TextPrimary,
				},
			},
			innerRadius: 0.5,
			autoFit: true,
			theme: "classicDark",
			animate: false,
			tooltip: false,
			marginLeft: 0,
			marginRight: 10,
		};
		totalLoaderCost = (profilerInfo.loaderCosts?.filter((item) => item.depth === 0).reduce((acc, cur) => acc + cur.time, 0) ?? 0) / 1000;
	} else {
		basicItems = [];
		timeItems = [];
		objectItems = [];
		memoryItems = [];
	}

	const consoleMinHeight = props.height * 0.3;
	const showLogPanel = !toggleProfiler || !compactLayout;

	return <Entry>
		<Dialog
			data-log-view-dialog="true"
			maxWidth="lg"
			fullWidth
			fullScreen={compactLayout}
			keepMounted
			open={props.openName !== null}
			onClose={props.onClose}
			hideBackdrop={props.allowBackgroundInteraction}
			disablePortal={props.allowBackgroundInteraction}
			disableAutoFocus={props.allowBackgroundInteraction}
			disableEnforceFocus={props.allowBackgroundInteraction}
			disableRestoreFocus={props.allowBackgroundInteraction}
			aria-labelledby="logview-dialog-title"
			aria-describedby="logview-dialog-description"
			transitionDuration={0}
			sx={props.allowBackgroundInteraction ? {
				pointerEvents: "none",
				"& .MuiDialog-paper": {
					pointerEvents: "auto",
				},
			} : undefined}
			slotProps={{
				transition: transitionProps,
				paper: {
					sx: {
						height: compactLayout ? "var(--dora-viewport-height, 100dvh)" : "auto",
						maxHeight: compactLayout ? "var(--dora-viewport-height, 100dvh)" : undefined,
						m: compactLayout ? 0 : undefined,
						overflow: "hidden",
					},
				},
			}}
		>
			<DialogContent sx={{
				display: "flex",
				flexDirection: "column",
				flex: compactLayout ? "1 1 auto" : "0 0 auto",
				width: "100%",
				height: compactLayout ? "auto" : props.height,
				minHeight: 0,
				overflow: "hidden",
				m: 0,
				p: 0,
			}}>
				<Box
					hidden={!toggleProfiler}
					data-log-view-performance="true"
					sx={{
						display: toggleProfiler ? "flex" : "none",
						flexDirection: "column",
						flex: compactLayout ? "1 1 auto" : "0 0 auto",
						minHeight: 0,
					}}
				>
					<Box sx={{
						width: "100%",
						height: compactLayout ? "100%" : props.height - consoleMinHeight - 1,
						minHeight: 0,
						background: Color.BackgroundDark,
					}}>
						<ConfigProvider
							theme={{
								algorithm: [theme.darkAlgorithm, theme.compactAlgorithm],
								components: {
									Radio: {
										colorPrimary: Color.Theme + 'aa',
									},
									Checkbox: {
										colorPrimary: Color.Theme + 'aa',
										colorPrimaryHover: Color.Theme,
									}
								}
							}}
						>
							<MacScrollbar
								skin='dark'
								suppressScrollX
								style={{ width: '100%', height: '100%' }}
							>
								<Box sx={{
									display: "grid",
									gridTemplateColumns: compactLayout
										? "repeat(auto-fit, minmax(min(100%, max(160px, calc((100% - 16px) / 3))), 1fr))"
										: "repeat(4, minmax(0, 1fr))",
									columnGap: 1,
									rowGap: 0,
									width: "100%",
									minWidth: 0,
									p: { xs: 1, sm: 1.25 },
									boxSizing: "border-box",
									alignItems: "start",
								}}>
									<Box sx={{ minWidth: 0 }}>
										<Descriptions title={t('pro.basic')} layout='vertical' bordered items={basicItems} size='small' column={3} />
									</Box>
									<Box sx={{ minWidth: 0, minHeight: 290 }}>
										<Descriptions title={t('pro.time')} layout='vertical' bordered items={timeItems} size='small' column={2} />
										{toggleProfiler && lineConfig ? <Box sx={{ height: 220, pointerEvents: "none" }}>
											<Line {...lineConfig} />
										</Box> : null}
									</Box>
									<Box sx={{ minWidth: 0, minHeight: 290 }}>
										<Descriptions title={t('pro.object')} layout='vertical' bordered items={objectItems} size='small' column={3} />
										{toggleProfiler && pieConfig ? <Box sx={{ height: 220, pointerEvents: "none" }}>
											<Pie {...pieConfig} />
										</Box> : null}
									</Box>
									<Box sx={{ minWidth: 0, minHeight: 290 }}>
										<Descriptions title={t('pro.memory')} layout='vertical' bordered items={memoryItems} size='small' column={3} />
									</Box>
									<Box sx={{
										minWidth: 0,
										minHeight: 290,
										gridColumn: compactLayout ? "1 / -1" : "span 2",
									}}>
										<Divider style={{ margin: "0px 0 8px" }}>
											{t('pro.loaderTimeCosts')} ({totalLoaderCost.toFixed(4)} s)
										</Divider>
										<Box sx={{ width: "100%", overflowX: "auto" }}>
											<Table bordered dataSource={profilerInfo?.loaderCosts?.map((item) => {
												return {
													key: item.order,
													order: item.order,
													time: item.time,
													depth: item.depth,
													moduleName: item.moduleName,
												};
											})} columns={tableColumns} />
										</Box>
									</Box>
								</Box>
							</MacScrollbar>
						</ConfigProvider>
					</Box>
					{compactLayout ? null : <Separator />}
				</Box>
				<Box
					data-log-view-console="true"
					ref={logContainerRef}
					sx={{
						position: "relative",
						display: showLogPanel ? "block" : "none",
						flex: toggleProfiler && !compactLayout
							? `0 0 ${consoleMinHeight}px`
							: "1 1 auto",
						height: toggleProfiler && !compactLayout ? consoleMinHeight : "auto",
						minHeight: 0,
						overflow: "hidden",
					}}
				>
					<LazyLog
						height={logHeight}
						text={text}
						style={{
							WebkitScrollSnapType: "none",
							fontSize: 18,
							fontFamily: "Roboto,Helvetica,Arial,sans-serif",
							color: Color.TextSecondary,
							background: Color.BackgroundDark,
						}}
						formatPart={formatPart}
						lineClassName={logFixLineClassName}
						rowHeight={22}
						extraLines={5}
						selectableLines
						enableSearch
						caseInsensitive
						stream
						follow
					/>
					{logSnapshot.truncated ? (
						<Box
							title={t("log.truncated")}
							sx={{
								position: "absolute",
								top: 8,
								right: 12,
								zIndex: 2,
								px: 1,
								py: 0.375,
								border: `1px solid ${Color.Warning}66`,
								borderRadius: 1.5,
								color: Color.Warning,
								backgroundColor: "rgba(28, 24, 16, 0.92)",
								fontSize: 12,
								pointerEvents: "none",
							}}
						>
							{t("log.truncatedShort")}
						</Box>
					) : null}
					{fixTarget && props.onFixLog && !fixTarget.panelOpen ? (
						<Button
							size="small"
							variant="contained"
							data-log-fix-button
							startIcon={<AutoAwesomeIcon sx={{ fontSize: 14 }} />}
							onClick={(event) => {
								event.stopPropagation();
								const containerWidth = logContainerRef.current?.clientWidth ?? 360;
								setFixTarget({
									...fixTarget,
									left: Math.min(fixTarget.left, Math.max(8, containerWidth - 356)),
									panelOpen: true,
								});
							}}
							sx={{
								position: "absolute",
								top: fixTarget.top,
								left: fixTarget.left,
								minWidth: 48,
								height: 24,
								px: 1,
								fontSize: 12,
								fontWeight: 600,
								color: Color.Theme,
								border: `1px solid ${Color.Theme}99`,
								backgroundColor: "rgba(34, 28, 14, 0.92)",
								zIndex: 2,
								"& .MuiButton-startIcon": {
									mr: 0.5,
								},
								"&:hover": {
									color: "#ffd66a",
									borderColor: Color.Theme,
									backgroundColor: "rgba(65, 48, 18, 0.96)",
								},
							}}
						>
							{t("log.fix")}
						</Button>
					) : null}
					{fixTarget && props.onFixLog && fixTarget.panelOpen ? (
						<Box
							sx={{
								position: "absolute",
								top: fixTarget.top,
								left: fixTarget.left,
								zIndex: 3,
							}}
						>
							<LogFixPanel
								defaultPrompt={`${t("log.fixPrompt")}${fixTarget.message}`}
								onClose={() => setFixTarget(null)}
								onSend={(prompt) => {
									props.onFixLog?.({
										lineNumber: fixTarget.lineNumber,
										message: prompt,
									});
									setFixTarget(null);
								}}
							/>
						</Box>
					) : null}
				</Box>
			</DialogContent>
			<DialogActions
				data-log-view-actions="true"
				sx={{
					flexDirection: portraitLayout ? "column" : "row",
					alignItems: portraitLayout ? "stretch" : "center",
					flexShrink: 0,
					gap: compactLayout ? 1 : 0,
					p: compactLayout ? 1 : undefined,
					backgroundColor: Color.BackgroundDark,
					"& > :not(style) ~ :not(style)": {
						ml: portraitLayout ? 0 : undefined,
					},
				}}
			>
				<form
					noValidate
					autoComplete="off"
					style={{
						flex: portraitLayout ? "0 0 auto" : 1,
						width: portraitLayout ? "100%" : "auto",
						minWidth: 0,
					}}
					onSubmit={onSubmit}
				>
					<FormControl fullWidth sx={{
						pr: portraitLayout ? 0 : 1,
					}}
					>
						<TextField
							fullWidth
							size={compactLayout ? "small" : "medium"}
							label={t("log.command")}
							id="commandline"
							value={command}
							onChange={e => setCommand(e.target.value)}
							onKeyDown={handleKeyDown}
						/>
					</FormControl>
				</form>
				<Box sx={{
					display: "grid",
					gridTemplateColumns: portraitLayout ? "repeat(4, minmax(0, 1fr))" : "repeat(4, auto)",
					width: portraitLayout ? "100%" : "auto",
					flexShrink: 0,
					minWidth: 0,
					alignItems: "center",
					p: 0,
					m: 0,
				}}>
					<Button
						aria-label="toggle-profiler"
						onClick={onToggleProfiler}
						startIcon={toggleProfiler ? <BsTerminal /> : <InsertChartIcon />}
						sx={{
							color: Color.Secondary,
							minWidth: 0,
							height: 36,
							px: compactLayout ? 1 : 2,
							whiteSpace: 'nowrap',
						}}
					>
						{toggleProfiler ? t("log.modeLog") : t("log.modePerformance")}
					</Button>
					<Button onClick={onReload}>
						{t("action.reload")}
					</Button>
					<Button onClick={onClear}>
						{t("action.clear")}
					</Button>
					<Button
						data-first-project-log-close="true"
						onClick={props.onClose}
						sx={{ minWidth: 0, px: compactLayout ? 1 : 2, mr: compactLayout ? 0 : 1.25 }}
					>
						{t("action.close")}
					</Button>
				</Box>
			</DialogActions>
		</Dialog>
	</Entry>;
});

export default LogView;

/* Copyright (c) 2017-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { LazyLog } from 'react-lazylog';
import * as Service from './Service';
import { FormEvent, memo, useEffect, useState } from 'react';
import { Box, Button, Dialog, DialogActions, DialogContent, FormControl, IconButton, TextField, Tooltip } from '@mui/material';
import { useTranslation } from 'react-i18next';
import { Color, Entry, Separator } from './Frame';
import { BsTerminal } from 'react-icons/bs';
import InsertChartIcon from '@mui/icons-material/InsertChart';
import { ProfilerInfo } from './ProfilerInfo';
import { Checkbox, ConfigProvider, Descriptions, Radio, theme } from 'antd';
import type { DescriptionsProps, RadioChangeEvent } from 'antd';
import { CheckboxChangeEvent } from 'antd/es/checkbox';
import { MacScrollbar } from 'mac-scrollbar';
import { Line, LineConfig, Pie, PieConfig } from '@ant-design/plots';
import { Table, Divider } from 'antd';
import type { TableColumnsType } from 'antd';
import Info from './Info';

export interface LogViewProps {
	openName: string | null;
	height: number;
	onClose: () => void;
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
			render: (_, { depth }) => <>{Array.from({length: depth}, (_, index) => <p style={{display: 'inline-block', padding: 0, margin: 0}} key={index}>&emsp;</p>)}{depth + 1}</>,
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
				return <span key={index}>[<span style={{color: part === 'error' ? Color.Error : part === 'warning' ? Color.Warning : Color.Info}}>{part}</span>]</span>;
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
	const {t} = useTranslation();
	const [text, setText] = useState(t("log.wait"));
	const [command, setCommand] = useState("");
	const [history, setHistory] = useState<string[]>([]);
	const [historyIndex, setHistoryIndex] = useState<number>(-1);
	const [toggleProfiler, setToggleProfiler] = useState(Info.webProfiler);
	const [profilerInfo, setProfilerInfo] = useState<ProfilerInfo | null>(null);
	const [tableColumns, setTableColumns] = useState<TableColumnsType<LoaderDataType>>(getTableColumns(t));

	useEffect(() => {
		setTableColumns(getTableColumns(t));
	}, [t]);

	useEffect(() => {
		const logListener = (_newItem: string, allText: string) => {
			setText(allText === "" ? t("log.wait") : allText);
		};
		Service.addLogListener(logListener);
		const profilerListener = (info: ProfilerInfo) => {
			if (!toggleProfiler) {
				return;
			}
			if (info.loaderCosts === undefined) {
				info.loaderCosts = profilerInfo?.loaderCosts ?? [];
				baseLine = info.plotCount > 0 ? Array.from({length: info.plotCount + 1}, (_, index) => index) : [];
			}
			setProfilerInfo(info);
		};
		Service.addProfilerListener(profilerListener);
		return () => {
			Service.removeLogListener(logListener);
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
				x.onload = function() {
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
			Service.command({code: command, log: true}).then().catch((err) => {
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
		Service.command({code: `Director.profilerSending = ${toggleProfiler ? 'false' : 'true'}`, log: false}).then(() => {
			setToggleProfiler(!toggleProfiler);
		}).catch((err) => {
			console.error(err);
		});
	};

	const onTargetFPSChange = (e: RadioChangeEvent) => {
		if (profilerInfo !== null) {
			profilerInfo.targetFPS = e.target.value;
			Service.command({code: `App.targetFPS = ${profilerInfo.targetFPS}`, log: false}).then(() => {
				setProfilerInfo({...profilerInfo});
			}).catch((err) => {
				console.error(err);
			});
		}
	};

	const onFixedFPSChange = (e: RadioChangeEvent) => {
		if (profilerInfo !== null) {
			profilerInfo.fixedFPS = e.target.value;
			Service.command({code: `Director.scheduler.fixedFPS = ${profilerInfo.fixedFPS}`, log: false}).then(() => {
				setProfilerInfo({...profilerInfo});
			}).catch((err) => {
				console.error(err);
			});
		}
	};

	const onVSyncChange = (e: CheckboxChangeEvent) => {
		if (profilerInfo !== null) {
			profilerInfo.vSync = e.target.checked;
			Service.command({code: `View.vsync = ${profilerInfo.vSync ? 'true' : 'false'}`, log: false}).then(() => {
				setProfilerInfo({...profilerInfo});
			}).catch((err) => {
				console.error(err);
			});
		}
	};

	const onFPSLimitedChange = (e: CheckboxChangeEvent) => {
		if (profilerInfo !== null) {
			profilerInfo.fpsLimited = e.target.checked;
			Service.command({code: `App.fpsLimited = ${profilerInfo.fpsLimited ? 'true' : 'false'}`, log: false}).then(() => {
				setProfilerInfo({...profilerInfo});
			}).catch((err) => {
				console.error(err);
			});
		}
	};

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
				children: <Checkbox checked={profilerInfo?.vSync} onChange={onVSyncChange}/>,
			},
			{
				key: '9',
				label: <Tooltip title={t('pro.fpsLimitedTip')}>
					<div>{t("pro.fpsLimited")}</div>
				</Tooltip>,
				children: <Checkbox checked={profilerInfo?.fpsLimited} onChange={onFPSLimitedChange}/>,
			},
			{
				key: '10',
				label: <Tooltip title={t('pro.fpsTip')}>
					<div>{t("pro.fps")}</div>
				</Tooltip>,
				children: (
					<Radio.Group onChange={onTargetFPSChange} value={profilerInfo.targetFPS}>
						<Radio value={30}>30</Radio>
						<br/>
						<Radio value={45}>45</Radio>
						<br/>
						<Radio value={60}>60</Radio>
						{profilerInfo.maxTargetFPS > 60 &&
							<><br/><Radio value={profilerInfo.maxTargetFPS}>{profilerInfo.maxTargetFPS}</Radio></>
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
						<br/>
						<Radio value={45}>45</Radio>
						<br/>
						<Radio value={60}>60</Radio>
						{profilerInfo.maxTargetFPS > 60 &&
							<><br/><Radio value={profilerInfo.maxTargetFPS}>{profilerInfo.maxTargetFPS}</Radio></>
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
				return {time: baseLine.length - index, value: 1000 / profilerInfo.targetFPS, category: 'Base'};
			}).concat(profilerInfo.cpuTimePeeks.map((value, index) => {
				return {time: profilerInfo.cpuTimePeeks.length - index, value: value, category: 'CPU'};
			})).concat(profilerInfo.gpuTimePeeks.map((value, index) => {
				return {time: profilerInfo.gpuTimePeeks.length - index, value: value, category: 'GPU'};
			})).concat(profilerInfo.deltaTimePeeks.map((value, index) => {
				return {time: profilerInfo.deltaTimePeeks.length - index, value: value, category: 'Delta'};
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
				return {type: cost.name, value: Math.round(cost.value * 100 / totalCost)};
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

	return <Entry>
		<Dialog
			maxWidth="lg"
			fullWidth
			keepMounted
			open={props.openName !== null}
			aria-labelledby="logview-dialog-title"
			aria-describedby="logview-dialog-description"
			transitionDuration={0}
			slotProps={{transition: transitionProps}}
		>
			<DialogContent style={{overflow: "hidden", margin: 0, padding: 0}}>
				<div hidden={!toggleProfiler}>
					<Box sx={{
						width: "100%",
						height: props.height - consoleMinHeight - 1,
						background: Color.BackgroundDark
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
							<MacScrollbar skin='dark' style={{width: '100%', height: '100%'}}>
								<div style={{
									display: 'flex',
									flexDirection: 'row',
									flexWrap: 'wrap',
									width: '100%',
									height: '100%',
									padding: 10,
								}}>
									<div style={{padding: 5, width: '25%', minHeight: 400}}>
										<Descriptions title={t('pro.basic')} layout='vertical' bordered items={basicItems} size='small'/>
									</div>
									<div style={{padding: 5, width: '25%', height: 290}}>
										<Descriptions title={t('pro.time')} layout='vertical' bordered items={timeItems} size='small'/>
										{lineConfig ? <Line {...lineConfig}/> : null}
									</div>
									<div style={{padding: 5, width: '25%', height: 290}}>
										<Descriptions title={t('pro.object')} layout='vertical' bordered items={objectItems} size='small'/>
										{pieConfig ? <Pie {...pieConfig}/> : null}
									</div>
									<div style={{padding: 5, width: '25%', minHeight: 290}}>
										<Descriptions title={t('pro.memory')} layout='vertical' bordered items={memoryItems} size='small'/>
									</div>
									<div style={{padding: 5, width: '50%', minHeight: 290}}>
										<Divider>{t('pro.loaderTimeCosts')} ({totalLoaderCost.toFixed(4)} s)</Divider>
										<Table bordered dataSource={profilerInfo?.loaderCosts?.map((item) => {
											return {
												key: item.order,
												order: item.order,
												time: item.time,
												depth: item.depth,
												moduleName: item.moduleName,
											};
										})} columns={tableColumns}/>
									</div>
								</div>
							</MacScrollbar>
						</ConfigProvider>
					</Box>
					<Separator/>
				</div>
				<LazyLog
					height={toggleProfiler ? consoleMinHeight : props.height}
					text={text}
					style={{
						msOverflowStyle: "none",
						scrollbarWidth: "none",
						WebkitScrollSnapType: "none",
						fontSize: 18,
						fontFamily: "Roboto,Helvetica,Arial,sans-serif",
						color: Color.TextSecondary,
						background: Color.BackgroundDark,
					}}
					formatPart={formatPart}
					rowHeight={22}
					extraLines={1}
					selectableLines
					enableSearch
					caseInsensitive
					stream
					follow
				/>
				<div style={{position: 'absolute', bottom: 10, right: 10, opacity: 0.5, display: 'flex', alignItems: 'center'}}>
					<p style={{fontSize: 14, marginRight: 10, color: Color.Secondary}}>{props.openName}</p>
					<IconButton
						color="secondary"
						aria-label="toggle-profiler"
						onClick={onToggleProfiler}
						sx={{width: 40, height: 40}}
					>
						{toggleProfiler ?
							<BsTerminal/> :
							<InsertChartIcon/>
						}
					</IconButton>
				</div>
			</DialogContent>
			<DialogActions>
				<form noValidate autoComplete="off" style={{width: "100%"}} onSubmit={onSubmit}>
					<FormControl fullWidth sx={{
							paddingRight: 3,
							"& .MuiOutlinedInput-notchedOutline": {
								borderColor: Color.Secondary,
							}
						}}
					>
						<TextField
							label={t("log.command")}
							id="commandline"
							value={command}
							onChange={e => setCommand(e.target.value)}
							onKeyDown={handleKeyDown}
						/>
					</FormControl>
				</form>
				<Button onClick={onReload}>
					{t("action.reload")}
				</Button>
				<Button onClick={onClear}>
					{t("action.clear")}
				</Button>
				<Button onClick={props.onClose} style={{marginRight: 20}}>
					{t("action.close")}
				</Button>
			</DialogActions>
		</Dialog>
	</Entry>;
});

export default LogView;
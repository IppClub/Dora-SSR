/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { LazyLog } from 'react-lazylog';
import * as Service from './Service';
import { FormEvent, memo, useEffect, useState } from 'react';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, FormControl, TextField } from '@mui/material';
import { useTranslation } from 'react-i18next';
import { Color, Entry } from './Frame';

export interface LogViewProps {
	openName: string | null;
	height: number;
	onClose: () => void;
};

const LogView = memo((props: LogViewProps) => {
	const {t} = useTranslation();
	const [text, setText] = useState(t("log.wait"));
	const [command, setCommand] = useState("");
	const [history, setHistory] = useState<string[]>([]);
	const [historyIndex, setHistoryIndex] = useState<number>(-1);

	useEffect(() => {
		const logListener = (newItem: string, allText: string) => {
			setText(allText === "" ? t("log.wait") : allText);
		};
		Service.addLogListener(logListener);
		return () => {
			Service.removeLogListener(logListener);
		};
	}, [t]);

	const onClear = () => {
		Service.clearLog();
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
			Service.command({code: command}).then().catch((err) => {
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

	return <Entry>
		<Dialog
			maxWidth="lg"
			fullWidth
			open={props.openName !== null}
			aria-labelledby="logview-dialog-title"
			aria-describedby="logview-dialog-description"
		>
			<DialogTitle id="logview-dialog-title">
				{props.openName}
			</DialogTitle>
			<DialogContent>
				<LazyLog
					height={props.height}
					text={text}
					style={{
						fontSize: 18,
						fontFamily: "Roboto,Helvetica,Arial,sans-serif",
						color: Color.TextSecondary
					}}
					rowHeight={22}
					selectableLines
					enableSearch
					stream
					follow
				/>
			</DialogContent>
			<DialogActions>
				<form noValidate autoComplete="off" style={{width: "100%"}} onSubmit={onSubmit}>
					<FormControl fullWidth sx={{
							m: 2,
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
				<Button onClick={onClear}>
					{t("action.clear")}
				</Button>
				<Button onClick={props.onClose}>
					{t("action.close")}
				</Button>
			</DialogActions>
		</Dialog>
	</Entry>;
});

export default LogView;
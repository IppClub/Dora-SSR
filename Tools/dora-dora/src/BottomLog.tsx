/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { LazyLog } from 'react-lazylog';
import { useTranslation } from 'react-i18next';
import { Color } from './Theme';
import * as Service from './Service';
import { memo, useEffect, useRef, useState } from 'react';
import { LogFixRequest, buildLogFixMessage, logFixLineClassName } from './LogFix';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';

export interface BottomLogProps {
	height: number;
	onFixLog?: (request: LogFixRequest) => void;
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

const BottomLog = memo((props: BottomLogProps) => {
	const { t } = useTranslation();
	const logContainerRef = useRef<HTMLDivElement | null>(null);
	const [text, setText] = useState(t("log.wait"));
	const [fixTarget, setFixTarget] = useState<{
		lineNumber: number;
		top: number;
		left: number;
		message: string;
	} | null>(null);


	useEffect(() => {
		const logListener = (_newItem: string, allText: string) => {
			setText(allText === "" ? t("log.wait") : allText);
		};
		Service.addLogListener(logListener);
		return () => {
			Service.removeLogListener(logListener);
		};
	}, [t]);

	const showFixButton = (event: MouseEvent, container: HTMLElement) => {
		if (!props.onFixLog) return;
		const target = event.target as HTMLElement | null;
		if (target?.closest("[data-log-fix-button]")) return;
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
		});
	};

	useEffect(() => {
		const container = logContainerRef.current;
		if (!container) return;
		const onMouseDown = (event: MouseEvent) => {
			showFixButton(event, container);
		};
		container.addEventListener("mousedown", onMouseDown, true);
		return () => {
			container.removeEventListener("mousedown", onMouseDown, true);
		};
	});

	return <div style={{
		height: props.height,
		backgroundColor: Color.BackgroundDark,
		overflow: "hidden",
		overscrollBehavior: "contain",
		position: "relative",
	}} ref={logContainerRef}>
		<LazyLog
			height={props.height}
			text={text}
			containerStyle={{
				width: 'auto',
				maxWidth: 'initial',
				overflow: 'initial',
				backgroundColor: Color.BackgroundDark,
			}}
			style={{
				msOverflowStyle: "none",
				scrollbarWidth: "none",
				WebkitScrollSnapType: "none",
				overscrollBehavior: "contain",
				fontSize: 18,
				fontFamily: "Roboto,Helvetica,Arial,sans-serif",
				color: Color.TextSecondary,
				backgroundColor: Color.BackgroundDark,
			}}
			formatPart={formatPart}
			lineClassName={logFixLineClassName}
			rowHeight={22}
			extraLines={1}
			selectableLines
			enableSearch
			caseInsensitive
			stream
			follow
			onScroll={() => setFixTarget(null)}
		/>
		{fixTarget && props.onFixLog ? (
			<button
				type="button"
				data-log-fix-button
				onClick={(event) => {
					event.stopPropagation();
					props.onFixLog?.({
						lineNumber: fixTarget.lineNumber,
						message: fixTarget.message,
					});
					setFixTarget(null);
				}}
				style={{
					position: "absolute",
					top: fixTarget.top,
					left: fixTarget.left,
					height: 24,
					padding: "0 10px",
					border: `1px solid ${Color.Theme}`,
					borderRadius: 6,
					color: Color.BackgroundDark,
					background: Color.Theme,
					fontSize: 12,
					fontWeight: 600,
					cursor: "pointer",
					zIndex: 2,
					display: "inline-flex",
					alignItems: "center",
					gap: 4,
				}}
			>
				<AutoAwesomeIcon sx={{ fontSize: 14 }} />
				{t("log.fix")}
			</button>
		) : null}
	</div>;
});

export default BottomLog;

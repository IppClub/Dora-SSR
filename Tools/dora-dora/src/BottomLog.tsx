/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { LazyLog } from 'react-lazylog';
import { useTranslation } from 'react-i18next';
import { Color } from './Theme';
import * as Service from './Service';
import { memo, useEffect, useState } from 'react';

export interface BottomLogProps {
	height: number;
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

const BottomLog = memo((props: BottomLogProps) => {
	const {t} = useTranslation();
	const [text, setText] = useState(t("log.wait"));


	useEffect(() => {
		const logListener = (_newItem: string, allText: string) => {
			setText(allText === "" ? t("log.wait") : allText);
		};
		Service.addLogListener(logListener);
		return () => {
			Service.removeLogListener(logListener);
		};
	}, [t]);

	return <LazyLog
		height={props.height}
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
	/>;
});

export default BottomLog;

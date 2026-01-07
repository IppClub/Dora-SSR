/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { memo } from "react";

export interface CodeWireData {
	getScript: () => string;
	getVisualScript: () => string;
	setVisualScript: (script: string) => void;
	reportVisualScriptError: (message: string) => void;
};

export interface CodeWireProps {
	title: string;
	width: number;
	height: number;
	defaultValue?: string;
	onLoad: (data: CodeWireData) => void;
	onChange: () => void;
	onKeydown: (event: KeyboardEvent) => void;
};

const CodeWire = memo((props: CodeWireProps) => {
	return <iframe
		width={props.width}
		height={props.height}
		title={props.title}
		onLoad={(e) => {
			if (e.currentTarget.contentWindow === null) {
				return;
			}
			const win = e.currentTarget.contentWindow as any;
			win.document.addEventListener("mouseup", () => {
				props.onChange();
			});
			if (props.defaultValue !== undefined && props.defaultValue !== "") {
				win.setVisualScript(props.defaultValue);
			}
			props.onLoad(win as CodeWireData);
			win.document.addEventListener("keydown", (event: KeyboardEvent) => {
				if (event.ctrlKey || event.altKey || event.metaKey) {
					switch (event.key) {
						case 'N': case 'n':
						case 'D': case 'd':
						case 'S': case 's':
						case 'W': case 'w':
						case 'R': case 'r':
						case 'P': case 'p':
						case 'Q': case 'q': {
							event.preventDefault();
							props.onKeydown(event);
							break;
						}
					}
				} else {
					props.onChange();
				}
			});
		}}
		src="code-wire/index.html"
		style={{
			border: 'none',
			overflowY: 'hidden',
		}}/>;
}, (prevProps, nextProps) => {
	return prevProps.width === nextProps.width &&
		prevProps.height === nextProps.height &&
		prevProps.title === nextProps.title;
});

export default CodeWire;

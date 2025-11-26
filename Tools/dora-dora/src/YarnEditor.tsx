/* Copyright (c) 2017-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { memo } from "react";
import * as Service from "./Service";
import { convertYarnTextToJson } from "./YarnConvert";

export interface YarnEditorData {
	warpToFocusedNode: () => void;
	getJSONData: () => Promise<string>;
};

export interface YarnEditorProps {
	title: string;
	width: number;
	height: number;
	defaultValue?: string;
	onLoad: (data: YarnEditorData) => void;
	onChange: () => void;
	onKeydown: (event: KeyboardEvent) => void;
};

const YarnEditor = memo((props: YarnEditorProps) => {
	return <iframe
		width={props.width}
		height={props.height}
		title={props.title}
		onLoad={(e) => {
			if (e.currentTarget.contentWindow !== null) {
				const win = e.currentTarget.contentWindow as any;
				win.addEventListener("yarnSavedStateToLocalStorage", () => {
					props.onChange();
				});
				let defaultValue: string | undefined = undefined;
				if (props.defaultValue !== undefined) {
					try {
						defaultValue = JSON.stringify(convertYarnTextToJson(props.defaultValue));
					} catch (e) {
						console.error(e);
					}
				}
				win.app.data.startNewFile(props.title, defaultValue);
				props.onLoad(win.app.data as YarnEditorData);
				win.document.addEventListener("YarnCheckSyntax", (e: { code: string }) => {
					Service.checkYarn({ code: e.code }).then((res) => {
						const event = new Event("YarnChecked");
						if (res.success) {
							(event as any).syntaxError = res.syntaxError;
							win.document.dispatchEvent(event);
						} else {
							(event as any).syntaxError = "Failed to check syntax";
							win.document.dispatchEvent(event);
						}
					}).catch(() => {
						const event = new Event("YarnChecked");
						(event as any).syntaxError = "Failed to check syntax";
						win.document.dispatchEvent(event);
					});
				});
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
					}
				});
			}
		}}
		src="yarn-editor/index.html"
		style={{
			border: 'none',
			overflowY: 'hidden',
		}}/>;
}, (prevProps, nextProps) => {
	return prevProps.width === nextProps.width &&
		prevProps.height === nextProps.height &&
		prevProps.title === nextProps.title;
});

export default YarnEditor;

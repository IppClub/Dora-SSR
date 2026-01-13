/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { memo } from "react";
import * as Service from "./Service";
import { AlertColor } from "@mui/material";
import { useTranslation } from 'react-i18next';
import Info from './Info';

export interface TIC80EditorProps {
	title: string;
	width: number;
	height: number;
	filePath: string;
	resPath: string;
	defaultValue?: string;
	onKeydown: (event: KeyboardEvent) => void;
	addAlert: (msg: string, type: AlertColor) => void;
};

const TIC80Editor = memo((props: TIC80EditorProps) => {
	const { t } = useTranslation();
	return <iframe
		width={props.width}
		height={props.height}
		title={props.title}
		onLoad={(e) => {
			if (e.currentTarget.contentWindow !== null) {
				const win = e.currentTarget.contentWindow as any;
				const filePath = props.filePath;

				// Listen for messages from iframe
				const handleMessage = async (event: MessageEvent) => {
					if (event.source !== win) return;

					if (event.data && event.data.type) {
						switch (event.data.type) {
							case 'TIC80_READ_FILE': {
								// Download binary file using HTTP GET
								try {
									const response = await fetch(Service.addr("/" + props.resPath.replace(/\\/g, "/")));
									if (response.ok) {
										const arrayBuffer = await response.arrayBuffer();
										const rom = new Uint8Array(arrayBuffer);
										// Send content back to iframe
										win.postMessage({
											type: 'TIC80_READ_FILE_RESPONSE',
											success: true,
											rom
										}, '*');
									} else {
										win.postMessage({
											type: 'TIC80_READ_FILE_RESPONSE',
											success: false
										}, '*');
									}
								} catch (error) {
									console.error("Error downloading file:", error);
									win.postMessage({
										type: 'TIC80_READ_FILE_RESPONSE',
										success: false
									}, '*');
								}
								break;
							}
							case 'TIC80_WRITE_FILE': {
								// Write file using Service
								try {
									const blob = event.data.rom;
									const filename = event.data.filename;
									// Upload the blob to the server using Service
									const formData = new FormData();
									formData.append('file', blob, filePath);

									const res = await fetch(Service.addr(`/upload?path=${props.filePath}`), {
										method: 'POST',
										body: formData,
									});
									const basename = Info.path.basename(props.filePath);
									if (res.ok) {
										if (basename !== filename) {
											props.addAlert(t("tic.overridden", {oldFilename: basename, newFilename: filename}), "success");
										} else {
											props.addAlert(t("tic.updated", {filename}), "success");
										}
									} else {
										props.addAlert(t("tic.updateFailed", {basename}), "error");
									}
								} catch (error) {
									console.error("Error writing file:", error);
								}
								break;
							}
						}
					}
				};

				window.addEventListener('message', handleMessage);

				// Send file path to iframe
				win.postMessage({
					type: 'TIC80_INIT',
					filePath: filePath,
					defaultValue: props.defaultValue
				}, '*');

				// Handle keyboard events
				win.document.addEventListener("keydown", (event: KeyboardEvent) => {
					if (event.ctrlKey || event.altKey || event.metaKey) {
						switch (event.key) {
							case 'N': case 'n':
							case 'W': case 'w': {
								event.preventDefault();
								props.onKeydown(event);
								break;
							}
						}
					}
				});
			}
		}}
		src="tic80/index.html"
		style={{
			border: 'none',
			overflowY: 'hidden',
		}}/>;
}, (prevProps, nextProps) => {
	return prevProps.width === nextProps.width &&
		prevProps.height === nextProps.height &&
		prevProps.title === nextProps.title &&
		prevProps.filePath === nextProps.filePath;
});

export default TIC80Editor;

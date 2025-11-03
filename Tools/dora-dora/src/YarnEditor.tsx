/* Copyright (c) 2017-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { memo } from "react";
import * as Service from "./Service";
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
						let event = new Event("YarnChecked");
						if (res.success) {
							(event as any).syntaxError = res.syntaxError;
							win.document.dispatchEvent(event);
						} else {
							(event as any).syntaxError = "Failed to check syntax";
							win.document.dispatchEvent(event);
						}
					}).catch(() => {
						let event = new Event("YarnChecked");
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

type YarnSpinnerJSON = {
	header: any;
	nodes: {
		title: string;
		tags: string;
		body: string;
		position: { x: number; y: number };
		colorID: number;
	}[]
};

function generateYamlHeader(header: any): string {
	const lines: string[] = [];
	const indent = (level: number) => '  '.repeat(level);

	if (header.comments) {
		for (const comment of header.comments) {
			lines.push(comment);
		}
	}

	// Plugin storage
	if (header.pluginStorage?.Runner?.variables) {
		lines.push(`variables:`);

		for (const v of header.pluginStorage.Runner.variables) {
			lines.push(`${indent(1)}- key: ${v.key}`);
			lines.push(`${indent(2)}value: ${v.value}`);
		}
	}

	return lines.map(line => `// ${line}`).join('\n');
}

function convertBodyToYarn(body: string): string {
	return body.replace(/\r\n/g, '\n');
}

function convertNodeToYarn(node: YarnSpinnerJSON['nodes'][0]): string {
	const lines = [
		`title: ${node.title}`,
		`tags: ${node.tags}`,
		`position: ${node.position.x},${node.position.y}`,
		`colorID: ${node.colorID}`,
		'---',
		convertBodyToYarn(node.body),
		'===\n'
	];
	return lines.join('\n');
}

export function convertYarnJsonToText(obj: object): string {
	const json = obj as YarnSpinnerJSON;
	const headerComment = generateYamlHeader(json.header);
	const nodes = json.nodes.map(convertNodeToYarn).join('\n');
	return headerComment === "" ? nodes : `${headerComment}\n\n${nodes}`;
}

type YarnNode = {
	title: string;
	tags: string;
	body: string;
	position: { x: number; y: number };
	colorID: number;
};

function parseYamlHeader(lines: string[]): any {
	const header: any = {};
	const variables: { key: string; value: any }[] = [];

	let inVariables = false;
	let currentVar: { key?: string; value?: any } = {};

	for (const line of lines) {
		const raw = line.replace(/^\/\/\s?/, '').trim().replace(/\s+/, ' ');

		if (raw === 'variables:') {
			inVariables = true;
		} else if (inVariables && raw.startsWith('- key:')) {
			if (Object.keys(currentVar).length > 0) {
				variables.push(currentVar as any);
				currentVar = {};
			}
			currentVar.key = raw.slice('- key:'.length).trim();
		} else if (inVariables && raw.startsWith('value:')) {
			const valRaw = raw.slice('value:'.length).trim();
			currentVar.value = valRaw;
		} else {
			if (header.comments) {
				header.comments.push(raw);
			} else {
				header.comments = [raw];
			}
		}
	}

	if (Object.keys(currentVar).length > 0) {
		variables.push(currentVar as any);
	}

	if (variables.length > 0) {
		header.pluginStorage = {
			Runner: {
				variables
			}
		};
	}

	return header;
}

function parseYarnNodes(content: string): YarnNode[] {
	const nodeChunks = content.replace(/\r\n/g, '\n').split(/^===\s*$/m).map(chunk => chunk.trim()).filter(Boolean);

	return nodeChunks.map((chunk) => {
		const [metaPart, ...bodyParts] = chunk.split(/^---\s*$/m);
		const metaLines = metaPart.split('\n').map(line => line.trim());
		const body = bodyParts.join('\n').trim();

		let title = '';
		let tags = '';
		let position = { x: 0, y: 0 };
		let colorID = 0;

		for (const line of metaLines) {
			if (line.startsWith('title:')) {
				title = line.slice(6).trim();
			} else if (line.startsWith('tags:')) {
				tags = line.slice(5).trim();
			} else if (line.startsWith('position:')) {
				const [x, y] = line.slice(9).trim().split(',').map(s => s.trim()).map(Number);
				position = { x, y };
			} else if (line.startsWith('colorID:')) {
				colorID = parseInt(line.slice(8).trim());
			}
		}

		return { title, tags, position, colorID, body };
	});
}

export function convertYarnTextToJson(yarnText: string): YarnSpinnerJSON {
	const lines = yarnText.replace(/\r\n/g, '\n').split('\n');

	const headerLines: string[] = [];
	let index = 0;
	while (index < lines.length) {
		const line = lines[index].trim();
		if (line.startsWith('//')) {
			headerLines.push(line);
		} else if (line !== '') {
			break;
		}
		index++;
	}

	const contentLines = lines.slice(index);

	let header = undefined;
	try {
		header = parseYamlHeader(headerLines);
	} catch (e) {
		console.error(e);
	}
	header ??= {};
	const content = contentLines.join('\n');
	let nodes: YarnNode[] | undefined = undefined;
	try {
		nodes = parseYarnNodes(content);
	} catch (e) {
		console.error(e);
	}
	nodes ??= [];
	return { header, nodes };
}


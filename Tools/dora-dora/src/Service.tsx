/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import EventEmitter from "events";
import type { TreeDataType } from "./FileTree";
import type { AlertColor } from '@mui/material';
import { ProfilerInfo } from "./ProfilerInfo";

let webSocket: WebSocket;
const eventEmitter = new EventEmitter();

function wsUrl() {
	let url: string;
	if (!process.env.NODE_ENV || process.env.NODE_ENV === 'development') {
		url = "ws://localhost:8868";
	} else {
		url = `ws://${window.location.hostname}:8868`;
	}
	return url;
}

const wsOpenEvent = "Open";
const wsCloseEvent = "Close";
const logEventName = "Log";
const alertEventName = "Alert";
const profilerEventName = "Profiler";

let logText = "";

export const addLog = (text: string) => {
	logText += text;
	eventEmitter.emit(logEventName, text, logText);
};

export const clearLog = () => {
	logText = "";
	eventEmitter.emit(logEventName, "", logText);
};

export const getLog = () => {
	return logText;
};

export const addLogListener = (listener: (newItem: string, allText: string) => void) => {
	eventEmitter.on(logEventName, listener);
};

export const removeLogListener = (listener: (newItem: string, allText: string) => void) => {
	eventEmitter.removeListener(logEventName, listener);
};

export const addProfilerListener = (listener: (info: ProfilerInfo) => void) => {
	eventEmitter.on(profilerEventName, listener);
};

export const removeProfilerListener = (listener: (info: ProfilerInfo) => void) => {
	eventEmitter.removeListener(profilerEventName, listener);
};

export const addWSOpenListener = (listener: () => void) => {
	eventEmitter.on(wsOpenEvent, listener);
};

export const addWSCloseListener = (listener: () => void) => {
	eventEmitter.on(wsCloseEvent, listener);
};

export const addAlertListener = (listener: (message: string, color: AlertColor) => void) => {
	eventEmitter.on(alertEventName, listener);
};

export const alert = (message: string, color: AlertColor) => {
	eventEmitter.emit(alertEventName, message, color);
};

export function openWebSocket() {
	let connected = false;
	const connect = () => {
		connected = false;
		webSocket = new WebSocket(wsUrl());
		webSocket.onmessage = function(evt: MessageEvent<string>) {
			const result = JSON.parse(evt.data);
			if (result !== null && result.name !== undefined) {
				switch (result.name) {
					case logEventName: {
						logText += result.text as string;
						eventEmitter.emit(result.name, result.text, logText);
						break;
					}
					case profilerEventName: {
						eventEmitter.emit(result.name, result.info);
						break;
					}
					default: {
						eventEmitter.emit(result.name, result);
						break;
					}
				}
			}
		};
		webSocket.onopen = () => {
			connected = true;
			eventEmitter.emit(wsOpenEvent);
		};
		webSocket.onclose = () => {
			if (connected) {
				connected = false;
				eventEmitter.emit(wsCloseEvent);
			}
			setTimeout(connect, 1000);
		};
		webSocket.onerror = () => {
			webSocket.close();
		};
	};
	connect();
};

export function addr(url: string) {
	if (!process.env.NODE_ENV || process.env.NODE_ENV === 'development') {
		return "http://localhost:8866" + url;
	}
	return url;
};

async function post<T>(url: string, data: any = {}) {
	const response = await fetch(addr(url), {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json',
		},
		body: JSON.stringify(data)
	});
	const json: T = await response.json();
	return json;
};

function postSync<T>(url: string, data: any): T | null {
	let xhr = new XMLHttpRequest();
	xhr.open('POST', addr(url), false);
	xhr.setRequestHeader('Content-Type', 'application/json');
	xhr.send(JSON.stringify(data));
	if (xhr.status === 200) {
		try {
			let json = JSON.parse(xhr.responseText);
			return json;
		} catch (error) {
			console.error(error);
			return null;
		}
	} else {
		throw new Error('请求失败: ' + xhr.status);
	}
}

// Infer

export interface InferRequest {
	lang: "tl" | "lua" | "yue";
	file: string;
	line: string;
	row: number;
	content: string;
}
export interface InferResponse {
	success: boolean;
	infered?: {
		desc: string,
		doc?: string,
		file: string,
		row: number,
		col: number,
		key?: string,
	};
}
export const infer = (req: InferRequest) => {
	return post<InferResponse>("/infer", req);
};

// signature

export interface SignatureRequest {
	lang: "tl" | "lua" | "yue";
	file: string;
	line: string;
	row: number;
	content: string;
}
export interface SignatureResponse {
	success: boolean;
	signatures?: [{
		desc: string,
		params?: [{
			name: string,
			desc: string
		}]
		doc: string,
	}];
}
export const signature = (req: SignatureRequest) => {
	return post<SignatureResponse>("/signature", req);
};

// Complete

export interface CompleteRequest {
	lang: "tl" | "lua" | "yue" | "xml";
	file: string;
	line: string;
	row: number;
	content: string;
}
type CompleteItemType = "function" | "variable" | "field" | "method" | "keyword";
export interface CompleteResponse {
	success: boolean;
	suggestions?: [string, string, CompleteItemType][];
}
export const complete = (req: CompleteRequest) => {
	return post<CompleteResponse>("/complete", req);
};

// Check

export interface CheckRequest {
	file: string;
	content: string;
}
type CheckError = "parsing" | "syntax" | "type" | "warning" | "crash";
export interface CheckResponse {
	success: boolean;
	info?: [CheckError, string, number, number, string][];
}
export const check = (req: CheckRequest) => {
	return post<CheckResponse>("/check", req);
};

// Assets

export const assets = () => {
	return post<TreeDataType>('/assets');
};

// Info

export interface InfoResponse {
	platform: "Windows" | "macOS" | "iOS" | "Android" | "Linux";
	locale: string;
	version: string;
	engineDev: boolean;
	webProfiler: boolean;
	drawerWidth: number;
}
export const info = () => {
	return post<InfoResponse>("/info");
};

// Read

export interface ReadRequest {
	path: string;
}
export interface ReadResponse {
	success: boolean;
	content?: string;
}
export const read = (req: ReadRequest) => {
	return post<ReadResponse>("/read", req);
};

// ReadSync

export interface ReadSyncRequest {
	path: string;
	exts?: string[];
}
export type ReadSyncResponse =  {
	success: false;
} | {
	success: true;
	content: string;
	ext: string;
};
export const readSync = (req: ReadSyncRequest) => {
	const {path, exts = [""]} = req;
	return postSync<ReadSyncResponse>("/read-sync", {path, exts});
};

// Write

export interface WriteRequest {
	path: string;
	content: string;
}
export interface WriteResponse {
	success: boolean;
	resultCodes?: string;
}
export const write = (req: WriteRequest) => {
	return post<WriteResponse>("/write", req);
};

// Build

export interface BuildRequest {
	path: string;
}
export interface BuildResponse {
	success: boolean;
	resultCodes?: string;
}
export const build = (req: BuildRequest) => {
	return post<BuildResponse>("/build", req);
};

// Rename

export interface RenameRequest {
	old: string;
	new: string;
}
export interface RenameResponse {
	success: boolean;
}
export const rename = (req: RenameRequest) => {
	return post<RenameResponse>("/rename", req);
};

// Delete

export interface DeleteRequest {
	path: string;
}
export interface DeleteResponse {
	success: boolean;
}
export const deleteFile = (req: DeleteRequest) => {
	return post<DeleteResponse>("/delete", req);
};

// New

export interface NewRequest {
	path: string;
	content: string;
	folder: boolean;
}
export interface NewResponse {
	success: boolean;
}
export const newFile = (req: NewRequest) => {
	return post<NewResponse>("/new", req);
};

// List

export interface ListRequest {
	path: string;
}
export interface ListResponse {
	success: boolean;
	files?: string[];
}
export const list = (req: ListRequest) => {
	return post<ListResponse>("/list", req);
};

// Run

export interface RunRequest {
	file: string;
	asProj: boolean;
}
export interface RunResponse {
	success: boolean;
	target?: string;
	err?: string;
}
export const run = (req: RunRequest) => {
	return post<RunResponse>("/run", req);
};

// Stop

export interface StopResponse {
	success: boolean;
}
export const stop = () => {
	return post<StopResponse>("/stop");
};

// Zip

export interface ZipRequest {
	path: string;
	zipFile: string;
}
export interface ZipResponse {
	success: boolean;
}
export const zip = (req: ZipRequest) => {
	return post<ZipResponse>("/zip", req);
};

// Unzip

export interface UnzipRequest {
	zipFile: string;
	path: string;
}
export interface UnzipResponse {
	success: boolean;
}
export const unzip = (req: UnzipRequest) => {
	return post<UnzipResponse>("/unzip", req);
};

// EditingInfo

export interface EditingInfo {
	index: number;
	files: {
		key: string,
		title: string,
		folder: boolean,
		mdEditing?: boolean,
		position?: {
			lineNumber: number,
			column: number
		}
		readOnly?: boolean,
	}[];
};
export interface EditingInfoRequest {
	editingInfo: string;
};
export interface EditingInfoResponse {
	success: boolean;
	editingInfo?: string;
};
export const editingInfo = (req?: EditingInfoRequest) => {
	return post<EditingInfoResponse>("/editingInfo", req ?? {});
};

// Command

export interface CommandRequest {
	code: string;
	log: boolean;
};
export interface CommandResponse {
	success: boolean;
};
export const command = (req: CommandRequest) => {
	return post<CommandResponse>("/command", req);
};

// exist

export interface FileExistRequest {
	file: string;
};
export interface FileExistResponse {
	success: boolean;
};
export const exist = (req: FileExistRequest) => {
	return post<FileExistResponse>("/exist", req);
};
export const existSync = (req: FileExistRequest) => {
	return postSync<FileExistResponse>("/exist", req);
};
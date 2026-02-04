/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import type { TreeDataType } from "./FileTree";
import { ProfilerInfo } from "./ProfilerInfo";
import { TypedEmitter } from "./utils/typedEmitter";

let webSocket: WebSocket;
export const getWebSocket = () => webSocket ? webSocket : null;

type ServiceEvents = {
	[WsEvent.Log]: [string, string];
	[WsEvent.Profiler]: [ProfilerInfo];
	[WsEvent.UpdateTSCode]: [string, string];
	[WsEvent.Download]: [string, WsDownloadStatus, number];
	[WsOpenEvent]: [];
	[WsCloseEvent]: [];
	SearchFilesResult: [SearchFilesResultMessage];
	SearchFilesDone: [SearchFilesDoneMessage];
};

const eventEmitter = new TypedEmitter<ServiceEvents>();

function wsUrl() {
	let url: string;
	if (!process.env.NODE_ENV || process.env.NODE_ENV === 'development') {
		url = "ws://localhost:8868";
	} else {
		url = `ws://${window.location.hostname}:8868`;
	}
	return url;
}

type AuthSession = {
	sessionId: string;
	sessionSecret: string;
};

const parseSession = (raw: string | null): AuthSession | null => {
	if (!raw) return null;
	try {
		const parsed = JSON.parse(raw) as AuthSession;
		if (parsed && parsed.sessionId && parsed.sessionSecret) {
			return parsed;
		}
	} catch (err) {
		void err;
	}
	return null;
};

const canonicalizePath = (url: URL) => {
	if (!url.searchParams || Array.from(url.searchParams).length === 0) {
		return url.pathname;
	}
	const params = Array.from(url.searchParams.entries());
	params.sort(([keyA, valueA], [keyB, valueB]) => {
		const keySort = keyA.localeCompare(keyB);
		if (keySort !== 0) return keySort;
		return valueA.localeCompare(valueB);
	});
	const query = params
		.map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
		.join('&');
	return query ? `${url.pathname}?${query}` : url.pathname;
};

const hmacHex = async (secret: string, payload: string) => {
	const encoder = new TextEncoder();
	const key = await crypto.subtle.importKey(
		'raw',
		encoder.encode(secret),
		{name: 'HMAC', hash: 'SHA-256'},
		false,
		['sign'],
	);
	const signature = await crypto.subtle.sign('HMAC', key, encoder.encode(payload));
	return Array.from(new Uint8Array(signature))
		.map((byte) => byte.toString(16).padStart(2, '0'))
		.join('');
};

const buildWebSocketUrl = async (baseUrl: string, session: AuthSession) => {
	const url = new URL(baseUrl, window.location.href);
	const timestamp = Math.floor(Date.now() / 1000).toString();
	const nonce = crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(16).slice(2);
	const params = new URLSearchParams(url.searchParams);
	params.set('session', session.sessionId);
	params.set('ts', timestamp);
	params.set('nonce', nonce);
	const path = canonicalizePath(new URL(`${url.origin}${url.pathname}?${params.toString()}`));
	const payload = [session.sessionId, 'GET', path, timestamp, nonce, ''].join('\n');
	const signature = await hmacHex(session.sessionSecret, payload);
	params.set('sig', signature);
	url.search = params.toString();
	return url.toString();
};

const WsOpenEvent = "Open";
const WsCloseEvent = "Close";

const enum WsEvent {
	Log = "Log",
	Profiler = "Profiler",
	TranspileTS = "TranspileTS",
	UpdateTSCode = "UpdateTSCode",
	Download = "Download",
}

let logText = "";

export const addLog = (text: string) => {
	logText += text;
	eventEmitter.emit(WsEvent.Log, text, logText);
};

export const clearLog = () => {
	logText = "";
	eventEmitter.emit(WsEvent.Log, "", logText);
};

export const getLog = () => {
	return logText;
};

export const addLogListener = (listener: (newItem: string, allText: string) => void) => {
	eventEmitter.on(WsEvent.Log, listener);
};

export const removeLogListener = (listener: (newItem: string, allText: string) => void) => {
	eventEmitter.off(WsEvent.Log, listener);
};

export const addProfilerListener = (listener: (info: ProfilerInfo) => void) => {
	eventEmitter.on(WsEvent.Profiler, listener);
};

export const removeProfilerListener = (listener: (info: ProfilerInfo) => void) => {
	eventEmitter.off(WsEvent.Profiler, listener);
};

export const addUpdateTSCodeListener = (listener: (file: string, code: string) => void) => {
	eventEmitter.on(WsEvent.UpdateTSCode, listener);
};

type WsDownloadStatus = "downloading" | "completed" | "failed";

export const addDownloadListener = (listener: (url: string, status: WsDownloadStatus, progress: number) => void) => {
	eventEmitter.on(WsEvent.Download, listener);
};

export const removeDownloadListener = (listener: (url: string, status: WsDownloadStatus, progress: number) => void) => {
	eventEmitter.off(WsEvent.Download, listener);
};

export const addWSOpenListener = (listener: () => void) => {
	eventEmitter.on(WsOpenEvent, listener);
};

export const addWSCloseListener = (listener: () => void) => {
	eventEmitter.on(WsCloseEvent, listener);
};

type WebSocketPayload = Record<string, unknown>;

const sendWebSocketMessage = (payload: WebSocketPayload) => {
	if (!webSocket || webSocket.readyState === WebSocket.CLOSED || webSocket.readyState === WebSocket.CLOSING) {
		return false;
	}
	webSocket.send(new Blob([JSON.stringify(payload)]));
	return true;
};

export function openWebSocket() {
	let connected = false;
	const connect = () => {
		connected = false;
		const storageKey = 'doraWebAuthSession';
		const session = parseSession(localStorage.getItem(storageKey));
		if (!session) {
			setTimeout(connect, 1000);
			return;
		}
		void (async () => {
			try {
				const signedUrl = await buildWebSocketUrl(wsUrl(), session);
				webSocket = new WebSocket(signedUrl);
				webSocket.onmessage = async function(evt: MessageEvent) {
					let dataStr: string;
					if (evt.data instanceof ArrayBuffer) {
						const decoder = new TextDecoder("utf-8");
						dataStr = decoder.decode(evt.data);
					} else if (typeof evt.data === "string") {
						dataStr = evt.data;
					} else if (evt.data instanceof Blob) {
						dataStr = await evt.data.text();
					} else {
						return;
					}
					let result: any;
					try {
						result = JSON.parse(dataStr);
					} catch (e) {
						console.error("Failed to parse WebSocket message:", e, dataStr);
						return;
					}
					if (result && typeof result === "object" && "name" in result) {
						switch (result.name) {
							case WsEvent.Log: {
								logText += result.text as string;
								eventEmitter.emit(result.name, result.text, logText);
								break;
							}
							case WsEvent.Profiler: {
								eventEmitter.emit(result.name, result.info);
								break;
							}
							case WsEvent.UpdateTSCode: {
								eventEmitter.emit(result.name, result.file, result.content);
								break;
							}
							case WsEvent.Download: {
								eventEmitter.emit(result.name, result.url, result.status, result.progress);
								break;
							}
							case WsEvent.TranspileTS: {
								const {transpileTypescript, getDiagnosticMessage} = await import('./TranspileTS');
								const {file, content} = result;
								if (typeof file === 'string' && typeof content === 'string') {
									const {success, luaCode, diagnostics} = await transpileTypescript(file, content);
									let data = "";
									if (success) {
										data = JSON.stringify({name: WsEvent.TranspileTS, success, luaCode, message: ""});
									} else {
										const message = await getDiagnosticMessage(file, diagnostics);
										data = JSON.stringify({name: WsEvent.TranspileTS, success, luaCode: "", message});
									}
									webSocket.send(new Blob([data]));
								}
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
					eventEmitter.emit(WsOpenEvent);
				};
				webSocket.onclose = () => {
					if (connected) {
						connected = false;
						eventEmitter.emit(WsCloseEvent);
					}
					setTimeout(connect, 1000);
				};
				webSocket.onerror = () => {
					webSocket.close();
				};
			} catch (err) {
				void err;
				setTimeout(connect, 1000);
			}
		})();
	};
	connect();
};

// Search Files

export interface SearchFilesRequest {
	id: number;
	path: string;
	exts: string[];
	extensionLevels?: Record<string, number>;
	excludes?: string[];
	pattern: string;
	useRegex: boolean;
	caseSensitive: boolean;
	includeContent: boolean;
	contentWindow: number;
}

export interface SearchFilesResult {
	file: string;
	pos: number;
	line: number;
	column: number;
	content: string;
}

export interface SearchFilesResultMessage {
	name: "SearchFilesResult";
	id: number;
	result: SearchFilesResult;
}

export interface SearchFilesDoneMessage {
	name: "SearchFilesDone";
	id: number;
	stopped?: boolean;
}

export const searchFiles = (req: SearchFilesRequest) => {
	return sendWebSocketMessage({name: "SearchFiles", ...req});
};

export const stopSearchFiles = (id: number) => {
	return sendWebSocketMessage({name: "SearchFilesStop", id});
};

export const addSearchFilesResultListener = (listener: (message: SearchFilesResultMessage) => void) => {
	eventEmitter.on("SearchFilesResult", listener);
};

export const removeSearchFilesResultListener = (listener: (message: SearchFilesResultMessage) => void) => {
	eventEmitter.off("SearchFilesResult", listener);
};

export const addSearchFilesDoneListener = (listener: (message: SearchFilesDoneMessage) => void) => {
	eventEmitter.on("SearchFilesDone", listener);
};

export const removeSearchFilesDoneListener = (listener: (message: SearchFilesDoneMessage) => void) => {
	eventEmitter.off("SearchFilesDone", listener);
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
	const xhr = new XMLHttpRequest();
	xhr.open('POST', addr(url), false);
	xhr.setRequestHeader('Content-Type', 'application/json');
	xhr.send(JSON.stringify(data));
	if (xhr.status === 200) {
		try {
			const json = JSON.parse(xhr.responseText);
			return json;
		} catch (error) {
			console.error(error);
			return null;
		}
	} else {
		throw new Error('failed to post: ' + xhr.status);
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
};
type CheckError = "parsing" | "syntax" | "type" | "warning" | "crash";
export interface CheckResponse {
	success: boolean;
	info?: [CheckError, string, number, number, string][];
};
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
};
export const info = () => {
	return post<InfoResponse>("/info");
};

// LLM Config

export interface LLMConfigItem {
	id: number;
	name: string;
	url: string;
	model: string;
	key: string;
}

export interface LLMConfigListResponse {
	success: boolean;
	items?: LLMConfigItem[];
	message?: string;
}

export interface LLMConfigWriteResponse {
	success: boolean;
	message?: string;
}

export const listLLMConfigs = () => {
	return post<LLMConfigListResponse>("/llm/list");
};

export const createLLMConfig = (item: Omit<LLMConfigItem, "id">) => {
	return post<LLMConfigWriteResponse>("/llm/create", item);
};

export const updateLLMConfig = (item: LLMConfigItem) => {
	return post<LLMConfigWriteResponse>("/llm/update", item);
};

export const deleteLLMConfig = (id: number) => {
	return post<LLMConfigWriteResponse>("/llm/delete", {id});
};

// Read

export interface ReadRequest {
	path: string;
	projFile?: string;
};
export type ReadResponse  = {
	success: true;
	content: string;
} | {
	success: false;
};
export const read = (req: ReadRequest) => {
	return post<ReadResponse>("/read", req);
};

// ReadSync

export interface ReadSyncRequest {
	path: string;
	exts?: string[];
	projFile?: string;
};
export type ReadSyncResponse =  {
	success: false;
} | {
	success: true;
	content: string;
	fullPath: string;
};
export const readSync = (req: ReadSyncRequest) => {
	const {path, exts = [""], projFile} = req;
	return postSync<ReadSyncResponse>("/read-sync", {path, exts, projFile});
};

// Write

export interface WriteRequest {
	path: string;
	content: string;
};
export interface WriteResponse {
	success: boolean;
	resultCodes?: string;
};
export const write = (req: WriteRequest) => {
	return post<WriteResponse>("/write", req);
};

// Build

export interface BuildRequest {
	path: string;
};
export type BuildResponse = {
	success: true;
	resultCodes: string;
} | {
	success: false;
};
export const build = (req: BuildRequest) => {
	return post<BuildResponse>("/build", req);
};

// Rename

export interface RenameRequest {
	old: string;
	new: string;
};
export interface RenameResponse {
	success: boolean;
};
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
	message: 'Failed' | 'TargetExisted' | 'SourceExisted';
}
export const newFile = (req: NewRequest) => {
	return post<NewResponse>("/new", req);
};

// List

export interface ListRequest {
	path: string;
}
export type ListResponse = {
	success: true;
	files: string[];
} | {
	success: false;
};
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
	obfuscated: boolean;
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
		yarnTextEditing?: boolean,
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
	return post<EditingInfoResponse>("/editing-info", req ?? {});
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
	projFile?: string;
};
export interface FileExistResponse {
	success: boolean;
};
export const exist = (req: FileExistRequest) => {
	return post<FileExistResponse>("/exist", req);
};

// saveLog

export type SaveLogResponse = {
	success: true;
	path: string;
} | {
	success: false;
};
export const saveLog = () => {
	return post<SaveLogResponse>("/log/save", {});
};

// checkYarn

export interface CheckYarnRequest {
	code: string;
}
export type CheckYarnResponse = {
	success: true;
	syntaxError: string;
} | {
	success: false;
};
export const checkYarn = (req: CheckYarnRequest) => {
	return post<CheckYarnResponse>("/yarn/check", req);
};


// checkYarnFile

export interface CheckYarnFileRequest {
	code: string;
}
export type CheckYarnFileResponse = {
	success: false;
	message: string;
	line: number;
	column: number;
	node: string;
} | {
	success: true;
};
export const checkYarnFile = (req: CheckYarnFileRequest) => {
	return post<CheckYarnFileResponse>("/yarn/check-file", req);
};

// buildWa

export interface BuildWaRequest {
	path: string;
}
export type BuildWaResponse = {
	success: true;
} | {
	success: false;
	message: string;
};
export const buildWa = (req: BuildWaRequest) => {
	return post<BuildWaResponse>("/wa/build", req);
};

// formatWa

export interface FormatWaRequest {
	file: string;
}
export type FormatWaResponse = {
	success: true;
	code: string;
} | {
	success: false;
};
export const formatWa = (req: FormatWaRequest) => {
	return post<FormatWaResponse>("/wa/format", req);
};


// createWa

export interface CreateWaRequest {
	path: string;
}
export type CreateWaResponse = {
	success: true;
} | {
	success: false;
	message: string;
};
export const createWa = (req: CreateWaRequest) => {
	return post<CreateWaResponse>("/wa/create", req);
};

// download

export interface DownloadRequest {
	url: string;
	target: string;
}
export type DownloadResponse = {
	success: boolean;
};
export const download = (req: DownloadRequest) => {
	return post<DownloadResponse>("/download", req);
};

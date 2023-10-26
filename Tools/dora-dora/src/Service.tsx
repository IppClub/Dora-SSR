import { TreeDataType } from "./FileTree";

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

// Write

export interface WriteRequest {
	path: string;
	content: string;
}
export interface WriteResponse {
	success: boolean;
}
export const write = (req: WriteRequest) => {
	return post<WriteResponse>("/write", req);
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

// EditingInfo

export interface EditingInfo {
	index: number;
	files: {
		key: string,
		title: string,
		mdEditing?: boolean,
		position?: {
			lineNumber: number,
			column: number
		}
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

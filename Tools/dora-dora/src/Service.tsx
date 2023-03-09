import { TreeDataType } from "./FileTree";
import Post from "./Post";

// Infer

export interface InferRequest {
	lang: "tl" | "lua";
	line: string;
	row: number;
	content: string;
}
export interface InferResponse {
	success: boolean;
	infered?: {
		desc: string,
		file: string,
		row: number,
		col: number,
		key?: string,
	};
}
export const infer = (req: InferRequest) => {
	return Post("/infer", req)
		.then((res: InferResponse) => res);
};

// Complete

export interface CompleteRequest {
	lang: "tl" | "lua";
	line: string;
	row: number;
	content: string;
}
export interface CompleteResponse {
	success: boolean;
	suggestions?: [string, string, boolean][];
}
export const complete = (req: CompleteRequest) => {
	return Post("/complete", req)
		.then((res: CompleteResponse) => res);
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
	return Post("/check", req)
		.then((res: CheckResponse) => res);
};

// Assets

export const assets = () => {
	return Post('/assets')
		.then((res: TreeDataType) => res);
};

// Info

export interface InfoResponse {
	platform: "Windows" | "macOS" | "iOS" | "Android" | "Linux";
}
export const info = () => {
	return Post("/info")
		.then((res: InfoResponse) => res);
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
	return Post("/read", req)
		.then((res: ReadResponse) => res);
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
	return Post("/write", req)
		.then((res: WriteResponse) => res);
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
	return Post("/rename", req)
		.then((res: RenameResponse) => res);
};

// Delete

export interface DeleteRequest {
	path: string;
}
export interface DeleteResponse {
	success: boolean;
}
export const deleteFile = (req: DeleteRequest) => {
	return Post("/delete", req)
		.then((res: DeleteResponse) => res);
};

// New

export interface NewRequest {
	path: string;
}
export interface NewResponse {
	success: boolean;
}
export const newFile = (req: NewRequest) => {
	return Post("/new", req)
		.then((res: NewResponse) => res);
};

// List

export interface ListRequest {
	path: string;
}
export interface ListResponse {
	success: boolean;
	files: string[];
}
export const list = (req: ListRequest) => {
	return Post("/list", req)
		.then((res: ListResponse) => res);
};

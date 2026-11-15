// @preview-file off clear
import { Content, Path } from 'Dora';
import { inspectReadableFile, isAgentContentVirtualPath, resolveAgentContentVirtualPath, type DoraDocLanguage } from 'Agent/Tool/Workspace';

type NativeMethod = (this: void, self: unknown, ...args: unknown[]) => LuaMultiReturn<unknown[]>;

/** Native Content operations with project-root defaults and command-local configuration. */
export function createCommandContent(workDir: string, docLanguage?: DoraDocLanguage): object {
	let assetPath = workDir;
	let writablePath = workDir;
	let searchPaths: string[] = [];
	const normalizePath = (value: unknown): string => {
		if (typeof value !== "string") error("Content path must be a string");
		const path = (value as string) === "" ? "." : (value as string);
		if (path.indexOf("\0") >= 0) error("Content path must not contain NUL");
		return path.split("\\").join("/");
	};
	const directory = (value: unknown): string => {
		const path = normalizePath(value);
		if (isAgentContentVirtualPath(path)) error("Content virtual paths are read-only files, not search/root directories");
		const fullPath = Content.isAbsolutePath(path) ? path : Path(workDir, path);
		if (!Content.isdir(fullPath)) error("Content search/root path must be an existing directory");
		return fullPath;
	};
	const resolve = (value: unknown, write: boolean): string => {
		const path = normalizePath(value);
		if (isAgentContentVirtualPath(path)) {
			if (write) error("Content virtual paths are read-only");
			const target = resolveAgentContentVirtualPath(workDir, path, docLanguage);
			if (!target) error("Content virtual file not found or outside its namespace");
			return target as string;
		}
		if (Content.isAbsolutePath(path)) return path;
		if (!write) {
			for (const base of searchPaths) {
				const candidate = Path(base, path);
				if (Content.exist(candidate)) return candidate;
			}
		}
		return Path(write ? writablePath : assetPath, path);
	};
	const methods: Record<string, unknown> = {};
	let facade: object;
	const argumentsOf = (values: unknown[]): unknown[] => values[0] === facade ? values.slice(1) : values;
	const delegate = (name: string, paths: boolean[], inspect = false) => {
		methods[name] = (...values: unknown[]): LuaMultiReturn<unknown[]> => {
			const args = argumentsOf(values);
			const virtualPath = typeof args[0] === "string" && isAgentContentVirtualPath(args[0]) ? args[0] as string : undefined;
			for (let i = 0; i < paths.length; i++) args[i] = resolve(args[i], paths[i]);
			if (virtualPath && name === "getFullPath") return $multi(virtualPath);
			if (virtualPath && ["getDirs", "getFiles", "getAllFiles", "glob", "zipAsync"].indexOf(name) >= 0) error("Content virtual paths identify individual read-only files");
			if (virtualPath && name === "searchFilesAsync") {
				args[3] = [Path.getFilename(args[0] as string)];
				args[0] = Path.getPath(args[0] as string);
				const callback = args[9] as ((this: void, row: Record<string, unknown>) => boolean) | undefined;
				if (callback) args[9] = (row: Record<string, unknown>) => { row.file = virtualPath; return callback(row); };
			}
			if (inspect) {
				const result = inspectReadableFile(args[0] as string);
				if (!result.success) error(result.message ?? "file is not readable");
			}
			const fn = (Content as unknown as Record<string, NativeMethod>)[name];
			if (virtualPath && name === "searchFilesAsync") {
				const [rows] = fn(Content, ...args);
				for (const row of rows as Record<string, unknown>[]) row.file = virtualPath;
				return $multi(rows);
			}
			return fn(Content, ...args);
		};
	};
	for (const name of ["exist", "isdir", "getAttr", "getDirs", "getFiles", "getAllFiles", "getFullPath", "glob", "searchFilesAsync", "loadExcel", "loadExcelAsync"]) delegate(name, [false]);
	for (const name of ["load", "loadAsync"]) delegate(name, [false], true);
	for (const name of ["save", "saveAsync", "mkdir", "remove"]) delegate(name, [true]);
	for (const name of ["copy", "copyAsync", "zipAsync", "unzipAsync"]) delegate(name, [false, true]);
	// A move mutates its source as well as its destination.
	delegate("move", [true, true]);
	methods.isAbsolutePath = (...values: unknown[]) => {
		const [path] = argumentsOf(values);
		if (typeof path !== "string") error("Content.isAbsolutePath expects a string");
		return Content.isAbsolutePath(path as string);
	};
	methods.addSearchPath = (...values: unknown[]) => {
		const [path] = argumentsOf(values);
		searchPaths.push(directory(path));
	};
	methods.insertSearchPath = (...values: unknown[]) => {
		const [index, path] = argumentsOf(values);
		if (typeof index !== "number" || index !== math.floor(index) || index < 1 || index > searchPaths.length + 1) error("Content.insertSearchPath index is out of range");
		searchPaths.splice((index as number) - 1, 0, directory(path));
	};
	methods.removeSearchPath = (...values: unknown[]) => {
		const [value] = argumentsOf(values);
		const path = normalizePath(value);
		if (isAgentContentVirtualPath(path)) error("Content virtual paths are read-only files, not search directories");
		const fullPath = Content.isAbsolutePath(path) ? path : Path(workDir, path);
		searchPaths = searchPaths.filter(item => item !== fullPath);
	};
	// Full paths are resolved afresh by the facade; never alter the engine cache.
	methods.clearPathCache = () => {};
	facade = setmetatable({}, {
		__index: (_self: unknown, key: string): unknown => {
			if (key === "assetPath") return assetPath;
			if (key === "writablePath") return writablePath;
			if (key === "appPath") return Content.appPath;
			if (key === "searchPaths") return searchPaths.slice();
			return methods[key];
		},
		__newindex: function(this: void, _self: unknown, key: string, value: unknown) {
			if (key === "assetPath") assetPath = directory(value);
			else if (key === "writablePath") writablePath = directory(value);
			else if (key === "searchPaths") {
				if (!Array.isArray(value)) error("Content.searchPaths expects an array of directories");
				searchPaths = (value as unknown[]).map(item => directory(item));
			} else error(`Content.${key} is read-only`);
		},
		__metatable: "Agent project Content",
	});
	return facade;
}

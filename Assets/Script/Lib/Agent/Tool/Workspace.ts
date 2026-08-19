// @preview-file off clear
import { Content, Path, App, Director, once } from 'Dora';
import type { SearchFilesResult } from 'Dora';
import * as AgentConfig from 'Agent/AgentConfig';
import { Log } from 'Agent/Utils';

export type ListFilesResult = {
	success: true;
	files: string[];
	totalEntries?: number;
	truncated?: boolean;
	maxEntries?: number;
} | {
	success: false;
	message: string;
};

export type GetLogsResult = {
	success: true;
	logs: string[];
	text?: string;
} | {
	success: false;
	message: string;
};

export type ReadFileResult = {
	success: true;
	content: string;
	totalLines?: number;
	startLine?: number;
	endLine?: number;
	truncated?: boolean;
	size?: number;
} | {
	success: false;
	message: string;
	size?: number;
	isBinary?: boolean;
};

export type WorkspaceTextTargetResult = {
	success: true;
	exists: boolean;
	content: string;
} | {
	success: false;
	message: string;
};

export type SearchFilesToolResult = {
	success: true;
	results: SearchFilesResult[];
	groupedResults?: {
		file: string;
		totalMatches: number;
		matches: SearchFilesResult[];
	}[];
	totalResults?: number;
	truncated?: boolean;
	limit?: number;
	offset?: number;
	nextOffset?: number;
	hasMore?: boolean;
	groupByFile?: boolean;
} | {
	success: false;
	message: string;
};

export type DoraDocLanguage = "zh" | "en";
export type DoraDocSearchType = "dora-tutorial" | "dora-api" | "love-api" | "tic80-api";
export type DoraDocProgrammingLanguage = "ts" | "tsx" | "lua" | "yue" | "teal" | "tl" | "wa";

export interface DoraDocSearchHit {
	file: string;
	line?: number;
	content?: string;
}

export type DoraDocSearchResult = {
	success: true;
	docType: DoraDocSearchType;
	docLanguage: DoraDocLanguage;
	programmingLanguage: DoraDocProgrammingLanguage;
	exts: string[];
	results: DoraDocSearchHit[];
	hint?: string;
	totalResults?: number;
	truncated?: boolean;
	limit?: number;
	fallbackPatterns?: string[];
} | {
	success: false;
	message: string;
};

export type DoraDocReadResult = {
	success: true;
	docLanguage: DoraDocLanguage;
	file: string;
	content: string;
	startLine?: number;
	endLine?: number;
} | {
	success: false;
	message: string;
};

function getDoraDocDefinitionRoot(docLanguage: DoraDocLanguage): string {
	const zhDir = Path(Content.assetPath, "Script", "Lib", "Dora", "zh-Hans");
	const enDir = Path(Content.assetPath, "Script", "Lib", "Dora", "en");
	return docLanguage === "zh" ? zhDir : enDir;
}

function getDoraTutorialDocRoot(docLanguage: DoraDocLanguage): string {
	const zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial");
	const enDir = Path(Content.assetPath, "Doc", "en", "Tutorial");
	return docLanguage === "zh" ? zhDir : enDir;
}

function getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage: DoraDocProgrammingLanguage): string[] {
	if (programmingLanguage === "ts" || programmingLanguage === "tsx") {
		return ["ts"];
	}
	return ["tl"];
}

function getTutorialProgrammingLanguageDir(programmingLanguage: DoraDocProgrammingLanguage): string {
	switch (programmingLanguage) {
		case "teal": return "tl";
		case "tl": return "tl";
		default: return programmingLanguage;
	}
}

export function getDoraDocSearchTarget(
	docType: DoraDocSearchType,
	docLanguage: DoraDocLanguage,
	programmingLanguage: DoraDocProgrammingLanguage
): { root: string; exts: string[]; globs: string[] } {
	if (docType === "dora-tutorial") {
		const tutorialRoot = getDoraTutorialDocRoot(docLanguage);
		const langDir = getTutorialProgrammingLanguageDir(programmingLanguage);
		return {
			root: Path(tutorialRoot, langDir),
			exts: ["md"],
			globs: ["**/*.md"],
		};
	}
	const exts = getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage);
	if (docType === "love-api" || docType === "tic80-api") {
		const name = docType === "love-api" ? "love" : "tic80";
		return {
			root: getDoraDocDefinitionRoot(docLanguage),
			exts,
			globs: exts.map(ext => `${name}.d.${ext}`),
		};
	}
	return {
		root: getDoraDocDefinitionRoot(docLanguage),
		exts,
		globs: exts.flatMap(ext => [
			`**/*.${ext}`,
			`!**/love.d.${ext}`,
			`!**/tic80.d.${ext}`,
		]),
	};
}

export function getDoraDocResultBaseRoot(docType: DoraDocSearchType, docLanguage: DoraDocLanguage): string {
	if (docType === "dora-tutorial") {
		return getDoraTutorialDocRoot(docLanguage);
	}
	return getDoraDocDefinitionRoot(docLanguage);
}

export function isDoraDocFileInScope(docType: DoraDocSearchType, file: string): boolean {
	const normalized = file.split("\\").join("/").toLowerCase();
	const segments = normalized.split("/");
	const baseName = segments[segments.length - 1] ?? normalized;
	if (docType === "dora-tutorial") return normalized.endsWith(".md");
	if (docType === "love-api") return normalized === "love.d.ts" || normalized === "love.d.tl";
	if (docType === "tic80-api") return normalized === "tic80.d.ts" || normalized === "tic80.d.tl";
	return (normalized.endsWith(".ts") || normalized.endsWith(".tl"))
		&& baseName !== "love.d.ts"
		&& baseName !== "love.d.tl"
		&& baseName !== "tic80.d.ts"
		&& baseName !== "tic80.d.tl";
}

export const AGENT_DORA_DOC_PREFIX = "@dora-doc/";

export const ENGINE_LOG_DOWNLOAD_DIR = ".download";
const ENGINE_LOG_FILE = "dora_full_logs.txt";
const ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs.txt";

function isAbsolutePathLike(path: string): boolean {
	if (Content.isAbsolutePath(path)) return true;
	if (path.startsWith("/") || path.startsWith("\\")) return true;
	const [drivePath] = string.match(path, "^%a:[/\\]");
	return drivePath !== undefined;
}

export function isValidWorkspacePath(path: string): boolean {
	if (!path || path.length === 0) return false;
	if (isAbsolutePathLike(path)) return false;
	const parts = path.split("\\").join("/").split("/");
	if (parts.indexOf("..") >= 0) return false;
	return true;
}

export function isValidWorkDir(workDir: string): boolean {
	if (!workDir || workDir.length === 0) return false;
	if (!Content.isAbsolutePath(workDir)) return false;
	if (!Content.exist(workDir) || !Content.isdir(workDir)) return false;
	return true;
}

function isValidSearchPath(path: string): boolean {
	if (path === "") return true;
	if (isAbsolutePathLike(path)) return false;
	if (!path || path.length === 0) return false;
	const parts = path.split("\\").join("/").split("/");
	if (parts.indexOf("..") >= 0) return false;
	return true;
}

export function resolveWorkspaceFilePath(workDir: string, path: string): string | undefined {
	if (!isValidWorkDir(workDir)) return undefined;
	if (!isValidWorkspacePath(path)) return undefined;
	return Path(workDir, path);
}

export function resolveWorkspaceSearchPath(workDir: string, path: string): string | undefined {
	if (!isValidWorkDir(workDir)) return undefined;
	if (!isValidSearchPath(path)) return undefined;
	return path === "" ? workDir : Path(workDir, path);
}

export function toWorkspaceRelativePath(workDir: string, path: string): string {
	if (!path || path.length === 0) return path;
	if (!Content.isAbsolutePath(path)) return path;
	return Path.getRelative(path, workDir);
}

function toWorkspaceRelativeFileList(workDir: string, files: string[]): string[] {
	return files.map(file => toWorkspaceRelativePath(workDir, file));
}

function toWorkspaceRelativeSearchResults(workDir: string, results: SearchFilesResult[]): SearchFilesResult[] {
	const mapped: SearchFilesResult[] = [];
	for (let i = 0; i < results.length; i++) {
		const row = results[i];
		const clone: SearchFilesResult = { ...row };
		clone.file = toWorkspaceRelativePath(workDir, clone.file);
		mapped.push(clone);
	}
	return mapped;
}

export function resolveWorkspaceDirectoryPath(workDir: string, path?: string): { success: true; path: string; relative: string } | { success: false; message: string } {
	const relative = (path ?? "").trim();
	if (relative === "") {
		return { success: true, path: workDir, relative: "." };
	}
	if (!isValidWorkDir(workDir) || !isValidWorkspacePath(relative)) {
		return { success: false, message: "invalid cwd path" };
	}
	const resolved = Path(workDir, relative);
	if (!Content.exist(resolved)) {
		return { success: false, message: "cwd does not exist" };
	}
	if (!Content.isdir(resolved)) {
		return { success: false, message: "cwd is not a directory" };
	}
	return { success: true, path: resolved, relative };
}

const AGENT_SKILL_PREFIX = "@agent-skill/";

export function toDocRelativePath(baseRoot: string, path: string, docType: DoraDocSearchType): string {
	if (!path || path.length === 0) return path;
	const relative = Content.isAbsolutePath(path) ? Path.getRelative(path, baseRoot) : path;
	return `${AGENT_DORA_DOC_PREFIX}${docType}/${relative}`;
}

function resolveAgentDoraDocFilePath(path: string, docLanguage?: DoraDocLanguage): string | undefined {
	if (!docLanguage) return undefined;
	let relative = path;
	let docType: DoraDocSearchType = "dora-tutorial";
	if (path.startsWith(AGENT_DORA_DOC_PREFIX)) {
		const namespaced = path.slice(AGENT_DORA_DOC_PREFIX.length);
		if (namespaced.startsWith("dora-api/")) {
			docType = "dora-api";
			relative = namespaced.slice(9);
		} else if (namespaced.startsWith("love-api/")) {
			docType = "love-api";
			relative = namespaced.slice(9);
		} else if (namespaced.startsWith("tic80-api/")) {
			docType = "tic80-api";
			relative = namespaced.slice(10);
		} else if (namespaced.startsWith("dora-tutorial/")) {
			docType = "dora-tutorial";
			relative = namespaced.slice(14);
		} else if (namespaced.startsWith("api/")) {
			docType = "dora-api";
			relative = namespaced.slice(4);
		} else if (namespaced.startsWith("tutorial/")) {
			docType = "dora-tutorial";
			relative = namespaced.slice(9);
		} else {
			return undefined;
		}
	}
	if (!isValidWorkspacePath(relative)) return undefined;
	if (!isDoraDocFileInScope(docType, relative)) return undefined;
	const root = getDoraDocResultBaseRoot(docType, docLanguage);
	const candidate = Path(root, relative);
	const checked = Path.getRelative(candidate, root);
	if (checked === ".." || checked.startsWith("../") || checked.startsWith("..\\")) return undefined;
	if (Content.exist(candidate) && !Content.isdir(candidate)) {
		return candidate;
	}
	return undefined;
}

function resolveAgentSkillFilePath(workDir: string, path: string): string | undefined {
	if (!path.startsWith(AGENT_SKILL_PREFIX)) return undefined;
	const namespaced = path.slice(AGENT_SKILL_PREFIX.length).split("\\").join("/");
	let root = "";
	let relative = "";
	if (namespaced.startsWith("builtin/")) {
		root = Path(Content.assetPath, "Doc", "skills");
		relative = namespaced.slice("builtin/".length);
	} else if (namespaced.startsWith("user/")) {
		root = Path(Content.writablePath, ".agent", "skills");
		relative = namespaced.slice("user/".length);
	} else if (namespaced.startsWith("project/")) {
		root = Path(workDir, ".agent", "skills");
		relative = namespaced.slice("project/".length);
	} else {
		return undefined;
	}
	if (!isValidWorkspacePath(relative) || relative === ".") return undefined;
	const candidate = Path(root, relative);
	const checked = Path.getRelative(candidate, root);
	if (checked === ".." || checked.startsWith("../") || checked.startsWith("..\\")) return undefined;
	if (!Content.exist(candidate) || Content.isdir(candidate)) return undefined;
	return candidate;
}

export function ensureDirPath(dir: string): boolean {
	if (!dir || dir === "." || dir === "") return true;
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent !== dir && parent !== "." && parent !== "") {
		if (!ensureDirPath(parent)) return false;
	}
	return Content.mkdir(dir);
}

export function ensureDirForFile(path: string): boolean {
	const dir = Path.getPath(path);
	return ensureDirPath(dir);
}

export function getFileState(path: string) {
	const exists = Content.exist(path);
	if (!exists) {
		return {
			exists: false,
			content: "",
			bytes: 0,
		};
	}
	if (Content.isdir(path)) {
		return {
			exists: true,
			content: "",
			bytes: 0,
			isDirectory: true,
		};
	}
	const content = Content.load(path);
	if (typeof content !== "string") {
		return {
			exists: true,
			content: "",
			bytes: 0,
		};
	}
	return {
		exists: true,
		content,
		bytes: content.length,
	};
}

export function inspectReadableFile(path: string): { success: true; size?: number } | { success: false; message: string; size?: number; isBinary?: boolean } {
	try {
		const [size, isBinary] = Content.getAttr(path);
		if (size === undefined) {
			return {
				success: false,
				message: "failed to read file"
			};
		}
		if (isBinary) {
			return {
				success: false,
				message: `file is binary and cannot be previewed by read_file${typeof size === "number" ? ` (${size} bytes)` : ""}`,
				size: typeof size === "number" ? size : undefined,
				isBinary: true,
			};
		}
		return {
			success: true,
			size: typeof size === "number" ? size : undefined,
		};
	} catch (e) {
		Log("Warn", `[Agent.Tools] Content.getAttr failed for ${path}: ${tostring(e)}`);
		return { success: true };
	}
}

function isEngineLogFilePath(path: string): boolean {
	return path === ENGINE_LOG_VIRTUAL_FILE;
}

function readEngineLogFile(path: string): ReadFileResult | undefined {
	if (!isEngineLogFilePath(path)) return undefined;
	const content = getEngineLogText();
	if (content === undefined) {
		return { success: false, message: "failed to read engine logs" };
	}
	return { success: true, content, size: content.length };
}

function readWorkspaceFile(workDir: string, path: string, docLanguage?: DoraDocLanguage): ReadFileResult {
	const engineLog = readEngineLogFile(path);
	if (engineLog) return engineLog;
	const fullPath = resolveWorkspaceFilePath(workDir, path);
	if (fullPath && Content.exist(fullPath) && !Content.isdir(fullPath)) {
		const attr = inspectReadableFile(fullPath);
		if (!attr.success) return attr;
		return { success: true, content: Content.load(fullPath), size: attr.size };
	}
	const docPath = resolveAgentDoraDocFilePath(path, docLanguage);
	if (docPath) {
		const attr = inspectReadableFile(docPath);
		if (!attr.success) return attr;
		return { success: true, content: Content.load(docPath), size: attr.size };
	}
	const skillPath = resolveAgentSkillFilePath(workDir, path);
	if (skillPath) {
		const attr = inspectReadableFile(skillPath);
		if (!attr.success) return attr;
		return { success: true, content: Content.load(skillPath), size: attr.size };
	}
	if (!fullPath) return { success: false, message: "invalid path or workDir" };
	return { success: false, message: "file not found" };
}

export function readFileRaw(workDir: string, path: string, docLanguage?: DoraDocLanguage): ReadFileResult {
	return readWorkspaceFile(workDir, path, docLanguage);
}

export function inspectWorkspaceTextTarget(workDir: string, path: string): WorkspaceTextTargetResult {
	const fullPath = resolveWorkspaceFilePath(workDir, path);
	if (!fullPath) return { success: false, message: "invalid path or workDir" };
	if (!Content.exist(fullPath)) return { success: true, exists: false, content: "" };
	if (Content.isdir(fullPath)) return { success: false, message: "target is a directory" };
	const attr = inspectReadableFile(fullPath);
	if (!attr.success) return { success: false, message: attr.message };
	return { success: true, exists: true, content: Content.load(fullPath) };
}

function getEngineLogText(): string | undefined {
	const folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR);
	if (!Content.exist(folder)) {
		Content.mkdir(folder);
	}
	const logPath = Path(folder, ENGINE_LOG_FILE);
	if (!App.saveLog(logPath)) {
		return undefined;
	}
	return Content.load(logPath);
}

export function getLogs(req?: { tailLines?: number; joinText?: boolean }): GetLogsResult {
	const text = getEngineLogText();
	if (text === undefined) {
		return { success: false, message: "failed to read engine logs" };
	}
	const tailLines = math.max(1, math.floor(req?.tailLines ?? 200));
	const allLines = text.split("\n");
	const logs = allLines.slice(math.max(0, allLines.length - tailLines));
	return req?.joinText ? { success: true, logs, text: logs.join("\n") } : { success: true, logs };
}

export function listFiles(req: {
	workDir: string;
	path: string;
	globs?: string[];
	maxEntries?: number;
}): ListFilesResult {
	const root = req.path ?? "";
	const searchRoot = resolveWorkspaceSearchPath(req.workDir, root);
	if (!searchRoot) {
		return { success: false, message: "invalid path or workDir" };
	}
	try {
		const userGlobs = req.globs && req.globs.length > 0 ? req.globs : ["**"];
		const globs = ensureSafeSearchGlobs(userGlobs);
		let files = Content.glob(searchRoot, globs, extensionLevels);
		files = toWorkspaceRelativeFileList(req.workDir, files);
		const totalEntries = files.length;
		const maxEntries = math.max(1, math.floor(req.maxEntries ?? 200));
		const truncated = totalEntries > maxEntries;
		return {
			success: true,
			files: truncated ? files.slice(0, maxEntries) : files,
			totalEntries,
			truncated,
			maxEntries,
		};
	} catch (e) {
		return { success: false, message: tostring(e) };
	}
}

function formatReadSlice(
	content: string,
	startLine: number,
	endLine: number
): ReadFileResult {
	const lines = content.split("\n");
	const totalLines = lines.length;
	if (totalLines === 0) {
		return {
			success: true,
			content: "",
			totalLines: 0,
			startLine: 1,
			endLine: 0,
			truncated: false,
		};
	}
	const rawStart = math.floor(startLine);
	const rawEnd = math.floor(endLine);
	if (rawStart === 0) {
		return { success: false, message: "startLine cannot be 0" };
	}
	if (rawEnd === 0) {
		return { success: false, message: "endLine cannot be 0" };
	}
	const start = rawStart > 0
		? rawStart
		: math.max(1, totalLines + rawStart + 1);
	if (start > totalLines) {
		return { success: false, message: `startLine ${start} exceeds file length ${totalLines}` };
	}
	const end = math.min(
		totalLines,
		rawEnd > 0
			? rawEnd
			: math.max(1, totalLines + rawEnd + 1)
	);
	if (end < start) {
		return {
			success: false,
			message: `resolved endLine ${end} is before startLine ${start}`,
		};
	}
	const slice: string[] = [];
	for (let i = start; i <= end; i++) {
		slice.push(lines[i - 1]);
	}
	const truncated = start > 1 || end < totalLines;
	const hint = end < totalLines
		? `(Showing lines ${start}-${end} of ${totalLines}. Use startLine=${end + 1} to continue.)`
		: truncated
			? `(Showing lines ${start}-${end} of ${totalLines}.)`
			: `(End of file - ${totalLines} lines total)`;
	const body = slice.join("\n");
	const output = body === "" ? hint : `${body}\n\n${hint}`;
	return {
		success: true,
		content: output,
		totalLines,
		startLine: start,
		endLine: end,
		truncated,
	};
}

export function readFile(
	workDir: string,
	path: string,
	startLine?: number,
	endLine?: number,
	docLanguage?: DoraDocLanguage
): ReadFileResult {
	const fallback = readFileRaw(workDir, path, docLanguage);
	if (!fallback.success || fallback.content === undefined) return fallback;
	const resolvedStartLine = startLine ?? 1;
	const resolvedEndLine = endLine ?? (resolvedStartLine < 0 ? -1 : 300);
	return formatReadSlice(
		fallback.content,
		resolvedStartLine,
		resolvedEndLine
	);
}

export const codeExtensions = [".lua", ".tl", ".yue", ".ts", ".tsx", ".xml", ".md", ".yarn", ".wa", ".mod"];
const extensionLevels: Record<string, number> = {
	vs: 2,
	bl: 2,
	ts: 1,
	tsx: 1,
	tl: 1,
	yue: 1,
	xml: 1,
	lua: 0,
};

export function ensureSafeSearchGlobs(globs: string[]): string[] {
	const result: string[] = [];
	for (let i = 0; i < globs.length; i++) {
		result.push(globs[i]);
	}
	const requiredExcludes = ["!**/.*/**", "!**/node_modules/**"];
	for (let i = 0; i < requiredExcludes.length; i++) {
		if (result.indexOf(requiredExcludes[i]) === -1) {
			result.push(requiredExcludes[i]);
		}
	}
	return result;
}

export function splitSearchPatterns(pattern: string): string[] {
	const trimmed = (pattern ?? "").trim();
	if (trimmed === "") return [];
	const out: string[] = [];
	const seen = new Set<string>();
	for (const [p0] of string.gmatch(trimmed, "([^|]+)")) {
		const p = tostring(p0).trim();
		if (p !== "" && !seen.has(p)) {
			seen.add(p);
			out.push(p);
		}
	}
	return out;
}

export function splitWhitespaceSearchPatterns(pattern: string): string[] {
	const out: string[] = [];
	const seen = new Set<string>();
	for (const [p0] of string.gmatch(pattern, "(%S+)")) {
		const p = tostring(p0).trim();
		const key = p.toLowerCase();
		if (p !== "" && !seen.has(key)) {
			seen.add(key);
			out.push(p);
		}
	}
	return out;
}

function mergeSearchFileResultsUnique(resultsList: SearchFilesResult[][]): SearchFilesResult[] {
	const merged: SearchFilesResult[] = [];
	const seen = new Set<string>();
	for (let i = 0; i < resultsList.length; i++) {
		const list = resultsList[i];
		for (let j = 0; j < list.length; j++) {
			const row = list[j];
			const key = `${row.file}:${row.pos}:${row.line}:${row.column}`;
			if (seen.has(key)) continue;
			seen.add(key);
			merged.push(list[j]);
		}
	}
	return merged;
}

function buildGroupedSearchResults(results: SearchFilesResult[]): {
	file: string;
	totalMatches: number;
	matches: SearchFilesResult[];
}[] {
	const order: string[] = [];
	const grouped = new Map<string, {
		file: string;
		totalMatches: number;
		matches: SearchFilesResult[];
	}>();
	for (let i = 0; i < results.length; i++) {
		const row = results[i]
		const file = row.file;
		const key = file !== "" ? file : `(unknown:${i})`;
		let bucket = grouped.get(key);
		if (!bucket) {
			bucket = { file: file !== "" ? file : "(unknown)", totalMatches: 0, matches: [] };
			grouped.set(key, bucket);
			order.push(key);
		}
		bucket.totalMatches += 1;
		bucket.matches.push(results[i]);
	}
	const out: {
		file: string;
		totalMatches: number;
		matches: SearchFilesResult[];
	}[] = [];
	for (let i = 0; i < order.length; i++) {
		const bucket = grouped.get(order[i]);
		if (bucket) out.push(bucket);
	}
	return out;
}

export async function searchFiles(req: {
	workDir: string;
	path: string;
	docLanguage?: DoraDocLanguage;
	globs?: string[];
	pattern: string;
	useRegex?: boolean;
	caseSensitive?: boolean;
	includeContent?: boolean;
	contentWindow?: number;
	limit?: number;
	offset?: number;
	groupByFile?: boolean;
}): Promise<SearchFilesToolResult> {
	const requestedPath = (req.path ?? "").trim();
	const isVirtualDoc = requestedPath.startsWith(AGENT_DORA_DOC_PREFIX);
	const virtualDocPath = isVirtualDoc
		? resolveAgentDoraDocFilePath(requestedPath, req.docLanguage ?? "en")
		: undefined;
	if (isVirtualDoc && !virtualDocPath) {
		return { success: false, message: "virtual document not found or outside its documentation scope" };
	}
	const resolvedPath = virtualDocPath ?? resolveWorkspaceSearchPath(req.workDir, requestedPath);
	if (!resolvedPath) {
		return { success: false, message: "invalid path or workDir" as string };
	}
	const searchIsSingleFile = Content.exist(resolvedPath) && !Content.isdir(resolvedPath);
	const searchRoot = searchIsSingleFile ? Path.getPath(resolvedPath) : resolvedPath;
	if (!searchRoot) {
		return { success: false, message: "invalid path or workDir" as string };
	}
	if (!req.pattern || req.pattern.trim() === "") {
		return { success: false, message: "empty pattern" as string };
	}
	const patterns = splitSearchPatterns(req.pattern);
	if (patterns.length === 0) {
		return { success: false, message: "empty pattern" as string };
	}
	return new Promise(resolve => {
		Director.systemScheduler.schedule(once(() => {
			try {
				const searchGlobs = searchIsSingleFile
					? [Path.getFilename(resolvedPath)]
					: ensureSafeSearchGlobs(req.globs ?? ["**"]);
				const allResults: SearchFilesResult[][] = [];
				for (let i = 0; i < patterns.length; i++) {
					allResults.push(Content.searchFilesAsync(
						searchRoot,
						codeExtensions,
						extensionLevels,
						searchGlobs,
						patterns[i],
						req.useRegex ?? false,
						req.caseSensitive ?? false,
						req.includeContent ?? true,
						req.contentWindow ?? 120
					));
				}
				const results = mergeSearchFileResultsUnique(allResults);
				const totalResults = results.length;
				const limit = math.max(1, math.floor(req.limit ?? 20));
				const offset = math.max(0, math.floor(req.offset ?? 0));
				const paged = offset >= totalResults ? [] : results.slice(offset, offset + limit);
				const nextOffset = offset + paged.length;
				const hasMore = nextOffset < totalResults;
				const truncated = offset > 0 || hasMore;
				const relativeResults = virtualDocPath
					? paged.map(row => ({ ...row, file: requestedPath }))
					: toWorkspaceRelativeSearchResults(req.workDir, paged);
				const groupByFile = req.groupByFile === true;
				resolve({
					success: true,
					results: relativeResults,
					groupedResults: groupByFile ? buildGroupedSearchResults(relativeResults) : undefined,
					totalResults,
					truncated,
					limit,
					offset,
					nextOffset,
					hasMore,
					groupByFile,
				});
			} catch (e) {
				resolve({ success: false, message: tostring(e) });
			}
		}));
	});
}

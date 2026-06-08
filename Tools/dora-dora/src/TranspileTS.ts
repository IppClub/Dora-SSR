/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import monaco, { monacoTypescript } from './monacoBase';
import type { CompilerHost, CompilerOptions, Diagnostic, Program } from 'typescript';
import type { CompilerOptions as TstlCompilerOptions } from './3rdParty/tstl';
import { SourceMapConsumer } from 'source-map';
import Info from './Info';
import * as Service from './Service';
import { getExtraLib } from './MonacoPath';

type TsModule = typeof import('typescript');
type TstlModule = typeof import('./3rdParty/tstl');
type OutputCollectorModule = typeof import('./3rdParty/tstl/transpilation/output-collector');

let tsPromise: Promise<TsModule> | null = null;
let cachedTs: TsModule | null = null;
let cachedTstlOptions: TstlCompilerOptions | null = null;
let cachedDeclarationOptions: CompilerOptions | null = null;
let tstlPromise: Promise<TstlModule> | null = null;
let outputCollectorPromise: Promise<OutputCollectorModule> | null = null;

function getTypescriptUrl() {
	let url = "/typescript.js";
	try {
		const custom = (globalThis as any).__TYPESCRIPT_CUSTOM_URL__;
		if (typeof custom === "string" && custom.length > 0) {
			url = custom;
		}
	} catch {
		// ignore
	}
	return url;
}

async function loadTypescriptCompiler(): Promise<TsModule> {
	if (cachedTs) return cachedTs;
	const existing = (globalThis as any).ts;
	if (existing) {
		cachedTs = existing as TsModule;
		return cachedTs;
	}
	if (!tsPromise) {
		tsPromise = new Promise((resolve, reject) => {
			const url = getTypescriptUrl();
			if (typeof document === "undefined") {
				const scope = globalThis as any;
				if (typeof scope.importScripts === "function") {
					try {
						scope.importScripts(url);
						const loaded = scope.ts as TsModule | undefined;
						if (loaded) {
							cachedTs = loaded;
							resolve(cachedTs);
							return;
						}
					} catch (err) {
						reject(err);
						return;
					}
				}
				reject(new Error(`TypeScript compiler is not available and cannot load ${url}`));
				return;
			}
			const script = document.createElement("script");
			script.src = url;
			script.async = true;
			script.onload = () => {
				const loaded = (globalThis as any).ts;
				if (!loaded) {
					reject(new Error(`TypeScript compiler loaded from ${url} but global "ts" is missing`));
					return;
				}
				cachedTs = loaded as TsModule;
				resolve(cachedTs);
			};
			script.onerror = () => {
				reject(new Error(`Failed to load TypeScript compiler from ${url}`));
			};
			document.head.appendChild(script);
		});
	}
	return tsPromise;
}

async function loadTstl(): Promise<TstlModule> {
	if (!tstlPromise) {
		tstlPromise = import('./3rdParty/tstl');
	}
	return tstlPromise;
}

async function loadOutputCollector(): Promise<OutputCollectorModule> {
	if (!outputCollectorPromise) {
		outputCollectorPromise = import('./3rdParty/tstl/transpilation/output-collector');
	}
	return outputCollectorPromise;
}

function getTstlOptions(ts: TsModule, tstl: TstlModule): TstlCompilerOptions {
	if (!cachedTstlOptions) {
		const scriptTarget = ts.ScriptTarget.ESNext;
		const moduleKind = ts.ModuleKind.ESNext;
		cachedTstlOptions = {
			strict: true,
			jsx: ts.JsxEmit.React,
			luaTarget: tstl.LuaTarget.Lua55,
			luaLibImport: tstl.LuaLibImportKind.Require,
			noHeader: true,
			sourceMap: true,
			noImplicitSelf: true,
			moduleResolution: ts.ModuleResolutionKind.Classic,
			target: scriptTarget,
			module: moduleKind,
		};
	}
	return cachedTstlOptions;
}

function getDeclarationOptions(ts: TsModule): CompilerOptions {
	if (!cachedDeclarationOptions) {
		const scriptTarget = ts.ScriptTarget.ESNext;
		const moduleKind = ts.ModuleKind.ESNext;
		cachedDeclarationOptions = {
			declaration: true,
			emitDeclarationOnly: true,
			strict: true,
			jsx: ts.JsxEmit.React,
			sourceMap: true,
			moduleResolution: ts.ModuleResolutionKind.Classic,
			target: scriptTarget,
			module: moduleKind,
		};
	}
	return cachedDeclarationOptions;
}

function createCompilerHost(
	ts: TsModule,
	rootFileName: string,
	content: string
): [CompilerHost, Map<string, string>] {
	const currentDirectory = Info.path.dirname(rootFileName);
	const writeFiles = new Map<string, string>();
	const pathMap = new Map<string, monaco.Uri>();
	const unexistMap = new Set<string>();
	const scriptTarget = ts.ScriptTarget.ESNext;
	type SourceFileData = {
		fileName: string;
		content: string;
	};
	const sourceCache = new Map<string, SourceFileData | null>();
	const isSamePath = (a: string, b: string) => {
		try {
			return Info.path.relative(a, b) === "";
		} catch {
			return false;
		}
	};
	const syncModelContent = (uri: monaco.Uri, nextContent: string) => {
		const model = monaco.editor.getModel(uri);
		if (model !== null) {
			if (model.getValue() !== nextContent) {
				model.setValue(nextContent);
			}
		} else {
			monaco.editor.createModel(nextContent, 'typescript', uri);
		}
	};
	syncModelContent(monaco.Uri.file(rootFileName), content);
	const getCachedBuiltinLib = (fileName: string): SourceFileData | undefined => {
		const directLib = getExtraLib(fileName);
		if (directLib !== undefined) {
			return { fileName, content: directLib.content };
		}
		const baseName = Info.path.basename(fileName);
		if (baseName !== "Dora.d.ts" && baseName !== "es6-subset.d.ts" && baseName !== "lua.d.ts") {
			return undefined;
		}
		for (const [libFileName, lib] of Object.entries(monacoTypescript.typescriptDefaults.getExtraLibs()) as [string, { content: string }][]) {
			if (Info.path.basename(libFileName) === baseName) {
				return { fileName: libFileName, content: lib.content };
			}
		}
		return undefined;
	};
	const readSourceFile = (fileName: string, options?: { exts?: string[], fallbackToBaseName?: boolean }) => {
		fileName = Info.path.normalize(fileName);
		const fallbackToBaseName = options?.fallbackToBaseName !== false;
		const cacheKey = `${fileName}\n${options?.exts?.join("|") ?? ""}\n${fallbackToBaseName ? "base" : ""}`;
		if (sourceCache.has(cacheKey)) {
			return sourceCache.get(cacheKey) ?? undefined;
		}
		const cacheSource = (source: SourceFileData | undefined) => {
			sourceCache.set(cacheKey, source ?? null);
			return source;
		};
		if (isSamePath(rootFileName, fileName)) {
			return cacheSource({ fileName: rootFileName, content });
		}
		const readResolvedFile = (targetPath: string, exts?: string[], fallbackToBaseName = false) => {
			const resolvedCacheKey = `${Info.path.normalize(targetPath)}\n${exts?.join("|") ?? ""}\n${fallbackToBaseName ? "base" : ""}`;
			if (sourceCache.has(resolvedCacheKey)) {
				return sourceCache.get(resolvedCacheKey) ?? undefined;
			}
			const cacheResolvedSource = (source: SourceFileData | undefined) => {
				sourceCache.set(resolvedCacheKey, source ?? null);
				return source;
			};
			const readSync = (path: string) => Service.readSync({ path, exts, projFile: rootFileName });
			let res = readSync(targetPath);
			if (!res?.success && fallbackToBaseName && Info.path.isAbsolute(targetPath)) {
				const ext = Info.path.extname(targetPath);
				let baseName = Info.path.basename(targetPath, ext);
				baseName = Info.path.extname(baseName) === ".d" ? Info.path.basename(baseName, ".d") : baseName;
				res = readSync(baseName);
			}
			if (res?.success) {
				const fullUri = monaco.Uri.file(res.fullPath);
				syncModelContent(fullUri, res.content);
				const requestedUri = monaco.Uri.file(fileName);
				const requestedModel = monaco.editor.getModel(requestedUri);
				if (requestedModel !== null && !isSamePath(requestedUri.fsPath, fullUri.fsPath)) {
					requestedModel.dispose();
				}
				pathMap.set(fileName, fullUri);
				return cacheResolvedSource({ fileName: res.fullPath, content: res.content });
			}
			return cacheResolvedSource(undefined);
		};
		const mappedUri = pathMap.get(fileName);
		if (mappedUri !== undefined) {
			const mappedModel = monaco.editor.getModel(mappedUri);
			if (mappedModel !== null) {
				return cacheSource({ fileName: mappedUri.fsPath, content: mappedModel.getValue() });
			}
		}
		const builtinLib = getCachedBuiltinLib(fileName);
		if (builtinLib !== undefined) {
			return cacheSource(builtinLib);
		}
		const currentExt = Info.path.extname(fileName);
		if (options?.exts !== undefined) {
			const source = readResolvedFile(fileName, options.exts, fallbackToBaseName);
			if (source !== undefined) return cacheSource(source);
		} else if (currentExt === ".ts" || currentExt === ".tsx" || currentExt === ".d.ts") {
			const baseName = Info.path.basename(fileName, currentExt);
			const lookupBaseName = Info.path.extname(baseName) === ".d" ? Info.path.basename(baseName, ".d") : baseName;
			const source = readResolvedFile(Info.path.join(Info.path.dirname(fileName), lookupBaseName), [".d.ts", ".ts", ".tsx"], fallbackToBaseName);
			if (source !== undefined) return cacheSource(source);
		}
		const uri = monaco.Uri.file(fileName);
		const model = monaco.editor.getModel(uri);
		if (model !== null) {
			return cacheSource({ fileName: uri.fsPath, content: model.getValue() });
		}
		return cacheSource(readResolvedFile(fileName, options?.exts, fallbackToBaseName));
	};
	const compilerHost: CompilerHost = {
		fileExists: fileName => {
			if (fileName.search("node_modules") > 0) {
				return false;
			}
			fileName = Info.path.normalize(fileName);
			const uri = pathMap.get(fileName);
			if (uri !== undefined) {
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return true;
				}
			}
			const baseName = Info.path.basename(fileName);
			if (baseName.startsWith('Dora.d.') && baseName !== 'Dora.d.ts') {
				return false;
			}
			if (baseName.startsWith('Dora.') && baseName !== 'Dora.d.ts') {
				return true;
			}
			if (baseName.toLowerCase().startsWith('dora.')) {
				return false;
			}
			if (baseName === 'lib.Dora.d.ts') {
				return true;
			}
			if (Info.path.isAbsolute(fileName)) {
				const relativePath = Info.path.relative(currentDirectory, fileName);
				if (!relativePath.startsWith('..')) {
					const ext = Info.path.extname(relativePath);
					let baseName = Info.path.basename(relativePath, ext);
					baseName = Info.path.extname(baseName) === ".d" ? Info.path.basename(baseName, ".d") : baseName;
					const targetFile = baseName;
					const dirName = Info.path.dirname(relativePath);
					const path = Info.path.join(dirName, targetFile);
					for (const ext of [".d.ts", ".ts", ".tsx"]) {
						const uri = monaco.Uri.file(path + ext);
						const model = monaco.editor.getModel(uri);
						if (model !== null) {
							pathMap.set(fileName, uri);
							return true;
						}
					}
					if (unexistMap.has(path)) {
						return false;
					}
					const source = readSourceFile(path, { exts: [".d.ts", ".ts", ".tsx"] });
					if (source !== undefined) {
						pathMap.set(fileName, monaco.Uri.file(source.fileName));
						return true;
					} else {
						pathMap.delete(fileName);
						unexistMap.add(path);
					}
				}
			}
			const currentExt = Info.path.extname(fileName);
			let currentBaseName = Info.path.basename(fileName, currentExt);
			currentBaseName = Info.path.extname(currentBaseName) === ".d" ? Info.path.basename(currentBaseName, ".d") : currentBaseName;
			for (const ext of [".d.ts", ".ts", ".tsx"]) {
				const uri = monaco.Uri.file(Info.path.join(Info.path.dirname(fileName), currentBaseName + ext));
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					pathMap.set(fileName, uri);
					return true;
				}
			}
			if (readSourceFile(fileName) !== undefined) {
				return true;
			}
			if (currentExt === "" && readSourceFile(fileName, { exts: [".d.ts", ".ts", ".tsx"] }) !== undefined) {
				return true;
			}
			return false;
		},
		getCanonicalFileName: fileName => Info.path.normalize(fileName),
		getCurrentDirectory: () => currentDirectory,
		getDefaultLibFileName: () => "lib.Dora.d.ts",
		readFile: fileName => {
			fileName = Info.path.normalize(fileName);
			return readSourceFile(fileName)?.content;
		},
		getNewLine: () => "\n",
		useCaseSensitiveFileNames: () => true,
		writeFile: (fileName, content) => {
			writeFiles.set(fileName, content);
		},
		getSourceFile(fileName) {
			fileName = Info.path.normalize(fileName);
			const baseName = Info.path.basename(fileName);
			if (baseName.startsWith('Dora.') && baseName !== 'Dora.d.ts') {
				return ts.createSourceFile("dummy.d.ts", "", scriptTarget, false);
			}
			if (baseName === 'jsx.d.ts') {
				const source = readSourceFile(baseName);
				if (source !== undefined) {
					return ts.createSourceFile(source.fileName, source.content, scriptTarget, false);
				}
			}
			if (baseName === 'lib.Dora.d.ts') {
				const source = readSourceFile("Dora.d.ts");
				if (source !== undefined) {
					return ts.createSourceFile(source.fileName, source.content, scriptTarget, false);
				}
			}
			const source = readSourceFile(fileName);
			if (source !== undefined) {
				return ts.createSourceFile(source.fileName, source.content, scriptTarget, false);
			}
			if (!Info.path.isAbsolute(fileName)) {
				return undefined;
			} else {
				const uri = pathMap.get(fileName);
				if (uri !== undefined) {
					const model = monaco.editor.getModel(uri);
					if (model !== null) {
						return ts.createSourceFile(uri.fsPath, model.getValue(), scriptTarget, false);
					}
				}
				const fileContent = compilerHost.readFile(fileName);
				if (fileContent !== undefined) {
					return ts.createSourceFile(fileName, fileContent, scriptTarget, false);
				}
				return undefined;
			}
		},
	};
	return [compilerHost, writeFiles];
}

function createTypescriptProgram(
	ts: TsModule,
	tstlOptions: TstlCompilerOptions,
	rootFileName: string,
	content: string
): Program {
	const [compilerHost] = createCompilerHost(ts, rootFileName, content);
	tstlOptions.baseUrl = Info.path.dirname(rootFileName);
	return ts.createProgram([rootFileName], tstlOptions, compilerHost);
}

(SourceMapConsumer as any).initialize({
	'lib/mappings.wasm': "/mappings.wasm"
});

export async function transpileTypescript(
	fileName: string,
	content: string
) {
	const ts = await loadTypescriptCompiler();
	const tstl = await loadTstl();
	const tstlOptions = getTstlOptions(ts, tstl);
	const program = createTypescriptProgram(ts, tstlOptions, fileName, content);
	let diagnostics = ts.getPreEmitDiagnostics(program);
	const { createEmitOutputCollector } = await loadOutputCollector();
	const collector = createEmitOutputCollector();
	const res = new tstl.Transpiler({
		emitHost: {
			directoryExists: () => false,
			fileExists: () => true,
			getCurrentDirectory: () => Info.path.dirname(fileName),
			readFile: (filename) => {
				const res = Service.readSync({ path: filename });
				if (res?.success) {
					return res.content;
				}
				return undefined;
			},
			writeFile: () => { }
		}
	}).emit({
		program,
		writeFile: collector.writeFile
	});
	diagnostics = [...diagnostics, ...res.diagnostics].filter(d => d.code !== 2497 && d.code !== 2666);

	const otherFileDiagnostics = diagnostics.filter(d => {
		try {
			return Info.path.relative(d.file?.fileName ?? "", fileName) !== "";
		} catch {
			return true;
		}
	});
	await addDiagnosticToLog(fileName, otherFileDiagnostics);

	const success = diagnostics.length === 0;
	const file = collector.files.find(({ sourceFiles }) => sourceFiles.some(f => {
		return Info.path.relative(f.fileName, fileName) === "";
	}));
	if (file !== undefined) {
		const luaSourceMap = file.luaSourceMap;
		if (luaSourceMap !== undefined && file.lua !== undefined) {
			const luaCode = file.lua.split('\n');
			let modifiedLuaCode: string | undefined;
			await SourceMapConsumer.with(luaSourceMap, null, consumer => {
				let lastValidTsLineNumber: number | null = null;
				modifiedLuaCode = `-- [${Info.path.extname(fileName).substring(1).toLowerCase()}]: ${Info.path.basename(fileName)}\n` + luaCode.map((line, index) => {
					const firstNonWhitespaceIndex = line.search(/\S|$/);
					const originalPosition = consumer.originalPositionFor({ line: index + 1, column: firstNonWhitespaceIndex });
					if (originalPosition.line != null) {
						lastValidTsLineNumber = originalPosition.line;
					}
					const lineToUse = lastValidTsLineNumber ?? 1;
					if (line.trim() === "") {
						return "";
					}
					if (line.match("--")) {
						return line;
					}
					return line + ` -- ${lineToUse}`;
				}).filter(l => l !== "").join('\n');
			});
			return { success, luaCode: modifiedLuaCode, diagnostics, extraError: otherFileDiagnostics.length > 0 };
		}
	}
	return { success, luaCode: undefined as string | undefined, diagnostics, extraError: otherFileDiagnostics.length > 0 };
}

export async function revalidateModel(model: monaco.editor.ITextModel) {
	if (!model || model.isDisposed()) return;
	const ts = await loadTypescriptCompiler();
	const getWorker = await monacoTypescript.getTypeScriptWorker();
	const worker = await getWorker(model.uri);
	const diagnostics = (await Promise.all([
		worker.getSyntacticDiagnostics(model.uri.toString()),
		worker.getSemanticDiagnostics(model.uri.toString())
	]))
		.reduce((a: Diagnostic[], it) => a.concat(it), [])
		.filter((d: Diagnostic) => d.code !== 2497 && d.code !== 2666);
	const markers = diagnostics.map(d => {
		const { start = 0, length = 0 } = d;
		const startPos = model.getPositionAt(start);
		const endPos = model.getPositionAt(start + length);
		return {
			severity: monaco.MarkerSeverity.Error,
			startLineNumber: startPos.lineNumber,
			startColumn: startPos.column,
			endLineNumber: endPos.lineNumber,
			endColumn: endPos.column,
			message: ts.flattenDiagnosticMessageText(d.messageText, "\n")
		};
	});
	monaco.editor.setModelMarkers(model, model.getLanguageId(), markers);
}

export async function setModelMarkers(model: monaco.editor.ITextModel, diagnostics: readonly Diagnostic[]) {
	const ts = await loadTypescriptCompiler();
	const markers = diagnostics.filter(d => {
		const fileName = d.file?.fileName ?? "";
		if (!Info.path.isAbsolute(fileName)) {
			return false;
		}
		if (!Info.path.isAbsolute(model.uri.fsPath)) {
			return false;
		}
		try {
			return Info.path.relative(fileName, model.uri.fsPath) === "" && d.source === 'typescript-to-lua';
		} catch {
			return false;
		}
	}).map(d => {
		const { start = 0, length = 0 } = d;
		const startPos = model.getPositionAt(start);
		const endPos = model.getPositionAt(start + length);
		return {
			severity: monaco.MarkerSeverity.Error,
			startLineNumber: startPos.lineNumber,
			startColumn: startPos.column,
			endLineNumber: endPos.lineNumber,
			endColumn: endPos.column,
			message: ts.flattenDiagnosticMessageText(d.messageText, "\n")
		};
	});
	monaco.editor.setModelMarkers(model, 'tstl', markers);
}

export async function getDiagnosticMessage(fileName: string, diagnostics: readonly Diagnostic[]) {
	const ts = await loadTypescriptCompiler();
	if (diagnostics.length === 0) return "";
	return `Compiling error: ${fileName}\n` +
		ts.formatDiagnostics(diagnostics, {
			getCanonicalFileName: fileName => Info.path.normalize(fileName),
			getCurrentDirectory: () => Info.path.dirname(fileName),
			getNewLine: () => "\n"
		});
}

export async function addDiagnosticToLog(fileName: string, diagnostics: readonly Diagnostic[]) {
	if (diagnostics.length === 0) return;
	let message = await getDiagnosticMessage(fileName, diagnostics);
	message = message.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\r?\n/g, "\\n");
	Service.command({ code: `Log "Error", "${message}"`, log: false });
}

export async function getDeclarationFile(fileName: string, content: string) {
	const ts = await loadTypescriptCompiler();
	const [host, writeFiles] = createCompilerHost(ts, fileName, content);
	const program = ts.createProgram([fileName], getDeclarationOptions(ts), host);
	const result = program.emit();
	await addDiagnosticToLog(fileName, result.diagnostics);
	const baseName = Info.path.basename(fileName, Info.path.extname(fileName));
	for (const [outputFileName, outputContent] of writeFiles.entries()) {
		const outputBaseName = Info.path.basename(outputFileName, '.d.ts');
		if (outputBaseName === baseName && outputFileName.endsWith('.d.ts')) {
			return {
				fileName: outputFileName,
				content: outputContent
			};
		}
	}
	return null;
}

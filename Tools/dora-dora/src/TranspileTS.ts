/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import monaco, { monacoTypescript } from './monacoBase';
import type { CompilerOptions, Diagnostic } from 'typescript';
import type { CompilerOptions as TstlCompilerOptions } from '@dora-studio/tstl';
import { SourceMapConsumer } from 'source-map';
import Info from './Info';
import * as Service from './Service';
import type { TranspileTSVirtualFile, TypeScriptSnapshot } from './Service';
import { setMonacoRuntime } from './MonacoRuntimeAccess';
import { createSnapshotProgram, doraCompilerOptions, normalizePath } from '@dora-studio/compiler';
import { promoteCompilerWarnings } from './TranspileDiagnostics';

setMonacoRuntime({
	monaco,
	typescript: monacoTypescript,
});

type TsModule = typeof import('typescript');
type TstlModule = typeof import('@dora-studio/tstl');
type OutputCollectorModule = typeof import('@dora-studio/tstl/output-collector');

let tsPromise: Promise<TsModule> | null = null;
let cachedTs: TsModule | null = null;
let tstlPromise: Promise<TstlModule> | null = null;
let outputCollectorPromise: Promise<OutputCollectorModule> | null = null;
let typescriptUrlPromise: Promise<string> | null = null;
let sourceMapWasmPromise: Promise<void> | null = null;

async function getTypescriptUrl() {
	try {
		const custom = (globalThis as any).__TYPESCRIPT_CUSTOM_URL__;
		if (typeof custom === "string" && custom.length > 0) {
			return custom;
		}
	} catch {
		// ignore
	}
	typescriptUrlPromise ??= fetch("/heavy-assets.json", {
		cache: "no-cache",
	}).then(async response => {
		if (!response.ok) {
			throw new Error(`Failed to load heavy asset manifest: ${response.status}`);
		}
		const manifest = await response.json() as { typescript?: unknown };
		if (typeof manifest.typescript !== "string" || manifest.typescript.length === 0) {
			throw new Error("Heavy asset manifest does not contain a TypeScript URL.");
		}
		return manifest.typescript;
	});
	return typescriptUrlPromise;
}

async function loadTypescriptCompiler(): Promise<TsModule> {
	if (cachedTs) return cachedTs;
	const existing = (globalThis as any).ts;
	if (existing) {
		cachedTs = existing as TsModule;
		return cachedTs;
	}
	if (!tsPromise) {
		tsPromise = getTypescriptUrl().then(url => new Promise<TsModule>((resolve, reject) => {
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
		}));
	}
	return tsPromise;
}

async function loadTstl(): Promise<TstlModule> {
	if (!tstlPromise) {
		tstlPromise = import('@dora-studio/tstl');
	}
	return tstlPromise;
}

async function loadOutputCollector(): Promise<OutputCollectorModule> {
	if (!outputCollectorPromise) {
		outputCollectorPromise = import('@dora-studio/tstl/output-collector');
	}
	return outputCollectorPromise;
}

async function loadSourceMapWasm() {
	if (!sourceMapWasmPromise) {
		sourceMapWasmPromise = fetch("/mappings.wasm").then(async response => {
			if (!response.ok) {
				throw new Error(`Failed to load source-map WASM: ${response.status}`);
			}
			// source-map declares initialize on instances, but implements it statically.
			(SourceMapConsumer as typeof SourceMapConsumer & Pick<SourceMapConsumer, "initialize">).initialize({
				'lib/mappings.wasm': await response.arrayBuffer(),
			});
		});
	}
	return sourceMapWasmPromise;
}

export async function warmupTypescriptTranspiler() {
	// TSTL's TypeScript shim reads globalThis.ts while the module is imported,
	// so the compiler script must finish before either TSTL chunk starts.
	await loadTypescriptCompiler();
	await Promise.all([
		loadTstl(),
		loadOutputCollector(),
		loadSourceMapWasm(),
	]);
}

function getTstlOptions(ts: TsModule, tstl: TstlModule, runtimeModules: readonly string[], assetPath?: string): TstlCompilerOptions {
	return doraCompilerOptions(ts, tstl.LuaTarget.Lua55, tstl.LuaLibImportKind.Require, runtimeModules, assetPath);
}

function getDeclarationOptions(ts: TsModule): CompilerOptions {
	return {
		declaration: true,
		emitDeclarationOnly: true,
		strict: true,
		jsx: ts.JsxEmit.React,
		sourceMap: true,
		moduleResolution: ts.ModuleResolutionKind.Classic,
		target: ts.ScriptTarget.ESNext,
		module: ts.ModuleKind.ESNext,
	};
}

async function requestTypeScriptSnapshot(file: string): Promise<TypeScriptSnapshot> {
	const snapshot = await Service.tsSnapshot(file);
	if (!snapshot.success) throw new Error(snapshot.message || "TypeScript snapshot is unavailable");
	return snapshot;
}

function createTypescriptProgram(
	ts: TsModule, options: CompilerOptions, file: string, content: string, snapshot: TypeScriptSnapshot,
) {
	const fileName = normalizePath(file);
	const files = new Map(snapshot.files.map(entry => [normalizePath(entry.file), entry]));
	files.set(fileName, { ...files.get(fileName), file: fileName, content });
	return createSnapshotProgram(ts, {
		...snapshot, rootNames: [fileName], files: [...files.values()], options,
	});
}

export async function transpileTypescript(
	fileName: string,
	content: string,
	projectRoot?: string,
	virtualFiles?: TranspileTSVirtualFile[],
	projectScriptRoot?: string,
	luaRuntimeModules?: string[],
	assetPath?: string,
	defaultLibFileName?: string,
) {
	const ts = await loadTypescriptCompiler();
	const tstl = await loadTstl();
	await loadSourceMapWasm();
	const snapshot = projectRoot && virtualFiles && luaRuntimeModules && assetPath && defaultLibFileName
		? { projectRoot, projectScriptRoot, files: virtualFiles, luaRuntimeModules, assetPath, defaultLibFileName }
		: await requestTypeScriptSnapshot(fileName);
	const options = getTstlOptions(ts, tstl, snapshot.luaRuntimeModules, snapshot.assetPath);
	const { program, host } = createTypescriptProgram(ts, options, fileName, content, snapshot);
	const preEmitDiagnostics = ts.getPreEmitDiagnostics(program);
	const { createEmitOutputCollector } = await loadOutputCollector();
	const collector = createEmitOutputCollector();
	const res = new tstl.Transpiler({
		emitHost: {
			directoryExists: path => host.directoryExists?.(path) ?? false,
			fileExists: host.fileExists,
			getCurrentDirectory: host.getCurrentDirectory,
			readFile: host.readFile,
			writeFile: () => { }
		}
	}).emit({
		program,
		writeFile: collector.writeFile
	});
	const diagnostics = promoteCompilerWarnings(
		[...preEmitDiagnostics, ...res.diagnostics].filter(d => d.code !== 2497 && d.code !== 2666),
		ts.DiagnosticCategory,
	);

	const otherFileDiagnostics = diagnostics.filter(d => {
		try {
			return Info.path.relative(d.file?.fileName ?? "", fileName) !== "";
		} catch {
			return true;
		}
	});
	if (virtualFiles === undefined) {
		await addDiagnosticToLog(fileName, otherFileDiagnostics);
	}

	const success = diagnostics.length === 0;
	if (!success) {
		return { success, luaCode: undefined as string | undefined, diagnostics, extraError: otherFileDiagnostics.length > 0 };
	}
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
			if (modifiedLuaCode !== undefined && modifiedLuaCode.trim() !== "") {
				return { success, luaCode: modifiedLuaCode, diagnostics, extraError: otherFileDiagnostics.length > 0 };
			}
		}
	}
	diagnostics.push({ category: ts.DiagnosticCategory.Error, code: 0,
		file: program.getSourceFile(fileName), start: 0, length: 0,
		messageText: "Compiler produced no Lua output for this source file." });
	return { success: false, luaCode: undefined as string | undefined, diagnostics, extraError: otherFileDiagnostics.length > 0 };
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
		.flat()
		.filter((d) => d.code !== 2497 && d.code !== 2666);
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
	const compilerOptions = getDeclarationOptions(ts);
	const snapshot = await requestTypeScriptSnapshot(fileName);
	const { program, outputs } = createTypescriptProgram(ts, compilerOptions, fileName, content, snapshot);
	const result = program.emit();
	await addDiagnosticToLog(fileName, result.diagnostics);
	const baseName = Info.path.basename(fileName, Info.path.extname(fileName));
	for (const [outputFileName, outputContent] of outputs.entries()) {
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

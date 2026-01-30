/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import monaco, { monacoTypescript } from './monacoBase';
import * as tstl from './3rdParty/tstl';
import * as ts from 'typescript';
import { createEmitOutputCollector } from './3rdParty/tstl/transpilation/output-collector';
import { SourceMapConsumer } from 'source-map';
import Info from './Info';
import * as Service from './Service';

const scriptTarget = ts.ScriptTarget.ESNext;
const moduleKind = ts.ModuleKind.ESNext;

const tstlOptions: tstl.CompilerOptions = {
	strict: true,
	jsx: ts.JsxEmit.React,
	luaTarget: tstl.LuaTarget.Lua54,
	luaLibImport: tstl.LuaLibImportKind.Require,
	noHeader: true,
	sourceMap: true,
	noImplicitSelf: true,
	moduleResolution: ts.ModuleResolutionKind.Classic,
	target: scriptTarget,
	module: moduleKind,
};

function createCompilerHost(rootFileName: string, content: string): [ts.CompilerHost, Map<string, string>] {
	const currentDirectory = Info.path.dirname(rootFileName);
	const writeFiles = new Map<string, string>();
	const pathMap = new Map<string, monaco.Uri>();
	const unexistMap = new Set<string>();
	const compilerHost: ts.CompilerHost = {
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
			if (baseName.startsWith('Dora.d.')) {
				return false;
			}
			if (baseName.startsWith('Dora.')) {
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
					const res = Service.readSync({path, exts: [".d.ts", ".ts", ".tsx"], projFile: rootFileName});
					if (res?.success) {
						const uri = monaco.Uri.file(res.fullPath);
						if (monaco.editor.getModel(uri) === null) {
							monaco.editor.createModel(res.content, 'typescript', uri);
						}
						pathMap.set(fileName, uri);
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
			return false;
		},
		getCanonicalFileName: fileName => Info.path.normalize(fileName),
		getCurrentDirectory: () => currentDirectory,
		getDefaultLibFileName: () => "lib.Dora.d.ts",
		readFile: fileName => {
			fileName = Info.path.normalize(fileName);
			const uri = monaco.Uri.file(fileName);
			const model = monaco.editor.getModel(uri);
			if (model !== null) {
				return model.getValue();
			}
			const res = Service.readSync({path: fileName});
			if (res?.success) {
				if (monaco.editor.getModel(uri) === null) {
					monaco.editor.createModel(res.content, 'typescript', uri);
				}
			}
			return content;
		},
		getNewLine: () => "\n",
		useCaseSensitiveFileNames: () => true,
		writeFile: (fileName, content) => {
			writeFiles.set(fileName, content);
		},
		getSourceFile(fileName) {
			fileName = Info.path.normalize(fileName);
			const baseName = Info.path.basename(fileName);
			if (baseName.startsWith('Dora.')) {
				return ts.createSourceFile("dummy.d.ts", "", scriptTarget, false);
			}
			if (baseName === 'jsx.d.ts') {
				const uri = monaco.Uri.file(baseName);
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return ts.createSourceFile(baseName, model.getValue(), scriptTarget, false);
				} else {
					const res = Service.readSync({path: baseName, projFile: rootFileName});
					if (res?.success) {
						monaco.editor.createModel(res.content, 'typescript', uri);
						return ts.createSourceFile(baseName, res.content, scriptTarget, false);
					}
				}
			}
			if (baseName === 'lib.Dora.d.ts') {
				const uri = monaco.Uri.file("Dora.d.ts");
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return ts.createSourceFile("Dora.d.ts", model.getValue(), scriptTarget, false);
				} else {
					const res = Service.readSync({path: "Dora.d.ts"});
					if (res?.success) {
						monaco.editor.createModel(res.content, 'typescript', uri);
						return ts.createSourceFile("Dora.d.ts", res.content, scriptTarget, false);
					}
				}
			}
			const lib = monacoTypescript.typescriptDefaults.getExtraLibs()[fileName];
			if (lib) {
				return ts.createSourceFile(fileName, lib.content, scriptTarget, false);
			}
			if (!Info.path.isAbsolute(fileName) || Info.path.relative(rootFileName, fileName) === "") {
				return ts.createSourceFile(fileName, content, scriptTarget, false);
			} else {
				const uri = pathMap.get(fileName);
				if (uri !== undefined) {
					const model = monaco.editor.getModel(uri);
					if (model !== null) {
						return ts.createSourceFile(uri.fsPath, model.getValue(), scriptTarget, false);
					}
				}
				return undefined;
			}
		},
	};
	return [compilerHost, writeFiles];
}

function createTypescriptProgram(rootFileName: string, content: string): ts.Program {
	const [compilerHost] = createCompilerHost(rootFileName, content);
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
	const program = createTypescriptProgram(fileName, content);
	let diagnostics = ts.getPreEmitDiagnostics(program);
	const collector = createEmitOutputCollector();
	const res = new tstl.Transpiler({
		emitHost: {
			directoryExists: () => false,
			fileExists: () => true,
			getCurrentDirectory: () => Info.path.dirname(fileName),
			readFile: (filename) => {
				if (tstlOptions.luaLibImport !== tstl.LuaLibImportKind.Inline) return "";
				const res = Service.readSync({path: filename});
				if (res?.success) {
					return res.content;
				}
				return "";
			},
			writeFile: () => {}
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
	addDiagnosticToLog(fileName, otherFileDiagnostics);

	const success = diagnostics.length === 0;
	const file = collector.files.find(({ sourceFiles }) => sourceFiles.some(f => {
		return Info.path.relative(f.fileName, fileName) === "";
	}));
	if (file !== undefined) {
		const luaSourceMap = file.luaSourceMap;
		if (luaSourceMap !== undefined && file.lua !== undefined) {
			const luaCode = file.lua.split('\n');
			let modifiedLuaCode: string | undefined = undefined;
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
			return {success, luaCode: modifiedLuaCode, diagnostics, extraError: otherFileDiagnostics.length > 0};
		}
	}
	return {success, luaCode: undefined as string | undefined, diagnostics, extraError: otherFileDiagnostics.length > 0};
}

export async function revalidateModel(model: monaco.editor.ITextModel) {
	if (!model || model.isDisposed()) return;
	const getWorker = await monacoTypescript.getTypeScriptWorker();
	const worker = await getWorker(model.uri);
	const diagnostics = (await Promise.all([
		worker.getSyntacticDiagnostics(model.uri.toString()),
		worker.getSemanticDiagnostics(model.uri.toString())
	]))
		.reduce((a: import('typescript').Diagnostic[], it) => a.concat(it), [])
		.filter((d: import('typescript').Diagnostic) => d.code !== 2497 && d.code !== 2666);
	const markers = diagnostics.map(d => {
		const {start = 0, length = 0} = d;
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

export function setModelMarkers(model: monaco.editor.ITextModel, diagnostics: readonly ts.Diagnostic[]) {
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
		const {start = 0, length = 0} = d;
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

export function getDiagnosticMessage(fileName: string, diagnostics: readonly ts.Diagnostic[]) {
	if (diagnostics.length === 0) return "";
	return `Compiling error: ${fileName}\n` +
		ts.formatDiagnostics(diagnostics, {
			getCanonicalFileName: fileName => Info.path.normalize(fileName),
			getCurrentDirectory: () => Info.path.dirname(fileName),
			getNewLine: () => "\n"
		});
}

export function addDiagnosticToLog(fileName: string, diagnostics: readonly ts.Diagnostic[]) {
	if (diagnostics.length === 0) return;
	let message = getDiagnosticMessage(fileName, diagnostics);
	message = message.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\r?\n/g, "\\n");
	Service.command({code: `Log "Error", "${message}"`, log: false});
}

const options: ts.CompilerOptions = {
	declaration: true,
	emitDeclarationOnly: true,
	strict: true,
	jsx: ts.JsxEmit.React,
	sourceMap: true,
	moduleResolution: ts.ModuleResolutionKind.Classic,
	target: scriptTarget,
	module: moduleKind,
};

export function getDeclarationFile(fileName: string, content: string) {
	const [host, writeFiles] = createCompilerHost(fileName, content);
	const program = ts.createProgram([fileName], options, host);
	const result = program.emit();
	addDiagnosticToLog(fileName, result.diagnostics);
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

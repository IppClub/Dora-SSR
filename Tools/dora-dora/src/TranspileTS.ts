/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as monaco from 'monaco-editor';
import * as tstl from './3rdParty/tstl';
import * as ts from 'typescript';
import { createEmitOutputCollector } from './3rdParty/tstl/transpilation/output-collector';
import {SourceMapConsumer} from 'source-map';
import Info from './Info';
import * as Service from './Service';

const tstlOptions: tstl.CompilerOptions = {
	strict: true,
	jsx: ts.JsxEmit.React,
	luaTarget: tstl.LuaTarget.Lua54,
	luaLibImport: tstl.LuaLibImportKind.Require,
	noHeader: true,
	sourceMap: true,
	noImplicitSelf: true,
	moduleResolution: ts.ModuleResolutionKind.Classic,
	target: ts.ScriptTarget.ESNext,
	module: ts.ModuleKind.ESNext,
};

function createTypescriptProgram(rootFileName: string, content: string): ts.Program {
	const currentDirectory = Info.path.dirname(rootFileName);
	const pathMap = new Map<string, monaco.Uri>();
	const compilerHost: ts.CompilerHost = {
		fileExists: fileName => {
			if (fileName.search("node_modules") > 0) {
				return false;
			}
			fileName = Info.path.normalize(fileName);
			const baseName = Info.path.basename(fileName);
			if (baseName.startsWith('Dora.d.')) {
				return false;
			}
			if (baseName.startsWith('Dora.')) {
				return true;
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
						const uri = monaco.Uri.parse(path + ext);
						const model = monaco.editor.getModel(uri);
						if (model !== null) {
							pathMap.set(fileName, uri);
							return true;
						}
					}
					const res = Service.readSync({path, exts: [".d.ts", ".ts", ".tsx"], projFile: rootFileName});
					if (res?.success) {
						const uri = monaco.Uri.parse(res.fullPath);
						if (monaco.editor.getModel(uri) === null) {
							monaco.editor.createModel(res.content, 'typescript', uri);
						}
						pathMap.set(fileName, uri);
						return true;
					}
				}
			}
			const currentExt = Info.path.extname(fileName);
			let currentBaseName = Info.path.basename(fileName, currentExt);
			currentBaseName = Info.path.extname(currentBaseName) === ".d" ? Info.path.basename(currentBaseName, ".d") : currentBaseName;
			for (const ext of [".d.ts", ".ts", ".tsx"]) {
				const uri = monaco.Uri.parse(Info.path.join(Info.path.dirname(fileName), currentBaseName + ext));
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					pathMap.set(fileName, uri);
					return true;
				}
			}
			const searchFile = Info.path.join(Info.path.dirname(fileName), currentBaseName);
			const res = Service.readSync({path: searchFile, exts: [".d.ts", ".ts", ".tsx"], projFile: rootFileName});
			if (res?.success) {
				const uri = monaco.Uri.parse(res.fullPath);
				if (monaco.editor.getModel(uri) === null) {
					monaco.editor.createModel(res.content, 'typescript', uri);
				}
				pathMap.set(fileName, uri);
				return true;
			}
			if (Info.path.isAbsolute(fileName)) {
				const relativeFile = Info.path.join(".", fileName);
				const ext = Info.path.extname(relativeFile);
				let baseName = Info.path.basename(relativeFile, ext);
				baseName = Info.path.extname(baseName) === ".d" ? Info.path.basename(baseName, ".d") : baseName;
				const dirName = Info.path.dirname(relativeFile);
				const targetFile = Info.path.join(dirName, baseName) + ".d.ts";
				const uri = monaco.Uri.parse(targetFile);
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					pathMap.set(fileName, uri);
					return true;
				}
				const res = Service.readSync({path: targetFile, projFile: rootFileName});
				if (res?.success) {
					const uri = monaco.Uri.parse(targetFile);
					if (monaco.editor.getModel(uri) === null) {
						monaco.editor.createModel(res.content, 'typescript', uri);
					}
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
			const uri = monaco.Uri.parse(fileName);
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
		writeFile: () => { },
		getSourceFile(fileName) {
			fileName = Info.path.normalize(fileName);
			const baseName = Info.path.basename(fileName);
			if (baseName.startsWith('Dora.')) {
				return ts.createSourceFile("dummy.d.ts", "", ts.ScriptTarget.ESNext, false);
			}
			if (baseName === 'jsx.d.ts' || baseName === 'DoraX.d.ts') {
				const uri = monaco.Uri.parse(baseName);
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return ts.createSourceFile(baseName, model.getValue(), ts.ScriptTarget.ESNext, false);
				} else {
					const res = Service.readSync({path: baseName, projFile: rootFileName});
					if (res?.success) {
						monaco.editor.createModel(res.content, 'typescript', uri);
						return ts.createSourceFile(baseName, res.content, ts.ScriptTarget.ESNext, false);
					}
				}
			}
			if (baseName === 'lib.Dora.d.ts') {
				const uri = monaco.Uri.parse("Dora.d.ts");
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return ts.createSourceFile("Dora.d.ts", model.getValue(), ts.ScriptTarget.ESNext, false);
				} else {
					const res = Service.readSync({path: "Dora.d.ts"});
					if (res?.success) {
						monaco.editor.createModel(res.content, 'typescript', uri);
						return ts.createSourceFile("Dora.d.ts", res.content, ts.ScriptTarget.ESNext, false);
					}
				}
			}
			const lib = monaco.languages.typescript.typescriptDefaults.getExtraLibs()[fileName];
			if (lib) {
				return ts.createSourceFile(fileName, lib.content, ts.ScriptTarget.ESNext, false);
			}
			if (!Info.path.isAbsolute(fileName) || Info.path.relative(rootFileName, fileName) === "") {
				return ts.createSourceFile(fileName, content, ts.ScriptTarget.ESNext, false);
			} else {
				const uri = pathMap.get(fileName);
				if (uri !== undefined) {
					const model = monaco.editor.getModel(uri);
					if (model !== null) {
						return ts.createSourceFile(uri.fsPath, model.getValue(), ts.ScriptTarget.ESNext, false);
					}
				}
				return undefined;
			}
		},
	};
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
			readFile: () => "",
			writeFile: () => {}
		}
	}).emit({
		program,
		writeFile: collector.writeFile
	});
	diagnostics = [...diagnostics, ...res.diagnostics].filter(d => d.code !== 2497 && d.code !== 2666);

	const otherFileDiagnostics = diagnostics.filter(d => Info.path.relative(monaco.Uri.parse(d.file?.fileName ?? "").fsPath, fileName) !== "");
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
	const getWorker = await monaco.languages.typescript.getTypeScriptWorker();
	const worker = await getWorker(model.uri);
	const diagnostics = (await Promise.all([
		worker.getSyntacticDiagnostics(model.uri.toString()),
		worker.getSemanticDiagnostics(model.uri.toString())
	])).reduce((a, it) => a.concat(it)).filter(d => d.code !== 2497 && d.code !== 2666);
	const markers = diagnostics.map(d => {
		let {start = 0, length = 0} = d;
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
	const markers = diagnostics.filter(d => Info.path.relative(monaco.Uri.parse(d.file?.fileName ?? "").fsPath, model.uri.fsPath) === "" && d.source === 'typescript-to-lua').map(d => {
		let {start = 0, length = 0} = d;
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

export function addDiagnosticToLog(fileName: string, diagnostics: readonly ts.Diagnostic[]) {
	if (diagnostics.length === 0) return;
	const message = `Compiling error: ${fileName}\n` +
		ts.formatDiagnostics(diagnostics, {
			getCanonicalFileName: fileName => Info.path.normalize(fileName),
			getCurrentDirectory: () => Info.path.dirname(fileName),
			getNewLine: () => "\n"
		});
	Service.command({code: `print [=======[${message}]=======]`, log: false});
}

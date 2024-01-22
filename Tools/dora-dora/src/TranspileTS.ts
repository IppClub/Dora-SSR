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
	moduleResolution: ts.ModuleResolutionKind.Classic,
	allowSyntheticDefaultImports: true,
	target: ts.ScriptTarget.ES2015,
	module: ts.ModuleKind.ES2015,
};

function createTypescriptProgram(rootFileName: string, content: string): ts.Program {
	const currentDirectory = Info.path.dirname(rootFileName);
	const compilerHost: ts.CompilerHost = {
		fileExists: fileName => {
			if (fileName.search("node_modules") > 0) {
				return false;
			}
			fileName = Info.path.normalize(fileName);
			const baseName = Info.path.basename(fileName).toLowerCase();
			if (baseName.startsWith('dora.')) {
				return true;
			}
			if (baseName === 'lib.dora.d.ts') {
				return true;
			}
			if (Info.path.isAbsolute(fileName)) {
				const relativePath = Info.path.relative(currentDirectory, fileName);
				if (!relativePath.startsWith('..')) {
					const ext = Info.path.extname(relativePath);
					const baseName = Info.path.basename(relativePath, ext) + ".d.ts";
					const dirName = Info.path.dirname(relativePath);
					const path = Info.path.join(dirName, baseName);
					const uri = monaco.Uri.parse(path);
					const model = monaco.editor.getModel(uri);
					if (model !== null) {
						return true;
					}
					const res = Service.readSync({path: baseName});
					if (res?.content !== undefined) {
						monaco.editor.createModel(res?.content, 'typescript', uri);
						return true;
					}
				}
			}
			const uri = monaco.Uri.parse(fileName);
			const model = monaco.editor.getModel(uri);
			if (model !== null) {
				return true;
			}
			const res = Service.readSync({path: fileName});
			if (res?.content !== undefined) {
				monaco.editor.createModel(res?.content, 'typescript', uri);
				return true;
			}
			return false;
		},
		getCanonicalFileName: fileName => Info.path.normalize(fileName),
		getCurrentDirectory: () => currentDirectory,
		getDefaultLibFileName: () => "lib.dora.d.ts",
		readFile: fileName => {
			fileName = Info.path.normalize(fileName);
			const uri = monaco.Uri.parse(fileName);
			const model = monaco.editor.getModel(uri);
			if (model !== null) {
				return model.getValue();
			}
			const content = Service.readSync({path: fileName})?.content;
			if (content !== undefined) {
				monaco.editor.createModel(content, 'typescript', uri);
			}
			return content;
		},
		getNewLine: () => "\n",
		useCaseSensitiveFileNames: () => true,
		writeFile: () => { },
		getSourceFile(fileName) {
			fileName = Info.path.normalize(fileName);
			const baseName = Info.path.basename(fileName).toLowerCase();
			if (baseName.startsWith('dora.')) {
				return ts.createSourceFile("dummy.d.ts", "", ts.ScriptTarget.ES2015, false);
			}
			if (baseName === 'jsx.d.ts' || baseName === 'dora-x.d.ts') {
				const uri = monaco.Uri.parse(baseName);
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return ts.createSourceFile(baseName, model.getValue(), ts.ScriptTarget.ES2015, false);
				} else {
					const res = Service.readSync({path: baseName});
					if (res?.content !== undefined) {
						monaco.editor.createModel(res.content, 'typescript', uri);
						return ts.createSourceFile(baseName, res.content, ts.ScriptTarget.ES2015, false);
					}
				}
			}
			if (baseName === 'lib.dora.d.ts') {
				const uri = monaco.Uri.parse("dora.d.ts");
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return ts.createSourceFile("dora.d.ts", model.getValue(), ts.ScriptTarget.ES2015, false);
				} else {
					const res = Service.readSync({path: "dora.d.ts"});
					if (res?.content !== undefined) {
						monaco.editor.createModel(res.content, 'typescript', uri);
						return ts.createSourceFile("dora.d.ts", res.content, ts.ScriptTarget.ES2015, false);
					}
				}
			}
			if (Info.path.isAbsolute(fileName)) {
				const relativePath = Info.path.relative(currentDirectory, fileName);
				if (!relativePath.startsWith('..')) {
					const ext = Info.path.extname(relativePath);
					const baseName = Info.path.basename(relativePath, ext) + ".d.ts";
					const dirName = Info.path.dirname(relativePath);
					const path = Info.path.join(dirName, baseName);
					const uri = monaco.Uri.parse(path);
					const model = monaco.editor.getModel(uri);
					if (model !== null) {
						return ts.createSourceFile(baseName, model.getValue(), ts.ScriptTarget.ES2015, false);
					}
				}
			}
			const lib = monaco.languages.typescript.typescriptDefaults.getExtraLibs()[fileName];
			if (lib) {
				return ts.createSourceFile(fileName, lib.content, ts.ScriptTarget.ES2015, false);
			}
			if (!Info.path.isAbsolute(fileName) || Info.path.relative(rootFileName, fileName) === "") {
				return ts.createSourceFile(fileName, content, ts.ScriptTarget.ES2015, false);
			} else {
				const uri = monaco.Uri.parse(fileName);
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return ts.createSourceFile(fileName, model.getValue(), ts.ScriptTarget.ES2015, false);
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
			readFile: () => undefined,
			writeFile: () => {}
		}
	}).emit({
		program,
		writeFile: collector.writeFile
	});
	diagnostics = [...diagnostics, ...res.diagnostics].filter(d => d.code !== 2497 && d.code !== 2666);
	if (diagnostics.length > 0) {
		Service.addLog(
			(Service.getLog() !== "" ? "\n" : "") +
			`Compiling error: ${fileName}\n` +
			ts.formatDiagnostics(diagnostics, {
				getCanonicalFileName: fileName => Info.path.normalize(fileName),
				getCurrentDirectory: () => Info.path.dirname(fileName),
				getNewLine: () => "\n"
			})
		);
		Service.alert("alert.failedTS", "error");
	}
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
			return modifiedLuaCode;
		}
	}
	return undefined as string | undefined;
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
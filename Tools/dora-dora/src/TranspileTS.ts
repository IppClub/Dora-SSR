/* Copyright (c) 2023 Jin Li, dragon-fly@qq.com

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
};

function createTypescriptProgram(rootFileName: string, content: string): ts.Program {
	const currentDirectory = Info.path.dirname(rootFileName);
	const compilerHost: ts.CompilerHost = {
		fileExists: fileName => {
			if (fileName.search("node_modules") > 0) return false;
			fileName = Info.path.normalize(fileName);
			const uri = monaco.Uri.parse(fileName);
			const model = monaco.editor.getModel(uri);
			if (model !== null) {
				return true;
			}
			return Service.existSync({file: fileName})?.success ?? false
		},
		getCanonicalFileName: fileName => Info.path.normalize(fileName),
		getCurrentDirectory: () => currentDirectory,
		getDefaultLibFileName: () => "dora.d.ts",
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
			const lib = monaco.languages.typescript.typescriptDefaults.getExtraLibs()[fileName];
			if (lib) {
				return ts.createSourceFile(fileName, lib.content, ts.ScriptTarget.Latest, false);
			}
			if (Info.path.relative(rootFileName, fileName) === "") {
				return ts.createSourceFile(fileName, content, ts.ScriptTarget.Latest, false);
			} else {
				const uri = monaco.Uri.parse(fileName);
				const model = monaco.editor.getModel(uri);
				if (model !== null) {
					return ts.createSourceFile(fileName, model.getValue(), ts.ScriptTarget.Latest, false);
				}
				const res = Service.readSync({path: fileName});
				if (res?.content !== undefined) {
					monaco.editor.createModel(res?.content, 'typescript', uri);
					return ts.createSourceFile(fileName, res.content, ts.ScriptTarget.Latest, false);
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
	const collector = createEmitOutputCollector();
	new tstl.Transpiler({
		emitHost: {
			directoryExists: () => false,
			fileExists: () => false,
			getCurrentDirectory: () => Info.path.dirname(fileName),
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
			writeFile: () => {}
		}
	}).emit({
		program,
		writeFile: collector.writeFile
	});
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
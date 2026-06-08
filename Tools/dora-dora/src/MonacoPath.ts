/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import monaco, { monacoTypescript } from './monacoBase';
import Info from './Info';

export const toTypeScriptFileName = (file: string) => {
	if (file.startsWith("file:")) return file;
	return monaco.Uri.file(file).toString();
};

export const toFilePath = (fileName: string) => {
	if (!fileName.startsWith("file:")) return fileName;
	try {
		return Info.path.fromFileUrl(fileName);
	} catch {
		return monaco.Uri.parse(fileName).fsPath;
	}
};

export const getExtraLib = (fileName: string) => {
	const extraLibs = monacoTypescript.typescriptDefaults.getExtraLibs();
	const directLib = extraLibs[fileName];
	if (directLib !== undefined) return directLib;
	const filePath = toFilePath(fileName);
	const pathLib = extraLibs[filePath];
	if (pathLib !== undefined) return pathLib;
	return extraLibs[toTypeScriptFileName(filePath)];
};

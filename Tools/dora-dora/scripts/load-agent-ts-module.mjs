import {readFile} from 'node:fs/promises';
import ts from 'typescript';

export async function loadAgentTsModule(path) {
	const source = await readFile(path, 'utf8');
	const {outputText} = ts.transpileModule(source, {
		compilerOptions: {
			module: ts.ModuleKind.ES2022,
			target: ts.ScriptTarget.ES2022,
		},
		fileName: path,
		reportDiagnostics: true,
	});
	return import(`data:text/javascript;base64,${Buffer.from(outputText).toString('base64')}`);
}

import * as monaco from 'monaco-editor';
import * as yuescript from './languages/yuescript';
import * as teal from './languages/teal';
import * as Service from './Service';

monaco.editor.defineTheme("dora-dark", {
	base: "vs-dark",
	inherit: true,
	rules: [
		{
			token: "invalid",
			foreground: "f44747",
			fontStyle: 'italic',
		},
		{
			token: "self.call",
			foreground: "dcdcaa",
		},
		{
			token: "operator",
			foreground: "cc76d1",
		}
	],
	colors: {},
})
monaco.languages.register({id: 'tl'});
monaco.languages.setLanguageConfiguration("tl", teal.config);
monaco.languages.setMonarchTokensProvider("tl", teal.language);
monaco.languages.registerCompletionItemProvider("tl", {
	triggerCharacters: [".", ":"],
	provideCompletionItems: function(model, position) {
		const line: string = model.getValueInRange({
			startLineNumber: position.lineNumber,
			startColumn: 1,
			endLineNumber: position.lineNumber,
			endColumn: position.column,
		});
		const word = model.getWordUntilPosition(position);
		const range: monaco.IRange = {
			startLineNumber: position.lineNumber,
			endLineNumber: position.lineNumber,
			startColumn: word.startColumn,
			endColumn: word.endColumn,
		};
		return Service.complete({
			lang: "tl", line,
			row: position.lineNumber,
			content: model.getValue()
		}).then((res) => {
			if (!res.success) return {suggestions:[]};
			if (res.suggestions === undefined) return {suggestions:[]};
			return {
				suggestions: res.suggestions.map((item) => {
					const [name, desc, func] = item;
					return {
						label: name,
						kind: func ?
							monaco.languages.CompletionItemKind.Function :
							monaco.languages.CompletionItemKind.Variable,
						document: desc,
						detail: desc,
						insertText: name,
						range: range,
					};
				}),
			};
		});
	},
});
monaco.languages.registerHoverProvider("tl", {
	provideHover: function(model, position) {
		const word = model.getWordAtPosition(position);
		if (word === null) return {contents:[]};
		const line: string = model.getValueInRange({
			startLineNumber: position.lineNumber,
			startColumn: 1,
			endLineNumber: position.lineNumber,
			endColumn: word.endColumn,
		});
		return Service.infer({
			lang: "tl", line,
			row: position.lineNumber,
			content: model.getValue()
		}).then(function (res) {
			if (!res.success) return {contents:[]};
			if (res.infered === undefined) return {contents:[]};
			const contents = [
				{
					value: "```\n" + res.infered.desc + "\n```",
				},
			];
			if (res.infered.row !== 0 && res.infered.col !== 0) {
				if (res.infered.file === "") {
					res.infered.file = "current file";
				}
				contents.push({
					value: `${res.infered.file}:${res.infered.row}:${res.infered.col}`
				});
			}
			return {
				range: new monaco.Range(
					position.lineNumber,
					word.startColumn,
					position.lineNumber,
					word.endColumn
				),
				contents,
			};
		});
	},
});

monaco.languages.register({ id: 'yue' });
monaco.languages.setLanguageConfiguration("yue", yuescript.config);
monaco.languages.setMonarchTokensProvider("yue", yuescript.language);
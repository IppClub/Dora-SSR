import * as monaco from 'monaco-editor';
import * as yuescript from './languages/yuescript';
import * as teal from './languages/teal';
import * as lua from './languages/lua';
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

type DoraLang = "tl" | "lua" | "yue";
const completionItemProvider = (triggerCharacters: string[], lang: DoraLang) => {
	return {
		triggerCharacters,
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
				lang, line,
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
	} as monaco.languages.CompletionItemProvider;
};

const hoverProvider = (lang: DoraLang) => {
	return {
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
				lang, line,
				row: position.lineNumber,
				content: model.getValue()
			}).then(function (res) {
				if (!res.success) return {contents:[]};
				if (res.infered === undefined) return {contents:[]};
				const polyText = "polymorphic function (with types ";
				let desc = res.infered.desc;
				if (desc.startsWith(polyText)) {
					desc = desc.substring(polyText.length);
					desc = desc.substring(0, desc.length - 1);
					desc = "polymorphic:\n" + desc.split(" and ").join("\n")
					res.infered.desc = desc;
				}
				const contents = [
					{
						value: "```tl\n" + res.infered.desc + "\n```",
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
	} as monaco.languages.HoverProvider;
};

monaco.languages.register({id: 'tl'});
monaco.languages.setLanguageConfiguration("tl", teal.config);
monaco.languages.setMonarchTokensProvider("tl", teal.language);
const tlComplete = completionItemProvider([".", ":"], "tl");
monaco.languages.registerCompletionItemProvider("tl", tlComplete);
monaco.languages.registerHoverProvider("tl", hoverProvider("tl"));

const luaComplete = completionItemProvider([".", ":"], "lua");
monaco.languages.setLanguageConfiguration("lua", lua.config);
monaco.languages.setMonarchTokensProvider("lua", lua.language);
monaco.languages.registerCompletionItemProvider("lua", luaComplete);
monaco.languages.registerHoverProvider("lua", hoverProvider("lua"));

monaco.languages.register({id: 'yue'});
monaco.languages.setLanguageConfiguration("yue", yuescript.config);
monaco.languages.setMonarchTokensProvider("yue", yuescript.language);
const yueComplete = completionItemProvider([".", "::", "\\"], "yue");
monaco.languages.registerCompletionItemProvider("yue", yueComplete);
monaco.languages.registerHoverProvider("yue", hoverProvider("yue"));

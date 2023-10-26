import * as monaco from 'monaco-editor';
import * as yuescript from './languages/yuescript';
import * as teal from './languages/teal';
import * as lua from './languages/lua';
import * as Service from './Service';
import Info from './Info';

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
		},
		{
			token: "comment",
			foreground: "8bb66f",
		}
	],
	colors: {},
})

type CompleteLang = "tl" | "lua" | "yue" | "xml";
const completionItemProvider = (triggerCharacters: string[], lang: CompleteLang) => {
	return {
		triggerCharacters,
		provideCompletionItems: function(model, position, context) {
			const line: string = model.getValueInRange({
				startLineNumber: position.lineNumber,
				startColumn: 1,
				endLineNumber: position.lineNumber,
				endColumn: position.column,
			});
			switch (context.triggerCharacter) {
				case "\"": case "'": case "/":
					let available = line.match(/\brequire\b/) !== null;
					if (lang === "yue") {
						available = available || line.match(/\bimport\b/) !== null;
					}
					available = available || line.match(/\bSprite\b/) !== null;
					if (!available) {
						return {suggestions:[]};
					}
					break;
			}
			const word = model.getWordUntilPosition(position);
			const range: monaco.IRange = {
				startLineNumber: position.lineNumber,
				endLineNumber: position.lineNumber,
				startColumn: word.startColumn,
				endColumn: word.endColumn,
			};
			let content: string;
			if (lang === "yue") {
				if (position.lineNumber > 1) {
					content = model.getValueInRange({
						startLineNumber: 1,
						startColumn: 1,
						endLineNumber: position.lineNumber - 1,
						endColumn: model.getLineLastNonWhitespaceColumn(position.lineNumber - 1),
					});
				} else {
					content = "";
				}
				content += "\n" + "\t".repeat(Math.max(0, model.getLineFirstNonWhitespaceColumn(position.lineNumber) - 1)) + "print()\n" + model.getValueInRange({
					startLineNumber: position.lineNumber + 1,
					startColumn: 1,
					endLineNumber: model.getLineCount(),
					endColumn: model.getLineLastNonWhitespaceColumn(model.getLineCount()),
				});
			} else if (lang === "xml") {
				content = model.getValueInRange({
					startLineNumber: 1,
					startColumn: 1,
					endLineNumber: position.lineNumber,
					endColumn: position.column,
				});
			} else {
				content = model.getValue();
			}
			return Service.complete({
				lang, line,
				file: model.uri.path,
				row: position.lineNumber,
				content
			}).then((res) => {
				if (!res.success) return {suggestions:[]};
				if (res.suggestions === undefined) return {suggestions:[]};
				return {
					suggestions: res.suggestions.map((item) => {
						const [label, desc, itemType] = item;
						let kind = monaco.languages.CompletionItemKind.Variable;
						switch (itemType) {
							case "variable": kind = monaco.languages.CompletionItemKind.Variable; break;
							case "function": kind = monaco.languages.CompletionItemKind.Function; break;
							case "method": kind = monaco.languages.CompletionItemKind.Method; break;
							case "field": kind = monaco.languages.CompletionItemKind.Field; break;
							case "keyword": kind = monaco.languages.CompletionItemKind.Keyword; break;
						}
						if (lang === "xml") {
							return {
								label,
								kind,
								insertText: desc,
								insertTextRules:
				monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
								range: range,
							};
						}
						return {
							label,
							kind,
							document: desc,
							detail: desc,
							insertText: label,
							range: range,
						};
					}),
				};
			}).catch((reason) => {
				console.error(`failed to complete codes, due to: ${reason}`);
			});
		},
	} as monaco.languages.CompletionItemProvider;
};

type InferLang = "tl" | "lua" | "yue";
const hoverProvider = (lang: InferLang) => {
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
				file: model.uri.path,
				row: position.lineNumber,
				content: model.getValue()
			}).then(function (res) {
				if (!res.success) return {contents:[]};
				if (res.infered === undefined) return {contents:[]};
				const polyText = "polymorphic function (with types ";
				let desc = res.infered.desc;
				if (desc === "<invalid type>" || desc === "<unknown type>") return {contents:[]};
				if (desc.startsWith(polyText)) {
					desc = desc.substring(polyText.length);
					desc = desc.substring(0, desc.length - 1);
					const tag = Info.locale.match(/^zh/) ? "多重定义" : "Polymorphic";
					desc = tag + ":\n" + desc.split(" and ").join("\n")
					res.infered.desc = desc;
				}
				const contents = [
					{
						value: "```tl\n" + res.infered.desc + "\n```",
					},
				];
				if (res.infered.doc !== undefined) {
					contents.push({
						value: res.infered.doc,
					});
				}
				if (res.infered.row !== 0 && res.infered.col !== 0) {
					if (res.infered.file === "") {
						res.infered.file = "current file";
					}
					contents.push({
						value: `${res.infered.file}:${res.infered.row}:${res.infered.col}`
					});
				} else {
					contents.push({
						value: "Lua built-in",
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
			}).catch((reason) => {
				console.error(`failed to infer codes, due to: ${reason}`);
			});
		},
	} as monaco.languages.HoverProvider;
};

type SignatureLang = "tl" | "lua" | "yue";
const signatureHelpProvider = (signatureHelpTriggerCharacters: string[], lang: SignatureLang) => {
	return {
		signatureHelpTriggerCharacters,
		provideSignatureHelp(model, position, token, context) {
			let activeSignature = context.activeSignatureHelp?.activeSignature ?? 0;
			let activeParameter = 0;
			const currentLine: string = model.getValueInRange({
				startLineNumber: position.lineNumber,
				startColumn: 1,
				endLineNumber: position.lineNumber,
				endColumn: position.column,
			});
			let newLine = currentLine;
			while (true) {
				const tmp = newLine.replace(/\([^()]*\)/g,"");
				if (tmp === newLine) {
					break;
				} else {
					newLine = tmp;
				}
			}
			let line = newLine;
			let content = "";
			switch (lang) {
				case "lua":
				case "tl": {
					const index = newLine.lastIndexOf("(");
					line = newLine.substring(0, index);
					if (index >= 0) {
						for (let i = index; i < newLine.length; i++) {
							if (newLine.at(i) === ",") {
								activeParameter++;
							}
						}
					}
					content = model.getValue();
					break;
				}
				case "yue": {
					newLine = newLine.replace(/\s*,\s*/g, ",");
					let index = Math.max(newLine.lastIndexOf(" "), newLine.lastIndexOf("("));
					line = newLine.substring(0, index);
					if (index >= 0) {
						for (let i = index; i < newLine.length; i++) {
							if (newLine.at(i) === ",") {
								activeParameter++;
							}
						}
					}
					if (position.lineNumber > 1) {
						content = model.getValueInRange({
							startLineNumber: 1,
							startColumn: 1,
							endLineNumber: position.lineNumber - 1,
							endColumn: model.getLineLastNonWhitespaceColumn(position.lineNumber - 1),
						});
					} else {
						content = "";
					}
					content += "\n" + "\t".repeat(Math.max(0, model.getLineFirstNonWhitespaceColumn(position.lineNumber) - 1)) + "print()\n" + model.getValueInRange({
						startLineNumber: position.lineNumber + 1,
						startColumn: 1,
						endLineNumber: model.getLineCount(),
						endColumn: model.getLineLastNonWhitespaceColumn(model.getLineCount()),
					});
					break;
				}
			}
			return Service.signature({
				lang, line,
				file: model.uri.path,
				row: position.lineNumber,
				content
			}).then((res)=> {
				if (!res.success) return null;
				if (res.signatures === undefined) return null;
				const signatures = res.signatures.map(s => {
					return {
						label: s.desc,
						documentation: {
							value: s.doc
						},
						parameters: (s.params ?? []).map(p => {
							return {
								label: p.name,
								documentation: {
									value: p.desc
								}
							};
						})
					};
				});
				if (activeSignature >= signatures.length || signatures[activeSignature].label !== context.activeSignatureHelp?.signatures[activeSignature].label) {
					activeSignature = 0;
				}
				if (signatures[activeSignature].parameters.length <= activeParameter) {
					for (let i = 0; i < signatures.length; i++) {
						if (signatures[i].parameters.length > activeParameter) {
							activeSignature = i;
							break;
						}
					}
				}
				return {
					dispose: () => {},
					value: {
						signatures,
						activeSignature,
						activeParameter,
					}
				};
			});
		},
	} as monaco.languages.SignatureHelpProvider;
};

const codeActionProvider = {
	resolveCodeAction(codeAction, token) {
		console.log(codeAction, token);
		return undefined;
	},
	provideCodeActions(model, range, context) {
		if (context.only !== "quickfix") {
			return undefined;
		}
		const marker = context.markers.find(m => {
			return m.message.startsWith("unknown variable:");
		});
		if (marker === undefined) {
			return undefined;
		}
		const moduleName = marker.message.replace("unknown variable: ", "");
		const message = Info.locale.match(/^zh/) ? "导入模块" : "Require";
		return {
			actions: [
				{
					title: `${message} ${moduleName}`,
					edit: {
						edits: [
							{
								resource: model.uri,
								textEdit: {
									text: `local ${moduleName} <const> = require("${moduleName}")\n`,
									range: {
										startLineNumber: 1,
										startColumn: 0,
										endLineNumber: 1,
										endColumn: 0
									}
								},
							}
						]
					},
					isPreferred: true,
					kind: "quickfix"
				}
			],
			dispose() { },
		} as monaco.languages.CodeActionList;
	},
} as monaco.languages.CodeActionProvider;

monaco.languages.register({id: 'tl'});
monaco.languages.setLanguageConfiguration("tl", teal.config);
monaco.languages.setMonarchTokensProvider("tl", teal.language);
const tlComplete = completionItemProvider([".", ":", "\"", "'", "/"], "tl");
monaco.languages.registerCompletionItemProvider("tl", tlComplete);
monaco.languages.registerHoverProvider("tl", hoverProvider("tl"));
monaco.languages.registerSignatureHelpProvider("tl", signatureHelpProvider(["(", ","], "tl"));
monaco.languages.registerCodeActionProvider("tl", codeActionProvider)

const luaComplete = completionItemProvider([".", ":", "\"", "'", "/"], "lua");
monaco.languages.setLanguageConfiguration("lua", lua.config);
monaco.languages.setMonarchTokensProvider("lua", lua.language);
monaco.languages.registerCompletionItemProvider("lua", luaComplete);
monaco.languages.registerHoverProvider("lua", hoverProvider("lua"));
monaco.languages.registerSignatureHelpProvider("lua", signatureHelpProvider(["(", ","], "lua"));

monaco.languages.register({id: 'yue'});
monaco.languages.setLanguageConfiguration("yue", yuescript.config);
monaco.languages.setMonarchTokensProvider("yue", yuescript.language);
const yueComplete = completionItemProvider([".", "::", "\\", "/", "\"", "'"], "yue");
monaco.languages.registerCompletionItemProvider("yue", yueComplete);
monaco.languages.registerHoverProvider("yue", hoverProvider("yue"));
monaco.languages.registerSignatureHelpProvider("yue", signatureHelpProvider(["(", ",", " "], "yue"));

const xmlComplete = completionItemProvider([">", "<", "/", " ", "\t", "=", "\n"], "xml");
monaco.languages.registerCompletionItemProvider("xml", xmlComplete);

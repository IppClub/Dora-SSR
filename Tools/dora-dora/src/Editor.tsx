/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import monaco, { monacoTypescript } from './monacoBase';
import * as yuescript from './languages/yuescript';
import * as teal from './languages/teal';
import * as lua from './languages/lua';
import * as Service from './Service';
import Info from './Info';
import * as wa from './languages/wa';
import * as yarn from './languages/yarn';

Service.addUpdateTSCodeListener((file, code) => {
	const model = monaco.editor.getModel(monaco.Uri.file(file));
	if (model) {
		model.setValue(code);
	} else {
		monaco.editor.createModel(code, "typescript", monaco.Uri.file(file));
	}
});

const options = monacoTypescript.typescriptDefaults.getCompilerOptions();
options.noLib = true;
options.strict = true;
options.jsx = monacoTypescript.JsxEmit.React;
options.target = monacoTypescript.ScriptTarget.ESNext;
options.module = monacoTypescript.ModuleKind.ESNext;
options.moduleResolution = monacoTypescript.ModuleResolutionKind.Classic;
monacoTypescript.typescriptDefaults.setCompilerOptions(options);

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
	colors: {
		"actionBar.toggledBackground": "#383a49",
		"activityBar.activeBorder": "#0078d4",
		"activityBar.background": "#181818",
		"activityBar.border": "#2b2b2b",
		"activityBar.foreground": "#d7d7d7",
		"activityBar.inactiveForeground": "#868686",
		"activityBarBadge.background": "#0078d4",
		"activityBarBadge.foreground": "#ffffff",
		"badge.background": "#616161",
		"badge.foreground": "#f8f8f8",
		"button.background": "#0078d4",
		"button.border": "#ffffff12",
		"button.foreground": "#ffffff",
		"button.hoverBackground": "#026ec1",
		"button.secondaryBackground": "#313131",
		"button.secondaryForeground": "#cccccc",
		"button.secondaryHoverBackground": "#3c3c3c",
		"chat.slashCommandBackground": "#34414b",
		"chat.slashCommandForeground": "#40a6ff",
		"checkbox.background": "#313131",
		"checkbox.border": "#3c3c3c",
		"debugToolBar.background": "#181818",
		"descriptionForeground": "#9d9d9d",
		"dropdown.background": "#313131",
		"dropdown.border": "#3c3c3c",
		"dropdown.foreground": "#cccccc",
		"dropdown.listBackground": "#1f1f1f",
		"editor.background": "#1f1f1f",
		"editor.findMatchBackground": "#9e6a03",
		"editor.foreground": "#cccccc",
		"editor.inactiveSelectionBackground": "#3a3d41",
		"editor.selectionHighlightBackground": "#add6ff26",
		"editorGroup.border": "#ffffff17",
		"editorGroupHeader.tabsBackground": "#181818",
		"editorGroupHeader.tabsBorder": "#2b2b2b",
		"editorGutter.addedBackground": "#2ea043",
		"editorGutter.deletedBackground": "#f85149",
		"editorGutter.modifiedBackground": "#0078d4",
		"editorIndentGuide.activeBackground1": "#707070",
		"editorIndentGuide.background1": "#404040",
		"editorLineNumber.activeForeground": "#cccccc",
		"editorLineNumber.foreground": "#6e7681",
		"editorOverviewRuler.border": "#010409",
		"editorWidget.background": "#202020",
		"errorForeground": "#f85149",
		"focusBorder": "#0078d4",
		"foreground": "#cccccc",
		"icon.foreground": "#cccccc",
		"input.background": "#313131",
		"input.border": "#3c3c3c",
		"input.foreground": "#cccccc",
		"input.placeholderForeground": "#989898",
		"inputOption.activeBackground": "#2489db82",
		"inputOption.activeBorder": "#2488db",
		"keybindingLabel.foreground": "#cccccc",
		"list.activeSelectionIconForeground": "#ffffff",
		"list.dropBackground": "#383b3d",
		"menu.background": "#1f1f1f",
		"menu.border": "#454545",
		"menu.foreground": "#cccccc",
		"menu.selectionBackground": "#0078d4",
		"menu.separatorBackground": "#454545",
		"notificationCenterHeader.background": "#1f1f1f",
		"notificationCenterHeader.foreground": "#cccccc",
		"notifications.background": "#1f1f1f",
		"notifications.border": "#2b2b2b",
		"notifications.foreground": "#cccccc",
		"panel.background": "#181818",
		"panel.border": "#2b2b2b",
		"panelInput.border": "#2b2b2b",
		"panelTitle.activeBorder": "#0078d4",
		"panelTitle.activeForeground": "#cccccc",
		"panelTitle.inactiveForeground": "#9d9d9d",
		"peekViewEditor.background": "#1f1f1f",
		"peekViewEditor.matchHighlightBackground": "#bb800966",
		"peekViewResult.background": "#1f1f1f",
		"peekViewResult.matchHighlightBackground": "#bb800966",
		"pickerGroup.border": "#3c3c3c",
		"ports.iconRunningProcessForeground": "#369432",
		"progressBar.background": "#0078d4",
		"quickInput.background": "#222222",
		"quickInput.foreground": "#cccccc",
		"settings.dropdownBackground": "#313131",
		"settings.dropdownBorder": "#3c3c3c",
		"settings.headerForeground": "#ffffff",
		"settings.modifiedItemIndicator": "#bb800966",
		"sideBar.background": "#181818",
		"sideBar.border": "#2b2b2b",
		"sideBar.foreground": "#cccccc",
		"sideBarSectionHeader.background": "#181818",
		"sideBarSectionHeader.border": "#2b2b2b",
		"sideBarSectionHeader.foreground": "#cccccc",
		"sideBarTitle.foreground": "#cccccc",
		"statusBar.background": "#181818",
		"statusBar.border": "#2b2b2b",
		"statusBar.debuggingBackground": "#0078d4",
		"statusBar.debuggingForeground": "#ffffff",
		"statusBar.focusBorder": "#0078d4",
		"statusBar.foreground": "#cccccc",
		"statusBar.noFolderBackground": "#1f1f1f",
		"statusBarItem.focusBorder": "#0078d4",
		"statusBarItem.prominentBackground": "#6e768166",
		"statusBarItem.remoteBackground": "#0078d4",
		"statusBarItem.remoteForeground": "#ffffff",
		"tab.activeBackground": "#1f1f1f",
		"tab.activeBorder": "#1f1f1f",
		"tab.activeBorderTop": "#0078d4",
		"tab.activeForeground": "#ffffff",
		"tab.border": "#2b2b2b",
		"tab.hoverBackground": "#1f1f1f",
		"tab.inactiveBackground": "#181818",
		"tab.inactiveForeground": "#9d9d9d",
		"tab.lastPinnedBorder": "#cccccc33",
		"tab.selectedBackground": "#222222",
		"tab.selectedBorderTop": "#6caddf",
		"tab.selectedForeground": "#ffffffa0",
		"tab.unfocusedActiveBorder": "#1f1f1f",
		"tab.unfocusedActiveBorderTop": "#2b2b2b",
		"tab.unfocusedHoverBackground": "#1f1f1f",
		"terminal.foreground": "#cccccc",
		"terminal.inactiveSelectionBackground": "#3a3d41",
		"terminal.tab.activeBorder": "#0078d4",
		"textBlockQuote.background": "#2b2b2b",
		"textBlockQuote.border": "#616161",
		"textCodeBlock.background": "#2b2b2b",
		"textLink.activeForeground": "#4daafc",
		"textLink.foreground": "#4daafc",
		"textPreformat.background": "#3c3c3c",
		"textPreformat.foreground": "#d0d0d0",
		"textSeparator.foreground": "#21262d",
		"titleBar.activeBackground": "#181818",
		"titleBar.activeForeground": "#cccccc",
		"titleBar.border": "#2b2b2b",
		"titleBar.inactiveBackground": "#1f1f1f",
		"titleBar.inactiveForeground": "#9d9d9d",
		"welcomePage.progress.foreground": "#0078d4",
		"welcomePage.tileBackground": "#2b2b2b",
		"widget.border": "#313131",
	},
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
				case "\"": case "'": case "/": {
					let available = line.match(/\brequire\b/) !== null;
					if (lang === "yue") {
						available = available || line.match(/\bimport\b/) !== null;
					}
					available = available || line.match(/\bSprite\b/) !== null;
					available = available || line.match(/\bLabel\b/) !== null;
					if (!available) {
						return {suggestions:[]};
					}
					break;
				}
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
				let whiteSpace = "";
				const start = model.getLineFirstNonWhitespaceColumn(position.lineNumber);
				if (start > 0) {
					whiteSpace = model.getValueInRange({
						startLineNumber: position.lineNumber,
						startColumn: 1,
						endLineNumber: position.lineNumber,
						endColumn: start,
					});
				}
				if (line.match(/\W[.\\]$/g)) {
					content += "\n" + whiteSpace + ".___DUMMY_CALL___()\n";
				} else {
					content += "\n" + whiteSpace + "print()\n";
				}
				content += model.getValueInRange({
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
		provideSignatureHelp(model, position, _token, context) {
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
					const index = Math.max(newLine.lastIndexOf(" "), newLine.lastIndexOf("("));
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
					let whiteSpace = "";
					const start = model.getLineFirstNonWhitespaceColumn(position.lineNumber);
					if (start > 0) {
						whiteSpace = model.getValueInRange({
							startLineNumber: position.lineNumber,
							startColumn: 1,
							endLineNumber: position.lineNumber,
							endColumn: start,
						});
					}
					if (line.match(/\W[.\\][^.\\]+$/g)) {
						content += "\n" + whiteSpace + ".___DUMMY_CALL___()\n";
					} else {
						content += "\n" + whiteSpace + "print()\n";
					}
					content += model.getValueInRange({
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
	provideCodeActions(model, _range, context) {
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

monaco.languages.register({ id: 'lua' });
const luaComplete = completionItemProvider([".", ":", "\"", "'", "/"], "lua");
monaco.languages.setLanguageConfiguration("lua", lua.config);
monaco.languages.setMonarchTokensProvider("lua", lua.language);
monaco.languages.registerCompletionItemProvider("lua", luaComplete);
monaco.languages.registerHoverProvider("lua", hoverProvider("lua"));
monaco.languages.registerSignatureHelpProvider("lua", signatureHelpProvider(["(", ","], "lua"));

monaco.languages.register({id: 'yue'});
monaco.languages.setLanguageConfiguration("yue", yuescript.config);
monaco.languages.setMonarchTokensProvider("yue", yuescript.language);
const yueComplete = completionItemProvider([".", "\\", "/", "\"", "'"], "yue");
monaco.languages.registerCompletionItemProvider("yue", yueComplete);
monaco.languages.registerHoverProvider("yue", hoverProvider("yue"));
monaco.languages.registerSignatureHelpProvider("yue", signatureHelpProvider(["(", ",", " "], "yue"));

const xmlComplete = completionItemProvider([">", "<", "/", " ", "\t", "=", "\n"], "xml");
monaco.languages.registerCompletionItemProvider("xml", xmlComplete);

monaco.editor.onDidCreateEditor(newEditor => {
	newEditor.onDidChangeModel(() => {
		newEditor.updateOptions({
			readOnly: true
		});
	});
});

monaco.languages.register({ id: 'wa' });
monaco.languages.setLanguageConfiguration('wa', wa.langConfig);
monaco.languages.setMonarchTokensProvider('wa', wa.language);

monaco.languages.register({ id: 'yarn' });
monaco.languages.setLanguageConfiguration('yarn', yarn.config);
monaco.languages.setMonarchTokensProvider('yarn', yarn.language);

export const EditorTheme = 'dora-dark';

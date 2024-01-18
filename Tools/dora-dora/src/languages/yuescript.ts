/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

/* eslint-disable no-useless-escape */
import { languages } from 'monaco-editor';

export const config: languages.LanguageConfiguration = {
	comments: {
		blockComment: ['--[[', ']]'],
		lineComment: '--'
	},
	brackets: [
		['{', '}'],
		['[', ']'],
		['(', ')']
	],
	autoClosingPairs: [
		{ open: '{', close: '}' },
		{ open: '[', close: ']' },
		{ open: '(', close: ')' },
		{ open: '"', close: '"' },
		{ open: "'", close: "'" }
	],
	surroundingPairs: [
		{ open: '{', close: '}' },
		{ open: '[', close: ']' },
		{ open: '(', close: ')' },
		{ open: '"', close: '"' },
		{ open: "'", close: "'" }
	],
	folding: {
		markers: {
			start: new RegExp('^\\s*#region\\b'),
			end: new RegExp('^\\s*#endregion\\b')
		}
	}
};

export const language: languages.IMonarchLanguage = {
	defaultToken: '',
	ignoreCase: false,
	tokenPostfix: '.yue',

	brackets: [
		{ open: '{', close: '}', token: 'delimiter.curly' },
		{ open: '[', close: ']', token: 'delimiter.square' },
		{ open: '(', close: ')', token: 'delimiter.parenthesis' }
	],

	keywords: [
		"and",
		"break",
		"do",
		"else",
		"elseif",
		"false",
		"for",
		"goto",
		"if",
		"in",
		"local",
		"nil",
		"not",
		"or",
		"repeat",
		"return",
		"then",
		"true",
		"until",
		"while",
		"as",
		"class",
		"continue",
		"export",
		"extends",
		"from",
		"global",
		"import",
		"macro",
		"switch",
		"try",
		"unless",
		"using",
		"when",
		"with",
	],

	builtins: [
		"assert",
		"collectgarbage",
		"dofile",
		"error",
		"next",
		"print",
		"rawget",
		"rawset",
		"tonumber",
		"tostring",
		"type",
		"_ENV",
		"_VERSION",
		"_G",
		"getfenv",
		"getmetatable",
		"ipairs",
		"loadfile",
		"loadstring",
		"pairs",
		"pcall",
		"rawequal",
		"require",
		"setfenv",
		"setmetatable",
		"unpack",
		"xpcall",
		"load",
		"module",
		"select",
		"package.cpath",
		"package.loaded",
		"package.loadlib",
		"package.path",
		"package.preload",
		"package.seeall",
		"package",
		"coroutine.running",
		"coroutine.create",
		"coroutine.resume",
		"coroutine.status",
		"coroutine.wrap",
		"coroutine.yield",
		"coroutine",
		"string.byte",
		"string.char",
		"string.dump",
		"string.find",
		"string.len",
		"string.lower",
		"string.rep",
		"string.sub",
		"string.upper",
		"string.format",
		"string.gsub",
		"string.gmatch",
		"string.match",
		"string.reverse",
		"string",
		"table.maxn",
		"table.concat",
		"table.sort",
		"table.insert",
		"table.remove",
		"table",
		"math.abs",
		"math.acos",
		"math.asin",
		"math.atan",
		"math.atan2",
		"math.ceil",
		"math.sin",
		"math.cos",
		"math.tan",
		"math.deg",
		"math.exp",
		"math.floor",
		"math.log",
		"math.log10",
		"math.max",
		"math.min",
		"math.fmod",
		"math.modf",
		"math.cosh",
		"math.sinh",
		"math.tanh",
		"math.pow",
		"math.rad",
		"math.sqrt",
		"math.frexp",
		"math.ldexp",
		"math.random",
		"math.randomseed",
		"math.pi",
		"math",
		"io.stdin",
		"io.stdout",
		"io.stderr",
		"io.close",
		"io.flush",
		"io.input",
		"io.lines",
		"io.open",
		"io.output",
		"io.popen",
		"io.read",
		"io.tmpfile",
		"io.type",
		"io.write",
		"io",
		"os.clock",
		"os.date",
		"os.difftime",
		"os.execute",
		"os.exit",
		"os.getenv",
		"os.remove",
		"os.rename",
		"os.setlocale",
		"os.time",
		"os.tmpname",
		"os",
		"debug.debug",
		"debug.gethook",
		"debug.getinfo",
		"debug.getlocal",
		"debug.getupvalue",
		"debug.setlocal",
		"debug.setupvalue",
		"debug.sethook",
		"debug.traceback",
		"debug.getfenv",
		"debug.getmetatable",
		"debug.getregistry",
		"debug.setfenv",
		"debug.setmetatable",
		"debug",
	],

	invalid: [
		"function",
		"end",
	],

	// we include these common regular expressions
	symbols: /==|~=|!=|=>|<=|[><!~?&%|+\-*\/\^\.\:@]=?/,
	escapes: /\\(?:[abfnrtv\\"'$]|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,

	// The main tokenizer for our languages
	tokenizer: {
		root: [
			// identifiers and keywords
			[
				/[a-z_$][\w\.$]*/,
				{
					cases: {
						self: 'variable.predefined',
						'@builtins': 'self.call',
						'@keywords': { token: 'keyword.$0' },
						'@invalid': 'invalid',
						'@default': '',
					}
				}
			],
			[/[A-Z][\w\$]*/, 'type.identifier'], // to show class names nicely

			// whitespace
			{ include: '@whitespace' },

			// delimiters
			[
				/}/,
				{
					cases: {
						'$S2==interpolatedstring': {
							token: 'string',
							next: '@pop'
						},
						'@default': '@brackets'
					}
				}
			],
			[/\\[\w]+/, 'self.call'],
			[/[{}()\[\]]/, '@brackets'],
			[/@symbols/, 'operator'],

			// numbers
			[/\d[\d_]*[eE]([\-+]?\d[\d_]*)?/, 'number.float'],
			[/\d[\d_]*\.\d[\d_]*([eE][\-+]?\d[\d_]*)?/, 'number.float'],
			[/0[xX][0-9a-fA-F][0-9a-fA-F_]*/, 'number.hex'],
			[/\d[\d_]*/, 'number'],

			// delimiter: after number because of .\d floats
			[/[,.]/, 'delimiter'],

			// strings:
			[
				/"/,
				{
					cases: {
						'@default': { token: 'string', next: '@string."' }
					}
				}
			],
			[
				/'/,
				{
					cases: {
						'@eos': 'string',
						'@default': { token: 'string', next: "@string.'" }
					}
				}
			]
		],

		string: [
			[/[^"'\#]+/, 'string'],
			[/@escapes/, 'string.escape'],
			[/\./, 'string.escape.invalid'],
			[/\./, 'string.escape.invalid'],

			[
				/#{/,
				{
					cases: {
						'$S2=="': {
							token: 'string',
							next: 'root.interpolatedstring'
						},
						'@default': 'string'
					}
				}
			],

			[
				/["']/,
				{
					cases: {
						'$#==$S2': { token: 'string', next: '@pop' },
						'@default': 'string'
					}
				}
			],
			[/#/, 'string']
		],

		whitespace: [
			[/[ \t\r\n]+/, ''],
			[/\[([=]*)\[/, 'comment', '@comment.$1'],
			[/--\[\[/, 'comment', '@comment.$1'],
			[/--.*$/, 'comment']
		],

		comment: [
			[/[^\]]+/, 'comment'],
			[
				/\]([=]*)\]/,
				{
					cases: {
						'$1==$S2': { token: 'comment', next: '@pop' },
						'@default': 'comment'
					}
				}
			],
			[/./, 'comment']
		],
	}
};
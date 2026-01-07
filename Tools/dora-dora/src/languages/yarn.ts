/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

/* eslint-disable no-useless-escape */
import { languages } from 'monaco-editor';

export const config: languages.LanguageConfiguration = {
	comments: {
		lineComment: '//',
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
		{ open: '"', close: '"' }
	],
	surroundingPairs: [
		{ open: '{', close: '}' },
		{ open: '[', close: ']' },
		{ open: '(', close: ')' },
		{ open: '"', close: '"' }
	]
};

export const language: languages.IMonarchLanguage = {
	defaultToken: '',
	tokenPostfix: '.yarn',

	keywords: [
		'title',
		'tags',
		'position',
		'colorID'
	],

	brackets: [
		{ token: 'delimiter.bracket', open: '{', close: '}' },
		{ token: 'delimiter.array', open: '[', close: ']' },
		{ token: 'delimiter.parenthesis', open: '(', close: ')' }
	],

	operators: [
		'==',
		'!=',
		'<=',
		'>=',
		'<',
		'>',
		'+',
		'-',
		'*',
		'/',
		'%',
		'=',
		'!'
	],

	symbols: /[><!~?:&|+\-*\/\^%\.]+/,
	escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,

	// The main tokenizer for our languages
	tokenizer: {
		root: [
			// YarnSpinner node header
			[/^title:\s*/, 'keyword', '@nodeHeader'],
			[/^tags:\s*/, 'keyword', '@nodeHeader'],
			[/^position:\s*/, 'keyword', '@nodeHeader'],
			[/^colorID:\s*/, 'keyword', '@nodeHeader'],
			[/^---\s*$/, 'delimiter'],
			[/^===\s*$/, 'delimiter'],

			// YarnSpinner commands
			[/<<(\w+)/, { token: 'keyword.control', next: '@command' }],

			// Shortcut commands
			[/\[\[/, 'keyword.control', '@shortcut'],
			[/->/, 'operator'],

			// Variables
			[/\$[a-zA-Z_][\w\$]*/, 'variable'],

			// identifiers
			[/[a-zA-Z_][\w\$]*/, 'identifier'],

			// whitespace
			{ include: '@whitespace' },

			// delimiters and operators
			[/[{}()\[\]]/, '@brackets'],
			[
				/@symbols/,
				{
					cases: {
						'@operators': 'operator',
						'@default': ''
					}
				}
			],

			// numbers
			[/\d*\.\d+([eE][\-+]?\d+)?/, 'number.float'],
			[/0[xX][0-9a-fA-F_]*[0-9a-fA-F]/, 'number.hex'],
			[/\d+?/, 'number'],

			// delimiter: after number because of .\d floats
			[/[;,.]/, 'delimiter'],

			// strings: recover on non-terminated strings
			[/"([^"\\]|\\.)*$/, 'string.invalid'], // non-teminated string
			[/"/, 'string', '@string."']
		],

		nodeHeader: [
			[/\S+/, 'string', '@pop']
		],

		command: [
			[/\w+/, 'keyword.control'],
			[/[^>]+/, 'string'],
			[/>>/, { token: 'keyword.control', next: '@pop' }]
		],

		shortcut: [
			[/[^\]]+/, 'string'],
			[/\]\]/, { token: 'keyword.control', next: '@pop' }]
		],

		whitespace: [
			[/[ \t\r\n]+/, ''],
			[/\/\/.*$/, 'comment']
		],

		string: [
			[/[^\\"]+/, 'string'],
			[/@escapes/, 'string.escape'],
			[/\\./, 'string.escape.invalid'],
			[
				/"/,
				{
					cases: {
						'$#==$S2': { token: 'string', next: '@pop' },
						'@default': 'string'
					}
				}
			]
		]
	}
};


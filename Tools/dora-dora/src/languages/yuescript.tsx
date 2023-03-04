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

	invalid: [
		"function",
		"end",
	],

	// we include these common regular expressions
	symbols: /[><!~?&%|+\-*\/\^\.\:@]|=>|<=/,
	escapes: /\\(?:[abfnrtv\\"'$]|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,

	// The main tokenizer for our languages
	tokenizer: {
		root: [
			// identifiers and keywords
			[
				/[a-z_$][\w$]*/,
				{
					cases: {
						self: 'variable.predefined',
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
						'@eos': 'string',
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
			[/--\[([=]*)\[/, 'comment', '@comment.$1'],
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
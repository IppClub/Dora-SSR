import type * as Monaco from 'monaco-editor';

export const langConfig = {
	brackets: [
		['{', '}'],
		['[', ']'],
		['(', ')'],
	],
	autoClosingPairs: [
		{ open: '{', close: '}' },
		{ open: '[', close: ']' },
		{ open: '(', close: ')' },
		{ open: '"', close: '"', notIn: ['string', 'comment'] },
		{ open: '\'', close: '\'', notIn: ['string', 'comment'] },
	],
	surroundingPairs: [
		{ open: '{', close: '}' },
		{ open: '[', close: ']' },
		{ open: '(', close: ')' },
		{ open: '"', close: '"' },
		{ open: '\'', close: '\'' },
	],
} satisfies Monaco.languages.LanguageConfiguration;

export const language: Monaco.languages.IMonarchLanguage = {
	defaultToken: '',
	tokenPostfix: '.wa',
	ignoreCase: false,

	keywords: [
		'break','defer','import','struct','case','else','interface','switch',
		'const','for','map','type','continue','func','range','default',
		'global','if','return','make','true','false'
	],

	typeKeywords: [
		'bool','string','error','map',
		'int','int8','int16','int32','int64','i8','i16','i32','i64','rune',
		'uint','uint8','uint16','uint32','uint64','u8','u16','u32','u64','uintptr','byte',
		'float32','float64','f32','f64',
		'complex64','complex128','c64','c128'
	],

	operators: [
		'==','!=','<=','>=','<','>','+','-','*','/','%','++','--',
		'!','&&','||',':=','=>','=',
		'<<','>>','&','^','|'
	],

	symbols: /==|!=|<=|>=|<|>|\+\+|--|:=|=>|&&|\|\||<<|>>|[+\-*/%&^|=!]/,
	escapes: /\\(?:[nrt"'\\]|x[0-9A-Fa-f]{2}|u\{[0-9A-Fa-f]+\})/,

	tokenizer: {
		root: [
			// whitespace
			{ include: '@whitespace' },

			// comments
			[/\/\/.*$/, 'comment'],
			[/\/\*/, 'comment', '@comment'],

			// —— 函数声明 ——
			[/\bfunc\b\s*/, { token: 'keyword', next: '@functionDecl' }],

			[/\bconst\b/, 'keyword'],

			// —— 方法调用 —— （obj.method()）
			[/((?<!\.)[A-Za-z_][\w]+)(?=\s*\()/, 'self.call'],

			[/((?<!\.)[A-Z][\w]+)/, 'type.identifier'],

			[/\./, 'operator'],

			// —— 普通函数调用 —— （foo()），但排除 func foo()
			[/((?<!\bfunc\s)[A-Za-z_][\w]*)(?=\s*\()/, 'self.call'],

			// identifiers
			[/[A-Za-z_][\w]*/, {
				cases: {
					'@keywords': 'keyword',
					'@typeKeywords': 'type',
				}
			}],

			[/[A-Z][\w]*/, 'type.identifier'], // to show class names nicely

			// strings
			[/"([^"\\]|\\.)*$/, 'string.invalid'],  // non-terminated
			[/"/, { token: 'string.quote', next: '@string_double' }],
			[/'([^'\\]|\\.)*$/, 'string.invalid'],
			[/'/, { token: 'string.quote', next: '@string_single' }],

			// numbers
			[/\b0b[01_]+\b/, 'number.binary'],
			[/\b0o[0-7_]+\b/, 'number.octal'],
			[/\b0x[0-9A-Fa-f_]+\b/, 'number.hex'],
			[/\d[\d_]*(\.[\d_]*)?([eE][+-]?[\d_]+)?/, 'number.float'],
			[/\d[\d_]*/, 'number'],

			// identifiers
			[/[A-Za-z_][\w]*/, {
				cases: {
					'@default': 'identifier'
				}
			}],

			// operators
			[/@symbols/, {
				cases: {
					'@operators': 'operator',
					'@default': ''
				}
			}],

			// delimiters and brackets
			[/[{}()[\]]/, '@brackets'],
			[/[,.;]/, 'delimiter'],
		],

		// 新增函数声明子状态：匹配 func 后的函数名与参数列表
		functionDecl: [
			// 匹配函数名
			[/[a-z_][\w]*/, '', '@functionParams'],
			[/[A-Z][\w]*/, '', '@functionParams'],
			[/\(/, 'delimiter.parenthesis', '@paramList'],
			// 如果没有跟名字就直接退回 root
			['', '', '@pop']
		],

		// 解析参数列表直到遇到 { 或 =>
		functionParams: [
			// 匹配左括号
			[/\(/, 'delimiter.parenthesis', '@paramList'],
			// 其他情况直接弹出到 root
			['', '', '@pop']
		],

		// 参数列表状态：处理逗号、类型声明、默认值等
		paramList: [
			// 匹配标识符
			[/[A-Z][\w]*/, 'type.identifier'],
			[/[a-z_][\w]*\s*\./, ''],
			[/[a-z_][\w]*/, {
				cases: {
					'@typeKeywords': 'type.identifier',
					'@default': 'variable.parameter'
				}
			}],
			// 冒号类型注释
			[/:/, 'delimiter'],
			// comma
			[/,/, 'delimiter'],
			[/@symbols/, 'operator'],
			// 右括号结束
			[/\)/, 'delimiter.parenthesis', '@pop'],
			// whitespace
			[/[ \t\r\n]+/, ''],
		],

		comment: [
			[/[^*]+/, 'comment'],
			[/\*\//, 'comment', '@pop'],
			[/[/*]/, 'comment']
		],

		string_double: [
			[/[^\\"]+/, 'string'],
			[/@escapes/, 'string.escape'],
			[/\\./, 'string.escape.invalid'],
			[/"/, { token: 'string.quote', next: '@pop' }]
		],

		string_single: [
			[/[^\\']+/, 'string'],
			[/@escapes/, 'string.escape'],
			[/\\./, 'string.escape.invalid'],
			[/'/, { token: 'string.quote', next: '@pop' }]
		],

		whitespace: [
			[/[ \t\r\n]+/, 'white']
		]
	}
};

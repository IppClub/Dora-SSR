(function (Prism) {
	Prism.languages.wa = {
		'directive': {
			pattern: /(^[\t ]*)#wa:[^\r\n]*/m,
			lookbehind: true,
			greedy: true,
			alias: 'atrule',
		},
		comment: {
			pattern: /\/\*[\s\S]*?(?:\*\/|$)|(?:\/\/|#)[^\r\n]*/,
			greedy: true,
		},
		string: {
			pattern: /`[^`]*`|"(?:[^"\\\r\n]|\\[^\r\n])*"|'(?:[^'\\\r\n]|\\[^\r\n])*'/,
			greedy: true,
		},
		keyword: /\b(?:break|case|const|continue|default|defer|else|for|func|global|if|import|interface|map|package|range|return|struct|switch|type|var)\b/,
		boolean: /\b(?:false|true)\b/,
		constant: /\b(?:iota|nil)\b/,
		'class-name': /\b(?:any|bool|byte|complex(?:64|128)|double|error|f(?:32|64)|float(?:32|64)?|i(?:32|64)|int(?:8|16|32|64)?|rune|string|u(?:8|16|32|64|128|256)|uint(?:8|16|32|64|ptr)?)\b/,
		number: /\b0x_?[\da-f][\da-f_]*(?:\.[\da-f_]*)?(?:p[+-]?[\d_]+)?i?\b|\b0(?:b_?[01][01_]*|o_?[0-7][0-7_]*)i?\b|(?:\b\d[\d_]*(?:\.[\d_]*)?|\B\.\d[\d_]*)(?:e[+-]?[\d_]+)?i?(?!\w)/i,
		function: /\b(?:[a-zA-Z_]\w*)(?=\s*\()|\binit\b(?=\s*\{)/,
		operator: /<=>|=>|:=|\.\.\.|\+\+|--|&&|\|\||(?:<<|>>|&\^|[-+*/%&|^!=<>])=?/,
		punctuation: /[()[\]{},.;:]/,
	};
})(Prism);

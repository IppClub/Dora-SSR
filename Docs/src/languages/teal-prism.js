(function (Prism) {
	Prism.languages.teal = {
		comment: /^#!.+|--(?:\[(=*)\[[\s\S]*?\]\1\]|.*)/m,
		// \z may be used to skip the following space
		string: {
			pattern:
				/(["'])(?:(?!\1)[^\\\r\n]|\\z(?:\r\n|\s)|\\(?:\r\n|[^z]))*\1|\[(=*)\[[\s\S]*?\]\2\]/,
			greedy: true
		},
		number:
			/\b0x[a-f\d]+(?:\.[a-f\d]*)?(?:p[+-]?\d+)?\b|\b\d+(?:\.\B|(?:\.\d*)?(?:e[+-]?\d+)?\b)|\B\.\d+(?:e[+-]?\d+)?\b/i,
		keyword:
			/\b(?:and|break|do|else|elseif|end|false|for|function|goto|if|in|local|nil|not|or|repeat|return|then|true|until|while|type|record|as|is|embed|enum)\b|<const>|<close>/,
		function: /(?!\d)\w+(?=\s*(?:[({]))/,
		'class-name': /\b[A-Z]\w*|boolean|number|integer|string|table|thread|any|userdata/,
		operator: [
			/[-+*%^&|#]|\/\/?|<[<=]?|>[>=]?|[=~]=?/,
			{
				// Match ".." but don't break "..."
				pattern: /(^|[^.])\.\.(?!\.)/,
				lookbehind: true
			}
		],
		punctuation: /[[\](){},;]|\.+|:+/
	}
	Prism.languages.tl = Prism.languages.teal
})(Prism);

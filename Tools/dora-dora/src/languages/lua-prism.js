/* MIT LICENSE

Copyright (c) 2012 Lea Verou. Modified by Li Jin 2024.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */

function lua(Prism) {
	Prism.languages.lua = {
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
			/\b(?:and|break|do|else|elseif|end|false|for|function|goto|if|in|local|nil|not|or|repeat|return|then|true|until|while)\b/,
		'class-name': /\b[A-Z]\w*/,
		function: /(?!\d)\w+(?=\s*(?:[({]))/,
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
}

lua.displayName = 'lua';
lua.aliases = [];

export default lua;

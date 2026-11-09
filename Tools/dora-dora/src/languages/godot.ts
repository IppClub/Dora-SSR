import type * as Monaco from 'monaco-editor/esm/vs/editor/editor.api.js';

const brackets: Monaco.languages.LanguageConfiguration['brackets'] = [['{', '}'], ['[', ']'], ['(', ')']];
const pairs = brackets!.map(([open, close]) => ({ open, close }));
const quotes = ['"', "'"].map(quote => ({ open: quote, close: quote, notIn: ['string', 'comment'] }));

const gdscript: Monaco.languages.IMonarchLanguage = {
	keywords: ['and', 'as', 'assert', 'await', 'break', 'breakpoint', 'class', 'class_name', 'const', 'continue',
		'elif', 'else', 'enum', 'extends', 'for', 'func', 'if', 'in', 'is', 'match', 'not', 'or', 'pass',
		'return', 'self', 'signal', 'static', 'super', 'var', 'void', 'when', 'while'],
	tokenizer: {
		root: [
			[/#.*/, 'comment'],
			[/"""/, 'string', '@tripleDouble'],
			[/'''/, 'string', '@tripleSingle'],
			[/"/, 'string', '@doubleString'],
			[/'/, 'string', '@singleString'],
			[/@[a-zA-Z_]\w*/, 'annotation'],
			[/\b(?:true|false|null)\b/, 'constant'],
			[/[a-zA-Z_]\w*/, { cases: { '@keywords': 'keyword', '@default': 'identifier' } }],
			[/0[xX][\da-fA-F_]+|0[bB][01_]+|(?:\d[\d_]*(?:\.[\d_]*)?|\.\d[\d_]*)(?:[eE][+-]?[\d_]+)?/, 'number'],
			[/[{}()[\]]/, '@brackets'],
			[/[-+*/%=<>!&|^~:]+/, 'operator'],
		],
		doubleString: [[/\\./, 'string.escape'], [/"/, 'string', '@pop'], [/[^"\\]+/, 'string']],
		singleString: [[/\\./, 'string.escape'], [/'/, 'string', '@pop'], [/[^'\\]+/, 'string']],
		tripleDouble: [[/"""/, 'string', '@pop'], [/\\./, 'string.escape'], [/[^"\\]+|"/, 'string']],
		tripleSingle: [[/'''/, 'string', '@pop'], [/\\./, 'string.escape'], [/[^'\\]+|'/, 'string']],
	},
};

const resource: Monaco.languages.IMonarchLanguage = {
	tokenizer: {
		root: [
			[/[;#].*$/, 'comment'],
			[/"/, 'string', '@string'],
			[/[a-zA-Z_]\w*(?=\()/, 'type'],
			[/\b(?:true|false|null)\b/, 'constant'],
			[/-?\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b/, 'number'],
			[/[{}()[\]]/, '@brackets'],
			[/=/, 'operator'],
		],
		string: [[/\\./, 'string.escape'], [/"/, 'string', '@pop'], [/[^"\\]+/, 'string']],
	},
};

const shader: Monaco.languages.IMonarchLanguage = {
	keywords: ['shader_type', 'render_mode', 'uniform', 'varying', 'group_uniforms', 'global', 'instance',
		'const', 'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default', 'break', 'continue', 'return',
		'discard', 'in', 'out', 'inout', 'void', 'bool', 'int', 'uint', 'float', 'vec2', 'vec3', 'vec4',
		'ivec2', 'ivec3', 'ivec4', 'uvec2', 'uvec3', 'uvec4', 'bvec2', 'bvec3', 'bvec4', 'mat2', 'mat3', 'mat4',
		'sampler2D', 'sampler2DArray', 'sampler3D', 'samplerCube', 'canvas_item', 'spatial', 'particles', 'sky', 'fog'],
	tokenizer: {
		root: [
			[/\/\/.*/, 'comment'],
			[/\/\*/, 'comment', '@comment'],
			[/^\s*#\w+/, 'keyword'],
			[/"[^"\n]*"/, 'string'],
			[/\b(?:true|false)\b/, 'constant'],
			[/[A-Z_][A-Z_\d]+\b/, 'variable.predefined'],
			[/[a-zA-Z_]\w*/, { cases: { '@keywords': 'keyword', '@default': 'identifier' } }],
			[/\d+(?:\.\d*)?(?:[eE][+-]?\d+)?|\.\d+/, 'number'],
			[/[{}()[\]]/, '@brackets'],
			[/[-+*/%=<>!&|^~:]+/, 'operator'],
		],
		comment: [[/\*\//, 'comment', '@pop'], [/[^*]+|\*/, 'comment']],
	},
};

export function registerGodotLanguages(monaco: typeof Monaco) {
	for (const [id, extensions, language, comments] of [
		['gdscript', ['.gd'], gdscript, { lineComment: '#' }],
		['godot-resource', ['.tscn', '.tres', '.godot'], resource, { lineComment: ';' }],
		['godot-shader', ['.gdshader', '.gdshaderinc'], shader, { lineComment: '//', blockComment: ['/*', '*/'] }],
	] as const) {
		monaco.languages.register({ id, extensions: [...extensions] });
		monaco.languages.setMonarchTokensProvider(id, language);
		monaco.languages.setLanguageConfiguration(id, {
			comments: { lineComment: comments.lineComment,
				...('blockComment' in comments ? { blockComment: [...comments.blockComment] as [string, string] } : {}) },
			brackets,
			autoClosingPairs: [...pairs, ...quotes],
			surroundingPairs: [...pairs, ...quotes],
			...(id === 'gdscript' ? { indentationRules: {
				increaseIndentPattern: /^\s*(?:class|func|static\s+func|if|elif|else|for|while|match|\w+\s*\([^)]*\)).*:\s*(?:#.*)?$/,
				decreaseIndentPattern: /^\s*(?:elif\b|else\s*:)/,
			} } : {}),
		});
	}
}

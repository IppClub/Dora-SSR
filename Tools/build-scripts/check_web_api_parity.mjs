// Audit the API layers that canonical tolua generation alone cannot cover.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const read = name => fs.readFileSync(path.join(root, name), 'utf8');
const native = read('Source/Lua/Builtin/Initialization.lua');
const web = read('Source/Lua/Builtin/WebInitialization.lua');
function luaMethods(source) {
	const aliases = new Map([['Dora', 'Dora'], ['yue', 'Dora.yue'], ['teal', 'Dora.teal']]);
	for (const m of source.matchAll(/local\s+(\w+)\s*=\s*(?:getmetatable\()?Dora\.([\w.]+)/g)) aliases.set(m[1], `Dora.${m[2]}`);
	const result = new Set();
	for (const m of source.matchAll(/\b([A-Za-z_]\w*(?:\.\w+)+)\s*=\s*(?:function\b|pairCall[A-Z]\b|[A-Za-z_]\w*_[A-Za-z_]\w*\b)/g)) {
		const [first, ...rest] = m[1].split('.');
		if (aliases.has(first)) result.add(`${aliases.get(first)}.${rest.join('.')}`);
	}
	return result;
}
function bindings(source) {
	const stack = [], result = new Set();
	for (const m of source.matchAll(/tolua_(beginmodule|endmodule|function|variable|call)\(L(?:,\s*("[^"]*"|nullptr|MT_CALL))?/g)) {
		if (m[1] === 'beginmodule') stack.push(m[2] === 'nullptr' ? '' : JSON.parse(m[2]));
		else if (m[1] === 'endmodule') stack.pop();
		else result.add([...stack.filter(Boolean), m[1] === 'call' ? '__call' : JSON.parse(m[2])].join('.'));
	}
	return result;
}
const cpp = read('Source/Lua/LuaEngine.cpp');
const webCpp = cpp.slice(cpp.indexOf('\ttolua_LuaBindingWeb_open(L);'), cpp.indexOf('\n#else\n\tstd::string builtinModuleError;'));
const nativeCpp = cpp.slice(cpp.indexOf('// add manual binding'), cpp.indexOf('// load binding codes'));
// Explicit profile boundaries. New methods outside these modules fail the audit.
const exclusions = {
	'Git': 'native Git workspace integration is excluded',
	'HttpServer': 'browser cannot host the native HTTP server',
	'Cache': 'aggregate cache API pulls in excluded 3D/Wasm loaders',
	'Wasm': 'Wasm script runtime excluded',
	'teal': 'Teal editor/compiler excluded',
	'xml': 'XML compiler excluded',
	'Surface3D': '3D nodes excluded',
	'Application.testNames': 'native test registry excluded',
	'Application.runTest': 'native test registry excluded',
	'Audio.renderMusicAsync': 'native music-rendering service excluded',
	'ubox': 'native object-debugging helper excluded',
	'yarncompile': 'Yarn compiler excluded',
	'bgfxProbeDraw': 'native diagnostic probe excluded',
	'bgfxProbeClearRed': 'native diagnostic probe excluded',
};
const ignored = key => Object.keys(exclusions).some(prefix => key === prefix || key.startsWith(`${prefix}.`));
const missing = [];
for (const [kind, a, b] of [['lua', luaMethods(native), luaMethods(web)], ['manual', bindings(nativeCpp), bindings(webCpp)]]) {
	for (const name of a) if (!b.has(name) && !ignored(name.replace(/^Dora\./, ''))) missing.push(`${kind}: ${name}`);
	console.log(`[INFO] ${kind}: checked ${a.size} native entries against ${b.size} Web entries`);
}
// Generated bindings must still consume the canonical declarations.
const pkg = read('Tools/tolua++/LuaBindingWeb.pkg');
for (const name of ['Dora.h', 'ImGui.h', 'NanoVG.h']) if (!pkg.includes(`$pfile "${name}"`)) missing.push(`canonical binding: ${name}`);
if (missing.length) throw new Error(`Unclassified Web API omissions:\n${missing.join('\n')}`);
if (process.argv[2] === '--emit') {
	const file = path.resolve(process.argv[3]);
	const names = [...luaMethods(native)].filter(name => !ignored(name.replace(/^Dora\./, '')));
	for (const m of native.matchAll(/register\w+Event\((Dora\.\w+|Node), "(\w+)"\)/g)) names.push(`${m[1] === 'Node' ? 'Dora.Node' : m[1]}.on${m[2]}`);
	names.sort();
	fs.mkdirSync(path.dirname(file), {recursive:true});
	fs.writeFileSync(file, `return {\n${names.map(name => `  ${JSON.stringify(name)},`).join('\n')}\n}\n`);
}
console.log('[INFO] Web API parity audit passed (explicit profile exclusions applied)');

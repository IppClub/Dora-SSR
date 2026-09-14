import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import vm from 'node:vm';
import { commonjsLodashPlugin } from './commonjs-lodash-plugin.mjs';

const store = 'node_modules/.pnpm';
const packageDir = readdirSync(store).find(name => name.startsWith('lodash@'));
assert.ok(packageDir, 'Installed Lodash is required');
const id = join(store, packageDir, 'node_modules/lodash/lodash.js');
const source = readFileSync(id, 'utf8');
const plugin = commonjsLodashPlugin();

function evaluate(code, amd) {
	const module = { exports: {} };
	let registrations = 0;
	const define = () => { registrations++; };
	define.amd = { jQuery: true };
	const context = vm.createContext({ module, exports: module.exports, ...(amd ? { define } : {}) });
	vm.runInContext(`(function(module, exports) {\n${code}\n})(module, exports);`, context);
	return { lodash: module.exports, registrations, context, define };
}

assert.equal(typeof evaluate(source, true).lodash.memoize, 'undefined', 'Reproduce original AMD failure');
const transformed = plugin.transform(source, id).code;
for (const amd of [false, true]) {
	const { lodash, registrations, context, define } = evaluate(transformed, amd);
	assert.equal(typeof lodash.memoize, 'function');
	let calls = 0;
	const cached = lodash.memoize(value => { calls++; return value * 2; });
	assert.equal(cached(3), 6);
	assert.equal(cached(3), 6);
	assert.equal(calls, 1);
	assert.equal(registrations, 0);
	if (amd) assert.equal(context.define, define, 'Preserve the global AMD loader');
}
assert.equal(plugin.transform(source, '/other/module.js'), null);
console.log('Lodash exports and memoization work with and without a global AMD loader.');

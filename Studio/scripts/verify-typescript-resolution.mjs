import assert from 'node:assert/strict';
import { readdir, readFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { build } from 'esbuild';
import { readStudioCompilerResources } from './compiler-resources.mjs';

const studio = fileURLToPath(new URL('../', import.meta.url));
const { outputFiles } = await build({
  stdin: {
    contents: `
      export { compile, COMPILER_VERSION } from './packages/compiler-web/src/worker.mjs';
      export { compileSnapshot, doraCompilerOptions } from './packages/compiler/src/index.ts';
      export { Transpiler, LuaTarget, LuaLibImportKind } from './packages/tstl/index.ts';
    `,
    resolveDir: studio,
  },
  bundle: true, write: false, platform: 'node', format: 'cjs', external: ['typescript', 'source-map'],
});
const module = { exports: {} };
const require = createRequire(new URL('../packages/tstl/package.json', import.meta.url));
new Function('module', 'exports', 'require', 'self', outputFiles[0].text)(module, module.exports, require, {});
const { compile, COMPILER_VERSION, compileSnapshot, doraCompilerOptions, Transpiler, LuaTarget, LuaLibImportKind } = module.exports;
const ts = require('typescript');
const library = new URL('../../Assets/Script/Lib/Dora/en/', import.meta.url);
const assetPath = '/data/app/~~install-id/base.apk/assets';
const android = assetPath + '/Script/Lib/Dora/en';
const projectRoot = '/data/user/0/org.ippclub.dorassr/files/Project';
const nativeDeclarations = await Promise.all((await readdir(library)).filter(name => name.endsWith('.d.ts'))
  .map(async name => ({ file: `${android}/${name}`, moduleName: name.slice(0, -5), content: await readFile(new URL(name, library), 'utf8') })));
// Fixture metadata models what the engine supplies with a snapshot.
const nativeRuntimeModules = ['DB', 'thread', 'fixture.extension'];
const native = (entry, files, projectScriptRoot, bundled = []) => compileSnapshot(ts, {
  projectScriptRoot,
  rootNames: [`${projectRoot}/${entry}`], projectRoot, defaultLibFileName: `${android}/Dora.d.ts`,
  files: [...nativeDeclarations, ...bundled, ...Object.entries(files).map(([name, content]) => ({ file: `${projectRoot}/${name}`, content }))],
  options: doraCompilerOptions(ts, LuaTarget.Lua55, LuaLibImportKind.Require, nativeRuntimeModules, assetPath),
}, (program, emitHost, writeFile) => new Transpiler({ emitHost }).emit({ program, writeFile }).diagnostics);

const builtins = ['love', 'ImGui', 'nvg', 'DoraX', 'InputManager', 'Platformer', 'bit32', 'socket', 'socket.http', 'socket.url', 'ssl.https', 'mime', 'ltn12'];
const builtinSource = builtins.map((name, i) => `import * as module${i} from "${name}"; export const value${i} = module${i};`).join('\n');
const builtinResult = native('main.ts', {
  'main.ts': builtinSource,
  'DoraX.lua': 'return {}',
  'InputManager.lua': 'return {}',
});
assert.deepEqual(builtinResult.diagnostics, []);
const builtinLua = builtinResult.output.get(`${projectRoot}/main.lua`).content;
for (const name of builtins) assert.ok(builtinLua.includes(`require("${name}")`), name);
assert.ok(!builtinLua.includes('base.apk'));

const luaDependency = native('main.ts', {
  'main.ts': 'import hooks from "hooks"; export const value = hooks;',
  'hooks.d.ts': 'declare const hooks: number; export default hooks;',
  'hooks.lua': 'local DB = require("DB"); local thread = require("thread"); return 42;',
});
assert.deepEqual(luaDependency.diagnostics, []);
assert.ok(luaDependency.output.get(projectRoot + '/hooks.lua').content.includes('require("DB")'));
const doraArray = native('main.ts', {
  'main.ts': 'import {Node} from "Dora"; export const child = Node().children?.get(1);',
});
assert.deepEqual(doraArray.diagnostics, []);

const result = native('game/main.ts', {
  'game/main.ts': 'import {x} from "model"; import {y} from "pkg/config.local"; import {z} from "widget"; export const answer = x + y + z;',
  'game/model.ts': 'export const x = 1;',
  'model.lua': 'return { x = false }',
  'pkg/config.local.ts': 'export const y = 2;',
  'widget/index.ts': 'export const z = 3;',
});
assert.deepEqual(result.diagnostics, []);
const lua = result.output.get(`${projectRoot}/game/main.lua`).content;
assert.ok(lua.includes('require("game.model")'));
assert.ok(lua.includes('require("./pkg/config.local.lua")'));
assert.ok(lua.includes('require("widget.index")'));
assert.ok(result.output.has(`${projectRoot}/pkg/config.local.lua`));
assert.ok(!result.output.has(`${projectRoot}/model.lua`));
const missing = native('main.ts', { 'main.ts': 'import {x} from "pkg"; export const value = x;', 'pkg.d.ts': 'export const x: number;' });
assert.ok(missing.diagnostics.some(d => String(d.messageText).includes("Could not resolve lua source files for require path 'pkg'")));

const mountedDeclaration = {
  file: projectRoot + '/Mounted.d.ts',
  sourcePath: assetPath + '/Script/Lib/Mounted.d.ts',
  content: 'export const value: number;',
};
const mountedSource = { 'main.ts': 'import {value} from "Mounted"; export const result = value;' };
const mounted = native('main.ts', mountedSource, undefined, [mountedDeclaration]);
assert.deepEqual(mounted.diagnostics, []);
assert.ok(mounted.output.get(projectRoot + '/main.lua').content.includes('require("Mounted")'));
const untrustedMount = native('main.ts', mountedSource, undefined, [{
  ...mountedDeclaration, sourcePath: assetPath + '-other/Script/Lib/Mounted.d.ts',
}]);
assert.ok(untrustedMount.diagnostics.some(d => String(d.messageText).includes("require path 'Mounted'")));

const projectImplementation = native('main.ts', {
  ...mountedSource,
  'Mounted.ts': 'export const value = 42;',
}, undefined, [mountedDeclaration]);
assert.deepEqual(projectImplementation.diagnostics, []);
assert.ok(projectImplementation.output.get(projectRoot + '/Mounted.lua').content.includes('42'));

const suppliedAtRuntime = native('main.ts', {
  'main.ts': 'import hooks from "fixture.extension"; export const value = hooks;',
  'fixture.extension.d.ts': 'declare const hooks: number; export default hooks;',
});
assert.deepEqual(suppliedAtRuntime.diagnostics, []);
assert.ok(suppliedAtRuntime.output.get(projectRoot + '/main.lua').content.includes('require("fixture.extension")'));

const grouped = native('main.ts', {
  'main.ts': 'import {value} from "fixture.grouped"; export const result = value;',
}, undefined, [{
  file: android + '/unrelated-file-name.d.ts',
  content: 'declare module "fixture.grouped" { export const value: number; }',
}]);
assert.deepEqual(grouped.diagnostics, []);
assert.ok(grouped.output.get(projectRoot + '/main.lua').content.includes('require("fixture.grouped")'));

for (const [name, expected] of [['thread.ts', './thread.lua'], ['game/thread.ts', 'game.thread']]) {
  const entry = name.startsWith('game/') ? 'game/main.ts' : 'main.ts';
  const shadowedRuntime = native(entry, {
    [entry]: 'import {value} from "thread"; export const result = value;',
    [name]: 'export const value = 42;',
  });
  assert.deepEqual(shadowedRuntime.diagnostics, []);
  assert.ok(shadowedRuntime.output.get(projectRoot + '/' + entry.replace('.ts', '.lua')).content.includes(`require("${expected}")`));
}

const scriptRoot = native('Test/main.ts', {
  'Test/main.ts': 'import {value} from "UIX"; export const result: number = value;',
  'Script/UIX.ts': 'export {value} from "widgets/value";',
  'Script/widgets/value.ts': 'export const value = 42;',
  'UIX.ts': 'export const value = "shadowed by Script";',
}, projectRoot + '/Script');
assert.deepEqual(scriptRoot.diagnostics, []);
assert.ok(scriptRoot.output.get(projectRoot + '/Test/main.lua').content.includes('require("UIX")'));
assert.ok(scriptRoot.output.get(projectRoot + '/Script/UIX.lua').content.includes('require("widgets.value")'));

const studioSources = {
  'main.ts': `import {React} from "DoraX"; import * as nvg from "nvg"; import * as love from "love";
import {x} from "pkg"; export const values = {React, nvg, love, x};`,
  'pkg.d.ts': 'export const x: number;',
  'pkg/init.lua': '-- Authored Lua\nreturn { x = 1 }\n',
};
const studioRequest = {
  type: 'compile', version: 1, sessionId: 'resolution', projectId: 'resolution', revision: 0,
  requestId: 'resolution', buildId: 'resolution', compilerVersion: COMPILER_VERSION, options: {},
  declarations: JSON.parse(await readStudioCompilerResources()),
  snapshot: {
    version: 1, projectId: 'resolution', revision: 0, entry: 'main.ts',
    files: Object.entries(studioSources).map(([path, text]) => ({ path, kind: 'text', text })),
  },
};
const reply = await compile(studioRequest);
assert.equal(reply.type, 'compiled', JSON.stringify(reply.diagnostics));
assert.deepEqual(reply.diagnostics, []);
const artifact = new Map(reply.artifact.files.map(file => [file.path, file.text]));
assert.equal(artifact.get('pkg/init.lua'), studioSources['pkg/init.lua']);
for (const name of ['DoraX', 'nvg', 'love', 'pkg.init']) assert.ok(artifact.get('main.lua').includes(`require("${name}")`), name);
for (const [name, expected] of [['socket.http', 'compileFailed'], ['mime', 'compiled'], ['ltn12', 'compiled']]) {
  const result = await compile({
    ...studioRequest,
    snapshot: {
      ...studioRequest.snapshot,
      files: [{ path: 'main.ts', kind: 'text', text: `import * as mod from "${name}"; export const value = mod;` }],
    },
  });
  assert.equal(result.type, expected, JSON.stringify(result.diagnostics));
}
console.log('TypeScript module resolution and Studio Lua resources passed.');

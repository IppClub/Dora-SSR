import { readdir, readFile } from 'node:fs/promises';
import { transform } from 'esbuild';
import { runtimeModulesResource, studioCompilerResourcesPath } from '../packages/compiler/dist/index.js';

export { studioCompilerResourcesPath };

const root = new URL('../../', import.meta.url);
const readText = (path) => readFile(new URL(path, root), 'utf8');
const runtimeRoot = new URL('build/studio-runtime/', root);

function readBindings(source, features, template) {
  // The generated registration function uses the same guards as the Player.
  const defines = new Set(['DORA_WEB_MINIMAL']);
  for (const [, key, flag] of template.matchAll(/"([^"]+)": @DORA_WEB_(?:FEATURE_)?(\w+)_JSON@/g)) {
    if (features.modules[key] === false) defines.add('DORA_WEB_NO_' + flag);
  }
  const start = source.indexOf('TOLUA_API int tolua_LuaBindingWeb_open (');
  if (start < 0) throw new Error('Missing generated Web Lua registration');
  const modules = new Set();
  const conditions = [];
  for (const line of source.slice(start).split('\n')) {
    const guard = line.match(/^#if !defined\((\w+)\)/);
    if (guard) conditions.push(!defines.has(guard[1]));
    else if (line.startsWith('#endif')) conditions.pop();
    else if (line.startsWith('#if') || line.startsWith('#el')) throw new Error(`Unknown Web binding guard: ${line}`);
    else if (conditions.every(Boolean)) {
      const match = line.match(/^  tolua_(?:cclass|module|variable|function)\(tolua_S,"([^"]+)"/);
      if (match) modules.add(match[1]);
    }
  }
  return modules;
}

async function readEmbeddedModules(modules, providers, socketScripts, engineLua) {
  for (const [, name] of providers.matchAll(/^DORA_LUA_MODULE\("([^"]+)"/gm)) modules.add(name);
  const start = engineLua.indexOf('static int dora_load_base(');
  const end = engineLua.indexOf('for (const luaL_Reg* lib', start);
  if (start < 0 || end < 0) throw new Error('Missing Lua base library registration');
  for (const [, name] of engineLua.slice(start, end).matchAll(/luaopen_(\w+)/g)) {
    modules.add(name === 'base' ? '_G' : name);
  }
  const finder = await readText('Studio/packages/tstl/transpilation/find-lua-requires.ts');
  const { code } = await transform(finder, { loader: 'ts', format: 'esm' });
  const { findLuaRequires } = await import('data:text/javascript;base64,' + Buffer.from(code).toString('base64'));
  // Follow the actual LuaSocket preload table. A Lua wrapper is usable only
  // when all its dependencies are present in the selected runtime.
  const wrappers = await Promise.all([...socketScripts.matchAll(/\{"([^"]+)", "@dora-builtin\/luasocket\/([^"]+)"/g)]
    .map(async ([, name, file]) => ({
      name,
      requires: findLuaRequires(await readText('Source/3rdParty/LuaSocket/' + file)).map(dep => dep.requirePath),
    })));
  for (let added = true; added;) {
    added = false;
    for (const { name, requires } of wrappers) {
      if (!modules.has(name) && requires.every(dep => modules.has(dep))) {
        modules.add(name);
        added = true;
      }
    }
  }
}

export async function readStudioCompilerResources() {
  const library = 'Assets/Script/Lib/';
  const types = library + 'Dora/en/';
  const [names, player, featuresJson, featuresTemplate, bindingCode, webInit, loveRegistration, providers, socketScripts, engineLua, lualib] = await Promise.all([
    readdir(new URL(types, root)),
    readFile(new URL('dora-player-runtime.js', runtimeRoot), 'utf8'),
    readFile(new URL('dora-web-features.json', runtimeRoot), 'utf8'),
    readText('Projects/Web/web-features.json.in'),
    readText('Source/Lua/LuaBindingWeb.cpp'),
    readText('Source/Lua/Builtin/WebInitialization.lua'),
    readText('Source/Love/PreloadModules.inc'),
    readText('Source/Lua/BuiltinModuleProviders.inc'),
    readText('Source/3rdParty/LuaSocket/LuaScripts.h'),
    readText('Source/Lua/LuaEngine.cpp'),
    readText(library + 'lualib_bundle.lua'),
  ]);
  const declarations = await Promise.all(names.filter(path => path.endsWith('.d.ts')).sort().map(async path => ({
    path, kind: 'text', text: await readText(types + path),
  })));
  const features = JSON.parse(featuresJson);
  const modules = readBindings(bindingCode, features, featuresTemplate);
  for (const [, name, expression] of webInit.matchAll(/^Dora\.(\w+) = ([^\r\n]+)/gm)) {
    if (expression === 'nil') modules.delete(name);
    else modules.add(name);
  }
  // Emscripten embeds the final asset names in the Player loader.
  for (const [, name] of player.matchAll(/"\/builtin\/Script\/Lib\/([^"\\]+)\.lua"/g)) {
    modules.add(name.replaceAll('/', '.'));
  }
  if (features.modules.loveNode) {
    for (const [, name] of loveRegistration.matchAll(/^DORA_LOVE_MODULE\("([^"]+)"/gm)) modules.add(name);
  }
  await readEmbeddedModules(modules, providers, socketScripts, engineLua);
  declarations.push(
    { path: 'lualib_bundle.lua', kind: 'text', text: lualib },
    { path: runtimeModulesResource, kind: 'text', text: JSON.stringify([...modules].sort()) },
  );
  return JSON.stringify(declarations);
}

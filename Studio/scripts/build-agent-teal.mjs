import { mkdir, readFile, writeFile, readdir } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { build } from 'esbuild';
const root = new URL('../../', import.meta.url);
const lua = new URL('Source/3rdParty/Lua/', root);
const output = new URL('../packages/agent-contracts/dist/teal/', import.meta.url);
await mkdir(output, { recursive: true });
const source = await readFile(new URL('Source/Lua/Builtin/tl.lua', root));
await writeFile(new URL('teal-source.h', output), `static const unsigned char teal_source[] = {${[...source].join(',')}};`);
const webServer = await readFile(new URL('Assets/Script/Dev/WebServer.lua', root), 'utf8');
const utils = await readFile(new URL('Assets/Script/Lib/Utils.lua', root), 'utf8');
const ticStart = utils.indexOf('local tic80APIs');
const ticEnd = utils.indexOf('_module_0["CheckTIC80Code"]', ticStart);
if (ticStart < 0 || ticEnd < 0) throw new Error('Original TIC80 detector changed');
const ticDetector = utils.slice(ticStart, ticEnd);
const substitutions = webServer.split('\n').map(line => line.trim()).filter(line => line.startsWith('content = content:gsub(') && line.includes('tic80'));
if (!substitutions.length || new Set(substitutions).size !== 1) throw new Error('Original TIC80 substitutions require review');
function extract(start, end) {
  const a = webServer.indexOf(start), b = webServer.indexOf(end, a);
  if (a < 0 || b < 0) throw new Error(`Original Lua check shape changed: ${start}`);
  return webServer.slice(a, b);
}
const luaCheck = Buffer.from(`local teal = {checkAsync = studio_teal.dora_check}\n` +
  ticDetector + '\n' +
  extract('local disabledCheckForLua = {', 'local yueCheck\n') +
  extract('local luaCheck\nluaCheck = function(', 'local luaCheckWithLineInfo\n') +
  `\nfunction studio_lua_check(content, filename)
    if CheckTIC80Code(content) then ${substitutions[0]} end
    local result = luaCheck(filename, content); return result.success, result.info
  end
  function studio_tl_compile(content, filename)
    local isTIC80 = not not CheckTIC80Code(content)
    if isTIC80 then ${substitutions[0]} end
    local codes, err = studio_teal.dora_to_lua(content, filename, "")
    if codes and isTIC80 then codes = codes:gsub('^require%("tic80"%)', '-- tic80') end
    return codes, err, isTIC80
  end\n`);
await writeFile(new URL('lua-check-source.h', output), `static const unsigned char lua_check_source[] = {${[...luaCheck].join(',')}};`);
const files = (await readdir(lua)).filter(name => name.endsWith('.c')).sort();
execFileSync(process.env.STUDIO_EMCC || 'emcc', [fileURLToPath(new URL('teal-host.c', import.meta.url)),
  ...files.map(name => fileURLToPath(new URL(name, lua))), '-I' + fileURLToPath(lua), '-I' + fileURLToPath(output),
  '-O2', '--no-entry', '-sMODULARIZE=1', '-sEXPORT_ES6=1', '-sSINGLE_FILE=1',
  '-sENVIRONMENT=web,node', '-sFILESYSTEM=0', '-sALLOW_MEMORY_GROWTH=1',
  '-sEXPORTED_FUNCTIONS=["_teal_open","_teal_close","_teal_add_file","_teal_remove_file","_teal_compile","_teal_compiled_source","_teal_compiled_tic80","_teal_init","_teal_check","_teal_check_lua","_teal_diagnostic_count","_teal_diagnostic","_teal_error","_malloc","_free"]',
  '-sEXPORTED_RUNTIME_METHODS=["cwrap","HEAPU8"]', '-o', fileURLToPath(new URL('compiler.mjs', output)),
], { stdio: 'inherit' });
await writeFile(new URL('Lua-LICENSE', output), await readFile(new URL('LICENSE', lua)));
await build({ entryPoints: [fileURLToPath(new URL('../packages/agent-contracts/src/teal-worker.js', import.meta.url))],
  outfile: fileURLToPath(new URL('worker.mjs', output)), bundle: true, format: 'esm', platform: 'browser', external: ['./compiler.mjs'] });

import { mkdir, readFile, writeFile, readdir } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const source = new URL('../../Source/3rdParty/Lua/', import.meta.url);
const output = new URL('../packages/agent-contracts/dist/lua/', import.meta.url);
await mkdir(output, { recursive: true });
await writeFile(new URL('syntax.c', output), `#include "lua.h"
#include "lauxlib.h"
static lua_State* state;
int syntax_check(const char* source, unsigned length) {
  if (state) lua_close(state);
  state = luaL_newstate();
  if (!state) return LUA_ERRMEM;
  /* Parse only. Never open libraries or execute a user chunk. */
  return luaL_loadbufferx(state, source, length, "check", "t");
}
const char* syntax_error(void) { return state ? lua_tostring(state, -1) : "Lua allocation failed"; }
void syntax_close(void) { if (state) lua_close(state); state = 0; }
`);
const files = (await readdir(source)).filter(name => name.endsWith('.c')).sort();
execFileSync(process.env.STUDIO_EMCC || 'emcc', [fileURLToPath(new URL('syntax.c', output)),
  ...files.map(name => fileURLToPath(new URL(name, source))), '-I' + fileURLToPath(source),
  '-O2', '--no-entry', '-sMODULARIZE=1', '-sEXPORT_ES6=1', '-sSINGLE_FILE=1',
  '-sENVIRONMENT=web,node', '-sFILESYSTEM=0', '-sALLOW_MEMORY_GROWTH=1',
  '-sEXPORTED_FUNCTIONS=["_syntax_check","_syntax_error","_syntax_close","_malloc","_free"]',
  '-sEXPORTED_RUNTIME_METHODS=["cwrap","HEAPU8"]', '-o', fileURLToPath(new URL('syntax.mjs', output)),
], { stdio: 'inherit' });
await writeFile(new URL('LICENSE', output), await readFile(new URL('LICENSE', source)));

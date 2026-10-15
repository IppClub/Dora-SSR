#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "teal-source.h"
#include "lua-check-source.h"

static lua_State* state;
static int files_ref;
static int read_file(lua_State* L) {
  const char* path = luaL_checkstring(L, 1);
  lua_rawgeti(L, LUA_REGISTRYINDEX, files_ref);
  lua_getfield(L, -1, path);
  return 1;
}
static int file_exist(lua_State* L) {
  read_file(L);
  lua_pushboolean(L, !lua_isnil(L, -1));
  return 1;
}
void teal_close(void) { if (state) lua_close(state); state = 0; }
int teal_open(void) {
  teal_close();
  state = luaL_newstate();
  if (!state) return 1;
  /* Only trusted compiler code is executed. User code is parsed by Teal. */
  const luaL_Reg libraries[] = {
    {LUA_GNAME, luaopen_base}, {LUA_LOADLIBNAME, luaopen_package},
    {LUA_TABLIBNAME, luaopen_table}, {LUA_STRLIBNAME, luaopen_string},
    {LUA_MATHLIBNAME, luaopen_math}, {LUA_UTF8LIBNAME, luaopen_utf8},
    {LUA_COLIBNAME, luaopen_coroutine}, {0, 0}
  };
  for (const luaL_Reg* lib = libraries; lib->func; lib++) {
    luaL_requiref(state, lib->name, lib->func, 1); lua_pop(state, 1);
  }
  lua_newtable(state); files_ref = luaL_ref(state, LUA_REGISTRYINDEX);
  if (luaL_loadbufferx(state, (const char*)teal_source, sizeof(teal_source), "@tl.lua", "t") ||
      lua_pcall(state, 0, 0, 0)) return 1;
  lua_getglobal(state, "package"); lua_getfield(state, -1, "loaded"); lua_getfield(state, -1, "tl");
  lua_pushcfunction(state, read_file); lua_setfield(state, -2, "read_file");
  lua_pushcfunction(state, file_exist); lua_setfield(state, -2, "file_exist");
  lua_setglobal(state, "studio_teal"); lua_settop(state, 0);
  if (luaL_loadbufferx(state, (const char*)lua_check_source, sizeof(lua_check_source), "@studio-lua-check", "t") ||
      lua_pcall(state, 0, 0, 0)) return 1;
  return 0;
}
void teal_add_file(const char* path, const char* bytes, unsigned length) {
  lua_settop(state, 0); lua_rawgeti(state, LUA_REGISTRYINDEX, files_ref);
  lua_pushlstring(state, bytes, length); lua_setfield(state, -2, path); lua_settop(state, 0);
}
void teal_remove_file(const char* path) {
  lua_settop(state, 0); lua_rawgeti(state, LUA_REGISTRYINDEX, files_ref);
  lua_pushnil(state); lua_setfield(state, -2, path); lua_settop(state, 0);
}
int teal_compile(const char* source, unsigned length, const char* filename) {
  lua_settop(state, 0); lua_getglobal(state, "studio_tl_compile");
  lua_pushlstring(state, source, length); lua_pushstring(state, filename);
  if (lua_pcall(state, 2, 3, 0)) return 2;
  return lua_isnil(state, 1) ? 1 : 0;
}
const char* teal_compiled_source(void) { return lua_tostring(state, 1); }
int teal_compiled_tic80(void) { return lua_toboolean(state, 3); }
int teal_init(void) {
  lua_settop(state, 0); lua_getglobal(state, "studio_teal"); lua_getfield(state, -1, "dora_init");
  lua_remove(state, -2);
  return lua_pcall(state, 0, 0, 0);
}
int teal_check(const char* source, unsigned length, const char* filename, int lax) {
  lua_settop(state, 0); lua_getglobal(state, "studio_teal"); lua_getfield(state, -1, "dora_check");
  lua_remove(state, -2);
  lua_pushlstring(state, source, length); lua_pushstring(state, filename);
  lua_pushboolean(state, lax); lua_pushliteral(state, "");
  if (lua_pcall(state, 4, 2, 0)) return 2;
  return lua_toboolean(state, 1) ? 0 : 1;
}
int teal_diagnostic_count(void) { return lua_istable(state, 2) ? (int)lua_rawlen(state, 2) : 0; }
int teal_check_lua(const char* source, unsigned length, const char* filename) {
  lua_settop(state, 0); lua_getglobal(state, "studio_lua_check");
  lua_pushlstring(state, source, length); lua_pushstring(state, filename);
  if (lua_pcall(state, 2, 2, 0)) return 2;
  return lua_toboolean(state, 1) ? 0 : 1;
}
const char* teal_diagnostic(int index, int field) {
  lua_settop(state, 2); lua_rawgeti(state, 2, index); lua_rawgeti(state, -1, field);
  return lua_tostring(state, -1);
}
const char* teal_error(void) { return state ? lua_tostring(state, -1) : "Teal allocation failed"; }

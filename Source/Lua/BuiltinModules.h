#pragma once

#include <string>

struct lua_State;

namespace Dora {

/** Registers the LuaSocket and Lua 5.2 bit32 compatibility modules. */
bool dora_open_builtin_modules(lua_State* state, std::string& error);

} // namespace Dora

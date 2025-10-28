/* tolua: functions to push C values.
** Support code for Lua bindings.
** Written by Waldemar Celes, modified by Li Jin, 2022
** TeCGraf/PUC-Rio
** Apr 2003, Apr 2014
** $Id: $
*/

/* This code is free software; you can redistribute it and/or modify it.
** The software provided hereunder is on an "as is" basis, and
** the author has no obligation to provide maintenance, support, updates,
** enhancements, or modifications.
*/

#include "Const/Header.h"

#include "Lua/ToLua/tolua++.h"

NS_DORA_BEGIN

void tolua_pushvalue(lua_State* L, int lo) {
	lua_pushvalue(L, lo);
}

void tolua_pushboolean(lua_State* L, int value) {
	lua_pushboolean(L, value);
}

void tolua_pushnumber(lua_State* L, lua_Number value) {
	lua_pushnumber(L, value);
}

void tolua_pushinteger(lua_State* L, lua_Integer value) {
	lua_pushinteger(L, value);
}

void tolua_pushstring(lua_State* L, const char* value) {
	if (value == nullptr)
		lua_pushnil(L);
	else
		lua_pushstring(L, value);
}

void tolua_pushstring(lua_State* L, const char* value, size_t len) {
	if (value == nullptr || len == 0)
		lua_pushnil(L);
	else
		lua_pushlstring(L, value, len);
}

void tolua_pushusertype(lua_State* L, void* value, int typeId) {
	if (value == nullptr) {
		lua_pushnil(L);
		return;
	}
	lua_rawgeti(L, LUA_REGISTRYINDEX, typeId); // mt
	if (lua_isnil(L, -1)) // mt == nil
	{
		Error("[Lua] object pushed to lua is not registered!");
		lua_pop(L, 1);
		lua_pushnil(L);
		return;
	}
	*r_cast<void**>(lua_newuserdata(L, sizeof(void*))) = value; // mt newud
	lua_insert(L, -2); // newud mt
	lua_setmetatable(L, -2); // newud<mt>, newud
}

void tolua_pushfieldvalue(lua_State* L, int lo, int index, int v) {
	lua_pushnumber(L, index);
	lua_pushvalue(L, v);
	lua_settable(L, lo);
}

void tolua_pushfieldboolean(lua_State* L, int lo, int index, int v) {
	lua_pushnumber(L, index);
	lua_pushboolean(L, v);
	lua_settable(L, lo);
}

void tolua_pushfieldnumber(lua_State* L, int lo, int index, lua_Number v) {
	lua_pushnumber(L, index);
	tolua_pushnumber(L, v);
	lua_settable(L, lo);
}

void tolua_pushfieldinteger(lua_State* L, int lo, int index, lua_Integer v) {
	lua_pushnumber(L, index);
	tolua_pushinteger(L, v);
	lua_settable(L, lo);
}

void tolua_pushfieldstring(lua_State* L, int lo, int index, const char* v) {
	lua_pushnumber(L, index);
	tolua_pushstring(L, v);
	lua_settable(L, lo);
}

void tolua_pushfieldusertype(lua_State* L, int lo, int index, void* v, int typeId) {
	lua_pushnumber(L, index);
	tolua_pushusertype(L, v, typeId);
	lua_settable(L, lo);
}

NS_DORA_END

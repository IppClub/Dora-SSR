/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Lua/LuaEngine.h"
#include "Lua/ToLua/tolua++.h"

NS_DORA_BEGIN

static int g_ref_id = 0;
static std::stack<int> g_available_ref_ids;

int tolua_get_max_callback_ref_count() {
	return g_ref_id;
}

int tolua_get_callback_ref_count() {
	return g_ref_id - (unsigned int)g_available_ref_ids.size();
}

int tolua_alloc_callback_ref_id() {
	if (g_available_ref_ids.empty()) {
		return ++g_ref_id;
	} else {
		int id = g_available_ref_ids.top();
		g_available_ref_ids.pop();
		return id;
	}
}

void tolua_collect_callback_ref_id(int refid) {
	g_available_ref_ids.push(refid);
}

int tolua_collect_object(lua_State* L) {
	if (Object* object = r_cast<Object*>(tolua_tousertype(L, 1, 0))) {
		object->release();
		Object::decLuaRefCount();
	}
	return 0;
}

void tolua_pushobject(lua_State* L, Object* object) {
	if (!object) {
		lua_pushnil(L);
		return;
	}
	int refid = object->getLuaRef();

	lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_UBOX); // ubox
	lua_rawgeti(L, -1, refid); // ubox ud

	if (lua_toboolean(L, -1) == 0) { // ud is falsy (nil or false)
		lua_pop(L, 1); // ubox
		*r_cast<void**>(lua_newuserdata(L, sizeof(void*))) = object; // ubox newud
		lua_pushvalue(L, -1); // ubox newud newud
		lua_insert(L, -3); // newud ubox newud
		lua_rawseti(L, -2, refid); // ubox[refid] = newud, newud ubox
		lua_pop(L, 1); // newud
		lua_rawgeti(L, LUA_REGISTRYINDEX, object->getDoraType()); // newud mt
		lua_setmetatable(L, -2); // newud<mt>, newud
		lua_pushvalue(L, TOLUA_NOPEER);
		lua_setuservalue(L, -2);
		// register Object GC
		object->retain();
		Object::incLuaRefCount();
	} else
		lua_remove(L, -2); // ud
}

void tolua_typeid(lua_State* L, int typeId, const char* className) {
	lua_getfield(L, LUA_REGISTRYINDEX, className); // mt
	lua_rawseti(L, LUA_REGISTRYINDEX, typeId); // empty
}

int tolua_isobject(lua_State* L, int lo) {
	if (lua_isuserdata(L, lo)) {
		lua_getmetatable(L, lo); // mt
		lua_rawgeti(L, -1, s_cast<int>(tolua_mt::Super)); // mt super
		lua_rawgeti(L, LUA_REGISTRYINDEX, LuaType<Object>()); // mt super objmt
		lua_rawget(L, LUA_REGISTRYINDEX); // reg[objmt], mt super "Object"
		lua_rawget(L, -2); // super["Object"], mt super flag
		int result = lua_toboolean(L, -1);
		lua_pop(L, 3); // empty
		return result;
	}
	return 0;
}

void tolua_dobuffer(lua_State* L, char* codes, unsigned int size, const char* name) {
	PROFILE("Loader"_slice, name);
	if (luaL_loadbuffer(L, codes, size, name) != 0) {
		Error("[Lua] error loading module \"{}\" :\n\t{}", name, lua_tostring(L, -1));
	} else
		LuaEngine::call(L, 0, 0);
}

int tolua_ref_function(lua_State* L, int lo) {
	/* function or thread at lo */
	int type = lua_type(L, lo);
	if (type == LUA_TFUNCTION || type == LUA_TTHREAD) {
		int refid = tolua_alloc_callback_ref_id();
		lua_pushvalue(L, lo); // fun
		lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_CALLBACK); // fun, funcMap
		lua_insert(L, -2); // funcMap, fun
		lua_rawseti(L, -2, refid); // funcMap[refid] = fun, funcMap
		lua_pop(L, 1); // empty
		return refid;
	}
	return 0;
}

void tolua_get_function_by_refid(lua_State* L, int refid) {
	lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_CALLBACK); // funcMap
	lua_rawgeti(L, -1, refid); // funcMap fun
	lua_remove(L, -2); // fun
}

void tolua_remove_function_by_refid(lua_State* L, int refid) {
	lua_rawgeti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_CALLBACK); // funcMap
	lua_rawgeti(L, -1, refid); // funcMap func
	if (lua_isthread(L, -1)) {
		lua_State* co = lua_tothread(L, -1);
		switch (lua_status(co)) {
			case LUA_YIELD: {
				int state = lua_closethread(co, L);
				if (state != LUA_OK) {
					Error("[Lua] failed to close a suspended coroutine, due to {}.", lua_tostring(co, -1));
					lua_pop(L, 1);
				}
				break;
			}
		}
	}
	lua_pop(L, 1); // funcMap
	lua_pushboolean(L, 0); // funcMap false
	lua_rawseti(L, -2, refid); // funcMap[refid] = false, funcMap
	lua_pop(L, 1); // empty
	tolua_collect_callback_ref_id(refid);
}

int tolua_isfunction(lua_State* L, int lo, tolua_Error* err) {
	int type = lua_type(L, lo);
	if (lua_gettop(L) >= abs(lo) && (type == LUA_TFUNCTION || type == LUA_TTHREAD)) {
		return 1;
	}
	err->index = lo;
	err->array = 0;
	err->type = "function or thread";
	return 0;
}

int tolua_isfunction(lua_State* L, int lo) {
	int type = lua_type(L, lo);
	return type == LUA_TFUNCTION || type == LUA_TTHREAD;
}

void tolua_stack_dump(lua_State* L, int offset, const char* label) {
	int top = lua_gettop(L) + offset;
	if (top == 0) {
		return;
	}
	std::list<std::string> msgs;
	msgs.push_back(fmt::format("Total [{}] in lua stack: {}\n", top, label != 0 ? label : ""));
	for (int i = -1; i >= -top; i--) {
		int t = lua_type(L, i);
		switch (t) {
			case LUA_TSTRING:
				msgs.push_back(fmt::format("  [{}] [string] {}\n", i, lua_tostring(L, i)));
				break;
			case LUA_TBOOLEAN:
				msgs.push_back(fmt::format("  [{}] [boolean] {}\n", i, lua_toboolean(L, i) ? "true" : "false"));
				break;
			case LUA_TNUMBER:
				msgs.push_back(fmt::format("  [{}] [number] {}\n", i, lua_tonumber(L, i)));
				break;
			default:
				msgs.push_back(fmt::format("  [{}] {}\n", i, lua_typename(L, t)));
				break;
		}
	}
	LogInfo(String::join(msgs));
}

Slice tolua_toslice(lua_State* L, int narg, const char* def) {
	if (lua_gettop(L) < abs(narg)) {
		return Slice(def);
	}
	size_t size = 0;
	const char* str = lua_tolstring(L, narg, &size);
	return Slice(str, size);
}

void tolua_pushslice(lua_State* L, String str) {
	lua_pushlstring(L, str.rawData(), str.size());
}

Slice tolua_tofieldslice(lua_State* L, int lo, int index, const char* def) {
	Slice slice;
	lua_pushnumber(L, index);
	lua_gettable(L, lo);
	if (lua_isnil(L, -1)) {
		slice = def;
	} else {
		size_t size = 0;
		const char* str = lua_tolstring(L, -1, &size);
		slice = Slice(str, size);
	}
	lua_pop(L, 1);
	return slice;
}

void tolua_pushlight(lua_State* L, LightValue var) {
	lua_pushlightuserinteger(L, var.i);
}

void tolua_setlightmetatable(lua_State* L) {
	lua_rawgeti(L, LUA_REGISTRYINDEX, LuaType<LightValue::ValueType>()); // mt
	if (lua_isnil(L, -1)) // mt == nil
	{
		lua_pop(L, 1);
		Error("[Lua] Type of light value is not registered!");
		return;
	}
	lua_pushlightuserdata(L, nullptr); // mt ud
	lua_insert(L, -2); // ud mt
	lua_setmetatable(L, -2); // setmetatable(ud, mt), ud
	lua_pop(L, 1); // clear
}

LightValue tolua_tolight(lua_State* L, int narg, LightValue def) {
	if (lua_gettop(L) < abs(narg)) {
		return def;
	} else {
		return LightValue(lua_tolightuserinteger(L, narg));
	}
}

LightValue tolua_tolight(lua_State* L, int narg) {
	return LightValue(lua_tolightuserinteger(L, narg));
}

LightValue tolua_tofieldlight(lua_State* L, int lo, int index, LightValue def) {
	lua_pushnumber(L, index);
	lua_gettable(L, lo);
	LightValue v = lua_isnil(L, -1) ? def : LightValue(lua_tolightuserinteger(L, -1));
	lua_pop(L, 1);
	return v;
}

LightValue tolua_tofieldlight(lua_State* L, int lo, int index) {
	lua_pushnumber(L, index);
	lua_gettable(L, lo);
	LightValue v = LightValue(lua_tolightuserinteger(L, -1));
	lua_pop(L, 1);
	return v;
}

NS_DORA_END

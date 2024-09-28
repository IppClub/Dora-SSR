/* tolua: functions to map features
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
#include "Lua/ToLua/tolua_event.h"

NS_DORA_BEGIN

/* Create metatable
 * Create and register new metatable
 */
static int tolua_newmetatable(lua_State* L, const char* name) {
	if (luaL_getmetatable(L, name) != LUA_TNIL) { /* name already in use? */
		return 0; /* leave previous value on top, but return 0 */
	}
	lua_pop(L, 1);
	const int count = s_cast<int>(tolua_mt::MaxCount);
	lua_createtable(L, count, 2); /* create metatable */
	for (int i = 0; i < count; ++i) {
		lua_pushboolean(L, 0);
		lua_rawseti(L, -2, i + 1);
	}
	lua_pushstring(L, name);
	lua_setfield(L, -2, "__name"); /* metatable.__name = tname */
	lua_pushvalue(L, -1);
	lua_setfield(L, LUA_REGISTRYINDEX, name); /* registry.name = metatable */
	lua_pushvalue(L, -1);
	lua_pushstring(L, name);
	lua_rawset(L, LUA_REGISTRYINDEX); // reg[mt] = type_name
	tolua_classevents(L); // set meta events
	lua_pop(L, 1);
	return 1;
}

/* Map super classes
 * It sets 'name' as being also a 'base', mapping all super classes of 'base' in 'name'
 */
static void mapsuper(lua_State* L, const char* name, const char* base) {
	const int SuperIndex = s_cast<int>(tolua_mt::Super);
	luaL_getmetatable(L, name); // mt
	lua_rawgeti(L, -1, SuperIndex); // mt super
	if (!lua_toboolean(L, -1)) {
		lua_pop(L, 1); // mt
		lua_newtable(L); // mt tb
		lua_pushvalue(L, -1); // mt tb tb
		lua_rawseti(L, -3, SuperIndex); // mt[MT_SUPER] = tb, mt tb
	}
	if (base && *base) {
		lua_pushstring(L, base); // mt tb base
		lua_pushboolean(L, 1); // mt tb base true
		lua_rawset(L, -3); // tb[base] = true, mt tb

		/* set all super class of base as super class of name */
		luaL_getmetatable(L, base); // mt tb basemt
		lua_rawgeti(L, -1, SuperIndex); // mt tb basemt basetb

		if (lua_istable(L, -1)) {
			/* traverse basetb */
			lua_pushnil(L); // mt tb basemt basetb nil
			while (lua_next(L, -2) != 0) // mt tb basemt basetb k v
			{
				/* mt tb basemt basetb k v */
				lua_pushvalue(L, -2); // mt tb basemt basetb k v k
				lua_insert(L, -2); // mt tb basemt basetb k k v
				lua_rawset(L, -6); // tb[k] = v, mt tb basemt basetb k
			} // mt tb basemt basetb
		}
		lua_pop(L, 4); // empty
	} else
		lua_pop(L, 2); // empty
}

/* Map inheritance
 * It sets 'name' as derived from 'base' by setting 'base' as metatable of 'name'
 */
static void mapinheritance(lua_State* L, const char* name, const char* base) {
	/* set metatable inheritance */
	luaL_getmetatable(L, name); // mt
	if (base && *base) {
		luaL_getmetatable(L, base); // mt basemt
	} else {
		/* already has a mt, we don't overwrite it */
		if (lua_getmetatable(L, -1)) // mt mtmt
		{
			lua_pop(L, 2); // empty
			return;
		}
		luaL_getmetatable(L, "tolua_class"); // mt basemt
	}
	lua_setmetatable(L, -2); // mt<basemt>, mt
	lua_pop(L, 1); // empty
}

/* Object type
 */
static int tolua_bnd_type(lua_State* L) {
	tolua_typename(L, lua_gettop(L));
	return 1;
}

static int fast_is(lua_State* L, int self_idx, int name_idx) {
	int result;
	lua_rawgeti(L, self_idx, s_cast<int>(tolua_mt::Super)); // tb
	lua_pushvalue(L, name_idx); // tb name
	lua_rawget(L, -2); // tb[name], tb flag
	result = lua_toboolean(L, -1);
	lua_pop(L, 2);
	return result;
}

/* Type casting
 */
static int tolua_bnd_cast(lua_State* L) {
	void* ptr = tolua_tousertype(L, 1, 0);
	if (ptr && lua_isstring(L, 2)) {
		lua_getmetatable(L, 1); // mt
		if (fast_is(L, -1, 2)) {
			lua_pop(L, 1); // empty
			lua_pushvalue(L, 1); // ud
		} else {
			lua_pop(L, 1); // empty
			lua_pushnil(L); // ud
		}
	} else
		lua_pushnil(L);
	return 1;
}

static int tolua_bnd_setpeer(lua_State* L) {
	/* stack: userdata, table */
	if (!lua_isuserdata(L, -2)) {
		lua_pushstring(L, "invalid argument #1 to setpeer: userdata expected.");
		lua_error(L);
	}
	if (lua_isnil(L, -1)) {
		lua_pop(L, 1);
		lua_pushvalue(L, TOLUA_NOPEER);
	}
	lua_setuservalue(L, -2);
	return 0;
};

static int tolua_bnd_getpeer(lua_State* L) {
	/* stack: userdata */
	lua_getuservalue(L, -1);
	if (lua_rawequal(L, -1, TOLUA_NOPEER)) {
		lua_pop(L, 1);
		lua_pushnil(L);
	}
	return 1;
};

static int tolua_bnd_class(lua_State* L) {
	/* stack: classname */
	luaL_checkstring(L, 1);
	lua_pushvalue(L, 1); // classname
	lua_rawget(L, LUA_REGISTRYINDEX); // reg[classname], mt
	return 1;
}

void tolua_open(lua_State* L) {
	int top = lua_gettop(L);
	lua_pushstring(L, "tolua_opened");
	lua_rawget(L, LUA_REGISTRYINDEX);
	if (!lua_isboolean(L, -1)) {
		lua_pushstring(L, "tolua_opened");
		lua_pushboolean(L, 1);
		lua_rawset(L, LUA_REGISTRYINDEX);
		tolua_newmetatable(L, "tolua_class");
		tolua_module(L, NULL, 0);
		tolua_beginmodule(L, NULL);
		tolua_module(L, "tolua", 0);
		tolua_beginmodule(L, "tolua");
		tolua_function(L, "type", tolua_bnd_type);
		tolua_function(L, "cast", tolua_bnd_cast);
		tolua_function(L, "class", tolua_bnd_class);
		tolua_function(L, "setpeer", tolua_bnd_setpeer);
		tolua_function(L, "getpeer", tolua_bnd_getpeer);
		tolua_endmodule(L);
		tolua_endmodule(L);
	}

	// Setup ubox table and callback table in registry.
	lua_createtable(L, TOLUA_UBOX_START_SIZE, 0);
	lua_newtable(L);
	lua_pushliteral(L, "__mode");
	lua_pushliteral(L, "v");
	lua_rawset(L, -3);
	lua_setmetatable(L, -2);
	lua_rawseti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_UBOX);
	lua_newtable(L);
	lua_rawseti(L, LUA_REGISTRYINDEX, TOLUA_REG_INDEX_CALLBACK);

	lua_settop(L, top);
}

/* Copy a C object
 */
void* tolua_copy(lua_State* L, void* value, unsigned int size) {
	void* clone = r_cast<void*>(malloc(size));
	if (clone)
		memcpy(clone, value, size);
	else
		tolua_error(L, "insuficient memory", NULL);
	return clone;
}

/* Default collect function
 */
int tolua_default_collect(lua_State* tolua_S) {
	void* self = tolua_tousertype(tolua_S, 1, 0);
	free(self);
	return 0;
}

/* Register a usertype
 * It creates the correspoding metatable in the registry, for 'type'.
 */
void tolua_usertype(lua_State* L, const char* type) {
	/* create metatable */
	tolua_newmetatable(L, type);
}

/* Begin module
 * It pushes the module(or class) table on the stack
 */
void tolua_beginmodule(lua_State* L, const char* name) {
	if (name) {
		lua_pushstring(L, name);
		lua_rawget(L, -2);
	} else {
		lua_getglobal(L, BUILTIN_ENV); // builtin
		if (!lua_istable(L, -1)) {
			lua_pop(L, 1);
			lua_newtable(L); // builtin
			lua_pushvalue(L, -1); // builtin builtin
			lua_setglobal(L, BUILTIN_ENV); // _G[BUILTIN_ENV] = builtin, builtin
		}
	}
}

/* End module
 * It pops the module(or class) from the stack
 */
void tolua_endmodule(lua_State* L) {
	lua_pop(L, 1);
}

/* Map module
 * It creates a new module
 */
void tolua_module(lua_State* L, const char* name, int hasvar) {
	if (name) {
		/* global table */
		lua_pushstring(L, name);
		lua_rawget(L, -2);
		/* check if module already exists */
		if (!lua_istable(L, -1)) {
			lua_pop(L, 1);
			lua_newtable(L);
			lua_pushstring(L, name);
			lua_pushvalue(L, -2);
			/* assing module into module */
			lua_rawset(L, -4);
		}
	} else {
		/* get global table */
		lua_getglobal(L, BUILTIN_ENV); // builtin
	}
	if (hasvar) {
		/* check if it already has a module metatable */
		if (!tolua_ismodulemetatable(L)) {
			/* create metatable to get/set C/C++ variable */
			lua_newtable(L);
			tolua_moduleevents(L);
			if (lua_getmetatable(L, -2)) {
				/* set old metatable as metatable of metatable */
				lua_setmetatable(L, -2);
			}
			lua_setmetatable(L, -2);
		}
	}
	lua_pop(L, 1); // pop module
}

static void push_collector(lua_State* L, lua_CFunction col) {
	/* mt */
	if (!col) return;
	lua_pushcfunction(L, col); // mt cfunc
	lua_rawseti(L, -2, s_cast<int>(tolua_mt::Del)); // mt[MT_DEL] = cfunc, mt
}

static void mapself(lua_State* L, const char* name) {
	luaL_getmetatable(L, name); // mt
	lua_rawgeti(L, -1, s_cast<int>(tolua_mt::Super)); // mt super
	lua_pushstring(L, name); // mt tb name
	lua_pushboolean(L, 1); // mt tb name true
	lua_rawset(L, -3); // tb[name] = true, mt tb
	lua_pop(L, 1); // mt
}

/* Map C class
 * It maps a C class, setting the appropriate inheritance and super classes.
 */
void tolua_cclass(lua_State* L, const char* name, const char* lname, const char* base, lua_CFunction col) {
	mapinheritance(L, name, base); // parentModule
	mapsuper(L, name, base); // parentModule mt
	mapself(L, name); // parentModule mt
	push_collector(L, col); // parentModule mt
	lua_pushstring(L, lname); // parentModule mt lname
	lua_insert(L, -2); // parentModule lname mt
	lua_rawset(L, -3); // parentModule[lname] = mt, parentModule
}

/* Add base
 * It adds additional base classes to a class(for multiple inheritance)
 *(not for now)
 */
void tolua_addbase(lua_State* L, char* name, char* base) {
	mapsuper(L, name, base);
}

/* Map function
 * It assigns a function into the current module(or class)
 */
void tolua_function(lua_State* L, const char* name, lua_CFunction func) {
	lua_pushstring(L, name);
	lua_pushcfunction(L, func);
	lua_rawset(L, -3);
}

void tolua_call(lua_State* L, tolua_mt index, lua_CFunction func) {
	lua_pushcfunction(L, func);
	lua_rawseti(L, -2, s_cast<int>(index));
}

/* Map constant number
 * It assigns a constant number into the current module(or class)
 */
void tolua_constant(lua_State* L, const char* name, lua_Integer value) {
	lua_pushstring(L, name);
	tolua_pushinteger(L, value);
	lua_rawset(L, -3);
}

/* Map string
 * It assigns a string into the current module(or class)
 */
void tolua_string(lua_State* L, const char* str) {
	lua_pushstring(L, str);
	lua_pushstring(L, str);
	lua_rawset(L, -3);
}

#ifndef TOLUA_RELEASE
static int tolua_set_readonly(lua_State* L) {
	// 1 self, 2 value
	luaL_error(L, "assign to a readonly field of \"%s\".", tolua_typename(L, 1).c_str().get());
	return 0;
}
#endif

/* Map variable
 * It assigns a variable into the current module(or class)
 */
void tolua_variable(lua_State* L, const char* name, lua_CFunction get, lua_CFunction set) {
	const int GetIndex = s_cast<int>(tolua_mt::Get);
	const int SetIndex = s_cast<int>(tolua_mt::Set);
#ifndef TOLUA_RELEASE
	if (!set) set = tolua_set_readonly;
#endif
	/* get func */
	lua_rawgeti(L, -1, GetIndex);
	if (!lua_istable(L, -1)) {
		/* create .get table, leaving it at the top */
		lua_pop(L, 1);
		lua_newtable(L);
		lua_pushvalue(L, -1);
		lua_rawseti(L, -3, GetIndex);
	}
	lua_pushstring(L, name);
	lua_pushcfunction(L, get);
	lua_rawset(L, -3); // store variable
	lua_pop(L, 1); // pop .get table

	/* set func */
	if (set) {
		lua_rawgeti(L, -1, SetIndex);
		if (!lua_istable(L, -1)) {
			/* create .set table, leaving it at the top */
			lua_pop(L, 1);
			lua_newtable(L);
			lua_pushvalue(L, -1);
			lua_rawseti(L, -3, SetIndex);
		}
		lua_pushstring(L, name);
		lua_pushcfunction(L, set);
		lua_rawset(L, -3); /* store variable */
		lua_pop(L, 1); /* pop .set table */
	}
}

NS_DORA_END

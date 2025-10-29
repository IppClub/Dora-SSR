/* tolua: event functions
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

/* Store at ubox
 * It stores, creating the corresponding table if needed,
 * the pair key/value in the corresponding ubox table
 */
static void storeatubox(lua_State* L, int lo) {
	int type = lua_getuservalue(L, lo);
	if (type <= 0) {
		lua_pop(L, 1);
		lua_newtable(L);
		lua_pushvalue(L, -1);
		lua_setuservalue(L, lo); /* stack: k,v,table  */
	}
	lua_insert(L, -3);
	lua_settable(L, -3); /* on lua 5.1, we trade the "tolua_peers" lookup for a settable call */
	lua_pop(L, 1);
}

/* Module index function
 */
static int module_index_event(lua_State* L) {
	// 1 tb, 2 key
	lua_rawgeti(L, -2, s_cast<int>(tolua_mt::Get)); // tb key get
	if (lua_istable(L, -1)) { // get is table
		lua_pushvalue(L, 2); // tb key get key
		lua_rawget(L, -2); // get[key], tb key get key getter
		if (lua_isfunction(L, -1)) { // getter is function
			lua_call(L, 0, 1); // getter(), tb key get key result
			return 1;
		}
	}
	lua_settop(L, 2); // tb key
	/* act like old index meta event */
	if (lua_getmetatable(L, 1)) { // tb key mt
		lua_pushliteral(L, "__index");
		lua_rawget(L, -2); // mt["__index"], tb key mt index
		if (lua_isfunction(L, -1)) { // index is function
			lua_pushvalue(L, -2); // tb key mt index mt
			lua_pushvalue(L, 2); // tb key mt index mt key
			lua_call(L, 2, 1); // index(mt,key), tb key mt result
			return 1;
		} else if (lua_istable(L, -1)) { // index is table
			lua_pushvalue(L, 2); // tb key mt index key
			lua_gettable(L, -2); // index[key], tb key mt index value
			return 1;
		}
	}
	lua_pushnil(L);
	return 1;
}

/* Module newindex function
 */
static int module_newindex_event(lua_State* L) {
	// 1 tb, 2 key, 3 value
	lua_rawgeti(L, 1, s_cast<int>(tolua_mt::Set)); // tb key value set
	if (lua_istable(L, -1)) { // set is table
		lua_pushvalue(L, 2); // tb key value set key
		lua_rawget(L, -2); // set[key], tb key value set setter
		if (lua_isfunction(L, -1)) { // setter is function
			lua_pushvalue(L, 1); // tb key value set setter tb
			lua_pushvalue(L, 2); // tb key value set setter tb key
			lua_pushvalue(L, 3); // tb key value set setter tb key value
			lua_call(L, 3, 0); // setter(tb,key,value), tb key value set
			return 0;
		}
	}
	// only assign class field in self class
	lua_settop(L, 3); // tb name value
	lua_rawset(L, -3); // tb[name] = value, self
	return 0;
}

/* Class index function
 * If the object is a userdata(ie, an object), it searches the field in
 * the alternative table stored in the corresponding "ubox" table.
 */
static int class_index_event(lua_State* L) {
	const int GetIndex = s_cast<int>(tolua_mt::Get);
	// 1 ud 2 key
	int t = lua_type(L, 1);
	switch (t) {
		case LUA_TUSERDATA:
		case LUA_TLIGHTUSERDATA:
			break;
		case LUA_TTABLE: // __index for ud`s class
			return module_index_event(L);
		default:
			lua_pushnil(L);
			return 1;
	}
	// 1. direct access
	lua_getmetatable(L, 1); // ud key mt
	lua_rawgeti(L, -1, GetIndex); // ud key mt tget
	if (lua_istable(L, -1)) {
		lua_pushvalue(L, 2); // ud key mt tget key
		lua_rawget(L, -2); // tget[key], ud key mt tget cfunc
		if (lua_isfunction(L, -1)) { // check cfunc
			lua_pushvalue(L, 1); // ud key mt tget cfunc ud
			lua_call(L, 1, 1); // return cfunc(ud)
			return 1;
		}
	}
	lua_settop(L, 3); // ud key mt
	/* try class methods */
	lua_pushvalue(L, 2); // ud key mt key
	lua_rawget(L, -2); // mt[key], ud key mt value
	if (!lua_isnil(L, -1)) {
		return 1;
	}
	// 2. search all the super classes
	lua_settop(L, 3);
	/* 1 ud, 2 key, 3 mt */
	lua_pushvalue(L, 3); // ud key mt mt
	while (lua_getmetatable(L, -1)) { // ud key mt basemt super
		lua_remove(L, -2); // ud key mt super
		/* try class fields */
		lua_rawgeti(L, -1, GetIndex); // ud key mt super tget
		if (lua_istable(L, -1)) {
			lua_pushvalue(L, 2); // ud key mt super tget key
			lua_rawget(L, -2); // tget[key], ud key mt super tget cfunc
			if (lua_isfunction(L, -1)) { // check cfunc
				lua_rawgeti(L, 3, GetIndex); // cfunc tget
				if (!lua_toboolean(L, -1)) { // not tget
					lua_pop(L, 1); // cfunc
					lua_newtable(L); // cfunc tb
					lua_pushvalue(L, -1); // cfunc tb tb
					lua_rawseti(L, 3, GetIndex); // mt[MT_GET] = tb, cfunc tb
				}
				lua_pushvalue(L, 2); // cfunc tget key
				lua_pushvalue(L, -3); // cfunc tget key cfunc
				lua_rawset(L, -3); // tget[key] = cfunc, cfunc tget
				lua_pop(L, 1); // cfunc
				lua_pushvalue(L, 1); // cfunc ud
				lua_call(L, 1, 1); // return cfunc(ud)
				return 1;
			}
		}
		lua_settop(L, 4); // ud key mt super
		/* try class methods */
		lua_pushvalue(L, 2); // ud key mt super key
		lua_rawget(L, -2); // super[key], ud key mt super value
		if (!lua_isnil(L, -1)) {
			lua_pushvalue(L, 2); // ud key mt super value key
			lua_pushvalue(L, -2); // ud key mt super value key value
			lua_rawset(L, 3); // mt[key] = value, ud key mt super value
			return 1;
		} else {
			lua_pop(L, 1); // ud key mt super
		}
	}
	// 3. finally, retrieval of the user field
	if (t == LUA_TUSERDATA) {
		lua_settop(L, 2); // ud key
		/* try peer table */
		if (lua_getuservalue(L, 1) == LUA_TTABLE) { // peer
			lua_pushvalue(L, 2); // peer key
			lua_gettable(L, -2); // peer[key], peer value
			if (!lua_isnil(L, -1)) { // value != nil
				return 1;
			}
		}
	}
	lua_pushnil(L);
	return 1;
}

/* Newindex function
 * It first searches for a C/C++ varaible to be set.
 * Then, it either stores it in the alternative ubox table(in the case it is
 * an object) or in the own table(that represents the class or module).
 */
static int class_newindex_event(lua_State* L) {
	const int SetIndex = s_cast<int>(tolua_mt::Set);
	// 1 ud, 2 key, 3 value
	int t = lua_type(L, 1);
	switch (t) {
		case LUA_TUSERDATA:
		case LUA_TLIGHTUSERDATA:
			break;
		case LUA_TTABLE: // __newindex for ud`s class
			return module_newindex_event(L);
		default:
			return 0;
	}
	// 1. direct access
	lua_getmetatable(L, 1); // ud key value mt
	lua_rawgeti(L, -1, SetIndex); // ud key value mt tset
	if (lua_istable(L, -1)) {
		lua_pushvalue(L, 2); // ud key value mt tset key
		lua_rawget(L, -2); // tset[key], ud key value mt tset cfunc
		if (lua_isfunction(L, -1)) { // check cfunc
			lua_rawgeti(L, 4, SetIndex); // cfunc tset
			if (!lua_toboolean(L, -1)) { // no tset
				lua_pop(L, 1); // cfunc
				lua_newtable(L); // cfunc tset
				lua_pushvalue(L, -1); // cfunc tset tset
				lua_rawseti(L, 4, SetIndex); // mt[MT_SET] = tset, cfunc tset
			}
			lua_pushvalue(L, 2); // cfunc tset key
			lua_pushvalue(L, -3); // cfunc tset key cfunc
			lua_rawset(L, -3); // tset[key] = cfunc, cfunc tset
			lua_pop(L, 1); // cfunc
			lua_pushvalue(L, 1); // cfunc ud
			lua_pushvalue(L, 3); // cfunc ud value
			lua_call(L, 2, 0);
			return 0;
		}
		lua_pop(L, 1); // ud key value mt tset
	}
	// 2. search all the super classes
	lua_pop(L, 1); // ud key value mt
	if (!lua_getmetatable(L, -1)) { // ud key value mt super
		lua_pushnil(L);
	}
	lua_pushvalue(L, -1); // ud key value mt super
	while (lua_istable(L, -1)) { // super is table
		lua_rawgeti(L, -1, SetIndex); // ud key value mt super tset
		if (lua_istable(L, -1)) {
			lua_pushvalue(L, 2); // ud key value mt super tset key
			lua_rawget(L, -2); // ud key value mt super tset cfunc
			if (lua_isfunction(L, -1)) {
				lua_rawgeti(L, 4, SetIndex); // cfunc set
				if (!lua_toboolean(L, -1)) { // no tset
					lua_pop(L, 1); // cfunc
					lua_newtable(L); // cfunc tset
					lua_pushvalue(L, -1); // cfunc tset tset
					lua_rawseti(L, 4, SetIndex); // mt[MT_SET] = tset, cfunc tset
				}
				lua_pushvalue(L, 2); // cfunc tset key
				lua_pushvalue(L, -3); // cfunc tset key cfunc
				lua_rawset(L, -3); // tset[key] = cfunc, cfunc tset
				lua_pop(L, 1); // cfunc
				lua_pushvalue(L, 1); // cfunc ud
				lua_pushvalue(L, 3); // cfunc ud value
				lua_call(L, 2, 0);
				return 0;
			}
			lua_pop(L, 1); // ud key value mt super tset
		}
		lua_pop(L, 1); // ud key value mt super
		if (!lua_getmetatable(L, -1)) { // ud key value mt super new_super
			lua_pushnil(L);
		}
		lua_remove(L, -2); // ud key value mt new_super
	}
	lua_settop(L, 3); // ud key value
	// 3. finally, store as a new user field
	if (t == LUA_TUSERDATA) {
		storeatubox(L, 1);
	} else {
		luaL_error(L, "can not add custom field to a light user data object.");
	}
	return 0;
}

static int class_call_event(lua_State* L) {
	if (lua_istable(L, 1)) {
		lua_rawgeti(L, 1, s_cast<int>(tolua_mt::Call));
		if (lua_isfunction(L, -1)) {
			lua_insert(L, 1);
			lua_call(L, lua_gettop(L) - 1, 1);
			return 1;
		}
	}
	tolua_error(L, "attempt to call a non-callable object.", NULL);
	return 0;
}

static int do_operator(lua_State* L, tolua_mt op) {
	if (lua_isuserdata(L, 1)) {
		/* Try metatables */
		lua_pushvalue(L, 1); /* stack: op1 op2 */
		while (lua_getmetatable(L, -1)) {
			/* stack: op1 op2 op1 mt */
			lua_remove(L, -2); /* stack: op1 op2 mt */
			lua_rawgeti(L, -1, s_cast<int>(op)); /* stack: obj key mt func */
			if (lua_isfunction(L, -1)) {
				lua_pushvalue(L, 1);
				lua_pushvalue(L, 2);
				lua_call(L, 2, 1);
				return 1;
			}
			lua_settop(L, 3);
		}
	}
	tolua_error(L, "attempt to perform operation on an invalid operand", NULL);
	return 0;
}

static int class_add_event(lua_State* L) {
	return do_operator(L, tolua_mt::Add);
}

static int class_sub_event(lua_State* L) {
	return do_operator(L, tolua_mt::Sub);
}

static int class_mul_event(lua_State* L) {
	return do_operator(L, tolua_mt::Mul);
}

static int class_div_event(lua_State* L) {
	return do_operator(L, tolua_mt::Div);
}

static int class_lt_event(lua_State* L) {
	return do_operator(L, tolua_mt::Lt);
}

static int class_le_event(lua_State* L) {
	return do_operator(L, tolua_mt::Le);
}

static int class_eq_event(lua_State* L) {
	/* copying code from do_operator here to return false when no operator is found */
	if (lua_isuserdata(L, 1)) {
		/* Try metatables */
		lua_pushvalue(L, 1); /* stack: op1 op2 */
		while (lua_getmetatable(L, -1)) { /* stack: op1 op2 op1 mt */
			lua_remove(L, -2); /* stack: op1 op2 mt */
			lua_rawgeti(L, -1, s_cast<int>(tolua_mt::Eq)); /* stack: obj key mt func */
			if (lua_isfunction(L, -1)) {
				lua_pushvalue(L, 1);
				lua_pushvalue(L, 2);
				lua_call(L, 2, 1);
				return 1;
			}
			lua_settop(L, 3);
		}
	}
	lua_settop(L, 3);
	lua_pushboolean(L, 0);
	return 1;
}

static int class_gc_event(lua_State* L) {
	lua_getmetatable(L, 1);
	lua_rawgeti(L, -1, s_cast<int>(tolua_mt::Del)); // stack: mt collector
	if (lua_isfunction(L, -1)) {
		lua_pushvalue(L, 1); // stack: mt collector u
		lua_call(L, 1, 0);
	}
	lua_pop(L, 1);
	return 0;
}

static int class_tostring_event(lua_State* L) {
	tolua_typename(L, 1);
	return 1;
}

/* Register module events
 * It expects the metatable on the top of the stack
 */
void tolua_moduleevents(lua_State* L) {
	lua_pushliteral(L, "__index");
	lua_pushcfunction(L, module_index_event);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__newindex");
	lua_pushcfunction(L, module_newindex_event);
	lua_rawset(L, -3);
}

/* Check if the object on the top has a module metatable
 */
int tolua_ismodulemetatable(lua_State* L) {
	int r = 0;
	if (lua_getmetatable(L, -1)) {
		lua_pushliteral(L, "__index");
		lua_rawget(L, -2);
		r = lua_tocfunction(L, -1) == module_index_event ? 1 : 0;
		lua_pop(L, 2);
	}
	return r;
}

/* Register class events
 * It expects the metatable on the top of the stack
 */
void tolua_classevents(lua_State* L) {
	lua_pushliteral(L, "__index");
	lua_pushcfunction(L, class_index_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__newindex");
	lua_pushcfunction(L, class_newindex_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__add");
	lua_pushcfunction(L, class_add_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__sub");
	lua_pushcfunction(L, class_sub_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__mul");
	lua_pushcfunction(L, class_mul_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__div");
	lua_pushcfunction(L, class_div_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__lt");
	lua_pushcfunction(L, class_lt_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__le");
	lua_pushcfunction(L, class_le_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__eq");
	lua_pushcfunction(L, class_eq_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__call");
	lua_pushcfunction(L, class_call_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__gc");
	lua_pushcfunction(L, class_gc_event);
	lua_rawset(L, -3);

	lua_pushliteral(L, "__tostring");
	lua_pushcfunction(L, class_tostring_event);
	lua_rawset(L, -3);
}

NS_DORA_END


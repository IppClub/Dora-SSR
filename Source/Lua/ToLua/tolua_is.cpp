/* tolua: functions to check types.
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

/* a fast check if a is b, without parameter validation
 i.e. if b is equal to a or a superclass of a. */
int tolua_fast_isa(lua_State* L, int mt_indexa, int mt_indexb) {
	int result = 1;
	if (!lua_rawequal(L, mt_indexa, mt_indexb)) {
		lua_rawgeti(L, mt_indexa, s_cast<int>(tolua_mt::Super)); // super
		lua_pushvalue(L, mt_indexb); // super mtb
		lua_rawget(L, LUA_REGISTRYINDEX); // super typeb
		lua_rawget(L, -2); // super[typeb], super flag
		result = lua_toboolean(L, -1);
		lua_pop(L, 2);
	}
	return result;
}

/* Push and returns the corresponding object typename */
Slice tolua_typename(lua_State* L, int lo) {
	int tag = lua_type(L, lo);
	if (tag == LUA_TNONE) {
		tolua_pushslice(L, "[no object]"_slice);
	} else if (tag != LUA_TUSERDATA && tag != LUA_TLIGHTUSERDATA && tag != LUA_TTABLE) {
		lua_pushstring(L, lua_typename(L, tag));
	} else if (tag == LUA_TUSERDATA || tag == LUA_TLIGHTUSERDATA) {
		if (!lua_getmetatable(L, lo)) // mt
		{
			lua_pop(L, 1); // empty
			lua_pushstring(L, lua_typename(L, tag)); // result
		} else {
			lua_rawget(L, LUA_REGISTRYINDEX); // reg[mt], name
			if (!lua_isstring(L, -1)) {
				lua_pop(L, 1); // empty
				tolua_pushslice(L, "[undefined]"_slice); // result
			}
		}
	} else { // is table
		lua_pushvalue(L, lo); // tb
		lua_rawget(L, LUA_REGISTRYINDEX); // reg[tb], name
		if (!lua_isstring(L, -1)) { // name is string
			lua_pop(L, 1); // empty
			tolua_pushslice(L, "table"_slice); // result
		} else {
			tolua_pushslice(L, "class "_slice); // name "class "
			lua_insert(L, -2); // "class " name
			lua_concat(L, 2); // "class "..name
		}
	}
	return tolua_toslice(L, -1, nullptr);
}

void tolua_error(lua_State* L, const char* msg, tolua_Error* err) {
	if (msg[0] == '#') {
		std::string expected = err->type.toString();
		if (msg[1] == 'f') {
			int narg = err->index;
			if (err->array) {
				std::string provided = tolua_typename(L, err->array).toString();
				luaL_error(L, "%s\nargument %d is array of '%s', array of '%s' expected",
					msg + 2, narg, provided.c_str(), expected.c_str());
			} else {
				std::string provided = tolua_typename(L, err->index).toString();
				luaL_error(L, "%s\nargument %d is '%s', '%s' expected",
					msg + 2, narg, provided.c_str(), expected.c_str());
			}
		} else if (msg[1] == 'v') {
			if (err->array) {
				std::string provided = tolua_typename(L, err->array).toString();
				luaL_error(L, "%s\nvalue is array of '%s', array of '%s' expected",
					msg + 2, provided.c_str(), expected.c_str());
			} else {
				std::string provided = tolua_typename(L, err->index).toString();
				luaL_error(L, "%s\nvalue is '%s', '%s' expected",
					msg + 2, provided.c_str(), expected.c_str());
			}
		}
	} else
		luaL_error(L, msg);
}

/* the equivalent of lua_is* for usertable */
static bool tolua_check_usertable(lua_State* L, int lo, String type) {
	bool r = false;
	if (lo < 0) lo = lua_gettop(L) + lo + 1;
	lua_pushvalue(L, lo);
	lua_rawget(L, LUA_REGISTRYINDEX); /* get registry[t] */
	if (lua_isstring(L, -1)) {
		r = (tolua_toslice(L, -1, nullptr) == type);
	}
	lua_pop(L, 1);
	return r;
}

/* the equivalent of lua_is* for usertype */
int tolua_istype(lua_State* L, int lo, String type) {
	if (!lua_isuserdata(L, lo)) return 0;
	/* check if it is of the same type */
	if (lua_getmetatable(L, lo)) /* if metatable? */
	{
		lua_rawget(L, LUA_REGISTRYINDEX); /* get registry[mt] */
		Slice tn = tolua_toslice(L, -1, nullptr);
		bool r = (tn == type);
		lua_pop(L, 1);
		if (r)
			return 1;
		else {
			/* check if it is a specialized class */
			lua_getmetatable(L, lo); // mt
			lua_rawgeti(L, -1, s_cast<int>(tolua_mt::Super)); // mt tb
			if (lua_istable(L, -1)) {
				tolua_pushslice(L, type); // mt tb type
				lua_rawget(L, -2); // tb[type], mt tb flag
				bool b = lua_toboolean(L, -1) != 0;
				lua_pop(L, 3);
				if (b) return 1;
			}
		}
	}
	return 0;
}

int tolua_isnoobj(lua_State* L, int lo, tolua_Error* err) {
	if (lua_gettop(L) < abs(lo)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = "[no object]"_slice;
	return 0;
}

int tolua_isboolean(lua_State* L, int lo, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (lua_isnil(L, lo) || lua_isboolean(L, lo)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = "boolean"_slice;
	return 0;
}

int tolua_isnumber(lua_State* L, int lo, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (lua_isnumber(L, lo)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = "number"_slice;
	return 0;
}

int tolua_isinteger(lua_State* L, int lo, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (lua_isinteger(L, lo)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = "integer"_slice;
	return 0;
}

int tolua_isstring(lua_State* L, int lo, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (lua_isstring(L, lo)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = "string"_slice;
	return 0;
}

int tolua_istable(lua_State* L, int lo, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (lua_istable(L, lo)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = "table"_slice;
	return 0;
}

int tolua_isusertable(lua_State* L, int lo, String type, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (tolua_check_usertable(L, lo, type)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = type;
	return 0;
}

int tolua_isuserdata(lua_State* L, int lo, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (lua_isnil(L, lo) || lua_isuserdata(L, lo)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = "userdata"_slice;
	return 0;
}

int tolua_isvaluenil(lua_State* L, int lo, tolua_Error* err) {
	if (lua_gettop(L) < abs(lo)) return 0; // somebody else should check this
	if (!lua_isnil(L, lo)) return 0;
	err->index = lo;
	err->array = 0;
	err->type = "value"_slice;
	return 1;
};

int tolua_isvalue(lua_State* L, int lo, int def, tolua_Error* err) {
	if (def || abs(lo) <= lua_gettop(L)) return 1; // any valid index
	err->index = lo;
	err->array = 0;
	err->type = "value"_slice;
	return 0;
}

int tolua_isobject(lua_State* L, int lo, String type, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (lua_isnil(L, lo) || tolua_istype(L, lo, type)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = type;
	return 0;
}

int tolua_isusertype(lua_State* L, int lo, String type, int def, tolua_Error* err) {
	if (def && lua_gettop(L) < abs(lo)) return 1;
	if (tolua_istype(L, lo, type)) return 1;
	err->index = lo;
	err->array = 0;
	err->type = type;
	return 0;
}

int tolua_isvaluearray(lua_State* L, int lo, int dim, int def, tolua_Error* err) {
	if (!tolua_istable(L, lo, def, err))
		return 0;
	else
		return 1;
}

int tolua_isbooleanarray(lua_State* L, int lo, int dim, int def, tolua_Error* err) {
	if (!tolua_istable(L, lo, def, err)) {
		return 0;
	} else {
		int i;
		for (i = 1; i <= dim; ++i) {
			lua_pushnumber(L, i);
			lua_gettable(L, lo);
			if (!(lua_isnil(L, -1) || lua_isboolean(L, -1)) && !(def && lua_isnil(L, -1))) {
				err->index = lo;
				err->array = 1;
				err->type = "boolean"_slice;
				return 0;
			}
			lua_pop(L, 1);
		}
	}
	return 1;
}

int tolua_isnumberarray(lua_State* L, int lo, int dim, int def, tolua_Error* err) {
	if (!tolua_istable(L, lo, def, err)) {
		return 0;
	} else {
		int i;
		for (i = 1; i <= dim; ++i) {
			lua_pushnumber(L, i);
			lua_gettable(L, lo);
			if (!lua_isnumber(L, -1) && !(def && lua_isnil(L, -1))) {
				err->index = lo;
				err->array = 1;
				err->type = "number"_slice;
				return 0;
			}
			lua_pop(L, 1);
		}
	}
	return 1;
}

int tolua_isintegerarray(lua_State* L, int lo, int dim, int def, tolua_Error* err) {
	if (!tolua_istable(L, lo, def, err)) {
		return 0;
	} else {
		int i;
		for (i = 1; i <= dim; ++i) {
			lua_pushnumber(L, i);
			lua_gettable(L, lo);
			if (!lua_isinteger(L, -1) && !(def && lua_isnil(L, -1))) {
				err->index = lo;
				err->array = 1;
				err->type = "integer"_slice;
				return 0;
			}
			lua_pop(L, 1);
		}
	}
	return 1;
}

int tolua_isstringarray(lua_State* L, int lo, int dim, int def, tolua_Error* err) {
	if (!tolua_istable(L, lo, def, err)) {
		return 0;
	} else {
		int i;
		for (i = 1; i <= dim; ++i) {
			lua_pushnumber(L, i);
			lua_gettable(L, lo);
			if (!lua_isstring(L, -1) && !(def && lua_isnil(L, -1))) {
				err->index = lo;
				err->array = 1;
				err->type = "string"_slice;
				return 0;
			}
			lua_pop(L, 1);
		}
	}
	return 1;
}

int tolua_istablearray(lua_State* L, int lo, int dim, int def, tolua_Error* err) {
	if (!tolua_istable(L, lo, def, err)) {
		return 0;
	} else {
		int i;
		for (i = 1; i <= dim; ++i) {
			lua_pushnumber(L, i);
			lua_gettable(L, lo);
			if (!lua_istable(L, -1) && !(def && lua_isnil(L, -1))) {
				err->index = lo;
				err->array = 1;
				err->type = "table"_slice;
				return 0;
			}
			lua_pop(L, 1);
		}
	}
	return 1;
}

int tolua_isusertypearray(lua_State* L, int lo, String type, int dim, int def, tolua_Error* err) {
	if (!tolua_istable(L, lo, def, err)) {
		return 0;
	} else {
		int i;
		for (i = 1; i <= dim; ++i) {
			lua_pushnumber(L, i);
			lua_gettable(L, lo);
			if (!tolua_istype(L, -1, type) && !(def && lua_isnil(L, -1))) {
				err->index = lo;
				err->type = type;
				err->array = lua_gettop(L);
				return 0;
			}
			lua_pop(L, 1);
		}
	}
	return 1;
}

NS_DORA_END

/* tolua
** Support code for Lua bindings.
** Written by Waldemar Celes, modified by Jin Li, 2020
** TeCGraf/PUC-Rio
** Apr 2003, Apr 2014
** $Id: $
*/

/* This code is free software; you can redistribute it and/or modify it.
** The software provided hereunder is on an "as is" basis, and
** the author has no obligation to provide maintenance, support, updates,
** enhancements, or modifications.
*/

#pragma once

#include "lua.hpp"

NS_DOROTHY_BEGIN

#ifndef TEMPLATE_BIND
	#define TEMPLATE_BIND(p)
#endif

#define TOLUA_TEMPLATE_BIND(p)

#define TOLUA_PROTECTED_DESTRUCTOR
#define TOLUA_PROPERTY_TYPE(p)

#define MT_DEL 1
#define MT_CALL 2
#define MT_SUPER 3
#define MT_GET 4
#define MT_SET 5
#define MT_EQ 6
#define MT_ADD 7
#define MT_SUB 8
#define MT_MUL 9
#define MT_DIV 10
#define MT_LT 11
#define MT_LE 12

#define TOLUA_REG_INDEX_UBOX LUA_RIDX_LAST+1
#define TOLUA_REG_INDEX_CALLBACK LUA_RIDX_LAST+2
#define TOLUA_REG_INDEX_TYPE LUA_RIDX_LAST+3

#define TOLUA_UBOX_START_SIZE 4096

typedef int lua_Object;

struct tolua_Error
{
    int index;
    int array;
    Slice type;
};
typedef struct tolua_Error tolua_Error;

#define TOLUA_NOPEER LUA_REGISTRYINDEX

class Object;

Slice tolua_typename(lua_State* L, int lo);
void tolua_error(lua_State* L, const char* msg, tolua_Error* err);
int tolua_isnoobj(lua_State* L, int lo, tolua_Error* err);
int tolua_isvalue(lua_State* L, int lo, int def, tolua_Error* err);
int tolua_isvaluenil(lua_State* L, int lo, tolua_Error* err);
int tolua_isboolean(lua_State* L, int lo, int def, tolua_Error* err);
int tolua_isnumber(lua_State* L, int lo, int def, tolua_Error* err);
int tolua_isinteger(lua_State* L, int lo, int def, tolua_Error* err);
int tolua_isstring(lua_State* L, int lo, int def, tolua_Error* err);
int tolua_istable(lua_State* L, int lo, int def, tolua_Error* err);
int tolua_isusertable(lua_State* L, int lo, String type, int def, tolua_Error* err);
int tolua_isuserdata(lua_State* L, int lo, int def, tolua_Error* err);
int tolua_istype(lua_State* L, int lo, String type);
int tolua_isusertype(lua_State* L, int lo, String type, int def, tolua_Error* err);
int tolua_isvaluearray(lua_State* L, int lo, int dim, int def, tolua_Error* err);
int tolua_isbooleanarray(lua_State* L, int lo, int dim, int def, tolua_Error* err);
int tolua_isnumberarray(lua_State* L, int lo, int dim, int def, tolua_Error* err);
int tolua_isintegerarray(lua_State* L, int lo, int dim, int def, tolua_Error* err);
int tolua_isstringarray(lua_State* L, int lo, int dim, int def, tolua_Error* err);
int tolua_istablearray(lua_State* L, int lo, int dim, int def, tolua_Error* err);
int tolua_isuserdataarray(lua_State* L, int lo, int dim, int def, tolua_Error* err);
int tolua_isusertypearray(lua_State* L, int lo, String type, int dim, int def, tolua_Error* err);

void tolua_open(lua_State* L);

void* tolua_copy(lua_State* L, void* value, unsigned int size);
int tolua_default_collect(lua_State* tolua_S);

void tolua_usertype(lua_State* L, const char* type);
void tolua_beginmodule(lua_State* L, const char* name);
void tolua_endmodule(lua_State* L);
void tolua_module(lua_State* L, const char* name, int hasvar);
void tolua_cclass(lua_State* L, const char* name, const char* lname, const char* base, lua_CFunction col);
void tolua_function(lua_State* L, const char* name, lua_CFunction func);
void tolua_call(lua_State* L, int index, lua_CFunction func);
void tolua_constant(lua_State* L, const char* name, lua_Integer value);
void tolua_string(lua_State* L, const char* str);
void tolua_variable(lua_State* L, const char* name, lua_CFunction get, lua_CFunction set);

/* void tolua_set_call_event(lua_State* L, lua_CFunction func, char* type); */
void tolua_addbase(lua_State* L, char* name, char* base);

void tolua_pushvalue(lua_State* L, int lo);
void tolua_pushboolean(lua_State* L, int value);
void tolua_pushnumber(lua_State* L, lua_Number value);
void tolua_pushinteger(lua_State* L, lua_Integer value);
void tolua_pushstring(lua_State* L, const char* value);
void tolua_pushstring(lua_State* L, const char* value, size_t len);
void tolua_pushusertype(lua_State* L, void* value, int typeId);
void tolua_pushfieldvalue(lua_State* L, int lo, int index, int v);
void tolua_pushfieldboolean(lua_State* L, int lo, int index, int v);
void tolua_pushfieldnumber(lua_State* L, int lo, int index, lua_Number v);
void tolua_pushfieldinteger(lua_State* L, int lo, int index, lua_Integer v);
void tolua_pushfieldstring(lua_State* L, int lo, int index, const char* v);
void tolua_pushfieldusertype(lua_State* L, int lo, int index, void* v, int typeId);
void tolua_pushobject(lua_State* L, Object* object);

lua_Number tolua_tonumber(lua_State* L, int narg, lua_Number def);
lua_Integer tolua_tointeger(lua_State* L, int narg, lua_Integer def);
const char* tolua_tostring(lua_State* L, int narg, const char* def);
void* tolua_tousertype(lua_State* L, int narg, void* def);
int tolua_tovalue(lua_State* L, int narg, int def);
bool tolua_toboolean(lua_State* L, int narg, int def);
lua_Number tolua_tofieldnumber(lua_State* L, int lo, int index, lua_Number def);
lua_Integer tolua_tofieldinteger(lua_State* L, int lo, int index, lua_Integer def);
const char* tolua_tofieldstring(lua_State* L, int lo, int index, const char* def);
void* tolua_tofielduserdata(lua_State* L, int lo, int index, void* def);
void* tolua_tofieldusertype(lua_State* L, int lo, int index, void* def);
int tolua_tofieldvalue(lua_State* L, int lo, int index, int def);
int tolua_getfieldboolean(lua_State* L, int lo, int index, int def);

void tolua_dobuffer(lua_State* L, char* B, unsigned int size, const char* name);

int tolua_collect_object(lua_State* tolua_S);

inline const char* tolua_tocppstring(lua_State* L, int narg, const char* def)
{
    const char* s = tolua_tostring(L, narg, def);
    return s ? s : "";
}

inline const char* tolua_tofieldcppstring(lua_State* L, int lo, int index, const char* def)
{
    const char* s = tolua_tofieldstring(L, lo, index, def);
    return s ? s : "";
}

int tolua_fast_isa(lua_State *L, int mt_indexa, int mt_indexb);
int tolua_isobject(lua_State* L, int mt_idx);
void tolua_typeid(lua_State *L, int typeId, const char* className);

/* tolua_fix */
int tolua_ref_function(lua_State* L, int lo);
void tolua_get_function_by_refid(lua_State* L, int refid);
void tolua_remove_function_by_refid(lua_State* L, int refid);
int tolua_isfunction(lua_State* L, int lo, tolua_Error* err);
void tolua_stack_dump(lua_State* L, int offset, const char* label);
int tolua_get_callback_ref_count();
int tolua_get_max_callback_ref_count();
Slice tolua_toslice(lua_State* L, int narg, const char* def);
#define tolua_isslice tolua_isstring
void tolua_pushslice(lua_State* L, String str);
#define tolua_isslicearray tolua_isstringarray
Slice tolua_tofieldslice(lua_State* L, int lo, int index, const char* def);

#ifndef Mtolua_new
	#define Mtolua_new(EXP) new EXP
#endif

#ifndef Mtolua_delete
	#define Mtolua_delete(EXP) delete EXP
#endif

#ifndef Mtolua_new_dim
	#define Mtolua_new_dim(EXP, len) r_cast<EXP*>(alloca(sizeof(EXP)*len)) // new EXP[len]
#endif

#ifndef Mtolua_delete_dim
	#define Mtolua_delete_dim(EXP) // delete [] EXP
#endif

#ifndef tolua_outside
	#define tolua_outside
#endif

#ifndef tolua_owned
	#define tolua_owned
#endif

#ifndef Mtolua_typeid
	#define Mtolua_typeid(L,type,name) tolua_typeid(L,LuaType<type>(),name)
#endif

#define TOLUA_API
#define _cstring const char*

NS_DOROTHY_END

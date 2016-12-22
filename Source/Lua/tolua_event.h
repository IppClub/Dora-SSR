/* tolua: event functions
** Support code for Lua bindings.
** Written by Waldemar Celes, modified by Jin Li
** TeCGraf/PUC-Rio
** Apr 2003, Apr 2014
** $Id: $
*/

/* This code is free software; you can redistribute it and/or modify it.
** The software provided hereunder is on an "as is" basis, and
** the author has no obligation to provide maintenance, support, updates,
** enhancements, or modifications.
*/

#ifndef __DOROTHY_LUA_TOLUA_EVENT_H__
#define __DOROTHY_LUA_TOLUA_EVENT_H__

#include "tolua++.h"

NS_DOROTHY_BEGIN

void tolua_moduleevents(lua_State* L);
int tolua_ismodulemetatable(lua_State* L);
void tolua_classevents(lua_State* L);

NS_DOROTHY_END

#endif // __DOROTHY_LUA_TOLUA_EVENT_H__

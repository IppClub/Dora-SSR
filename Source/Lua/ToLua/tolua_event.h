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

#pragma once

#include "Lua/ToLua/tolua++.h"

NS_DORA_BEGIN

void tolua_moduleevents(lua_State* L);
int tolua_ismodulemetatable(lua_State* L);
void tolua_classevents(lua_State* L);

NS_DORA_END

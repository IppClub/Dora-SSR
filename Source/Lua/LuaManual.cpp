/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Dorothy.h"
#include "Lua/ToLua/tolua++.h"

NS_DOROTHY_BEGIN

/* Event */

int dora_emit(lua_State* L)
{
	int top = lua_gettop(L);
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(L, 1, 0, &tolua_err))
	{
		tolua_error(L, "#vinvalid type in variable assignment", &tolua_err);
	}
#endif
	Slice name = tolua_toslice(L, 1, nullptr);
	LuaEventArgs::send(name, top - 1);
	return 0;
}

/* Content */

void __Content_loadFile(lua_State* L, Content* self, String filename)
{
	OwnArray<Uint8> data = self->loadFile(filename);
	if (data) lua_pushlstring(L, r_cast<char*>(data.get()), data.size());
	else lua_pushnil(L);
}

void __Content_getDirEntries(lua_State* L, Content* self, String path, bool isFolder)
{
	auto dirs = self->getDirEntries(path, isFolder);
	lua_createtable(L, (int)dirs.size(), 0);
	for (int i = 0; i < (int)dirs.size(); i++)
	{
		lua_pushstring(L, dirs[i].c_str());
		lua_rawseti(L, -2, i+1);
	}
}

void Content_setSearchPaths(Content* self, Slice paths[], int length)
{
	vector<string> searchPaths(length);
	for (int i = 0; i < length; i++)
	{
		searchPaths[i] = paths[i];
	}
	self->setSearchPaths(searchPaths);
}

/* Node */

int Node_emit(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(L, 1, "Node", 0, &tolua_err) ||
		!tolua_isstring(L, 2, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		Node* self = (Node*)tolua_tousertype(L, 1, 0);
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'CCNode_emit'", NULL);
#endif
		Slice name = tolua_toslice(L, 2, 0);
		int top = lua_gettop(L);
		LuaEventArgs luaEvent(name, top - 2);
		self->emit(&luaEvent);
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'emit'.", &tolua_err);
	return 0;
#endif
}

int Node_slot(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(L, 1, "Node", 0, &tolua_err) ||
		!tolua_isstring(L, 2, 0, &tolua_err) ||
		!(tolua_isfunction(L, 3, &tolua_err) ||
			lua_isnil(L, 3) ||
			tolua_isnoobj(L, 3, &tolua_err)) ||
		!tolua_isnoobj(L, 4, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		Node* self = (Node*)tolua_tousertype(L, 1, 0);
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'CCNode_slot'", NULL);
#endif
		Slice name = tolua_toslice(L, 2, 0);
		if (lua_isfunction(L, 3))
		{
			int handler = tolua_ref_function(L, 3);
			self->slot(name, LuaFunction(handler));
			return 0;
		}
		else if (lua_isnil(L, 3))
		{
			self->slot(name, nullptr);
			return 0;
		}
		else tolua_pushobject(L, self->slot(name));
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'slot'.", &tolua_err);
	return 0;
#endif
}

int Node_gslot(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(L, 1, "Node", 0, &tolua_err) ||
		!(tolua_isstring(L, 2, 0, &tolua_err) ||
			tolua_isusertype(L, 2, "GSlot", 0, &tolua_err)) ||
		!(tolua_isfunction(L, 3, &tolua_err) ||
			lua_isnil(L, 3) ||
			tolua_isnoobj(L, 3, &tolua_err)) ||
		!tolua_isnoobj(L, 4, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		Node* self = (Node*)tolua_tousertype(L, 1, 0);
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_gslot'", NULL);
#endif
		if (lua_isstring(L, 2))
		{
			Slice name = tolua_toslice(L, 2, 0);
			if (lua_isfunction(L, 3)) // set
			{
				int handler = tolua_ref_function(L, 3);
				Listener* listener =self->gslot(name, LuaFunction(handler));
				tolua_pushobject(L, listener);
				return 1;
			}
			else if (lua_gettop(L) < 3) // get
			{
				RefVector<Listener> gslots = self->gslot(name);
				if (!gslots.empty())
				{
					int size = s_cast<int>(gslots.size());
					lua_createtable(L, size, 0);
					for (int i = 0; i < size; i++)
					{
						tolua_pushobject(L, gslots[i]);
						lua_rawseti(L, -2, i + 1);
					}
				}
				else lua_pushnil(L);
				return 1;
			}
			else if (lua_isnil(L, 3))// del
			{
				self->gslot(name, nullptr);
				return 0;
			}
		}
		else
		{
			Listener* listener = r_cast<Listener*>(tolua_tousertype(L, 2, 0));
			self->gslot(listener, nullptr);
			return 0;
		}
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'gslot'.", &tolua_err);
#endif
	return 0;
}

NS_DOROTHY_END

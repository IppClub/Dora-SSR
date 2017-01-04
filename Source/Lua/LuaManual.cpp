/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/LuaEngine.h"
#include "Lua/ToLua/tolua++.h"

NS_DOROTHY_BEGIN

/* Content */

void __Content_loadFile(lua_State* L, Content* self, const char* filename)
{
	Sint64 size = 0;
	OwnArray<Uint8> data = self->loadFile(filename, size);
	if (data) lua_pushlstring(L, r_cast<char*>(data.get()), (size_t)size);
	else lua_pushnil(L);
}

void __Content_getDirEntries(lua_State* L, Content* self, const char* path, bool isFolder)
{
	auto dirs = self->getDirEntries(path, isFolder);
	lua_createtable(L, (int)dirs.size(), 0);
	for (int i = 0; i < (int)dirs.size(); i++)
	{
		lua_pushstring(L, dirs[i].c_str());
		lua_rawseti(L, -2, i+1);
	}
}

void Content_setSearchPaths(Content* self, char* paths[], int length)
{
	vector<string> searchPaths(length);
	for (int i = 0; i < length; i++)
	{
		searchPaths[i] = paths[i];
	}
	self->setSearchPaths(searchPaths);
}

void Content_loadFileAsync(Content* self, String filename, int handler)
{
	LuaFunctor func(handler);
	string file(filename);
	self->loadFileAsync(filename, [file,func](OwnArray<Uint8> data, Sint64 size)
	{
		Slice str(r_cast<char*>(data.get()), size);
		func(file,str);
	});
}

void Content_copyFileAsync(Content* self, String src, String dst, int handler)
{
	LuaFunctor func(handler);
	self->copyFileAsync(src, dst, func);
}

/* Scheduler */

void Scheduler_schedule(Scheduler* self, int handler)
{
	self->schedule(LuaHandler::create(handler));
}

void Scheduler_unschedule(Scheduler* self, int handler)
{
	self->unschedule(LuaHandler::create(handler));
}

/* Director */

void Director_schedule(Director* self, int handler)
{
	self->getSystemScheduler()->schedule(LuaHandler::create(handler));
}

void Director_unschedule(Director* self, int handler)
{
	self->getSystemScheduler()->unschedule(LuaHandler::create(handler));
}

NS_DOROTHY_END

#include "Const/oHeader.h"
#include "Lua/oLuaEngine.h"
#include "Lua/tolua++.h"

NS_DOROTHY_BEGIN

void __oContent_loadFile(lua_State* L, oContent* self, const char* filename)
{
	Sint64 size = 0;
	oOwnArray<Uint8> data = self->loadFile(filename, size);
	if (!data)
	{
		lua_pushnil(L);
	}
	else
	{
		lua_pushlstring(L, (const char*)data.get(), (size_t)size);
	}
}

void __oContent_getDirEntries(lua_State* L, oContent* self, const char* path, bool isFolder)
{
	auto dirs = self->getDirEntries(path, isFolder);
	lua_createtable(L, (int)dirs.size(), 0);
	for (int i = 0; i < (int)dirs.size(); i++)
	{
		lua_pushstring(L, dirs[i].c_str());
		lua_rawseti(L, -2, i+1);
	}
}

void oContent_setSearchPaths(oContent* self, char* paths[], int length)
{
	vector<string> searchPaths(length);
	for (int i = 0; i < length; i++)
	{
		searchPaths[i] = paths[i];
	}
	self->setSearchPaths(searchPaths);
}

NS_DOROTHY_END

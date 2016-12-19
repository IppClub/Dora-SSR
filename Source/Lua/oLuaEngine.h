/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_LUA_OLUAENGINE_H__
#define __DOROTHY_LUA_OLUAENGINE_H__

#include "Lua/tolua++.h"
#include "Lua/tolua_fix.h"

NS_DOROTHY_BEGIN

class oLuaEngine : public oObject
{
public:
	PROPERTY_READONLY(lua_State*, State);

	void addLuaLoader(lua_CFunction func);

	void removeScriptHandler(int handler);
	void removePeer(oObject* object);

	int executeString(oSlice codes);
	int executeScriptFile(oSlice filename);
	int executeFunction(int nHandler, int paramCount, oObject* params[]);
	int executeFunction(int nHandler, int paramCount, void* params[], int paramTypes[]);
	int executeFunction(int nHandler, int paramCount = 0);

	bool executeAssert(bool cond, oSlice msg = Slice::Empty);
	bool scriptHandlerEqual(int nHandlerA, int nHandlerB);

	static int call(lua_State* L, int paramCount, int returnCount);
	static int execute(lua_State* L, int nHandler, int numArgs);
	static int execute(lua_State* L, int numArgs);
	static int invoke(lua_State* L, int nHandler, int numArgs, int numRets);
protected:
	oLuaEngine();
	static int _callFromLua;
	lua_State* L;
};

#define oSharedLueEngine \
	silly::Singleton<oLuaEngine, oSingletonIndex::LuaEngine>::shared()

NS_DOROTHY_END

#endif // __DOROTHY_LUA_OLUAENGINE_H__

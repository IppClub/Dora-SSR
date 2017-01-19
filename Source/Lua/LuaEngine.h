/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "lua.hpp"

NS_DOROTHY_BEGIN

class LuaEngine : public Object
{
public:
	virtual ~LuaEngine();
	PROPERTY_READONLY(lua_State*, State);

	void addLuaLoader(lua_CFunction func);

	void removeScriptHandler(int handler);
	void removePeer(Object* object);

	int executeString(String codes);
	int executeScriptFile(String filename);
	int executeFunction(int handler, int paramCount = 0);

	void push(int value);
	void push(float value);
	void push(double value);
	void push(Object* value);
	void push(String value);
	void push(std::nullptr_t);

	bool to(int& value, int index);
	bool to(float& value, int index);
	bool to(double& value, int index);
	bool to(Object*& value, int index);
	bool to(Slice& value, int index);

	template<typename T>
	void push(T* t)
	{
		tolua_pushusertype(L, t, LuaType<T>());
	}

	bool executeAssert(bool cond, String condStr);
	bool scriptHandlerEqual(int handlerA, int handlerB);

	static int call(lua_State* L, int paramCount, int returnCount);
	static int execute(lua_State* L, int handler, int numArgs);
	static int execute(lua_State* L, int numArgs);
	static int invoke(lua_State* L, int handler, int numArgs, int numRets);
protected:
	LuaEngine();
	static int _callFromLua;
	lua_State* L;
};

#define SharedLueEngine \
	silly::Singleton<LuaEngine, SingletonIndex::LuaEngine>::shared()

NS_DOROTHY_END

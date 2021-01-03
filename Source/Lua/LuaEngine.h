/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Lua/ToLua/tolua++.h"
#include "Common/Ref.h"
#include "yuescript/yue_compiler.h"

NS_DOROTHY_BEGIN

class Value;
class Node;
class LuaHandler;

class LuaEngine
{
public:
	virtual ~LuaEngine();
	PROPERTY_READONLY(lua_State*, State);
	PROPERTY_READONLY_REF(yue::YueCompiler, Yue);

	void insertLuaLoader(lua_CFunction func);

	void removeScriptHandler(int handler);
	void removePeer(Object* object);

	bool executeString(String codes);
	bool executeScriptFile(String filename);
	bool executeFunction(int handler, int paramCount = 0);
	int executeReturnFunction(int handler, int paramCount = 0);
	Node* executeReturnNode(int handler);

	void pop(int count = 1);

	void push(bool value);
	void push(int value);
	void push(Uint16 value);
	void push(lua_Integer value);
	void push(float value);
	void push(lua_Number value);
	void push(Value* value);
	void push(Object* value);
	void push(String value);
	void push(const string& value);
	void push(std::nullptr_t);
	template<typename T>
	typename std::enable_if<!std::is_pointer<T>::value>::type push(const T& t)
	{
		tolua_pushusertype(L, new T(t), LuaType<T>());
	}
	template<typename T>
	typename std::enable_if<!std::is_base_of<Object, T>::value>::type push(T* t)
	{
		tolua_pushusertype(L, t, LuaType<T>());
	}

	static void push(lua_State* L, bool value);
	static void push(lua_State* L, int value);
	static void push(lua_State* L, Uint16 value);
	static void push(lua_State* L, lua_Integer value);
	static void push(lua_State* L, float value);
	static void push(lua_State* L, lua_Number value);
	static void push(lua_State* L, Value* value);
	static void push(lua_State* L, Object* value);
	static void push(lua_State* L, String value);
	static void push(lua_State* L, const string& value);
	static void push(lua_State* L, std::nullptr_t);
	template<typename T>
	static typename std::enable_if<!std::is_pointer<T>::value>::type push(lua_State* L, const T& t)
	{
		tolua_pushusertype(L, new T(t), LuaType<T>());
	}
	template<typename T>
	static typename std::enable_if<!std::is_base_of<Object, T>::value>::type push(lua_State* L, T* t)
	{
		tolua_pushusertype(L, t, LuaType<T>());
	}

	bool to(bool& value, int index);
	bool to(int& value, int index);
	bool to(Uint16& value, int index);
	bool to(Sint64& value, int index);
	bool to(float& value, int index);
	bool to(double& value, int index);
	bool to(Object*& value, int index);
	bool to(string& value, int index);

	template<typename T>
	typename std::enable_if<std::is_base_of<Object, T>::value, bool>::type to(T*& t, int index)
	{
		t = dynamic_cast<T*>(r_cast<Object*>(tolua_tousertype(L, index, nullptr)));
		return false;
	}

	void executeReturn(LuaHandler*& luaHandler, int handler, int paramCount);

	template<typename T>
	typename std::enable_if<!std::is_base_of<Object, T>::value>::type executeReturn(T& value, int handler, int paramCount)
	{
		LuaEngine::invoke(L, handler, paramCount, 1);
		to(value, -1);
		LuaEngine::pop();
	}

	template<typename T>
	typename std::enable_if<std::is_base_of<Object, T>::value>::type executeReturn(T*& value, int handler, int paramCount)
	{
		LuaEngine::invoke(L, handler, paramCount, 1);
		Object* obj = nullptr;
		LuaEngine::to(obj, -1);
		value =  dynamic_cast<T*>(obj);
		LuaEngine::pop();
	}

	bool executeAssert(bool cond, String condStr);
	bool scriptHandlerEqual(int handlerA, int handlerB);

	static bool call(lua_State* L, int paramCount, int returnCount); // returns success or failure
	static bool execute(lua_State* L, int handler, int numArgs); // returns function result
	static bool execute(lua_State* L, int numArgs); // returns function result
	static bool invoke(lua_State* L, int handler, int numArgs, int numRets); // returns success or failure
protected:
	LuaEngine();
	static int _callFromLua;
	lua_State* L;
	Own<yue::YueCompiler> _yueCompiler;
	SINGLETON_REF(LuaEngine, AsyncThread);
};

#define SharedLuaEngine \
	Dorothy::Singleton<Dorothy::LuaEngine>::shared()

NS_DOROTHY_END

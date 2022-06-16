/* Copyright (c) 2022 Jin Li, dragon-fly@qq.com

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
	PROPERTY_READONLY_BOOL(InLua);

	std::pair<std::string, std::string> tealToLua(const std::string& tlCodes, String moduleName);

	void insertLuaLoader(lua_CFunction func, int index);

	void removeScriptHandler(int handler);
	void removePeer(Object* object);

	bool executeString(const std::string& codes);
	bool executeScriptFile(String filename);
	bool executeFunction(int handler, int paramCount = 0);
	int executeReturnFunction(int handler, int paramCount = 0);
	Node* executeReturnNode(int handler);

	void pop(int count = 1);

	template <class T>
	typename std::enable_if_t<std::is_integral_v<T>> push(T value)
	{
		lua_pushinteger(L, s_cast<lua_Integer>(value));
	}

	template <class T>
	typename std::enable_if_t<std::is_floating_point_v<T>> push(T value)
	{
		lua_pushnumber(L, s_cast<lua_Number>(value));
	}

	template<typename T>
	typename std::enable_if_t<std::is_base_of_v<Object, T>> push(T* value)
	{
		tolua_pushobject(L, value);
	}

	template<typename T>
	typename std::enable_if_t<!std::is_pointer_v<T> && std::is_class_v<T> && !std::is_same_v<std::string, T>> push(const T& t)
	{
		tolua_pushusertype(L, new T(t), LuaType<T>());
	}

	template<typename T>
	typename std::enable_if<!std::is_base_of_v<Object, T>>::type push(T* t)
	{
		tolua_pushusertype(L, t, LuaType<T>());
	}

	void push(bool value);
	void push(Value* value);
	void push(String value);
	void push(const Vec2& value);

	template <class T>
	static typename std::enable_if_t<std::is_integral_v<T>> push(lua_State* L, T value)
	{
		lua_pushinteger(L, s_cast<lua_Integer>(value));
	}

	template <class T>
	static typename std::enable_if_t<std::is_floating_point_v<T>> push(lua_State* L, T value)
	{
		lua_pushnumber(L, s_cast<lua_Number>(value));
	}

	template<typename T>
	static typename std::enable_if_t<std::is_base_of_v<Object, T>> push(lua_State* L, T* value)
	{
		tolua_pushobject(L, value);
	}

	template<typename T>
	static typename std::enable_if_t<!std::is_pointer_v<T> && std::is_class_v<T> && !std::is_same_v<std::string, T>> push(lua_State* L, const T& t)
	{
		tolua_pushusertype(L, new T(t), LuaType<T>());
	}

	template<typename T>
	static typename std::enable_if<!std::is_base_of_v<Object, T>>::type push(lua_State* L, T* t)
	{
		tolua_pushusertype(L, t, LuaType<T>());
	}

	static void push(lua_State* L, bool value);
	static void push(lua_State* L, Value* value);
	static void push(lua_State* L, String value);
	static void push(lua_State* L, const Vec2& value);

	bool to(bool& value, int index);
	bool to(Object*& value, int index);
	bool to(std::string& value, int index);

	template <class T>
	typename std::enable_if_t<std::is_integral_v<T>, bool> to(T& value, int index)
	{
		if (lua_isinteger(L, index))
		{
			value = s_cast<T>(lua_tointeger(L, index));
			return true;
		}
		return false;
	}

	template <class T>
	typename std::enable_if_t<std::is_floating_point_v<T>, bool> to(T& value, int index)
	{
		if (lua_isnumber(L, index))
		{
			value = s_cast<T>(lua_tonumber(L, index));
			return true;
		}
		return false;
	}

	template<typename T>
	typename std::enable_if_t<std::is_base_of_v<Object, T>, bool> to(T*& t, int index)
	{
		Object* obj = r_cast<Object*>(tolua_tousertype(L, index, nullptr));
		t = dynamic_cast<T*>(obj);
		return t == obj;
	}

	void executeReturn(LuaHandler*& luaHandler, int handler, int paramCount);

	template<typename T>
	typename std::enable_if_t<!std::is_base_of_v<Object, T>> executeReturn(T& value, int handler, int paramCount)
	{
		LuaEngine::invoke(L, handler, paramCount, 1);
		to(value, -1);
		LuaEngine::pop();
	}

	template<typename T>
	typename std::enable_if_t<std::is_base_of_v<Object, T>> executeReturn(T*& value, int handler, int paramCount)
	{
		LuaEngine::invoke(L, handler, paramCount, 1);
		Object* obj = nullptr;
		LuaEngine::to(obj, -1);
		value =  dynamic_cast<T*>(obj);
		LuaEngine::pop();
	}

	bool scriptHandlerEqual(int handlerA, int handlerB);

	static bool call(lua_State* L, int paramCount, int returnCount); // returns success or failure
	static bool execute(lua_State* L, int handler, int numArgs); // returns function result
	static bool execute(lua_State* L, int numArgs); // returns function result
	static bool invoke(lua_State* L, int handler, int numArgs, int numRets); // returns success or failure
protected:
	LuaEngine();
	static int _callFromLua;
	lua_State* L;
	lua_State* _tlState;
	Own<yue::YueCompiler> _yueCompiler;
	SINGLETON_REF(LuaEngine, AsyncThread);
};

#define SharedLuaEngine \
	Dorothy::Singleton<Dorothy::LuaEngine>::shared()

NS_DOROTHY_END

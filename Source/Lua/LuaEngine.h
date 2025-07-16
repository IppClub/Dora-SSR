/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Lua/ToLua/tolua++.h"
#include "yuescript/yue_compiler.h"

NS_DORA_BEGIN

class Value;
class Node;
class LuaHandler;
class Async;
class Listener;

namespace Platformer {
class UnitAction;
namespace Behavior {
class Blackboard;
} // namespace Behavior
} // namespace Platformer

class LuaEngine : public NonCopyable {
public:
	virtual ~LuaEngine();
	PROPERTY_READONLY(lua_State*, State);
	PROPERTY_READONLY(int, RuntimeMemory);
	PROPERTY_READONLY(int, TealMemory);

	std::pair<std::string, std::string> compileTealToLua(String tlCodes, String filename, String searchPath);
	void compileTealToLuaAsync(String tlCodes, String filename, String searchPath, const std::function<void(std::pair<std::string, std::string>)>& callback);
	std::string getTealVersion();
	struct TealError {
		std::string type;
		std::string filename;
		int row;
		int col;
		std::string msg;
	};
	void checkTealAsync(String tlCodes, String moduleName, bool lax, String searchPath, const std::function<void(std::optional<std::list<TealError>>)>& callback);
	struct TealToken {
		std::string name;
		std::string desc;
		std::string type;
	};
	void completeTealAsync(String tlCodes, String line, int row, String searchPath, const std::function<void(std::list<TealToken>)>& callback);
	struct TealInference {
		std::string desc;
		std::string file;
		int row;
		int col;
	};
	void inferTealAsync(String tlCodes, String line, int row, String searchPath, const std::function<void(std::optional<TealInference>)>& callback);
	void getTealSignatureAsync(String tlCodes, String line, int row, String searchPath, const std::function<void(std::optional<std::list<TealInference>>)>& callback);
	void clearTealCompiler(bool reset);

	struct XmlToken {
		std::string label;
		std::string insertText;
	};
	std::list<XmlToken> completeXml(String xmlCodes);

	void insertLuaLoader(lua_CFunction func, int index);

	void removeScriptHandler(int handler);
	void removePeer(Object* object);

	bool executeString(const std::string& codes);
	bool executeScriptFile(String filename);
	bool executeModule(String module);
	bool executeFunction(int handler, int paramCount = 0);

	void pop(int count = 1);

	template <class T>
	typename std::enable_if_t<std::is_integral_v<T> && !std::is_same_v<T, bool>> push(T value) {
		lua_pushinteger(L, s_cast<lua_Integer>(value));
	}

	template <class T>
	typename std::enable_if_t<std::is_floating_point_v<T>> push(T value) {
		lua_pushnumber(L, s_cast<lua_Number>(value));
	}

	template <typename T>
	typename std::enable_if_t<std::is_base_of_v<Object, T>> push(T* value) {
		tolua_pushobject(L, value);
	}

	template <typename T>
	typename std::enable_if_t<std::is_same_v<T, bool>> push(T value) {
		lua_pushboolean(L, value ? 1 : 0);
	}

	template <typename T>
	typename std::enable_if_t<
		std::is_same_v<T, Platformer::UnitAction>
		|| std::is_same_v<T, Platformer::Behavior::Blackboard>>
	push(T* value) {
		tolua_pushusertype(L, value, LuaType<T>());
	}

	template <typename T>
	typename std::enable_if_t<
		std::is_same_v<T, Size>
		|| std::is_same_v<T, Vec4>
		|| std::is_same_v<T, Rect>
		|| std::is_same_v<T, Matrix>>
	push(const T& value) {
		tolua_pushusertype(L, new T(value), LuaType<T>());
	}

	template <typename T>
	typename std::enable_if_t<
		!std::is_same_v<T, Slice>
		&& std::is_same_v<T, std::optional<Slice>>>
	push(const T& value) {
		if (value) {
			tolua_pushslice(L, *value);
		} else {
			lua_pushnil(L);
		}
	}

	void push(Value* value);
	void push(String value);
	void push(const Vec2& value);

	template <class T>
	static typename std::enable_if_t<std::is_integral_v<T> && !std::is_same_v<T, bool>> push(lua_State* L, T value) {
		lua_pushinteger(L, s_cast<lua_Integer>(value));
	}

	template <class T>
	static typename std::enable_if_t<std::is_floating_point_v<T>> push(lua_State* L, T value) {
		lua_pushnumber(L, s_cast<lua_Number>(value));
	}

	template <typename T>
	static typename std::enable_if_t<std::is_base_of_v<Object, T>> push(lua_State* L, T* value) {
		tolua_pushobject(L, value);
	}

	template <typename T>
	static typename std::enable_if_t<!std::is_base_of_v<Object, T>> push(lua_State* L, T* t) {
		tolua_pushusertype(L, t, LuaType<T>());
	}

	template <typename T>
	static typename std::enable_if_t<std::is_same_v<T, bool>> push(lua_State* L, T value) {
		lua_pushboolean(L, value ? 1 : 0);
	}

	template <typename T>
	static typename std::enable_if_t<
		std::is_same_v<T, Size>
		|| std::is_same_v<T, Vec4>
		|| std::is_same_v<T, Rect>
		|| std::is_same_v<T, Matrix>>
	push(lua_State* L, const T& value) {
		tolua_pushusertype(L, new T(value), LuaType<T>());
	}

	template <typename T>
	static typename std::enable_if_t<
		std::is_same_v<T, Platformer::UnitAction>
		|| std::is_same_v<T, Platformer::Behavior::Blackboard>>
	push(lua_State* L, T* value) {
		tolua_pushusertype(L, value, LuaType<T>());
	}

	static void push(lua_State* L, Value* value);
	static void push(lua_State* L, String value);
	static void push(lua_State* L, const Vec2& value);

	template <class T>
	typename std::enable_if_t<std::is_integral_v<T> && !std::is_same_v<T, bool>, bool> to(T& value, int index) {
		if (lua_isinteger(L, index)) {
			value = s_cast<T>(lua_tointeger(L, index));
			return true;
		}
		return false;
	}

	template <class T>
	typename std::enable_if_t<std::is_floating_point_v<T>, bool> to(T& value, int index) {
		if (lua_isnumber(L, index)) {
			value = s_cast<T>(lua_tonumber(L, index));
			return true;
		}
		return false;
	}

	template <typename T>
	typename std::enable_if_t<std::is_base_of_v<Object, T>, bool> to(T*& t, int index) {
		Object* obj = r_cast<Object*>(tolua_tousertype(L, index, nullptr));
		t = dynamic_cast<T*>(obj);
		return t == obj;
	}

	bool to(bool& value, int index);
	bool to(std::string& value, int index);

	void executeReturn(LuaHandler*& luaHandler, int handler, int paramCount);

	template <typename T>
	typename std::enable_if_t<!std::is_base_of_v<Object, T>> executeReturn(T& value, int handler, int paramCount) {
		int top = lua_gettop(L) - paramCount;
		DEFER(lua_settop(L, top));
		LuaEngine::invoke(L, handler, paramCount, 1);
		to(value, -1);
	}

	template <typename T>
	typename std::enable_if_t<std::is_base_of_v<Object, T>> executeReturn(T*& value, int handler, int paramCount) {
		int top = lua_gettop(L) - paramCount;
		DEFER(lua_settop(L, top));
		LuaEngine::invoke(L, handler, paramCount, 1);
		Object* obj = nullptr;
		LuaEngine::to(obj, -1);
		value = dynamic_cast<T*>(obj);
	}

	bool scriptHandlerEqual(int handlerA, int handlerB);

	static bool call(lua_State* L, int paramCount, int returnCount); // returns success or failure
	static bool execute(lua_State* L, int handler, int numArgs); // returns function result
	static bool execute(lua_State* L, int numArgs); // returns function result
	static bool invoke(lua_State* L, int handler, int numArgs, int numRets); // returns success or failure

	static bool isInLua();

private:
	struct TealState {
		lua_State* L;
		Async* thread;
	};
	Own<TealState> _tlState;
	TealState* loadTealState();
	void initTealState(bool mainThread);

protected:
	LuaEngine();
	static int _callFromLua;
	lua_State* L;
	Ref<Listener> _commandListener;
	SINGLETON_REF(LuaEngine, AsyncThread);
};

#define SharedLuaEngine \
	Dora::Singleton<Dora::LuaEngine>::shared()

void dora_open_threaded_compiler(void* state);

NS_DORA_END

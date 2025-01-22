/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Lua/LuaEngine.h"

NS_DORA_BEGIN

class LuaHandler : public Object {
public:
	virtual ~LuaHandler();
	virtual bool init() override;
	bool equals(LuaHandler* other) const;
	int get() const;
	CREATE_FUNC_NOT_NULL(LuaHandler);

protected:
	LuaHandler(int handler);

private:
	int _handler;
	DORA_TYPE_OVERRIDE(LuaHandler);
};

struct LuaArgsPusher {
	template <typename T>
	void operator()(T&& element) {
		SharedLuaEngine.push(element);
	}
};

class Event;

template <class T>
class LuaFunction {
public:
	explicit LuaFunction(int handler)
		: _handler(LuaHandler::create(handler)) { }
	inline bool operator==(const LuaFunction& other) const {
		return _handler->equals(other._handler);
	}
	template <typename... Args>
	T operator()(Args... args) const {
		T value{};
		if (_handler->get() > 0) {
			SharedLuaEngine.executeReturn(value, _handler->get(),
				Tuple::foreach (std::make_tuple(args...), LuaArgsPusher()));
		}
		return value;
	}

private:
	Ref<LuaHandler> _handler;
};

template <>
class LuaFunction<void> {
public:
	LuaFunction(int handler)
		: _handler(LuaHandler::create(handler)) { }
	inline bool operator==(const LuaFunction& other) const {
		return _handler->equals(other._handler);
	}
	template <typename... Args>
	void operator()(Args... args) const {
		if (_handler->get() > 0) {
			SharedLuaEngine.executeFunction(_handler->get(), Tuple::foreach (std::make_tuple(args...), LuaArgsPusher()));
		}
	}
	void operator()(Event* event) const;

private:
	Ref<LuaHandler> _handler;
};

template <>
class LuaFunction<bool> {
public:
	LuaFunction(int handler)
		: _handler(LuaHandler::create(handler)) { }
	LuaFunction(LuaHandler* handler)
		: _handler(handler) { }
	inline bool operator==(const LuaFunction& other) const {
		if (_handler) return _handler->equals(other._handler);
		return other._handler == nullptr;
	}
	template <typename... Args>
	bool operator()(Args... args) const {
		if (_handler && _handler->get() > 0) {
			return SharedLuaEngine.executeFunction(_handler->get(), Tuple::foreach (std::make_tuple(args...), LuaArgsPusher()));
		}
		return true;
	}

private:
	Ref<LuaHandler> _handler;
};

template <>
class LuaFunction<LuaFunction<bool>> {
public:
	LuaFunction(int handler)
		: _handler(LuaHandler::create(handler)) { }
	inline bool operator==(const LuaFunction& other) const {
		return _handler->equals(other._handler);
	}
	template <typename... Args>
	LuaFunction<bool> operator()(Args... args) const {
		LuaHandler* luaHandler = nullptr;
		if (_handler->get() > 0) {
			SharedLuaEngine.executeReturn(luaHandler, _handler->get(),
				Tuple::foreach (std::make_tuple(args...), LuaArgsPusher()));
		}
		return LuaFunction<bool>(luaHandler);
	}

private:
	Ref<LuaHandler> _handler;
};

NS_DORA_END

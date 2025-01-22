/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Support/Value.h"

#include "Lua/LuaHandler.h"

NS_DORA_BEGIN

const Own<Value> Value::None;

/* ValueInt */

Own<Value> ValueInt::clone() const {
	return Value::alloc(_value);
}

void ValueInt::pushToLua(lua_State* L) const {
	LuaEngine::push(L, _value);
}

ValueType ValueInt::getType() const {
	return ValueType::Integral;
}

bool ValueInt::equals(Value* other) const {
	if (auto value = DoraAs<ValueInt>(other)) {
		return _value == value->get();
	}
	return false;
}

MEMORY_POOL(ValueInt);

/* ValueFloat */

Own<Value> ValueFloat::clone() const {
	return Value::alloc(_value);
}

void ValueFloat::pushToLua(lua_State* L) const {
	LuaEngine::push(L, _value);
}

ValueType ValueFloat::getType() const {
	return ValueType::FloatingPoint;
}

bool ValueFloat::equals(Value* other) const {
	if (auto value = DoraAs<ValueFloat>(other)) {
		return _value == value->get();
	}
	return false;
}

MEMORY_POOL(ValueFloat);

/* ValueBool */

Own<Value> ValueBool::clone() const {
	return Value::alloc(_value);
}

void ValueBool::pushToLua(lua_State* L) const {
	LuaEngine::push(L, _value);
}

ValueType ValueBool::getType() const {
	return ValueType::Boolean;
}

bool ValueBool::equals(Value* other) const {
	if (auto value = DoraAs<ValueBool>(other)) {
		return _value == value->get();
	}
	return false;
}

MEMORY_POOL(ValueBool);

/* ValueObject */

Own<Value> ValueObject::clone() const {
	return Value::alloc(_value.get());
}

void ValueObject::pushToLua(lua_State* L) const {
	if (auto value = DoraAs<LuaHandler>(_value.get())) {
		tolua_get_function_by_refid(L, value->get());
	} else
		LuaEngine::push(L, _value.get());
}

ValueType ValueObject::getType() const {
	return ValueType::Object;
}

bool ValueObject::equals(Value* other) const {
	if (auto value = DoraAs<ValueObject>(other)) {
		BLOCK_START
		auto handler = DoraAs<LuaHandler>(_value.get());
		BREAK_IF(!handler);
		auto otherHandler = DoraAs<LuaHandler>(value->get());
		BREAK_IF(!otherHandler);
		return SharedLuaEngine.scriptHandlerEqual(handler->get(), otherHandler->get());
		BLOCK_END
		return _value == value->get();
	}
	return false;
}

MEMORY_POOL(ValueObject);

NS_DORA_END

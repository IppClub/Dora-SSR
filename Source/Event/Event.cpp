/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Event/Event.h"

#include "Event/EventType.h"
#include "Event/Listener.h"

NS_DORA_BEGIN

StringMap<Own<EventType>> Event::_eventMap;
std::list<std::pair<std::string, EventHandler>> Event::_postEvents;

Event::Event(String name)
	: _name(name) { }

Event::~Event() { }

void Event::clear() {
	_eventMap.clear();
}

void Event::unreg(Listener* listener) {
	auto it = _eventMap.find(listener->getName());
	if (it != _eventMap.end()) {
		EventType* type = it->second.get();
		type->remove(listener);
		if (type->isEmpty()) {
			_eventMap.erase(it);
		}
	}
}

void Event::reg(Listener* listener) {
	auto it = _eventMap.find(listener->getName());
	if (it != _eventMap.end()) {
		it->second->add(listener);
	} else {
		EventType* type = new EventType(listener->getName());
		_eventMap[listener->getName()] = MakeOwn(type);
		type->add(listener);
	}
}

void Event::send(Event* e) {
	auto it = _eventMap.find(e->getName());
	if (it != _eventMap.end()) {
		it->second->handle(e);
	}
}

void Event::post(String name, const EventHandler& handler) {
	_postEvents.emplace_back(name.toString(), handler);
}

void Event::handlePostEvents() {
	while (!_postEvents.empty()) {
		const auto& eventPair = _postEvents.front();
		Event event(eventPair.first);
		eventPair.second(&event);
		_postEvents.pop_front();
	}
}

Listener* Event::addListener(String name, const EventHandler& handler) {
	Listener* listener = Listener::create(name.toString(), handler);
	return listener;
}

bool Event::hasListener(String name) {
	return _eventMap.contains(name);
}

LuaEventArgs::LuaEventArgs(String name, int paramCount)
	: Event(name)
	, _paramCount(paramCount) { }

void LuaEventArgs::send(String name, int paramCount) {
	LuaEventArgs event(name, paramCount);
	Event::send(&event);
}

int LuaEventArgs::pushArgsToLua() {
	lua_State* L = SharedLuaEngine.getState();
	int top = lua_gettop(L);
	for (int index = top - _paramCount + 1; index <= top; index++) {
		lua_pushvalue(L, index);
	}
	return _paramCount;
}

void LuaEventArgs::pushArgsToWasm(CallStack* stack) {
	lua_State* L = SharedLuaEngine.getState();
	int top = lua_gettop(L);
	for (int index = top - _paramCount + 1; index <= top; index++) {
		if (!lua_isnil(L, index)) {
			if (lua_isinteger(L, index)) {
				stack->push(s_cast<int64_t>(lua_tointeger(L, index)));
			} else if (lua_isnumber(L, index)) {
				stack->push(lua_tonumber(L, index));
			} else if (lua_isboolean(L, index)) {
				stack->push(lua_toboolean(L, index) > 0);
			} else if (lua_isstring(L, index)) {
				stack->push(tolua_toslice(L, index, nullptr).toString());
			} else if (tolua_isobject(L, index)) {
				stack->push(r_cast<Object*>(tolua_tousertype(L, index, 0)));
			} else {
				auto name = tolua_typename(L, index);
				lua_pop(L, 1);
				switch (Switch::hash(name)) {
					case "Vec2"_hash:
						stack->push(tolua_tolight(L, index).value);
					case "Size"_hash:
						stack->push(*r_cast<Size*>(tolua_tousertype(L, index, 0)));
					default:
#ifndef TOLUA_RELEASE
						tolua_error(L, "Can only pass number, boolean, string, Object, Vec2, Size from Lua to Wasm.", nullptr);
#endif // TOLUA_RELEASE
						break;
				}
			}
		}
	}
}

int LuaEventArgs::getArgsCount() const {
	return _paramCount;
}

WasmEventArgs::WasmEventArgs(String name, CallStack* stack)
	: Event(name) {
	while (!stack->empty()) {
		_values.push_back(stack->pop());
	}
}

int WasmEventArgs::pushArgsToLua() {
	for (const auto& val : _values) {
		std::visit(
			[](const auto& arg) {
				SharedLuaEngine.push(arg);
			},
			val);
	}
	return s_cast<int>(_values.size());
}

void WasmEventArgs::pushArgsToWasm(CallStack* stack) {
	for (const auto& value : _values) {
		stack->push_v(value);
	}
}

int WasmEventArgs::getArgsCount() const {
	return s_cast<int>(_values.size());
}

bool WasmEventArgs::to(bool& value, int index) {
	if (index < s_cast<int>(_values.size()) && std::holds_alternative<bool>(_values[index])) {
		value = std::get<bool>(_values[index]);
		return true;
	}
	return false;
}

bool WasmEventArgs::to(Object*& value, int index) {
	if (index < s_cast<int>(_values.size()) && std::holds_alternative<Object*>(_values[index])) {
		value = std::get<Object*>(_values[index]);
		return true;
	}
	return false;
}

bool WasmEventArgs::to(std::string& value, int index) {
	if (index < s_cast<int>(_values.size()) && std::holds_alternative<std::string>(_values[index])) {
		value = std::get<std::string>(_values[index]);
		return true;
	}
	return false;
}

void WasmEventArgs::send(String name, CallStack* stack) {
	WasmEventArgs event(name, stack);
	Event::send(&event);
}

NS_DORA_END

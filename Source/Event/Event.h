/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Lua/LuaHandler.h"
#include "Wasm/WasmRuntime.h"

NS_DORA_BEGIN

class Listener;
class EventType;
class Event;
typedef std::function<void(Event*)> EventHandler;

/** @brief This event system is designed to be used in a single threaded
 environment and is associated with event, event type and event listener.
 Events sent and received are all in a shared space.
 Use this system as following.
 @example User defined event.
 // Register callback function.
 Event::addListener("UserEvent", [](Event* event)
 {
	Slice msg;
	if (event->get(msg)) {
		Log("Received Event with msg: {}", msg);
	}
 });

 // Send event with all types of arguments, then the callback function will be invoked.
 Event::send("UserEvent", Slice("info1"));
 Event::send("UserEvent", Slice("msg2"));
 */
class Event {
public:
	virtual ~Event();
	Event(String name);
	inline String getName() const { return _name; }
	virtual int pushArgsToLua() { return 0; }
	virtual void pushArgsToWasm(CallStack*) { }
	virtual int getArgsCount() const { return 0; }

public:
	static Listener* addListener(String name, const EventHandler& handler);
	static bool hasListener(String name);
	static void clear();

	template <class... Args>
	static void send(String name, const Args&... args);

	static void post(String name, const EventHandler& handler);

	static void handlePostEvents();

	template <class... Args>
	static void sendInternal(String name, const Args&... args);

	/** @brief Helper function to retrieve the passed event arguments.
	 */
	template <class... Args>
	bool get(Args&... args);

protected:
	static void reg(Listener* listener);
	static void unreg(Listener* listener);
	static void send(Event* event);
	Slice _name;

private:
	static StringMap<Own<EventType>> _eventMap;
	static std::list<std::pair<std::string, EventHandler>> _postEvents;
	friend class Listener;
	DORA_TYPE_BASE(Event);
};

struct WasmArgsPusher {
	CallStack* stack;

	inline void operator()(bool value) {
		stack->push(value);
	}

	inline void operator()(Object* value) {
		stack->push(value);
	}

	inline void operator()(String value) {
		stack->push(value.toString());
	}

	inline void operator()(const std::string& value) {
		stack->push(value);
	}

	inline void operator()(const Vec2& value) {
		stack->push(value);
	}

	template <class T>
	typename std::enable_if_t<std::is_integral_v<T> && !std::is_same_v<T, bool>, void> operator()(T value) {
		stack->push(s_cast<int64_t>(value));
	}

	template <class T>
	typename std::enable_if_t<std::is_floating_point_v<T>, void> operator()(T value) {
		stack->push(s_cast<double>(value));
	}

	template <typename T>
	typename std::enable_if_t<std::is_base_of_v<Object, T>, void> operator()(T* value) {
		stack->push(value);
	}
};

template <typename... Args>
struct ArgCount;

template <typename T, typename... Args>
struct ArgCount<T, Args...> {
	static const int value = 1 + ArgCount<Args...>::value;
};

template <>
struct ArgCount<> {
	static const int value = 0;
};

template <class... Fields>
class EventArgs : public Event {
public:
	EventArgs(String name, const Fields&... args)
		: Event(name)
		, arguments(std::make_tuple(args...)) { }
	virtual int pushArgsToLua() override {
		return Tuple::foreach (arguments, LuaArgsPusher());
	}
	virtual void pushArgsToWasm(CallStack* stack) override {
		Tuple::foreach (arguments, WasmArgsPusher{stack});
	}
	virtual int getArgsCount() const override {
		return ArgCount<Fields...>::value;
	}
	std::tuple<Fields...> arguments;
	DORA_TYPE_OVERRIDE(EventArgs<Fields...>);
};

class LuaEventArgs : public Event {
public:
	LuaEventArgs(String name, int paramCount);
	virtual int pushArgsToLua() override;
	virtual void pushArgsToWasm(CallStack* stack) override;
	virtual int getArgsCount() const override;
	static void send(String name, int paramCount);

private:
	int _paramCount;
	DORA_TYPE_OVERRIDE(LuaEventArgs);
};

class WasmEventArgs : public Event {
public:
	WasmEventArgs(String name, CallStack* stack);
	virtual int pushArgsToLua() override;
	virtual void pushArgsToWasm(CallStack* stack) override;
	virtual int getArgsCount() const override;
	const std::vector<dora_val_t>& values() const;
	static void send(String name, CallStack* stack);

public:
	bool to(bool& value, int index);
	bool to(Object*& value, int index);
	bool to(std::string& value, int index);

	template <class T>
	typename std::enable_if_t<std::is_integral_v<T> && !std::is_same_v<T, bool>, bool> to(T& value, int index) {
		if (index < s_cast<int>(_values.size())) {
			if (std::holds_alternative<int64_t>(_values[index])) {
				value = s_cast<T>(std::get<int64_t>(_values[index]));
				return true;
			}
		}
		return false;
	}

	template <class T>
	typename std::enable_if_t<std::is_floating_point_v<T>, bool> to(T& value, int index) {
		if (index < s_cast<int>(_values.size())) {
			if (std::holds_alternative<double>(_values[index])) {
				value = s_cast<T>(std::get<double>(_values[index]));
				return true;
			}
		}
		return false;
	}

	template <typename T>
	typename std::enable_if_t<std::is_base_of_v<Object, T>, bool> to(T*& value, int index) {
		if (index < s_cast<int>(_values.size()) && std::holds_alternative<Object*>(_values[index])) {
			Object* obj = std::get<Object*>(_values[index]);
			value = dynamic_cast<T*>(obj);
			return value == obj;
		}
		return false;
	}

private:
	std::vector<dora_val_t> _values;
	DORA_TYPE_OVERRIDE(WasmEventArgs);
};

template <class... Args>
void Event::send(String name, const Args&... args) {
	EventArgs<Args...> event(name, args...);
	Event::send(&event);
}

inline bool logicAnd(std::initializer_list<bool> values) {
	return std::accumulate(values.begin(), values.end(), true, std::logical_and<bool>());
}

template <class... Args>
bool Event::get(Args&... args) {
	if (auto event = DoraAs<LuaEventArgs>(this)) {
		lua_State* L = SharedLuaEngine.getState();
		int i = lua_gettop(L) - event->getArgsCount();
		if (!logicAnd({SharedLuaEngine.to(args, ++i)...})) {
			Error("lua event \"{}\" argument type mismatch.", getName().toString());
			return false;
		}
	} else if (auto event = DoraAs<EventArgs<Args...>>(this)) {
		std::tie(args...) = event->arguments;
	} else if (auto event = DoraAs<WasmEventArgs>(this)) {
		int i = -1;
		if (!logicAnd({event->to(args, ++i)...})) {
			Error("wasm event \"{}\" argument type mismatch.", getName().toString());
			return false;
		}
	} else {
		Error("event \"{}\" argument type mismatch.", getName().toString());
		return false;
	}
	return true;
}

NS_DORA_END

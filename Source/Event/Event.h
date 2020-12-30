/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Lua/LuaHandler.h"

NS_DOROTHY_BEGIN

class Listener;
class EventType;
class Event;
typedef Delegate<void (Event* event)> EventHandler;

/** @brief This event system is designed to be used in a single threaded
 environment and is associated with event, event type and event listener.
 Events sent and recieved are all in a shared space.
 Use this system as following.
 @example User defined event.
 // Register callback function.
 Event::addListener("UserEvent", [](Event* event)
 {
 	Slice msg;
 	event->get(msg);
	Log("Recieved Event with msg: {}", msg);
 });

 // Send event with all types of arguments, then the callback function will be invoked.
 Event::send("UserEvent", Slice("info1"));
 Event::send("UserEvent", Slice("msg2"));
 */
class Event
{
public:
	virtual ~Event();
	Event(String name);
	inline String getName() const { return _name; }
	virtual int pushArgsToLua() { return 0; }
public:
	static Listener* addListener(String name, const EventHandler& handler);
	static void clear();

	template<class... Args>
	static void send(String name, const Args&... args);

	template<class... Args>
	static void sendInternal(String name, const Args&... args);

	/** @brief Helper function to retrieve the passed event arguments.
	*/
	template<class... Args>
	void get(Args&... args);
protected:
	static void reg(Listener* listener);
	static void unreg(Listener* listener);
	static void send(Event* event);
	Slice _name;
private:
	static unordered_map<string, Own<EventType>> _eventMap;
	friend class Listener;
	DORA_TYPE_BASE(Event);
};

template<class... Fields>
class EventArgs : public Event
{
public:
	EventArgs(String name, const Fields&... args):
	Event(name),
	arguments(std::make_tuple(args...))
	{ }
	virtual int pushArgsToLua() override
	{
		return Tuple::foreach(arguments, LuaArgsPusher());
	}
	std::tuple<Fields...> arguments;
	DORA_TYPE_OVERRIDE(EventArgs<Fields...>);
};

class LuaEventArgs : public Event
{
public:
	LuaEventArgs(String name, int paramCount);
	virtual int pushArgsToLua() override;
	int getParamCount() const;
	static void send(String name, int paramCount);
private:
	int _paramCount;
	DORA_TYPE_OVERRIDE(LuaEventArgs);
};

template<class... Args>
void Event::send(String name, const Args&... args)
{
	EventArgs<Args...> event(name, args...);
	Event::send(&event);
}

template<class... Args>
void Event::get(Args&... args)
{
	LuaEventArgs* luaEvent = DoraAs<LuaEventArgs>(this);
	if (luaEvent)
	{
		lua_State* L = SharedLuaEngine.getState();
		int i = lua_gettop(L) - luaEvent->getParamCount();
		bool results[] = {SharedLuaEngine.to(args, ++i)...};
#if DORA_DEBUG
		for (bool result : results)
		{
			AssertUnless(result, "lua event arguments mismatch.");
			if (!result) return;
		}
#else
		DORA_UNUSED_PARAM(results);
#endif // DORA_DEBUG
	}
	else
	{
		auto targetEvent = DoraAs<EventArgs<Args...>>(this);
		AssertIf(targetEvent == nullptr, "no required event argument type can be retrieved.");
		std::tie(args...) = targetEvent->arguments;
	}
}

NS_DOROTHY_END

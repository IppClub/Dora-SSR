/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

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
 	Event::retrieve(event, msg);
	Log("Recieved Event with msg: %s", msg);
 });

 // Send event with all types of arguments, then the callback function will be invoked.
 Event::send("UserEvent", Slice("info1"));
 Event::send("UserEvent", Slice("msg2"));
 */
class Event
{
public:
	Event();
	virtual ~Event();
	Event(String name);
	inline String getName() const { return _name; }
	virtual int pushArgsToLua() { return 0; }
public:
	static Listener* addListener(String name, const EventHandler& handler);
	static void clear();

	template<class... Args>
	static void send(String name, Args&&... args);

	/** @brief Helper function to retrieve the passed event arguments.
	*/
	template<class... Args>
	static void retrieve(Event* event, Args&... args);
protected:
	static void reg(Listener* listener);
	static void unreg(Listener* listener);
	static void send(Event* event);
	Slice _name;
private:
	static unordered_map<string, Own<EventType>> _eventMap;
	friend class Listener;
};

template<class... Fields>
class EventArgs : public Event
{
public:
	EventArgs(String name, Fields&&... args):
	Event(name),
	arguments(std::make_tuple(args...))
	{ }
	template<class... Args>
	static void send(String name, Args&&... args)
	{
		EventArgs<Fields...> event(name, args...);
		Event::send(&event);
	}
	virtual int pushArgsToLua() override
	{
		return Tuple::foreach(arguments, LuaArgsPusher());
	}
	std::tuple<Fields...> arguments;
};

template<class... Args>
void Event::send(String name, Args&&... args)
{
	EventArgs<Args...>::send(name, args...);
}

template<class... Args>
void Event::retrieve(Event* event, Args&... args)
{
	auto targetEvent = d_cast<EventArgs<Args...>*>(event);
	AssertIf(targetEvent == nullptr, "no required event argument type can be retrieved.");
	std::tie(args...) = targetEvent->arguments;
}

NS_DOROTHY_END

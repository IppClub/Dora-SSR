/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_EVENT_EVENT_H__
#define __DOROTHY_EVENT_EVENT_H__

NS_DOROTHY_BEGIN

class Listener;
class EventType;
class Event;
typedef Delegate<void (Event* event)> EventHandler;

/** @brief The event system can only be used in single threaded
 environment and is associated with event, event type and event listener.
 Use this system as following.
 @example User defined event.
 // Register callback function.
 Event::addListener("UserEvent", [](Event* event)
 {
 	Slice msg;
 	Event::retrieve(event, msg);
	Log("Recieved Event with msg: %s", msg);
 });

 // Send event, then the callback function will be invoked.
 Event::send("UserEvent", Slice("info1"));
 Event::send("UserEvent", Slice("msg2"));
 */
class Event
{
public:
	Event();
	virtual ~Event();
	Event(String name);
	inline const string& getName() const { return _name; }
	virtual int pushArgsToLua() { return 0; }
public:
	static Listener* addListener(const string& name, const EventHandler& handler);
	static void clear();

	template<class... Args>
	static void send(String name, Args&&... args);

	template<class... Args>
	static void retrieve(Event* event, Args&... args);
private:
	static void reg(Listener* listener);
	static void unreg(Listener* listener);
	static unordered_map<string, Own<EventType>> _eventMap;
protected:
	static void send(Event* event);
	string _name;
	friend class Listener;
};

template<class... Fields>
class EventArgs : public Event
{
public:
	template<class... Args>
	static void send(String name, Args&&... args)
	{
		_event._name = name;
		_event.arguments = std::make_tuple(args...);
		Event::send(&_event);
	}
	virtual int pushArgsToLua() override
	{
		Tuple::foreach(arguments, ArgsPusher());
		return std::tuple_size<decltype(arguments)>::value;
	}
	std::tuple<Fields...> arguments;
private:
	struct ArgsPusher
	{
		template<typename T>
		void operator()(const T& element)
		{
			SharedLueEngine.push(element);
		}
	};
	static EventArgs<Fields...> _event;
};

template<class... Fields>
EventArgs<Fields...> EventArgs<Fields...>::_event;

template<class... Args>
void Event::send(String name, Args&&... args)
{
	EventArgs<Args...>::send(name, args...);
}

template<class... Args>
void Event::retrieve(Event* event, Args&... args)
{
	auto targetEvent = dynamic_cast<EventArgs<Args...>*>(event);
	AssertIf(targetEvent == nullptr, "no required event argument type can be retrieved.");
	std::tie(args...) = targetEvent->arguments;
}

NS_DOROTHY_END

#endif //__DOROTHY_EVENT_EVENT_H__

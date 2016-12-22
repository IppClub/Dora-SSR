/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_EVENT_OEVENT_H__
#define __DOROTHY_EVENT_OEVENT_H__

NS_DOROTHY_BEGIN

class oListener;
class oEventType;
class oEvent;
typedef Delegate<void (oEvent* event)> oEventHandler;

/** @brief The event system is associate with event,
 event type and event listener.Use the system as following.
 @example User defined event.
 // Register callback function.
 oEvent::addListener("UserEvent", [](oEvent* event)
 {
 	Slice msg;
 	oEvent::retrieve(event, msg);
	oLog("Recieved Event with msg: %s", msg);
 });

 // Send event, then the callback function will be invoked.
 oEvent::send("UserEvent", Slice("info1"));
 oEvent::send("UserEvent", Slice("msg2"));
 */
class oEvent
{
public:
	oEvent();
	virtual ~oEvent();
	oEvent(oSlice name);
	inline const string& getName() const { return _name; }
	virtual int pushArgsToLua() { return 0; }
public:
	static oListener* addListener(const string& name, const oEventHandler& handler);
	static void clear();

	template<class... Args>
	static void send(oSlice name, Args&&... args);

	template<class... Args>
	static void retrieve(oEvent* event, Args&... args);
private:
	static void reg(oListener* listener);
	static void unreg(oListener* listener);
	static unordered_map<string, oOwn<oEventType>> _eventMap;
protected:
	static void send(oEvent* event);
	string _name;
	friend class oListener;
};

template<class... Fields>
class oEventArgs : public oEvent
{
public:
	template<class... Args>
	static void send(oSlice name, Args&&... args)
	{
		_event._name = name;
		_event.arguments = std::make_tuple(args...);
		oEvent::send(&_event);
	}
	virtual int pushArgsToLua() override
	{
		oTupleForeach(arguments, ArgsPusher());
		return std::tuple_size<decltype(arguments)>::value;
	}
	std::tuple<Fields...> arguments;
private:
	struct ArgsPusher
	{
		template<typename T>
		void operator()(const T& element)
		{
			oSharedLueEngine.push(element);
		}
	};
	static oEventArgs<Fields...> _event;
};

template<class... Fields>
oEventArgs<Fields...> oEventArgs<Fields...>::_event;

template<class... Args>
void oEvent::send(oSlice name, Args&&... args)
{
	oEventArgs<Args...>::send(name, args...);
}

template<class... Args>
void oEvent::retrieve(oEvent* event, Args&... args)
{
	auto targetEvent = dynamic_cast<oEventArgs<Args...>*>(event);
	oAssertIf(targetEvent == nullptr, "no required event argument type can be retrieved.");
	std::tie(args...) = targetEvent->arguments;
}

NS_DOROTHY_END

#endif //__DOROTHY_EVENT_OEVENT_H__

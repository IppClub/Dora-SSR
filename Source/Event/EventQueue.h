/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Other/concurrentqueue.h"
#include "Support/Value.h"

NS_DORA_BEGIN

class QEvent {
public:
	QEvent(String name);
	virtual ~QEvent();
	inline const std::string& getName() const { return _name; }

	/** @brief Helper function to retrieve the passed event arguments.
	 */
	template <class... Args>
	void get(Args&... args);

protected:
	std::string _name;
	DORA_TYPE_BASE(QEvent);
};

template <class... Fields>
class QEventArgs : public QEvent {
public:
	template <class... Args>
	QEventArgs(String name, Args&&... args)
		: QEvent(name)
		, arguments{std::forward<Args>(args)...} { }
	std::tuple<Fields...> arguments;
	DORA_TYPE_OVERRIDE(QEventArgs<Fields...>);
};

template <class... Args>
void QEvent::get(Args&... args) {
	auto targetEvent = DoraAs<QEventArgs<special_decay_t<Args>...>>(this);
	AssertIf(targetEvent == nullptr, "no required event argument type can be retrieved.");
	std::tie(args...) = std::move(targetEvent->arguments);
}

/** @brief This event system is designed to be used in a multi-threaded
 environment to communicated between two threads.
 Use this system as following.
 @example Communicate between threads.
 // Define a event queue.
 EventQueue _eventForOne;

 // Define worker functions.
 int threadOneFunc(void* userData)
 {
	while (true)
	{
		for (Own<QEvent> event = _eventForOne.poll();
			event != nullptr;
			event = _eventForOne.poll())
		{
			switch (Switch::hash(event->getName()))
			{
				case "Whatever"_hash:
				{
					int val1, val2;
					Slice msg;
					event->get(val1, val2, msg);
					Log("{}, {}, {}", val1, val2, msg);
					break;
				}
			}
		}
	}
	return 0;
 }
 int threadTwoFunc(void* userData)
 {
	while (true)
	{
		_eventForOne.post("Whatever"_slice, 998, 233, "msg"_slice);
	}
	return 0;
 }

 // execute threads
 threadOne.init(threadOneFunc);
 threadTwo.init(threadTwoFunc);
 */
class EventQueue {
public:
	EventQueue();
	~EventQueue();

	/** @brief Post a new event,
	 for producer thread use.
	 */
	template <class... Args>
	void post(String name, Args&&... args) {
		auto event = new QEventArgs<special_decay_t<Args>...>(name, std::forward<Args>(args)...);
		_queue.enqueue(event);
	}

	/** @brief Try get a posted event and consume it,
	 for consumer thread use.
	 Return null item if there is no event posted.
	 */
	Own<QEvent> poll();

private:
	moodycamel::ConcurrentQueue<QEvent*> _queue;
};

NS_DORA_END

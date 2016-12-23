/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_EVENT_EVENTQUEUE_H__
#define __DOROTHY_EVENT_EVENTQUEUE_H__

#include "bx/spscqueue.h"

NS_DOROTHY_BEGIN
/*
class oQEvent
{
public:
	oQEvent(int id);
	virtual ~oQEvent();
private:
	int _id;
};

class oEventQueue
{
public:
	~oEventQueue()
	{
		for (const Event* ev = poll(); NULL != ev; ev = poll() )
		{
			release(ev);
		}
	}

	void postEvent()
	{
		Event* ev = new Event(Event::Exit);
		m_queue.push(ev);
	}

	const Event* poll()
	{
		return m_queue.pop();
	}

	void release(const Event* _event) const
	{
		delete _event;
	}

private:
	bx::SpScUnboundedQueue<Event> m_queue;
};
*/

NS_DOROTHY_END

#endif //__DOROTHY_EVENT_EVENTQUEUE_H__

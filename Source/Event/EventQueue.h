/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_EVENT_EVENTQUEUE_H__
#define __DOROTHY_EVENT_EVENTQUEUE_H__

#include "bx/spscqueue.h"

NS_DOROTHY_BEGIN

class QEvent
{
public:
	QEvent(int id);
	virtual ~QEvent();
private:
	int _id;
};

class EventQueue
{
public:
	~EventQueue()
	{
		for (const QEvent* ev = poll(); ev; ev = poll())
		{
			release(ev);
		}
	}

	void postEvent()
	{
		QEvent* ev = new QEvent(0);
		m_queue.push(ev);
	}

	const QEvent* poll()
	{
		return m_queue.pop();
	}

	void release(const QEvent* _event) const
	{
		delete _event;
	}

private:
	bx::SpScUnboundedQueue<QEvent> m_queue;
};

NS_DOROTHY_END

#endif //__DOROTHY_EVENT_EVENTQUEUE_H__

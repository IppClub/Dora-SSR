/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/oHeader.h"
#include "Event/oEventType.h"
#include "Event/oEvent.h"
#include "Event/oListener.h"

NS_DOROTHY_BEGIN

oEventType::oEventType( const string& name ):
_name(name)
{ }

const string& oEventType::getName() const
{
	return _name;
}

void oEventType::add( oListener* listener )
{
	if (listener->_order == oListener::InvalidOrder)
	{
		listener->_order = (int)_listeners.size();
		_listeners.push_back(listener);
	}
}

void oEventType::remove( oListener* listener )
{
	if (listener->_order != oListener::InvalidOrder)
	{
		_listeners[listener->_order] = nullptr;
		listener->_order = oListener::InvalidOrder;
	}
}

void oEventType::handle( oEvent* e )
{
	for (int i = 0; i < (int)_listeners.size(); i++)
	{
		if (_listeners[i] == nullptr)
		{
			int last = (int)_listeners.size() - 1;
			for (;last >= 0 && _listeners[last] == nullptr;_listeners.pop_back(), --last);
			if (i > last)
			{
				break;
			}
			if (_listeners.size() > 0)
			{
				_listeners[i] = _listeners[_listeners.size() - 1];
				_listeners[i]->_order = i;
				_listeners.pop_back();
			}
		}
		_listeners[i]->handle(e);
	}
}

bool oEventType::isEmpty() const
{
	return _listeners.empty();
}

NS_DOROTHY_END

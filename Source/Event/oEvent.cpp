/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/oHeader.h"
#include "Event/oEvent.h"
#include "Event/oEventType.h"
#include "Event/oListener.h"

NS_DOROTHY_BEGIN

unordered_map<string, oOwn<oEventType>> oEvent::_eventMap;

oEvent::oEvent()
{}

oEvent::oEvent( oSlice name ):
_name(name)
{ }

oEvent::~oEvent()
{ }

void oEvent::clear()
{
	_eventMap.clear();
}

void oEvent::unreg( oListener* listener )
{
	auto it = _eventMap.find(listener->getName());
	if (it != _eventMap.end())
	{
		oEventType* type = it->second;
		type->remove(listener);
		if (type->isEmpty())
		{
			_eventMap.erase(it);
		}
	}
}

void oEvent::reg( oListener* listener )
{
	auto it = _eventMap.find(listener->getName());
	if (it != _eventMap.end())
	{
		it->second->add(listener);
	}
	else
	{
		oEventType* type = new oEventType(listener->getName());
		_eventMap[listener->getName()] = oOwnMake(type);
		type->add(listener);
	}
}

void oEvent::send( oEvent* e )
{
	auto it = _eventMap.find(e->getName());
	if (it != _eventMap.end())
	{
		it->second->handle(e);
	}
}

oListener* oEvent::addListener( const string& name, const oEventHandler& handler )
{
	oListener* listener = oListener::create(name, handler);
	return listener;
}

NS_DOROTHY_END

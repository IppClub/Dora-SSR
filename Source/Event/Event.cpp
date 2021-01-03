/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Event/Event.h"
#include "Event/EventType.h"
#include "Event/Listener.h"

NS_DOROTHY_BEGIN

unordered_map<string, Own<EventType>> Event::_eventMap;

Event::Event(String name):
_name(name)
{ }

Event::~Event()
{ }

void Event::clear()
{
	_eventMap.clear();
}

void Event::unreg(Listener* listener)
{
	auto it = _eventMap.find(listener->getName());
	if (it != _eventMap.end())
	{
		EventType* type = it->second.get();
		type->remove(listener);
		if (type->isEmpty())
		{
			_eventMap.erase(it);
		}
	}
}

void Event::reg(Listener* listener)
{
	auto it = _eventMap.find(listener->getName());
	if (it != _eventMap.end())
	{
		it->second->add(listener);
	}
	else
	{
		EventType* type = new EventType(listener->getName());
		_eventMap[listener->getName()] = MakeOwn(type);
		type->add(listener);
	}
}

void Event::send(Event* e)
{
	auto it = _eventMap.find(e->getName());
	if (it != _eventMap.end())
	{
		it->second->handle(e);
	}
}

Listener* Event::addListener(String name, const EventHandler& handler)
{
	Listener* listener = Listener::create(name, handler);
	return listener;
}

LuaEventArgs::LuaEventArgs(String name, int paramCount):
Event(name),
_paramCount(paramCount)
{ }

void LuaEventArgs::send(String name, int paramCount)
{
	LuaEventArgs event(name, paramCount);
	Event::send(&event);
}

int LuaEventArgs::pushArgsToLua()
{
	lua_State* L = SharedLuaEngine.getState();
	int top = lua_gettop(L);
	for (int index = top-_paramCount+1; index <= top; index++)
	{
		lua_pushvalue(L, index);
	}
	return _paramCount;
}

int LuaEventArgs::getParamCount() const
{
	return _paramCount;
}

NS_DOROTHY_END

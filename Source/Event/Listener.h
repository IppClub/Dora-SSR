/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Event;
class EventType;

typedef Delegate<void (Event* event)> EventHandler;

/** @brief Use event listener to handle event. */
class Listener : public Object
{
public:
	virtual ~Listener();
	virtual bool init() override;
	const string& getName() const;
	/** True to receive event and handle it, false to not receive event. */
	void setEnabled(bool enable);
	/** Get is registered. */
	bool isEnabled() const;
	/** Change the callback delegate. */
	void setHandler(const EventHandler& handler);
	/** Get callback delegate. */
	const EventHandler& getHandler() const;
	void clearHandler();
	/** Invoked when event is received. */
	void handle(Event* e);
	/** Use it to create a new listener. You may want to get the listener retained for future use. */
	CREATE_FUNC(Listener);
protected:
	Listener(const string& name, const EventHandler& handler);
	Listener(const string& name, int handler);
	bool _enabled;
	string _name;
	EventHandler _handler;
	friend class EventType;
	LUA_TYPE_OVERRIDE(Listener)
};

NS_DOROTHY_END

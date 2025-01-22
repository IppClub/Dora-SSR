/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

class Event;
class EventType;

typedef std::function<void(Event*)> EventHandler;

/** @brief Use event listener to handle event. */
class Listener : public Object {
public:
	PROPERTY_BOOL(Enabled);
	PROPERTY_CREF(EventHandler, Handler);
	PROPERTY_READONLY_CREF(std::string, Name);
	virtual ~Listener();
	virtual bool init() override;
	void clearHandler();
	void handle(Event* e);
	CREATE_FUNC_NOT_NULL(Listener);

protected:
	Listener(const std::string& name, const EventHandler& handler);

private:
	bool _enabled;
	std::string _name;
	EventHandler _handler;
	friend class EventType;
	DORA_TYPE_OVERRIDE(Listener);
};

NS_DORA_END

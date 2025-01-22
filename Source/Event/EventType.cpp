/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Event/EventType.h"

#include "Event/Event.h"
#include "Event/Listener.h"

NS_DORA_BEGIN

EventType::EventType(const std::string& name)
	: _name(name) { }

const std::string& EventType::getName() const noexcept {
	return _name;
}

void EventType::add(Listener* listener) {
	if (!listener->_enabled) {
		listener->_enabled = true;
		_listeners.push_back(listener);
	}
}

void EventType::remove(Listener* listener) {
	if (listener->_enabled) {
		listener->_enabled = false;
		_listeners.erase(std::remove(_listeners.begin(), _listeners.end(), listener));
	}
}

void EventType::handle(Event* event, int index) {
	if (index >= 0) {
		// save listener on stack and make a reference here
		Ref<Listener> listener(_listeners[index]);
		EventType::handle(event, index - 1);
		listener->handle(event);
	}
}

void EventType::handle(Event* event) {
	EventType::handle(event, s_cast<int>(_listeners.size()) - 1);
}

bool EventType::isEmpty() const noexcept {
	return _listeners.empty();
}

NS_DORA_END

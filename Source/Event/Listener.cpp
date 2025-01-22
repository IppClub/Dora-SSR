/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Event/Listener.h"

#include "Event/Event.h"

NS_DORA_BEGIN

bool Listener::init() {
	if (!Object::init()) return false;
	Listener::setEnabled(true);
	return true;
}

void Listener::setEnabled(bool enable) {
	if (enable) {
		Event::reg(this);
	} else {
		Event::unreg(this);
	}
}

bool Listener::isEnabled() const noexcept {
	return _enabled;
}

void Listener::setHandler(const EventHandler& handler) {
	_handler = handler;
}

const EventHandler& Listener::getHandler() const noexcept {
	return _handler;
}

void Listener::clearHandler() {
	_handler = nullptr;
}

void Listener::handle(Event* e) {
	if (_handler) {
		_handler(e);
	}
}

Listener::Listener(const std::string& name, const EventHandler& handler)
	: _name(name)
	, _handler(handler)
	, _enabled(false) { }

const std::string& Listener::getName() const noexcept {
	return _name;
}

Listener::~Listener() {
	Listener::setEnabled(false);
}

NS_DORA_END

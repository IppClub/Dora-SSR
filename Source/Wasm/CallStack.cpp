/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Const/Header.h"
#include "Wasm/WasmRuntime.h"

NS_DORA_BEGIN

void CallStack::push(uint64_t value) { _stack.push_back(s_cast<int64_t>(value)); }
void CallStack::push(int64_t value) { _stack.push_back(value); }
void CallStack::push(double value) { _stack.push_back(value); }
void CallStack::push(bool value) { _stack.push_back(value); }
void CallStack::push(String value) { _stack.push_back(value.toString()); }
void CallStack::push(Object* value) { _stack.push_back(value); }
void CallStack::push(const Vec2& value) { _stack.push_back(value); }
void CallStack::push(const Vec3& value) { _stack.push_back(value); }
void CallStack::push(const Size& value) { _stack.push_back(value); }
void CallStack::push_v(dora_val_t value) { _stack.push_back(value); }

bool CallStack::empty() const {
	return _stack.empty();
}

dora_val_t CallStack::pop() {
	auto var = _stack.front();
	_stack.pop_front();
	return var;
}

bool CallStack::pop_bool_or(bool def) {
	if (_stack.empty()) return def;
	auto var = _stack.front();
	_stack.pop_front();
	return std::holds_alternative<bool>(var) ? std::get<bool>(var) : def;
}

dora_val_t& CallStack::front() {
	return _stack.front();
}

void CallStack::clear() {
	_stack.clear();
}

NS_DORA_END

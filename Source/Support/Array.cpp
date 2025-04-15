/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Support/Array.h"

NS_DORA_BEGIN

Array::Array() { }

Array::Array(NotNull<Array, 1> other)
	: _data(other->_data.size()) {
	for (size_t i = 0; i < other->_data.size(); i++) {
		_data.push_back(other->_data[i]->clone());
	}
}

Array::Array(size_t capacity) {
	_data.reserve(capacity);
}

size_t Array::getCount() const noexcept {
	return _data.size();
}

const Own<Value>& Array::getLast() const {
	AssertIf(_data.empty(), "get last item from an empty array.");
	return _data.back();
}

const Own<Value>& Array::getFirst() const {
	AssertIf(_data.empty(), "get first item from an empty array.");
	return _data.front();
}

const Own<Value>& Array::getRandomObject() const {
	AssertIf(_data.empty(), "retrieving random item from an empty array.");
	return _data[std::rand() % _data.size()];
}

bool Array::isEmpty() const noexcept {
	return _data.empty();
}

bool Array::contains(NotNull<Value, 1> value) const {
	return std::find_if(_data.begin(), _data.end(), [&](const Own<Value>& val) {
		return value->equals(val.get());
	}) != _data.end();
}

void Array::add(Own<Value>&& value) {
	AssertIf(_traversing, "Can not add item to array while traversing");
	_data.push_back(std::move(value));
}

void Array::addRange(NotNull<Array, 1> other) {
	AssertIf(_traversing, "Can not add range to array while traversing");
	for (const auto& item : other->_data) {
		_data.push_back(item->clone());
	}
}

void Array::removeFrom(NotNull<Array, 1> other) {
	AssertIf(_traversing, "Can not remove item from array while traversing");
	for (const auto& it : other->_data) {
		Array::remove(it.get());
	}
}

Own<Value> Array::removeLast() {
	AssertIf(_traversing, "Can not remove item from array while traversing");
	auto value = _data.back()->clone();
	_data.pop_back();
	return value;
}

bool Array::remove(NotNull<Value, 1> value) {
	AssertIf(_traversing, "Can not remove item from array while traversing");
	auto it = std::remove_if(_data.begin(), _data.end(), [&](Own<Value>& item) {
		return item->equals(value);
	});
	if (it == _data.end()) return false;
	_data.erase(it);
	return true;
}

void Array::clear() {
	AssertIf(_traversing, "Can not clear array while traversing");
	_data.clear();
}

bool Array::fastRemove(NotNull<Value, 1> value) {
	AssertIf(_traversing, "Can not remove item from array while traversing");
	size_t ind = index(value);
	if (ind < _data.size()) {
		_data.at(ind) = std::move(_data.back());
		_data.pop_back();
		return true;
	}
	return false;
}

void Array::swap(NotNull<Value, 1> objectA, NotNull<Value, 2> objectB) {
	std::swap(_data[index(objectA)], _data[index(objectB.get())]);
}

void Array::swap(size_t indexA, size_t indexB) {
	std::swap(_data[indexA], _data[indexB]);
}

void Array::reverse() {
	AssertIf(_traversing, "Can not reverse array while traversing");
	std::reverse(_data.begin(), _data.end());
}

void Array::shrink() {
	AssertIf(_traversing, "Can not shrink array while traversing");
	_data.shrink_to_fit();
}

int Array::index(NotNull<Value, 1> value) {
	auto it = std::find_if(_data.begin(), _data.end(), [&](const Own<Value>& val) {
		return value->equals(val.get());
	});
	if (it == _data.end()) {
		return -1;
	}
	return s_cast<int>(std::distance(_data.begin(), it));
}

void Array::set(size_t index, Own<Value>&& value) {
	_data[index] = std::move(value);
}

Own<Value>& Array::get(size_t index) {
	return _data[index];
}

const Own<Value>& Array::get(size_t index) const {
	return _data[index];
}

void Array::insert(size_t index, Own<Value>&& value) {
	AssertIf(_traversing, "Can not insert item to array while traversing");
	_data.insert(_data.begin() + index, std::move(value));
}

bool Array::removeAt(size_t index) {
	AssertIf(_traversing, "Can not remove item from array while traversing");
	if (index < _data.size()) {
		_data.erase(_data.begin() + index);
		return true;
	}
	return false;
}

bool Array::fastRemoveAt(size_t index) {
	AssertIf(_traversing, "Can not remove item from array while traversing");
	if (index < _data.size()) {
		_data[index] = std::move(_data.back());
		_data.pop_back();
		return true;
	}
	return false;
}

const std::vector<Own<Value>>& Array::data() const {
	return _data;
}

std::vector<Own<Value>>& Array::data() {
	return _data;
}

NS_DORA_END

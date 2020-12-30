/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Support/Array.h"

NS_DOROTHY_BEGIN

Array::Array()
{ }

Array::Array(Array* other):
_data(other->_data.size())
{
	for (size_t i = 0; i < other->_data.size(); i++)
	{
		_data[i] = other->_data[i]->clone();
	}
}

Array::Array(size_t capacity):
_data(capacity)
{ }

size_t Array::getCount() const
{
	return _data.size();
}

size_t Array::getCapacity() const
{
	return _data.capacity();
}

const Own<Value>& Array::getLast() const
{
	AssertIf(_data.empty(), "get last item from an empty array.");
	return _data.back();
}

const Own<Value>& Array::getFirst() const
{
	AssertIf(_data.empty(), "get first item from an empty array.");
	return _data.front();
}

const Own<Value>& Array::getRandomObject() const
{
	AssertIf(_data.empty(), "retrieving random item from an empty array.");
	return _data[std::rand() % _data.size()];
}

bool Array::isEmpty() const
{
	return _data.empty();
}

bool Array::contains(Value* value) const
{
	return std::find_if(_data.begin(), _data.end(), [&](const Own<Value>& val)
	{
		return value->equals(val.get());
	}) != _data.end();
}

void Array::add(Own<Value>&& value)
{
	_data.push_back(std::move(value));
}

void Array::addRange(Array* other)
{
	for (const auto& item : other->_data)
	{
		_data.push_back(item->clone());
	}
}

void Array::removeFrom(Array* other)
{
	for (const auto& it : other->_data)
	{
		Array::remove(it.get());
	}
}

Own<Value> Array::removeLast()
{
	auto value = _data.back()->clone();
	_data.pop_back();
	return value;
}

bool Array::remove(Value* value)
{
	auto it = std::remove_if(_data.begin(), _data.end(), [&](Own<Value>& item)
	{
		return item->equals(value);
	});
	if (it == _data.end()) return false;
	_data.erase(it);
	return true;
}

void Array::clear()
{
	_data.clear();
}

bool Array::fastRemove(Value* value)
{
	size_t ind = index(value);
	if (ind < _data.size())
	{
		_data.at(ind) = std::move(_data.back());
		_data.pop_back();
		return true;
	}
	return false;
}

void Array::swap(Value* objectA, Value* objectB)
{
	std::swap(_data[index(objectA)], _data[index(objectB)]);
}

void Array::swap(size_t indexA, size_t indexB)
{
	std::swap(_data[indexA], _data[indexB]);
}

void Array::reverse()
{
	std::reverse(_data.begin(), _data.end());
}

void Array::shrink()
{
	_data.shrink_to_fit();
}

size_t Array::index(Value* value)
{
	auto it = std::find_if(_data.begin(), _data.end(), [&](const Own<Value>& val)
	{
		return value->equals(val.get());
	});
	return std::distance(_data.begin(), it);
}

void Array::set(size_t index, Own<Value>&& value)
{
	if (value)
	{
		_data[index] = std::move(value);
	}
	else
	{
		_data[index] = nullptr;
	}
}

const Own<Value>& Array::get(size_t index) const
{
	return _data[index];
}

void Array::insert(size_t index, Own<Value>&& value)
{
	_data.insert(_data.begin() + index, std::move(value));
}

bool Array::removeAt(size_t index)
{
	if (index < _data.size())
	{
		_data.erase(_data.begin() + index);
		return true;
	}
	return false;
}

bool Array::fastRemoveAt(size_t index)
{
	if (index < _data.size())
	{
		_data[index] = std::move(_data.back());
		_data.pop_back();
		return true;
	}
	return false;
}

vector<Own<Value>>& Array::data()
{
	return _data;
}

NS_DOROTHY_END

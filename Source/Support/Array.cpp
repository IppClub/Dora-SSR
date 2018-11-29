/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Support/Array.h"

NS_DOROTHY_BEGIN

Array::Array()
{ }

Array::Array(Array* other):
_data(other->_data)
{ }

Array::Array(int capacity):
_data(capacity)
{ }

int Array::getCount() const
{
	return s_cast<int>(_data.size());
}

int Array::getCapacity() const
{
	return s_cast<int>(_data.capacity());
}

const Ref<Object>& Array::getLast() const
{
	return _data.back();
}

const Ref<Object>& Array::getFirst() const
{
	return _data.front();
}

const Ref<Object>& Array::getRandomObject() const
{
	AssertIf(_data.empty(), "retrieving random item from an empty array.");
	return _data[std::rand()%_data.size()];
}

bool Array::isEmpty() const
{
	return _data.empty();
}

bool Array::contains(Object* object) const
{
	return std::find(_data.begin(), _data.end(), MakeRef(object)) != _data.end();
}

void Array::add(Object* object)
{
	_data.push_back(object);
}

void Array::addRange(Array* other)
{
	_data.insert(_data.end(), other->_data.begin(), other->_data.end());
}

void Array::removeFrom(Array* other)
{
	for (const auto& it : other->_data)
	{
		Array::remove(it);
	}
}

Ref<Object> Array::removeLast()
{
	Ref<Object> item(_data.back());
	item->autoretain();
	_data.pop_back();
	return item;
}

bool Array::remove(Object* object)
{
	return _data.remove(object);
}

void Array::clear()
{
	_data.clear();
}

bool Array::fastRemove(Object* object)
{
	return _data.fast_remove(object);
}

void Array::swap(Object* objectA, Object* objectB)
{
	std::swap(_data[index(objectA)], _data[index(objectB)]);
}

void Array::swap(int indexA, int indexB)
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

int Array::index(Object* object)
{
	size_t index = std::distance(_data.begin(), _data.index(object));
	return index == _data.size() ? -1 : s_cast<int>(index);
}

void Array::set(int index, Object* object)
{
	_data[index] = object;
}

const Ref<Object>& Array::get(int index) const
{
	return _data[index];
}

void Array::insert(int index, Object* object)
{
	_data.insert(index, object);
}

bool Array::removeAt(int index)
{
	if (index < s_cast<int>(_data.size()))
	{
		_data.erase(_data.begin() + index);
		return true;
	}
	return false;
}

bool Array::fastRemoveAt(int index)
{
	if (index < s_cast<int>(_data.size()))
	{
		_data[index] = _data.back();
		_data.pop_back();
		return true;
	}
	return false;
}

RefVector<Object>& Array::data()
{
	return _data;
}

NS_DOROTHY_END

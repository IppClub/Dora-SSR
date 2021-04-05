/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Support/Value.h"

NS_DOROTHY_BEGIN

class Array : public Object
{
public:
	PROPERTY_READONLY(size_t, Count);
	PROPERTY_READONLY(size_t, Capacity);
	PROPERTY_READONLY_CREF(Own<Value>, Last);
	PROPERTY_READONLY_CREF(Own<Value>, First);
	PROPERTY_READONLY_CREF(Own<Value>, RandomObject);
	PROPERTY_READONLY_BOOL(Empty);
	bool contains(Value* value) const;
	void add(Own<Value>&& value);
	void addRange(Array* other);
	void removeFrom(Array* other);
	Own<Value> removeLast();
	bool remove(Value* value);
	void clear();
	bool fastRemove(Value* value);
	void swap(Value* valueA, Value* valueB);
	void swap(size_t indexA, size_t indexB);
	void reverse();
	void shrink();
	size_t index(Value* value);
	void set(size_t index, Own<Value>&& value);
	const Own<Value>& get(size_t index) const;
	void insert(size_t index, Own<Value>&& value);
	bool removeAt(size_t index);
	bool fastRemoveAt(size_t index);
	std::vector<Own<Value>>& data();
	CREATE_FUNC(Array);
public:
	template <class Func>
	bool each(const Func& handler)
	{
		for (const auto& item : _data)
		{
			if (handler(item.get())) return true;
		}
		return false;
	}
	template <class Cond>
	void removeIf(const Cond& cond)
	{
		_data.erase(std::remove_if(_data.begin(), _data.end(), cond), _data.end());
	}
protected:
	Array();
	Array(Array* other);
	Array(size_t capacity);
private:
	std::vector<Own<Value>> _data;
	DORA_TYPE_OVERRIDE(Array);
};

#define ARRAY_START(type,varName,array) \
	if (array && !array->isEmpty()) \
	{ \
		for (const auto& _item_ : array->data()) \
		{ \
			type* varName = &_item_->to<type>();

#define ARRAY_END }}

NS_DOROTHY_END

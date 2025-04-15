/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Support/Value.h"

NS_DORA_BEGIN

class Array : public Object {
public:
	Array(const Array&) = delete;
	PROPERTY_READONLY(size_t, Count);
	PROPERTY_READONLY_CREF_EXCEPT(Own<Value>, Last);
	PROPERTY_READONLY_CREF_EXCEPT(Own<Value>, First);
	PROPERTY_READONLY_CREF_EXCEPT(Own<Value>, RandomObject);
	PROPERTY_READONLY_BOOL(Empty);
	bool contains(NotNull<Value, 1> value) const;
	void add(Own<Value>&& value);
	void addRange(NotNull<Array, 1> other);
	void removeFrom(NotNull<Array, 1> other);
	Own<Value> removeLast();
	bool remove(NotNull<Value, 1> value);
	void clear();
	bool fastRemove(NotNull<Value, 1> value);
	void swap(NotNull<Value, 1> valueA, NotNull<Value, 2> valueB);
	void swap(size_t indexA, size_t indexB);
	void reverse();
	void shrink();
	int index(NotNull<Value, 1> value);
	void set(size_t index, Own<Value>&& value);
	Own<Value>& get(size_t index);
	const Own<Value>& get(size_t index) const;
	void insert(size_t index, Own<Value>&& value);
	bool removeAt(size_t index);
	bool fastRemoveAt(size_t index);
	const std::vector<Own<Value>>& data() const;
	std::vector<Own<Value>>& data();
	CREATE_FUNC_NOT_NULL(Array);

public:
	template <class Func>
	bool each(const Func& handler) {
		_traversing = true;
		DEFER(_traversing = false);
		for (const auto& item : _data) {
			if (handler(item.get())) return true;
		}
		return false;
	}
	template <class Cond>
	void removeIf(const Cond& cond) {
		AssertIf(_traversing, "Can not remove item from array while traversing");
		_data.erase(std::remove_if(_data.begin(), _data.end(), cond), _data.end());
	}

protected:
	Array();
	Array(NotNull<Array, 1> other);
	Array(size_t capacity);

private:
	bool _traversing = false;
	std::vector<Own<Value>> _data;
	DORA_TYPE_OVERRIDE(Array);
};

#define ARRAY_START_VAL(type, varName, array) \
	if (array && !array->isEmpty()) { \
		array->each([&](Value* _item_) { \
			do { \
				type varName = _item_->toVal<type>();

#define ARRAY_START(type, varName, array) \
	if (array && !array->isEmpty()) { \
		array->each([&](Value* _item_) { \
			do { \
				type* varName = _item_->to<type>();

#define ARRAY_END \
			} while (false); \
			return false; \
		}); \
	}

NS_DORA_END

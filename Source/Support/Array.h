/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Array : public Object
{
public:
	PROPERTY_READONLY(int, Count);
	PROPERTY_READONLY(int, Capacity);
	PROPERTY_READONLY_REF(Ref<Object>, Last);
	PROPERTY_READONLY_REF(Ref<Object>, First);
	PROPERTY_READONLY_REF(Ref<Object>, RandomObject);
	PROPERTY_READONLY_BOOL(Empty);
	bool contains(Object* object) const;
	void add(Object* object);
	void addRange(Array* other);
	void removeFrom(Array* other);
	Ref<Object> removeLast();
	bool remove(Object* object);
	void clear();
	void fastRemove(Object* object);
	void swap(Object* objectA, Object* objectB);
	void swap(int indexA, int indexB);
	void reverse();
	void shrink();
	int index(Object* object);
	void set(int index, Object* object);
	const Ref<Object>& get(int index) const;
	void insert(int index, Object* object);
	void removeAt(int index);
	void fastRemoveAt(int index);
	RefVector<Object>& data();
	CREATE_FUNC(Array);
public:
	template <class Func>
	bool each(const Func& handler)
	{
		for (int i = 0; i < getCount(); i++)
		{
			if (handler(get(i), i)) return true;
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
	Array(int capacity);
	Array(Object* objects[], int size);
private:
	RefVector<Object> _data;
	DORA_TYPE_OVERRIDE(Array);
};

#define ARRAY_START(type,varName,array) \
	if (array) \
	{ \
		for (const auto& _item_ : array->data()) \
		{ \
			type* varName = _item_.to<type>();

#define ARRAY_END }}

NS_DOROTHY_END

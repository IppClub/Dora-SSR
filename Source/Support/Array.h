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
	PROPERTY(int, Capacity);
	PROPERTY_REF(Ref<Object>, Last);
	PROPERTY_REF(Ref<Object>, First);
	PROPERTY_REF(Ref<Object>, RandomObject);
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
protected:
	Array();
	Array(Array* other);
	Array(int capacity);
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

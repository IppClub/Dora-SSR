/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DOROTHY_BEGIN

template <class T>
class ValueEx;

class Value : public Object
{
public:
	template <class T>
	const T& to();

	template <class T>
	ValueEx<T>* as();

	template <class T>
	static Value* create(const T& value);
};

template <class T>
class ValueEx : public Value
{
public:
	inline void set(const T& value)
	{
		_value = value;
	}
	inline const T& get() const
	{
		return _value;
	}
	CREATE_FUNC(ValueEx<T>);
protected:
	ValueEx(const T& value):
	_value(value)
	{ }
private:
	T _value;
	DORA_TYPE_OVERRIDE(ValueEx<T>);
};

template <class T>
const T& Value::to()
{
	auto item = DoraCast<ValueEx<T>>(this);
	AssertUnless(item, "can not get value of target type from value object.");
	return item->get();
}

template <class T>
ValueEx<T>* Value::as()
{
	return DoraCast<ValueEx<T>>(this);
}

template <class T>
Value* Value::create(const T& value)
{
	return ValueEx<T>::create(value);
}

class Values : public Object
{
public:
	virtual ~Values() { }
	template<class... Args>
	static Ref<Values> create(const Args&... args);
	template<class... Args>
	void get(Args&... args);
	static const Ref<Values> None;
protected:
	Values() { }
};

template<class... Fields>
class ValuesEx : public Values
{
public:
	template<class... Args>
	ValuesEx(const Args&... args):values(std::make_tuple(args...))
	{ }
	std::tuple<Fields...> values;
};

template<class... Args>
Ref<Values> Values::create(const Args&... args)
{
	auto item = new ValuesEx<Args...>(args...);
	Ref<Values> itemRef(item);
	item->release();
	return itemRef;
}

template<class... Args>
void Values::get(Args&... args)
{
	auto values = d_cast<ValuesEx<Args...>*>(this);
	AssertIf(values == nullptr, "no required value type can be retrieved.");
	std::tie(args...) = values->values;
}

NS_DOROTHY_END

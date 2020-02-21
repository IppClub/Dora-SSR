/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"
#include "Lua/LuaEngine.h"

NS_DOROTHY_BEGIN

template <class T>
struct unwrap_refwrapper
{
    using type = T;
};

template <class T>
struct unwrap_refwrapper<std::reference_wrapper<T>>
{
    using type = T&;
};

template <class T>
using special_decay_t = typename unwrap_refwrapper<typename std::decay<T>::type>::type;

template <class T, class Enable = void>
class ValueEx;

class Value : public Object
{
public:
	template <class T>
	const T& to();

	template <class T>
	ValueEx<T>* as();

	virtual Value* clone() const = 0;
	virtual void pushToLua(lua_State* L) const = 0;

	template <class T>
	static Value* create(T&& value);
protected:
	Value() { }
};

template <class T>
class ValueEx<T, typename std::enable_if<!std::is_base_of<Object, T>::value>::type> : public Value
{
public:
	inline void set(const T& value)
	{
		_value = value;
	}
	inline const T& get()
	{
		return _value;
	}
	virtual Value* clone() const override
	{
		return ValueEx<T>::create(_value);
	}
	virtual bool equals(Object* other) const override
	{
		if (this != other)
		{
			return getDoraType() == other->getDoraType()
			&& s_cast<decltype(this)>(other)->_value == _value;
		}
		return true;
	}
	virtual void pushToLua(lua_State* L) const override
	{
		LuaEngine::push(L, _value);
	}
	CREATE_FUNC(ValueEx<T>);
protected:
	ValueEx(const T& value):
	_value(value)
	{ }
	ValueEx(T&& value):
	_value(std::forward<T>(value))
	{ }
private:
	T _value;
	DORA_TYPE_OVERRIDE(ValueEx<T>);
};

template<>
class ValueEx<Object*> : public Value
{
public:
	inline void set(Object* value)
	{
		_value = value;
	}
	inline Object* get()
	{
		return _value.get();
	}
	virtual Value* clone() const override
	{
		return ValueEx<Object*>::create(_value);
	}
	virtual void pushToLua(lua_State* L) const override
	{
		LuaEngine::push(L, _value.get());
	}
	CREATE_FUNC(ValueEx<Object*>);
protected:
	ValueEx(Object* value):
	_value(value)
	{ }
private:
	Ref<> _value;
	DORA_TYPE_OVERRIDE(ValueEx<Object*>);
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
Value* Value::create(T&& value)
{
	return ValueEx<special_decay_t<T>>::create(value);
}

class Values : public Object
{
public:
	virtual ~Values() { }
	template<class... Args>
	static Ref<Values> create(Args&&... args);
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
	ValuesEx(Args&&... args):values{std::forward<Args>(args)...}
	{ }
	std::tuple<Fields...> values;
	DORA_TYPE_OVERRIDE(ValuesEx<Fields...>);
};

template<class... Args>
Ref<Values> Values::create(Args&&... args)
{
	auto item = new ValuesEx<special_decay_t<Args>...>(std::forward<Args>(args)...);
	Ref<Values> itemRef(item);
	item->release();
	return itemRef;
}

template<class... Args>
void Values::get(Args&... args)
{
	auto values = DoraCast<ValuesEx<special_decay_t<Args>...>>(this);
	AssertIf(values == nullptr, "no required value type can be retrieved.");
	std::tie(args...) = std::move(values->values);
}

NS_DOROTHY_END

/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

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

class Value
{
public:
	virtual ~Value() { }
	template <class T>
	T& to();
	template <class T>
	T* as();
	virtual Own<Value> clone() const = 0;
	virtual void pushToLua(lua_State* L) const = 0;
	virtual bool isNumeric() const = 0;
	virtual float toFloat() const = 0;
	virtual bool equals(Value* other) const = 0;
	template <class T>
	static Own<Value> alloc(const T& value);
	static const Own<Value> None;
protected:
	Value() { }
	DORA_TYPE_BASE(Value);
};

template <class T>
class ValueEx<T,
	typename std::enable_if<
		!std::is_pointer_v<T> &&
		!std::is_same_v<Slice,T>
	>::type> : public Value
{
public:
	inline void set(const T& value)
	{
		_value = value;
	}
	inline T& get()
	{
		return _value;
	}
	virtual Own<Value> clone() const override
	{
		return Value::alloc(_value);
	}
	virtual void pushToLua(lua_State* L) const override
	{
		LuaEngine::push(L, _value);
	}
	virtual bool isNumeric() const override
	{
		return std::is_arithmetic_v<T>;
	}
	virtual float toFloat() const override
	{
		if constexpr (std::is_arithmetic_v<T>)
		{
			return s_cast<float>(_value);
		}
		else
		{
			return 0.0f;
		}
	}
	virtual bool equals(Value* other) const override
	{
		if (auto value = DoraAs<ValueEx<T>>(other))
		{
			return _value == value->get();
		}
		return false;
	}
protected:
	ValueEx(const T& value):
	_value(value)
	{ }
private:
	T _value;
	friend class Value;
	USE_MEMORY_POOL(ValueEx<T>);
	DORA_TYPE_OVERRIDE(ValueEx<T>);
};

template<class T>
MemoryPoolImpl<ValueEx<T>> ValueEx<T,
	typename std::enable_if<
		!std::is_pointer_v<T> &&
		!std::is_same_v<Slice,T>
	>::type>::_memory;

class ValueObject : public Value
{
public:
	virtual ~ValueObject() { }
	inline void set(Object* value)
	{
		_value = value;
	}
	inline Object* get() const
	{
		return _value.get();
	}
	virtual Own<Value> clone() const override;
	virtual void pushToLua(lua_State* L) const override;
	virtual bool isNumeric() const override;
	virtual float toFloat() const override;
	virtual bool equals(Value* other) const override;
protected:
	ValueObject(Object* value):
	_value(value)
	{ }
private:
	Ref<> _value;
	friend class Value;
	USE_MEMORY_POOL(ValueObject);
	DORA_TYPE_OVERRIDE(ValueObject);
};

template <class T>
T& Value::to()
{
	if constexpr (std::is_base_of_v<Object,T>)
	{
		auto item = DoraAs<ValueObject>(this);
		AssertUnless(item, "can not convert value to Object.");
		return DoraTo<T>(item->get());
	}
	else
	{
		auto item = DoraAs<ValueEx<T>>(this);
		AssertUnless(item, "can not convert value to target type.");
		return item->get();
	}
}

template <class T>
T* Value::as()
{
	if constexpr (std::is_base_of_v<Object,T>)
	{
		if (auto item = DoraAs<ValueObject>(this))
		{
			return DoraAs<T>(item->get());
		}
	}
	else
	{
		if (auto item = DoraAs<ValueEx<T>>(this))
		{
			return &item->get();
		}
	}
	return nullptr;
}

template <class T>
Own<Value> Value::alloc(const T& value)
{
	if constexpr (std::is_base_of_v<Object, std::remove_pointer_t<special_decay_t<T>>>)
	{
		return Own<Value>(new ValueObject(value));
	}
	else
	{
		return Own<Value>(new ValueEx<special_decay_t<T>>(value));
	}
}

class Values
{
public:
	virtual ~Values() { }
	template<class... Args>
	static Own<Values> create(Args&&... args);
	template<class... Args>
	void get(Args&... args);
	DORA_TYPE_BASE(Values);
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
Own<Values> Values::create(Args&&... args)
{
	return std::make_unique<ValuesEx<special_decay_t<Args>...>>(std::forward<Args>(args)...);
}

template<class... Args>
void Values::get(Args&... args)
{
	auto values = DoraAs<ValuesEx<special_decay_t<Args>...>>(this);
	AssertIf(values == nullptr, "no required value type can be retrieved.");
	std::tie(args...) = std::move(values->values);
}

NS_DOROTHY_END

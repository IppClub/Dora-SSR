/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Lua/LuaEngine.h"
#include "Support/Geometry.h"

NS_DORA_BEGIN

template <class T>
struct unwrap_refwrapper {
	using type = T;
};

template <class T>
struct unwrap_refwrapper<std::reference_wrapper<T>> {
	using type = T&;
};

template <class T>
using special_decay_t = typename unwrap_refwrapper<typename std::decay<T>::type>::type;

enum class ValueType {
	Integral,
	FloatingPoint,
	Boolean,
	Object,
	Struct
};

class Value {
public:
	virtual ~Value() { }
	template <class T>
	T toVal();
	template <class T>
	T* to();
	template <class T>
	std::optional<T> asVal();
	template <class T>
	T* as();
	template <class T>
	void set(const T& value);
	template <class T>
	T get() const;
	virtual Own<Value> clone() const = 0;
	virtual void pushToLua(lua_State* L) const = 0;
	virtual ValueType getType() const = 0;
	virtual bool equals(Value* other) const = 0;
	template <class T>
	static Own<Value> alloc(const T& value);
	static const Own<Value> None;

protected:
	Value() { }
	DORA_TYPE_BASE(Value);
};

class ValueInt : public Value {
public:
	virtual ~ValueInt() { }
	inline void set(int64_t value) { _value = value; }
	inline int64_t get() const { return _value; }
	virtual Own<Value> clone() const override;
	virtual void pushToLua(lua_State* L) const override;
	virtual ValueType getType() const override;
	virtual bool equals(Value* other) const override;

protected:
	ValueInt(int64_t value)
		: _value(value) { }

private:
	int64_t _value;
	friend class Value;
	USE_MEMORY_POOL(ValueInt);
	DORA_TYPE_OVERRIDE(ValueInt);
};

class ValueFloat : public Value {
public:
	virtual ~ValueFloat() { }
	inline void set(double value) { _value = value; }
	inline double get() const { return _value; }
	virtual Own<Value> clone() const override;
	virtual void pushToLua(lua_State* L) const override;
	virtual ValueType getType() const override;
	virtual bool equals(Value* other) const override;

protected:
	ValueFloat(double value)
		: _value(value) { }

private:
	double _value;
	friend class Value;
	USE_MEMORY_POOL(ValueFloat);
	DORA_TYPE_OVERRIDE(ValueFloat);
};

class ValueBool : public Value {
public:
	virtual ~ValueBool() { }
	inline void set(bool value) { _value = value; }
	inline bool get() const { return _value; }
	virtual Own<Value> clone() const override;
	virtual void pushToLua(lua_State* L) const override;
	virtual ValueType getType() const override;
	virtual bool equals(Value* other) const override;

protected:
	ValueBool(bool value)
		: _value(value) { }

private:
	bool _value;
	friend class Value;
	USE_MEMORY_POOL(ValueBool);
	DORA_TYPE_OVERRIDE(ValueBool);
};

class ValueObject : public Value {
public:
	virtual ~ValueObject() { }
	inline void set(Object* value) { _value = value; }
	inline Object* get() const { return _value.get(); }
	virtual Own<Value> clone() const override;
	virtual void pushToLua(lua_State* L) const override;
	virtual ValueType getType() const override;
	virtual bool equals(Value* other) const override;

protected:
	ValueObject(Object* value)
		: _value(value) { }

private:
	Ref<> _value;
	friend class Value;
	USE_MEMORY_POOL(ValueObject);
	DORA_TYPE_OVERRIDE(ValueObject);
};

template <class T, class Enable = void>
class ValueStruct;

template <class T>
class ValueStruct<T,
	typename std::enable_if<
		!std::is_pointer_v<T> && std::is_class_v<T>>::type> : public Value {
public:
	virtual ~ValueStruct() { }
	inline void set(const T& value) {
		_value = value;
	}
	inline T& get() {
		return _value;
	}
	virtual Own<Value> clone() const override {
		return Value::alloc(_value);
	}
	virtual void pushToLua(lua_State* L) const override {
		LuaEngine::push(L, _value);
	}
	virtual ValueType getType() const override {
		return ValueType::Struct;
	}
	virtual bool equals(Value* other) const override {
		if (auto value = DoraAs<ValueStruct<T>>(other)) {
			return _value == value->get();
		}
		return false;
	}

protected:
	ValueStruct(const T& value)
		: _value(value) { }

private:
	T _value;
	friend class Value;
	USE_MEMORY_POOL(ValueStruct<T>);
	DORA_TYPE_OVERRIDE(ValueStruct<T>);
};

template <class T>
MemoryPoolImpl<ValueStruct<T>> ValueStruct<T,
	typename std::enable_if<
		!std::is_pointer_v<T> && std::is_class_v<T>>::type>::_memory;

template <class T>
T Value::toVal() {
	if constexpr (std::is_same_v<bool, T>) {
		auto item = DoraAs<ValueBool>(this);
		AssertUnless(item, "can not convert value to Boolean.");
		return item->get();
	} else if constexpr (std::is_integral_v<T>) {
		auto item = DoraAs<ValueInt>(this);
		AssertUnless(item, "can not convert value to Integral.");
		return s_cast<T>(item->get());
	} else if constexpr (std::is_floating_point_v<T>) {
		if (auto item = DoraAs<ValueFloat>(this)) {
			return s_cast<T>(item->get());
		}
		auto item = DoraAs<ValueInt>(this);
		AssertUnless(item, "can not convert value to FloatingPoint.");
		return s_cast<T>(item->get());
	} else if constexpr (!std::is_pointer_v<T> && std::is_class_v<T> && !std::is_base_of_v<Object, T>) {
		auto item = DoraAs<ValueStruct<T>>(this);
		AssertUnless(item, "can not convert value to Struct type.");
		return item->get();
	}
}

template <class T>
T* Value::to() {
	if constexpr (std::is_base_of_v<Object, T>) {
		auto item = DoraAs<ValueObject>(this);
		AssertUnless(item, "can not convert value to Object.");
		return DoraTo<T>(item->get());
	}
}

template <class T>
std::optional<T> Value::asVal() {
	if constexpr (std::is_same_v<bool, T>) {
		if (auto item = DoraAs<ValueBool>(this)) {
			return item->get();
		}
		return std::nullopt;
	} else if constexpr (std::is_integral_v<T>) {
		if (auto item = DoraAs<ValueInt>(this)) {
			return s_cast<T>(item->get());
		}
		return std::nullopt;
	} else if constexpr (std::is_floating_point_v<T>) {
		if (auto item = DoraAs<ValueFloat>(this)) {
			return s_cast<T>(item->get());
		} else if (auto item = DoraAs<ValueInt>(this)) {
			return s_cast<T>(item->get());
		}
		return std::nullopt;
	} else if constexpr (!std::is_pointer_v<T> && std::is_class_v<T> && !std::is_base_of_v<Object, T>) {
		if (auto item = DoraAs<ValueStruct<T>>(this)) {
			return item->get();
		}
		return std::nullopt;
	}
}

template <class T>
T* Value::as() {
	if constexpr (std::is_base_of_v<Object, T>) {
		if (auto item = DoraAs<ValueObject>(this)) {
			return DoraAs<T>(item->get());
		}
		return nullptr;
	}
}

template <class T>
void Value::set(const T& value) {
	if constexpr (std::is_same_v<bool, T>) {
		if (auto item = DoraAs<ValueBool>(this)) {
			item->set(value);
		} else {
			Issue("failed to set value expecting boolean.");
		}
	} else if constexpr (std::is_integral_v<T>) {
		if (auto item = DoraAs<ValueInt>(this)) {
			item->set(s_cast<int64_t>(value));
		} else if (auto item = DoraAs<ValueFloat>(this)) {
			item->set(s_cast<double>(value));
		} else {
			Issue("failed to set value expecting integral.");
		}
	} else if constexpr (std::is_floating_point_v<T>) {
		if (auto item = DoraAs<ValueFloat>(this)) {
			item->set(s_cast<double>(value));
		} else {
			Issue("failed to set value expecting floating point.");
		}
	} else if constexpr (!std::is_pointer_v<T> && std::is_class_v<T> && !std::is_base_of_v<Object, T>) {
		if (auto item = DoraAs<ValueStruct<T>>(this)) {
			item->set(value);
		} else {
			Issue("failed to set value expecting struct.");
		}
	} else if constexpr (std::is_base_of_v<Object, std::remove_pointer_t<special_decay_t<T>>>) {
		if (auto item = DoraAs<ValueObject>(this)) {
			item->set(value);
		} else {
			Issue("failed to set value expecting object.");
		}
	}
}

template <class T>
T Value::get() const {
	if constexpr (std::is_same_v<bool, T>) {
		if (auto item = DoraAs<ValueBool>(this)) {
			return item->get();
		}
	} else if constexpr (std::is_integral_v<T>) {
		if (auto item = DoraAs<ValueInt>(this)) {
			return s_cast<T>(item->get());
		}
	} else if constexpr (std::is_floating_point_v<T>) {
		if (auto item = DoraAs<ValueFloat>(this)) {
			return s_cast<T>(item->get());
		} else if (auto item = DoraAs<ValueInt>(this)) {
			return s_cast<T>(item->get());
		}
	} else if constexpr (!std::is_pointer_v<T> && std::is_class_v<T> && !std::is_base_of_v<Object, T>) {
		if (auto item = DoraAs<ValueStruct<T>>(this)) {
			return item->get();
		}
	} else if constexpr (std::is_base_of_v<Object, std::remove_pointer_t<special_decay_t<T>>>) {
		if (auto item = DoraAs<ValueObject>(this)) {
			return item->get();
		}
	}
}

template <class T>
Own<Value> Value::alloc(const T& value) {
	if constexpr (std::is_same_v<bool, T>) {
		return Own<Value>(new ValueBool(value));
	} else if constexpr (std::is_integral_v<T>) {
		return Own<Value>(new ValueInt(s_cast<int64_t>(value)));
	} else if constexpr (std::is_floating_point_v<T>) {
		return Own<Value>(new ValueFloat(s_cast<double>(value)));
	} else if constexpr (std::is_base_of_v<Object, std::remove_pointer_t<special_decay_t<T>>>) {
		return Own<Value>(new ValueObject(value));
	} else if constexpr (!std::is_pointer_v<T> && std::is_class_v<T>) {
		return Own<Value>(new ValueStruct<special_decay_t<T>>(value));
	}
}

class Values {
public:
	virtual ~Values() { }
	template <class... Args>
	static Own<Values> alloc(Args&&... args);
	template <class... Args>
	void get(Args&... args);
	DORA_TYPE_BASE(Values);

protected:
	Values() { }
};

template <class... Fields>
class ValuesEx : public Values {
public:
	template <class... Args>
	ValuesEx(Args&&... args)
		: values{std::move(std::forward<Args>(args))...} { }
	std::tuple<Fields...> values;
	DORA_TYPE_OVERRIDE(ValuesEx<Fields...>);
};

template <class... Args>
Own<Values> Values::alloc(Args&&... args) {
	return std::make_unique<ValuesEx<special_decay_t<Args>...>>(std::forward<Args>(args)...);
}

template <class... Args>
void Values::get(Args&... args) {
	auto values = DoraAs<ValuesEx<special_decay_t<Args>...>>(this);
	AssertIf(values == nullptr, "no required value type can be retrieved.");
	std::tie(args...) = std::move(values->values);
}

NS_DORA_END

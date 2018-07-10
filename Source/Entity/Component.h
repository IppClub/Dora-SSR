#pragma once
#include "Basic/Object.h"
#include "Support/Value.h"

NS_DOROTHY_BEGIN

template <class T, class Enable = void>
class ComEx;

class Com
{
public:
	virtual ~Com() { }
	template <class T>
	const T& to();
	template <class T>
	ComEx<T>* as();
	virtual Own<Com> clone() const = 0;
	virtual void pushToLua() const = 0;
	template <class T>
	static Own<Com> create(const T& value);
protected:
	Com() { }
	DORA_TYPE_BASE(Com);
};

template <class T>
class ComEx<T, typename std::enable_if<!std::is_base_of<Object, T>::value>::type> : public Com
{
public:
	ComEx(const T& value):
	_value(value)
	{ }
	inline void set(const T& value)
	{
		_value = value;
	}
	inline const T& get()
	{
		return _value;
	}
	virtual Own<Com> clone() const override
	{
		return Com::create(_value);
	}
	virtual void pushToLua() const override
	{
		SharedLueEngine.push(_value);
	}
private:
	T _value;
	USE_MEMORY_POOL(ComEx<T>);
	DORA_TYPE_OVERRIDE(ComEx<T>);
};

template<class T>
MemoryPool<ComEx<T>> ComEx<T, typename std::enable_if<!std::is_base_of<Object, T>::value>::type>::_memory;

template<>
class ComEx<Object*> : public Com
{
public:
	ComEx(Object* value):
	_value(value)
	{ }
	virtual ~ComEx() { }
	inline void set(Object* value)
	{
		_value = value;
	}
	inline Object* get()
	{
		return _value.get();
	}
	virtual Own<Com> clone() const override
	{
		return Com::create(_value.get());
	}
	virtual void pushToLua() const override
	{
		SharedLueEngine.push(_value.get());
	}
private:
	Ref<> _value;
	USE_MEMORY_POOL(ComEx<Object*>);
	DORA_TYPE_OVERRIDE(ComEx<Object*>);
};

template <class T>
const T& Com::to()
{
	auto item = DoraCast<ComEx<T>>(this);
	AssertUnless(item, "can not get value of target type from value object.");
	return item->get();
}

template <class T>
ComEx<T>* Com::as()
{
	return DoraCast<ComEx<T>>(this);
}

template <class T>
Own<Com> Com::create(const T& value)
{
	return Own<Com>(new ComEx<T>(value));
}

NS_DOROTHY_END

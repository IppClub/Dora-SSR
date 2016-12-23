/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_COMMON_WREF_H__
#define __DOROTHY_COMMON_WREF_H__

NS_DOROTHY_BEGIN

/** @brief Used for weak reference. */
template<class T = Object>
class WRef
{
public:
	WRef(): _weak(nullptr)
	{ }
	explicit WRef(T* item): _weak(nullptr)
	{
		if (item)
		{
			_weak = item->getWeakRef();
			_weak->retain();
		}
	}
	WRef(const Ref<T>& ref): _weak(nullptr)
	{
		if (ref)
		{
			_weak = ref->getWeakRef();
			_weak->retain();
		}
	}
	WRef(const WRef& ref): _weak(ref._weak)
	{
		if (_weak)
		{
			_weak->retain();
		}
	}
	WRef(WRef&& ref): _weak(ref._weak)
	{
		ref._weak = nullptr;
	}
	~WRef()
	{
		if (_weak)
		{
			_weak->release();
		}
	}
	inline T* operator->() const
	{
		return get();
	}
	T* operator=(T* item)
	{
		Weak* weak = nullptr;
		if (item)
		{
			weak = item->getWeakRef();
			weak->retain();
		}
		if (_weak)
		{
			_weak->release();
		}
		_weak = weak;
		return item;
	}
	const WRef& operator=(const Ref<T>& ref)
	{
		operator=(ref.get());
		return *this;
	}
	const WRef& operator=(const WRef& ref)
	{
		operator=(ref.get());
		return *this;
	}
	const WRef& operator=(WRef&& ref)
	{
		if (this == &ref)
		{
			return *this;
		}
		if (_weak)
		{
			_weak->release();
		}
		_weak = ref._weak;
		ref._weak = nullptr;
		return *this;
	}
	bool operator==(const WRef& ref) const
	{
		return get() == ref.get();
	}
	bool operator!=(const WRef& ref) const
	{
		return get() != ref.get();
	}
	bool operator==(const Ref<T>& ref) const
	{
		return get() == ref;
	}
	bool operator!=(const Ref<T>& ref) const
	{
		return get() != ref;
	}
	inline operator T*() const
	{
		return get();
	}
	inline T* get() const
	{
		if (_weak) return s_cast<T*>(_weak->target);
		else return nullptr;
	}
private:
	Weak* _weak;
};

template <class name>
inline WRef<name> WRefMake(name* item)
{
	return WRef<name>(item);
}

NS_DOROTHY_END

#endif // __DOROTHY_COMMON_WREF_H__

/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_COMMON_OWREF_H__
#define __DOROTHY_COMMON_OWREF_H__

NS_DOROTHY_BEGIN

/** @brief Used for weak reference. */
template<class T = oObject>
class oWRef
{
public:
	oWRef(): _weak(nullptr)
	{ }
	explicit oWRef(T* item): _weak(nullptr)
	{
		if (item)
		{
			_weak = item->getWeakRef();
			_weak->retain();
		}
	}
	oWRef(const oRef<T>& ref): _weak(nullptr)
	{
		if (ref)
		{
			_weak = ref->getWeakRef();
			_weak->retain();
		}
	}
	oWRef(const oWRef& ref): _weak(ref._weak)
	{
		if (_weak)
		{
			_weak->retain();
		}
	}
	oWRef(oWRef&& ref): _weak(ref._weak)
	{
		ref._weak = nullptr;
	}
	~oWRef()
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
		oWeak* weak = nullptr;
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
	const oWRef& operator=(const oRef<T>& ref)
	{
		operator=(ref.get());
		return *this;
	}
	const oWRef& operator=(const oWRef& ref)
	{
		operator=(ref.get());
		return *this;
	}
	const oWRef& operator=(oWRef&& ref)
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
	bool operator==(const oWRef& ref) const
	{
		return get() == ref.get();
	}
	bool operator!=(const oWRef& ref) const
	{
		return get() != ref.get();
	}
	bool operator==(const oRef<T>& ref) const
	{
		return get() == ref;
	}
	bool operator!=(const oRef<T>& ref) const
	{
		return get() != ref;
	}
	inline operator T*() const
	{
		return get();
	}
	inline T* get() const
	{
		if (_weak) return (T*)_weak->target;
		else return nullptr;
	}
private:
	oWeak* _weak;
};

template <class name>
inline oWRef<name> oWRefMake(name* item)
{
	return oWRef<name>(item);
}

NS_DOROTHY_END

#endif // __DOROTHY_COMMON_OWREF_H__

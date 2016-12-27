/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

/** @brief Used with Aggregation Relationship. 
 @param T Object
*/
template<class T>
class Ref
{
public:
	Ref():_item(nullptr)
	{ }
	explicit Ref(T* item):_item(item)
	{
		if (item)
		{
			item->retain();
		}
	}
	Ref(const Ref& ref)
	{
		if (ref._item)
		{
			ref._item->retain();
		}
		_item = ref._item;
	}
	Ref(Ref&& ref)
	{
		_item = ref._item;
		ref._item = nullptr;
	}
	~Ref()
	{
		if (_item)
		{
			_item->release();
			_item = nullptr;
		}
	}
	inline T* operator->() const
	{
		return _item;
	}
	T* operator=(T* item)
	{
		/* ensure that assign same item is Ok
		 so first retain new item then release old item
		*/
		if (item)
		{
			item->retain();
		}
		if (_item)
		{
			_item->release();
		}
		_item = item;
		return item;
	}
	const Ref& operator=(const Ref& ref)
	{
		if (this == &ref) // handle self assign
		{
			return *this;
		}
		if (ref._item)
		{
			ref._item->retain();
		}
		if (_item)
		{
			_item->release();
		}
		_item = ref._item;
		return *this;
	}
	const Ref& operator=(Ref&& ref)
	{
		if (this == &ref) // handle self assign
		{
			return *this;
		}
		if (_item)
		{
			_item->release();
		}
		_item = ref._item;
		ref._item = nullptr;
		return *this;
	}
	bool operator==(const Ref& ref) const
	{
		return _item == ref._item;
	}
	bool operator!=(const Ref& ref) const
	{
		return _item != ref._item;
	}
	inline operator T*() const
	{
		return _item;
	}
	inline T* get() const
	{
		return _item;
	}
private:
	T* _item;
};

template <class name>
inline Ref<name> RefMake(name* item)
{
	return Ref<name>(item);
}

NS_DOROTHY_END

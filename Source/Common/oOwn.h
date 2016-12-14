/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_COMMON_OWN_H__
#define __DOROTHY_COMMON_OWN_H__

NS_DOROTHY_BEGIN

/** @brief Used with Composition Relationship. */
template<class Item, class Del = std::default_delete<Item>>
class oOwn: public std::unique_ptr<Item, Del>
{
public:
	oOwn(){}
	oOwn(oOwn&& own):std::unique_ptr<Item>(std::move(own)){}
	explicit oOwn(Item* item):std::unique_ptr<Item>(item){}
	inline operator Item*() const
	{
		return std::unique_ptr<Item, Del>::get();
	}
	inline oOwn& operator=(std::nullptr_t)
	{
		std::unique_ptr<Item, Del>::reset();
		return (*this);
	}
	inline const oOwn& operator=(oOwn&& own)
	{
		std::unique_ptr<Item, Del>::operator=(std::move(own));
		return *this;
	}
private:
	oOwn(const oOwn& own);
	const oOwn& operator=(const oOwn& own);
};

template<class Item>
class oOwnArray: public std::unique_ptr<Item, std::default_delete<Item[]>>
{
	typedef std::unique_ptr<Item, std::default_delete<Item[]>> oUPtr;
public:
	oOwnArray(){}
	oOwnArray(oOwnArray&& own):oUPtr(std::move(own)){}
	explicit oOwnArray(Item* item):oUPtr(item){}
	inline operator Item*() const
	{
		return std::unique_ptr<Item, std::default_delete<Item[]>>::get();
	}
	inline const oOwnArray& operator=(oOwnArray&& own)
	{
		oUPtr::operator=(std::move(own));
		return *this;
	}
private:
	oOwnArray(const oOwnArray& own);
	const oOwnArray& operator=(const oOwnArray& own);
};

/** Useless */
template<class T>
inline oOwn<T> oOwnMake(T* item)
{
	return oOwn<T>(item);
}

template<class T, class... Args>
inline oOwn<T> oOwnNew(Args&&... args)
{
	return oOwn<T>(new T(std::forward<Args>(args)...));
}

template<class T>
inline oOwnArray<T> oOwnArrayMake(T* item)
{
	return oOwnArray<T>(item);
}

NS_DOROTHY_END

#endif // __DOROTHY_COMMON_OWN_H__

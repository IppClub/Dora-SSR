/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_COMMON_OWN_H__
#define __DOROTHY_COMMON_OWN_H__

NS_DOROTHY_BEGIN

/** @brief Used with Composition Relationship. */
template<class Item, class Del = std::default_delete<Item>>
class Own: public std::unique_ptr<Item, Del>
{
public:
	Own(){}
	Own(Own&& own):std::unique_ptr<Item>(std::move(own)){}
	explicit Own(Item* item):std::unique_ptr<Item>(item){}
	inline operator Item*() const
	{
		return std::unique_ptr<Item, Del>::get();
	}
	inline Own& operator=(std::nullptr_t)
	{
		std::unique_ptr<Item, Del>::reset();
		return (*this);
	}
	inline const Own& operator=(Own&& own)
	{
		std::unique_ptr<Item, Del>::operator=(std::move(own));
		return *this;
	}
private:
	Own(const Own& own);
	const Own& operator=(const Own& own);
};

template<class Item>
class OwnArray : public std::unique_ptr<Item, std::default_delete<Item[]>>
{
	typedef std::unique_ptr<Item, std::default_delete<Item[]>> UPtr;
public:
	OwnArray(){}
	OwnArray(OwnArray&& own):UPtr(std::move(own)){}
	explicit OwnArray(Item* item):UPtr(item){}
	inline operator Item*() const
	{
		return std::unique_ptr<Item, std::default_delete<Item[]>>::get();
	}
	inline const OwnArray& operator=(OwnArray&& own)
	{
		UPtr::operator=(std::move(own));
		return *this;
	}
private:
	OwnArray(const OwnArray& own);
	const OwnArray& operator=(const OwnArray& own);
};

/** Useless */
template<class T>
inline Own<T> OwnMake(T* item)
{
	return Own<T>(item);
}

template<class T, class... Args>
inline Own<T> OwnNew(Args&&... args)
{
	return Own<T>(new T(std::forward<Args>(args)...));
}

template<class T>
inline OwnArray<T> OwnArrayMake(T* item)
{
	return OwnArray<T>(item);
}

NS_DOROTHY_END

#endif // __DOROTHY_COMMON_OWN_H__

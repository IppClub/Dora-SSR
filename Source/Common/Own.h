/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

/** @brief Used with Composition Relationship. */
template<class Item, class Del = std::default_delete<Item>>
class Own : public std::unique_ptr<Item, Del>
{
public:
	Own() { }
	Own(Own&& own):std::unique_ptr<Item>(std::move(own)) { }
	explicit Own(Item* item):std::unique_ptr<Item>(item) { }
	inline operator Item*() const
	{
		return std::unique_ptr<Item, Del>::get();
	}
	inline Own& operator=(std::nullptr_t)
	{
		std::unique_ptr<Item, Del>::reset();
		return (*this);
	}
	inline const Own& operator=(Own&& own) noexcept
	{
		std::unique_ptr<Item, Del>::operator=(std::move(own));
		return *this;
	}
private:
	Own(const Own& own) = delete;
	const Own& operator=(const Own& own) = delete;
};

template<class Item>
class OwnArray : public std::unique_ptr<Item, std::default_delete<Item[]>>
{
	typedef std::unique_ptr<Item, std::default_delete<Item[]>> UPtr;
public:
	OwnArray():_size(0){}
	OwnArray(OwnArray&& own) noexcept:UPtr(std::move(own)),_size(own._size) { }
	OwnArray(Item* item, size_t size):UPtr(item), _size(size) { }
	inline operator Item*() const
	{
		return UPtr::get();
	}
	inline const OwnArray& operator=(OwnArray&& own)
	{
		UPtr::operator=(std::move(own));
		_size = own._size;
		return *this;
	}
	size_t size() const { return _size; }
private:
	size_t _size;
	OwnArray(const OwnArray& own) = delete;
	const OwnArray& operator=(const OwnArray& own) = delete;
};

/** Useless */
template<class T>
inline Own<T> MakeOwn(T* item)
{
	return Own<T>(item);
}

template<class T, class... Args>
inline Own<T> New(Args&&... args)
{
	return Own<T>(new T(std::forward<Args>(args)...));
}

template<class T>
inline OwnArray<T> NewArray(size_t size)
{
	return OwnArray<T>(new T[size], size);
}

template<class T>
inline OwnArray<T> MakeOwnArray(T* item, size_t size)
{
	return OwnArray<T>(item, size);
}

/** @brief vector of pointers, but accessed as values
 pointers pushed into OwnVector are owned by the vector,
 pointers will be auto deleted when it`s erased/removed from the vector
 or the vector is destroyed.
 Used with Composition Relationship.
*/
template<class T>
class OwnVector : public vector<Own<T>>
{
	typedef vector<Own<T>> OwnV;
public:
	using OwnV::OwnV;
	using OwnV::insert;

	bool remove(T* item)
	{
		auto it = std::remove(OwnV::begin(), OwnV::end(), item);
		if (it == OwnV::end()) return false;
		OwnV::erase(it);
		return true;
	}
	typename OwnV::iterator index(T* item)
	{
		return std::find(OwnV::begin(), OwnV::end(), item);
	}
	bool fast_remove(T* item)
	{
		size_t index = std::distance(OwnV::begin(), OwnVector::index(item));
		if (index < OwnV::size())
		{
			OwnV::at(index) = OwnV::back();
			OwnV::pop_back();
			return true;
		}
		return false;
	}
};

NS_DOROTHY_END

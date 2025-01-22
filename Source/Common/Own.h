/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

/** @brief Used with Composition Relationship. */
template <class Item, class Del = std::default_delete<Item>>
using Own = std::unique_ptr<Item, Del>;

template <class Item>
using OwnArray = std::unique_ptr<Item, std::default_delete<Item[]>>;

/** Useless */
template <class T>
inline Own<T> MakeOwn(T* item) {
	return Own<T>(item);
}

template <class T, class... Args>
inline Own<T> New(Args&&... args) {
	return Own<T>(new T(std::forward<Args>(args)...));
}

template <class T, class Del, class... Args>
inline Own<T, Del> New(Args&&... args) {
	return Own<T, Del>(new T(std::forward<Args>(args)...));
}

template <class T>
inline OwnArray<T> NewArray(size_t size) {
	return OwnArray<T>(new T[size]);
}

template <class T>
inline OwnArray<T> MakeOwnArray(T* item) {
	return OwnArray<T>(item);
}

/** @brief vector of pointers, but accessed as values
 pointers pushed into OwnVector are owned by the vector,
 pointers will be auto deleted when it`s erased/removed from the vector
 or the vector is destroyed.
 Used with Composition Relationship.
*/
template <class T>
class OwnVector : public std::vector<Own<T>> {
	typedef std::vector<Own<T>> OwnV;

public:
	using OwnV::insert;
	using OwnV::OwnV;

	bool remove(const Own<T>& item) {
		auto it = std::remove(OwnV::begin(), OwnV::end(), item);
		if (it == OwnV::end()) return false;
		OwnV::erase(it);
		return true;
	}
	typename OwnV::iterator index(const Own<T>& item) {
		return std::find(OwnV::begin(), OwnV::end(), item);
	}
	bool fast_remove(const Own<T>& item) {
		size_t index = std::distance(OwnV::begin(), OwnVector::index(item));
		if (index < OwnV::size()) {
			OwnV::at(index) = std::move(OwnV::back());
			OwnV::pop_back();
			return true;
		}
		return false;
	}
};

NS_DORA_END

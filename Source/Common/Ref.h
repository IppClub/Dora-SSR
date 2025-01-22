/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

template <class T = Object>
class Ref {
public:
	Ref()
		: _item(nullptr) { }
	explicit Ref(T* item)
		: _item(item) {
		if (item) {
			item->retain();
		}
	}
	Ref(const Ref& ref) {
		if (ref._item) {
			ref._item->retain();
		}
		_item = ref._item;
	}
	Ref(Ref&& ref) noexcept {
		_item = ref._item;
		ref._item = nullptr;
	}
	~Ref() {
		if (_item) {
			_item->release();
			_item = nullptr;
		}
	}
	inline T* operator->() const {
		return s_cast<T*>(_item);
	}
	T* operator=(T* item) {
		/* ensure that assign same item is Ok
		 so first retain new item then release old item
		*/
		if (item) {
			item->retain();
		}
		if (_item) {
			_item->release();
		}
		_item = item;
		return item;
	}
	const Ref& operator=(const Ref& ref) {
		// handle self assign
		if (this == &ref) {
			return *this;
		}
		if (ref._item) {
			ref._item->retain();
		}
		if (_item) {
			_item->release();
		}
		_item = ref._item;
		return *this;
	}
	const Ref& operator=(Ref&& ref) noexcept {
		// handle self assign
		if (this == &ref) {
			return *this;
		}
		if (_item) {
			_item->release();
		}
		_item = ref._item;
		ref._item = nullptr;
		return *this;
	}
	bool operator==(const Ref& ref) const {
		return _item == ref._item;
	}
	bool operator!=(const Ref& ref) const {
		return _item != ref._item;
	}
	inline operator T*() const {
		return r_cast<T*>(_item);
	}
	inline T* get() const {
		return r_cast<T*>(_item);
	}
	template <class Type>
	inline Type* as() const {
		return DoraAs<Type>(_item);
	}
	template <class Type>
	inline Type& to() const {
		return DoraTo<Type>(_item);
	}
	template <class Type>
	inline bool is() const {
		return DoraIs<Type>(_item);
	}

private:
	Object* _item;
};

template <class T>
inline Ref<T> MakeRef(T* item) {
	return Ref<T>(item);
}

template <class T, class... Args>
inline Ref<T> NewRef(Args&&... args) {
	return Ref<T>(T::create(std::forward<Args>(args)...));
}

template <class T = Object>
class RefVector : public std::vector<Ref<T>> {
	typedef std::vector<Ref<T>> RefV;

public:
	using RefV::insert;
	using RefV::RefV;

	inline void push_back(T* item) {
		RefV::push_back(MakeRef(item));
	}
	typename RefV::iterator insert(size_t where, T* item) {
		return RefV::insert(RefV::begin() + where, MakeRef(item));
	}
	bool remove(T* item) {
		auto it = std::remove(RefV::begin(), RefV::end(), MakeRef(item));
		if (it == RefV::end()) return false;
		RefV::erase(it);
		return true;
	}
	bool remove(size_t index) {
		if (index < RefV::size()) {
			RefV::erase(RefV::begin() + index);
			return true;
		}
		return false;
	}
	typename RefV::iterator index(T* item) {
		return std::find(RefV::begin(), RefV::end(), MakeRef(item));
	}
	bool fast_remove(T* item) {
		size_t index = std::distance(RefV::begin(), RefVector::index(item));
		if (index < RefV::size()) {
			RefV::at(index) = RefV::back();
			RefV::pop_back();
			return true;
		}
		return false;
	}
};

NS_DORA_END

/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

/** @brief Used for weak reference.
 @param T Object
*/
template <class T = Object>
class WRef {
public:
	WRef()
		: _weak(nullptr) { }
	explicit WRef(T* item)
		: _weak(nullptr) {
		if (item) {
			_weak = item->getWeakRef();
			_weak->retain();
		}
	}
	WRef(const Ref<T>& ref)
		: _weak(nullptr) {
		if (ref) {
			_weak = ref->getWeakRef();
			_weak->retain();
		}
	}
	WRef(const WRef& ref)
		: _weak(ref._weak) {
		if (_weak) {
			_weak->retain();
		}
	}
	WRef(WRef&& ref) noexcept
		: _weak(ref._weak) {
		ref._weak = nullptr;
	}
	~WRef() {
		if (_weak) {
			_weak->release();
		}
	}
	inline T* operator->() const {
		return get();
	}
	T* operator=(T* item) {
		Weak* weak = nullptr;
		if (item) {
			weak = item->getWeakRef();
			weak->retain();
		}
		if (_weak) {
			_weak->release();
		}
		_weak = weak;
		return item;
	}
	const WRef& operator=(const Ref<T>& ref) {
		operator=(ref.get());
		return *this;
	}
	const WRef& operator=(const WRef& ref) {
		operator=(ref.get());
		return *this;
	}
	const WRef& operator=(WRef&& ref) {
		if (this == &ref) {
			return *this;
		}
		if (_weak) {
			_weak->release();
		}
		_weak = ref._weak;
		ref._weak = nullptr;
		return *this;
	}
	bool operator==(const WRef& ref) const {
		return get() == ref.get();
	}
	bool operator!=(const WRef& ref) const {
		return get() != ref.get();
	}
	bool operator==(const Ref<T>& ref) const {
		return get() == ref.get();
	}
	bool operator!=(const Ref<T>& ref) const {
		return get() != ref.get();
	}
	inline operator T*() const {
		return get();
	}
	inline T* get() const {
		if (_weak)
			return s_cast<T*>(_weak->target);
		else
			return nullptr;
	}

private:
	Weak* _weak;
};

template <class T>
inline WRef<T> MakeWRef(T* item) {
	return WRef<T>(item);
}

/** @brief Used with Aggregation Relationship.
 @param T Object
*/
template <class T = Object>
class WRefVector : public std::vector<WRef<T>> {
	typedef std::vector<WRef<T>> WRefV;

public:
	using WRefV::insert;
	using WRefV::WRefV;

	inline void push_back(T* item) {
		WRefV::push_back(MakeWRef(item));
	}
	typename WRefV::iterator insert(size_t where, T* item) {
		return WRefV::insert(WRefV::begin() + where, MakeWRef(item));
	}
	bool remove(T* item) {
		auto it = std::remove(WRefV::begin(), WRefV::end(), MakeWRef(item));
		if (it == WRefV::end()) return false;
		WRefV::erase(it);
		return true;
	}
	typename WRefV::iterator index(T* item) {
		return std::find(WRefV::begin(), WRefV::end(), MakeWRef(item));
	}
	bool fast_remove(T* item) {
		size_t index = std::distance(WRefV::begin(), WRefVector::index(item));
		if (index < WRefV::size()) {
			WRefV::at(index) = WRefV::back();
			WRefV::pop_back();
			return true;
		}
		return false;
	}
};

NS_DORA_END

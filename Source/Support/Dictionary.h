/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Support/Value.h"

NS_DORA_BEGIN

class Dictionary : public Object {
public:
	PROPERTY_READONLY(int, Count);
	PROPERTY_READONLY(std::vector<Slice>, Keys);
	const StringMap<Own<Value>>& data() const;

	bool has(String key) const;
	const Own<Value>& get(String key) const;
	void set(String key, Own<Value>&& value);
	bool remove(String key);
	void clear();

	template <typename T>
	T get(String key, const T& def) const {
		const auto& val = get(key);
		if (!val) return def;
		using Type = std::remove_cv_t<std::remove_reference_t<std::remove_pointer_t<T>>>;
		if constexpr (std::is_base_of_v<Object, Type>) {
			return val->as<std::remove_pointer_t<special_decay_t<T>>>();
		} else {
			if (auto item = val->asVal<Type>()) {
				return *item;
			}
		}
		return def;
	}

	template <typename Func>
	bool each(const Func& func) {
		_traversing = true;
		DEFER(_traversing = false);
		for (const auto& item : _dict) {
			if (func(item.second.get(), item.first)) {
				return true;
			}
		}
		return false;
	}

	CREATE_FUNC_NOT_NULL(Dictionary);

private:
	bool _traversing = false;
	StringMap<Own<Value>> _dict;
	DORA_TYPE_OVERRIDE(Dictionary);
};

NS_DORA_END

/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Support/Value.h"

NS_DOROTHY_BEGIN

class Dictionary : public Object
{
public:
	PROPERTY_READONLY(int, Count);
	PROPERTY_READONLY(std::vector<Slice>, Keys);
	const std::unordered_map<std::string,Own<Value>>& data() const;

	bool has(String key) const;
	const Own<Value>& get(String key) const;
	void set(String key, Own<Value>&& value);
	bool remove(String key);
	void clear();

	float get(String key, float def) const;

	template <typename T>
	T get(String key, const T& def) const
	{
		const auto& val = get(key);
		if (!val) return def;
		using Type = std::remove_pointer_t<T>;
		if constexpr (std::is_base_of_v<Object, Type>)
		{
			if (auto item = DoraAs<ValueObject>(val.get()))
			{
				return d_cast<T>(item->get());
			}
		}
		else
		{
			if (auto item = val->as<Type>())
			{
				return *item;
			}
		}
		return def;
	}

	template <typename Func>
	bool each(const Func& func)
	{
		for (const auto& item : _dict)
		{
			if (func(item.second.get(), item.first))
			{
				return true;
			}
		}
		return false;
	}

	CREATE_FUNC(Dictionary);
private:
	std::unordered_map<std::string,Own<Value>> _dict;
	DORA_TYPE_OVERRIDE(Dictionary);
};

NS_DOROTHY_END

/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Support/Dictionary.h"
#include "lua.hpp"

NS_DOROTHY_BEGIN

int Dictionary::getCount() const
{
	return s_cast<int>(_dict.size());
}

vector<Slice> Dictionary::getKeys() const
{
	vector<Slice> keys;
	keys.reserve(_dict.size());
	for (const auto& item : _dict)
	{
		keys.push_back(item.first);
	}
	return keys;
}

const unordered_map<string,Own<Value>>& Dictionary::data() const
{
	return _dict;
}

bool Dictionary::has(String key) const
{
	return _dict.find(key) != _dict.end();
}

const Own<Value>& Dictionary::get(String key) const
{
	auto it = _dict.find(key);
	if (it != _dict.end())
	{
		return it->second;
	}
	return Value::None;
}

float Dictionary::get(String key, float def) const
{
	const auto& value = get(key);
	if (value && value->isNumeric())
	{
		return value->toFloat();
	}
	return def;
}

void Dictionary::set(String key, Own<Value>&& value)
{
	if (value)
	{
		_dict[key] = std::move(value);
	}
	else remove(key);
}

bool Dictionary::remove(String key)
{
	auto it = _dict.find(key);
	if (it != _dict.end())
	{
		_dict.erase(it);
		return true;
	}
	return false;
}

void Dictionary::clear()
{
	_dict.clear();
}

NS_DOROTHY_END

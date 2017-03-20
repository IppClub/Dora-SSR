/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"

NS_DOROTHY_BEGIN
/*
CCDictionary	9	n
	each	13	n
	count	11	n
	get	8	n
	set	7	n
	clear	4	n
	keys	3	n
*/

class Dictionary : public Object
{
public:
	PROPERTY_READONLY(int, Count);
	PROPERTY_READONLY(vector<Slice>, Keys);
	const unordered_map<string,Ref<Object>>& data() const;

	Ref<Object> get(String key) const;
	void set(String key, Object* value);
	void clear();

	template <typename Func>
	void each(const Func& func)
	{
		for (const auto& item : _dict)
		{
			if (func(item.second, item.first))
			{
				return;
			}
		}
	}

	CREATE_FUNC(Dictionary);
private:
	unordered_map<string,Ref<Object>> _dict;
	DORA_TYPE_OVERRIDE(Dictionary);
};

NS_DOROTHY_END

/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Content.h"
#include "Other/rapidxml_sax3.hpp"

NS_DOROTHY_BEGIN

/** @brief Useful for reading xml files and cache them in memory.
 T is the class to store every parsed xml file.
*/
template<class T>
class XmlItemCache : public rapidxml::xml_sax2_handler
{
	typedef unordered_map<string, Ref<T>> dict;
	typedef typename dict::iterator dict_iter;
public:
	virtual ~XmlItemCache() { }
	/** Load a new xml file or get its data for cache. */
	T* load(String filename)
	{
		_path = filename.getFilePath();
		dict_iter it = _dict.find(filename);
		if (it != _dict.end())
		{
			return it->second;
		}
		else
		{
			this->beforeParse(filename);
			auto data = SharedContent.loadFile(filename);
			if (data)
			{
				_parser.parse<>(r_cast<char*>(data.get()), s_cast<int>(data.size()));
				this->afterParse(filename);
				_dict[filename] = _item;
				T* item = _item;
				_item = nullptr;
				return item;
			}
			return nullptr;
		}
	}
	T* update(String name, String content)
	{
		_path = name.getFilePath();
		this->beforeParse(name);
		_parser.parse<>(content, content.size());
		this->afterParse(name);
		_dict[name] = _item;
		T* item = _item;
		_item = nullptr;
		return item;
	}
	T* update(String name, T* item)
	{
		_dict[name] = item;
		return item;
	}
	/** Purge the cached file. */
	bool unload(String filename)
	{
		dict_iter it = _dict.find(filename);
		if (it != _dict.end())
		{
			_dict.erase(it);
			return true;
		}
		return false;
	}
	/** Purge all cached files. */
	bool unload()
	{
		if (_dict.empty())
		{
			return false;
		}
		else
		{
			_dict.clear();
			return true;
		}
	}
	void removeUnused()
	{
		if (!_dict.empty())
		{
			for (dict_iter it = _dict.begin(); it != _dict.end();)
			{
				if (it->second->isSingleReference())
				{
					it = _dict.erase(it);
				}
				else ++it;
			}
		}
	}
protected:
	XmlItemCache():
	_item(nullptr),
	_parser(this)
	{ }
	string _path;
	dict _dict;
	Ref<T> _item; // Use reference in case that do the loading in another thread
private:
	rapidxml::xml_sax3_parser<> _parser;
	/** Implement it to get prepare for specific xml parse. */
	virtual void beforeParse(String filename) = 0;
	/** Implement it to do something after xml is parsed. */
	virtual void afterParse(String filename) = 0;
};

NS_DOROTHY_END

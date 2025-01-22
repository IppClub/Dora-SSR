/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Content.h"
#include "Common/Async.h"
#include "Other/rapidxml_sax3.hpp"

NS_DORA_BEGIN

template <class T>
class XmlParser : public NonCopyable {
public:
	XmlParser(rapidxml::xml_sax2_handler* handler, T* item)
		: _parser(handler)
		, _item(item) { }
	virtual ~XmlParser() { }
	void parse(char* text, int length) {
		_parser.parse<>(text, length);
	}
	T* getItem() const {
		return _item;
	}

protected:
	rapidxml::xml_sax3_parser<> _parser;
	Ref<T> _item;
};

/** @brief Useful for reading xml files and cache them in memory.
 T is the class to store every parsed xml file.
*/
template <class T>
class XmlItemCache : public NonCopyable {
public:
	virtual ~XmlItemCache() { }
	/** Load a new xml file or get its data for cache. */
	T* load(String filename) {
		std::string file = SharedContent.getFullPath(filename);
		auto it = _dict.find(file);
		if (it != _dict.end()) {
			return it->second;
		} else {
			auto data = SharedContent.load(file);
			if (data.first) {
				auto parser = prepareParser(file);
				T* result = nullptr;
				try {
					parser->parse(r_cast<char*>(data.first.get()), s_cast<int>(data.second));
					result = parser->getItem();
					_dict[file] = parser->getItem();
					return result;
				} catch (rapidxml::parse_error error) {
					Error("xml parse error: {}, at: {}", error.what(), error.where<char>() - r_cast<char*>(data.first.get()));
					return nullptr;
				}
			}
			return nullptr;
		}
	}
	void loadAsync(String filename, const std::function<void(T* item)>& handler) {
		std::string fullPath = SharedContent.getFullPath(filename);
		auto it = _dict.find(fullPath);
		if (it != _dict.end()) {
			handler(it->second);
		} else {
			std::string file(filename.toString());
			SharedContent.loadAsyncUnsafe(file, [this, file, handler](uint8_t* data, int64_t size) {
				if (data) {
					auto parser = prepareParser(file);
					SharedAsyncThread.run(
						[this, file, parser, data, size]() {
							OwnArray<uint8_t> dataOwner = MakeOwnArray(data);
							T* result;
							try {
								parser->parse(r_cast<char*>(data), s_cast<int>(size));
								result = parser->getItem();
							} catch (rapidxml::parse_error error) {
								Error("xml parse error: {}, at: {}", error.what(), error.where<char>() - r_cast<const char*>(data));
							}
							return Values::alloc(result);
						},
						[this, handler, file](Own<Values> values) {
							T* item;
							values->get(item);
							_dict[file] = item;
							handler(item);
						});
				} else {
					handler(nullptr);
				}
			});
		}
	}
	T* update(String name, String content) {
		std::string file = SharedContent.getFullPath(name);
		std::string data(content.toString());
		T* result = nullptr;
		auto parser = prepareParser(name);
		try {
			parser->parse(c_cast<char*>(data.c_str()), s_cast<int>(content.size()));
			result = parser->getItem();
			_dict[file] = parser->getItem();
			return result;
		} catch (rapidxml::parse_error error) {
			Error("xml parse error: {}, at: {}", error.what(), error.where<char>() - r_cast<const char*>(data.c_str()));
			return nullptr;
		}
	}
	T* update(String name, T* item) {
		std::string file = SharedContent.getFullPath(name);
		_dict[file] = item;
		return item;
	}
	/** Purge the cached file. */
	bool unload(String filename) {
		std::string file = SharedContent.getFullPath(filename);
		auto it = _dict.find(file);
		if (it != _dict.end()) {
			_dict.erase(it);
			return true;
		}
		return false;
	}
	/** Purge all cached files. */
	bool unload() {
		if (_dict.empty()) {
			return false;
		}
		_dict.clear();
		return true;
	}
	void removeUnused() {
		for (auto it = _dict.begin(); it != _dict.end();) {
			if (it->second->isSingleReferenced()) {
				it = _dict.erase(it);
			} else
				++it;
		}
	}

protected:
	XmlItemCache() { }
	StringMap<Ref<T>> _dict;

private:
	/** Implement it to get prepare for specific xml parse. */
	virtual std::shared_ptr<XmlParser<T>> prepareParser(String filename) = 0;
};

NS_DORA_END

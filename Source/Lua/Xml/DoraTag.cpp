/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/Xml/DoraTag.h"

#include <sstream>

NS_DORA_BEGIN

static const char dora_tag_text[] =
#include "Lua/Xml/DoraTagText.hpp"
	;

DoraTag& DoraTag::shared() {
	static DoraTag tag;
	return tag;
}

DoraTag::Attribute::Attribute(const std::string& name, std::shared_ptr<std::list<std::string>> hints)
	: name(name)
	, hints(hints) { }

DoraTag::Attribute::~Attribute() { }

DoraTag::DoraTag() {
	DoraTag::load();
}

DoraTag::~DoraTag() { }

DoraTag::LineType DoraTag::getType(const std::string& line) {
	auto lineStr = Slice(line).trimSpace();
	if (lineStr.empty()) {
		return LineType::None;
	} else if (line.at(0) != '\t' && line.at(0) != ' ') {
		return line.find_first_of(':') == std::string::npos ? LineType::Element : LineType::List;
	} else
		return LineType::Attribute;
}

void DoraTag::load() {
	StringMap<std::shared_ptr<std::list<std::string>>> lists;
	std::string elementName;
	std::shared_ptr<Element> element;

	std::stringstream stream;
	stream << dora_tag_text;

	for (std::string line; std::getline(stream, line);) {
		auto lineType = getType(line);
		line.erase(std::remove_if(line.begin(), line.end(), [](char ch) {
			return std::isspace(ch);
		}),
			line.end());
		switch (lineType) {
			case LineType::None:
				break;
			case LineType::List: {
				auto index = line.find_first_of(':');
				auto listStr = line.substr(index + 1);
				auto tokens = Slice(listStr).split(","_slice);
				auto list = std::make_shared<std::list<std::string>>();
				for (const auto& token : tokens) {
					list->push_back(token.toString());
				}
				lists[line.substr(0, index)] = list;
				break;
			}
			case LineType::Element: {
				if (element) {
					_elements[elementName] = element;
				}
				elementName = line;
				element = std::make_shared<Element>();
				element->isNode = elementName == "Node"_slice;
				elementNames.push_back(elementName);
				break;
			}
			case LineType::Attribute: {
				auto index = line.find_first_of(':');
				if (index != std::string::npos) { // has hints
					std::string attrName = line.substr(0, index);
					std::string hints = line.substr(index + 1);
					if (attrName == "Base"_slice) {
						if (hints != "No"_slice) {
							element->isNode = elementName == "Node"_slice ? true : _elements[hints]->isNode;
							element->base = hints;
						}
					} else if (attrName == "Parent"_slice) {
						if (hints != "No"_slice) {
							auto list = std::make_shared<std::list<std::string>>();
							if (hints.find_first_of(',') != std::string::npos) {
								list = std::make_shared<std::list<std::string>>();
								auto tokens = Slice(hints).split(","_slice);
								for (const auto& token : tokens) {
									list->push_back(token.toString());
								}
							} else if (hints == "*"_slice) {
								list = std::make_shared<std::list<std::string>>();
							} else {
								auto listName = line.substr(index + 1);
								list = lists[listName];
							}
							element->parents = list;
						}
					} else {
						std::shared_ptr<std::list<std::string>> list;
						if (hints.find_first_of(',') != std::string::npos) {
							list = std::make_shared<std::list<std::string>>();
							auto tokens = Slice(hints).split(","_slice);
							for (const auto& token : tokens) {
								list->push_back(token.toString());
							}
						} else {
							std::string listName = line.substr(index + 1);
							list = lists[listName];
						}
						element->attributes.push_back(std::make_shared<Attribute>(attrName, list));
					}
				} else {
					element->attributes.push_back(std::make_shared<Attribute>(line, nullptr));
				}
				break;
			}
			default:
				break;
		}
	}
	if (element) {
		_elements[elementName] = element;
		element = nullptr;
	}
	for (const std::string& name : elementNames) {
		const auto& element = _elements[name];
		if (element->parents) {
			std::list<std::string>& parents = *(element->parents);
			for (const std::string& parent : parents) {
				_elements[parent]->subElements.push_back(name);
			}
			element->parents = nullptr;
		}
		if (!element->base.empty()) {
			const auto& attributes = _elements[element->base]->attributes;
			for (const std::shared_ptr<Attribute>& attr : attributes) {
				element->attributes.push_back(attr);
			}
		}
	}
}

std::list<std::string> DoraTag::getAttributes(const std::string& elementName) {
	std::list<std::string> attrs;
	auto it = _elements.find(elementName);
	if (it != _elements.end()) {
		for (const std::shared_ptr<Attribute>& attr : it->second->attributes) {
			attrs.push_back(attr->name);
		}
	}
	return attrs;
}

std::list<std::string> DoraTag::getAttributeHints(const std::string& elementName, const std::string& attrName) {
	auto it = _elements.find(elementName);
	if (it != _elements.end()) {
		for (const std::shared_ptr<Attribute>& attr : it->second->attributes) {
			if (attr->name == attrName && attr->hints) {
				return *attr->hints;
			}
		}
	} else if (attrName == "Ref"_slice) {
		return std::list<std::string>{"True"s, "False"s};
	}
	return std::list<std::string>();
}

std::list<std::string> DoraTag::getSubElements(const std::string& elementName) {
	auto it = _elements.find(elementName);
	if (it != _elements.end()) {
		return it->second->subElements;
	} else {
		it = _elements.find("Node"s);
		if (it != _elements.end()) {
			return it->second->subElements;
		}
	}
	return std::list<std::string>();
}

bool DoraTag::isElementNode(const std::string& elementName) {
	auto it = _elements.find(elementName);
	if (it != _elements.end()) {
		return it->second->isNode;
	}
	return true;
}

NS_DORA_END

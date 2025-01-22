/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

class DoraTag {
public:
	DoraTag();
	~DoraTag();
	std::list<std::string> getAttributes(const std::string& elementName);
	std::list<std::string> getAttributeHints(const std::string& elementName, const std::string& attrName);
	std::list<std::string> getSubElements(const std::string& elementName);
	bool isElementNode(const std::string& elementName);
	static DoraTag& shared();

private:
	void load();
	enum class LineType {
		None,
		List,
		Element,
		Attribute
	};
	LineType getType(const std::string& line);

private:
	class Attribute {
	public:
		Attribute(const std::string& name, std::shared_ptr<std::list<std::string>> hints);
		~Attribute();
		std::string name;
		std::shared_ptr<std::list<std::string>> hints;
	};

	struct Element {
		bool isNode;
		std::string base;
		std::shared_ptr<std::list<std::string>> parents;
		std::list<std::string> subElements;
		std::list<std::shared_ptr<Attribute>> attributes;
	};

	StringMap<std::shared_ptr<Element>> _elements;
	std::list<std::string> elementNames;
};

NS_DORA_END

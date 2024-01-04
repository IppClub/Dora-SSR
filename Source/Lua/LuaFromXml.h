/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "tinyxml2/SAXParser.h"

NS_DORA_BEGIN

class XmlDelegator;

class XmlLoader {
public:
	virtual ~XmlLoader();
	struct XmlError {
		int line;
		std::string message;
	};
	using XmlErrors = std::list<XmlError>;
	std::variant<std::string, XmlErrors> loadFile(String filename);
	std::variant<std::string, XmlErrors> loadXml(String xml);

protected:
	XmlLoader();

private:
	Own<XmlDelegator> _delegator;
	Own<SAXParser> _parser;
	SINGLETON_REF(XmlLoader, ObjectBase);
};

#define SharedXmlLoader \
	Dora::Singleton<Dora::XmlLoader>::shared()

NS_DORA_END

/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "tinyxml2/SAXParser.h"

NS_DOROTHY_BEGIN

class XmlDelegator;

class XmlLoader
{
public:
	virtual ~XmlLoader();
	std::string load(String filename);
	std::string loadXml(String xml);
	std::string getLastError();
protected:
	XmlLoader();
private:
	Own<XmlDelegator> _delegator;
	SAXParser _parser;
	SINGLETON_REF(XmlLoader, ObjectBase);
};

#define SharedXmlLoader \
	Dorothy::Singleton<Dorothy::XmlLoader>::shared()

NS_DOROTHY_END

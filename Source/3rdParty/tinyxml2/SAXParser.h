/* Copyright (c) 2022 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "tinyxml2/tinyxml2.h"
#include <string>

typedef unsigned char XML_CHAR;

class SAXDelegator {
public:
	virtual void startElement(const char* name, const char** atts) = 0;
	virtual void endElement(const char* name) = 0;
	virtual void textHandler(const char* s, int len) = 0;
};

class SAXParser {
public:
	SAXParser();
	~SAXParser();

	bool parseXml(const std::string& xmlData);
	bool parse(const std::string& filename);
	const char* getBuffer() const;
	const std::string& getLastError() const;

	void setDelegator(SAXDelegator* delegator);

	static void startElement(void* ctx, const XML_CHAR* name, const XML_CHAR** atts);
	static void endElement(void* ctx, const XML_CHAR* name);
	static void textHandler(void* ctx, const XML_CHAR* name, int len);

	static void placeCDataHeader(const char* cdataHeader);
	static void setHeaderHandler(void (*handler)(const char* start, const char* end));

private:
	SAXDelegator* _delegator;
	std::string _lastError;
	tinyxml2::XMLDocument _tinyDoc;
};

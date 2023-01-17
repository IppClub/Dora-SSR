/* Copyright (c) 2023 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "tinyxml2/SAXParser.h"

#include "Basic/Content.h"
using namespace Dorothy;

class XmlSaxHander : public tinyxml2::XMLVisitor {
public:
	XmlSaxHander()
		: _saxParser(nullptr) { }
	virtual bool VisitEnter(const tinyxml2::XMLElement& element, const tinyxml2::XMLAttribute* firstAttribute);
	virtual bool VisitExit(const tinyxml2::XMLElement& element);
	virtual bool Visit(const tinyxml2::XMLText& text);
	virtual bool Visit(const tinyxml2::XMLUnknown&) { return true; }

	void setSAXParser(SAXParser* parser) {
		_saxParser = parser;
	}

private:
	SAXParser* _saxParser;
};

bool XmlSaxHander::VisitEnter(const tinyxml2::XMLElement& element, const tinyxml2::XMLAttribute* firstAttribute) {
	std::vector<const char*> attsVector;
	for (const tinyxml2::XMLAttribute* attrib = firstAttribute; attrib; attrib = attrib->Next()) {
		attsVector.push_back(attrib->Name());
		attsVector.push_back(attrib->Value());
	}
	attsVector.push_back(nullptr);

	SAXParser::startElement(_saxParser, (const XML_CHAR*)element.Value(), (const XML_CHAR**)(&attsVector[0]));
	return true;
}
bool XmlSaxHander::VisitExit(const tinyxml2::XMLElement& element) {
	SAXParser::endElement(_saxParser, (const XML_CHAR*)element.Value());
	return true;
}

bool XmlSaxHander::Visit(const tinyxml2::XMLText& text) {
	SAXParser::textHandler(_saxParser, (const XML_CHAR*)text.Value(), (int)strlen(text.Value()));
	return true;
}

SAXParser::SAXParser()
	: _delegator(nullptr) { }

SAXParser::~SAXParser() { }

const std::string& SAXParser::getLastError() const {
	return _lastError;
}

bool SAXParser::parseXml(const std::string& xmlData) {
	_lastError.clear();
	tinyxml2::XMLError error;
	if (xmlData.empty()) {
		error = _tinyDoc.Parse(xmlData.c_str());
	} else {
		error = _tinyDoc.Parse(xmlData.c_str(), xmlData.size());
	}
	if (error != tinyxml2::XML_NO_ERROR) {
		_lastError = fmt::format("Xml document error at line {}, ", _tinyDoc.GetErrorLine());
		switch (error) {
			case tinyxml2::XML_NO_ATTRIBUTE: _lastError += "no attribute."; break;
			case tinyxml2::XML_WRONG_ATTRIBUTE_TYPE: _lastError += "wrong attribute type."; break;
			case tinyxml2::XML_ERROR_FILE_NOT_FOUND: _lastError += "file not found."; break;
			case tinyxml2::XML_ERROR_FILE_COULD_NOT_BE_OPENED: _lastError += "file could not be opened."; break;
			case tinyxml2::XML_ERROR_FILE_READ_ERROR: _lastError += "file read error."; break;
			case tinyxml2::XML_ERROR_ELEMENT_MISMATCH: _lastError += "element mismatch."; break;
			case tinyxml2::XML_ERROR_PARSING_ELEMENT: _lastError += "parsing element error."; break;
			case tinyxml2::XML_ERROR_PARSING_ATTRIBUTE: _lastError += "parsing attribute error."; break;
			case tinyxml2::XML_ERROR_IDENTIFYING_TAG: _lastError += "identifying tag error."; break;
			case tinyxml2::XML_ERROR_PARSING_TEXT: _lastError += "parsing text error."; break;
			case tinyxml2::XML_ERROR_PARSING_CDATA: _lastError += "parsing cdata error."; break;
			case tinyxml2::XML_ERROR_PARSING_COMMENT: _lastError += "parsing comment error."; break;
			case tinyxml2::XML_ERROR_PARSING_DECLARATION: _lastError += "parsing declaration error."; break;
			case tinyxml2::XML_ERROR_PARSING_UNKNOWN: _lastError += "parsing unknown error."; break;
			case tinyxml2::XML_ERROR_EMPTY_DOCUMENT: _lastError += "empty document."; break;
			case tinyxml2::XML_ERROR_MISMATCHED_ELEMENT: _lastError += "mismatch element."; break;
			case tinyxml2::XML_ERROR_PARSING: _lastError += "parsing error."; break;
			case tinyxml2::XML_CAN_NOT_CONVERT_TEXT: _lastError += "can not convert text."; break;
			case tinyxml2::XML_NO_TEXT_NODE: _lastError += "no text node."; break;
			default:
				break;
		}
		if (_tinyDoc.GetErrorStr1()) {
			_lastError += " ";
			_lastError += _tinyDoc.GetErrorStr1();
		}
		if (_tinyDoc.GetErrorStr2()) {
			_lastError += ", ";
			_lastError += _tinyDoc.GetErrorStr2();
		}
		_lastError += "\n";
		return false;
	}
	XmlSaxHander printer;
	printer.setSAXParser(this);
	return _tinyDoc.Accept(&printer);
}

bool SAXParser::parse(const std::string& filename) {
	auto data = SharedContent.load(filename);
	return parseXml(Slice(r_cast<char*>(data.first.get()), data.second));
}

const char* SAXParser::getBuffer() const {
	return _tinyDoc.GetCharBuffer();
}

void SAXParser::startElement(void* ctx, const XML_CHAR* name, const XML_CHAR** atts) {
	((SAXParser*)(ctx))->_delegator->startElement((char*)name, (const char**)atts);
}

void SAXParser::endElement(void* ctx, const XML_CHAR* name) {
	((SAXParser*)(ctx))->_delegator->endElement((char*)name);
}

void SAXParser::textHandler(void* ctx, const XML_CHAR* name, int len) {
	((SAXParser*)(ctx))->_delegator->textHandler((char*)name, len);
}

void SAXParser::setDelegator(SAXDelegator* delegator) {
	_delegator = delegator;
}

void SAXParser::placeCDataHeader(const char* cdataHeader) {
	tinyxml2::XMLUtil::PlaceCDataHeader(cdataHeader);
}

void SAXParser::setHeaderHandler(void (*handler)(const char* start, const char* end)) {
	tinyxml2::XMLUtil::PlaceHeaderHandler(handler);
}

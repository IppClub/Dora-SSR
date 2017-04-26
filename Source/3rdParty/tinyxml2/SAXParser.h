#pragma once

#include "tinyxml2/tinyxml2.h"

typedef unsigned char XML_CHAR;

class SAXDelegator
{
public:
    virtual void startElement(const char* name, const char** atts) = 0;
    virtual void endElement(const char* name) = 0;
    virtual void textHandler(const char* s, int len) = 0;
};

class SAXParser
{
public:
    SAXParser();
    ~SAXParser();

    bool parseXml(const string& xmlData);
    bool parse(const string& filename);
	const string& getLastError() const;

    void setDelegator(SAXDelegator* delegator);

    static void startElement(void* ctx, const XML_CHAR* name, const XML_CHAR** atts);
    static void endElement(void* ctx, const XML_CHAR* name);
    static void textHandler(void* ctx, const XML_CHAR* name, int len);

	static void placeCDataHeader(const char* cdataHeader);
	static void setHeaderHandler(void(*handler)(const char* start, const char* end));
	int getLineNumber(const char* name);
private:
	SAXDelegator* _delegator;
	string _lastError;
	tinyxml2::XMLDocument _tinyDoc;
};

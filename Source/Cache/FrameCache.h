/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Cache/XmlItemCache.h"
#include "Common/Singleton.h"

NS_DOROTHY_BEGIN

class FrameAction;
struct Rect;

class FrameActionDef : public Object
{
public:
	std::string clipStr;
	float duration;
	OwnVector<Rect> rects;
	CREATE_FUNC(FrameActionDef);
protected:
	FrameActionDef():duration(0) { }
};

/** @brief Load frame animations from ".frame" files and cache them. */
class FrameCache : public XmlItemCache<FrameActionDef>
{
public:
	FrameActionDef* loadFrame(String frameStr);
	bool isFrame(String frameStr) const;
protected:
	FrameCache() { }
	virtual std::shared_ptr<XmlParser<FrameActionDef>> prepareParser(String filename) override;
private:
	class Parser : public XmlParser<FrameActionDef>, public rapidxml::xml_sax2_handler
	{
	public:
		Parser(FrameActionDef* def, String path):XmlParser<FrameActionDef>(this, def),_path(path) { }
		virtual void xmlSAX2StartElement(const char* name, size_t len, const std::vector<AttrSlice>& attrs) override;
		virtual void xmlSAX2EndElement(const char* name, size_t len) override;
		virtual void xmlSAX2Text(const char* s, size_t len) override;
	private:
		std::string _path;
	};
	SINGLETON_REF(FrameCache, Director, AsyncThread);
};

#define SharedFrameCache \
	Dorothy::Singleton<Dorothy::FrameCache>::shared()

NS_DOROTHY_END

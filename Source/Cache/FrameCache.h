/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Cache/XmlItemCache.h"
#include "Common/Singleton.h"

NS_DORA_BEGIN

class FrameAction;
struct Rect;

class FrameActionDef : public Object {
public:
	std::string clipStr;
	float duration;
	OwnVector<Rect> rects;
	CREATE_FUNC_NOT_NULL(FrameActionDef);

protected:
	FrameActionDef()
		: duration(0) { }
};

/** @brief Load frame animations from ".frame" files and cache them. */
class FrameCache : public XmlItemCache<FrameActionDef> {
public:
	FrameActionDef* loadFrame(String frameStr);
	bool isFrame(String frameStr) const;

protected:
	FrameCache() { }
	virtual std::shared_ptr<XmlParser<FrameActionDef>> prepareParser(String filename) override;

private:
	class Parser : public XmlParser<FrameActionDef>, public rapidxml::xml_sax2_handler {
	public:
		Parser(FrameActionDef* def, String path)
			: XmlParser<FrameActionDef>(this, def)
			, _path(path.toString()) { }
		virtual void xmlSAX2StartElement(std::string_view name, const std::vector<std::string_view>& attrs) override;
		virtual void xmlSAX2EndElement(std::string_view name) override;
		virtual void xmlSAX2Text(std::string_view text) override;

	private:
		std::string _path;
	};
	SINGLETON_REF(FrameCache, Director, AsyncThread);
};

#define SharedFrameCache \
	Dora::Singleton<Dora::FrameCache>::shared()

NS_DORA_END

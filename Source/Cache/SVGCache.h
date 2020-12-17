/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Cache/XmlItemCache.h"
#include "Common/Singleton.h"
#include "Support/Geometry.h"
#include "Support/Common.h"
#include "Basic/VGRender.h"
#include <optional>

NS_DOROTHY_BEGIN

class SVGDef : public Object
{
public:
	struct Context
	{
		NVGcontext* nvg;
		SVGDef* def;
		vector<Vec2> previousPathXY;
		vector<int> transformCounts;
	};
	using GradientMap = unordered_map<string,function<void(Context*)>>;
	using CommandList = list<function<void(Context*)>>;
	PROPERTY_READONLY_CREF(GradientMap, Gradients);
	PROPERTY_READONLY_CREF(CommandList, Commands);
	PROPERTY_READONLY(float, Width);
	PROPERTY_READONLY(float, Height);
	void render();
	CREATE_FUNC(SVGDef);
private:
	float _width = 0.0f;
	float _height = 0.0f;
	GradientMap _gradients;
	CommandList _commands;
	friend class SVGCache;
	DORA_TYPE_OVERRIDE(SVGDef);
};

class SVGCache : public XmlItemCache<SVGDef>
{
protected:
	SVGCache() { }
	virtual std::shared_ptr<XmlParser<SVGDef>> prepareParser(String filename) override;
private:
	class Parser : public XmlParser<SVGDef>, public rapidxml::xml_sax2_handler
	{
	public:
		Parser(SVGDef* def):XmlParser<SVGDef>(this, def),
		_params{
			{'A', 7}, {'C', 6}, {'H', 1}, {'L', 2},
			{'M', 2}, {'Q', 4}, {'S', 4}, {'T', 2},
			{'V', 1}, {'Z', 0}} { }
		virtual void xmlSAX2StartElement(const char* name, size_t len, const vector<AttrSlice>& attrs) override;
		virtual void xmlSAX2EndElement(const char* name, size_t len) override;
		virtual void xmlSAX2Text(const char* s, size_t len) override;
	private:
		struct LinearGradient
		{
			string id;
			float x1 = 0.0f, y1 = 0.0f, x2 = 0.0f, y2 = 0.0f;
			std::optional<nvg::Transform> transform;
			vector<std::pair<float,Color>> stops;
		} _currentLinearGradient;
		unordered_map<char, int> _params;
		stack<vector<AttrSlice>> _attrStack;
	};
private:
	SINGLETON_REF(SVGCache, Director, AsyncThread);
};

#define SharedSVGCache \
	Dorothy::Singleton<Dorothy::SVGCache>::shared()

NS_DOROTHY_END

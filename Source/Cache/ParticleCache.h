/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Cache/XmlItemCache.h"
#include "Common/Singleton.h"
#include "Support/Geometry.h"

NS_DORA_BEGIN

class ParticleNode;
class ParticleDef;

class ParticleCache : public XmlItemCache<ParticleDef> {
protected:
	ParticleCache() { }
	virtual std::shared_ptr<XmlParser<ParticleDef>> prepareParser(String filename) override;

private:
	class Parser : public XmlParser<ParticleDef>, public rapidxml::xml_sax2_handler {
	public:
		Parser(ParticleDef* def)
			: XmlParser<ParticleDef>(this, def) { }
		virtual void xmlSAX2StartElement(std::string_view name, const std::vector<std::string_view>& attrs) override;
		virtual void xmlSAX2EndElement(std::string_view name) override;
		virtual void xmlSAX2Text(std::string_view text) override;

	private:
		void get(String value, Vec4& vec);
		void get(String value, Vec2& vec);
		void get(String value, Rect& rect);
	};

private:
	SINGLETON_REF(ParticleCache, Director, AsyncThread);
};

#define SharedParticleCache \
	Dora::Singleton<Dora::ParticleCache>::shared()

NS_DORA_END

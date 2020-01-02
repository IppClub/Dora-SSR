/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Cache/XmlItemCache.h"
#include "Common/Singleton.h"

NS_DOROTHY_BEGIN

class SpriteDef;
class AnimationDef;
class KeyAnimationDef;
class PlayTrackDef;
class ModelDef;
class Model;

class ModelCache : public XmlItemCache<ModelDef>
{
protected:
	ModelCache() { }
	virtual std::shared_ptr<XmlParser<ModelDef>> prepareParser(String filename) override;
private:
	class Parser : public XmlParser<ModelDef>, public rapidxml::xml_sax2_handler
	{
	public:
		Parser(ModelDef* def, String path);
		virtual void xmlSAX2StartElement(const char* name, size_t len, const vector<AttrSlice>& attrs) override;
		virtual void xmlSAX2EndElement(const char* name, size_t len) override;
		virtual void xmlSAX2Text(const char* s, size_t len) override;
	private:
		string _path;
		void getPosFromStr(String str, float& x, float& y);
		KeyAnimationDef* getCurrentKeyAnimation();
		PlayTrackDef* getCurrentTrack();
		stack<Own<SpriteDef>> _nodeStack;
		Own<AnimationDef> _currentAnimationDef;
		Own<AnimationDef> _currentTrackDef;
	};
	SINGLETON_REF(ModelCache, Director, AsyncThread);
};

#define SharedModelCache \
	Dorothy::Singleton<Dorothy::ModelCache>::shared()

NS_DOROTHY_END

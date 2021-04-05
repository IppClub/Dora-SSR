/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Cache/XmlItemCache.h"
#include "Common/Singleton.h"

NS_DOROTHY_BEGIN

class Sprite;
class Texture2D;
struct Rect;

/** @brief Clips are different rectangle areas on textures.
 This is the data for clips from a single texture.
*/
class ClipDef : public Object
{
public:
	/** Name of the texture file. Name only, not file path. */
	std::string textureFile;
	/** Different areas on this texture. */
	std::unordered_map<std::string, Own<Rect>> rects;
	/** Get a sprite instance with an name. */
	Sprite* toSprite(String name);
	std::string toXml();
	CREATE_FUNC(ClipDef);
protected:
	ClipDef();
};

/** @brief Load texture clip from ".clip" files and cache them. */
class ClipCache : public XmlItemCache<ClipDef>
{
public:
	/** A clip str is like "loli.clip|0", file name + "|" + clip index.
	 Load a new clip file or get it from cache,
	 then create a new sprite instance with certain clip.
	*/
	Sprite* loadSprite(String clipStr);
	std::pair<Texture2D*,Rect> loadTexture(String clipStr);
	bool isFileExist(String clipStr) const;
	bool isClip(String clipStr) const;
protected:
	ClipCache() { }
	virtual std::shared_ptr<XmlParser<ClipDef>> prepareParser(String filename) override;
private:
	class Parser : public XmlParser<ClipDef>, public rapidxml::xml_sax2_handler
	{
	public:
		Parser(ClipDef* def, String path):XmlParser<ClipDef>(this, def),_path(path) { }
		virtual void xmlSAX2StartElement(const char* name, size_t len, const std::vector<AttrSlice>& attrs) override;
		virtual void xmlSAX2EndElement(const char* name, size_t len) override;
		virtual void xmlSAX2Text(const char* s, size_t len) override;
	private:
		std::string _path;
	};
	SINGLETON_REF(ClipCache, Director, AsyncThread);
};

#define SharedClipCache \
	Dorothy::Singleton<Dorothy::ClipCache>::shared()

NS_DOROTHY_END

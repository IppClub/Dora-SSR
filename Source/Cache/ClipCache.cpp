/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/ClipCache.h"
#include "Const/XmlTag.h"
#include "Cache/TextureCache.h"
#include "Node/Sprite.h"
#include "fmt/format.h"

NS_DOROTHY_BEGIN

ClipDef::ClipDef()
{ }

Sprite* ClipDef::toSprite(String name)
{
	auto it = rects.find(name);
	if (it != rects.end())
	{
		Texture2D* texture = SharedTextureCache.load(textureFile);
		Sprite* sprite = Sprite::create(texture, *it->second);
		return sprite;
	}
	return nullptr;
}

string ClipDef::toXml()
{
	fmt::MemoryWriter writer;
	writer << '<' << char(Xml::Clip::Element::Dorothy) << ' ' << char(Xml::Clip::Dorothy::File) << "=\""
		<< Slice(textureFile).getFileName() << "\">";
	for (const auto& rect : rects)
	{
		writer << '<' << char(Xml::Clip::Element::Clip) << ' '
			<< char(Xml::Clip::Clip::Name) << "=\"" << rect.first << "\" "
			<< char(Xml::Clip::Clip::Rect) << "=\""
			<< rect.second->origin.x << ',' << rect.second->origin.y << ','
			<< rect.second->size.width << ',' << rect.second->size.height
			<< "\"/>";
	}
	writer << "</" << char(Xml::Clip::Element::Dorothy) << '>';
	return writer.str();
}

Sprite* ClipCache::loadSprite(String clipStr)
{
	auto tokens = clipStr.split("|");
	AssertUnless(tokens.size() < 2, "invalid clip str for: \"%s\".", clipStr);
	ClipDef* clipDef = ClipCache::load(tokens.front());
	auto it = clipDef->rects.find(*(++tokens.begin()));
	if (it != clipDef->rects.end())
	{
		Texture2D* texture = SharedTextureCache.load(clipDef->textureFile);
		Sprite* sprite = Sprite::create(texture, *it->second);
		return sprite;
	}
	return nullptr;
}

void ClipCache::xmlSAX2Text(const char *s, size_t len)
{ }

void ClipCache::xmlSAX2StartElement(const char* name, size_t len, const vector<AttrSlice>& attrs)
{
	switch (Xml::Clip::Element(name[0]))
	{
		case Xml::Clip::Element::Dorothy:
		{
			for (int i = 0; attrs[i].first != nullptr; i++)
			{
				switch (Xml::Clip::Dorothy(attrs[i].first[0]))
				{
					case Xml::Clip::Dorothy::File:
						_item->textureFile = _path + Slice(attrs[++i]);
						break;
				}
			}
			break;
		}
		case Xml::Clip::Element::Clip:
		{
			Slice name;
			for (int i = 0; attrs[i].first != nullptr; i++)
			{
				switch (Xml::Clip::Clip(attrs[i].first[0]))
				{
					case Xml::Clip::Clip::Name:
					{
						name = attrs[++i];
						break;
					}
					case Xml::Clip::Clip::Rect:
					{
						Slice attr(attrs[++i]);
						auto tokens = attr.split(",");
						AssertUnless(tokens.size() == 4, "invalid clip rect str for: \"%s\"", attr);
						auto it = tokens.begin();
						float x = std::stof(*it);
						float y = std::stof(*++it);
						float w = std::stof(*++it);
						float h = std::stof(*++it);
						_item->rects[name] = New<Rect>(x, y, w, h);
						break;
					}
				}
			}
			break;
		}
	}
}

void ClipCache::xmlSAX2EndElement(const char *name, size_t len)
{ }

void ClipCache::beforeParse(String filename )
{
	_item = ClipDef::create();
}

void ClipCache::afterParse(String filename )
{ }

NS_DOROTHY_END

/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/ClipCache.h"
#include "Const/XmlTag.h"
#include "Cache/TextureCache.h"
#include "Node/Sprite.h"

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
	fmt::memory_buffer out;
	fmt::format_to(out, "<{} =\"{}\">", char(Xml::Clip::Element::Dorothy), char(Xml::Clip::Dorothy::File));
	for (const auto& rect : rects)
	{
		fmt::format_to(out, "<{} {}=\"{}\" {}=\"{},{},{},{}\"/>",
			char(Xml::Clip::Element::Clip),
			char(Xml::Clip::Clip::Name), rect.first,
			char(Xml::Clip::Clip::Rect),
			rect.second->origin.x, rect.second->origin.y,
			rect.second->size.width, rect.second->size.height);
	}
	fmt::format_to(out, "</{}>", char(Xml::Clip::Element::Dorothy));
	return fmt::to_string(out);
}

/* ClipCache */

Texture2D* ClipCache::loadTexture(String clipStr)
{
	if (clipStr.toString().find('|') != string::npos)
	{
		auto tokens = clipStr.split("|");
		AssertUnless(tokens.size() == 2, "invalid clip str for: \"{}\".", clipStr);
		ClipDef* clipDef = ClipCache::load(tokens.front());
		return SharedTextureCache.load(clipDef->textureFile);
	}
	else if (Path::getExt(clipStr) == "clip"_slice)
	{
		ClipDef* clipDef = SharedClipCache.load(clipStr);
		return SharedTextureCache.load(clipDef->textureFile);
	}
	else
	{
		return SharedTextureCache.load(clipStr);
	}
}

std::pair<ClipDef*,Slice> ClipCache::loadClip(String clipStr)
{
	if (clipStr.toString().find('|') != string::npos)
	{
		auto tokens = clipStr.split("|");
		AssertUnless(tokens.size() == 2 && Path::getExt(tokens.front()) == "clip"_slice, "invalid clip str: \"{}\".", clipStr);
		ClipDef* clipDef = ClipCache::load(tokens.front());
		Slice name = tokens.back();
		return std::make_pair(clipDef, name);
	}
	else if (Path::getExt(clipStr) == "clip"_slice)
	{
		ClipDef* clipDef = SharedClipCache.load(clipStr);
		return std::make_pair(clipDef, Slice());
	}
	return std::make_pair(s_cast<ClipDef*>(nullptr), Slice());
}

Sprite* ClipCache::loadSprite(String clipStr)
{
	if (clipStr.toString().find('|') != string::npos)
	{
		auto tokens = clipStr.split("|");
		AssertUnless(tokens.size() == 2 && Path::getExt(tokens.front()) == "clip"_slice, "invalid clip str: \"{}\".", clipStr);
		ClipDef* clipDef = ClipCache::load(tokens.front());
		Slice name = tokens.back();
		auto it = clipDef->rects.find(name);
		if (it != clipDef->rects.end())
		{
			Texture2D* texture = SharedTextureCache.load(clipDef->textureFile);
			return Sprite::create(texture, *it->second);
		}
		else
		{
			Warn("no clip named \"{}\" in {}", name, tokens.front());
			return Sprite::create(clipDef->textureFile);
		}
	}
	else if (Path::getExt(clipStr) == "clip"_slice)
	{
		ClipDef* clipDef = SharedClipCache.load(clipStr);
		return Sprite::create(clipDef->textureFile);
	}
	else
	{
		return Sprite::create(clipStr);
	}
}

bool ClipCache::isFileExist(String clipStr) const
{
	auto tokens = clipStr.split("|");
	return SharedContent.isExist(tokens.front());
}

bool ClipCache::isClip(String clipStr) const
{
	if (clipStr.toString().find('|') != string::npos)
	{
		auto tokens = clipStr.split("|");
		return tokens.size() == 2 && Path::getExt(tokens.front()) == "clip"_slice;
	}
	else if (Path::getExt(clipStr) == "clip"_slice)
	{
		return true;
	}
	return false;
}

std::shared_ptr<XmlParser<ClipDef>> ClipCache::prepareParser(String filename)
{
	return std::shared_ptr<XmlParser<ClipDef>>(new Parser(ClipDef::create(), Path::getPath(filename)));
}

void ClipCache::Parser::xmlSAX2Text(const char *s, size_t len)
{ }

void ClipCache::Parser::xmlSAX2StartElement(const char* name, size_t len, const vector<AttrSlice>& attrs)
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
						_item->textureFile = Path::concat({_path, Slice(attrs[++i])});
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
						AssertUnless(tokens.size() == 4, "invalid clip rect str for: \"{}\"", attr);
						auto it = tokens.begin();
						float x = Slice::stof(*it);
						float y = Slice::stof(*++it);
						float w = Slice::stof(*++it);
						float h = Slice::stof(*++it);
						_item->rects[name] = New<Rect>(x, y, w, h);
						break;
					}
				}
			}
			break;
		}
	}
}

void ClipCache::Parser::xmlSAX2EndElement(const char *name, size_t len)
{ }

NS_DOROTHY_END

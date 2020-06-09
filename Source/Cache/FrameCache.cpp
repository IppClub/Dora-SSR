/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/FrameCache.h"
#include "Const/XmlTag.h"
#include "Cache/TextureCache.h"
#include "Cache/ClipCache.h"
#include "Node/Sprite.h"

NS_DOROTHY_BEGIN

FrameActionDef* FrameCache::loadFrame(String frameStr)
{
	if (Path::getExt(frameStr) == "frame"_slice) return load(frameStr);
	BLOCK_START
	{
		auto parts = frameStr.split("::"_slice);
		BREAK_IF(parts.size() != 2);
		FrameActionDef* def = FrameActionDef::create();
		def->clipStr = parts.front();
		Vec2 origin{};
		if (SharedClipCache.isClip(parts.front()))
		{
			ClipDef* def;
			Slice clip;
			std::tie(def, clip) = SharedClipCache.loadClip(parts.front());
			auto it = def->rects.find(clip);
			if (it != def->rects.end())
			{
				origin = (*it->second).origin;
			}
		}
		auto tokens = parts.back().split(","_slice);
		BREAK_IF(tokens.size() != 4);
		auto it = tokens.begin();
		float width = Slice::stof(*it);
		float height = Slice::stof(*++it);
		int count = Slice::stoi(*++it);
		def->duration = Slice::stof(*++it);
		for (int i = 0; i < count; i++)
		{
			def->rects.push_back(New<Rect>(origin.x + i * width, origin.y, width, height));
		}
		return def;
	}
	BLOCK_END
	Warn("invalid frame str not load: \"{}\".", frameStr);
	return nullptr;
}

bool FrameCache::isFrame(String frameStr) const
{
	auto parts = frameStr.split("::"_slice);
	if (parts.size() == 1) return Path::getExt(parts.front()) == "frame"_slice;
	else if (parts.size() == 2) return parts.back().split(","_slice).size() == 4;
	else return false;
}

std::shared_ptr<XmlParser<FrameActionDef>> FrameCache::prepareParser(String filename)
{
	return std::shared_ptr<XmlParser<FrameActionDef>>(new Parser(FrameActionDef::create(), Path::getPath(filename)));
}

void FrameCache::Parser::xmlSAX2Text(const char* s, size_t len)
{ }

void FrameCache::Parser::xmlSAX2StartElement(const char* name, size_t len, const vector<AttrSlice>& attrs)
{
	switch (Xml::Frame::Element(name[0]))
	{
		case Xml::Frame::Element::Dorothy:
		{
			for (int i = 0; attrs[i].first != nullptr;i++)
			{
				switch (Xml::Frame::Dorothy(attrs[i].first[0]))
				{
					case Xml::Frame::Dorothy::File:
					{
						string file = Slice(attrs[++i]);
						string localFile = Path::concat({_path, file});
						_item->clipStr = SharedContent.isExist(localFile) ? localFile : file;
						break;
					}
					case Xml::Frame::Dorothy::Duration:
						_item->duration = s_cast<float>(std::atof(attrs[++i].first));
						break;
				}
			}
			break;
		}
		case Xml::Frame::Element::Clip:
		{
			for (int i = 0; attrs[i].first != nullptr; i++)
			{
				switch (Xml::Frame::Clip(attrs[i].first[0]))
				{
					case Xml::Frame::Clip::Rect:
					{
						Slice attr(attrs[++i]);
						auto tokens = attr.split(",");
						AssertUnless(tokens.size() == 4, "invalid clip rect str for: \"{}\"", attr);
						auto it = tokens.begin();
						float x = Slice::stof(*it);
						float y = Slice::stof(*++it);
						float w = Slice::stof(*++it);
						float h = Slice::stof(*++it);
						_item->rects.push_back(New<Rect>(x, y, w, h));
						break;
					}
				}
			}
			break;
		}
	}
}

void FrameCache::Parser::xmlSAX2EndElement(const char* name, size_t len)
{ }

NS_DOROTHY_END

/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/FrameCache.h"
#include "Const/XmlTag.h"
#include "Cache/TextureCache.h"
#include "Node/Sprite.h"
#include "fmt/format.h"

NS_DOROTHY_BEGIN

std::shared_ptr<XmlParser<FrameActionDef>> FrameCache::prepareParser(String filename)
{
	return std::shared_ptr<XmlParser<FrameActionDef>>(new Parser(FrameActionDef::create(), filename.getFilePath()));
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
						_item->textureFile = _path + Slice(attrs[++i]);
						break;
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

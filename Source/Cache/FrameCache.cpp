/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/FrameCache.h"

#include "Cache/ClipCache.h"
#include "Cache/TextureCache.h"
#include "Const/XmlTag.h"
#include "Node/Sprite.h"

NS_DORA_BEGIN

FrameActionDef* FrameCache::loadFrame(String frameStr) {
	if (Path::getExt(frameStr.toString()) == "frame"_slice) return load(frameStr);
	BLOCK_START {
		auto parts = frameStr.split("::"_slice);
		BREAK_IF(parts.size() != 2);
		FrameActionDef* def = FrameActionDef::create();
		def->clipStr = parts.front().toString();
		Vec2 origin{};
		if (SharedClipCache.isClip(parts.front())) {
			auto [_tex, rect] = SharedClipCache.loadTexture(parts.front());
			origin = rect.origin;
		}
		auto tokens = parts.back().split(","_slice);
		BREAK_IF(tokens.size() != 4);
		auto it = tokens.begin();
		float width = it->toFloat();
		float height = (++it)->toFloat();
		int count = (++it)->toInt();
		def->duration = (++it)->toFloat();
		for (int i = 0; i < count; i++) {
			def->rects.push_back(New<Rect>(origin.x + i * width, origin.y, width, height));
		}
		return def;
	}
	BLOCK_END
	Error("invalid frame str not load: \"{}\".", frameStr.toString());
	return nullptr;
}

bool FrameCache::isFrame(String frameStr) const {
	auto parts = frameStr.split("::"_slice);
	if (parts.size() == 1)
		return Path::getExt(parts.front().toString()) == "frame"_slice;
	else if (parts.size() == 2)
		return parts.back().split(","_slice).size() == 4;
	else
		return false;
}

std::shared_ptr<XmlParser<FrameActionDef>> FrameCache::prepareParser(String filename) {
	return std::shared_ptr<XmlParser<FrameActionDef>>(new Parser(FrameActionDef::create(), Path::getPath(filename.toString())));
}

void FrameCache::Parser::xmlSAX2Text(std::string_view text) { }

void FrameCache::Parser::xmlSAX2StartElement(std::string_view name, const std::vector<std::string_view>& attrs) {
	switch (Xml::Frame::Element(name[0])) {
		case Xml::Frame::Element::Dorothy: {
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Frame::Dorothy(attrs[i][0])) {
					case Xml::Frame::Dorothy::File: {
						Slice file(attrs[++i]);
						std::string localFile = Path::concat({_path, file});
						_item->clipStr = SharedContent.exist(localFile) ? localFile : file.toString();
						break;
					}
					case Xml::Frame::Dorothy::Duration:
						_item->duration = s_cast<float>(std::atof(attrs[++i].data()));
						break;
				}
			}
			break;
		}
		case Xml::Frame::Element::Clip: {
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Frame::Clip(attrs[i][0])) {
					case Xml::Frame::Clip::Rect: {
						Slice attr(attrs[++i]);
						auto tokens = attr.split(",");
						AssertUnless(tokens.size() == 4, "invalid clip rect str for: \"{}\"", attr.toString());
						auto it = tokens.begin();
						float x = it->toFloat();
						float y = (++it)->toFloat();
						float w = (++it)->toFloat();
						float h = (++it)->toFloat();
						_item->rects.push_back(New<Rect>(x, y, w, h));
						break;
					}
				}
			}
			break;
		}
	}
}

void FrameCache::Parser::xmlSAX2EndElement(std::string_view name) { }

NS_DORA_END

/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/ClipCache.h"

#include "Cache/TextureCache.h"
#include "Const/XmlTag.h"
#include "Node/Sprite.h"

NS_DORA_BEGIN

ClipDef::ClipDef() { }

Sprite* ClipDef::toSprite(String name) {
	auto it = rects.find(name);
	if (it != rects.end()) {
		Texture2D* texture = SharedTextureCache.load(textureFile);
		Sprite* sprite = Sprite::create(texture, *it->second);
		return sprite;
	}
	return nullptr;
}

std::string ClipDef::toXml() {
	fmt::memory_buffer out;
	fmt::format_to(std::back_inserter(out), "<{} =\"{}\">"sv, char(Xml::Clip::Element::Dorothy), char(Xml::Clip::Dorothy::File));
	for (const auto& rect : rects) {
		fmt::format_to(std::back_inserter(out), "<{} {}=\"{}\" {}=\"{},{},{},{}\"/>"sv,
			char(Xml::Clip::Element::Clip),
			char(Xml::Clip::Clip::Name), rect.first,
			char(Xml::Clip::Clip::Rect),
			rect.second->origin.x, rect.second->origin.y,
			rect.second->size.width, rect.second->size.height);
	}
	fmt::format_to(std::back_inserter(out), "</{}>"sv, char(Xml::Clip::Element::Dorothy));
	return fmt::to_string(out);
}

/* ClipCache */

std::pair<Texture2D*, Rect> ClipCache::loadTexture(String clipStr) {
	if (clipStr.toString().find('|') != std::string::npos) {
		auto tokens = clipStr.split("|");
		if (tokens.size() != 2 || Path::getExt(tokens.front().toString()) != "clip"_slice) {
			Error("invalid clip str: \"{}\".", clipStr.toString());
			return {};
		}
		ClipDef* clipDef = ClipCache::load(tokens.front());
		if (!clipDef) {
			Error("failed to load clip: \"{}\".", clipStr.toString());
			return {};
		}
		Slice name = tokens.back();
		auto nameStr = name.toString();
		auto it = clipDef->rects.find(nameStr);
		if (it != clipDef->rects.end()) {
			Texture2D* texture = SharedTextureCache.load(clipDef->textureFile);
			return {texture, *it->second};
		} else {
			Error("no clip named \"{}\" in {}", nameStr, tokens.front().toString());
			Texture2D* tex = SharedTextureCache.load(clipDef->textureFile);
			Rect rect(0.0f, 0.0f, s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight()));
			return {};
		}
	} else if (Path::getExt(clipStr.toString()) == "clip"_slice) {
		Texture2D* tex = nullptr;
		ClipDef* clipDef = SharedClipCache.load(clipStr);
		if (clipDef) tex = SharedTextureCache.load(clipDef->textureFile);
		if (tex) {
			Rect rect(0.0f, 0.0f, s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight()));
			return {tex, rect};
		}
		Error("failed to get clip from clipStr \"{}\".", clipStr.toString());
		return {};
	} else {
		Texture2D* tex = SharedTextureCache.load(clipStr);
		if (tex) {
			Rect rect(0.0f, 0.0f, s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight()));
			return {tex, rect};
		}
		Error("failed to get texture from clipStr \"{}\".", clipStr.toString());
		return {};
	}
}

Sprite* ClipCache::loadSprite(String clipStr) {
	Texture2D* tex = nullptr;
	Rect rect;
	std::tie(tex, rect) = loadTexture(clipStr);
	if (tex) {
		return Sprite::create(tex, rect);
	}
	return nullptr;
}

bool ClipCache::isFileExist(String clipStr) const {
	auto tokens = clipStr.split("|");
	return SharedContent.exist(tokens.front());
}

bool ClipCache::isClip(String clipStr) const {
	if (clipStr.toString().find('|') != std::string::npos) {
		auto tokens = clipStr.split("|");
		return tokens.size() == 2 && Path::getExt(tokens.front().toString()) == "clip"_slice;
	} else if (Path::getExt(clipStr.toString()) == "clip"_slice) {
		return true;
	}
	return false;
}

std::shared_ptr<XmlParser<ClipDef>> ClipCache::prepareParser(String filename) {
	return std::shared_ptr<XmlParser<ClipDef>>(new Parser(ClipDef::create(), Path::getPath(filename.toString())));
}

void ClipCache::Parser::xmlSAX2Text(std::string_view text) { }

void ClipCache::Parser::xmlSAX2StartElement(std::string_view name, const std::vector<std::string_view>& attrs) {
	switch (Xml::Clip::Element(name[0])) {
		case Xml::Clip::Element::Dorothy: {
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Clip::Dorothy(attrs[i][0])) {
					case Xml::Clip::Dorothy::File:
						_item->textureFile = Path::concat({_path, attrs[++i]});
						break;
				}
			}
			break;
		}
		case Xml::Clip::Element::Clip: {
			Slice name;
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Clip::Clip(attrs[i][0])) {
					case Xml::Clip::Clip::Name: {
						name = attrs[++i];
						break;
					}
					case Xml::Clip::Clip::Rect: {
						Slice attr(attrs[++i]);
						auto tokens = attr.split(",");
						AssertUnless(tokens.size() == 4, "invalid clip rect str for: \"{}\"", attr.toString());
						auto it = tokens.begin();
						float x = it->toFloat();
						float y = (++it)->toFloat();
						float w = (++it)->toFloat();
						float h = (++it)->toFloat();
						_item->rects[name.toString()] = New<Rect>(x, y, w, h);
						break;
					}
				}
			}
			break;
		}
	}
}

void ClipCache::Parser::xmlSAX2EndElement(std::string_view name) { }

NS_DORA_END

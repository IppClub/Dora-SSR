/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Animation/ModelDef.h"

#include "Animation/Animation.h"
#include "Cache/ClipCache.h"
#include "Cache/TextureCache.h"
#include "Const/XmlTag.h"
#include "Node/Model.h"
#include "Node/Sprite.h"

NS_DORA_BEGIN

inline std::string s2(float var) {
	return Slice(fmt::format("{:.2f}", var)).trimZero().toString();
}

inline std::string s3(float var) {
	return Slice(fmt::format("{:.3f}", var)).trimZero().toString();
}

inline std::string s4(float var) {
	return Slice(fmt::format("{:.4f}", var)).trimZero().toString();
}

/* SpriteDef */

Sprite* SpriteDef::toSprite(ClipDef* clipDef) {
	Sprite* sprite = clipDef->toSprite(clip);
	if (!sprite) sprite = Sprite::create();
	sprite->setAnchor(Vec2{anchorX, anchorY});
	SpriteDef::restore(sprite);
	return sprite;
}

void SpriteDef::restore(Sprite* sprite) {
	sprite->setPosition(Vec2{x, y});
	sprite->setScaleX(scaleX);
	sprite->setScaleY(scaleY);
	sprite->setAngle(rotation);
	sprite->setSkewX(skewX);
	sprite->setSkewY(skewY);
	sprite->setOpacity(opacity);
}

SpriteDef::SpriteDef()
	: emittingEvent(false)
	, front(true)
	, x(0.0f)
	, y(0.0f)
	, rotation(0.0f)
	, anchorX(0.5f)
	, anchorY(0.5f)
	, scaleX(1.0f)
	, scaleY(1.0f)
	, skewX(0.0f)
	, skewY(0.0f)
	, opacity(1.0f) { }

std::string SpriteDef::toXml() {
	fmt::memory_buffer out;
	fmt::format_to(std::back_inserter(out), "<{}"sv, char(Xml::Model::Element::Sprite));
	if (x != 0.0f || y != 0.0f) {
		fmt::format_to(std::back_inserter(out), " {}=\"{},{}\""sv, char(Xml::Model::Sprite::Position), s2(x), s2(y));
	}
	if (rotation != 0.0f) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::Sprite::Rotation), s2(rotation));
	}
	if (anchorX != 0.5f || anchorY != 0.5f) {
		fmt::format_to(std::back_inserter(out), " {}=\"{},{}\""sv, char(Xml::Model::Sprite::Key), s4(anchorX), s4(anchorY));
	}
	if (scaleX != 1.0f || scaleY != 1.0f) {
		fmt::format_to(std::back_inserter(out), " {}=\"{},{}\""sv, char(Xml::Model::Sprite::Scale), s3(scaleX), s3(scaleY));
	}
	if (skewX != 0.0f || skewY != 0.0f) {
		fmt::format_to(std::back_inserter(out), " {}=\"{},{}\""sv, char(Xml::Model::Sprite::Skew), s3(skewX), s3(skewY));
	}
	if (!name.empty()) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::Sprite::Name), name);
	}
	if (!clip.empty()) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::Sprite::Clip), clip);
	}
	if (!front) {
		fmt::format_to(std::back_inserter(out), " {}=\"0\""sv, char(Xml::Model::Sprite::Front));
	}
	fmt::format_to(std::back_inserter(out), ">"sv);
	for (const auto& actionDef : animationDefs) {
		if (actionDef) {
			fmt::format_to(std::back_inserter(out), "{}"sv, actionDef->toXml());
		} else {
			fmt::format_to(std::back_inserter(out), "<{}/>"sv, char(Xml::Model::Element::KeyAnimation));
		}
	}
	if (!looks.empty()) {
		fmt::format_to(std::back_inserter(out), "<{} {}=\""sv, char(Xml::Model::Element::Look), char(Xml::Model::Look::Name));
		int lookSize = s_cast<int>(looks.size());
		int last = lookSize - 1;
		for (int i = 0; i < lookSize; i++) {
			fmt::format_to(std::back_inserter(out), "{}"sv, looks[i]);
			if (i != last) {
				fmt::format_to(std::back_inserter(out), ","sv);
			}
		}
		fmt::format_to(std::back_inserter(out), "\"/>"sv);
	}
	for (const auto& spriteDef : children) {
		fmt::format_to(std::back_inserter(out), "{}"sv, spriteDef->toXml());
	}
	fmt::format_to(std::back_inserter(out), "</{}>"sv, char(Xml::Model::Element::Sprite));
	return fmt::to_string(out);
}

std::tuple<Action*, ResetAction*> SpriteDef::toResetAction() {
	Own<ActionDuration> resetAction = ResetAction::alloc(1.0f, this, Ease::InOutQuad);
	ResetAction* action = s_cast<ResetAction*>(resetAction.get());
	return std::make_tuple(Action::create(std::move(resetAction)), action);
}

void SpriteDef::restoreResetAnimation(Node* target, ActionDuration* action) {
	ResetAction* resetAction = DoraAs<ResetAction>(action);
	if (resetAction) {
		resetAction->prepareWith(target);
		resetAction->updateEndValues(this);
	}
}

/* ModelDef */

ModelDef::ModelDef()
	: _size{} { }

ModelDef::ModelDef(
	const Size& size,
	String clipFile,
	Own<SpriteDef>&& root,
	const StringMap<Vec2>& keys,
	const StringMap<int>& animationIndex,
	const StringMap<int>& lookIndex)
	: _clip(clipFile)
	, _size(size)
	, _keys(keys)
	, _animationIndex(animationIndex)
	, _lookIndex(lookIndex)
	, _root(std::move(root)) { }

const std::string& ModelDef::getClipFile() const {
	return _clip;
}

void ModelDef::setRoot(Own<SpriteDef>&& root) {
	_root = std::move(root);
}

SpriteDef* ModelDef::getRoot() {
	return _root.get();
}

std::string ModelDef::toXml() {
	fmt::memory_buffer out;
	fmt::format_to(std::back_inserter(out), "<{} {}=\"{}\" "sv, char(Xml::Model::Element::Dorothy), char(Xml::Model::Dorothy::File), Path::getFilename(_clip));
	if (_size != Size::zero) {
		fmt::format_to(std::back_inserter(out), "{}=\"{:d},{:d}\""sv, char(Xml::Model::Dorothy::Size), s_cast<int>(_size.width), s_cast<int>(_size.height));
	}
	fmt::format_to(std::back_inserter(out), ">{}"sv, _root->toXml());
	for (const auto& item : _animationIndex) {
		fmt::format_to(std::back_inserter(out), "<{} {}=\"{}\" {}=\"{}\"/>"sv, char(Xml::Model::Element::AnimationName), char(Xml::Model::AnimationName::Index), item.second, char(Xml::Model::AnimationName::Name), item.first);
	}
	for (const auto& item : _lookIndex) {
		fmt::format_to(std::back_inserter(out), "<{} {}=\"{}\" {}=\"{}\"/>"sv, char(Xml::Model::Element::LookName), char(Xml::Model::LookName::Index), item.second, char(Xml::Model::LookName::Name), item.first);
	}
	for (const auto& it : _keys) {
		const Vec2& point = it.second;
		fmt::format_to(std::back_inserter(out), "<{} {}=\"{}\" {}=\"{},{}\"/>"sv,
			char(Xml::Model::Element::KeyPoint), char(Xml::Model::KeyPoint::Key), it.first,
			char(Xml::Model::KeyPoint::Position), s2(point.x), s2(point.y));
	}
	fmt::format_to(std::back_inserter(out), "</{}>"sv, char(Xml::Model::Element::Dorothy));
	return fmt::to_string(out);
}

int ModelDef::getAnimationIndexByName(String name) {
	auto it = _animationIndex.find(name);
	if (it != _animationIndex.end()) {
		return it->second;
	}
	return Animation::None;
}

const std::string& ModelDef::getAnimationNameByIndex(int index) {
	for (const auto& item : _animationIndex) {
		if (item.second == index) {
			return item.first;
		}
	}
	return Slice::Empty;
}

int ModelDef::getLookIndexByName(String name) {
	auto it = _lookIndex.find(name);
	if (it != _lookIndex.end()) {
		return it->second;
	}
	return Look::None;
}

const StringMap<int>& ModelDef::getAnimationIndexMap() const {
	return _animationIndex;
}

const StringMap<int>& ModelDef::getLookIndexMap() const {
	return _lookIndex;
}

void ModelDef::setActionName(int index, String name) {
	_animationIndex[name.toString()] = index;
}

void ModelDef::setLookName(int index, String name) {
	_lookIndex[name.toString()] = index;
}

void ModelDef::addKeyPoint(String key, const Vec2& point) {
	ModelDef::getKeyPoints()[key.toString()] = point;
}

Vec2 ModelDef::getKeyPoint(String key) const {
	auto it = _keys.find(key);
	return it != _keys.end() ? it->second : Vec2::zero;
}

StringMap<Vec2>& ModelDef::getKeyPoints() {
	return _keys;
}

const Size& ModelDef::getSize() const {
	return _size;
}

std::vector<std::string> ModelDef::getLookNames() const {
	std::vector<std::string> names(_lookIndex.size());
	for (const auto& it : _lookIndex) {
		names[it.second] = it.first;
	}
	return names;
}

std::vector<std::string> ModelDef::getAnimationNames() const {
	std::vector<std::string> names(_animationIndex.size());
	for (const auto& it : _animationIndex) {
		names[it.second] = it.first;
	}
	return names;
}

NS_DORA_END

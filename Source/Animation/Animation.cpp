/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Animation/Animation.h"

#include "Animation/ModelDef.h"
#include "Cache/FrameCache.h"
#include "Const/XmlTag.h"
#include "Node/Node.h"

NS_DORA_BEGIN

inline std::string s(float var) {
	return Slice(fmt::format("{:.2f}", var)).trimZero().toString();
}

/* KeyFrameDef */

KeyFrameDef::KeyFrameDef()
	: easePos(Ease::Linear)
	, easeScale(Ease::Linear)
	, easeRotation(Ease::Linear)
	, easeSkew(Ease::Linear)
	, easeOpacity(Ease::Linear)
	, visible(true)
	, opacity(1.0f)
	, duration(0.0f)
	, x(0.0f)
	, y(0.0f)
	, scaleX(1.0f)
	, scaleY(1.0f)
	, rotation(0.0f)
	, skewX(0.0f)
	, skewY(0.0f) { }

std::string KeyFrameDef::toXml(KeyFrameDef* lastDef) {
	fmt::memory_buffer out;
	fmt::format_to(std::back_inserter(out), "<{}"sv, char(Xml::Model::Element::KeyFrame));
	if ((lastDef && lastDef->duration != duration) || (!lastDef && duration != 0.0f)) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::Duration), s_cast<int>(duration * 60.0f + 0.5f));
	}
	if ((lastDef && lastDef->visible != visible) || (!lastDef && !visible)) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::Visible), (visible ? "1" : "0"));
	}
	if ((lastDef && (lastDef->x != x || lastDef->y != y)) || (!lastDef && (x != 0.0f || y != 0.0f))) {
		fmt::format_to(std::back_inserter(out), " {}=\"{},{}\""sv, char(Xml::Model::KeyFrame::Position), s(x), s(y));
	}
	if ((lastDef && lastDef->rotation != rotation) || (!lastDef && rotation != 0.0f)) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::Rotation), s(rotation));
	}
	if ((lastDef && (lastDef->scaleX != scaleX || lastDef->scaleY != scaleY)) || (!lastDef && (scaleX != 1.0f || scaleY != 1.0f))) {
		fmt::format_to(std::back_inserter(out), " {}=\"{},{}\""sv, char(Xml::Model::KeyFrame::Scale), s(scaleX), s(scaleY));
	}
	if ((lastDef && lastDef->opacity != opacity) || (!lastDef && opacity != 1.0f)) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::Opacity), s(opacity));
	}
	if ((lastDef && (lastDef->skewX != skewX || lastDef->skewY != skewY)) || (!lastDef && (skewX != 0.0f || skewY != 0.0f))) {
		fmt::format_to(std::back_inserter(out), " {}=\"{},{}\""sv, char(Xml::Model::KeyFrame::Skew), s(skewX), s(skewY));
	}
	if (easePos != Ease::Linear) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::EasePos), s_cast<int>(easePos));
	}
	if (easeScale != Ease::Linear) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::EaseScale), s_cast<int>(easeScale));
	}
	if (easeRotation != Ease::Linear) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::EaseRotate), s_cast<int>(easeRotation));
	}
	if (easeSkew != Ease::Linear) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::EaseSkew), s_cast<int>(easeSkew));
	}
	if (easeOpacity != Ease::Linear) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::KeyFrame::EaseOpacity), s_cast<int>(easeOpacity));
	}
	fmt::format_to(std::back_inserter(out), "/>"sv);
	return fmt::to_string(out);
}

/* KeyReset */

float KeyReset::getDuration() const {
	return 0.0f;
}

bool KeyReset::update(Node* target, float elapsed) {
	if (_ended && elapsed > 0.0f) return true;
	target->setPosition(Vec2{_x, _y});
	target->setScaleX(_scaleX);
	target->setScaleY(_scaleY);
	target->setSkewX(_skewX);
	target->setSkewY(_skewY);
	target->setAngle(_rotation);
	if (!_visible) target->setVisible(false);
	target->setOpacity(_opacity);
	_ended = elapsed > 0.0f;
	return true;
}

Own<ActionDuration> KeyReset::alloc(KeyFrameDef* def) {
	KeyReset* action = new KeyReset();
	action->_ended = false;
	action->_visible = def->visible;
	action->_opacity = def->opacity;
	action->_x = def->x;
	action->_y = def->y;
	action->_scaleX = def->scaleX;
	action->_scaleY = def->scaleY;
	action->_rotation = def->rotation;
	action->_skewX = def->skewX;
	action->_skewY = def->skewY;
	return Own<ActionDuration>(action);
}

Action* KeyReset::create(KeyFrameDef* def) {
	return Action::create(KeyReset::alloc(def));
}

/* ResetAction */

float ResetAction::getDuration() const {
	return _duration;
}

void ResetAction::prepareWith(Node* target) {
	float xEnd = _xStart + _xDelta;
	float yEnd = _yStart + _yDelta;
	float scaleXEnd = _scaleXStart + _scaleXDelta;
	float scaleYEnd = _scaleYStart + _scaleYDelta;
	float skewXEnd = _skewXStart + _skewXDelta;
	float skewYEnd = _skewYStart + _skewYDelta;
	float rotationEnd = _rotationStart + _rotationDelta;
	float opacityEnd = _opacityStart + _opacityDelta;
	_xStart = target->getX();
	_xDelta = xEnd - _xStart;
	_yStart = target->getY();
	_yDelta = yEnd - _yStart;
	_scaleXStart = target->getScaleX();
	_scaleXDelta = scaleXEnd - _scaleXStart;
	_scaleYStart = target->getScaleY();
	_scaleYDelta = scaleYEnd - _scaleYStart;
	_skewXStart = target->getSkewX();
	_skewXDelta = skewXEnd - _skewXStart;
	_skewYStart = target->getSkewY();
	_skewYDelta = skewYEnd - _skewYStart;
	_rotationStart = target->getAngle();
	_rotationStart = std::fmod(_rotationStart, _rotationStart > 0.0f ? 360.0f : -360.0f);
	_rotationDelta = rotationEnd - _rotationStart;
	if (_rotationDelta > 180) {
		_rotationDelta -= 360;
	}
	if (_rotationDelta < -180) {
		_rotationDelta += 360;
	}
	_opacityStart = target->getOpacity();
	_opacityDelta = opacityEnd - _opacityStart;
}

void ResetAction::updateEndValues(KeyFrameDef* def) {
	_xDelta = def->x - _xStart;
	_yDelta = def->y - _yStart;
	_scaleXDelta = def->scaleX - _scaleXStart;
	_scaleYDelta = def->scaleY - _scaleYStart;
	_skewXDelta = def->skewX - _skewXStart;
	_skewYDelta = def->skewY - _skewYStart;
	_rotationDelta = def->rotation - _rotationStart;
	if (_rotationDelta > 180) {
		_rotationDelta -= 360;
	}
	if (_rotationDelta < -180) {
		_rotationDelta += 360;
	}
	_opacityDelta = def->opacity - _opacityStart;
}

void ResetAction::updateEndValues(SpriteDef* def) {
	_xDelta = def->x - _xStart;
	_yDelta = def->y - _yStart;
	_scaleXDelta = def->scaleX - _scaleXStart;
	_scaleYDelta = def->scaleY - _scaleYStart;
	_skewXDelta = def->skewX - _skewXStart;
	_skewYDelta = def->skewY - _skewYStart;
	_rotationDelta = def->rotation - _rotationStart;
	if (_rotationDelta > 180) {
		_rotationDelta -= 360;
	}
	if (_rotationDelta < -180) {
		_rotationDelta += 360;
	}
	_opacityDelta = def->opacity - _opacityStart;
}

bool ResetAction::update(Node* target, float elapsed) {
	if (_ended && elapsed > _duration) return true;
	float time = std::max(std::min(elapsed / _duration, 1.0f), 0.0f);
	_ended = time == 1.0f;
	time = _ended ? 1.0f : _ease(time);
	target->setX(_xStart + _xDelta * time);
	target->setY(_yStart + _yDelta * time);
	target->setScaleX(_scaleXStart + _scaleXDelta * time);
	target->setScaleY(_scaleYStart + _scaleYDelta * time);
	target->setSkewX(_skewXStart + _skewXDelta * time);
	target->setSkewY(_skewYStart + _skewYDelta * time);
	target->setAngle(_rotationStart + _rotationDelta * time);
	target->setOpacity(_opacityStart + _opacityDelta * time);
	return _ended;
}

Own<ActionDuration> ResetAction::alloc(float duration, SpriteDef* def, Ease::Enum easing) {
	ResetAction* action = new ResetAction();
	action->_duration = duration;
	action->_opacityStart = def->opacity;
	action->_opacityDelta = 0.0f;
	action->_xStart = def->x;
	action->_xDelta = 0.0f;
	action->_yStart = def->y;
	action->_yDelta = 0.0f;
	action->_scaleXStart = def->scaleX;
	action->_scaleXDelta = 0.0f;
	action->_scaleYStart = def->scaleY;
	action->_scaleYDelta = 0.0f;
	action->_rotationStart = def->rotation;
	action->_rotationDelta = 0.0f;
	if (action->_rotationDelta > 180) {
		action->_rotationDelta -= 360;
	}
	if (action->_rotationDelta < -180) {
		action->_rotationDelta += 360;
	}
	action->_skewXStart = def->skewX;
	action->_skewXDelta = 0.0f;
	action->_skewYStart = def->skewY;
	action->_skewYDelta = 0.0f;
	action->_ease = Ease::getFunc(easing);
	return Own<ActionDuration>(action);
}

Action* ResetAction::create(float duration, SpriteDef* def, Ease::Enum easing) {
	return Action::create(ResetAction::alloc(duration, def, easing));
}

/* KeyAnimationDef */

KeyFrameDef* KeyAnimationDef::getLastFrameDef() const {
	if (!_keyFrameDefs.empty()) {
		return _keyFrameDefs.back().get();
	}
	return nullptr;
}

void KeyAnimationDef::add(Own<KeyFrameDef>&& def) {
	_keyFrameDefs.push_back(std::move(def));
}

const OwnVector<KeyFrameDef>& KeyAnimationDef::getFrames() const {
	return _keyFrameDefs;
}

Action* KeyAnimationDef::toAction() {
	if (_keyFrameDefs.empty()) {
		return nullptr;
	}

	std::vector<Own<ActionDuration>> keyFrames;
	keyFrames.reserve(_keyFrameDefs.size());
	std::vector<Own<ActionDuration>> keyAttrs;
	const int MaxKeyAttributes = 10;
	keyAttrs.reserve(MaxKeyAttributes);

	KeyFrameDef* lastDef = _keyFrameDefs.front().get();
	keyFrames.push_back(KeyReset::alloc(lastDef));
	for (size_t i = 1; i < _keyFrameDefs.size(); i++) {
		/* Get current keyFrameDef */
		KeyFrameDef* def = _keyFrameDefs[i].get();
		/* Check for animated attributes of keyFrame */
		if (lastDef->x != def->x) {
			keyAttrs.push_back(PropertyAction::alloc(def->duration, lastDef->x, def->x, Property::X, def->easePos));
		}
		if (lastDef->y != def->y) {
			keyAttrs.push_back(PropertyAction::alloc(def->duration, lastDef->y, def->y, Property::Y, def->easePos));
		}
		if (lastDef->scaleX != def->scaleX) {
			keyAttrs.push_back(PropertyAction::alloc(def->duration, lastDef->scaleX, def->scaleX, Property::ScaleX, def->easeScale));
		}
		if (lastDef->scaleY != def->scaleY) {
			keyAttrs.push_back(PropertyAction::alloc(def->duration, lastDef->scaleY, def->scaleY, Property::ScaleY, def->easeScale));
		}
		if (lastDef->skewX != def->skewX) {
			keyAttrs.push_back(PropertyAction::alloc(def->duration, lastDef->skewX, def->skewX, Property::SkewX, def->easeSkew));
		}
		if (lastDef->skewY != def->skewY) {
			keyAttrs.push_back(PropertyAction::alloc(def->duration, lastDef->skewY, def->skewY, Property::SkewY, def->easeSkew));
		}
		if (lastDef->rotation != def->rotation) {
			keyAttrs.push_back(PropertyAction::alloc(def->duration, lastDef->rotation, def->rotation, Property::Angle, def->easeRotation));
		}
		if (lastDef->opacity != def->opacity) {
			keyAttrs.push_back(PropertyAction::alloc(def->duration, lastDef->opacity, def->opacity, Property::Opacity, def->easeOpacity));
		}
		if (lastDef->visible != def->visible) {
			keyAttrs.push_back(Sequence::alloc(Delay::alloc(def->duration), def->visible ? Show::alloc() : Hide::alloc()));
		}
		if (def->event) {
			keyAttrs.push_back(Emit::alloc("ModelEvent"_slice, def->event.value()));
		}
		/* Add a new keyFrame */
		if (keyAttrs.size() > 1) // Multiple attributes animated
		{
			keyFrames.push_back(Spawn::alloc(keyAttrs));
		} else if (keyAttrs.size() == 1) // Single attribute animated
		{
			keyFrames.push_back(std::move(keyAttrs[0]));
		} else // No attribute animated
		{
			keyFrames.push_back(Delay::alloc(def->duration));
		}
		keyAttrs.clear();
		lastDef = def;
	}
	return Sequence::create(std::move(keyFrames));
}

std::string KeyAnimationDef::toXml() {
	fmt::memory_buffer out;
	fmt::format_to(std::back_inserter(out), "<{}"sv, char(Xml::Model::Element::KeyAnimation));
	if (_keyFrameDefs.empty()) {
		fmt::format_to(std::back_inserter(out), "/>"sv);
	} else {
		fmt::format_to(std::back_inserter(out), ">"sv);
		KeyFrameDef* lastDef = nullptr;
		for (const auto& keyFrameDef : _keyFrameDefs) {
			fmt::format_to(std::back_inserter(out), "{}"sv, keyFrameDef->toXml(lastDef));
			lastDef = keyFrameDef.get();
		}
		fmt::format_to(std::back_inserter(out), "</{}>"sv, char(Xml::Model::Element::KeyAnimation));
	}
	return fmt::to_string(out);
}

void KeyAnimationDef::restoreResetAnimation(Node* target, ActionDuration* action) {
	ResetAction* resetAction = DoraAs<ResetAction>(action);
	if (resetAction) {
		target->setVisible(_keyFrameDefs[0]->visible);
		resetAction->prepareWith(target);
		resetAction->updateEndValues(_keyFrameDefs[0].get());
	}
}

/* FrameAnimationDef */

Action* FrameAnimationDef::toAction() {
	return Sequence::create(
		Delay::alloc(delay),
		FrameAction::alloc(_def));
}

void FrameAnimationDef::setFile(String filename) {
	_file = filename.toString();
	_def = SharedFrameCache.loadFrame(filename);
}

const std::string& FrameAnimationDef::getFile() const noexcept {
	return _file;
}

std::string FrameAnimationDef::toXml() {
	fmt::memory_buffer out;
	fmt::format_to(std::back_inserter(out), "<{} {}=\"{}\""sv, char(Xml::Model::Element::FrameAnimation), char(Xml::Model::FrameAnimation::File), _file);
	if (delay != 0.0f) {
		fmt::format_to(std::back_inserter(out), " {}=\"{}\""sv, char(Xml::Model::FrameAnimation::Delay), delay);
	}
	fmt::format_to(std::back_inserter(out), "/>"sv);
	return fmt::to_string(out);
}

NS_DORA_END

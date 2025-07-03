/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Animation/Action.h"

#include "Audio/Audio.h"
#include "Cache/ClipCache.h"
#include "Cache/FrameCache.h"
#include "Node/Node.h"
#include "Node/Sprite.h"

NS_DORA_BEGIN

static void SetX(Node* target, float value) { target->setX(value); }
static void SetY(Node* target, float value) { target->setY(value); }
static void SetZ(Node* target, float value) { target->setZ(value); }
static void SetAngle(Node* target, float value) { target->setAngle(value); }
static void SetAngleX(Node* target, float value) { target->setAngleX(value); }
static void SetAngleY(Node* target, float value) { target->setAngleY(value); }
static void SetScaleX(Node* target, float value) { target->setScaleX(value); }
static void SetScaleY(Node* target, float value) { target->setScaleY(value); }
static void SetSkewX(Node* target, float value) { target->setSkewX(value); }
static void SetSkewY(Node* target, float value) { target->setSkewY(value); }
static void SetWidth(Node* target, float value) { target->setWidth(value); }
static void SetHeight(Node* target, float value) { target->setHeight(value); }
static void SetAnchorX(Node* target, float value) { target->setAnchor(Vec2{value, target->getAnchor().y}); }
static void SetAnchorY(Node* target, float value) { target->setAnchor(Vec2{target->getAnchor().x, value}); }
static void SetOpacity(Node* target, float value) { target->setOpacity(value); }

static SetFunc setFuncs[] = {
	SetX,
	SetY,
	SetZ,
	SetAngle,
	SetAngleX,
	SetAngleY,
	SetScaleX,
	SetScaleY,
	SetSkewX,
	SetSkewY,
	SetWidth,
	SetHeight,
	SetAnchorX,
	SetAnchorY,
	SetOpacity};

SetFunc Property::getFunc(Property::Enum prop) {
	return setFuncs[prop];
}

static bx::EaseFn easeFuncs[] = {
	bx::easeLinear,
	bx::easeInQuad,
	bx::easeOutQuad,
	bx::easeInOutQuad,
	bx::easeInCubic,
	bx::easeOutCubic,
	bx::easeInOutCubic,
	bx::easeInQuart,
	bx::easeOutQuart,
	bx::easeInOutQuart,
	bx::easeInQuint,
	bx::easeOutQuint,
	bx::easeInOutQuint,
	bx::easeInSine,
	bx::easeOutSine,
	bx::easeInOutSine,
	bx::easeInExpo,
	bx::easeOutExpo,
	bx::easeInOutExpo,
	bx::easeInCirc,
	bx::easeOutCirc,
	bx::easeInOutCirc,
	bx::easeInElastic,
	bx::easeOutElastic,
	bx::easeInOutElastic,
	bx::easeInBack,
	bx::easeOutBack,
	bx::easeInOutBack,
	bx::easeInBounce,
	bx::easeOutBounce,
	bx::easeInOutBounce,
	bx::easeOutInQuad,
	bx::easeOutInCubic,
	bx::easeOutInQuart,
	bx::easeOutInQuint,
	bx::easeOutInSine,
	bx::easeOutInExpo,
	bx::easeOutInCirc,
	bx::easeOutInElastic,
	bx::easeOutInBack,
	bx::easeOutInBounce};

bx::EaseFn Ease::getFunc(Ease::Enum easing) {
	return easeFuncs[easing];
}

float Ease::func(Ease::Enum easing, float time) {
	return easeFuncs[easing](time);
}

/* ActionProperty */

Own<ActionDuration> PropertyAction::alloc(float duration, float start, float stop, Property::Enum prop, Ease::Enum easing) {
	PropertyAction* action = new PropertyAction();
	action->_start = start;
	action->_delta = stop - start;
	action->_duration = std::max(FLT_EPSILON, duration);
	action->_setFunc = Property::getFunc(prop);
	action->_ease = Ease::getFunc(easing);
	action->_ended = false;
	return Own<ActionDuration>(action);
}

Action* PropertyAction::create(float duration, float start, float stop, Property::Enum prop, Ease::Enum easing) {
	return Action::create(PropertyAction::alloc(duration, start, stop, prop, easing));
}

float PropertyAction::getDuration() const {
	return _duration;
}

bool PropertyAction::update(Node* target, float elapsed) {
	if (_ended && elapsed > _duration) return true;
	float time = std::max(std::min(elapsed / _duration, 1.0f), 0.0f);
	_ended = time == 1.0f;
	_setFunc(target, _start + _delta * (_ended ? 1.0f : _ease(time)));
	return _ended;
}

/* Tint */

Own<ActionDuration> Tint::alloc(float duration, Color3 start, Color3 stop, Ease::Enum easing) {
	Tint* action = new Tint();
	auto v1 = start.toVec3();
	auto v2 = stop.toVec3();
	action->_start = v1;
	action->_delta = Vec3{v2.x - v1.x, v2.y - v1.y, v2.z - v1.z};
	action->_duration = std::max(FLT_EPSILON, duration);
	action->_ease = Ease::getFunc(easing);
	action->_ended = false;
	return Own<ActionDuration>(action);
}

Action* Tint::create(float duration, Color3 start, Color3 stop, Ease::Enum easing) {
	return Action::create(Tint::alloc(duration, start, stop, easing));
}

float Tint::getDuration() const {
	return _duration;
}

bool Tint::update(Node* target, float elapsed) {
	if (_ended && elapsed > _duration) return true;
	float time = std::max(std::min(elapsed / _duration, 1.0f), 0.0f);
	_ended = time == 1.0f;
	float change = _ended ? 1.0f : _ease(time);
	target->setColor3(Color3(Vec3{_start.x + _delta.x * change, _start.y + _delta.y * change, _start.z + _delta.z * change}));
	return _ended;
}

/* Roll */

Own<ActionDuration> Roll::alloc(float duration, float start, float stop, Ease::Enum easing) {
	Roll* action = new Roll();
	if (start > 0)
		start = std::fmod(start, 360.0f);
	else
		start = std::fmod(start, -360.0f);
	float delta = stop - start;
	if (delta > 180)
		delta -= 360;
	else if (delta < -180)
		delta += 360;
	action->_start = start;
	action->_delta = delta;
	action->_duration = std::max(FLT_EPSILON, duration);
	action->_ease = Ease::getFunc(easing);
	action->_ended = false;
	return Own<ActionDuration>(action);
}

Action* Roll::create(float duration, float start, float stop, Ease::Enum easing) {
	return Action::create(Roll::alloc(duration, start, stop, easing));
}

float Roll::getDuration() const {
	return _duration;
}

bool Roll::update(Node* target, float elapsed) {
	if (_ended && elapsed > _duration) return true;
	float time = std::max(std::min(elapsed / _duration, 1.0f), 0.0f);
	_ended = time == 1.0f;
	target->setAngle(_start + _delta * (_ended ? 1.0f : _ease(time)));
	return _ended;
}

/* Spawn */

float Spawn::getDuration() const {
	return _duration;
}

bool Spawn::update(Node* target, float elapsed) {
	if (_ended && elapsed > _duration) return true;
	bool resultA = !_first || _first->update(target, elapsed);
	bool resultB = !_second || _second->update(target, elapsed);
	_ended = resultA && resultB;
	return _ended;
}

Own<ActionDuration> Spawn::alloc(Own<ActionDuration>&& first, Own<ActionDuration>&& second) {
	Spawn* action = new Spawn();
	float durationA = first ? first->getDuration() : 0.0f;
	float durationB = second ? second->getDuration() : 0.0f;
	action->_duration = std::max(durationA, durationB);
	action->_first = std::move(first);
	action->_second = std::move(second);
	action->_ended = false;
	return Own<ActionDuration>(action);
}

Own<ActionDuration> Spawn::alloc(const std::vector<Own<ActionDuration>>& actions) {
	if (actions.begin() == actions.end()) {
		return Spawn::alloc(Own<ActionDuration>(), Own<ActionDuration>());
	}
	auto it = actions.begin();
	Own<ActionDuration> first = std::move(c_cast<Own<ActionDuration>&>(*it));
	Own<ActionDuration> second;
	++it;
	for (; it != actions.end(); ++it) {
		second = std::move(c_cast<Own<ActionDuration>&>(*it));
		first = Spawn::alloc(std::move(first), std::move(second));
	}
	return first;
}

Own<ActionDuration> Spawn::alloc(std::initializer_list<RRefCapture<Own<ActionDuration>>> actions) {
	if (actions.begin() == actions.end()) {
		return Spawn::alloc(Own<ActionDuration>(), Own<ActionDuration>());
	}
	auto it = actions.begin();
	Own<ActionDuration> first = std::move(*it);
	Own<ActionDuration> second;
	++it;
	for (; it != actions.end(); ++it) {
		second = std::move(*it);
		first = Spawn::alloc(std::move(first), std::move(second));
	}
	return first;
}

Action* Spawn::create(Own<ActionDuration>&& first, Own<ActionDuration>&& second) {
	return Action::create(Spawn::alloc(std::move(first), std::move(second)));
}

Action* Spawn::create(const std::vector<Own<ActionDuration>>& actions) {
	return Action::create(Spawn::alloc(actions));
}

Action* Spawn::create(std::initializer_list<RRefCapture<Own<ActionDuration>>> actions) {
	return Action::create(Spawn::alloc(actions));
}

/* Sequence */

float Sequence::getDuration() const {
	return _duration;
}

bool Sequence::update(Node* target, float elapsed) {
	if (_ended && elapsed > _duration) return true;
	if (_ended && _second && _first && elapsed < _first->getDuration()) {
		_second->update(target, 0.0f);
	}
	if (!_first || _first->update(target, elapsed)) {
		_ended = !_second || _second->update(target, elapsed - _first->getDuration());
		return _ended;
	}
	_ended = false;
	return false;
}

Own<ActionDuration> Sequence::alloc(Own<ActionDuration>&& first, Own<ActionDuration>&& second) {
	Sequence* action = new Sequence();
	float durationA = first ? first->getDuration() : 0.0f;
	float durationB = second ? second->getDuration() : 0.0f;
	action->_duration = durationA + durationB;
	action->_first = std::move(first);
	action->_second = std::move(second);
	action->_ended = false;
	return Own<ActionDuration>(action);
}

Own<ActionDuration> Sequence::alloc(std::vector<Own<ActionDuration>>&& actions) {
	if (actions.begin() == actions.end()) {
		return Sequence::alloc(Own<ActionDuration>(), Own<ActionDuration>());
	}
	auto it = actions.begin();
	Own<ActionDuration> first = std::move(*it);
	Own<ActionDuration> second;
	++it;
	for (; it != actions.end(); ++it) {
		second = std::move(c_cast<Own<ActionDuration>&>(*it));
		first = Sequence::alloc(std::move(first), std::move(second));
	}
	return first;
}

Own<ActionDuration> Sequence::alloc(std::initializer_list<RRefCapture<Own<ActionDuration>>> actions) {
	if (actions.begin() == actions.end()) {
		return Sequence::alloc(Own<ActionDuration>(), Own<ActionDuration>());
	}
	auto it = actions.begin();
	Own<ActionDuration> first = std::move(*it);
	Own<ActionDuration> second;
	++it;
	for (; it != actions.end(); ++it) {
		second = std::move(*it);
		first = Sequence::alloc(std::move(first), std::move(second));
	}
	return first;
}

Action* Sequence::create(Own<ActionDuration>&& first, Own<ActionDuration>&& second) {
	return Action::create(Sequence::alloc(std::move(first), std::move(second)));
}

Action* Sequence::create(std::vector<Own<ActionDuration>>&& actions) {
	return Action::create(Sequence::alloc(std::move(actions)));
}

Action* Sequence::create(std::initializer_list<RRefCapture<Own<ActionDuration>>> actions) {
	return Action::create(Sequence::alloc(actions));
}

/* Delay */

float Delay::getDuration() const {
	return _duration;
}

bool Delay::update(Node* target, float elapsed) {
	DORA_UNUSED_PARAM(target);
	return elapsed >= _duration;
}

Own<ActionDuration> Delay::alloc(float duration) {
	Delay* action = new Delay();
	action->_duration = duration;
	return Own<ActionDuration>(action);
}

Action* Delay::create(float duration) {
	return Action::create(Delay::alloc(duration));
}

/* Show */

float Show::getDuration() const {
	return 0.0f;
}

bool Show::update(Node* target, float elapsed) {
	if (_ended && elapsed > 0.0f) return true;
	target->setVisible(true);
	_ended = elapsed > 0.0f;
	return true;
}

Own<ActionDuration> Show::alloc() {
	Show* show = new Show();
	show->_ended = false;
	return Own<ActionDuration>(show);
}

Action* Show::create() {
	return Action::create(Show::alloc());
}

/* Hide */

float Hide::getDuration() const {
	return 0.0f;
}

bool Hide::update(Node* target, float elapsed) {
	if (_ended && elapsed > 0.0f) return true;
	target->setVisible(false);
	_ended = elapsed > 0.0f;
	return true;
}

Own<ActionDuration> Hide::alloc() {
	Hide* hide = new Hide();
	hide->_ended = false;
	return Own<ActionDuration>(hide);
}

Action* Hide::create() {
	return Action::create(Hide::alloc());
}

/* Emit */

bool Emit::available = true;

float Emit::getDuration() const {
	return 0.0f;
}

bool Emit::update(Node* target, float elapsed) {
	if (_ended && elapsed > 0.0f) return true;
	if (Emit::available) {
		if (_argument.empty()) {
			target->emit(_event, target);
		} else {
			target->emit(_event, target, _argument);
		}
	}
	_ended = elapsed > 0.0f;
	return true;
}

Own<ActionDuration> Emit::alloc(String event, String arg) {
	Emit* emit = new Emit();
	emit->_ended = false;
	emit->_event = event.toString();
	emit->_argument = arg.toString();
	return Own<ActionDuration>(emit);
}

Action* Emit::create(String event, String arg) {
	return Action::create(Emit::alloc(event, arg));
}

/* FrameAction */

float FrameAction::getDuration() const {
	return _def->duration;
}

bool FrameAction::update(Node* target, float elapsed) {
	if (_ended && elapsed > _def->duration) return true;
	Sprite* sprite = DoraAs<Sprite>(target);
	if (sprite && _texture) {
		int frames = s_cast<int>(_def->rects.size());
		float time = std::max(0.0f, elapsed / std::max(_def->duration, FLT_EPSILON));
		int current = s_cast<int>(time * frames + 0.5f);
		if (current < frames) {
			if (sprite->getTexture() != _texture) {
				sprite->setTexture(_texture);
			}
			if (sprite->getTextureRect() != *_def->rects[current]) {
				sprite->setTextureRect(*_def->rects[current]);
			}
		}
	}
	_ended = elapsed > _def->duration;
	return _ended;
}

Own<ActionDuration> FrameAction::alloc(FrameActionDef* def) {
	FrameAction* action = new FrameAction();
	action->_def = def;
	action->_ended = false;
	action->_texture = SharedClipCache.loadTexture(def->clipStr).first;
	return Own<ActionDuration>(action);
}

Action* FrameAction::create(FrameActionDef* def) {
	return Action::create(FrameAction::alloc(def));
}

/* Action */

const int Action::InvalidOrder = -1;

Action::Action(Own<ActionDuration>&& actionDuration)
	: _order(Action::InvalidOrder)
	, _speed(1.0f)
	, _elapsed(0)
	, _target(nullptr)
	, _action(std::move(actionDuration))
	, _reversed(false)
	, _looped(false)
	, _paused(false) { }

void Action::updateTo(float elapsed, bool reversed) {
	float oldElapsed = _elapsed;
	bool oldReversed = _reversed;
	_elapsed = elapsed;
	_reversed = reversed;
	if (_target) {
		updateProgress();
	}
	_elapsed = oldElapsed;
	_reversed = oldReversed;
}

float Action::getDuration() const noexcept {
	return _action->getDuration();
}

float Action::getElapsed() const noexcept {
	return _elapsed;
}

bool Action::isPaused() const noexcept {
	return _paused;
}

bool Action::isRunning() const noexcept {
	return _order != Action::InvalidOrder;
}

void Action::setReversed(bool var) {
	_reversed = var;
}

bool Action::isReversed() const noexcept {
	return _reversed;
}

void Action::setSpeed(float var) {
	_speed = var;
}

float Action::getSpeed() const noexcept {
	return _speed;
}

Own<ActionDuration>& Action::getAction() {
	return _action;
}

void Action::pause() {
	_paused = true;
}

void Action::resume() {
	_paused = false;
}

bool Action::updateProgress() {
	if (!_action) return true;
	if (_elapsed == 0.0f) {
		float start = _reversed ? _action->getDuration() : 0.0f;
		/* reset actions to initial state */
		Emit::available = false; // disable event callbacks while reseting
		_action->update(_target, start);
		Emit::available = true;
		/* execute action right here */
		if (0.0f == _action->getDuration()) {
			_action->update(_target, start);
			return true;
		}
		return false;
	} else if (_elapsed >= _action->getDuration()) {
		float stop = _reversed ? 0.0f : _elapsed;
		_action->update(_target, stop);
		return true;
	} else {
		float current = _reversed ? _action->getDuration() - _elapsed : _elapsed;
		_action->update(_target, current);
		return false;
	}
}

NS_DORA_END

/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Animation/Action.h"
#include "Node/Node.h"
#include "Common/Utils.h"

NS_DOROTHY_BEGIN

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
	SetOpacity
};

SetFunc Property::getFunc(Property::Enum prop)
{
	return setFuncs[prop];
}

static bx::EaseFn easeFuncs[] = {
	bx::easeLinear,
	bx::easeInQuad,
	bx::easeOutQuad,
	bx::easeInOutQuad,
	bx::easeOutInQuad,
	bx::easeInCubic,
	bx::easeOutCubic,
	bx::easeInOutCubic,
	bx::easeOutInCubic,
	bx::easeInQuart,
	bx::easeOutQuart,
	bx::easeInOutQuart,
	bx::easeOutInQuart,
	bx::easeInQuint,
	bx::easeOutQuint,
	bx::easeInOutQuint,
	bx::easeOutInQuint,
	bx::easeInSine,
	bx::easeOutSine,
	bx::easeInOutSine,
	bx::easeOutInSine,
	bx::easeInExpo,
	bx::easeOutExpo,
	bx::easeInOutExpo,
	bx::easeOutInExpo,
	bx::easeInCirc,
	bx::easeOutCirc,
	bx::easeInOutCirc,
	bx::easeOutInCirc,
	bx::easeInElastic,
	bx::easeOutElastic,
	bx::easeInOutElastic,
	bx::easeOutInElastic,
	bx::easeInBack,
	bx::easeOutBack,
	bx::easeInOutBack,
	bx::easeOutInBack,
	bx::easeInBounce,
	bx::easeOutBounce,
	bx::easeInOutBounce,
	bx::easeOutInBounce
};

bx::EaseFn Ease::getFunc(Ease::Enum easing)
{
	return easeFuncs[easing];
}

/* ActionProperty */

Own<ActionDuration> PropertyAction::alloc(float duration, float start, float stop, Property::Enum prop, Ease::Enum easing)
{
	PropertyAction* action = new PropertyAction();
	action->_start = start;
	action->_delta = stop - start;
	action->_duration = std::max(FLT_EPSILON, duration);
	action->_setFunc = Property::getFunc(prop);
	action->_ease = Ease::getFunc(easing);
	action->_ended = false;
	return Own<ActionDuration>(action);
}

Action* PropertyAction::create(float duration, float start, float stop, Property::Enum prop, Ease::Enum easing)
{
	return Action::create(PropertyAction::alloc(duration, start, stop, prop, easing));
}

float PropertyAction::getDuration() const
{
	return _duration;
}

bool PropertyAction::update(Node* target, float eclapsed)
{
	if (_ended && eclapsed > _duration) return true;
	float time = std::max(std::min(eclapsed / _duration, 1.0f), 0.0f);
	_ended = time == 1.0f;
	_setFunc(target, _start + _delta * (_ended ? 1.0f : _ease(time)));
	return _ended;
}

/* Spawn */

float Spawn::getDuration() const
{
	return _duration;
}

bool Spawn::update(Node* target, float eclapsed)
{
	if (_ended && eclapsed > _duration) return true;
	bool resultA = !_first || _first->update(target, eclapsed);
	bool resultB = !_second || _second->update(target, eclapsed);
	_ended = resultA && resultB;
	return _ended;
}

Own<ActionDuration> Spawn::alloc(Own<ActionDuration>&& first, Own<ActionDuration>&& second)
{
	Spawn* action = new Spawn();
	float durationA = first ? first->getDuration() : 0.0f;
	float durationB = second ? second->getDuration() : 0.0f;
	action->_duration = std::max(durationA, durationB);
	action->_first = std::move(first);
	action->_second = std::move(second);
	action->_ended = false;
	return Own<ActionDuration>(action);
}

Own<ActionDuration> Spawn::alloc(const vector<RRefCapture<Own<ActionDuration>>>& actions)
{
	if (actions.begin() == actions.end())
	{
		return Spawn::alloc(Own<ActionDuration>(), Own<ActionDuration>());
	}
	auto it = actions.begin();
	Own<ActionDuration> first = std::move(*it);
	Own<ActionDuration> second;
	++it;
	for (; it != actions.end(); ++it)
	{
		second = std::move(*it);
		first = Spawn::alloc(std::move(first), std::move(second));
	}
	return first;
}

Action* Spawn::create(Own<ActionDuration>&& first, Own<ActionDuration>&& second)
{
	return Action::create(Spawn::alloc(std::move(first), std::move(second)));
}

Action* Spawn::create(const vector<RRefCapture<Own<ActionDuration>>>& actions)
{
	return Action::create(Spawn::alloc(actions));
}

/* Sequence */

float Sequence::getDuration() const
{
	return _duration;
}

bool Sequence::update(Node* target, float eclapsed)
{
	if (_ended && eclapsed > _duration) return true;
	if (_ended && _second && _first && eclapsed < _first->getDuration())
	{
		_second->update(target, 0.0f);
	}
	if (!_first || _first->update(target, eclapsed))
	{
		_ended = !_second || _second->update(target, eclapsed - _first->getDuration());
		return _ended;
	}
	_ended = false;
	return false;
}

Own<ActionDuration> Sequence::alloc(Own<ActionDuration>&& first, Own<ActionDuration>&& second)
{
	Sequence* action = new Sequence();
	float durationA = first ? first->getDuration() : 0.0f;
	float durationB = second ? second->getDuration() : 0.0f;
	action->_duration = durationA + durationB;
	action->_first = std::move(first);
	action->_second = std::move(second);
	action->_ended = false;
	return Own<ActionDuration>(action);
}

Own<ActionDuration> Sequence::alloc(const vector<RRefCapture<Own<ActionDuration>>>& actions)
{
	if (actions.begin() == actions.end())
	{
		return Sequence::alloc(Own<ActionDuration>(), Own<ActionDuration>());
	}
	auto it = actions.begin();
	Own<ActionDuration> first = std::move(*it);
	Own<ActionDuration> second;
	++it;
	for (; it != actions.end(); ++it)
	{
		second = std::move(*it);
		first = Sequence::alloc(std::move(first), std::move(second));
	}
	return first;
}

Action* Sequence::create(Own<ActionDuration>&& first, Own<ActionDuration>&& second)
{
	return Action::create(Sequence::alloc(std::move(first), std::move(second)));
}

Action* Sequence::create(const vector<RRefCapture<Own<ActionDuration>>>& actions)
{
	return Action::create(Sequence::alloc(actions));
}

/* Delay */

float Delay::getDuration() const
{
	return _duration;
}

bool Delay::update(Node* target, float eclapsed)
{
	DORA_UNUSED_PARAM(target);
	return eclapsed >= _duration;
}

Own<ActionDuration> Delay::alloc(float duration)
{
	Delay* action = new Delay();
	action->_duration = duration;
	return Own<ActionDuration>(action);
}

Action* Delay::create(float duration)
{
	return Action::create(Delay::alloc(duration));
}

/* Show */

float Show::getDuration() const
{
	return 0.0f;
}

bool Show::update(Node* target, float eclapsed)
{
	if (_ended && eclapsed > 0.0f) return true;
	target->setVisible(true);
	_ended = eclapsed > 0.0f;
	return true;
}

Own<ActionDuration> Show::alloc()
{
	Show* show = new Show();
	show->_ended = false;
	return Own<ActionDuration>(show);
}

Action* Show::create()
{
	return Action::create(Show::alloc());
}

/* Hide */

float Hide::getDuration() const
{
	return 0.0f;
}

bool Hide::update(Node* target, float eclapsed)
{
	if (_ended && eclapsed > 0.0f) return true;
	target->setVisible(false);
	_ended = eclapsed > 0.0f;
	return true;
}

Own<ActionDuration> Hide::alloc()
{
	Hide* hide = new Hide();
	hide->_ended = false;
	return Own<ActionDuration>(hide);
}

Action* Hide::create()
{
	return Action::create(Hide::alloc());
}

/* Call */

bool Call::available = true;

float Call::getDuration() const
{
	return 0.0f;
}

bool Call::update(Node* target, float eclapsed)
{
	if (_ended && eclapsed > 0.0f) return true;
	if (Call::available && _callback) _callback();
	_ended = eclapsed > 0.0f;
	return true;
}

Own<ActionDuration> Call::alloc(const function<void()>& callback)
{
	Call* call = new Call();
	call->_ended = false;
	call->_callback = callback;
	return Own<ActionDuration>(call);
}

Action* Call::create(const function<void()>& callback)
{
	return Action::create(Call::alloc(callback));
}

/* Action */

const int Action::InvalidOrder = -1;

Action::Action(Own<ActionDuration>&& actionDuration):
_order(Action::InvalidOrder),
_speed(1.0f),
_eclapsed(0),
_target(nullptr),
_action(std::move(actionDuration)),
_reversed(false)
{ }

float Action::getDuration() const
{
	return _action->getDuration();
}

bool Action::isRunning() const
{
	return _order != Action::InvalidOrder;
}

void Action::setReversed(bool var)
{
	_reversed = var;
}

bool Action::isReversed() const
{
	return _reversed;
}

void Action::setSpeed(float var)
{
	_speed = var;
}

float Action::getSpeed() const
{
	return _speed;
}

bool Action::update()
{
	if (!_reversed)
	{
		return _action->update(_target, _eclapsed);
	}
	else
	{
		if (_eclapsed == 0.0f)
		{
			Call::available = false;
			_action->update(_target, _action->getDuration());
			Call::available = true;
		}
		else
		{
			_action->update(_target, _action->getDuration() - _eclapsed);
		}
		if (_eclapsed >= _action->getDuration())
		{
			_action->update(_target, 0.0f);
			return true;
		}
		return false;
	}
}

NS_DOROTHY_END

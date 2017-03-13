/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "bx/easing.h"
#include "Common/Utils.h"

NS_DOROTHY_BEGIN

class Node;

typedef void (*SetFunc)(Node* target, float value);
struct Property
{
	enum Enum
	{
		X,
		Y,
		Z,
		Angle,
		AngleX,
		AngleY,
		ScaleX,
		ScaleY,
		SkewX,
		SkewY,
		Width,
		Height,
		AnchorX,
		AnchorY,
		Opacity
	};
	static SetFunc getFunc(Property::Enum attr);
};

struct Ease
{
	enum Enum
	{
		Linear,
		InQuad,
		OutQuad,
		InOutQuad,
		OutInQuad,
		InCubic,
		OutCubic,
		InOutCubic,
		OutInCubic,
		InQuart,
		OutQuart,
		InOutQuart,
		OutInQuart,
		InQuint,
		OutQuint,
		InOutQuint,
		OutInQuint,
		InSine,
		OutSine,
		InOutSine,
		OutInSine,
		InExpo,
		OutExpo,
		InOutExpo,
		OutInExpo,
		InCirc,
		OutCirc,
		InOutCirc,
		OutInCirc,
		InElastic,
		OutElastic,
		InOutElastic,
		OutInElastic,
		InBack,
		OutBack,
		InOutBack,
		OutInBack,
		InBounce,
		OutBounce,
		InOutBounce,
		OutInBounce
	};
	static bx::EaseFn getFunc(Ease::Enum easing);
};

class ActionDuration
{
public:
	virtual ~ActionDuration() { }
	virtual float getDuration() const = 0;
	virtual bool update(Node* target, float eclapsed) = 0;
};

class Action;

class PropertyAction : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(float duration, float start, float stop, Property::Enum attr, Ease::Enum easing = Ease::Linear);
	static Action* create(float duration, float start, float stop, Property::Enum attr, Ease::Enum easing = Ease::Linear);
protected:
	PropertyAction() { }
private:
	bool _ended;
	float _start;
	float _delta;
	float _duration;
	bx::EaseFn _ease;
	SetFunc _setFunc;
};

class Spawn : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(Own<ActionDuration>&& first, Own<ActionDuration>&& second);
	static Own<ActionDuration> alloc(const vector<RRefCapture<Own<ActionDuration>>>& actions);
	static Action* create(Own<ActionDuration>&& first, Own<ActionDuration>&& second);
	static Action* create(const vector<RRefCapture<Own<ActionDuration>>>& actions);
protected:
	Spawn() { }
private:
	bool _ended;
	float _duration;
	Own<ActionDuration> _first;
	Own<ActionDuration> _second;
};

class Sequence : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(Own<ActionDuration>&& first, Own<ActionDuration>&& second);
	static Own<ActionDuration> alloc(const vector<RRefCapture<Own<ActionDuration>>>& actions);
	static Action* create(Own<ActionDuration>&& first, Own<ActionDuration>&& second);
	static Action* create(const vector<RRefCapture<Own<ActionDuration>>>& actions);
protected:
	Sequence() { }
private:
	bool _ended;
	float _duration;
	Own<ActionDuration> _first;
	Own<ActionDuration> _second;
};

class Delay : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(float duration);
	static Action* create(float duration);
protected:
	Delay() { }
private:
	float _duration;
};

class Show : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc();
	static Action* create();
protected:
	Show() { }
private:
	bool _ended;
};

class Hide : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc();
	static Action* create();
protected:
	Hide() { }
private:
	bool _ended;
};

class Action : public Object
{
public:
	PROPERTY_READONLY(float, Duration);
	PROPERTY_READONLY_BOOL(Running);
	PROPERTY_BOOL(Reversed);
	PROPERTY(float, Speed);
	virtual bool update();
	CREATE_FUNC(Action);
protected:
	Action(Own<ActionDuration>&& actionDuration);
private:
	Ref<Action> _prev;
	Ref<Action> _next;
	bool _reversed;
	int _order;
	float _speed;
	float _eclapsed;
	Node* _target;
	Own<ActionDuration> _action;
	static const int InvalidOrder;
	friend class Node;
	friend class Scheduler;
};

NS_DOROTHY_END

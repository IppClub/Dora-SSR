/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "bx/easing.h"
#include "Common/Utils.h"
#include "Support/Geometry.h"

NS_DOROTHY_BEGIN

class Node;

typedef void (*SetFunc)(Node* target, float value);
struct Property
{
	enum Enum
	{
		None,
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
	static float func(Ease::Enum easing, float time);
};

class ActionDuration
{
public:
	virtual ~ActionDuration() { }
	virtual float getDuration() const = 0;
	virtual bool update(Node* target, float eclapsed) = 0;
	DORA_TYPE_BASE(ActionDuration);
};

class Action;

class PropertyAction : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(float duration, float start, float stop,
		Property::Enum prop, Ease::Enum easing = Ease::Linear);
	static Action* create(float duration, float start, float stop,
		Property::Enum prop, Ease::Enum easing = Ease::Linear);
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

class Roll : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(float duration, float start, float stop, Ease::Enum easing = Ease::Linear);
	static Action* create(float duration, float start, float stop, Ease::Enum easing = Ease::Linear);
protected:
	Roll() { }
private:
	bool _ended;
	float _start;
	float _delta;
	float _duration;
	bx::EaseFn _ease;
};

class Spawn : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(Own<ActionDuration>&& first, Own<ActionDuration>&& second);
	static Own<ActionDuration> alloc(std::initializer_list<RRefCapture<Own<ActionDuration>>> actions);
	static Own<ActionDuration> alloc(const vector<Own<ActionDuration>>& actions);
	static Action* create(Own<ActionDuration>&& first, Own<ActionDuration>&& second);
	static Action* create(std::initializer_list<RRefCapture<Own<ActionDuration>>> actions);
	static Action* create(const vector<Own<ActionDuration>>& actions);
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
	static Own<ActionDuration> alloc(std::initializer_list<RRefCapture<Own<ActionDuration>>> actions);
	static Own<ActionDuration> alloc(vector<Own<ActionDuration>>&& actions);
	static Action* create(Own<ActionDuration>&& first, Own<ActionDuration>&& second);
	static Action* create(std::initializer_list<RRefCapture<Own<ActionDuration>>> actions);
	static Action* create(vector<Own<ActionDuration>>&& actions);
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

class Call : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(const function<void()>& callback);
	static Action* create(const function<void()>& callback);
	static bool available;
protected:
	Call() { }
private:
	bool _ended;
	function<void()> _callback;
};

class PlaySound : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(String filename);
	static Action* create(String filename);
	static bool available;
protected:
	PlaySound() { }
private:
	bool _ended;
	string _filename;
};

class Texture2D;
class FrameActionDef;

class FrameAction : public ActionDuration
{
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float eclapsed) override;
	static Own<ActionDuration> alloc(FrameActionDef* def);
	static Action* create(FrameActionDef* def);
protected:
	FrameAction() { }
private:
	bool _ended;
	Ref<Texture2D> _texture;
	Ref<FrameActionDef> _def;
};

struct Move
{
	static inline Own<ActionDuration> alloc(float duration, const Vec2& startPos, const Vec2& endPos, Ease::Enum ease)
	{
		return Spawn::alloc(PropertyAction::alloc(duration, startPos.x, endPos.x, Property::X, ease),
			PropertyAction::alloc(duration, startPos.y, endPos.y, Property::Y, ease));
	}
	static inline Action* create(float duration, const Vec2& startPos, const Vec2& endPos, Ease::Enum ease)
	{
		return Spawn::create(PropertyAction::alloc(duration, startPos.x, endPos.x, Property::X, ease),
			PropertyAction::alloc(duration, startPos.y, endPos.y, Property::Y, ease));
	}
};

struct Scale
{
	static inline Own<ActionDuration> alloc(float duration, const Vec2& startScale, const Vec2& endScale, Ease::Enum ease)
	{
		return Spawn::alloc(PropertyAction::alloc(duration, startScale.x, endScale.x, Property::ScaleX, ease),
			PropertyAction::alloc(duration, startScale.y, endScale.y, Property::ScaleY, ease));
	}
	static inline Own<ActionDuration> alloc(float duration, float startScale, float endScale, Ease::Enum ease)
	{
		return Spawn::alloc(PropertyAction::alloc(duration, startScale, endScale, Property::ScaleX, ease),
			PropertyAction::alloc(duration, startScale, endScale, Property::ScaleY, ease));
	}
	static inline Action* create(float duration, const Vec2& startScale, const Vec2& endScale, Ease::Enum ease)
	{
		return Spawn::create(PropertyAction::alloc(duration, startScale.x, endScale.x, Property::ScaleX, ease),
			PropertyAction::alloc(duration, startScale.y, endScale.y, Property::ScaleY, ease));
	}
	static inline Action* create(float duration, float startScale, float endScale, Ease::Enum ease)
	{
		return Spawn::create(PropertyAction::alloc(duration, startScale, endScale, Property::ScaleX, ease),
			PropertyAction::alloc(duration, startScale, endScale, Property::ScaleY, ease));
	}
};

class Action : public Object
{
public:
	PROPERTY_READONLY(float, Eclapsed);
	PROPERTY_READONLY(float, Duration);
	PROPERTY_READONLY_BOOL(Running);
	PROPERTY_READONLY_BOOL(Paused);
	PROPERTY_BOOL(Reversed);
	PROPERTY(float, Speed);
	PROPERTY_READONLY_CALL(Own<ActionDuration>&, Action);
	void pause();
	void resume();
	void updateTo(float eclapsed, bool reversed = false);
	CREATE_FUNC(Action);
protected:
	Action(Own<ActionDuration>&& actionDuration);
private:
	bool updateProgress();
	Ref<Action> _prev;
	Ref<Action> _next;
	bool _paused;
	bool _reversed;
	int _order;
	float _speed;
	float _eclapsed;
	Node* _target;
	Own<ActionDuration> _action;
	static const int InvalidOrder;
	friend class Node;
	friend class Scheduler;
	DORA_TYPE_OVERRIDE(Action);
};

NS_DOROTHY_END

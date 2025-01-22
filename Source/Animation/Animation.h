/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Animation/Action.h"

NS_DORA_BEGIN

class Object;
class Node;
class ResetAction;

class AnimationDef {
public:
	virtual ~AnimationDef() { }
	virtual Action* toAction() = 0;
	virtual std::string toXml() = 0;
	virtual void restoreResetAnimation(Node* target, ActionDuration* resetTarget) = 0;
};

class KeyFrameDef {
public:
	KeyFrameDef();
	Ease::Enum easePos;
	Ease::Enum easeScale;
	Ease::Enum easeOpacity;
	Ease::Enum easeRotation;
	Ease::Enum easeSkew;
	bool visible;
	float opacity;
	float duration;
	float x;
	float y;
	float scaleX;
	float scaleY;
	float rotation;
	float skewX;
	float skewY;
	std::optional<std::string> event;
	std::string toXml(KeyFrameDef* lastDef);
};

class KeyReset : public ActionDuration {
public:
	virtual float getDuration() const override;
	virtual bool update(Node* target, float elapsed) override;
	static Own<ActionDuration> alloc(KeyFrameDef* def);
	static Action* create(KeyFrameDef* def);

private:
	bool _ended;
	bool _visible;
	float _opacity;
	float _x;
	float _y;
	float _scaleX;
	float _scaleY;
	float _rotation;
	float _skewX;
	float _skewY;
};

class SpriteDef;

class ResetAction : public ActionDuration {
public:
	virtual float getDuration() const override;
	void prepareWith(Node* target);
	void updateEndValues(KeyFrameDef* def);
	void updateEndValues(SpriteDef* def);
	virtual bool update(Node* target, float elapsed) override;
	static Own<ActionDuration> alloc(float duration, SpriteDef* def, Ease::Enum easing);
	static Action* create(float duration, SpriteDef* def, Ease::Enum easing);

private:
	bool _ended;
	float _opacityStart;
	float _opacityDelta;
	float _xStart;
	float _xDelta;
	float _yStart;
	float _yDelta;
	float _scaleXStart;
	float _scaleXDelta;
	float _scaleYStart;
	float _scaleYDelta;
	float _rotationStart;
	float _rotationDelta;
	float _skewXStart;
	float _skewXDelta;
	float _skewYStart;
	float _skewYDelta;
	float _duration;
	bx::EaseFn _ease;
	DORA_TYPE_OVERRIDE(ResetAction);
};

class KeyAnimationDef : public AnimationDef {
public:
	void add(Own<KeyFrameDef>&& def);
	KeyFrameDef* getLastFrameDef() const;
	const OwnVector<KeyFrameDef>& getFrames() const;
	virtual Action* toAction() override;
	virtual std::string toXml() override;
	virtual void restoreResetAnimation(Node* target, ActionDuration* resetTarget) override;

private:
	OwnVector<KeyFrameDef> _keyFrameDefs;
};

class FrameAnimationDef : public AnimationDef {
public:
	PROPERTY_STRING(File);
	FrameAnimationDef()
		: delay(0) { }
	float delay;
	virtual Action* toAction() override;
	virtual std::string toXml() override;
	virtual void restoreResetAnimation(Node* target, ActionDuration* resetTarget) override { }

private:
	Ref<FrameActionDef> _def;
	std::string _file;
};

NS_DORA_END

/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Playable.h"
#include "spine/spine.h"

NS_DORA_BEGIN

class SkeletonData;
class SpriteEffect;
class DrawNode;
class Line;

class Spine : public Playable {
public:
	PROPERTY_BOOL(DepthWrite);
	PROPERTY_BOOL(HitTestEnabled);
	virtual bool init() override;
	virtual bool update(double deltaTime) override;
	virtual void render() override;
	virtual void cleanup() override;
	virtual void setShowDebug(bool var) override;
	virtual void setSpeed(float var) override;
	virtual void setRecovery(float var) override;
	virtual void setFliped(bool var) override;
	virtual void setLook(String var) override;
	virtual const std::string& getCurrent() const override;
	virtual const std::string& getLastCompleted() const override;
	virtual Vec2 getKeyPoint(String name) override;
	virtual float play(String name, bool loop = false) override;
	virtual void stop() override;
	virtual void setSlot(String name, Node* item) override;
	virtual Node* getSlot(String name) override;
	bool setBoneRotation(String name, float rotation);
	std::string containsPoint(float x, float y) const;
	std::string intersectsSegment(float x1, float y1, float x2, float y2) const;
	CREATE_FUNC_NULLABLE(Spine);

protected:
	Spine(String skelFile, String atlasFile);
	Spine(String spineStr);
	class SpineListener : public spine::AnimationStateListenerObject {
	public:
		SpineListener(Spine* owner);
		virtual void callback(spine::AnimationState* state, spine::EventType type, spine::TrackEntry* entry, spine::Event* event) override;

	private:
		Spine* _owner;
	} _listener;

private:
	std::string _currentAnimationName;
	std::string _lastCompletedAnimationName;
	Ref<SpriteEffect> _effect;
	Ref<SkeletonData> _skeletonData;
	Own<spine::Skeleton> _skeleton;
	Own<spine::AnimationState> _animationState;
	Own<spine::AnimationStateData> _animationStateData;
	Own<spine::Skin> _newSkin;
	Own<spine::SkeletonBounds> _bounds;
	Own<spine::SkeletonClipping> _clipper;
	Ref<Line> _debugLine;
	Own<StringMap<Ref<Node>>> _slots;
	enum : Flag::ValueType {
		DepthWrite = Node::UserFlag,
		HitTest = Node::UserFlag << 1,
	};
	DORA_TYPE_OVERRIDE(Spine);
};

NS_DORA_END

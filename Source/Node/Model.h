/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Playable.h"

NS_DORA_BEGIN

class Model;
class Action;
class ResetAction;
class Sequence;
class Sprite;
class SpriteDef;
class ModelDef;
class ClipDef;

/** @brief A look is to change visibility of a model`s different parts.
 For example you can change a character`s face by different look.
 It`s component class of Model. Do not use it alone.
*/
class Look {
public:
	enum { None = -1 };
	void add(Node* node);
	void apply();
	void unApply();

private:
	std::vector<Node*> _nodes;
};

/** @brief It`s component class of oModelDef. Do not use it alone. */
class Animation {
public:
	enum { None = -1 };
	PROPERTY(float, Speed);
	PROPERTY(Action*, Action);
	PROPERTY_READONLY(float, Duration);
	PROPERTY_READONLY(float, Elapsed);
	PROPERTY_BOOL(Reversed);
	PROPERTY_READONLY(Node*, Node);
	Animation(Node* node, Action* action);
	void run();
	void pause();
	void resume();
	void stop();
	void updateTo(float elapsed, bool reversed = false);

private:
	Node* _node;
	Ref<Action> _action;
};

typedef Acf::Delegate<void(Model* model)> AnimationHandler;

class AnimationGroup {
public:
	float duration;
	OwnVector<Animation> animations;
	AnimationHandler animationEnd;
};

class ActionDuration;

class ResetAnimation : public Object {
public:
	void add(
		SpriteDef* spriteDef,
		Node* node,
		Action* action,
		ActionDuration* resetTarget);
	void run(float duration, int index);
	void stop();
	Acf::Delegate<void()> end;

private:
	void onActionEnd();
	struct AnimationData {
		SpriteDef* spriteDef;
		Node* node; // weak reference
		Ref<Action> action;
		ActionDuration* resetTarget;
	};
	OwnVector<AnimationData> _group;
};

class Model : public Playable {
public:
	PROPERTY_BOOL(Reversed);
	PROPERTY_READONLY(float, Duration);
	PROPERTY_READONLY_BOOL(Playing);
	PROPERTY_READONLY_BOOL(Paused);
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
	bool hasAnimation(String name) const;
	void pause();
	void resume();
	void resume(String name, bool loop = false);
	void reset();
	void updateTo(float elapsed, bool reversed = false);
	int getCurrentAnimationIndex() const;
	ModelDef* getModelDef() const;
	Node* getNodeByName(String name) const;
	bool eachNode(std::function<bool(Node* node)>) const;
	class AnimationHandlerGroup {
	public:
		void operator()(Model* owner);
		AnimationHandler& operator[](int index);
		AnimationHandler& operator[](String name);

	private:
		Model* _owner;
		AnimationHandler _unavailableHandler;
		friend class Model;
	} handlers;
	virtual bool init() override;
	virtual void cleanup() override;
	static Model* dummy();
	CREATE_FUNC_NULLABLE(Model);

protected:
	Model(ModelDef* def);
	Model(String filename);

private:
	void setLook(int index);
	float play(uint32_t index, bool loop);
	void resume(uint32_t index, bool loop);
	typedef StringMap<Node*> NodeMap;
	void visit(SpriteDef* parentDef, Node* parentNode, ClipDef* clipDef);
	void onResetAnimationEnd();
	void addLook(int index, Node* node);
	void addAnimation(int index, Node* node, Action* action);
	void resetActions();
	void setupCallback();
	void onActionEnd();
	NodeMap& nodeMap();

private:
	bool _loop;
	bool _reversed;
	bool _isPlaying;
	bool _isPaused;
	bool _isRecovering;
	float _time;
	int _currentLook;
	int _currentAnimation;
	Node* _root;
	Own<NodeMap> _nodeMap;
	Ref<ModelDef> _modelDef;
	OwnVector<Look> _looks;
	OwnVector<AnimationGroup> _animationGroups;
	ResetAnimation _resetAnimation;
	std::list<std::pair<Sprite*, SpriteDef*>> _spritePairs;
	std::string _lastCompletedAnimationName;
	DORA_TYPE_OVERRIDE(Model);
};

NS_DORA_END

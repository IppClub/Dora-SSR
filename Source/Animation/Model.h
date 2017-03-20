/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DOROTHY_BEGIN

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
 It`s component class of oModel. Do not use it alone.
*/
class Look
{
public:
	enum {None = -1};
	void add(Node* node);
	void apply();
	void unApply();
private:
	vector<Node*> _nodes;
};

/** @brief It`s component class of oModelDef. Do not use it alone. */
class Animation
{
public:
	enum {None = -1};
	PROPERTY(float, Speed);
	PROPERTY(Action*, Action);
	PROPERTY_READONLY(float, Time);
	PROPERTY_READONLY(float, Duration);
	PROPERTY_READONLY(Node*, Node);
	Animation(Node* node, Action* action);
	void run();
	void pause();
	void resume();
	void stop();
	void updateProgress(float time);
private:
	Node* _node;
	Ref<Action> _action;
};

typedef Delegate<void (Model* model)> AnimationHandler;

class AnimationGroup
{
public:
	float duration;
	OwnVector<Animation> animations;
	AnimationHandler animationEnd;
};

class ActionDuration;

class ResetAnimation : public Object
{
public:
	void add(
		SpriteDef* spriteDef,
		Node* node,
		Action* action,
		ActionDuration* resetTarget);
	void run(float duration, int index);
	void stop();
	Delegate<void()> end;
private:
	void onActionEnd();
	struct AnimationData
	{
		SpriteDef* spriteDef;
		Node* node; // weak reference
		Ref<Action> action;
		ActionDuration* resetTarget;
	};
	OwnVector<AnimationData> _group;
};

class Model : public Node
{
public:
	PROPERTY(float, Speed);
	PROPERTY(float, Time);
	PROPERTY(float, Recovery);
	PROPERTY_BOOL(Loop);
	PROPERTY_BOOL(FaceRight);
	PROPERTY_READONLY(float, Duration);
	PROPERTY_STRING(Look);
	void setLook(int index);
	float play(Uint32 index);
	float play(String name);
	void pause();
	void resume();
	void resume(Uint32 index);
	void resume(String name);
	void reset();
	void stop();
	bool isPlaying() const;
	bool isPaused() const;
	int getCurrentAnimationIndex() const;
	string getCurrentAnimationName() const;
	ModelDef* getModelDef() const;
	Node* getNodeByName(String name);
	class AnimationHandlerGroup
	{
	public:
		void operator()(Model* owner);
		AnimationHandler& operator[](int index);
		AnimationHandler& operator[](String name);
		void each(const function<void(const string&,AnimationHandler&)>& func);
	private:
		Model* _owner;
		friend class Model;
	} handlers;
	virtual bool init() override;
	virtual void cleanup() override;
	virtual Rect getBoundingBox() override;
	static Model* none();
	CREATE_FUNC(Model);
protected:
	Model(ModelDef* def);
private:
	typedef unordered_map<string,Node*> NodeMap;
	void visit(SpriteDef* parentDef, Node* parentNode, ClipDef* clipDef);
	void onResetAnimationEnd();
	void addLook(int index, Node* node);
	void addAnimation(int index, Node* node, Action* action);
	void resetActions();
	void setupCallback();
	void onActionEnd();
	NodeMap& nodeMap();

	bool _loop;
	bool _faceRight;
	bool _isPlaying;
	bool _isPaused;
	bool _isRecovering;
	float _time;
	float _speed;
	float _recoveryTime;
	int _currentLook;
	int _currentAnimation;
	const string& _currentLookName;
	Node* _root;
	Own<NodeMap> _nodeMap;
	Ref<ModelDef> _modelDef;
	OwnVector<Look> _looks;
	OwnVector<AnimationGroup> _animationGroups;
	ResetAnimation _resetAnimation;
	list<std::pair<Sprite*,SpriteDef*>> _spritePairs;
	DORA_TYPE_OVERRIDE(Model);
};

NS_DOROTHY_END

/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"
#include "Support/Common.h"
#include "Event/Event.h"
#include "Support/Array.h"

NS_DOROTHY_BEGIN

class Event;
class Listener;
class Signal;
class Slot;
class Scheduler;
class TouchHandler;
class NodeTouchHandler;
class Action;

typedef Delegate<void (Event* event)> EventHandler;

class Node : public Object
{
public:
	PROPERTY(int, Order);
	PROPERTY_VIRTUAL(float, Angle);
	PROPERTY(float, AngleX);
	PROPERTY(float, AngleY);
	PROPERTY(float, ScaleX);
	PROPERTY(float, ScaleY);
	PROPERTY(float, X);
	PROPERTY(float, Y);
	PROPERTY(float, Z);
	PROPERTY_VIRTUAL_REF(Vec2, Position);
	PROPERTY(float, SkewX);
	PROPERTY(float, SkewY);
	PROPERTY_BOOL(Visible);
	PROPERTY_REF(Vec2, Anchor);
	PROPERTY_READONLY_REF(Vec2, AnchorPoint);
	PROPERTY(float, Width);
	PROPERTY(float, Height);
	PROPERTY_REF(Size, Size);
	PROPERTY_REF(string, Tag);
	PROPERTY(float, Opacity);
	PROPERTY_READONLY(float, RealOpacity);
	PROPERTY(Color, Color);
	PROPERTY(Color3, Color3);
	PROPERTY_READONLY(Color, RealColor);
	PROPERTY_BOOL(PassOpacity);
	PROPERTY_BOOL(PassColor3);
	PROPERTY(Node*, TransformTarget);
	PROPERTY(Scheduler*, Scheduler);
	PROPERTY(Object*, UserData);
	PROPERTY_READONLY(Node*, Parent);
	PROPERTY_READONLY(Node*, TargetParent);
	PROPERTY_READONLY(Array*, Children);
	PROPERTY_READONLY_BOOL(Running);
	PROPERTY_READONLY_BOOL(Updating);
	PROPERTY_READONLY_BOOL(Scheduled);
	PROPERTY_BOOL(TouchEnabled);
	PROPERTY_BOOL(SwallowTouches);
	PROPERTY_BOOL(SwallowMouseWheel);
	PROPERTY_READONLY(TouchHandler*, TouchHandler);
	PROPERTY_BOOL(KeyboardEnabled);
	PROPERTY_VIRTUAL(int, RenderOrder);
	PROPERTY_BOOL(RenderGroup);
	PROPERTY_READONLY(Uint32, NodeCount);

	virtual void addChild(Node* child, int order, String tag);
	void addChild(Node* child, int order);
	void addChild(Node* child);

	virtual Node* addTo(Node* parent, int order, String tag);
	Node* addTo(Node* parent, int order);
	Node* addTo(Node* parent);

	void removeChild(Node* child, bool cleanup = true);
	void removeChildByTag(String tag, bool cleanup = true);
	void removeAllChildren(bool cleanup = true);

	virtual Rect getBoundingBox();

	virtual void onEnter();
	virtual void onExit();
	virtual void cleanup();

	Node* getChildByTag(String tag);

	void schedule(const function<bool(double)>& func);
	void unschedule();

	Vec2 convertToNodeSpace(const Vec2& worldPoint);
	Vec2 convertToWorldSpace(const Vec2& nodePoint);

	Vec3 convertToNodeSpace3(const Vec3& worldPoint);
	Vec3 convertToWorldSpace3(const Vec3& nodePoint);

	void convertToWindowSpace(const Vec2& nodePoint, const function<void(const Vec2&)>& callback);

	void scheduleUpdate();
	void unscheduleUpdate();

	virtual void visit();
	virtual void render();
	virtual bool update(double deltaTime) override;

	const AffineTransform& getLocalTransform();

	void getLocalWorld(Matrix& localWorld);
	virtual const Matrix& getWorld();

	void markDirty();

	void emit(Event* event);

	Slot* slot(String name);
	Slot* slot(String name, const EventHandler& handler);
	void slot(String name, std::nullptr_t);

	Listener* gslot(String name, const EventHandler& handler);
	void gslot(String name, std::nullptr_t);
	void gslot(Listener* listener, std::nullptr_t);
	RefVector<Listener> gslot(String name);

	CREATE_FUNC(Node);
public:
	template <class ...Args>
	void emit(String name, Args ...args)
	{
		if (_signal)
		{
			EventArgs<Args...> event(name, args...);
			emit(&event);
		}
	}

	/** @brief traverse children, return true to stop. */
	template <class Func>
	bool eachChild(const Func& func)
	{
		if (_children && !_children->isEmpty())
		{
			return _children->each<Node>(func);
		}
		return false;
	}

	/** @brief traverse node tree, return true to stop. */
	template <class Func>
	bool traverse(const Func& func)
	{
		if (func(this)) return true;
		if (_children && _flags.isOn(Node::TraverseEnabled))
		{
			for (auto child : _children->data())
			{
				if (child.to<Node>()->traverse(func))
				{
					return true;
				}
			}
		}
		return false;
	}

	/** @brief traverse node tree, return true to stop. */
	template <class Func>
	bool traverseVisible(const Func& func)
	{
		if (!isVisible() || func(this)) return true;
		if (_children && _flags.isOn(Node::TraverseEnabled))
		{
			for (auto child : _children->data())
			{
				if (child.to<Node>()->traverse(func))
				{
					return true;
				}
			}
		}
		return false;
	}

	PROPERTY_READONLY(int, ActionCount);
	void runAction(Action* action);
	bool hasAction(Action* action);
	void stopAllActions();
	void perform(Action* action);
	void removeAction(Action* action);
	void stopAction(Action* action);

	Size alignItemsVertically(float padding = 10.0f);
	Size alignItemsVertically(const Size& size, float padding = 10.0f);
	Size alignItemsHorizontally(float padding = 10.0f);
	Size alignItemsHorizontally(const Size& size, float padding = 10.0f);
	Size alignItems(float padding = 10.0f);
	Size alignItems(const Size& size, float padding = 10.0f);
	void moveAndCullItems(const Vec2& delta);

	void attachIME();
	void detachIME();
protected:
	Node();
	virtual ~Node();
	virtual void updateRealColor3();
	virtual void updateRealOpacity();
	void sortAllChildren();
	void pauseActionInList(Action* action);
	void resumeActionInList(Action* action);
	void stopActionInList(Action* action);
	void handleKeyboard(Event* event);
protected:
	Flag _flags;
	int _order;
	int _renderOrder;
	Color _color;
	Color _realColor;
	float _angle;
	float _angleX;
	float _angleY;
	float _scaleX;
	float _scaleY;
	float _skewX;
	float _skewY;
	float _positionZ;
	Vec2 _position;
	Vec2 _anchor;
	Vec2 _anchorPoint;
	Size _size;
	Matrix _world;
	AffineTransform _transform;
	WRef<Node> _transformTarget;
	Node* _parent;
	Ref<Object> _userData;
	Ref<Array> _children;
	Ref<Scheduler> _scheduler;
	Ref<Action> _action;
	Own<Signal> _signal;
	string _tag;
	Own<NodeTouchHandler> _touchHandler;
	function<bool(double)> _scheduleFunc;
	enum
	{
		Visible = 1,
		TransformDirty = 1 << 1,
		WorldDirty = 1 << 2,
		Running = 1 << 3,
		Updating = 1 << 4,
		Scheduling = 1 << 5,
		PassOpacity = 1 << 6,
		PassColor3 = 1 << 7,
		Reorder = 1 << 8,
		Cleanup = 1 << 9,
		TouchEnabled = 1 << 10,
		SwallowTouches = 1 << 11,
		SwallowMouseWheel = 1 << 12,
		KeyboardEnabled = 1 << 13,
		TraverseEnabled = 1 << 14,
		RenderGrouped = 1 << 15,
		UserFlag = 1 << 16
	};
	DORA_TYPE_OVERRIDE(Node);
};

class Slot : public Object
{
public:
	void add(const EventHandler& handler);
	void set(const EventHandler& handler);
	void remove(const EventHandler& handler);
	void clear();
	void handle(Event* event);
	CREATE_FUNC(Slot);
protected:
	Slot(const EventHandler& handler);
private:
	EventHandler _handler;
	DORA_TYPE_OVERRIDE(Slot);
};

class Signal
{
public:
	Slot* addSlot(String name, const EventHandler& handler);
	Listener* addGSlot(String name, const EventHandler& handler);
	void removeSlot(String name, const EventHandler& handler);
	void removeGSlot(Listener* gslot);
	void removeSlots(String name);
	void removeGSlots(String name);
	RefVector<Listener> getGSlots(String name) const;
	void emit(Event* event);
	static const size_t MaxSlotArraySize;
private:
	Own<unordered_map<string, Ref<Slot>>> _slots;
	Own<vector<std::pair<string, Ref<Slot>>>> _slotsArray;
	RefVector<Listener> _gslots;
};

NS_DOROTHY_END

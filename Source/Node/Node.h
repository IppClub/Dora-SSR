/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Event;

typedef Delegate<void (Event* event)> EventHandler;

class Node : public Object
{
public:
	PROPERTY(int, Order);
	PROPERTY(float, Angle);
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
	PROPERTY(float, Width);
	PROPERTY(float, Height);
	PROPERTY_REF(Size, Size);
	PROPERTY(int, Tag);
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

	virtual void addChild(Node* child, int order, int tag);
	void addChild(Node* child, int order);
	void addChild(Node* child);

	virtual Node* addTo(Node* parent, int order, int tag);
	Node* addTo(Node* parent, int order);
	Node* addTo(Node* parent);

	void removeChild(Node* child, bool cleanup = true);
	void removeChildByTag(int tag, bool cleanup = true);
	void removeAllChildren(bool cleanup = true);

	virtual Rect getBoundingBox();

	virtual void onEnter();
	virtual void onEnterFinished();
	virtual void onExit();
	virtual void onExitFinished();
	virtual void cleanup();

	Node* getChildByTag(int tag);

	void schedule(const function<bool(double)>& func);
	void unschedule();

	Vec2 convertToNodeSpace(const Vec2& worldPoint);
	Vec2 convertToWorldSpace(const Vec2& nodePoint);

	void scheduleUpdate();
	void unscheduleUpdate();

	virtual void visit(const float* world = Matrix::Indentity);
	virtual void render(float* world);
	virtual bool update(double deltaTime) override;

	const AffineTransform& getLocalTransform();
	AffineTransform getWorldTransform();

	void getLocalWorld(float* localWorld);
	void getWorld(float* world);

	void emit(String name);
	void slot(String name, const EventHandler& handler);
	Listener* gslot(String name);

	CREATE_FUNC(Node);
/*
	PROPERTY_READONLY(int, ActionCount);
	void runAction(CCAction* action);
	void stopAllActions();
	void perform(CCAction* action);
	void stopAction(CCAction* action);
*/
protected:
	Node();
	virtual ~Node();
	void setOn(Uint32 type);
	void setOff(Uint32 type);
	void setFlag(Uint32 type, bool value);
	void markDirty();
	bool isOn(Uint32 type) const;
	bool isOff(Uint32 type) const;
	void updateRealColor3();
	void updateRealOpacity();
	void sortAllChildren();
protected:
	Uint32 _flags;
	int _tag;
	int _order;
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
	float* _world;
	Vec2 _position;
	Vec2 _anchor;
	Vec2 _anchorPoint;
	Size _size;
	AffineTransform _transform;
	WRef<Node> _transformTarget;
	Node* _parent;
	Ref<Object> _userData;
	Ref<Array> _children;
	Ref<Scheduler> _scheduler;
	function<bool(double)> _scheduleFunc;
	enum
	{
		Visible = 1,
		TransformDirty = 1 << 1,
		Running = 1 << 2,
		Updating = 1 << 3,
		Scheduling = 1 << 4,
		PassOpacity = 1 << 5,
		PassColor3 = 1 << 6,
		Reorder = 1 << 7,
		Cleanup = 1 << 8
	};
	DORA_TYPE_OVERRIDE(Node);
};

NS_DOROTHY_END

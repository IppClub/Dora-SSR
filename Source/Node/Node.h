/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Node : public Object
{
public:
	PROPERTY(int, ZOrder);
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
	PROPERTY(Color, Color);
	PROPERTY(Color3, Color3);
	PROPERTY_BOOL(PassOpacity);
	PROPERTY_BOOL(PassColor);
	PROPERTY(Node*, TransformTarget);
	PROPERTY(Scheduler*, Scheduler);
	PROPERTY(Object*, UserData);
	PROPERTY_READONLY(Node*, Parent);
	PROPERTY_READONLY_VIRTUAL(Rect, BoundingBox);
	PROPERTY_READONLY(const char*, Description);
	PROPERTY_READONLY(Array*, Children);
	PROPERTY_READONLY_BOOL(Running);
	PROPERTY_READONLY_BOOL(Updating);
	PROPERTY_READONLY_BOOL(Scheduled);

	virtual void addChild(Node* child, int zOrder, int tag);
	void addChild(Node* child, int zOrder);
	void addChild(Node* child);

	virtual Node* addTo(Node* parent, int zOrder, int tag);
	Node* addTo(Node* parent, int zOrder);
	Node* addTo(Node* parent);

	void removeChild(Node* child, bool cleanup = true);
	void removeChildByTag(int tag, bool cleanup = true);
	void removeAllChildren(bool cleanup = true);

	virtual void cleanup();

	Node* getChildByTag(int tag);

	void schedule(const function<bool(double)>& func);
	void unschedule();

	Vec2 convertToNodeSpace(const Vec2& worldPoint);
	Vec2 convertToWorldSpace(const Vec2& nodePoint);

	void scheduleUpdate();
	void unscheduleUpdate();

	virtual void visit();
	virtual void render();
	virtual bool update(double deltaTime) override;

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
	bool isOn(Uint32 type) const;
	bool isOff(Uint32 type) const;
	void sortAllChildren();
protected:
	Uint32 _flags;
	int _tag;
	int _zOrder;
	Color _color;
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
	Size _size;
	float _localTransform[16];
	WRef<Node> _transformTarget;
	WRef<Node> _parent;
	Ref<Object> _userData;
	Ref<Array> _children;
	Ref<Scheduler> _scheduler;
	function<bool(double)> _scheduleFunc;
	enum
	{
		Visible = 1,
		Dirty = 1<<1,
		Running = 1<<2,
		Updating = 1<<3,
		Scheduling = 1<<4,
		PassOpacity = 1<<5,
		PassColor = 1<<6,
		Reorder = 1<<7,
		Cleanup = 1<<8
	};
	DORA_TYPE_OVERRIDE(Node);
};

NS_DOROTHY_END

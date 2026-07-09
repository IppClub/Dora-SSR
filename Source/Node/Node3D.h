/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Basic/Scheduler.h"
#include "Support/Common.h"
#include "Support/Geometry.h"

NS_DORA_BEGIN

using Quat = bx::Quaternion;

class Node3D : public Object {
public:
	PROPERTY(Scheduler*, Scheduler);
	PROPERTY(int, Order);
	PROPERTY_CREF(Vec3, Position);
	PROPERTY_CREF(Vec3, Scale);
	PROPERTY_CREF(Quat, Rotation);
	PROPERTY_CREF(Vec3, EulerAngles);
	PROPERTY_STRING(Tag);
	PROPERTY_BOOL(Visible);
	PROPERTY_READONLY(Node3D*, Parent);
	PROPERTY_READONLY_CREF(Matrix, WorldMatrix);
	PROPERTY_READONLY_CALL(const std::vector<Ref<Node3D>>&, Children);
	PROPERTY(float, X);
	PROPERTY(float, Y);
	PROPERTY(float, Z);
	PROPERTY(float, AngleX);
	PROPERTY(float, AngleY);
	PROPERTY(float, AngleZ);
	PROPERTY(float, ScaleX);
	PROPERTY(float, ScaleY);
	PROPERTY(float, ScaleZ);

	void setPosition(float x, float y, float z);
	void setScale(float x, float y, float z);
	void setEulerAngles(float x, float y, float z);

	virtual void addChild(Node3D* child, int order, String tag);
	void addChild(Node3D* child, int order);
	void addChild(Node3D* child);
	virtual void removeChild(Node3D* child, bool cleanup = true);
	virtual void removeAllChildren(bool cleanup = true);
	virtual void removeFromParent(bool cleanup = true);
	virtual void cleanup() override;

	virtual bool update(double deltaTime);

	Vec3 convertToWorldSpace(const Vec3& localPoint);
	Vec3 convertToNodeSpace(const Vec3& worldPoint);

	void markReorder() noexcept;
	uint64_t getHandle() const noexcept;
	bool hasChildren() const noexcept;

	virtual bool init() override;
	CREATE_FUNC_NOT_NULL(Node3D);

protected:
	Node3D();
	virtual ~Node3D();
	void sortAllChildren();
	ScheduledItem* getScheduledItem();

protected:
	int _order;
	std::string _tag;
	bool _reorderDirty;
	Node3D* _parent;
	std::vector<Ref<Node3D>> _children;
	Ref<Scheduler> _scheduler;
	Own<ScheduledItem> _scheduledItem;
	uint64_t _handle;
	mutable Vec3 _position;
	mutable Vec3 _scale;
	mutable Quat _rotation;
	mutable Vec3 _eulerAngles;
	mutable Matrix _worldMatrix;
	DORA_TYPE_OVERRIDE(Node3D);
};

NS_DORA_END

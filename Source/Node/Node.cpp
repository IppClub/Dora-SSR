/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Node.h"

NS_DOROTHY_BEGIN

Node::Node():
_flags(Node::Visible|Node::PassOpacity|Node::PassColor),
_tag(0),
_zOrder(0),
_color(),
_angle(0.0f),
_angleX(0.0f),
_angleY(0.0f),
_scaleX(1.0f),
_scaleY(1.0f),
_skewX(0.0f),
_skewY(0.0f),
_positionZ(0.0f),
_position(),
_anchor(0.5f, 0.5f),
_size(),
localTransform{},
_scheduler(SharedDirector.getScheduler())
{ }

Node::~Node()
{
}

void Node::setZOrder(int var)
{
	if (_zOrder != var)
	{
		if (_parent)
		{

		}
	}
}

int Node::getZOrder() const
{
	return _zOrder;
}

void Node::setAngle(float var)
{
}

float Node::getAngle() const
{
	return _angle;
}

void Node::setScaleX(float var)
{
}

float Node::getScaleX() const
{
	return _scaleX;
}

void Node::setScaleY(float var)
{
}

float Node::getScaleY() const
{
	return _scaleY;
}

void Node::setX(float var)
{
}

float Node::getX() const
{
	return _position.x;
}

void Node::setY(float var)
{
}

float Node::getY() const
{
	return _position.y;
}

void Node::setZ(float var)
{
}

float Node::getZ() const
{
	return _positionZ;
}

void Node::setPosition(const Vec2& var)
{
}

const Vec2& Node::getPosition() const
{
	return _position;
}

void Node::setSkewX(float var)
{
}

float Node::getSkewX() const
{
	return _skewX;
}

void Node::setSkewY(float var)
{
}

float Node::getSkewY() const
{
	return _skewY;
}

void Node::setVisible(bool var)
{
}

bool Node::isVisible() const
{
	return isOn(Node::Visible);
}

void Node::setAnchor(const Vec2& var)
{
}

const Vec2& Node::getAnchor() const
{
	return _anchor;
}

void Node::setWidth(float var)
{
}

float Node::getWidth() const
{
	return _size.width;
}

void Node::setHeight(float var)
{
}

float Node::getHeight() const
{
	return _size.height;
}

void Node::setSize(const Size& var)
{
}

const Size& Node::getSize() const
{
	return _size;
}

void Node::setTag(int var)
{
}

int Node::getTag() const
{
	return _tag;
}

void Node::setOpacity(float var)
{
}

float Node::getOpacity() const
{
	return _color.getOpacity();
}

void Node::setColor(Color var)
{
}

Color Node::getColor() const
{
	return _color;
}

void Node::setPassOpacity(bool var)
{
}

bool Node::isPassOpacity() const
{
	return isOn(Node::PassOpacity);
}

void Node::setPassColor(bool var)
{
}

bool Node::isPassColor() const
{
	return isOn(Node::PassColor);
}

void Node::setTransformTarget(Node* var)
{
	_transformTarget = var;
}

Node* Node::getTransformTarget() const
{
	return _transformTarget;
}

void Node::setScheduler(Scheduler* var)
{
	_scheduler = var;
}

Scheduler* Node::getScheduler() const
{
	return _scheduler;
}

void Node::setUserData(Object* var)
{
	_userData = var;
}

Object* Node::getUserData() const
{
	return _userData;
}

Node* Node::getParent() const
{
	return _parent;
}

Rect Node::getBoundingBox() const
{
	return Rect();
}

const char* Node::getDescription() const
{
	return "";
}

Array* Node::getChildren() const
{
	return _children;
}

bool Node::isRunning() const
{
	return isOn(Node::Running);
}

void Node::addChild(Node* child, int zOrder, int tag)
{
}

void Node::addChild(Node* child, int zOrder)
{
	addChild(child, zOrder, child->getTag());
}

void Node::addChild(Node* child)
{
	addChild(child, child->getZOrder(), child->getTag());
}

Node* Node::addTo(Node* parent, int zOrder, int tag)
{
	return this;
}

Node* Node::addTo(Node* parent, int zOrder)
{
	return addTo(parent, zOrder, getTag());
}

Node* Node::addTo(Node* parent)
{
	return addTo(parent, getZOrder(), getTag());
}

void Node::removeChild(Node* child, bool cleanup)
{
}

void Node::removeChildByTag(int tag, bool cleanup)
{
}

void Node::removeAllChildren(bool cleanup)
{
}

void Node::cleanup()
{
	if (isOff(Node::Cleanup))
	{
		setOn(Node::Cleanup);
		unschedule();
		unscheduleUpdate();
	}
}

Node* Node::getChildByTag(int tag)
{
	return nullptr;
}

Vec2 Node::convertToNodeSpace(const Vec2& worldPoint)
{
	return Vec2();
}

Vec2 Node::convertToWorldSpace(const Vec2& nodePoint)
{
	return Vec2();
}

bool Node::isScheduled() const
{
	return isOn(Node::Scheduling);
}

void Node::schedule(const function<bool(double)>& func)
{
	_scheduleFunc = func;
	if (isOn(Node::Scheduling))
	{
		return;
	}
	if (isOn(Node::Updating))
	{
		setOn(Node::Scheduling);
		return;
	}
	_scheduler->schedule(this);
}

void Node::unschedule()
{
	_scheduleFunc = nullptr;
	setOff(Node::Scheduling);
	if (isOff(Node::Updating))
	{
		_scheduler->unschedule(this);
	}
}

bool Node::isUpdating() const
{
	return isOn(Node::Updating) || isOn(Node::Scheduling);
}

void Node::scheduleUpdate()
{
	if (isOn(Node::Updating))
	{
		return;
	}
	if (isOn(Node::Scheduling))
	{
		setOn(Node::Updating);
		return;
	}
	setOn(Node::Updating);
	_scheduler->schedule(this);
}

void Node::unscheduleUpdate()
{
	if (isOn(Node::Updating) || isOn(Node::Scheduling))
	{
		setOff(Node::Updating);
		setOff(Node::Scheduling);
		_scheduler->unschedule(this);
	}
}

bool Node::update(double deltaTime)
{
	if (_scheduleFunc)
	{
		return _scheduleFunc(deltaTime);
	}
	return Object::update(deltaTime);
}

void Node::visit()
{
}

void Node::render()
{
}

void Node::setOn(Uint32 type)
{
	_flags |= type;
}

void Node::setOff(Uint32 type)
{
	_flags &= ~type;
}

bool Node::isOn(Uint32 type) const
{
	return _flags & type;
}

bool Node::isOff(Uint32 type) const
{
	return !(_flags & type);
}

NS_DOROTHY_END

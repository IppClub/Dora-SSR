/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Node.h"

NS_DOROTHY_BEGIN

Node::Node():
_flags(Node::Visible|Node::PassOpacity|Node::PassColor3),
_tag(0),
_order(0),
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
_transform(AffineTransform::Indentity),
_scheduler(SharedDirector.getScheduler())
{ }

Node::~Node()
{ }

void Node::setOrder(int var)
{
	if (_order != var)
	{
		_order = var;
		if (_parent)
		{
			_parent->setOn(Node::Reorder);
		}
	}
}

int Node::getOrder() const
{
	return _order;
}

void Node::setAngle(float var)
{
	_angle = var;
	markDirty();
}

float Node::getAngle() const
{
	return _angle;
}

void Node::setScaleX(float var)
{
	_scaleX = var;
	markDirty();
}

float Node::getScaleX() const
{
	return _scaleX;
}

void Node::setScaleY(float var)
{
	_scaleY = var;
	markDirty();
}

float Node::getScaleY() const
{
	return _scaleY;
}

void Node::setX(float var)
{
	_position.x = var;
	markDirty();
}

float Node::getX() const
{
	return _position.x;
}

void Node::setY(float var)
{
	_position.y = var;
	markDirty();
}

float Node::getY() const
{
	return _position.y;
}

void Node::setZ(float var)
{
	_positionZ = var;
	markDirty();
}

float Node::getZ() const
{
	return _positionZ;
}

void Node::setPosition(const Vec2& var)
{
	_position = var;
	markDirty();
}

const Vec2& Node::getPosition() const
{
	return _position;
}

void Node::setSkewX(float var)
{
	_skewX = var;
	markDirty();
}

float Node::getSkewX() const
{
	return _skewX;
}

void Node::setSkewY(float var)
{
	_skewY = var;
	markDirty();
}

float Node::getSkewY() const
{
	return _skewY;
}

void Node::setVisible(bool var)
{
	setFlag(Node::Visible, var);
}

bool Node::isVisible() const
{
	return isOn(Node::Visible);
}

void Node::setAnchor(const Vec2& var)
{
	_anchor = var;
	_anchorPoint = _anchor * _size;
	markDirty();
}

const Vec2& Node::getAnchor() const
{
	return _anchor;
}

void Node::setWidth(float var)
{
	_size.width = var;
	_anchorPoint.x = _anchor.x * var;
	markDirty();
}

float Node::getWidth() const
{
	return _size.width;
}

void Node::setHeight(float var)
{
	_size.height = var;
	_anchorPoint.y = _anchor.y * var;
	markDirty();
}

float Node::getHeight() const
{
	return _size.height;
}

void Node::setSize(const Size& var)
{
	_size = var;
	_anchorPoint = _anchor * _size;
	markDirty();
}

const Size& Node::getSize() const
{
	return _size;
}

void Node::setTag(int var)
{
	_tag = var;
}

int Node::getTag() const
{
	return _tag;
}

void Node::setOpacity(float var)
{
	_color.setOpacity(var);
	updateRealOpacity();
}

float Node::getOpacity() const
{
	return _color.getOpacity();
}

float Node::getRealOpacity() const
{
	return _realColor.getOpacity();
}

void Node::setColor(Color var)
{
	_realColor = _color = var;
	updateRealColor3();
	updateRealOpacity();
}

Color Node::getColor() const
{
	return _color;
}

void Node::setColor3(Color3 var)
{
	_realColor = _color = var;
	updateRealColor3();
}

Color3 Node::getColor3() const
{
	return _color.toColor3();
}

Color Node::getRealColor() const
{
	return _realColor;
}

void Node::setPassOpacity(bool var)
{
	setFlag(Node::PassOpacity, var);
	setOpacity(_color.getOpacity());
}

bool Node::isPassOpacity() const
{
	return isOn(Node::PassOpacity);
}

void Node::setPassColor3(bool var)
{
	setFlag(Node::PassColor3, var);
	setColor3(_color.toColor3());
}

bool Node::isPassColor3() const
{
	return isOn(Node::PassColor3);
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
	if (isUpdating())
	{
		_scheduler->unschedule(this);
		_scheduler = var;
		_scheduler->schedule(this);
	}
	else
	{
		_scheduler = var;
	}
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

Node* Node::getTargetParent() const
{
	return _transformTarget ? _transformTarget : _parent;
}

Rect Node::getBoundingBox()
{
	Rect rect(0, 0, _size.width, _size.height);
	return AffineTransform::applyRect(getLocalTransform(), rect);
}

void Node::onEnter()
{
	ARRAY_START(Node, child, _children)
	{
		child->onEnter();
	}
	ARRAY_END
	setOn(Node::Running);
	if (isUpdating())
	{
		_scheduler->schedule(this);
	}
}

void Node::onEnterFinished()
{
	ARRAY_START(Node, child, _children)
	{
		child->onEnterFinished();
	}
	ARRAY_END
}

void Node::onExit()
{
	ARRAY_START(Node, child, _children)
	{
		child->onExit();
	}
	ARRAY_END
	setOff(Node::Running);
	if (isUpdating())
	{
		_scheduler->unschedule(this);
	}
}

void Node::onExitFinished()
{
	ARRAY_START(Node, child, _children)
	{
		child->onExitFinished();
	}
	ARRAY_END
}

Array* Node::getChildren() const
{
	return _children;
}

bool Node::isRunning() const
{
	return isOn(Node::Running);
}

void Node::addChild(Node* child, int order, int tag)
{
	AssertUnless(child, "add invalid child to node.");
	AssertIf(child->_parent, "child already added. It can't be added again.");
	child->setTag(tag);
	child->setOrder(order);
	if (!_children)
	{
		_children = Array::create();
	}
	Node* last = nullptr;
	if (!_children->isEmpty())
	{
		last = _children->getLast().to<Node>();
	}
	_children->add(child);
	if (last && last->getOrder() > child->getOrder())
	{
		setOn(Node::Reorder);
	}
	child->_parent = this;
	child->updateRealColor3();
	child->updateRealOpacity();
	if (isOn(Node::Running))
	{
		child->onEnter();
		child->onEnterFinished();
	}
}

void Node::addChild(Node* child, int order)
{
	addChild(child, order, child->getTag());
}

void Node::addChild(Node* child)
{
	addChild(child, child->getOrder(), child->getTag());
}

Node* Node::addTo(Node* parent, int order, int tag)
{
	AssertUnless(parent, "add node to invalid parent.");
	parent->addChild(this, order, tag);
	return this;
}

Node* Node::addTo(Node* parent, int zOrder)
{
	return addTo(parent, zOrder, getTag());
}

Node* Node::addTo(Node* parent)
{
	return addTo(parent, getOrder(), getTag());
}

void Node::removeChild(Node* child, bool cleanup)
{
	if (!_children)
	{
		return;
	}
	Ref<> childRef(child);
	if (_children->remove(child))
	{
		if (isOn(Node::Running))
		{
			child->onExit();
			child->onExitFinished();
		}
		if (cleanup)
		{
			child->cleanup();
		}
		child->_parent = nullptr;
	}
}

void Node::removeChildByTag(int tag, bool cleanup)
{
	removeChild(getChildByTag(tag), cleanup);
}

void Node::removeAllChildren(bool cleanup)
{
	ARRAY_START(Node, child, _children)
	{
		if (isOn(Node::Running))
		{
			child->onExit();
			child->onExitFinished();
		}
		if (cleanup)
		{
			child->cleanup();
		}
		child->_parent = nullptr;
	}
	ARRAY_END
	if (_children)
	{
		_children->clear();
	}
}

void Node::cleanup()
{
	if (isOff(Node::Cleanup))
	{
		setOn(Node::Cleanup);
		ARRAY_START(Node, child, _children)
		{
			child->cleanup();
		}
		ARRAY_END
		unschedule();
		unscheduleUpdate();
		_userData = nullptr;
	}
}

Node* Node::getChildByTag(int tag)
{
	Node* targetNode = nullptr;
	ARRAY_START(Node, child, _children)
	{
		if (child->getTag() == tag)
		{
			targetNode = child;
			break;
		}
	}
	ARRAY_END
	return targetNode;
}

Vec2 Node::convertToNodeSpace(const Vec2& worldPoint)
{
	return AffineTransform::applyPoint(getWorldTransform(), worldPoint);
}

Vec2 Node::convertToWorldSpace(const Vec2& nodePoint)
{
	return AffineTransform::applyPoint(getLocalTransform(), nodePoint);
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
	if (isOn(Node::Updating)) return;
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

void Node::visit(const float* parentWorld)
{
	/* get world matrix */
	float world[16];
	getLocalWorld(world);

	if (_transformTarget)
	{
		float targetWorld[16];
		_transformTarget->getWorld(targetWorld);
		parentWorld = targetWorld;
	}
	bx::mtxMul(world, parentWorld, world);

	if (_children && !_children->isEmpty())
	{
		sortAllChildren();

		/* visit and render child whose order is less than 0 */
		size_t index = 0;
		RefVector<Object>& data = _children->data();
		for (index = 0; index < data.size(); index++)
		{
			Node* node = data[index].to<Node>();
			if (node->getOrder() >= 0) break;
			node->visit(world);
		}

		/* render self */
		render(world);

		/* visit and render child whose order is greater equal than 0 */
		for (; index < data.size(); index++)
		{
			Node* node = data[index].to<Node>();
			node->visit(world);
		}
	}
	else render(world);
}

void Node::render(float* world)
{
	DORA_UNUSED_PARAM(world);
}

const AffineTransform& Node::getLocalTransform()
{
	if (isOn(Node::TransformDirty))
	{
		/* cos(rotateZ), sin(rotateZ) */
		float c = 1, s = 0;
		if (_angle)
		{
			float radians = -bx::toRad(_angle);
			c = std::cos(radians);
			s = std::sin(radians);
		}
		if (_skewX || _skewY)
		{
			/* translateXY, rotateZ, scaleXY */
			_transform = {c * _scaleX, s * _scaleX, -s * _scaleY, c * _scaleY, _position.x, _position.y};

			/* skewXY */
			AffineTransform skewMatrix {
				1.0f, std::tan(bx::toRad(_skewY)),
				std::tan(bx::toRad(_skewX)), 1.0f,
				0.0f, 0.0f};
			_transform = AffineTransform::concat(skewMatrix, _transform);

			/* translateAnchorXY */
			if (_anchorPoint != Vec2::zero)
			{
				_transform = AffineTransform::translate(_transform, -_anchorPoint.x, -_anchorPoint.y);
			}
		}
		else
		{
			/* translateXY, scaleXY, rotateZ, translateAnchorXY */
			float x = _position.x;
			float y = _position.y;
			if (_anchorPoint != Vec2::zero)
			{
				x += c * -_anchorPoint.x * _scaleX + -s * -_anchorPoint.y * _scaleY;
				y += s * -_anchorPoint.x * _scaleX + c * -_anchorPoint.y * _scaleY;
			}
			_transform = {c * _scaleX, s * _scaleX, -s * _scaleY, c * _scaleY, x, y};
		}
		setOff(Node::TransformDirty);
	}
	return _transform;
}

AffineTransform Node::getWorldTransform()
{
	AffineTransform transform = getLocalTransform();
	for (Node* parent = this->getTargetParent();
		parent != nullptr;
		parent = parent->getTargetParent())
	{
		transform = AffineTransform::concat(transform, parent->getLocalTransform());
	}
	return transform;
}

void Node::getLocalWorld(float* localWorld)
{
	if (_angleX || _angleY)
	{
		if (_skewX || _skewY)
		{
			/* cos(rotateZ), sin(rotateZ) */
			float c = 1, s = 0;
			if (_angle)
			{
				float radians = -bx::toRad(_angle);
				c = std::cos(radians);
				s = std::sin(radians);
			}

			/* tanslateXY, scaleXY, rotateZ */
			AffineTransform::toMatrix(
				{c * _scaleX, s * _scaleX, -s * _scaleY, c * _scaleY, _position.x, _position.y},
				localWorld);

			/* translateZ */
			localWorld[14] = _positionZ;

			/* rotateXY */
			float rotate[16];
			bx::mtxRotateXY(rotate, bx::toRad(_angleX), bx::toRad(_angleY));
			bx::mtxMul(localWorld, localWorld, rotate);

			/* skewXY */
			float skewMatrix[16] = {
				1.0f, std::tan(bx::toRad(_skewY)), 0.0f, 0.0f,
				std::tan(bx::toRad(_skewX)), 1.0f, 0.0f, 0.0f,
				0.0f, 0.0f, 1.0f, 0.0f,
				0.0f, 0.0f, 0.0f, 1.0f
			};
			bx::mtxMul(localWorld, localWorld, skewMatrix);

			/* translateAnchorXY */
			if (_anchorPoint != Vec2::zero)
			{
				float translate[16];
				bx::mtxTranslate(translate, -_anchorPoint.x, -_anchorPoint.y, 0);
				bx::mtxMul(localWorld, localWorld, translate);
			}
		}
		else
		{
			/* translateXY, scaleXY, rotateZ, translateAnchorXY */
			AffineTransform transform = getLocalTransform();
			if (_anchorPoint != Vec2::zero)
			{
				/* -translateAnchorXY */
				float translate[16];
				AffineTransform::toMatrix(
					AffineTransform::translate(transform, -_anchorPoint.x, -_anchorPoint.y),
					translate);

				/* translateZ */
				translate[14] = _positionZ;

				/* rotateXY */
				float rotate[16];
				bx::mtxRotateXY(rotate, bx::toRad(_angleX), bx::toRad(_angleY));
				bx::mtxMul(localWorld, translate, rotate);

				/* translateAnchorXY */
				bx::mtxTranslate(translate, _anchorPoint.x, _anchorPoint.y, 0);
				bx::mtxMul(localWorld, localWorld, translate);
			}
			else
			{
				AffineTransform::toMatrix(transform, localWorld);

				/* translateZ */
				localWorld[14] = _positionZ;

				/* rotateXY */
				float rotate[16];
				bx::mtxRotateXY(rotate, bx::toRad(_angleX), bx::toRad(_angleY));
				bx::mtxMul(localWorld, localWorld, rotate);
			}
		}
	}
	else
	{
		/* translateXY, scaleXY, rotateZ, translateAnchorXY */
		AffineTransform transform = getLocalTransform();
		AffineTransform::toMatrix(transform, localWorld);

		/* translateZ */
		localWorld[14] = _positionZ;
	}
}

void Node::getWorld(float* world)
{
	float parentWorld[16];
	getLocalWorld(world);
	for (Node* parent = this->getTargetParent();
		parent != nullptr;
		parent = parent->getTargetParent())
	{
		parent->getLocalWorld(parentWorld);
		bx::mtxMul(world, parentWorld, world);
	}
}

void Node::setOn(Uint32 type)
{
	_flags |= type;
}

void Node::setOff(Uint32 type)
{
	_flags &= ~type;
}

void Node::setFlag(Uint32 type, bool value)
{
	if (value)
	{
		_flags |= type;
	}
	else
	{
		_flags &= ~type;
	}
}

void Node::markDirty()
{
	_flags |= Node::TransformDirty;
}

bool Node::isOn(Uint32 type) const
{
	return (_flags & type) != 0;
}

bool Node::isOff(Uint32 type) const
{
	return !(_flags & type);
}

void Node::sortAllChildren()
{
	if (isOn(Node::Reorder))
	{
		RefVector<Object>& data = _children->data();
		std::stable_sort(data.begin(), data.end(), [](const Ref<>& a, const Ref<>& b)
		{
			return a.to<Node>()->getOrder() < b.to<Node>()->getOrder();
		});
		setOff(Node::Reorder);
	}
}

void Node::updateRealColor3()
{
	if (_parent && _parent->isPassColor3())
	{
		Color parentColor = _parent->_realColor;
		_realColor.r = _color.r * parentColor.r / 255.0f;
		_realColor.g = _color.g * parentColor.g / 255.0f;
		_realColor.b = _color.b * parentColor.b / 255.0f;
	}
	else
	{
		_realColor = _color;
	}
	if (isOn(Node::PassColor3))
	{
		ARRAY_START(Node, child, _children)
		{
			child->updateRealColor3();
		}
		ARRAY_END
	}
}

void Node::updateRealOpacity()
{
	if (_parent && _parent->isPassOpacity())
	{
		float parentOpacity = _parent->_realColor.getOpacity();
		_realColor.setOpacity(_color.getOpacity() * parentOpacity);
	}
	else
	{
		_realColor.setOpacity(_color.getOpacity());
	}
	if (isOn(Node::PassOpacity))
	{
		ARRAY_START(Node, child, _children)
		{
			child->updateRealOpacity();
		}
		ARRAY_END
	}
}

NS_DOROTHY_END

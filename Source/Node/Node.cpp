/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Node.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Input/TouchDispather.h"
#include "Event/Listener.h"
#include "Animation/Action.h"
#include "Basic/Renderer.h"
#include "Input/Keyboard.h"
#include "Basic/View.h"
#include "Basic/Application.h"

NS_DOROTHY_BEGIN

Node::Node():
_flags(
	Node::Visible|
	Node::SelfVisible|Node::ChildrenVisible|
	Node::PassOpacity|Node::PassColor3|
	Node::TraverseEnabled),
_order(0),
_renderOrder(0),
_color(),
_angle(0.0f),
_angleX(0.0f),
_angleY(0.0f),
_scaleX(1.0f),
_scaleY(1.0f),
_skewX(0.0f),
_skewY(0.0f),
_positionZ(0.0f),
_position{},
_anchor{0.5f, 0.5f},
_anchorPoint{},
_size{},
_transform(AffineTransform::Indentity),
_scheduler(SharedDirector.getScheduler()),
_parent(nullptr),
_touchHandler(nullptr)
{
	bx::mtxIdentity(_world);
}

Node::~Node()
{ }

void Node::setOrder(int var)
{
	if (_order != var)
	{
		_order = var;
		markParentReorder();
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

void Node::setAngleX(float var)
{
	_angleX = var;
	markDirty();
}

float Node::getAngleX() const
{
	return _angleX;
}

void Node::setAngleY(float var)
{
	_angleY = var;
	markDirty();
}

float Node::getAngleY() const
{
	return _angleY;
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
	_flags.set(Node::Visible, var);
}

bool Node::isVisible() const
{
	return _flags.isOn(Node::Visible);
}

void Node::setSelfVisible(bool var)
{
	_flags.set(Node::SelfVisible, var);
}

bool Node::isSelfVisible() const
{
	return _flags.isOn(Node::SelfVisible);
}

void Node::setChildrenVisible(bool var)
{
	_flags.set(Node::ChildrenVisible, var);
}

bool Node::isChildrenVisible() const
{
	return _flags.isOn(Node::ChildrenVisible);
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

const Vec2& Node::getAnchorPoint() const
{
	return _anchorPoint;
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

void Node::setTag(String tag)
{
	_tag = tag;
}

const string& Node::getTag() const
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
	_flags.set(Node::PassOpacity, var);
	setOpacity(_color.getOpacity());
}

bool Node::isPassOpacity() const
{
	return _flags.isOn(Node::PassOpacity);
}

void Node::setPassColor3(bool var)
{
	_flags.set(Node::PassColor3, var);
	setColor3(_color.toColor3());
}

bool Node::isPassColor3() const
{
	return _flags.isOn(Node::PassColor3);
}

void Node::setTransformTarget(Node* var)
{
	_transformTarget = var;
	_flags.setOn(Node::WorldDirty);
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

void Node::setRenderOrder(int var)
{
	_renderOrder = var;
}

int Node::getRenderOrder() const
{
	return _renderOrder;
}

void Node::setRenderGroup(bool var)
{
	_flags.set(Node::RenderGrouped, var);
}

bool Node::isRenderGroup() const
{
	return _flags.isOn(Node::RenderGrouped);
}

Uint32 Node::getNodeCount() const
{
	Uint32 count = 1;
	ARRAY_START(Node, child, _children)
	{
		count += child->getNodeCount();
	}
	ARRAY_END
	return count;
}

void Node::onEnter()
{
	ARRAY_START(Node, child, _children)
	{
		child->onEnter();
	}
	ARRAY_END
	_flags.setOn(Node::Running);
	if (isUpdating() || isScheduled())
	{
		_scheduler->schedule(this);
	}
	resumeActionInList(_action);
	markDirty();
	emit("Enter"_slice);
}

void Node::onExit()
{
	ARRAY_START(Node, child, _children)
	{
		child->onExit();
	}
	ARRAY_END
	_flags.setOff(Node::Running);
	if (isUpdating() || isScheduled())
	{
		_scheduler->unschedule(this);
	}
	pauseActionInList(_action);
	emit("Exit"_slice);
}

Array* Node::getChildren() const
{
	return _children;
}

bool Node::hasChildren() const
{
	return _children && !_children->isEmpty();
}

bool Node::isRunning() const
{
	return _flags.isOn(Node::Running);
}

void Node::addChild(Node* child, int order, String tag)
{
	AssertIf(child == nullptr, "add invalid child(nullptr) to node.");
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
		_flags.setOn(Node::Reorder);
	}
	child->_parent = this;
	child->updateRealColor3();
	child->updateRealOpacity();
	if (_flags.isOn(Node::Running))
	{
		child->onEnter();
	}
}

void Node::addChild(Node* child, int order)
{
	AssertIf(child == nullptr, "add invalid child(nullptr) to node.");
	addChild(child, order, child->getTag());
}

void Node::addChild(Node* child)
{
	AssertIf(child == nullptr, "add invalid child(nullptr) to node.");
	addChild(child, child->getOrder(), child->getTag());
}

Node* Node::addTo(Node* parent, int order, String tag)
{
	AssertIf(parent == nullptr, "add node to invalid parent.");
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
	AssertIf(child == nullptr, "remove invalid child (nullptr) from node.");
	AssertIf(child->_parent != this, "can`t remove child node from different parent.");
	if (!_children)
	{
		return;
	}
	Ref<> childRef(child);
	if (_children->remove(child))
	{
		if (_flags.isOn(Node::Running))
		{
			child->onExit();
		}
		if (cleanup)
		{
			child->cleanup();
		}
		child->_parent = nullptr;
	}
}

void Node::removeChildByTag(String tag, bool cleanup)
{
	removeChild(getChildByTag(tag), cleanup);
}

void Node::removeAllChildren(bool cleanup)
{
	ARRAY_START(Node, child, _children)
	{
		if (_flags.isOn(Node::Running))
		{
			child->onExit();
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

void Node::removeFromParent(bool cleanup)
{
	if (_parent) _parent->removeChild(this, cleanup);
}

void Node::cleanup()
{
	if (_flags.isOff(Node::Cleanup))
	{
		_flags.setOn(Node::Cleanup);
		emit("Cleanup"_slice);
		ARRAY_START(Node, child, _children)
		{
			child->cleanup();
		}
		ARRAY_END
		unschedule();
		unscheduleUpdate();
		stopActionInList(_action);
		_userData = nullptr;
		_signal = nullptr;
		if (_flags.isOn(Node::KeyboardEnabled))
		{
			setKeyboardEnabled(false);
		}
		Object::cleanup();
	}
}

Node* Node::getChildByTag(String tag)
{
	Node* targetNode = nullptr;
	traverse([&](Node* child)
	{
		if (child->getTag() == tag)
		{
			targetNode = child;
			return true;
		}
		return false;
	});
	return targetNode;
}

Vec2 Node::convertToNodeSpace(const Vec2& worldPoint)
{
	Matrix invWorld;
	bx::mtxInverse(invWorld, getWorld());
	Vec3 point;
	point = Vec3::from(bx::mul(bx::Vec3{worldPoint.x, worldPoint.y, 0.0f}, invWorld));
	return point.toVec2();
}

Vec2 Node::convertToWorldSpace(const Vec2& nodePoint)
{
	Vec3 point = Vec3::from(bx::mul(bx::Vec3{nodePoint.x, nodePoint.y, 0.0f}, getWorld()));
	return point.toVec2();
}

Vec3 Node::convertToNodeSpace3(const Vec3& worldPoint)
{
	Matrix invWorld;
	bx::mtxInverse(invWorld, getWorld());
	return Vec3::from(bx::mul(worldPoint, invWorld));
}

Vec3 Node::convertToWorldSpace3(const Vec3& nodePoint)
{
	Vec3 point = Vec3::from(bx::mul(nodePoint, getWorld()));
	return point;
}

bool Node::isScheduled() const
{
	return _flags.isOn(Node::Scheduling);
}

void Node::setTouchEnabled(bool var)
{
	if (!_touchHandler)
	{
		_touchHandler = New<NodeTouchHandler>(this);
		_touchHandler->setSwallowTouches(_flags.isOn(Node::SwallowTouches));
	}
	_flags.set(Node::TouchEnabled, var);
}

bool Node::isTouchEnabled() const
{
	return _flags.isOn(Node::TouchEnabled);
}

void Node::setSwallowTouches(bool var)
{
	_flags.set(Node::SwallowTouches, var);
	if (_touchHandler)
	{
		_touchHandler->setSwallowTouches(var);
	}
}

bool Node::isSwallowTouches() const
{
	return _flags.isOn(Node::SwallowTouches);
}

void Node::setSwallowMouseWheel(bool var)
{
	_flags.set(Node::SwallowMouseWheel, var);
	if (_touchHandler)
	{
		_touchHandler->setSwallowMouseWheel(var);
	}
}

bool Node::isSwallowMouseWheel() const
{
	return _flags.isOn(Node::SwallowMouseWheel);
}

TouchHandler* Node::getTouchHandler() const
{
	return _touchHandler;
}

void Node::schedule(const function<bool(double)>& func)
{
	_scheduleFunc = func;
	if (_flags.isOff(Node::Scheduling))
	{
		_flags.setOn(Node::Scheduling);
		if (_flags.isOff(Node::Updating) && _flags.isOn(Node::Running))
		{
			_scheduler->schedule(this);
		}
	}
}

void Node::unschedule()
{
	if (_flags.isOn(Node::Scheduling))
	{
		_flags.setOff(Node::Scheduling);
		if (_flags.isOff(Node::Updating))
		{
			_scheduler->unschedule(this);
		}
		_scheduleFunc = nullptr;
	}
}

bool Node::isUpdating() const
{
	return _flags.isOn(Node::Updating);
}

void Node::scheduleUpdate()
{
	if (_flags.isOff(Node::Updating))
	{
		_flags.setOn(Node::Updating);
		if (_flags.isOff(Node::Scheduling) && _flags.isOn(Node::Running))
		{
			_scheduler->schedule(this);
		}
	}
}

void Node::unscheduleUpdate()
{
	if (_flags.isOn(Node::Updating))
	{
		_flags.setOff(Node::Updating);
		if (_flags.isOff(Node::Scheduling))
		{
			_scheduler->unschedule(this);
		}
	}
}

bool Node::update(double deltaTime)
{
	bool result = true;
	if (isScheduled() && _scheduleFunc)
	{
		result = _scheduleFunc(deltaTime);
		if (result) unschedule();
	}
	return result && !isUpdating();
}

void Node::visit()
{
	if (_flags.isOff(Node::Visible))
	{
		return;
	}

	/* get world matrix */
	getWorld();

	auto& rendererManager = SharedRendererManager;
	if (_children && !_children->isEmpty() && _flags.isOn(Node::ChildrenVisible))
	{
		sortAllChildren();

		auto visitChildren = [&]()
		{
			/* visit and render child whose order is less than 0 */
			size_t index = 0;
			RefVector<Object>& data = _children->data();
			for (index = 0; index < data.size(); index++)
			{
				Node* node = data[index].to<Node>();
				if (node->getOrder() >= 0) break;
				node->visit();
			}

			/* render self */
			if (_flags.isOn(Node::SelfVisible))
			{
				if (rendererManager.isGrouping() && _renderOrder != 0)
				{
					rendererManager.pushGroupItem(this);
				}
				else render();
			}

			/* visit and render child whose order is greater equal than 0 */
			for (; index < data.size(); index++)
			{
				Node* node = data[index].to<Node>();
				node->visit();
			}
		};

		if (_flags.isOn(Node::RenderGrouped))
		{
			rendererManager.pushGroup(getNodeCount(), visitChildren);
		}
		else visitChildren();
	}
	else if (_flags.isOn(Node::SelfVisible))
	{
		if (rendererManager.isGrouping() && _renderOrder != 0)
		{
			rendererManager.pushGroupItem(this);
		}
		else render();
	}
}

void Node::render()
{ }

const AffineTransform& Node::getLocalTransform()
{
	if (_flags.isOn(Node::TransformDirty))
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
		_flags.setOff(Node::TransformDirty);
	}
	return _transform;
}

void Node::getLocalWorld(Matrix& localWorld)
{
	if (_angleX || _angleY)
	{
		AffineTransform transform = getLocalTransform();
		/* translateXY, scaleXY, rotateZ, translateAnchorXY */
		if (_anchorPoint != Vec2::zero)
		{
			Matrix mtxRoted;
			{
				/* -translateAnchorXY */
				Matrix mtxBase;
				AffineTransform::toMatrix(AffineTransform::translate(transform, _anchorPoint.x, _anchorPoint.y), mtxBase);

				/* translateZ */
				mtxBase.m[14] = _positionZ;

				/* rotateXY */
				Matrix mtxRot;
				bx::mtxRotateXY(mtxRot, -bx::toRad(_angleX), -bx::toRad(_angleY));
				bx::mtxMul(mtxRoted, mtxRot, mtxBase);
			}

			/* translateAnchorXY */
			Matrix mtxAnchor;
			bx::mtxTranslate(mtxAnchor, -_anchorPoint.x, -_anchorPoint.y, 0.0f);
			bx::mtxMul(localWorld, mtxAnchor, mtxRoted);
		}
		else
		{
			Matrix mtxBase;
			AffineTransform::toMatrix(transform, mtxBase);

			/* translateZ */
			mtxBase.m[14] = _positionZ;

			/* rotateXY */
			Matrix mtxRot;
			bx::mtxRotateXY(mtxRot, -bx::toRad(_angleX), -bx::toRad(_angleY));
			bx::mtxMul(localWorld, mtxRot, mtxBase);
		}
	}
	else
	{
		/* translateXY, scaleXY, rotateZ, translateAnchorXY */
		AffineTransform transform = getLocalTransform();
		AffineTransform::toMatrix(transform, localWorld);

		/* translateZ */
		localWorld.m[14] = _positionZ;
	}
}

const Matrix& Node::getWorld()
{
	if (_flags.isOn(Node::WorldDirty))
	{
		_flags.setOff(WorldDirty);
		Matrix localWorld;
		getLocalWorld(localWorld);
		const Matrix* parentWorld = &Matrix::Indentity;
		if (_transformTarget)
		{
			parentWorld = &_transformTarget->getWorld();
			_flags.setOn(Node::WorldDirty);
		}
		else if (_parent)
		{
			parentWorld = &_parent->getWorld();
		}
		bx::mtxMul(_world, localWorld, *parentWorld);
		ARRAY_START(Node, child, _children)
		{
			child->_flags.setOn(Node::WorldDirty);
		}
		ARRAY_END
	}
	return _world;
}

void Node::emit(Event* event)
{
	if (_signal)
	{
		_signal->emit(event);
	}
}

Slot* Node::slot(String name)
{
	if (!_signal)
	{
		_signal = New<Signal>();
	}
	return _signal->addSlot(name, EventHandler());
}

Slot* Node::slot(String name, const EventHandler& handler)
{
	if (!_signal)
	{
		_signal = New<Signal>();
	}
	return _signal->addSlot(name, handler);
}

void Node::slot(String name, std::nullptr_t)
{
	if (_signal)
	{
		_signal->removeSlots(name);
	}
}

Listener* Node::gslot(String name, const EventHandler& handler)
{
	if (!_signal)
	{
		_signal = New<Signal>();
	}
	return _signal->addGSlot(name, handler);
}

void Node::gslot(String name, std::nullptr_t)
{
	if (_signal)
	{
		_signal->removeGSlots(name);
	}
}

void Node::gslot(Listener* listener, std::nullptr_t)
{
	if (_signal)
	{
		_signal->removeGSlot(listener);
	}
}

RefVector<Listener> Node::gslot(String name)
{
	if (_signal)
	{
		return _signal->getGSlots(name);
	}
	return RefVector<Listener>();
}

void Node::markDirty()
{
	_flags.setOn(Node::TransformDirty);
	_flags.setOn(Node::WorldDirty);
}

void Node::sortAllChildren()
{
	if (_flags.isOn(Node::Reorder))
	{
		RefVector<Object>& data = _children->data();
		std::stable_sort(data.begin(), data.end(), [](const Ref<>& a, const Ref<>& b)
		{
			return a.to<Node>()->getOrder() < b.to<Node>()->getOrder();
		});
		_flags.setOff(Node::Reorder);
	}
}

void Node::markParentReorder()
{
	if (_parent) _parent->_flags.setOn(Node::Reorder);
}

void Node::updateRealColor3()
{
	if (_parent && _parent->isPassColor3())
	{
		Color parentColor = _parent->_realColor;
		_realColor.r = s_cast<Uint8>(_color.r * parentColor.r / 255.0f);
		_realColor.g = s_cast<Uint8>(_color.g * parentColor.g / 255.0f);
		_realColor.b = s_cast<Uint8>(_color.b * parentColor.b / 255.0f);
	}
	else
	{
		_realColor = _color;
	}
	if (_flags.isOn(Node::PassColor3))
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
	if (_flags.isOn(Node::PassOpacity))
	{
		ARRAY_START(Node, child, _children)
		{
			child->updateRealOpacity();
		}
		ARRAY_END
	}
}

int Node::getActionCount() const
{
	int count = 0;
	for (Action* action = _action; action; action = action->_next)
	{
		count++;
	}
	return count;
}

void Node::runAction(Action* action)
{
	if (!action) return;
	if (action->isRunning())
	{
		stopAction(action);
	}
	action->_target = this;
	action->_prev = nullptr;
	if (_action)
	{
		action->_next = _action;
		_action->_prev = action;
		_action = action;
	}
	else
	{
		action->_next = nullptr;
		_action = action;
	}
	_action->_eclapsed = 0.0f;
	_action->resume();
	if (isRunning())
	{
		_scheduler->schedule(action);
	}
}

void Node::stopAllActions()
{
	stopActionInList(_action);
}

void Node::perform(Action* action)
{
	stopAllActions();
	runAction(action);
}

bool Node::hasAction(Action* action)
{
	bool found = false;
	for (Action* ac = _action; ac; ac = ac->_next)
	{
		if (ac == action)
		{
			found = true;
			break;
		}
	}
	return found;
}

void Node::removeAction(Action* action)
{
	if (!hasAction(action)) return;
	if (_action == action)
	{
		if (action->_next)
		{
			_action = action->_next;
			_action->_prev = nullptr;
		}
		else
		{
			_action = nullptr;
		}
	}
	else
	{
		if (action->_prev)
		{
			action->_prev->_next = action->_next;
		}
	}
	action->_prev = nullptr;
	action->_next = nullptr;
}

void Node::stopAction(Action* action)
{
	if (hasAction(action))
	{
		_scheduler->unschedule(action);
		removeAction(action);
	}
}

void Node::pauseActionInList(Action* action)
{
	if (action)
	{
		pauseActionInList(action->_next);
		_scheduler->unschedule(action);
	}
}

void Node::resumeActionInList(Action* action)
{
	if (action)
	{
		resumeActionInList(action->_next);
		_scheduler->schedule(action);
	}
}

void Node::stopActionInList(Action* action)
{
	if (action)
	{
		Ref<> ref(action);
		stopActionInList(action->_next);
		_scheduler->unschedule(action);
		removeAction(action);
	}
}

Size Node::alignItemsVertically(float padding)
{
	return alignItemsVertically(getSize(), padding);
}

Size Node::alignItemsVertically(const Size& size, float padding)
{
	float width = size.width;
	float y = size.height - padding;
	ARRAY_START(Node, child, _children)
	{
		float realWidth = child->getWidth() * child->getScaleX();
		float realHeight = child->getHeight() * child->getScaleY();
		if (realWidth == 0.0f || realHeight == 0.0f) continue;
		float realPosY = (1.0f - child->getAnchor().y) * realHeight;
		y -= realPosY;
		child->setX(width * 0.5f - (0.5f - child->getAnchor().x) * realWidth);
		child->setY(y);
		y -= child->getAnchor().y * realHeight;
		y -= padding;
	}
	ARRAY_END
	return _children && !_children->isEmpty() ? Size{size.width, size.height - y} : Size::zero;
}

Size Node::alignItemsHorizontally(float padding)
{
	return alignItemsHorizontally(getSize(), padding);
}

Size Node::alignItemsHorizontally(const Size& size, float padding)
{
	float height = size.height;
	float x = padding;
	ARRAY_START(Node, child, _children)
	{
		float realWidth = child->getWidth() * child->getScaleX();
		float realHeight = child->getHeight() * child->getScaleY();
		if (realWidth == 0.0f || realHeight == 0.0f) continue;
		float realPosX = child->getAnchor().x * realWidth;
		x += realPosX;
		child->setX(x);
		child->setY(height * 0.5f - (0.5f - child->getAnchor().y) * realHeight);
		x += (1.0f - child->getAnchor().x) * realWidth;
		x += padding;
	}
	ARRAY_END
	return _children && !_children->isEmpty() ? Size{x, size.height} : Size::zero;
}

Size Node::alignItems(float padding)
{
	return alignItems(getSize(), padding);
}

Size Node::alignItems(const Size& size, float padding)
{
	float height = size.height;
	float width = size.width;
	float x = padding;
	float y = height - padding;
	int rows = 0;
	float curY = y;
	float maxX = 0;
	ARRAY_START(Node, child, _children)
	{
		float realWidth = child->getWidth() * child->getScaleX();
		float realHeight = child->getHeight() * child->getScaleY();

		if (realWidth == 0.0f || realHeight == 0.0f) continue;

		if (x + realWidth + padding > width)
		{
			x = padding;
			rows++;
			y = curY - padding;
		}
		float realPosX = child->getAnchor().x * realWidth;
		x += realPosX;

		float realPosY = (1.0f - child->getAnchor().y) * realHeight;

		child->setX(x);
		child->setY(y - realPosY);

		x += (1.0f - child->getAnchor().x) * realWidth;
		x += padding;
		
		maxX = std::max(maxX, x);

		if (curY > y - realHeight)
		{
			curY = y - realHeight;
		}
	}
	ARRAY_END
	return _children && !_children->isEmpty() ? Size{maxX, height - curY + 10.0f} : Size::zero;
}

void Node::moveAndCullItems(const Vec2& delta)
{
	Rect contentRect(Vec2::zero, getSize());
	ARRAY_START(Node, child, _children)
	{
		child->setPosition(child->getPosition() + delta);
		const Vec2& pos = child->getPosition();
		const Size& size = child->getSize();
		const Vec2& anchor = child->getAnchor();
		Rect childRect(
			pos.x - size.width * anchor.x,
			pos.y - size.height * anchor.y,
			size.width,
			size.height);
		if (childRect.size != Size::zero)
		{
			child->setVisible(contentRect.intersectsRect(childRect));
		}
	}
	ARRAY_END
}

void Node::handleKeyboard(Event* event)
{
	emit(event);
}

void Node::setKeyboardEnabled(bool var)
{
	if (var == _flags.isOn(Node::KeyboardEnabled)) return;
	_flags.set(Node::KeyboardEnabled, var);
	if (var)
	{
		SharedKeyboard.KeyHandler += std::make_pair(this, &Node::handleKeyboard);
	}
	else
	{
		SharedKeyboard.KeyHandler -= std::make_pair(this, &Node::handleKeyboard);
	}
}

bool Node::isKeyboardEnabled() const
{
	return _flags.isOn(Node::KeyboardEnabled);
}

void Node::attachIME()
{
	WRef<Node> self(this);
	SharedKeyboard.attachIME([self](Event* e)
	{
		if (self) self->emit(e);
	});
}

void Node::detachIME()
{
	SharedKeyboard.detachIME();
}


static void transform_point(float out[4], const float m[16], const float in[4])
{
	#define M(row,col) m[col*4+row]
	out[0] = M(0, 0) * in[0] + M(0, 1) * in[1] + M(0, 2) * in[2] + M(0, 3) * in[3];
	out[1] = M(1, 0) * in[0] + M(1, 1) * in[1] + M(1, 2) * in[2] + M(1, 3) * in[3];
	out[2] = M(2, 0) * in[0] + M(2, 1) * in[1] + M(2, 2) * in[2] + M(2, 3) * in[3];
	out[3] = M(3, 0) * in[0] + M(3, 1) * in[1] + M(3, 2) * in[2] + M(3, 3) * in[3];
	#undef M
}

static bool project(float objx, float objy, float objz,
	const float model[16], const float proj[16],
	const float viewport[4],
	float* winx, float* winy, float* winz)
{
	/* matrice de transformation */
	float in[4], out[4];
	/* initilise la matrice et le vecteur a transformer */
	in[0] = objx;
	in[1] = objy;
	in[2] = objz;
	in[3] = 1.0;
	transform_point(out, model, in);
	transform_point(in, proj, out);
	/* d’ou le resultat normalise entre -1 et 1 */
	if (in[3] == 0.0) return false;
	in[0] /= in[3];
	in[1] /= in[3];
	in[2] /= in[3];
	/* en coordonnees ecran */
	*winx = viewport[0] + (1 + in[0]) * viewport[2] / 2;
	*winy = viewport[1] + (1 + in[1]) * viewport[3] / 2;
	/* entre 0 et 1 suivant z */
	*winz = (1 + in[2]) / 2;
	return true;
}

class ProjectNode : public Node
{
public:
	virtual void render() override
	{
		Size viewSize = SharedView.getSize();
		float viewPort[4]{0, 0, viewSize.width, viewSize.height};
		float winX, winY, winZ;
		if (project(_nodePoint.x, _nodePoint.y, 0, getWorld(), SharedDirector.getViewProjection(), viewPort, &winX, &winY, &winZ))
		{
			Size winSize = SharedApplication.getWinSize();
			winX = winX * winSize.width / viewSize.width;
			winY = winY * winSize.height / viewSize.height;
			if (SharedView.getName() != "UI"_slice)
			{
				winY = winSize.height - winY;
			}
			_convertHandler(Vec2{winX, winY});
		}
		schedule([this](double deltaTime)
		{
			Node* parent = getParent();
			if (parent)
			{
				parent->removeChild(this);
			}
			return true;
		});
	}
	CREATE_FUNC(ProjectNode);
protected:
	ProjectNode(const Vec2& nodePoint, const function<void(const Vec2&)>& convertHandler):
	_nodePoint(nodePoint),
	_convertHandler(convertHandler)
	{ }
private:
	Vec2 _nodePoint;
	function<void(const Vec2&)> _convertHandler;
};

void Node::convertToWindowSpace(const Vec2& nodePoint, const function<void(const Vec2&)>& callback)
{
	addChild(ProjectNode::create(nodePoint, callback));
}

/* Slot */

Slot::Slot(const EventHandler& handler):
_handler(handler)
{ }

void Slot::add(const EventHandler& handler)
{
	_handler += handler;
}

void Slot::set(const EventHandler& handler)
{
	_handler = handler;
}

void Slot::remove(const EventHandler& handler)
{
	_handler -= handler;
}

void Slot::clear()
{
	_handler = nullptr;
}

void Slot::handle(Event* event)
{
	_handler(event);
}

/* Signal */

const size_t Signal::MaxSlotArraySize = 5;

Slot* Signal::addSlot(String name, const EventHandler& handler)
{
	if (_slots)
	{
		auto it = _slots->find(name);
		if (it != _slots->end())
		{
			it->second->add(handler);
			return it->second;
		}
		else
		{
			Slot* slot = Slot::create(handler);
			(*_slots)[name] = slot;
			return slot;
		}
	}
	else if (_slotsArray)
	{
		for (auto& item : *_slotsArray)
		{
			if (name == item.first)
			{
				item.second->add(handler);
				return item.second;
			}
		}
		if (_slotsArray->size() < Signal::MaxSlotArraySize)
		{
			Slot* slot = Slot::create(handler);
			_slotsArray->push_back(
				std::make_pair(name.toString(), MakeRef(slot)));
			return slot;
		}
		else
		{
			_slots = New<unordered_map<string, Ref<Slot>>>();
			for (auto& item : *_slotsArray)
			{
				(*_slots)[item.first] = item.second;
			}
			Slot* slot = Slot::create(handler);
			(*_slots)[name] = slot;
			_slotsArray = nullptr;
			return slot;
		}
	}
	else
	{
		_slotsArray = New<vector<std::pair<string, Ref<Slot>>>>(MaxSlotArraySize);
		Slot* slot = Slot::create(handler);
		_slotsArray->push_back(std::make_pair(name.toString(), MakeRef(slot)));
		return slot;
	}
}

Listener* Signal::addGSlot(String name, const EventHandler& handler)
{
	Listener* gslot = Listener::create(name, handler);
	_gslots.push_back(gslot);
	return gslot;
}

void Signal::removeSlot(String name, const EventHandler& handler)
{
	if (_slots)
	{
		auto it = _slots->find(name);
		if (it != _slots->end())
		{
			it->second->remove(handler);
			return;
		}
	}
	else if (_slotsArray)
	{
		for (auto& item : *_slotsArray)
		{
			if (name == item.first)
			{
				item.second->remove(handler);
				return;
			}
		}
	}
}

void Signal::removeGSlot(Listener* gslot)
{
	_gslots.remove(gslot);
}

void Signal::removeSlots(String name)
{
	if (_slots)
	{
		auto it = _slots->find(name);
		if (it != _slots->end())
		{
			it->second->clear();
			return;
		}
	}
	else if (_slotsArray)
	{
		for (auto it = _slotsArray->begin(); it != _slotsArray->end(); ++it)
		{
			if (name == it->first)
			{
				_slotsArray->erase(it);
				return;
			}
		}
	}
}

void Signal::removeGSlots(String name)
{
	_gslots.erase(std::remove_if(_gslots.begin(), _gslots.end(), [&name](const Ref<Listener>& gslot)
	{
		return name == gslot->getName();
	}), _gslots.end());
}

RefVector<Listener> Signal::getGSlots(String name) const
{
	RefVector<Listener> listeners;
	for (const auto& item : _gslots)
	{
		if (name == item->getName())
		{
			listeners.push_back(item);
		}
	}
	return listeners;
}

void Signal::emit(Event* event)
{
	if (_slots)
	{
		auto it = _slots->find(event->getName());
		if (it != _slots->end())
		{
			it->second->handle(event);
		}
	}
	else if (_slotsArray)
	{
		for (auto& item : *_slotsArray)
		{
			if (event->getName() == item.first)
			{
				item.second->handle(event);
				return;
			}
		}
	}
}

NS_DOROTHY_END

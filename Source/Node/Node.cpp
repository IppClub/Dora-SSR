/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Node.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Input/TouchDispather.h"
#include "Node/Sprite.h"
#include "Event/Listener.h"

NS_DOROTHY_BEGIN

Node::Node():
_flags(Node::Visible|Node::PassOpacity|Node::PassColor3|Node::SwallowTouches|Node::TraverseEnabled),
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
		if (_parent)
		{
			_parent->_flags.setOn(Node::Reorder);
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
	_flags.setFlag(Node::Visible, var);
}

bool Node::isVisible() const
{
	return _flags.isOn(Node::Visible);
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

void Node::setName(const string& name)
{
	_name = name;
}

const string& Node::getName() const
{
	return _name;
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
	_flags.setFlag(Node::PassOpacity, var);
	setOpacity(_color.getOpacity());
}

bool Node::isPassOpacity() const
{
	return _flags.isOn(Node::PassOpacity);
}

void Node::setPassColor3(bool var)
{
	_flags.setFlag(Node::PassColor3, var);
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

void Node::onEnter()
{
	ARRAY_START(Node, child, _children)
	{
		child->onEnter();
	}
	ARRAY_END
	_flags.setOn(Node::Running);
	if (isUpdating())
	{
		_scheduler->schedule(this);
	}
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
	if (isUpdating())
	{
		_scheduler->unschedule(this);
	}
	emit("Exit"_slice);
}

Array* Node::getChildren() const
{
	return _children;
}

bool Node::isRunning() const
{
	return _flags.isOn(Node::Running);
}

void Node::addChild(Node* child, int order, String name)
{
	AssertIf(child == nullptr, "add invalid child to node.");
	AssertIf(child->_parent, "child already added. It can't be added again.");
	child->setName(name);
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
	addChild(child, order, child->getName());
}

void Node::addChild(Node* child)
{
	addChild(child, child->getOrder(), child->getName());
}

Node* Node::addTo(Node* parent, int order, String name)
{
	AssertIf(parent == nullptr, "add node to invalid parent.");
	parent->addChild(this, order, name);
	return this;
}

Node* Node::addTo(Node* parent, int zOrder)
{
	return addTo(parent, zOrder, getName());
}

Node* Node::addTo(Node* parent)
{
	return addTo(parent, getOrder(), getName());
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

void Node::removeChildByName(String name, bool cleanup)
{
	removeChild(getChildByName(name), cleanup);
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
		_userData = nullptr;
		_signal = nullptr;
	}
}

Node* Node::getChildByName(String name)
{
	Node* targetNode = nullptr;
	ARRAY_START(Node, child, _children)
	{
		if (name == child->getName())
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
	return AffineTransform::applyPoint(AffineTransform::invert(getWorldTransform()), worldPoint);
}

Vec2 Node::convertToWorldSpace(const Vec2& nodePoint)
{
	return AffineTransform::applyPoint(getWorldTransform(), nodePoint);
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
	_flags.setFlag(Node::TouchEnabled, var);
}

bool Node::isTouchEnabled() const
{
	return _flags.isOn(Node::TouchEnabled);
}

void Node::setSwallowTouches(bool var)
{
	_flags.setFlag(Node::SwallowTouches, var);
	if (_touchHandler)
	{
		_touchHandler->setSwallowTouches(var);
	}
}

bool Node::isSwallowTouches() const
{
	return _flags.isOn(Node::SwallowTouches);
}

TouchHandler* Node::getTouchHandler() const
{
	return _touchHandler;
}

void Node::schedule(const function<bool(double)>& func)
{
	_scheduleFunc = func;
	if (_flags.isOn(Node::Scheduling))
	{
		return;
	}
	if (_flags.isOn(Node::Updating))
	{
		_flags.setOn(Node::Scheduling);
		return;
	}
	_scheduler->schedule(this);
}

void Node::unschedule()
{
	_scheduleFunc = nullptr;
	_flags.setOff(Node::Scheduling);
	if (_flags.isOff(Node::Updating))
	{
		_scheduler->unschedule(this);
	}
}

bool Node::isUpdating() const
{
	return _flags.isOn(Node::Updating) || _flags.isOn(Node::Scheduling);
}

void Node::scheduleUpdate()
{
	if (_flags.isOn(Node::Updating)) return;
	if (_flags.isOn(Node::Scheduling))
	{
		_flags.setOn(Node::Updating);
		return;
	}
	_flags.setOn(Node::Updating);
	_scheduler->schedule(this);
}

void Node::unscheduleUpdate()
{
	if (_flags.isOn(Node::Updating) || _flags.isOn(Node::Scheduling))
	{
		_flags.setOff(Node::Updating);
		_flags.setOff(Node::Scheduling);
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
	if (_flags.isOff(Node::Visible))
	{
		return;
	}

	/* get world matrix */
	getWorld();

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
			node->visit();
		}

		/* render self */
		render();

		/* visit and render child whose order is greater equal than 0 */
		for (; index < data.size(); index++)
		{
			Node* node = data[index].to<Node>();
			node->visit();
		}
	}
	else render();
}

void Node::render()
{
	SharedSpriteRenderer.render();
}

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
		/* translateXY, scaleXY, rotateZ, translateAnchorXY */
		AffineTransform transform = getLocalTransform();
		if (_anchorPoint != Vec2::zero)
		{
			/* -translateAnchorXY */
			float mtxBase[16];
			{
				AffineTransform::toMatrix(transform, mtxBase);
				/* translateZ */
				mtxBase[14] = _positionZ;
			}

			/* rotateXY */
			float mtxRot[16];
			bx::mtxRotateXY(mtxRot, -bx::toRad(_angleX), -bx::toRad(_angleY));
			bx::mtxMul(localWorld, mtxBase, mtxRot);
		}
		else
		{
			float mtxBase[16];
			{
				AffineTransform::toMatrix(transform, mtxBase);
				/* translateZ */
				mtxBase[14] = _positionZ;
			}

			/* rotateXY */
			float mtxRot[16];
			bx::mtxRotateXY(mtxRot, -bx::toRad(_angleX), -bx::toRad(_angleY));
			bx::mtxMul(localWorld, mtxBase, mtxRot);
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

const float* Node::getWorld()
{
	if (_flags.isOn(Node::WorldDirty))
	{
		_flags.setOff(WorldDirty);
		float localWorld[16];
		getLocalWorld(localWorld);
		const float* parentWorld;
		if (_transformTarget)
		{
			parentWorld = _transformTarget->getWorld();
			_flags.setOn(Node::WorldDirty);
		}
		else if (_parent)
		{
			parentWorld = _parent->getWorld();
		}
		else
		{
			parentWorld = Matrix::Indentity;
		}
		bx::mtxMul(_world, localWorld, parentWorld);
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

/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Node.h"

#include "Animation/Action.h"
#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Effect/Effect.h"
#include "Event/Listener.h"
#include "Input/Controller.h"
#include "Input/Keyboard.h"
#include "Input/TouchDispather.h"
#include "Node/DrawNode.h"
#include "Node/Grid.h"
#include "Node/Sprite.h"
#include "Render/Camera.h"
#include "Render/RenderTarget.h"
#include "Render/Renderer.h"
#include "Render/View.h"
#include "Support/Dictionary.h"

NS_DORA_BEGIN

#define GetTAttr(name) (_transform ? _transform->name : Node::NodeTransform::Default.name)
#define SetTAttr(name, value) getTransform().name = value

Node::NodeTransform::NodeTransform()
	: x(0.0f)
	, y(0.0f)
	, z(0.0f)
	, angle(0.0f)
	, angleX(0.0f)
	, angleY(0.0f)
	, scaleX(1.0f)
	, scaleY(1.0f)
	, scaleZ(1.0f)
	, skewX(0.0f)
	, skewY(0.0f)
	, anchorX(0.5f)
	, anchorY(0.5f)
	, anchorPointX(0.0f)
	, anchorPointY(0.0f)
	, width(0.0f)
	, height(0.0f)
	, transform(AffineTransform::Indentity) {
	bx::mtxIdentity(world.m);
}

Node::NodeTransform& Node::getTransform() {
	if (!_transform) {
		_transform = New<NodeTransform>();
	}
	return *_transform;
}

Node::NodeTransform Node::NodeTransform::Default;

Node::Node(bool unManaged)
	: _flags(
		  Node::Visible | Node::SelfVisible | Node::ChildrenVisible | Node::PassOpacity | Node::PassColor3 | Node::TraverseEnabled)
	, _order(0)
	, _renderOrder(0)
	, _color()
	, _scheduler(SharedDirector.getScheduler())
	, _parent(nullptr)
	, _touchHandler(nullptr) {
	if (unManaged) {
		_flags.setOn(Node::UnManaged);
		SharedDirector.addUnManagedNode(this);
	}
}

Node::~Node() {
	setAsManaged();
}

void Node::setOrder(int var) {
	if (_order != var) {
		_order = var;
		markParentReorder();
	}
}

int Node::getOrder() const noexcept {
	return _order;
}

void Node::setAngle(float var) {
	SetTAttr(angle, var);
	markDirty();
}

float Node::getAngle() const noexcept {
	return GetTAttr(angle);
}

void Node::setAngleX(float var) {
	SetTAttr(angleX, var);
	markDirty();
}

float Node::getAngleX() const noexcept {
	return GetTAttr(angleX);
}

void Node::setAngleY(float var) {
	SetTAttr(angleY, var);
	markDirty();
}

float Node::getAngleY() const noexcept {
	return GetTAttr(angleY);
}

void Node::setScaleX(float var) {
	SetTAttr(scaleX, var);
	markDirty();
}

float Node::getScaleX() const noexcept {
	return GetTAttr(scaleX);
}

void Node::setScaleY(float var) {
	SetTAttr(scaleY, var);
	markDirty();
}

float Node::getScaleY() const noexcept {
	return GetTAttr(scaleY);
}

void Node::setScaleZ(float var) {
	SetTAttr(scaleZ, var);
	markDirty();
}

float Node::getScaleZ() const noexcept {
	return GetTAttr(scaleZ);
}

void Node::setX(float var) {
	setPosition({var, getY()});
}

float Node::getX() const noexcept {
	return GetTAttr(x);
}

void Node::setY(float var) {
	setPosition({getX(), var});
}

float Node::getY() const noexcept {
	return GetTAttr(y);
}

void Node::setZ(float var) {
	SetTAttr(z, var);
	markDirty();
}

float Node::getZ() const noexcept {
	return GetTAttr(z);
}

void Node::setPosition(Vec2 var) {
	auto& transform = getTransform();
	transform.x = var.x;
	transform.y = var.y;
	markDirty();
}

Vec2 Node::getPosition() const noexcept {
	if (_transform) return {_transform->x, _transform->y};
	return Vec2::zero;
}

void Node::setSkewX(float var) {
	SetTAttr(skewX, var);
	markDirty();
}

float Node::getSkewX() const noexcept {
	return GetTAttr(skewX);
}

void Node::setSkewY(float var) {
	SetTAttr(skewY, var);
	markDirty();
}

float Node::getSkewY() const noexcept {
	return GetTAttr(skewY);
}

void Node::setVisible(bool var) {
	_flags.set(Node::Visible, var);
}

bool Node::isVisible() const noexcept {
	return _flags.isOn(Node::Visible);
}

void Node::setSelfVisible(bool var) {
	_flags.set(Node::SelfVisible, var);
}

bool Node::isSelfVisible() const noexcept {
	return _flags.isOn(Node::SelfVisible);
}

void Node::setChildrenVisible(bool var) {
	_flags.set(Node::ChildrenVisible, var);
}

bool Node::isChildrenVisible() const noexcept {
	return _flags.isOn(Node::ChildrenVisible);
}

void Node::setAnchor(Vec2 var) {
	auto& transform = getTransform();
	transform.anchorX = var.x;
	transform.anchorY = var.y;
	transform.anchorPointX = var.x * transform.width;
	transform.anchorPointY = var.y * transform.height;
	markDirty();
}

Vec2 Node::getAnchor() const noexcept {
	if (_transform) return {_transform->anchorX, _transform->anchorY};
	return {0.5f, 0.5f};
}

Vec2 Node::getAnchorPoint() const noexcept {
	if (_transform) return {_transform->anchorPointX, _transform->anchorPointY};
	return Vec2::zero;
}

void Node::setWidth(float var) {
	auto& transform = getTransform();
	transform.width = var;
	transform.anchorPointX = transform.anchorX * var;
	markDirty();
}

float Node::getWidth() const noexcept {
	return GetTAttr(width);
}

void Node::setHeight(float var) {
	auto& transform = getTransform();
	transform.height = var;
	transform.anchorPointY = transform.anchorY * var;
	markDirty();
}

float Node::getHeight() const noexcept {
	return GetTAttr(height);
}

void Node::setSize(Size var) {
	auto& transform = getTransform();
	transform.width = var.width;
	transform.height = var.height;
	transform.anchorPointX = transform.anchorX * var.width;
	transform.anchorPointY = transform.anchorY * var.height;
	markDirty();
}

Size Node::getSize() const noexcept {
	return _transform ? Size{_transform->width, _transform->height} : Size::zero;
}

void Node::setTag(String tag) {
	if (!tag.empty()) {
		_tag = tag.toString();
	}
}

const std::string& Node::getTag() const noexcept {
	return _tag ? _tag.value() : Slice::Empty;
}

void Node::setOpacity(float var) {
	_color.setOpacity(var);
	updateRealOpacity();
}

float Node::getOpacity() const noexcept {
	return _color.getOpacity();
}

float Node::getRealOpacity() const noexcept {
	return _realColor.getOpacity();
}

void Node::setColor(Color var) {
	_color = var;
	updateRealColor3();
	updateRealOpacity();
}

Color Node::getColor() const noexcept {
	return _color;
}

void Node::setColor3(Color3 var) {
	_color = var;
	updateRealColor3();
}

Color3 Node::getColor3() const noexcept {
	return _color.toColor3();
}

Color Node::getRealColor() const noexcept {
	return _realColor;
}

void Node::setPassOpacity(bool var) {
	_flags.set(Node::PassOpacity, var);
	setOpacity(_color.getOpacity());
}

bool Node::isPassOpacity() const noexcept {
	return _flags.isOn(Node::PassOpacity);
}

void Node::setPassColor3(bool var) {
	_flags.set(Node::PassColor3, var);
	setColor3(_color.toColor3());
}

bool Node::isPassColor3() const noexcept {
	return _flags.isOn(Node::PassColor3);
}

void Node::setTransformTarget(Node* var) {
	SetTAttr(transformTarget, var);
	_flags.setOn(Node::WorldDirty);
}

Node* Node::getTransformTarget() const noexcept {
	return GetTAttr(transformTarget);
}

void Node::setScheduler(Scheduler* var) {
	AssertUnless(var, "set invalid scheduler(nullptr) to node.");
	auto oldScheduler = _scheduler.get();
	if (_flags.isOn(Node::Updating)) {
		if (_updateItem && _updateItem->scheduled()) {
			oldScheduler->unschedule(_updateItem->scheduledItem.get());
		}
		var->schedule(getUpdateItem()->scheduledItem.get());
	}
	if (_flags.isOn(Node::FixedUpdating)) {
		if (_updateItem && _updateItem->fixedScheduled()) {
			oldScheduler->unscheduleFixed(_updateItem->fixedScheduledItem.get());
		}
		var->scheduleFixed(getFixedScheduledItem());
	}
	pauseActionInList(_action);
	_scheduler = var;
	resumeActionInList(_action);
}

Scheduler* Node::getScheduler() const noexcept {
	return _scheduler;
}

Dictionary* Node::getUserData() {
	if (!_userData) {
		_userData = Dictionary::create();
	}
	return _userData;
}

Node* Node::getParent() const noexcept {
	return _parent;
}

Node* Node::getTargetParent() const noexcept {
	if (_transform && _transform->transformTarget) {
		return _transform->transformTarget;
	}
	return _parent;
}

void Node::setRenderOrder(int var) {
	_renderOrder = var;
}

int Node::getRenderOrder() const noexcept {
	return _renderOrder;
}

void Node::setRenderGroup(bool var) {
	_flags.set(Node::RenderGrouped, var);
}

bool Node::isRenderGroup() const noexcept {
	return _flags.isOn(Node::RenderGrouped);
}

uint32_t Node::getNodeCount() const noexcept {
	uint32_t count = 1;
	ARRAY_START(Node, child, _children) {
		count += child->getNodeCount();
	}
	ARRAY_END
	return count;
}

void Node::onEnter() {
	ARRAY_START(Node, child, _children) {
		child->onEnter();
	}
	ARRAY_END
	_flags.setOn(Node::Running);
	if (isUpdating() || isScheduled()) {
		auto updateItem = getUpdateItem();
		if (!updateItem->scheduled()) {
			_scheduler->schedule(updateItem->scheduledItem.get());
		}
	}
	if (isFixedUpdating()) {
		auto fixedScheduledItem = getFixedScheduledItem();
		if (!fixedScheduledItem->iter) {
			_scheduler->scheduleFixed(fixedScheduledItem);
		}
	}
	resumeActionInList(_action);
	markDirty();
	post("Enter"_slice);
}

void Node::onExit() {
	ARRAY_START(Node, child, _children) {
		child->onExit();
	}
	ARRAY_END
	_flags.setOff(Node::Running);
	if (isUpdating() || isScheduled()) {
		if (_updateItem && _updateItem->scheduled()) {
			_scheduler->unschedule(_updateItem->scheduledItem.get());
		}
	}
	if (isFixedUpdating()) {
		if (_updateItem && _updateItem->fixedScheduled()) {
			_scheduler->unscheduleFixed(_updateItem->fixedScheduledItem.get());
		}
	}
	pauseActionInList(_action);
	post("Exit"_slice);
}

Array* Node::getChildren() {
	sortAllChildren();
	return _children;
}

bool Node::hasChildren() const noexcept {
	return _children && !_children->isEmpty();
}

bool Node::isRunning() const noexcept {
	return _flags.isOn(Node::Running);
}

void Node::addChild(Node* child, int order, String tag) {
	AssertIf(child == nullptr, "add invalid child (nullptr) to node.");
	AssertIf(child->_parent, "child already added. It can't be added again.");
	AssertIf(child->_flags.isOn(Node::Cleanup), "add invalid child (disposed) to node.");

	if (child->_flags.isOn(Node::UnManaged)) {
		child->_flags.setOff(Node::UnManaged);
	}

	if (child->_flags.isOn(Node::InWaitingList)) {
		child->_flags.setOff(Node::InWaitingList);
		SharedDirector.removeFromWaitingList(child);
	}

	child->setTag(tag);
	child->setOrder(order);
	if (!_children) {
		_children = Array::create();
	}
	Node* last = nullptr;
	if (!_children->isEmpty()) {
		last = _children->getLast()->to<Node>();
	}
	_children->add(Value::alloc(child));
	if (last && last->getOrder() > child->getOrder()) {
		_flags.setOn(Node::Reorder);
	}
	child->_parent = this;
	child->updateRealColor3();
	child->updateRealOpacity();
	if (_flags.isOn(Node::Running)) {
		child->onEnter();
	}
}

void Node::addChild(Node* child, int order) {
	AssertIf(child == nullptr, "add invalid child(nullptr) to node.");
	addChild(child, order, child->getTag());
}

void Node::addChild(Node* child) {
	AssertIf(child == this, "can not add node to itself.");
	AssertIf(child == nullptr, "add invalid child(nullptr) to node.");
	addChild(child, child->getOrder(), child->getTag());
}

Node* Node::addTo(Node* parent, int order, String tag) {
	AssertIf(parent == this, "can not add node to itself.");
	AssertIf(parent == nullptr, "add node to invalid parent.");
	parent->addChild(this, order, tag);
	return this;
}

Node* Node::addTo(Node* parent, int zOrder) {
	return addTo(parent, zOrder, getTag());
}

Node* Node::addTo(Node* parent) {
	return addTo(parent, getOrder(), getTag());
}

void Node::removeChild(Node* child, bool cleanup) {
	AssertIf(child == nullptr, "remove invalid child (nullptr) from node.");
	AssertIf(child->_parent != this, "can't remove child node from different parent.");
	if (!_children) {
		return;
	}
	auto childRef = Value::alloc(child);
	if (_children->remove(childRef.get())) {
		if (_flags.isOn(Node::Running)) {
			child->onExit();
		}
		if (cleanup) {
			child->cleanup();
		} else {
			child->_flags.setOn(Node::InWaitingList);
			SharedDirector.addToWaitingList(child);
		}
		child->_parent = nullptr;
		child->autorelease();
	}
}

void Node::removeChildByTag(String tag, bool cleanup) {
	removeChild(getChildByTag(tag), cleanup);
}

void Node::removeAllChildren(bool cleanup) {
	ARRAY_START(Node, child, _children) {
		if (_flags.isOn(Node::Running)) {
			child->onExit();
		}
		if (cleanup) {
			child->cleanup();
		} else {
			child->_flags.setOn(Node::InWaitingList);
			SharedDirector.addToWaitingList(child);
		}
		child->_parent = nullptr;
	}
	ARRAY_END
	if (_children) {
		_children->clear();
	}
}

void Node::removeFromParent(bool cleanup) {
	if (_parent) {
		_parent->removeChild(this, cleanup);
	} else if (cleanup) {
		this->cleanup();
	}
}

void Node::moveToParent(Node* parent) {
	AssertIf(parent == nullptr, "can not move node to an invalid parent (nullptr).");
	if (_parent == parent) return;
	if (_parent) {
		auto childRef = Value::alloc(this);
		if (_parent->_children->remove(childRef.get())) {
			if (!parent->_children) {
				parent->_children = Array::create();
			}
			Node* last = nullptr;
			if (!parent->_children->isEmpty()) {
				last = parent->_children->getLast()->to<Node>();
			}
			parent->_children->add(Value::alloc(this));
			if (last && last->getOrder() > getOrder()) {
				parent->_flags.setOn(Node::Reorder);
			}
			_parent = parent;
			updateRealColor3();
			updateRealOpacity();
			markDirty();
		}
	} else {
		parent->addChild(this);
	}
}

void Node::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		_flags.setOn(Node::Cleanup);
		post("Cleanup"_slice);
		_signal = nullptr;
		ARRAY_START(Node, child, _children) {
			child->cleanup();
		}
		ARRAY_END
		unschedule();
		unscheduleUpdate();
		stopActionInList(_action);
		if (_updateItem) {
			_updateItem->renderFuncs = nullptr;
			_updateItem->scheduledMainFunc = nullptr;
			_updateItem->scheduledThreadFuncs.clear();
		}
		if (_userData) {
			_userData->clear();
		}
		if (_flags.isOn(Node::KeyboardEnabled)) {
			setKeyboardEnabled(false);
		}
		if (_flags.isOn(Node::ControllerEnabled)) {
			setControllerEnabled(false);
		}
		if (_grabber) {
			_grabber->cleanup();
			_grabber = nullptr;
		}
		_parent = nullptr;
		Object::cleanup();
	}
}

Node* Node::getChildByTag(String tag) {
	Node* targetNode = nullptr;
	traverseAll([&](Node* child) {
		if (child->getTag() == tag) {
			targetNode = child;
			return true;
		}
		return false;
	});
	return targetNode;
}

Vec2 Node::convertToNodeSpace(const Vec2& worldPoint) {
	Matrix invWorld;
	bx::mtxInverse(invWorld.m, getWorld().m);
	Vec3 point;
	point = Vec3::from(bx::mul(bx::Vec3{worldPoint.x, worldPoint.y, 0.0f}, invWorld.m));
	return point.toVec2();
}

Vec2 Node::convertToWorldSpace(const Vec2& nodePoint) {
	Vec3 point = Vec3::from(bx::mul(bx::Vec3{nodePoint.x, nodePoint.y, 0.0f}, getWorld().m));
	return point.toVec2();
}

Vec2 Node::convertToWorldSpace(const Vec2& nodePoint, float& zInOut) {
	auto pos = convertToWorldSpace3({nodePoint.x, nodePoint.y, zInOut});
	zInOut = pos.z;
	return {pos.x, pos.y};
}

Vec2 Node::convertToNodeSpace(const Vec2& worldPoint, float& zInOut) {
	auto pos = convertToNodeSpace3({worldPoint.x, worldPoint.y, zInOut});
	zInOut = pos.z;
	return {pos.x, pos.y};
}

Vec3 Node::convertToNodeSpace3(const Vec3& worldPoint) {
	Matrix invWorld;
	bx::mtxInverse(invWorld.m, getWorld().m);
	return Vec3::from(bx::mul(worldPoint, invWorld.m));
}

Vec3 Node::convertToWorldSpace3(const Vec3& nodePoint) {
	Vec3 point = Vec3::from(bx::mul(nodePoint, getWorld().m));
	return point;
}

bool Node::isScheduled() const noexcept {
	return _updateItem && _updateItem->hasFunc();
}

bool Node::isUnManaged() const noexcept {
	return _flags.isOn(Node::UnManaged) && _flags.isOff(Node::Cleanup) && _flags.isOff(Node::InWaitingList);
}

void Node::setTouchEnabled(bool var) {
	if (_flags.isOn(Node::TouchEnabled) == var) return;
	if (!_touchHandler) {
		_touchHandler = std::make_shared<NodeTouchHandler>(this);
		_touchHandler->setSwallowTouches(_flags.isOn(Node::SwallowTouches));
	}
	_flags.set(Node::TouchEnabled, var);
}

bool Node::isTouchEnabled() const noexcept {
	return _flags.isOn(Node::TouchEnabled);
}

void Node::setSwallowTouches(bool var) {
	_flags.set(Node::SwallowTouches, var);
	if (_touchHandler) {
		_touchHandler->setSwallowTouches(var);
	}
}

bool Node::isSwallowTouches() const noexcept {
	return _flags.isOn(Node::SwallowTouches);
}

void Node::setSwallowMouseWheel(bool var) {
	_flags.set(Node::SwallowMouseWheel, var);
	if (_touchHandler) {
		_touchHandler->setSwallowMouseWheel(var);
	}
}

bool Node::isSwallowMouseWheel() const noexcept {
	return _flags.isOn(Node::SwallowMouseWheel);
}

TouchHandler* Node::getTouchHandler() const noexcept {
	return _touchHandler.get();
}

Node::UpdateItem* Node::getUpdateItem() {
	if (!_updateItem) {
		_updateItem = New<Node::UpdateItem>();
		_updateItem->scheduledItem = New<ScheduledItemWrapper<Node>>(this);
	}
	return _updateItem.get();
}

FixedScheduledItem* Node::getFixedScheduledItem() {
	auto updateItem = getUpdateItem();
	if (!updateItem->fixedScheduledItem) {
		updateItem->fixedScheduledItem = New<FixedScheduledItemWrapper<Node>>(this);
	}
	return updateItem->fixedScheduledItem.get();
}

void Node::schedule(const Update& func) {
	auto updateItem = getUpdateItem();
	auto funcRef = std::make_shared<Update>();
	std::weak_ptr<Update> weak(funcRef);
	*funcRef = [func, weak](double deltaTime) {
		std::shared_ptr<Update> ref(weak);
		return func(deltaTime);
	};
	updateItem->scheduledMainFunc = funcRef;
	if (_flags.isOff(Node::Running)) return;
	if (!updateItem->scheduled()) {
		_scheduler->schedule(updateItem->scheduledItem.get());
	}
}

void Node::unschedule() {
	if (!_updateItem) return;
	if (_updateItem->scheduledMainFunc) {
		_updateItem->scheduledMainFunc = nullptr;
		if (_flags.isOff(Node::Updating) && _updateItem->scheduledItem->iter) {
			_scheduler->unschedule(_updateItem->scheduledItem.get());
		}
	}
}

void Node::onUpdate(const Update& func) {
	auto updateItem = getUpdateItem();
	auto funcRef = std::make_shared<Update>();
	std::weak_ptr<Update> weak(funcRef);
	*funcRef = [func, weak](double deltaTime) {
		std::shared_ptr<Update> ref(weak);
		return func(deltaTime);
	};
	updateItem->scheduledThreadFuncs.push_back(funcRef);
	if (_flags.isOff(Node::Running)) return;
	if (!updateItem->scheduled()) {
		_scheduler->schedule(updateItem->scheduledItem.get());
	}
}

void Node::onRender(const Update& func) {
	auto updateItem = getUpdateItem();
	if (!updateItem->renderFuncs) {
		updateItem->renderFuncs = New<std::list<Update>>();
	}
	updateItem->renderFuncs->push_back(func);
}

bool Node::isUpdating() const noexcept {
	return _flags.isOn(Node::Updating);
}

bool Node::isFixedUpdating() const noexcept {
	return _flags.isOn(Node::FixedUpdating);
}

void Node::scheduleUpdate() {
	if (_flags.isOn(Node::Updating)) return;
	_flags.setOn(Node::Updating);
	if (_flags.isOff(Node::Running)) return;
	auto updateItem = getUpdateItem();
	if (!updateItem->scheduled()) {
		_scheduler->schedule(updateItem->scheduledItem.get());
	}
}

void Node::scheduleFixedUpdate() {
	if (_flags.isOn(Node::FixedUpdating)) return;
	_flags.setOn(Node::FixedUpdating);
	if (_flags.isOff(Node::Running)) return;
	auto fixedScheduledItem = getFixedScheduledItem();
	if (!fixedScheduledItem->iter) {
		_scheduler->scheduleFixed(fixedScheduledItem);
	}
}

void Node::unscheduleUpdate() {
	if (_flags.isOn(Node::Updating)) {
		_flags.setOff(Node::Updating);
		if (_updateItem && !_updateItem->hasFunc() && _updateItem->scheduledItem->iter) {
			_scheduler->unschedule(_updateItem->scheduledItem.get());
		}
	}
}

void Node::unscheduleFixedUpdate() {
	if (_flags.isOn(Node::FixedUpdating)) {
		_flags.setOff(Node::FixedUpdating);
		if (_updateItem && _updateItem->fixedScheduledItem && _updateItem->fixedScheduledItem->iter) {
			_scheduler->unscheduleFixed(_updateItem->fixedScheduledItem.get());
		}
	}
}

bool Node::fixedUpdate(double deltaTime) {
	return !isFixedUpdating();
}

bool Node::update(double deltaTime) {
	bool result = true;
	if (isScheduled()) {
		if (_updateItem->scheduledMainFunc != nullptr) {
			if ((*_updateItem->scheduledMainFunc)(deltaTime)) {
				_updateItem->scheduledMainFunc = nullptr;
			} else {
				result = false;
			}
		}
		if (!_updateItem->scheduledThreadFuncs.empty()) {
			auto funcs = std::move(_updateItem->scheduledThreadFuncs);
			for (auto it = funcs.begin(); it != funcs.end();) {
				if ((**it)(deltaTime)) {
					it = funcs.erase(it);
				} else {
					it++;
				}
			}
			for (auto& f : _updateItem->scheduledThreadFuncs) {
				funcs.emplace_back(std::move(f));
			}
			_updateItem->scheduledThreadFuncs = std::move(funcs);
			if (result && !_updateItem->scheduledThreadFuncs.empty()) {
				result = false;
			}
		}
		if (result) unschedule();
	}
	return result && !isUpdating();
}

void Node::visitInner() {
	if (_flags.isOff(Node::Visible)) {
		return;
	}

	/* get world matrix */
	getWorld();

	auto& rendererManager = SharedRendererManager;
	if (_children && !_children->isEmpty() && _flags.isOn(Node::ChildrenVisible)) {
		sortAllChildren();

		auto visitChildren = [&]() {
			/* visit and render child whose order is less than 0 */
			size_t index = 0;
			auto& data = _children->data();
			for (index = 0; index < data.size(); index++) {
				Node* node = data[index]->to<Node>();
				if (node->getOrder() >= 0) break;
				node->visit();
			}

			/* render self */
			if (_flags.isOn(Node::SelfVisible)) {
				if (rendererManager.isGrouping() && _renderOrder != 0) {
					rendererManager.pushGroupItem(this);
				} else {
					render();
				}
			}

			/* visit and render child whose order is greater equal than 0 */
			for (; index < data.size(); index++) {
				Node* node = data[index]->to<Node>();
				node->visit();
			}
		};

		if (_flags.isOn(Node::RenderGrouped)) {
			rendererManager.pushGroup(getNodeCount(), visitChildren);
		} else
			visitChildren();
	} else if (_flags.isOn(Node::SelfVisible)) {
		if (rendererManager.isGrouping() && _renderOrder != 0) {
			rendererManager.pushGroupItem(this);
		} else {
			render();
		}
	}
}

void Node::visit() {
	if (_grabber) {
		_grabber->grab(this);
		_grabber->visit();
	} else
		visitInner();
}

void Node::render() {
	if (_updateItem && _updateItem->renderFuncs) {
		if (!_updateItem->renderFuncs->empty()) {
			double deltaTime = _scheduler->getDeltaTime() * _scheduler->getTimeScale();
			auto funcs = std::move(*_updateItem->renderFuncs);
			for (auto it = funcs.begin(); it != funcs.end();) {
				if ((*it)(deltaTime)) {
					it = funcs.erase(it);
				} else {
					it++;
				}
			}
			for (auto& f : *_updateItem->renderFuncs) {
				funcs.emplace_back(std::move(f));
			}
			*_updateItem->renderFuncs = std::move(funcs);
		}
	}
	if (isShowDebug()) {
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
		float w = getWidth();
		float h = getHeight();
		const float anchorSize = 20.0f;
		float anchorPointX = GetTAttr(anchorPointX);
		float anchorPointY = GetTAttr(anchorPointY);
		Vec4 positions[] = {
			{0, h, 0, 1.0f},
			{w, h, 0, 1.0f},
			{w, 0, 0, 1.0f},
			{0, 0, 0, 1.0f},
			{anchorPointX - anchorSize, anchorPointY, 0, 1.0f},
			{anchorPointX + anchorSize, anchorPointY, 0, 1.0f},
			{anchorPointX, anchorPointY - anchorSize, 0, 1.0f},
			{anchorPointX, anchorPointY + anchorSize, 0, 1.0f}};
		auto color = getColor().toABGR();
		auto themeColor = SharedApplication.getThemeColor();
		themeColor.setOpacity(getRealOpacity());
		auto anchorColor = themeColor.toABGR();
		PosColorVertex verts[8] = {
			{0, 0, 0, 0, color},
			{0, 0, 0, 0, color},
			{0, 0, 0, 0, color},
			{0, 0, 0, 0, color},
			{0, 0, 0, 0, anchorColor},
			{0, 0, 0, 0, anchorColor},
			{0, 0, 0, 0, anchorColor},
			{0, 0, 0, 0, anchorColor}};
		for (size_t i = 0; i < 8; i++) {
			Matrix::mulVec4(&verts[i].x, transform, positions[i]);
		}
		SharedRendererManager.setCurrent(SharedLineRenderer.getTarget());
		if (getSize() != Size::zero) {
			SharedLineRenderer.pushRect(verts);
		}
		SharedLineRenderer.pushSegment(verts + 4);
		SharedLineRenderer.pushSegment(verts + 6);
	}
}

const AffineTransform& Node::getLocalTransform() {
	if (!_transform) return AffineTransform::Indentity;
	auto& t = *_transform;
	if (_flags.isOn(Node::TransformDirty)) {
		/* cos(rotateZ), sin(rotateZ) */
		float c = 1, s = 0;
		if (t.angle) {
			float radians = -bx::toRad(t.angle);
			c = bx::cos(radians);
			s = bx::sin(radians);
		}

		if (t.skewX || t.skewY) {
			/* skewXY */
			t.transform = {
				1.0f, bx::tan(bx::toRad(t.skewY)),
				bx::tan(bx::toRad(t.skewX)), 1.0f,
				0.0f, 0.0f};

			/* scaleXY, rotateZ, translateXY */
			t.transform.concat({c * t.scaleX, s * t.scaleX, -s * t.scaleY, c * t.scaleY, t.x, t.y});
		} else {
			/* scaleXY, rotateZ, translateXY */
			t.transform = {c * t.scaleX, s * t.scaleX, -s * t.scaleY, c * t.scaleY, t.x, t.y};
		}

		/* translateAnchorXY */
		if (t.anchorPointX != 0.0f || t.anchorPointY != 0.0f) {
			t.transform.translate(-t.anchorPointX, -t.anchorPointY);
		}

		_flags.setOff(Node::TransformDirty);
	}
	return t.transform;
}

void Node::getLocalWorld(Matrix& localWorld) {
	if (!_transform) {
		localWorld = Matrix::Indentity;
		return;
	}
	auto& t = *_transform;
	if (t.z || t.angleX || t.angleY || t.scaleZ != 1.0f) {
		if (t.anchorPointX || t.anchorPointY) {
			/* scaleXYZ, rotateXYZ, translateXYZ */
			Matrix mtxBase;
			bx::mtxSRT(mtxBase.m,
				t.scaleX, t.scaleY, t.scaleZ,
				-bx::toRad(t.angleX), -bx::toRad(t.angleY), -bx::toRad(t.angle),
				t.x, t.y, t.z);
			if (t.skewX || t.skewY) {
				Matrix mtxTemp;
				{
					Matrix mtxSkew;
					/* skewXY */
					AffineTransform{
						1.0f, bx::tan(bx::toRad(t.skewY)),
						bx::tan(bx::toRad(t.skewX)), 1.0f,
						0.0f, 0.0f}
						.toMatrix(mtxSkew);
					Matrix::mulMtx(mtxTemp, mtxBase, mtxSkew);
				}
				/* translateAnchorXY */
				Matrix mtxAnchor;
				bx::mtxTranslate(mtxAnchor.m, -t.anchorPointX, -t.anchorPointY, 0.0f);
				Matrix::mulMtx(localWorld, mtxTemp, mtxAnchor);
			} else {
				/* translateAnchorXY */
				Matrix mtxAnchor;
				bx::mtxTranslate(mtxAnchor.m, -t.anchorPointX, -t.anchorPointY, 0.0f);
				Matrix::mulMtx(localWorld, mtxBase, mtxAnchor);
			}
		} else {
			if (t.skewX || t.skewY) {
				/* scaleXYZ, rotateXYZ, translateXYZ */
				Matrix mtxBase;
				bx::mtxSRT(mtxBase.m,
					t.scaleX, t.scaleY, t.scaleZ,
					-bx::toRad(t.angleX), -bx::toRad(t.angleY), -bx::toRad(t.angle),
					t.x, t.y, t.z);
				Matrix mtxSkew;
				/* skewXY */
				AffineTransform{
					1.0f, bx::tan(bx::toRad(t.skewY)),
					bx::tan(bx::toRad(t.skewX)), 1.0f,
					0.0f, 0.0f}
					.toMatrix(mtxSkew);
				Matrix::mulMtx(localWorld, mtxBase, mtxSkew);
			} else {
				/* translateXYZ, rotateXYZ, scaleXYZ */
				bx::mtxSRT(localWorld.m,
					t.scaleX, t.scaleY, t.scaleZ,
					-bx::toRad(t.angleX), -bx::toRad(t.angleY), -bx::toRad(t.angle),
					t.x, t.y, t.z);
			}
		}
	} else {
		/* translateXY, rotateZ, scaleXY, translateAnchorXY */
		getLocalTransform().toMatrix(localWorld);
	}
}

const Matrix& Node::getWorld() {
	Node* parent = getTargetParent();
	if (!_transform) {
		if (_flags.isOn(Node::WorldDirty)) {
			_flags.setOff(Node::WorldDirty);
			ARRAY_START(Node, child, _children) {
				child->_flags.setOn(Node::WorldDirty);
			}
			ARRAY_END
		}
		return parent ? parent->getWorld() : Matrix::Indentity;
	}
	auto& t = getTransform();
	if (_flags.isOn(Node::WorldDirty)) {
		_flags.setOff(WorldDirty);
		const Matrix* parentWorld = &Matrix::Indentity;
		Node* transformTarget = t.transformTarget;
		if (transformTarget) {
			parentWorld = &transformTarget->getWorld();
			_flags.setOn(Node::WorldDirty);
		} else if (_parent) {
			parentWorld = &_parent->getWorld();
		}
		if (_flags.isOn(Node::IgnoreLocalTransform)) {
			t.world = *parentWorld;
		} else {
			Matrix localWorld;
			getLocalWorld(localWorld);
			Matrix::mulMtx(t.world, *parentWorld, localWorld);
		}
		ARRAY_START(Node, child, _children) {
			child->_flags.setOn(Node::WorldDirty);
		}
		ARRAY_END
	}
	return t.world;
}

void Node::emit(Event* event) {
	if (_signal) {
		_signal->emit(event);
	}
}

void Node::post(String name) {
	if (_signal) {
		if (auto slot = _signal->getSlot(name)) {
			Event::post(name, slot->getHandler());
		}
	}
}

Slot* Node::slot(String name) {
	if (!_signal) {
		_signal = New<Signal>();
	}
	return _signal->addSlot(name);
}

void Node::slot(String name, std::nullptr_t) {
	if (_signal) {
		_signal->removeSlots(name);
	}
}

Listener* Node::gslot(String name, const EventHandler& handler) {
	if (!_signal) {
		_signal = New<Signal>();
	}
	return _signal->addGSlot(name, handler);
}

void Node::gslot(String name, std::nullptr_t) {
	if (_signal) {
		_signal->removeGSlots(name);
	}
}

void Node::gslot(Listener* listener, std::nullptr_t) {
	if (_signal) {
		_signal->removeGSlot(listener);
	}
}

RefVector<Listener> Node::gslot(String name) {
	if (_signal) {
		return _signal->getGSlots(name);
	}
	return RefVector<Listener>();
}

void Node::markDirty() noexcept {
	_flags.setOn(Node::TransformDirty);
	_flags.setOn(Node::WorldDirty);
}

void Node::sortAllChildren() {
	if (_children && _flags.isOn(Node::Reorder)) {
		auto& data = _children->data();
		std::stable_sort(data.begin(), data.end(), [](const Own<Value>& a, const Own<Value>& b) {
			return a->to<Node>()->getOrder() < b->to<Node>()->getOrder();
		});
		_flags.setOff(Node::Reorder);
	}
}

void Node::markReorder() noexcept {
	_flags.setOn(Node::Reorder);
}

void Node::markParentReorder() {
	if (_parent) _parent->markReorder();
}

void Node::updateRealColor3() {
	if (_parent && _parent->isPassColor3()) {
		Color parentColor = _parent->_realColor;
		_realColor.r = s_cast<uint8_t>(_color.r * parentColor.r / 255.0f);
		_realColor.g = s_cast<uint8_t>(_color.g * parentColor.g / 255.0f);
		_realColor.b = s_cast<uint8_t>(_color.b * parentColor.b / 255.0f);
	} else {
		_realColor = _color;
	}
	if (_flags.isOn(Node::PassColor3)) {
		ARRAY_START(Node, child, _children) {
			child->updateRealColor3();
		}
		ARRAY_END
	}
}

void Node::updateRealOpacity() {
	if (_parent && _parent->isPassOpacity()) {
		float parentOpacity = _parent->_realColor.getOpacity();
		_realColor.setOpacity(_color.getOpacity() * parentOpacity);
	} else {
		_realColor.setOpacity(_color.getOpacity());
	}
	if (_flags.isOn(Node::PassOpacity)) {
		ARRAY_START(Node, child, _children) {
			child->updateRealOpacity();
		}
		ARRAY_END
	}
}

int Node::getActionCount() const noexcept {
	int count = 0;
	for (Action* action = _action; action; action = action->_next) {
		count++;
	}
	return count;
}

float Node::runAction(Action* action, bool loop) {
	if (!action) return 0.0f;
	if (action->isRunning()) {
		stopAction(action);
	}
	action->_looped = loop;
	action->_target = this;
	action->_prev = nullptr;
	if (_action) {
		action->_next = _action;
		_action->_prev = action;
		_action = action;
	} else {
		action->_next = nullptr;
		_action = action;
	}
	_action->_elapsed = 0.0f;
	_action->resume();
	if (isRunning()) {
		_scheduler->schedule(action);
	}
	return _action ? _action->getDuration() : 0.0f;
}

void Node::stopAllActions() {
	stopActionInList(_action);
}

float Node::perform(Action* action, bool loop) {
	stopAllActions();
	return runAction(action, loop);
}

bool Node::hasAction(Action* action) {
	bool found = false;
	for (Action* ac = _action; ac; ac = ac->_next) {
		if (ac == action) {
			found = true;
			break;
		}
	}
	return found;
}

void Node::removeAction(Action* action) {
	if (!hasAction(action)) return;
	if (_action == action) {
		if (action->_next) {
			_action = action->_next;
			_action->_prev = nullptr;
		} else {
			_action = nullptr;
		}
	} else {
		if (action->_prev) {
			action->_prev->_next = action->_next;
		}
	}
	action->_prev = nullptr;
	action->_next = nullptr;
}

void Node::stopAction(Action* action) {
	if (hasAction(action)) {
		_scheduler->unschedule(action);
		removeAction(action);
	}
}

void Node::pauseActionInList(Action* action) {
	if (action) {
		pauseActionInList(action->_next);
		_scheduler->unschedule(action);
	}
}

void Node::resumeActionInList(Action* action) {
	if (action) {
		resumeActionInList(action->_next);
		_scheduler->schedule(action);
	}
}

void Node::stopActionInList(Action* action) {
	if (action) {
		Ref<> ref(action);
		stopActionInList(action->_next);
		_scheduler->unschedule(action);
		removeAction(action);
	}
}

Size Node::alignItemsVertically(float padding) {
	return alignItemsVertically(getSize(), padding);
}

Size Node::alignItemsVertically(const Size& size, float padding) {
	sortAllChildren();
	float width = size.width;
	float y = size.height - padding;
	ARRAY_START(Node, child, _children) {
		float realWidth = child->getWidth() * std::abs(child->getScaleX());
		float realHeight = child->getHeight() * std::abs(child->getScaleY());
		float anchorX = child->getScaleX() > 0 ? child->getAnchor().x : 1.0f - child->getAnchor().x;
		float anchorY = child->getScaleY() > 0 ? child->getAnchor().y : 1.0f - child->getAnchor().y;
		if (realWidth == 0.0f || realHeight == 0.0f) continue;
		float realPosY = (1.0f - anchorY) * realHeight;
		y -= realPosY;
		child->setX(width * 0.5f - (0.5f - anchorX) * realWidth);
		child->setY(y);
		y -= anchorY * realHeight;
		y -= padding;
	}
	ARRAY_END
	return _children && !_children->isEmpty() ? Size{size.width, size.height - y} : Size::zero;
}

Size Node::alignItemsHorizontally(float padding) {
	return alignItemsHorizontally(getSize(), padding);
}

Size Node::alignItemsHorizontally(const Size& size, float padding) {
	sortAllChildren();
	float height = size.height;
	float x = padding;
	ARRAY_START(Node, child, _children) {
		float realWidth = child->getWidth() * std::abs(child->getScaleX());
		float realHeight = child->getHeight() * std::abs(child->getScaleY());
		float anchorX = child->getScaleX() > 0 ? child->getAnchor().x : 1.0f - child->getAnchor().x;
		float anchorY = child->getScaleY() > 0 ? child->getAnchor().y : 1.0f - child->getAnchor().y;
		if (realWidth == 0.0f || realHeight == 0.0f) continue;
		float realPosX = anchorX * realWidth;
		x += realPosX;
		child->setX(x);
		child->setY(height * 0.5f - (0.5f - anchorY) * realHeight);
		x += (1.0f - anchorX) * realWidth;
		x += padding;
	}
	ARRAY_END
	return _children && !_children->isEmpty() ? Size{x, size.height} : Size::zero;
}

Size Node::alignItems(float padding) {
	return alignItems(getSize(), padding);
}

Size Node::alignItems(const Size& size, float padding) {
	sortAllChildren();
	float height = size.height;
	float width = size.width;
	float x = padding;
	float y = height - padding;
	int rows = 0;
	float curY = y;
	float maxX = 0;
	ARRAY_START(Node, child, _children) {
		float realWidth = child->getWidth() * std::abs(child->getScaleX());
		float realHeight = child->getHeight() * std::abs(child->getScaleY());

		float anchorX = child->getScaleX() > 0 ? child->getAnchor().x : 1.0f - child->getAnchor().x;
		float anchorY = child->getScaleY() > 0 ? child->getAnchor().y : 1.0f - child->getAnchor().y;

		if (realWidth == 0.0f || realHeight == 0.0f) continue;

		if (x + realWidth + padding > width) {
			x = padding;
			rows++;
			y = curY - padding;
		}
		float realPosX = anchorX * realWidth;
		x += realPosX;

		float realPosY = (1.0f - anchorY) * realHeight;

		child->setX(x);
		child->setY(y - realPosY);

		x += (1.0f - anchorX) * realWidth;
		x += padding;

		maxX = std::max(maxX, x);

		if (curY > y - realHeight) {
			curY = y - realHeight;
		}
	}
	ARRAY_END
	return _children && !_children->isEmpty() ? Size{maxX, height - curY} : Size::zero;
}

void Node::moveAndCullItems(const Vec2& delta) {
	sortAllChildren();
	Rect contentRect(Vec2::zero, getSize());
	ARRAY_START(Node, child, _children) {
		child->setPosition(child->getPosition() + delta);
		const Vec2& pos = child->getPosition();
		const Size& size = child->getSize();
		const Vec2& anchor = child->getAnchor();
		Rect childRect(
			pos.x - size.width * anchor.x,
			pos.y - size.height * anchor.y,
			size.width,
			size.height);
		if (childRect.size != Size::zero) {
			child->setVisible(contentRect.intersectsRect(childRect));
		}
	}
	ARRAY_END
}

void Node::handleKeyboardAndController(Event* event) {
	emit(event);
}

void Node::setKeyboardEnabled(bool var) {
	if (_flags.isOn(Node::KeyboardEnabled) == var) return;
	_flags.set(Node::KeyboardEnabled, var);
	if (var) {
		SharedKeyboard.handler += std::make_pair(MakeRef(this), &Node::handleKeyboardAndController);
	} else {
		SharedKeyboard.handler -= std::make_pair(MakeRef(this), &Node::handleKeyboardAndController);
	}
}

bool Node::isKeyboardEnabled() const noexcept {
	return _flags.isOn(Node::KeyboardEnabled);
}

void Node::setControllerEnabled(bool var) {
	if (_flags.isOn(Node::ControllerEnabled) == var) return;
	_flags.set(Node::ControllerEnabled, var);
	if (var) {
		SharedController.handler += std::make_pair(MakeRef(this), &Node::handleKeyboardAndController);
	} else {
		SharedController.handler -= std::make_pair(MakeRef(this), &Node::handleKeyboardAndController);
	}
}

bool Node::isControllerEnabled() const noexcept {
	return _flags.isOn(Node::ControllerEnabled);
}

void Node::attachIME() {
	WRef<Node> self(this);
	SharedKeyboard.attachIME([self](Event* e) {
		if (self) self->emit(e);
	});
}

void Node::detachIME() {
	SharedKeyboard.detachIME();
}

static bool project(float objx, float objy, float objz,
	const Matrix& model, const Matrix& proj,
	const float viewport[4],
	float* winx, float* winy, float* winz) {
	/* matrice de transformation */
	Vec4 in, out;
	/* initilise la matrice et le vecteur a transformer */
	in.x = objx;
	in.y = objy;
	in.z = objz;
	in.w = 1.0;
	Matrix::mulVec4(out, model, in);
	Matrix::mulVec4(in, proj, out);
	/* d’ou le resultat normalise entre -1 et 1 */
	if (in.z == 0.0) return false;
	in.x /= in.w;
	in.y /= in.w;
	in.z /= in.w;
	/* en coordonnees ecran */
	*winx = viewport[0] + (1.0f + in.x) * viewport[2] / 2.0f;
	*winy = viewport[1] + (1.0f + in.y) * viewport[3] / 2.0f;
	/* entre 0 et 1 suivant z */
	*winz = (1.0f + in.z) / 2.0f;
	return true;
}

class ProjectNode : public Node {
public:
	virtual void render() override {
		Size viewSize = SharedView.getSize();
		float viewPort[4]{0, 0, viewSize.width, viewSize.height};
		float winX, winY, winZ;
		if (project(_nodePoint.x, _nodePoint.y, 0, getWorld(), SharedDirector.getViewProjection(), viewPort, &winX, &winY, &winZ)) {
			Size winSize = SharedApplication.getWinSize();
			winX = winX * winSize.width / viewSize.width;
			winY = winY * winSize.height / viewSize.height;
			if (SharedView.getName() != "UI"_slice) {
				winY = winSize.height - winY;
			}
			_convertHandler(Vec2{winX, winY});
		} else {
			_convertHandler(Vec2::zero);
		}
		WRef<Node> wref(this);
		schedule([wref](double deltaTime) {
			if (wref) wref->removeFromParent();
			return true;
		});
	}
	CREATE_FUNC_NOT_NULL(ProjectNode);

protected:
	ProjectNode(const Vec2& nodePoint, const std::function<void(const Vec2&)>& convertHandler)
		: _nodePoint(nodePoint)
		, _convertHandler(convertHandler) { }

private:
	Vec2 _nodePoint;
	std::function<void(const Vec2&)> _convertHandler;
};

void Node::convertToWindowSpace(const Vec2& nodePoint, const std::function<void(const Vec2&)>& callback) {
	addChild(ProjectNode::create(nodePoint, callback));
}

Node::Grabber::Grabber(const Size& size, uint32_t gridX, uint32_t gridY)
	: _clearColor(0x0)
	, _blendFunc(BlendFunc::Default)
	, _grid(Grid::create(size.width, size.height, gridX, gridY)) {
	_grid->setAsManaged();
}

uint32_t Node::Grabber::getGridX() const noexcept {
	return _grid->getGridX();
}

uint32_t Node::Grabber::getGridY() const noexcept {
	return _grid->getGridY();
}

void Node::Grabber::setClearColor(Color var) {
	_clearColor = var;
}

Color Node::Grabber::getClearColor() const noexcept {
	return _clearColor;
}

void Node::Grabber::setCamera(Camera* var) {
	_camera = var;
}

Camera* Node::Grabber::getCamera() const noexcept {
	return _camera;
}

void Node::Grabber::setBlendFunc(const BlendFunc& var) {
	_blendFunc = var;
}

const BlendFunc& Node::Grabber::getBlendFunc() const noexcept {
	return _blendFunc;
}

void Node::Grabber::setEffect(SpriteEffect* var) {
	_effect = var;
}

SpriteEffect* Node::Grabber::getEffect() const noexcept {
	return _effect;
}

Node::Grabber::RenderPair Node::Grabber::newRenderPair(float width, float height) {
	auto renderTarget = RenderTarget::create(
		s_cast<uint16_t>(width),
		s_cast<uint16_t>(height));
	auto surface = Sprite::create(renderTarget->getTexture());
	surface->setAsManaged();
	surface->setPosition({width / 2.0f, height / 2.0f});
	surface->setBlendFunc({BlendFunc::One, BlendFunc::Zero});
	surface->setEffect(SpriteEffect::create());
	return {MakeRef(renderTarget), MakeRef(surface)};
}

void Node::Grabber::grab(Node* target) {
	float width = std::floor(target->getWidth()); // init RT with integer size
	float height = std::floor(target->getHeight());

	AssertIf(width <= 0.0f || height <= 0.0f, "can not grab a node with size [{}x{}].", width, height);

	size_t rtCount = 1;
	if (_effect) {
		for (Pass* pass : _effect->getPasses()) {
			if (pass->isGrabPass()) {
				rtCount = 2;
				break;
			}
		}
	}
	if (rtCount < _renderTargets.size()) {
		for (size_t i = rtCount; i < _renderTargets.size(); i++) {
			_renderTargets.pop_back();
		}
	} else {
		for (size_t i = _renderTargets.size(); i < rtCount; i++) {
			_renderTargets.push_back(newRenderPair(width, height));
		}
	}
	for (size_t i = 0; i < _renderTargets.size(); i++) {
		const auto& rt = _renderTargets[i];
		if (rt.surface->getWidth() != width || rt.surface->getHeight() != height) {
			_renderTargets[i] = newRenderPair(width, height);
		}
		_renderTargets[i].surface->getEffect()->clear();
	}

	SharedView.pushInsertionMode(true, [&]() {
		target->markDirty();
		target->_flags.setOn(Node::IgnoreLocalTransform);
		_renderTargets[0].rt->setCamera(_camera);
		_renderTargets[0].rt->renderWithClear(target, _clearColor);
		_renderTargets[0].rt->setCamera(nullptr);
		target->_flags.setOff(Node::IgnoreLocalTransform);
		target->markDirty();

		size_t rtIndex = 0;
		if (_effect) {
			for (Pass* pass : _effect->getPasses()) {
				Effect* effect = _renderTargets[rtIndex].surface->getEffect();
				effect->add(pass);
				if (pass->isGrabPass()) {
					Sprite* surface = _renderTargets[rtIndex].surface;
					rtIndex = (rtIndex + 1) % 2;
					surface->setPosition({width / 2.0f, height / 2.0f});
					surface->setBlendFunc({BlendFunc::One, BlendFunc::Zero});
					_renderTargets[rtIndex].rt->render(surface);
					surface->getEffect()->clear();
					_renderTargets[rtIndex].surface->getEffect()->clear();
				}
			}
		}

		Sprite* display = _renderTargets[rtIndex].surface;
		_grid->_parent = target;
		_grid->setTransformTarget(target);
		_grid->markDirty();
		s_cast<Node*>(_grid.get())->updateRealColor3();
		s_cast<Node*>(_grid.get())->updateRealOpacity();
		_grid->setEffect(display->getEffect());
		_grid->setTexture(display->getTexture());
		_grid->setTextureRect(display->getTextureRect());
		_grid->setPosition({width / 2.0f, height / 2.0f});
		_grid->setBlendFunc(_blendFunc);
	});
}

void Node::Grabber::setPos(int x, int y, Vec2 pos, float z) {
	_grid->setPos(x, y, pos, z);
}

Vec2 Node::Grabber::getPos(int x, int y, float* z) const {
	return _grid->getPos(x, y, z);
}

Color Node::Grabber::getColor(int x, int y) const {
	return _grid->getColor(x, y);
}

void Node::Grabber::setColor(int x, int y, Color color) {
	_grid->setColor(x, y, color);
}

void Node::Grabber::moveUV(int x, int y, Vec2 offset) {
	_grid->moveUV(x, y, offset);
}

void Node::Grabber::visit() {
	if (_grid) {
		_grid->visitInner();
	}
}

void Node::Grabber::cleanup() {
	if (_effect) {
		_effect = nullptr;
	}
	if (_grid) {
		_grid->cleanup();
		_grid = nullptr;
	}
	_renderTargets.clear();
}

Node::Grabber* Node::grab(bool enabled) {
	float width = GetTAttr(width);
	float height = GetTAttr(height);
	AssertIf(width <= 0.0f || height <= 0.0f, "can not grab a invalid sized node.");
	if (enabled) {
		if (!_grabber) _grabber = Grabber::create(Size{width, height}, 1, 1);
		return _grabber;
	}
	if (_grabber) {
		_grabber->cleanup();
		_grabber = nullptr;
	}
	return nullptr;
}

Node::Grabber* Node::grab(uint32_t gridX, uint32_t gridY) {
	float width = GetTAttr(width);
	float height = GetTAttr(height);
	AssertIf(width <= 0.0f || height <= 0.0f, "can not grab a invalid sized node.");
	if (!_grabber) {
		_grabber = Grabber::create(Size{width, height}, gridX, gridY);
	} else if (_grabber->getGridX() != gridX || _grabber->getGridY() != gridY) {
		_grabber->cleanup();
		_grabber = Grabber::create(Size{width, height}, gridX, gridY);
	}
	return _grabber;
}

/* Slot */

Slot::Slot() { }

const NodeEventHandler& Slot::getHandler() const noexcept {
	return _handler;
}

void Slot::clear() {
	_handler = nullptr;
}

void Slot::handle(Event* event) {
	_handler(event);
}

Own<Slot> Slot::alloc() {
	return Own<Slot>(new Slot());
}

/* Signal */

const size_t Signal::MaxSlotArraySize = 5;

Signal::~Signal() {
	for (auto& gslot : _gslots) {
		gslot->clearHandler();
	}
}

Slot* Signal::addSlot(String name) {
	if (std::holds_alternative<std::nullopt_t>(_slots)) {
		auto slotsArray = New<SlotArray>(MaxSlotArraySize);
		auto slot = Slot::alloc();
		auto slotPtr = slot.get();
		slotsArray->push_back(std::make_pair(name.toString(), std::move(slot)));
		_slots = std::move(slotsArray);
		return slotPtr;
	} else if (std::holds_alternative<Own<SlotMap>>(_slots)) {
		auto& slots = std::get<Own<SlotMap>>(_slots);
		auto it = slots->find(name);
		if (it != slots->end()) {
			return it->second.get();
		} else {
			auto slot = Slot::alloc();
			auto slotPtr = slot.get();
			(*slots)[name.toString()] = std::move(slot);
			return slotPtr;
		}
	} else {
		auto& slots = std::get<Own<SlotArray>>(_slots);
		for (auto& item : *slots) {
			if (name == item.first) {
				return item.second.get();
			}
		}
		auto nameStr = name.toString();
		if (slots->size() < Signal::MaxSlotArraySize) {
			auto slot = Slot::alloc();
			auto slotPtr = slot.get();
			slots->push_back(
				std::make_pair(nameStr, std::move(slot)));
			return slotPtr;
		} else {
			auto newSlots = New<SlotMap>();
			for (auto& item : *slots) {
				(*newSlots)[item.first] = std::move(item.second);
			}
			auto slot = Slot::alloc();
			auto slotPtr = slot.get();
			(*newSlots)[nameStr] = std::move(slot);
			_slots = std::move(newSlots);
			return slotPtr;
		}
	}
}

Listener* Signal::addGSlot(String name, const EventHandler& handler) {
	auto gslot = Listener::create(name.toString(), handler);
	_gslots.push_back(gslot);
	return gslot;
}

void Signal::removeGSlot(Listener* gslot) {
	_gslots.remove(gslot);
}

void Signal::removeSlots(String name) {
	if (std::holds_alternative<std::nullopt_t>(_slots)) {
		return;
	} else if (std::holds_alternative<Own<SlotMap>>(_slots)) {
		auto& slots = std::get<Own<SlotMap>>(_slots);
		auto it = slots->find(name);
		if (it != slots->end()) {
			it->second->clear();
			return;
		}
	} else {
		auto& slots = std::get<Own<SlotArray>>(_slots);
		for (auto it = slots->begin(); it != slots->end(); ++it) {
			if (name == it->first) {
				slots->erase(it);
				return;
			}
		}
	}
}

void Signal::removeGSlots(String name) {
	_gslots.erase(std::remove_if(_gslots.begin(), _gslots.end(), [&name](const Ref<Listener>& gslot) {
		return name == gslot->getName();
	}),
		_gslots.end());
}

Slot* Signal::getSlot(String name) {
	if (std::holds_alternative<std::nullopt_t>(_slots)) {
		return nullptr;
	} else if (std::holds_alternative<Own<SlotMap>>(_slots)) {
		auto& slots = std::get<Own<SlotMap>>(_slots);
		auto it = slots->find(name);
		if (it != slots->end()) {
			return it->second.get();
		}
	} else {
		auto& slots = std::get<Own<SlotArray>>(_slots);
		for (auto& item : *slots) {
			if (name == item.first) {
				return item.second.get();
			}
		}
	}
	return nullptr;
}

RefVector<Listener> Signal::getGSlots(String name) const {
	RefVector<Listener> listeners;
	for (const auto& item : _gslots) {
		if (name == item->getName()) {
			listeners.push_back(item);
		}
	}
	return listeners;
}

void Signal::emit(Event* event) {
	if (std::holds_alternative<std::nullopt_t>(_slots)) {
		return;
	} else if (std::holds_alternative<Own<SlotMap>>(_slots)) {
		auto& slots = std::get<Own<SlotMap>>(_slots);
		auto it = slots->find(event->getName());
		if (it != slots->end()) {
			it->second->handle(event);
		}
	} else {
		auto& slots = std::get<Own<SlotArray>>(_slots);
		for (auto& item : *slots) {
			if (item.second && event->getName() == item.first) {
				item.second->handle(event);
				return;
			}
		}
	}
}

bool Node::UpdateItem::hasFunc() const {
	return scheduledMainFunc != nullptr || !scheduledThreadFuncs.empty();
}

bool Node::UpdateItem::scheduled() const {
	return scheduledItem->iter.has_value();
}

bool Node::UpdateItem::fixedScheduled() const {
	return fixedScheduledItem && fixedScheduledItem->iter.has_value();
}

void Node::setAsManaged() {
	if (_flags.isOn(Node::UnManaged)) {
		_flags.setOff(Node::UnManaged);
	}
}

void Node::setShowDebug(bool var) {
	_flags.set(Node::ShowDebug, var);
}

bool Node::isShowDebug() const noexcept {
	return _flags.isOn(Node::ShowDebug);
}

NS_DORA_END

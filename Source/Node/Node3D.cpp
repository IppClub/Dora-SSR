/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Node3D.h"

#include "Basic/Director.h"

#ifndef DORA_NO_RUST
extern "C" {
uint64_t dora_3d_node_create();
void dora_3d_node_destroy(uint64_t node);
int32_t dora_3d_node_add_child(uint64_t parent, uint64_t child, int32_t order, const char* tag);
int32_t dora_3d_node_remove_child(uint64_t parent, uint64_t child);
int32_t dora_3d_node_remove_from_parent(uint64_t node);
void dora_3d_node_set_position(uint64_t node, float x, float y, float z);
void dora_3d_node_get_position(uint64_t node, float* out);
void dora_3d_node_set_rotation(uint64_t node, float x, float y, float z, float w);
void dora_3d_node_get_rotation(uint64_t node, float* out);
void dora_3d_node_set_euler(uint64_t node, float x, float y, float z);
void dora_3d_node_get_euler(uint64_t node, float* out);
void dora_3d_node_set_scale(uint64_t node, float x, float y, float z);
void dora_3d_node_get_scale(uint64_t node, float* out);
void dora_3d_node_set_tag(uint64_t node, const char* tag);
void dora_3d_node_set_visible(uint64_t node, int32_t visible);
int32_t dora_3d_node_is_visible(uint64_t node);
void dora_3d_node_get_world_matrix(uint64_t node, float* out);
void dora_3d_node_convert_to_world(uint64_t node, float x, float y, float z, float* out);
void dora_3d_node_convert_to_node(uint64_t node, float x, float y, float z, float* out);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

static void copyVec3(Vec3& out, const float* data) {
	out = {data[0], data[1], data[2]};
}

static void copyQuat(Quat& out, const float* data) {
	out = {data[0], data[1], data[2], data[3]};
}

Node3D::Node3D()
	: _order(0)
	, _tag()
	, _reorderDirty(false)
	, _parent(nullptr)
	, _scheduler(SharedDirector.getScheduler())
	, _handle(0)
	, _position{0.0f, 0.0f, 0.0f}
	, _scale{1.0f, 1.0f, 1.0f}
	, _rotation(bx::InitIdentity)
	, _eulerAngles{0.0f, 0.0f, 0.0f}
	, _worldMatrix(Matrix::Indentity) { }

bool Node3D::init() {
	if (!Object::init()) return false;
#ifndef DORA_NO_RUST
	_handle = dora_3d_node_create();
#endif // DORA_NO_RUST
	return _handle != 0;
}

void Node3D::setOrder(int var) {
	if (_order != var) {
		_order = var;
		if (_parent) {
			_parent->markReorder();
#ifndef DORA_NO_RUST
			dora_3d_node_add_child(_parent->_handle, _handle, _order, _tag.c_str());
#endif // DORA_NO_RUST
		}
	}
}

int Node3D::getOrder() const noexcept {
	return _order;
}

void Node3D::setScheduler(Scheduler* var) {
	AssertUnless(var, "set invalid scheduler(nullptr) to Node3D.");
	auto oldScheduler = _scheduler.get();
	if (_scheduledItem && _scheduledItem->iter) {
		oldScheduler->unschedule(_scheduledItem.get());
		var->schedule(_scheduledItem.get());
	}
	_scheduler = var;
}

Scheduler* Node3D::getScheduler() const noexcept {
	return _scheduler;
}

void Node3D::setX(float var) {
	Vec3 position = getPosition();
	position.x = var;
	setPosition(position);
}

float Node3D::getX() const noexcept {
	return getPosition().x;
}

void Node3D::setY(float var) {
	Vec3 position = getPosition();
	position.y = var;
	setPosition(position);
}

float Node3D::getY() const noexcept {
	return getPosition().y;
}

void Node3D::setZ(float var) {
	Vec3 position = getPosition();
	position.z = var;
	setPosition(position);
}

float Node3D::getZ() const noexcept {
	return getPosition().z;
}

void Node3D::setAngleX(float var) {
	Vec3 eulerAngles = getEulerAngles();
	eulerAngles.x = var;
	setEulerAngles(eulerAngles);
}

float Node3D::getAngleX() const noexcept {
	return getEulerAngles().x;
}

void Node3D::setAngleY(float var) {
	Vec3 eulerAngles = getEulerAngles();
	eulerAngles.y = var;
	setEulerAngles(eulerAngles);
}

float Node3D::getAngleY() const noexcept {
	return getEulerAngles().y;
}

void Node3D::setAngleZ(float var) {
	Vec3 eulerAngles = getEulerAngles();
	eulerAngles.z = var;
	setEulerAngles(eulerAngles);
}

float Node3D::getAngleZ() const noexcept {
	return getEulerAngles().z;
}

void Node3D::setScaleX(float var) {
	Vec3 scale = getScale();
	scale.x = var;
	setScale(scale);
}

float Node3D::getScaleX() const noexcept {
	return getScale().x;
}

void Node3D::setScaleY(float var) {
	Vec3 scale = getScale();
	scale.y = var;
	setScale(scale);
}

float Node3D::getScaleY() const noexcept {
	return getScale().y;
}

void Node3D::setScaleZ(float var) {
	Vec3 scale = getScale();
	scale.z = var;
	setScale(scale);
}

float Node3D::getScaleZ() const noexcept {
	return getScale().z;
}

void Node3D::setPosition(float x, float y, float z) {
	setPosition({x, y, z});
}

void Node3D::setPosition(const Vec3& var) {
#ifndef DORA_NO_RUST
	dora_3d_node_set_position(_handle, var.x, var.y, var.z);
#endif // DORA_NO_RUST
}

const Vec3& Node3D::getPosition() const noexcept {
#ifndef DORA_NO_RUST
	float data[3] = {};
	dora_3d_node_get_position(_handle, data);
	copyVec3(_position, data);
#endif // DORA_NO_RUST
	return _position;
}

void Node3D::setScale(float x, float y, float z) {
	setScale({x, y, z});
}

void Node3D::setScale(const Vec3& var) {
#ifndef DORA_NO_RUST
	dora_3d_node_set_scale(_handle, var.x, var.y, var.z);
#endif // DORA_NO_RUST
}

const Vec3& Node3D::getScale() const noexcept {
#ifndef DORA_NO_RUST
	float data[3] = {};
	dora_3d_node_get_scale(_handle, data);
	copyVec3(_scale, data);
#endif // DORA_NO_RUST
	return _scale;
}

void Node3D::setRotation(const Quat& var) {
	Quat rotation = bx::normalize(var);
#ifndef DORA_NO_RUST
	dora_3d_node_set_rotation(_handle, rotation.x, rotation.y, rotation.z, rotation.w);
#endif // DORA_NO_RUST
}

const Quat& Node3D::getRotation() const noexcept {
#ifndef DORA_NO_RUST
	float data[4] = {};
	dora_3d_node_get_rotation(_handle, data);
	copyQuat(_rotation, data);
#endif // DORA_NO_RUST
	return _rotation;
}

void Node3D::setEulerAngles(float x, float y, float z) {
	setEulerAngles({x, y, z});
}

void Node3D::setEulerAngles(const Vec3& var) {
#ifndef DORA_NO_RUST
	dora_3d_node_set_euler(_handle, var.x, var.y, var.z);
#endif // DORA_NO_RUST
}

const Vec3& Node3D::getEulerAngles() const noexcept {
#ifndef DORA_NO_RUST
	float data[3] = {};
	dora_3d_node_get_euler(_handle, data);
	copyVec3(_eulerAngles, data);
#endif // DORA_NO_RUST
	return _eulerAngles;
}

void Node3D::setTag(String var) {
	_tag = var.toString();
#ifndef DORA_NO_RUST
	dora_3d_node_set_tag(_handle, _tag.c_str());
	if (_parent) {
		dora_3d_node_add_child(_parent->_handle, _handle, _order, _tag.c_str());
	}
#endif // DORA_NO_RUST
}

const std::string& Node3D::getTag() const noexcept {
	return _tag;
}

void Node3D::setVisible(bool var) {
#ifndef DORA_NO_RUST
	dora_3d_node_set_visible(_handle, var ? 1 : 0);
#endif // DORA_NO_RUST
}

bool Node3D::isVisible() const noexcept {
#ifndef DORA_NO_RUST
	return dora_3d_node_is_visible(_handle) != 0;
#else
	return true;
#endif // DORA_NO_RUST
}

Node3D* Node3D::getParent() const noexcept {
	return _parent;
}

bool Node3D::hasChildren() const noexcept {
	return !_children.empty();
}

const std::vector<Ref<Node3D>>& Node3D::getChildren() {
	return _children;
}

void Node3D::addChild(Node3D* child, int order, String tag) {
	if (!child || child == this) return;
	if (child->_parent == this) {
		child->setOrder(order);
		child->setTag(tag);
		return;
	}
	child->removeFromParent(false);
	child->_parent = this;
	child->_order = order;
	child->_tag = tag.toString();
	_children.push_back(Ref<Node3D>(child));
#ifndef DORA_NO_RUST
	dora_3d_node_add_child(_handle, child->_handle, order, child->_tag.c_str());
#endif // DORA_NO_RUST
	markReorder();
}

void Node3D::addChild(Node3D* child, int order) {
	if (!child) return;
	addChild(child, order, child->getTag());
}

void Node3D::addChild(Node3D* child) {
	if (!child) return;
	addChild(child, child->getOrder(), child->getTag());
}

void Node3D::removeChild(Node3D* child, bool cleanup) {
	if (!child || child->_parent != this) return;
	auto it = std::find_if(_children.begin(), _children.end(), [child](const Ref<Node3D>& item) {
		return item.get() == child;
	});
	if (it != _children.end()) {
#ifndef DORA_NO_RUST
		dora_3d_node_remove_child(_handle, child->_handle);
#endif // DORA_NO_RUST
		if (cleanup) {
			(*it)->cleanup();
		}
		(*it)->_parent = nullptr;
		_children.erase(it);
	}
}

void Node3D::removeAllChildren(bool cleanup) {
	for (auto& child : _children) {
#ifndef DORA_NO_RUST
		dora_3d_node_remove_child(_handle, child->_handle);
#endif // DORA_NO_RUST
		if (cleanup) {
			child->cleanup();
		}
		child->_parent = nullptr;
	}
	_children.clear();
}

void Node3D::removeFromParent(bool cleanup) {
	if (_parent) {
		_parent->removeChild(this, cleanup);
#ifndef DORA_NO_RUST
	} else if (_handle != 0) {
		dora_3d_node_remove_from_parent(_handle);
#endif // DORA_NO_RUST
		if (cleanup) {
			this->cleanup();
		}
	}
}

void Node3D::sortAllChildren() {
	if (_reorderDirty) {
		std::stable_sort(_children.begin(), _children.end(), [](const Ref<Node3D>& a, const Ref<Node3D>& b) {
			return a->getOrder() < b->getOrder();
		});
		_reorderDirty = false;
	}
}

const Matrix& Node3D::getWorldMatrix() const noexcept {
#ifndef DORA_NO_RUST
	dora_3d_node_get_world_matrix(_handle, _worldMatrix.m);
#endif // DORA_NO_RUST
	return _worldMatrix;
}

bool Node3D::update(double) {
	return true;
}

Vec3 Node3D::convertToWorldSpace(const Vec3& localPoint) {
	Vec3 out{0.0f, 0.0f, 0.0f};
#ifndef DORA_NO_RUST
	float data[3] = {};
	dora_3d_node_convert_to_world(_handle, localPoint.x, localPoint.y, localPoint.z, data);
	copyVec3(out, data);
#endif // DORA_NO_RUST
	return out;
}

Vec3 Node3D::convertToNodeSpace(const Vec3& worldPoint) {
	Vec3 out{0.0f, 0.0f, 0.0f};
#ifndef DORA_NO_RUST
	float data[3] = {};
	dora_3d_node_convert_to_node(_handle, worldPoint.x, worldPoint.y, worldPoint.z, data);
	copyVec3(out, data);
#endif // DORA_NO_RUST
	return out;
}

void Node3D::markReorder() noexcept {
	_reorderDirty = true;
}

uint64_t Node3D::getHandle() const noexcept {
	return _handle;
}

ScheduledItem* Node3D::getScheduledItem() {
	if (!_scheduledItem) {
		_scheduledItem = New<ScheduledItemWrapper<Node3D>>(this);
	}
	return _scheduledItem.get();
}

void Node3D::cleanup() {
	if (_scheduledItem && _scheduledItem->iter) {
		_scheduler->unschedule(_scheduledItem.get());
	}
	removeAllChildren(true);
	_parent = nullptr;
#ifndef DORA_NO_RUST
	if (_handle != 0) {
		dora_3d_node_destroy(_handle);
		_handle = 0;
	}
#endif // DORA_NO_RUST
	Object::cleanup();
}

Node3D::~Node3D() {
	if (_scheduledItem && _scheduledItem->iter) {
		_scheduler->unschedule(_scheduledItem.get());
	}
#ifndef DORA_NO_RUST
	if (_handle != 0) {
		dora_3d_node_destroy(_handle);
		_handle = 0;
	}
#endif // DORA_NO_RUST
}

NS_DORA_END

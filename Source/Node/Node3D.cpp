/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Node3D.h"

#include "Render/RenderPass3D.h"

NS_DORA_BEGIN

Node3D::Node3D()
	: _order(0)
	, _position{0.0f, 0.0f, 0.0f}
	, _scale{1.0f, 1.0f, 1.0f}
	, _rotation(bx::InitIdentity)
	, _visible(true)
	, _transformDirty(true)
	, _worldDirty(true)
	, _reorderDirty(false)
	, _parent(nullptr)
	, _localMatrix(Matrix::Indentity)
	, _worldMatrix(Matrix::Indentity)
	, _eulerAngles{0.0f, 0.0f, 0.0f} { }

bool Node3D::init() {
	return Object::init();
}

void Node3D::setOrder(int var) {
	if (_order != var) {
		_order = var;
		if (_parent) {
			_parent->markReorder();
		}
	}
}

int Node3D::getOrder() const noexcept {
	return _order;
}

void Node3D::setPosition(const Vec3& var) {
	if (_position != var) {
		_position = var;
		markDirty();
	}
}

const Vec3& Node3D::getPosition() const noexcept {
	return _position;
}

void Node3D::setScale(const Vec3& var) {
	if (_scale != var) {
		_scale = var;
		markDirty();
	}
}

const Vec3& Node3D::getScale() const noexcept {
	return _scale;
}

void Node3D::setRotation(const Quat& var) {
	Quat rotation = bx::normalize(var);
	if (!bx::isEqual(_rotation, rotation, 0.0001f)) {
		_rotation = rotation;
		markDirty();
	}
}

const Quat& Node3D::getRotation() const noexcept {
	return _rotation;
}

void Node3D::setEulerAngles(const Vec3& var) {
	setRotation(bx::fromEuler(bx::Vec3{
		bx::toRad(var.x),
		bx::toRad(var.y),
		bx::toRad(var.z)}));
}

const Vec3& Node3D::getEulerAngles() const noexcept {
	bx::Vec3 euler = bx::toEuler(_rotation);
	_eulerAngles = {
		bx::toDeg(euler.x),
		bx::toDeg(euler.y),
		bx::toDeg(euler.z)};
	return _eulerAngles;
}

void Node3D::setTag(String var) {
	_tag = var.toString();
}

const std::string& Node3D::getTag() const noexcept {
	return _tag;
}

void Node3D::setVisible(bool var) {
	_visible = var;
}

bool Node3D::isVisible() const noexcept {
	return _visible;
}

Node3D* Node3D::getParent() const noexcept {
	return _parent;
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
	child->removeFromParent();
	child->_parent = this;
	child->_order = order;
	child->_tag = tag.toString();
	_children.push_back(Ref<Node3D>(child));
	child->markDirty();
	markReorder();
}

void Node3D::removeChild(Node3D* child) {
	if (!child || child->_parent != this) return;
	auto it = std::find_if(_children.begin(), _children.end(), [child](const Ref<Node3D>& item) {
		return item.get() == child;
	});
	if (it != _children.end()) {
		(*it)->_parent = nullptr;
		(*it)->markDirty();
		_children.erase(it);
	}
}

void Node3D::removeAllChildren() {
	for (auto& child : _children) {
		child->_parent = nullptr;
		child->markDirty();
	}
	_children.clear();
}

void Node3D::removeFromParent() {
	if (_parent) {
		_parent->removeChild(this);
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

void Node3D::updateLocalMatrix() {
	if (_transformDirty) {
		bx::mtxFromQuaternion(_localMatrix.m, _rotation);
		_localMatrix.m[0] *= _scale.x;
		_localMatrix.m[1] *= _scale.x;
		_localMatrix.m[2] *= _scale.x;
		_localMatrix.m[4] *= _scale.y;
		_localMatrix.m[5] *= _scale.y;
		_localMatrix.m[6] *= _scale.y;
		_localMatrix.m[8] *= _scale.z;
		_localMatrix.m[9] *= _scale.z;
		_localMatrix.m[10] *= _scale.z;
		_localMatrix.m[12] = _position.x;
		_localMatrix.m[13] = _position.y;
		_localMatrix.m[14] = _position.z;
		_transformDirty = false;
	}
}

const Matrix& Node3D::getWorldMatrix() const noexcept {
	auto self = const_cast<Node3D*>(this);
	if (self->_worldDirty) {
		self->updateLocalMatrix();
		if (self->_parent) {
			Matrix::mulMtx(self->_worldMatrix, self->_parent->getWorldMatrix(), self->_localMatrix);
		} else {
			self->_worldMatrix = self->_localMatrix;
		}
		self->_worldDirty = false;
		for (auto& child : self->_children) {
			child->_worldDirty = true;
		}
	}
	return self->_worldMatrix;
}

void Node3D::visit(RenderPass3D& renderPass, Camera3D* camera) {
	if (!_visible) return;
	getWorldMatrix();
	if (!_children.empty()) {
		sortAllChildren();
		size_t index = 0;
		for (; index < _children.size(); index++) {
			Node3D* child = _children[index].get();
			if (child->getOrder() >= 0) break;
			child->visit(renderPass, camera);
		}
		render(renderPass, camera);
		for (; index < _children.size(); index++) {
			_children[index]->visit(renderPass, camera);
		}
	} else {
		render(renderPass, camera);
	}
}

void Node3D::render(RenderPass3D&, Camera3D*) { }

Vec3 Node3D::convertToWorldSpace(const Vec3& localPoint) {
	Vec4 result;
	Matrix::mulVec4(result, getWorldMatrix(), Vec4::from(localPoint, 1.0f));
	return result.toVec3();
}

Vec3 Node3D::convertToNodeSpace(const Vec3& worldPoint) {
	Matrix inverse;
	bx::mtxInverse(inverse.m, getWorldMatrix().m);
	Vec4 result;
	Matrix::mulVec4(result, inverse, Vec4::from(worldPoint, 1.0f));
	return result.toVec3();
}

void Node3D::markDirty() noexcept {
	_transformDirty = true;
	_worldDirty = true;
	for (auto& child : _children) {
		child->_worldDirty = true;
	}
}

void Node3D::markReorder() noexcept {
	_reorderDirty = true;
}

NS_DORA_END

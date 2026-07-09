/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Visual3D.h"

#include "Effect/Material.h"

#ifndef DORA_NO_RUST
extern "C" {
void dora_3d_visual_set_frustum_culling(uint64_t visual, int32_t enabled);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

Visual3D::Visual3D()
	: _frustumCulling(true)
	, _localBounds{{0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f}}
	, _worldBounds(_localBounds)
	, _meshHandle(nullptr)
	, _rustVisual(0) { }

void Visual3D::setFrustumCulling(bool var) {
	_frustumCulling = var;
#ifndef DORA_NO_RUST
	if (_rustVisual != 0) {
		dora_3d_visual_set_frustum_culling(_rustVisual, var ? 1 : 0);
	}
#endif // DORA_NO_RUST
}

bool Visual3D::isFrustumCulling() const noexcept {
	return _frustumCulling;
}

void Visual3D::setLocalBounds(const AABB& var) {
	_localBounds = var;
}

const AABB& Visual3D::getLocalBounds() const noexcept {
	return _localBounds;
}

const AABB& Visual3D::getWorldBounds() const noexcept {
	auto self = const_cast<Visual3D*>(this);
	Matrix::mulAABB(self->_worldBounds, getWorldMatrix(), _localBounds);
	return self->_worldBounds;
}

void Visual3D::setMaterial(Material* var) {
	_material = var;
}

Material* Visual3D::getMaterial() const noexcept {
	return _material;
}

void Visual3D::setMeshHandle(void* var) {
	_meshHandle = var;
}

void* Visual3D::getMeshHandle() const noexcept {
	return _meshHandle;
}

void Visual3D::setRustVisual(uint64_t var) {
	_rustVisual = var;
#ifndef DORA_NO_RUST
	if (_rustVisual != 0) {
		dora_3d_visual_set_frustum_culling(_rustVisual, _frustumCulling ? 1 : 0);
	}
#endif // DORA_NO_RUST
}

uint64_t Visual3D::getRustVisual() const noexcept {
	return _rustVisual;
}

NS_DORA_END

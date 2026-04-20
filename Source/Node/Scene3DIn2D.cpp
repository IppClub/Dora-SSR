/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Scene3DIn2D.h"

#include "Node/Node3D.h"
#include "Render/Camera3D.h"
#include "Render/View.h"

NS_DORA_BEGIN

Scene3DIn2D::Scene3DIn2D()
	: Node(false) { }

bool Scene3DIn2D::init() {
	if (!Node::init()) return false;
	_scene = Node3D::create();
	_camera = Camera3D::create("Scene3D"_slice);
	return _scene != nullptr && _camera != nullptr;
}

void Scene3DIn2D::setCamera(Camera3D* var) {
	_camera = var ? var : Camera3D::create("Scene3D"_slice);
}

Camera3D* Scene3DIn2D::getCamera() const noexcept {
	return _camera;
}

Node3D* Scene3DIn2D::getScene() {
	return _scene;
}

void Scene3DIn2D::render() {
	Node::render();
	if (!_scene || !_camera) return;
	SharedView.pushBack("Scene3D"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::setViewClear(viewId, BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL, 0, 1.0f, 0);
		bgfx::setViewTransform(viewId, _camera->getViewMatrix().m, _camera->getProjectionMatrix().m);
		_renderPass.reset();
		_scene->visit(_renderPass, _camera);
		_renderPass.sort();
		_renderPass.submit(viewId);
	});
}

NS_DORA_END

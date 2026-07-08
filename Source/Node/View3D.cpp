/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/View3D.h"

#include "Node/Node3D.h"
#include "Render/Camera3D.h"
#include "Render/View.h"

#ifndef DORA_NO_RUST
extern "C" {
void dora_3d_set_view_state(uint16_t view_id, const float* view_proj, float eye_x, float eye_y, float eye_z);
int32_t dora_3d_render_node(uint16_t view_id, uint64_t node);
int32_t dora_3d_set_environment_equirect(const char* path);
void dora_3d_set_environment_intensity(float diffuse, float specular, float exposure);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

View3D::View3D()
	: Node(false) { }

View3D::~View3D() { }

bool View3D::init() {
	if (!Node::init()) return false;
	_scene = Node3D::create();
	_camera = Camera3D::create("Scene3D"_slice);
	return _scene != nullptr && _camera != nullptr;
}

void View3D::setCamera(Camera3D* var) {
	_camera = var ? var : Camera3D::create("Scene3D"_slice);
}

Camera3D* View3D::getCamera() const noexcept {
	return _camera;
}

Node3D* View3D::getScene() {
	return _scene;
}

void View3D::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		if (_scene) {
			_scene->removeAllChildren(true);
			_scene->cleanup();
			_scene = nullptr;
		}
		_camera = nullptr;
		Node::cleanup();
	}
}

bool View3D::setEnvironmentMap(String path) {
#ifdef DORA_NO_RUST
	return false;
#else
	return dora_3d_set_environment_equirect(path.toString().c_str()) != 0;
#endif // DORA_NO_RUST
}

void View3D::setEnvironmentIntensity(float diffuse, float specular, float exposure) {
#ifndef DORA_NO_RUST
	dora_3d_set_environment_intensity(diffuse, specular, exposure);
#endif // DORA_NO_RUST
}

void View3D::render() {
	Node::render();
	if (!_scene || !_camera) return;
	SharedView.pushBack("View3D"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::setViewClear(viewId, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL, 0x00000000, 1.0f, 0);
		bgfx::setViewTransform(viewId, _camera->getViewMatrix().m, _camera->getProjectionMatrix().m);
#ifndef DORA_NO_RUST
		Matrix viewProj;
		Matrix::mulMtx(viewProj, _camera->getProjectionMatrix(), _camera->getViewMatrix());
		Matrix flipX = Matrix::Indentity;
		flipX.m[0] = -1.0f;
		Matrix::mulMtx(viewProj, flipX, viewProj);
		const Vec3& eye = _camera->getPosition();
		dora_3d_set_view_state(viewId, viewProj.m, eye.x, eye.y, eye.z);
		dora_3d_render_node(viewId, _scene->getHandle());
#endif // DORA_NO_RUST
	});
}

NS_DORA_END

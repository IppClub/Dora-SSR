/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/View3D.h"

#include "Basic/Director.h"
#include "Node/Node3D.h"
#include "Render/Camera.h"
#include "Render/View.h"

#ifndef DORA_NO_RUST
extern "C" {
void dora_3d_set_view_state(uint16_t view_id, const float* view_proj, float eye_x, float eye_y, float eye_z);
void dora_3d_set_view_frustum_culling(uint16_t view_id, int32_t enabled);
int32_t dora_3d_render_node(uint16_t view_id, uint64_t node);
int32_t dora_3d_prepare_environment_equirect(const char* path);
int32_t dora_3d_set_view_environment(uint16_t view_id, const char* path, float diffuse, float specular, float exposure);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

View3D::View3D()
	: Node(false)
	, _environmentDiffuse(1.0f)
	, _environmentSpecular(1.0f)
	, _environmentExposure(1.0f) { }

View3D::~View3D() { }

bool View3D::init() {
	if (!Node::init()) return false;
	_scene = Node3D::create();
	return _scene != nullptr;
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
		Node::cleanup();
	}
}

bool View3D::setEnvironmentMap(String path) {
#ifdef DORA_NO_RUST
	return false;
#else
	std::string nextPath = path.toString();
	if (dora_3d_prepare_environment_equirect(nextPath.c_str()) == 0) {
		return false;
	}
	_environmentMap = std::move(nextPath);
	return true;
#endif // DORA_NO_RUST
}

void View3D::setEnvironmentIntensity(float diffuse, float specular, float exposure) {
	_environmentDiffuse = std::max(diffuse, 0.0f);
	_environmentSpecular = std::max(specular, 0.0f);
	_environmentExposure = std::max(exposure, 0.0f);
}

void View3D::render() {
	Node::render();
	if (!_scene) return;
	Camera* camera = SharedDirector.getCurrentCamera();
	const Matrix& directorViewProj = SharedDirector.getViewProjection();
	const Vec3& eye = camera->getPosition();
	SharedView.pushBack("View3D"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::setViewClear(viewId, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL, 0x00000000, 1.0f, 0);
#ifndef DORA_NO_RUST
		Matrix viewProj = directorViewProj;
		Matrix flipX = Matrix::Indentity;
		flipX.m[0] = -1.0f;
		Matrix::mulMtx(viewProj, flipX, viewProj);
		dora_3d_set_view_state(viewId, viewProj.m, eye.x, eye.y, eye.z);
		dora_3d_set_view_frustum_culling(viewId, SharedView.isFrustumCulling() ? 1 : 0);
		dora_3d_set_view_environment(viewId, _environmentMap.c_str(), _environmentDiffuse, _environmentSpecular, _environmentExposure);
		dora_3d_render_node(viewId, _scene->getHandle());
#endif // DORA_NO_RUST
	});
}

NS_DORA_END

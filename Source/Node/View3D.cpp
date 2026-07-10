/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/View3D.h"

#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Cache/Model3DCache.h"
#include "Common/WRef.h"
#include "Node/Node3D.h"
#include "Render/Camera.h"
#include "Render/View.h"

#ifndef DORA_NO_RUST
extern "C" {
void dora_3d_set_view_state(uint16_t view_id, const float* view_proj, float eye_x, float eye_y, float eye_z);
void dora_3d_set_view_frustum_culling(uint16_t view_id, int32_t enabled);
int32_t dora_3d_render_node(uint16_t view_id, uint64_t node);
int32_t dora_3d_get_render_stats(uint16_t view_id, uint64_t* out, uint32_t count);
int32_t dora_3d_set_view_environment(uint16_t view_id, const char* path, float diffuse, float specular, float exposure);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

View3D::View3D()
	: Node(false)
	, _environmentDiffuse(1.0f)
	, _environmentSpecular(1.0f)
	, _environmentExposure(1.0f)
	, _lastViewId(std::numeric_limits<uint16_t>::max()) { }

View3D::~View3D() { }

bool View3D::init() {
	return Node::init();
}

Node3D* View3D::getScene() {
	if (!_scene) {
		_scene = Node3D::create();
	}
	return _scene;
}

const RenderStats3D& View3D::getStats() const noexcept {
#ifndef DORA_NO_RUST
	uint64_t values[30] = {};
	if (dora_3d_get_render_stats(_lastViewId, values, 30) != 0) {
		_stats.sceneNodes = s_cast<uint32_t>(values[0]);
		_stats.visibleVisuals = s_cast<uint32_t>(values[1]);
		_stats.culledVisuals = s_cast<uint32_t>(values[2]);
		_stats.opaqueItems = s_cast<uint32_t>(values[3]);
		_stats.transparentItems = s_cast<uint32_t>(values[4]);
		_stats.drawCalls = s_cast<uint32_t>(values[5]);
		_stats.triangles = values[6];
		_stats.programSwitches = s_cast<uint32_t>(values[7]);
		_stats.materialSwitches = s_cast<uint32_t>(values[8]);
		_stats.textureSwitches = s_cast<uint32_t>(values[9]);
		_stats.meshSwitches = s_cast<uint32_t>(values[10]);
		_stats.nodeCount = s_cast<uint32_t>(values[11]);
		_stats.visualCount = s_cast<uint32_t>(values[12]);
		_stats.modelCount = s_cast<uint32_t>(values[13]);
		_stats.modelInstanceCount = s_cast<uint32_t>(values[14]);
		_stats.meshCount = s_cast<uint32_t>(values[15]);
		_stats.materialCount = s_cast<uint32_t>(values[16]);
		_stats.textureCount = s_cast<uint32_t>(values[17]);
		_stats.animationCount = s_cast<uint32_t>(values[18]);
		_stats.environmentCount = s_cast<uint32_t>(values[19]);
		_stats.modelResidentBytes = values[20];
		_stats.meshResidentBytes = values[21];
		_stats.textureResidentBytes = values[22];
		_stats.collectMicros = values[23];
		_stats.sortMicros = values[24];
		_stats.submitMicros = values[25];
		_stats.uploadCommands = values[26];
		_stats.uploadBytes = values[27];
		_stats.uploadMicros = values[28];
		_stats.uploadMaxCommandMicros = values[29];
	}
#endif // DORA_NO_RUST
	return _stats;
}

void View3D::addChild(Node3D* child, int order, String tag) {
	if (!child) return;
	if (Node3D* scene = getScene()) {
		scene->addChild(child, order, tag);
	}
}

void View3D::addChild(Node3D* child, int order) {
	if (!child) return;
	addChild(child, order, child->getTag());
}

void View3D::addChild(Node3D* child) {
	if (!child) return;
	addChild(child, child->getOrder(), child->getTag());
}

void View3D::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		if (_scene) {
			_scene->removeAllChildren(true);
			_scene->cleanup();
			_scene = nullptr;
		}
		_lastViewId = std::numeric_limits<uint16_t>::max();
		_stats = {};
		++_environmentGeneration;
		_environmentMap.clear();
	}
}

bool View3D::setEnvironmentMap(String path) {
#ifdef DORA_NO_RUST
	return false;
#else
	std::string nextPath = path.toString();
	++_environmentGeneration;
	if (nextPath.empty()) {
		_environmentMap.clear();
		return true;
	}
	std::string file = SharedContent.getFullPath(nextPath);
	if (file.empty()) return false;
	uint64_t generation = _environmentGeneration;
	WRef<View3D> self(this);
	SharedModel3DCache.loadEnvironmentAsync(file, [self, generation, file](bool success) {
		View3D* view = self.get();
		if (!view || view->_environmentGeneration != generation) return;
		if (success) {
			view->_environmentMap = file;
		}
	});
	return true;
#endif // DORA_NO_RUST
}

void View3D::setEnvironmentIntensity(float diffuse, float specular, float exposure) {
	_environmentDiffuse = std::max(diffuse, 0.0f);
	_environmentSpecular = std::max(specular, 0.0f);
	_environmentExposure = std::max(exposure, 0.0f);
}

void View3D::render3D(bgfx::ViewId viewId) {
	if (!_scene || !_scene->hasChildren()) return;
	Camera* camera = SharedDirector.getCurrentCamera();
	const Matrix& directorViewProj = SharedDirector.getViewProjection();
	const Vec3& eye = camera->getPosition();
#ifndef DORA_NO_RUST
	Matrix viewProj = directorViewProj;
	Matrix flipX = Matrix::Indentity;
	flipX.m[0] = -1.0f;
	Matrix::mulMtx(viewProj, flipX, viewProj);
	dora_3d_set_view_state(viewId, viewProj.m, eye.x, eye.y, eye.z);
	dora_3d_set_view_frustum_culling(viewId, SharedView.isFrustumCulling() ? 1 : 0);
	dora_3d_set_view_environment(viewId, _environmentMap.c_str(), _environmentDiffuse, _environmentSpecular, _environmentExposure);
	dora_3d_render_node(viewId, _scene->getHandle());
	_lastViewId = viewId;
#endif // DORA_NO_RUST
}

void View3D::render() {
	bool has2DChildren = hasChildren();
	Node::render();
	if (!_scene || !_scene->hasChildren()) {
		_lastViewId = std::numeric_limits<uint16_t>::max();
		return;
	}
	if (this == SharedDirector.getEntry() && !has2DChildren) {
		render3D(SharedView.getId());
		return;
	}
	SharedView.pushBack("View3D"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::setViewClear(viewId, BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL, 0x00000000, 1.0f, 0);
		render3D(viewId);
	});
}

NS_DORA_END

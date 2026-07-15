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
#include "Node/Model3D.h"
#include "Node/Node3D.h"
#include "Node/Surface3D.h"
#include "Render/Camera.h"
#include "Render/View.h"

#ifndef DORA_NO_RUST
extern "C" {
void dora_3d_set_view_state(uint16_t view_id, const float* view_proj, float eye_x, float eye_y, float eye_z);
void dora_3d_set_view_frustum_culling(uint16_t view_id, int32_t enabled);
void dora_3d_set_view_show_aabb(uint16_t view_id, int32_t enabled);
void dora_3d_set_view_shadow_map_size(uint16_t view_id, uint16_t size);
int32_t dora_3d_render_node(uint16_t view_id, uint64_t node);
int32_t dora_3d_render_node_with_shadow(uint16_t view_id, uint16_t shadow_view_id, uint64_t node);
int32_t dora_3d_scene_has_shadow_light(uint64_t node);
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
	, _showAABB(false)
	, _shadowMapSize(1024)
	, _lastViewId(std::numeric_limits<uint16_t>::max()) { }

View3D::~View3D() { }

bool View3D::init() {
	return Node::init();
}

Node3D* View3D::getScene() {
	if (!_scene) {
		_scene = Node3D::create(false);
	}
	return _scene;
}

const RenderStats3D& View3D::getStats() const noexcept {
#ifndef DORA_NO_RUST
	uint64_t values[32] = {};
	if (dora_3d_get_render_stats(_lastViewId, values, 32) != 0) {
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
		_stats.staticMeshCount = s_cast<uint32_t>(values[16]);
		_stats.dynamicMeshCount = s_cast<uint32_t>(values[17]);
		_stats.materialCount = s_cast<uint32_t>(values[18]);
		_stats.textureCount = s_cast<uint32_t>(values[19]);
		_stats.animationCount = s_cast<uint32_t>(values[20]);
		_stats.environmentCount = s_cast<uint32_t>(values[21]);
		_stats.modelResidentBytes = values[22];
		_stats.meshResidentBytes = values[23];
		_stats.textureResidentBytes = values[24];
		_stats.collectMicros = values[25];
		_stats.sortMicros = values[26];
		_stats.submitMicros = values[27];
		_stats.uploadCommands = values[28];
		_stats.uploadBytes = values[29];
		_stats.uploadMicros = values[30];
		_stats.uploadMaxCommandMicros = values[31];
	}
#endif // DORA_NO_RUST
	return _stats;
}

bool View3D::isShowAABB() const noexcept {
	return _showAABB;
}

void View3D::setShowAABB(bool var) {
	_showAABB = var;
}

uint16_t View3D::getShadowMapSize() const noexcept {
	return _shadowMapSize;
}

void View3D::setShadowMapSize(uint16_t size) {
	static constexpr uint16_t sizes[] = {256, 512, 1024, 2048, 4096};
	uint16_t nearest = sizes[0];
	uint32_t nearestDistance = std::abs(s_cast<int32_t>(size) - s_cast<int32_t>(nearest));
	for (uint16_t candidate : sizes) {
		uint32_t distance = std::abs(s_cast<int32_t>(size) - s_cast<int32_t>(candidate));
		if (distance < nearestDistance) {
			nearest = candidate;
			nearestDistance = distance;
		}
	}
	_shadowMapSize = nearest;
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

bool View3D::getScreenRay(const Vec2& viewPoint, Vec3& origin, Vec3& direction) const {
	Size viewSize = SharedView.getSize();
	if (viewSize.width <= 0.0f || viewSize.height <= 0.0f) return false;
	Matrix viewProj = SharedDirector.getViewProjection();
	Matrix flipX = Matrix::Indentity;
	flipX.m[0] = -1.0f;
	Matrix::mulMtx(viewProj, flipX, viewProj);
	Matrix inverse;
	bx::mtxInverse(inverse.m, viewProj.m);
	float ndcX = viewPoint.x / viewSize.width * 2.0f - 1.0f;
	float ndcY = viewPoint.y / viewSize.height * 2.0f - 1.0f;
	float nearZ = bgfx::getCaps()->homogeneousDepth ? -1.0f : 0.0f;
	auto unproject = [&inverse, ndcX, ndcY](float z, Vec3& result) {
		Vec4 world;
		Matrix::mulVec4(world, inverse, {ndcX, ndcY, z, 1.0f});
		if (std::abs(world.w) <= FLT_EPSILON) return false;
		float inverseW = 1.0f / world.w;
		result = {world.x * inverseW, world.y * inverseW, world.z * inverseW};
		return true;
	};
	Vec3 farPoint;
	if (!unproject(nearZ, origin) || !unproject(1.0f, farPoint)) return false;
	bx::Vec3 ray = bx::sub(farPoint, origin);
	float length = bx::length(ray);
	if (length <= FLT_EPSILON) return false;
	direction = Vec3::from(bx::mul(ray, 1.0f / length));
	return true;
}

Vec3 View3D::getRayOrigin(const Vec2& viewPoint) const {
	Vec3 origin{0.0f, 0.0f, 0.0f};
	Vec3 direction{0.0f, 0.0f, 0.0f};
	getScreenRay(viewPoint, origin, direction);
	return origin;
}

Vec3 View3D::getRayDirection(const Vec2& viewPoint) const {
	Vec3 origin{0.0f, 0.0f, 0.0f};
	Vec3 direction{0.0f, 0.0f, 0.0f};
	getScreenRay(viewPoint, origin, direction);
	return direction;
}

Model3D* View3D::pick(const Vec2& viewPoint) const {
	if (!_scene) return nullptr;
	Vec3 origin;
	Vec3 direction;
	if (!getScreenRay(viewPoint, origin, direction)) return nullptr;
	Model3D* result = nullptr;
	float nearest = std::numeric_limits<float>::infinity();
	std::function<void(Node3D*)> visit = [&](Node3D* node) {
		if (!node || !node->isVisible()) return;
		if (Model3D* model = DoraAs<Model3D>(node)) {
			float distance = model->rayCast(origin, direction);
			if (distance >= 0.0f && distance < nearest) {
				nearest = distance;
				result = model;
			}
		}
		for (const auto& child : node->getChildren()) visit(child.get());
	};
	visit(_scene);
	return result;
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
	dora_3d_set_view_show_aabb(viewId, _showAABB ? 1 : 0);
	dora_3d_set_view_shadow_map_size(viewId, _shadowMapSize);
	dora_3d_set_view_environment(viewId, _environmentMap.c_str(), _environmentDiffuse, _environmentSpecular, _environmentExposure);
	if (dora_3d_scene_has_shadow_light(_scene->getHandle()) != 0) {
		bgfx::ViewId shadowViewId = 0;
		SharedView.pushInsertionMode(true, [&]() {
			SharedView.pushFront("Shadow3D"_slice, [&]() {
				shadowViewId = SharedView.getId();
			});
		});
		dora_3d_render_node_with_shadow(viewId, shadowViewId, _scene->getHandle());
	} else {
		dora_3d_render_node(viewId, _scene->getHandle());
	}
	// Surface3D has two adaptive paths. Isolated 2D render-target views must be
	// recorded before the final Surface3D view. The final view uses the same
	// framebuffer without clearing, so it preserves the 3D depth buffer while
	// keeping C++ 2D submissions ordered after the Rust 3D renderer.
	std::vector<Surface3D*> surfaces;
	std::function<void(Node3D*)> collectSurfaces = [&](Node3D* node) {
		if (!node || !node->isVisible()) return;
		if (auto surface = DoraAs<Surface3D>(node)) surfaces.push_back(surface);
		for (const auto& child : node->getChildren()) collectSurfaces(child.get());
	};
	collectSurfaces(_scene);
	std::stable_sort(surfaces.begin(), surfaces.end(), [camera](Surface3D* a, Surface3D* b) {
		Vec3 ap{a->getWorldMatrix().m[12], a->getWorldMatrix().m[13], a->getWorldMatrix().m[14]};
		Vec3 bp{b->getWorldMatrix().m[12], b->getWorldMatrix().m[13], b->getWorldMatrix().m[14]};
		auto ad = bx::sub(camera->getPosition(), ap);
		auto bd = bx::sub(camera->getPosition(), bp);
		return bx::dot(ad, ad) > bx::dot(bd, bd);
	});
	if (!surfaces.empty()) {
		for (auto surface : surfaces) surface->prepare(*camera);
		SharedView.pushBack("Surface3D"_slice, [&]() {
			for (auto surface : surfaces) surface->renderPrepared();
		});
	}
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

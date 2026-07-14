/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Physics/PhysicsWorld.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Common/Async.h"
#include "Node/DrawNode.h"
#include "Node/Node3D.h"
#include "Node/View3D.h"
#include "Physics/Body.h"
#include "Physics/DebugDraw.h"
#include "Physics/Joint.h"
#include "Physics/Sensor.h"
#include "playrho/d2/Distance.hpp"
#include "playrho/d2/DynamicTree.hpp"
#include "playrho/d2/Manifold.hpp"

NS_DORA_BEGIN

extern "C" {
uint64_t dora_3d_physics_world_create(uint32_t maxBodies);
void dora_3d_physics_world_destroy(uint64_t world);
void dora_3d_physics_world_set_gravity(uint64_t world, float x, float y, float z);
int32_t dora_3d_physics_world_step(uint64_t world, float deltaTime);
uint64_t dora_3d_physics_body_create_box(uint64_t world, uint64_t node, float halfX, float halfY, float halfZ, uint8_t motion);
uint64_t dora_3d_physics_body_create_sphere(uint64_t world, uint64_t node, float radius, uint8_t motion);
uint64_t dora_3d_physics_body_create_capsule(uint64_t world, uint64_t node, float halfHeight, float radius, uint8_t motion);
int32_t dora_3d_physics_body_destroy(uint64_t world, uint64_t body);
int32_t dora_3d_physics_body_sync_transform(uint64_t world, uint64_t body);
int32_t dora_3d_physics_body_get_bounds(uint64_t world, uint64_t body, float* out);
void dora_3d_queue_physics_debug_bounds(uint64_t root, float minX, float minY, float minZ, float maxX, float maxY, float maxZ, float red, float green, float blue);
void dora_3d_queue_physics_debug_shape(uint64_t root, uint8_t type, float x, float y, float z, const float* transform, float red, float green, float blue);
int32_t dora_3d_physics_body_set_linear_velocity(uint64_t world, uint64_t body, float x, float y, float z);
int32_t dora_3d_physics_body_get_linear_velocity(uint64_t world, uint64_t body, float* out);
int32_t dora_3d_physics_body_set_angular_velocity(uint64_t world, uint64_t body, float x, float y, float z);
int32_t dora_3d_physics_body_get_angular_velocity(uint64_t world, uint64_t body, float* out);
int32_t dora_3d_physics_body_apply_force(uint64_t world, uint64_t body, float x, float y, float z);
int32_t dora_3d_physics_body_apply_impulse(uint64_t world, uint64_t body, float x, float y, float z);
int32_t dora_3d_physics_body_set_filter(uint64_t world, uint64_t body, uint8_t layer, uint32_t mask);
int32_t dora_3d_physics_body_get_filter(uint64_t world, uint64_t body, uint8_t* layer, uint32_t* mask);
int32_t dora_3d_physics_body_set_sensor(uint64_t world, uint64_t body, int32_t sensor);
int32_t dora_3d_physics_body_is_sensor(uint64_t world, uint64_t body);
uint64_t dora_3d_physics_character_create_capsule(uint64_t world, uint64_t node, float halfHeight, float radius, float maxSlopeAngle, float stepHeight);
int32_t dora_3d_physics_character_destroy(uint64_t world, uint64_t character);
int32_t dora_3d_physics_character_set_velocity(uint64_t world, uint64_t character, float x, float y, float z);
int32_t dora_3d_physics_character_jump(uint64_t world, uint64_t character, float speed);
int32_t dora_3d_physics_character_set_filter(uint64_t world, uint64_t character, uint8_t layer, uint32_t mask);
int32_t dora_3d_physics_character_get_state(uint64_t world, uint64_t character, float* velocity, uint8_t* groundState, float* groundNormal);
uint64_t dora_3d_physics_shape_create_box(float x, float y, float z);
uint64_t dora_3d_physics_shape_create_sphere(float radius);
uint64_t dora_3d_physics_shape_create_capsule(float halfHeight, float radius);
uint64_t dora_3d_physics_shape_create_compound();
uint64_t dora_3d_physics_shape_create_mesh_data(const char* path, const uint8_t* data, size_t size, int32_t (*loader)(const char*, const uint8_t**, size_t*, void*), void* userData);
uint64_t dora_3d_physics_shape_create_convex_hull_data(const char* path, const uint8_t* data, size_t size, int32_t (*loader)(const char*, const uint8_t**, size_t*, void*), void* userData);
int32_t dora_3d_physics_shape_add_child(uint64_t compound, uint64_t shape, float positionX, float positionY, float positionZ, float angleX, float angleY, float angleZ);
int32_t dora_3d_physics_shape_build(uint64_t shape);
int32_t dora_3d_physics_shape_is_built(uint64_t shape);
void dora_3d_physics_shape_destroy(uint64_t shape);
uint64_t dora_3d_physics_body_create_shape(uint64_t world, uint64_t node, uint64_t shape, uint8_t motion);
uint64_t dora_3d_physics_constraint_create_fixed(uint64_t world, uint64_t firstBody, uint64_t secondBody, float x, float y, float z);
uint64_t dora_3d_physics_constraint_create_distance(uint64_t world, uint64_t firstBody, uint64_t secondBody, float firstX, float firstY, float firstZ, float secondX, float secondY, float secondZ, float minDistance, float maxDistance);
uint64_t dora_3d_physics_constraint_create_hinge(uint64_t world, uint64_t firstBody, uint64_t secondBody, float anchorX, float anchorY, float anchorZ, float axisX, float axisY, float axisZ, float minAngle, float maxAngle);
int32_t dora_3d_physics_constraint_destroy(uint64_t world, uint64_t constraint);
int32_t dora_3d_collect_gltf_buffer_dependencies(const char* path, const uint8_t* data, size_t size, void (*visitor)(const char*, void*), void* userData);
uint32_t dora_3d_physics_world_event_count(uint64_t world);
int32_t dora_3d_physics_world_event_get(uint64_t world, uint32_t index, uint8_t* eventType, uint64_t* body, uint64_t* other, float* point, float* normal);
void dora_3d_physics_world_event_clear(uint64_t world);
int32_t dora_3d_physics_world_raycast(uint64_t world, float originX, float originY, float originZ, float directionX, float directionY, float directionZ, float distance, uint64_t* body, float* point, float* normal, float* hitDistance);
uint32_t dora_3d_physics_world_overlap_sphere(uint64_t world, float x, float y, float z, float radius, uint64_t* bodies, uint32_t capacity);
}

struct FixtureDef3DImportResource {
	OwnArray<uint8_t> data;
	size_t size = 0;
};

enum class FixtureDef3DLoadKind : uint8_t {
	Mesh,
	ConvexHull,
};

struct FixtureDef3DLoadTask {
	std::string key;
	std::string file;
	FixtureDef3DLoadKind kind = FixtureDef3DLoadKind::Mesh;
	OwnArray<uint8_t> data;
	size_t size = 0;
	std::vector<std::string> dependencies;
	std::unordered_map<std::string, FixtureDef3DImportResource> resources;
	size_t remaining = 0;
	bool failed = false;
	bool cancelled = false;
	std::vector<std::function<void(FixtureDef3D*)>> handlers;
};

static void collectFixtureDef3DDependency(const char* path, void* userData) {
	auto task = r_cast<FixtureDef3DLoadTask*>(userData);
	task->dependencies.emplace_back(path);
}

static int32_t loadFixtureDef3DResource(const char* path, const uint8_t** data, size_t* size, void* userData) {
	auto task = r_cast<FixtureDef3DLoadTask*>(userData);
	auto it = task->resources.find(path);
	if (it == task->resources.end()) return 0;
	*data = it->second.data.get();
	*size = it->second.size;
	return 1;
}

class FixtureDef3DCache : public NonCopyable {
public:
	virtual ~FixtureDef3DCache() {
		for (auto& [_, task] : _tasks) task->cancelled = true;
		_tasks.clear();
		_shapes.clear();
	}

	void loadAsync(String filename, FixtureDef3DLoadKind kind, const std::function<void(FixtureDef3D*)>& handler) {
		auto file = SharedContent.getFullPath(filename);
		if (file.empty()) {
			handler(nullptr);
			return;
		}
		auto key = std::string(kind == FixtureDef3DLoadKind::Mesh ? "mesh:" : "hull:") + file;
		if (auto it = _shapes.find(key); it != _shapes.end()) {
			if (it->second->isBuilt()) {
				handler(it->second);
				return;
			}
			_shapes.erase(it);
		}
		if (auto it = _tasks.find(key); it != _tasks.end()) {
			it->second->handlers.push_back(handler);
			return;
		}
		auto task = std::make_shared<FixtureDef3DLoadTask>();
		task->key = key;
		task->file = file;
		task->kind = kind;
		task->handlers.push_back(handler);
		_tasks[key] = task;
		SharedContent.loadAsyncData(file, [this, task](OwnArray<uint8_t>&& data, size_t size) {
			if (!isCurrent(task)) return;
			if (!data || size == 0) {
				complete(task, 0);
				return;
			}
			task->data = std::move(data);
			task->size = size;
			collectDependencies(task);
		});
	}

protected:
	FixtureDef3DCache() { }

private:
	bool isCurrent(const std::shared_ptr<FixtureDef3DLoadTask>& task) const {
		auto it = _tasks.find(task->key);
		return !task->cancelled && it != _tasks.end() && it->second == task;
	}

	void collectDependencies(const std::shared_ptr<FixtureDef3DLoadTask>& task) {
		SharedAsyncThread.run(
			[task]() {
				auto success = dora_3d_collect_gltf_buffer_dependencies(
					task->file.c_str(), task->data.get(), task->size,
					collectFixtureDef3DDependency, task.get()) != 0;
				return Values::alloc(success);
			},
			[this, task](Own<Values> result) {
				if (!isCurrent(task)) return;
				bool success = false;
				result->get(success);
				if (!success) {
					complete(task, 0);
					return;
				}
				loadDependencies(task);
			});
	}

	void loadDependencies(const std::shared_ptr<FixtureDef3DLoadTask>& task) {
		if (task->dependencies.empty()) {
			cook(task);
			return;
		}
		task->remaining = task->dependencies.size();
		for (const auto& dependency : task->dependencies) {
			SharedContent.loadAsyncData(dependency, [this, task, dependency](OwnArray<uint8_t>&& data, size_t size) {
				if (!isCurrent(task)) return;
				if (!data || size == 0) {
					task->failed = true;
				} else {
					task->resources.emplace(dependency, FixtureDef3DImportResource {std::move(data), size});
				}
				if (--task->remaining == 0) {
					if (task->failed) {
						complete(task, 0);
					} else {
						cook(task);
					}
				}
			});
		}
	}

	void cook(const std::shared_ptr<FixtureDef3DLoadTask>& task) {
		SharedAsyncThread.run(
			[task]() {
				auto createShape = task->kind == FixtureDef3DLoadKind::Mesh
					? dora_3d_physics_shape_create_mesh_data
					: dora_3d_physics_shape_create_convex_hull_data;
				return Values::alloc(createShape(task->file.c_str(), task->data.get(), task->size,
					loadFixtureDef3DResource, task.get()));
			},
			[this, task](Own<Values> result) {
				uint64_t handle = 0;
				result->get(handle);
				if (!isCurrent(task)) {
					if (handle != 0) dora_3d_physics_shape_destroy(handle);
					return;
				}
				complete(task, handle);
			});
	}

	void complete(const std::shared_ptr<FixtureDef3DLoadTask>& task, uint64_t handle) {
		Ref<FixtureDef3D> shape(Object::create<FixtureDef3D>(handle, handle != 0));
		if (handle != 0 && shape) {
			_shapes[task->key] = shape;
		} else if (handle != 0) {
			dora_3d_physics_shape_destroy(handle);
		}
		auto handlers = std::move(task->handlers);
		_tasks.erase(task->key);
		for (const auto& handler : handlers) handler(shape);
	}

	StringMap<Ref<FixtureDef3D>> _shapes;
	StringMap<std::shared_ptr<FixtureDef3DLoadTask>> _tasks;
	SINGLETON_REF(FixtureDef3DCache, Director);
};

#define SharedFixtureDef3DCache \
	Dora::Singleton<Dora::FixtureDef3DCache>::shared()

FixtureDef3D::FixtureDef3D(uint64_t handle, bool built)
	: _handle(handle)
	, _built(built) { }

FixtureDef3D::~FixtureDef3D() {
	clearPhysics();
}

bool FixtureDef3D::isBuilt() const noexcept {
	return _handle != 0 && _built && dora_3d_physics_shape_is_built(_handle) != 0;
}

bool FixtureDef3D::addChild(NotNull<FixtureDef3D, 1> shape, const Vec3& position, const Vec3& angles) {
	if (_handle == 0 || _built || !shape->isBuilt()) return false;
	if (dora_3d_physics_shape_add_child(
			_handle,
			shape->_handle,
			position.x, position.y, position.z,
			angles.x, angles.y, angles.z)
		== 0) {
		return false;
	}
	_children.emplace_back(shape.get());
	return true;
}

bool FixtureDef3D::addChild(NotNull<FixtureDef3D, 1> shape, const Vec3& position) {
	return addChild(shape, position, Vec3{});
}

bool FixtureDef3D::build() {
	if (_handle == 0 || _built) return false;
	if (dora_3d_physics_shape_build(_handle) == 0) return false;
	_built = true;
	_children.clear();
	return true;
}

void FixtureDef3D::clearPhysics() {
	_children.clear();
	if (_handle != 0) {
		dora_3d_physics_shape_destroy(_handle);
		_handle = 0;
	}
	_built = false;
}

void FixtureDef3D::cleanup() {
	clearPhysics();
	Object::cleanup();
}

FixtureDef3D* FixtureDef3D::createBox(const Vec3& halfExtent) {
	auto handle = dora_3d_physics_shape_create_box(halfExtent.x, halfExtent.y, halfExtent.z);
	return handle == 0 ? nullptr : Object::create<FixtureDef3D>(handle, true);
}

FixtureDef3D* FixtureDef3D::createSphere(float radius) {
	auto handle = dora_3d_physics_shape_create_sphere(radius);
	return handle == 0 ? nullptr : Object::create<FixtureDef3D>(handle, true);
}

FixtureDef3D* FixtureDef3D::createCapsule(float halfHeight, float radius) {
	auto handle = dora_3d_physics_shape_create_capsule(halfHeight, radius);
	return handle == 0 ? nullptr : Object::create<FixtureDef3D>(handle, true);
}

FixtureDef3D* FixtureDef3D::createCompound() {
	auto handle = dora_3d_physics_shape_create_compound();
	return handle == 0 ? nullptr : Object::create<FixtureDef3D>(handle, false);
}

void FixtureDef3D::loadMeshAsync(String filename, const std::function<void(FixtureDef3D*)>& handler) {
	SharedFixtureDef3DCache.loadAsync(filename, FixtureDef3DLoadKind::Mesh, handler);
}

void FixtureDef3D::loadConvexHullAsync(String filename, const std::function<void(FixtureDef3D*)>& handler) {
	SharedFixtureDef3DCache.loadAsync(filename, FixtureDef3DLoadKind::ConvexHull, handler);
}

BodyDef3D::BodyDef3D()
	: _type(BodyType3D::Dynamic)
	, _collisionLayer(0)
	, _collisionMask(0xffffffffu)
	, _sensor(false) { }

uint8_t BodyDef3D::getTypeValue() const noexcept {
	return s_cast<uint8_t>(_type);
}

void BodyDef3D::setTypeValue(uint8_t type) {
	AssertIf(type > s_cast<uint8_t>(BodyType3D::Dynamic), "Invalid BodyType3D value {}.", type);
	_type = s_cast<BodyType3D>(type);
}

void BodyDef3D::setType(BodyType3D type) {
	_type = type;
}

BodyType3D BodyDef3D::getType() const noexcept {
	return _type;
}

void BodyDef3D::setCollisionLayer(uint8_t layer) {
	AssertIf(layer >= 32, "BodyDef3D collision layer should be less than 32.");
	_collisionLayer = layer;
}

uint8_t BodyDef3D::getCollisionLayer() const noexcept {
	return _collisionLayer;
}

void BodyDef3D::setCollisionMask(uint32_t mask) {
	_collisionMask = mask;
}

uint32_t BodyDef3D::getCollisionMask() const noexcept {
	return _collisionMask;
}

void BodyDef3D::setSensor(bool sensor) {
	_sensor = sensor;
}

bool BodyDef3D::isSensor() const noexcept {
	return _sensor;
}

bool BodyDef3D::attach(NotNull<FixtureDef3D, 1> fixture, const Vec3& position, const Vec3& angles) {
	if (!fixture->isBuilt()) return false;
	if (!_fixture) _fixture = FixtureDef3D::createCompound();
	return _fixture && _fixture->addChild(fixture, position, angles);
}

bool BodyDef3D::attach(NotNull<FixtureDef3D, 1> fixture, const Vec3& position) {
	return attach(fixture, position, Vec3{});
}

bool BodyDef3D::attach(NotNull<FixtureDef3D, 1> fixture) {
	return attach(fixture, Vec3{}, Vec3{});
}

FixtureDef3D* BodyDef3D::getFixture() {
	if (!_fixture) return nullptr;
	if (!_fixture->isBuilt() && !_fixture->build()) return nullptr;
	return _fixture;
}

BodyDef3D* BodyDef3D::create() {
	return Object::create<BodyDef3D>();
}

Constraint3D::Constraint3D(NotNull<PhysicsWorld3D, 1> world, NotNull<Body3D, 2> firstBody, NotNull<Body3D, 3> secondBody, uint64_t handle)
	: _world(world)
	, _firstBody(firstBody)
	, _secondBody(secondBody)
	, _handle(handle) { }

Constraint3D::~Constraint3D() {
	clearPhysics();
}

PhysicsWorld3D* Constraint3D::getPhysicsWorld() const noexcept {
	return _world.get();
}

Body3D* Constraint3D::getFirstBody() const noexcept {
	return _firstBody.get();
}

Body3D* Constraint3D::getSecondBody() const noexcept {
	return _secondBody.get();
}

bool Constraint3D::references(Body3D* body) const {
	return _firstBody.get() == body || _secondBody.get() == body;
}

void Constraint3D::clearPhysics() {
	if (_handle != 0) {
		if (_world) dora_3d_physics_constraint_destroy(_world->_handle, _handle);
		_handle = 0;
	}
	_firstBody = nullptr;
	_secondBody = nullptr;
	_world = nullptr;
}

void Constraint3D::destroy() {
	if (_world) {
		_world->destroyConstraint(this);
	} else {
		clearPhysics();
	}
}

void Constraint3D::cleanup() {
	clearPhysics();
	Object::cleanup();
}

Constraint3D* Constraint3D::createFixed(Body3D* firstBody, Body3D* secondBody, const Vec3& anchor) {
	if (!firstBody || !secondBody) return nullptr;
	auto world = firstBody->getPhysicsWorld();
	return world && world == secondBody->getPhysicsWorld() ? world->createFixedConstraint(firstBody, secondBody, anchor) : nullptr;
}

Constraint3D* Constraint3D::createDistance(Body3D* firstBody, Body3D* secondBody, const Vec3& firstAnchor, const Vec3& secondAnchor, float minDistance, float maxDistance) {
	if (!firstBody || !secondBody) return nullptr;
	auto world = firstBody->getPhysicsWorld();
	return world && world == secondBody->getPhysicsWorld() ? world->createDistanceConstraint(firstBody, secondBody, firstAnchor, secondAnchor, minDistance, maxDistance) : nullptr;
}

Constraint3D* Constraint3D::createHinge(Body3D* firstBody, Body3D* secondBody, const Vec3& anchor, const Vec3& axis, float minAngle, float maxAngle) {
	if (!firstBody || !secondBody) return nullptr;
	auto world = firstBody->getPhysicsWorld();
	return world && world == secondBody->getPhysicsWorld() ? world->createHingeConstraint(firstBody, secondBody, anchor, axis, minAngle, maxAngle) : nullptr;
}

CharacterController3D::CharacterController3D(NotNull<PhysicsWorld3D, 1> world, NotNull<Node3D, 2> node, uint64_t handle)
	: _world(world)
	, _node(node)
	, _handle(handle)
	, _desiredVelocity{}
	, _velocity{}
	, _groundNormal{}
	, _groundState(3)
	, _collisionLayer(0)
	, _collisionMask(0xffffffffu) { }

CharacterController3D::~CharacterController3D() {
	clearPhysics();
}

Node3D* CharacterController3D::getNode() const noexcept {
	return _node.get();
}

PhysicsWorld3D* CharacterController3D::getPhysicsWorld() const noexcept {
	return _world.get();
}

void CharacterController3D::setDesiredVelocity(const Vec3& velocity) {
	_desiredVelocity = velocity;
	if (_world && _handle != 0) {
		dora_3d_physics_character_set_velocity(_world->_handle, _handle, velocity.x, velocity.y, velocity.z);
	}
}

const Vec3& CharacterController3D::getDesiredVelocity() const noexcept {
	return _desiredVelocity;
}

void CharacterController3D::refreshState() const {
	_velocity = {};
	_groundNormal = {};
	_groundState = 3;
	if (_world && _handle != 0) {
		dora_3d_physics_character_get_state(_world->_handle, _handle, &_velocity.x, &_groundState, &_groundNormal.x);
	}
}

const Vec3& CharacterController3D::getVelocity() const noexcept {
	refreshState();
	return _velocity;
}

const Vec3& CharacterController3D::getGroundNormal() const noexcept {
	refreshState();
	return _groundNormal;
}

bool CharacterController3D::isGrounded() const noexcept {
	refreshState();
	return _groundState == 0;
}

void CharacterController3D::setCollisionLayer(uint8_t layer) {
	AssertIf(layer >= 32, "CharacterController3D collision layer should be less than 32.");
	_collisionLayer = layer;
	if (_world && _handle != 0) {
		dora_3d_physics_character_set_filter(_world->_handle, _handle, _collisionLayer, _collisionMask);
	}
}

uint8_t CharacterController3D::getCollisionLayer() const noexcept {
	return _collisionLayer;
}

void CharacterController3D::setCollisionMask(uint32_t mask) {
	_collisionMask = mask;
	if (_world && _handle != 0) {
		dora_3d_physics_character_set_filter(_world->_handle, _handle, _collisionLayer, _collisionMask);
	}
}

uint32_t CharacterController3D::getCollisionMask() const noexcept {
	return _collisionMask;
}

void CharacterController3D::jump(float speed) {
	if (_world && _handle != 0 && speed > 0.0f) {
		dora_3d_physics_character_jump(_world->_handle, _handle, speed);
	}
}

void CharacterController3D::clearPhysics() {
	if (_handle != 0) {
		if (_world) dora_3d_physics_character_destroy(_world->_handle, _handle);
		_handle = 0;
	}
	_node = nullptr;
	_world = nullptr;
}

void CharacterController3D::destroy() {
	if (_world) {
		_world->destroyCharacter(this);
	} else {
		clearPhysics();
	}
}

void CharacterController3D::cleanup() {
	clearPhysics();
	Object::cleanup();
}

Body3D::Body3D(NotNull<BodyDef3D, 1> bodyDef, NotNull<PhysicsWorld3D, 2> world, const Vec3& position, const Vec3& angles)
	: _world(world)
	, _bodyDef(bodyDef)
	, _type(bodyDef->getType())
	, _bodyHandle(0)
	, _initialPosition(position)
	, _initialAngles(angles)
	, _linearVelocity{}
	, _angularVelocity{}
	, _collisionLayer(bodyDef->getCollisionLayer())
	, _collisionMask(bodyDef->getCollisionMask())
	, _sensor(bodyDef->isSensor())
	, _debugShape(DebugShape::Bounds)
	, _debugSize{} { }

Body3D::~Body3D() {
	clearPhysics();
}

PhysicsWorld3D* Body3D::getPhysicsWorld() const noexcept {
	return _world.get();
}

BodyDef3D* Body3D::getBodyDef() const noexcept {
	return _bodyDef;
}

BodyType3D Body3D::getType() const noexcept {
	return _type;
}

uint8_t Body3D::getTypeValue() const noexcept {
	return s_cast<uint8_t>(_type);
}

void Body3D::setLinearVelocity(const Vec3& velocity) {
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_set_linear_velocity(_world->_handle, _bodyHandle, velocity.x, velocity.y, velocity.z);
	}
}

const Vec3& Body3D::getLinearVelocity() const noexcept {
	_linearVelocity = {};
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_get_linear_velocity(_world->_handle, _bodyHandle, &_linearVelocity.x);
	}
	return _linearVelocity;
}

void Body3D::setAngularVelocity(const Vec3& velocity) {
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_set_angular_velocity(_world->_handle, _bodyHandle, velocity.x, velocity.y, velocity.z);
	}
}

const Vec3& Body3D::getAngularVelocity() const noexcept {
	_angularVelocity = {};
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_get_angular_velocity(_world->_handle, _bodyHandle, &_angularVelocity.x);
	}
	return _angularVelocity;
}

void Body3D::setCollisionLayer(uint8_t layer) {
	AssertIf(layer >= 32, "Body3D collision layer should be less than 32.");
	_collisionLayer = layer;
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_set_filter(_world->_handle, _bodyHandle, _collisionLayer, _collisionMask);
	}
}

uint8_t Body3D::getCollisionLayer() const noexcept {
	return _collisionLayer;
}

void Body3D::setCollisionMask(uint32_t mask) {
	_collisionMask = mask;
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_set_filter(_world->_handle, _bodyHandle, _collisionLayer, _collisionMask);
	}
}

uint32_t Body3D::getCollisionMask() const noexcept {
	return _collisionMask;
}

void Body3D::setSensor(bool sensor) {
	_sensor = sensor;
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_set_sensor(_world->_handle, _bodyHandle, sensor ? 1 : 0);
	}
}

bool Body3D::isSensor() const noexcept {
	return _sensor;
}

void Body3D::applyForce(const Vec3& force) {
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_apply_force(_world->_handle, _bodyHandle, force.x, force.y, force.z);
	}
}

void Body3D::applyLinearImpulse(const Vec3& impulse) {
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_apply_impulse(_world->_handle, _bodyHandle, impulse.x, impulse.y, impulse.z);
	}
}

void Body3D::onContactEnter(const Contact3DHandler& handler) {
	_contactEnter = handler;
}

void Body3D::onContactStay(const Contact3DHandler& handler) {
	_contactStay = handler;
}

void Body3D::onContactExit(const Contact3DHandler& handler) {
	_contactExit = handler;
}

void Body3D::dispatchContact(uint8_t eventType, Body3D* other, const Vec3& point, const Vec3& normal) {
	auto* handler = eventType == 0 ? &_contactEnter : eventType == 1 ? &_contactStay : &_contactExit;
	if (*handler) (*handler)(other, point, normal);
}

void Body3D::setPosition(const Vec3& position) {
	if (position == Node3D::getPosition()) return;
	Node3D::setPosition(position);
	if (_world && _bodyHandle != 0) {
		dora_3d_physics_body_sync_transform(_world->_handle, _bodyHandle);
	}
}

void Body3D::clearPhysics() {
	if (_bodyHandle != 0) {
		if (_world) {
			dora_3d_physics_body_destroy(_world->_handle, _bodyHandle);
		}
		_bodyHandle = 0;
	}
	_world = nullptr;
	_contactEnter = nullptr;
	_contactStay = nullptr;
	_contactExit = nullptr;
}

bool Body3D::init() {
	if (!Node3D::init()) return false;
	setPosition(_initialPosition);
	setAngles(_initialAngles);
	auto fixture = _bodyDef->getFixture();
	if (!fixture || !_world || _world->_handle == 0) {
		setAsManaged();
		return false;
	}
	_bodyHandle = dora_3d_physics_body_create_shape(
		_world->_handle, getHandle(), fixture->_handle, s_cast<uint8_t>(_type));
	if (_bodyHandle == 0 || !_world->addBody(this, _bodyHandle)) {
		setAsManaged();
		return false;
	}
	dora_3d_physics_body_set_filter(_world->_handle, _bodyHandle, _collisionLayer, _collisionMask);
	dora_3d_physics_body_set_sensor(_world->_handle, _bodyHandle, _sensor ? 1 : 0);
	return true;
}

void Body3D::cleanup() {
	if (_world) {
		_world->destroyBody(this);
	} else {
		clearPhysics();
	}
	Node3D::cleanup();
}

Body3D* Body3D::create(BodyDef3D* bodyDef, PhysicsWorld3D* world, const Vec3& position, const Vec3& angles) {
	if (!bodyDef || !world) return nullptr;
	return Object::create<Body3D>(bodyDef, world, position, angles);
}

PhysicsWorld3D::PhysicsWorld3D()
	: _handle(0)
	, _gravity(0.0f, -9.81f, 0.0f) { }

PhysicsWorld3D::~PhysicsWorld3D() {
	clearPhysics();
}

bool PhysicsWorld3D::init() {
	if (!Node::init()) return false;
	_handle = dora_3d_physics_world_create(65536);
	if (_handle == 0) return false;
	dora_3d_physics_world_set_gravity(_handle, _gravity.x, _gravity.y, _gravity.z);
	Node::scheduleFixedUpdate();
	return true;
}

void PhysicsWorld3D::setGravity(const Vec3& gravity) {
	_gravity = gravity;
	if (_handle != 0) {
		dora_3d_physics_world_set_gravity(_handle, gravity.x, gravity.y, gravity.z);
	}
}

const Vec3& PhysicsWorld3D::getGravity() const noexcept {
	return _gravity;
}

bool PhysicsWorld3D::addBody(Body3D* body, uint64_t handle) {
	if (!body || handle == 0) return false;
	_bodies.emplace_back(body);
	_bodyMap.emplace(handle, body);
	return true;
}

CharacterController3D* PhysicsWorld3D::createCharacter(NotNull<Node3D, 1> node, float halfHeight, float radius, float maxSlopeAngle, float stepHeight) {
	if (_handle == 0) return nullptr;
	auto handle = dora_3d_physics_character_create_capsule(
		_handle, node->getHandle(), halfHeight, radius, maxSlopeAngle, stepHeight);
	if (handle == 0) return nullptr;
	auto character = Object::create<CharacterController3D>(this, node.get(), handle);
	if (character) _characters.emplace_back(character);
	return character;
}

CharacterController3D* PhysicsWorld3D::makeCharacter(NotNull<Node3D, 1> node, float halfHeight, float radius, float maxSlopeAngle, float stepHeight) {
	return createCharacter(node, halfHeight, radius, maxSlopeAngle, stepHeight);
}

Constraint3D* PhysicsWorld3D::addConstraint(Body3D* firstBody, Body3D* secondBody, uint64_t handle) {
	if (handle == 0) return nullptr;
	auto constraint = Object::create<Constraint3D>(this, firstBody, secondBody, handle);
	if (constraint) _constraints.emplace_back(constraint);
	return constraint;
}

Constraint3D* PhysicsWorld3D::createFixedConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& anchor) {
	if (_handle == 0 || firstBody->_world.get() != this || secondBody->_world.get() != this) return nullptr;
	auto handle = dora_3d_physics_constraint_create_fixed(
		_handle, firstBody->_bodyHandle, secondBody->_bodyHandle, anchor.x, anchor.y, anchor.z);
	return addConstraint(firstBody, secondBody, handle);
}

Constraint3D* PhysicsWorld3D::createDistanceConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& firstAnchor, const Vec3& secondAnchor, float minDistance, float maxDistance) {
	if (_handle == 0 || firstBody->_world.get() != this || secondBody->_world.get() != this) return nullptr;
	auto handle = dora_3d_physics_constraint_create_distance(
		_handle, firstBody->_bodyHandle, secondBody->_bodyHandle,
		firstAnchor.x, firstAnchor.y, firstAnchor.z,
		secondAnchor.x, secondAnchor.y, secondAnchor.z,
		minDistance, maxDistance);
	return addConstraint(firstBody, secondBody, handle);
}

Constraint3D* PhysicsWorld3D::createHingeConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& anchor, const Vec3& axis, float minAngle, float maxAngle) {
	if (_handle == 0 || firstBody->_world.get() != this || secondBody->_world.get() != this) return nullptr;
	auto handle = dora_3d_physics_constraint_create_hinge(
		_handle, firstBody->_bodyHandle, secondBody->_bodyHandle,
		anchor.x, anchor.y, anchor.z, axis.x, axis.y, axis.z, minAngle, maxAngle);
	return addConstraint(firstBody, secondBody, handle);
}

Constraint3D* PhysicsWorld3D::makeFixedConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& anchor) {
	return createFixedConstraint(firstBody, secondBody, anchor);
}

Constraint3D* PhysicsWorld3D::makeDistanceConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& firstAnchor, const Vec3& secondAnchor, float minDistance, float maxDistance) {
	return createDistanceConstraint(firstBody, secondBody, firstAnchor, secondAnchor, minDistance, maxDistance);
}

Constraint3D* PhysicsWorld3D::makeHingeConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& anchor, const Vec3& axis, float minAngle, float maxAngle) {
	return createHingeConstraint(firstBody, secondBody, anchor, axis, minAngle, maxAngle);
}

void PhysicsWorld3D::destroyConstraint(NotNull<Constraint3D, 1> constraint) {
	auto it = std::find_if(_constraints.begin(), _constraints.end(), [constraint](const Ref<Constraint3D>& candidate) {
		return candidate.get() == constraint;
	});
	if (it == _constraints.end()) return;
	Ref<Constraint3D> retained(*it);
	_constraints.erase(it);
	retained->clearPhysics();
}

void PhysicsWorld3D::destroyConstraintsFor(Body3D* body) {
	for (size_t i = _constraints.size(); i > 0; --i) {
		if (_constraints[i - 1]->references(body)) destroyConstraint(_constraints[i - 1].get());
	}
}

void PhysicsWorld3D::destroyBody(NotNull<Body3D, 1> body) {
	auto it = std::find_if(_bodies.begin(), _bodies.end(), [body](const Ref<Body3D>& candidate) {
		return candidate.get() == body;
	});
	if (it == _bodies.end()) return;
	Ref<Body3D> retained(*it);
	destroyConstraintsFor(retained);
	_bodies.erase(it);
	_bodyMap.erase(retained->_bodyHandle);
	retained->clearPhysics();
}

void PhysicsWorld3D::destroyCharacter(NotNull<CharacterController3D, 1> character) {
	auto it = std::find_if(_characters.begin(), _characters.end(), [character](const Ref<CharacterController3D>& candidate) {
		return candidate.get() == character;
	});
	if (it == _characters.end()) return;
	Ref<CharacterController3D> retained(*it);
	_characters.erase(it);
	retained->clearPhysics();
}

Body3D* PhysicsWorld3D::getBody(uint64_t handle) const {
	auto it = _bodyMap.find(handle);
	return it == _bodyMap.end() ? nullptr : it->second;
}

bool PhysicsWorld3D::raycast(const Vec3& start, const Vec3& stop, const std::function<bool(Body3D*, const Vec3&, const Vec3&)>& callback) {
	auto delta = bx::sub(stop, start);
	auto distance = bx::length(delta);
	if (_handle == 0 || distance <= 0.0f) return false;
	auto direction = Vec3::from(bx::mul(delta, 1.0f / distance));
	uint64_t bodyHandle = 0;
	Vec3 point;
	Vec3 normal;
	float hitDistance = 0.0f;
	if (!dora_3d_physics_world_raycast(
			_handle,
			start.x, start.y, start.z,
			direction.x, direction.y, direction.z,
			distance, &bodyHandle, &point.x, &normal.x, &hitDistance)) {
		return false;
	}
	auto body = getBody(bodyHandle);
	return body ? callback(body, point, normal) : false;
}

bool PhysicsWorld3D::querySphere(const Vec3& center, float radius, const std::function<bool(Body3D*)>& callback) {
	if (_handle == 0 || radius <= 0.0f) return false;
	auto count = dora_3d_physics_world_overlap_sphere(_handle, center.x, center.y, center.z, radius, nullptr, 0);
	if (count == 0) return false;
	std::vector<uint64_t> handles(count);
	count = dora_3d_physics_world_overlap_sphere(_handle, center.x, center.y, center.z, radius, handles.data(), count);
	for (uint32_t i = 0; i < count && i < handles.size(); ++i) {
		if (auto body = getBody(handles[i]); body && callback(body)) return true;
	}
	return false;
}

void PhysicsWorld3D::dispatchContacts() {
	struct Contact {
		Ref<Body3D> body;
		Ref<Body3D> other;
		Vec3 point;
		Vec3 normal;
		uint8_t eventType;
	};
	std::vector<Contact> contacts;
	auto count = dora_3d_physics_world_event_count(_handle);
	contacts.reserve(count);
	for (uint32_t i = 0; i < count; ++i) {
		uint8_t eventType = 0;
		uint64_t bodyHandle = 0;
		uint64_t otherHandle = 0;
		Vec3 point;
		Vec3 normal;
		if (!dora_3d_physics_world_event_get(_handle, i, &eventType, &bodyHandle, &otherHandle, &point.x, &normal.x)) continue;
		auto body = getBody(bodyHandle);
		auto other = getBody(otherHandle);
		if (body && other) {
			contacts.push_back({Ref<Body3D>(body), Ref<Body3D>(other), point, normal, eventType});
		}
	}
	dora_3d_physics_world_event_clear(_handle);
	for (auto& contact : contacts) {
		contact.body->dispatchContact(contact.eventType, contact.other, contact.point, contact.normal);
	}
}

bool PhysicsWorld3D::fixedUpdate(double deltaTime) {
	if (_handle != 0 && isFixedUpdating()) {
		dora_3d_physics_world_step(_handle, s_cast<float>(deltaTime));
		dispatchContacts();
	}
	return Node::fixedUpdate(deltaTime);
}

void PhysicsWorld3D::queueDebugBounds() {
	if (_handle == 0 || !isShowDebug()) return;
	auto* parent = getParent();
	while (parent && !dynamic_cast<View3D*>(parent)) parent = parent->getParent();
	auto* view = dynamic_cast<View3D*>(parent);
	if (!view || !view->getScene()) return;
	for (const auto& body : _bodies) {
		if (body->_bodyHandle == 0) continue;
		float red = 0.1f;
		float green = 0.85f;
		float blue = 1.0f;
		if (body->_sensor) {
			red = 1.0f;
			green = 0.15f;
			blue = 0.85f;
		} else if (body->_type == BodyType3D::Static) {
			red = 0.35f;
			green = 1.0f;
			blue = 0.35f;
		} else if (body->_type == BodyType3D::Kinematic) {
			red = 1.0f;
			green = 0.85f;
			blue = 0.1f;
		}
		if (body->_debugShape != Body3D::DebugShape::Bounds) {
			dora_3d_queue_physics_debug_shape(
				view->getScene()->getHandle(), s_cast<uint8_t>(body->_debugShape),
				body->_debugSize.x, body->_debugSize.y, body->_debugSize.z,
				body->getWorldMatrix().m, red, green, blue);
			continue;
		}
		float bounds[6];
		if (dora_3d_physics_body_get_bounds(_handle, body->_bodyHandle, bounds) == 0) continue;
		dora_3d_queue_physics_debug_bounds(
			view->getScene()->getHandle(),
			bounds[0], bounds[1], bounds[2], bounds[3], bounds[4], bounds[5],
			red, green, blue);
	}
}

void PhysicsWorld3D::render() {
	queueDebugBounds();
	Node::render();
}

void PhysicsWorld3D::setShowDebug(bool var) {
	Node::setShowDebug(var);
}

void PhysicsWorld3D::clearPhysics() {
	if (_handle == 0) return;
	auto constraints = std::move(_constraints);
	_constraints.clear();
	for (auto& constraint : constraints) {
		constraint->clearPhysics();
	}
	auto characters = std::move(_characters);
	_characters.clear();
	for (auto& character : characters) {
		character->clearPhysics();
	}
	auto bodies = std::move(_bodies);
	_bodies.clear();
	_bodyMap.clear();
	for (auto& body : bodies) {
		body->clearPhysics();
	}
	dora_3d_physics_world_destroy(_handle);
	_handle = 0;
}

void PhysicsWorld3D::cleanup() {
	clearPhysics();
	Node::cleanup();
}

float PhysicsWorld::scaleFactor = 100.0f;

PhysicsWorld::PhysicsWorld() {
	_stepConf.regVelocityIters = 1;
	_stepConf.regPositionIters = 1;
	static_assert(sizeof(decltype(pr::Filter::categoryBits)) == 4, "filter category should be 32 bits");
	static_assert(sizeof(decltype(pr::Filter::maskBits)) == 4, "filter mask should be 32 bits");
	static_assert(sizeof(decltype(pr::Filter::groupIndex)) == 1, "filter group index should be 8 bits");
}

PhysicsWorld::~PhysicsWorld() {
	clearPhysics();
}

void PhysicsWorld::setupBeginContact() {
	pd::SetBeginContactListener(*_world, [this](pr::ContactID contact) {
		auto& world = *_world;
		if (!pd::IsEnabled(world, contact)) {
			return;
		}
		pr::ShapeID fixtureA = pd::GetShapeA(world, contact);
		pr::ShapeID fixtureB = pd::GetShapeB(world, contact);
		Body* bodyA = _bodyData[pd::GetBodyA(world, contact).get()];
		Body* bodyB = _bodyData[pd::GetBodyB(world, contact).get()];
		if (!bodyA || !bodyB) {
			return;
		}
		if (pd::IsSensor(world, fixtureA)) {
			Sensor* sensor = _fixtureData[fixtureA.get()];
			if (sensor && sensor->isEnabled() && !pd::IsSensor(world, fixtureB) && sensor->getOwner()) {
				SensorPair pair{MakeWRef(sensor->getOwner()), MakeWRef(sensor), MakeWRef(bodyB)};
				_sensorEnters.push_back(pair);
			}
		} else if (pd::IsSensor(world, fixtureB)) {
			Sensor* sensor = _fixtureData[fixtureB.get()];
			if (sensor && sensor->isEnabled() && sensor->getOwner()) {
				SensorPair pair{MakeWRef(sensor->getOwner()), MakeWRef(sensor), MakeWRef(bodyA)};
				_sensorEnters.push_back(pair);
			}
		} else {
			if (bodyA->isReceivingContact() || bodyB->isReceivingContact()) {
				if (bodyA->filterContact && !bodyA->filterContact(bodyB)) {
					pd::UnsetEnabled(world, contact);
				} else if (bodyB->filterContact && !bodyB->filterContact(bodyA)) {
					pd::UnsetEnabled(world, contact);
				}
				bool enabled = pd::IsEnabled(world, contact);
				pd::WorldManifold worldManifold = pd::GetWorldManifold(world, contact);
				Vec2 point = PhysicsWorld::Val(worldManifold.GetPoint(0));
				pd::UnitVec normal = worldManifold.GetNormal();
				if (bodyA->isReceivingContact()) {
					ContactPair pair{MakeWRef(bodyA), MakeWRef(bodyB), point, {normal[0], normal[1]}, enabled};
					_contactStarts.push_back(pair);
				}
				if (bodyB->isReceivingContact()) {
					ContactPair pair{MakeWRef(bodyB), MakeWRef(bodyA), point, {normal[0], normal[1]}, enabled};
					_contactStarts.push_back(pair);
				}
			}
		}
	});
}

void PhysicsWorld::setupEndContact() {
	pd::SetEndContactListener(*_world, [this](pr::ContactID contact) {
		auto& world = *_world;
		if (!pd::IsEnabled(world, contact)) {
			return;
		}
		pr::ShapeID fixtureA = pd::GetShapeA(world, contact);
		pr::ShapeID fixtureB = pd::GetShapeB(world, contact);
		Body* bodyA = _bodyData[pd::GetBodyA(world, contact).get()];
		Body* bodyB = _bodyData[pd::GetBodyB(world, contact).get()];
		if (pd::IsSensor(world, fixtureA)) {
			Sensor* sensor = _fixtureData[fixtureA.get()];
			if (sensor && bodyB && sensor->isEnabled() && !pd::IsSensor(world, fixtureB) && sensor->getOwner()) {
				SensorPair pair{MakeWRef(sensor->getOwner()), MakeWRef(sensor), MakeWRef(bodyB)};
				_sensorLeaves.push_back(pair);
			}
		} else if (pd::IsSensor(world, fixtureB)) {
			Sensor* sensor = _fixtureData[fixtureB.get()];
			if (sensor && bodyA && sensor->isEnabled() && sensor->getOwner()) {
				SensorPair pair{MakeWRef(sensor->getOwner()), MakeWRef(sensor), MakeWRef(bodyA)};
				_sensorLeaves.push_back(pair);
			}
		} else if ((bodyA && bodyB) && (bodyA->isReceivingContact() || bodyB->isReceivingContact())) {
			pd::WorldManifold worldManifold = pd::GetWorldManifold(world, contact);
			Vec2 point = PhysicsWorld::Val(worldManifold.GetPoint(0));
			if (bodyA->isReceivingContact()) {
				pd::UnitVec normal = worldManifold.GetNormal();
				ContactPair pair{MakeWRef(bodyA), MakeWRef(bodyB), point, {normal[0], normal[1]}};
				_contactEnds.push_back(pair);
			}
			if (bodyB->isReceivingContact()) {
				pd::UnitVec normal = worldManifold.GetNormal();
				ContactPair pair{MakeWRef(bodyB), MakeWRef(bodyA), point, {normal[0], normal[1]}};
				_contactEnds.push_back(pair);
			}
		}
	});
}

bool PhysicsWorld::init() {
	if (!Node::init()) return false;
	_world = New<pd::World>();
	setupBeginContact();
	setupEndContact();
	for (int i = 0; i < TotalGroups; i++) {
		_filters[i].groupIndex = i;
		_filters[i].categoryBits = 1 << i;
		_filters[i].maskBits = 0;
		setShouldContact(i, i, true);
	}
	Node::scheduleFixedUpdate();
	return true;
}

void PhysicsWorld::render() {
	if (_debugDraw) {
		_debugDraw->DrawWorld(this);
	}
	Node::render();
}

void PhysicsWorld::clearPhysics() {
	if (_world) {
		RefVector<Body> bodies;
		for (pr::BodyID b : pd::GetBodies(*_world)) {
			Body* body = _bodyData[b.get()];
			if (body) bodies.push_back(body);
		}
		for (Body* b : bodies) {
			b->clearPhysics();
		}
		_world = nullptr;
	}
}

void PhysicsWorld::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		clearPhysics();
		Node::cleanup();
	}
}

pd::World* PhysicsWorld::getPrWorld() const noexcept {
	return _world.get();
}

void PhysicsWorld::setShowDebug(bool var) {
	if (var) {
		if (!_debugDraw) {
			_debugDraw = New<DebugDraw>();
			addChild(_debugDraw->getRenderer(), INT_MAX, "DebugDraw"_slice);
		}
	} else if (_debugDraw) {
		removeChild(_debugDraw->getRenderer());
		_debugDraw = nullptr;
	}
	Node::setShowDebug(var);
}

void PhysicsWorld::setIterations(int velocityIter, int positionIter) {
	_stepConf.regVelocityIters = velocityIter;
	_stepConf.regPositionIters = positionIter;
	_stepConf.toiVelocityIters = velocityIter;
	if (positionIter == 0) {
		_stepConf.toiPositionIters = 0;
	}
}

void PhysicsWorld::doUpdate(double deltaTime) {
	if (!_world) return;
	auto& world = *_world;
	{
		PROFILE("Physics"_slice);
		_stepConf.deltaTime = s_cast<pr::Time>(deltaTime);
		_stepConf.dtRatio = _stepConf.deltaTime * pd::GetInvDeltaTime(world);
		pd::Step(world, _stepConf);
		const auto& bodies = pd::GetBodies(world);
		for (pr::BodyID b : bodies) {
			if (pd::IsEnabled(world, b)) {
				Body* body = _bodyData[b.get()];
				body->updatePhysics();
			}
		}
	}
	solveContacts();
}

bool PhysicsWorld::fixedUpdate(double deltaTime) {
	if (isFixedUpdating()) {
		doUpdate(deltaTime);
	}
	return Node::fixedUpdate(deltaTime);
}

bool PhysicsWorld::update(double deltaTime) {
	if (isUpdating() && !isFixedUpdating()) {
		doUpdate(deltaTime);
	}
	return Node::update(deltaTime);
}

void PhysicsWorld::setFixtureData(pr::ShapeID f, Sensor* sensor) {
	if (_fixtureData.size() < f.get() + 1u) {
		_fixtureData.resize(f.get() + 1u);
	}
	_fixtureData[f.get()] = sensor;
}

Sensor* PhysicsWorld::getFixtureData(pr::ShapeID fixture) const {
	return _fixtureData[fixture.get()];
}

void PhysicsWorld::setBodyData(pr::BodyID b, Body* body) {
	if (_bodyData.size() < b.get() + 1u) {
		_bodyData.resize(b.get() + 1u);
	}
	_bodyData[b.get()] = body;
}

Body* PhysicsWorld::getBodyData(pr::BodyID body) const {
	return _bodyData[body.get()];
}

void PhysicsWorld::setJointData(pr::JointID j, Joint* joint) {
	if (_jointData.size() < j.get() + 1u) {
		_jointData.resize(j.get() + 1u);
	}
	_jointData[j.get()] = joint;
}

Joint* PhysicsWorld::getJointData(pr::JointID joint) const {
	return _jointData[joint.get()];
}

bool PhysicsWorld::query(const Rect& rect, const std::function<bool(Body*)>& callback) {
	AssertUnless(_world, "accessing invalid physics world.");
	auto& world = *_world;
	pd::AABB aabb{
		pd::AABB::Location{
			prVal(rect.getLeft()),
			prVal(rect.getBottom())},
		pd::AABB::Location{
			prVal(rect.getRight()),
			prVal(rect.getTop())}};
	pd::Transformation transform{
		pr::Length2{
			prVal(rect.getCenterX()),
			prVal(rect.getCenterY())}};
	pd::Shape testShape = pd::Shape{
		pd::PolygonShapeConf{
			prVal(rect.size.width),
			prVal(rect.size.height)}};
	pd::Query(pd::GetTree(world), aabb, [&](pr::BodyID bodyID, pr::ShapeID shapeID, const pr::ChildCounter) {
		BLOCK_START {
			BREAK_IF(pd::IsSensor(world, shapeID));
			const auto shapeType = pd::GetType(world, shapeID);
			bool isCommonShape = shapeType != pr::GetTypeID<pd::ChainShapeConf>() && shapeType != pr::GetTypeID<pd::EdgeShapeConf>();
			const auto shape = pd::GetShape(world, shapeID);
			BREAK_IF(isCommonShape && !pd::TestOverlap(pd::GetChild(testShape, 0), transform, pd::GetChild(shape, 0), pd::GetTransformation(world, bodyID)));
			Body* body = _bodyData[bodyID.get()];
			std::vector<Body*>& results = isCommonShape ? _queryResultsOfCommonShapes : _queryResultsOfChainsAndEdges;
			if (body && (results.empty() || results.back() != body)) {
				results.push_back(body);
			}
		}
		BLOCK_END
		return true;
	});
	bool result = false;
	for (Body* item : _queryResultsOfCommonShapes) {
		if (callback(item)) {
			result = true;
			break;
		}
	}
	for (Body* item : _queryResultsOfChainsAndEdges) {
		if (callback(item)) {
			result = true;
			break;
		}
	}
	_queryResultsOfCommonShapes.clear();
	_queryResultsOfChainsAndEdges.clear();
	return result;
}

bool PhysicsWorld::raycast(const Vec2& start, const Vec2& end, bool closest, const std::function<bool(Body*, const Vec2&, const Vec2&)>& callback) {
	AssertUnless(_world, "accessing invalid physics world.");
	auto& world = *_world;
	pd::RayCastInput input{prVal(start), prVal(end), pr::Real{1}};
	bool result = false;
	pd::RayCast(world, input, [&](pr::BodyID body, pr::ShapeID fixture, pr::ChildCounter child, pr::Length2 point, pd::UnitVec normal) {
		Body* node = _bodyData[body.get()];
		if (!node) return pr::RayCastOpcode::ResetRay;
		_rayCastResult.body = node;
		_rayCastResult.point = Val(pr::Vec2{point[0], point[1]});
		_rayCastResult.normal = Val(pr::Vec2{normal[0], normal[1]});
		if (closest) {
			return pr::RayCastOpcode::Terminate;
		} else {
			_rayCastResults.push_back(_rayCastResult);
			return pr::RayCastOpcode::ResetRay;
		}
	});
	if (closest) {
		result = _rayCastResult.body ? callback(_rayCastResult.body, _rayCastResult.point, _rayCastResult.normal) : false;
		_rayCastResult.body = nullptr;
	} else {
		for (auto& item : _rayCastResults) {
			if (callback(item.body, item.point, item.normal)) {
				result = true;
				break;
			}
		}
		_rayCastResults.clear();
	}
	return result;
}

void PhysicsWorld::setShouldContact(uint8_t groupA, uint8_t groupB, bool contact) {
	AssertIf(groupA >= TotalGroups || groupB >= TotalGroups, "Body group should be less than {}.", s_cast<int>(TotalGroups));
	AssertUnless(_world, "accessing invalid physics world.");
	auto& world = *_world;
	pr::Filter& filterA = _filters[groupA];
	pr::Filter& filterB = _filters[groupB];
	if (contact) {
		filterA.maskBits |= filterB.categoryBits;
		filterB.maskBits |= filterA.categoryBits;
	} else {
		filterA.maskBits &= (~filterB.categoryBits);
		filterB.maskBits &= (~filterA.categoryBits);
	}
	for (pr::BodyID body : pd::GetBodies(world)) {
		for (pr::ShapeID f : pd::GetShapes(world, body)) {
			int groupIndex = pd::GetFilterData(world, f).groupIndex;
			if (groupIndex == groupA) {
				pd::SetFilterData(world, f, _filters[groupA]);
			} else if (groupIndex == groupB) {
				pd::SetFilterData(world, f, _filters[groupB]);
			}
		}
	}
}

bool PhysicsWorld::getShouldContact(uint8_t groupA, uint8_t groupB) const {
	AssertIf(groupA >= TotalGroups || groupB >= TotalGroups, "Body group should be less than {}.", s_cast<int>(TotalGroups));
	const pr::Filter& filterA = _filters[groupA];
	const pr::Filter& filterB = _filters[groupB];
	return (filterA.maskBits & filterB.categoryBits) && (filterA.categoryBits & filterB.maskBits);
}

const pr::Filter& PhysicsWorld::getFilter(uint8_t group) const {
	AssertIf(group >= TotalGroups, "Body group should be less than {}.", s_cast<int>(TotalGroups));
	return _filters[group];
}

void PhysicsWorld::solveContacts() {
	if (!_contactStarts.empty()) {
		for (ContactPair& pair : _contactStarts) {
			if (pair.bodyA && pair.bodyB) {
				pair.bodyA->contactStart(pair.bodyB, pair.point, pair.normal, pair.enabled);
			}
		}
		_contactStarts.clear();
	}
	if (!_contactEnds.empty()) {
		for (ContactPair& pair : _contactEnds) {
			if (pair.bodyA && pair.bodyB) {
				pair.bodyA->contactEnd(pair.bodyB, pair.point, pair.normal);
			}
		}
		_contactEnds.clear();
	}
	if (!_sensorEnters.empty()) {
		for (SensorPair& pair : _sensorEnters) {
			if (pair.owner && pair.sensor && pair.body && pair.sensor->isEnabled()) {
				pair.sensor->add(pair.body);
			}
		}
		_sensorEnters.clear();
	}
	if (!_sensorLeaves.empty()) {
		for (SensorPair& pair : _sensorLeaves) {
			if (pair.owner && pair.sensor && pair.body && pair.sensor->isEnabled()) {
				pair.sensor->remove(pair.body);
			}
		}
		_sensorLeaves.clear();
	}
}

NS_DORA_END

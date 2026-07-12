#ifndef JPH_NO_FORCE_INLINE
#define JPH_NO_FORCE_INLINE
#endif

#include <Jolt/Jolt.h>

#include <Jolt/Core/Factory.h>
#include <Jolt/Core/JobSystemSingleThreaded.h>
#include <Jolt/Core/TempAllocator.h>
#include <Jolt/Physics/Body/BodyCreationSettings.h>
#include <Jolt/Physics/Body/BodyLock.h>
#include <Jolt/Physics/Body/BodyFilter.h>
#include <Jolt/Physics/Character/CharacterVirtual.h>
#include <Jolt/Physics/Body/BodyLockMulti.h>
#include <Jolt/Physics/Collision/BroadPhase/BroadPhaseLayer.h>
#include <Jolt/Physics/Collision/CollideShape.h>
#include <Jolt/Physics/Collision/CastResult.h>
#include <Jolt/Physics/Collision/CollisionCollectorImpl.h>
#include <Jolt/Physics/Collision/ContactListener.h>
#include <Jolt/Physics/Collision/NarrowPhaseQuery.h>
#include <Jolt/Physics/Collision/RayCast.h>
#include <Jolt/Physics/Collision/Shape/BoxShape.h>
#include <Jolt/Physics/Collision/Shape/CapsuleShape.h>
#include <Jolt/Physics/Collision/Shape/ConvexHullShape.h>
#include <Jolt/Physics/Collision/Shape/MeshShape.h>
#include <Jolt/Physics/Collision/Shape/RotatedTranslatedShape.h>
#include <Jolt/Physics/Collision/Shape/SphereShape.h>
#include <Jolt/Physics/Collision/Shape/StaticCompoundShape.h>
#include <Jolt/Physics/Constraints/DistanceConstraint.h>
#include <Jolt/Physics/Constraints/FixedConstraint.h>
#include <Jolt/Physics/Constraints/HingeConstraint.h>
#include <Jolt/Physics/PhysicsSystem.h>
#include <Jolt/RegisterTypes.h>

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <mutex>
#include <memory>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace {
using namespace JPH;

namespace Layers {
constexpr ObjectLayer NonMoving = 0;
constexpr ObjectLayer Moving = 1;
} // namespace Layers

namespace BroadPhaseLayers {
constexpr BroadPhaseLayer NonMoving(0);
constexpr BroadPhaseLayer Moving(1);
constexpr uint32_t Count = 2;
} // namespace BroadPhaseLayers

class BroadPhaseLayerInterfaceImpl final : public BroadPhaseLayerInterface {
public:
	uint GetNumBroadPhaseLayers() const override { return BroadPhaseLayers::Count; }

	BroadPhaseLayer GetBroadPhaseLayer(ObjectLayer layer) const override {
		return layer == Layers::NonMoving ? BroadPhaseLayers::NonMoving : BroadPhaseLayers::Moving;
	}
};

class ObjectVsBroadPhaseLayerFilterImpl final : public ObjectVsBroadPhaseLayerFilter {
public:
	bool ShouldCollide(ObjectLayer objectLayer, BroadPhaseLayer broadPhaseLayer) const override {
		return objectLayer == Layers::Moving || broadPhaseLayer == BroadPhaseLayers::Moving;
	}
};

class ObjectLayerPairFilterImpl final : public ObjectLayerPairFilter {
public:
	bool ShouldCollide(ObjectLayer first, ObjectLayer second) const override {
		return first == Layers::Moving || second == Layers::Moving;
	}
};

struct DoraJoltEvent {
	uint8_t type;
	uint64_t first;
	uint64_t second;
	float point[3];
	float normal[3];
};

class ContactListenerImpl final : public ContactListener {
public:
	ValidateResult OnContactValidate(const Body& first, const Body& second, RVec3Arg, const CollideShapeResult&) override {
		const CollisionGroup& firstGroup = first.GetCollisionGroup();
		const CollisionGroup& secondGroup = second.GetCollisionGroup();
		const uint32_t firstLayer = firstGroup.GetGroupID();
		const uint32_t secondLayer = secondGroup.GetGroupID();
		const uint32_t firstMask = firstGroup.GetSubGroupID();
		const uint32_t secondMask = secondGroup.GetSubGroupID();
		if (firstLayer >= 32 || secondLayer >= 32
			|| (firstMask & (uint32_t(1) << secondLayer)) == 0
			|| (secondMask & (uint32_t(1) << firstLayer)) == 0) {
			return ValidateResult::RejectAllContactsForThisBodyPair;
		}
		return ValidateResult::AcceptAllContactsForThisBodyPair;
	}

	void OnContactAdded(const Body& first, const Body& second, const ContactManifold& manifold, ContactSettings&) override {
		auto event = makeEvent(0, first.GetUserData(), second.GetUserData(), manifold);
		std::lock_guard lock(mutex);
		events.push_back(event);
		contacts[SubShapeIDPair(first.GetID(), manifold.mSubShapeID1, second.GetID(), manifold.mSubShapeID2)] = event;
	}

	void OnContactPersisted(const Body& first, const Body& second, const ContactManifold& manifold, ContactSettings&) override {
		auto event = makeEvent(1, first.GetUserData(), second.GetUserData(), manifold);
		std::lock_guard lock(mutex);
		events.push_back(event);
	}

	void OnContactRemoved(const SubShapeIDPair& pair) override {
		std::lock_guard lock(mutex);
		auto found = contacts.find(pair);
		if (found == contacts.end()) return;
		auto event = found->second;
		event.type = 2;
		events.push_back(event);
		contacts.erase(found);
	}

	void drain(std::vector<DoraJoltEvent>& output) {
		std::lock_guard lock(mutex);
		output.clear();
		output.swap(events);
	}

private:
	DoraJoltEvent makeEvent(uint8_t type, uint64_t first, uint64_t second, const ContactManifold& manifold) {
		DoraJoltEvent event {};
		event.type = type;
		event.first = first;
		event.second = second;
		if (!manifold.mRelativeContactPointsOn1.empty()) {
			const RVec3 point = manifold.GetWorldSpaceContactPointOn1(0);
			event.point[0] = static_cast<float>(point.GetX());
			event.point[1] = static_cast<float>(point.GetY());
			event.point[2] = static_cast<float>(point.GetZ());
		}
		event.normal[0] = manifold.mWorldSpaceNormal.GetX();
		event.normal[1] = manifold.mWorldSpaceNormal.GetY();
		event.normal[2] = manifold.mWorldSpaceNormal.GetZ();
		return event;
	}

	std::mutex mutex;
	std::vector<DoraJoltEvent> events;
	std::unordered_map<SubShapeIDPair, DoraJoltEvent> contacts;
};

struct DoraJoltWorld {
	explicit DoraJoltWorld(uint32_t maxBodies)
		: tempAllocator(4 * 1024 * 1024) {
		const uint32_t bodyPairs = std::max(1024u, maxBodies * 4);
		const uint32_t contacts = std::max(1024u, maxBodies * 2);
		physics.Init(maxBodies, 0, bodyPairs, contacts, broadPhaseLayers, objectVsBroadPhase, objectPairs);
		physics.SetContactListener(&contactListener);
	}

	BroadPhaseLayerInterfaceImpl broadPhaseLayers;
	ObjectVsBroadPhaseLayerFilterImpl objectVsBroadPhase;
	ObjectLayerPairFilterImpl objectPairs;
	ContactListenerImpl contactListener;
	PhysicsSystem physics;
	TempAllocatorImplWithMallocFallback tempAllocator;
	JobSystemSingleThreaded jobs {cMaxPhysicsJobs};
	std::vector<DoraJoltEvent> pendingEvents;
	std::vector<std::unique_ptr<struct DoraJoltCharacter>> characters;
};

struct DoraJoltCharacter {
	Ref<CharacterVirtual> character;
	float stepHeight = 0.4f;
	uint8_t collisionLayer = 0;
	uint32_t collisionMask = 0xffffffffu;
};

struct DoraJoltShape {
	RefConst<Shape> shape;
};

struct DoraJoltConstraint {
	Ref<TwoBodyConstraint> constraint;
};

class CharacterBodyFilter final : public BodyFilter {
public:
	CharacterBodyFilter(uint8_t layer, uint32_t mask)
		: layer(layer)
		, mask(mask) { }

	bool ShouldCollideLocked(const Body& body) const override {
		if (body.IsSensor()) return false;
		const CollisionGroup& group = body.GetCollisionGroup();
		const uint32_t bodyLayer = group.GetGroupID();
		return bodyLayer < 32
			&& (mask & (uint32_t(1) << bodyLayer)) != 0
			&& (group.GetSubGroupID() & (uint32_t(1) << layer)) != 0;
	}

private:
	uint8_t layer;
	uint32_t mask;
};

std::mutex gInitMutex;
uint32_t gWorldCount = 0;

void retainJolt() {
	std::lock_guard lock(gInitMutex);
	if (gWorldCount++ == 0) {
		RegisterDefaultAllocator();
		Factory::sInstance = new Factory();
		RegisterTypes();
	}
}

void releaseJolt() {
	std::lock_guard lock(gInitMutex);
	if (--gWorldCount == 0) {
		UnregisterTypes();
		delete Factory::sInstance;
		Factory::sInstance = nullptr;
	}
}

BodyID bodyId(uint32_t value) { return BodyID(value); }

EMotionType motionType(uint8_t value) {
	switch (value) {
		case 0: return EMotionType::Static;
		case 1: return EMotionType::Kinematic;
		default: return EMotionType::Dynamic;
	}
}

ObjectLayer objectLayer(EMotionType type) {
	return type == EMotionType::Static ? Layers::NonMoving : Layers::Moving;
}

BodyID createBody(DoraJoltWorld* world, const Shape* shape, uint8_t motion, const float* position, const float* rotation, uint64_t userData) {
	if (world == nullptr || shape == nullptr || position == nullptr || rotation == nullptr) return BodyID();
	const EMotionType type = motionType(motion);
	BodyCreationSettings settings(
		shape,
		RVec3(position[0], position[1], position[2]),
		Quat(rotation[0], rotation[1], rotation[2], rotation[3]).Normalized(),
		type,
		objectLayer(type));
	settings.mUserData = userData;
	settings.mCollisionGroup = CollisionGroup(nullptr, 0, 0xffffffffu);
	return world->physics.GetBodyInterface().CreateAndAddBody(
		settings,
		type == EMotionType::Dynamic ? EActivation::Activate : EActivation::DontActivate);
}

DoraJoltShape* wrapShape(const Shape* shape) {
	if (shape == nullptr) return nullptr;
	auto* wrapper = new DoraJoltShape();
	wrapper->shape = shape;
	return wrapper;
}

DoraJoltConstraint* addConstraint(DoraJoltWorld* world, TwoBodyConstraint* constraint) {
	if (world == nullptr || constraint == nullptr) return nullptr;
	auto* wrapper = new DoraJoltConstraint();
	wrapper->constraint = constraint;
	world->physics.AddConstraint(constraint);
	return wrapper;
}

template <class Update>
void rebuildBodyContacts(DoraJoltWorld* world, uint32_t body, Update&& update) {
	if (world == nullptr || body == BodyID().GetIndexAndSequenceNumber()) return;
	auto& bodies = world->physics.GetBodyInterface();
	const BodyID id = bodyId(body);
	if (!bodies.IsAdded(id)) return;
	const EMotionType motion = bodies.GetMotionType(id);
	bodies.RemoveBody(id);
	update(bodies, id);
	bodies.AddBody(id, motion == EMotionType::Static ? EActivation::DontActivate : EActivation::Activate);
}
} // namespace

extern "C" {
DoraJoltWorld* dora_jolt_world_create(uint32_t maxBodies) {
	if (maxBodies == 0) return nullptr;
	retainJolt();
	return new DoraJoltWorld(maxBodies);
}

void dora_jolt_world_destroy(DoraJoltWorld* world) {
	if (world == nullptr) return;
	delete world;
	releaseJolt();
}

void dora_jolt_world_set_gravity(DoraJoltWorld* world, float x, float y, float z) {
	if (world != nullptr) world->physics.SetGravity(Vec3(x, y, z));
}

void dora_jolt_world_step(DoraJoltWorld* world, float deltaTime) {
	if (world != nullptr && deltaTime > 0.0f) {
		world->physics.Update(deltaTime, 1, &world->tempAllocator, &world->jobs);
		world->contactListener.drain(world->pendingEvents);
	}
}

DoraJoltShape* dora_jolt_shape_create_box(const float* halfExtent) {
	if (halfExtent == nullptr || halfExtent[0] <= 0.0f || halfExtent[1] <= 0.0f || halfExtent[2] <= 0.0f) return nullptr;
	retainJolt();
	return wrapShape(new BoxShape(Vec3(halfExtent[0], halfExtent[1], halfExtent[2])));
}

DoraJoltShape* dora_jolt_shape_create_sphere(float radius) {
	if (radius <= 0.0f) return nullptr;
	retainJolt();
	return wrapShape(new SphereShape(radius));
}

DoraJoltShape* dora_jolt_shape_create_capsule(float halfHeight, float radius) {
	if (halfHeight < 0.0f || radius <= 0.0f) return nullptr;
	retainJolt();
	return wrapShape(new CapsuleShape(halfHeight, radius));
}

DoraJoltShape* dora_jolt_shape_create_compound(
	DoraJoltShape* const* shapes,
	const float* positions,
	const float* rotations,
	uint32_t count) {
	if (shapes == nullptr || positions == nullptr || rotations == nullptr || count == 0) return nullptr;
	StaticCompoundShapeSettings settings;
	for (uint32_t i = 0; i < count; ++i) {
		if (shapes[i] == nullptr || shapes[i]->shape == nullptr) return nullptr;
		const float* position = positions + i * 3;
		const float* rotation = rotations + i * 4;
		settings.AddShape(
			Vec3(position[0], position[1], position[2]),
			Quat(rotation[0], rotation[1], rotation[2], rotation[3]).Normalized(),
			shapes[i]->shape.GetPtr());
	}
	auto result = settings.Create();
	if (!result.IsValid()) return nullptr;
	retainJolt();
	return wrapShape(result.Get().GetPtr());
}

DoraJoltShape* dora_jolt_shape_create_mesh(
	const float* vertices,
	uint32_t vertexCount,
	const uint32_t* indices,
	uint32_t indexCount) {
	if (vertices == nullptr || indices == nullptr || vertexCount < 3 || indexCount < 3 || indexCount % 3 != 0) return nullptr;
	for (uint32_t i = 0; i < indexCount; ++i) {
		if (indices[i] >= vertexCount) return nullptr;
	}
	retainJolt();
	VertexList meshVertices;
	meshVertices.reserve(vertexCount);
	for (uint32_t i = 0; i < vertexCount; ++i) {
		const float* vertex = vertices + i * 3;
		meshVertices.emplace_back(vertex[0], vertex[1], vertex[2]);
	}
	IndexedTriangleList triangles;
	triangles.reserve(indexCount / 3);
	for (uint32_t i = 0; i < indexCount; i += 3) {
		triangles.emplace_back(indices[i], indices[i + 1], indices[i + 2], 0);
	}
	MeshShapeSettings settings(std::move(meshVertices), std::move(triangles));
	settings.mBuildQuality = MeshShapeSettings::EBuildQuality::FavorRuntimePerformance;
	auto result = settings.Create();
	if (!result.IsValid()) {
		releaseJolt();
		return nullptr;
	}
	return wrapShape(result.Get().GetPtr());
}

DoraJoltShape* dora_jolt_shape_create_convex_hull(const float* points, uint32_t pointCount) {
	if (points == nullptr || pointCount < 4) return nullptr;
	Array<Vec3> hullPoints;
	hullPoints.reserve(pointCount);
	for (uint32_t i = 0; i < pointCount; ++i) {
		const float* point = points + i * 3;
		if (!std::isfinite(point[0]) || !std::isfinite(point[1]) || !std::isfinite(point[2])) return nullptr;
		hullPoints.emplace_back(point[0], point[1], point[2]);
	}
	ConvexHullShapeSettings settings(hullPoints);
	auto result = settings.Create();
	if (!result.IsValid()) return nullptr;
	retainJolt();
	return wrapShape(result.Get().GetPtr());
}

void dora_jolt_shape_destroy(DoraJoltShape* shape) {
	if (shape == nullptr) return;
	delete shape;
	releaseJolt();
}

DoraJoltCharacter* dora_jolt_character_create_capsule(
	DoraJoltWorld* world,
	float halfHeight,
	float radius,
	const float* position,
	const float* rotation,
	float maxSlopeAngle,
	float stepHeight) {
	if (world == nullptr || halfHeight <= 0.0f || radius <= 0.0f || position == nullptr || rotation == nullptr) return nullptr;
	CharacterVirtualSettings settings;
	settings.mMaxSlopeAngle = DegreesToRadians(Clamp(maxSlopeAngle, 0.0f, 89.0f));
	settings.mSupportingVolume = Plane(Vec3::sAxisY(), -radius);
	settings.mShape = new RotatedTranslatedShape(
		Vec3(0.0f, halfHeight + radius, 0.0f),
		Quat::sIdentity(),
		new CapsuleShape(halfHeight, radius));
	auto wrapper = std::make_unique<DoraJoltCharacter>();
	wrapper->stepHeight = std::max(0.0f, stepHeight);
	wrapper->character = new CharacterVirtual(
		&settings,
		RVec3(position[0], position[1], position[2]),
		Quat(rotation[0], rotation[1], rotation[2], rotation[3]).Normalized(),
		&world->physics);
	auto* result = wrapper.get();
	world->characters.push_back(std::move(wrapper));
	return result;
}

void dora_jolt_character_destroy(DoraJoltWorld* world, DoraJoltCharacter* character) {
	if (world == nullptr || character == nullptr) return;
	auto found = std::find_if(world->characters.begin(), world->characters.end(), [character](const auto& item) {
		return item.get() == character;
	});
	if (found != world->characters.end()) world->characters.erase(found);
}

bool dora_jolt_character_update(
	DoraJoltWorld* world,
	DoraJoltCharacter* wrapper,
	float deltaTime,
	const float* desiredVelocity,
	float jumpSpeed) {
	if (world == nullptr || wrapper == nullptr || desiredVelocity == nullptr || deltaTime <= 0.0f) return false;
	auto* character = wrapper->character.GetPtr();
	const Vec3 up = character->GetUp();
	const Vec3 gravity = world->physics.GetGravity();
	const bool grounded = character->GetGroundState() == CharacterBase::EGroundState::OnGround;
	Vec3 velocity = character->GetLinearVelocity();
	Vec3 horizontal(desiredVelocity[0], desiredVelocity[1], desiredVelocity[2]);
	horizontal -= up * horizontal.Dot(up);
	if (grounded && jumpSpeed > 0.0f) {
		velocity = character->GetGroundVelocity() + horizontal + up * jumpSpeed;
	} else if (grounded && velocity.Dot(up) <= 0.0f) {
		velocity = character->GetGroundVelocity() + horizontal;
	} else {
		velocity = horizontal + up * velocity.Dot(up);
	}
	velocity += gravity * deltaTime;
	character->SetLinearVelocity(character->CancelVelocityTowardsSteepSlopes(velocity));

	CharacterVirtual::ExtendedUpdateSettings settings;
	settings.mStickToFloorStepDown = -up * wrapper->stepHeight;
	settings.mWalkStairsStepUp = up * wrapper->stepHeight;
	const DefaultBroadPhaseLayerFilter broadPhaseFilter = world->physics.GetDefaultBroadPhaseLayerFilter(Layers::Moving);
	const DefaultObjectLayerFilter objectLayerFilter = world->physics.GetDefaultLayerFilter(Layers::Moving);
	const CharacterBodyFilter bodyFilter(wrapper->collisionLayer, wrapper->collisionMask);
	const ShapeFilter shapeFilter;
	character->ExtendedUpdate(
		deltaTime,
		gravity,
		settings,
		broadPhaseFilter,
		objectLayerFilter,
		bodyFilter,
		shapeFilter,
		world->tempAllocator);
	return true;
}

bool dora_jolt_character_get_transform(DoraJoltCharacter* wrapper, float* position, float* rotation) {
	if (wrapper == nullptr || position == nullptr || rotation == nullptr) return false;
	const RVec3 value = wrapper->character->GetPosition();
	const Quat orientation = wrapper->character->GetRotation();
	position[0] = static_cast<float>(value.GetX());
	position[1] = static_cast<float>(value.GetY());
	position[2] = static_cast<float>(value.GetZ());
	rotation[0] = orientation.GetX();
	rotation[1] = orientation.GetY();
	rotation[2] = orientation.GetZ();
	rotation[3] = orientation.GetW();
	return true;
}

void dora_jolt_character_get_velocity(DoraJoltCharacter* wrapper, float* velocity) {
	if (wrapper == nullptr || velocity == nullptr) return;
	const Vec3 value = wrapper->character->GetLinearVelocity();
	velocity[0] = value.GetX();
	velocity[1] = value.GetY();
	velocity[2] = value.GetZ();
}

uint8_t dora_jolt_character_get_ground_state(DoraJoltCharacter* wrapper) {
	return wrapper == nullptr ? 3 : static_cast<uint8_t>(wrapper->character->GetGroundState());
}

void dora_jolt_character_get_ground_normal(DoraJoltCharacter* wrapper, float* normal) {
	if (wrapper == nullptr || normal == nullptr) return;
	const Vec3 value = wrapper->character->GetGroundNormal();
	normal[0] = value.GetX();
	normal[1] = value.GetY();
	normal[2] = value.GetZ();
}

void dora_jolt_character_set_filter(DoraJoltCharacter* wrapper, uint8_t layer, uint32_t mask) {
	if (wrapper == nullptr || layer >= 32) return;
	wrapper->collisionLayer = layer;
	wrapper->collisionMask = mask;
}

uint32_t dora_jolt_world_event_count(DoraJoltWorld* world) {
	return world == nullptr ? 0 : static_cast<uint32_t>(world->pendingEvents.size());
}

bool dora_jolt_world_event_get(DoraJoltWorld* world, uint32_t index, DoraJoltEvent* output) {
	if (world == nullptr || output == nullptr || index >= world->pendingEvents.size()) return false;
	*output = world->pendingEvents[index];
	return true;
}

void dora_jolt_world_event_clear(DoraJoltWorld* world) {
	if (world != nullptr) world->pendingEvents.clear();
}

uint32_t dora_jolt_body_create_box(DoraJoltWorld* world, const float* halfExtent, uint8_t motion, const float* position, const float* rotation, uint64_t userData) {
	if (halfExtent == nullptr || halfExtent[0] <= 0.0f || halfExtent[1] <= 0.0f || halfExtent[2] <= 0.0f) return BodyID().GetIndexAndSequenceNumber();
	ShapeRefC shape = new BoxShape(Vec3(halfExtent[0], halfExtent[1], halfExtent[2]));
	return createBody(world, shape, motion, position, rotation, userData).GetIndexAndSequenceNumber();
}

uint32_t dora_jolt_body_create_sphere(DoraJoltWorld* world, float radius, uint8_t motion, const float* position, const float* rotation, uint64_t userData) {
	if (radius <= 0.0f) return BodyID().GetIndexAndSequenceNumber();
	ShapeRefC shape = new SphereShape(radius);
	return createBody(world, shape, motion, position, rotation, userData).GetIndexAndSequenceNumber();
}

uint32_t dora_jolt_body_create_capsule(DoraJoltWorld* world, float halfHeight, float radius, uint8_t motion, const float* position, const float* rotation, uint64_t userData) {
	if (halfHeight <= 0.0f || radius <= 0.0f) return BodyID().GetIndexAndSequenceNumber();
	ShapeRefC shape = new CapsuleShape(halfHeight, radius);
	return createBody(world, shape, motion, position, rotation, userData).GetIndexAndSequenceNumber();
}

uint32_t dora_jolt_body_create_shape(DoraJoltWorld* world, DoraJoltShape* shape, uint8_t motion, const float* position, const float* rotation, uint64_t userData) {
	if (shape == nullptr) return BodyID().GetIndexAndSequenceNumber();
	if (motionType(motion) != EMotionType::Static && shape->shape->MustBeStatic()) {
		return BodyID().GetIndexAndSequenceNumber();
	}
	return createBody(world, shape->shape.GetPtr(), motion, position, rotation, userData).GetIndexAndSequenceNumber();
}

DoraJoltConstraint* dora_jolt_constraint_create_fixed(
	DoraJoltWorld* world,
	uint32_t firstBody,
	uint32_t secondBody,
	const float* anchor) {
	if (world == nullptr || anchor == nullptr) return nullptr;
	BodyID ids[] = {bodyId(firstBody), bodyId(secondBody)};
	Ref<TwoBodyConstraint> constraint;
	{
		BodyLockMultiWrite lock(world->physics.GetBodyLockInterface(), ids, 2);
		auto* first = lock.GetBody(0);
		auto* second = lock.GetBody(1);
		if (first == nullptr || second == nullptr) return nullptr;
		FixedConstraintSettings settings;
		settings.mSpace = EConstraintSpace::WorldSpace;
		settings.mAutoDetectPoint = false;
		settings.mPoint1 = settings.mPoint2 = RVec3(anchor[0], anchor[1], anchor[2]);
		constraint = settings.Create(*first, *second);
	}
	return addConstraint(world, constraint.GetPtr());
}

DoraJoltConstraint* dora_jolt_constraint_create_distance(
	DoraJoltWorld* world,
	uint32_t firstBody,
	uint32_t secondBody,
	const float* firstAnchor,
	const float* secondAnchor,
	float minDistance,
	float maxDistance) {
	if (world == nullptr || firstAnchor == nullptr || secondAnchor == nullptr) return nullptr;
	BodyID ids[] = {bodyId(firstBody), bodyId(secondBody)};
	Ref<TwoBodyConstraint> constraint;
	{
		BodyLockMultiWrite lock(world->physics.GetBodyLockInterface(), ids, 2);
		auto* first = lock.GetBody(0);
		auto* second = lock.GetBody(1);
		if (first == nullptr || second == nullptr) return nullptr;
		DistanceConstraintSettings settings;
		settings.mSpace = EConstraintSpace::WorldSpace;
		settings.mPoint1 = RVec3(firstAnchor[0], firstAnchor[1], firstAnchor[2]);
		settings.mPoint2 = RVec3(secondAnchor[0], secondAnchor[1], secondAnchor[2]);
		if (minDistance >= 0.0f && maxDistance >= minDistance) {
			settings.mMinDistance = minDistance;
			settings.mMaxDistance = maxDistance;
		}
		constraint = settings.Create(*first, *second);
	}
	return addConstraint(world, constraint.GetPtr());
}

DoraJoltConstraint* dora_jolt_constraint_create_hinge(
	DoraJoltWorld* world,
	uint32_t firstBody,
	uint32_t secondBody,
	const float* anchor,
	const float* axis,
	float minAngle,
	float maxAngle) {
	if (world == nullptr || anchor == nullptr || axis == nullptr || minAngle > maxAngle) return nullptr;
	Vec3 hingeAxis(axis[0], axis[1], axis[2]);
	if (hingeAxis.IsNearZero()) return nullptr;
	hingeAxis = hingeAxis.Normalized();
	Vec3 reference = std::abs(hingeAxis.Dot(Vec3::sAxisX())) < 0.9f ? Vec3::sAxisX() : Vec3::sAxisY();
	Vec3 normalAxis = hingeAxis.Cross(reference).Normalized();
	BodyID ids[] = {bodyId(firstBody), bodyId(secondBody)};
	Ref<TwoBodyConstraint> constraint;
	{
		BodyLockMultiWrite lock(world->physics.GetBodyLockInterface(), ids, 2);
		auto* first = lock.GetBody(0);
		auto* second = lock.GetBody(1);
		if (first == nullptr || second == nullptr) return nullptr;
		HingeConstraintSettings settings;
		settings.mSpace = EConstraintSpace::WorldSpace;
		settings.mPoint1 = settings.mPoint2 = RVec3(anchor[0], anchor[1], anchor[2]);
		settings.mHingeAxis1 = settings.mHingeAxis2 = hingeAxis;
		settings.mNormalAxis1 = settings.mNormalAxis2 = normalAxis;
		settings.mLimitsMin = minAngle;
		settings.mLimitsMax = maxAngle;
		constraint = settings.Create(*first, *second);
	}
	return addConstraint(world, constraint.GetPtr());
}

void dora_jolt_constraint_destroy(DoraJoltWorld* world, DoraJoltConstraint* constraint) {
	if (world == nullptr || constraint == nullptr) return;
	BodyID first;
	BodyID second;
	if (constraint->constraint != nullptr) {
		first = constraint->constraint->GetBody1()->GetID();
		second = constraint->constraint->GetBody2()->GetID();
		world->physics.RemoveConstraint(constraint->constraint);
	}
	delete constraint;
	auto& bodies = world->physics.GetBodyInterface();
	if (!first.IsInvalid() && bodies.IsAdded(first)) bodies.ActivateBody(first);
	if (!second.IsInvalid() && bodies.IsAdded(second)) bodies.ActivateBody(second);
}

void dora_jolt_body_destroy(DoraJoltWorld* world, uint32_t body) {
	if (world == nullptr || body == BodyID().GetIndexAndSequenceNumber()) return;
	auto& bodies = world->physics.GetBodyInterface();
	const BodyID id = bodyId(body);
	if (!bodies.IsAdded(id)) return;
	bodies.RemoveBody(id);
	bodies.DestroyBody(id);
}

void dora_jolt_body_set_transform(DoraJoltWorld* world, uint32_t body, const float* position, const float* rotation, bool kinematic, float deltaTime) {
	if (world == nullptr || position == nullptr || rotation == nullptr) return;
	auto& bodies = world->physics.GetBodyInterface();
	const RVec3 bodyPosition(position[0], position[1], position[2]);
	const Quat bodyRotation = Quat(rotation[0], rotation[1], rotation[2], rotation[3]).Normalized();
	if (kinematic && deltaTime > 0.0f) {
		bodies.MoveKinematic(bodyId(body), bodyPosition, bodyRotation, deltaTime);
	} else {
		bodies.SetPositionAndRotation(bodyId(body), bodyPosition, bodyRotation, EActivation::DontActivate);
	}
}

bool dora_jolt_body_get_transform(DoraJoltWorld* world, uint32_t body, float* position, float* rotation) {
	if (world == nullptr || position == nullptr || rotation == nullptr) return false;
	RVec3 bodyPosition;
	Quat bodyRotation;
	world->physics.GetBodyInterface().GetPositionAndRotation(bodyId(body), bodyPosition, bodyRotation);
	position[0] = static_cast<float>(bodyPosition.GetX());
	position[1] = static_cast<float>(bodyPosition.GetY());
	position[2] = static_cast<float>(bodyPosition.GetZ());
	rotation[0] = bodyRotation.GetX();
	rotation[1] = bodyRotation.GetY();
	rotation[2] = bodyRotation.GetZ();
	rotation[3] = bodyRotation.GetW();
	return true;
}

bool dora_jolt_body_get_bounds(DoraJoltWorld* world, uint32_t body, float* bounds) {
	if (world == nullptr || bounds == nullptr) return false;
	BodyLockRead lock(world->physics.GetBodyLockInterface(), bodyId(body));
	const Body& value = lock.GetBody();
	const AABox& box = value.GetWorldSpaceBounds();
	bounds[0] = box.mMin.GetX();
	bounds[1] = box.mMin.GetY();
	bounds[2] = box.mMin.GetZ();
	bounds[3] = box.mMax.GetX();
	bounds[4] = box.mMax.GetY();
	bounds[5] = box.mMax.GetZ();
	return true;
}

void dora_jolt_body_set_linear_velocity(DoraJoltWorld* world, uint32_t body, const float* velocity) {
	if (world != nullptr && velocity != nullptr) world->physics.GetBodyInterface().SetLinearVelocity(bodyId(body), Vec3(velocity[0], velocity[1], velocity[2]));
}

void dora_jolt_body_get_linear_velocity(DoraJoltWorld* world, uint32_t body, float* velocity) {
	if (world == nullptr || velocity == nullptr) return;
	const Vec3 value = world->physics.GetBodyInterface().GetLinearVelocity(bodyId(body));
	velocity[0] = value.GetX();
	velocity[1] = value.GetY();
	velocity[2] = value.GetZ();
}

void dora_jolt_body_set_angular_velocity(DoraJoltWorld* world, uint32_t body, const float* velocity) {
	if (world != nullptr && velocity != nullptr) world->physics.GetBodyInterface().SetAngularVelocity(bodyId(body), Vec3(velocity[0], velocity[1], velocity[2]));
}

void dora_jolt_body_get_angular_velocity(DoraJoltWorld* world, uint32_t body, float* velocity) {
	if (world == nullptr || velocity == nullptr) return;
	const Vec3 value = world->physics.GetBodyInterface().GetAngularVelocity(bodyId(body));
	velocity[0] = value.GetX();
	velocity[1] = value.GetY();
	velocity[2] = value.GetZ();
}

void dora_jolt_body_add_force(DoraJoltWorld* world, uint32_t body, const float* force) {
	if (world != nullptr && force != nullptr) world->physics.GetBodyInterface().AddForce(bodyId(body), Vec3(force[0], force[1], force[2]));
}

void dora_jolt_body_add_impulse(DoraJoltWorld* world, uint32_t body, const float* impulse) {
	if (world != nullptr && impulse != nullptr) world->physics.GetBodyInterface().AddImpulse(bodyId(body), Vec3(impulse[0], impulse[1], impulse[2]));
}

void dora_jolt_body_set_filter(DoraJoltWorld* world, uint32_t body, uint8_t layer, uint32_t mask) {
	rebuildBodyContacts(world, body, [layer, mask](BodyInterface& bodies, const BodyID& id) {
		bodies.SetCollisionGroup(id, CollisionGroup(nullptr, layer, mask));
	});
}

void dora_jolt_body_get_filter(DoraJoltWorld* world, uint32_t body, uint8_t* layer, uint32_t* mask) {
	if (world == nullptr || layer == nullptr || mask == nullptr) return;
	const CollisionGroup& group = world->physics.GetBodyInterface().GetCollisionGroup(bodyId(body));
	*layer = static_cast<uint8_t>(group.GetGroupID());
	*mask = group.GetSubGroupID();
}

void dora_jolt_body_set_sensor(DoraJoltWorld* world, uint32_t body, bool sensor) {
	rebuildBodyContacts(world, body, [sensor](BodyInterface& bodies, const BodyID& id) {
		bodies.SetIsSensor(id, sensor);
	});
}

bool dora_jolt_body_is_sensor(DoraJoltWorld* world, uint32_t body) {
	return world != nullptr && world->physics.GetBodyInterface().IsSensor(bodyId(body));
}

bool dora_jolt_world_raycast(DoraJoltWorld* world, const float* origin, const float* direction, float distance, uint64_t* body, float* point, float* normal, float* fraction) {
	if (world == nullptr || origin == nullptr || direction == nullptr || body == nullptr || point == nullptr || normal == nullptr || fraction == nullptr || distance <= 0.0f) return false;
	Vec3 rayDirection(direction[0], direction[1], direction[2]);
	if (rayDirection.LengthSq() <= Square(1.0e-6f)) return false;
	rayDirection = rayDirection.Normalized() * distance;
	RRayCast ray(RVec3(origin[0], origin[1], origin[2]), rayDirection);
	RayCastResult hit;
	if (!world->physics.GetNarrowPhaseQuery().CastRay(ray, hit)) return false;
	const RVec3 hitPoint = ray.GetPointOnRay(hit.mFraction);
	const TransformedShape shape = world->physics.GetBodyInterface().GetTransformedShape(hit.mBodyID);
	const Vec3 hitNormal = shape.GetWorldSpaceSurfaceNormal(hit.mSubShapeID2, hitPoint);
	*body = world->physics.GetBodyInterface().GetUserData(hit.mBodyID);
	point[0] = static_cast<float>(hitPoint.GetX());
	point[1] = static_cast<float>(hitPoint.GetY());
	point[2] = static_cast<float>(hitPoint.GetZ());
	normal[0] = hitNormal.GetX();
	normal[1] = hitNormal.GetY();
	normal[2] = hitNormal.GetZ();
	*fraction = hit.mFraction;
	return true;
}

uint32_t dora_jolt_world_overlap_sphere(DoraJoltWorld* world, const float* center, float radius, uint64_t* bodies, uint32_t capacity) {
	if (world == nullptr || center == nullptr || radius <= 0.0f) return 0;
	ShapeRefC shape = new SphereShape(radius);
	CollideShapeSettings settings;
	AllHitCollisionCollector<CollideShapeCollector> collector;
	const RVec3 centerPosition(center[0], center[1], center[2]);
	world->physics.GetNarrowPhaseQuery().CollideShape(shape, Vec3::sOne(), RMat44::sTranslation(centerPosition), settings, centerPosition, collector);
	std::unordered_set<uint64_t> unique;
	for (const auto& hit : collector.mHits) {
		unique.insert(world->physics.GetBodyInterface().GetUserData(hit.mBodyID2));
	}
	uint32_t count = 0;
	if (bodies != nullptr) {
		for (uint64_t value : unique) {
			if (count >= capacity) break;
			bodies[count++] = value;
		}
		return count;
	}
	return static_cast<uint32_t>(unique.size());
}
}

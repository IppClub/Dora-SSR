/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include <algorithm>
#include <cassert> // for assert
#include <cstddef> // for std::size_t
#include <exception> // for std::throw_with_nested
#include <functional>
#include <iterator> // for std::next
#include <limits> // for std::numeric_limits
#include <map>
#include <optional>
#include <set>
#include <stdexcept> // for std::out_of_range
#include <tuple>
#include <utility> // for std::pair
#include <vector>

#ifdef DO_PAR_UNSEQ
#include <atomic>
#endif

//#define DO_THREADED
#if defined(DO_THREADED)
#include <future>
#endif

#include "playrho/BodyID.hpp"
#include "playrho/BodyType.hpp"
#include "playrho/Contact.hpp"
#include "playrho/Contactable.hpp"
#include "playrho/ContactID.hpp"
#include "playrho/ContactKey.hpp"
#include "playrho/ConstraintSolverConf.hpp"
#include "playrho/FlagGuard.hpp"
#include "playrho/InvalidArgument.hpp"
#include "playrho/Island.hpp"
#include "playrho/JointID.hpp"
#include "playrho/KeyedContactID.hpp"
#include "playrho/LengthError.hpp"
#include "playrho/Math.hpp"
#include "playrho/MovementConf.hpp"
#include "playrho/ObjectPool.hpp"
#include "playrho/OutOfRange.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/Span.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/StepStats.hpp"
#include "playrho/Templates.hpp"
#include "playrho/ToiConf.hpp"
#include "playrho/ToiOutput.hpp"
#include "playrho/to_underlying.hpp"
#include "playrho/UnitInterval.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"
#include "playrho/WrongState.hpp"
#include "playrho/ZeroToUnderOne.hpp"

#include "playrho/pmr/MemoryResource.hpp"
#include "playrho/pmr/PoolMemoryResource.hpp"

#include "playrho/d2/AABB.hpp"
#include "playrho/d2/AabbTreeWorld.hpp"
#include "playrho/d2/Body.hpp"
#include "playrho/d2/BodyConf.hpp"
#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/d2/ContactImpulsesFunction.hpp"
#include "playrho/d2/ContactImpulsesList.hpp"
#include "playrho/d2/ContactSolver.hpp"
#include "playrho/d2/Distance.hpp"
#include "playrho/d2/DistanceConf.hpp"
#include "playrho/d2/DistanceJointConf.hpp"
#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/DynamicTree.hpp"
#include "playrho/d2/FrictionJointConf.hpp"
#include "playrho/d2/GearJointConf.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/Manifold.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/MotorJointConf.hpp"
#include "playrho/d2/Position.hpp"
#include "playrho/d2/PositionConstraint.hpp"
#include "playrho/d2/PrismaticJointConf.hpp"
#include "playrho/d2/PulleyJointConf.hpp"
#include "playrho/d2/RayCastOutput.hpp"
#include "playrho/d2/RevoluteJointConf.hpp"
#include "playrho/d2/RopeJointConf.hpp"
#include "playrho/d2/Shape.hpp"
#include "playrho/d2/TargetJointConf.hpp"
#include "playrho/d2/TimeOfImpact.hpp"
#include "playrho/d2/Transformation.hpp"
#include "playrho/d2/Velocity.hpp"
#include "playrho/d2/VelocityConstraint.hpp"
#include "playrho/d2/WeldJointConf.hpp"
#include "playrho/d2/WheelJointConf.hpp"
#include "playrho/d2/World.hpp"
#include "playrho/d2/WorldConf.hpp"
#include "playrho/d2/WorldContact.hpp" // for SameTouching
#include "playrho/d2/WorldManifold.hpp"

// Enable this macro to enable sorting ID lists like m_contacts. This results in more linearly
// accessed memory. Benchmarking hasn't found a significant performance improvement however but
// it does seem to decrease performance in smaller simulations.
#define DO_SORT_ID_LISTS 0

using std::for_each;
using std::remove;
using std::sort;
using std::transform;
using std::unique;

namespace playrho::d2 {

using playrho::size;

/// @brief Collection of body constraints.
using BodyConstraints = std::vector<BodyConstraint, pmr::polymorphic_allocator<BodyConstraint>>;

/// @brief Collection of position constraints.
using PositionConstraints = std::vector<PositionConstraint, pmr::polymorphic_allocator<PositionConstraint>>;

/// @brief Collection of velocity constraints.
using VelocityConstraints = std::vector<VelocityConstraint, pmr::polymorphic_allocator<VelocityConstraint>>;

/// @brief The contact updating configuration.
struct AabbTreeWorld::ContactUpdateConf
{
    DistanceConf distance; ///< Distance configuration data.
    Manifold::Conf manifold; ///< Manifold configuration data.
};

namespace {

constexpr auto idIsDestroyedMsg = "ID is destroyed";
constexpr auto cannotBeEmptyMsg = "cannot be empty";
constexpr auto worldIsLockedMsg = "world is locked";
constexpr auto noSuchBodyMsg = "no such body";
constexpr auto noSuchContactMsg = "no such contact";
constexpr auto noSuchManifoldMsg = "no such manifold";
constexpr auto noSuchShapeMsg = "no such shape";
constexpr auto noSuchJointMsg = "no such joint";

template <class Container, class U, class V, class Message>
auto At(Container &&container, ::playrho::detail::IndexingNamedType<U, V> id, Message &&msg)
    -> decltype(OutOfRange{id, std::forward<Message>(msg)}, // NOLINT(cppcoreguidelines-pro-bounds-array-to-pointer-decay)
                std::forward<Container>(container).at(to_underlying(id)))
{
    try {
        return std::forward<Container>(container).at(to_underlying(id));
    }
    catch (const std::out_of_range&) {
        std::throw_with_nested(OutOfRange{id, std::forward<Message>(msg)}); // NOLINT(cppcoreguidelines-pro-bounds-array-to-pointer-decay)
    }
}

inline void IntegratePositions(const Span<const BodyID>& bodies,
                               const Span<BodyConstraint>& constraints,
                               Time h)
{
    assert(IsValid(h));
    for_each(cbegin(bodies), cend(bodies), [&](const auto& id) {
        auto& bc = constraints[to_underlying(id)];
        const auto velocity = bc.GetVelocity();
        const auto translation = h * velocity.linear;
        const auto rotation = h * velocity.angular;
        bc.SetPosition(bc.GetPosition() + Position{translation, rotation});
    });
}

/// Reports the given constraints to the listener.
/// @details
/// This calls the listener's PostSolve function for all size(contacts) elements of
/// the given array of constraints.
/// @param listener Listener to call.
/// @param constraints Array of m_contactCount contact velocity constraint elements.
inline void Report(const ContactImpulsesFunction& listener,
                   const Span<const ContactID>& contacts,
                   const Span<const VelocityConstraint>& constraints,
                   StepConf::iteration_type solved)
{
    const auto numContacts = size(contacts);
    for (auto i = decltype(numContacts){0}; i < numContacts; ++i)
    {
        listener(contacts[i], GetContactImpulses(constraints[i]), solved);
    }
}

inline void AssignImpulses(Manifold& var, const VelocityConstraint& vc)
{
    assert(var.GetPointCount() >= vc.GetPointCount());

    auto assignProc = [&](VelocityConstraint::size_type i) {
        const auto& point = vc.GetPointAt(i);
        var.SetImpulses(i, point.normalImpulse, point.tangentImpulse);
    };
#if 0
    // Branch free assignment causes problems in TilesComeToRest test.
    assignProc(1);
    assignProc(0);
#else
    const auto count = vc.GetPointCount();
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        assignProc(i);
    }
#endif
}

/// @brief Calculates the "warm start" velocity deltas for the given velocity constraint.
VelocityPair CalcWarmStartVelocityDeltas(const VelocityConstraint& vc,
                                         const Span<const BodyConstraint>& bodies)
{
    auto vp = VelocityPair{Velocity{LinearVelocity2{}, 0_rpm}, Velocity{LinearVelocity2{}, 0_rpm}};

    const auto normal = vc.GetNormal();
    const auto tangent = vc.GetTangent();
    const auto pointCount = vc.GetPointCount();
    const auto& bodyA = bodies[to_underlying(vc.GetBodyA())];
    const auto& bodyB = bodies[to_underlying(vc.GetBodyB())];

    const auto invMassA = bodyA.GetInvMass();
    const auto invRotInertiaA = bodyA.GetInvRotInertia();

    const auto invMassB = bodyB.GetInvMass();
    const auto invRotInertiaB = bodyB.GetInvRotInertia();

    for (auto j = decltype(pointCount){0}; j < pointCount; ++j) {
        // inverse moment of inertia : L^-2 M^-1 QP^2
        // P is M L T^-2
        // GetPointRelPosA() is Length2
        // Cross(Length2, P) is: M L^2 T^-2
        // L^-2 M^-1 QP^2 M L^2 T^-2 is: QP^2 T^-2
        const auto& vcp = vc.GetPointAt(j);
        const auto P = vcp.normalImpulse * normal + vcp.tangentImpulse * tangent;
        const auto LA = Cross(vcp.relA, P) / Radian;
        const auto LB = Cross(vcp.relB, P) / Radian;
        std::get<0>(vp) -= Velocity{invMassA * P, invRotInertiaA * LA};
        std::get<1>(vp) += Velocity{invMassB * P, invRotInertiaB * LB};
    }

    return vp;
}

void WarmStartVelocities(const Span<const VelocityConstraint>& velConstraints,
                         const Span<BodyConstraint>& bodies)
{
    for_each(cbegin(velConstraints), cend(velConstraints), [&](const VelocityConstraint& vc) {
        const auto vp = CalcWarmStartVelocityDeltas(vc, bodies);
        auto& bodyA = bodies[to_underlying(vc.GetBodyA())];
        auto& bodyB = bodies[to_underlying(vc.GetBodyB())];
        bodyA.SetVelocity(bodyA.GetVelocity() + std::get<0>(vp));
        bodyB.SetVelocity(bodyB.GetVelocity() + std::get<1>(vp));
    });
}

BodyConstraints GetBodyConstraints(pmr::memory_resource& resource,
                                   const Span<const BodyID>& bodies,
                                   const ObjectPool<Body>& bodyBuffer,
                                   Time h, const MovementConf& conf)
{
    auto constraints = BodyConstraints{&resource};
    constraints.resize(size(bodyBuffer)); // can't be size(bodies)!
    for (const auto& id: bodies) {
        constraints[to_underlying(id)] = GetBodyConstraint(bodyBuffer[to_underlying(id)], h, conf);
    }
    return constraints;
}

PositionConstraints GetPositionConstraints(pmr::memory_resource& resource,
                                           const Span<const ContactID>& contacts,
                                           const ObjectPool<Contact>& contactBuffer,
                                           const ObjectPool<Manifold>& manifoldBuffer,
                                           const ObjectPool<Shape>& shapeBuffer)
{
    auto constraints = PositionConstraints{&resource};
    constraints.reserve(size(contacts));
    transform(cbegin(contacts), cend(contacts), back_inserter(constraints),
              [&](const ContactID& contactID) {
        const auto& contact = contactBuffer[to_underlying(contactID)];
        const auto shapeA = GetShapeA(contact);
        const auto shapeB = GetShapeB(contact);
        const auto indexA = GetChildIndexA(contact);
        const auto indexB = GetChildIndexB(contact);
        const auto bodyA = GetBodyA(contact);
        const auto bodyB = GetBodyB(contact);
        const auto radiusA = GetVertexRadius(shapeBuffer[to_underlying(shapeA)], indexA);
        const auto radiusB = GetVertexRadius(shapeBuffer[to_underlying(shapeB)], indexB);
        const auto& manifold = manifoldBuffer[to_underlying(contactID)];
        return PositionConstraint{manifold, bodyA, bodyB, radiusA + radiusB};
    });
    return constraints;
}

/// @brief Gets the velocity constraints for the given inputs.
/// @details Inializes the velocity constraints with the position dependent portions of
///   the current position constraints.
/// @post Velocity constraints will have their "normal" field set to the world manifold
///   normal for them.
/// @post Velocity constraints will have their constraint points set.
/// @see SolveVelocityConstraints.
VelocityConstraints GetVelocityConstraints(pmr::memory_resource& resource,
                                           const Span<const ContactID>& contacts,
                                           const ObjectPool<Contact>& contactBuffer,
                                           const ObjectPool<Manifold>& manifoldBuffer,
                                           const ObjectPool<Shape>& shapeBuffer,
                                           const Span<const BodyConstraint>& bodies,
                                           const VelocityConstraint::Conf conf)
{
    auto velConstraints = VelocityConstraints{&resource};
    velConstraints.reserve(size(contacts));
    transform(cbegin(contacts), cend(contacts), back_inserter(velConstraints),
              [&](const auto& contactID) {
        const auto& contact = contactBuffer[to_underlying(contactID)];
        const auto bodyA = GetBodyA(contact);
        const auto bodyB = GetBodyB(contact);
        const auto shapeIdA = GetShapeA(contact);
        const auto shapeIdB = GetShapeB(contact);
        const auto indexA = GetChildIndexA(contact);
        const auto indexB = GetChildIndexB(contact);
        const auto friction = GetFriction(contact);
        const auto restitution = GetRestitution(contact);
        const auto tangentSpeed = GetTangentSpeed(contact);
        const auto& bodyConstraintA = bodies[to_underlying(bodyA)];
        const auto& bodyConstraintB = bodies[to_underlying(bodyB)];
        const auto radiusA = GetVertexRadius(shapeBuffer[to_underlying(shapeIdA)], indexA);
        const auto radiusB = GetVertexRadius(shapeBuffer[to_underlying(shapeIdB)], indexB);
        const auto xfA = GetTransformation(bodyConstraintA.GetPosition(),
                                           bodyConstraintA.GetLocalCenter());
        const auto xfB = GetTransformation(bodyConstraintB.GetPosition(),
                                           bodyConstraintB.GetLocalCenter());
        const auto& manifold = manifoldBuffer[to_underlying(contactID)];
        return VelocityConstraint{friction, restitution, tangentSpeed,
            GetWorldManifold(manifold, xfA, radiusA, xfB, radiusB),
            bodyA, bodyB, bodies, conf};
    });
    return velConstraints;
}

/// "Solves" the velocity constraints.
/// @details Updates the velocities and velocity constraint points' normal and tangent impulses.
/// @pre <code>UpdateVelocityConstraints</code> has been called on the velocity constraints.
/// @return Maximum momentum used for solving both the tangential and normal portions of
///   the velocity constraints.
Momentum SolveVelocityConstraintsViaGS(const Span<VelocityConstraint>& velConstraints,
                                       const Span<BodyConstraint>& bodies)
{
    auto maxIncImpulse = 0_Ns;
    for_each(begin(velConstraints), end(velConstraints), [&](VelocityConstraint& vc) {
        maxIncImpulse = std::max(maxIncImpulse, GaussSeidel::SolveVelocityConstraint(vc, bodies));
    });
    return maxIncImpulse;
}

/// Solves the given position constraints.
/// @details This updates positions (and nothing else) by calling the position constraint solving function.
/// @note Can't expect the returned minimum separation to be greater than or equal to
///  <code>-conf.linearSlop</code> because code won't push the separation above this
///   amount to begin with.
/// @return Minimum separation.
Length SolvePositionConstraintsViaGS(const Span<const PositionConstraint>& posConstraints,
                                     const Span<BodyConstraint>& bodies,
                                     const ConstraintSolverConf& conf)
{
    auto minSeparation = std::numeric_limits<Length>::infinity();
    for_each(begin(posConstraints), end(posConstraints), [&](const PositionConstraint &pc) {
        assert(pc.bodyA != pc.bodyB); // Confirms ContactManager::Add() did its job.
        const auto res = GaussSeidel::SolvePositionConstraint(pc, true, true, bodies, conf);
        bodies[to_underlying(pc.bodyA)].SetPosition(res.pos_a);
        bodies[to_underlying(pc.bodyB)].SetPosition(res.pos_b);
        minSeparation = std::min(minSeparation, res.min_separation);
    });
    return minSeparation;
}

inline Time GetUnderActiveTime(const Body& b, const StepConf& conf) noexcept
{
    const auto underactive = IsUnderActive(GetVelocity(b), conf.linearSleepTolerance,
                                           conf.angularSleepTolerance);
    const auto sleepable = IsSleepingAllowed(b);
    return (sleepable && underactive)? GetUnderActiveTime(b) + conf.deltaTime: 0_s;
}

inline Time UpdateUnderActiveTimes(const Span<const BodyID>& bodies,
                                   ObjectPool<Body>& bodyBuffer,
                                   const StepConf& conf)
{
    auto minUnderActiveTime = std::numeric_limits<Time>::infinity();
    for_each(cbegin(bodies), cend(bodies), [&](const auto& bodyID) {
        auto& b = bodyBuffer[to_underlying(bodyID)];
        if (IsSpeedable(b)) {
            const auto underActiveTime = GetUnderActiveTime(b, conf);
            b.SetUnderActiveTime(underActiveTime);
            minUnderActiveTime = std::min(minUnderActiveTime, underActiveTime);
        }
    });
    return minUnderActiveTime;
}

inline BodyCounter Sleepem(const Span<const BodyID>& bodies,
                           ObjectPool<Body>& bodyBuffer)
{
    auto unawoken = BodyCounter{0};
    for_each(cbegin(bodies), cend(bodies), [&](const auto& bodyID) {
        if (Unawaken(bodyBuffer[to_underlying(bodyID)])) {
            ++unawoken;
        }
    });
    return unawoken;
}

inline bool IsValidForTime(ToiOutput::State state) noexcept
{
    return state == ToiOutput::e_touching;
}

bool FlagForFiltering(ObjectPool<Contact>& contactBuffer, BodyID bodyA,
                      const Span<const std::tuple<ContactKey, ContactID>>& contactsBodyB,
                      BodyID bodyB) noexcept
{
    auto anyFlagged = false;
    for (const auto& ci: contactsBodyB) {
        auto& contact = contactBuffer[to_underlying(std::get<ContactID>(ci))];
        if (GetOtherBody(contact, bodyB) == bodyA) {
            // Flag the contact for filtering at the next time step (where either
            // body is awake).
            contact.FlagForFiltering();
            anyFlagged = true;
        }
    }
    return anyFlagged;
}

/// @brief Gets the update configuration from the given step configuration data.
AabbTreeWorld::ContactUpdateConf GetUpdateConf(const StepConf& conf) noexcept
{
    return AabbTreeWorld::ContactUpdateConf{GetDistanceConf(conf), GetManifoldConf(conf)};
}

template <typename T>
void FlagForUpdating(ObjectPool<Contact>& contactsBuffer, const T& contacts) noexcept
{
    std::for_each(begin(contacts), end(contacts), [&](const auto& ci) {
        contactsBuffer[to_underlying(std::get<ContactID>(ci))].FlagForUpdating();
    });
}

[[maybe_unused]] auto NeedsUpdating(const Span<const Contact>& contacts) noexcept -> bool
{
    return std::any_of(begin(contacts), end(contacts), [](const Contact &contact){
        return contact.NeedsUpdating();
    });
}

inline bool EitherIsAccelerable(const Body& lhs, const Body& rhs) noexcept
{
    return IsAccelerable(lhs) || IsAccelerable(rhs);
}

bool ShouldCollide(const ObjectPool<Joint>& jointBuffer,
                   const ObjectPool<BodyJointIDs>& bodyJoints,
                   BodyID lhs, BodyID rhs)
{
    // Does a joint prevent collision?
    const auto& joints = bodyJoints[to_underlying(lhs)];
    const auto it = std::find_if(cbegin(joints), cend(joints), [&](const auto& ji) {
        return (std::get<BodyID>(ji) == rhs) &&
        !GetCollideConnected(jointBuffer[to_underlying(std::get<JointID>(ji))]);
    });
    return it == end(joints);
}

void Unset(std::vector<bool>& islanded, const Span<const BodyID>& elements)
{
    for (const auto& element: elements) {
        islanded[to_underlying(element)] = false;
    }
}

void Unset(std::vector<bool>& islanded, const Span<const std::pair<ContactKey, ContactID>>& elements)
{
    for (const auto& element: elements) {
        islanded[to_underlying(std::get<ContactID>(element))] = false;
    }
}

void Unset(std::vector<bool>& islanded, const Span<const std::tuple<ContactKey, ContactID>>& elements)
{
    for (const auto& element: elements) {
        islanded[to_underlying(std::get<ContactID>(element))] = false;
    }
}

/// @brief Reset bodies for solve TOI.
void ResetBodiesForSolveTOI(BodyIDs& bodies, ObjectPool<Body>& buffer) noexcept
{
    for_each(begin(bodies), end(bodies), [&](const auto& body) {
        buffer[to_underlying(body)].ResetAlpha0();
    });
}

/// @brief Reset contacts for solve TOI.
void ResetBodyContactsForSolveTOI(ObjectPool<Contact>& buffer,
                                  const Span<const std::tuple<ContactKey, ContactID>>& contacts) noexcept
{
    // Invalidate all contact TOIs on this displaced body.
    for_each(cbegin(contacts), cend(contacts), [&buffer](const auto& ci) {
        SetToi(buffer[to_underlying(std::get<ContactID>(ci))], {});
    });
}

/// @brief Reset contacts for solve TOI.
void ResetContactsForSolveTOI(ObjectPool<Contact>& buffer,
                              const KeyedContactIDs& contacts) noexcept
{
    for_each(begin(contacts), end(contacts), [&buffer](const auto& c) {
        auto& contact = buffer[to_underlying(std::get<ContactID>(c))];
        SetToi(contact, {});
        SetToiCount(contact, 0);
    });
}

/// @brief Destroys proxies of all tree nodes with the given body and shape identifiers.
void DestroyProxies(DynamicTree& tree, BodyID bodyId, ShapeID shapeId, ProxyIDs& proxies) noexcept
{
    const auto n = tree.GetNodeCapacity();
    for (auto i = DynamicTree::Size(0); i < n; ++i) {
        if (DynamicTree::IsLeaf(tree.GetHeight(i))) {
            const auto leaf = tree.GetLeafData(i);
            if ((leaf.bodyId == bodyId) && (leaf.shapeId == shapeId)) {
                EraseFirst(proxies, i);
                tree.DestroyLeaf(i);
            }
        }
    }
}

auto CreateProxies(DynamicTree& tree,
                   BodyID bodyID, ShapeID shapeID, const Shape& shape,
                   const Transformation& xfm0, const Transformation& xfm1,
                   const StepConf& conf,
                   ProxyIDs& fixtureProxies,
                   ProxyIDs& otherProxies) -> ChildCounter
{
    // Reserve proxy space and create proxies in the broad-phase.
    const auto childCount = GetChildCount(shape);
    fixtureProxies.reserve(size(fixtureProxies) + childCount);
    otherProxies.reserve(size(otherProxies) + childCount);
    const auto displacement = conf.displaceMultiplier * (xfm1.p - xfm0.p);
    for (auto childID = decltype(childCount){0}; childID < childCount; ++childID) {
        const auto dp = GetChild(shape, childID);
        const auto baseAABB = ComputeAABB(dp, xfm0, xfm1);
        const auto fattenedAABB = GetFattenedAABB(baseAABB, conf.aabbExtension);
        const auto displacedAABB = GetDisplacedAABB(fattenedAABB, displacement);
        const auto treeID = tree.CreateLeaf(displacedAABB, Contactable{bodyID, shapeID, childID});
        fixtureProxies.push_back(treeID);
        otherProxies.push_back(treeID);
    }
    return childCount;
}

template <typename Element, typename Value>
auto FindTypeValue(const std::vector<Element>& container, const Value& value)
{
    const auto last = end(container);
    auto it = std::find_if(begin(container), last, [value](const auto& elem) {
        return std::get<Value>(elem) == value;
    });
    return (it != last)? std::optional<decltype(it)>{it}: std::optional<decltype(it)>{};
}

template <class C, class V>
auto Find(const C& c, const V& value) -> decltype(find(begin(c), end(c), value), bool{})
{
    const auto last = end(c);
    return find(begin(c), last, value) != last;
}

void Erase(BodyContactIDs& contacts, const std::function<bool(ContactID)>& callback)
{
    auto last = end(contacts);
    auto iter = begin(contacts);
    auto index = KeyedContactIDs::difference_type(0);
    while (iter != last) {
        const auto contact = std::get<ContactID>(*iter);
        if (callback(contact)) {
            contacts.erase(iter);
            iter = begin(contacts) + index;
            last = end(contacts);
        }
        else {
            iter = std::next(iter);
            ++index;
        }
    }
}

ProxyIDs FindProxies(const DynamicTree& tree, BodyID bodyId)
{
    ProxyIDs result;
    const auto n = tree.GetNodeCapacity();
    for (auto i = static_cast<decltype(tree.GetNodeCapacity())>(0); i < n; ++i) {
        if (DynamicTree::IsLeaf(tree.GetHeight(i))) {
            const auto leaf = tree.GetLeafData(i);
            if (leaf.bodyId == bodyId) {
                result.push_back(i);
            }
        }
    }
    return result;
}

template <class Function>
auto ForMatchingProxies(const DynamicTree& tree, ShapeID shapeId, Function f)
-> decltype(f(DynamicTree::Size{}), std::declval<void>())
{
    const auto n = tree.GetNodeCapacity();
    for (auto i = static_cast<decltype(tree.GetNodeCapacity())>(0); i < n; ++i) {
        if (DynamicTree::IsLeaf(tree.GetHeight(i))) {
            if (tree.GetLeafData(i).shapeId == shapeId) {
                f(i);
            }
        }
    }
}

std::pair<std::vector<ShapeID>, std::vector<ShapeID>>
GetOldAndNewShapeIDs(const Body& oldBody, const Body& newBody)
{
    if (IsEnabled(oldBody) && IsEnabled(newBody)) {
        auto oldShapeIds = std::vector<ShapeID>{};
        auto newShapeIds = std::vector<ShapeID>{};
        auto oldmap = std::map<ShapeID, int>{};
        auto newmap = std::map<ShapeID, int>{};
        for (auto&& i: oldBody.GetShapes()) {
            ++oldmap[i];
            --newmap[i];
        }
        for (auto&& i: newBody.GetShapes()) {
            --oldmap[i];
            ++newmap[i];
        }
        for (auto&& entry: oldmap) {
            for (auto i = 0; i < entry.second; ++i) {
                oldShapeIds.push_back(entry.first);
            }
        }
        for (auto&& entry: newmap) {
            for (auto i = 0; i < entry.second; ++i) {
                newShapeIds.push_back(entry.first);
            }
        }
        return {oldShapeIds, newShapeIds};
    }
    if (IsEnabled(newBody)) {
        return {std::vector<ShapeID>{}, newBody.GetShapes()};
    }
    if (IsEnabled(oldBody)) {
        return {oldBody.GetShapes(), std::vector<ShapeID>{}};
    }
    return {};
}

template <class T, class U>
void ResizeAndReset(std::vector<T>& vector, typename std::vector<T>::size_type newSize, const U& newValue)
{
    std::fill(begin(vector),
              begin(vector) + ToSigned(std::min(size(vector), newSize)),
              newValue);
    vector.resize(newSize);
}

/// @brief Removes <em>unspeedables</em> from the is <em>is-in-island</em> state.
BodyIDs::size_type
RemoveUnspeedablesFromIslanded(const Span<const BodyID>& bodies,
                               const ObjectPool<Body>& buffer,
                               std::vector<bool>& islanded)
{
    // Allow static bodies to participate in other islands.
    auto numRemoved = BodyIDs::size_type{0};
    for_each(begin(bodies), end(bodies), [&](BodyID id) {
        if (!IsSpeedable(buffer[to_underlying(id)])) {
            islanded[to_underlying(id)] = false;
            ++numRemoved;
        }
    });
    return numRemoved;
}

auto FindContacts(pmr::memory_resource& resource,
                  const DynamicTree& tree,
                  const ProxyIDs& proxies)
    -> std::vector<AabbTreeWorld::ProxyKey, pmr::polymorphic_allocator<AabbTreeWorld::ProxyKey>>
{
    std::vector<AabbTreeWorld::ProxyKey, pmr::polymorphic_allocator<AabbTreeWorld::ProxyKey>>
        proxyKeys{&resource};
    // Never need more than tree.GetLeafCount(), but in case big, use smaller default...
    static constexpr auto DefaultReserveSize = 256u;
    proxyKeys.reserve(std::min(tree.GetLeafCount(), DefaultReserveSize));

    // Accumalate contact keys for pairs of nodes that are overlapping and aren't identical.
    // Note that if the dynamic tree node provides the body index, it's assumed to be faster
    // to eliminate any node pairs that have the same body here before the key pairs are
    // sorted.
    for_each(cbegin(proxies), cend(proxies), [&](DynamicTree::Size pid) {
        const auto &node = tree.GetNode(pid);
        const auto aabb = node.GetAABB();
        const auto leaf0 = node.AsLeaf();
        Query(tree, aabb, [pid,leaf0,&proxyKeys,&tree](DynamicTree::Size nodeId) {
            const auto leaf1 = tree.GetLeafData(nodeId);
            // A proxy cannot form a pair with itself.
            if ((nodeId != pid) && (leaf0.bodyId != leaf1.bodyId)) {
                const auto key = ContactKey{pid, nodeId};
                if (key.GetMin() == pid) {
                    proxyKeys.emplace_back(key, leaf0, leaf1);
                }
                else {
                    proxyKeys.emplace_back(key, leaf1, leaf0);
                }
            }
            return DynamicTreeOpcode::Continue;
        });
    });

    // Sort and eliminate any duplicate contact keys.
    sort(begin(proxyKeys), end(proxyKeys),
         [](const AabbTreeWorld::ProxyKey& a, const AabbTreeWorld::ProxyKey& b) {
        return std::get<0>(a) < std::get<0>(b);
    });
    proxyKeys.erase(unique(begin(proxyKeys), end(proxyKeys)), end(proxyKeys));
    return proxyKeys;
}

auto GetBodyStackOpts(const WorldConf& conf) -> pmr::PoolMemoryOptions
{
    return {conf.reserveBuffers, conf.reserveBodyStack * sizeof(BodyID)};
}

auto GetBodyConstraintOpts(const WorldConf& conf) -> pmr::PoolMemoryOptions
{
    return {conf.reserveBuffers, conf.reserveBodyConstraints * sizeof(BodyConstraint)};
}

auto GetPositionConstraintsOpts(const WorldConf& conf) -> pmr::PoolMemoryOptions
{
    return {conf.reserveBuffers, conf.reserveDistanceConstraints * sizeof(PositionConstraint)};
}

auto GetVelocityConstraintsOpts(const WorldConf& conf) -> pmr::PoolMemoryOptions
{
    return {conf.reserveBuffers, conf.reserveDistanceConstraints * sizeof(VelocityConstraint)};
}

auto GetProxyKeysOpts(const WorldConf& conf) -> pmr::PoolMemoryOptions
{
    return {conf.reserveBuffers, conf.reserveContactKeys * sizeof(AabbTreeWorld::ProxyKey)};
}

auto IsGeomChanged(const Shape& shape0, const Shape& shape1) -> bool
{
    const auto numKids0 = GetChildCount(shape0);
    const auto numKids1 = GetChildCount(shape1);
    if (numKids0 != numKids1) {
        return true;
    }
    for (auto child = 0u; child < numKids1; ++child) {
        const auto distanceProxy0 = GetChild(shape0, child);
        const auto distanceProxy1 = GetChild(shape1, child);
        if (distanceProxy0 != distanceProxy1) {
            return true;
        }
    }
    return false;
}

auto Append(std::vector<std::pair<BodyID, ShapeID>>& fixtures,
            BodyID bodyId, Span<const ShapeID> shapeIds) -> void
{
    for (const auto shapeId: shapeIds) {
        fixtures.emplace_back(bodyId, shapeId);
    }
}

template <class Container, class ElementType, class Message>
auto Validate(const Container& container, const Span<const ElementType>& ids, Message &&msg)
-> decltype(container.at(to_underlying(ElementType{})), std::declval<void>())
{
    for (const auto& id: ids) {
        At(container, id, std::forward<Message>(msg));
    }
}

auto SetAwake(ObjectPool<Body>& bodies, const Contact& c) -> void
{
    SetAwake(bodies[to_underlying(GetBodyA(c))]);
    SetAwake(bodies[to_underlying(GetBodyB(c))]);
}

} // anonymous namespace

AabbTreeWorld::AabbTreeWorld(const WorldConf& conf):
    m_statsResource(conf.doStats? conf.upstream: nullptr),
    m_bodyStackResource(GetBodyStackOpts(conf),
                        conf.doStats? &m_statsResource: conf.upstream),
    m_bodyConstraintsResource(GetBodyConstraintOpts(conf),
                              conf.doStats? &m_statsResource: conf.upstream),
    m_positionConstraintsResource(GetPositionConstraintsOpts(conf),
                                  conf.doStats? &m_statsResource: conf.upstream),
    m_velocityConstraintsResource(GetVelocityConstraintsOpts(conf),
                                  conf.doStats? &m_statsResource: conf.upstream),
    m_proxyKeysResource(GetProxyKeysOpts(conf), conf.doStats? &m_statsResource: conf.upstream),
    m_islandResource({conf.reserveBuffers}, conf.doStats? &m_statsResource: conf.upstream),
    m_tree(conf.treeCapacity),
    m_vertexRadius{conf.vertexRadius}
{
    m_proxiesForContacts.reserve(conf.proxyCapacity);
    m_contactBuffer.reserve(conf.contactCapacity);
    m_manifoldBuffer.reserve(conf.contactCapacity);
    m_contacts.reserve(conf.contactCapacity);
    m_islanded.contacts.reserve(conf.contactCapacity);
}

AabbTreeWorld::AabbTreeWorld(const AabbTreeWorld& other):
    m_statsResource(other.m_statsResource.upstream_resource()),
    m_bodyConstraintsResource(other.m_bodyConstraintsResource.GetOptions(),
                              other.m_statsResource.upstream_resource()?
                              &m_statsResource: other.m_bodyConstraintsResource.GetUpstream()),
    m_positionConstraintsResource(other.m_positionConstraintsResource.GetOptions(),
                                  other.m_statsResource.upstream_resource()?
                                  &m_statsResource: other.m_positionConstraintsResource.GetUpstream()),
    m_velocityConstraintsResource(other.m_velocityConstraintsResource.GetOptions(),
                                  other.m_statsResource.upstream_resource()?
                                  &m_statsResource: other.m_velocityConstraintsResource.GetUpstream()),
    m_proxyKeysResource(other.m_proxyKeysResource.GetOptions(),
                        other.m_statsResource.upstream_resource()?
                        &m_statsResource: other.m_proxyKeysResource.GetUpstream()),
    m_islandResource(other.m_islandResource.GetOptions(),
                     other.m_statsResource.upstream_resource()?
                     &m_statsResource: other.m_islandResource.GetUpstream()),
    m_tree(other.m_tree),
    m_bodyBuffer(other.m_bodyBuffer),
    m_shapeBuffer(other.m_shapeBuffer),
    m_jointBuffer(other.m_jointBuffer),
    m_contactBuffer(other.m_contactBuffer),
    m_manifoldBuffer(other.m_manifoldBuffer),
    m_bodyContacts(other.m_bodyContacts),
    m_bodyJoints(other.m_bodyJoints),
    m_bodyProxies(other.m_bodyProxies),
    m_proxiesForContacts(other.m_proxiesForContacts),
    m_fixturesForProxies(other.m_fixturesForProxies),
    m_bodiesForSync(other.m_bodiesForSync),
    m_bodies(other.m_bodies),
    m_joints(other.m_joints),
    m_contacts(other.m_contacts),
    m_islanded(other.m_islanded),
    m_listeners(other.m_listeners),
    m_flags(other.m_flags),
    m_inv_dt0(other.m_inv_dt0),
    m_vertexRadius(other.m_vertexRadius)
{
}

AabbTreeWorld::AabbTreeWorld(AabbTreeWorld&& other) noexcept:
    m_statsResource(other.m_statsResource.upstream_resource()),
    m_bodyConstraintsResource(other.m_bodyConstraintsResource.GetOptions(),
                              other.m_statsResource.upstream_resource()?
                              &m_statsResource: other.m_bodyConstraintsResource.GetUpstream()),
    m_positionConstraintsResource(other.m_positionConstraintsResource.GetOptions(),
                                  other.m_statsResource.upstream_resource()?
                                  &m_statsResource: other.m_positionConstraintsResource.GetUpstream()),
    m_velocityConstraintsResource(other.m_velocityConstraintsResource.GetOptions(),
                                  other.m_statsResource.upstream_resource()?
                                  &m_statsResource: other.m_velocityConstraintsResource.GetUpstream()),
    m_proxyKeysResource(other.m_proxyKeysResource.GetOptions(),
                        other.m_statsResource.upstream_resource()?
                        &m_statsResource: other.m_proxyKeysResource.GetUpstream()),
    m_islandResource(other.m_islandResource.GetOptions(),
                     other.m_statsResource.upstream_resource()?
                     &m_statsResource: other.m_islandResource.GetUpstream()),
    m_tree(std::move(other.m_tree)),
    m_bodyBuffer(std::move(other.m_bodyBuffer)),
    m_shapeBuffer(std::move(other.m_shapeBuffer)),
    m_jointBuffer(std::move(other.m_jointBuffer)),
    m_contactBuffer(std::move(other.m_contactBuffer)),
    m_manifoldBuffer(std::move(other.m_manifoldBuffer)),
    m_bodyContacts(std::move(other.m_bodyContacts)),
    m_bodyJoints(std::move(other.m_bodyJoints)),
    m_bodyProxies(std::move(other.m_bodyProxies)),
    m_proxiesForContacts(std::move(other.m_proxiesForContacts)),
    m_fixturesForProxies(std::move(other.m_fixturesForProxies)),
    m_bodiesForSync(std::move(other.m_bodiesForSync)),
    m_bodies(std::move(other.m_bodies)),
    m_joints(std::move(other.m_joints)),
    m_contacts(std::move(other.m_contacts)),
    m_islanded(std::move(other.m_islanded)),
    m_listeners(std::move(other.m_listeners)),
    m_flags(other.m_flags),
    m_inv_dt0(other.m_inv_dt0),
    m_vertexRadius(other.m_vertexRadius)
{
}

AabbTreeWorld::~AabbTreeWorld() noexcept
{
    Clear(*this);
}

auto operator==(const AabbTreeWorld& lhs, const AabbTreeWorld& rhs) -> bool
{
    // Note: the following member variables are non-essential parts:
    //   m_listeners, m_inv_dt0, m_islanded, m_bodyContacts, m_tree.
    // Note: the following member variables cannot be compared by themselves:
    //   m_contactBuffer, m_contacts, m_manifoldBuffer.
    return // newline!
        (lhs.m_bodyBuffer == rhs.m_bodyBuffer) && // newline!
        (lhs.m_shapeBuffer == rhs.m_shapeBuffer) && // newline!
        (lhs.m_jointBuffer == rhs.m_jointBuffer) && // newline!
        (lhs.m_bodyJoints == rhs.m_bodyJoints) && // newline!
        (lhs.m_bodyProxies == rhs.m_bodyProxies) && // newline!
        (lhs.m_proxiesForContacts == rhs.m_proxiesForContacts) && // newline!
        (lhs.m_fixturesForProxies == rhs.m_fixturesForProxies) && // newline!
        (lhs.m_bodiesForSync == rhs.m_bodiesForSync) && // newline!
        (lhs.m_bodies == rhs.m_bodies) && // newline!
        (lhs.m_joints == rhs.m_joints) && // newline!
        (lhs.m_flags == rhs.m_flags) && // newline!
        (lhs.m_vertexRadius == rhs.m_vertexRadius) && // newline
        SameTouching(World{lhs}, World{rhs});
}

bool operator!=(const AabbTreeWorld& lhs, const AabbTreeWorld& rhs)
{
    return !(lhs == rhs);
}

void Clear(AabbTreeWorld& world) noexcept
{
    if (const auto listener = world.m_listeners.jointDestruction) {
        for_each(cbegin(world.m_joints), cend(world.m_joints), [&listener](const auto& id) {
            try {
                listener(id);
            }
            catch (...) // NOLINT(bugprone-empty-catch)
            {
                // Don't allow exception to escape.
            }
        });
    }
    if (const auto listener = world.m_listeners.shapeDestruction) {
        for (auto&& shape: world.m_shapeBuffer) {
            if (shape != Shape{}) {
                using underlying_type = ::playrho::underlying_type_t<ShapeID>;
                const auto index = &shape - world.m_shapeBuffer.data();
                try {
                    listener(static_cast<ShapeID>(static_cast<underlying_type>(index)));
                }
                catch (...) // NOLINT(bugprone-empty-catch)
                {
                    // Don't allow exception to escape.
                }
            }
        }
    }
    world.m_inv_dt0 = 0_Hz;
    world.m_flags = AabbTreeWorld::e_stepComplete;
    world.m_islanded.bodies.clear();
    world.m_islanded.joints.clear();
    world.m_islanded.contacts.clear();
    world.m_contacts.clear();
    world.m_joints.clear();
    world.m_bodies.clear();
    world.m_bodiesForSync.clear();
    world.m_fixturesForProxies.clear();
    world.m_proxiesForContacts.clear();
    world.m_tree.Clear();
    world.m_manifoldBuffer.clear();
    world.m_contactBuffer.clear();
    world.m_jointBuffer.clear();
    world.m_bodyBuffer.clear();
    world.m_shapeBuffer.clear();
    world.m_bodyProxies.clear();
    world.m_bodyContacts.clear();
    world.m_bodyJoints.clear();
}

BodyCounter GetBodyRange(const AabbTreeWorld& world) noexcept
{
    return static_cast<BodyCounter>(world.m_bodyBuffer.size());
}

JointCounter GetJointRange(const AabbTreeWorld& world) noexcept
{
    return static_cast<JointCounter>(world.m_jointBuffer.size());
}

ContactCounter GetContactRange(const AabbTreeWorld& world) noexcept
{
    return static_cast<ContactCounter>(world.m_contactBuffer.size());
}

BodyID CreateBody(AabbTreeWorld& world, Body body)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }
    if (size(world.m_bodies) >= MaxBodies) {
        throw LengthError("CreateBody: operation would exceed MaxBodies");
    }
    Validate(world.m_shapeBuffer, Span<const ShapeID>(body.GetShapes()), noSuchShapeMsg);
    const auto id = static_cast<BodyID>(
        static_cast<BodyID::underlying_type>(world.m_bodyBuffer.Allocate(std::move(body))));
    world.m_islanded.bodies.resize(size(world.m_bodyBuffer));
    const auto bodyContactsIndex = world.m_bodyContacts.Allocate();
    static constexpr auto DefaultBodyContactsReserveSize = 32u;
    world.m_bodyContacts[bodyContactsIndex].reserve(DefaultBodyContactsReserveSize);
    world.m_bodyJoints.Allocate();
    const auto bodyProxiesIndex = world.m_bodyProxies.Allocate();
    world.m_bodyProxies[bodyProxiesIndex].reserve(1u);
    world.m_bodies.push_back(id);
    auto &bufferedBody = world.m_bodyBuffer[to_underlying(id)];
    bufferedBody.UnsetDestroyed();
    if (IsEnabled(bufferedBody)) {
        Append(world.m_fixturesForProxies, id, bufferedBody.GetShapes());
    }
    return id;
}

void AabbTreeWorld::Remove(BodyID id)
{
    m_bodiesForSync.erase(remove(begin(m_bodiesForSync), end(m_bodiesForSync), id),
                             end(m_bodiesForSync));
    const auto it = find(cbegin(m_bodies), cend(m_bodies), id);
    if (it != cend(m_bodies)) {
        // Remove in reverse order from add/allocate.
        m_bodies.erase(it);
        m_bodyProxies.Free(to_underlying(id));
        m_bodyJoints.Free(to_underlying(id));
        m_bodyContacts.Free(to_underlying(id));
        m_bodyBuffer.Free(to_underlying(id)).SetDestroyed();
        m_islanded.bodies.resize(size(m_bodyBuffer));
    }
}

void Destroy(AabbTreeWorld& world, BodyID id)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }

    const auto& body = GetBody(world, id);

    // Delete the attached joints.
    auto& joints = world.m_bodyJoints[to_underlying(id)];
    while (!joints.empty()) {
        const auto jointID = std::get<JointID>(*begin(joints));
        if (world.m_listeners.jointDestruction) {
            world.m_listeners.jointDestruction(jointID);
        }
        const auto endIter = cend(world.m_joints);
        const auto iter = find(cbegin(world.m_joints), endIter, jointID);
        if (iter != endIter) {
            world.Remove(jointID); // removes joint from body!
            world.m_joints.erase(iter);
            world.m_jointBuffer.Free(to_underlying(jointID));
        }
    }

    // Destroy the attached contacts.
    Erase(world.m_bodyContacts[to_underlying(id)], [&world,&body](ContactID contactID) {
        world.Destroy(contactID, &body);
        return true;
    });

    for (auto&& shapeId: body.GetShapes()) {
        EraseAll(world.m_fixturesForProxies, std::make_pair(id, shapeId));
    }

    const auto proxies = FindProxies(world.m_tree, id);
    for (const auto& proxy: proxies) {
        world.m_tree.DestroyLeaf(proxy);
    }
    if (world.m_listeners.detach) {
        for (const auto& shapeId: body.GetShapes()) {
            world.m_listeners.detach(std::make_pair(id, shapeId));
        }
    }
    world.Remove(id);
}

void SetJoint(AabbTreeWorld& world, JointID id, Joint def)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }
    // Validate the references...
    auto &joint = At(world.m_jointBuffer, id, noSuchJointMsg);
    if (!joint.has_value()) {
        throw WasDestroyed{id, idIsDestroyedMsg};
    }
    if (const auto bodyId = GetBodyA(def); bodyId != InvalidBodyID) {
        GetBody(world, bodyId);
    }
    if (const auto bodyId = GetBodyB(def); bodyId != InvalidBodyID) {
        GetBody(world, bodyId);
    }
    if (!def.has_value()) {
        throw WasDestroyed{def, cannotBeEmptyMsg};
    }
    world.Remove(id);
    joint = std::move(def);
    world.Add(id, !GetCollideConnected(joint));
}

JointID CreateJoint(AabbTreeWorld& world, Joint def)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }
    if (size(world.m_joints) >= MaxJoints) {
        throw LengthError("CreateJoint: operation would exceed MaxJoints");
    }
    if (!def.has_value()) {
        throw WasDestroyed{def, cannotBeEmptyMsg};
    }
    // Validate the referenced bodies...
    if (const auto bodyId = GetBodyA(def); bodyId != InvalidBodyID) {
        GetBody(world, bodyId);
    }
    if (const auto bodyId = GetBodyB(def); bodyId != InvalidBodyID) {
        GetBody(world, bodyId);
    }
    const auto id = static_cast<JointID>(
        static_cast<JointID::underlying_type>(world.m_jointBuffer.Allocate(std::move(def))));
    world.m_islanded.joints.resize(size(world.m_jointBuffer));
    world.m_joints.push_back(id);
    // Note: creating a joint doesn't wake the bodies.
    world.Add(id, !GetCollideConnected(world.m_jointBuffer[to_underlying(id)]));
    return id;
}

void AabbTreeWorld::Add(JointID id, bool flagForFiltering)
{
    const auto& joint = m_jointBuffer[to_underlying(id)];
    const auto bodyA = GetBodyA(joint);
    const auto bodyB = GetBodyB(joint);
    if (bodyA != InvalidBodyID) {
        m_bodyJoints[to_underlying(bodyA)].emplace_back(bodyB, id);
    }
    if (bodyB != InvalidBodyID) {
        m_bodyJoints[to_underlying(bodyB)].emplace_back(bodyA, id);
    }
    if (flagForFiltering && (bodyA != InvalidBodyID) && (bodyB != InvalidBodyID)) {
        if (FlagForFiltering(m_contactBuffer, bodyA, m_bodyContacts[to_underlying(bodyB)], bodyB)) {
            m_flags |= e_needsContactFiltering;
        }
    }
}

void AabbTreeWorld::Remove(JointID id)
{
    // Disconnect from island graph.
    const auto& joint = m_jointBuffer[to_underlying(id)];
    const auto bodyIdA = GetBodyA(joint);
    const auto bodyIdB = GetBodyB(joint);
    const auto collideConnected = GetCollideConnected(joint);

    // If the joint prevented collisions, then flag any contacts for filtering.
    if ((!collideConnected) && (bodyIdA != InvalidBodyID) && (bodyIdB != InvalidBodyID)) {
        if (FlagForFiltering(m_contactBuffer, bodyIdA, m_bodyContacts[to_underlying(bodyIdB)], bodyIdB)) {
            m_flags |= e_needsContactFiltering;
        }
    }

    // Wake up connected bodies.
    if (bodyIdA != InvalidBodyID) {
        auto& bodyA = m_bodyBuffer[to_underlying(bodyIdA)];
        SetAwake(bodyA);
        auto& bodyJoints = m_bodyJoints[to_underlying(bodyIdA)];
        const auto found = FindTypeValue(bodyJoints, id);
        assert(found);
        if (found) {
            bodyJoints.erase(*found);
        }
    }
    if (bodyIdB != InvalidBodyID) {
        auto& bodyB = m_bodyBuffer[to_underlying(bodyIdB)];
        SetAwake(bodyB);
        auto& bodyJoints = m_bodyJoints[to_underlying(bodyIdB)];
        const auto found = FindTypeValue(bodyJoints, id);
        assert(found);
        if (found) {
            bodyJoints.erase(*found);
        }
    }
}

void Destroy(AabbTreeWorld& world, JointID id)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }
    const auto endIter = cend(world.m_joints);
    const auto iter = find(cbegin(world.m_joints), endIter, id);
    if (iter != endIter) {
        world.Remove(id);
        world.m_joints.erase(iter);
        world.m_jointBuffer.Free(to_underlying(id));
    }
}

ShapeCounter GetShapeRange(const AabbTreeWorld& world) noexcept
{
    return static_cast<ShapeCounter>(size(world.m_shapeBuffer));
}

ShapeID CreateShape(AabbTreeWorld& world, Shape def)
{
    if (!def.has_value()) {
        throw WasDestroyed{def, cannotBeEmptyMsg};
    }
    const auto vertexRadius = GetVertexRadiusInterval(world);
    const auto childCount = GetChildCount(def);
    for (auto i = ChildCounter{0}; i < childCount; ++i) {
        const auto vr = GetVertexRadius(def, i);
        if (!(vr >= vertexRadius.GetMin())) {
            throw InvalidArgument("CreateShape: vertex radius < min");
        }
        if (!(vr <= vertexRadius.GetMax())) {
            throw InvalidArgument("CreateShape: vertex radius > max");
        }
    }
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }
    if (size(world.m_shapeBuffer) >= MaxShapes) {
        throw LengthError("CreateShape: operation would exceed MaxShapes");
    }
    return static_cast<ShapeID>(static_cast<ShapeID::underlying_type>(world.m_shapeBuffer.Allocate(std::move(def))));
}

void Destroy(AabbTreeWorld& world, ShapeID id)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }
    At(world.m_shapeBuffer, id, noSuchShapeMsg); // confirm id valid.
    const auto numBodies = GetBodyRange(world);
    for (auto bodyIdx = static_cast<decltype(GetBodyRange(world))>(0); bodyIdx < numBodies; ++bodyIdx) {
        auto body = world.m_bodyBuffer[bodyIdx];
        auto n = std::size_t(0);
        while (body.Detach(id)) {
            ++n;
        }
        if (n) {
            SetBody(world, BodyID(bodyIdx), body);
        }
    }
    world.m_shapeBuffer.Free(to_underlying(id));
}

const Shape& GetShape(const AabbTreeWorld& world, ShapeID id)
{
    return At(world.m_shapeBuffer, id, noSuchShapeMsg);
}

void SetShape(AabbTreeWorld& world, ShapeID id, Shape def) // NOLINT(readability-function-cognitive-complexity)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }
    auto& shape = At(world.m_shapeBuffer, id, noSuchShapeMsg);
    if (!shape.has_value()) {
        throw WasDestroyed{id, idIsDestroyedMsg};
    }
    if (!def.has_value()) {
        throw WasDestroyed{def, cannotBeEmptyMsg};
    }
    const auto geometryChanged = IsGeomChanged(shape, def);
    for (auto&& b: world.m_bodyBuffer) {
        if (!Find(b.GetShapes(), id)) {
            continue;
        }
        SetAwake(b);
        if (geometryChanged && IsEnabled(b)) {
            const auto bodyId = BodyID(static_cast<BodyID::underlying_type>(&b - data(world.m_bodyBuffer)));
            auto& bodyProxies = world.m_bodyProxies[to_underlying(bodyId)];
            const auto lastProxy = end(bodyProxies);
            bodyProxies.erase(std::remove_if(begin(bodyProxies), lastProxy,
                                             [&world,id](DynamicTree::Size idx){
                const auto leafData = world.m_tree.GetLeafData(idx);
                if (leafData.shapeId == id) {
                    world.m_tree.DestroyLeaf(idx);
                    EraseFirst(world.m_proxiesForContacts, idx);
                    return true;
                }
                return false;
            }), lastProxy);
            // Destroy any contacts associated with the fixture.
            Erase(world.m_bodyContacts[to_underlying(bodyId)], [&world,bodyId,id,&b](ContactID contactID) {
                if (!IsFor(world.m_contactBuffer[to_underlying(contactID)], bodyId, id)) {
                    return false;
                }
                world.Destroy(contactID, &b);
                return true;
            });
            const auto fixture = std::make_pair(bodyId, id);
            EraseAll(world.m_fixturesForProxies, fixture);
            DestroyProxies(world.m_tree, bodyId, id, world.m_proxiesForContacts);
            world.m_fixturesForProxies.push_back(fixture);
        }
    }
    if (GetFilter(shape) != GetFilter(def)) {
        auto anyNeedFiltering = false;
        for (auto& c: world.m_contactBuffer) {
            if (IsFor(c, id)) {
                FlagForFiltering(c);
                SetAwake(world.m_bodyBuffer, c);
                anyNeedFiltering = true;
            }
        }
        if (anyNeedFiltering) {
            world.m_flags |= AabbTreeWorld::e_needsContactFiltering;
        }
        ForMatchingProxies(world.m_tree, id, [&](DynamicTreeSize proxyId){
            world.m_proxiesForContacts.push_back(proxyId);
        });
    }
    if ((IsSensor(shape) != IsSensor(def)) || (GetFriction(shape) != GetFriction(def)) ||
        (GetRestitution(shape) != GetRestitution(def)) || geometryChanged) {
        for (auto&& c: world.m_contactBuffer) {
            if (IsFor(c, id)) {
                FlagForUpdating(c);
                SetAwake(world.m_bodyBuffer, c);
            }
        }
    }
    shape = std::move(def);
}

void AabbTreeWorld::AddToIsland(Island& island, BodyID seedID,
                            BodyCounter& remNumBodies,
                            ContactCounter& remNumContacts,
                            JointCounter& remNumJoints)
{
#ifndef NDEBUG
    assert(!m_islanded.bodies[to_underlying(seedID)]);
    auto& seed = m_bodyBuffer[to_underlying(seedID)];
    assert(IsSpeedable(seed));
    assert(IsAwake(seed));
    assert(IsEnabled(seed));
    assert(remNumBodies != 0);
    assert(remNumBodies < MaxBodies);
#endif
    // Perform a depth first search (DFS) on the constraint graph.
    // Create a stack for bodies to be is-in-island that aren't already in the island.
    auto stack = BodyStack{&m_bodyStackResource};
    stack.reserve(remNumBodies);
    stack.push_back(seedID);
    m_islanded.bodies[to_underlying(seedID)] = true;
    AddToIsland(island, stack, remNumBodies, remNumContacts, remNumJoints);
}

void AabbTreeWorld::AddToIsland(Island& island, BodyStack& stack,
                            BodyCounter& remNumBodies,
                            ContactCounter& remNumContacts,
                            JointCounter& remNumJoints)
{
    while (!empty(stack)) {
        // Grab the next body off the stack and add it to the island.
        const auto bodyID = stack.back();
        stack.pop_back();

        auto& body = m_bodyBuffer[to_underlying(bodyID)];

        assert(IsEnabled(body));
        island.bodies.push_back(bodyID);
        assert(remNumBodies > 0);
        --remNumBodies;

        // Don't propagate islands across bodies that can't have a velocity (static bodies).
        // This keeps islands smaller and helps with isolating separable collision clusters.
        if (!IsSpeedable(body)) {
            continue;
        }

        // Make sure the body is awake (without resetting sleep timer).
        body.SetAwakeFlag();

        const auto oldNumContacts = size(island.contacts);
        // Adds appropriate contacts of current body and appropriate 'other' bodies of those contacts.
        AddContactsToIsland(island, stack, m_bodyContacts[to_underlying(bodyID)], bodyID);

        const auto newNumContacts = size(island.contacts);
        assert(newNumContacts >= oldNumContacts);
        const auto netNumContacts = newNumContacts - oldNumContacts;
        assert(remNumContacts >= netNumContacts);
        remNumContacts -= static_cast<ContactCounter>(netNumContacts);

        const auto numJoints = size(island.joints);
        // Adds appropriate joints of current body and appropriate 'other' bodies of those joint.
        AddJointsToIsland(island, stack, m_bodyJoints[to_underlying(bodyID)]);

        remNumJoints -= static_cast<JointCounter>(size(island.joints) - numJoints);
    }
}

void AabbTreeWorld::AddContactsToIsland(Island& island, BodyStack& stack,
                                    const BodyContactIDs& contacts,
                                    BodyID bodyID)
{
    for_each(cbegin(contacts), cend(contacts), [&](const auto& ci) {
        const auto contactID = std::get<ContactID>(ci);
        if (!m_islanded.contacts[to_underlying(contactID)]) {
            const auto& contact = m_contactBuffer[to_underlying(contactID)];
            if (IsEnabled(contact) && IsTouching(contact) && !IsSensor(contact)) {
                const auto other = GetOtherBody(contact, bodyID);
                island.contacts.push_back(contactID);
                m_islanded.contacts[to_underlying(contactID)] = true;
                if (!m_islanded.bodies[to_underlying(other)]) {
                    m_islanded.bodies[to_underlying(other)] = true;
                    stack.push_back(other);
                }
            }
        }
    });
}

void AabbTreeWorld::AddJointsToIsland(Island& island, BodyStack& stack,
                                  const BodyJointIDs& joints)
{
    for_each(cbegin(joints), cend(joints), [this,&island,&stack](const auto& ji) {
        const auto jointID = std::get<JointID>(ji);
        assert(jointID != InvalidJointID);
        if (!m_islanded.joints[to_underlying(jointID)]) {
            const auto otherID = std::get<BodyID>(ji);
            const auto other = (otherID == InvalidBodyID)
                                   ? static_cast<Body*>(nullptr)
                                   : &m_bodyBuffer[to_underlying(otherID)];
            assert(!other || IsEnabled(*other) || !IsAwake(*other));
            if (!other || IsEnabled(*other))
            {
                m_islanded.joints[to_underlying(jointID)] = true;
                island.joints.push_back(jointID);
                if ((otherID != InvalidBodyID) && !m_islanded.bodies[to_underlying(otherID)])
                {
                    m_islanded.bodies[to_underlying(otherID)] = true;
                    stack.push_back(otherID);
                }
            }
        }
    });
}

RegStepStats AabbTreeWorld::SolveReg(const StepConf& conf)
{
    assert(IsStepComplete(*this));
    assert(IsLocked(*this));

    auto stats = RegStepStats{};
    auto remNumBodies = static_cast<BodyCounter>(size(m_bodies)); // Remaining # of bodies.
    auto remNumContacts = static_cast<ContactCounter>(size(m_contacts)); // Remaining # of contacts.
    auto remNumJoints = static_cast<JointCounter>(size(m_joints)); // Remaining # of joints.

    // Clear all the island flags.
    // This builds the logical set of bodies, contacts, and joints eligible for resolution.
    // As bodies, contacts, or joints get added to resolution islands, they're essentially
    // removed from this eligible set.
    ResizeAndReset(m_islanded.bodies, size(m_bodyBuffer), false);
    ResizeAndReset(m_islanded.contacts, size(m_contactBuffer), false);
    ResizeAndReset(m_islanded.joints, size(m_jointBuffer), false);

#if defined(DO_THREADED)
    std::vector<std::future<IslandStats>> futures;
    futures.reserve(remNumBodies);
#endif
    // Build and simulate all awake islands.
    for (const auto& bodyId: m_bodies) {
        if (!m_islanded.bodies[to_underlying(bodyId)]) {
            auto& body = m_bodyBuffer[to_underlying(bodyId)];
            assert(!IsAwake(body) || IsSpeedable(body));
            if (IsAwake(body) && IsEnabled(body)) {
                ++stats.islandsFound;
                Island island{m_islandResource, m_islandResource, m_islandResource};
                // Size the island for the remaining un-evaluated contacts.
                island.bodies.reserve(remNumBodies);
                island.contacts.reserve(remNumContacts);
                island.joints.reserve(remNumJoints);
                AddToIsland(island, bodyId, remNumBodies, remNumContacts, remNumJoints);
#if defined(DO_SORT_ISLANDS)
                Sort(island);
#endif
                stats.maxIslandBodies = std::max(stats.maxIslandBodies,
                                                 static_cast<BodyCounter>(size(island.bodies)));
                const auto numRemoved = RemoveUnspeedablesFromIslanded(island.bodies, m_bodyBuffer, m_islanded.bodies);
                remNumBodies += static_cast<BodyCounter>(numRemoved);
#if defined(DO_THREADED)
                // Updates bodies' sweep.pos0 to current sweep.pos1 and bodies' sweep.pos1 to new positions
                futures.push_back(std::async(std::launch::async, &AabbTreeWorld::SolveRegIslandViaGS,
                                             this, conf, island));
#else
                ::playrho::Update(stats, SolveRegIslandViaGS(conf, island));
#endif
            }
        }
    }

#if defined(DO_THREADED)
    for (auto&& future: futures) {
        const auto solverResults = future.get();
        ::playrho::Update(stats, solverResults);
    }
#endif

    for (const auto& bodyId: m_bodies) {
        if (m_islanded.bodies[to_underlying(bodyId)]) {
            // A non-static body that was in an island may have moved.
            const auto& body = m_bodyBuffer[to_underlying(bodyId)];
            if (IsSpeedable(body)) {
                // Update fixtures (for broad-phase).
                stats.proxiesMoved += Synchronize(m_bodyProxies[to_underlying(bodyId)],
                                                  GetTransform0(GetSweep(body)),
                                                  GetTransformation(body),
                                                  conf);
            }
        }
    }

    ResizeAndReset(m_islanded.bodies, size(m_bodyBuffer), false);
    ResizeAndReset(m_islanded.contacts, size(m_contactBuffer), false);
    ResizeAndReset(m_islanded.joints, size(m_jointBuffer), false);

    const auto updateStats = UpdateContacts(conf);
    stats.contactsUpdated += updateStats.updated;
    stats.contactsSkipped += updateStats.skipped;

    // Look for new contacts.
    stats.contactsAdded = AddContacts(
        FindContacts(m_proxyKeysResource, m_tree, std::exchange(m_proxiesForContacts, {})),
        conf);

    assert(!NeedsUpdating(m_contactBuffer));
    return stats;
}

IslandStats AabbTreeWorld::SolveRegIslandViaGS(const StepConf& conf, const Island& island)
{
    assert(!empty(island.bodies) || !empty(island.contacts) || !empty(island.joints));
    assert(IsStepComplete(*this));
    assert(IsLocked(*this));

    auto results = IslandStats{};
    results.positionIters = conf.regPositionIters;
    const auto h = conf.deltaTime; ///< Time step.

    // Update bodies' pos0 values.
    for_each(cbegin(island.bodies), cend(island.bodies), [&](const auto& bodyID) {
        auto& body = m_bodyBuffer[to_underlying(bodyID)];
        SetPosition0(body, GetPosition1(body));
        // XXX/TODO figure out why the following causes Gears Test to stutter!!!
        // SetSweep(body, GetNormalized(GetSweep(body)));
        // SetSweep(body, Sweep{GetNormalized(GetPosition0(body)), GetLocalCenter(body)});
    });

    // Copy bodies' pos1 and velocity data into local arrays.
    auto bodyConstraints = GetBodyConstraints(m_bodyConstraintsResource,
                                              island.bodies, m_bodyBuffer, h, GetMovementConf(conf));
    auto posConstraints = GetPositionConstraints(m_positionConstraintsResource, island.contacts,
                                                 m_contactBuffer, m_manifoldBuffer, m_shapeBuffer);
    auto velConstraints = GetVelocityConstraints(m_velocityConstraintsResource, island.contacts,
                                                 m_contactBuffer, m_manifoldBuffer, m_shapeBuffer,
                                                 bodyConstraints,
                                                 GetRegVelocityConstraintConf(conf));
    if (conf.doWarmStart) {
        WarmStartVelocities(velConstraints, bodyConstraints);
    }

    const auto psConf = GetRegConstraintSolverConf(conf);

    for_each(cbegin(island.joints), cend(island.joints), [&](const auto& id) {
        auto& joint = m_jointBuffer[to_underlying(id)];
        InitVelocity(joint, bodyConstraints, conf, psConf);
    });

    results.velocityIters = conf.regVelocityIters;
    for (auto i = decltype(conf.regVelocityIters){0}; i < conf.regVelocityIters; ++i) {
        auto jointsOkay = true;
        for_each(cbegin(island.joints), cend(island.joints), [&](const auto& id) {
            auto& joint = m_jointBuffer[to_underlying(id)];
            jointsOkay &= SolveVelocity(joint, bodyConstraints, conf);
        });
        // Note that the new incremental impulse can potentially be orders of magnitude
        // greater than the last incremental impulse used in this loop.
        const auto newIncImpulse = SolveVelocityConstraintsViaGS(velConstraints, bodyConstraints);
        results.maxIncImpulse = std::max(results.maxIncImpulse, newIncImpulse);
        if (jointsOkay && (newIncImpulse <= conf.regMinMomentum)) {
            // No joint related velocity constraints were out of tolerance.
            // No body related velocity constraints were out of tolerance.
            // There does not appear to be any benefit to doing more loops now.
            // XXX: Is it really safe to bail now? Not certain of that.
            // Bail now assuming that this is helpful to do...
            results.velocityIters = i + 1;
            break;
        }
    }

    // updates array of tentative new body positions per the velocities as if there were no obstacles...
    IntegratePositions(island.bodies, bodyConstraints, h);

    // Solve position constraints
    for (auto i = decltype(conf.regPositionIters){0}; i < conf.regPositionIters; ++i) {
        const auto minSeparation = SolvePositionConstraintsViaGS(posConstraints, bodyConstraints,
                                                                 psConf);
        results.minSeparation = std::min(results.minSeparation, minSeparation);
        const auto contactsOkay = (minSeparation >= conf.regMinSeparation);
        auto jointsOkay = true;
        for_each(cbegin(island.joints), cend(island.joints), [&](const auto& id) {
            auto& joint = m_jointBuffer[to_underlying(id)];
            jointsOkay &= SolvePosition(joint, bodyConstraints, psConf);
        });
        if (contactsOkay && jointsOkay) {
            // Reached tolerance, early out...
            results.positionIters = i + 1;
            results.solved = true;
            break;
        }
    }

    // Update normal and tangent impulses of contacts' manifold points
    for_each(cbegin(velConstraints), cend(velConstraints), [&](const VelocityConstraint& vc) {
        const auto i = static_cast<VelocityConstraints::size_type>(&vc - data(velConstraints));
        AssignImpulses(m_manifoldBuffer[to_underlying(island.contacts[i])], vc);
    });

    for (const auto& id: island.bodies) {
        const auto i = to_underlying(id);
        const auto& bc = bodyConstraints[i];
        auto& body = m_bodyBuffer[i];
        // Could normalize position here to avoid unbounded angles but angular
        // normalization isn't handled correctly by joints that constrain rotation.
        body.JustSetVelocity(bc.GetVelocity());
        // XXX/TODO figure out why calling GetNormalized here causes Gears Test to stutter!!!
        if (const auto pos = /*GetNormalized*/(bc.GetPosition()); GetPosition1(body) != pos) {
            SetPosition1(body, pos);
            FlagForUpdating(m_contactBuffer, m_bodyContacts[i]);
        }
    }

    // XXX: Should contacts needing updating be updated now??
    //const auto updateStats = UpdateContacts(conf);
    //results.contactsUpdated += updateStats.updated;
    //results.contactsSkipped += updateStats.skipped;

    if (m_listeners.postSolveContact) {
        Report(m_listeners.postSolveContact, island.contacts, velConstraints,
               results.solved? results.positionIters - 1: StepConf::InvalidIteration);
    }

    const auto minUnderActiveTime = UpdateUnderActiveTimes(island.bodies, m_bodyBuffer, conf);
    if ((minUnderActiveTime >= conf.minStillTimeToSleep) && results.solved) {
        results.bodiesSlept = Sleepem(island.bodies, m_bodyBuffer);
    }

    return results;
}

AabbTreeWorld::UpdateContactsData
AabbTreeWorld::UpdateContactTOIs(const StepConf& conf)
{
    auto results = UpdateContactsData{};

    const auto toiConf = GetToiConf(conf);
    for (const auto& contact: m_contacts) {
        auto& c = m_contactBuffer[to_underlying(std::get<ContactID>(contact))];
        if (HasValidToi(c)) {
            ++results.numValidTOI;
            continue;
        }
        if (!IsEnabled(c) || IsSensor(c) || !IsImpenetrable(c)) {
            continue;
        }
        if (GetToiCount(c) >= conf.maxSubSteps) {
            // What are the pros/cons of this?
            // Larger m_maxSubSteps slows down the simulation.
            // m_maxSubSteps of 44 and higher seems to decrease the occurrance of tunneling
            // of multiple bullet body collisions with static objects.
            ++results.numAtMaxSubSteps;
            continue;
        }

        auto& bA = m_bodyBuffer[to_underlying(GetBodyA(c))];
        auto& bB = m_bodyBuffer[to_underlying(GetBodyB(c))];

        if (!IsAwake(bA) && !IsAwake(bB)) {
            continue;
        }

        /*
         * Put the sweeps onto the same time interval.
         * Presumably no unresolved collisions happen before the maximum of the bodies'
         * alpha-0 times. So long as the least TOI of the contacts is always the first
         * collision that gets dealt with, this presumption is safe.
         */
        const auto alpha0 = std::max(GetSweep(bA).alpha0, GetSweep(bB).alpha0);
        Advance0(bA, alpha0);
        Advance0(bB, alpha0);

        // Compute the TOI for this contact (one or both bodies are awake and impenetrable).
        // Computes the time of impact in interval [0, 1]
        const auto proxyA = GetChild(m_shapeBuffer[to_underlying(GetShapeA(c))], GetChildIndexA(c));
        const auto proxyB = GetChild(m_shapeBuffer[to_underlying(GetShapeB(c))], GetChildIndexB(c));

        // Large rotations can make the root finder of TimeOfImpact fail, so normalize sweep angles.
        const auto sweepA = GetNormalized(GetSweep(bA));
        const auto sweepB = GetNormalized(GetSweep(bB));

        // Compute the TOI for this contact (one or both bodies are awake and impenetrable).
        // Computes the time of impact in interval [0, 1]
        const auto output = GetToiViaSat(proxyA, sweepA, proxyB, sweepB, toiConf);

        // Use Min function to handle floating point imprecision which possibly otherwise
        // could provide a TOI that's greater than 1.
        const auto toi = IsValidForTime(output.state)?
            std::min(alpha0 + (Real(1) - alpha0) * output.time, Real(1)): Real(1);
        SetToi(c, {UnitIntervalFF<Real>(toi)});
        results.maxDistIters = std::max(results.maxDistIters, output.stats.max_dist_iters);
        results.maxToiIters = std::max(results.maxToiIters, output.stats.toi_iters);
        results.maxRootIters = std::max(results.maxRootIters, output.stats.max_root_iters);
        ++results.numUpdatedTOI;
    }

    return results;
}

ToiStepStats AabbTreeWorld::SolveToi(const StepConf& conf)
{
    assert(IsLocked(*this));

    auto stats = ToiStepStats{};
    const auto subStepping = GetSubStepping(*this);

    // Find TOI events and solve them.
    for (;;) {
        const auto updateData = UpdateContactTOIs(conf);
        stats.contactsAtMaxSubSteps += updateData.numAtMaxSubSteps;
        stats.contactsUpdatedToi += updateData.numUpdatedTOI;
        stats.maxDistIters = std::max(stats.maxDistIters, updateData.maxDistIters);
        stats.maxRootIters = std::max(stats.maxRootIters, updateData.maxRootIters);
        stats.maxToiIters = std::max(stats.maxToiIters, updateData.maxToiIters);

        const auto next = GetSoonestContact(m_contacts, m_contactBuffer);
        if (next == InvalidContactID) {
            // No more TOI events to handle within the current time step. Done!
            m_flags |= e_stepComplete;
            ResetBodiesForSolveTOI(m_bodies, m_bodyBuffer);
            Unset(m_islanded.bodies, m_bodies);
            ResetContactsForSolveTOI(m_contactBuffer, m_contacts);
            Unset(m_islanded.contacts, m_contacts);
            break;
        }

        ++stats.contactsFound;
        auto islandsFound = 0u;
        if (!m_islanded.contacts[to_underlying(next)]) {
            const auto solverResults = SolveToi(next, conf);
            stats.minSeparation = std::min(stats.minSeparation, solverResults.minSeparation);
            stats.maxIncImpulse = std::max(stats.maxIncImpulse, solverResults.maxIncImpulse);
            stats.islandsSolved += solverResults.solved;
            stats.sumPosIters += solverResults.positionIters;
            stats.sumVelIters += solverResults.velocityIters;
            if ((solverResults.positionIters > 0) || (solverResults.velocityIters > 0)) {
                ++islandsFound;
            }
            stats.contactsUpdatedTouching += solverResults.contactsUpdated;
            stats.contactsSkippedTouching += solverResults.contactsSkipped;
        }
        stats.islandsFound += islandsFound;

        // Reset island flags and synchronize broad-phase proxies.
        for (const auto& bodyId: m_bodies) {
            if (m_islanded.bodies[to_underlying(bodyId)]) {
                m_islanded.bodies[to_underlying(bodyId)] = false;
                const auto& body = m_bodyBuffer[to_underlying(bodyId)];
                if (IsAccelerable(body)) {
                    stats.proxiesMoved += Synchronize(m_bodyProxies[to_underlying(bodyId)],
                                                      GetTransform0(body.GetSweep()),
                                                      GetTransformation(body),
                                                      conf);
                    const auto& bodyContacts = m_bodyContacts[to_underlying(bodyId)];
                    ResetBodyContactsForSolveTOI(m_contactBuffer, bodyContacts);
                    Unset(m_islanded.contacts, bodyContacts);
                }
            }
        }

        // Commit fixture proxy movements to the broad-phase so that new contacts are created.
        // Also, some contacts can be destroyed.
        stats.contactsAdded += AddContacts(
            FindContacts(m_proxyKeysResource, m_tree, std::exchange(m_proxiesForContacts, {})),
            conf);

        if (subStepping) {
            m_flags &= ~e_stepComplete;
            break;
        }
    }

    const auto updateStats = UpdateContacts(conf);
    stats.contactsUpdatedTouching += updateStats.updated;
    stats.contactsSkippedTouching += updateStats.skipped;

    assert(!NeedsUpdating(m_contactBuffer));
    return stats;
}

IslandStats AabbTreeWorld::SolveToi(ContactID contactID, const StepConf& conf)
{
    assert(IsLocked(*this));

    // Note:
    //   This function is what used to be b2World::SolveToi(const b2TimeStep& step).
    //   It also differs internally from Erin's implementation.
    //   Here's some specific behavioral differences:
    //   1. Bodies don't get their under-active times reset (like they do in Erin's code).

    auto numUpdated = ContactCounter{0};
    auto& contact = m_contactBuffer[to_underlying(contactID)];

    /*
     * Confirm that contact is as it's supposed to be according to contract of the
     * GetSoonestContact function from which this contact should have been obtained.
     */
    assert(IsEnabled(contact));
    assert(!IsSensor(contact));
    assert(IsImpenetrable(contact));
    assert(!m_islanded.contacts[to_underlying(contactID)]);
    assert(GetToi(contact));

    const auto toi = ZeroToUnderOneFF<Real>(*GetToi(contact)); // NOLINT(bugprone-unchecked-optional-access)
    const auto bodyIdA = GetBodyA(contact);
    const auto bodyIdB = GetBodyB(contact);
    auto& bA = m_bodyBuffer[to_underlying(bodyIdA)];
    auto& bB = m_bodyBuffer[to_underlying(bodyIdB)];

    {
        const auto backupA = GetSweep(bA);
        const auto backupB = GetSweep(bB);

        // Advance the bodies to the TOI.
        assert((toi != Real(0)) || ((GetSweep(bA).alpha0 == Real(0)) && (GetSweep(bB).alpha0 == Real(0))));
        Advance(bA, toi);
        if (GetPosition0(bA) != backupA.pos0 || GetPosition1(bA) != backupA.pos1) {
            FlagForUpdating(m_contactBuffer, m_bodyContacts[to_underlying(bodyIdA)]);
        }
        Advance(bB, toi);
        if (GetPosition0(bB) != backupB.pos0 || GetPosition1(bB) != backupB.pos1) {
            FlagForUpdating(m_contactBuffer, m_bodyContacts[to_underlying(bodyIdB)]);
        }

        // The TOI contact likely has some new contact points.
        if (contact.NeedsUpdating()) {
            Update(contactID, GetUpdateConf(conf));
            ++numUpdated;
        }

        SetToi(contact, {});
        contact.IncrementToiCount();

        // Is contact disabled or separated?
        //
        // XXX: Not often, but sometimes, contact.IsTouching() is false now.
        //      Seems like this is a bug, or at least suboptimal, condition.
        //      This function shouldn't be getting called unless contact has an
        //      impact indeed at the given TOI. Seen this happen in an edge-polygon
        //      contact situation where the polygon had a larger than default
        //      vertex radius. CollideShapes had called GetManifoldFaceB which
        //      was failing to see 2 clip points after GetClipPoints was called.
        //assert(contact.IsEnabled() && contact.IsTouching());
        if (!IsEnabled(contact) || !IsTouching(contact)) {
            //contact.UnsetEnabled();
            SetSweep(bA, backupA);
            SetSweep(bB, backupB);
            return IslandStats{}.IncContactsUpdated(numUpdated).IncContactsSkipped(numUpdated? 0u: 1u);
        }
    }
    if (IsSpeedable(bA)) {
        bA.SetAwakeFlag();
        // XXX should the body's under-active time be reset here?
        //   Erin's code does for here but not in b2World::Solve(const b2TimeStep& step).
        //   Reseting the body's under-active time has performance implications.
    }
    if (IsSpeedable(bB)) {
        bB.SetAwakeFlag();
        // XXX should the body's under-active time be reset here?
        //   Erin's code does for here but not in b2World::Solve(const b2TimeStep& step).
        //   Reseting the body's under-active time has performance implications.
    }

    // Build the island
    Island island{m_islandResource, m_islandResource, m_islandResource};
    island.bodies.reserve(size(m_bodies));
    island.contacts.reserve(used(m_contactBuffer));

     // These asserts get triggered sometimes if contacts within TOI are iterated over.
    assert(!m_islanded.bodies[to_underlying(bodyIdA)]);
    assert(!m_islanded.bodies[to_underlying(bodyIdB)]);
    m_islanded.bodies[to_underlying(bodyIdA)] = true;
    m_islanded.bodies[to_underlying(bodyIdB)] = true;
    m_islanded.contacts[to_underlying(contactID)] = true;
    island.bodies.push_back(bodyIdA);
    island.bodies.push_back(bodyIdB);
    island.contacts.push_back(contactID);

    auto numSkipped = ContactCounter(0u);
    // Process the contacts of the two bodies, adding appropriate ones to the island,
    // adding appropriate other bodies of added contacts, and advancing those other
    // bodies sweeps and transforms to the minimum contact's TOI.
    if (IsAccelerable(bA)) {
        const auto procOut = ProcessContactsForTOI(bodyIdA, island, toi, conf);
        numUpdated += procOut.contactsUpdated;
        numSkipped += procOut.contactsSkipped;
    }
    if (IsAccelerable(bB)) {
        const auto procOut = ProcessContactsForTOI(bodyIdB, island, toi, conf);
        numUpdated += procOut.contactsUpdated;
        numSkipped += procOut.contactsSkipped;
    }

#if defined(DO_SORT_ISLANDS)
    Sort(island);
#endif
    RemoveUnspeedablesFromIslanded(island.bodies, m_bodyBuffer, m_islanded.bodies);

    // Now solve for remainder of time step.
    auto subConf = StepConf{conf};
    subConf.deltaTime = (Real(1) - toi) * conf.deltaTime;
    return SolveToiViaGS(island, subConf).IncContactsUpdated(numUpdated).IncContactsSkipped(numSkipped);
}

IslandStats AabbTreeWorld::SolveToiViaGS(const Island& island, const StepConf& conf)
{
    assert(IsLocked(*this));

    auto results = IslandStats{};

    /*
     * Resets body constraints to what they were right after reg phase processing.
     * Presumably the regular phase resolution has already taken care of updating the
     * body's velocity w.r.t. acceleration and damping such that this call here to get
     * the body constraint doesn't need to pass an elapsed time (and doesn't need to
     * update the velocity from what it already is).
     */
    auto bodyConstraints = GetBodyConstraints(m_bodyConstraintsResource,
                                              island.bodies, m_bodyBuffer, 0_s, GetMovementConf(conf));

    // Initialize the body state.
    auto posConstraints = GetPositionConstraints(m_positionConstraintsResource, island.contacts, m_contactBuffer,
                                                 m_manifoldBuffer, m_shapeBuffer);

    // Solve TOI-based position constraints.
    assert(results.minSeparation == std::numeric_limits<Length>::infinity());
    assert(results.solved == false);
    results.positionIters = conf.toiPositionIters;
    {
        const auto psConf = GetToiConstraintSolverConf(conf);
        for (auto i = decltype(conf.toiPositionIters){0}; i < conf.toiPositionIters; ++i) {
            //
            // Note: There are two flavors of the SolvePositionConstraints function.
            //   One takes an extra two arguments that are the indexes of two bodies that are
            //   okay to move. The other one does not.
            //   Calling the selective solver (that takes the two additional arguments) appears
            //   to result in phsyics simulations that are more prone to tunneling. Meanwhile,
            //   using the non-selective solver would presumably be slower (since it appears to
            //   have more that it will do). Assuming that slower is preferable to tunnelling,
            //   then the non-selective function is the one to be calling here.
            //
            const auto minSeparation = SolvePositionConstraintsViaGS(posConstraints,
                                                                     bodyConstraints, psConf);
            results.minSeparation = std::min(results.minSeparation, minSeparation);
            if (minSeparation >= conf.toiMinSeparation) {
                // Reached tolerance, early out...
                results.positionIters = i + 1;
                results.solved = true;
                break;
            }
        }
    }

    // Leap of faith to new safe state.
    // Not doing this results in slower simulations.
    // Originally this update was only done to island.bodies 0 and 1.
    // Unclear whether rest of bodies should also be updated. No difference noticed.
    for (const auto& id: island.bodies) {
        const auto& bc = bodyConstraints[to_underlying(id)];
        SetPosition0(m_bodyBuffer[to_underlying(id)], bc.GetPosition());
    }

    auto velConstraints = GetVelocityConstraints(m_velocityConstraintsResource, island.contacts,
                                                 m_contactBuffer, m_manifoldBuffer, m_shapeBuffer,
                                                 bodyConstraints,
                                                 GetToiVelocityConstraintConf(conf));

    // No warm starting is needed for TOI events because warm
    // starting impulses were applied in the discrete solver.

    // Solve velocity constraints.
    assert(results.maxIncImpulse == 0_Ns);
    results.velocityIters = conf.toiVelocityIters;
    for (auto i = decltype(conf.toiVelocityIters){0}; i < conf.toiVelocityIters; ++i) {
        const auto newIncImpulse = SolveVelocityConstraintsViaGS(velConstraints, bodyConstraints);
        if (newIncImpulse <= conf.toiMinMomentum) {
            // No body related velocity constraints were out of tolerance.
            // There does not appear to be any benefit to doing more loops now.
            // XXX: Is it really safe to bail now? Not certain of that.
            // Bail now assuming that this is helpful to do...
            results.velocityIters = i + 1;
            break;
        }
        results.maxIncImpulse = std::max(results.maxIncImpulse, newIncImpulse);
    }

    // Don't store TOI contact forces for warm starting because they can be quite large.

    IntegratePositions(island.bodies, bodyConstraints, conf.deltaTime);
    for (const auto& id: island.bodies) {
        const auto i = to_underlying(id);
        auto& body = m_bodyBuffer[i];
        auto& bc = bodyConstraints[i];
        body.JustSetVelocity(bc.GetVelocity());
        if (const auto pos = bc.GetPosition(); GetPosition1(body) != pos) {
            SetPosition1(body, pos);
            FlagForUpdating(m_contactBuffer, m_bodyContacts[i]);
        }
    }

    if (m_listeners.postSolveContact) {
        Report(m_listeners.postSolveContact, island.contacts, velConstraints, results.positionIters);
    }

    return results;
}

AabbTreeWorld::ProcessContactsOutput
AabbTreeWorld::ProcessContactsForTOI( // NOLINT(readability-function-cognitive-complexity)
                                     BodyID id, Island& island, ZeroToUnderOneFF<Real> toi,
                                     const StepConf& conf)
{
    const auto& body = m_bodyBuffer[to_underlying(id)];

    assert(m_islanded.bodies[to_underlying(id)]);
    assert(IsAccelerable(body));

    auto results = ProcessContactsOutput{};
    assert(results.contactsUpdated == 0);
    assert(results.contactsSkipped == 0);

    const auto updateConf = GetUpdateConf(conf);

    // Note: the original contact (for body of which this function was called) already is-in-island.
    const auto bodyImpenetrable = IsImpenetrable(body);
    for (const auto& ci: m_bodyContacts[to_underlying(id)]) {
        const auto contactID = std::get<ContactID>(ci);
        if (!m_islanded.contacts[to_underlying(contactID)]) {
            auto& contact = m_contactBuffer[to_underlying(contactID)];
            if (!IsSensor(contact)) {
                const auto otherId = GetOtherBody(contact, id);
                auto& other = m_bodyBuffer[to_underlying(otherId)];
                if (bodyImpenetrable || IsImpenetrable(other)) {
                    const auto otherIslanded = m_islanded.bodies[to_underlying(otherId)];
                    {
                        const auto backup = GetSweep(other);
                        if (!otherIslanded /* && GetSweep(other).alpha0 != toi */) {
                            Advance(other, toi);
                            if (GetPosition0(other) != backup.pos0 || GetPosition1(other) != backup.pos1) {
                                FlagForUpdating(m_contactBuffer, m_bodyContacts[to_underlying(otherId)]);
                            }
                        }

                        // Update the contact points
                        if (NeedsUpdating(contact)) {
                            Update(contactID, updateConf);
                            ++results.contactsUpdated;
                        }
                        else {
                            ++results.contactsSkipped;
                        }

                        // Revert and skip if contact disabled by user or not touching anymore (very possible).
                        if (!IsEnabled(contact) || !IsTouching(contact)) {
                            SetSweep(other, backup);
                            continue;
                        }
                    }
                    island.contacts.push_back(contactID);
                    m_islanded.contacts[to_underlying(contactID)] = true;
                    if (!otherIslanded) {
                        if (IsSpeedable(other)) {
                            other.SetAwakeFlag();
                        }
                        island.bodies.push_back(otherId);
                        m_islanded.bodies[to_underlying(otherId)] = true;
#if 0
                        if (IsAccelerable(other)) {
                            contactsUpdated += ProcessContactsForTOI(island, other, toi);
                        }
#endif
                    }
#ifndef NDEBUG
                    else {
                        /*
                         * If other is-in-island but not in current island, then something's gone wrong.
                         * Other needs to be in current island but was already in the island.
                         * A previous contact island didn't grow to include all the bodies it needed or
                         * perhaps the current contact is-touching while another one wasn't and the
                         * inconsistency is throwing things off.
                         */
                        assert(Count(island, otherId) > 0);
                    }
#endif
                }
            }
        }
    }
    return results;
}

StepStats Step(AabbTreeWorld& world, const StepConf& conf)
{
    assert((world.m_vertexRadius.GetMax() * Real(2)) +
           (conf.linearSlop / Real(4)) > (world.m_vertexRadius.GetMax() * Real(2)));

    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }

    // "Named return value optimization" (NRVO) will make returning this more efficient.
    auto stepStats = StepStats{};
    {
        const FlagGuard<decltype(world.m_flags)> flagGaurd(world.m_flags, AabbTreeWorld::e_locked);

        // Create proxies herein for access to StepConf info!
        for (const auto& [bodyID, shapeID]: world.m_fixturesForProxies) {
            const auto &body = world.m_bodyBuffer[to_underlying(bodyID)];
            const auto xfm0 = GetTransform0(GetSweep(body));
            const auto xfm1 = GetTransformation(body);
            stepStats.pre.proxiesCreated +=
                CreateProxies(world.m_tree, bodyID, shapeID, world.m_shapeBuffer[to_underlying(shapeID)],
                              xfm0, xfm1, conf,
                              world.m_bodyProxies[to_underlying(bodyID)], world.m_proxiesForContacts);
        }
        world.m_fixturesForProxies = {};

        stepStats.pre.proxiesMoved = [&world](const StepConf& cfg){
            auto proxiesMoved = PreStepStats::counter_type{0};
            for_each(begin(world.m_bodiesForSync), end(world.m_bodiesForSync),
                     [&world,&cfg,&proxiesMoved](const auto& bodyID) {
                const auto &body = world.m_bodyBuffer[to_underlying(bodyID)];
                const auto xfm0 = GetTransform0(GetSweep(body));
                const auto xfm1 = GetTransformation(body);
                proxiesMoved += world.Synchronize(world.m_bodyProxies[to_underlying(bodyID)], xfm0, xfm1, cfg);
            });
            return proxiesMoved;
        }(conf);
        world.m_bodiesForSync = {};
        // pre.proxiesMoved is usually zero but sometimes isn't.

        {
            // Note: this may update bodies (in addition to the contacts container).
            const auto destroyStats = world.DestroyContacts(world.m_contacts);
            stepStats.pre.contactsDestroyed = destroyStats.overlap + destroyStats.filter;
        }

        {
            // Could potentially run UpdateContacts multithreaded over split lists...
            const auto updateStats = world.UpdateContacts(conf);
            stepStats.pre.contactsUpdated = updateStats.updated;
            stepStats.pre.contactsSkipped = updateStats.skipped;
        }

        // For any new fixtures added: need to find and create the new contacts.
        // Note: this may update bodies (in addition to the contacts container).
        stepStats.pre.contactsAdded = world.AddContacts(
            FindContacts(world.m_proxyKeysResource, world.m_tree, std::exchange(world.m_proxiesForContacts, {})),
            conf);

        assert(!NeedsUpdating(world.m_contactBuffer));

        if (conf.deltaTime != 0_s) {
            world.m_inv_dt0 = Real(1) / conf.deltaTime;
            // Integrate velocities, solve velocity constraints, and integrate positions.
            if (IsStepComplete(world)) {
                stepStats.reg = world.SolveReg(conf);
            }

            // Handle TOI events.
            if (conf.doToi) {
                stepStats.toi = world.SolveToi(conf);
            }
        }
    }
    return stepStats;
}

void ShiftOrigin(AabbTreeWorld& world, const Length2& newOrigin)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }

    // Optimize for newOrigin being different than current...
    for (const auto& body: world.m_bodies) {
        auto& b = world.m_bodyBuffer[to_underlying(body)];
        auto sweep = GetSweep(b);
        sweep.pos0.linear -= newOrigin;
        sweep.pos1.linear -= newOrigin;
        SetSweep(b, sweep);
        FlagForUpdating(world.m_contactBuffer, world.m_bodyContacts[to_underlying(body)]);
    }

    for_each(begin(world.m_joints), end(world.m_joints), [&](const auto& joint) {
        auto& j = world.m_jointBuffer[to_underlying(joint)];
        ::playrho::d2::ShiftOrigin(j, newOrigin);
    });

    world.m_tree.ShiftOrigin(newOrigin);
}

void AabbTreeWorld::InternalDestroy(ContactID contactID, const Body* from)
{
    assert(contactID != InvalidContactID);
    auto& contact = m_contactBuffer[to_underlying(contactID)];
    if (m_listeners.endContact && contact.IsTouching()) {
        // EndContact hadn't been called in DestroyOrUpdateContacts() since is-touching,
        //  so call it now
        m_listeners.endContact(contactID);
    }
    const auto bodyIdA = GetBodyA(contact);
    const auto bodyIdB = GetBodyB(contact);
    const auto bodyA = &m_bodyBuffer[to_underlying(bodyIdA)];
    const auto bodyB = &m_bodyBuffer[to_underlying(bodyIdB)];
    if (bodyA != from) {
        auto& bodyContacts = m_bodyContacts[to_underlying(bodyIdA)];
        if (const auto found = FindTypeValue(bodyContacts, contactID)) {
            bodyContacts.erase(*found);
        }
    }
    if (bodyB != from) {
        auto& bodyContacts = m_bodyContacts[to_underlying(bodyIdB)];
        if (const auto found = FindTypeValue(bodyContacts, contactID)) {
            bodyContacts.erase(*found);
        }
    }
    auto& manifold = m_manifoldBuffer[to_underlying(contactID)];
    if ((manifold.GetPointCount() > 0) && !IsSensor(contact)) {
        // Contact may have been keeping accelerable bodies of fixture A or B from moving.
        // Need to awaken those bodies now in case they are again movable.
        SetAwake(*bodyA);
        SetAwake(*bodyB);
    }
    m_contactBuffer.Free(to_underlying(contactID)).SetDestroyed();
    m_manifoldBuffer.Free(to_underlying(contactID));
}

void AabbTreeWorld::Destroy(ContactID contactID, const Body* from)
{
    assert(contactID != InvalidContactID);
    if (const auto found = FindTypeValue(m_contacts, contactID)) {
        m_contacts.erase(*found);
    }
    InternalDestroy(contactID, from);
}

AabbTreeWorld::DestroyContactsStats AabbTreeWorld::DestroyContacts(KeyedContactIDs& contacts)
{
    auto stats = DestroyContactsStats{};
    const auto beforeOverlapSize = size(contacts);
    contacts.erase(std::remove_if(begin(contacts), end(contacts), [&](const auto& c){
        const auto key = std::get<ContactKey>(c);
        if (!TestOverlap(m_tree, key.GetMin(), key.GetMax())) {
            // Destroy contacts that cease to overlap in the broad-phase.
            InternalDestroy(std::get<ContactID>(c));
            return true;
        }
        return false;
    }), end(contacts));
    const auto afterOverlapSize = size(contacts);
    stats.overlap = static_cast<ContactCounter>(beforeOverlapSize - afterOverlapSize);
    if (m_flags & e_needsContactFiltering) {
        contacts.erase(std::remove_if(begin(contacts), end(contacts), [&](const auto& c){
            const auto contactID = std::get<ContactID>(c);
            auto& contact = m_contactBuffer[to_underlying(contactID)];
            if (contact.NeedsFiltering()) {
                const auto bodyIdA = GetBodyA(contact);
                const auto bodyIdB = GetBodyB(contact);
                const auto& bodyA = m_bodyBuffer[to_underlying(bodyIdA)];
                const auto& bodyB = m_bodyBuffer[to_underlying(bodyIdB)];
                const auto& shapeA = m_shapeBuffer[to_underlying(GetShapeA(contact))];
                const auto& shapeB = m_shapeBuffer[to_underlying(GetShapeB(contact))];
                if (!EitherIsAccelerable(bodyA, bodyB) ||
                    !ShouldCollide(m_jointBuffer, m_bodyJoints, bodyIdA, bodyIdB) ||
                    !ShouldCollide(shapeA, shapeB)) {
                    InternalDestroy(contactID);
                    return true;
                }
                contact.UnflagForFiltering();
            }
            return false;
        }), end(contacts));
        const auto afterFilteringSize = size(contacts);
        stats.filter = static_cast<ContactCounter>(afterOverlapSize - afterFilteringSize);
        m_flags &= ~e_needsContactFiltering;
    }
    return stats;
}

AabbTreeWorld::UpdateContactsStats AabbTreeWorld::UpdateContacts(const StepConf& conf)
{
#ifdef DO_PAR_UNSEQ
    atomic<ContactCounter> updated;
    atomic<ContactCounter> skipped;
#else
    auto updated = ContactCounter(0u);
    auto skipped = ContactCounter(0u);
#endif

    const auto updateConf = GetUpdateConf(conf);

#if defined(DO_THREADED)
    std::vector<ContactID> contactsNeedingUpdate;
    contactsNeedingUpdate.reserve(size(m_contacts));
    std::vector<std::future<void>> futures;
    futures.reserve(size(m_contacts));
#endif

    // Update awake contacts.
    for_each(/*execution::par_unseq,*/ begin(m_contacts), end(m_contacts), [&](const auto& c) {
        const auto contactID = std::get<ContactID>(c);
        auto& contact = m_contactBuffer[to_underlying(contactID)];
#ifndef NDEBUG
        const auto& bodyA = m_bodyBuffer[to_underlying(GetBodyA(contact))];
        const auto& bodyB = m_bodyBuffer[to_underlying(GetBodyB(contact))];
#endif

        // Awake && speedable (dynamic or kinematic) means collidable.
        // At least one body must be collidable
        assert(!IsAwake(bodyA) || IsSpeedable(bodyA));
        assert(!IsAwake(bodyB) || IsSpeedable(bodyB));

        // Possible that bodyA.GetSweep().alpha0 != 0
        // Possible that bodyB.GetSweep().alpha0 != 0

        // Update the contact manifold and notify the listener.
        // Note: ideally contacts are only updated if there was a change to:
        //   - The fixtures' sensor states.
        //   - The fixtures bodies' transformations.
        //   - The "maxCirclesRatio" per-step configuration state if contact IS NOT for sensor.
        //   - The "maxDistanceIters" per-step configuration state if contact IS for sensor.
        //
        if (NeedsUpdating(contact)) {
            // The following may call listener but is otherwise thread-safe.
#if defined(DO_THREADED)
            contactsNeedingUpdate.push_back(contactID);
            //futures.push_back(async(&Update, this, *contact, conf)));
            //futures.push_back(async(launch::async, [=]{ Update(*contact, conf); }));
#else
            Update(contactID, updateConf);
#endif
            ++updated;
        }
        else {
            ++skipped;
        }
    });

#if defined(DO_THREADED)
    auto numJobs = size(contactsNeedingUpdate);
    const auto jobsPerCore = numJobs / 4;
    for (auto i = decltype(numJobs){0}; numJobs > 0 && i < 3; ++i) {
        futures.push_back(std::async(std::launch::async, [=]{
            const auto offset = jobsPerCore * i;
            for (auto j = decltype(jobsPerCore){0}; j < jobsPerCore; ++j) {
                Update(contactsNeedingUpdate[offset + j], updateConf);
            }
        }));
        numJobs -= jobsPerCore;
    }
    if (numJobs > 0) {
        futures.push_back(std::async(std::launch::async, [=]{
            const auto offset = jobsPerCore * 3;
            for (auto j = decltype(numJobs){0}; j < numJobs; ++j) {
                Update(contactsNeedingUpdate[offset + j], updateConf);
            }
        }));
    }
    for (auto&& future: futures) {
        future.get();
    }
#endif

    return UpdateContactsStats{
        static_cast<ContactCounter>(updated),
        static_cast<ContactCounter>(skipped)
    };
}

ContactCounter
AabbTreeWorld::AddContacts( // NOLINT(readability-function-cognitive-complexity)
    std::vector<ProxyKey, pmr::polymorphic_allocator<ProxyKey>>&& keys,
    const StepConf& conf)
{
    const auto numContactsBefore = size(m_contacts);
    const auto updateConf = GetUpdateConf(conf);
    for_each(cbegin(keys), cend(keys), [this,&updateConf](const ProxyKey& key) {
        const auto& minKeyLeafData = std::get<1>(key);
        const auto& maxKeyLeafData = std::get<2>(key);
        const auto bodyIdA = minKeyLeafData.bodyId;
        const auto shapeIdA = minKeyLeafData.shapeId;
        const auto bodyIdB = maxKeyLeafData.bodyId;
        const auto shapeIdB = maxKeyLeafData.shapeId;
        assert(bodyIdA != bodyIdB);
        auto& bodyA = m_bodyBuffer[to_underlying(bodyIdA)];
        auto& bodyB = m_bodyBuffer[to_underlying(bodyIdB)];
        const auto& shapeA = m_shapeBuffer[to_underlying(shapeIdA)];
        const auto& shapeB = m_shapeBuffer[to_underlying(shapeIdB)];

        // Does a joint override collision? Is at least one body dynamic?
        if (!EitherIsAccelerable(bodyA, bodyB) ||
            !ShouldCollide(m_jointBuffer, m_bodyJoints, bodyIdA, bodyIdB) ||
            !ShouldCollide(shapeA, shapeB))
        {
            return;
        }

#ifndef NO_RACING
        // Code herein may be racey in a multithreaded context...
        // Would need a lock on bodyA, bodyB, and contacts.
        // A global lock on the world instance should work but then would it have so much
        // contention as to make multi-threaded handling of adding new connections senseless?

        // Have to quickly figure out if there's a contact already added for the current
        // fixture-childindex pair that this method's been called for.
        //
        // In cases where there's a bigger bullet-enabled object that's colliding with lots of
        // smaller objects packed tightly together and overlapping like in the Add Pair Stress
        // Test demo that has some 400 smaller objects, the bigger object could have 387 contacts
        // while the smaller object has 369 or more, and the total world contact count can be over
        // 30,495. While searching linearly through the object with less contacts should help,
        // that may still be a lot of contacts to be going through in the context this function
        // is being called. OTOH, speed seems to be dominated by cache hit-ratio...
        //
        // With compiler optimization enabled and 400 small bodies and Real=double...
        // For world:
        //   World::set<Contact*> shows up as .524 seconds max step
        //   World::list<Contact> shows up as .482 seconds max step.
        // For body:
        //    using contact map w/ proxy ID keys shows up as .561
        // W/ unordered_map: .529 seconds max step (step 15).
        // W/ World::list<Contact> and Body::list<ContactKey,Contact*>   .444s@step15, 1.063s-sumstep20
        // W/ World::list<Contact> and Body::list<ContactKey,Contact*>   .393s@step15, 1.063s-sumstep20
        // W/ World::list<Contact> and Body::list<ContactKey,Contact*>   .412s@step15, 1.012s-sumstep20
        // W/ World::list<Contact> and Body::vector<ContactKey,Contact*> .219s@step15, 0.659s-sumstep20

        // Does a contact already exist?
        // Identify body with least contacts and search it.
        // NOTE: Time trial testing found the following rough ordering of data structures, to be
        // fastest to slowest: vector, list, unorderered_set, unordered_map,
        //     set, map.
        auto& contactsA = m_bodyContacts[to_underlying(bodyIdA)];
        auto& contactsB = m_bodyContacts[to_underlying(bodyIdB)];
        if (FindTypeValue((size(contactsA) < size(contactsB))? contactsA: contactsB, std::get<0>(key))) {
            return;
        }

        if (size(m_contacts) >= MaxContacts) {
            // New contact was needed, but denied due to MaxContacts count being reached.
            return;
        }

        const auto contactID = static_cast<ContactID>(static_cast<ContactID::underlying_type>(
            m_contactBuffer.Allocate(minKeyLeafData, maxKeyLeafData)));
        m_islanded.contacts.resize(size(m_contactBuffer));
        m_manifoldBuffer.Allocate();
        auto& contact = m_contactBuffer[to_underlying(contactID)];
        assert(contact.IsEnabled());
        contact.UnsetDestroyed();
        if (IsImpenetrable(bodyA) || IsImpenetrable(bodyB)) {
            SetImpenetrable(contact);
        }
        if (IsSensor(shapeA) || IsSensor(shapeB)) {
            SetSensor(contact);
        }
        SetFriction(contact, MixFriction(GetFriction(shapeA), GetFriction(shapeB)));
        SetRestitution(contact, MixRestitution(GetRestitution(shapeA), GetRestitution(shapeB)));

        // Insert into the contacts container.
        //
        // Should the new contact be added at front or back?
        //
        // Original strategy added to the front. Since processing done front to back, front
        // adding means container more a LIFO container, while back adding means more a FIFO.
        //
        m_contacts.emplace_back(std::get<0>(key), contactID);

        // TODO: check contactID unique in contacts containers if !NDEBUG
        contactsA.emplace_back(std::get<0>(key), contactID);
        contactsB.emplace_back(std::get<0>(key), contactID);

        if (!IsSensor(contact)) {
            if (IsSpeedable(bodyA)) {
                bodyA.SetAwakeFlag();
            }
            if (IsSpeedable(bodyB)) {
                bodyB.SetAwakeFlag();
            }
        }

        Update(contactID, updateConf);
#endif
    });
    const auto numContactsAfter = size(m_contacts);
    const auto numContactsAdded = numContactsAfter - numContactsBefore;
#if DO_SORT_ID_LISTS
    if (numContactsAdded > 0u) {
        sort(begin(m_contacts), end(m_contacts), [](const KeyedContactID& a, const KeyedContactID& b){
            return std::get<ContactID>(a) < std::get<ContactID>(b);
        });
    }
#endif
    return static_cast<ContactCounter>(numContactsAdded);
}

const std::vector<DynamicTree::Size>& GetProxies(const AabbTreeWorld& world, BodyID id)
{
    return At(world.m_bodyProxies, id, noSuchBodyMsg);
}

const BodyContactIDs& GetContacts(const AabbTreeWorld& world, BodyID id)
{
    return At(world.m_bodyContacts, id, noSuchBodyMsg);
}

const BodyJointIDs& GetJoints(const AabbTreeWorld& world, BodyID id)
{
    return At(world.m_bodyJoints, id, noSuchBodyMsg);
}

ContactCounter AabbTreeWorld::Synchronize(const ProxyIDs& bodyProxies,
                                          const Transformation& xfm0, const Transformation& xfm1,
                                          const StepConf& conf)
{
    auto updatedCount = ContactCounter{0};
    assert(::playrho::IsValid(xfm0));
    assert(::playrho::IsValid(xfm1));
    const auto displacement = conf.displaceMultiplier * (xfm1.p - xfm0.p);
    for (auto&& e: bodyProxies) {
        const auto& node = m_tree.GetNode(e);
        const auto leafData = node.AsLeaf();
        const auto aabb = ComputeAABB(GetChild(m_shapeBuffer[to_underlying(leafData.shapeId)],
                                               leafData.childId), xfm0, xfm1);
        // Note: updating leaf here is expensive, avoid when possible!
        if (!Contains(node.GetAABB(), aabb)) {
            m_tree.UpdateLeaf(e, GetDisplacedAABB(GetFattenedAABB(aabb, conf.aabbExtension), displacement));
            m_proxiesForContacts.push_back(e);
            ++updatedCount;
        }
    }
    return updatedCount;
}

void AabbTreeWorld::Update( // NOLINT(readability-function-cognitive-complexity)
    ContactID contactID, const ContactUpdateConf& conf)
{
    assert(IsLocked(*this));
    auto& c = m_contactBuffer[to_underlying(contactID)];
    assert(c.NeedsUpdating());
    auto& manifold = m_manifoldBuffer[to_underlying(contactID)];
    const auto oldManifold = manifold;

    // Note: do not assume the fixture AABBs are overlapping or are valid.
    const auto oldTouching = c.IsTouching();
    auto newTouching = false;

    const auto bodyIdA = GetBodyA(c);
    const auto shapeIdA = GetShapeA(c);
    const auto indexA = GetChildIndexA(c);
    const auto bodyIdB = GetBodyB(c);
    const auto shapeIdB = GetShapeB(c);
    const auto indexB = GetChildIndexB(c);
    const auto& shapeA = m_shapeBuffer[to_underlying(shapeIdA)];
    const auto& shapeB = m_shapeBuffer[to_underlying(shapeIdB)];
    const auto& bodyA = m_bodyBuffer[to_underlying(bodyIdA)];
    const auto& bodyB = m_bodyBuffer[to_underlying(bodyIdB)];
    const auto xfA = GetTransformation(bodyA);
    const auto xfB = GetTransformation(bodyB);
    const auto childA = GetChild(shapeA, indexA);
    const auto childB = GetChild(shapeB, indexB);

    // NOTE: Ideally, the touching state returned by the TestOverlap function
    //   agrees 100% of the time with that returned from the CollideShapes function.
    //   This is not always the case however especially as the separation or overlap
    //   approaches zero.
#define OVERLAP_TOLERANCE (SquareMeter / Real(20))

    const auto sensor = c.IsSensor();
    if (sensor) {
        const auto overlapping = TestOverlap(childA, xfA, childB, xfB, conf.distance);
        newTouching = (overlapping >= 0_m2);
#ifdef OVERLAP_TOLERANCE
#ifndef NDEBUG
        const auto tolerance = OVERLAP_TOLERANCE;
        const auto newManifold = CollideShapes(childA, xfA, childB, xfB, conf.manifold);
        assert(newTouching == (newManifold.GetPointCount() > 0) ||
               abs(overlapping) < tolerance);
#endif
#endif
        // Sensors don't generate manifolds.
        manifold = Manifold{};
    }
    else {
        auto newManifold = CollideShapes(childA, xfA, childB, xfB, conf.manifold);
        const auto old_point_count = oldManifold.GetPointCount();
        const auto new_point_count = newManifold.GetPointCount();
        newTouching = new_point_count > 0;
#ifdef OVERLAP_TOLERANCE
#ifndef NDEBUG
        const auto tolerance = OVERLAP_TOLERANCE;
        const auto overlapping = TestOverlap(childA, xfA, childB, xfB, conf.distance);
        assert(newTouching == (overlapping >= 0_m2) || abs(overlapping) < tolerance);
#endif
#endif
        // Match old contact ids to new contact ids and copy the stored impulses to warm
        // start the solver. Note: missing any opportunities to warm start the solver
        // results in squishier stacking and less stable simulations.
        bool found[2] = {false, new_point_count < 2};
        for (auto i = decltype(new_point_count){0}; i < new_point_count; ++i) {
            const auto new_cf = newManifold.GetContactFeature(i);
            for (auto j = decltype(old_point_count){0}; j < old_point_count; ++j) {
                if (new_cf == oldManifold.GetContactFeature(j)) {
                    found[i] = true;
                    newManifold.SetImpulses(i, oldManifold.GetImpulses(j));
                    break;
                }
            }
        }
        // If warm starting data wasn't found for a manifold point via contact feature
        // matching, it's better to just set the data to whatever old point is closest
        // to the new one.
        for (auto i = decltype(new_point_count){0}; i < new_point_count; ++i) {
            if (!found[i]) {
                auto leastSquareDiff = std::numeric_limits<Area>::infinity();
                const auto newPt = newManifold.GetPoint(i);
                for (auto j = decltype(old_point_count){0}; j < old_point_count; ++j) {
                    const auto oldPt = oldManifold.GetPoint(j);
                    const auto squareDiff = GetMagnitudeSquared(oldPt.localPoint - newPt.localPoint);
                    if (leastSquareDiff > squareDiff) {
                        leastSquareDiff = squareDiff;
                        newManifold.SetImpulses(i, oldManifold.GetImpulses(j));
                    }
                }
            }
        }

        // Ideally this function is **NEVER** called unless a dependency changed such
        // that the following assertion is **ALWAYS** valid.
        //assert(newManifold != oldManifold);

        manifold = newManifold;

#ifdef MAKE_CONTACT_PROCESSING_ORDER_DEPENDENT
        /*
         * The following code creates an ordering dependency in terms of update processing
         * over a container of contacts. It also puts this function into the situation of
         * modifying bodies which adds race potential in a multi-threaded mode of operation.
         * Lastly, without this code, the step-statistics show a world getting to sleep in
         * less TOI position iterations.
         */
        if (newTouching != oldTouching) {
            bodyA.SetAwake();
            bodyB.SetAwake();
        }
#endif
    }

    c.UnflagForUpdating();

    if (!oldTouching && newTouching) {
        c.SetTouching();
        if (m_listeners.beginContact) {
            m_listeners.beginContact(contactID);
        }
    }
    else if (oldTouching && !newTouching) {
        c.UnsetTouching();
        if (m_listeners.endContact) {
            m_listeners.endContact(contactID);
        }
    }

    if (!sensor && newTouching) {
        if (m_listeners.preSolveContact) {
            m_listeners.preSolveContact(contactID, oldManifold);
        }
    }
}

void SetBody(AabbTreeWorld& world, BodyID id, Body value)
{
    if (IsLocked(world)) {
        throw WrongState(worldIsLockedMsg);
    }
    // Validate id and all the new body's shapeIds...
    auto& elem = At(world.m_bodyBuffer, id, noSuchBodyMsg);
    Validate(world.m_shapeBuffer, Span<const ShapeID>(value.GetShapes()), noSuchShapeMsg);
    if (world.m_bodyBuffer.FindFree(to_underlying(id))) {
        throw WasDestroyed{id, idIsDestroyedMsg};
    }
    if (elem.IsDestroyed() != value.IsDestroyed()) {
        throw InvalidArgument("cannot change is-destroyed value");
    }
    auto addToBodiesForSync = false;
    // handle state changes that other data needs to stay in sync with
    if (GetType(elem) != GetType(value)) {
        // Destroy the attached contacts.
        Erase(world.m_bodyContacts[to_underlying(id)], [&world,&elem](ContactID contactID) {
            world.Destroy(contactID, &elem);
            return true;
        });
        switch (value.GetType()) {
        case BodyType::Static: {
#ifndef NDEBUG
            const auto xfm1 = GetTransform0(value.GetSweep());
            const auto xfm2 = GetTransformation(value);
            assert(xfm1 == xfm2);
#endif
            addToBodiesForSync = true;
            break;
        }
        case BodyType::Kinematic:
        case BodyType::Dynamic:
            break;
        }
    }
    const auto shapeIds = GetOldAndNewShapeIDs(elem, value);
    if (!empty(shapeIds.first)) {
        auto& bodyProxies = world.m_bodyProxies[to_underlying(id)];
        const auto lastProxy = end(bodyProxies);
        bodyProxies.erase(std::remove_if(begin(bodyProxies), lastProxy,
                                         [&world,&shapeIds](DynamicTree::Size idx){
            if (Find(shapeIds.first, world.m_tree.GetLeafData(idx).shapeId)) {
                world.m_tree.DestroyLeaf(idx);
                EraseFirst(world.m_proxiesForContacts, idx);
                return true;
            }
            return false;
        }), lastProxy);
    }
    for (auto&& shapeId: shapeIds.first) {
        // Destroy any contacts associated with the fixture.
        Erase(world.m_bodyContacts[to_underlying(id)], [&world,id,shapeId,&elem](ContactID contactID) {
            if (!IsFor(world.m_contactBuffer[to_underlying(contactID)], id, shapeId)) {
                return false;
            }
            world.Destroy(contactID, &elem);
            return true;
        });
        EraseAll(world.m_fixturesForProxies, std::make_pair(id, shapeId));
        DestroyProxies(world.m_tree, id, shapeId, world.m_proxiesForContacts);
    }
    Append(world.m_fixturesForProxies, id, shapeIds.second);
    if (GetTransformation(elem) != GetTransformation(value)) {
        FlagForUpdating(world.m_contactBuffer, world.m_bodyContacts[to_underlying(id)]);
        addToBodiesForSync = true;
    }
    if (addToBodiesForSync) {
        world.m_bodiesForSync.push_back(id);
    }
    elem = std::move(value);
}

void SetContact(AabbTreeWorld& world, ContactID id, Contact value)
{
    // Make sure body identifiers and shape identifiers are valid...
    const auto bodyIdA = GetBodyA(value);
    const auto bodyIdB = GetBodyB(value);
    GetBody(world, bodyIdA);
    GetBody(world, bodyIdB);
    GetChild(GetShape(world, GetShapeA(value)), GetChildIndexA(value));
    GetChild(GetShape(world, GetShapeB(value)), GetChildIndexB(value));
    if (world.m_contactBuffer.FindFree(to_underlying(id))) {
        throw WasDestroyed{id, idIsDestroyedMsg};
    }
    auto &elem = At(world.m_contactBuffer, id, noSuchContactMsg);
    if (elem.IsDestroyed() != value.IsDestroyed()) {
        throw InvalidArgument("cannot change is-destroyed value");
    }
    if (elem.GetContactableA() != value.GetContactableA()) {
        throw InvalidArgument("cannot change contactable A");
    }
    if (elem.GetContactableB() != value.GetContactableB()) {
        throw InvalidArgument("cannot change contactable B");
    }
    if (IsImpenetrable(elem) != IsImpenetrable(value)) {
        throw InvalidArgument("change body A or B being impenetrable to change impenetrable state");
    }
    if (IsSensor(elem) != IsSensor(value)) {
        throw InvalidArgument("change shape A or B being a sensor to change sensor state");
    }
    if (GetToi(elem) != GetToi(value)) {
        throw InvalidArgument("user may not change the TOI");
    }
    if (GetToiCount(elem) != GetToiCount(value)) {
        throw InvalidArgument("user may not change the TOI count");
    }
    elem = value;
}

void SetManifold(AabbTreeWorld& world, ContactID id, const Manifold& value)
{
    auto &manifold = At(world.m_manifoldBuffer, id, noSuchContactMsg);
    if (world.m_manifoldBuffer.FindFree(to_underlying(id))) {
        throw WasDestroyed{id, idIsDestroyedMsg};
    }
    if (manifold.GetType() != value.GetType()) {
        throw InvalidArgument("cannot change manifold type");
    }
    if (manifold.GetPointCount() != value.GetPointCount()) {
        throw InvalidArgument("cannot change manifold point count");
    }
    // Allows user to set normal & tangent impulses.
    manifold = value;
}

const Body& GetBody(const AabbTreeWorld& world, BodyID id)
{
    return At(world.m_bodyBuffer, id, noSuchBodyMsg);
}

const Joint& GetJoint(const AabbTreeWorld& world, JointID id)
{
    return At(world.m_jointBuffer, id, noSuchJointMsg);
}

const Contact& GetContact(const AabbTreeWorld& world, ContactID id)
{
    return At(world.m_contactBuffer, id, noSuchContactMsg);
}

const Manifold& GetManifold(const AabbTreeWorld& world, ContactID id)
{
    return At(world.m_manifoldBuffer, id, noSuchManifoldMsg);
}

ContactID GetSoonestContact(const Span<const KeyedContactID>& ids,
                            const Span<const Contact>& contacts) noexcept
{
    auto found = InvalidContactID;
    auto minToi = UnitIntervalFF<Real>{Real(1)};
    for (const auto& id: ids)
    {
        const auto contactID = std::get<ContactID>(id);
        assert(to_underlying(contactID) < contacts.size());
        const auto& c = contacts[to_underlying(contactID)];
        if (const auto toi = c.GetToi())
        {
            if (minToi > *toi) {
                minToi = *toi;
                found = contactID;
            }
        }
    }
    return found;
}

BodyID CreateBody(AabbTreeWorld& world, const BodyConf& def)
{
    return CreateBody(world, Body{def});
}

void Attach(AabbTreeWorld& world, BodyID id, ShapeID shapeID)
{
    auto body = GetBody(world, id);
    body.Attach(shapeID);
    SetBody(world, id, body);
}

bool Detach(AabbTreeWorld& world, BodyID id, ShapeID shapeID)
{
    auto body = GetBody(world, id);
    if (body.Detach(shapeID)) {
        SetBody(world, id, body);
        return true;
    }
    return false;
}

const std::vector<ShapeID>& GetShapes(const AabbTreeWorld& world, BodyID id)
{
    return GetBody(world, id).GetShapes();
}

} // namespace playrho::d2

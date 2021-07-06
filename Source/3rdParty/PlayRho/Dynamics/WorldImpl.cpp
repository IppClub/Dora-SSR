/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Dynamics/WorldImpl.hpp"

#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Island.hpp"
#include "PlayRho/Dynamics/MovementConf.hpp"
#include "PlayRho/Dynamics/ContactImpulsesList.hpp"

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/RevoluteJointConf.hpp"
#include "PlayRho/Dynamics/Joints/PrismaticJointConf.hpp"
#include "PlayRho/Dynamics/Joints/DistanceJointConf.hpp"
#include "PlayRho/Dynamics/Joints/PulleyJointConf.hpp"
#include "PlayRho/Dynamics/Joints/TargetJointConf.hpp"
#include "PlayRho/Dynamics/Joints/GearJointConf.hpp"
#include "PlayRho/Dynamics/Joints/WheelJointConf.hpp"
#include "PlayRho/Dynamics/Joints/WeldJointConf.hpp"
#include "PlayRho/Dynamics/Joints/FrictionJointConf.hpp"
#include "PlayRho/Dynamics/Joints/RopeJointConf.hpp"
#include "PlayRho/Dynamics/Joints/MotorJointConf.hpp"

#include "PlayRho/Dynamics/Contacts/ConstraintSolverConf.hpp"
#include "PlayRho/Dynamics/Contacts/Contact.hpp"
#include "PlayRho/Dynamics/Contacts/ContactSolver.hpp"
#include "PlayRho/Dynamics/Contacts/VelocityConstraint.hpp"
#include "PlayRho/Dynamics/Contacts/PositionConstraint.hpp"

#include "PlayRho/Collision/Distance.hpp"
#include "PlayRho/Collision/WorldManifold.hpp"
#include "PlayRho/Collision/TimeOfImpact.hpp"
#include "PlayRho/Collision/RayCastOutput.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"

#include "PlayRho/Common/LengthError.hpp"
#include "PlayRho/Common/DynamicMemory.hpp"
#include "PlayRho/Common/FlagGuard.hpp"
#include "PlayRho/Common/WrongState.hpp"

#include <algorithm>
#include <new>
#include <functional>
#include <type_traits>
#include <map>
#include <memory>
#include <set>
#include <vector>

#ifdef DO_PAR_UNSEQ
#include <atomic>
#endif

//#define DO_THREADED
#if defined(DO_THREADED)
#include <future>
#endif

// Enable this macro to enable sorting ID lists like m_contacts. This results in more linearly
// accessed memory. Benchmarking hasn't found a significant performance improvement however but
// it does seem to decrease performance in smaller simulations.
//#define DO_SORT_ID_LISTS

using std::for_each;
using std::remove;
using std::sort;
using std::transform;
using std::unique;

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible<WorldImpl>::value,
              "WorldImpl must be default constructible!");
static_assert(std::is_copy_constructible<WorldImpl>::value,
              "WorldImpl must be copy constructible!");
static_assert(std::is_copy_assignable<WorldImpl>::value,
              "WorldImpl must be copy assignable!");
static_assert(std::is_nothrow_destructible<WorldImpl>::value,
              "WorldImpl must be nothrow destructible!");

using playrho::size;

/// @brief Collection of body constraints.
using BodyConstraints = std::vector<BodyConstraint>;

/// @brief Collection of position constraints.
using PositionConstraints = std::vector<PositionConstraint>;

/// @brief Collection of velocity constraints.
using VelocityConstraints = std::vector<VelocityConstraint>;

/// @brief Contact updating configuration.
struct WorldImpl::ContactUpdateConf
{
    DistanceConf distance; ///< Distance configuration data.
    Manifold::Conf manifold; ///< Manifold configuration data.
};

namespace {

constexpr char idIsDestroyedMsg[] = "ID is destroyed";
constexpr char worldIsLockedMsg[] = "world is locked";

inline void IntegratePositions(const Island::Bodies& bodies, BodyConstraints& constraints, Time h)
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
/// This calls the listener's PostSolve method for all size(contacts) elements of
/// the given array of constraints.
/// @param listener Listener to call.
/// @param constraints Array of m_contactCount contact velocity constraint elements.
inline void Report(const WorldImpl::ImpulsesContactListener& listener,
                   const std::vector<ContactID>& contacts,
                   const VelocityConstraints& constraints,
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
        var.SetPointImpulses(i, point.normalImpulse, point.tangentImpulse);
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
                                         const std::vector<BodyConstraint>& bodies)
{
    auto vp = VelocityPair{Velocity{LinearVelocity2{}, 0_rpm}, Velocity{LinearVelocity2{}, 0_rpm}};

    const auto normal = vc.GetNormal();
    const auto tangent = vc.GetTangent();
    const auto pointCount = vc.GetPointCount();
    const auto bodyA = &bodies[to_underlying(vc.GetBodyA())];
    const auto bodyB = &bodies[to_underlying(vc.GetBodyB())];

    const auto invMassA = bodyA->GetInvMass();
    const auto invRotInertiaA = bodyA->GetInvRotInertia();

    const auto invMassB = bodyB->GetInvMass();
    const auto invRotInertiaB = bodyB->GetInvRotInertia();

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

void WarmStartVelocities(const VelocityConstraints& velConstraints,
                         std::vector<BodyConstraint>& bodies)
{
    for_each(cbegin(velConstraints), cend(velConstraints), [&](const VelocityConstraint& vc) {
        const auto vp = CalcWarmStartVelocityDeltas(vc, bodies);
        const auto bodyA = &bodies[to_underlying(vc.GetBodyA())];
        const auto bodyB = &bodies[to_underlying(vc.GetBodyB())];
        bodyA->SetVelocity(bodyA->GetVelocity() + std::get<0>(vp));
        bodyB->SetVelocity(bodyB->GetVelocity() + std::get<1>(vp));
    });
}

void GetBodyConstraints(std::vector<BodyConstraint>& constraints, const Island::Bodies& bodies,
                        const ArrayAllocator<Body>& bodyBuffer, Time h, MovementConf conf)
{
    assert(size(constraints) == size(bodyBuffer));
    for (const auto& id: bodies) {
        constraints[to_underlying(id)] = GetBodyConstraint(bodyBuffer[to_underlying(id)], h, conf);
    }
}

PositionConstraints GetPositionConstraints(const Island::Contacts& contacts,
                                           const ArrayAllocator<Contact>& contactBuffer,
                                           const ArrayAllocator<Manifold>& manifoldBuffer,
                                           const ArrayAllocator<Shape>& shapeBuffer)
{
    auto constraints = PositionConstraints{};
    constraints.reserve(size(contacts));
    transform(cbegin(contacts), cend(contacts), back_inserter(constraints),
              [&](const auto& contactID) {
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
VelocityConstraints GetVelocityConstraints(const Island::Contacts& contacts,
                                           const ArrayAllocator<Contact>& contactBuffer,
                                           const ArrayAllocator<Manifold>& manifoldBuffer,
                                           const ArrayAllocator<Shape>& shapeBuffer,
                                           const BodyConstraints& bodies,
                                           const VelocityConstraint::Conf conf)
{
    auto velConstraints = VelocityConstraints{};
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
        const auto& shapeA = shapeBuffer[to_underlying(shapeIdA)];
        const auto& shapeB = shapeBuffer[to_underlying(shapeIdB)];
        const auto& bodyConstraintA = bodies[to_underlying(bodyA)];
        const auto& bodyConstraintB = bodies[to_underlying(bodyB)];
        const auto radiusA = GetVertexRadius(shapeA, indexA);
        const auto radiusB = GetVertexRadius(shapeB, indexB);
        const auto xfA = GetTransformation(bodyConstraintA.GetPosition(),
                                           bodyConstraintA.GetLocalCenter());
        const auto xfB = GetTransformation(bodyConstraintB.GetPosition(),
                                           bodyConstraintB.GetLocalCenter());
        const auto& manifold = manifoldBuffer[to_underlying(contactID)];
        const auto worldManifold = GetWorldManifold(manifold, xfA, radiusA, xfB, radiusB);
        return VelocityConstraint{friction, restitution, tangentSpeed, worldManifold,
            bodyA, bodyB, bodies, conf};
    });
    return velConstraints;
}

/// "Solves" the velocity constraints.
/// @details Updates the velocities and velocity constraint points' normal and tangent impulses.
/// @pre <code>UpdateVelocityConstraints</code> has been called on the velocity constraints.
/// @return Maximum momentum used for solving both the tangential and normal portions of
///   the velocity constraints.
Momentum SolveVelocityConstraintsViaGS(VelocityConstraints& velConstraints, BodyConstraints& bodies)
{
    auto maxIncImpulse = 0_Ns;
    for_each(begin(velConstraints), end(velConstraints), [&](VelocityConstraint& vc)
    {
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
Length SolvePositionConstraintsViaGS(PositionConstraints& posConstraints,
                                     BodyConstraints& bodies,
                                     const ConstraintSolverConf& conf)
{
    auto minSeparation = std::numeric_limits<Length>::infinity();

    for_each(begin(posConstraints), end(posConstraints), [&](PositionConstraint &pc) {
        assert(pc.GetBodyA() != pc.GetBodyB()); // Confirms ContactManager::Add() did its job.
        const auto res = GaussSeidel::SolvePositionConstraint(pc, true, true, bodies, conf);
        bodies[to_underlying(pc.GetBodyA())].SetPosition(res.pos_a);
        bodies[to_underlying(pc.GetBodyB())].SetPosition(res.pos_b);
        minSeparation = std::min(minSeparation, res.min_separation);
    });

    return minSeparation;
}

inline Time GetUnderActiveTime(const Body& b, const StepConf& conf) noexcept
{
    const auto underactive = IsUnderActive(b.GetVelocity(), conf.linearSleepTolerance,
                                           conf.angularSleepTolerance);
    const auto sleepable = b.IsSleepingAllowed();
    return (sleepable && underactive)? b.GetUnderActiveTime() + conf.deltaTime: 0_s;
}

inline Time UpdateUnderActiveTimes(const Island::Bodies& bodies,
                                   ArrayAllocator<Body>& bodyBuffer,
                                   const StepConf& conf)
{
    auto minUnderActiveTime = std::numeric_limits<Time>::infinity();
    for_each(cbegin(bodies), cend(bodies), [&](const auto& bodyID)
    {
        auto& b = bodyBuffer[to_underlying(bodyID)];
        if (b.IsSpeedable())
        {
            const auto underActiveTime = GetUnderActiveTime(b, conf);
            b.SetUnderActiveTime(underActiveTime);
            minUnderActiveTime = std::min(minUnderActiveTime, underActiveTime);
        }
    });
    return minUnderActiveTime;
}

inline BodyCounter Sleepem(const Island::Bodies& bodies,
                           ArrayAllocator<Body>& bodyBuffer,
                           ArrayAllocator<WorldImpl::Contacts>& bodyContacts,
                           ArrayAllocator<Contact>& contactBuffer)
{
    auto unawoken = BodyCounter{0};
    for_each(cbegin(bodies), cend(bodies), [&](const auto& bodyID) {
        if (Unawaken(bodyBuffer[to_underlying(bodyID)])) {
            ++unawoken;
            for (auto&& e: bodyContacts[to_underlying(bodyID)]) {
                const auto contactId = std::get<ContactID>(e);
                auto& contact = contactBuffer[to_underlying(contactId)];
                if (contact.GetBodyA() == bodyID) {
                    if (!bodyBuffer[to_underlying(contact.GetBodyB())].IsAwake()) {
                        contact.UnsetIsActive();
                    }
                }
                else {
                    assert(contact.GetBodyB() == bodyID);
                    if (!bodyBuffer[to_underlying(contact.GetBodyA())].IsAwake()) {
                        contact.UnsetIsActive();
                    }
                }
            }
        }
    });
    return unawoken;
}

inline bool IsValidForTime(TOIOutput::State state) noexcept
{
    return state == TOIOutput::e_touching;
}

bool FlagForFiltering(ArrayAllocator<Contact>& contactBuffer, BodyID bodyA,
                      const std::vector<KeyedContactPtr>& contactsBodyB,
                      BodyID bodyB) noexcept
{
    auto anyFlagged = false;
    for (const auto& ci: contactsBodyB) {
        auto& contact = contactBuffer[to_underlying(std::get<ContactID>(ci))];
        const auto bA = contact.GetBodyA();
        const auto bB = contact.GetBodyB();
        const auto other = (bA != bodyB)? bA: bB;
        if (other == bodyA) {
            // Flag the contact for filtering at the next time step (where either
            // body is awake).
            contact.FlagForFiltering();
            anyFlagged = true;
        }
    }
    return anyFlagged;
}

/// @brief Gets the update configuration from the given step configuration data.
WorldImpl::ContactUpdateConf GetUpdateConf(const StepConf& conf) noexcept
{
    return WorldImpl::ContactUpdateConf{GetDistanceConf(conf), GetManifoldConf(conf)};
}

template <typename T>
void FlagForUpdating(ArrayAllocator<Contact>& contactsBuffer, const T& contacts) noexcept
{
    std::for_each(begin(contacts), end(contacts), [&](const auto& ci) {
        contactsBuffer[to_underlying(std::get<ContactID>(ci))].FlagForUpdating();
    });
}

inline bool EitherIsAccelerable(const Body& lhs, const Body& rhs) noexcept
{
    return lhs.IsAccelerable() || rhs.IsAccelerable();
}

bool ShouldCollide(const ArrayAllocator<Joint>& jointBuffer,
                   const ArrayAllocator<WorldImpl::BodyJoints>& bodyJoints,
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

void Unset(std::vector<bool>& islanded, const WorldImpl::Bodies& elements)
{
    for (const auto& element: elements) {
        islanded[to_underlying(element)] = false;
    }
}

void Unset(std::vector<bool>& islanded, const WorldImpl::Contacts& elements)
{
    for (const auto& element: elements) {
        islanded[to_underlying(std::get<ContactID>(element))] = false;
    }
}

/// @brief Reset bodies for solve TOI.
void ResetBodiesForSolveTOI(WorldImpl::Bodies& bodies, ArrayAllocator<Body>& buffer) noexcept
{
    for_each(begin(bodies), end(bodies), [&](const auto& body) {
        buffer[to_underlying(body)].ResetAlpha0();
    });
}

/// @brief Reset contacts for solve TOI.
void ResetBodyContactsForSolveTOI(ArrayAllocator<Contact>& buffer,
                                  const std::vector<KeyedContactPtr>& contacts) noexcept
{
    // Invalidate all contact TOIs on this displaced body.
    for_each(cbegin(contacts), cend(contacts), [&buffer](const auto& ci) {
        auto& contact = buffer[to_underlying(std::get<ContactID>(ci))];
        contact.UnsetToi();
    });
}

/// @brief Reset contacts for solve TOI.
void ResetContactsForSolveTOI(ArrayAllocator<Contact>& buffer,
                              const WorldImpl::Contacts& contacts) noexcept
{
    for_each(begin(contacts), end(contacts), [&buffer](const auto& c) {
        auto& contact = buffer[to_underlying(std::get<ContactID>(c))];
        contact.UnsetToi();
        contact.SetToiCount(0);
    });
}

/// @brief Destroys all of the given fixture's proxies.
void DestroyProxies(DynamicTree& tree,
                    const std::vector<DynamicTree::Size>& fixtureProxies,
                    std::vector<DynamicTree::Size>& proxies) noexcept
{
    const auto childCount = size(fixtureProxies);
    if (childCount > 0) {
        // Destroy proxies in reverse order from what they were created in.
        for (auto i = childCount - 1; i < childCount; --i) {
            const auto treeId = fixtureProxies[i];
            EraseFirst(proxies, treeId);
            tree.DestroyLeaf(treeId);
        }
    }
}

void CreateProxies(DynamicTree& tree,
                   BodyID bodyID, ShapeID shapeID, const Shape& shape,
                   const Transformation& xfm, Length aabbExtension,
                   std::vector<DynamicTree::Size>& fixtureProxies,
                   std::vector<DynamicTree::Size>& otherProxies)
{
    // Reserve proxy space and create proxies in the broad-phase.
    const auto childCount = GetChildCount(shape);
    fixtureProxies.reserve(size(fixtureProxies) + childCount);
    otherProxies.reserve(size(otherProxies) + childCount);
    for (auto childIndex = decltype(childCount){0}; childIndex < childCount; ++childIndex) {
        const auto dp = GetChild(shape, childIndex);
        const auto aabb = playrho::d2::ComputeAABB(dp, xfm);
        const auto fattenedAABB = GetFattenedAABB(aabb, aabbExtension);
        const auto treeId = tree.CreateLeaf(fattenedAABB, DynamicTree::LeafData{
            bodyID, shapeID, childIndex});
        fixtureProxies.push_back(treeId);
        otherProxies.push_back(treeId);
    }
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

void Erase(std::vector<KeyedContactPtr>& contacts, const std::function<bool(ContactID)>& callback)
{
    auto last = end(contacts);
    auto iter = begin(contacts);
    auto index = std::vector<KeyedContactPtr>::difference_type(0);
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

template <class Functor>
void ForProxies(const DynamicTree& tree, BodyID bodyId, ShapeID shapeId, Functor fn)
{
    const auto n = tree.GetNodeCapacity();
    for (auto i = static_cast<decltype(tree.GetNodeCapacity())>(0); i < n; ++i) {
        if (DynamicTree::IsLeaf(tree.GetHeight(i))) {
            const auto leaf = tree.GetLeafData(i);
            if (leaf.body == bodyId && leaf.shape == shapeId) {
                fn(i);
            }
        }
    }
}

std::vector<DynamicTree::Size> FindProxies(const DynamicTree& tree, BodyID bodyId, ShapeID shapeId)
{
    std::vector<DynamicTree::Size> result;
    ForProxies(tree, bodyId, shapeId, [&result](DynamicTree::Size i){
        result.push_back(i);
    });
    return result;
}

std::vector<DynamicTree::Size> FindProxies(const DynamicTree& tree, BodyID bodyId)
{
    std::vector<DynamicTree::Size> result;
    const auto n = tree.GetNodeCapacity();
    for (auto i = static_cast<decltype(tree.GetNodeCapacity())>(0); i < n; ++i) {
        if (DynamicTree::IsLeaf(tree.GetHeight(i))) {
            const auto leaf = tree.GetLeafData(i);
            if (leaf.body == bodyId)
                result.push_back(i);
        }
    }
    return result;
}

std::vector<DynamicTree::Size> FindProxies(const DynamicTree& tree, ShapeID shapeId)
{
    std::vector<DynamicTree::Size> result;
    const auto n = tree.GetNodeCapacity();
    for (auto i = static_cast<decltype(tree.GetNodeCapacity())>(0); i < n; ++i) {
        if (DynamicTree::IsLeaf(tree.GetHeight(i))) {
            const auto leaf = tree.GetLeafData(i);
            if (leaf.shape == shapeId)
                result.push_back(i);
        }
    }
    return result;
}

std::pair<std::vector<ShapeID>, std::vector<ShapeID>>
GetOldAndNewShapeIDs(const Body& oldBody, const Body& newBody)
{
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
    return std::make_pair(oldShapeIds, newShapeIds);
}

} // anonymous namespace

WorldImpl::WorldImpl(const WorldConf& def):
    m_tree(def.treeCapacity),
    m_minVertexRadius{def.minVertexRadius},
    m_maxVertexRadius{def.maxVertexRadius}
{
    if (def.minVertexRadius > def.maxVertexRadius)
    {
        throw InvalidArgument("max vertex radius must be >= min vertex radius");
    }
    m_proxyKeys.reserve(1024);
    m_proxiesForContacts.reserve(1024);
    m_contactBuffer.reserve(def.contactCapacity);
    m_contacts.reserve(def.contactCapacity);
    m_islandedContacts.reserve(def.contactCapacity);
}

WorldImpl::~WorldImpl() noexcept
{
    Clear();
}

void WorldImpl::Clear() noexcept
{
    if (m_jointDestructionListener) {
        for_each(cbegin(m_joints), cend(m_joints), [this](const auto& id) {
            m_jointDestructionListener(id);
        });
    }
    if (m_shapeDestructionListener) {
        for (auto&& shape: m_shapeBuffer) {
            if (shape != Shape{}) {
                m_shapeDestructionListener(static_cast<ShapeID>(
                    static_cast<underlying_type_t<ShapeID>>(&shape - m_shapeBuffer.data())));
            }
        }
    }
    m_contacts.clear();
    m_joints.clear();
    m_bodies.clear();
    m_bodiesForSync.clear();
    m_fixturesForProxies.clear();
    m_proxiesForContacts.clear();
    m_proxyKeys.clear();
    m_tree.Clear();
    m_manifoldBuffer.clear();
    m_contactBuffer.clear();
    m_jointBuffer.clear();
    m_bodyBuffer.clear();
    m_shapeBuffer.clear();
    m_bodyProxies.clear();
    m_bodyContacts.clear();
    m_bodyJoints.clear();
}

BodyCounter WorldImpl::GetBodyRange() const noexcept
{
    return static_cast<BodyCounter>(m_bodyBuffer.size());
}

JointCounter WorldImpl::GetJointRange() const noexcept
{
    return static_cast<JointCounter>(m_jointBuffer.size());
}

ContactCounter WorldImpl::GetContactRange() const noexcept
{
    return static_cast<ContactCounter>(m_contactBuffer.size());
}

BodyID WorldImpl::CreateBody(Body body)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }
    if (size(m_bodies) >= MaxBodies) {
        throw LengthError("CreateBody: operation would exceed MaxBodies");
    }
    // confirm all shapeIds are valid...
    for (const auto& shapeId: body.GetShapes()) {
        m_shapeBuffer.at(to_underlying(shapeId));
    }
    const auto id = static_cast<BodyID>(
        static_cast<BodyID::underlying_type>(m_bodyBuffer.Allocate(body)));
    m_bodyContacts.Allocate();
    m_bodyJoints.Allocate();
    m_bodyProxies.Allocate();
    m_bodies.push_back(id);
    m_bodyConstraints.resize(size(m_bodyBuffer));
    if (IsEnabled(body)) {
        for (const auto& shapeId: body.GetShapes()) {
            m_fixturesForProxies.push_back(std::make_pair(id, shapeId));
        }
        if (!empty(body.GetShapes())) {
            m_flags |= e_newFixture;
        }
    }
    return id;
}

void WorldImpl::Remove(BodyID id) noexcept
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
        m_bodyBuffer.Free(to_underlying(id));
        m_bodyConstraints.resize(size(m_bodyContacts));
    }
}

void WorldImpl::Destroy(BodyID id)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }

    const auto& body = GetBody(id);

    // Delete the attached joints.
    auto& joints = m_bodyJoints[to_underlying(id)];
    while (!joints.empty()) {
        const auto jointID = std::get<JointID>(*begin(joints));
        if (m_jointDestructionListener) {
            m_jointDestructionListener(jointID);
        }
        const auto endIter = cend(m_joints);
        const auto iter = find(cbegin(m_joints), endIter, jointID);
        if (iter != endIter) {
            Remove(jointID); // removes joint from body!
            m_joints.erase(iter);
            m_jointBuffer.Free(to_underlying(jointID));
        }
    }

    // Destroy the attached contacts.
    Erase(m_bodyContacts[to_underlying(id)], [this,&body](ContactID contactID) {
        Destroy(contactID, &body);
        return true;
    });

    for (auto&& shapeId: body.GetShapes()) {
        EraseAll(m_fixturesForProxies, std::make_pair(id, shapeId));
    }

    const auto proxies = FindProxies(m_tree, id);
    for (const auto& proxy: proxies) {
        m_tree.DestroyLeaf(proxy);
    }
    if (m_detachListener) {
        for (const auto& shapeId: body.GetShapes()) {
            m_detachListener(std::make_pair(id, shapeId));
        }
    }
    Remove(id);
}

bool WorldImpl::IsDestroyed(BodyID id) const noexcept
{
    return m_bodyBuffer.FindFree(to_underlying(id));
}

void WorldImpl::SetJoint(JointID id, Joint def)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }
    // Validate the references...
    m_jointBuffer.at(to_underlying(id));
    if (const auto bodyId = GetBodyA(def); bodyId != InvalidBodyID) {
        GetBody(bodyId);
    }
    if (const auto bodyId = GetBodyB(def); bodyId != InvalidBodyID) {
        GetBody(bodyId);
    }
    if (m_jointBuffer.FindFree(to_underlying(id))) {
        throw InvalidArgument(idIsDestroyedMsg);
    }
    Remove(id);
    m_jointBuffer[to_underlying(id)] = def;
    Add(id, !GetCollideConnected(def));
}

JointID WorldImpl::CreateJoint(Joint def)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }
    if (size(m_joints) >= MaxJoints) {
        throw LengthError("CreateJoint: operation would exceed MaxJoints");
    }
    // Validate the referenced bodies...
    if (const auto bodyId = GetBodyA(def); bodyId != InvalidBodyID) {
        GetBody(bodyId);
    }
    if (const auto bodyId = GetBodyB(def); bodyId != InvalidBodyID) {
        GetBody(bodyId);
    }
    const auto id = static_cast<JointID>(
        static_cast<JointID::underlying_type>(m_jointBuffer.Allocate(def)));
    m_joints.push_back(id);
    // Note: creating a joint doesn't wake the bodies.
    Add(id, !GetCollideConnected(def));
    return id;
}

void WorldImpl::Add(JointID id, bool flagForFiltering)
{
    const auto& joint = m_jointBuffer[to_underlying(id)];
    const auto bodyA = GetBodyA(joint);
    const auto bodyB = GetBodyB(joint);
    if (bodyA != InvalidBodyID) {
        m_bodyJoints[to_underlying(bodyA)].push_back(std::make_pair(bodyB, id));
    }
    if (bodyB != InvalidBodyID) {
        m_bodyJoints[to_underlying(bodyB)].push_back(std::make_pair(bodyA, id));
    }
    if (flagForFiltering && (bodyA != InvalidBodyID) && (bodyB != InvalidBodyID)) {
        if (FlagForFiltering(m_contactBuffer, bodyA, m_bodyContacts[to_underlying(bodyB)], bodyB)) {
            m_flags |= e_needsContactFiltering;
        }
    }
}

void WorldImpl::Remove(JointID id) noexcept
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
        bodyA.SetAwake();
        auto& bodyJoints = m_bodyJoints[to_underlying(bodyIdA)];
        const auto found = FindTypeValue(bodyJoints, id);
        assert(found);
        if (found) {
            bodyJoints.erase(*found);
        }
    }
    if (bodyIdB != InvalidBodyID) {
        auto& bodyB = m_bodyBuffer[to_underlying(bodyIdB)];
        bodyB.SetAwake();
        auto& bodyJoints = m_bodyJoints[to_underlying(bodyIdB)];
        const auto found = FindTypeValue(bodyJoints, id);
        assert(found);
        if (found) {
            bodyJoints.erase(*found);
        }
    }
}

void WorldImpl::Destroy(JointID id)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }
    const auto endIter = cend(m_joints);
    const auto iter = find(cbegin(m_joints), endIter, id);
    if (iter != endIter) {
        Remove(id);
        m_joints.erase(iter);
        m_jointBuffer.Free(to_underlying(id));
    }
}

bool WorldImpl::IsDestroyed(JointID id) const noexcept
{
    return m_jointBuffer.FindFree(to_underlying(id));
}

ShapeCounter WorldImpl::GetShapeRange() const noexcept
{
    return static_cast<ShapeCounter>(size(m_shapeBuffer));
}

ShapeID WorldImpl::CreateShape(Shape def)
{
    const auto minVertexRadius = GetMinVertexRadius();
    const auto maxVertexRadius = GetMaxVertexRadius();
    const auto childCount = GetChildCount(def);
    for (auto i = ChildCounter{0}; i < childCount; ++i) {
        const auto vr = GetVertexRadius(def, i);
        if (!(vr >= minVertexRadius)) {
            throw InvalidArgument("CreateShape: vertex radius < min");
        }
        if (!(vr <= maxVertexRadius)) {
            throw InvalidArgument("CreateShape: vertex radius > max");
        }
    }
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }
    if (size(m_shapeBuffer) >= MaxShapes) {
        throw LengthError("CreateShape: operation would exceed MaxShapes");
    }
    return static_cast<ShapeID>(static_cast<ShapeID::underlying_type>(m_shapeBuffer.Allocate(std::move(def))));
}

void WorldImpl::Destroy(ShapeID id)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }
    m_shapeBuffer.at(to_underlying(id)); // confirm id valid.
    const auto numBodies = GetBodyRange();
    for (auto bodyIdx = static_cast<decltype(GetBodyRange())>(0); bodyIdx < numBodies; ++bodyIdx) {
        auto body = m_bodyBuffer[bodyIdx];
        auto n = std::size_t(0);
        while (body.Detach(id)) {
            ++n;
        }
        if (n) {
            SetBody(BodyID(bodyIdx), body);
        }
    }
    m_shapeBuffer.Free(to_underlying(id));
}

const Shape& WorldImpl::GetShape(ShapeID id) const
{
    return m_shapeBuffer.at(to_underlying(id));
}

void WorldImpl::SetShape(ShapeID id, Shape def)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }
    const auto& shape = m_shapeBuffer.at(to_underlying(id));
    if (m_shapeBuffer.FindFree(to_underlying(id))) {
        throw InvalidArgument(idIsDestroyedMsg);
    }
    const auto geometryChanged = [](const Shape& shape0, const Shape& shape1){
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
    }(shape, def);
    for (auto&& b: m_bodyBuffer) {
        for (const auto& shapeId: b.GetShapes()) {
            if (shapeId == id) {
                b.SetAwake();
            }
        }
    }
    if (GetFilter(shape) != GetFilter(def)) {
        auto anyNeedFiltering = false;
        for (auto& c: m_contactBuffer) {
            const auto shapeIdA = GetShapeA(c);
            const auto shapeIdB = GetShapeB(c);
            if (shapeIdA == id || shapeIdB == id) {
                c.FlagForFiltering();
                m_bodyBuffer[to_underlying(c.GetBodyA())].SetAwake();
                m_bodyBuffer[to_underlying(c.GetBodyB())].SetAwake();
                anyNeedFiltering = true;
            }
        }
        if (anyNeedFiltering) {
            m_flags |= e_needsContactFiltering;
        }
        AddProxies(FindProxies(m_tree, id));
    }
    if ((IsSensor(shape) != IsSensor(def)) || (GetFriction(shape) != GetFriction(def)) ||
        (GetRestitution(shape) != GetRestitution(def)) || geometryChanged) {
        for (auto&& c: m_contactBuffer) {
            if (c.GetShapeA() == id || c.GetShapeB() == id) {
                c.FlagForUpdating();
                m_bodyBuffer[to_underlying(c.GetBodyA())].SetAwake();
                m_bodyBuffer[to_underlying(c.GetBodyB())].SetAwake();
            }
        }
    }
    m_shapeBuffer[to_underlying(id)] = std::move(def);
    // TODO: anything else that needs doing?
}

void WorldImpl::AddToIsland(Island& island, BodyID seedID,
                            BodyCounter& remNumBodies,
                            ContactCounter& remNumContacts,
                            JointCounter& remNumJoints)
{
#ifndef NDEBUG
    assert(!m_islandedBodies[to_underlying(seedID)]);
    auto& seed = m_bodyBuffer[to_underlying(seedID)];
    assert(seed.IsSpeedable());
    assert(seed.IsAwake());
    assert(seed.IsEnabled());
    assert(remNumBodies != 0);
    assert(remNumBodies < MaxBodies);
#endif
    // Perform a depth first search (DFS) on the constraint graph.
    // Create a stack for bodies to be is-in-island that aren't already in the island.
    auto bodies = std::vector<BodyID>{};
    bodies.reserve(remNumBodies);
    bodies.push_back(seedID);
    auto stack = BodyStack{std::move(bodies)};
    m_islandedBodies[to_underlying(seedID)] = true;
    AddToIsland(island, stack, remNumBodies, remNumContacts, remNumJoints);
#if DO_SORT_ID_LISTS
    Sort(island);
#endif
}

void WorldImpl::AddToIsland(Island& island, BodyStack& stack,
                            BodyCounter& remNumBodies,
                            ContactCounter& remNumContacts,
                            JointCounter& remNumJoints)
{
    while (!empty(stack)) {
        // Grab the next body off the stack and add it to the island.
        const auto bodyID = stack.top();
        stack.pop();

        auto& body = m_bodyBuffer[to_underlying(bodyID)];

        assert(body.IsEnabled());
        island.bodies.push_back(bodyID);
        assert(remNumBodies > 0);
        --remNumBodies;

        // Don't propagate islands across bodies that can't have a velocity (static bodies).
        // This keeps islands smaller and helps with isolating separable collision clusters.
        if (!body.IsSpeedable()) {
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
        remNumContacts -= netNumContacts;

        const auto numJoints = size(island.joints);
        // Adds appropriate joints of current body and appropriate 'other' bodies of those joint.
        AddJointsToIsland(island, stack, m_bodyJoints[to_underlying(bodyID)]);

        remNumJoints -= size(island.joints) - numJoints;
    }
}

void WorldImpl::AddContactsToIsland(Island& island, BodyStack& stack,
                                    const Contacts& contacts, BodyID bodyID)
{
    for_each(cbegin(contacts), cend(contacts), [&](const KeyedContactPtr& ci) {
        const auto contactID = std::get<ContactID>(ci);
        if (!m_islandedContacts[to_underlying(contactID)]) {
            auto& contact = m_contactBuffer[to_underlying(contactID)];
            if (IsEnabled(contact) && IsTouching(contact) && !IsSensor(contact))
            {
                const auto bodyA = GetBodyA(contact);
                const auto bodyB = GetBodyB(contact);
                const auto other = (bodyID != bodyA)? bodyA: bodyB;
                island.contacts.push_back(contactID);
                m_islandedContacts[to_underlying(contactID)] = true;
                if (!m_islandedBodies[to_underlying(other)])
                {
                    m_islandedBodies[to_underlying(other)] = true;
                    stack.push(other);
                }
            }
        }
    });
}

void WorldImpl::AddJointsToIsland(Island& island, BodyStack& stack, const BodyJoints& joints)
{
    for_each(cbegin(joints), cend(joints), [this,&island,&stack](const auto& ji) {
        const auto jointID = std::get<JointID>(ji);
        assert(jointID != InvalidJointID);
        if (!m_islandedJoints[to_underlying(jointID)]) {
            const auto otherID = std::get<BodyID>(ji);
            const auto other = (otherID == InvalidBodyID)? static_cast<Body*>(nullptr): &m_bodyBuffer[to_underlying(otherID)];
            assert(!other || other->IsEnabled() || !other->IsAwake());
            if (!other || other->IsEnabled())
            {
                m_islandedJoints[to_underlying(jointID)] = true;
                island.joints.push_back(jointID);
                if ((otherID != InvalidBodyID) && !m_islandedBodies[to_underlying(otherID)])
                {
                    m_islandedBodies[to_underlying(otherID)] = true;
                    stack.push(otherID);
                }
            }
        }
    });
}

WorldImpl::Bodies::size_type
WorldImpl::RemoveUnspeedablesFromIslanded(const std::vector<BodyID>& bodies,
                                          const ArrayAllocator<Body>& buffer,
                                          std::vector<bool>& islanded)
{
    // Allow static bodies to participate in other islands.
    auto numRemoved = Bodies::size_type{0};
    for_each(begin(bodies), end(bodies), [&](BodyID id) {
        if (!buffer[to_underlying(id)].IsSpeedable()) {
            islanded[to_underlying(id)] = false;
            ++numRemoved;
        }
    });
    return numRemoved;
}

RegStepStats WorldImpl::SolveReg(const StepConf& conf)
{
    auto stats = RegStepStats{};
    auto remNumBodies = static_cast<BodyCounter>(size(m_bodies)); // Remaining # of bodies.
    auto remNumContacts = static_cast<ContactCounter>(size(m_contacts)); // Remaining # of contacts.
    auto remNumJoints = static_cast<JointCounter>(size(m_joints)); // Remaining # of joints.

    // Clear all the island flags.
    // This builds the logical set of bodies, contacts, and joints eligible for resolution.
    // As bodies, contacts, or joints get added to resolution islands, they're essentially
    // removed from this eligible set.
    m_islandedBodies.clear();
    m_islandedContacts.clear();
    m_islandedJoints.clear();
    m_islandedBodies.resize(size(m_bodyBuffer));
    m_islandedContacts.resize(size(m_contactBuffer));
    m_islandedJoints.resize(size(m_jointBuffer));

#if defined(DO_THREADED)
    std::vector<std::future<IslandStats>> futures;
    futures.reserve(remNumBodies);
#endif
    // Build and simulate all awake islands.
    for (const auto& b: m_bodies) {
        if (!m_islandedBodies[to_underlying(b)]) {
            auto& body = m_bodyBuffer[to_underlying(b)];
            assert(!body.IsAwake() || body.IsSpeedable());
            if (body.IsAwake() && body.IsEnabled()) {
                ++stats.islandsFound;
                ::playrho::d2::Clear(m_island);
                // Size the island for the remaining un-evaluated bodies, contacts, and joints.
                Reserve(m_island, remNumBodies, remNumContacts, remNumJoints);
                AddToIsland(m_island, b, remNumBodies, remNumContacts, remNumJoints);
                stats.maxIslandBodies = std::max(stats.maxIslandBodies,
                                                 static_cast<BodyCounter>(size(m_island.bodies)));
                remNumBodies += RemoveUnspeedablesFromIslanded(m_island.bodies, m_bodyBuffer,
                                                               m_islandedBodies);
#if defined(DO_THREADED)
                // Updates bodies' sweep.pos0 to current sweep.pos1 and bodies' sweep.pos1 to new positions
                futures.push_back(std::async(std::launch::async, &WorldImpl::SolveRegIslandViaGS,
                                             this, conf, m_island));
#else
                const auto solverResults = SolveRegIslandViaGS(conf, m_island);
                ::playrho::Update(stats, solverResults);
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

    for (const auto& b: m_bodies) {
        if (m_islandedBodies[to_underlying(b)]) {
            // A non-static body that was in an island may have moved.
            const auto& body = m_bodyBuffer[to_underlying(b)];
            if (body.IsSpeedable()) {
                // Update fixtures (for broad-phase).
                stats.proxiesMoved += Synchronize(b,
                                                  GetTransform0(body.GetSweep()),
                                                  GetTransformation(body),
                                                  conf.displaceMultiplier, conf.aabbExtension);
            }
        }
    }

    // Look for new contacts.
    stats.contactsAdded = FindNewContacts();

    return stats;
}

IslandStats WorldImpl::SolveRegIslandViaGS(const StepConf& conf, const Island& island)
{
    assert(!empty(island.bodies) || !empty(island.contacts) || !empty(island.joints));

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
    GetBodyConstraints(m_bodyConstraints, island.bodies, m_bodyBuffer, h, GetMovementConf(conf));
    auto posConstraints = GetPositionConstraints(island.contacts, m_contactBuffer,
                                                 m_manifoldBuffer, m_shapeBuffer);
    auto velConstraints = GetVelocityConstraints(island.contacts,
                                                 m_contactBuffer, m_manifoldBuffer, m_shapeBuffer,
                                                 m_bodyConstraints,
                                                 GetRegVelocityConstraintConf(conf));
    if (conf.doWarmStart) {
        WarmStartVelocities(velConstraints, m_bodyConstraints);
    }

    const auto psConf = GetRegConstraintSolverConf(conf);

    for_each(cbegin(island.joints), cend(island.joints), [&](const auto& id) {
        auto& joint = m_jointBuffer[to_underlying(id)];
        InitVelocity(joint, m_bodyConstraints, conf, psConf);
    });

    results.velocityIters = conf.regVelocityIters;
    for (auto i = decltype(conf.regVelocityIters){0}; i < conf.regVelocityIters; ++i) {
        auto jointsOkay = true;
        for_each(cbegin(island.joints), cend(island.joints), [&](const auto& id) {
            auto& joint = m_jointBuffer[to_underlying(id)];
            jointsOkay &= SolveVelocity(joint, m_bodyConstraints, conf);
        });
        // Note that the new incremental impulse can potentially be orders of magnitude
        // greater than the last incremental impulse used in this loop.
        const auto newIncImpulse = SolveVelocityConstraintsViaGS(velConstraints, m_bodyConstraints);
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
    IntegratePositions(island.bodies, m_bodyConstraints, h);

    // Solve position constraints
    for (auto i = decltype(conf.regPositionIters){0}; i < conf.regPositionIters; ++i) {
        const auto minSeparation = SolvePositionConstraintsViaGS(posConstraints, m_bodyConstraints,
                                                                 psConf);
        results.minSeparation = std::min(results.minSeparation, minSeparation);
        const auto contactsOkay = (minSeparation >= conf.regMinSeparation);
        auto jointsOkay = true;
        for_each(cbegin(island.joints), cend(island.joints), [&](const auto& id) {
            auto& joint = m_jointBuffer[to_underlying(id)];
            jointsOkay &= SolvePosition(joint, m_bodyConstraints, psConf);
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
        const auto& bc = m_bodyConstraints[i];
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

    if (m_postSolveContactListener) {
        Report(m_postSolveContactListener, island.contacts, velConstraints,
               results.solved? results.positionIters - 1: StepConf::InvalidIteration);
    }

    results.bodiesSlept = BodyCounter{0};
    const auto minUnderActiveTime = UpdateUnderActiveTimes(island.bodies, m_bodyBuffer, conf);
    if ((minUnderActiveTime >= conf.minStillTimeToSleep) && results.solved) {
        results.bodiesSlept = static_cast<decltype(results.bodiesSlept)>(Sleepem(island.bodies,
                                                                                 m_bodyBuffer,
                                                                                 m_bodyContacts,
                                                                                 m_contactBuffer));
    }

    return results;
}

WorldImpl::UpdateContactsData
WorldImpl::UpdateContactTOIs(const StepConf& conf)
{
    auto results = UpdateContactsData{};

    const auto toiConf = GetToiConf(conf);
    for (const auto& contact: m_contacts)
    {
        auto& c = m_contactBuffer[to_underlying(std::get<ContactID>(contact))];
        if (c.HasValidToi())
        {
            ++results.numValidTOI;
            continue;
        }
        if (!IsEnabled(c) || IsSensor(c) || !IsActive(c) || !IsImpenetrable(c))
        {
            continue;
        }
        if (c.GetToiCount() >= conf.maxSubSteps)
        {
            // What are the pros/cons of this?
            // Larger m_maxSubSteps slows down the simulation.
            // m_maxSubSteps of 44 and higher seems to decrease the occurrance of tunneling
            // of multiple bullet body collisions with static objects.
            ++results.numAtMaxSubSteps;
            continue;
        }

        auto& bA = m_bodyBuffer[to_underlying(c.GetBodyA())];
        auto& bB = m_bodyBuffer[to_underlying(c.GetBodyB())];

        /*
         * Put the sweeps onto the same time interval.
         * Presumably no unresolved collisions happen before the maximum of the bodies'
         * alpha-0 times. So long as the least TOI of the contacts is always the first
         * collision that gets dealt with, this presumption is safe.
         */
        const auto alpha0 = std::max(bA.GetSweep().GetAlpha0(), bB.GetSweep().GetAlpha0());
        assert(alpha0 >= 0 && alpha0 < 1);
        Advance0(bA, alpha0);
        Advance0(bB, alpha0);

        // Compute the TOI for this contact (one or both bodies are active and impenetrable).
        // Computes the time of impact in interval [0, 1]
        const auto proxyA = GetChild(m_shapeBuffer[to_underlying(c.GetShapeA())], c.GetChildIndexA());
        const auto proxyB = GetChild(m_shapeBuffer[to_underlying(c.GetShapeB())], c.GetChildIndexB());

        // Large rotations can make the root finder of TimeOfImpact fail, so normalize sweep angles.
        const auto sweepA = GetNormalized(bA.GetSweep());
        const auto sweepB = GetNormalized(bB.GetSweep());

        // Compute the TOI for this contact (one or both bodies are active and impenetrable).
        // Computes the time of impact in interval [0, 1]
        const auto output = GetToiViaSat(proxyA, sweepA, proxyB, sweepB, toiConf);

        // Use Min function to handle floating point imprecision which possibly otherwise
        // could provide a TOI that's greater than 1.
        const auto toi = IsValidForTime(output.state)?
            std::min(alpha0 + (1 - alpha0) * output.time, Real{1}): Real{1};
        assert(toi >= alpha0 && toi <= 1);
        c.SetToi(toi);

        results.maxDistIters = std::max(results.maxDistIters, output.stats.max_dist_iters);
        results.maxToiIters = std::max(results.maxToiIters, output.stats.toi_iters);
        results.maxRootIters = std::max(results.maxRootIters, output.stats.max_root_iters);
        ++results.numUpdatedTOI;
    }

    return results;
}

WorldImpl::ContactToiData WorldImpl::GetSoonestContact(const Contacts& contacts,
                                                       const ArrayAllocator<Contact>& buffer) noexcept
{
    auto minToi = nextafter(Real{1}, Real{0});
    auto found = InvalidContactID;
    auto count = ContactCounter{0};
    for (const auto& contact: contacts)
    {
        const auto contactID = std::get<ContactID>(contact);
        const auto& c = buffer[to_underlying(contactID)];
        if (c.HasValidToi())
        {
            const auto toi = c.GetToi();
            if (minToi > toi)
            {
                minToi = toi;
                found = contactID;
                count = 1;
            }
            else if (minToi == toi)
            {
                // Have multiple contacts at the current minimum time of impact.
                ++count;
            }
        }
    }
    return ContactToiData{found, minToi, count};
}

ToiStepStats WorldImpl::SolveToi(const StepConf& conf)
{
    auto stats = ToiStepStats{};

    if (IsStepComplete()) {
        ResetBodiesForSolveTOI(m_bodies, m_bodyBuffer);
        Unset(m_islandedBodies, m_bodies);
        ResetContactsForSolveTOI(m_contactBuffer, m_contacts);
        Unset(m_islandedContacts, m_contacts);
    }

    const auto subStepping = GetSubStepping();

    // Find TOI events and solve them.
    for (;;) {
        const auto updateData = UpdateContactTOIs(conf);
        stats.contactsAtMaxSubSteps += updateData.numAtMaxSubSteps;
        stats.contactsUpdatedToi += updateData.numUpdatedTOI;
        stats.maxDistIters = std::max(stats.maxDistIters, updateData.maxDistIters);
        stats.maxRootIters = std::max(stats.maxRootIters, updateData.maxRootIters);
        stats.maxToiIters = std::max(stats.maxToiIters, updateData.maxToiIters);

        const auto next = GetSoonestContact(m_contacts, m_contactBuffer);
        const auto contactID = next.contact;
        const auto ncount = next.simultaneous;
        if (contactID == InvalidContactID) {
            // No more TOI events to handle within the current time step. Done!
            SetStepComplete(true);
            break;
        }

        stats.maxSimulContacts = std::max(stats.maxSimulContacts,
                                          static_cast<decltype(stats.maxSimulContacts)>(ncount));
        stats.contactsFound += ncount;
        auto islandsFound = 0u;
        if (!m_islandedContacts[to_underlying(contactID)]) {
            const auto solverResults = SolveToi(contactID, conf);
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
        for (const auto& b: m_bodies) {
            if (m_islandedBodies[to_underlying(b)]) {
                m_islandedBodies[to_underlying(b)] = false;
                const auto& body = m_bodyBuffer[to_underlying(b)];
                if (IsAccelerable(body)) {
                    stats.proxiesMoved += Synchronize(b,
                                                      GetTransform0(body.GetSweep()),
                                                      GetTransformation(body),
                                                      conf.displaceMultiplier, conf.aabbExtension);
                    const auto& bodyContacts = m_bodyContacts[to_underlying(b)];
                    ResetBodyContactsForSolveTOI(m_contactBuffer, bodyContacts);
                    Unset(m_islandedContacts, bodyContacts);
                }
            }
        }

        // Commit fixture proxy movements to the broad-phase so that new contacts are created.
        // Also, some contacts can be destroyed.
        stats.contactsAdded += FindNewContacts();

        if (subStepping) {
            SetStepComplete(false);
            break;
        }
    }
    return stats;
}

IslandStats WorldImpl::SolveToi(ContactID contactID, const StepConf& conf)
{
    // Note:
    //   This method is what used to be b2World::SolveToi(const b2TimeStep& step).
    //   It also differs internally from Erin's implementation.
    //
    //   Here's some specific behavioral differences:
    //   1. Bodies don't get their under-active times reset (like they do in Erin's code).

    auto contactsUpdated = ContactCounter{0};
    auto contactsSkipped = ContactCounter{0};

    auto& contact = m_contactBuffer[to_underlying(contactID)];

    /*
     * Confirm that contact is as it's supposed to be according to contract of the
     * GetSoonestContacts method from which this contact should have been obtained.
     */
    assert(IsEnabled(contact));
    assert(!IsSensor(contact));
    assert(IsActive(contact));
    assert(IsImpenetrable(contact));
    assert(!m_islandedContacts[to_underlying(contactID)]);

    const auto toi = contact.GetToi();
    const auto bodyIdA = contact.GetBodyA();
    const auto bodyIdB = contact.GetBodyB();
    auto& bA = m_bodyBuffer[to_underlying(bodyIdA)];
    auto& bB = m_bodyBuffer[to_underlying(bodyIdB)];

    {
        const auto backupA = GetSweep(bA);
        const auto backupB = GetSweep(bB);

        // Advance the bodies to the TOI.
        assert(toi != 0 || (GetSweep(bA).GetAlpha0() == 0 && GetSweep(bB).GetAlpha0() == 0));
        Advance(bA, toi);
        Advance(bB, toi);
        FlagForUpdating(m_contactBuffer, m_bodyContacts[to_underlying(bodyIdA)]);
        FlagForUpdating(m_contactBuffer, m_bodyContacts[to_underlying(bodyIdB)]);

        // The TOI contact likely has some new contact points.
        contact.SetEnabled();
        assert(contact.NeedsUpdating());
        Update(contactID, GetUpdateConf(conf));
        ++contactsUpdated;

        contact.UnsetToi();
        contact.IncrementToiCount();

        // Is contact disabled or separated?
        //
        // XXX: Not often, but sometimes, contact.IsTouching() is false now.
        //      Seems like this is a bug, or at least suboptimal, condition.
        //      This method shouldn't be getting called unless contact has an
        //      impact indeed at the given TOI. Seen this happen in an edge-polygon
        //      contact situation where the polygon had a larger than default
        //      vertex radius. CollideShapes had called GetManifoldFaceB which
        //      was failing to see 2 clip points after GetClipPoints was called.
        //assert(contact.IsEnabled() && contact.IsTouching());
        if (!contact.IsEnabled() || !contact.IsTouching()) {
            //contact.UnsetEnabled();
            SetSweep(bA, backupA);
            SetSweep(bB, backupB);
            auto results = IslandStats{};
            results.contactsUpdated += contactsUpdated;
            results.contactsSkipped += contactsSkipped;
            return results;
        }
    }
    if (IsSpeedable(bA)) {
        bA.SetAwakeFlag();
        // XXX should the body's under-active time be reset here?
        //   Erin's code does for here but not in b2World::Solve(const b2TimeStep& step).
        //   Calling Body::ResetUnderActiveTime() has performance implications.
    }
    if (IsSpeedable(bB)) {
        bB.SetAwakeFlag();
        // XXX should the body's under-active time be reset here?
        //   Erin's code does for here but not in b2World::Solve(const b2TimeStep& step).
        //   Calling Body::ResetUnderActiveTime() has performance implications.
    }

    // Build the island
    ::playrho::d2::Clear(m_island);
    ::playrho::d2::Reserve(m_island,
                           static_cast<BodyCounter>(used(m_bodyBuffer)),
                           static_cast<ContactCounter>(used(m_contactBuffer)),
                           static_cast<JointCounter>(0));

     // These asserts get triggered sometimes if contacts within TOI are iterated over.
    assert(!m_islandedBodies[to_underlying(bodyIdA)]);
    assert(!m_islandedBodies[to_underlying(bodyIdB)]);
    m_islandedBodies[to_underlying(bodyIdA)] = true;
    m_islandedBodies[to_underlying(bodyIdB)] = true;
    m_islandedContacts[to_underlying(contactID)] = true;
    m_island.bodies.push_back(bodyIdA);
    m_island.bodies.push_back(bodyIdB);
    m_island.contacts.push_back(contactID);

    // Process the contacts of the two bodies, adding appropriate ones to the island,
    // adding appropriate other bodies of added contacts, and advancing those other
    // bodies sweeps and transforms to the minimum contact's TOI.
    if (IsAccelerable(bA)) {
        const auto procOut = ProcessContactsForTOI(bodyIdA, m_island, toi, conf);
        contactsUpdated += procOut.contactsUpdated;
        contactsSkipped += procOut.contactsSkipped;
    }
    if (IsAccelerable(bB)) {
        const auto procOut = ProcessContactsForTOI(bodyIdB, m_island, toi, conf);
        contactsUpdated += procOut.contactsUpdated;
        contactsSkipped += procOut.contactsSkipped;
    }

#if DO_SORT_ID_LISTS
    Sort(m_island);
#endif
    RemoveUnspeedablesFromIslanded(m_island.bodies, m_bodyBuffer, m_islandedBodies);

    // Now solve for remainder of time step.
    auto subConf = StepConf{conf};
    subConf.deltaTime = (1 - toi) * conf.deltaTime;
    auto results = SolveToiViaGS(m_island, subConf);
    results.contactsUpdated += contactsUpdated;
    results.contactsSkipped += contactsSkipped;
    return results;
}

IslandStats WorldImpl::SolveToiViaGS(const Island& island, const StepConf& conf)
{
    auto results = IslandStats{};

    /*
     * Resets body constraints to what they were right after reg phase processing.
     * Presumably the regular phase resolution has already taken care of updating the
     * body's velocity w.r.t. acceleration and damping such that this call here to get
     * the body constraint doesn't need to pass an elapsed time (and doesn't need to
     * update the velocity from what it already is).
     */
    GetBodyConstraints(m_bodyConstraints, island.bodies, m_bodyBuffer, 0_s, GetMovementConf(conf));

    // Initialize the body state.
    auto posConstraints = GetPositionConstraints(island.contacts, m_contactBuffer,
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
            //   okay tomove. The other one does not.
            //   Calling the selective solver (that takes the two additional arguments) appears
            //   to result in phsyics simulations that are more prone to tunneling. Meanwhile,
            //   using the non-selective solver would presumably be slower (since it appears to
            //   have more that it will do). Assuming that slower is preferable to tunnelling,
            //   then the non-selective function is the one to be calling here.
            //
            const auto minSeparation = SolvePositionConstraintsViaGS(posConstraints,
                                                                     m_bodyConstraints, psConf);
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
        const auto& bc = m_bodyConstraints[to_underlying(id)];
        SetPosition0(m_bodyBuffer[to_underlying(id)], bc.GetPosition());
    }

    auto velConstraints = GetVelocityConstraints(island.contacts,
                                                 m_contactBuffer, m_manifoldBuffer, m_shapeBuffer,
                                                 m_bodyConstraints,
                                                 GetToiVelocityConstraintConf(conf));

    // No warm starting is needed for TOI events because warm
    // starting impulses were applied in the discrete solver.

    // Solve velocity constraints.
    assert(results.maxIncImpulse == 0_Ns);
    results.velocityIters = conf.toiVelocityIters;
    for (auto i = decltype(conf.toiVelocityIters){0}; i < conf.toiVelocityIters; ++i) {
        const auto newIncImpulse = SolveVelocityConstraintsViaGS(velConstraints, m_bodyConstraints);
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

    IntegratePositions(island.bodies, m_bodyConstraints, conf.deltaTime);
    for (const auto& id: island.bodies) {
        const auto i = to_underlying(id);
        auto& body = m_bodyBuffer[i];
        auto& bc = m_bodyConstraints[i];
        body.JustSetVelocity(bc.GetVelocity());
        if (const auto pos = bc.GetPosition(); GetPosition1(body) != pos) {
            SetPosition1(body, pos);
            FlagForUpdating(m_contactBuffer, m_bodyContacts[i]);
        }
    }

    if (m_postSolveContactListener) {
        Report(m_postSolveContactListener, island.contacts, velConstraints, results.positionIters);
    }

    return results;
}

WorldImpl::ProcessContactsOutput
WorldImpl::ProcessContactsForTOI(BodyID id, Island& island, Real toi, const StepConf& conf)
{
    const auto& body = m_bodyBuffer[to_underlying(id)];

    assert(m_islandedBodies[to_underlying(id)]);
    assert(body.IsAccelerable());
    assert(toi >= 0 && toi <= 1);

    auto results = ProcessContactsOutput{};
    assert(results.contactsUpdated == 0);
    assert(results.contactsSkipped == 0);

    const auto updateConf = GetUpdateConf(conf);

    // Note: the original contact (for body of which this method was called) already is-in-island.
    const auto bodyImpenetrable = body.IsImpenetrable();
    for (const auto& ci: m_bodyContacts[to_underlying(id)]) {
        const auto contactID = std::get<ContactID>(ci);
        if (!m_islandedContacts[to_underlying(contactID)]) {
            auto& contact = m_contactBuffer[to_underlying(contactID)];
            if (!contact.IsSensor()) {
                const auto bodyIdA = contact.GetBodyA();
                const auto bodyIdB = contact.GetBodyB();
                const auto otherId = (bodyIdA != id)? bodyIdA: bodyIdB;
                auto& other = m_bodyBuffer[to_underlying(otherId)];
                if (bodyImpenetrable || IsImpenetrable(other)) {
                    const auto otherIslanded = m_islandedBodies[to_underlying(otherId)];
                    {
                        const auto backup = GetSweep(other);
                        if (!otherIslanded /* && GetSweep(other).GetAlpha0() != toi */) {
                            Advance(other, toi);
                            FlagForUpdating(m_contactBuffer, m_bodyContacts[to_underlying(otherId)]);
                        }

                        // Update the contact points
                        contact.SetEnabled();
                        if (contact.NeedsUpdating()) {
                            Update(contactID, updateConf);
                            ++results.contactsUpdated;
                        }
                        else {
                            ++results.contactsSkipped;
                        }

                        // Revert and skip if contact disabled by user or not touching anymore (very possible).
                        if (!contact.IsEnabled() || !contact.IsTouching()) {
                            SetSweep(other, backup);
                            continue;
                        }
                    }
                    island.contacts.push_back(contactID);
                    m_islandedContacts[to_underlying(contactID)] = true;
                    if (!otherIslanded) {
                        if (IsSpeedable(other)) {
                            other.SetAwakeFlag();
                        }
                        island.bodies.push_back(otherId);
                        m_islandedBodies[to_underlying(otherId)] = true;
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

StepStats WorldImpl::Step(const StepConf& conf)
{
    assert((Length{m_maxVertexRadius} * Real{2}) +
           (Length{conf.linearSlop} / Real{4}) > (Length{m_maxVertexRadius} * Real{2}));

    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }

    // "Named return value optimization" (NRVO) will make returning this more efficient.
    auto stepStats = StepStats{};
    {
        FlagGuard<decltype(m_flags)> flagGaurd(m_flags, e_locked);

        for (const auto& [bodyID, shapeID]: m_fixturesForProxies) {
            CreateProxies(m_tree, bodyID, shapeID, m_shapeBuffer[to_underlying(shapeID)],
                          GetTransformation(m_bodyBuffer[to_underlying(bodyID)]),
                          conf.aabbExtension,
                          m_bodyProxies[to_underlying(bodyID)], m_proxiesForContacts);
        }
        m_fixturesForProxies.clear();

        stepStats.pre.proxiesMoved = [this](const StepConf& conf){
            auto proxiesMoved = PreStepStats::counter_type{0};
            for_each(begin(m_bodiesForSync), end(m_bodiesForSync), [&](const auto& bodyID) {
                const auto& b = m_bodyBuffer[to_underlying(bodyID)];
                const auto xfm = GetTransformation(b);
                // Not always true: assert(GetTransform0(b->GetSweep()) == xfm);
                proxiesMoved += Synchronize(bodyID, xfm, xfm,
                                            conf.displaceMultiplier, conf.aabbExtension);
            });
            m_bodiesForSync.clear();
            return proxiesMoved;
        }(conf);
        // pre.proxiesMoved is usually zero but sometimes isn't.

        {
            // Note: this may update bodies (in addition to the contacts container).
            const auto destroyStats = DestroyContacts(m_contacts);
            stepStats.pre.destroyed = destroyStats.overlap + destroyStats.filter;
        }

        if (HasNewFixtures()) {
            UnsetNewFixtures();

            // New fixtures were added: need to find and create the new contacts.
            // Note: this may update bodies (in addition to the contacts container).
            stepStats.pre.added = FindNewContacts();
        }

        if (conf.deltaTime != 0_s) {
            m_inv_dt0 = (conf.deltaTime != 0_s)? Real(1) / conf.deltaTime: 0_Hz;

            // Could potentially run UpdateContacts multithreaded over split lists...
            const auto updateStats = UpdateContacts(conf);
            stepStats.pre.ignored = updateStats.ignored;
            stepStats.pre.updated = updateStats.updated;
            stepStats.pre.skipped = updateStats.skipped;

            // Integrate velocities, solve velocity constraints, and integrate positions.
            if (IsStepComplete()) {
                stepStats.reg = SolveReg(conf);
            }

            // Handle TOI events.
            if (conf.doToi) {
                stepStats.toi = SolveToi(conf);
            }
        }
    }
    return stepStats;
}

void WorldImpl::ShiftOrigin(Length2 newOrigin)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }

    // Optimize for newOrigin being different than current...
    for (const auto& body: m_bodies) {
        auto& b = m_bodyBuffer[to_underlying(body)];
        auto sweep = GetSweep(b);
        sweep.pos0.linear -= newOrigin;
        sweep.pos1.linear -= newOrigin;
        SetSweep(b, sweep);
        FlagForUpdating(m_contactBuffer, m_bodyContacts[to_underlying(body)]);
    }

    for_each(begin(m_joints), end(m_joints), [&](const auto& joint) {
        auto& j = m_jointBuffer[to_underlying(joint)];
        ::playrho::d2::ShiftOrigin(j, newOrigin);
    });

    m_tree.ShiftOrigin(newOrigin);
}

void WorldImpl::InternalDestroy(ContactID contactID, const Body* from)
{
    assert(contactID != InvalidContactID);
    auto& contact = m_contactBuffer[to_underlying(contactID)];
    if (m_endContactListener && contact.IsTouching()) {
        // EndContact hadn't been called in DestroyOrUpdateContacts() since is-touching,
        //  so call it now
        m_endContactListener(contactID);
    }
    const auto bodyIdA = contact.GetBodyA();
    const auto bodyIdB = contact.GetBodyB();
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
    if ((manifold.GetPointCount() > 0) && !contact.IsSensor()) {
        // Contact may have been keeping accelerable bodies of fixture A or B from moving.
        // Need to awaken those bodies now in case they are again movable.
        bodyA->SetAwake();
        bodyB->SetAwake();
    }
    m_contactBuffer.Free(to_underlying(contactID));
    m_manifoldBuffer.Free(to_underlying(contactID));
}

void WorldImpl::Destroy(ContactID contactID, const Body* from)
{
    assert(contactID != InvalidContactID);
    if (const auto found = FindTypeValue(m_contacts, contactID)) {
        m_contacts.erase(*found);
    }
    InternalDestroy(contactID, from);
}

bool WorldImpl::IsDestroyed(ContactID id) const noexcept
{
    return m_contactBuffer.FindFree(to_underlying(id));
}

WorldImpl::DestroyContactsStats WorldImpl::DestroyContacts(Contacts& contacts)
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
                const auto bodyIdA = contact.GetBodyA();
                const auto bodyIdB = contact.GetBodyB();
                const auto& bodyA = m_bodyBuffer[to_underlying(bodyIdA)];
                const auto& bodyB = m_bodyBuffer[to_underlying(bodyIdB)];
                const auto& shapeA = m_shapeBuffer[to_underlying(contact.GetShapeA())];
                const auto& shapeB = m_shapeBuffer[to_underlying(contact.GetShapeB())];
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

WorldImpl::UpdateContactsStats WorldImpl::UpdateContacts(const StepConf& conf)
{
#ifdef DO_PAR_UNSEQ
    atomic<uint32_t> ignored;
    atomic<uint32_t> updated;
    atomic<uint32_t> skipped;
#else
    auto ignored = uint32_t{0};
    auto updated = uint32_t{0};
    auto skipped = uint32_t{0};
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
        const auto& bodyA = m_bodyBuffer[to_underlying(contact.GetBodyA())];
        const auto& bodyB = m_bodyBuffer[to_underlying(contact.GetBodyB())];

        // Awake && speedable (dynamic or kinematic) means collidable.
        // At least one body must be collidable
        assert(!bodyA.IsAwake() || bodyA.IsSpeedable());
        assert(!bodyB.IsAwake() || bodyB.IsSpeedable());
        if (!bodyA.IsAwake() && !bodyB.IsAwake()) {
            // This sometimes fails... is it important?
            //assert(!contact.HasValidToi());
            ++ignored;
            return;
        }

        // Possible that bodyA->GetSweep().GetAlpha0() != 0
        // Possible that bodyB->GetSweep().GetAlpha0() != 0

        // Update the contact manifold and notify the listener.
        contact.SetEnabled();

        // Note: ideally contacts are only updated if there was a change to:
        //   - The fixtures' sensor states.
        //   - The fixtures bodies' transformations.
        //   - The "maxCirclesRatio" per-step configuration state if contact IS NOT for sensor.
        //   - The "maxDistanceIters" per-step configuration state if contact IS for sensor.
        //
        if (contact.NeedsUpdating()) {
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
        static_cast<ContactCounter>(ignored),
        static_cast<ContactCounter>(updated),
        static_cast<ContactCounter>(skipped)
    };
}

ContactCounter WorldImpl::FindNewContacts()
{
    m_proxyKeys.clear();

    // Accumalate contact keys for pairs of nodes that are overlapping and aren't identical.
    // Note that if the dynamic tree node provides the body pointer, it's assumed to be faster
    // to eliminate any node pairs that have the same body here before the key pairs are
    // sorted.
    for_each(cbegin(m_proxiesForContacts), cend(m_proxiesForContacts), [&](ProxyId pid) {
        const auto body0 = m_tree.GetLeafData(pid).body;
        const auto aabb = m_tree.GetAABB(pid);
        Query(m_tree, aabb, [this,pid,body0](ProxyId nodeId) {
            const auto body1 = m_tree.GetLeafData(nodeId).body;
            // A proxy cannot form a pair with itself.
            if ((nodeId != pid) && (body0 != body1)) {
                m_proxyKeys.push_back(ContactKey{nodeId, pid});
            }
            return DynamicTreeOpcode::Continue;
        });
    });
    m_proxiesForContacts.clear();

    // Sort and eliminate any duplicate contact keys.
    sort(begin(m_proxyKeys), end(m_proxyKeys));
    m_proxyKeys.erase(unique(begin(m_proxyKeys), end(m_proxyKeys)), end(m_proxyKeys));

    const auto numContactsBefore = size(m_contacts);
    for_each(cbegin(m_proxyKeys), cend(m_proxyKeys), [&](ContactKey key) {
        Add(key);
    });
    const auto numContactsAfter = size(m_contacts);
    m_islandedContacts.resize(numContactsAfter);
    const auto numContactsAdded = numContactsAfter - numContactsBefore;
#if DO_SORT_ID_LISTS
    if (numContactsAdded > 0u) {
        sort(begin(m_contacts), end(m_contacts), [](const KeyedContactPtr& a, const KeyedContactPtr& b){
            return std::get<ContactID>(a) < std::get<ContactID>(b);
        });
    }
#endif
    return static_cast<ContactCounter>(numContactsAdded);
}

bool WorldImpl::Add(ContactKey key)
{
    const auto minKeyLeafData = m_tree.GetLeafData(key.GetMin());
    const auto maxKeyLeafData = m_tree.GetLeafData(key.GetMax());

    const auto bodyIdA = minKeyLeafData.body;
    const auto shapeIdA = minKeyLeafData.shape;
    const auto indexA = minKeyLeafData.childIndex;
    const auto bodyIdB = maxKeyLeafData.body;
    const auto shapeIdB = maxKeyLeafData.shape;
    const auto indexB = maxKeyLeafData.childIndex;

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
        return false;
    }

#ifndef NO_RACING
    // Code herein may be racey in a multithreaded context...
    // Would need a lock on bodyA, bodyB, and contacts.
    // A global lock on the world instance should work but then would it have so much
    // contention as to make multi-threaded handing of adding new connections senseless?

    // Have to quickly figure out if there's a contact already added for the current
    // fixture-childindex pair that this method's been called for.
    //
    // In cases where there's a bigger bullet-enabled object that's colliding with lots of
    // smaller objects packed tightly together and overlapping like in the Add Pair Stress
    // Test demo that has some 400 smaller objects, the bigger object could have 387 contacts
    // while the smaller object has 369 or more, and the total world contact count can be over
    // 30,495. While searching linearly through the object with less contacts should help,
    // that may still be a lot of contacts to be going through in the context this method
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
    if (FindTypeValue((size(contactsA) < size(contactsB))? contactsA: contactsB, key)) {
        return false;
    }

    if (size(m_contacts) >= MaxContacts) {
        // New contact was needed, but denied due to MaxContacts count being reached.
        return false;
    }

    const auto contactID = static_cast<ContactID>(static_cast<ContactID::underlying_type>(
        m_contactBuffer.Allocate(bodyIdA, shapeIdA, indexA, bodyIdB, shapeIdB, indexB)));
    m_manifoldBuffer.Allocate();
    auto& contact = m_contactBuffer[to_underlying(contactID)];
    if (bodyA.IsImpenetrable() || bodyB.IsImpenetrable()) {
        contact.SetImpenetrable();
    }
    if (bodyA.IsAwake() || bodyB.IsAwake()) {
        contact.SetIsActive();
    }
    if (IsSensor(shapeA) || IsSensor(shapeB)) {
        contact.SetSensor();
    }
    contact.SetFriction(MixFriction(GetFriction(shapeA), GetFriction(shapeB)));
    contact.SetRestitution(MixRestitution(GetRestitution(shapeA), GetRestitution(shapeB)));

    // Insert into the contacts container.
    //
    // Should the new contact be added at front or back?
    //
    // Original strategy added to the front. Since processing done front to back, front
    // adding means container more a LIFO container, while back adding means more a FIFO.
    //
    m_contacts.push_back(KeyedContactPtr{key, contactID});

    // TODO: check contactID unique in contacts containers if !NDEBUG
    contactsA.emplace_back(key, contactID);
    contactsB.emplace_back(key, contactID);

    // Wake up the bodies
    if (!contact.IsSensor()) {
        if (bodyA.IsSpeedable()) {
            bodyA.SetAwakeFlag();
        }
        if (bodyB.IsSpeedable()) {
            bodyB.SetAwakeFlag();
        }
    }
#endif

    return true;
}

const WorldImpl::Proxies& WorldImpl::GetProxies(BodyID id) const
{
    return m_bodyProxies.at(to_underlying(id));
}

WorldImpl::Contacts WorldImpl::GetContacts(BodyID id) const
{
    return m_bodyContacts.at(to_underlying(id));
}

WorldImpl::BodyJoints WorldImpl::GetJoints(BodyID id) const
{
    return m_bodyJoints.at(to_underlying(id));
}

ContactCounter WorldImpl::Synchronize(BodyID bodyId,
                                      const Transformation& xfm1, const Transformation& xfm2,
                                      Real multiplier, Length extension)
{
    auto updatedCount = ContactCounter{0};
    assert(::playrho::IsValid(xfm1));
    assert(::playrho::IsValid(xfm2));
    const auto displacement = multiplier * (xfm2.p - xfm1.p);
    for (auto&& e: m_bodyProxies[to_underlying(bodyId)]) {
        const auto& node = m_tree.GetNode(e);
        const auto leafData = node.AsLeaf();
        const auto aabb = ComputeAABB(GetChild(m_shapeBuffer[to_underlying(leafData.shape)],
                                               leafData.childIndex), xfm1, xfm2);
        if (!Contains(node.GetAABB(), aabb)) {
            const auto newAabb = GetDisplacedAABB(GetFattenedAABB(aabb, extension),
                                                  displacement);
            m_tree.UpdateLeaf(e, newAabb);
            m_proxiesForContacts.push_back(e);
            ++updatedCount;
        }
    }
    return updatedCount;
}

void WorldImpl::Update(ContactID contactID, const ContactUpdateConf& conf)
{
    auto& c = m_contactBuffer[to_underlying(contactID)];
    auto& manifold = m_manifoldBuffer[to_underlying(contactID)];
    const auto oldManifold = manifold;

    // Note: do not assume the fixture AABBs are overlapping or are valid.
    const auto oldTouching = c.IsTouching();
    auto newTouching = false;

    const auto bodyIdA = c.GetBodyA();
    const auto shapeIdA = c.GetShapeA();
    const auto indexA = c.GetChildIndexA();
    const auto bodyIdB = c.GetBodyB();
    const auto shapeIdB = c.GetShapeB();
    const auto indexB = c.GetChildIndexB();
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
                    newManifold.SetContactImpulses(i, oldManifold.GetContactImpulses(j));
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
                        newManifold.SetContactImpulses(i, oldManifold.GetContactImpulses(j));
                    }
                }
            }
        }

        // Ideally this method is **NEVER** called unless a dependency changed such
        // that the following assertion is **ALWAYS** valid.
        //assert(newManifold != oldManifold);

        manifold = newManifold;

#ifdef MAKE_CONTACT_PROCESSING_ORDER_DEPENDENT
        /*
         * The following code creates an ordering dependency in terms of update processing
         * over a container of contacts. It also puts this method into the situation of
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
        if (m_beginContactListener) {
            m_beginContactListener(contactID);
        }
    }
    else if (oldTouching && !newTouching) {
        c.UnsetTouching();
        if (m_endContactListener) {
            m_endContactListener(contactID);
        }
    }

    if (!sensor && newTouching) {
        if (m_preSolveContactListener) {
            m_preSolveContactListener(contactID, oldManifold);
        }
    }
}

void WorldImpl::SetBody(BodyID id, Body value)
{
    if (IsLocked()) {
        throw WrongState(worldIsLockedMsg);
    }
    // confirm id and all shapeIds are valid...
    const auto& body = m_bodyBuffer.at(to_underlying(id));
    for (const auto& shapeId: value.GetShapes()) {
        m_shapeBuffer.at(to_underlying(shapeId));
    }
    if (m_bodyBuffer.FindFree(to_underlying(id))) {
        throw InvalidArgument(idIsDestroyedMsg);
    }

    auto addToBodiesForSync = false;
    // handle state changes that other data needs to stay in sync with
    if (GetType(body) != GetType(value)) {
        // Destroy the attached contacts.
        Erase(m_bodyContacts[to_underlying(id)], [this,&body](ContactID contactID) {
            Destroy(contactID, &body);
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
    auto oldShapeIds = std::vector<ShapeID>{};
    auto newShapeIds = std::vector<ShapeID>{};
    if (IsEnabled(value) && IsEnabled(body)) {
        auto result = GetOldAndNewShapeIDs(body, value);
        oldShapeIds = std::move(result.first);
        newShapeIds = std::move(result.second);
    }
    else if (IsEnabled(value)) {
        newShapeIds = value.GetShapes();
    }
    else if (IsEnabled(body)) {
        oldShapeIds = body.GetShapes();
    }
    if (!empty(oldShapeIds)) {
        auto& bodyProxies = m_bodyProxies[to_underlying(id)];
        const auto lastProxy = end(bodyProxies);
        bodyProxies.erase(std::remove_if(begin(bodyProxies), lastProxy,
                                         [this,&oldShapeIds](DynamicTree::Size idx){
            const auto leafData = m_tree.GetLeafData(idx);
            const auto last = end(oldShapeIds);
            if (std::find(begin(oldShapeIds), last, leafData.shape) != last) {
                m_tree.DestroyLeaf(idx);
                EraseFirst(m_proxiesForContacts, idx);
                return true;
            }
            return false;
        }), lastProxy);
    }
    for (auto&& shapeId: oldShapeIds) {
        // Destroy any contacts associated with the fixture.
        Erase(m_bodyContacts[to_underlying(id)], [this,id,shapeId,&body](ContactID contactID) {
            auto& contact = m_contactBuffer[to_underlying(contactID)];
            const auto bodyIdA = GetBodyA(contact);
            const auto shapeIdA = GetShapeA(contact);
            const auto bodyIdB = GetBodyB(contact);
            const auto shapeIdB = GetShapeB(contact);
            if ((bodyIdA == id && shapeIdA == shapeId) || (bodyIdB == id && shapeIdB == shapeId)) {
                Destroy(contactID, &body);
                return true;
            }
            return false;
        });
        EraseAll(m_fixturesForProxies, std::make_pair(id, shapeId));
        DestroyProxies(m_tree, FindProxies(m_tree, id, shapeId), m_proxiesForContacts);
    }
    for (auto&& shapeId: newShapeIds) {
        m_fixturesForProxies.push_back(std::make_pair(id, shapeId));
    }
    if (!empty(newShapeIds)) {
        m_flags |= e_newFixture;
    }
    if (GetTransformation(body) != GetTransformation(value)) {
        FlagForUpdating(m_contactBuffer, m_bodyContacts[to_underlying(id)]);
        addToBodiesForSync = true;
    }
    if (IsAwake(body) != IsAwake(value)) {
        // Update associated contacts
        if (IsAwake(value)) {
            for (const auto& elem: m_bodyContacts[to_underlying(id)]) {
                m_contactBuffer[to_underlying(std::get<ContactID>(elem))].SetIsActive();
            }
        }
        else { // sleep associated contacts whose other body is also asleep
            for (const auto& elem: m_bodyContacts[to_underlying(id)]) {
                auto& contact = m_contactBuffer[to_underlying(std::get<ContactID>(elem))];
                const auto otherID = (contact.GetBodyA() != id)
                    ? contact.GetBodyA(): contact.GetBodyB();
                if (!m_bodyBuffer[to_underlying(otherID)].IsAwake()) {
                    contact.UnsetIsActive();
                }
            }
        }
    }
    if (addToBodiesForSync) {
        m_bodiesForSync.push_back(id);
    }
    m_bodyBuffer[to_underlying(id)] = std::move(value);
}

void WorldImpl::SetContact(ContactID id, Contact value)
{
    const auto& contact = m_contactBuffer.at(to_underlying(id));

    // Make sure body identifiers and shape identifiers are valid...
    [[maybe_unused]] const auto& bodyA = m_bodyBuffer.at(to_underlying(value.GetBodyA()));
    [[maybe_unused]] const auto& bodyB = m_bodyBuffer.at(to_underlying(value.GetBodyB()));
    [[maybe_unused]] const auto& shapeA = m_shapeBuffer.at(to_underlying(value.GetShapeA()));
    [[maybe_unused]] const auto& shapeB = m_shapeBuffer.at(to_underlying(value.GetShapeB()));

    assert(IsActive(contact) == (IsAwake(bodyA) || IsAwake(bodyB)));
    assert(IsImpenetrable(contact) == (IsImpenetrable(bodyA) || IsImpenetrable(bodyB)));
    assert(IsSensor(contact) == (IsSensor(shapeA) || IsSensor(shapeB)));

    if (m_contactBuffer.FindFree(to_underlying(id))) {
        throw InvalidArgument(idIsDestroyedMsg);
    }
    if (contact.IsActive() != value.IsActive()) {
        throw InvalidArgument("change body A or B being awake to change active state");
    }
    if (contact.IsImpenetrable() != value.IsImpenetrable()) {
        throw InvalidArgument("change body A or B being impenetrable to change impenetrable state");
    }
    if (contact.IsSensor() != value.IsSensor()) {
        throw InvalidArgument("change shape A or B being a sensor to change sensor state");
    }
    if (contact.HasValidToi() != value.HasValidToi()) {
        throw InvalidArgument("user may not change whether contact has a valid TOI");
    }
    if (contact.HasValidToi() && (contact.GetToi() != value.GetToi())) {
        throw InvalidArgument("user may not change the TOI");
    }
    if (contact.GetToiCount() != value.GetToiCount()) {
        throw InvalidArgument("user may not change the TOI count");
    }

    m_contactBuffer[to_underlying(id)] = value;
}

const Body& WorldImpl::GetBody(BodyID id) const
{
    return m_bodyBuffer.at(to_underlying(id));
}

const Joint& WorldImpl::GetJoint(JointID id) const
{
    return m_jointBuffer.at(to_underlying(id));
}

const Contact& WorldImpl::GetContact(ContactID id) const
{
    return m_contactBuffer.at(to_underlying(id));
}

const Manifold& WorldImpl::GetManifold(ContactID id) const
{
    return m_manifoldBuffer.at(to_underlying(id));
}

} // namespace d2
} // namespace playrho

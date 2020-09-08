/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Dynamics/World.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/BodyAtty.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Fixture.hpp"
#include "PlayRho/Dynamics/FixtureAtty.hpp"
#include "PlayRho/Dynamics/FixtureProxy.hpp"
#include "PlayRho/Dynamics/Island.hpp"
#include "PlayRho/Dynamics/JointAtty.hpp"
#include "PlayRho/Dynamics/ContactAtty.hpp"
#include "PlayRho/Dynamics/MovementConf.hpp"
#include "PlayRho/Dynamics/ContactImpulsesList.hpp"

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/JointVisitor.hpp"
#include "PlayRho/Dynamics/Joints/RevoluteJoint.hpp"
#include "PlayRho/Dynamics/Joints/PrismaticJoint.hpp"
#include "PlayRho/Dynamics/Joints/DistanceJoint.hpp"
#include "PlayRho/Dynamics/Joints/PulleyJoint.hpp"
#include "PlayRho/Dynamics/Joints/TargetJoint.hpp"
#include "PlayRho/Dynamics/Joints/GearJoint.hpp"
#include "PlayRho/Dynamics/Joints/WheelJoint.hpp"
#include "PlayRho/Dynamics/Joints/WeldJoint.hpp"
#include "PlayRho/Dynamics/Joints/FrictionJoint.hpp"
#include "PlayRho/Dynamics/Joints/RopeJoint.hpp"
#include "PlayRho/Dynamics/Joints/MotorJoint.hpp"

#include "PlayRho/Dynamics/Contacts/Contact.hpp"
#include "PlayRho/Dynamics/Contacts/ContactSolver.hpp"
#include "PlayRho/Dynamics/Contacts/VelocityConstraint.hpp"
#include "PlayRho/Dynamics/Contacts/PositionConstraint.hpp"

#include "PlayRho/Collision/WorldManifold.hpp"
#include "PlayRho/Collision/TimeOfImpact.hpp"
#include "PlayRho/Collision/RayCastOutput.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"

#include "PlayRho/Common/LengthError.hpp"
#include "PlayRho/Common/DynamicMemory.hpp"
#include "PlayRho/Common/FlagGuard.hpp"
#include "PlayRho/Common/WrongState.hpp"

#include <algorithm>
#include <new>
#include <functional>
#include <type_traits>
#include <memory>
#include <set>
#include <vector>
#include <unordered_map>

#ifdef DO_PAR_UNSEQ
#include <atomic>
#endif

//#define DO_THREADED
#if defined(DO_THREADED)
#include <future>
#endif

#define PLAYRHO_MAGIC(x) (x)

using std::for_each;
using std::remove;
using std::sort;
using std::transform;
using std::unique;

namespace playrho {
namespace d2 {

using playrho::size;

/// @brief Body pointer alias.
using BodyPtr = Body*;

/// @brief A body pointer and body constraint pointer pair.
using BodyConstraintsPair = std::pair<const Body* const, BodyConstraint*>;

/// @brief Collection of body constraints.
using BodyConstraints = std::vector<BodyConstraint>;

/// @brief Collection of position constraints.
using PositionConstraints = std::vector<PositionConstraint>;

/// @brief Collection of velocity constraints.
using VelocityConstraints = std::vector<VelocityConstraint>;

namespace {
    
    inline void IntegratePositions(BodyConstraints& bodies, Time h)
    {
        assert(IsValid(h));
        for_each(begin(bodies), end(bodies), [&](BodyConstraint& bc) {
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
    inline void Report(ContactListener& listener,
                       Span<Contact*> contacts,
                       const VelocityConstraints& constraints,
                       StepConf::iteration_type solved)
    {
        const auto numContacts = size(contacts);
        for (auto i = decltype(numContacts){0}; i < numContacts; ++i)
        {
            listener.PostSolve(*contacts[i], GetContactImpulses(constraints[i]), solved);
        }
    }
    
    inline void AssignImpulses(Manifold& var, const VelocityConstraint& vc)
    {
        assert(var.GetPointCount() >= vc.GetPointCount());
        
        auto assignProc = [&](VelocityConstraint::size_type i) {
            var.SetPointImpulses(i, GetNormalImpulseAtPoint(vc, i), GetTangentImpulseAtPoint(vc, i));
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
    
    inline void WarmStartVelocities(const VelocityConstraints& velConstraints)
    {
        for_each(cbegin(velConstraints), cend(velConstraints),
                      [&](const VelocityConstraint& vc) {
            const auto vp = CalcWarmStartVelocityDeltas(vc);
            const auto bodyA = vc.GetBodyA();
            const auto bodyB = vc.GetBodyB();
            bodyA->SetVelocity(bodyA->GetVelocity() + std::get<0>(vp));
            bodyB->SetVelocity(bodyB->GetVelocity() + std::get<1>(vp));
        });
    }

    BodyConstraintsMap GetBodyConstraintsMap(const Island::Bodies& bodies,
                                             BodyConstraints &bodyConstraints)
    {
        auto map = BodyConstraintsMap{};
        map.reserve(size(bodies));
        for_each(cbegin(bodies), cend(bodies), [&](const BodyPtr& body) {
            const auto i = static_cast<size_t>(&body - data(bodies));
            assert(i < size(bodies));
#ifdef USE_VECTOR_MAP
            map.push_back(BodyConstraintPair{body, &bodyConstraints[i]});
#else
            map[body] = &bodyConstraints[i];
#endif
        });
#ifdef USE_VECTOR_MAP
        sort(begin(map), end(map), [](BodyConstraintPair a, BodyConstraintPair b) {
            return std::get<const Body*>(a) < std::get<const Body*>(b);
        });
#endif
        return map;
    }
    
    BodyConstraints GetBodyConstraints(const Island::Bodies& bodies, Time h, MovementConf conf)
    {
        auto constraints = BodyConstraints{};
        constraints.reserve(size(bodies));
        transform(cbegin(bodies), cend(bodies), back_inserter(constraints), [&](const BodyPtr &b) {
            return GetBodyConstraint(*b, h, conf);
        });
        return constraints;
    }

    PositionConstraints GetPositionConstraints(const Island::Contacts& contacts,
                                               BodyConstraintsMap& bodies)
    {
        auto constraints = PositionConstraints{};
        constraints.reserve(size(contacts));
        transform(cbegin(contacts), cend(contacts), back_inserter(constraints), [&](const Contact *contact) {
            const auto& manifold = static_cast<const Contact*>(contact)->GetManifold();
            
            const auto& fixtureA = *(GetFixtureA(*contact));
            const auto& fixtureB = *(GetFixtureB(*contact));
            const auto indexA = GetChildIndexA(*contact);
            const auto indexB = GetChildIndexB(*contact);

            const auto bodyA = GetBodyA(*contact);
            const auto shapeA = fixtureA.GetShape();
            
            const auto bodyB = GetBodyB(*contact);
            const auto shapeB = fixtureB.GetShape();
            
            const auto bodyConstraintA = At(bodies, bodyA);
            const auto bodyConstraintB = At(bodies, bodyB);
            
            const auto radiusA = GetVertexRadius(shapeA, indexA);
            const auto radiusB = GetVertexRadius(shapeB, indexB);
            
            return PositionConstraint{
                manifold, *bodyConstraintA, radiusA, *bodyConstraintB, radiusB
            };
        });
        return constraints;
    }

    /// @brief Gets the velocity constraints for the given inputs.
    /// @details Inializes the velocity constraints with the position dependent portions of
    ///   the current position constraints.
    /// @post Velocity constraints will have their "normal" field set to the world manifold
    ///   normal for them.
    /// @post Velocity constraints will have their constraint points set.
    /// @sa SolveVelocityConstraints.
    VelocityConstraints GetVelocityConstraints(const Island::Contacts& contacts,
                                               BodyConstraintsMap& bodies,
                                               const VelocityConstraint::Conf conf)
    {
        auto velConstraints = VelocityConstraints{};
        velConstraints.reserve(size(contacts));
        transform(cbegin(contacts), cend(contacts), back_inserter(velConstraints), [&](const ContactPtr& contact) {
            const auto& manifold = contact->GetManifold();
            const auto fixtureA = contact->GetFixtureA();
            const auto fixtureB = contact->GetFixtureB();
            const auto friction = contact->GetFriction();
            const auto restitution = contact->GetRestitution();
            const auto tangentSpeed = contact->GetTangentSpeed();
            const auto indexA = GetChildIndexA(*contact);
            const auto indexB = GetChildIndexB(*contact);

            const auto bodyA = fixtureA->GetBody();
            const auto shapeA = fixtureA->GetShape();
            
            const auto bodyB = fixtureB->GetBody();
            const auto shapeB = fixtureB->GetShape();
            
            const auto bodyConstraintA = At(bodies, bodyA);
            const auto bodyConstraintB = At(bodies, bodyB);
            
            const auto radiusA = GetVertexRadius(shapeA, indexA);
            const auto radiusB = GetVertexRadius(shapeB, indexB);
    
            const auto xfA = GetTransformation(bodyConstraintA->GetPosition(),
                                               bodyConstraintA->GetLocalCenter());
            const auto xfB = GetTransformation(bodyConstraintB->GetPosition(),
                                               bodyConstraintB->GetLocalCenter());
            const auto worldManifold = GetWorldManifold(manifold, xfA, radiusA, xfB, radiusB);

            return VelocityConstraint{friction, restitution, tangentSpeed, worldManifold,
                *bodyConstraintA, *bodyConstraintB, conf};
        });
        return velConstraints;
    }

    /// "Solves" the velocity constraints.
    /// @details Updates the velocities and velocity constraint points' normal and tangent impulses.
    /// @pre <code>UpdateVelocityConstraints</code> has been called on the velocity constraints.
    /// @return Maximum momentum used for solving both the tangential and normal portions of
    ///   the velocity constraints.
    Momentum SolveVelocityConstraintsViaGS(VelocityConstraints& velConstraints)
    {
        auto maxIncImpulse = 0_Ns;
        for_each(begin(velConstraints), end(velConstraints), [&](VelocityConstraint& vc)
        {
            maxIncImpulse = std::max(maxIncImpulse, GaussSeidel::SolveVelocityConstraint(vc));
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
                                    ConstraintSolverConf conf)
    {
        auto minSeparation = std::numeric_limits<Length>::infinity();
        
        for_each(begin(posConstraints), end(posConstraints), [&](PositionConstraint &pc) {
            assert(pc.GetBodyA() != pc.GetBodyB()); // Confirms ContactManager::Add() did its job.
            const auto res = GaussSeidel::SolvePositionConstraint(pc, true, true, conf);
            pc.GetBodyA()->SetPosition(res.pos_a);
            pc.GetBodyB()->SetPosition(res.pos_b);
            minSeparation = std::min(minSeparation, res.min_separation);
        });
        
        return minSeparation;
    }
    
#if 0
    /// Solves the given position constraints.
    ///
    /// @details This updates positions (and nothing else) for the two bodies identified by the
    ///   given indexes by calling the position constraint solving function.
    ///
    /// @note Can't expect the returned minimum separation to be greater than or equal to
    ///  <code>ConstraintSolverConf.max_separation</code> because code won't push the separation
    ///   above this amount to begin with.
    ///
    /// @param positionConstraints Positions constraints.
    /// @param bodyConstraintA Pointer to body constraint for body A.
    /// @param bodyConstraintB Pointer to body constraint for body B.
    /// @param conf Configuration for solving the constraint.
    ///
    /// @return Minimum separation (which is the same as the max amount of penetration/overlap).
    ///
    Length SolvePositionConstraints(PositionConstraints& posConstraints,
                                    const BodyConstraint* bodyConstraintA, const BodyConstraint* bodyConstraintB,
                                    ConstraintSolverConf conf)
    {
        auto minSeparation = std::numeric_limits<Length>::infinity();
        
        for_each(begin(posConstraints), end(posConstraints), [&](PositionConstraint &pc) {
            const auto moveA = (pc.GetBodyA() == bodyConstraintA) || (pc.GetBodyA() == bodyConstraintB);
            const auto moveB = (pc.GetBodyB() == bodyConstraintA) || (pc.GetBodyB() == bodyConstraintB);
            const auto res = SolvePositionConstraint(pc, moveA, moveB, conf);
            pc.GetBodyA()->SetPosition(res.pos_a);
            pc.GetBodyB()->SetPosition(res.pos_b);
            minSeparation = std::min(minSeparation, res.min_separation);
        });
        
        return minSeparation;
    }
#endif
    
    inline Time GetUnderActiveTime(const Body& b, const StepConf& conf) noexcept
    {
        const auto underactive = IsUnderActive(b.GetVelocity(), conf.linearSleepTolerance,
                                               conf.angularSleepTolerance);
        const auto sleepable = b.IsSleepingAllowed();
        return (sleepable && underactive)? b.GetUnderActiveTime() + conf.GetTime(): 0_s;
    }

    inline Time UpdateUnderActiveTimes(const Island::Bodies& bodies, const StepConf& conf)
    {
        auto minUnderActiveTime = std::numeric_limits<Time>::infinity();
        for_each(cbegin(bodies), cend(bodies), [&](Body *b)
        {
            if (b->IsSpeedable())
            {
                const auto underActiveTime = GetUnderActiveTime(*b, conf);
                b->SetUnderActiveTime(underActiveTime);
                minUnderActiveTime = std::min(minUnderActiveTime, underActiveTime);
            }
        });
        return minUnderActiveTime;
    }
    
    inline BodyCounter Sleepem(const Island::Bodies& bodies)
    {
        auto unawoken = BodyCounter{0};
        for_each(cbegin(bodies), cend(bodies), [&](Body *b)
        {
            if (Unawaken(*b))
            {
                ++unawoken;
            }
        });
        return unawoken;
    }
    
    inline bool IsValidForTime(TOIOutput::State state) noexcept
    {
        return state == TOIOutput::e_touching;
    }
    
    void FlagContactsForFiltering(const Body& bodyA, const Body& bodyB) noexcept
    {
        for (auto& ci: bodyB.GetContacts())
        {
            const auto contact = GetContactPtr(ci);
            const auto fA = contact->GetFixtureA();
            const auto fB = contact->GetFixtureB();
            const auto bA = fA->GetBody();
            const auto bB = fB->GetBody();
            const auto other = (bA != &bodyB)? bA: bB;
            if (other == &bodyA)
            {
                // Flag the contact for filtering at the next time step (where either
                // body is awake).
                contact->FlagForFiltering();
            }
        }
    }
    
} // anonymous namespace

World::World(const WorldConf& def):
    m_tree{def.initialTreeSize},
    m_minVertexRadius{def.minVertexRadius},
    m_maxVertexRadius{def.maxVertexRadius}
{
    if (def.minVertexRadius > def.maxVertexRadius)
    {
        throw InvalidArgument("max vertex radius must be >= min vertex radius");
    }
    m_proxyKeys.reserve(1024);
    m_proxies.reserve(1024);
}

World::World(const World& other):
    m_tree{other.m_tree},
    m_destructionListener{other.m_destructionListener},
    m_contactListener{other.m_contactListener},
    m_flags{other.m_flags},
    m_inv_dt0{other.m_inv_dt0},
    m_minVertexRadius{other.m_minVertexRadius},
    m_maxVertexRadius{other.m_maxVertexRadius}
{
    auto bodyMap = std::map<const Body*, Body*>();
    auto fixtureMap = std::map<const Fixture*, Fixture*>();
    CopyBodies(bodyMap, fixtureMap, other.GetBodies());
    CopyJoints(bodyMap, other.GetJoints());
    CopyContacts(bodyMap, fixtureMap, other.GetContacts());
}

World& World::operator= (const World& other)
{
    Clear();
    
    m_destructionListener = other.m_destructionListener;
    m_contactListener = other.m_contactListener;
    m_flags = other.m_flags;
    m_inv_dt0 = other.m_inv_dt0;
    m_minVertexRadius = other.m_minVertexRadius;
    m_maxVertexRadius = other.m_maxVertexRadius;
    m_tree = other.m_tree;

    auto bodyMap = std::map<const Body*, Body*>();
    auto fixtureMap = std::map<const Fixture*, Fixture*>();
    CopyBodies(bodyMap, fixtureMap, other.GetBodies());
    CopyJoints(bodyMap, other.GetJoints());
    CopyContacts(bodyMap, fixtureMap, other.GetContacts());

    return *this;
}
    
World::~World() noexcept
{
    InternalClear();
}

void World::Clear()
{
    if (IsLocked())
    {
        throw WrongState("World::Clear: world is locked");
    }
    InternalClear();
}

void World::InternalClear() noexcept
{
    m_proxyKeys.clear();
    m_proxies.clear();
    m_fixturesForProxies.clear();
    m_bodiesForProxies.clear();

    for_each(cbegin(m_joints), cend(m_joints), [&](const Joint *j) {
        if (m_destructionListener)
        {
            m_destructionListener->SayGoodbye(*j);
        }
        JointAtty::Destroy(j);
    });
    for_each(begin(m_bodies), end(m_bodies), [&](Bodies::value_type& body) {
        auto& b = GetRef(body);
        BodyAtty::ClearContacts(b);
        BodyAtty::ClearJoints(b);
        BodyAtty::ForallFixtures(b, [&](Fixture& fixture) {
            if (m_destructionListener)
            {
                m_destructionListener->SayGoodbye(fixture);
            }
            DestroyProxies(m_proxies, m_tree, fixture);
        });
        BodyAtty::ClearFixtures(b);
    });

    for_each(cbegin(m_bodies), cend(m_bodies), [&](const Bodies::value_type& b) {
        BodyAtty::Delete(GetPtr(b));
    });
    for_each(cbegin(m_contacts), cend(m_contacts), [&](const Contacts::value_type& c){
        delete GetPtr(std::get<Contact*>(c));
    });

    m_bodies.clear();
    m_joints.clear();
    m_contacts.clear();
}

void World::CopyBodies(std::map<const Body*, Body*>& bodyMap,
                       std::map<const Fixture*, Fixture*>& fixtureMap,
                       SizedRange<World::Bodies::const_iterator> range)
{
    for (const auto& otherBody: range)
    {
        const auto newBody = CreateBody(GetBodyConf(GetRef(otherBody)));
        for (const auto& of: GetRef(otherBody).GetFixtures())
        {
            const auto& otherFixture = GetRef(of);
            const auto shape = otherFixture.GetShape();
            const auto fixtureConf = GetFixtureConf(otherFixture);
            const auto newFixture = FixtureAtty::Create(*newBody, fixtureConf, shape);
            BodyAtty::AddFixture(*newBody, newFixture);
            fixtureMap[&otherFixture] = newFixture;
            const auto childCount = otherFixture.GetProxyCount();
            auto proxies = std::make_unique<FixtureProxy[]>(childCount);
            for (auto childIndex = decltype(childCount){0}; childIndex < childCount; ++childIndex)
            {
                const auto fp = otherFixture.GetProxy(childIndex);
                proxies[childIndex] = FixtureProxy{fp.treeId};
                const auto newData = DynamicTree::LeafData{newBody, newFixture, childIndex};
                m_tree.SetLeafData(fp.treeId, newData);
            }
            FixtureAtty::SetProxies(*newFixture, std::move(proxies), childCount);
        }
        newBody->SetMassData(GetMassData(GetRef(otherBody)));
        bodyMap[GetPtr(otherBody)] = newBody;
    }
}

void World::CopyContacts(const std::map<const Body*, Body*>& bodyMap,
                         const std::map<const Fixture*, Fixture*>& fixtureMap,
                         SizedRange<World::Contacts::const_iterator> range)
{
    for (const auto& contact: range)
    {
        auto& otherContact = GetRef(std::get<Contact*>(contact));
        const auto otherFixtureA = otherContact.GetFixtureA();
        const auto otherFixtureB = otherContact.GetFixtureB();
        const auto childIndexA = otherContact.GetChildIndexA();
        const auto childIndexB = otherContact.GetChildIndexB();
        const auto newFixtureA = fixtureMap.at(otherFixtureA);
        const auto newFixtureB = fixtureMap.at(otherFixtureB);
        const auto newBodyA = bodyMap.at(otherFixtureA->GetBody());
        const auto newBodyB = bodyMap.at(otherFixtureB->GetBody());
        const auto newContact = new Contact{newFixtureA, childIndexA, newFixtureB, childIndexB};
        assert(newContact);
        if (newContact)
        {
            const auto key = std::get<ContactKey>(contact);
            m_contacts.push_back(KeyedContactPtr{key, newContact});

            BodyAtty::Insert(*newBodyA, key, newContact);
            BodyAtty::Insert(*newBodyB, key, newContact);
            // No need to wake up the bodies - this should already be done due to above copy
            
            newContact->SetFriction(otherContact.GetFriction());
            newContact->SetRestitution(otherContact.GetRestitution());
            newContact->SetTangentSpeed(otherContact.GetTangentSpeed());
            auto& manifold = ContactAtty::GetMutableManifold(*newContact);
            manifold = otherContact.GetManifold();
            ContactAtty::CopyFlags(*newContact, otherContact);
            if (otherContact.HasValidToi())
            {
                ContactAtty::SetToi(*newContact, otherContact.GetToi());
            }
            ContactAtty::SetToiCount(*newContact, otherContact.GetToiCount());
        }
    }
}

void World::CopyJoints(const std::map<const Body*, Body*>& bodyMap,
                       SizedRange<World::Joints::const_iterator> range)
{
    class JointCopier: public ConstJointVisitor
    {
    public:
        
        JointCopier(World& w, std::map<const Body*, Body*> bodies):
            world{w}, bodyMap{std::move(bodies)}
        {
            // Intentionally empty.
        }

        void Visit(const RevoluteJoint& oldJoint) override
        {
            auto def = GetRevoluteJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }
        
        void Visit(const PrismaticJoint& oldJoint) override
        {
            auto def = GetPrismaticJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }

        void Visit(const DistanceJoint& oldJoint) override
        {
            auto def = GetDistanceJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }
        
        void Visit(const PulleyJoint& oldJoint) override
        {
            auto def = GetPulleyJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }
        
        void Visit(const TargetJoint& oldJoint) override
        {
            auto def = GetTargetJointConf(oldJoint);
            def.bodyA = (def.bodyA)? bodyMap.at(def.bodyA): nullptr;
            def.bodyB = (def.bodyB)? bodyMap.at(def.bodyB): nullptr;
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }
        
        void Visit(const GearJoint& oldJoint) override
        {
            auto def = GetGearJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            def.joint1 = jointMap.at(def.joint1);
            def.joint2 = jointMap.at(def.joint2);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }

        void Visit(const WheelJoint& oldJoint) override
        {
            auto def = GetWheelJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }

        void Visit(const WeldJoint& oldJoint) override
        {
            auto def = GetWeldJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }

        void Visit(const FrictionJoint& oldJoint) override
        {
            auto def = GetFrictionJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }

        void Visit(const RopeJoint& oldJoint) override
        {
            auto def = GetRopeJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }

        void Visit(const MotorJoint& oldJoint) override
        {
            auto def = GetMotorJointConf(oldJoint);
            def.bodyA = bodyMap.at(def.bodyA);
            def.bodyB = bodyMap.at(def.bodyB);
            jointMap[&oldJoint] = Add(JointAtty::Create(def));
        }
        
        Joint* Add(Joint* newJoint)
        {
            world.Add(newJoint);
            return newJoint;
        }

        World& world;
        const std::map<const Body*, Body*> bodyMap;
        std::map<const Joint*, Joint*> jointMap;
    };

    auto copier = JointCopier{*this, bodyMap};
    auto jointMap = std::map<const Joint*, Joint*>();
    for (const auto& otherJoint: range)
    {
        otherJoint->Accept(copier);
    }
}

Body* World::CreateBody(const BodyConf& def)
{
    if (IsLocked())
    {
        throw WrongState("World::CreateBody: world is locked");
    }

    if (size(m_bodies) >= MaxBodies)
    {
        throw LengthError("World::CreateBody: operation would exceed MaxBodies");
    }
    
    auto& b = *BodyAtty::CreateBody(this, def);

    // Add to world bodies collection.
    //
    // Note: the order in which bodies are added matters! At least in-so-far as
    //   causing different results to occur when adding to the back vs. adding to
    //   the front. The World TilesComeToRest unit test for example runs faster
    //   with bodies getting added to the back (than when bodies are added to the
    //   front).
    //
    m_bodies.push_back(&b);

    return &b;
}

void World::Remove(const Body& b) noexcept
{
    UnregisterForProxies(b);
    const auto it = find_if(cbegin(m_bodies), cend(m_bodies), [&](const Bodies::value_type& body) {
        return GetPtr(body) == &b;
    });
    if (it != end(m_bodies))
    {
        BodyAtty::Delete(GetPtr(*it));
        m_bodies.erase(it);
    }
}

void World::Destroy(Body* body)
{
    assert(body);
    assert(body->GetWorld() == this);
    
    if (IsLocked())
    {
        throw WrongState("World::Destroy: world is locked");
    }
    
    // Delete the attached joints.
    BodyAtty::ClearJoints(*body, [&](Joint& joint) {
        if (m_destructionListener)
        {
            m_destructionListener->SayGoodbye(joint);
        }
        InternalDestroy(joint);
    });
    
    // Destroy the attached contacts.
    BodyAtty::EraseContacts(*body, [&](Contact& contact) {
        Destroy(m_contacts, m_contactListener, &contact, body);
        return true;
    });
    
    // Delete the attached fixtures. This destroys broad-phase proxies.
    BodyAtty::ForallFixtures(*body, [&](Fixture& fixture) {
        if (m_destructionListener)
        {
            m_destructionListener->SayGoodbye(fixture);
        }
        EraseAll(m_fixturesForProxies, &fixture);
        DestroyProxies(m_proxies, m_tree, fixture);
        FixtureAtty::Delete(&fixture);
    });
    BodyAtty::ClearFixtures(*body);
    
    Remove(*body);
}

Joint* World::CreateJoint(const JointConf& def)
{
    if (IsLocked())
    {
        throw WrongState("World::CreateJoint: world is locked");
    }
    
    if (size(m_joints) >= MaxJoints)
    {
        throw LengthError("World::CreateJoint: operation would exceed MaxJoints");
    }
    
    // Note: creating a joint doesn't wake the bodies.
    const auto j = JointAtty::Create(def);

    Add(j);
 
    const auto bodyA = j->GetBodyA();
    const auto bodyB = j->GetBodyB();

    // If the joint prevents collisions, then flag any contacts for filtering.
    if ((!def.collideConnected) && bodyA && bodyB)
    {
        FlagContactsForFiltering(*bodyA, *bodyB);
    }
    
    return j;
}

bool World::Add(Joint* j)
{
    assert(j);
    m_joints.push_back(j);
    const auto bodyA = j->GetBodyA();
    const auto bodyB = j->GetBodyB();
    BodyAtty::Insert(bodyA, j);
    BodyAtty::Insert(bodyB, j);
    return true;
}

void World::Remove(const Joint& j) noexcept
{
    const auto endIter = cend(m_joints);
    const auto iter = find(cbegin(m_joints), endIter, &j);
    assert(iter != endIter);
    m_joints.erase(iter);
}

void World::Destroy(Joint* joint)
{
    if (joint)
    {
        if (IsLocked())
        {
            throw WrongState("World::Destroy: world is locked");
        }
        InternalDestroy(*joint);
    }
}
    
void World::InternalDestroy(Joint& joint) noexcept
{
    Remove(joint);
    
    // Disconnect from island graph.
    const auto bodyA = joint.GetBodyA();
    const auto bodyB = joint.GetBodyB();

    // Wake up connected bodies.
    if (bodyA)
    {
        bodyA->SetAwake();
        BodyAtty::Erase(*bodyA, &joint);
    }
    if (bodyB)
    {
        bodyB->SetAwake();
        BodyAtty::Erase(*bodyB, &joint);
    }

    const auto collideConnected = joint.GetCollideConnected();

    JointAtty::Destroy(&joint);

    // If the joint prevented collisions, then flag any contacts for filtering.
    if ((!collideConnected) && bodyA && bodyB)
    {
        FlagContactsForFiltering(*bodyA, *bodyB);
    }
}

void World::AddToIsland(Island& island, Body& seed,
                  Bodies::size_type& remNumBodies,
                  Contacts::size_type& remNumContacts,
                  Joints::size_type& remNumJoints)
{
    assert(!IsIslanded(&seed));
    assert(seed.IsSpeedable());
    assert(seed.IsAwake());
    assert(seed.IsEnabled());
    assert(remNumBodies != 0);
    assert(remNumBodies < MaxBodies);
    
    // Perform a depth first search (DFS) on the constraint graph.

    // Create a stack for bodies to be is-in-island that aren't already in the island.
    auto stack = BodyStack{};
    stack.reserve(remNumBodies);

    stack.push_back(&seed);
    SetIslanded(&seed);
    AddToIsland(island, stack, remNumBodies, remNumContacts, remNumJoints);
}

void World::AddToIsland(Island& island, BodyStack& stack,
                 Bodies::size_type& remNumBodies,
                 Contacts::size_type& remNumContacts,
                 Joints::size_type& remNumJoints)
{
    while (!empty(stack))
    {
        // Grab the next body off the stack and add it to the island.
        const auto b = stack.back();
        stack.pop_back();
        
        assert(b);
        assert(b->IsEnabled());
        island.m_bodies.push_back(b);
        assert(remNumBodies > 0);
        --remNumBodies;
        
        // Don't propagate islands across bodies that can't have a velocity (static bodies).
        // This keeps islands smaller and helps with isolating separable collision clusters.
        if (!b->IsSpeedable())
        {
            continue;
        }

        // Make sure the body is awake (without resetting sleep timer).
        BodyAtty::SetAwakeFlag(*b);

        const auto oldNumContacts = size(island.m_contacts);
        // Adds appropriate contacts of current body and appropriate 'other' bodies of those contacts.
        AddContactsToIsland(island, stack, b);
        
        const auto newNumContacts = size(island.m_contacts);
        assert(newNumContacts >= oldNumContacts);
        const auto netNumContacts = newNumContacts - oldNumContacts;
        assert(remNumContacts >= netNumContacts);
        remNumContacts -= netNumContacts;
        
        const auto numJoints = size(island.m_joints);
        // Adds appropriate joints of current body and appropriate 'other' bodies of those joint.
        AddJointsToIsland(island, stack, b);

        remNumJoints -= size(island.m_joints) - numJoints;
    }
}

void World::AddContactsToIsland(Island& island, BodyStack& stack, const Body* b)
{
    const auto contacts = b->GetContacts();
    for_each(cbegin(contacts), cend(contacts), [&](const KeyedContactPtr& ci) {
        const auto contact = GetContactPtr(ci);
        if (!IsIslanded(contact) && contact->IsEnabled() && contact->IsTouching())
        {
            const auto fA = contact->GetFixtureA();
            const auto fB = contact->GetFixtureB();
            if (!fA->IsSensor() && !fB->IsSensor())
            {
                const auto bA = fA->GetBody();
                const auto bB = fB->GetBody();
                const auto other = (bA != b)? bA: bB;
                island.m_contacts.push_back(contact);
                SetIslanded(contact);
                if (!IsIslanded(other))
                {
                    stack.push_back(other);
                    SetIslanded(other);
                }
            }
        }
    });
}

void World::AddJointsToIsland(Island& island, BodyStack& stack, const Body* b)
{
    const auto joints = b->GetJoints();
    for_each(cbegin(joints), cend(joints), [&](const Body::KeyedJointPtr& ji) {
        // Use data of ji before dereferencing its pointers.
        const auto other = std::get<Body*>(ji);
        const auto joint = std::get<Joint*>(ji);
        assert(!other || other->IsEnabled() || !other->IsAwake());
        if (!IsIslanded(joint) && (!other || other->IsEnabled()))
        {
            island.m_joints.push_back(joint);
            SetIslanded(joint);
            if (other && !IsIslanded(other))
            {
                // Only now dereference ji's pointers.
                const auto bodyA = joint->GetBodyA();
                const auto bodyB = joint->GetBodyB();
                const auto rwOther = bodyA != b? bodyA: bodyB;
                assert(rwOther == other);
                stack.push_back(rwOther);
                SetIslanded(rwOther);
            }
        }
    });
}

World::Bodies::size_type World::RemoveUnspeedablesFromIslanded(const std::vector<Body*>& bodies)
{
    auto numRemoved = Bodies::size_type{0};
    for_each(begin(bodies), end(bodies), [&](Body* body) {
        if (!body->IsSpeedable())
        {
            // Allow static bodies to participate in other islands.
            UnsetIslanded(body);
            ++numRemoved;
        }
    });
    return numRemoved;
}

RegStepStats World::SolveReg(const StepConf& conf)
{
    auto stats = RegStepStats{};
    auto remNumBodies = size(m_bodies); ///< Remaining number of bodies.
    auto remNumContacts = size(m_contacts); ///< Remaining number of contacts.
    auto remNumJoints = size(m_joints); ///< Remaining number of joints.

    // Clear all the island flags.
    // This builds the logical set of bodies, contacts, and joints eligible for resolution.
    // As bodies, contacts, or joints get added to resolution islands, they're essentially
    // removed from this eligible set.
    for_each(begin(m_bodies), end(m_bodies), [](Bodies::value_type& b) {
        BodyAtty::UnsetIslanded(GetRef(b));
    });
    for_each(begin(m_contacts), end(m_contacts), [](Contacts::value_type& c) {
        ContactAtty::UnsetIslanded(GetRef(std::get<Contact*>(c)));
    });
    for_each(begin(m_joints), end(m_joints), [](Joints::value_type& j) {
        JointAtty::UnsetIslanded(GetRef(j));
    });

#if defined(DO_THREADED)
    std::vector<std::future<IslandStats>> futures;
    futures.reserve(remNumBodies);
#endif
    // Build and simulate all awake islands.
    for (auto&& b: m_bodies)
    {
        auto& body = GetRef(b);
        assert(!body.IsAwake() || body.IsSpeedable());
        if (!IsIslanded(&body) && body.IsAwake() && body.IsEnabled())
        {
            ++stats.islandsFound;

            // Size the island for the remaining un-evaluated bodies, contacts, and joints.
            Island island(remNumBodies, remNumContacts, remNumJoints);

            AddToIsland(island, body, remNumBodies, remNumContacts, remNumJoints);
            remNumBodies += RemoveUnspeedablesFromIslanded(island.m_bodies);

#if defined(DO_THREADED)
            // Updates bodies' sweep.pos0 to current sweep.pos1 and bodies' sweep.pos1 to new positions
            futures.push_back(std::async(std::launch::async, &World::SolveRegIslandViaGS,
                                         this, conf, island));
#else
            const auto solverResults = SolveRegIslandViaGS(conf, island);
            Update(stats, solverResults);
#endif
        }
    }

#if defined(DO_THREADED)
    for (auto&& future: futures)
    {
        const auto solverResults = future.get();
        Update(stats, solverResults);
    }
#endif

    for (auto&& b: m_bodies)
    {
        auto& body = GetRef(b);
        // A non-static body that was in an island may have moved.
        if (IsIslanded(&body) && body.IsSpeedable())
        {
            // Update fixtures (for broad-phase).
            stats.proxiesMoved += Synchronize(body, GetTransform0(body.GetSweep()), body.GetTransformation(),
                        conf.displaceMultiplier, conf.aabbExtension);
        }
    }

    // Look for new contacts.
    stats.contactsAdded = FindNewContacts();
    
    return stats;
}

IslandStats World::SolveRegIslandViaGS(const StepConf& conf, Island island)
{
    assert(!empty(island.m_bodies) || !empty(island.m_contacts) || !empty(island.m_joints));
    
    auto results = IslandStats{};
    results.positionIterations = conf.regPositionIterations;
    const auto h = conf.GetTime(); ///< Time step.

    // Update bodies' pos0 values.
    for_each(cbegin(island.m_bodies), cend(island.m_bodies), [&](Body* body) {
        BodyAtty::SetPosition0(*body, GetPosition1(*body)); // like Advance0(1) on the sweep.
    });
    
    // Copy bodies' pos1 and velocity data into local arrays.
    auto bodyConstraints = GetBodyConstraints(island.m_bodies, h, GetMovementConf(conf));
    auto bodyConstraintsMap = GetBodyConstraintsMap(island.m_bodies, bodyConstraints);
    auto posConstraints = GetPositionConstraints(island.m_contacts, bodyConstraintsMap);
    auto velConstraints = GetVelocityConstraints(island.m_contacts, bodyConstraintsMap,
                                                      GetRegVelocityConstraintConf(conf));
    
    if (conf.doWarmStart)
    {
        WarmStartVelocities(velConstraints);
    }

    const auto psConf = GetRegConstraintSolverConf(conf);

    for_each(cbegin(island.m_joints), cend(island.m_joints), [&](Joint* joint) {
        JointAtty::InitVelocityConstraints(*joint, bodyConstraintsMap, conf, psConf);
    });
    
    results.velocityIterations = conf.regVelocityIterations;
    for (auto i = decltype(conf.regVelocityIterations){0}; i < conf.regVelocityIterations; ++i)
    {
        auto jointsOkay = true;
        for_each(cbegin(island.m_joints), cend(island.m_joints), [&](Joint* j) {
            jointsOkay &= JointAtty::SolveVelocityConstraints(*j, bodyConstraintsMap, conf);
        });

        // Note that the new incremental impulse can potentially be orders of magnitude
        // greater than the last incremental impulse used in this loop.
        const auto newIncImpulse = SolveVelocityConstraintsViaGS(velConstraints);
        results.maxIncImpulse = std::max(results.maxIncImpulse, newIncImpulse);

        if (jointsOkay && (newIncImpulse <= conf.regMinMomentum))
        {
            // No joint related velocity constraints were out of tolerance.
            // No body related velocity constraints were out of tolerance.
            // There does not appear to be any benefit to doing more loops now.
            // XXX: Is it really safe to bail now? Not certain of that.
            // Bail now assuming that this is helpful to do...
            results.velocityIterations = i + 1;
            break;
        }
    }
    
    // updates array of tentative new body positions per the velocities as if there were no obstacles...
    IntegratePositions(bodyConstraints, h);
    
    // Solve position constraints
    for (auto i = decltype(conf.regPositionIterations){0}; i < conf.regPositionIterations; ++i)
    {
        const auto minSeparation = SolvePositionConstraintsViaGS(posConstraints, psConf);
        results.minSeparation = std::min(results.minSeparation, minSeparation);
        const auto contactsOkay = (minSeparation >= conf.regMinSeparation);

        auto jointsOkay = true;
        for_each(cbegin(island.m_joints), cend(island.m_joints), [&](Joint* j) {
            jointsOkay &= JointAtty::SolvePositionConstraints(*j, bodyConstraintsMap, psConf);
        });

        if (contactsOkay && jointsOkay)
        {
            // Reached tolerance, early out...
            results.positionIterations = i + 1;
            results.solved = true;
            break;
        }
    }
    
    // Update normal and tangent impulses of contacts' manifold points
    for_each(cbegin(velConstraints), cend(velConstraints), [&](const VelocityConstraint& vc) {
        const auto i = static_cast<VelocityConstraints::size_type>(&vc - data(velConstraints));
        auto& manifold = ContactAtty::GetMutableManifold(*island.m_contacts[i]);
        AssignImpulses(manifold, vc);
    });
    
    for_each(cbegin(bodyConstraints), cend(bodyConstraints), [&](const BodyConstraint& bc) {
        const auto i = static_cast<size_t>(&bc - data(bodyConstraints));
        assert(i < size(bodyConstraints));
        // Could normalize position here to avoid unbounded angles but angular
        // normalization isn't handled correctly by joints that constrain rotation.
        UpdateBody(*island.m_bodies[i], bc.GetPosition(), bc.GetVelocity());
    });
    
    // XXX: Should contacts needing updating be updated now??

    if (m_contactListener)
    {
        Report(*m_contactListener, island.m_contacts, velConstraints,
               results.solved? results.positionIterations - 1: StepConf::InvalidIteration);
    }
    
    results.bodiesSlept = BodyCounter{0};
    const auto minUnderActiveTime = UpdateUnderActiveTimes(island.m_bodies, conf);
    if ((minUnderActiveTime >= conf.minStillTimeToSleep) && results.solved)
    {
        results.bodiesSlept = static_cast<decltype(results.bodiesSlept)>(Sleepem(island.m_bodies));
    }

    return results;
}

void World::ResetBodiesForSolveTOI() noexcept
{
    for_each(begin(m_bodies), end(m_bodies), [&](Bodies::value_type& body) {
        auto& b = GetRef(body);
        BodyAtty::UnsetIslanded(b);
        BodyAtty::ResetAlpha0(b);
    });
}

void World::ResetContactsForSolveTOI() noexcept
{
    for_each(begin(m_contacts), end(m_contacts), [&](Contacts::value_type &c) {
        auto& contact = GetRef(std::get<Contact*>(c));
        ContactAtty::UnsetIslanded(contact);
        ContactAtty::UnsetToi(contact);
        ContactAtty::ResetToiCount(contact);
    });
}

World::UpdateContactsData World::UpdateContactTOIs(const StepConf& conf)
{
    auto results = UpdateContactsData{};

    const auto toiConf = GetToiConf(conf);
    
    for (auto&& contact: m_contacts)
    {
        auto& c = GetRef(std::get<Contact*>(contact));
        if (c.HasValidToi())
        {
            ++results.numValidTOI;
            continue;
        }
        if (!c.IsEnabled() || HasSensor(c) || !IsActive(c) || !IsImpenetrable(c))
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
        
        const auto fA = c.GetFixtureA();
        const auto fB = c.GetFixtureB();
        const auto bA = fA->GetBody();
        const auto bB = fB->GetBody();
                
        /*
         * Put the sweeps onto the same time interval.
         * Presumably no unresolved collisions happen before the maximum of the bodies'
         * alpha-0 times. So long as the least TOI of the contacts is always the first
         * collision that gets dealt with, this presumption is safe.
         */
        const auto alpha0 = std::max(bA->GetSweep().GetAlpha0(), bB->GetSweep().GetAlpha0());
        assert(alpha0 >= 0 && alpha0 < 1);
        BodyAtty::Advance0(*bA, alpha0);
        BodyAtty::Advance0(*bB, alpha0);
        
        // Compute the TOI for this contact (one or both bodies are active and impenetrable).
        // Computes the time of impact in interval [0, 1]
        const auto output = CalcToi(c, toiConf);
        
        // Use Min function to handle floating point imprecision which possibly otherwise
        // could provide a TOI that's greater than 1.
        const auto toi = IsValidForTime(output.state)?
            std::min(alpha0 + (1 - alpha0) * output.time, Real{1}): Real{1};
        assert(toi >= alpha0 && toi <= 1);
        ContactAtty::SetToi(c, toi);
        
        results.maxDistIters = std::max(results.maxDistIters, output.stats.max_dist_iters);
        results.maxToiIters = std::max(results.maxToiIters, output.stats.toi_iters);
        results.maxRootIters = std::max(results.maxRootIters, output.stats.max_root_iters);
        ++results.numUpdatedTOI;
    }

    return results;
}
    
World::ContactToiData World::GetSoonestContact() const noexcept
{
    auto minToi = nextafter(Real{1}, Real{0});
    auto found = static_cast<Contact*>(nullptr);
    auto count = ContactCounter{0};
    for (auto&& contact: m_contacts)
    {
        const auto c = GetPtr(std::get<Contact*>(contact));
        if (c->HasValidToi())
        {
            const auto toi = c->GetToi();
            if (minToi > toi)
            {
                minToi = toi;
                found = c;
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

ToiStepStats World::SolveToi(const StepConf& conf)
{
    auto stats = ToiStepStats{};

    if (IsStepComplete())
    {
        ResetBodiesForSolveTOI();
        ResetContactsForSolveTOI();
    }

    const auto subStepping = GetSubStepping();

    // Find TOI events and solve them.
    for (;;)
    {
        const auto updateData = UpdateContactTOIs(conf);
        stats.contactsAtMaxSubSteps += updateData.numAtMaxSubSteps;
        stats.contactsUpdatedToi += updateData.numUpdatedTOI;
        stats.maxDistIters = std::max(stats.maxDistIters, updateData.maxDistIters);
        stats.maxRootIters = std::max(stats.maxRootIters, updateData.maxRootIters);
        stats.maxToiIters = std::max(stats.maxToiIters, updateData.maxToiIters);
        
        const auto next = GetSoonestContact();
        const auto contact = next.contact;
        const auto ncount = next.simultaneous;
        if (!contact)
        {
            // No more TOI events to handle within the current time step. Done!
            SetStepComplete(true);
            break;
        }

        stats.maxSimulContacts = std::max(stats.maxSimulContacts,
                                          static_cast<decltype(stats.maxSimulContacts)>(ncount));
        stats.contactsFound += ncount;
        auto islandsFound = 0u;
        if (!IsIslanded(contact))
        {
            /*
             * Confirm that contact is as it's supposed to be according to contract of the
             * GetSoonestContacts method from which this contact was obtained.
             */
            assert(contact->IsEnabled());
            assert(!HasSensor(*contact));
            assert(IsActive(*contact));
            assert(IsImpenetrable(*contact));
            
            const auto solverResults = SolveToi(conf, *contact);
            stats.minSeparation = std::min(stats.minSeparation, solverResults.minSeparation);
            stats.maxIncImpulse = std::max(stats.maxIncImpulse, solverResults.maxIncImpulse);
            stats.islandsSolved += solverResults.solved;
            stats.sumPosIters += solverResults.positionIterations;
            stats.sumVelIters += solverResults.velocityIterations;
            if ((solverResults.positionIterations > 0) || (solverResults.velocityIterations > 0))
            {
                ++islandsFound;
            }
            stats.contactsUpdatedTouching += solverResults.contactsUpdated;
            stats.contactsSkippedTouching += solverResults.contactsSkipped;
        }
        stats.islandsFound += islandsFound;

        // Reset island flags and synchronize broad-phase proxies.
        for (auto&& b: m_bodies)
        {
            auto& body = GetRef(b);
            if (IsIslanded(&body))
            {
                UnsetIslanded(&body);
                if (body.IsAccelerable())
                {
                    const auto xfm0 = GetTransform0(body.GetSweep());
                    const auto xfm1 = body.GetTransformation();
                    stats.proxiesMoved += Synchronize(body, xfm0, xfm1,
                                                      conf.displaceMultiplier, conf.aabbExtension);
                    ResetContactsForSolveTOI(body);
                }
            }
        }

        // Commit fixture proxy movements to the broad-phase so that new contacts are created.
        // Also, some contacts can be destroyed.
        stats.contactsAdded += FindNewContacts();

        if (subStepping)
        {
            SetStepComplete(false);
            break;
        }
    }
    return stats;
}

IslandStats World::SolveToi(const StepConf& conf, Contact& contact)
{
    // Note:
    //   This method is what used to be b2World::SolveToi(const b2TimeStep& step).
    //   It also differs internally from Erin's implementation.
    //
    //   Here's some specific behavioral differences:
    //   1. Bodies don't get their under-active times reset (like they do in Erin's code).

    auto contactsUpdated = ContactCounter{0};
    auto contactsSkipped = ContactCounter{0};

    /*
     * Confirm that contact is as it's supposed to be according to contract of the
     * GetSoonestContacts method from which this contact should have been obtained.
     */
    assert(contact.IsEnabled());
    assert(!HasSensor(contact));
    assert(IsActive(contact));
    assert(IsImpenetrable(contact));
    assert(!IsIslanded(&contact));
    
    const auto toi = contact.GetToi();
    const auto bA = contact.GetFixtureA()->GetBody();
    const auto bB = contact.GetFixtureB()->GetBody();

    /* XXX: if (toi != 0)? */
    /* if (bA->GetSweep().GetAlpha0() != toi || bB->GetSweep().GetAlpha0() != toi) */
    // Seems contact manifold needs updating regardless.
    {
        const auto backupA = bA->GetSweep();
        const auto backupB = bB->GetSweep();

        // Advance the bodies to the TOI.
        assert(toi != 0 || (bA->GetSweep().GetAlpha0() == 0 && bB->GetSweep().GetAlpha0() == 0));
        BodyAtty::Advance(*bA, toi);
        BodyAtty::Advance(*bB, toi);

        // The TOI contact likely has some new contact points.
        contact.SetEnabled();
        if (contact.NeedsUpdating())
        {
            ContactAtty::Update(contact, Contact::GetUpdateConf(conf), m_contactListener);
            ++contactsUpdated;
        }
        else
        {
            ++contactsSkipped;
        }
        ContactAtty::UnsetToi(contact);
        ContactAtty::IncrementToiCount(contact);

        // Is contact disabled or separated?
        //
        // XXX: Not often, but sometimes, contact.IsTouching() is false now.
        //      Seems like this is a bug, or at least suboptimal, condition.
        //      This method shouldn't be getting called unless contact has an
        //      impact indeed at the given TOI. Seen this happen in an edge-polygon
        //      contact situation where the polygon had a larger than default
        //      vertex radius. CollideShapes had called GetManifoldFaceB which
        //      was failing to see 2 clip points after GetClipPoints was called.
        if (!contact.IsEnabled() || !contact.IsTouching())
        {
            // assert(!contact.IsEnabled() || contact.IsTouching());
            contact.UnsetEnabled();
            BodyAtty::Restore(*bA, backupA);
            BodyAtty::Restore(*bB, backupB);
            auto results = IslandStats{};
            results.contactsUpdated += contactsUpdated;
            results.contactsSkipped += contactsSkipped;
            return results;
        }
    }
#if 0
    else if (!contact.IsTouching())
    {
        const auto newManifold = contact.Evaluate();
        assert(contact.IsTouching());
        return IslandSolverResults{};
    }
#endif
    
    if (bA->IsSpeedable())
    {
        BodyAtty::SetAwakeFlag(*bA);
        // XXX should the body's under-active time be reset here?
        //   Erin's code does for here but not in b2World::Solve(const b2TimeStep& step).
        //   Calling Body::ResetUnderActiveTime() has performance implications.
    }

    if (bB->IsSpeedable())
    {
        BodyAtty::SetAwakeFlag(*bB);
        // XXX should the body's under-active time be reset here?
        //   Erin's code does for here but not in b2World::Solve(const b2TimeStep& step).
        //   Calling Body::ResetUnderActiveTime() has performance implications.
    }

    // Build the island
    Island island(size(m_bodies), size(m_contacts), 0);

     // These asserts get triggered sometimes if contacts within TOI are iterated over.
    assert(!IsIslanded(bA));
    assert(!IsIslanded(bB));
    
    island.m_bodies.push_back(bA);
    SetIslanded(bA);
    island.m_bodies.push_back(bB);
    SetIslanded(bB);
    island.m_contacts.push_back(&contact);
    SetIslanded(&contact);

    // Process the contacts of the two bodies, adding appropriate ones to the island,
    // adding appropriate other bodies of added contacts, and advancing those other
    // bodies sweeps and transforms to the minimum contact's TOI.
    if (bA->IsAccelerable())
    {
        const auto procOut = ProcessContactsForTOI(island, *bA, toi, conf);
        contactsUpdated += procOut.contactsUpdated;
        contactsSkipped += procOut.contactsSkipped;
    }
    if (bB->IsAccelerable())
    {
        const auto procOut = ProcessContactsForTOI(island, *bB, toi, conf);
        contactsUpdated += procOut.contactsUpdated;
        contactsSkipped += procOut.contactsSkipped;
    }
    
    RemoveUnspeedablesFromIslanded(island.m_bodies);

    // Now solve for remainder of time step.
    //
    // Note: subConf is written the way it is because MSVS2017 emitted errors when
    //   written as:
    //     SolveToi(StepConf{conf}.SetTime((1 - toi) * conf.GetTime()), island);
    //
    auto subConf = StepConf{conf};
    auto results = SolveToiViaGS(subConf.SetTime((1 - toi) * conf.GetTime()), island);
    results.contactsUpdated += contactsUpdated;
    results.contactsSkipped += contactsSkipped;
    return results;
}

void World::UpdateBody(Body& body, const Position& pos, const Velocity& vel)
{
    assert(IsValid(pos));
    assert(IsValid(vel));
    BodyAtty::SetVelocity(body, vel);
    BodyAtty::SetPosition1(body, pos);
    BodyAtty::SetTransformation(body, GetTransformation(GetPosition1(body), body.GetLocalCenter()));
}

IslandStats World::SolveToiViaGS(const StepConf& conf, Island& island)
{
    auto results = IslandStats{};
    
    /*
     * Presumably the regular phase resolution has already taken care of updating the
     * body's velocity w.r.t. acceleration and damping such that this call here to get
     * the body constraint doesn't need to pass an elapsed time (and doesn't need to
     * update the velocity from what it already is).
     */
    auto bodyConstraints = GetBodyConstraints(island.m_bodies, 0_s, GetMovementConf(conf));
    auto bodyConstraintsMap = GetBodyConstraintsMap(island.m_bodies, bodyConstraints);

    // Initialize the body state.
#if 0
    for (auto&& contact: island.m_contacts)
    {
        const auto fixtureA = contact->GetFixtureA();
        const auto fixtureB = contact->GetFixtureB();
        const auto bodyA = fixtureA->GetBody();
        const auto bodyB = fixtureB->GetBody();

        bodyConstraintsMap[bodyA] = GetBodyConstraint(*bodyA);
        bodyConstraintsMap[bodyB] = GetBodyConstraint(*bodyB);
    }
#endif
    
    auto posConstraints = GetPositionConstraints(island.m_contacts, bodyConstraintsMap);
    
    // Solve TOI-based position constraints.
    assert(results.minSeparation == std::numeric_limits<Length>::infinity());
    assert(results.solved == false);
    results.positionIterations = conf.toiPositionIterations;
    {
        const auto psConf = GetToiConstraintSolverConf(conf);

        for (auto i = decltype(conf.toiPositionIterations){0}; i < conf.toiPositionIterations; ++i)
        {
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
            const auto minSeparation = SolvePositionConstraintsViaGS(posConstraints, psConf);
            results.minSeparation = std::min(results.minSeparation, minSeparation);
            if (minSeparation >= conf.toiMinSeparation)
            {
                // Reached tolerance, early out...
                results.positionIterations = i + 1;
                results.solved = true;
                break;
            }
        }
    }
    
    // Leap of faith to new safe state.
    // Not doing this results in slower simulations.
    // Originally this update was only done to island.m_bodies 0 and 1.
    // Unclear whether rest of bodies should also be updated. No difference noticed.
#if 0
    for (auto&& contact: island.m_contacts)
    {
        const auto fixtureA = contact->GetFixtureA();
        const auto fixtureB = contact->GetFixtureB();
        const auto bodyA = fixtureA->GetBody();
        const auto bodyB = fixtureB->GetBody();
        
        BodyAtty::SetPosition0(*bodyA, bodyConstraintsMap.at(bodyA).GetPosition());
        BodyAtty::SetPosition0(*bodyB, bodyConstraintsMap.at(bodyB).GetPosition());
    }
#else
    for_each(cbegin(bodyConstraints), cend(bodyConstraints), [&](const BodyConstraint& bc) {
        const auto i = static_cast<size_t>(&bc - data(bodyConstraints));
        assert(i < size(bodyConstraints));
        BodyAtty::SetPosition0(*island.m_bodies[i], bc.GetPosition());
    });
#endif
    
    auto velConstraints = GetVelocityConstraints(island.m_contacts, bodyConstraintsMap,
                                                 GetToiVelocityConstraintConf(conf));

    // No warm starting is needed for TOI events because warm
    // starting impulses were applied in the discrete solver.

    // Solve velocity constraints.
    assert(results.maxIncImpulse == 0_Ns);
    results.velocityIterations = conf.toiVelocityIterations;
    for (auto i = decltype(conf.toiVelocityIterations){0}; i < conf.toiVelocityIterations; ++i)
    {
        const auto newIncImpulse = SolveVelocityConstraintsViaGS(velConstraints);
        if (newIncImpulse <= conf.toiMinMomentum)
        {
            // No body related velocity constraints were out of tolerance.
            // There does not appear to be any benefit to doing more loops now.
            // XXX: Is it really safe to bail now? Not certain of that.
            // Bail now assuming that this is helpful to do...
            results.velocityIterations = i + 1;
            break;
        }
        results.maxIncImpulse = std::max(results.maxIncImpulse, newIncImpulse);
    }
    
    // Don't store TOI contact forces for warm starting because they can be quite large.
    
    IntegratePositions(bodyConstraints, conf.GetTime());
    
    for_each(cbegin(bodyConstraints), cend(bodyConstraints), [&](const BodyConstraint& bc) {
        const auto i = static_cast<size_t>(&bc - data(bodyConstraints));
        assert(i < size(bodyConstraints));
        UpdateBody(*island.m_bodies[i], bc.GetPosition(), bc.GetVelocity());
    });

    if (m_contactListener)
    {
        Report(*m_contactListener, island.m_contacts, velConstraints, results.positionIterations);
    }
    
    return results;
}
    
void World::ResetContactsForSolveTOI(Body& body) noexcept
{
    // Invalidate all contact TOIs on this displaced body.
    const auto contacts = body.GetContacts();
    for_each(cbegin(contacts), cend(contacts), [&](KeyedContactPtr ci) {
        const auto contact = GetContactPtr(ci);
        UnsetIslanded(contact);
        ContactAtty::UnsetToi(*contact);
    });
}

World::ProcessContactsOutput
World::ProcessContactsForTOI(Island& island, Body& body, Real toi,
                             const StepConf& conf)
{
    assert(IsIslanded(&body));
    assert(body.IsAccelerable());
    assert(toi >= 0 && toi <= 1);

    auto results = ProcessContactsOutput{};
    assert(results.contactsUpdated == 0);
    assert(results.contactsSkipped == 0);
    
    const auto updateConf = Contact::GetUpdateConf(conf);

    auto processContactFunc = [&](Contact* contact, Body* other)
    {
        const auto otherIslanded = IsIslanded(other);
        {
            const auto backup = other->GetSweep();
            if (!otherIslanded /* && other->GetSweep().GetAlpha0() != toi */)
            {
                BodyAtty::Advance(*other, toi);
            }
            
            // Update the contact points
            contact->SetEnabled();
            if (contact->NeedsUpdating())
            {
                ContactAtty::Update(*contact, updateConf, m_contactListener);
                ++results.contactsUpdated;
            }
            else
            {
                ++results.contactsSkipped;
            }
            
            // Revert and skip if contact disabled by user or not touching anymore (very possible).
            if (!contact->IsEnabled() || !contact->IsTouching())
            {
                BodyAtty::Restore(*other, backup);
                return;
            }
        }
        island.m_contacts.push_back(contact);
        SetIslanded(contact);
        if (!otherIslanded)
        {
            if (other->IsSpeedable())
            {
                BodyAtty::SetAwakeFlag(*other);
            }
            island.m_bodies.push_back(other);
            SetIslanded(other);
#if 0
            if (other->IsAccelerable())
            {
                contactsUpdated += ProcessContactsForTOI(island, *other, toi);
            }
#endif
        }
#ifndef NDEBUG
        else
        {
            /*
             * If other is-in-island but not in current island, then something's gone wrong.
             * Other needs to be in current island but was already in the island.
             * A previous contact island didn't grow to include all the bodies it needed or
             * perhaps the current contact is-touching while another one wasn't and the
             * inconsistency is throwing things off.
             */
            assert(Count(island, other) > 0);
        }
#endif
    };

    // Note: the original contact (for body of which this method was called) already is-in-island.
    const auto bodyImpenetrable = body.IsImpenetrable();
    for (auto&& ci: body.GetContacts())
    {
        const auto contact = GetContactPtr(ci);
        if (!IsIslanded(contact))
        {
            const auto fA = contact->GetFixtureA();
            const auto fB = contact->GetFixtureB();
            if (!fA->IsSensor() && !fB->IsSensor())
            {
                const auto bA = fA->GetBody();
                const auto bB = fB->GetBody();
                const auto other = (bA != &body)? bA: bB;
                if (bodyImpenetrable || other->IsImpenetrable())
                {
                    processContactFunc(contact, other);
                }
            }
        }
    }
    return results;
}
    
StepStats World::Step(const StepConf& conf)
{
    assert((Length{m_maxVertexRadius} * Real{2}) +
           (Length{conf.linearSlop} / Real{4}) > (Length{m_maxVertexRadius} * Real{2}));
    
    if (IsLocked())
    {
        throw WrongState("World::Step: world is locked");
    }

    // "Named return value optimization" (NRVO) will make returning this more efficient.
    auto stepStats = StepStats{};
    {
        FlagGuard<decltype(m_flags)> flagGaurd(m_flags, e_locked);

        CreateAndDestroyProxies(conf);
        m_fixturesForProxies.clear();

        stepStats.pre.proxiesMoved = SynchronizeProxies(conf);
        // pre.proxiesMoved is usually zero but sometimes isn't.

        {
            // Note: this may update bodies (in addition to the contacts container).
            const auto destroyStats = DestroyContacts(m_contacts);
            stepStats.pre.destroyed = destroyStats.erased;
        }

        if (HasNewFixtures())
        {
            UnsetNewFixtures();
            
            // New fixtures were added: need to find and create the new contacts.
            // Note: this may update bodies (in addition to the contacts container).
            stepStats.pre.added = FindNewContacts();
        }

        if (conf.GetTime() != 0_s)
        {
            m_inv_dt0 = conf.GetInvTime();

            // Could potentially run UpdateContacts multithreaded over split lists...
            const auto updateStats = UpdateContacts(m_contacts, conf);
            stepStats.pre.ignored = updateStats.ignored;
            stepStats.pre.updated = updateStats.updated;
            stepStats.pre.skipped = updateStats.skipped;

            // Integrate velocities, solve velocity constraints, and integrate positions.
            if (IsStepComplete())
            {
                stepStats.reg = SolveReg(conf);
            }

            // Handle TOI events.
            if (conf.doToi)
            {
                stepStats.toi = SolveToi(conf);
            }
        }
    }
    return stepStats;
}

void World::ShiftOrigin(Length2 newOrigin)
{
    if (IsLocked())
    {
        throw WrongState("World::ShiftOrigin: world is locked");
    }

    const auto bodies = GetBodies();
    for (auto&& body: bodies)
    {
        auto& b = GetRef(body);

        auto transformation = b.GetTransformation();
        transformation.p -= newOrigin;
        BodyAtty::SetTransformation(b, transformation);
        
        auto sweep = b.GetSweep();
        sweep.pos0.linear -= newOrigin;
        sweep.pos1.linear -= newOrigin;
        BodyAtty::SetSweep(b, sweep);
    }

    for_each(begin(m_joints), end(m_joints), [&](Joints::value_type& j) {
        GetRef(j).ShiftOrigin(newOrigin);
    });

    m_tree.ShiftOrigin(newOrigin);
}

void World::InternalDestroy(ContactListener* contactListener, Contact* contact, Body* from)
{
    if (contactListener && contact->IsTouching())
    {
        // EndContact hadn't been called in DestroyOrUpdateContacts() since is-touching, so call it now
        contactListener->EndContact(*contact);
    }
    
    const auto fixtureA = contact->GetFixtureA();
    const auto fixtureB = contact->GetFixtureB();
    const auto bodyA = fixtureA->GetBody();
    const auto bodyB = fixtureB->GetBody();
    
    if (bodyA != from)
    {
        BodyAtty::Erase(*bodyA, contact);
    }
    if (bodyB != from)
    {
        BodyAtty::Erase(*bodyB, contact);
    }
    
    if ((contact->GetManifold().GetPointCount() > 0) &&
        !fixtureA->IsSensor() && !fixtureB->IsSensor())
    {
        // Contact may have been keeping accelerable bodies of fixture A or B from moving.
        // Need to awaken those bodies now in case they are again movable.
        bodyA->SetAwake();
        bodyB->SetAwake();
    }
    
    delete contact;
}

void World::Destroy(Contacts& contacts, ContactListener* contactListener, Contact* contact, Body* from)
{
    assert(contact);

    InternalDestroy(contactListener, contact, from);
    
    const auto it = find_if(cbegin(contacts), cend(contacts),
                            [&](const Contacts::value_type& c) {
        return GetPtr(std::get<Contact*>(c)) == contact;
    });
    if (it != cend(contacts))
    {
        contacts.erase(it);
    }
}

World::DestroyContactsStats World::DestroyContacts(Contacts& contacts)
{
    const auto beforeSize = size(contacts);
    contacts.erase(std::remove_if(begin(contacts), end(contacts), [&](Contacts::value_type& c)
    {
        const auto key = std::get<ContactKey>(c);
        auto& contact = GetRef(std::get<Contact*>(c));
        
        if (!TestOverlap(m_tree, key.GetMin(), key.GetMax()))
        {
            // Destroy contacts that cease to overlap in the broad-phase.
            InternalDestroy(m_contactListener, &contact);
            return true;
        }
        
        // Is this contact flagged for filtering?
        if (contact.NeedsFiltering())
        {
            const auto fixtureA = contact.GetFixtureA();
            const auto fixtureB = contact.GetFixtureB();
            const auto bodyA = fixtureA->GetBody();
            const auto bodyB = fixtureB->GetBody();

            if (!ShouldCollide(*bodyB, *bodyA) || !ShouldCollide(*fixtureA, *fixtureB))
            {
                InternalDestroy(m_contactListener, &contact);
                return true;
            }
            ContactAtty::UnflagForFiltering(contact);
        }

        return false;
    }), end(contacts));
    const auto afterSize = size(contacts);

    auto stats = DestroyContactsStats{};
    stats.ignored = static_cast<ContactCounter>(afterSize);
    stats.erased = static_cast<ContactCounter>(beforeSize - afterSize);
    return stats;
}

World::UpdateContactsStats World::UpdateContacts(Contacts& contacts, const StepConf& conf)
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

    const auto updateConf = Contact::GetUpdateConf(conf);
    
#if defined(DO_THREADED)
    std::vector<Contact*> contactsNeedingUpdate;
    contactsNeedingUpdate.reserve(size(contacts));
    std::vector<std::future<void>> futures;
    futures.reserve(size(contacts));
#endif

    // Update awake contacts.
    for_each(/*execution::par_unseq,*/ begin(contacts), end(contacts),
             [&](Contacts::value_type& c) {
        auto& contact = GetRef(std::get<Contact*>(c));
#if 0
        ContactAtty::Update(contact, updateConf, m_contactListener);
        ++updated;
#else
        const auto bodyA = GetBodyA(contact);
        const auto bodyB = GetBodyB(contact);
        
        // Awake && speedable (dynamic or kinematic) means collidable.
        // At least one body must be collidable
        assert(!bodyA->IsAwake() || bodyA->IsSpeedable());
        assert(!bodyB->IsAwake() || bodyB->IsSpeedable());
        if (!bodyA->IsAwake() && !bodyB->IsAwake())
        {
            assert(!contact.HasValidToi());
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
        if (contact.NeedsUpdating())
        {
            // The following may call listener but is otherwise thread-safe.
#if defined(DO_THREADED)
            contactsNeedingUpdate.push_back(&contact);
            //futures.push_back(async(&ContactAtty::Update, *contact, conf, m_contactListener)));
            //futures.push_back(async(launch::async, [=]{ ContactAtty::Update(*contact, conf, m_contactListener); }));
#else
            ContactAtty::Update(contact, updateConf, m_contactListener);
#endif
        	++updated;
        }
        else
        {
            ++skipped;
        }
#endif
    });
    
#if defined(DO_THREADED)
    auto numJobs = size(contactsNeedingUpdate);
    const auto jobsPerCore = numJobs / 4;
    for (auto i = decltype(numJobs){0}; numJobs > 0 && i < 3; ++i)
    {
        futures.push_back(std::async(std::launch::async, [=]{
            const auto offset = jobsPerCore * i;
            for (auto j = decltype(jobsPerCore){0}; j < jobsPerCore; ++j)
            {
	            ContactAtty::Update(*contactsNeedingUpdate[offset + j], updateConf, m_contactListener);
            }
        }));
        numJobs -= jobsPerCore;
    }
    if (numJobs > 0)
    {
        futures.push_back(std::async(std::launch::async, [=]{
            const auto offset = jobsPerCore * 3;
            for (auto j = decltype(numJobs){0}; j < numJobs; ++j)
            {
                ContactAtty::Update(*contactsNeedingUpdate[offset + j], updateConf, m_contactListener);
            }
        }));
    }
    for (auto&& future: futures)
    {
        future.get();
    }
#endif
    
    return UpdateContactsStats{
        static_cast<ContactCounter>(ignored),
        static_cast<ContactCounter>(updated),
        static_cast<ContactCounter>(skipped)
    };
}

ContactCounter World::FindNewContacts()
{
    m_proxyKeys.clear();

    // Accumalate contact keys for pairs of nodes that are overlapping and aren't identical.
    // Note that if the dynamic tree node provides the body pointer, it's assumed to be faster
    // to eliminate any node pairs that have the same body here before the key pairs are
    // sorted.
    for_each(cbegin(m_proxies), cend(m_proxies), [&](ProxyId pid) {
    	if (pid == DynamicTree::GetInvalidSize()) return;
        const auto body0 = m_tree.GetLeafData(pid).body;
        const auto aabb = m_tree.GetAABB(pid);
        Query(m_tree, aabb, [&](DynamicTree::Size nodeId) {
            const auto body1 = m_tree.GetLeafData(nodeId).body;
            // A proxy cannot form a pair with itself.
            if ((nodeId != pid) && (body0 != body1))
            {
                m_proxyKeys.push_back(ContactKey{nodeId, pid});
            }
            return DynamicTreeOpcode::Continue;
        });
    });
    m_proxies.clear();

    // Sort and eliminate any duplicate contact keys.
    sort(begin(m_proxyKeys), end(m_proxyKeys));
    m_proxyKeys.erase(unique(begin(m_proxyKeys), end(m_proxyKeys)), end(m_proxyKeys));

    const auto numContactsBefore = size(m_contacts);
    for_each(cbegin(m_proxyKeys), cend(m_proxyKeys), [&](ContactKey key)
    {
        Add(m_contacts, m_tree, key);
    });
    const auto numContactsAfter = size(m_contacts);
    return static_cast<ContactCounter>(numContactsAfter - numContactsBefore);
}

bool World::Add(Contacts& contacts, const DynamicTree& tree, ContactKey key)
{
    const auto minKeyLeafData = tree.GetLeafData(key.GetMin());
    const auto maxKeyLeafData = tree.GetLeafData(key.GetMax());

    const auto fixtureA = minKeyLeafData.fixture;
    const auto indexA = minKeyLeafData.childIndex;
    const auto fixtureB = maxKeyLeafData.fixture;
    const auto indexB = maxKeyLeafData.childIndex;

    const auto bodyA = minKeyLeafData.body; // fixtureA->GetBody();
    const auto bodyB = maxKeyLeafData.body; // fixtureB->GetBody();

#if 0
    // Are the fixtures on the same body? They can be, and they often are.
    // Don't need nor want a contact for these fixtures if they are on the same body.
    if (bodyA == bodyB)
    {
        return false;
    }
#endif
    assert(bodyA != bodyB);
    
    // Does a joint override collision? Is at least one body dynamic?
    if (!ShouldCollide(*bodyB, *bodyA) || !ShouldCollide(*fixtureA, *fixtureB))
    {
        return false;
    }
   
#ifndef NO_RACING
    // Code herein may be racey in a multithreaded context...
    // Would need a lock on bodyA, bodyB, and m_contacts.
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
    const auto searchBody = (size(bodyA->GetContacts()) < size(bodyB->GetContacts()))?
        bodyA: bodyB;
    
    const auto bodyContacts = searchBody->GetContacts();
    const auto it = find_if(cbegin(bodyContacts), cend(bodyContacts), [&](KeyedContactPtr ci) {
        return std::get<ContactKey>(ci) == key;
    });
    if (it != cend(bodyContacts))
    {
        return false;
    }
    
    if (size(contacts) >= MaxContacts)
    {
        // New contact was needed, but denied due to MaxContacts count being reached.
        return false;
    }

    const auto contact = new Contact{fixtureA, indexA, fixtureB, indexB};
    
    // Insert into the contacts container.
    //
    // Should the new contact be added at front or back?
    //
    // Original strategy added to the front. Since processing done front to back, front
    // adding means container more a LIFO container, while back adding means more a FIFO.
    //
    contacts.push_back(KeyedContactPtr{key, contact});

    BodyAtty::Insert(*bodyA, key, contact);
    BodyAtty::Insert(*bodyB, key, contact);

    // Wake up the bodies
    if (!fixtureA->IsSensor() && !fixtureB->IsSensor())
    {
        if (bodyA->IsSpeedable())
        {
            BodyAtty::SetAwakeFlag(*bodyA);
        }
        if (bodyB->IsSpeedable())
        {
            BodyAtty::SetAwakeFlag(*bodyB);
        }
    }
#endif

    return true;
}

void World::RegisterForProxies(Fixture& fixture)
{
    assert(fixture.GetBody()->GetWorld() == this);
    m_fixturesForProxies.push_back(&fixture);
}

void World::RegisterForProxies(Body& body)
{
    assert(body.GetWorld() == this);
    m_bodiesForProxies.push_back(&body);
}

void World::UnregisterForProxies(const Body& body)
{
    assert(body.GetWorld() == this);
    const auto first = remove(begin(m_bodiesForProxies), end(m_bodiesForProxies), &body);
    m_bodiesForProxies.erase(first, end(m_bodiesForProxies));
}

void World::CreateAndDestroyProxies(const StepConf& conf)
{
    for_each(begin(m_fixturesForProxies), end(m_fixturesForProxies), [&](Fixture *f) {
        assert(f);
        auto& fixture = *f;
        const auto body = fixture.GetBody();
        const auto enabled = body->IsEnabled();

        const auto proxyCount = fixture.GetProxyCount();
        if (proxyCount == 0)
        {
            if (enabled)
            {
                CreateProxies(m_proxies, m_tree, fixture, conf.aabbExtension);
            }
        }
        else
        {
            if (!enabled)
            {
                DestroyProxies(m_proxies, m_tree, fixture);

                // Destroy any contacts associated with the fixture.
                BodyAtty::EraseContacts(*body, [&](Contact& contact) {
                    const auto fixtureA = contact.GetFixtureA();
                    const auto fixtureB = contact.GetFixtureB();
                    if ((fixtureA == &fixture) || (fixtureB == &fixture))
                    {
                        Destroy(m_contacts, m_contactListener, &contact, body);
                        return true;
                    }
                    return false;
                });
            }
        }
    });
}

PreStepStats::counter_type World::SynchronizeProxies(const StepConf& conf)
{
    auto proxiesMoved = PreStepStats::counter_type{0};
    for_each(begin(m_bodiesForProxies), end(m_bodiesForProxies), [&](Body *b) {
        const auto xfm = b->GetTransformation();
        // Not always true: assert(GetTransform0(b->GetSweep()) == xfm);
        proxiesMoved += Synchronize(*b, xfm, xfm, conf.displaceMultiplier, conf.aabbExtension);
    });
    m_bodiesForProxies.clear();
    return proxiesMoved;
}

void World::SetType(Body& body, playrho::BodyType type)
{
    assert(body.GetWorld() == this);
    if (body.GetType() == type)
    {
        return;
    }

    if (IsLocked())
    {
        throw WrongState("World::SetType: world is locked");
    }
    
    BodyAtty::SetTypeFlags(body, type);
    body.ResetMassData();
    
    // Destroy the attached contacts.
    BodyAtty::EraseContacts(body, [&](Contact& contact) {
        Destroy(m_contacts, m_contactListener, &contact, &body);
        return true;
    });

    if (type == BodyType::Static)
    {
#ifndef NDEBUG
        const auto xfm1 = GetTransform0(body.GetSweep());
        const auto xfm2 = body.GetTransformation();
        assert(xfm1 == xfm2);
#endif
        RegisterForProxies(body);
    }
    else
    {
        body.SetAwake();
        const auto fixtures = body.GetFixtures();
        for_each(begin(fixtures), end(fixtures), [&](Body::Fixtures::value_type& f) {
            InternalTouchProxies(GetRef(f));
        });
    }
}

Fixture* World::CreateFixture(Body& body, const Shape& shape,
                              const FixtureConf& def, bool resetMassData)
{
    assert(body.GetWorld() == this);

    {
        const auto childCount = GetChildCount(shape);
        const auto minVertexRadius = GetMinVertexRadius();
        const auto maxVertexRadius = GetMaxVertexRadius();
        for (auto i = ChildCounter{0}; i < childCount; ++i)
        {
            const auto vr = GetVertexRadius(shape, i);
            if (!(vr >= minVertexRadius))
            {
                throw InvalidArgument("World::CreateFixture: vertex radius < min");
            }
            if (!(vr <= maxVertexRadius))
            {
                throw InvalidArgument("World::CreateFixture: vertex radius > max");
            }
        }
    }
    
    if (IsLocked())
    {
        throw WrongState("World::CreateFixture: world is locked");
    }
    
    //const auto fixture = BodyAtty::CreateFixture(body, shape, def);
    const auto fixture = FixtureAtty::Create(body, def, shape);
    BodyAtty::AddFixture(body, fixture);

    if (body.IsEnabled())
    {
        RegisterForProxies(*fixture);
    }
    
    // Adjust mass properties if needed.
    if (fixture->GetDensity() > 0_kgpm2)
    {
        BodyAtty::SetMassDataDirty(body);
        if (resetMassData)
        {
            body.ResetMassData();
        }
    }
    
    // Let the world know we have a new fixture. This will cause new contacts
    // to be created at the beginning of the next time step.
    SetNewFixtures();
    
    return fixture;
}

bool World::Destroy(Fixture& fixture, bool resetMassData)
{
    auto& body = *fixture.GetBody();
    assert(body.GetWorld() == this);

    if (IsLocked())
    {
        throw WrongState("World::Destroy: world is locked");
    }
    
#if 0
    /*
     * XXX: Should the destruction listener be called when the user requested that
     *   the fixture be destroyed or only when the fixture is destroyed indirectly?
     */
    if (m_destructionListener)
    {
        m_destructionListener->SayGoodbye(fixture);
    }
#endif

    // Destroy any contacts associated with the fixture.
    BodyAtty::EraseContacts(body, [&](Contact& contact) {
        const auto fixtureA = contact.GetFixtureA();
        const auto fixtureB = contact.GetFixtureB();
        if ((fixtureA == &fixture) || (fixtureB == &fixture))
        {
            Destroy(m_contacts, m_contactListener, &contact, &body);
            return true;
        }
        return false;
    });
    
    EraseAll(m_fixturesForProxies, &fixture);
    DestroyProxies(m_proxies, m_tree, fixture);

    if (!BodyAtty::RemoveFixture(body, &fixture))
    {
        // Fixture probably destroyed already.
        return false;
    }
    FixtureAtty::Delete(&fixture);
    
    BodyAtty::SetMassDataDirty(body);
    if (resetMassData)
    {
        body.ResetMassData();
    }
    
    return true;
}

void World::CreateProxies(ProxyQueue& proxies, DynamicTree& tree, Fixture& fixture, Length aabbExtension)
{
    assert(fixture.GetProxyCount() == 0);
    
    const auto body = fixture.GetBody();
    const auto shape = fixture.GetShape();
    const auto xfm = GetTransformation(fixture);
    
    // Reserve proxy space and create proxies in the broad-phase.
    const auto childCount = GetChildCount(shape);
    auto fixtureProxies = std::make_unique<FixtureProxy[]>(childCount);
    for (auto childIndex = decltype(childCount){0}; childIndex < childCount; ++childIndex)
    {
        const auto dp = GetChild(shape, childIndex);
        const auto aabb = playrho::d2::ComputeAABB(dp, xfm);

        // Note: treeId from CreateLeaf can be higher than the number of fixture proxies.
        const auto fattenedAABB = GetFattenedAABB(aabb, aabbExtension);
        const auto treeId = tree.CreateLeaf(fattenedAABB, DynamicTree::LeafData{
            body, &fixture, childIndex});
        proxies.push_back(treeId);
        fixtureProxies[childIndex] = FixtureProxy{treeId};
    }

    FixtureAtty::SetProxies(fixture, std::move(fixtureProxies), childCount);
}

void World::DestroyProxies(ProxyQueue& proxies, DynamicTree& tree, Fixture& fixture) noexcept
{
    const auto fixtureProxies = FixtureAtty::GetProxies(fixture);
    const auto childCount = size(fixtureProxies);
    if (childCount > 0)
    {
        // Destroy proxies in reverse order from what they were created in.
        for (auto i = childCount - 1; i < childCount; --i)
        {
            const auto treeId = fixtureProxies[i].treeId;
            EraseFirst(proxies, treeId);
            tree.DestroyLeaf(treeId);
        }
    }
    FixtureAtty::ResetProxies(fixture);
}

void World::TouchProxies(Fixture& fixture) noexcept
{
    assert(fixture.GetBody()->GetWorld() == this);
    InternalTouchProxies(fixture);
}

void World::InternalTouchProxies(Fixture& fixture) noexcept
{
    const auto proxyCount = fixture.GetProxyCount();
    for (auto i = decltype(proxyCount){0}; i < proxyCount; ++i)
    {
        m_proxies.push_back(fixture.GetProxy(i).treeId);
    }
}

ContactCounter World::Synchronize(Body& body,
                                  Transformation xfm1, Transformation xfm2,
                                  Real multiplier, Length extension)
{
    assert(::playrho::IsValid(xfm1));
    assert(::playrho::IsValid(xfm2));

    auto updatedCount = ContactCounter{0};
    const auto displacement = multiplier * (xfm2.p - xfm1.p);
    const auto fixtures = body.GetFixtures();
    for_each(begin(fixtures), end(fixtures), [&](Body::Fixtures::value_type& f) {
        updatedCount += Synchronize(GetRef(f), xfm1, xfm2, displacement, extension);
    });
    return updatedCount;
}

ContactCounter World::Synchronize(Fixture& fixture,
                                  Transformation xfm1, Transformation xfm2,
                                  Length2 displacement, Length extension)
{
    assert(::playrho::IsValid(xfm1));
    assert(::playrho::IsValid(xfm2));
    
    auto updatedCount = ContactCounter{0};
    const auto shape = fixture.GetShape();
    const auto proxies = FixtureAtty::GetProxies(fixture);
    auto childIndex = ChildCounter{0};
    for (auto& proxy: proxies)
    {
        const auto treeId = proxy.treeId;
        
        // Compute an AABB that covers the swept shape (may miss some rotation effect).
        const auto aabb = ComputeAABB(GetChild(shape, childIndex), xfm1, xfm2);
        if (!Contains(m_tree.GetAABB(treeId), aabb))
        {
            const auto newAabb = GetDisplacedAABB(GetFattenedAABB(aabb, extension),
                                                  displacement);
            m_tree.UpdateLeaf(treeId, newAabb);
            m_proxies.push_back(treeId);
            ++updatedCount;
        }
        ++childIndex;
    }
    return updatedCount;
}

// Free functions...

StepStats Step(World& world, Time delta, TimestepIters velocityIterations,
               TimestepIters positionIterations)
{
    StepConf conf;
    conf.SetTime(delta);
    conf.regVelocityIterations = velocityIterations;
    conf.regPositionIterations = positionIterations;
    conf.toiVelocityIterations = velocityIterations;
    if (positionIterations == 0)
    {
        conf.toiPositionIterations = 0;
    }
    conf.dtRatio = delta * world.GetInvDeltaTime();
    return world.Step(conf);
}

ContactCounter GetTouchingCount(const World& world) noexcept
{
    const auto contacts = world.GetContacts();
    return static_cast<ContactCounter>(count_if(cbegin(contacts), cend(contacts),
                                                [&](const World::Contacts::value_type &c) {
        return GetRef(std::get<Contact*>(c)).IsTouching();
    }));
}

size_t GetFixtureCount(const World& world) noexcept
{
    auto sum = size_t{0};
    const auto bodies = world.GetBodies();
    for_each(cbegin(bodies), cend(bodies),
             [&](const World::Bodies::value_type &body) {
        sum += GetFixtureCount(GetRef(body));
    });
    return sum;
}

size_t GetShapeCount(const World& world) noexcept
{
    auto shapes = std::set<const void*>();
    const auto bodies = world.GetBodies();
    for_each(cbegin(bodies), cend(bodies), [&](const World::Bodies::value_type &b) {
        const auto fixtures = GetRef(b).GetFixtures();
        for_each(cbegin(fixtures), cend(fixtures), [&](const Body::Fixtures::value_type& f) {
            shapes.insert(GetData(GetRef(f).GetShape()));
        });
    });
    return size(shapes);
}

BodyCounter GetAwakeCount(const World& world) noexcept
{
    const auto bodies = world.GetBodies();
    return static_cast<BodyCounter>(count_if(cbegin(bodies), cend(bodies),
                                             [&](const World::Bodies::value_type &b) {
                                                 return GetRef(b).IsAwake(); }));
}
    
BodyCounter Awaken(World& world) noexcept
{
    // Can't use count_if since body gets modified.
    auto awoken = BodyCounter{0};
    const auto bodies = world.GetBodies();
    for_each(begin(bodies), end(bodies), [&](World::Bodies::value_type &b) {
        if (playrho::d2::Awaken(GetRef(b)))
        {
            ++awoken;
        }
    });
    return awoken;
}

void SetAccelerations(World& world, Acceleration acceleration) noexcept
{
    const auto bodies = world.GetBodies();
    for_each(begin(bodies), end(bodies), [&](World::Bodies::value_type &b) {
        SetAcceleration(GetRef(b), acceleration);
    });
}

void SetAccelerations(World& world, LinearAcceleration2 acceleration) noexcept
{
    const auto bodies = world.GetBodies();
    for_each(begin(bodies), end(bodies), [&](World::Bodies::value_type &b) {
        SetLinearAcceleration(GetRef(b), acceleration);
    });
}

Body* FindClosestBody(const World& world, Length2 location) noexcept
{
    const auto bodies = world.GetBodies();
    auto found = static_cast<decltype(bodies)::iterator_type::value_type>(nullptr);
    auto minLengthSquared = std::numeric_limits<Area>::infinity();
    for (const auto& b: bodies)
    {
        auto& body = GetRef(b);
        const auto bodyLoc = body.GetLocation();
        const auto lengthSquared = GetMagnitudeSquared(bodyLoc - location);
        if (minLengthSquared > lengthSquared)
        {
            minLengthSquared = lengthSquared;
            found = &body;
        }
    }
    return found;
}

} // namespace d2

RegStepStats& Update(RegStepStats& lhs, const IslandStats& rhs) noexcept
{
    lhs.maxIncImpulse = std::max(lhs.maxIncImpulse, rhs.maxIncImpulse);
    lhs.minSeparation = std::min(lhs.minSeparation, rhs.minSeparation);
    lhs.islandsSolved += rhs.solved;
    lhs.sumPosIters += rhs.positionIterations;
    lhs.sumVelIters += rhs.velocityIterations;
    lhs.bodiesSlept += rhs.bodiesSlept;
    return lhs;
}

} // namespace playrho

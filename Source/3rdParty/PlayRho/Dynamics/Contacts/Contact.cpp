/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Contacts/Contact.hpp"
#include "PlayRho/Collision/Collision.hpp"
#include "PlayRho/Collision/Distance.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/Fixture.hpp"
#include "PlayRho/Dynamics/World.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"

namespace playrho {
namespace d2 {

namespace {

inline Manifold::Conf GetManifoldConf(const playrho::StepConf& conf)
{
    auto manifoldConf = Manifold::Conf{};
    manifoldConf.linearSlop = conf.linearSlop;
    manifoldConf.tolerance = conf.tolerance;
    manifoldConf.targetDepth = conf.targetDepth;
    manifoldConf.maxCirclesRatio = conf.maxCirclesRatio;
    return manifoldConf;
}

inline DistanceConf GetDistanceConf(const playrho::StepConf& conf)
{
    DistanceConf distanceConf;
    distanceConf.maxIterations = conf.maxDistanceIters;
    return distanceConf;
}
} // namespace

Contact::UpdateConf Contact::GetUpdateConf(const playrho::StepConf& conf) noexcept
{
    return UpdateConf{GetDistanceConf(conf), GetManifoldConf(conf)};
}

Contact::Contact(Fixture* fA, ChildCounter iA, Fixture* fB, ChildCounter iB):
    m_fixtureA{fA}, m_fixtureB{fB},
    m_indexA{iA}, m_indexB{iB},
    m_friction{MixFriction(fA->GetFriction(), fB->GetFriction())},
    m_restitution{MixRestitution(fA->GetRestitution(), fB->GetRestitution())}
{
    assert(fA != fB);
    assert(fA->GetBody() != fB->GetBody());
}

void Contact::Update(const UpdateConf& conf, ContactListener* listener)
{
    const auto oldManifold = m_manifold;

    // Note: do not assume the fixture AABBs are overlapping or are valid.
    const auto oldTouching = (m_flags & e_touchingFlag) != 0;
    auto newTouching = false;

    const auto fixtureA = GetFixtureA();
    const auto indexA = GetChildIndexA();
    const auto fixtureB = GetFixtureB();
    const auto indexB = GetChildIndexB();
    const auto shapeA = fixtureA->GetShape();
    const auto xfA = fixtureA->GetBody()->GetTransformation();
    const auto shapeB = fixtureB->GetShape();
    const auto xfB = fixtureB->GetBody()->GetTransformation();
    const auto childA = GetChild(shapeA, indexA);
    const auto childB = GetChild(shapeB, indexB);

    // NOTE: Ideally, the touching state returned by the TestOverlap function
    //   agrees 100% of the time with that returned from the CollideShapes function.
    //   This is not always the case however especially as the separation or overlap
    //   approaches zero.
#define OVERLAP_TOLERANCE (SquareMeter / Real(20))

    const auto sensor = fixtureA->IsSensor() || fixtureB->IsSensor();
    if (sensor)
    {
        const auto overlapping = TestOverlap(childA, xfA, childB, xfB, conf.distance);
        newTouching = (overlapping >= 0_m2);

#ifdef OVERLAP_TOLERANCE
#ifndef NDEBUG
        const auto tolerance = OVERLAP_TOLERANCE;
        const auto manifold = CollideShapes(childA, xfA, childB, xfB, conf.manifold);
        assert(newTouching == (manifold.GetPointCount() > 0) ||
               abs(overlapping) < tolerance);
#endif
#endif
        
        // Sensors don't generate manifolds.
        m_manifold = Manifold{};
    }
    else
    {
        auto newManifold = CollideShapes(childA, xfA, childB, xfB, conf.manifold);

        const auto old_point_count = oldManifold.GetPointCount();
        const auto new_point_count = newManifold.GetPointCount();

        newTouching = new_point_count > 0;

#ifdef OVERLAP_TOLERANCE
#ifndef NDEBUG
        const auto tolerance = OVERLAP_TOLERANCE;
        const auto overlapping = TestOverlap(childA, xfA, childB, xfB, conf.distance);
        assert(newTouching == (overlapping >= 0_m2) ||
               abs(overlapping) < tolerance);
#endif
#endif
        // Match old contact ids to new contact ids and copy the stored impulses to warm
        // start the solver. Note: missing any opportunities to warm start the solver
        // results in squishier stacking and less stable simulations.
        bool found[2] = {false, new_point_count < 2};
        for (auto i = decltype(new_point_count){0}; i < new_point_count; ++i)
        {
            const auto new_cf = newManifold.GetContactFeature(i);
            for (auto j = decltype(old_point_count){0}; j < old_point_count; ++j)
            {
                if (new_cf == oldManifold.GetContactFeature(j))
                {
                    found[i] = true;
                    newManifold.SetContactImpulses(i, oldManifold.GetContactImpulses(j));
                    break;
                }
            }
        }
        // If warm starting data wasn't found for a manifold point via contact feature
        // matching, it's better to just set the data to whatever old point is closest
        // to the new one.
        for (auto i = decltype(new_point_count){0}; i < new_point_count; ++i)
        {
            if (!found[i])
            {
                auto leastSquareDiff = std::numeric_limits<Area>::infinity();
                const auto newPt = newManifold.GetPoint(i);
                for (auto j = decltype(old_point_count){0}; j < old_point_count; ++j)
                {
                    const auto oldPt = oldManifold.GetPoint(j);
                    const auto squareDiff = GetMagnitudeSquared(oldPt.localPoint - newPt.localPoint);
                    if (leastSquareDiff > squareDiff)
                    {
                        leastSquareDiff = squareDiff;
                        newManifold.SetContactImpulses(i, oldManifold.GetContactImpulses(j));
                    }
                }
            }
        }

        // Ideally this method is **NEVER** called unless a dependency changed such
        // that the following assertion is **ALWAYS** valid.
        //assert(newManifold != oldManifold);

        m_manifold = newManifold;

#ifdef MAKE_CONTACT_PROCESSING_ORDER_DEPENDENT
        const auto bodyA = fixtureA->GetBody();
        const auto bodyB = fixtureB->GetBody();

        assert(bodyA);
        assert(bodyB);

        /*
         * The following code creates an ordering dependency in terms of update processing
         * over a container of contacts. It also puts this method into the situation of
         * modifying bodies which adds race potential in a multi-threaded mode of operation.
         * Lastly, without this code, the step-statistics show a world getting to sleep in
         * less TOI position iterations.
         */
        if (newTouching != oldTouching)
        {
            bodyA->SetAwake();
            bodyB->SetAwake();
        }
#endif
    }

    UnflagForUpdating();

    if (!oldTouching && newTouching)
    {
        SetTouching();
        if (listener)
        {
            listener->BeginContact(*this);
        }
    }
    else if (oldTouching && !newTouching)
    {
        UnsetTouching();
        if (listener)
        {
            listener->EndContact(*this);
        }
    }

    if (!sensor && newTouching)
    {
        if (listener)
        {
            listener->PreSolve(*this, oldManifold);
        }
    }
}

// Free functions...

Body* GetBodyA(const Contact& contact) noexcept
{
    return contact.GetFixtureA()->GetBody();
}

Body* GetBodyB(const Contact& contact) noexcept
{
    return contact.GetFixtureB()->GetBody();
}

bool HasSensor(const Contact& contact) noexcept
{
    return contact.GetFixtureA()->IsSensor() || contact.GetFixtureB()->IsSensor();
}

bool IsImpenetrable(const Contact& contact) noexcept
{
    const auto bA = contact.GetFixtureA()->GetBody();
    const auto bB = contact.GetFixtureB()->GetBody();
    return bA->IsImpenetrable() || bB->IsImpenetrable();
}

bool IsActive(const Contact& contact) noexcept
{
    const auto bA = contact.GetFixtureA()->GetBody();
    const auto bB = contact.GetFixtureB()->GetBody();
    
    assert(!bA->IsAwake() || bA->IsSpeedable());
    assert(!bB->IsAwake() || bB->IsSpeedable());
    
    const auto activeA = bA->IsAwake();
    const auto activeB = bB->IsAwake();
    
    // Is at least one body active (awake and dynamic or kinematic)?
    return activeA || activeB;
}

void SetAwake(const Contact& c) noexcept
{
    SetAwake(*c.GetFixtureA());
    SetAwake(*c.GetFixtureB());
}

/// Resets the friction mixture to the default value.
void ResetFriction(Contact& contact)
{
    contact.SetFriction(MixFriction(contact.GetFixtureA()->GetFriction(), contact.GetFixtureB()->GetFriction()));
}

/// Reset the restitution to the default value.
void ResetRestitution(Contact& contact) noexcept
{
    const auto restitutionA = contact.GetFixtureA()->GetRestitution();
    const auto restitutionB = contact.GetFixtureB()->GetRestitution();
    contact.SetRestitution(MixRestitution(restitutionA, restitutionB));
}

TOIOutput CalcToi(const Contact& contact, ToiConf conf)
{
    const auto fA = contact.GetFixtureA();
    const auto fB = contact.GetFixtureB();
    const auto bA = fA->GetBody();
    const auto bB = fB->GetBody();

    const auto proxyA = GetChild(fA->GetShape(), contact.GetChildIndexA());
    const auto proxyB = GetChild(fB->GetShape(), contact.GetChildIndexB());

    // Large rotations can make the root finder of TimeOfImpact fail, so normalize sweep angles.
    const auto sweepA = GetNormalized(bA->GetSweep());
    const auto sweepB = GetNormalized(bB->GetSweep());

    // Compute the TOI for this contact (one or both bodies are active and impenetrable).
    // Computes the time of impact in interval [0, 1]
    // Large rotations can make the root finder of TimeOfImpact fail, so normalize the sweep angles.
    return GetToiViaSat(proxyA, sweepA, proxyB, sweepB, conf);
}

} // namespace d2
} // namespace playrho

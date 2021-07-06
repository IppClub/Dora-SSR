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

#include "PlayRho/Dynamics/WorldBody.hpp"
#include "PlayRho/Dynamics/WorldShape.hpp"

#include "PlayRho/Dynamics/World.hpp"
#include "PlayRho/Dynamics/Body.hpp"

#include <algorithm>
#include <functional>
#include <memory>

using std::for_each;
using std::remove;
using std::sort;
using std::transform;
using std::unique;

namespace playrho {
namespace d2 {

using playrho::size;

BodyCounter GetBodyRange(const World& world) noexcept
{
    return world.GetBodyRange();
}

std::vector<BodyID> GetBodies(const World& world) noexcept
{
    return world.GetBodies();
}

std::vector<BodyID> GetBodiesForProxies(const World& world) noexcept
{
    return world.GetBodiesForProxies();
}

BodyID CreateBody(World& world, const Body& body, bool resetMassData)
{
    const auto id = world.CreateBody(body);
    if (resetMassData) {
        ResetMassData(world, id);
    }
    return id;
}

const Body& GetBody(const World& world, BodyID id)
{
    return world.GetBody(id);
}

void SetBody(World& world, BodyID id, const Body& body)
{
    world.SetBody(id, body);
}

void Destroy(World& world, BodyID id)
{
    world.Destroy(id);
}

void Attach(World& world, BodyID id, ShapeID shapeID, bool resetMassData)
{
    auto body = GetBody(world, id);
    body.Attach(shapeID);
    SetBody(world, id, body);
    if (resetMassData) {
        ResetMassData(world, id);
    }
}

void Attach(World& world, BodyID id, const Shape& shape, bool resetMassData)
{
    Attach(world, id, CreateShape(world, shape), resetMassData);
}

bool Detach(World& world, BodyID id, ShapeID shapeID, bool resetMassData)
{
    auto body = GetBody(world, id);
    if (body.Detach(shapeID)) {
        SetBody(world, id, body);
        if (resetMassData) {
            ResetMassData(world, id);
        }
        return true;
    }
    return false;
}

bool Detach(World& world, BodyID id, bool resetMassData)
{
    auto anyDetached = false;
    while (!GetShapes(world, id).empty()) {
        anyDetached |= Detach(world, id, GetShapes(world, id).back());
    }
    if (anyDetached && resetMassData) {
        ResetMassData(world, id);
    }
    return anyDetached;
}

std::vector<ShapeID> GetShapes(const World& world, BodyID id)
{
    return world.GetShapes(id);
}

LinearAcceleration2 GetLinearAcceleration(const World& world, BodyID id)
{
    return GetLinearAcceleration(GetBody(world, id));
}

AngularAcceleration GetAngularAcceleration(const World& world, BodyID id)
{
    return GetAngularAcceleration(GetBody(world, id));
}

Acceleration GetAcceleration(const World& world, BodyID id)
{
    const auto& body = GetBody(world, id);
    return Acceleration{GetLinearAcceleration(body), GetAngularAcceleration(body)};
}

void SetAcceleration(World& world, BodyID id,
                     LinearAcceleration2 linear, AngularAcceleration angular)
{
    auto body = GetBody(world, id);
    SetAcceleration(body, linear, angular);
    SetBody(world, id, body);
}

void SetAcceleration(World& world, BodyID id, LinearAcceleration2 value)
{
    auto body = GetBody(world, id);
    SetAcceleration(body, value);
    SetBody(world, id, body);
}

void SetAcceleration(World& world, BodyID id, AngularAcceleration value)
{
    auto body = GetBody(world, id);
    SetAcceleration(body, value);
    SetBody(world, id, body);
}

void SetAcceleration(World& world, BodyID id, Acceleration value)
{
    auto body = GetBody(world, id);
    SetAcceleration(body, value);
    SetBody(world, id, body);
}

void SetTransformation(World& world, BodyID id, Transformation value)
{
    auto body = GetBody(world, id);
    SetTransformation(body, value);
    SetBody(world, id, body);
}

void SetLocation(World& world, BodyID id, Length2 value)
{
    auto body = GetBody(world, id);
    SetLocation(body, value);
    SetBody(world, id, body);
}

void SetAngle(World& world, BodyID id, Angle value)
{
    auto body = GetBody(world, id);
    SetAngle(body, value);
    SetBody(world, id, body);
}

void RotateAboutWorldPoint(World& world, BodyID body, Angle amount, Length2 worldPoint)
{
    const auto xfm = GetTransformation(world, body);
    const auto p = xfm.p - worldPoint;
    const auto c = cos(amount);
    const auto s = sin(amount);
    const auto x = GetX(p) * c - GetY(p) * s;
    const auto y = GetX(p) * s + GetY(p) * c;
    const auto pos = Length2{x, y} + worldPoint;
    const auto angle = GetAngle(xfm.q) + amount;
    SetTransform(world, body, pos, angle);
}

void RotateAboutLocalPoint(World& world, BodyID body, Angle amount, Length2 localPoint)
{
    RotateAboutWorldPoint(world, body, amount, GetWorldPoint(world, body, localPoint));
}

Acceleration CalcGravitationalAcceleration(const World& world, BodyID body)
{
    const auto m1 = GetMass(world, body);
    if (m1 != 0_kg)
    {
        auto sumForce = Force2{};
        const auto loc1 = GetLocation(world, body);
        for (const auto& b2: world.GetBodies())
        {
            if (b2 == body)
            {
                continue;
            }
            const auto m2 = GetMass(world, b2);
            const auto delta = GetLocation(world, b2) - loc1;
            const auto dir = GetUnitVector(delta);
            const auto rr = GetMagnitudeSquared(delta);

            // Uses Newton's law of universal gravitation: F = G * m1 * m2 / rr.
            // See: https://en.wikipedia.org/wiki/Newton%27s_law_of_universal_gravitation
            // Note that BigG is typically very small numerically compared to either mass
            // or the square of the radius between the masses. That's important to recognize
            // in order to avoid operational underflows or overflows especially when
            // playrho::Real has less exponential range like when it's defined to be float
            // instead of double. The operational ordering is deliberately established here
            // to help with this.
            const auto orderedMass = std::minmax(m1, m2);
            const auto f = (BigG * std::get<0>(orderedMass)) * (std::get<1>(orderedMass) / rr);
            sumForce += f * dir;
        }
        // F = m a... i.e.  a = F / m.
        return Acceleration{sumForce / m1, 0 * RadianPerSquareSecond};
    }
    return Acceleration{};
}

BodyCounter GetWorldIndex(const World&, BodyID id) noexcept
{
    return to_underlying(id);
}

BodyType GetType(const World& world, BodyID id)
{
    return GetType(GetBody(world, id));
}

void SetType(World& world, BodyID id, BodyType value, bool resetMassData)
{
    auto body = GetBody(world, id);
    if (GetType(body) != value) {
        SetType(body, value);
        world.SetBody(id, body);
        if (resetMassData) {
            ResetMassData(world, id);
        }
    }
}

Transformation GetTransformation(const World& world, BodyID id)
{
    return GetTransformation(GetBody(world, id));
}

Angle GetAngle(const World& world, BodyID id)
{
    return GetAngle(GetBody(world, id));
}

Velocity GetVelocity(const World& world, BodyID id)
{
    return GetVelocity(GetBody(world, id));
}

void SetVelocity(World& world, BodyID id, const Velocity& value)
{
    auto body = GetBody(world, id);
    SetVelocity(body, value);
    world.SetBody(id, body);
}

void SetVelocity(World& world, BodyID id, const LinearVelocity2& value)
{
    auto body = GetBody(world, id);
    SetVelocity(body, Velocity{value, GetAngularVelocity(body)});
    world.SetBody(id, body);
}

void SetVelocity(World& world, BodyID id, AngularVelocity value)
{
    auto body = GetBody(world, id);
    SetVelocity(body, Velocity{GetLinearVelocity(body), value});
    world.SetBody(id, body);
}

bool IsEnabled(const World& world, BodyID id)
{
    return IsEnabled(GetBody(world, id));
}

void SetEnabled(World& world, BodyID id, bool value)
{
    auto body = GetBody(world, id);
    SetEnabled(body, value);
    world.SetBody(id, body);
}

bool IsAwake(const World& world, BodyID id)
{
    return IsAwake(GetBody(world, id));
}

void SetAwake(World& world, BodyID id)
{
    auto body = GetBody(world, id);
    SetAwake(body);
    world.SetBody(id, body);
}

void UnsetAwake(World& world, BodyID id)
{
    auto body = GetBody(world, id);
    UnsetAwake(body);
    world.SetBody(id, body);
}

bool IsMassDataDirty(const World& world, BodyID id)
{
    return IsMassDataDirty(GetBody(world, id));
}

bool IsFixedRotation(const World& world, BodyID id)
{
    return IsFixedRotation(GetBody(world, id));
}

void SetFixedRotation(World& world, BodyID id, bool value)
{
    auto body = GetBody(world, id);
    if (IsFixedRotation(body) != value) {
        SetFixedRotation(body, value);
        world.SetBody(id, body);
        ResetMassData(world, id);
    }
}

Length2 GetWorldCenter(const World& world, BodyID id)
{
    return GetWorldCenter(GetBody(world, id));
}

InvMass GetInvMass(const World& world, BodyID id)
{
    return GetInvMass(GetBody(world, id));
}

InvRotInertia GetInvRotInertia(const World& world, BodyID id)
{
    return GetInvRotInertia(GetBody(world, id));
}

Length2 GetLocalCenter(const World& world, BodyID id)
{
    return GetLocalCenter(GetBody(world, id));
}

MassData ComputeMassData(const World& world, BodyID id)
{
    auto mass = 0_kg;
    auto I = RotInertia{0};
    auto weightedCenter = Length2{};
    for (const auto& shapeId: GetShapes(world, id)) {
        const auto& shape = GetShape(world, shapeId);
        if (GetDensity(shape) > 0_kgpm2) {
            const auto massData = GetMassData(shape);
            mass += Mass{massData.mass};
            weightedCenter += Real{massData.mass / Kilogram} * massData.center;
            I += RotInertia{massData.I};
        }
    }
    const auto center = (mass > 0_kg)? (weightedCenter / (Real{mass/1_kg})): Length2{};
    return MassData{center, mass, I};
}

void SetMassData(World& world, BodyID id, const MassData& massData)
{
    auto body = GetBody(world, id);

    if (!body.IsAccelerable()) {
        body.SetInvMassData(InvMass{}, InvRotInertia{});
        if (!body.IsSpeedable()) {
            body.SetSweep(Sweep{Position{GetLocation(body), GetAngle(body)}});
        }
        world.SetBody(id, body);
        return;
    }

    const auto mass = (massData.mass > 0_kg)? Mass{massData.mass}: 1_kg;
    const auto invMass = Real{1} / mass;
    auto invRotInertia = Real(0) / (1_m2 * 1_kg / SquareRadian);
    if ((massData.I > RotInertia{0}) && (!body.IsFixedRotation())) {
        const auto lengthSquared = GetMagnitudeSquared(massData.center);
        // L^2 M QP^-2
        const auto I = RotInertia{massData.I} - RotInertia{(mass * lengthSquared) / SquareRadian};
        assert(I > RotInertia{0});
        invRotInertia = Real{1} / I;
    }
    body.SetInvMassData(invMass, invRotInertia);
    // Move center of mass.
    const auto oldCenter = GetWorldCenter(body);
    SetSweep(body, Sweep{
        Position{Transform(massData.center, GetTransformation(body)), GetAngle(body)},
        massData.center
    });
    // Update center of mass velocity.
    const auto newCenter = GetWorldCenter(body);
    const auto deltaCenter = newCenter - oldCenter;
    auto newVelocity = body.GetVelocity();
    newVelocity.linear += GetRevPerpendicular(deltaCenter) * (newVelocity.angular / Radian);
    body.JustSetVelocity(newVelocity);
    world.SetBody(id, body);
}

std::vector<std::pair<BodyID, JointID>> GetJoints(const World& world, BodyID id)
{
    return world.GetJoints(id);
}

bool IsSpeedable(const World& world, BodyID id)
{
    return IsSpeedable(GetBody(world, id));
}

bool IsAccelerable(const World& world, BodyID id)
{
    return IsAccelerable(GetBody(world, id));
}

bool IsImpenetrable(const World& world, BodyID id)
{
    return IsImpenetrable(GetBody(world, id));
}

void SetImpenetrable(World& world, BodyID id)
{
    auto body = GetBody(world, id);
    SetImpenetrable(body);
    world.SetBody(id, body);
}

void UnsetImpenetrable(World& world, BodyID id)
{
    auto body = GetBody(world, id);
    UnsetImpenetrable(body);
    world.SetBody(id, body);
}

bool IsSleepingAllowed(const World& world, BodyID id)
{
    return IsSleepingAllowed(GetBody(world, id));
}

void SetSleepingAllowed(World& world, BodyID id, bool value)
{
    auto body = GetBody(world, id);
    SetSleepingAllowed(body, value);
    world.SetBody(id, body);
}

Frequency GetLinearDamping(const World& world, BodyID id)
{
    return GetLinearDamping(GetBody(world, id));
}

void SetLinearDamping(World& world, BodyID id, NonNegative<Frequency> value)
{
    auto body = GetBody(world, id);
    SetLinearDamping(body, value);
    world.SetBody(id, body);
}

Frequency GetAngularDamping(const World& world, BodyID id)
{
    return GetAngularDamping(GetBody(world, id));
}

void SetAngularDamping(World& world, BodyID id, NonNegative<Frequency> value)
{
    auto body = GetBody(world, id);
    SetAngularDamping(body, value);
    world.SetBody(id, body);
}

std::vector<KeyedContactPtr> GetContacts(const World& world, BodyID id)
{
    return world.GetContacts(id);
}

Force2 GetCentripetalForce(const World& world, BodyID id, Length2 axis)
{
    // For background on centripetal force, see:
    //   https://en.wikipedia.org/wiki/Centripetal_force

    // Force is M L T^-2.
    const auto velocity = GetLinearVelocity(world, id);
    const auto magnitudeOfVelocity = GetMagnitude(GetVec2(velocity)) * MeterPerSecond;
    const auto location = GetLocation(world, id);
    const auto mass = GetMass(world, id);
    const auto delta = axis - location;
    const auto invRadius = Real{1} / GetMagnitude(delta);
    const auto dir = delta * invRadius;
    return Force2{dir * mass * Square(magnitudeOfVelocity) * invRadius};
}

void ApplyForce(World& world, BodyID id, Force2 force, Length2 point)
{
    // Torque is L^2 M T^-2 QP^-1.
    const auto& body = GetBody(world, id);
    const auto linAccel = LinearAcceleration2{force * GetInvMass(body)};
    const auto invRotI = GetInvRotInertia(body); // L^-2 M^-1 QP^2
    const auto dp = Length2{point - GetWorldCenter(body)}; // L
    const auto cp = Torque{Cross(dp, force) / Radian}; // L * M L T^-2 is L^2 M T^-2
                                                       // L^2 M T^-2 QP^-1 * L^-2 M^-1 QP^2 = QP T^-2;
    const auto angAccel = AngularAcceleration{cp * invRotI};
    SetAcceleration(world, id,
                    GetLinearAcceleration(world, id) + linAccel,
                    GetAngularAcceleration(world, id) + angAccel);
}

void ApplyTorque(World& world, BodyID id, Torque torque)
{
    const auto linAccel = GetLinearAcceleration(world, id);
    const auto invRotI = GetInvRotInertia(world, id);
    const auto angAccel = GetAngularAcceleration(world, id) + torque * invRotI;
    SetAcceleration(world, id, linAccel, angAccel);
}

void ApplyLinearImpulse(World& world, BodyID id, Momentum2 impulse, Length2 point)
{
    auto body = GetBody(world, id);
    ApplyLinearImpulse(body, impulse, point);
    SetBody(world, id, body);
}

void ApplyAngularImpulse(World& world, BodyID id, AngularMomentum impulse)
{
    auto body = GetBody(world, id);
    ApplyAngularImpulse(body, impulse);
    SetBody(world, id, body);
}

BodyCounter GetAwakeCount(const World& world) noexcept
{
    const auto bodies = world.GetBodies();
    return static_cast<BodyCounter>(count_if(cbegin(bodies), cend(bodies),
                                             [&](const auto &b) {
        return IsAwake(world, b); }));
}

BodyCounter Awaken(World& world) noexcept
{
    // Can't use count_if since body gets modified.
    auto awoken = BodyCounter{0};
    const auto bodies = world.GetBodies();
    for_each(begin(bodies), end(bodies), [&world,&awoken](const auto &b) {
        if (::playrho::d2::Awaken(world, b))
        {
            ++awoken;
        }
    });
    return awoken;
}

void SetAccelerations(World& world, Acceleration acceleration) noexcept
{
    const auto bodies = world.GetBodies();
    for_each(begin(bodies), end(bodies), [&world, acceleration](const auto &b) {
        SetAcceleration(world, b, acceleration);
    });
}

void SetAccelerations(World& world, LinearAcceleration2 acceleration) noexcept
{
    const auto bodies = world.GetBodies();
    for_each(begin(bodies), end(bodies), [&world, acceleration](const auto &b) {
        SetAcceleration(world, b, acceleration);
    });
}

BodyID FindClosestBody(const World& world, Length2 location) noexcept
{
    const auto bodies = world.GetBodies();
    auto found = InvalidBodyID;
    auto minLengthSquared = std::numeric_limits<Area>::infinity();
    for (const auto& body: bodies)
    {
        const auto bodyLoc = GetLocation(world, body);
        const auto lengthSquared = GetMagnitudeSquared(bodyLoc - location);
        if (minLengthSquared > lengthSquared)
        {
            minLengthSquared = lengthSquared;
            found = body;
        }
    }
    return found;
}

} // namespace d2
} // namespace playrho

/*
 * Original work Copyright (c) 2007-2011 Erin Catto http://www.box2d.org
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

#include "playrho/ConstraintSolverConf.hpp"
#include "playrho/StepConf.hpp"

#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/d2/GearJointConf.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/PrismaticJointConf.hpp"
#include "playrho/d2/RevoluteJointConf.hpp"
#include "playrho/d2/World.hpp"
#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/WorldJoint.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible_v<GearJointConf>,
              "GearJointConf should be default constructible!");
static_assert(std::is_copy_constructible_v<GearJointConf>,
              "GearJointConf should be copy constructible!");
static_assert(std::is_copy_assignable_v<GearJointConf>,
              "GearJointConf should be copy assignable!");
static_assert(std::is_move_constructible_v<GearJointConf>,
              "GearJointConf should be move constructible!");
static_assert(std::is_move_assignable_v<GearJointConf>,
              "GearJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible_v<GearJointConf>,
              "GearJointConf should be nothrow destructible!");

namespace {

#if 0
Angle GetTransformationAngle(const World& world, BodyID id)
{
    return GetAngle(GetDirection(GetTransformation(world, id)));
}
#endif

} // namespace

// Gear Joint:
// C0 = (coordinate1 + ratio * coordinate2)_initial
// C = (coordinate1 + ratio * coordinate2) - C0 = 0
// J = [J1 ratio * J2]
// K = J * invM * JT
//   = J1 * invM1 * J1T + ratio * ratio * J2 * invM2 * J2T
//
// Revolute:
// coordinate = rotation
// Cdot = angularVelocity
// J = [0 0 1]
// K = J * invM * JT = invI
//
// Prismatic:
// coordinate = dot(p - pg, ug)
// Cdot = dot(v + cross(w, r), ug)
// J = [ug cross(r, ug)]
// K = J * invM * JT = invMass + invI * cross(r, ug)^2

GearJointConf::GearJointConf(BodyID bA, BodyID bB, BodyID bC, BodyID bD) noexcept
    : super{super{}.UseBodyA(bA).UseBodyB(bB)}, bodyC(bC), bodyD(bD)
{
    // Intentionally empty.
}

GearJointConf GetGearJointConf(const Joint& joint)
{
    return TypeCast<GearJointConf>(joint);
}

GearJointConf GetGearJointConf(const World& world, JointID id1, JointID id2, Real ratio)
{
    auto def = GearJointConf{/*body-A*/ GetBodyB(world, id1), /*body-B*/ GetBodyB(world, id2),
                             /*body-C*/ GetBodyA(world, id1), /*body-D*/ GetBodyA(world, id2)};
    auto scalar1 = Real{0};
    const auto type1 = GetType(world, id1);
    if (type1 == GetTypeID<RevoluteJointConf>()) {
#if 1
        const auto referenceAngle = GetReferenceAngle(world, id1);
        def.typeDataAC = GearJointConf::RevoluteData{referenceAngle};
        scalar1 =
            ((GetAngle(world, def.bodyA) - GetAngle(world, def.bodyC)) - referenceAngle) / 1_rad;
#else
        const auto referenceAngle = ::playrho::GetNormalized(GetReferenceAngle(world, id1));
        def.typeDataAC = GearJointConf::RevoluteData{referenceAngle};
        scalar1 =
            ((GetTransformationAngle(world, def.bodyA) - GetTransformationAngle(world, def.bodyC)) -
             referenceAngle) /
            1_rad;
        // scalar1 = GetShortestDelta(referenceAngle, GetShortestDelta(GetAngle(world, def.bodyC),
        // GetAngle(world, def.bodyA))) / 1_rad;
#endif
    }
    else if (type1 == GetTypeID<PrismaticJointConf>()) {
        const auto xfA = GetTransformation(world, def.bodyA);
        const auto xfC = GetTransformation(world, def.bodyC);
        const auto laA = GetLocalAnchorA(world, id1);
        const auto laB = GetLocalAnchorB(world, id1);
        const auto lxA = GetLocalXAxisA(world, id1);
        def.typeDataAC = GearJointConf::PrismaticData{laA, laB, lxA};
        // def.localAnchorC = GetLocalAnchorA(world, id1);
        // def.localAnchorA = GetLocalAnchorB(world, id1);
        const auto pC = laA;
        const auto pA = InverseRotate(Rotate(laB, xfA.q) + (xfA.p - xfC.p), xfC.q);
        scalar1 = Dot(pA - pC, lxA) / 1_m;
    }
    else {
        throw InvalidArgument("GetGearJointConf not supported for first joint's type");
    }
    auto scalar2 = Real{0};
    const auto type2 = GetType(world, id2);
    if (type2 == GetTypeID<RevoluteJointConf>()) {
#if 1
        const auto referenceAngle = GetReferenceAngle(world, id2);
        def.typeDataBD = GearJointConf::RevoluteData{referenceAngle};
        scalar2 =
            ((GetAngle(world, def.bodyB) - GetAngle(world, def.bodyD)) - referenceAngle) / 1_rad;
#else
        const auto referenceAngle = ::playrho::GetNormalized(GetReferenceAngle(world, id2));
        def.typeDataBD = GearJointConf::RevoluteData{referenceAngle};
        scalar2 =
            ((GetTransformationAngle(world, def.bodyB) - GetTransformationAngle(world, def.bodyD)) -
             referenceAngle) /
            1_rad;
        // scalar2 = GetShortestDelta(referenceAngle, GetShortestDelta(GetAngle(world, def.bodyD),
        // GetAngle(world, def.bodyB))) / 1_rad;
#endif
    }
    else if (type2 == GetTypeID<PrismaticJointConf>()) {
        const auto xfB = GetTransformation(world, def.bodyB);
        const auto xfD = GetTransformation(world, def.bodyD);
        const auto laA = GetLocalAnchorA(world, id2);
        const auto laB = GetLocalAnchorB(world, id2);
        const auto lxA = GetLocalXAxisA(world, id2);
        def.typeDataBD = GearJointConf::PrismaticData{laA, laB, lxA};
        // def.localAnchorD = GetLocalAnchorA(world, id2);
        // def.localAnchorB = GetLocalAnchorB(world, id2);
        const auto pD = laA;
        const auto pB = InverseRotate(Rotate(laB, xfB.q) + (xfB.p - xfD.p), xfD.q);
        scalar2 = Dot(pB - pD, lxA) / 1_m;
    }
    else {
        throw InvalidArgument("GetGearJointConf not supported for second joint's type");
    }
    def.ratio = ratio;
    def.constant = scalar1 + def.ratio * scalar2;
    return def;
}

void InitVelocity(GearJointConf& object, const Span<BodyConstraint>& bodies, const StepConf& step,
                  const ConstraintSolverConf&)
{
    if ((object.bodyA == InvalidBodyID) || (object.bodyB == InvalidBodyID) || //
        (object.bodyC == InvalidBodyID) || (object.bodyD == InvalidBodyID)) {
        return;
    }

    auto& bodyConstraintA = At(bodies, object.bodyA);
    auto& bodyConstraintB = At(bodies, object.bodyB);
    auto& bodyConstraintC = At(bodies, object.bodyC);
    auto& bodyConstraintD = At(bodies, object.bodyD);
    auto velA = bodyConstraintA.GetVelocity();
    auto velB = bodyConstraintB.GetVelocity();
    auto velC = bodyConstraintC.GetVelocity();
    auto velD = bodyConstraintD.GetVelocity();
    auto invMass = Real{0}; // Unitless to double for either linear mass or angular mass.
    if (std::holds_alternative<GearJointConf::PrismaticData>(object.typeDataAC)) {
        const auto qA = UnitVec::Get(bodyConstraintA.GetPosition().angular);
        const auto qC = UnitVec::Get(bodyConstraintC.GetPosition().angular);
        const auto& typeData = std::get<GearJointConf::PrismaticData>(object.typeDataAC);
        const auto u = Rotate(typeData.localAxis, qC);
        const auto rC =
            Length2{Rotate(typeData.localAnchorA - bodyConstraintC.GetLocalCenter(), qC)};
        const auto rA =
            Length2{Rotate(typeData.localAnchorB - bodyConstraintA.GetLocalCenter(), qA)};
        object.JvAC = Real{1} * u;
        object.JwC = Cross(rC, u);
        object.JwA = Cross(rA, u);
        const auto invRotMassC =
            InvMass{bodyConstraintC.GetInvRotInertia() * Square(object.JwC) / SquareRadian};
        const auto invRotMassA =
            InvMass{bodyConstraintA.GetInvRotInertia() * Square(object.JwA) / SquareRadian};
        const auto invLinMass = InvMass{bodyConstraintC.GetInvMass() +
                                        bodyConstraintA.GetInvMass() + invRotMassC + invRotMassA};
        invMass += StripUnit(invLinMass);
    }
    else {
        object.JvAC = Vec2{};
        object.JwA = 1_m;
        object.JwC = 1_m;
        const auto invAngMass =
            bodyConstraintA.GetInvRotInertia() + bodyConstraintC.GetInvRotInertia();
        invMass += StripUnit(invAngMass);
    }
    if (std::holds_alternative<GearJointConf::PrismaticData>(object.typeDataBD)) {
        const auto qB = UnitVec::Get(bodyConstraintB.GetPosition().angular);
        const auto qD = UnitVec::Get(bodyConstraintD.GetPosition().angular);
        const auto& typeData = std::get<GearJointConf::PrismaticData>(object.typeDataBD);
        const auto u = Rotate(typeData.localAxis, qD);
        const auto rD = Rotate(typeData.localAnchorA - bodyConstraintD.GetLocalCenter(), qD);
        const auto rB = Rotate(typeData.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);
        object.JvBD = object.ratio * u;
        object.JwD = object.ratio * Cross(rD, u);
        object.JwB = object.ratio * Cross(rB, u);
        const auto invRotMassD =
            InvMass{bodyConstraintD.GetInvRotInertia() * Square(object.JwD) / SquareRadian};
        const auto invRotMassB =
            InvMass{bodyConstraintB.GetInvRotInertia() * Square(object.JwB) / SquareRadian};
        const auto invLinMass = InvMass{
            Square(object.ratio) * (bodyConstraintD.GetInvMass() + bodyConstraintB.GetInvMass()) +
            invRotMassD + invRotMassB};
        invMass += StripUnit(invLinMass);
    }
    else {
        object.JvBD = Vec2{};
        object.JwB = object.ratio * Meter;
        object.JwD = object.ratio * Meter;
        const auto invAngMass =
            InvRotInertia{Square(object.ratio) * (bodyConstraintB.GetInvRotInertia() +
                                                  bodyConstraintD.GetInvRotInertia())};
        invMass += StripUnit(invAngMass);
    }
    // Compute effective mass.
    object.mass = (invMass > Real{0}) ? Real{1} / invMass : Real{0};
    if (step.doWarmStart) {
        velA += Velocity{(bodyConstraintA.GetInvMass() * object.impulse) * object.JvAC,
                         bodyConstraintA.GetInvRotInertia() * object.impulse * object.JwA / Radian};
        velB += Velocity{(bodyConstraintB.GetInvMass() * object.impulse) * object.JvBD,
                         bodyConstraintB.GetInvRotInertia() * object.impulse * object.JwB / Radian};
        velC -= Velocity{(bodyConstraintC.GetInvMass() * object.impulse) * object.JvAC,
                         bodyConstraintC.GetInvRotInertia() * object.impulse * object.JwC / Radian};
        velD -= Velocity{(bodyConstraintD.GetInvMass() * object.impulse) * object.JvBD,
                         bodyConstraintD.GetInvRotInertia() * object.impulse * object.JwD / Radian};
    }
    else {
        object.impulse = 0_Ns;
    }
    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
    bodyConstraintC.SetVelocity(velC);
    bodyConstraintD.SetVelocity(velD);
}

bool SolveVelocity(GearJointConf& object, const Span<BodyConstraint>& bodies, const StepConf&)
{
    if ((object.bodyA == InvalidBodyID) || (object.bodyB == InvalidBodyID) || //
        (object.bodyC == InvalidBodyID) || (object.bodyD == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));
    auto& bodyConstraintC = At(bodies, object.bodyC);
    auto& bodyConstraintD = At(bodies, object.bodyD);
    auto velA = bodyConstraintA.GetVelocity();
    auto velB = bodyConstraintB.GetVelocity();
    auto velC = bodyConstraintC.GetVelocity();
    auto velD = bodyConstraintD.GetVelocity();
    const auto acDot = LinearVelocity{Dot(object.JvAC, velA.linear - velC.linear)};
    const auto bdDot = LinearVelocity{Dot(object.JvBD, velB.linear - velD.linear)};
    const auto Cdot = acDot + bdDot +
                      (object.JwA * velA.angular - object.JwC * velC.angular) / Radian +
                      (object.JwB * velB.angular - object.JwD * velD.angular) / Radian;
    const auto impulse = Momentum{-object.mass * Kilogram * Cdot};
    object.impulse += impulse;
    velA += Velocity{(bodyConstraintA.GetInvMass() * impulse) * object.JvAC,
                     bodyConstraintA.GetInvRotInertia() * impulse * object.JwA / Radian};
    velB += Velocity{(bodyConstraintB.GetInvMass() * impulse) * object.JvBD,
                     bodyConstraintB.GetInvRotInertia() * impulse * object.JwB / Radian};
    velC -= Velocity{(bodyConstraintC.GetInvMass() * impulse) * object.JvAC,
                     bodyConstraintC.GetInvRotInertia() * impulse * object.JwC / Radian};
    velD -= Velocity{(bodyConstraintD.GetInvMass() * impulse) * object.JvBD,
                     bodyConstraintD.GetInvRotInertia() * impulse * object.JwD / Radian};
    bodyConstraintA.SetVelocity(velA);
    bodyConstraintB.SetVelocity(velB);
    bodyConstraintC.SetVelocity(velC);
    bodyConstraintD.SetVelocity(velD);
    return impulse == 0_Ns;
}

bool SolvePosition(const GearJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf)
{
    if ((object.bodyA == InvalidBodyID) || (object.bodyB == InvalidBodyID) || //
        (object.bodyC == InvalidBodyID) || (object.bodyD == InvalidBodyID)) {
        return true;
    }

    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));
    auto& bodyConstraintC = At(bodies, object.bodyC);
    auto& bodyConstraintD = At(bodies, object.bodyD);
    auto posA = bodyConstraintA.GetPosition();
    auto posB = bodyConstraintB.GetPosition();
    auto posC = bodyConstraintC.GetPosition();
    auto posD = bodyConstraintD.GetPosition();

    if (!isfinite(object.constant)) {
        return true;
    }

    auto JvAC = Vec2{};
    auto JvBD = Vec2{};
    auto JwA = Real{};
    auto JwB = Real{};
    auto JwC = Real{};
    auto JwD = Real{};
    auto coordinateA = Real{0}; // Angle or length.
    auto coordinateB = Real{0};
    auto invMass = Real{0}; // Inverse linear mass or inverse angular mass.
    if (std::holds_alternative<GearJointConf::PrismaticData>(object.typeDataAC)) {
        const auto qA = UnitVec::Get(posA.angular);
        const auto qC = UnitVec::Get(posC.angular);
        const auto& typeData = std::get<GearJointConf::PrismaticData>(object.typeDataAC);
        const auto u = Rotate(typeData.localAxis, qC);
        const auto rC = Rotate(typeData.localAnchorA - bodyConstraintC.GetLocalCenter(), qC);
        const auto rA = Rotate(typeData.localAnchorB - bodyConstraintA.GetLocalCenter(), qA);
        JvAC = u * Real{1};
        JwC = StripUnit(Length{Cross(rC, u)});
        JwA = StripUnit(Length{Cross(rA, u)});
        const auto invLinMass =
            InvMass{bodyConstraintC.GetInvMass() + bodyConstraintA.GetInvMass()};
        const auto invRotMassC =
            InvMass{bodyConstraintC.GetInvRotInertia() * Square(JwC * Meter / Radian)};
        const auto invRotMassA =
            InvMass{bodyConstraintA.GetInvRotInertia() * Square(JwA * Meter / Radian)};
        invMass += StripUnit(invLinMass + invRotMassC + invRotMassA);
        const auto pC = typeData.localAnchorA - bodyConstraintC.GetLocalCenter();
        const auto pA = InverseRotate(rA + (posA.linear - posC.linear), qC);
        coordinateA = Dot(pA - pC, typeData.localAxis) / 1_m;
    }
    else if (std::holds_alternative<GearJointConf::RevoluteData>(object.typeDataAC)) {
        const auto& typeData = std::get<GearJointConf::RevoluteData>(object.typeDataAC);
        JvAC = Vec2{};
        JwA = 1;
        JwC = 1;
        const auto invAngMass =
            bodyConstraintA.GetInvRotInertia() + bodyConstraintC.GetInvRotInertia();
        invMass += StripUnit(invAngMass);
#if 1
        coordinateA = ((posA.angular - posC.angular) - typeData.referenceAngle) / 1_rad;
#else
        if (bodyConstraintA.GetVelocity().angular > 0_rpm) {
            coordinateA =
                (GetRevRotationalAngle(posC.angular, posA.angular) - typeData.referenceAngle) /
                1_rad;
        }
        else if (bodyConstraintA.GetVelocity().angular < 0_rpm) {
            coordinateA =
                (GetFwdRotationalAngle(posC.angular, posA.angular) - typeData.referenceAngle) /
                1_rad;
        }
        else {
            coordinateA = 0;
            coordinateB = 0;
        }
#endif
        // coordinateA = ((::playrho::GetNormalized(posA.angular) - posC.angular) -
        // typeData.referenceAngle) / 1_rad;
        // coordinateA = (GetShortestDelta(posC.angular, posA.angular) - typeData.referenceAngle) /
        //     1_rad;
        // coordinateA = GetShortestDelta(typeData.referenceAngle,
        //     GetShortestDelta(posC.angular, posA.angular)) / 1_rad;
    }
    if (std::holds_alternative<GearJointConf::PrismaticData>(object.typeDataBD)) {
        const auto qB = UnitVec::Get(posB.angular);
        const auto qD = UnitVec::Get(posD.angular);
        const auto& typeData = std::get<GearJointConf::PrismaticData>(object.typeDataBD);
        const auto u = Rotate(typeData.localAxis, qD);
        const auto rD = Rotate(typeData.localAnchorA - bodyConstraintD.GetLocalCenter(), qD);
        const auto rB = Rotate(typeData.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);
        JvBD = object.ratio * u;
        JwD = object.ratio * StripUnit(Length{Cross(rD, u)});
        JwB = object.ratio * StripUnit(Length{Cross(rB, u)});
        const auto invLinMass = InvMass{
            Square(object.ratio) * (bodyConstraintD.GetInvMass() + bodyConstraintB.GetInvMass())};
        const auto invRotMassD =
            InvMass{bodyConstraintD.GetInvRotInertia() * Square(JwD * Meter / Radian)};
        const auto invRotMassB =
            InvMass{bodyConstraintB.GetInvRotInertia() * Square(JwB * Meter / Radian)};
        invMass += StripUnit(invLinMass + invRotMassD + invRotMassB);
        const auto pD = typeData.localAnchorA - bodyConstraintD.GetLocalCenter();
        const auto pB = InverseRotate(rB + (posB.linear - posD.linear), qD);
        coordinateB = Dot(pB - pD, typeData.localAxis) / 1_m;
    }
    else if (std::holds_alternative<GearJointConf::RevoluteData>(object.typeDataBD)) {
        const auto& typeData = std::get<GearJointConf::RevoluteData>(object.typeDataBD);
        JvBD = Vec2{};
        JwB = object.ratio;
        JwD = object.ratio;
        const auto invAngMass =
            InvRotInertia{Square(object.ratio) * (bodyConstraintB.GetInvRotInertia() +
                                                  bodyConstraintD.GetInvRotInertia())};
        invMass += StripUnit(invAngMass);
#if 1
        coordinateB = ((posB.angular - posD.angular) - typeData.referenceAngle) / 1_rad;
#else
        if (bodyConstraintB.GetVelocity().angular > 0_rpm) {
            coordinateB =
                (GetRevRotationalAngle(posD.angular, posB.angular) - typeData.referenceAngle) /
                1_rad;
        }
        else if (bodyConstraintB.GetVelocity().angular < 0_rpm) {
            coordinateB =
                (GetFwdRotationalAngle(posD.angular, posB.angular) - typeData.referenceAngle) /
                1_rad;
        }
        else {
            coordinateA = 0;
            coordinateB = 0;
        }
#endif
        // coordinateB = ((posB.angular - posD.angular) - typeData.referenceAngle) / 1_rad;
        // coordinateB = (GetShortestDelta(posD.angular, posB.angular) - typeData.referenceAngle) /
        //     1_rad;
        // coordinateB = GetShortestDelta(typeData.referenceAngle,
        //     GetShortestDelta(posD.angular, posB.angular)) / 1_rad;
    }
    const auto C =
        ((coordinateA + object.ratio * coordinateB) - object.constant) * conf.resolutionRate;
    const auto impulse = ((invMass > 0) ? -C / invMass : Real(0)) * Kilogram * Meter;
    const auto deltaA =
        Cap(Position{bodyConstraintA.GetInvMass() * impulse * JvAC,
                     bodyConstraintA.GetInvRotInertia() * impulse * JwA * Meter / Radian},
            conf);
    const auto deltaC =
        Cap(Position{bodyConstraintC.GetInvMass() * impulse * JvAC,
                     bodyConstraintC.GetInvRotInertia() * impulse * JwC * Meter / Radian},
            conf);
    const auto deltaB =
        Cap(Position{bodyConstraintB.GetInvMass() * impulse * JvBD,
                     bodyConstraintB.GetInvRotInertia() * impulse * JwB * Meter / Radian},
            conf);
    const auto deltaD =
        Cap(Position{bodyConstraintD.GetInvMass() * impulse * JvBD,
                     bodyConstraintD.GetInvRotInertia() * impulse * JwD * Meter / Radian},
            conf);
    bodyConstraintA.SetPosition(posA + deltaA);
    bodyConstraintB.SetPosition(posB + deltaB);
    bodyConstraintC.SetPosition(posC - deltaC);
    bodyConstraintD.SetPosition(posD - deltaD);
    auto linearError = 0_m2;
    auto angularError = 0_rad;
    linearError = std::max(linearError, GetMagnitudeSquared(deltaA.linear));
    linearError = std::max(linearError, GetMagnitudeSquared(deltaB.linear));
    linearError = std::max(linearError, GetMagnitudeSquared(deltaC.linear));
    linearError = std::max(linearError, GetMagnitudeSquared(deltaD.linear));
    angularError = std::max(angularError, abs(deltaA.angular));
    angularError = std::max(angularError, abs(deltaB.angular));
    angularError = std::max(angularError, abs(deltaC.angular));
    angularError = std::max(angularError, abs(deltaD.angular));
    return (linearError <= Square(conf.linearSlop)) && (angularError <= conf.angularSlop);
}

TypeID GetTypeAC(const GearJointConf& object) noexcept
{
    switch (object.typeDataAC.index()) {
    case 0:
        break;
    case 1:
        return GetTypeID<PrismaticJointConf>();
    case 2:
        return GetTypeID<RevoluteJointConf>();
    }
    return GetTypeID<void>();
}

TypeID GetTypeBD(const GearJointConf& object) noexcept
{
    switch (object.typeDataBD.index()) {
    case 0:
        break;
    case 1:
        return GetTypeID<PrismaticJointConf>();
    case 2:
        return GetTypeID<RevoluteJointConf>();
    }
    return GetTypeID<void>();
}

Length2 GetLocalAnchorA(const GearJointConf& conf)
{
    if (const auto pval = std::get_if<GearJointConf::PrismaticData>(&conf.typeDataAC)) {
        return GetLocalAnchorB(*pval);
    }
    return Length2{};
}

Length2 GetLocalAnchorB(const GearJointConf& conf)
{
    if (const auto pval = std::get_if<GearJointConf::PrismaticData>(&conf.typeDataBD)) {
        return GetLocalAnchorB(*pval);
    }
    return Length2{};
}

} // namespace d2
} // namespace playrho

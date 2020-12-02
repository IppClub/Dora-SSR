/*
 * Original work Copyright (c) 2007-2011 Erin Catto http://www.box2d.org
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

#include "PlayRho/Dynamics/Joints/GearJointConf.hpp"

#include "PlayRho/Dynamics/WorldBody.hpp"
#include "PlayRho/Dynamics/WorldJoint.hpp"
#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/RevoluteJointConf.hpp"
#include "PlayRho/Dynamics/Joints/PrismaticJointConf.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"
#include "PlayRho/Dynamics/Contacts/ConstraintSolverConf.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_default_constructible<GearJointConf>::value,
              "GearJointConf should be default constructible!");
static_assert(std::is_copy_constructible<GearJointConf>::value,
              "GearJointConf should be copy constructible!");
static_assert(std::is_copy_assignable<GearJointConf>::value,
              "GearJointConf should be copy assignable!");
static_assert(std::is_move_constructible<GearJointConf>::value,
              "GearJointConf should be move constructible!");
static_assert(std::is_move_assignable<GearJointConf>::value,
              "GearJointConf should be move assignable!");
static_assert(std::is_nothrow_destructible<GearJointConf>::value,
              "GearJointConf should be nothrow destructible!");

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

GearJointConf GetGearJointConf(const Joint& joint) noexcept
{
    return TypeCast<GearJointConf>(joint);
}

GearJointConf GetGearJointConf(const World& world, JointID id1, JointID id2, Real ratio)
{
    auto def = GearJointConf{/*body-A*/ GetBodyB(world, id1), /*body-B*/ GetBodyB(world, id2),
                             /*body-C*/ GetBodyA(world, id1), /*body-D*/ GetBodyA(world, id2)};

    auto scalar1 = Real{0};
    def.type1 = GetType(world, id1);
    if (def.type1 == GetTypeID<RevoluteJointConf>()) {
        def.referenceAngle1 = GetReferenceAngle(world, id1);
        scalar1 = (GetAngle(world, def.bodyA) - GetAngle(world, def.bodyC) - def.referenceAngle1) /
                  Radian;
    }
    else if (def.type1 == GetTypeID<PrismaticJointConf>()) {
        const auto xfA = GetTransformation(world, def.bodyA);
        const auto xfC = GetTransformation(world, def.bodyC);
        def.localAnchorC = GetLocalAnchorA(world, id1);
        def.localAnchorA = GetLocalAnchorB(world, id1);
        def.localAxis1 = GetLocalXAxisA(world, id1);
        const auto pC = def.localAnchorC;
        const auto pA = InverseRotate(Rotate(def.localAnchorA, xfA.q) + (xfA.p - xfC.p), xfC.q);
        scalar1 = Dot(pA - pC, def.localAxis1) / Meter;
    }
    else {
        throw InvalidArgument("GetGearJointConf not supported for joint 1 type");
    }

    auto scalar2 = Real{0};
    def.type2 = GetType(world, id2);
    if (def.type2 == GetTypeID<RevoluteJointConf>()) {
        def.referenceAngle2 = GetReferenceAngle(world, id2);
        scalar2 = (GetAngle(world, def.bodyB) - GetAngle(world, def.bodyD) - def.referenceAngle1) /
                  Radian;
    }
    else if (def.type2 == GetTypeID<PrismaticJointConf>()) {
        const auto xfB = GetTransformation(world, def.bodyB);
        const auto xfD = GetTransformation(world, def.bodyD);
        def.localAnchorD = GetLocalAnchorA(world, id2);
        def.localAnchorB = GetLocalAnchorB(world, id2);
        def.localAxis2 = GetLocalXAxisA(world, id2);
        const auto pD = def.localAnchorD;
        const auto pB = InverseRotate(Rotate(def.localAnchorB, xfB.q) + (xfB.p - xfD.p), xfD.q);
        scalar2 = Dot(pB - pD, def.localAxis2) / Meter;
    }
    else {
        throw InvalidArgument("GetGearJointConf not supported for joint 2 type");
    }

    def.ratio = ratio;
    def.constant = scalar1 + def.ratio * scalar2;
    return def;
}

void InitVelocity(GearJointConf& object, std::vector<BodyConstraint>& bodies, const StepConf& step,
                  const ConstraintSolverConf&)
{
    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));
    auto& bodyConstraintC = At(bodies, object.bodyC);
    auto& bodyConstraintD = At(bodies, object.bodyD);

    auto velA = bodyConstraintA.GetVelocity();
    const auto aA = bodyConstraintA.GetPosition().angular;

    auto velB = bodyConstraintB.GetVelocity();
    const auto aB = bodyConstraintB.GetPosition().angular;

    auto velC = bodyConstraintC.GetVelocity();
    const auto aC = bodyConstraintC.GetPosition().angular;

    auto velD = bodyConstraintD.GetVelocity();
    const auto aD = bodyConstraintD.GetPosition().angular;

    const auto qA = UnitVec::Get(aA);
    const auto qB = UnitVec::Get(aB);
    const auto qC = UnitVec::Get(aC);
    const auto qD = UnitVec::Get(aD);

    auto invMass = Real{0}; // Unitless to double for either linear mass or angular mass.

    if (object.type1 == GetTypeID<RevoluteJointConf>()) {
        object.JvAC = Vec2{};
        object.JwA = 1_m;
        object.JwC = 1_m;
        const auto invAngMass =
            bodyConstraintA.GetInvRotInertia() + bodyConstraintC.GetInvRotInertia();
        invMass += StripUnit(invAngMass);
    }
    else {
        const auto u = Rotate(object.localAxis1, qC);
        const auto rC = Length2{Rotate(object.localAnchorC - bodyConstraintC.GetLocalCenter(), qC)};
        const auto rA = Length2{Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA)};
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

    if (object.type2 == GetTypeID<RevoluteJointConf>()) {
        object.JvBD = Vec2{};
        object.JwB = object.ratio * Meter;
        object.JwD = object.ratio * Meter;
        const auto invAngMass =
            InvRotInertia{Square(object.ratio) * (bodyConstraintB.GetInvRotInertia() +
                                                  bodyConstraintD.GetInvRotInertia())};
        invMass += StripUnit(invAngMass);
    }
    else {
        const auto u = Rotate(object.localAxis2, qD);
        const auto rD = Rotate(object.localAnchorD - bodyConstraintD.GetLocalCenter(), qD);
        const auto rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);
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

bool SolveVelocity(GearJointConf& object, std::vector<BodyConstraint>& bodies, const StepConf&)
{
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

bool SolvePosition(const GearJointConf& object, std::vector<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf)
{
    auto& bodyConstraintA = At(bodies, GetBodyA(object));
    auto& bodyConstraintB = At(bodies, GetBodyB(object));
    auto& bodyConstraintC = At(bodies, object.bodyC);
    auto& bodyConstraintD = At(bodies, object.bodyD);

    auto posA = bodyConstraintA.GetPosition();
    auto posB = bodyConstraintB.GetPosition();
    auto posC = bodyConstraintC.GetPosition();
    auto posD = bodyConstraintD.GetPosition();

    const auto qA = UnitVec::Get(posA.angular);
    const auto qB = UnitVec::Get(posB.angular);
    const auto qC = UnitVec::Get(posC.angular);
    const auto qD = UnitVec::Get(posD.angular);

    const auto linearError = 0_m;

    Vec2 JvAC, JvBD;
    Real JwA, JwB, JwC, JwD;

    auto coordinateA = Real{0}; // Angle or length.
    auto coordinateB = Real{0};
    auto invMass = Real{0}; // Inverse linear mass or inverse angular mass.

    if (object.type1 == GetTypeID<RevoluteJointConf>()) {
        JvAC = Vec2{};
        JwA = 1;
        JwC = 1;
        const auto invAngMass =
            bodyConstraintA.GetInvRotInertia() + bodyConstraintC.GetInvRotInertia();
        invMass += StripUnit(invAngMass);
        coordinateA = (posA.angular - posC.angular - object.referenceAngle1) / Radian;
    }
    else {
        const auto u = Rotate(object.localAxis1, qC);
        const auto rC = Rotate(object.localAnchorC - bodyConstraintC.GetLocalCenter(), qC);
        const auto rA = Rotate(object.localAnchorA - bodyConstraintA.GetLocalCenter(), qA);
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
        const auto pC = object.localAnchorC - bodyConstraintC.GetLocalCenter();
        const auto pA = InverseRotate(rA + (posA.linear - posC.linear), qC);
        coordinateA = Dot(pA - pC, object.localAxis1) / Meter;
    }

    if (object.type2 == GetTypeID<RevoluteJointConf>()) {
        JvBD = Vec2{};
        JwB = object.ratio;
        JwD = object.ratio;
        const auto invAngMass =
            InvRotInertia{Square(object.ratio) * (bodyConstraintB.GetInvRotInertia() +
                                                  bodyConstraintD.GetInvRotInertia())};
        invMass += StripUnit(invAngMass);
        coordinateB = (posB.angular - posD.angular - object.referenceAngle2) / Radian;
    }
    else {
        const auto u = Rotate(object.localAxis2, qD);
        const auto rD = Rotate(object.localAnchorD - bodyConstraintD.GetLocalCenter(), qD);
        const auto rB = Rotate(object.localAnchorB - bodyConstraintB.GetLocalCenter(), qB);
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
        const auto pD = object.localAnchorD - bodyConstraintD.GetLocalCenter();
        const auto pB = InverseRotate(rB + (posB.linear - posD.linear), qD);
        coordinateB = Dot(pB - pD, object.localAxis2) / Meter;
    }

    const auto C = ((coordinateA + object.ratio * coordinateB) - object.constant);

    const auto impulse = ((invMass > 0) ? -C / invMass : 0) * Kilogram * Meter;

    posA += Position{bodyConstraintA.GetInvMass() * impulse * JvAC,
                     bodyConstraintA.GetInvRotInertia() * impulse * JwA * Meter / Radian};
    posB += Position{bodyConstraintB.GetInvMass() * impulse * JvBD,
                     bodyConstraintB.GetInvRotInertia() * impulse * JwB * Meter / Radian};
    posC -= Position{bodyConstraintC.GetInvMass() * impulse * JvAC,
                     bodyConstraintC.GetInvRotInertia() * impulse * JwC * Meter / Radian};
    posD -= Position{bodyConstraintD.GetInvMass() * impulse * JvBD,
                     bodyConstraintD.GetInvRotInertia() * impulse * JwD * Meter / Radian};

    bodyConstraintA.SetPosition(posA);
    bodyConstraintB.SetPosition(posB);
    bodyConstraintC.SetPosition(posC);
    bodyConstraintD.SetPosition(posD);

    // TODO_ERIN not implemented
    return linearError < conf.linearSlop;
}

} // namespace d2
} // namespace playrho

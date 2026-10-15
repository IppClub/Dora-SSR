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

#include "playrho/d2/CodeDumper.hpp"

#ifdef CODE_DUMPER_IS_READY

#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/WorldJoint.hpp"

#include "playrho/Contact.hpp"
#include "playrho/d2/Body.hpp"

#include "playrho/d2/Joint.hpp"
#include "playrho/d2/PulleyJointConf.hpp"
#include "playrho/d2/DistanceJointConf.hpp"
#include "playrho/d2/FrictionJointConf.hpp"
#include "playrho/d2/MotorJointConf.hpp"
#include "playrho/d2/WeldJointConf.hpp"
#include "playrho/d2/TargetJointConf.hpp"
#include "playrho/d2/RevoluteJointConf.hpp"
#include "playrho/d2/PrismaticJointConf.hpp"
#include "playrho/d2/GearJointConf.hpp"
#include "playrho/d2/RopeJointConf.hpp"
#include "playrho/d2/WheelJointConf.hpp"

#include "playrho/d2/Shape.hpp"
#include "playrho/d2/DiskShapeConf.hpp"
#include "playrho/d2/EdgeShapeConf.hpp"
#include "playrho/d2/PolygonShapeConf.hpp"
#include "playrho/d2/ChainShapeConf.hpp"
#include "playrho/d2/MultiShapeConf.hpp"
#include "playrho/d2/Shape.hpp"

#include <cstdarg>

namespace playrho {
namespace d2 {

namespace {

// You can modify this to use your logging facility.
void log(const char* string, ...)
{
    va_list args;
    va_start(args, string);
    std::vprintf(string, args);
    va_end(args);
}

} // namespace

void Dump(const World& world)
{
#if 0
    const auto& bodies = GetBodies(world);
    log("Body** bodies = (Body**)Alloc(%d * sizeof(Body*));\n", size(bodies));
    auto i = std::size_t{0};
    for (auto&& body: bodies)
    {
        const auto& b = GetRef(body);
        Dump(b, i);
        ++i;
    }
    
    const auto& joints = GetJoints(world);
    log("Joint** joints = (Joint**)Alloc(%d * sizeof(Joint*));\n", size(joints));
    i = 0;
    for (auto&& j: joints)
    {
        log("{\n");
        Dump(*j, i);
        log("}\n");
        ++i;
    }
    
    log("Free(joints);\n");
    log("Free(bodies);\n");
    log("joints = nullptr;\n");
    log("bodies = nullptr;\n");
#endif
}

void Dump(const Body& body, std::size_t bodyIndex)
{
#if 0
    log("{\n");
    log("  BodyConf bd;\n");
    log("  bd.type = BodyType(%d);\n", body.GetType());
    log("  bd.position = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real(get<0>(body.GetLocation()) / Meter)),
        static_cast<double>(Real(get<1>(body.GetLocation()) / Meter)));
    log("  bd.angle = %.15lef;\n", static_cast<double>(Real{body.GetAngle() / Radian}));
    log("  bd.linearVelocity = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(body.GetVelocity().linear) / MeterPerSecond}),
        static_cast<double>(Real{get<1>(body.GetVelocity().linear) / MeterPerSecond}));
    log("  bd.angularVelocity = %.15lef;\n",
        static_cast<double>(Real{body.GetVelocity().angular / RadianPerSecond}));
    log("  bd.linearDamping = %.15lef;\n",
        static_cast<double>(Real{body.GetLinearDamping() / Hertz}));
    log("  bd.angularDamping = %.15lef;\n",
        static_cast<double>(Real{body.GetAngularDamping() / Hertz}));
    log("  bd.allowSleep = bool(%d);\n", body.IsSleepingAllowed());
    log("  bd.awake = bool(%d);\n", body.IsAwake());
    log("  bd.fixedRotation = bool(%d);\n", body.IsFixedRotation());
    log("  bd.bullet = bool(%d);\n", body.IsImpenetrable());
    log("  bd.enabled = bool(%d);\n", body.IsEnabled());
    log("  bodies[%d] = m_world->CreateBody(bd);\n", bodyIndex);
    log("\n");
    for (auto&& fixture: body.GetFixtures())
    {
        log("  {\n");
        Dump(GetRef(fixture), bodyIndex);
        log("  }\n");
    }
    log("}\n");
#endif
}

void Dump(const Joint& joint, std::size_t index, const World& world)
{
    const auto type = GetType(joint);
    if (type == GetTypeID<PulleyJointConf>()) {
        Dump(TypeCast<PulleyJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<DistanceJointConf>()) {
        Dump(TypeCast<DistanceJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<FrictionJointConf>()) {
        Dump(TypeCast<FrictionJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<MotorJointConf>()) {
        Dump(TypeCast<MotorJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<WeldJointConf>()) {
        Dump(TypeCast<WeldJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<TargetJointConf>()) {
        Dump(TypeCast<TargetJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<RevoluteJointConf>()) {
        Dump(TypeCast<RevoluteJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<PrismaticJointConf>()) {
        Dump(TypeCast<PrismaticJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<GearJointConf>()) {
        Dump(TypeCast<GearJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<RopeJointConf>()) {
        Dump(TypeCast<RopeJointConf>(joint), index, world);
    }
    else if (type == GetTypeID<WheelJointConf>()) {
        Dump(TypeCast<WheelJointConf>(joint), index, world);
    }
}

void Dump(const DistanceJointConf& joint, std::size_t index, const World& world)
{
    log("  DistanceJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.localAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorA(joint)) / Meter}));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.length = %.15lef;\n", static_cast<double>(Real{GetLength(joint) / Meter}));
    log("  jd.frequency = %.15lef;\n", static_cast<double>(Real{GetFrequency(joint) / Hertz}));
    log("  jd.dampingRatio = %.15lef;\n", GetDampingRatio(joint));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const FrictionJointConf& joint, std::size_t index, const World& world)
{
    log("  FrictionJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.localAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorA(joint)) / Meter}));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.maxForce = %.15lef;\n", static_cast<double>(Real{GetMaxForce(joint) / Newton}));
    log("  jd.maxTorque = %.15lef;\n",
        static_cast<double>(Real{GetMaxTorque(joint) / NewtonMeter}));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const GearJointConf& joint, std::size_t index, const World& world)
{
    log("  GearJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    //  log("  jd.joint1 = joints[%d];\n", GetWorldIndex(world, joint.GetJoint1()));
    //  log("  jd.joint2 = joints[%d];\n", GetWorldIndex(world, joint.GetJoint2()));
    log("  jd.ratio = %.15lef;\n", GetRatio(joint));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const MotorJointConf& joint, std::size_t index, const World& world)
{
    log("  MotorJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.linearOffset = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLinearOffset(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLinearOffset(joint)) / Meter}));
    log("  jd.angularOffset = %.15lef;\n",
        static_cast<double>(Real{GetAngularOffset(joint) / Radian}));
    log("  jd.maxForce = %.15lef;\n", static_cast<double>(Real{GetMaxForce(joint) / Newton}));
    log("  jd.maxTorque = %.15lef;\n",
        static_cast<double>(Real{GetMaxTorque(joint) / NewtonMeter}));
    log("  jd.correctionFactor = %.15lef;\n", joint.correctionFactor);
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const TargetJointConf& joint, std::size_t index, const World& world)
{
    log("  TargetJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.frequency = %.15lef;\n", static_cast<double>(Real{GetFrequency(joint) / Hertz}));
    log("  jd.dampingRatio = %.15lef;\n", static_cast<double>(Real{GetDampingRatio(joint)}));
    log("  jd.maxForce = %.15lef;\n", static_cast<double>(Real{GetMaxForce(joint) / Newton}));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const PrismaticJointConf& joint, std::size_t index, const World& world)
{
    log("  PrismaticJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.localAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorA(joint)) / Meter}));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.localXAxisA = Vec2(%.15lef, %.15lef);\n", GetX(GetLocalXAxisA(joint)),
        GetY(GetLocalXAxisA(joint)));
    log("  jd.referenceAngle = %.15lef;\n",
        static_cast<double>(Real{GetReferenceAngle(joint) / Radian}));
    log("  jd.enableLimit = bool(%d);\n", IsLimitEnabled(joint));
    log("  jd.lowerTranslation = %.15lef;\n",
        static_cast<double>(Real{GetLinearLowerLimit(joint) / Meter}));
    log("  jd.upperTranslation = %.15lef;\n",
        static_cast<double>(Real{GetLinearUpperLimit(joint) / Meter}));
    log("  jd.enableMotor = bool(%d);\n", IsMotorEnabled(joint));
    log("  jd.motorSpeed = %.15lef;\n",
        static_cast<double>(Real{GetMotorSpeed(joint) / RadianPerSecond}));
    log("  jd.maxMotorForce = %.15lef;\n", static_cast<double>(Real{joint.maxMotorForce / Newton}));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const PulleyJointConf& joint, std::size_t index, const World& world)
{
    log("  PulleyJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.groundAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetGroundAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetGroundAnchorA(joint)) / Meter}));
    log("  jd.groundAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetGroundAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetGroundAnchorB(joint)) / Meter}));
    log("  jd.localAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorA(joint)) / Meter}));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.lengthA = %.15lef;\n", static_cast<double>(Real{joint.lengthA / Meter}));
    log("  jd.lengthB = %.15lef;\n", static_cast<double>(Real{joint.lengthB / Meter}));
    log("  jd.ratio = %.15lef;\n", GetRatio(joint));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const RevoluteJointConf& joint, std::size_t index, const World& world)
{
    log("  RevoluteJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.localAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorA(joint)) / Meter}));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.referenceAngle = %.15lef;\n",
        static_cast<double>(Real{GetReferenceAngle(joint) / Radian}));
    log("  jd.enableLimit = bool(%d);\n", IsLimitEnabled(joint));
    log("  jd.lowerAngle = %.15lef;\n",
        static_cast<double>(Real{GetAngularLowerLimit(joint) / Radian}));
    log("  jd.upperAngle = %.15lef;\n",
        static_cast<double>(Real{GetAngularUpperLimit(joint) / Radian}));
    log("  jd.enableMotor = bool(%d);\n", IsMotorEnabled(joint));
    log("  jd.motorSpeed = %.15lef;\n",
        static_cast<double>(Real{GetMotorSpeed(joint) / RadianPerSecond}));
    log("  jd.maxMotorTorque = %.15lef;\n",
        static_cast<double>(Real{GetMaxMotorTorque(joint) / NewtonMeter}));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const RopeJointConf& joint, std::size_t index, const World& world)
{
    log("  RopeJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.localAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorA(joint)) / Meter}));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.maxLength = %.15lef;\n", static_cast<double>(Real{joint.maxLength / Meter}));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const WeldJointConf& joint, std::size_t index, const World& world)
{
    log("  WeldJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.localAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorA(joint)) / Meter}));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.referenceAngle = %.15lef;\n",
        static_cast<double>(Real{GetReferenceAngle(joint) / Radian}));
    log("  jd.frequency = %.15lef;\n", static_cast<double>(Real{GetFrequency(joint) / Hertz}));
    log("  jd.dampingRatio = %.15lef;\n", GetDampingRatio(joint));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

void Dump(const WheelJointConf& joint, std::size_t index, const World& world)
{
    log("  WheelJointConf jd;\n");
    log("  jd.bodyA = bodies[%d];\n", GetWorldIndex(world, GetBodyA(joint)));
    log("  jd.bodyB = bodies[%d];\n", GetWorldIndex(world, GetBodyB(joint)));
    log("  jd.collideConnected = bool(%d);\n", GetCollideConnected(joint));
    log("  jd.localAnchorA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorA(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorA(joint)) / Meter}));
    log("  jd.localAnchorB = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(Real{get<0>(GetLocalAnchorB(joint)) / Meter}),
        static_cast<double>(Real{get<1>(GetLocalAnchorB(joint)) / Meter}));
    log("  jd.localAxisA = Vec2(%.15lef, %.15lef);\n",
        static_cast<double>(GetX(GetLocalXAxisA(joint))),
        static_cast<double>(GetY(GetLocalXAxisA(joint))));
    log("  jd.enableMotor = bool(%d);\n", IsMotorEnabled(joint));
    log("  jd.motorSpeed = %.15lef;\n",
        static_cast<double>(Real{GetMotorSpeed(joint) / RadianPerSecond}));
    log("  jd.maxMotorTorque = %.15lef;\n",
        static_cast<double>(Real{GetMaxMotorTorque(joint) / NewtonMeter}));
    log("  jd.frequency = %.15lef;\n", static_cast<double>(Real{GetFrequency(joint) / Hertz}));
    log("  jd.dampingRatio = %.15lef;\n", GetDampingRatio(joint));
    log("  joints[%d] = m_world->CreateJoint(jd);\n", index);
}

} // namespace d2
} // namespace playrho

#endif // CODE_DUMPER_IS_READY

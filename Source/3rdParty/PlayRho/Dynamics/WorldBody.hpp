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

#ifndef PLAYRHO_DYNAMICS_WORLDBODY_HPP
#define PLAYRHO_DYNAMICS_WORLDBODY_HPP

/// @file
/// Declarations of free functions of World for bodies identified by <code>BodyID</code>.
/// @details This is a collection of non-member non-friend functions - also called "free"
///   functions - that are related to bodies within an instance of a <code>World</code>.
///   Many are just "wrappers" to similarly named member functions but some are additional
///   functionality built on those member functions. A benefit to using free functions that
///   are now just wrappers, is that of helping to isolate your code from future changes that
///   might occur to the underlying <code>World</code> member functions. Free functions in
///   this sense are "cheap" abstractions. While using these incurs extra run-time overhead
///   when compiled without any compiler optimizations enabled, enabling optimizations
///   should entirely eliminate that overhead.
/// @note The four basic categories of these functions are "CRUD": create, read, update,
///   and delete.
/// @see World, BodyID.
/// @see https://en.wikipedia.org/wiki/Create,_read,_update_and_delete.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Range.hpp" // for SizedRange

#include "PlayRho/Collision/MassData.hpp"

#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/FixtureID.hpp"
#include "PlayRho/Dynamics/FixtureConf.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp" // for GetDefaultBodyConf
#include "PlayRho/Dynamics/Contacts/KeyedContactID.hpp" // for KeyedContactPtr
#include "PlayRho/Dynamics/Joints/JointID.hpp"

#include <iterator>
#include <vector>
#include <functional>

namespace playrho {
namespace d2 {

class World;
class Shape;
class Body;

/// @example WorldBody.cpp
/// This is the <code>googletest</code> based unit testing file for the free function
///   interfaces to <code>playrho::d2::World</code> body member functions and additional
///   functionality.

/// @brief Gets the extent of the currently valid body range.
/// @note This is one higher than the maxium BodyID that is in range for body related
///   functions.
/// @relatedalso World
BodyCounter GetBodyRange(const World& world) noexcept;

/// @brief Gets the bodies of the specified world.
/// @relatedalso World
SizedRange<std::vector<BodyID>::const_iterator> GetBodies(const World& world) noexcept;

/// @brief Gets the bodies-for-proxies range for the given world.
/// @relatedalso World
SizedRange<std::vector<BodyID>::const_iterator>
GetBodiesForProxies(const World& world) noexcept;

/// @brief Creates a rigid body with the given configuration.
/// @warning This function should not be used while the world is locked &mdash; as it is
///   during callbacks. If it is, it will throw an exception or abort your program.
/// @note No references to the configuration are retained. Its value is copied.
/// @post The created body will be present in the range returned from the
///   <code>GetBodies(const World&)</code> method.
/// @param world The world within which to create the body.
/// @param def A customized body configuration or its default value.
/// @return Identifier of the newly created body which can later be destroyed by calling
///   the <code>Destroy(World&, BodyID)</code> method.
/// @throws WrongState if this method is called while the world is locked.
/// @throws LengthError if this operation would create more than <code>MaxBodies</code>.
/// @see Destroy(World& world, BodyID), GetBodies(const World&).
/// @see PhysicalEntities.
/// @relatedalso World
BodyID CreateBody(World& world, const BodyConf& def = GetDefaultBodyConf());

/// @brief Gets the body configuration for the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see CreateBody(World& world, const BodyConf&),
///   SetBody(World& world, BodyID id, const Body& body).
/// @relatedalso World
const Body& GetBody(const World& world, BodyID id);

/// @brief Sets the body state for the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetBody(const World& world, BodyID id).
/// @relatedalso World
void SetBody(World& world, BodyID id, const Body& body);

/// @brief Destroys the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see CreateBody(World&, const BodyConf&).
/// @relatedalso World
void Destroy(World& world, BodyID id);

/// @brief Gets the range of all constant fixtures attached to the given body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
SizedRange<std::vector<FixtureID>::const_iterator> GetFixtures(const World& world, BodyID id);

/// @brief Gets the count of fixtures associated with the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetFixtures(const World& world, BodyID id).
/// @relatedalso World
inline FixtureCounter GetFixtureCount(const World& world, BodyID id)
{
    using std::size;
    return static_cast<FixtureCounter>(size(GetFixtures(world, id)));
}

/// @brief Gets this body's linear acceleration.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetAcceleration(const World& world, BodyID id).
/// @relatedalso World
LinearAcceleration2 GetLinearAcceleration(const World& world, BodyID id);

/// @brief Gets this body's angular acceleration.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetAcceleration(const World& world, BodyID id).
/// @relatedalso World
AngularAcceleration GetAngularAcceleration(const World& world, BodyID id);

/// @brief Gets the acceleration of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetAcceleration(World&, BodyID, LinearAcceleration2, AngularAcceleration).
/// @relatedalso World
Acceleration GetAcceleration(const World& world, BodyID id);

/// @brief Sets the linear and rotational accelerations on the body.
/// @note This has no effect on non-accelerable bodies.
/// @note A non-zero acceleration will also awaken the body.
/// @param world World in which it all happens.
/// @param id Identifier of body whose acceleration should be set.
/// @param linear Linear acceleration.
/// @param angular Angular acceleration.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetAcceleration(const World& world, BodyID id).
/// @relatedalso World
void SetAcceleration(World& world, BodyID id,
                     LinearAcceleration2 linear, AngularAcceleration angular);

/// @brief Sets the linear accelerations on the body.
/// @note This has no effect on non-accelerable bodies.
/// @note A non-zero acceleration will also awaken the body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetAcceleration(const World& world, BodyID id).
/// @relatedalso World
void SetAcceleration(World& world, BodyID id, LinearAcceleration2 value);

/// @brief Sets the rotational accelerations on the body.
/// @note This has no effect on non-accelerable bodies.
/// @note A non-zero acceleration will also awaken the body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetAcceleration(const World& world, BodyID id).
/// @relatedalso World
void SetAcceleration(World& world, BodyID id, AngularAcceleration value);

/// @brief Sets the accelerations on the given body.
/// @note This has no effect on non-accelerable bodies.
/// @note A non-zero acceleration will also awaken the body.
/// @param world The world in which the identified body's acceleration should be set.
/// @param id Identifier of body whose acceleration should be set.
/// @param value Acceleration value to set.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetAcceleration(const World& world, BodyID id).
/// @relatedalso World
void SetAcceleration(World& world, BodyID id, Acceleration value);

/// @brief Sets the transformation of the body.
/// @details This instantly adjusts the body to be at the new transformation.
/// @warning Manipulating a body's transformation can cause non-physical behavior!
/// @note Contacts are updated on the next call to World::Step.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetTransformation(const World& world, BodyID id).
/// @relatedalso World
void SetTransformation(World& world, BodyID id, Transformation xfm);

/// @brief Sets the position of the body's origin and rotation.
/// @details This instantly adjusts the body to be at the new position and new orientation.
/// @warning Manipulating a body's transform can cause non-physical behavior!
/// @note Contacts are updated on the next call to World::Step.
/// @param world The world in which the identified body's transform should be set.
/// @param id Identifier of body whose transform is to be set.
/// @param location Valid world location of the body's local origin. Behavior is undefined
///   if value is invalid.
/// @param angle Valid world rotation. Behavior is undefined if value is invalid.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline void SetTransform(World& world, BodyID id, Length2 location, Angle angle)
{
    SetTransformation(world, id, Transformation{location, UnitVec::Get(angle)});
}

/// @brief Sets the body's location.
/// @details This instantly adjusts the body to be at the new location.
/// @warning Manipulating a body's location this way can cause non-physical behavior!
/// @param world The world in which the identified body's location should be set.
/// @param id Identifier of body to move.
/// @param value Valid world location of the body's local origin. Behavior is undefined
///   if value is invalid.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetLocation(const World& world, BodyID id).
/// @relatedalso World
void SetLocation(World& world, BodyID id, Length2 value);

/// @brief Sets the body's angular orientation.
/// @details This instantly adjusts the body to be at the new angular orientation.
/// @warning Manipulating a body's angle this way can cause non-physical behavior!
/// @param world The world in which the identified body's angle should be set.
/// @param id Identifier of body to move.
/// @param value Valid world angle of the body's local origin. Behavior is undefined
///   if value is invalid.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetAngle(const World& world, BodyID id).
/// @relatedalso World
void SetAngle(World& world, BodyID id, Angle value);

/// @brief Rotates a body a given amount around a point in world coordinates.
/// @details This changes both the linear and angular positions of the body.
/// @note Manipulating a body's position this way may cause non-physical behavior.
/// @param world The world in which the identified body exists.
/// @param id Identifier of body to rotate.
/// @param amount Amount to rotate body by (in counter-clockwise direction).
/// @param worldPoint Point in world coordinates.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void RotateAboutWorldPoint(World& world, BodyID id, Angle amount, Length2 worldPoint);

/// @brief Rotates a body a given amount around a point in body local coordinates.
/// @details This changes both the linear and angular positions of the body.
/// @note Manipulating a body's position this way may cause non-physical behavior.
/// @note This is a convenience function that translates the local point into world coordinates
///   and then calls the <code>RotateAboutWorldPoint</code> function.
/// @param world The world in which the identified body exists.
/// @param id Identifier of body to rotate.
/// @param amount Amount to rotate body by (in counter-clockwise direction).
/// @param localPoint Point in local coordinates.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void RotateAboutLocalPoint(World& world, BodyID id, Angle amount, Length2 localPoint);

/// @brief Calculates the gravitationally associated acceleration for the given body within its world.
/// @return Zero acceleration if given body is has no mass, else the acceleration of
///    the body due to the gravitational attraction to the other bodies.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
Acceleration CalcGravitationalAcceleration(const World& world, BodyID id);

/// @brief Gets the world index for the given body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
BodyCounter GetWorldIndex(const World& world, const BodyID id) noexcept;

/// @brief Gets the type of the identified body.
/// @see SetType(World& world, BodyID id, BodyType value)
/// @relatedalso World
BodyType GetType(const World& world, BodyID id);

/// @brief Sets the type of the given body.
/// @note This may alter the body's mass and velocity.
/// @throws WrongState if this method is called while the world is locked.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetType(const World& world, BodyID id)
/// @relatedalso World
void SetType(World& world, BodyID id, BodyType value, bool resetMassData = true);

/// @brief Gets the body's transformation.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetTransformation(World& world, BodyID id, Transformation xfm).
/// @relatedalso World
Transformation GetTransformation(const World& world, BodyID id);

/// @brief Convenience function for getting just the location of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetTransformation(const World& world, BodyID id).
/// @relatedalso World
inline Length2 GetLocation(const World& world, BodyID id)
{
    return GetTransformation(world, id).p;
}

/// @brief Gets the world coordinates of a point given in coordinates relative to the body's origin.
/// @param world World context.
/// @param id Identifier of body that the given point is relative to.
/// @param localPoint a point measured relative the the body's origin.
/// @return the same point expressed in world coordinates.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline Length2 GetWorldPoint(const World& world, BodyID id, const Length2 localPoint)
{
    return Transform(localPoint, GetTransformation(world, id));
}

/// @brief Convenience function for getting the local vector of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline UnitVec GetLocalVector(const World& world, BodyID body, const UnitVec uv)
{
    return InverseRotate(uv, GetTransformation(world, body).q);
}

/// @brief Gets a local point relative to the body's origin given a world point.
/// @param world The world in which the identified body exists.
/// @param body Identifier of body that the returned point should be relative to.
/// @param worldPoint point in world coordinates.
/// @return the corresponding local point relative to the body's origin.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline Length2 GetLocalPoint(const World& world, BodyID body, const Length2 worldPoint)
{
    return InverseTransform(worldPoint, GetTransformation(world, body));
}

/// @brief Gets the angle of the identified body.
/// @return the current world rotation angle.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
Angle GetAngle(const World& world, BodyID id);

/// @brief Convenience function for getting the position of the identified body.
inline Position GetPosition(const World& world, BodyID id)
{
    return Position{GetLocation(world, id), GetAngle(world, id)};
}

/// @brief Convenience function for getting a world vector of the identified body.
/// @relatedalso World
inline UnitVec GetWorldVector(const World& world, BodyID body, UnitVec localVector)
{
    return Rotate(localVector, GetTransformation(world, body).q);
}

/// @brief Gets the velocity of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetVelocity(World& world, BodyID id, const Velocity& value).
/// @relatedalso World
Velocity GetVelocity(const World& world, BodyID id);

/// @brief Sets the body's velocity (linear and angular velocity).
/// @note This method does nothing if this body is not speedable.
/// @note A non-zero velocity will awaken this body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetVelocity(BodyID), SetAwake, SetUnderActiveTime.
/// @relatedalso World
void SetVelocity(World& world, BodyID id, const Velocity& value);

/// @brief Gets the awake/asleep state of this body.
/// @warning Being awake may or may not imply being speedable.
/// @return true if the body is awake.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetAwake(World& world, BodyID id), UnsetAwake(BodyID id).
/// @relatedalso World
bool IsAwake(const World& world, BodyID id);

/// @brief Wakes up the identified body.
/// @note This wakes up any associated contacts that had been asleep.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see IsAwake(const World& world, BodyID id), UnsetAwake(World& world, BodyID id).
/// @relatedalso World
void SetAwake(World& world, BodyID id);

/// @brief Sleeps the identified body.
/// @note This sleeps any associated contacts whose other body is also asleep.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see IsAwake(const World& world, BodyID id), SetAwake(World& world, BodyID id).
/// @relatedalso World
void UnsetAwake(World& world, BodyID id);

/// @brief Gets the linear velocity of the center of mass of the identified body.
/// @param world World in which body is identified for.
/// @param id Identifier of body to get the linear velocity for.
/// @return the linear velocity of the center of mass.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline LinearVelocity2 GetLinearVelocity(const World& world, BodyID id)
{
    return GetVelocity(world, id).linear;
}

/// @brief Gets the angular velocity.
/// @param world World in which body is identified for.
/// @param id Identifier of body to get the angular velocity for.
/// @return the angular velocity.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline AngularVelocity GetAngularVelocity(const World& world, BodyID id)
{
    return GetVelocity(world, id).angular;
}

/// @brief Sets the body's velocity (linear and angular velocity).
/// @note This method does nothing if this body is not speedable.
/// @note A non-zero velocity will awaken this body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetVelocity.
/// @relatedalso World
void SetVelocity(World& world, BodyID id, const Velocity& value);

/// @brief Sets the velocity of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void SetVelocity(World& world, BodyID id, const LinearVelocity2& value);

/// @brief Sets the velocity of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void SetVelocity(World& world, BodyID id, AngularVelocity value);

/// @brief Destroys fixtures of the identified body.
/// @details Destroys all of the fixtures previously created for this body by the
///   <code>CreateFixture(const Shape&, const FixtureConf&, bool)</code> method.
/// @note This may call the <code>ResetMassData()</code> method.
/// @post After this call, no fixtures will show up in the fixture enumeration
///   returned by the <code>GetFixtures()</code> methods.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see CreateFixture, GetFixtures, ResetMassData.
/// @see PhysicalEntities
/// @relatedalso World
void DestroyFixtures(World& world, BodyID id, bool resetMassData = true);

/// @brief Gets the enabled/disabled state of the body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetEnabled.
/// @relatedalso World
bool IsEnabled(const World& world, BodyID id);

/// @brief Sets the enabled state of the body.
/// @details A disabled body is not simulated and cannot be collided with or woken up.
///   If you pass a flag of true, all fixtures will be added to the broad-phase.
///   If you pass a flag of false, all fixtures will be removed from the broad-phase
///   and all contacts will be destroyed. Fixtures and joints are otherwise unaffected.
/// @note A disabled body is still owned by a World object and remains in the world's
///   body container.
/// @note You may continue to create/destroy fixtures and joints on disabled bodies.
/// @note Fixtures on a disabled body are implicitly disabled and will not participate in
///   collisions, ray-casts, or queries.
/// @note Joints connected to a disabled body are implicitly disabled.
/// @throws WrongState If call would change body's state when world is locked.
/// @throws std::out_of_range If given an invalid body identifier.
/// @post <code>IsEnabled()</code> returns the state given to this function.
/// @see IsEnabled.
/// @relatedalso World
void SetEnabled(World& world, BodyID id, bool value);

/// @brief Gets the awake/asleep state of this body.
/// @warning Being awake may or may not imply being speedable.
/// @return true if the body is awake.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetAwake, UnsetAwake.
/// @relatedalso World
bool IsAwake(const World& world, BodyID id);

/// @brief Wakes up the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void SetAwake(World& world, BodyID id);

/// @brief Sleeps the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see IsAwake, SetAwake.
/// @relatedalso World
void UnsetAwake(World& world, BodyID id);

/// @brief Awakens the body if it's asleep.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline bool Awaken(World& world, BodyID id)
{
    if (!IsAwake(world, id) && IsSpeedable(GetType(world, id)))
    {
        SetAwake(world, id);
        return true;
    }
    return false;
}

/// @brief Gets whether the body's mass-data is dirty.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
bool IsMassDataDirty(const World& world, BodyID id);

/// @brief Gets whether the body has fixed rotation.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetFixedRotation.
/// @relatedalso World
bool IsFixedRotation(const World& world, BodyID id);

/// @brief Sets this body to have fixed rotation.
/// @throws std::out_of_range If given an invalid body identifier.
/// @note This also causess the mass data to be reset.
/// @see IsFixedRotation.
/// @relatedalso World
void SetFixedRotation(World& world, BodyID id, bool value);

/// @brief Get the world position of the center of mass of the specified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
Length2 GetWorldCenter(const World& world, BodyID id);

/// @brief Gets the inverse total mass of the body.
/// @return Value of zero or more representing the body's inverse mass (in 1/kg).
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetMassData.
/// @relatedalso World
InvMass GetInvMass(const World& world, BodyID id);

/// @brief Gets the inverse rotational inertia of the body.
/// @return Inverse rotational inertia (in 1/kg-m^2).
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
InvRotInertia GetInvRotInertia(const World& world, BodyID id);

/// @brief Gets the mass of the body.
/// @note This may be the total calculated mass or it may be the set mass of the body.
/// @return Value of zero or more representing the body's mass.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetInvMass, SetMassData
/// @relatedalso World
inline Mass GetMass(const World& world, BodyID id)
{
    const auto invMass = GetInvMass(world, id);
    return (invMass != InvMass{0})? Mass{Real{1} / invMass}: 0_kg;
}

/// @brief Gets the rotational inertia of the body.
/// @param world The world in which the identified body exists.
/// @param id Identifier of body to get the rotational inertia for.
/// @return the rotational inertia.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline RotInertia GetRotInertia(const World& world, BodyID id)
{
    return Real{1} / GetInvRotInertia(world, id);
}

/// @brief Gets the local position of the center of mass of the specified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
Length2 GetLocalCenter(const World& world, BodyID id);

/// @brief Gets the rotational inertia of the body about the local origin.
/// @return the rotational inertia.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline RotInertia GetLocalRotInertia(const World& world, BodyID id)
{
    return GetRotInertia(world, id)
         + GetMass(world, id) * GetMagnitudeSquared(GetLocalCenter(world, id)) / SquareRadian;
}

/// @brief Gets the mass data of the body.
/// @return Data structure containing the mass, inertia, and center of the body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline MassData GetMassData(const World& world, BodyID id)
{
    return MassData{GetLocalCenter(world, id), GetMass(world, id), GetLocalRotInertia(world, id)};
}

/// @brief Computes the identified body's mass data.
/// @details This basically accumulates the mass data over all fixtures.
/// @note The center is the mass weighted sum of all fixture centers. Divide it by the
///   mass to get the averaged center.
/// @return accumulated mass data for all fixtures associated with the given body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
MassData ComputeMassData(const World& world, BodyID id);

/// @brief Sets the mass properties to override the mass properties of the fixtures.
/// @note This changes the center of mass position.
/// @note Creating or destroying fixtures can also alter the mass.
/// @note This function has no effect if the body isn't dynamic.
/// @param world The world in which the identified body exists.
/// @param id Identifier of the body.
/// @param massData the mass properties.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void SetMassData(World& world, BodyID id, const MassData& massData);

/// @brief Resets the mass data properties.
/// @details This resets the mass data to the sum of the mass properties of the fixtures.
/// @note This method must be called after calling <code>CreateFixture</code> to update the
///   body mass data properties unless <code>SetMassData</code> is used.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see SetMassData.
/// @relatedalso World
inline void ResetMassData(World& world, BodyID id)
{
    SetMassData(world, id, ComputeMassData(world, id));
}

/// @brief Gets the range of all joints attached to the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
SizedRange<std::vector<std::pair<BodyID, JointID>>::const_iterator>
GetJoints(const World& world, BodyID id);

/// @brief Is identified body "speedable".
/// @details Is the body able to have a non-zero speed associated with it.
///  Kinematic and Dynamic bodies are speedable. Static bodies are not.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
bool IsSpeedable(const World& world, BodyID id);

/// @brief Is identified body "accelerable"?
/// @details Indicates whether the body is accelerable, i.e. whether it is effected by
///   forces. Only Dynamic bodies are accelerable.
/// @return true if the body is accelerable, false otherwise.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
bool IsAccelerable(const World& world, BodyID id);

/// @brief Is the body treated like a bullet for continuous collision detection?
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
bool IsImpenetrable(const World& world, BodyID id);

/// @brief Sets the impenetrable status of the identified body.
/// @details Sets that the body should be treated like a bullet for continuous
///   collision detection.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void SetImpenetrable(World& world, BodyID id);

/// @brief Unsets the impenetrable status of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void UnsetImpenetrable(World& world, BodyID id);

/// @brief Convenience function that sets/unsets the impenetrable status of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline void SetImpenetrable(World& world, BodyID id, bool value)
{
    if (value)
        SetImpenetrable(world, id);
    else
        UnsetImpenetrable(world, id);
}

/// @brief Gets whether the identified body is allowed to sleep.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
bool IsSleepingAllowed(const World& world, BodyID id);

/// @brief Sets whether the identified body is allowed to sleep.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void SetSleepingAllowed(World& world, BodyID, bool value);

/// @brief Gets the container of all contacts attached to the identified body.
/// @warning This collection changes during the time step and you may
///   miss some collisions if you don't use <code>ContactListener</code>.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
SizedRange<std::vector<KeyedContactPtr>::const_iterator>
GetContacts(const World& world, BodyID id);

/// @brief Gets the centripetal force necessary to put the body into an orbit having
///    the given radius.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
Force2 GetCentripetalForce(const World& world, BodyID id, Length2 axis);

/// @brief Applies a force to the center of mass of the given body.
/// @note Non-zero forces wakes up the body.
/// @param world The world in which the identified body exists.
/// @param id Identifier of body to apply the force to.
/// @param force World force vector.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline void ApplyForceToCenter(World& world, BodyID id, Force2 force)
{
    const auto linAccel = GetLinearAcceleration(world, id) + force * GetInvMass(world, id);
    const auto angAccel = GetAngularAcceleration(world, id);
    SetAcceleration(world, id, linAccel, angAccel);
}

/// @brief Apply a force at a world point.
/// @note If the force is not applied at the center of mass, it will generate a torque and
///   affect the angular velocity.
/// @note Non-zero forces wakes up the body.
/// @param world World in which body exists.
/// @param id Identity of body to apply the force to.
/// @param force World force vector.
/// @param point World position of the point of application.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void ApplyForce(World& world, BodyID id, Force2 force, Length2 point);

/// @brief Applies a torque.
/// @note This affects the angular velocity without affecting the linear velocity of the
///   center of mass.
/// @note Non-zero forces wakes up the body.
/// @param world The world in which the identified body exists.
/// @param id Identifier of body to apply the torque to.
/// @param torque about the z-axis (out of the screen).
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void ApplyTorque(World& world, BodyID id, Torque torque);

/// @brief Applies an impulse at a point.
/// @note This immediately modifies the velocity.
/// @note This also modifies the angular velocity if the point of application
///   is not at the center of mass.
/// @note Non-zero impulses wakes up the body.
/// @param world The world in which the identified body exists.
/// @param id Identifier of body to apply the impulse to.
/// @param impulse the world impulse vector.
/// @param point the world position of the point of application.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void ApplyLinearImpulse(World& world, BodyID id, Momentum2 impulse, Length2 point);

/// @brief Applies an angular impulse.
/// @param world The world in which the identified body exists.
/// @param id Identifier of body to apply the angular impulse to.
/// @param impulse Angular impulse to be applied.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void ApplyAngularImpulse(World& world, BodyID id, AngularMomentum impulse);

/// @brief Sets the given amount of force at the given point to the given body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline void SetForce(World& world, BodyID id, Force2 force, Length2 point) noexcept
{
    const auto linAccel = LinearAcceleration2{force * GetInvMass(world, id)};
    const auto invRotI = GetInvRotInertia(world, id);
    const auto dp = point - GetWorldCenter(world, id);
    const auto cp = Torque{Cross(dp, force) / Radian};
    const auto angAccel = AngularAcceleration{cp * invRotI};
    SetAcceleration(world, id, linAccel, angAccel);
}

/// @brief Sets the given amount of torque to the given body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
inline void SetTorque(World& world, BodyID id, Torque torque) noexcept
{
    const auto linAccel = GetLinearAcceleration(world, id);
    const auto invRotI = GetInvRotInertia(world, id);
    const auto angAccel = torque * invRotI;
    SetAcceleration(world, id, linAccel, angAccel);
}

/// @brief Gets the linear damping of the body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
Frequency GetLinearDamping(const World& world, BodyID id);

/// @brief Sets the linear damping of the body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void SetLinearDamping(World& world, BodyID id, NonNegative<Frequency> linearDamping);

/// @brief Gets the angular damping of the body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
Frequency GetAngularDamping(const World& world, BodyID id);

/// @brief Sets the angular damping of the body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
void SetAngularDamping(World& world, BodyID id, NonNegative<Frequency> angularDamping);

/// @brief Gets the count of awake bodies in the given world.
/// @relatedalso World
BodyCounter GetAwakeCount(const World& world) noexcept;

/// @brief Awakens all of the bodies in the given world.
/// @details Calls all of the world's bodies' <code>SetAwake</code> method.
/// @return Sum total of calls to bodies' <code>SetAwake</code> method that returned true.
/// @relatedalso World
BodyCounter Awaken(World& world) noexcept;

/// @brief Finds body in given world that's closest to the given location.
/// @relatedalso World
BodyID FindClosestBody(const World& world, Length2 location) noexcept;

/// @brief Gets the body count in the given world.
/// @return 0 or higher.
/// @relatedalso World
inline BodyCounter GetBodyCount(const World& world) noexcept
{
    using std::size;
    return static_cast<BodyCounter>(size(GetBodies(world)));
}

/// @brief Sets the accelerations of all the world's bodies to the given value.
/// @relatedalso World
void SetAccelerations(World& world, Acceleration acceleration) noexcept;

/// @brief Sets the accelerations of all the world's bodies to the given value.
/// @note This will leave the angular acceleration alone.
/// @relatedalso World
void SetAccelerations(World& world, LinearAcceleration2 acceleration) noexcept;

/// @brief Clears forces.
/// @details Manually clear the force buffer on all bodies.
/// @relatedalso World
inline void ClearForces(World& world) noexcept
{
    SetAccelerations(world, Acceleration{});
}

/// @brief Sets the accelerations of all the world's bodies.
/// @param world World instance to set the acceleration of all contained bodies for.
/// @param fn Function or functor with a signature like:
///   <code>Acceleration (*fn)(World&,BodyID)</code>.
/// @relatedalso World
template <class F>
void SetAccelerations(World& world, F fn)
{
    const auto bodies = GetBodies(world);
    std::for_each(begin(bodies), end(bodies), [&](const auto &b) {
        SetAcceleration(world, b, fn(world, b));
    });
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDBODY_HPP

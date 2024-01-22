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

#ifndef PLAYRHO_D2_WORLD_HPP
#define PLAYRHO_D2_WORLD_HPP

/// @file
/// @brief Definitions of the World class and closely related code.

#include <iterator>
#include <memory> // for std::unique_ptr
#include <optional>
#include <tuple>
#include <typeinfo>
#include <type_traits> // for std::is_default_constructible_v, etc.
#include <utility> // for std::move
#include <vector>

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/BodyShapeFunction.hpp"
#include "playrho/Contact.hpp"
#include "playrho/ContactFunction.hpp"
#include "playrho/ContactID.hpp"
#include "playrho/ContactKey.hpp"
#include "playrho/Interval.hpp"
#include "playrho/KeyedContactID.hpp"
#include "playrho/JointFunction.hpp"
#include "playrho/JointID.hpp"
#include "playrho/Positive.hpp"
#include "playrho/Settings.hpp"
#include "playrho/ShapeFunction.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/StepStats.hpp"
#include "playrho/Templates.hpp" // for begin, end
#include "playrho/TypeInfo.hpp" // for GetTypeID
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/pmr/StatsResource.hpp"

#include "playrho/d2/Body.hpp"
#include "playrho/d2/BodyConf.hpp" // for GetDefaultBodyConf
#include "playrho/d2/ContactImpulsesFunction.hpp"
#include "playrho/d2/ContactManifoldFunction.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/Manifold.hpp"
#include "playrho/d2/Shape.hpp"
#include "playrho/d2/WorldConf.hpp"

// IWYU pragma: end_exports

#include "playrho/d2/detail/WorldConcept.hpp"
#include "playrho/d2/detail/WorldModel.hpp"

namespace playrho::d2 {

class World;
class ContactImpulsesList;
class DynamicTree;

/// @brief Sets the destruction listener for shapes.
/// @note This listener is called on <code>Clear(World&)</code> for every shape.
/// @param world The world to set the listener for.
/// @param listener Function that the world is to call on these events.
/// @see Clear(World&).
void SetShapeDestructionListener(World& world, ShapeFunction listener) noexcept;

/// @brief Sets the detach listener for shapes detaching from bodies.
/// @note This listener is called on <code>Destroy(World&,BodyID)</code> for every shape
///   associated with that identified body.
/// @param world The world to set the listener for.
/// @param listener Function that the world is to call on these events.
/// @see Destroy(World&,BodyID).
void SetDetachListener(World& world, BodyShapeFunction listener) noexcept;

/// @brief Sets the destruction listener for joints.
/// @note This listener is called on <code>Clear(World&)</code> for every joint. It's also called
///   on <code>Destroy(BodyID)</code> for every joint associated with the identified body.
/// @param world The world to set the listener for.
/// @param listener Function that the world is to call on these events.
/// @see Clear(World&), Destroy(BodyID).
void SetJointDestructionListener(World& world, JointFunction listener) noexcept;

/// @brief Sets the begin-contact lister.
/// @note This listener is called during calls to the
///   <code>Step(World&,const StepConf&)</code> function for every contact that transitions
///   from not previously touching, to touching in the step.
/// @param world The world to set the listener for.
/// @param listener Function that the world is to call on these events.
/// @see SetEndContactListener(World&, ContactFunction).
void SetBeginContactListener(World& world, ContactFunction listener) noexcept;

/// @brief Sets the end-contact lister.
/// @note This listener is called during calls to the
///   <code>Step(World&,const StepConf&)</code> function for every contact that transitions
///   from previously touching, to no longer touching in the step.
/// @param world The world to set the listener for.
/// @param listener Function that the world is to call on these events.
/// @see SetBeginContactListener(World&, ContactFunction).
void SetEndContactListener(World& world, ContactFunction listener) noexcept;

/// @brief Sets the pre-solve-contact lister.
/// @note This listener is called during calls to the
///   <code>Step(World&,const StepConf&)</code> function for every non-sensor contact that
///   is touching.
/// @param world The world to set the listener for.
/// @param listener Function that the world is to call on these events.
/// @see SetPostSolveContactListener(World&, ContactImpulsesFunction).
void SetPreSolveContactListener(World& world, ContactManifoldFunction listener) noexcept;

/// @brief Sets the post-solve-contact lister.
/// @note This listener is called during calls to the
///   <code>Step(World&,const StepConf&)</code> function for every contact that was "solved"
///   during regular processing or TOI processing (or both).
/// @param world The world to set the listener for.
/// @param listener Function that the world is to call on these events.
/// @see SetPreSolveContactListener(World&, ContactManifoldFunction).
void SetPostSolveContactListener(World& world, ContactImpulsesFunction listener) noexcept;

/// @brief Gets the identifier of the type of data the given world can be casted to.
/// @param world The world for which an identifier of the type of its underlying value is
///   to be returned.
/// @see TypeCast.
TypeID GetType(const World& world) noexcept;

/// @brief Casts the given world into its current underlying configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> code from the LLVM Project.
/// @tparam T type to cast the underlying value of the given world to, if matching the actual
///   type of the underlying value.
/// @param value Pointer to the world whose underlying value, if it's type is the type
///   of the template parameter, is to be returned.
/// @see GetType(const World&).
/// @see https://llvm.org/
template <typename T>
std::add_pointer_t<std::add_const_t<T>> TypeCast(const World* value) noexcept;

/// @brief Casts the given world into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @tparam T type to cast the underlying value of the given world to, if matching the actual
///   type of the underlying value.
/// @param value Pointer to the world whose underlying value, if it's type is the type
///   of the template parameter, is to be returned.
/// @see GetType(const World&).
/// @see https://llvm.org/
template <typename T>
std::add_pointer_t<T> TypeCast(World* value) noexcept;

/// @brief Equality operator for world comparisons.
/// @param lhs Left hand side world of the infix binary equality operator.
/// @param rhs Right hand side world of the infix binary equality operator.
/// @return true if @p lhs is equal to @p rhs , false otherwise.
bool operator==(const World& lhs, const World& rhs) noexcept;

/// @brief Inequality operator for world comparisons.
/// @param lhs Left hand side world of the infix binary inequality operator.
/// @param rhs Right hand side world of the infix binary inequality operator.
/// @return true if @p lhs is **not** equal to @p rhs , false otherwise.
bool operator!=(const World& lhs, const World& rhs) noexcept;

/// @brief Gets the polymorphic memory resource allocator statistics of the specified world.
/// @note This will be the empty value unless the world configuration the given world was
///   constructed with specified the collection of these statistics.
/// @note This information can be used to tweak the world configuration to pre-allocate enough
///   space to avoid the less deterministic performance behavior of dynamic memory allocation
///   during world step processing that may otherwise occur.
/// @param world The world to get the memory resource allocator statistics for.
/// @see WorldConf.
std::optional<pmr::StatsResource::Stats> GetResourceStats(const World& world) noexcept;

/// @brief Clears the given world.
/// @note This calls the joint and shape destruction listeners (if they're set), for all
///   defined joints and shapes, before clearing anything. Any exceptions thrown from these
///   listeners are ignored.
/// @param world The world to clear.
/// @post The contents of this world have all been destroyed and this world's internal
///   state is reset as though it had just been constructed.
/// @see SetJointDestructionListener, SetShapeDestructionListener.
void Clear(World& world) noexcept;

/// @brief Steps the given world simulation according to the given configuration.
/// @details Performs position and velocity updating, sleeping of non-moving bodies, updating
///   of the contacts, and notifying the contact listener of begin-contact, end-contact,
///   pre-solve, and post-solve events.
/// @warning Behavior is not specified if given a negative step time delta.
/// @warning Varying the step time delta may lead to non-physical behaviors.
/// @note Calling this with a zero step time delta results only in fixtures and bodies
///   registered for special handling being processed. No physics is performed.
/// @note If the given velocity and position iterations are zero, this function doesn't
///   do velocity or position resolutions respectively of the contacting bodies.
/// @note While body velocities are updated accordingly (per the sum of forces acting on them),
///   body positions (barring any collisions) are updated as if they had moved the entire time
///   step at those resulting velocities. In other words, a body initially at position 0
///   (<code>p0</code>) going velocity 0 (<code>v0</code>) fast with a sum acceleration of
///   <code>a</code>, after time <code>t</code> and barring any collisions, will have a new
///   velocity (<code>v1</code>) of <code>v0 + (a * t)</code> and a new position
///   (<code>p1</code>) of <code>p0 + v1 * t</code>.
/// @note While this function is running, some listener functions could get called.
///   Meanwhile some functions on <code>World</code> can only operate while the world
///   is not in the middle of being updated by this function. Listeners can use the
///   <code>IsLocked(const World& world)</code> function to detect whether they've been
///   called in this case or not and then act accordingly.
/// @post Static bodies are unmoved.
/// @post Kinetic bodies are moved based on their previous velocities.
/// @post Dynamic bodies are moved based on their previous velocities, gravity, applied
///   forces, applied impulses, masses, damping, and the restitution and friction values
///   of their fixtures when they experience collisions.
/// @param world The world to simulate a step for.
/// @param conf Configuration for the simulation step.
/// @return Statistics for the step.
/// @throws WrongState if this function is called while the world is locked.
/// @see IsLocked(const World&).
StepStats Step(World& world, const StepConf& conf = StepConf{});

/// @brief Whether or not "step" is complete.
/// @details The "step" is completed when there are no more TOI events for the current time
///   step.
/// @param world The world to return whether the step is completed for.
/// @return <code>true</code> unless sub-stepping is enabled and the step function returned
///   without finishing all of its sub-steps.
/// @see GetSubStepping, SetSubStepping, Step.
bool IsStepComplete(const World& world) noexcept;

/// @brief Gets whether or not sub-stepping is enabled.
/// @param world The world to return whether sub-stepping is enabled for.
/// @see SetSubStepping, IsStepComplete.
bool GetSubStepping(const World& world) noexcept;

/// @brief Enables/disables single stepped continuous physics.
/// @note This is not normally used. Enabling sub-stepping is meant for testing.
/// @param world The world to set whether or not to do sub-stepping for.
/// @param flag @c true to enable sub-stepping, @c false to disable it.
/// @post The <code>GetSubStepping()</code> function will return the value this function was
///   called with.
/// @see IsStepComplete, GetSubStepping.
void SetSubStepping(World& world, bool flag) noexcept;

/// @brief Gets access to the broad-phase dynamic tree information.
/// @todo Consider removing this function. This function exposes the implementation detail
///   of the broad-phase contact detection system.
const DynamicTree& GetTree(const World& world);

/// @brief Is the specified world locked.
/// @details Used to detect whether being called while already within the execution of the
///   <code>Step(World&, const StepConf&)</code> function - which sets this "lock".
/// @param world The world to return whether it's in a locked state or not.
/// @see Step(World&, const StepConf&).
bool IsLocked(const World& world) noexcept;

/// @brief Shifts the origin of the specified world.
/// @note Useful for large worlds.
/// @note The body shift formula is: <code>position -= newOrigin</code>.
/// @post The "origin" of this world's bodies, joints, and the board-phase dynamic tree
///   have been translated per the shift amount and direction.
/// @param world The world whose origin is to be shifted.
/// @param newOrigin the new origin with respect to the old origin
/// @throws WrongState if this function is called while the world is locked.
void ShiftOrigin(World& world, const Length2& newOrigin);

/// @brief Gets the vertex radius interval allowable for the given world.
/// @param world The world whose allowable vertex radius interval is to be returned for.
/// @see CreateShape(World&, const Shape&).
Interval<Positive<Length>> GetVertexRadiusInterval(const World& world) noexcept;

/// @brief Gets the inverse delta time.
/// @details Gets the inverse delta time that was set on construction or assignment, and
///   updated on every call to the <code>Step</code> function having a non-zero delta-time.
/// @param world The world whose inverse delta time is to be returned for.
/// @see Step.
Frequency GetInvDeltaTime(const World& world) noexcept;

/// @brief Gets the extent of the currently valid body range.
/// @note This is one higher than the maxium <code>BodyID</code> that is in range
///   for body related functions.
/// @param world The world whose body range is to be returned for.
BodyCounter GetBodyRange(const World& world) noexcept;

/// @brief Gets the valid world body identifiers container for this constant world.
/// @details Gets a container enumerating the identifiers of bodies currently existing
///   within this world. These are the bodies that had been created from previous calls to
///   <code>CreateBody(World&, const Body&)</code> that haven't yet been destroyed by
///   a call to <code>Destroy(World& world, BodyID)</code> or to <code>Clear(World&)</code>.
/// @param world The world whose body identifiers are to be returned for.
/// @return Container of body identifiers.
/// @see CreateBody(World&, const Body&), Destroy(World& world, BodyID), Clear(World&).
std::vector<BodyID> GetBodies(const World& world);

/// @brief Gets the bodies-for-proxies container for this world.
/// @details Provides insight on what bodies have been queued for proxy processing
///   during the next call to the world step function.
/// @see Step.
/// @todo Remove this function from this class - access from implementation instead.
std::vector<BodyID> GetBodiesForProxies(const World& world);

/// @brief Creates a rigid body within the world that's a copy of the given one.
/// @note This function should not be used while the world is locked &mdash; as it is
///   during callbacks. If it is, it will throw an exception or abort your program.
/// @note No references to the configuration are retained. Its value is copied.
/// @param world The world within which to create the body.
/// @param body A customized body or its default value.
/// @param resetMassData Whether or not the mass data of the body should be reset.
/// @return Identifier of the newly created body which can later be destroyed by calling
///   the <code>Destroy(BodyID)</code> function.
/// @throws WrongState if this function is called while the world is locked.
/// @throws LengthError if this operation would create more than <code>MaxBodies</code>.
/// @throws std::out_of_range if the given body references any out of range shape identifiers.
/// @post The created body's identifier will be present in the container returned from the
///   <code>GetBodies(const World&)</code> function.
/// @post Calling <code>GetBody(const World&, BodyID)</code> with the returned body identifer
///   returns the body given to this create function.
/// @see Destroy(World& world, BodyID), GetBodies(const World&), ResetMassData, GetShapeRange.
/// @see PhysicalEntities.
BodyID CreateBody(World& world, const Body& body = Body{}, bool resetMassData = true);

/// @brief Gets the state of the identified body.
/// @throws std::out_of_range If given an out of range body identifier.
/// @see CreateBody(World&, const Body&, bool), SetBody(World&, BodyID, const Body&),
///   GetBodyRange.
Body GetBody(const World& world, BodyID id);

/// @brief Sets the state of the identified body.
/// @param world The world containing the identified body whose state is to be set.
/// @param id Identifier of the body whose state is to be set.
/// @param body New state of the identified body.
/// @throws std::out_of_range if @p id is out of range, or if the given body references any
///   shape identifiers that are out of range.
/// @throws InvalidArgument if the specified ID was destroyed.
/// @post On success: <code>GetBody(const World&, BodyID)</code> for @p world and @p id
///   returns the value of @p body .
/// @see GetBody(const World&, BodyID), GetBodyRange, GetShapeRange.
void SetBody(World& world, BodyID id, const Body& body);

/// @brief Destroys the identified body.
/// @details Destroys the identified body that had previously been created by a call
///   to this world's <code>CreateBody(const BodyConf&)</code> function.
/// @note This automatically deletes all associated shapes and joints.
/// @note This function is locked during callbacks. The detatch listener, if set, is called
///   for every shape associated with the identified body.
/// @param world The world from which to delete the identified body from.
/// @param id Identifier of body to destroy that had been created in @p world.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an out of range body identifier.
/// @post On success: the destroyed body's identifier is no longer present in the container
///   returned from the <code>GetBodies(const World&)</code> function; the count returned
///   by <code>GetBodyCount(const World&)</code> will be one less than before this was called;
///   <code>GetBodyRange(const World&)</code> will be unchanged.
/// @see CreateBody, GetBodies, GetBodyCount, GetBodyRange, SetDetachListener, IsLocked.
/// @see PhysicalEntities.
void Destroy(World& world, BodyID id);

/// @brief Gets whether the given identifier is to a body that's been destroyed.
/// @note Complexity of this function is O(1).
/// @see Destroy(World& world, BodyID).
inline auto IsDestroyed(const World& world, BodyID id) -> bool
{
    return IsDestroyed(GetBody(world, id));
}

/// @brief Gets the container of valid joints attached to the identified body.
/// @throws std::out_of_range If given an out of range body identifier.
/// @see CreateJoint, GetBodyRange.
std::vector<std::pair<BodyID, JointID>> GetJoints(const World& world, BodyID id);

/// @brief Gets the container of contacts attached to the identified body.
/// @warning This collection changes during the time step and you may
///   miss some collisions if you don't use <code>ContactFunction</code>.
/// @throws std::out_of_range If given an out of range body identifier.
/// @see GetBodyRange.
std::vector<std::tuple<ContactKey, ContactID>> GetContacts(const World& world, BodyID id);

/// @brief Gets the identities of the shapes associated with the identified body.
/// @throws std::out_of_range If given an out of range body identifier.
/// @see GetBodyRange, CreateBody, SetBody.
std::vector<ShapeID> GetShapes(const World& world, BodyID id);

/// @brief Sets the accelerations of all the world's bodies.
/// @param world World instance to set the acceleration of all contained bodies for.
/// @param fn Function or functor with a signature like:
///   <code>Acceleration (*fn)(World&,BodyID)</code>.
/// @throws WrongState if this function is called while the world is locked.
/// @post On success: <code>GetAcceleration(const World&, BodyID)</code> will return
///   the acceleration assigned to it by the given function.
/// @see SetAcceleration(World&,BodyID,const Acceleration&),
///   GetAcceleration(const World&,BodyID).
/// @relatedalso World
template <class F>
void SetAccelerations(World& world, F fn)
{
    const auto bodies = GetBodies(world);
    std::for_each(begin(bodies), end(bodies), [&](const auto &b) {
        SetAcceleration(world, b, fn(world, b));
    });
}

/// @brief Gets the extent of the currently valid joint range.
/// @note This is one higher than the maxium <code>JointID</code> that is in range
///   for joint related functions.
JointCounter GetJointRange(const World& world) noexcept;

/// @brief Gets the joints of the specified world.
/// @note These are joints created by previous calls to
///   <code>CreateJoint(World&, const Joint&)</code> that haven't yet been
///   destroyed by a call to <code>Destroy(World& world, JointID)</code> or
///   <code>Clear(World&)</code>.
/// @see CreateJoint(World&, const Joint&), Destroy(World& world, JointID), Clear(World&).
std::vector<JointID> GetJoints(const World& world);

/// Gets the count of joints in the given world.
/// @return 0 or higher.
/// @relatedalso World
inline JointCounter GetJointCount(const World& world)
{
    using std::size;
    return static_cast<JointCounter>(size(GetJoints(world)));
}

/// @brief Creates a new joint within the given world.
/// @param world The world in which the specified joint is to be created within.
/// @param def State of the joint to create within the world.
/// @throws WrongState if this function is called while the world is locked.
/// @post On success: <code>GetJoints(const World&)</code> for this same world will contain
///   the identifier returned by this function; <code>GetJoint(const World&, JointID)</code>
///   for @p world and the returned identifier, returns @p def .
JointID CreateJoint(World& world, const Joint& def);

/// @brief Creates a new joint from a configuration.
/// @details This is a convenience function for allowing limited implicit conversions to joints.
/// @throws WrongState if this function is called while the world is locked.
/// @relatedalso World
template <typename T>
JointID CreateJoint(World& world, const T& value)
{
    return CreateJoint(world, Joint{value});
}

/// @brief Destroys the identified joint.
/// @param world The world in which the specified joint is to be destroyed from.
/// @param id Identifier of the joint to destroy.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an out of range joint identifier.
/// @post On success: the given identifier is no longer within those returned by
///   <code>GetJoints(const World&)</code>, the count returned by
///   <code>GetJointCount(const World&)</code> will be one less than before this was called.
/// @see CreateJoint, IsLocked, GetJointRange.
void Destroy(World& world, JointID id);

/// @brief Gets the value of the identified joint.
/// @throws std::out_of_range If given an out of range joint identifier.
/// @see GetJointRange.
Joint GetJoint(const World& world, JointID id);

/// @brief Sets the value of the identified joint.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an out of range joint identifier.
/// @see GetJointRange.
void SetJoint(World& world, JointID id, const Joint& def);

/// @brief Sets a joint's value from a configuration.
/// @details This is a convenience function for allowing limited implicit conversions to joints.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an out of range joint identifier.
/// @see GetJointRange.
/// @relatedalso World
template <typename T>
void SetJoint(World& world, JointID id, const T& value)
{
    return SetJoint(world, id, Joint{value});
}

/// @brief Gets whether the given identifier is to a joint that's been destroyed.
/// @note Complexity of this function is O(1).
inline auto IsDestroyed(const World& world, JointID id) -> bool
{
    return IsDestroyed(GetJoint(world, id));
}

/// @brief Gets the extent of the currently valid shape range.
/// @note This is one higher than the maxium <code>ShapeID</code> that is in range
///   for shape related functions.
ShapeCounter GetShapeRange(const World& world) noexcept;

/// @brief Creates an identifiable copy of the given shape within the specified world.
/// @throws InvalidArgument if called for a shape with a vertex radius that's not within
///   the world's allowable vertex radius interval.
/// @throws WrongState if this function is called while the world is locked.
/// @throws LengthError if this operation would create more than <code>MaxShapes</code>.
/// @see Destroy(World&, ShapeID), GetShape, SetShape, GetVertexRadiusInterval.
ShapeID CreateShape(World& world, const Shape& def);

/// @brief Creates a shape within the specified world using a configuration of the shape.
/// @details This is a convenience function for allowing limited implicit conversions to shapes.
/// @throws InvalidArgument if called for a shape with a vertex radius that's not within
///   the world's allowable vertex radius interval.
/// @throws WrongState if called while the world is "locked".
/// @see CreateShape(World& world, const Shape& def), GetVertexRadiusInterval.
/// @relatedalso World
template <typename T>
auto CreateShape(World& world, const T& shapeConf) ->
    decltype(CreateShape(world, Shape{shapeConf}))
{
    return CreateShape(world, Shape{shapeConf});
}

/// @brief Destroys the identified shape.
/// @param world The world in which the specified shape is to be destroyed from.
/// @param id Identifier of the shape to destroy.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an out of range identifier.
/// @post On success: no body in the specified world will have the identified shape attached
///   to it; <code>GetShapeRange(const World&)</code> will be unchanged.
/// @see CreateShape, IsLocked, GetShapeRange.
void Destroy(World& world, ShapeID id);

/// @brief Gets the shape associated with the identifier.
/// @throws std::out_of_range If given an out of range identifier.
/// @see GetShapeRange.
Shape GetShape(const World& world, ShapeID id);

/// @brief Sets the identified shape to the new value.
/// @throws std::out_of_range If given an out of range shape identifier.
/// @see CreateShape, GetShapeRange.
void SetShape(World& world, ShapeID, const Shape& def);

/// @brief Gets whether the given identifier is to a shape that's been destroyed.
/// @note Complexity of this function is O(1).
inline auto IsDestroyed(const World& world, ShapeID id) -> bool
{
    return IsDestroyed(GetShape(world, id));
}

/// @brief Gets the extent of the currently valid contact range.
/// @note This is one higher than the maxium <code>ContactID</code> that is in range
///   for contact related functions.
ContactCounter GetContactRange(const World& world) noexcept;

/// @brief Gets the contacts identified within the given world.
/// @note Further information for each element of the returned container
///   is available from functions like @c GetContact or @c GetManifold.
std::vector<KeyedContactID> GetContacts(const World& world);

/// @brief Gets the identified contact.
/// @throws std::out_of_range If given an out of range contact identifier.
/// @see GetContantRange.
Contact GetContact(const World& world, ContactID id);

/// @brief Sets the identified contact's state.
/// @param world The world of the contact whose state is to be set.
/// @param id Identifier of the contact whose state is to be set.
/// @param value Value the contact is to be set to. The new state:
///   is not allowed to change whether the contact is awake,
///   is not allowed to change whether the contact is impenetrable,
///   is not allowed to change whether the contact is for a sensor,
///   is not allowed to change the TOI of the contact,
///   is not allowed to change the TOI count of the contact. Otherwise, this function
///   will throw an <code>InvalidArgument</code> exception and not change anything.
/// @throws std::out_of_range If given an out of range contact identifier or the new
///   contact value references an out of range identifier.
/// @throws InvalidArgument if the identifier is to a freed contact or if the new state is
///   not allowable.
/// @see GetContact, GetContactRange.
void SetContact(World& world, ContactID id, const Contact& value);

/// @brief Gets the manifold for the identified contact.
/// @note There is a manifold for every contact and vice-versa.
/// @throws std::out_of_range If given an out of range contact identifier.
/// @see SetManifold, GetContantRange.
Manifold GetManifold(const World& world, ContactID id);

/// @brief Sets the identified manifold's state.
/// @note There is a manifold for every contact and vice-versa.
/// @param world The world of the manifold whose state is to be set.
/// @param id Identifier of the manifold whose state is to be set.
/// @param value Value the manifold is to be set to. The new state:
///   TODO: is not allowed to change whether the contact is awake,
///   TODO: is not allowed to change whether the contact is impenetrable.
///   Otherwise, throws <code>InvalidArgument</code> exception and doesn't change anything.
/// @throws std::out_of_range If given an out of range contact identifier or the new
///   manifold value references an out of range identifier.
/// @throws InvalidArgument if the identifier is to a freed contact or if the new state is
///   not allowable.
/// @see GetManifold, GetContactRange.
void SetManifold(World& world, ContactID id, const Manifold& value);

/// @brief Gets the count of contacts in the given world.
/// @note Not all contacts are for shapes that are actually touching. Some contacts are for
///   shapes which merely have overlapping AABBs.
/// @return 0 or higher.
/// @relatedalso World
inline ContactCounter GetContactCount(const World& world) noexcept
{
    using std::size;
    return static_cast<ContactCounter>(size(GetContacts(world)));
}

/// @brief Gets whether the given identifier is to a contact that's been destroyed.
/// @note Complexity of this function is O(1).
inline auto IsDestroyed(const World& world, ContactID id) -> bool
{
    return IsDestroyed(GetContact(world, id));
}

/// @defgroup PhysicalEntities Physical Entities
///
/// @brief Concepts and types associated with physical entities within a world.
///
/// @details Concepts and types of creatable and destroyable instances that associate
///   physical properties to simulations. These instances are typically created via a
///   function whose name begins with the prefix of <code>Create</code>. Similarly, these
///   instances are typically destroyed using a <code>Destroy</code> function.
///
/// @note For example, the following could be used to create a dynamic body having a one meter
///   radius disk shape:
/// @code{.cpp}
/// auto world = World{};
/// const auto shape = CreateShape(world, Shape{DiskShapeConf{1_m}});
/// const auto body = CreateBody(world, BodyConf{}.Use(BodyType::Dynamic).Use(shape));
/// @endcode
///
/// @see World.
/// @see BodyID, CreateBody, Destroy(World&, BodyID), GetBodies.
/// @see ShapeID, CreateShape, Destroy(World&, ShapeID).
/// @see JointID, CreateJoint, Destroy(World&, JointID), GetJoints(const World&).
/// @see ContactID, GetContacts(const World&).
/// @see BodyType, Shape, DiskShapeConf.

/// @brief Definition of an independent and simulatable "world".
///
/// @details The world class manages physics entities, dynamic simulation, and queries.
///   In a physical sense, perhaps this is more like a universe in that entities in a
///   world have no interaction with entities in other worlds. In any case, there's
///   precedence, from a physics-engine standpoint, for this being called a world.
///
/// @note World instances do not themselves have any force or acceleration properties.
///  They simply utilize the acceleration property of the bodies they manage. This is
///  different than some other engines (like <code>Box2D</code> which provides a world
///  gravity property).
/// @note World instances are composed of &mdash; i.e. contain and own &mdash; body, contact,
///   shape, and joint entities. These are identified by <code>BodyID</code>,
///   <code>ContactID</code>, <code>ShapeID</code>, and <code>JointID</code> values respectively.
/// @note This class uses the pointer to implementation (PIMPL) technique and non-vitural
///   interface (NVI) pattern to provide a complete layer of abstraction from the actual
///   implementations used. This forms a "compilation firewall" &mdash; or application
///   binary interface (ABI) &mdash; to help provide binary stability while facilitating
///   experimentation and optimization.
/// @note This class's design provides a "polymorphic value type" offering polymorphism
///   without public inheritance. This is based on a technique that's described by Sean Parent
///   in his January 2017 Norwegian Developers Conference London talk "Better Code: Runtime
///   Polymorphism".
///
/// @invariant <code>GetType(const World& world)</code> for a world in a valid and specified
///   state, always returns the ID for the type which a @c TypeCast function template can be
///   instantiated for when called with the @c world object, to access the underlying typed
///   data of that world.
///
/// @attention For example, the following could be used to create a dynamic body having a one
///   meter radius disk shape:
/// @code{.cpp}
/// auto world = World{};
/// const auto shape = CreateShape(world, Shape{DiskShapeConf{1_m}});
/// const auto body = CreateBody(world, BodyConf{}.Use(BodyType::Dynamic).Use(shape));
/// @endcode
///
/// @see BodyID, ContactID, ShapeID, JointID, PhysicalEntities.
/// @see https://en.wikipedia.org/wiki/Non-virtual_interface_pattern
/// @see https://en.wikipedia.org/wiki/Application_binary_interface
/// @see https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Polymorphic_Value_Types
/// @see https://en.cppreference.com/w/cpp/language/pimpl
/// @see https://youtu.be/QGcVXgEVMJg
///
class World
{
public:
    /// @brief Constructs a world object.
    /// @details Constructs a world object using the default world implementation class
    ///   that's instantiated with the given configuraion.
    /// @note More configurability can be had via the <code>StepConf</code>
    ///   data given to the <code>Step(World&, const StepConf&)</code> function.
    /// @param def A customized world configuration or its default value.
    /// @post <code>GetType(const World&)</code> for the created object returns the value
    ///   returned by <code>GetTypeID<AabbTreeWorld>()</code>.
    /// @post <code>GetBodyCount(const World&)</code>, <code>GetJointCount(const World&)</code>,
    ///   <code>GetContactCount(const World&)</code> for the created object all return 0.
    /// @post <code>GetBodies(const World&)</code>, <code>GetJoints(const World&)</code>,
    ///   <code>GetContacts(const World&)</code> for the created object all return empty
    ///   containers.
    /// @post <code>IsLocked(const World&)</code>, <code>GetSubStepping(const World&)</code>
    ///   all return false.
    /// @see Step(World&, const StepConf&).
    explicit World(const WorldConf& def = WorldConf{});

    /// @brief Copy constructs this world with a deep copy of the given world.
    /// @param other The world to copy construct this one from.
    /// @throws std::bad_alloc if memory cannot be allocated.
    /// @post The state of the created object is equal to the state of the copied from object.
    /// @see operator==(const World&, const World&).
    World(const World& other);

    /// @brief Move constructs this world.
    /// @param other The world to move construct this one from.
    /// @post <code>this</code> is what <code>other</code> used to be.
    /// @post <code>other</code> is in a "valid but unspecified state". The only thing it
    ///   can be used for, is as the destination of an assignment.
    World(World&& other) noexcept: m_impl{std::move(other.m_impl)}
    {
        // Intentionally empty.
    }

    /// @brief Polymorphic initializing constructor.
    /// @details Constructor for constructing an instance from any class supporting the @c World
    ///   functionality.
    /// @param arg A value of a world-concept supporting type to construct this object from.
    /// @throws std::bad_alloc if there's a failure allocating storage for the given value.
    /// @post <code>GetType(const World&)</code> for the created object returns the value
    ///   returned by <code>GetTypeID<std::decay_t<T>>()</code>.
    template <typename T, typename DT = std::decay_t<T>,
    typename Tp = std::enable_if_t<!std::is_same_v<DT, World> && !std::is_same_v<DT, WorldConf>, DT>,
    typename = std::enable_if_t<std::is_constructible_v<DT, T>>>
    explicit World(T&& arg) : m_impl{std::make_unique<detail::WorldModel<Tp>>(std::forward<T>(arg))}
    {
        // Intentionally empty.
    }

    /// @brief Destroys all contained physics entities and releases all related resources.
    /// @note This calls the <code>Clear(World&)</code> function.
    /// @see Clear.
    ~World() noexcept;

    /// @brief Copy assigns this world with a deep copy of the given world.
    /// @note Provides the strong exception guarantee. If this operation throws an exception,
    ///   the state of this object is unchanged.
    /// @param other The other world to copy assign from.
    /// @throws std::bad_alloc if memory cannot be allocated.
    /// @post On success: the state of the assigned-to object is equal to the state of the
    ///   copied from object.
    /// @see operator==(const World&, const World&).
    World& operator=(const World& other);

    /// @brief Move assigns this world.
    /// @param other The other world to move assign from.
    /// @post <code>this</code> is what @p other used to be.
    /// @post @p other is in a "valid but unspecified state". The only thing it
    ///   can be used for, is as the destination of an assignment.
    World& operator=(World&& other) noexcept
    {
        m_impl = std::move(other.m_impl);
        return *this;
    }

    // Listener friend functions...
    friend void SetShapeDestructionListener(World& world, ShapeFunction listener) noexcept;
    friend void SetDetachListener(World& world, BodyShapeFunction listener) noexcept;
    friend void SetJointDestructionListener(World& world, JointFunction listener) noexcept;
    friend void SetBeginContactListener(World& world, ContactFunction listener) noexcept;
    friend void SetEndContactListener(World& world, ContactFunction listener) noexcept;
    friend void SetPreSolveContactListener(World& world, ContactManifoldFunction listener) noexcept;
    friend void SetPostSolveContactListener(World& world, ContactImpulsesFunction listener) noexcept;

    // Miscellaneous friend functions...
    friend TypeID GetType(const World& world) noexcept;
    template <typename T>
    friend std::add_pointer_t<std::add_const_t<T>> TypeCast(const World* value) noexcept;
    template <typename T>
    friend std::add_pointer_t<T> TypeCast(World* value) noexcept;
    friend bool operator==(const World& lhs, const World& rhs) noexcept;
    friend bool operator!=(const World& lhs, const World& rhs) noexcept;

    friend std::optional<pmr::StatsResource::Stats> GetResourceStats(const World& world) noexcept;
    friend void Clear(World& world) noexcept;
    friend StepStats Step(World& world, const StepConf& conf);
    friend bool IsStepComplete(const World& world) noexcept;
    friend bool GetSubStepping(const World& world) noexcept;
    friend void SetSubStepping(World& world, bool flag) noexcept;
    friend const DynamicTree& GetTree(const World& world);
    friend bool IsLocked(const World& world) noexcept;
    friend void ShiftOrigin(World& world, const Length2& newOrigin);
    friend Interval<Positive<Length>> GetVertexRadiusInterval(const World& world) noexcept;
    friend Frequency GetInvDeltaTime(const World& world) noexcept;

    // Body friend functions...
    friend BodyCounter GetBodyRange(const World& world) noexcept;
    friend std::vector<BodyID> GetBodies(const World& world);
    friend std::vector<BodyID> GetBodiesForProxies(const World& world);
    friend BodyID CreateBody(World& world, const Body& body, bool resetMassData);
    friend Body GetBody(const World& world, BodyID id);
    friend void SetBody(World& world, BodyID id, const Body& body);
    friend void Destroy(World& world, BodyID id);
    friend std::vector<std::pair<BodyID, JointID>> GetJoints(const World& world, BodyID id);
    friend std::vector<std::tuple<ContactKey, ContactID>> GetContacts(const World& world, BodyID id);
    friend std::vector<ShapeID> GetShapes(const World& world, BodyID id);

    // Joint friend functions...
    friend JointCounter GetJointRange(const World& world) noexcept;
    friend std::vector<JointID> GetJoints(const World& world);
    friend JointID CreateJoint(World& world, const Joint& def);
    friend void Destroy(World& world, JointID id);
    friend Joint GetJoint(const World& world, JointID id);
    friend void SetJoint(World& world, JointID id, const Joint& def);

    // Shape friend functions...
    friend ShapeCounter GetShapeRange(const World& world) noexcept;
    friend ShapeID CreateShape(World& world, const Shape& def);
    friend void Destroy(World& world, ShapeID id);
    friend Shape GetShape(const World& world, ShapeID id);
    friend void SetShape(World& world, ShapeID, const Shape& def);

    // Contact friend functions...
    friend ContactCounter GetContactRange(const World& world) noexcept;
    friend std::vector<KeyedContactID> GetContacts(const World& world);
    friend Contact GetContact(const World& world, ContactID id);
    friend void SetContact(World& world, ContactID id, const Contact& value);
    friend Manifold GetManifold(const World& world, ContactID id);
    friend void SetManifold(World& world, ContactID id, const Manifold& value);

private:
    /// @brief Pointer to implementation (PIMPL)
    /// @see https://en.cppreference.com/w/cpp/language/pimpl
    std::unique_ptr<detail::WorldConcept> m_impl;
};

// State & confirm intended compile-time traits of World class...
static_assert(!std::is_polymorphic_v<World>);
static_assert(std::is_default_constructible_v<World>);
static_assert(std::is_copy_constructible_v<World>);
static_assert(std::is_copy_assignable_v<World>);
static_assert(std::is_nothrow_move_constructible_v<World>);
static_assert(std::is_nothrow_move_assignable_v<World>);

// World Listener Non-Member Functions...

inline void SetShapeDestructionListener(World& world, ShapeFunction listener) noexcept
{
    world.m_impl->SetShapeDestructionListener_(std::move(listener));
}

inline void SetDetachListener(World& world, BodyShapeFunction listener) noexcept
{
    world.m_impl->SetDetachListener_(std::move(listener));
}

inline void SetJointDestructionListener(World& world, JointFunction listener) noexcept
{
    world.m_impl->SetJointDestructionListener_(std::move(listener));
}

inline void SetBeginContactListener(World& world, ContactFunction listener) noexcept
{
    world.m_impl->SetBeginContactListener_(std::move(listener));
}

inline void SetEndContactListener(World& world, ContactFunction listener) noexcept
{
    world.m_impl->SetEndContactListener_(std::move(listener));
}

inline void SetPreSolveContactListener(World& world, ContactManifoldFunction listener) noexcept
{
    world.m_impl->SetPreSolveContactListener_(std::move(listener));
}

inline void SetPostSolveContactListener(World& world, ContactImpulsesFunction listener) noexcept
{
    world.m_impl->SetPostSolveContactListener_(std::move(listener));
}

// World Miscellaneous Non-Member Functions...

inline TypeID GetType(const World& world) noexcept
{
    return world.m_impl->GetType_();
}

inline bool operator==(const World& lhs, const World& rhs) noexcept
{
    return (lhs.m_impl == rhs.m_impl) ||
           ((lhs.m_impl && rhs.m_impl) && (lhs.m_impl->IsEqual_(*rhs.m_impl)));
}

inline bool operator!=(const World& lhs, const World& rhs) noexcept
{
    return !(lhs == rhs);
}

inline std::optional<pmr::StatsResource::Stats> GetResourceStats(const World& world) noexcept
{
    return world.m_impl->GetResourceStats_();
}

inline void Clear(World& world) noexcept
{
    world.m_impl->Clear_();
}

inline StepStats Step(World& world, const StepConf& conf)
{
    return world.m_impl->Step_(conf);
}

inline bool IsStepComplete(const World& world) noexcept
{
    return world.m_impl->IsStepComplete_();
}

inline bool GetSubStepping(const World& world) noexcept
{
    return world.m_impl->GetSubStepping_();
}

inline void SetSubStepping(World& world, bool flag) noexcept
{
    world.m_impl->SetSubStepping_(flag);
}

inline const DynamicTree& GetTree(const World& world)
{
    return world.m_impl->GetTree_();
}

inline bool IsLocked(const World& world) noexcept
{
    return world.m_impl->IsLocked_();
}

inline void ShiftOrigin(World& world, const Length2& newOrigin)
{
    world.m_impl->ShiftOrigin_(newOrigin);
}

inline Interval<Positive<Length>> GetVertexRadiusInterval(const World& world) noexcept
{
    return world.m_impl->GetVertexRadiusInterval_();
}

inline Frequency GetInvDeltaTime(const World& world) noexcept
{
    return world.m_impl->GetInvDeltaTime_();
}

// World Body non-member functions...

inline BodyCounter GetBodyRange(const World& world) noexcept
{
    return world.m_impl->GetBodyRange_();
}

inline std::vector<BodyID> GetBodies(const World& world)
{
    return world.m_impl->GetBodies_();
}

inline std::vector<BodyID> GetBodiesForProxies(const World& world)
{
    return world.m_impl->GetBodiesForProxies_();
}

inline Body GetBody(const World& world, BodyID id)
{
    return world.m_impl->GetBody_(id);
}

inline void SetBody(World& world, BodyID id, const Body& body)
{
    world.m_impl->SetBody_(id, body);
}

inline void Destroy(World& world, BodyID id)
{
    world.m_impl->Destroy_(id);
}

inline std::vector<std::pair<BodyID, JointID>> GetJoints(const World& world, BodyID id)
{
    return world.m_impl->GetJoints_(id);
}

inline std::vector<std::tuple<ContactKey, ContactID>> GetContacts(const World& world, BodyID id)
{
    return world.m_impl->GetContacts_(id);
}

inline std::vector<ShapeID> GetShapes(const World& world, BodyID id)
{
    return world.m_impl->GetShapes_(id);
}

// World Joint non-member functions...

inline JointCounter GetJointRange(const World& world) noexcept
{
    return world.m_impl->GetJointRange_();
}

inline std::vector<JointID> GetJoints(const World& world)
{
    return world.m_impl->GetJoints_();
}

inline JointID CreateJoint(World& world, const Joint& def)
{
    return world.m_impl->CreateJoint_(def);
}

inline void Destroy(World& world, JointID id)
{
    world.m_impl->Destroy_(id);
}

inline Joint GetJoint(const World& world, JointID id)
{
    return world.m_impl->GetJoint_(id);
}

inline void SetJoint(World& world, JointID id, const Joint& def)
{
    world.m_impl->SetJoint_(id, def);
}

// World Shape Non-Member Functions

inline ShapeCounter GetShapeRange(const World& world) noexcept
{
    return world.m_impl->GetShapeRange_();
}

inline ShapeID CreateShape(World& world, const Shape& def)
{
    return world.m_impl->CreateShape_(def);
}

inline void Destroy(World& world, ShapeID id)
{
    world.m_impl->Destroy_(id);
}

inline Shape GetShape(const World& world, ShapeID id)
{
    return world.m_impl->GetShape_(id);
}

inline void SetShape(World& world, ShapeID id, const Shape& def)
{
    world.m_impl->SetShape_(id, def);
}

// Contact non-member functions...

inline ContactCounter GetContactRange(const World& world) noexcept
{
    return world.m_impl->GetContactRange_();
}

inline std::vector<KeyedContactID> GetContacts(const World& world)
{
    return world.m_impl->GetContacts_();
}

inline Contact GetContact(const World& world, ContactID id)
{
    return world.m_impl->GetContact_(id);
}

inline void SetContact(World& world, ContactID id, const Contact& value)
{
    world.m_impl->SetContact_(id, value);
}

inline Manifold GetManifold(const World& world, ContactID id)
{
    return world.m_impl->GetManifold_(id);
}

inline void SetManifold(World& world, ContactID id, const Manifold& value)
{
    world.m_impl->SetManifold_(id, value);
}

// Free functions...

/// @brief Converts the given joint into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @throws std::bad_cast If the given template parameter type isn't the type of this
///   joint's configuration value.
/// @see https://llvm.org/
/// @relatedalso World
template <typename T>
inline T TypeCast(const World& value)
{
    using RawType = std::remove_cv_t<std::remove_reference_t<T>>;
    static_assert(std::is_constructible_v<T, RawType const&>,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<std::add_const_t<RawType>>(&value);
    if (!tmp) {
        throw std::bad_cast();
    }
    return static_cast<T>(*tmp);
}

/// @brief Converts the given joint into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @see https://llvm.org/
/// @relatedalso World
template <typename T>
inline T TypeCast(World& value)
{
    using RawType = std::remove_cv_t<std::remove_reference_t<T>>;
    static_assert(std::is_constructible_v<T, RawType&>,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<RawType>(&value);
    if (!tmp) {
        throw std::bad_cast();
    }
    return static_cast<T>(*tmp);
}

/// @brief Converts the given joint into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @see https://llvm.org/
/// @relatedalso World
template <typename T>
inline T TypeCast(World&& value)
{
    using RawType = std::remove_cv_t<std::remove_reference_t<T>>;
    static_assert(std::is_constructible_v<T, RawType>,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<RawType>(&value);
    if (!tmp) {
        throw std::bad_cast();
    }
    return static_cast<T>(std::move(*tmp));
}

template <typename T>
inline std::add_pointer_t<std::add_const_t<T>> TypeCast(const World* value) noexcept
{
    static_assert(!std::is_reference_v<T>, "T may not be a reference.");
    using ReturnType = std::add_pointer_t<T>;
    if (value && value->m_impl && (GetType(*value) == GetTypeID<T>())) {
        return static_cast<ReturnType>(value->m_impl->GetData_());
    }
    return nullptr;
}

template <typename T>
inline std::add_pointer_t<T> TypeCast(World* value) noexcept
{
    static_assert(!std::is_reference_v<T>, "T may not be a reference.");
    using ReturnType = std::add_pointer_t<T>;
    if (value && value->m_impl && (GetType(*value) == GetTypeID<T>())) {
        return static_cast<ReturnType>(value->m_impl->GetData_());
    }
    return nullptr;
}

/// @example HelloWorld.cpp
/// This is the source file for the <code>HelloWorld</code> application that demonstrates
/// use of the <code>playrho::d2::World</code> class and more.

/// @example World.cpp
/// This is the <code>googletest</code> based unit testing file for the
/// <code>playrho::d2::World</code> class.

} // namespace playrho::d2

#endif // PLAYRHO_D2_WORLD_HPP

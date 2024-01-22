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

#ifndef PLAYRHO_D2_AABBTREEWORLD_HPP
#define PLAYRHO_D2_AABBTREEWORLD_HPP

/// @file
/// @brief Declarations of the AabbTreeWorld class.

#include <cstdint> // for std::uint32_t
#include <map>
#include <optional>
#include <tuple>
#include <type_traits> // for std::is_default_constructible_v, etc.
#include <utility> // for std::pair, std::move
#include <vector>

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/BodyShapeFunction.hpp"
#include "playrho/Contact.hpp"
#include "playrho/Contactable.hpp"
#include "playrho/ContactFunction.hpp"
#include "playrho/ContactID.hpp"
#include "playrho/ContactKey.hpp"
#include "playrho/JointFunction.hpp"
#include "playrho/JointID.hpp"
#include "playrho/Interval.hpp"
#include "playrho/Island.hpp"
#include "playrho/IslandStats.hpp"
#include "playrho/KeyedContactID.hpp"
#include "playrho/ObjectPool.hpp"
#include "playrho/Positive.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/ShapeFunction.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/Span.hpp"
#include "playrho/StepStats.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"
#include "playrho/ZeroToUnderOne.hpp"

#include "playrho/pmr/MemoryResource.hpp"
#include "playrho/pmr/PoolMemoryResource.hpp"
#include "playrho/pmr/StatsResource.hpp"

#include "playrho/d2/Body.hpp"
#include "playrho/d2/BodyConstraint.hpp"
#include "playrho/d2/ContactImpulsesFunction.hpp"
#include "playrho/d2/ContactManifoldFunction.hpp"
#include "playrho/d2/DynamicTree.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/Shape.hpp"
#include "playrho/d2/Transformation.hpp"
#include "playrho/d2/WorldConf.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct StepConf;
enum class BodyType;

} // namespace playrho

namespace playrho::d2 {

class Manifold;
class ContactImpulsesList;
class AabbTreeWorld;

/// @brief Body IDs container type.
using BodyIDs = std::vector<BodyID>;

/// @brief Keyed contact IDs container type.
using KeyedContactIDs = std::vector<KeyedContactID>;

/// @brief Joint IDs container type.
/// @note Cannot be container of Joint instances since joints are polymorphic types.
using JointIDs = std::vector<JointID>;

/// @brief Container type for Body associated contact information.
using BodyContactIDs = std::vector<std::tuple<ContactKey, ContactID>>;

/// @brief Body joint IDs container type.
using BodyJointIDs = std::vector<std::pair<BodyID, JointID>>;

/// @brief Body shape IDs container type.
using BodyShapeIDs = std::vector<std::pair<BodyID, ShapeID>>;

/// @brief Proxy container type alias.
using ProxyIDs = std::vector<DynamicTree::Size>;

/// @name AabbTreeWorld Listener Non-Member Functions
/// @{

/// @brief Registers a destruction listener for shapes.
/// @note This listener is called on <code>Clear(AabbTreeWorld&)</code> for every shape.
/// @see Clear(AabbTreeWorld&).
void SetShapeDestructionListener(AabbTreeWorld& world, ShapeFunction listener) noexcept;

/// @brief Registers a detach listener for shapes detaching from bodies.
void SetDetachListener(AabbTreeWorld& world, BodyShapeFunction listener) noexcept;

/// @brief Register a destruction listener for joints.
/// @note This listener is called on <code>Clear()</code> for every joint. It's also called
///   on <code>Destroy(BodyID)</code> for every joint associated with the identified body.
/// @see Clear, Destroy(BodyID).
void SetJointDestructionListener(AabbTreeWorld& world, JointFunction listener) noexcept;

/// @brief Register a begin contact event listener.
void SetBeginContactListener(AabbTreeWorld& world, ContactFunction listener) noexcept;

/// @brief Register an end contact event listener.
void SetEndContactListener(AabbTreeWorld& world, ContactFunction listener) noexcept;

/// @brief Register a pre-solve contact event listener.
void SetPreSolveContactListener(AabbTreeWorld& world, ContactManifoldFunction listener) noexcept;

/// @brief Register a post-solve contact event listener.
void SetPostSolveContactListener(AabbTreeWorld& world, ContactImpulsesFunction listener) noexcept;

/// @}

/// @name AabbTreeWorld Miscellaneous Non-Member Functions
/// @{

/// @brief Equality operator for world comparisons.
bool operator==(const AabbTreeWorld& lhs, const AabbTreeWorld& rhs);

/// @brief Inequality operator for world comparisons.
bool operator!=(const AabbTreeWorld& lhs, const AabbTreeWorld& rhs);

/// @brief Gets the resource statistics of the specified world.
std::optional<pmr::StatsResource::Stats> GetResourceStats(const AabbTreeWorld& world) noexcept;

/// @brief Clears this world.
/// @note This calls the joint and shape destruction listeners (if they're set), for all
///   defined joints and shapes, before clearing anything. Any exceptions thrown from these
///   listeners are ignored.
/// @post The contents of this world have all been destroyed and this world's internal
///   state reset as though it had just been constructed.
/// @see SetJointDestructionListener, SetShapeDestructionListener.
void Clear(AabbTreeWorld& world) noexcept;

/// @brief Steps the world simulation according to the given configuration.
///
/// @details
/// Performs position and velocity updating, sleeping of non-moving bodies, updating
/// of the contacts, and notifying the contact listener of begin-contact, end-contact,
/// pre-solve, and post-solve events.
///
/// @warning Varying the step time delta may lead to non-physical behaviors.
///
/// @note Calling this with a zero step time delta results only in fixtures and bodies
///   registered for proxy handling being processed. No physics is performed.
/// @note If the given velocity and position iterations are zero, this function doesn't
///   do velocity or position resolutions respectively of the contacting bodies.
/// @note While body velocities are updated accordingly (per the sum of forces acting on them),
///   body positions (barring any collisions) are updated as if they had moved the entire time
///   step at those resulting velocities. In other words, a body initially at position 0
///   (<code>p0</code>) going velocity 0 (<code>v0</code>) fast with a sum acceleration of
///   <code>a</code>, after time <code>t</code> and barring any collisions, will have a new
///   velocity (<code>v1</code>) of <code>v0 + (a * t)</code> and a new position
///   (<code>p1</code>) of <code>p0 + v1 * t</code>.
///
/// @param world The world that is to be stepped.
/// @param conf Configuration for the simulation step.
///
/// @pre @p conf.linearSlop is significant enough compared to
///   <code>GetVertexRadiusInterval(const AabbTreeWorld& world).GetMax()</code>.
/// @post Static bodies are unmoved.
/// @post Kinetic bodies are moved based on their previous velocities.
/// @post Dynamic bodies are moved based on their previous velocities, gravity, applied
///   forces, applied impulses, masses, damping, and the restitution and friction values
///   of their fixtures when they experience collisions.
/// @post The bodies for proxies queue will be empty.
/// @post The fixtures for proxies queue will be empty.
/// @post No contact in the world needs updating.
///
/// @return Statistics for the step.
///
/// @throws WrongState if this function is called while the world is locked.
///
/// @see GetBodiesForProxies, GetFixturesForProxies.
///
StepStats Step(AabbTreeWorld& world, const StepConf& conf);

/// @brief Whether or not "step" is complete.
/// @details The "step" is completed when there are no more TOI events for the current time step.
/// @return <code>true</code> unless sub-stepping is enabled and the step function returned
///   without finishing all of its sub-steps.
/// @see GetSubStepping, SetSubStepping.
bool IsStepComplete(const AabbTreeWorld& world) noexcept;

/// @brief Gets whether or not sub-stepping is enabled.
/// @see SetSubStepping, IsStepComplete.
bool GetSubStepping(const AabbTreeWorld& world) noexcept;

/// @brief Enables/disables single stepped continuous physics.
/// @note This is not normally used. Enabling sub-stepping is meant for testing.
/// @post The <code>GetSubStepping()</code> function will return the value this function was
///   called with.
/// @see IsStepComplete, GetSubStepping.
void SetSubStepping(AabbTreeWorld& world, bool flag) noexcept;

/// @brief Gets access to the broad-phase dynamic tree information.
const DynamicTree& GetTree(const AabbTreeWorld& world) noexcept;

/// @brief Is the world locked (in the middle of a time step).
bool IsLocked(const AabbTreeWorld& world) noexcept;

/// @brief Shifts the world origin.
/// @note Useful for large worlds.
/// @note The body shift formula is: <code>position -= newOrigin</code>.
/// @post The "origin" of this world's bodies, joints, and the board-phase dynamic tree
///   have been translated per the shift amount and direction.
/// @param world The world whose origin should be shifted.
/// @param newOrigin the new origin with respect to the old origin
/// @throws WrongState if this function is called while the world is locked.
void ShiftOrigin(AabbTreeWorld& world, const Length2& newOrigin);

/// @brief Gets the vertex radius interval allowable for the given world.
/// @see CreateShape(AabbTreeWorld&, const Shape&).
Interval<Positive<Length>> GetVertexRadiusInterval(const AabbTreeWorld& world) noexcept;

/// @brief Gets the inverse delta time.
/// @details Gets the inverse delta time that was set on construction or assignment, and
///   updated on every call to the <code>Step()</code> function having a non-zero delta-time.
/// @see Step.
Frequency GetInvDeltaTime(const AabbTreeWorld& world) noexcept;

/// @brief Gets the dynamic tree leaves queued for finding new contacts.
const ProxyIDs& GetProxies(const AabbTreeWorld& world) noexcept;

/// @brief Gets the fixtures-for-proxies for this world.
/// @details Provides insight on what fixtures have been queued for proxy processing
///   during the next call to the world step function.
/// @see Step.
const BodyShapeIDs& GetFixturesForProxies(const AabbTreeWorld& world) noexcept;

/// @}

/// @name AabbTreeWorld Body Member Functions
/// Member functions relating to bodies.
/// @{

/// @brief Gets the extent of the currently valid body range.
/// @note This is one higher than the maxium <code>BodyID</code> that is in range
///   for body related functions.
BodyCounter GetBodyRange(const AabbTreeWorld& world) noexcept;

/// @brief Gets a container of valid world body identifiers for this constant world.
/// @details Gets a container of identifiers of bodies currently existing within this world.
///   These are the bodies that had been created from previous calls to the
///   <code>CreateBody(const Body&)</code> function that haven't yet been destroyed.
/// @return Container of body identifiers that can be iterated over using begin and
///   end functions or using ranged-based for-loops.
/// @see CreateBody(const Body&).
const BodyIDs& GetBodies(const AabbTreeWorld& world) noexcept;

/// @brief Gets the bodies-for-proxies container for this world.
/// @details Provides insight on what bodies have been queued for proxy processing
///   during the next call to the world step function.
/// @see Step.
const BodyIDs& GetBodiesForProxies(const AabbTreeWorld& world) noexcept;

/// @brief Creates a rigid body that's a copy of the given one.
/// @warning This function should not be used while the world is locked &mdash; as it is
///   during callbacks. If it is, it will throw an exception or abort your program.
/// @note No references to the configuration are retained. Its value is copied.
/// @note This function does not reset the mass data for the body.
/// @post The created body will be present in the container returned from the
///   <code>GetBodies(const AabbTreeWorld&)</code> function.
/// @param world The world within which to create the body.
/// @param body A customized body or its default value.
/// @return Identifier of the newly created body which can later be destroyed by calling
///   the <code>Destroy(BodyID)</code> function.
/// @throws WrongState if this function is called while the world is locked.
/// @throws LengthError if this operation would create more than <code>MaxBodies</code>.
/// @throws std::out_of_range if the given body references any invalid shape identifiers.
/// @see Destroy(BodyID), GetBodies.
/// @see PhysicalEntities.
BodyID CreateBody(AabbTreeWorld& world, Body body = Body{});

/// @brief Gets the identified body.
/// @throws std::out_of_range if given an invalid id.
/// @see SetBody, GetBodyRange.
const Body& GetBody(const AabbTreeWorld& world, BodyID id);

/// @brief Sets the identified body.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range if given an invalid id of if the given body references any
///   invalid shape identifiers.
/// @throws InvalidArgument if the specified ID was destroyed.
/// @see GetBody, GetBodyRange.
void SetBody(AabbTreeWorld& world, BodyID id, Body value);

/// @brief Destroys the identified body.
/// @details Destroys a given body that had previously been created by a call to this
///   world's <code>CreateBody(const Body&)</code> function.
/// @warning This automatically deletes all associated shapes and joints.
/// @note This function is locked during callbacks.
/// @param world The world within which the identified body is to be destroyed.
/// @param id Identifier of body to destroy that had been created by this world.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid body identifier.
/// @post On success: the destroyed body will no longer be present in the container returned
///   from the <code>GetBodies(const AabbTreeWorld&)</code> function; none of the body's
///   fixtures will be present in the fixtures-for-proxies collection;
///   <code>IsDestroyed(const AabbTreeWorld& world, BodyID)</code> for @p world and @p id
///   returns true.
/// @see CreateBody, GetBodies(const AabbTreeWorld&), GetFixturesForProxies,
///   IsDestroyed(const AabbTreeWorld& world, BodyID).
/// @see PhysicalEntities.
void Destroy(AabbTreeWorld& world, BodyID id);

/// @brief Gets whether the given identifier is to a body that's been destroyed.
/// @note Complexity of this function is O(1).
/// @see Destroy(AabbTreeWorld& world, BodyID).
inline auto IsDestroyed(const AabbTreeWorld& world, BodyID id) -> bool
{
    return IsDestroyed(GetBody(world, id));
}

/// @brief Gets the proxies for the identified body.
/// @throws std::out_of_range If given an invalid identifier.
const ProxyIDs& GetProxies(const AabbTreeWorld& world, BodyID id);

/// @brief Gets the contacts associated with the identified body.
/// @throws std::out_of_range if given an invalid id.
const BodyContactIDs& GetContacts(const AabbTreeWorld& world, BodyID id);

/// @throws std::out_of_range if given an invalid id.
const BodyJointIDs& GetJoints(const AabbTreeWorld& world, BodyID id);

/// @}

/// @name AabbTreeWorld Joint Member Functions
/// Member functions relating to joints.
/// @{

/// @brief Gets the extent of the currently valid joint range.
/// @note This is one higher than the maxium <code>JointID</code> that is in range
///   for joint related functions.
JointCounter GetJointRange(const AabbTreeWorld& world) noexcept;

/// @brief Gets the container of joint IDs of the given world.
/// @details Gets a container enumerating the joints currently existing within this world.
///   These are the joints that had been created from previous calls to the
///   <code>CreateJoint(const Joint&)</code> function that haven't yet been destroyed.
/// @return Container of joint IDs of existing joints.
/// @see CreateJoint(const Joint&).
const JointIDs& GetJoints(const AabbTreeWorld& world) noexcept;

/// @brief Creates a joint to constrain one or more bodies.
/// @warning This function is locked during callbacks.
/// @note No references to the configuration are retained. Its value is copied.
/// @post The created joint will be present in the container returned from the
///   <code>GetJoints(const AabbTreeWorld&)</code> function.
/// @return Identifier for the newly created joint which can later be destroyed by calling
///   the <code>Destroy(JointID)</code> function.
/// @throws WrongState if this function is called while the world is locked.
/// @throws LengthError if this operation would create more than <code>MaxJoints</code>.
/// @throws InvalidArgument if the given definition is not allowed.
/// @throws std::out_of_range if the given joint references any invalid body id.
/// @see PhysicalEntities.
/// @see Destroy(JointID), GetJoints.
JointID CreateJoint(AabbTreeWorld& world, Joint def);

/// @brief Gets the identified joint.
/// @throws std::out_of_range if given an invalid ID.
const Joint& GetJoint(const AabbTreeWorld& world, JointID id);

/// @brief Sets the identified joint.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range if given an invalid ID or the given joint references any
///    invalid body ID.
/// @throws InvalidArgument if the specified ID was destroyed.
/// @see CreateJoint(Joint def), Destroy(JointID joint).
void SetJoint(AabbTreeWorld& world, JointID id, Joint def);

/// @brief Destroys a joint.
/// @details Destroys a given joint that had previously been created by a call to this
///   world's <code>CreateJoint(const Joint&)</code> function.
/// @note This function is locked during callbacks.
/// @note This may cause the connected bodies to begin colliding.
/// @param world The world within which the identified joint is to be destroyed.
/// @param id Identifier of joint to destroy that had been created by this world.
/// @post On success: the destroyed joint will no longer be present in the container
///   returned from the <code>GetJoints(const AabbTreeWorld&)</code> function;
///   <code>IsDestroyed(const AabbTreeWorld&,JointID)</code> returns true.
/// @throws WrongState if this function is called while the world is locked.
/// @see CreateJoint, GetJoints, IsDestroyed(const AabbTreeWorld& world, JointID).
/// @see PhysicalEntities.
void Destroy(AabbTreeWorld& world, JointID id);

/// @brief Gets whether the given identifier is to a joint that's been destroyed.
/// @note Complexity is O(1).
/// @see Destroy(AabbTreeWorld& world, JointID).
inline auto IsDestroyed(const AabbTreeWorld& world, JointID id) -> bool
{
    return IsDestroyed(GetJoint(world, id));
}

/// @}

/// @name AabbTreeWorld Shape Member Functions
/// Member functions relating to shapes.
/// @{

/// @brief Gets the extent of the currently valid shape range.
/// @note This is one higher than the maxium <code>ShapeID</code> that is in range
///   for shape related functions.
ShapeCounter GetShapeRange(const AabbTreeWorld& world) noexcept;

/// @brief Creates an identifiable copy of the given shape within this world.
/// @throws InvalidArgument if called for a shape with a vertex radius that's not within
///   the world's allowable vertex radius interval.
/// @throws WrongState if this function is called while the world is locked.
/// @throws LengthError if this operation would create more than <code>MaxShapes</code>.
/// @see Destroy(ShapeID), GetShape, SetShape, GetVertexRadiusInterval(const AabbTreeWorld& world).
ShapeID CreateShape(AabbTreeWorld& world, Shape def);

/// @brief Gets the identified shape.
/// @throws std::out_of_range If given an invalid shape identifier.
/// @see CreateShape.
const Shape& GetShape(const AabbTreeWorld& world, ShapeID id);

/// @brief Sets the value of the identified shape.
/// @warning This function is locked during callbacks.
/// @note This function does not reset the mass data of any effected bodies.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid identifier.
/// @throws InvalidArgument if the specified ID was destroyed.
/// @see CreateShape, Destroy(ShapeID id).
void SetShape(AabbTreeWorld& world, ShapeID id, Shape def);

/// @brief Destroys the identified shape removing any body associations with it first.
/// @note This function is locked during callbacks.
/// @note This function does not reset the mass data of any effected bodies.
/// @param world The world from which the identified shape is to be destroyed.
/// @param id Identifier of the shape to destroy.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid shape identifier.
/// @post On success: <code>IsDestroyed(const AabbTreeWorld& world, ShapeID)</code> for
///   @p world and @p id returns true.
/// @see CreateShape, Detach, IsDestroyed(const AabbTreeWorld& world, ShapeID).
void Destroy(AabbTreeWorld& world, ShapeID id);

/// @brief Gets whether the given identifier is to a shape that's been destroyed.
/// @note Complexity is O(1).
/// @see Destroy(AabbTreeWorld& world, ShapeID).
inline auto IsDestroyed(const AabbTreeWorld& world, ShapeID id) -> bool
{
    return IsDestroyed(GetShape(world, id));
}

/// @}

/// @name AabbTreeWorld Contact Member Functions
/// Member functions relating to contacts.
/// @{

/// @brief Gets the extent of the currently valid contact range.
/// @note This is one higher than the maxium <code>ContactID</code> that is in range
///   for contact related functions.
ContactCounter GetContactRange(const AabbTreeWorld& world) noexcept;

/// @brief Gets a container of valid world contact identifiers.
/// @warning contacts are created and destroyed in the middle of a time step.
/// Use <code>ContactFunction</code> to avoid missing contacts.
/// @return Container of keyed contact IDs of existing contacts.
KeyedContactIDs GetContacts(const AabbTreeWorld& world);

/// @brief Gets the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see SetContact.
const Contact& GetContact(const AabbTreeWorld& world, ContactID id);

/// @brief Sets the identified contact's state.
/// @note The new state:
///   - Is not allowed to change the bodies, shapes, or children identified.
///   - Is not allowed to change whether the contact is awake.
///   - Is not allowed to change whether the contact is impenetrable.
///   - Is not allowed to change whether the contact is for a sensor.
///   - Is not allowed to change the TOI of the contact.
///   - Is not allowed to change the TOI count of the contact.
/// @param world The world of the contact whose state is to be set.
/// @param id Identifier of the contact whose state is to be set.
/// @param value Value the contact is to be set to.
/// @throws std::out_of_range If given an invalid contact identifier or an invalid identifier
///   in the new contact value.
/// @throws InvalidArgument if the identifier is to a freed contact or if the new state is
///   not allowable.
/// @see GetContact, GetContactRange.
void SetContact(AabbTreeWorld& world, ContactID id, Contact value);

/// @brief Gets the identified manifold.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see SetManifold, GetContactRange.
const Manifold& GetManifold(const AabbTreeWorld& world, ContactID id);

/// @brief Sets the identified manifold.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see GetManifold, GetContactRange.
void SetManifold(AabbTreeWorld& world, ContactID id, const Manifold& value);

/// @brief Gets whether the given identifier is to a contact that's been destroyed.
/// @note Complexity of this function is O(1).
inline auto IsDestroyed(const AabbTreeWorld& world, ContactID id) -> bool
{
    return IsDestroyed(GetContact(world, id));
}

/// @}

/// @brief An AABB dynamic-tree based world implementation.
/// @note This is designed to be compatible with the World class interface.
/// @see World
class AabbTreeWorld {
public:
    /// @brief Broad phase generated data for identifying potentially new contacts.
    /// @details Stores the contact-key followed by the key's min contactable then max contactable data.
    using ProxyKey = std::tuple<ContactKey, Contactable, Contactable>;

    struct ContactUpdateConf;

    /// @brief Constructs a world implementation for a world.
    /// @param conf A customized world configuration or its default value.
    /// @note A lot more configurability can be had via the <code>StepConf</code>
    ///   data that's given to the world's <code>Step</code> function.
    /// @see Step.
    /// @post <code>GetResourceStats(const AabbTreeWorld&)</code> for this world returns an empty
    ///   value if <code>conf.doStats</code> is false, a non-empty value otherwise.
    /// @post <code>GetVertexRadiusInterval(const AabbTreeWorld&)</code> for this world returns
    ///   <code>conf.vertexRadius</code>.
    explicit AabbTreeWorld(const WorldConf& conf = WorldConf{});

    /// @brief Copy constructor.
    /// @details Basically copy constructs this world as a deep copy of the given world.
    /// @post <code>GetResourceStats(const AabbTreeWorld&)</code> for this world returns an empty
    ///   value if <code>GetResourceStats(other)</code> returns an empty value, a non-empty value
    ///   that's zero initialized otherwise.
    /// @post <code>GetVertexRadiusInterval(const AabbTreeWorld&)</code> for this world returns
    ///   the same value as <code>GetVertexRadiusInterval(other)</code>.
    AabbTreeWorld(const AabbTreeWorld& other);

    /// @brief Move constructor.
    /// @post <code>GetResourceStats(const AabbTreeWorld&)</code> for this world returns an empty
    ///   value if <code>GetResourceStats(other)</code> returned an empty value, a non-empty value
    ///   that's zero initialized otherwise.
    /// @post <code>GetVertexRadiusInterval(const AabbTreeWorld&)</code> for this world returns
    ///   the value of <code>GetVertexRadiusInterval(other)</code> just before this call.
    AabbTreeWorld(AabbTreeWorld&& other) noexcept;

    /// @brief Destructor.
    /// @details All physics entities are destroyed and all memory is released.
    /// @note This will call the <code>Clear()</code> function.
    /// @see Clear.
    ~AabbTreeWorld() noexcept;

    /// @brief Copy assignment is explicitly deleted.
    /// @note This type is not assignable.
    AabbTreeWorld& operator=(const AabbTreeWorld& other) = delete;

    /// @brief Move assignment is explicitly deleted.
    /// @note This type is not assignable.
    AabbTreeWorld& operator=(AabbTreeWorld&& other) = delete;

    // Listener friend functions...
    friend void SetShapeDestructionListener(AabbTreeWorld& world, ShapeFunction listener) noexcept;
    friend void SetDetachListener(AabbTreeWorld& world, BodyShapeFunction listener) noexcept;
    friend void SetJointDestructionListener(AabbTreeWorld& world, JointFunction listener) noexcept;
    friend void SetBeginContactListener(AabbTreeWorld& world, ContactFunction listener) noexcept;
    friend void SetEndContactListener(AabbTreeWorld& world, ContactFunction listener) noexcept;
    friend void SetPreSolveContactListener(AabbTreeWorld& world, ContactManifoldFunction listener) noexcept;
    friend void SetPostSolveContactListener(AabbTreeWorld& world, ContactImpulsesFunction listener) noexcept;

    // Miscellaneous friend functions...
    friend bool operator==(const AabbTreeWorld& lhs, const AabbTreeWorld& rhs);
    friend bool operator!=(const AabbTreeWorld& lhs, const AabbTreeWorld& rhs);
    friend std::optional<pmr::StatsResource::Stats> GetResourceStats(const AabbTreeWorld& world) noexcept;
    friend void Clear(AabbTreeWorld& world) noexcept;
    friend StepStats Step(AabbTreeWorld& world, const StepConf& conf);
    friend bool IsStepComplete(const AabbTreeWorld& world) noexcept;
    friend bool GetSubStepping(const AabbTreeWorld& world) noexcept;
    friend void SetSubStepping(AabbTreeWorld& world, bool flag) noexcept;
    friend const DynamicTree& GetTree(const AabbTreeWorld& world) noexcept;
    friend bool IsLocked(const AabbTreeWorld& world) noexcept;
    friend void ShiftOrigin(AabbTreeWorld& world, const Length2& newOrigin);
    friend Interval<Positive<Length>> GetVertexRadiusInterval(const AabbTreeWorld& world) noexcept;
    friend Frequency GetInvDeltaTime(const AabbTreeWorld& world) noexcept;
    friend const ProxyIDs& GetProxies(const AabbTreeWorld& world) noexcept;
    friend const BodyShapeIDs& GetFixturesForProxies(const AabbTreeWorld& world) noexcept;

    // Body friend functions...
    friend BodyCounter GetBodyRange(const AabbTreeWorld& world) noexcept;
    friend const BodyIDs& GetBodies(const AabbTreeWorld& world) noexcept;
    friend const BodyIDs& GetBodiesForProxies(const AabbTreeWorld& world) noexcept;
    friend BodyID CreateBody(AabbTreeWorld& world, Body body);
    friend const Body& GetBody(const AabbTreeWorld& world, BodyID id);
    friend void SetBody(AabbTreeWorld& world, BodyID id, Body value);
    friend void Destroy(AabbTreeWorld& world, BodyID id);
    friend const ProxyIDs& GetProxies(const AabbTreeWorld& world, BodyID id);
    friend const BodyContactIDs& GetContacts(const AabbTreeWorld& world, BodyID id);
    friend const BodyJointIDs& GetJoints(const AabbTreeWorld& world, BodyID id);

    // Joint friend functions...
    friend JointCounter GetJointRange(const AabbTreeWorld& world) noexcept;
    friend const JointIDs& GetJoints(const AabbTreeWorld& world) noexcept;
    friend JointID CreateJoint(AabbTreeWorld& world, Joint def);
    friend const Joint& GetJoint(const AabbTreeWorld& world, JointID id);
    friend void SetJoint(AabbTreeWorld& world, JointID id, Joint def);
    friend void Destroy(AabbTreeWorld& world, JointID id);

    // Shape friend functions...
    friend ShapeCounter GetShapeRange(const AabbTreeWorld& world) noexcept;
    friend ShapeID CreateShape(AabbTreeWorld& world, Shape def);
    friend const Shape& GetShape(const AabbTreeWorld& world, ShapeID id);
    friend void SetShape(AabbTreeWorld& world, ShapeID id, Shape def);
    friend void Destroy(AabbTreeWorld& world, ShapeID id);

    // Contact friend functions...
    friend ContactCounter GetContactRange(const AabbTreeWorld& world) noexcept;
    friend KeyedContactIDs GetContacts(const AabbTreeWorld& world);
    friend const Contact& GetContact(const AabbTreeWorld& world, ContactID id);
    friend void SetContact(AabbTreeWorld& world, ContactID id, Contact value);
    friend const Manifold& GetManifold(const AabbTreeWorld& world, ContactID id);
    friend void SetManifold(AabbTreeWorld& world, ContactID id, const Manifold& value);

private:
    /// @brief Flags type data type.
    using FlagsType = std::uint32_t;

    /// @brief Flag enumeration.
    enum Flag: FlagsType
    {
        /// Locked.
        e_locked = 0x0002,

        /// Sub-stepping.
        e_substepping = 0x0020,

        /// Step complete. @details Used for sub-stepping. @see e_substepping.
        e_stepComplete = 0x0040,

        /// Needs contact filtering.
        e_needsContactFiltering = 0x0080,
    };

    /// Bodies, contacts, and joints that are already in an <code>Island</code> by their ID.
    /// @see Step.
    struct Islanded
    {
        /// @brief Type alias for member variables.
        using vector = std::vector<bool>;

        vector bodies; ///< IDs of bodies that have been "islanded".
        vector contacts; ///< IDs of contacts that have been "islanded".
        vector joints; ///< IDs of joints that have been "islanded".

        /// @brief Hidden friend equality support for Islanded.
        friend bool operator==(const Islanded& lhs, const Islanded& rhs) noexcept
        {
            return lhs.bodies == rhs.bodies // newline!
                && lhs.contacts == rhs.contacts // newline!
                && lhs.joints == rhs.joints;
        }

        /// @brief Hidden friend inequality support for Islanded.
        friend bool operator!=(const Islanded& lhs, const Islanded& rhs) noexcept
        {
            return !(lhs == rhs);
        }
    };

    /// @brief Solves the step.
    /// @details Finds islands, integrates and solves constraints, solves position constraints.
    /// @note This may miss collisions involving fast moving bodies and allow them to tunnel
    ///   through each other.
    /// @pre <code>IsLocked(const AabbTreeWorld&)</code> & <code>IsStepComplete(const AabbTreeWorld&)</code>
    ///   return true for this world.
    /// @post No contact in the world needs updating.
    RegStepStats SolveReg(const StepConf& conf);

    /// @brief Solves the given island (regularly).
    /// @details This:
    ///   1. Updates every island-body's <code>sweep.pos0</code> to its <code>sweep.pos1</code>.
    ///   2. Updates every island-body's <code>sweep.pos1</code> to the new normalized "solved"
    ///      position for it.
    ///   3. Updates every island-body's velocity to the new accelerated, dampened, and "solved"
    ///      velocity for it.
    ///   4. Synchronizes every island-body's transform (by updating it to transform one of the
    ///      body's sweep).
    ///   5. Reports to the listener (if non-null).
    /// @param conf Time step configuration information.
    /// @param island Island of bodies, contacts, and joints to solve for. Must contain at least
    ///   one body, contact, or joint.
    /// @pre <code>IsLocked(const AabbTreeWorld&)</code> & <code>IsStepComplete(const AabbTreeWorld&)</code>
    ///   return true for this world.
    /// @pre @p island contains at least one body, contact, or joint identifier.
    /// @return Island solver results.
    IslandStats SolveRegIslandViaGS(const StepConf& conf, const Island& island);

    /// @brief Adds to the island based off of a given "seed" body.
    /// @post Contacts are listed in the island in the order that bodies provide those contacts.
    /// @post Joints are listed the island in the order that bodies provide those joints.
    void AddToIsland(Island& island, BodyID seed,
                     BodyCounter& remNumBodies,
                     ContactCounter& remNumContacts,
                     JointCounter& remNumJoints);

    /// @brief Body stack.
    using BodyStack = std::vector<BodyID, pmr::polymorphic_allocator<BodyID>>;

    /// @brief Adds to the island.
    void AddToIsland(Island& island, BodyStack& stack,
                     BodyCounter& remNumBodies,
                     ContactCounter& remNumContacts,
                     JointCounter& remNumJoints);

    /// @brief Adds contacts of identified body to island & adds other contacted bodies to body stack.
    void AddContactsToIsland(Island& island, BodyStack& stack,
                             const BodyContactIDs& contacts,
                             BodyID bodyID);

    /// @brief Adds joints to the island.
    void AddJointsToIsland(Island& island, BodyStack& stack, const BodyJointIDs& joints);

    /// @brief Solves the step using successive time of impact (TOI) events.
    /// @details Used for continuous physics.
    /// @note This is intended to detect and prevent the tunneling that the faster Solve function
    ///    may miss.
    /// @param conf Time step configuration to use.
    /// @pre <code>IsLocked(const AabbTreeWorld&)</code> returns true for this world.
    /// @post No contact in the world needs updating.
    ToiStepStats SolveToi(const StepConf& conf);

    /// @brief Solves collisions for the given time of impact.
    /// @param contactID Identifier of contact to solve for.
    /// @param conf Time step configuration to solve for.
    /// @pre <code>IsLocked(const AabbTreeWorld&)</code> returns true for this world.
    /// @pre The identified contact has a valid TOI, is enabled, is awake, and is impenetrable.
    /// @pre The identified contact is **not** a sensor.
    /// @pre There is no contact having a lower TOI in this time step that has
    ///   not already been solved for.
    /// @pre There is not a lower TOI in the time step for which collisions have
    ///   not already been processed.
    IslandStats SolveToi(ContactID contactID, const StepConf& conf);

    /// @brief Solves the time of impact for bodies 0 and 1 of the given island.
    /// @details This:
    ///   1. Updates position 0 of the sweeps of bodies 0 and 1.
    ///   2. Updates position 1 of the sweeps, the transforms, and the velocities of the other
    ///      bodies in this island.
    ///   3. Calls the post solve contact listener if set.
    /// @pre <code>IsLocked(const AabbTreeWorld&)</code> returns true for this world.
    /// @pre <code>island.bodies</code> contains at least two bodies, the first two of which
    ///   are bodies 0 and 1.
    /// @pre <code>island.bodies</code> contains appropriate other bodies of the contacts of
    ///   the two bodies.
    /// @pre <code>island.contacts</code> contains the contact that specified the two identified
    ///   bodies.
    /// @pre <code>island.contacts</code> contains appropriate other contacts of the two bodies.
    /// @param conf Time step configuration information.
    /// @param island Island to do time of impact solving for.
    /// @return Island solver results.
    IslandStats SolveToiViaGS(const Island& island, const StepConf& conf);

    /// @brief Process contacts output.
    struct ProcessContactsOutput
    {
        ContactCounter contactsUpdated = 0; ///< Contacts updated.
        ContactCounter contactsSkipped = 0; ///< Contacts skipped.
    };

    /// @brief Processes the contacts of a given body for TOI handling.
    /// @details This does the following:
    ///   1. Advances the appropriate associated other bodies to the given TOI (advancing
    ///      their sweeps and synchronizing their transforms to their new sweeps).
    ///   2. Updates the contact manifolds and touching statuses and notifies listener (if one given) of
    ///      the appropriate contacts of the body.
    ///   3. Adds those contacts that are still enabled and still touching to the given island
    ///      (or resets the other bodies advancement).
    ///   4. Adds to the island, those other bodies that haven't already been added of the contacts that
    ///      got added.
    /// @param[in,out] id Identifier of the dynamic/accelerable body to process contacts for.
    /// @param[in,out] island Island. On return this may contain additional contacts or bodies.
    /// @param[in] toi Time of impact (TOI). Value between 0 and under 1.
    /// @param[in] conf Step configuration data.
    /// @pre The identified body is in <code>m_islanded.bodies</code> and accelerable.
    /// @pre There should be no lower TOI for which contacts have not already been processed.
    ProcessContactsOutput ProcessContactsForTOI(BodyID id, Island& island,
                                                ZeroToUnderOneFF<Real> toi,
                                                const StepConf& conf);

    /// @brief Removes the given body from this world.
    void Remove(BodyID id);

    /// @brief Updates associated bodies and contacts for specified joint's addition.
    void Add(JointID id, bool flagForFiltering = false);

    /// @brief Updates associated bodies and contacts for specified joint's removal.
    void Remove(JointID id);

    /// @brief Update contacts statistics.
    struct UpdateContactsStats
    {
        /// @brief Number of contacts updated.
        ContactCounter updated = 0;

        /// @brief Number of contacts skipped because they weren't marked as needing updating.
        ContactCounter skipped = 0;
    };

    /// @brief Destroy contacts statistics.
    struct DestroyContactsStats
    {
        ContactCounter overlap = 0; ///< Erased by not overlapping.
        ContactCounter filter = 0; ///< Erased due to filtering.
    };

    /// @brief Update contacts data.
    struct UpdateContactsData
    {
        ContactCounter numAtMaxSubSteps = 0; ///< # at max sub-steps (lower the better).
        ContactCounter numUpdatedTOI = 0; ///< # updated TOIs (made valid).
        ContactCounter numValidTOI = 0; ///< # already valid TOIs.

        /// @brief Distance iterations type alias.
        using dist_iter_type = std::remove_const_t<decltype(DefaultMaxDistanceIters)>;

        /// @brief TOI iterations type alias.
        using toi_iter_type = std::remove_const_t<decltype(DefaultMaxToiIters)>;

        /// @brief Root iterations type alias.
        using root_iter_type = std::remove_const_t<decltype(DefaultMaxToiRootIters)>;

        dist_iter_type maxDistIters = 0; ///< Max distance iterations.
        toi_iter_type maxToiIters = 0; ///< Max TOI iterations.
        root_iter_type maxRootIters = 0; ///< Max root iterations.
    };

    /// @brief Aggregate of user settable listener functions.
    struct Listeners
    {
        ShapeFunction shapeDestruction; ///< Listener for shape destruction.
        BodyShapeFunction detach; ///< Listener for shapes detaching from bodies.
        JointFunction jointDestruction; ///< Listener for joint destruction.
        ContactFunction beginContact; ///< Listener for beginning contact events.
        ContactFunction endContact; ///< Listener for ending contact events.
        ContactManifoldFunction preSolveContact; ///< Listener for pre-solving contacts.
        ContactImpulsesFunction postSolveContact; ///< Listener for post-solving contacts.
    };

    /// @brief Updates the contact times of impact.
    UpdateContactsData UpdateContactTOIs(const StepConf& conf);

    /// @brief Processes the narrow phase collision for the contacts collection.
    /// @details
    /// This finds and destroys the contacts that need filtering and no longer should collide or
    /// that no longer have AABB-based overlapping fixtures. Those contacts that persist and
    /// have awake bodies (either or both) get their Update methods called with the current
    /// contact listener as its argument.
    /// Essentially this really just purges contacts that are no longer relevant.
    DestroyContactsStats DestroyContacts(KeyedContactIDs& contacts);

    /// @brief Update contacts.
    UpdateContactsStats UpdateContacts(const StepConf& conf);

    /// @brief Adds contacts.
    /// @details Processes given container for valid contacts & adds them to contacts container.
    /// @note Added contacts will all have overlapping AABBs.
    /// @param keys Keys of contacts to evaluate for adding. These should be keys found for
    ///   potential contacts that are not currently added.
    /// @return Number of contacts actually added.
    /// @post <code>GetProxies()</code> will return an empty container.
    /// @post Container returned by <code>GetContacts()</code> increases in size by returned amount.
    /// @post For some body IDs, <code>GetContacts(BodyID)</code> may have more elements.
    /// @see GetProxies.
    ContactCounter AddContacts(std::vector<ProxyKey, pmr::polymorphic_allocator<ProxyKey>>&& keys,
                               const StepConf& conf);

    /// @brief Destroys the given contact and removes it from its container.
    /// @details This updates the contacts container, returns the memory to the allocator,
    ///   and decrements the contact manager's contact count.
    /// @param contact Contact to destroy.
    /// @param from From body.
    /// @pre @p contact is not @c InvalidContactID .
    void Destroy(ContactID contact, const Body* from);

    /// @brief Destroys the given contact.
    /// @param contact Identifier of the contact to destroy.
    /// @param from Optional Body for which to restrict removal the contact.
    /// @pre @p contact is not @c InvalidContactID .
    void InternalDestroy(ContactID contact, const Body* from = nullptr);

    /// @brief Synchronizes the given body.
    /// @details This updates the broad phase dynamic tree data for all of the identified shapes.
    ContactCounter Synchronize(const ProxyIDs& bodyProxies,
                               const Transformation& xfm0, const Transformation& xfm1,
                               const StepConf& conf);

    /// @brief Updates touching related state and notifies any listeners.
    /// @note Ideally this function is only called when a dependent change has occurred.
    /// @note Touching related state depends on the following data:
    ///   - The fixtures' sensor states.
    ///   - The fixtures bodies' transformations.
    ///   - The <code>maxCirclesRatio</code> per-step configuration state *OR* the
    ///     <code>maxDistanceIters</code> per-step configuration state.
    /// @param id Identifies the contact to update.
    /// @param conf Per-step configuration information.
    /// @pre <code>IsLocked(const AabbTreeWorld&)</code> returns true for this world.
    /// @pre The identified contact needs updating.
    /// @post The identified contact does not need updating.
    /// @see GetManifold, IsTouching
    void Update(ContactID id, const ContactUpdateConf& conf);

    /******** Member variables. ********/

    pmr::StatsResource m_statsResource; ///< For PMR statistics.
    pmr::PoolMemoryResource m_bodyStackResource; ///< For body stacks.
    pmr::PoolMemoryResource m_bodyConstraintsResource; ///< For body constraints.
    pmr::PoolMemoryResource m_positionConstraintsResource; ///< For position constraints.
    pmr::PoolMemoryResource m_velocityConstraintsResource; ///< For velocity constraints.
    pmr::PoolMemoryResource m_proxyKeysResource; ///< For dynamic tree.
    pmr::PoolMemoryResource m_islandResource; ///< For island building.

    DynamicTree m_tree; ///< Dynamic tree.

    ObjectPool<Body> m_bodyBuffer; ///< Array of body data both used and freed.
    ObjectPool<Shape> m_shapeBuffer; ///< Array of shape data both used and freed.
    ObjectPool<Joint> m_jointBuffer; ///< Array of joint data both used and freed.

    /// @brief Array of contact data both used and freed.
    ObjectPool<Contact> m_contactBuffer;

    /// @brief Array of manifold data both used and freed.
    /// @note Size depends on and matches <code>size(m_contactBuffer)</code>.
    ObjectPool<Manifold> m_manifoldBuffer;

    /// @brief Cache of contacts associated with bodies.
    /// @note Size depends on and matches <code>size(m_bodyBuffer)</code>.
    /// @note Individual body contact containers are added to by <code>AddContacts</code>.
    ObjectPool<BodyContactIDs> m_bodyContacts;

    /// @brief Cache of joints associated with bodies.
    /// @note Size depends on and matches <code>size(m_bodyBuffer)</code>.
    ObjectPool<BodyJointIDs> m_bodyJoints;

    /// @brief Cache of proxies associated with bodies.
    /// @note Size depends on and matches <code>size(m_bodyBuffer)</code>.
    ObjectPool<ProxyIDs> m_bodyProxies;

    /// @brief Buffer of proxies to inspect for finding new contacts.
    /// @note Built from @a m_fixturesForProxies and on body synchronization. Consumed by the finding-of-new-contacts.
    ProxyIDs m_proxiesForContacts;

    /// @brief Fixtures for proxies queue.
    /// @note Capacity grows on calls to <code>CreateBody</code>, <code>SetBody</code>, and <code>SetShape</code>.
    BodyShapeIDs m_fixturesForProxies;

    /// @brief Bodies for proxies queue.
    /// @note Size & capacity grows on calls to <code>SetBody</code>.
    /// @note Size shrinks on calls to <code>Remove(BodyID id)</code>.
    /// @note Size clears on calls to <code>Step</code> or <code>Clear</code>.
    BodyIDs m_bodiesForSync;

    BodyIDs m_bodies; ///< Body collection.

    JointIDs m_joints; ///< Joint collection.

    /// @brief Container of contacts.
    /// @note In the <em>add pair</em> stress-test, 401 bodies can have some 31000 contacts
    ///   during a given time step.
    KeyedContactIDs m_contacts;

    /// Bodies, contacts, and joints that are already in an island.
    /// @note This is step-wise state that needs to be here or within a step solving co-routine for
    ///   sub-stepping TOI solving.
    /// @note This instance's members capacities depend on state changed outside the step loop.
    /// @see Island.
    Islanded m_islanded;

    /// @brief Listeners.
    Listeners m_listeners;

    FlagsType m_flags = e_stepComplete; ///< Flags.

    /// Inverse delta-t from previous step.
    /// @details Used to compute time step ratio to support a variable time step.
    /// @see Step.
    Frequency m_inv_dt0 = 0_Hz;

    /// @brief Vertex radius range.
    /// @details
    /// The interval max is the maximum shape vertex radius that any bodies' of this world should
    /// create fixtures for. Requests to create fixtures for shapes with vertex radiuses bigger than
    /// this must be rejected. As an upper bound, this value prevents shapes from getting
    /// associated with this world that would otherwise not be able to be simulated due to
    /// numerical issues. It can also be set below this upper bound to constrain the differences
    /// between shape vertex radiuses to possibly more limited visual ranges.
    Interval<Positive<Length>> m_vertexRadius = WorldConf::DefaultVertexRadius;
};

// State & confirm compile-time traits of AabbTreeWorld class.
static_assert(std::is_default_constructible_v<AabbTreeWorld>);
static_assert(std::is_copy_constructible_v<AabbTreeWorld>);
static_assert(std::is_move_constructible_v<AabbTreeWorld>);
static_assert(!std::is_copy_assignable_v<AabbTreeWorld>);
static_assert(!std::is_move_assignable_v<AabbTreeWorld>);

inline std::optional<pmr::StatsResource::Stats> GetResourceStats(const AabbTreeWorld& world) noexcept
{
    return world.m_statsResource.upstream_resource()
        ? world.m_statsResource.GetStats(): std::optional<pmr::StatsResource::Stats>{};
}

inline const ProxyIDs& GetProxies(const AabbTreeWorld& world) noexcept
{
    return world.m_proxiesForContacts;
}

inline const BodyIDs& GetBodies(const AabbTreeWorld& world) noexcept
{
    return world.m_bodies;
}

inline const BodyIDs& GetBodiesForProxies(const AabbTreeWorld& world) noexcept
{
    return world.m_bodiesForSync;
}

inline const BodyShapeIDs& GetFixturesForProxies(const AabbTreeWorld& world) noexcept
{
    return world.m_fixturesForProxies;
}

inline const JointIDs& GetJoints(const AabbTreeWorld& world) noexcept
{
    return world.m_joints;
}

inline KeyedContactIDs GetContacts(const AabbTreeWorld& world)
{
    using std::begin, std::end;
    return KeyedContactIDs{begin(world.m_contacts), end(world.m_contacts)};
}

inline bool IsLocked(const AabbTreeWorld& world) noexcept
{
    return (world.m_flags & AabbTreeWorld::e_locked) == AabbTreeWorld::e_locked;
}

inline bool IsStepComplete(const AabbTreeWorld& world) noexcept
{
    return (world.m_flags & AabbTreeWorld::e_stepComplete) != 0u;
}

inline bool GetSubStepping(const AabbTreeWorld& world) noexcept
{
    return (world.m_flags & AabbTreeWorld::e_substepping) != 0u;
}

inline void SetSubStepping(AabbTreeWorld& world, bool flag) noexcept
{
    if (flag) {
        world.m_flags |= AabbTreeWorld::e_substepping;
    }
    else {
        world.m_flags &= ~AabbTreeWorld::e_substepping;
    }
}

inline Interval<Positive<Length>> GetVertexRadiusInterval(const AabbTreeWorld& world) noexcept
{
    return world.m_vertexRadius;
}

inline Frequency GetInvDeltaTime(const AabbTreeWorld& world) noexcept
{
    return world.m_inv_dt0;
}

inline const DynamicTree& GetTree(const AabbTreeWorld& world) noexcept
{
    return world.m_tree;
}

inline void SetShapeDestructionListener(AabbTreeWorld& world, ShapeFunction listener) noexcept
{
    world.m_listeners.shapeDestruction = std::move(listener);
}

inline void SetDetachListener(AabbTreeWorld& world, BodyShapeFunction listener) noexcept
{
    world.m_listeners.detach = std::move(listener);
}

inline void SetJointDestructionListener(AabbTreeWorld& world, JointFunction listener) noexcept
{
    world.m_listeners.jointDestruction = std::move(listener);
}

inline void SetBeginContactListener(AabbTreeWorld& world, ContactFunction listener) noexcept
{
    world.m_listeners.beginContact = std::move(listener);
}

inline void SetEndContactListener(AabbTreeWorld& world, ContactFunction listener) noexcept
{
    world.m_listeners.endContact = std::move(listener);
}

inline void SetPreSolveContactListener(AabbTreeWorld& world, ContactManifoldFunction listener) noexcept
{
    world.m_listeners.preSolveContact = std::move(listener);
}

inline void SetPostSolveContactListener(AabbTreeWorld& world, ContactImpulsesFunction listener) noexcept
{
    world.m_listeners.postSolveContact = std::move(listener);
}

/// @brief Gets the identifier of the contact with the lowest time of impact.
/// @details This finds the contact with the lowest (soonest) time of impact that's under one
///   and returns its identifier.
/// @return Identifier of contact with the least time of impact under 1, or invalid contact ID.
ContactID GetSoonestContact(const Span<const KeyedContactID>& ids,
                            const Span<const Contact>& contacts) noexcept;

/// @brief Creates a body within the world that's a copy of the given one.
/// @relatedalso AabbTreeWorld
BodyID CreateBody(AabbTreeWorld& world, const BodyConf& def);

/// @brief Associates a validly identified shape with the validly identified body.
/// @throws std::out_of_range If given an invalid body or shape identifier.
/// @throws WrongState if this function is called while the world is locked.
/// @see GetShapes.
/// @relatedalso AabbTreeWorld
void Attach(AabbTreeWorld& world, BodyID id, ShapeID shapeID);

/// @brief Disassociates a validly identified shape from the validly identified body.
/// @throws std::out_of_range If given an invalid body or shape identifier.
/// @throws WrongState if this function is called while the world is locked.
/// @relatedalso AabbTreeWorld
bool Detach(AabbTreeWorld& world, BodyID id, ShapeID shapeID);

/// @brief Disassociates all of the associated shape from the validly identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @throws WrongState if this function is called while the world is locked.
/// @relatedalso AabbTreeWorld
const std::vector<ShapeID>& GetShapes(const AabbTreeWorld& world, BodyID id);

} // namespace playrho::d2

#endif // PLAYRHO_D2_AABBTREEWORLD_HPP

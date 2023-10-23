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

#include <functional> // for std::function
#include <iterator>
#include <memory> // for std::unique_ptr
#include <optional>
#include <stdexcept>
#include <type_traits> // for std::is_default_constructible_v, etc.
#include <vector>

#include "playrho/BodyID.hpp"
#include "playrho/Contact.hpp"
#include "playrho/KeyedContactID.hpp"
#include "playrho/JointID.hpp"
#include "playrho/LimitState.hpp"
#include "playrho/propagate_const.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/StepStats.hpp"
#include "playrho/TypeInfo.hpp" // for GetTypeID

#include "playrho/pmr/StatsResource.hpp"

#include "playrho/d2/BodyConf.hpp" // for GetDefaultBodyConf
#include "playrho/d2/Body.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/Manifold.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/Shape.hpp"
#include "playrho/d2/WorldConf.hpp"

namespace playrho {
namespace d2 {

class World;
class ContactImpulsesList;
class DynamicTree;

/// @brief Shape listener.
using ShapeListener = std::function<void(ShapeID)>;

/// @brief Body-shape listener.
using AssociationListener = std::function<void(std::pair<BodyID, ShapeID>)>;

/// @brief Listener type for some joint related events.
using JointListener = std::function<void(JointID)>;

/// @brief Listener type for some contact related events.
using ContactListener = std::function<void(ContactID)>;

/// @brief Listener type for some manifold contact events.
using ManifoldContactListener = std::function<void(ContactID, const Manifold&)>;

/// @brief Impulses contact listener.
using ImpulsesContactListener =
    std::function<void(ContactID, const ContactImpulsesList&, unsigned)>;

/// @name World Listener Non-Member Functions
/// @{

/// @brief Sets the destruction listener for shapes.
/// @note This listener is called on <code>Clear(World&)</code> for every shape.
/// @see Clear(World&).
void SetShapeDestructionListener(World& world, ShapeListener listener) noexcept;

/// @brief Sets the detach listener for shapes detaching from bodies.
void SetDetachListener(World& world, AssociationListener listener) noexcept;

/// @brief Sets the destruction listener for joints.
/// @note This listener is called on <code>Clear(World&)</code> for every joint. It's also called
///   on <code>Destroy(BodyID)</code> for every joint associated with the identified body.
/// @see Clear(World&), Destroy(BodyID).
void SetJointDestructionListener(World& world, JointListener listener) noexcept;

/// @brief Sets the begin-contact lister.
/// @see SetEndContactListener(World&, ContactListener).
void SetBeginContactListener(World& world, ContactListener listener) noexcept;

/// @brief Sets the end-contact lister.
/// @see SetBeginContactListener(World&, ContactListener).
void SetEndContactListener(World& world, ContactListener listener) noexcept;

/// @brief Sets the pre-solve-contact lister.
/// @see etPostSolveContactListener(World&, ImpulsesContactListener).
void SetPreSolveContactListener(World& world, ManifoldContactListener listener) noexcept;

/// @brief Sets the post-solve-contact lister.
/// @see SetPreSolveContactListener(World&, ManifoldContactListener).
void SetPostSolveContactListener(World& world, ImpulsesContactListener listener) noexcept;

/// @}

/// @name World Miscellaneous Non-Member Functions
/// @{

/// @brief Gets the identifier of the type of data this can be casted to.
TypeID GetType(const World& world) noexcept;

/// @brief Converts the given world into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> code from the LLVM Project.
/// @see https://llvm.org/
template <typename T>
std::add_pointer_t<std::add_const_t<T>> TypeCast(const World* value) noexcept;

/// @brief Converts the given world into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> implementation from the LLVM Project.
/// @see https://llvm.org/
template <typename T>
std::add_pointer_t<T> TypeCast(World* value) noexcept;

/// @brief Gets the polymorphic memory resource allocator statistics of the specified world.
/// @note This will be the empty value unless the world configuration the given world was
///   constructed with specified the collection of these statistics.
/// @note This information can be used to tweak the world configuration to pre-allocate enough
///   space to avoid the less deterministic performance behavior of dynamic memory allocation
///   during world step processing that may otherwise occur.
/// @see WorldConf.
std::optional<pmr::StatsResource::Stats> GetResourceStats(const World& world) noexcept;

/// @brief Clears the given world.
/// @note This calls the joint and shape destruction listeners (if they're set), for all
///   defined joints and shapes, before clearing anything. Any exceptions thrown from these
///   listeners are ignored.
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
/// step.
/// @return <code>true</code> unless sub-stepping is enabled and the step function returned
///   without finishing all of its sub-steps.
/// @see GetSubStepping, SetSubStepping.
bool IsStepComplete(const World& world) noexcept;

/// @brief Gets whether or not sub-stepping is enabled.
/// @see SetSubStepping, IsStepComplete.
bool GetSubStepping(const World& world) noexcept;

/// @brief Enables/disables single stepped continuous physics.
/// @note This is not normally used. Enabling sub-stepping is meant for testing.
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
/// @see CreateShape(World&, const Shape&).
Interval<Positive<Length>> GetVertexRadiusInterval(const World& world) noexcept;

/// @brief Gets the inverse delta time.
/// @details Gets the inverse delta time that was set on construction or assignment, and
///   updated on every call to the <code>Step()</code> function having a non-zero delta-time.
/// @see Step.
Frequency GetInvDeltaTime(const World& world) noexcept;

/// @}

/// @name World Body Non-Member Functions.
/// Non-Member functions relating to bodies.
/// @{

/// @brief Gets the extent of the currently valid body range.
/// @note This is one higher than the maxium <code>BodyID</code> that is in range
///   for body related functions.
BodyCounter GetBodyRange(const World& world) noexcept;

/// @brief Gets the world body range for this constant world.
/// @details Gets a range enumerating the bodies currently existing within this world.
///   These are the bodies that had been created from previous calls to
///   <code>CreateBody(World&, const Body&)</code> that haven't yet been destroyed by
///   a call to <code>Destroy(World& world, BodyID)</code> or to <code>Clear(World&)</code>.
/// @return Container of body identifiers.
/// @see CreateBody(World&, const Body&), Destroy(World& world, BodyID), Clear(World&).
std::vector<BodyID> GetBodies(const World& world);

/// @brief Gets the bodies-for-proxies range for this world.
/// @details Provides insight on what bodies have been queued for proxy processing
///   during the next call to the world step function.
/// @see Step.
/// @todo Remove this function from this class - access from implementation instead.
std::vector<BodyID> GetBodiesForProxies(const World& world);

/// @brief Creates a rigid body within the world that's a copy of the given one.
/// @warning This function should not be used while the world is locked &mdash; as it is
///   during callbacks. If it is, it will throw an exception or abort your program.
/// @note No references to the configuration are retained. Its value is copied.
/// @post The created body will be present in the range returned from the
///   <code>GetBodies(const World&)</code> function.
/// @param world The world within which to create the body.
/// @param body A customized body or its default value.
/// @param resetMassData Whether or not the mass data of the body should be reset.
/// @return Identifier of the newly created body which can later be destroyed by calling
///   the <code>Destroy(BodyID)</code> function.
/// @throws WrongState if this function is called while the world is locked.
/// @throws LengthError if this operation would create more than <code>MaxBodies</code>.
/// @throws std::out_of_range if the given body references any invalid shape identifiers.
/// @see Destroy(World& world, BodyID), GetBodies(const World&), ResetMassData.
/// @see PhysicalEntities.
BodyID CreateBody(World& world, const Body& body = Body{}, bool resetMassData = true);

/// @brief Gets the state of the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see CreateBody(World& world, const BodyConf&),
///   SetBody(World& world, BodyID id, const Body& body).
Body GetBody(const World& world, BodyID id);

/// @brief Sets the state of the identified body.
/// @throws std::out_of_range if given an invalid id of if the given body references any
///   invalid shape identifiers.
/// @throws InvalidArgument if the specified ID was destroyed.
/// @see GetBody(const World& world, BodyID id), GetBodyRange.
void SetBody(World& world, BodyID id, const Body& body);

/// @brief Destroys the identified body.
/// @details Destroys the identified body that had previously been created by a call
///   to this world's <code>CreateBody(const BodyConf&)</code> function.
/// @warning This automatically deletes all associated shapes and joints.
/// @warning This function is locked during callbacks.
/// @warning Behavior is not specified if identified body wasn't created by this world.
/// @note This function is locked during callbacks.
/// @post The destroyed body will no longer be present in the range returned from the
///   <code>GetBodies()</code> function.
/// @param world The world from which to delete the identified body from.
/// @param id Identifier of body to destroy that had been created in @p world.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see CreateBody(const BodyConf&), GetBodies, GetBodyRange.
/// @see PhysicalEntities.
void Destroy(World& world, BodyID id);

/// @brief Gets the range of joints attached to the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see CreateJoint, GetBodyRange.
std::vector<std::pair<BodyID, JointID>> GetJoints(const World& world, BodyID id);

/// @brief Gets the container of contacts attached to the identified body.
/// @warning This collection changes during the time step and you may
///   miss some collisions if you don't use <code>ContactListener</code>.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetBodyRange.
std::vector<std::tuple<ContactKey, ContactID>> GetContacts(const World& world, BodyID id);

/// @brief Gets the identities of the shapes associated with the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @see GetBodyRange, CreateBody, SetBody.
std::vector<ShapeID> GetShapes(const World& world, BodyID id);

/// @brief Sets the accelerations of all the world's bodies.
/// @param world World instance to set the acceleration of all contained bodies for.
/// @param fn Function or functor with a signature like:
///   <code>Acceleration (*fn)(World&,BodyID)</code>.
/// @throws WrongState if this function is called while the world is locked.
/// @relatedalso World
template <class F>
void SetAccelerations(World& world, F fn)
{
    const auto bodies = GetBodies(world);
    std::for_each(begin(bodies), end(bodies), [&](const auto &b) {
        SetAcceleration(world, b, fn(world, b));
    });
}

/// @}

/// @name World Joint Non-Member Functions
/// Member functions relating to joints.
/// @{

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
/// @throws WrongState if this function is called while the world is locked.
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
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
void Destroy(World& world, JointID id);

/// @brief Gets the value of the identified joint.
/// @throws std::out_of_range If given an invalid joint identifier.
Joint GetJoint(const World& world, JointID id);

/// @brief Sets the value of the identified joint.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
void SetJoint(World& world, JointID id, const Joint& def);

/// @brief Sets a joint's value from a configuration.
/// @details This is a convenience function for allowing limited implicit conversions to joints.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
template <typename T>
void SetJoint(World& world, JointID id, const T& value)
{
    return SetJoint(world, id, Joint{value});
}

/// @}

/// @name World Shape Non-Member Functions
/// Non-member functions relating to shapes.
/// @{

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
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid identifier.
void Destroy(World& world, ShapeID id);

/// @brief Gets the shape associated with the identifier.
/// @throws std::out_of_range If given an invalid identifier.
Shape GetShape(const World& world, ShapeID id);

/// @brief Sets the identified shape to the new value.
/// @throws std::out_of_range If given an invalid shape identifier.
/// @see CreateShape.
void SetShape(World& world, ShapeID, const Shape& def);

/// @}


/// @name World Contact Non-Member Functions
/// Non-member functions relating to contacts.
/// @{

/// @brief Gets the extent of the currently valid contact range.
/// @note This is one higher than the maxium <code>ContactID</code> that is in range
///   for contact related functions.
ContactCounter GetContactRange(const World& world) noexcept;

/// @brief Gets the contacts identified within the given world.
/// @note Further information for each element of the returned container
///   is available from functions like @c GetContact or @c GetManifold.
std::vector<KeyedContactID> GetContacts(const World& world);

/// @brief Gets the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
Contact GetContact(const World& world, ContactID id);

/// @brief Sets the identified contact's state.
/// @note This may throw an exception or update associated entities to preserve invariants.
/// @invariant A contact may only be impenetrable if one or both bodies are.
/// @invariant A contact may only be active if one or both bodies are awake.
/// @invariant A contact may only be a sensor or one or both shapes are.
/// @throws std::out_of_range If given an invalid contact identifier.
void SetContact(World& world, ContactID id, const Contact& value);

/// @brief Gets the manifold for the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
Manifold GetManifold(const World& world, ContactID id);

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

/// @}

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
    /// @param def A customized world configuration or its default value.
    /// @note A lot more configurability can be had via the <code>StepConf</code>
    ///   data that's given to the <code>Step(World&, const StepConf&)</code> function.
    /// @see Step(World&, const StepConf&).
    explicit World(const WorldConf& def = WorldConf{});

    /// @brief Copy constructor.
    /// @details Copy constructs this world with a deep copy of the given world.
    World(const World& other): m_impl{other.m_impl? other.m_impl->Clone_(): nullptr}
    {
        // Intentionally empty.
    }

    /// @brief Move constructor.
    /// @details Move constructs this world.
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
    /// @throws std::bad_alloc if there's a failure allocating storage for the given value.
    template <typename T, typename DT = std::decay_t<T>,
    typename Tp = std::enable_if_t<!std::is_same_v<DT, World> && !std::is_same_v<DT, WorldConf>, DT>,
    typename = std::enable_if_t<std::is_constructible_v<DT, T>>>
    explicit World(T&& arg) : m_impl{std::make_unique<Model<Tp>>(std::forward<T>(arg))}
    {
        // Intentionally empty.
    }

    /// @brief Copy assignment operator.
    /// @details Copy assigns this world with a deep copy of the given world.
    World& operator=(const World& other)
    {
        m_impl = other.m_impl ? other.m_impl->Clone_() : nullptr;
        return *this;
    }

    /// @brief Move assignment operator.
    /// @details Move assigns this world.
    /// @post <code>this</code> is what <code>other</code> used to be.
    /// @post <code>other</code> is in a "valid but unspecified state". The only thing it
    ///   can be used for, is as the destination of an assignment.
    World& operator=(World&& other) noexcept
    {
        m_impl = std::move(other.m_impl);
        return *this;
    }

    /// @brief Destructor.
    /// @details All physics entities are destroyed and all memory is released.
    /// @note This will call the <code>Clear()</code> function.
    /// @see Clear.
    ~World() noexcept;

    // Listener friend functions...
    friend void SetShapeDestructionListener(World& world, ShapeListener listener) noexcept;
    friend void SetDetachListener(World& world, AssociationListener listener) noexcept;
    friend void SetJointDestructionListener(World& world, JointListener listener) noexcept;
    friend void SetBeginContactListener(World& world, ContactListener listener) noexcept;
    friend void SetEndContactListener(World& world, ContactListener listener) noexcept;
    friend void SetPreSolveContactListener(World& world, ManifoldContactListener listener) noexcept;
    friend void SetPostSolveContactListener(World& world, ImpulsesContactListener listener) noexcept;

    // Miscellaneous friend functions...
    friend TypeID GetType(const World& world) noexcept;
    template <typename T>
    friend std::add_pointer_t<std::add_const_t<T>> TypeCast(const World* value) noexcept;
    template <typename T>
    friend std::add_pointer_t<T> TypeCast(World* value) noexcept;
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

private:
    /// @brief Concept pure virtual base class.
    struct Concept {
        /// @brief Destructor.
        virtual ~Concept() = default;

        /// @name Listener Member Functions
        /// @note Having these as part of the base interface instead of say taking
        ///   these settings on construction, allows users to already have access
        ///   to the World object so these can be set without making the underlying
        ///   type part of the listener callback parameter interface.
        /// @{

        /// @brief Sets the destruction listener for shapes.
        /// @note This listener is called on <code>Clear_()</code> for every shape.
        /// @see Clear_.
        virtual void SetShapeDestructionListener_(ShapeListener listener) noexcept = 0;

        /// @brief Sets the detach listener for shapes detaching from bodies.
        virtual void SetDetachListener_(AssociationListener listener) noexcept = 0;

        /// @brief Sets a destruction listener for joints.
        /// @note This listener is called on <code>Clear_()</code> for every joint. It's also called
        ///   on <code>Destroy_(BodyID)</code> for every joint associated with the identified body.
        /// @see Clear_, Destroy_(BodyID).
        virtual void SetJointDestructionListener_(JointListener listener) noexcept = 0;

        /// @brief Sets a begin contact event listener.
        virtual void SetBeginContactListener_(ContactListener listener) noexcept = 0;

        /// @brief Sets an end contact event listener.
        virtual void SetEndContactListener_(ContactListener listener) noexcept = 0;

        /// @brief Sets a pre-solve contact event listener.
        virtual void SetPreSolveContactListener_(ManifoldContactListener listener) noexcept = 0;

        /// @brief Sets a post-solve contact event listener.
        virtual void SetPostSolveContactListener_(ImpulsesContactListener listener) noexcept = 0;

        /// @}

        /// @name Miscellaneous Member Functions
        /// @{

        /// @brief Clones the instance - making a deep copy.
        virtual std::unique_ptr<Concept> Clone_() const = 0;

        /// @brief Gets the use type information.
        /// @return Type info of the underlying value's type.
        virtual TypeID GetType_() const noexcept = 0;

        /// @brief Gets the data for the underlying configuration.
        virtual const void* GetData_() const noexcept = 0;

        /// @brief Gets the data for the underlying configuration.
        virtual void* GetData_() noexcept = 0;

        /// @brief Gets the polymorphic memory resource statistics.
        /// @note This will be the zero initialized value unless the world configuration the
        ///   world was constructed with specified the collection of these statistics.
        virtual std::optional<pmr::StatsResource::Stats> GetResourceStats_() const noexcept = 0;

        /// @brief Clears the world.
        /// @note This calls the joint and shape destruction listeners (if they're set), for all
        ///   defined joints and shapes, before clearing anything. Any exceptions thrown from these
        ///   listeners are ignored.
        /// @post The contents of this world have all been destroyed and this world's internal
        ///   state is reset as though it had just been constructed.
        /// @see SetJointDestructionListener_, SetShapeDestructionListener_.
        virtual void Clear_() noexcept = 0;

        /// @brief Steps the world simulation according to the given configuration.
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
        /// @post Static bodies are unmoved.
        /// @post Kinetic bodies are moved based on their previous velocities.
        /// @post Dynamic bodies are moved based on their previous velocities, gravity, applied
        ///   forces, applied impulses, masses, damping, and the restitution and friction values
        ///   of their fixtures when they experience collisions.
        /// @param conf Configuration for the simulation step.
        /// @return Statistics for the step.
        /// @throws WrongState if this function is called while the world is locked.
        virtual StepStats Step_(const StepConf& conf) = 0;

        /// @brief Whether or not "step" is complete.
        /// @details The "step" is completed when there are no more TOI events for the current time
        /// step.
        /// @return <code>true</code> unless sub-stepping is enabled and the step function returned
        ///   without finishing all of its sub-steps.
        /// @see GetSubStepping_, SetSubStepping_.
        virtual bool IsStepComplete_() const noexcept = 0;

        /// @brief Gets whether or not sub-stepping is enabled.
        /// @see SetSubStepping_, IsStepComplete_.
        virtual bool GetSubStepping_() const noexcept = 0;

        /// @brief Enables/disables single stepped continuous physics.
        /// @note This is not normally used. Enabling sub-stepping is meant for testing.
        /// @post The <code>GetSubStepping_()</code> function will return the value this function was
        ///   called with.
        /// @see IsStepComplete_, GetSubStepping_.
        virtual void SetSubStepping_(bool flag) noexcept = 0;

        /// @brief Gets access to the broad-phase dynamic tree information.
        /// @todo Consider removing this function. This function exposes the implementation detail
        ///   of the broad-phase contact detection system.
        virtual const DynamicTree& GetTree_() const noexcept = 0;

        /// @brief Is the world locked (in the middle of a time step).
        virtual bool IsLocked_() const noexcept = 0;

        /// @brief Shifts the world origin.
        /// @note Useful for large worlds.
        /// @note The body shift formula is: <code>position -= newOrigin</code>.
        /// @post The "origin" of this world's bodies, joints, and the board-phase dynamic tree
        ///   have been translated per the shift amount and direction.
        /// @param newOrigin the new origin with respect to the old origin
        /// @throws WrongState if this function is called while the world is locked.
        virtual void ShiftOrigin_(const Length2& newOrigin) = 0;

        /// @brief Gets the vertex radius range that shapes in this world can be.
        virtual Interval<Positive<Length>> GetVertexRadiusInterval_() const noexcept = 0;

        /// @brief Gets the inverse delta time.
        /// @details Gets the inverse delta time that was set on construction or assignment, and
        ///   updated on every call to the <code>Step_</code> function having a non-zero delta-time.
        /// @see Step_.
        virtual Frequency GetInvDeltaTime_() const noexcept = 0;

        /// @}

        /// @name Body Member Functions.
        /// Member functions relating to bodies.
        /// @{

        /// @brief Gets the extent of the currently valid body range.
        /// @note This is one higher than the maxium <code>BodyID</code> that is in range
        ///   for body related functions.
        virtual BodyCounter GetBodyRange_() const noexcept = 0;

        /// @brief Gets the world body range for this constant world.
        /// @details Gets a range enumerating the bodies currently existing within this world.
        ///   These are the bodies that had been created from previous calls to the
        ///   <code>CreateBody_(const Body&)</code> function that haven't yet been destroyed.
        /// @return An iterable of body identifiers.
        /// @see CreateBody_.
        virtual std::vector<BodyID> GetBodies_() const = 0;

        /// @brief Gets the bodies-for-proxies range for this world.
        /// @details Provides insight on what bodies have been queued for proxy processing
        ///   during the next call to the world step function.
        /// @see Step_.
        /// @todo Remove this function from this class - access from implementation instead.
        virtual std::vector<BodyID> GetBodiesForProxies_() const = 0;

        /// @brief Creates a rigid body that's a copy of the given one.
        /// @warning This function should not be used while the world is locked &mdash; as it is
        ///   during callbacks. If it is, it will throw an exception or abort your program.
        /// @note No references to the configuration are retained. Its value is copied.
        /// @post The created body will be present in the range returned from the
        ///   <code>GetBodies_()</code> function.
        /// @param body A customized body or its default value.
        /// @return Identifier of the newly created body which can later be destroyed by calling
        ///   the <code>Destroy_(BodyID)</code> function.
        /// @throws WrongState if this function is called while the world is locked.
        /// @throws LengthError if this operation would create more than <code>MaxBodies</code>.
        /// @throws std::out_of_range if the given body references any invalid shape identifiers.
        /// @see Destroy_(BodyID), GetBodies_.
        /// @see PhysicalEntities.
        virtual BodyID CreateBody_(const Body& body) = 0;

        /// @brief Gets the state of the identified body.
        /// @throws std::out_of_range If given an invalid body identifier.
        /// @see SetBody_, GetBodyRange_.
        virtual Body GetBody_(BodyID id) const = 0;

        /// @brief Sets the state of the identified body.
        /// @throws std::out_of_range if given an invalid id of if the given body references any
        ///   invalid shape identifiers.
        /// @throws InvalidArgument if the specified ID was destroyed.
        /// @see GetBody_, GetBodyRange_.
        virtual void SetBody_(BodyID id, const Body& value) = 0;

        /// @brief Destroys the identified body.
        /// @details Destroys the identified body that had previously been created by a call to this
        ///   world's <code>CreateBody_(const Body&)</code> function.
        /// @warning This automatically deletes all associated shapes and joints.
        /// @warning This function is locked during callbacks.
        /// @warning Behavior is not specified if identified body wasn't created by this world.
        /// @note This function is locked during callbacks.
        /// @post The destroyed body will no longer be present in the range returned from the
        ///   <code>GetBodies_()</code> function.
        /// @param id Identifier of body to destroy that had been created by this world.
        /// @throws WrongState if this function is called while the world is locked.
        /// @throws std::out_of_range If given an invalid body identifier.
        /// @see CreateBody_, GetBodies_, GetBodyRange_.
        /// @see PhysicalEntities.
        virtual void Destroy_(BodyID id) = 0;

        /// @brief Gets the range of joints attached to the identified body.
        /// @throws std::out_of_range If given an invalid body identifier.
        /// @see CreateJoint_, GetBodyRange_.
        virtual std::vector<std::pair<BodyID, JointID>> GetJoints_(BodyID id) const = 0;

        /// @brief Gets the container of contacts attached to the identified body.
        /// @warning This collection changes during the time step and you may
        ///   miss some collisions if you don't use <code>ContactListener</code>.
        /// @throws std::out_of_range If given an invalid body identifier.
        /// @see GetBodyRange_.
        virtual std::vector<std::tuple<ContactKey, ContactID>> GetContacts_(BodyID id) const = 0;

        /// @brief Gets the identities of the shapes associated with the identified body.
        /// @throws std::out_of_range If given an invalid body identifier.
        /// @see GetBodyRange_, CreateBody_, SetBody_.
        virtual std::vector<ShapeID> GetShapes_(BodyID id) const = 0;

        /// @}

        /// @name Joint Member Functions
        /// Member functions relating to joints.
        /// @{

        /// @brief Gets the extent of the currently valid joint range.
        /// @note This is one higher than the maxium <code>JointID</code> that is in range
        ///   for joint related functions.
        virtual JointCounter GetJointRange_() const noexcept = 0;

        /// @brief Gets the world joint range.
        /// @details Gets a range enumerating the joints currently existing within this world.
        ///   These are the joints that had been created from previous calls to the
        ///   <code>CreateJoint_</code> function that haven't yet been destroyed.
        /// @return World joints sized-range.
        /// @see CreateJoint_.
        virtual std::vector<JointID> GetJoints_() const = 0;

        /// @brief Creates a joint to constrain one or more bodies.
        /// @warning This function is locked during callbacks.
        /// @post The created joint will be present in the range returned from the
        ///   <code>GetJoints_()</code> function.
        /// @return Identifier of newly created joint which can later be destroyed by calling the
        ///   <code>Destroy_(JointID)</code> function.
        /// @throws WrongState if this function is called while the world is locked.
        /// @throws LengthError if this operation would create more than <code>MaxJoints</code>.
        /// @see PhysicalEntities.
        /// @see Destroy_(JointID), GetJoints_.
        virtual JointID CreateJoint_(const Joint& def) = 0;

        /// @brief Gets the value of the identified joint.
        /// @throws std::out_of_range If given an invalid joint identifier.
        /// @see SetJoint_, GetJointRange_.
        virtual Joint GetJoint_(JointID id) const = 0;

        /// @brief Sets the identified joint to the given value.
        /// @throws WrongState if this function is called while the world is locked.
        /// @throws std::out_of_range If given an invalid joint identifier.
        /// @throws InvalidArgument if the specified ID was destroyed.
        /// @see GetJoint_, GetJointRange_.
        virtual void SetJoint_(JointID id, const Joint& def) = 0;

        /// @brief Destroys the identified joint.
        /// @details Destroys the identified joint that had previously been created by a call to this
        ///   world's <code>CreateJoint_(const Joint&)</code> function.
        /// @warning This function is locked during callbacks.
        /// @note This may cause the connected bodies to begin colliding.
        /// @post The destroyed joint will no longer be present in the range returned from the
        ///   <code>GetJoints_()</code> function.
        /// @param id Identifier of joint to destroy that had been created by this world.
        /// @throws WrongState if this function is called while the world is locked.
        /// @throws std::out_of_range If given an invalid joint identifier.
        /// @see CreateJoint_(const Joint&), GetJoints_, GetJointRange_.
        /// @see PhysicalEntities.
        virtual void Destroy_(JointID id) = 0;

        /// @}

        /// @name Shape Member Functions
        /// Member functions relating to shapes.
        /// @{

        /// @brief Gets the extent of the currently valid shape range.
        /// @note This is one higher than the maxium <code>ShapeID</code> that is in range
        ///   for shape related functions.
        virtual ShapeCounter GetShapeRange_() const noexcept = 0;

        /// @brief Creates an identifiable copy of the given shape within this world.
        /// @throws InvalidArgument if called for a shape with a vertex radius that's either:
        ///    less than the minimum vertex radius, or greater than the maximum vertex radius.
        /// @throws WrongState if this function is called while the world is locked.
        /// @throws LengthError if this operation would create more than <code>MaxShapes</code>.
        /// @see Destroy_(ShapeID), GetShape_, SetShape_.
        virtual ShapeID CreateShape_(const Shape& def) = 0;

        /// @throws std::out_of_range If given an invalid shape identifier.
        /// @see CreateShape_.
        virtual Shape GetShape_(ShapeID id) const = 0;

        /// @brief Sets the identified shape to the new value.
        /// @throws std::out_of_range If given an invalid shape identifier.
        /// @throws InvalidArgument if the specified ID was destroyed.
        /// @see CreateShape_.
        virtual void SetShape_(ShapeID id, const Shape& def) = 0;

        /// @brief Destroys the identified shape.
        /// @throws std::out_of_range If given an invalid shape identifier.
        /// @see CreateShape_.
        virtual void Destroy_(ShapeID id) = 0;

        /// @}

        /// @name Contact Member Functions
        /// Member functions relating to contacts.
        /// @{

        /// @brief Gets the extent of the currently valid contact range.
        /// @note This is one higher than the maxium <code>ContactID</code> that is in range
        ///   for contact related functions.
        virtual ContactCounter GetContactRange_() const noexcept = 0;

        /// @brief Gets the world contact range.
        /// @warning contacts are created and destroyed in the middle of a time step.
        /// Use <code>ContactListener</code> to avoid missing contacts.
        /// @return World contacts sized-range.
        virtual std::vector<KeyedContactID> GetContacts_() const = 0;

        /// @brief Gets the identified contact.
        /// @throws std::out_of_range If given an invalid contact identifier.
        /// @see SetContact_, GetContactRange_.
        virtual Contact GetContact_(ContactID id) const = 0;

        /// @brief Sets the identified contact's state.
        /// @note This may throw an exception or update associated entities to preserve invariants.
        /// @invariant A contact may only be impenetrable if one or both bodies are.
        /// @invariant A contact may only be active if one or both bodies are awake.
        /// @invariant A contact may only be a sensor or one or both shapes are.
        /// @throws std::out_of_range If given an invalid contact identifier.
        /// @throws InvalidArgument if a change would violate an invariant or if the specified ID
        ///   was destroyed.
        /// @see GetContact_, GetContactRange_.
        virtual void SetContact_(ContactID id, const Contact& value) = 0;

        /// @brief Gets the collision manifold for the identified contact.
        /// @throws std::out_of_range If given an invalid contact identifier.
        /// @see GetContact_, GetContactRange_.
        virtual Manifold GetManifold_(ContactID id) const = 0;

        /// @}
    };

    template <class T>
    struct Model;

    /// @brief Pointer to implementation (PIMPL)
    /// @see https://en.cppreference.com/w/cpp/language/pimpl
    propagate_const<std::unique_ptr<Concept>> m_impl;
};

/// @brief Interface between type class template instantiated for and Concept class.
/// @see Concept.
template <class T>
struct World::Model final: World::Concept {
    /// @brief Type alias for the type of the data held.
    using data_type = T;

    /// @brief Initializing constructor.
    template <typename U, std::enable_if_t<!std::is_same_v<U, Model>, int> = 0>
    explicit Model(U&& arg) noexcept(std::is_nothrow_constructible_v<T, U>)
        : data{std::forward<U>(arg)}
    {
        // Intentionally empty.
    }

    /// @name Listener Member Functions
    /// @{

    /// @copydoc Concept::SetShapeDestructionListener_
    void SetShapeDestructionListener_(ShapeListener listener) noexcept override
    {
        SetShapeDestructionListener(data, std::move(listener));
    }

    /// @copydoc Concept::SetDetachListener_
    void SetDetachListener_(AssociationListener listener) noexcept override
    {
        SetDetachListener(data, std::move(listener));
    }

    /// @copydoc Concept::SetJointDestructionListener_
    void SetJointDestructionListener_(JointListener listener) noexcept override
    {
        SetJointDestructionListener(data, std::move(listener));
    }

    /// @copydoc Concept::SetBeginContactListener_
    void SetBeginContactListener_(ContactListener listener) noexcept override
    {
        SetBeginContactListener(data, std::move(listener));
    }

    /// @copydoc Concept::SetEndContactListener_
    void SetEndContactListener_(ContactListener listener) noexcept override
    {
        SetEndContactListener(data, std::move(listener));
    }

    /// @copydoc Concept::SetPreSolveContactListener_
    void SetPreSolveContactListener_(ManifoldContactListener listener) noexcept override
    {
        SetPreSolveContactListener(data, std::move(listener));
    }

    /// @copydoc Concept::SetPostSolveContactListener_
    void SetPostSolveContactListener_(ImpulsesContactListener listener) noexcept override
    {
        SetPostSolveContactListener(data, std::move(listener));
    }

    /// @}

    /// @name Miscellaneous Member Functions
    /// @{

    /// @copydoc Concept::Clone_
    std::unique_ptr<Concept> Clone_() const override
    {
        return std::make_unique<Model<T>>(data);
    }

    /// @copydoc Concept::GetType_
    TypeID GetType_() const noexcept override
    {
        return GetTypeID<data_type>();
    }

    /// @copydoc Concept::GetData_
    const void* GetData_() const noexcept override
    {
        // Note address of "data" not necessarily same as address of "this" since
        // base class is virtual.
        return &data;
    }

    /// @copydoc Concept::GetData_
    void* GetData_() noexcept override
    {
        // Note address of "data" not necessarily same as address of "this" since
        // base class is virtual.
        return &data;
    }

    /// @copydoc Concept::GetResourceStats_
    std::optional<pmr::StatsResource::Stats> GetResourceStats_() const noexcept override
    {
        return GetResourceStats(data);
    }

    /// @copydoc Concept::Clear_
    void Clear_() noexcept override
    {
        Clear(data);
    }

    /// @copydoc Concept::Step_
    StepStats Step_(const StepConf& conf) override
    {
        return Step(data, conf);
    }

    /// @copydoc Concept::IsStepComplete_
    bool IsStepComplete_() const noexcept override
    {
        return IsStepComplete(data);
    }

    /// @copydoc Concept::GetSubStepping_
    bool GetSubStepping_() const noexcept override
    {
        return GetSubStepping(data);
    }

    /// @copydoc Concept::SetSubStepping_
    void SetSubStepping_(bool flag) noexcept override
    {
        SetSubStepping(data, flag);
    }

    /// @copydoc Concept::GetTree_
    const DynamicTree& GetTree_() const noexcept override
    {
        return GetTree(data);
    }

    /// @copydoc Concept::IsLocked_
    bool IsLocked_() const noexcept override
    {
        return IsLocked(data);
    }

    /// @copydoc Concept::ShiftOrigin_
    void ShiftOrigin_(const Length2& newOrigin) override
    {
        ShiftOrigin(data, newOrigin);
    }

    /// @copydoc Concept::GetVertexRadiusInterval_
    Interval<Positive<Length>> GetVertexRadiusInterval_() const noexcept override
    {
        return GetVertexRadiusInterval(data);
    }

    /// @copydoc Concept::GetInvDeltaTime_
    Frequency GetInvDeltaTime_() const noexcept override
    {
        return GetInvDeltaTime(data);
    }

    /// @}

    /// @name Body Member Functions.
    /// Member functions relating to bodies.
    /// @{

    /// @copydoc Concept::GetBodyRange_
    BodyCounter GetBodyRange_() const noexcept override
    {
        return GetBodyRange(data);
    }

    /// @copydoc Concept::GetBodies_
    std::vector<BodyID> GetBodies_() const override
    {
        return GetBodies(data);
    }

    /// @copydoc Concept::GetBodiesForProxies_
    std::vector<BodyID> GetBodiesForProxies_() const override
    {
        return GetBodiesForProxies(data);
    }

    /// @copydoc Concept::CreateBody_
    BodyID CreateBody_(const Body& body) override
    {
        return CreateBody(data, body);
    }

    /// @copydoc Concept::GetBody_
    Body GetBody_(BodyID id) const override
    {
        return GetBody(data, id);
    }

    /// @copydoc Concept::SetBody_
    void SetBody_(BodyID id, const Body& value) override
    {
        SetBody(data, id, value);
    }

    /// @copydoc Concept::Destroy_(BodyID)
    void Destroy_(BodyID id) override
    {
        Destroy(data, id);
    }

    /// @copydoc Concept::GetJoints_(BodyID)
    std::vector<std::pair<BodyID, JointID>> GetJoints_(BodyID id) const override
    {
        return GetJoints(data, id);
    }

    /// @copydoc Concept::GetContacts_(BodyID)
    std::vector<std::tuple<ContactKey, ContactID>> GetContacts_(BodyID id) const override
    {
        return GetContacts(data, id);
    }

    /// @copydoc Concept::GetShapes_
    std::vector<ShapeID> GetShapes_(BodyID id) const override
    {
        return GetShapes(data, id);
    }

    /// @}

    /// @name Joint Member Functions
    /// Member functions relating to joints.
    /// @{

    /// @copydoc Concept::GetJointRange_
    JointCounter GetJointRange_() const noexcept override
    {
        return GetJointRange(data);
    }

    /// @copydoc Concept::GetJoints_
    std::vector<JointID> GetJoints_() const override
    {
        return GetJoints(data);
    }

    /// @copydoc Concept::CreateJoint_
    JointID CreateJoint_(const Joint& def) override
    {
        return CreateJoint(data, def);
    }

    /// @copydoc Concept::GetJoint_
    Joint GetJoint_(JointID id) const override
    {
        return GetJoint(data, id);
    }

    /// @copydoc Concept::SetJoint_
    void SetJoint_(JointID id, const Joint& def) override
    {
        return SetJoint(data, id, def);
    }

    /// @copydoc Concept::Destroy_
    void Destroy_(JointID id) override
    {
        return Destroy(data, id);
    }

    /// @}

    /// @name Shape Member Functions
    /// Member functions relating to shapes.
    /// @{

    /// @copydoc Concept::GetShapeRange_
    ShapeCounter GetShapeRange_() const noexcept override
    {
        return GetShapeRange(data);
    }

    /// @copydoc Concept::CreateShape_
    ShapeID CreateShape_(const Shape& def) override
    {
        return CreateShape(data, def);
    }

    /// @copydoc Concept::GetShape_
    Shape GetShape_(ShapeID id) const override
    {
        return GetShape(data, id);
    }

    /// @copydoc Concept::SetShape_
    void SetShape_(ShapeID id, const Shape& def) override
    {
        SetShape(data, id, def);
    }

    /// @copydoc Concept::Destroy_
    void Destroy_(ShapeID id) override
    {
        Destroy(data, id);
    }

    /// @}

    /// @name Contact Member Functions
    /// Member functions relating to contacts.
    /// @{

    /// @copydoc Concept::GetContactRange_
    ContactCounter GetContactRange_() const noexcept override
    {
        return GetContactRange(data);
    }

    /// @copydoc Concept::GetContacts_
    std::vector<KeyedContactID> GetContacts_() const override
    {
        return GetContacts(data);
    }

    /// @copydoc Concept::GetContact_
    Contact GetContact_(ContactID id) const override
    {
        return GetContact(data, id);
    }

    /// @copydoc Concept::SetContact_
    void SetContact_(ContactID id, const Contact& value) override
    {
        SetContact(data, id, value);
    }

    /// @copydoc Concept::GetManifold_
    Manifold GetManifold_(ContactID id) const override
    {
        return GetManifold(data, id);
    }

    /// @}

    data_type data; ///< Data.
};

// State & confirm intended compile-time traits of World class...
static_assert(std::is_default_constructible_v<World>);
static_assert(std::is_copy_constructible_v<World>);
static_assert(std::is_copy_assignable_v<World>);
static_assert(std::is_nothrow_move_constructible_v<World>);
static_assert(std::is_nothrow_move_assignable_v<World>);

inline World::~World() noexcept
{
    if (m_impl) { // for proper handling after being moved from
        // Call implementation's clear while World still valid to give destruction
        // listening callbacks chance to run while world data is still valid.
        m_impl->Clear_();
    }
}

// World Listener Non-Member Functions...

inline void SetShapeDestructionListener(World& world, ShapeListener listener) noexcept
{
    world.m_impl->SetShapeDestructionListener_(std::move(listener));
}

inline void SetDetachListener(World& world, AssociationListener listener) noexcept
{
    world.m_impl->SetDetachListener_(std::move(listener));
}

inline void SetJointDestructionListener(World& world, JointListener listener) noexcept
{
    world.m_impl->SetJointDestructionListener_(std::move(listener));
}

inline void SetBeginContactListener(World& world, ContactListener listener) noexcept
{
    world.m_impl->SetBeginContactListener_(std::move(listener));
}

inline void SetEndContactListener(World& world, ContactListener listener) noexcept
{
    world.m_impl->SetEndContactListener_(std::move(listener));
}

inline void SetPreSolveContactListener(World& world, ManifoldContactListener listener) noexcept
{
    world.m_impl->SetPreSolveContactListener_(std::move(listener));
}

inline void SetPostSolveContactListener(World& world, ImpulsesContactListener listener) noexcept
{
    world.m_impl->SetPostSolveContactListener_(std::move(listener));
}

// World Miscellaneous Non-Member Functions...

inline TypeID GetType(const World& world) noexcept
{
    return world.m_impl->GetType_();
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

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_D2_WORLD_HPP

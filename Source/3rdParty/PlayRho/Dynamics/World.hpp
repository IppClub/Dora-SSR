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

#ifndef PLAYRHO_DYNAMICS_WORLD_HPP
#define PLAYRHO_DYNAMICS_WORLD_HPP

/// @file
/// Declarations of the World class.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/propagate_const.hpp"

#include "PlayRho/Collision/MassData.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"
#include "PlayRho/Collision/Shapes/ShapeID.hpp"

#include "PlayRho/Dynamics/BodyConf.hpp" // for GetDefaultBodyConf
#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/StepStats.hpp"
#include "PlayRho/Dynamics/WorldConf.hpp"
#include "PlayRho/Dynamics/Contacts/KeyedContactID.hpp" // for KeyedContactPtr
#include "PlayRho/Dynamics/Joints/JointID.hpp"

#include <iterator>
#include <vector>
#include <memory> // for std::unique_ptr
#include <stdexcept>
#include <functional> // for std::function
#include <type_traits> // for std::add_pointer_t, std::add_const_t

namespace playrho {

struct StepConf;
struct Filter;

namespace d2 {

class WorldImpl;
class Body;
class Joint;
class Contact;
class Manifold;
class ContactImpulsesList;
class DynamicTree;

/// @defgroup PhysicalEntities Physical Entities
///
/// @brief Concepts and types associated with physical entities within a world.
///
/// @details Concepts and types of creatable and destroyable instances that associate
///   physical properties to simulations. These instances are typically created via a
///   method whose name begins with the prefix of <code>Create</code>. Similarly, these
///   instances are typically destroyed using a method whose name begins with the prefix
///   of <code>Destroy</code>.
///
/// @note For example, the following could be used to create a dynamic body having a one meter
///   radius disk shape:
/// @code{.cpp}
/// auto world = World{};
/// const auto shape = world.CreateShape(Shape{DiskShapeConf{1_m}});
/// const auto body = world.CreateBody(BodyConf{}.Use(BodyType::Dynamic).Use(shape));
/// @endcode
///
/// @see World.
/// @see BodyID, World::CreateBody, World::Destroy(BodyID), World::GetBodies().
/// @see ShapeID, World::CreateShape, World::Destroy(ShapeID).
/// @see JointID, World::CreateJoint, World::Destroy(JointID), World::GetJoints().
/// @see ContactID, World::GetContacts().
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
/// @note This data structure is 8-bytes large (on at least one 64-bit platform).
///
/// @attention For example, the following could be used to create a dynamic body having a one
///   meter radius disk shape:
/// @code{.cpp}
/// auto world = World{};
/// const auto shape = world.CreateShape(Shape{DiskShapeConf{1_m}});
/// const auto body = world.CreateBody(BodyConf{}.Use(BodyType::Dynamic).Use(shape));
/// @endcode
///
/// @see BodyID, ContactID, ShapeID, JointID, PhysicalEntities.
/// @see https://en.wikipedia.org/wiki/Non-virtual_interface_pattern
/// @see https://en.wikipedia.org/wiki/Application_binary_interface
/// @see https://en.cppreference.com/w/cpp/language/pimpl
///
class World
{
public:
    /// @brief Container type for Shape identifiers.
    using Shapes = std::vector<ShapeID>;

    /// @brief Container type for Body identifiers.
    using Bodies = std::vector<BodyID>;

    /// @brief Container type for keyed contact identifiers.
    using Contacts = std::vector<KeyedContactPtr>;

    /// @brief Container type for Joint identifiers.
    using Joints = std::vector<JointID>;

    /// @brief Container type for Body associated Joint identifiers.
    using BodyJoints = std::vector<std::pair<BodyID, JointID>>;

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

    /// @name Special Member Functions
    /// Special member functions that are explicitly defined.
    /// @{

    /// @brief Constructs a world object.
    /// @param def A customized world configuration or its default value.
    /// @note A lot more configurability can be had via the <code>StepConf</code>
    ///   data that's given to the world's <code>Step</code> method.
    /// @throws InvalidArgument if the given max vertex radius is less than the min.
    /// @see Step.
    explicit World(const WorldConf& def = GetDefaultWorldConf());

    /// @brief Copy constructor.
    /// @details Copy constructs this world with a deep copy of the given world.
    World(const World& other);

    /// @brief Assignment operator.
    /// @details Copy assigns this world with a deep copy of the given world.
    World& operator=(const World& other);

    /// @brief Destructor.
    /// @details All physics entities are destroyed and all memory is released.
    /// @note This will call the <code>Clear()</code> function.
    /// @see Clear.
    ~World() noexcept;

    /// @}

    /// @name Listener Member Functions
    /// @{

    /// @brief Registers a destruction listener for shapes.
    void SetShapeDestructionListener(ShapeListener listener) noexcept;

    /// @brief Registers a detach listener for shapes detaching from bodies.
    void SetDetachListener(AssociationListener listener) noexcept;

    /// @brief Registers a destruction listener for joints.
    void SetJointDestructionListener(const JointListener& listener) noexcept;

    /// @brief Registers a begin contact event listener.
    void SetBeginContactListener(ContactListener listener) noexcept;

    /// @brief Registers an end contact event listener.
    void SetEndContactListener(ContactListener listener) noexcept;

    /// @brief Registers a pre-solve contact event listener.
    void SetPreSolveContactListener(ManifoldContactListener listener) noexcept;

    /// @brief Registers a post-solve contact event listener.
    void SetPostSolveContactListener(ImpulsesContactListener listener) noexcept;

    /// @}

    /// @name Miscellaneous Member Functions
    /// @{

    /// @brief Clears this world.
    /// @note This calls the joint and fixture destruction listeners (if they're set)
    ///   before clearing anything.
    /// @post The contents of this world have all been destroyed and this world's internal
    ///   state is reset as though it had just been constructed.
    void Clear() noexcept;

    /// @brief Steps the world simulation according to the given configuration.
    ///
    /// @details
    /// Performs position and velocity updating, sleeping of non-moving bodies, updating
    /// of the contacts, and notifying the contact listener of begin-contact, end-contact,
    /// pre-solve, and post-solve events.
    ///
    /// @warning Behavior is undefined if given a negative step time delta.
    /// @warning Varying the step time delta may lead to non-physical behaviors.
    ///
    /// @note Calling this with a zero step time delta results only in fixtures and bodies
    ///   registered for special handling being processed. No physics is performed.
    /// @note If the given velocity and position iterations are zero, this method doesn't
    ///   do velocity or position resolutions respectively of the contacting bodies.
    /// @note While body velocities are updated accordingly (per the sum of forces acting on them),
    ///   body positions (barring any collisions) are updated as if they had moved the entire time
    ///   step at those resulting velocities. In other words, a body initially at position 0
    ///   (<code>p0</code>) going velocity 0 (<code>v0</code>) fast with a sum acceleration of
    ///   <code>a</code>, after time <code>t</code> and barring any collisions, will have a new
    ///   velocity (<code>v1</code>) of <code>v0 + (a * t)</code> and a new position
    ///   (<code>p1</code>) of <code>p0 + v1 * t</code>.
    ///
    /// @post Static bodies are unmoved.
    /// @post Kinetic bodies are moved based on their previous velocities.
    /// @post Dynamic bodies are moved based on their previous velocities, gravity, applied
    ///   forces, applied impulses, masses, damping, and the restitution and friction values
    ///   of their fixtures when they experience collisions.
    ///
    /// @param conf Configuration for the simulation step.
    ///
    /// @return Statistics for the step.
    ///
    /// @throws WrongState if this method is called while the world is locked.
    ///
    StepStats Step(const StepConf& conf = StepConf{});

    /// @brief Whether or not "step" is complete.
    /// @details The "step" is completed when there are no more TOI events for the current time
    /// step.
    /// @return <code>true</code> unless sub-stepping is enabled and the step method returned
    ///   without finishing all of its sub-steps.
    /// @see GetSubStepping, SetSubStepping.
    bool IsStepComplete() const noexcept;

    /// @brief Gets whether or not sub-stepping is enabled.
    /// @see SetSubStepping, IsStepComplete.
    bool GetSubStepping() const noexcept;

    /// @brief Enables/disables single stepped continuous physics.
    /// @note This is not normally used. Enabling sub-stepping is meant for testing.
    /// @post The <code>GetSubStepping()</code> method will return the value this method was
    ///   called with.
    /// @see IsStepComplete, GetSubStepping.
    void SetSubStepping(bool flag) noexcept;

    /// @brief Gets access to the broad-phase dynamic tree information.
    /// @todo Consider removing this function. This function exposes the implementation detail
    ///   of the broad-phase contact detection system.
    const DynamicTree& GetTree() const noexcept;

    /// @brief Is the world locked (in the middle of a time step).
    bool IsLocked() const noexcept;

    /// @brief Shifts the world origin.
    /// @note Useful for large worlds.
    /// @note The body shift formula is: <code>position -= newOrigin</code>.
    /// @post The "origin" of this world's bodies, joints, and the board-phase dynamic tree
    ///   have been translated per the shift amount and direction.
    /// @param newOrigin the new origin with respect to the old origin
    /// @throws WrongState if this method is called while the world is locked.
    void ShiftOrigin(Length2 newOrigin);

    /// @brief Gets the minimum vertex radius that shapes in this world can be.
    /// @see GetMaxVertexRadius.
    Length GetMinVertexRadius() const noexcept;

    /// @brief Gets the maximum vertex radius that shapes in this world can be.
    /// @see GetMinVertexRadius.
    Length GetMaxVertexRadius() const noexcept;

    /// @brief Gets the inverse delta time.
    /// @details Gets the inverse delta time that was set on construction or assignment, and
    ///   updated on every call to the <code>Step()</code> method having a non-zero delta-time.
    /// @see Step.
    Frequency GetInvDeltaTime() const noexcept;

    /// @}

    /// @name Body Member Functions.
    /// Member functions relating to bodies.
    /// @{

    /// @brief Gets the extent of the currently valid body range.
    /// @note This is one higher than the maxium <code>BodyID</code> that is in range
    ///   for body related functions.
    BodyCounter GetBodyRange() const noexcept;

    /// @brief Gets the world body range for this constant world.
    /// @details Gets a range enumerating the bodies currently existing within this world.
    ///   These are the bodies that had been created from previous calls to the
    ///   <code>CreateBody(const BodyConf&)</code> method that haven't yet been destroyed.
    /// @return An iterable of body identifiers.
    /// @see CreateBody(const BodyConf&).
    Bodies GetBodies() const noexcept;

    /// @brief Gets the bodies-for-proxies range for this world.
    /// @details Provides insight on what bodies have been queued for proxy processing
    ///   during the next call to the world step method.
    /// @see Step.
    /// @todo Remove this function from this class - access from implementation instead.
    Bodies GetBodiesForProxies() const noexcept;

    /// @brief Creates a rigid body that's a copy of the given one.
    /// @warning This function should not be used while the world is locked &mdash; as it is
    ///   during callbacks. If it is, it will throw an exception or abort your program.
    /// @note No references to the configuration are retained. Its value is copied.
    /// @post The created body will be present in the range returned from the
    ///   <code>GetBodies()</code> method.
    /// @param body A customized body or its default value.
    /// @return Identifier of the newly created body which can later be destroyed by calling
    ///   the <code>Destroy(BodyID)</code> method.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws LengthError if this operation would create more than <code>MaxBodies</code>.
    /// @throws std::out_of_range if the given body references any invalid shape identifiers.
    /// @see Destroy(BodyID), GetBodies.
    /// @see PhysicalEntities.
    BodyID CreateBody(const Body& body);

    /// @brief Gets the state of the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see SetBody, GetBodyRange.
    const Body& GetBody(BodyID id) const;

    /// @brief Sets the state of the identified body.
    /// @throws std::out_of_range if given an invalid id of if the given body references any
    ///   invalid shape identifiers.
    /// @throws InvalidArgument if the specified ID was destroyed.
    /// @see GetBody, GetBodyRange.
    void SetBody(BodyID id, const Body& value);

    /// @brief Destroys the identified body.
    /// @details Destroys the identified body that had previously been created by a call to this
    ///   world's <code>CreateBody(const BodyConf&)</code> method.
    /// @warning This automatically deletes all associated shapes and joints.
    /// @warning This function is locked during callbacks.
    /// @warning Behavior is undefined if the identified body was not created by this world.
    /// @note This function is locked during callbacks.
    /// @post The destroyed body will no longer be present in the range returned from the
    ///   <code>GetBodies()</code> method.
    /// @param id Identifier of body to destroy that had been created by this world.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see CreateBody(const BodyConf&), GetBodies, GetBodyRange.
    /// @see PhysicalEntities.
    void Destroy(BodyID id);

    /// @brief Gets the range of joints attached to the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see CreateJoint, GetBodyRange.
    BodyJoints GetJoints(BodyID id) const;

    /// @brief Gets the container of contacts attached to the identified body.
    /// @warning This collection changes during the time step and you may
    ///   miss some collisions if you don't use <code>ContactListener</code>.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see GetBodyRange.
    Contacts GetContacts(BodyID id) const;

    /// @brief Gets the identities of the shapes associated with the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see GetBodyRange, CreateBody, SetBody.
    Shapes GetShapes(BodyID id) const;

    /// @}

    /// @name Joint Member Functions
    /// Member functions relating to joints.
    /// @{

    /// @brief Gets the extent of the currently valid joint range.
    /// @note This is one higher than the maxium <code>JointID</code> that is in range
    ///   for joint related functions.
    JointCounter GetJointRange() const noexcept;

    /// @brief Gets the world joint range.
    /// @details Gets a range enumerating the joints currently existing within this world.
    ///   These are the joints that had been created from previous calls to the
    ///   <code>CreateJoint</code> method that haven't yet been destroyed.
    /// @return World joints sized-range.
    /// @see CreateJoint.
    Joints GetJoints() const noexcept;

    /// @brief Creates a joint to constrain one or more bodies.
    /// @warning This function is locked during callbacks.
    /// @post The created joint will be present in the range returned from the
    ///   <code>GetJoints()</code> method.
    /// @return Identifier of newly created joint which can later be destroyed by calling the
    ///   <code>Destroy(JointID)</code> method.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws LengthError if this operation would create more than <code>MaxJoints</code>.
    /// @see PhysicalEntities.
    /// @see Destroy(JointID), GetJoints.
    JointID CreateJoint(const Joint& def);

    /// @brief Gets the value of the identified joint.
    /// @throws std::out_of_range If given an invalid joint identifier.
    /// @see SetJoint, GetJointRange.
    const Joint& GetJoint(JointID id) const;

    /// @brief Sets the identified joint to the given value.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws std::out_of_range If given an invalid joint identifier.
    /// @throws InvalidArgument if the specified ID was destroyed.
    /// @see GetJoint, GetJointRange.
    void SetJoint(JointID id, const Joint& def);

    /// @brief Destroys the identified joint.
    /// @details Destroys the identified joint that had previously been created by a call to this
    ///   world's <code>CreateJoint(const Joint&)</code> method.
    /// @warning This function is locked during callbacks.
    /// @note This may cause the connected bodies to begin colliding.
    /// @post The destroyed joint will no longer be present in the range returned from the
    ///   <code>GetJoints()</code> method.
    /// @param id Identifier of joint to destroy that had been created by this world.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws std::out_of_range If given an invalid joint identifier.
    /// @see CreateJoint(const Joint&), GetJoints, GetJointRange.
    /// @see PhysicalEntities.
    void Destroy(JointID id);

    /// @}

    /// @name Shape Member Functions
    /// Member functions relating to shapes.
    /// @{

    /// @brief Gets the extent of the currently valid shape range.
    /// @note This is one higher than the maxium <code>ShapeID</code> that is in range
    ///   for shape related functions.
    ShapeCounter GetShapeRange() const noexcept;

    /// @brief Creates an identifiable copy of the given shape within this world.
    /// @throws InvalidArgument if called for a shape with a vertex radius that's either:
    ///    less than the minimum vertex radius, or greater than the maximum vertex radius.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws LengthError if this operation would create more than <code>MaxShapes</code>.
    /// @see Destroy(ShapeID), GetShape, SetShape.
    ShapeID CreateShape(const Shape& def);

    /// @throws std::out_of_range If given an invalid shape identifier.
    /// @see CreateShape.
    const Shape& GetShape(ShapeID id) const;

    /// @brief Sets the identified shape to the new value.
    /// @throws std::out_of_range If given an invalid shape identifier.
    /// @throws InvalidArgument if the specified ID was destroyed.
    /// @see CreateShape.
    void SetShape(ShapeID, const Shape& def);

    /// @brief Destroys the identified shape.
    /// @throws std::out_of_range If given an invalid shape identifier.
    /// @see CreateShape.
    void Destroy(ShapeID id);

    /// @}

    /// @name Contact Member Functions
    /// Member functions relating to contacts.
    /// @{

    /// @brief Gets the extent of the currently valid contact range.
    /// @note This is one higher than the maxium <code>ContactID</code> that is in range
    ///   for contact related functions.
    ContactCounter GetContactRange() const noexcept;

    /// @brief Gets the world contact range.
    /// @warning contacts are created and destroyed in the middle of a time step.
    /// Use <code>ContactListener</code> to avoid missing contacts.
    /// @return World contacts sized-range.
    Contacts GetContacts() const noexcept;

    /// @brief Gets the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see SetContact, GetContactRange.
    const Contact& GetContact(ContactID id) const;

    /// @brief Sets the identified contact's state.
    /// @note This may throw an exception or update associated entities to preserve invariants.
    /// @invariant A contact may only be impenetrable if one or both bodies are.
    /// @invariant A contact may only be active if one or both bodies are awake.
    /// @invariant A contact may only be a sensor or one or both shapes are.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @throws InvalidArgument if a change would violate an invariant or if the specified ID
    ///   was destroyed.
    /// @see GetContact, GetContactRange.
    void SetContact(ContactID id, const Contact& value);

    /// @brief Gets the collision manifold for the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see GetContact, GetContactRange.
    const Manifold& GetManifold(ContactID id) const;

    /// @}

private:
    /// @brief Pointer to implementation (PIMPL)
    /// @see https://en.cppreference.com/w/cpp/language/pimpl
    propagate_const<std::unique_ptr<WorldImpl>> m_impl;
};

/// @example HelloWorld.cpp
/// This is the source file for the <code>HelloWorld</code> application that demonstrates
/// use of the <code>playrho::d2::World</code> class and more.

/// @example World.cpp
/// This is the <code>googletest</code> based unit testing file for the
/// <code>playrho::d2::World</code> class.

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLD_HPP

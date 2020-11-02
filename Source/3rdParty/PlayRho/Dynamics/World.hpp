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
#include "PlayRho/Common/Range.hpp" // for SizedRange
#include "PlayRho/Common/propagate_const.hpp"

#include "PlayRho/Collision/MassData.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"

#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/FixtureID.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp" // for GetDefaultBodyConf
#include "PlayRho/Dynamics/StepStats.hpp"
#include "PlayRho/Dynamics/Contacts/KeyedContactID.hpp" // for KeyedContactPtr
#include "PlayRho/Dynamics/FixtureConf.hpp"
#include "PlayRho/Dynamics/WorldConf.hpp"
#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/JointID.hpp"
#include "PlayRho/Dynamics/Joints/JointType.hpp"

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
class Manifold;
class ContactImpulsesList;
class DynamicTree;
struct JointConf;

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
/// const auto body = world.CreateBody(BodyConf{}.UseType(BodyType::Dynamic));
/// const auto fixture = world.CreateFixture(body, Shape{DiskShapeConf{1_m}});
/// @endcode
///
/// @see World.
/// @see BodyID, World::CreateBody, World::Destroy(BodyID), World::GetBodies().
/// @see FixtureID, World::CreateFixture, World::Destroy(FixtureID).
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
///   fixture, and joint entities. These are identified by <code>BodyID</code>,
///   <code>ContactID</code>, <code>FixtureID</code>, and <code>JointID</code> values respectively.
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
/// const auto body = world.CreateBody(BodyConf{}.UseType(BodyType::Dynamic));
/// const auto fixture = world.CreateFixture(body, Shape{DiskShapeConf{1_m}});
/// @endcode
///
/// @see BodyID, ContactID, FixtureID, JointID, PhysicalEntities.
/// @see https://en.wikipedia.org/wiki/Non-virtual_interface_pattern
/// @see https://en.wikipedia.org/wiki/Application_binary_interface
/// @see https://en.cppreference.com/w/cpp/language/pimpl
///
class World
{
public:
    /// @brief Bodies container type.
    using Bodies = std::vector<BodyID>;

    /// @brief Contacts container type.
    using Contacts = std::vector<KeyedContactPtr>;

    /// @brief Joints container type.
    /// @note Cannot be container of Joint instances since joints are polymorphic types.
    using Joints = std::vector<JointID>;

    /// @brief Body joints container type.
    using BodyJoints = std::vector<std::pair<BodyID, JointID>>;

    /// @brief Fixtures container type.
    using Fixtures = std::vector<FixtureID>;

    /// @brief Fixture listener.
    using FixtureListener = std::function<void(FixtureID)>;

    /// @brief Joint listener.
    using JointListener = std::function<void(JointID)>;

    /// @brief Contact listener.
    using ContactListener = std::function<void(ContactID)>;

    /// @brief Manifold contact listener.
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
    /// @post The state of this world is like that of the given world except this world now
    ///   has deep copies of the given world with pointers having the new addresses of the
    ///   new memory required for those copies.
    World(const World& other);

    /// @brief Assignment operator.
    /// @details Copy assigns this world with a deep copy of the given world.
    /// @post The state of this world is like that of the given world except this world now
    ///   has deep copies of the given world with pointers having the new addresses of the
    ///   new memory required for those copies.
    /// @warning This method should not be called while the world is locked!
    /// @throws WrongState if this method is called while the world is locked.
    World& operator=(const World& other);

    /// @brief Destructor.
    /// @details All physics entities are destroyed and all allocated memory is released.
    /// @note This will call the <code>Clear()</code> function.
    /// @see Clear.
    ~World() noexcept;

    /// @}

    /// @name Listener Member Functions
    /// @{

    /// @brief Register a destruction listener for fixtures.
    void SetFixtureDestructionListener(const FixtureListener& listener) noexcept;

    /// @brief Register a destruction listener for joints.
    void SetJointDestructionListener(const JointListener& listener) noexcept;

    /// @brief Register a begin contact event listener.
    void SetBeginContactListener(ContactListener listener) noexcept;

    /// @brief Register an end contact event listener.
    void SetEndContactListener(ContactListener listener) noexcept;

    /// @brief Register a pre-solve contact event listener.
    void SetPreSolveContactListener(ManifoldContactListener listener) noexcept;

    /// @brief Register a post-solve contact event listener.
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
    ///   registered for proxy handling being processed. No physics is performed.
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
    /// @post The bodies for proxies queue will be empty.
    /// @post The fixtures for proxies queue will be empty.
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
    Length GetMinVertexRadius() const noexcept;

    /// @brief Gets the maximum vertex radius that shapes in this world can be.
    Length GetMaxVertexRadius() const noexcept;

    /// @brief Gets the inverse delta time.
    /// @details Gets the inverse delta time that was set on construction or assignment, and
    ///   updated on every call to the <code>Step()</code> method having a non-zero delta-time.
    /// @see Step.
    Frequency GetInvDeltaTime() const noexcept;

    /// @brief Gets the shape count.
    /// @todo Consider removing this function.
    FixtureCounter GetShapeCount() const noexcept;

    /// @}

    /// @name Body Member Functions
    /// Member functions relating to bodies.
    /// @{

    /// @brief Gets the extent of the currently valid body range.
    /// @note This is one higher than the maxium BodyID that is in range for body related
    ///   functions.
    BodyCounter GetBodyRange() const noexcept;

    /// @brief Gets the world body range for this constant world.
    /// @details Gets a range enumerating the bodies currently existing within this world.
    ///   These are the bodies that had been created from previous calls to the
    ///   <code>CreateBody(const BodyConf&)</code> method that haven't yet been destroyed.
    /// @return Body range that can be iterated over using its begin and end methods
    ///   or using ranged-based for-loops.
    /// @see CreateBody(const BodyConf&).
    SizedRange<Bodies::const_iterator> GetBodies() const noexcept;

    /// @brief Gets the bodies-for-proxies range for this world.
    /// @details Provides insight on what bodies have been queued for proxy processing
    ///   during the next call to the world step method.
    /// @see Step.
    SizedRange<Bodies::const_iterator> GetBodiesForProxies() const noexcept;

    /// @brief Creates a rigid body with the given configuration.
    /// @warning This function should not be used while the world is locked &mdash; as it is
    ///   during callbacks. If it is, it will throw an exception or abort your program.
    /// @note No references to the configuration are retained. Its value is copied.
    /// @post The created body will be present in the range returned from the
    ///   <code>GetBodies()</code> method.
    /// @param def A customized body configuration or its default value.
    /// @return Identifier of the newly created body which can later be destroyed by calling
    ///   the <code>Destroy(BodyID)</code> method.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws LengthError if this operation would create more than <code>MaxBodies</code>.
    /// @see Destroy(BodyID), GetBodies.
    /// @see PhysicalEntities.
    BodyID CreateBody(const BodyConf& def = GetDefaultBodyConf());

    /// @brief Destroys the given body.
    /// @details Destroys a given body that had previously been created by a call to this
    ///   world's <code>CreateBody(const BodyConf&)</code> method.
    /// @warning This automatically deletes all associated shapes and joints.
    /// @warning This function is locked during callbacks.
    /// @warning Behavior is undefined if given a null body.
    /// @warning Behavior is undefined if the passed body was not created by this world.
    /// @note This function is locked during callbacks.
    /// @post The destroyed body will no longer be present in the range returned from the
    ///   <code>GetBodies()</code> method.
    /// @post None of the body's fixtures will be present in the fixtures-for-proxies
    ///   collection.
    /// @param id Body to destroy that had been created by this world.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see CreateBody(const BodyConf&), GetBodies.
    /// @see PhysicalEntities.
    void Destroy(BodyID id);

    /// @brief Gets the type of this body.
    BodyType GetType(BodyID id) const;

    /// @brief Sets the type of the given body.
    /// @note This may alter the body's mass and velocity.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws std::out_of_range If given an invalid body identifier.
    void SetType(BodyID id, BodyType type);

    /// @brief Destroys fixtures of the given body.
    /// @details Destroys all of the fixtures previously created for this body by the
    ///   <code>CreateFixture(const Shape&, const FixtureConf&, bool)</code> method.
    /// @note This unconditionally calls the <code>ResetMassData()</code> method.
    /// @post After this call, no fixtures will show up in the fixture enumeration
    ///   returned by the <code>GetFixtures()</code> methods.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see CreateFixture, GetFixtures, ResetMassData.
    /// @see PhysicalEntities
    void DestroyFixtures(BodyID id);

    /// @brief Gets the enabled/disabled state of the body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see SetEnabled(BodyID).
    bool IsEnabled(BodyID id) const;

    /// @brief Sets the enabled state of the body.
    ///
    /// @details A disabled body is not simulated and cannot be collided with or woken up.
    ///   If you pass a flag of true, all fixtures will be added to the broad-phase.
    ///   If you pass a flag of false, all fixtures will be removed from the broad-phase
    ///   and all contacts will be destroyed. Fixtures and joints are otherwise unaffected.
    ///
    /// @note A disabled body is still owned by a World object and remains in the world's
    ///   body container.
    /// @note You may continue to create/destroy fixtures and joints on disabled bodies.
    /// @note Fixtures on a disabled body are implicitly disabled and will not participate in
    ///   collisions, ray-casts, or queries.
    /// @note Joints connected to a disabled body are implicitly disabled.
    ///
    /// @throws WrongState If call would change body's state when world is locked.
    /// @throws std::out_of_range If given an invalid body identifier.
    ///
    /// @post <code>IsEnabled()</code> returns the state given to this function.
    ///
    /// @see IsEnabled(BodyID).
    ///
    void SetEnabled(BodyID id, bool flag);

    /// @brief Gets the range of all joints attached to this body.
    /// @throws std::out_of_range If given an invalid body identifier.
    SizedRange<World::BodyJoints::const_iterator> GetJoints(BodyID id) const;

    /// @brief Computes the body's mass data.
    /// @details This basically accumulates the mass data over all fixtures.
    /// @return accumulated mass data for all fixtures associated with the given body.
    /// @throws std::out_of_range If given an invalid body identifier.
    MassData ComputeMassData(BodyID id) const;

    /// @brief Set the mass properties to override the mass properties of the fixtures.
    /// @note This changes the center of mass position.
    /// @note Creating or destroying fixtures can also alter the mass.
    /// @note This function has no effect if the body isn't dynamic.
    /// @param id Identifier of the body to change.
    /// @param massData the mass properties.
    /// @throws std::out_of_range If given an invalid body identifier.
    void SetMassData(BodyID id, const MassData& massData);

    /// @brief Gets the body configuration for the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    BodyConf GetBodyConf(BodyID id) const;

    /// @brief Gets the range of all constant fixtures attached to the given body.
    /// @throws std::out_of_range If given an invalid body identifier.
    SizedRange<Fixtures::const_iterator> GetFixtures(BodyID id) const;

    /// @brief Get the angle.
    /// @return the current world rotation angle.
    /// @throws std::out_of_range If given an invalid body identifier.
    Angle GetAngle(BodyID id) const;

    /// @brief Gets the body's transformation.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see SetTransformation(BodyID id, Transformation xfm).
    Transformation GetTransformation(BodyID id) const;

    /// @brief Sets the transformation of the body.
    /// @details This instantly adjusts the body to be at the new transformation.
    /// @warning Manipulating a body's transformation can cause non-physical behavior!
    /// @note Contacts are updated on the next call to World::Step.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see GetTransformation(BodyID id).
    void SetTransformation(BodyID id, Transformation xfm);

    /// @brief Gets the local position of the center of mass of the specified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    Length2 GetLocalCenter(BodyID id) const;

    /// @brief Gets the world position of the center of mass of the specified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    Length2 GetWorldCenter(BodyID id) const;

    /// @brief Gets the velocity of the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see SetVelocity(BodyID id, const Velocity& value).
    Velocity GetVelocity(BodyID id) const;

    /// @brief Sets the body's velocity (linear and angular velocity).
    /// @note This method does nothing if this body is not speedable.
    /// @note A non-zero velocity will awaken this body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see GetVelocity(BodyID), SetAwake, SetUnderActiveTime.
    void SetVelocity(BodyID id, const Velocity& value);

    /// @brief Gets the awake/asleep state of this body.
    /// @warning Being awake may or may not imply being speedable.
    /// @return true if the body is awake.
    /// @throws std::out_of_range If given an invalid body identifier.
    bool IsAwake(BodyID id) const;

    /// @brief Wakes up the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    void SetAwake(BodyID id);

    /// @brief Sleeps the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see IsAwake(BodyID id), SetAwake(BodyID id).
    void UnsetAwake(BodyID id);

    /// @brief Gets this body's linear acceleration.
    /// @throws std::out_of_range If given an invalid body identifier.
    LinearAcceleration2 GetLinearAcceleration(BodyID id) const;

    /// @brief Gets this body's angular acceleration.
    /// @throws std::out_of_range If given an invalid body identifier.
    AngularAcceleration GetAngularAcceleration(BodyID id) const;

    /// @brief Sets the linear and rotational accelerations on the body.
    /// @note This has no effect on non-accelerable bodies.
    /// @note A non-zero acceleration will also awaken the body.
    /// @param id Body whose acceleration should be set.
    /// @param linear Linear acceleration.
    /// @param angular Angular acceleration.
    /// @throws std::out_of_range If given an invalid body identifier.
    void SetAcceleration(BodyID id, LinearAcceleration2 linear, AngularAcceleration angular);

    /// @brief Gets the linear damping of the body.
    /// @throws std::out_of_range If given an invalid body identifier.
    Frequency GetLinearDamping(BodyID id) const;

    /// @brief Sets the linear damping of the body.
    /// @throws std::out_of_range If given an invalid body identifier.
    void SetLinearDamping(BodyID id, NonNegative<Frequency> value);

    /// @brief Gets the angular damping of the body.
    /// @throws std::out_of_range If given an invalid body identifier.
    Frequency GetAngularDamping(BodyID id) const;

    /// @brief Sets the angular damping of the body.
    /// @throws std::out_of_range If given an invalid body identifier.
    void SetAngularDamping(BodyID id, NonNegative<Frequency> angularDamping);

    /// @brief Gets whether the body's mass-data is dirty.
    /// @throws std::out_of_range If given an invalid body identifier.
    bool IsMassDataDirty(BodyID id) const;

    /// @brief Gets whether the body has fixed rotation.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see SetFixedRotation(BodyID id, bool value).
    bool IsFixedRotation(BodyID id) const;

    /// @brief Sets the body to have fixed rotation.
    /// @note This causes the mass to be reset.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see IsFixedRotation(BodyID id).
    void SetFixedRotation(BodyID id, bool value);

    /// @brief Gets the inverse total mass of the body.
    /// @return Value of zero or more representing the body's inverse mass (in 1/kg).
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see SetMassData.
    InvMass GetInvMass(BodyID id) const;

    /// @brief Gets the inverse rotational inertia of the body.
    /// @return Inverse rotational inertia (in 1/kg-m^2).
    /// @throws std::out_of_range If given an invalid body identifier.
    InvRotInertia GetInvRotInertia(BodyID id) const;

    /// @brief Is identified body "speedable".
    /// @details Is the body able to have a non-zero speed associated with it.
    /// Kinematic and Dynamic bodies are speedable. Static bodies are not.
    /// @throws std::out_of_range If given an invalid body identifier.
    bool IsSpeedable(BodyID id) const;

    /// @brief Is identified body "accelerable"?
    /// @details Indicates whether the body is accelerable, i.e. whether it is effected by
    ///   forces. Only Dynamic bodies are accelerable.
    /// @return true if the body is accelerable, false otherwise.
    /// @throws std::out_of_range If given an invalid body identifier.
    bool IsAccelerable(BodyID id) const;

    /// @brief Is the body treated like a bullet for continuous collision detection?
    /// @throws std::out_of_range If given an invalid body identifier.
    bool IsImpenetrable(BodyID id) const;

    /// @brief Sets the bullet status of this body.
    /// @details Sets that the body should be treated like a bullet for continuous
    ///   collision detection.
    /// @throws std::out_of_range If given an invalid body identifier.
    void SetImpenetrable(BodyID id);

    /// @brief Unsets the bullet status of this body.
    /// @throws std::out_of_range If given an invalid body identifier.
    void UnsetImpenetrable(BodyID id);

    /// @brief Gets whether or not the identified body allowed to sleep.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see SetSleepingAllowed
    bool IsSleepingAllowed(BodyID id) const;

    /// @brief Sets whether sleeping is allowed for the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see IsSleepingAllowed
    void SetSleepingAllowed(BodyID id, bool value);

    /// @brief Gets the container of all contacts attached to the body.
    /// @warning This collection changes during the time step and you may
    ///   miss some collisions if you don't use <code>ContactListener</code>.
    /// @throws std::out_of_range If given an invalid body identifier.
    SizedRange<World::Contacts::const_iterator> GetContacts(BodyID id) const;

    /// @}

    /// @name Fixture Member Functions
    /// Member functions relating to fixtures.
    /// @{

    /// @brief Creates a fixture and attaches it to the given body.
    /// @details Creates a fixture for attaching a shape and other characteristics to this
    ///   body. Fixtures automatically go away when this body is destroyed. Fixtures can
    ///   also be manually removed and destroyed using the
    ///   <code>Destroy(FixtureID, bool)</code>, or <code>DestroyFixtures()</code> methods.
    ///
    /// @note This function should not be called if the world is locked.
    /// @warning This function is locked during callbacks.
    ///
    /// @post After creating a new fixture, it will show up in the fixture enumeration
    ///   returned by the <code>GetFixtures()</code> methods.
    ///
    /// @param def Initial fixture settings.
    ///   Friction and density must be >= 0.
    ///   Restitution must be > -infinity and < infinity.
    /// @param resetMassData Whether or not to reset the mass data of the body.
    ///
    /// @return Identifier for the created fixture.
    ///
    /// @throws WrongState if called while the world is "locked".
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @throws InvalidArgument if called for a shape with a vertex radius less than the
    ///    minimum vertex radius.
    /// @throws InvalidArgument if called for a shape with a vertex radius greater than the
    ///    maximum vertex radius.
    ///
    /// @see Destroy(FixtureID), GetFixtures
    /// @see PhysicalEntities
    ///
    FixtureID CreateFixture(const FixtureConf& def = FixtureConf{}, bool resetMassData = true);

    /// @brief Gets the identified fixture state.
    /// @throws std::out_of_range If given an invalid fixture identifier.
    const FixtureConf& GetFixture(FixtureID id) const;

    /// @brief Sets the identified fixture's state.
    /// @throws std::out_of_range If given an invalid fixture identifier.
    void SetFixture(FixtureID id, const FixtureConf& value);

    /// @brief Destroys the identified fixture.
    ///
    /// @details Destroys a fixture previously created by the
    ///   <code>CreateFixture(const Shape&, const FixtureConf&, bool)</code>
    ///   method. This removes the fixture from the broad-phase and destroys all contacts
    ///   associated with this fixture. All fixtures attached to a body are implicitly
    ///   destroyed when the body is destroyed.
    ///
    /// @warning This function is locked during callbacks.
    /// @note Make sure to explicitly call <code>ResetMassData()</code> after fixtures have
    ///   been destroyed if resetting the mass data is not requested via the reset mass data
    ///   parameter.
    /// @throws WrongState if this function is called while the world is locked.
    /// @throws std::out_of_range If given an invalid fixture identifier.
    ///
    /// @post After destroying a fixture, it will no longer show up in the fixture enumeration
    ///   returned by the <code>GetFixtures()</code> methods.
    ///
    /// @param id the fixture to be removed.
    /// @param resetMassData Whether or not to reset the mass data of the associated body.
    ///
    /// @see CreateFixture, Body::GetFixtures, Body::ResetMassData.
    /// @see PhysicalEntities
    ///
    bool Destroy(FixtureID id, bool resetMassData = true);

    /// @brief Re-filter contacts and proxies for the identified fixture.
    /// @note Call this if you want to establish collision that was previously disabled.
    /// @throws std::out_of_range If given an invalid fixture identifier.
    /// @see SetFilterData, GetFilterData.
    void Refilter(FixtureID id);

    /// @}

    /// @name Joint Member Functions
    /// Member functions relating to joints.
    /// @{

    /// @brief Gets the world joint range.
    /// @details Gets a range enumerating the joints currently existing within this world.
    ///   These are the joints that had been created from previous calls to the
    ///   <code>CreateJoint(const JointConf&)</code> method that haven't yet been destroyed.
    /// @return World joints sized-range.
    /// @see CreateJoint(const JointConf&).
    SizedRange<Joints::const_iterator> GetJoints() const noexcept;

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

    /// @brief Destroys the identified joint.
    /// @details Destroys a given joint that had previously been created by a call to this
    ///   world's <code>CreateJoint(const Joint&)</code> method.
    /// @warning This function is locked during callbacks.
    /// @note This may cause the connected bodies to begin colliding.
    /// @post The destroyed joint will no longer be present in the range returned from the
    ///   <code>GetJoints()</code> method.
    /// @param id Joint to destroy that had been created by this world.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws std::out_of_range If given an invalid joint identifier.
    /// @see CreateJoint(const Joint&), GetJoints.
    /// @see PhysicalEntities.
    void Destroy(JointID id);

    /// @brief Gets the value of the identified joint.
    /// @throws std::out_of_range If given an invalid joint identifier.
    const Joint& GetJoint(JointID id) const;

    /// @brief Sets the identified joint to the given value.
    /// @throws std::out_of_range If given an invalid joint identifier.
    void SetJoint(JointID id, const Joint& def);

    /// @}

    /// @name Contact Member Functions
    /// Member functions relating to contacts.
    /// @{

    /// @brief Gets the world contact range.
    /// @warning contacts are created and destroyed in the middle of a time step.
    /// Use <code>ContactListener</code> to avoid missing contacts.
    /// @return World contacts sized-range.
    SizedRange<Contacts::const_iterator> GetContacts() const noexcept;

    /// @brief Gets the awake status of the specified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see SetAwake(ContactID id)
    bool IsAwake(ContactID id) const;

    /// @brief Sets the awake status of the specified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see IsAwake(ContactID id)
    void SetAwake(ContactID id);

    /// @brief Gets the desired tangent speed.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see SetTangentSpeed(ContactID id, LinearVelocity value).
    LinearVelocity GetTangentSpeed(ContactID id) const;

    /// @brief Sets the desired tangent speed for a conveyor belt behavior.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see GetTangentSpeed(ContactID id) const.
    void SetTangentSpeed(ContactID id, LinearVelocity value);

    /// @brief Is this contact touching?
    /// @details
    /// Touching is defined as either:
    ///   1. This contact's manifold has more than 0 contact points, or
    ///   2. This contact has sensors and the two shapes of this contact are found to be
    ///      overlapping.
    /// @return true if this contact is said to be touching, false otherwise.
    /// @throws std::out_of_range If given an invalid contact identifier.
    bool IsTouching(ContactID id) const;

    /// @brief Whether or not the contact needs filtering.
    /// @throws std::out_of_range If given an invalid contact identifier.
    bool NeedsFiltering(ContactID id) const;

    /// @brief Whether or not the contact needs updating.
    /// @throws std::out_of_range If given an invalid contact identifier.
    bool NeedsUpdating(ContactID id) const;

    /// @brief Gets body-A of the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    BodyID GetBodyA(ContactID id) const;

    /// @brief Gets body-B of the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    BodyID GetBodyB(ContactID id) const;

    /// @brief Gets fixture A of the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    FixtureID GetFixtureA(ContactID id) const;

    /// @brief Gets fixture B of the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    FixtureID GetFixtureB(ContactID id) const;

    /// @brief Get the child primitive index for fixture A.
    /// @throws std::out_of_range If given an invalid contact identifier.
    ChildCounter GetChildIndexA(ContactID id) const;

    /// @brief Get the child primitive index for fixture B.
    /// @throws std::out_of_range If given an invalid contact identifier.
    ChildCounter GetChildIndexB(ContactID id) const;

    /// @brief Whether or not the contact has a valid TOI.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see GetToi.
    bool HasValidToi(ContactID id) const;

    /// @brief Gets the time of impact (TOI) as a fraction.
    /// @note This is only valid if a TOI has been set.
    /// @return Time of impact fraction in the range of 0 to 1 if set (where 1
    ///   means no actual impact in current time slot), otherwise undefined.
    /// @throws std::out_of_range If given an invalid contact identifier.
    Real GetToi(ContactID id) const;

    /// @brief Gets the time of impact count of the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    TimestepIters GetToiCount(ContactID id) const;

    /// @brief Gets the default friction value for the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    Real GetDefaultFriction(ContactID id) const;

    /// @brief Gets the default restitution value for the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    Real GetDefaultRestitution(ContactID id) const;

    /// @brief Gets the friction used with the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see SetFriction(ContactID id, Real value)
    Real GetFriction(ContactID id) const;

    /// @brief Gets the restitution used with the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see SetRestitution(ContactID id, Real value)
    Real GetRestitution(ContactID id) const;

    /// @brief Sets the friction value for the identified contact.
    /// @details Overrides the default friction mixture.
    /// @note You can call this in "pre-solve" listeners.
    /// @note This value persists until set or reset.
    /// @warning Behavior is undefined if given a negative friction value.
    /// @param id Contact identifier.
    /// @param value Co-efficient of friction value of zero or greater.
    /// @throws std::out_of_range If given an invalid contact identifier.
    void SetFriction(ContactID id, Real value);

    /// @brief Sets the restitution value for the identified contact.
    /// @details This override the default restitution mixture.
    /// @note You can call this in "pre-solve" listeners.
    /// @note The value persists until you set or reset.
    /// @throws std::out_of_range If given an invalid contact identifier.
    void SetRestitution(ContactID id, Real value);

    /// @brief Gets the collision manifold for the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    const Manifold& GetManifold(ContactID id) const;

    /// @brief Gets whether or not the identified contact is enabled.
    /// @throws std::out_of_range If given an invalid contact identifier.
    bool IsEnabled(ContactID id) const;

    /// @brief Enables the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    void SetEnabled(ContactID id);

    /// @brief Disables the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    void UnsetEnabled(ContactID id);

    /// @}

private:
    /// @brief Pointer to implementation (PIMPL)
    /// @see https://en.cppreference.com/w/cpp/language/pimpl
    propagate_const<std::unique_ptr<WorldImpl>> m_impl;
};

/// @example HelloWorld.cpp
/// This is the source file for the <code>HelloWorld</code> application that demonstrates
/// use of the <code>playrho::d2::World</code> class and more.
/// After instantiating a world, the code creates a body and its fixture to act as the ground,
/// creates another body and a fixture for it to act like a ball, then steps the world using
/// the world <code>playrho::d2::World::Step(const StepConf&)</code> function which simulates a ball
/// falling to the ground and outputs the position of the ball after each step.

/// @example World.cpp
/// This is the <code>googletest</code> based unit testing file for the
/// <code>playrho::d2::World</code> class.

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLD_HPP

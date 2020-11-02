/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_WORLDIMPL_HPP
#define PLAYRHO_DYNAMICS_WORLDIMPL_HPP

/// @file
/// Declarations of the WorldImpl class.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Range.hpp" // for SizedRange
#include "PlayRho/Common/Positive.hpp"
#include "PlayRho/Common/ArrayAllocator.hpp"

#include "PlayRho/Collision/DynamicTree.hpp"
#include "PlayRho/Collision/MassData.hpp"

#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/Filter.hpp"
#include "PlayRho/Dynamics/Island.hpp"
#include "PlayRho/Dynamics/FixtureID.hpp"
#include "PlayRho/Dynamics/FixtureConf.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp" // for GetDefaultBodyConf
#include "PlayRho/Dynamics/StepStats.hpp"
#include "PlayRho/Dynamics/Contacts/ContactKey.hpp"
#include "PlayRho/Dynamics/Contacts/KeyedContactID.hpp" // for KeyedContactPtr
#include "PlayRho/Dynamics/WorldConf.hpp"
#include "PlayRho/Dynamics/Joints/JointID.hpp"
#include "PlayRho/Dynamics/Joints/JointType.hpp"
#include "PlayRho/Dynamics/IslandStats.hpp"

#include <iterator>
#include <vector>
#include <map>
#include <memory>
#include <stack>
#include <stdexcept>
#include <functional>

namespace playrho {

struct StepConf;
enum class BodyType;

namespace d2 {

struct JointConf;
class Body;
class Contact;
class Joint;
class Shape;
class Manifold;
class ContactImpulsesList;

/// @brief Definition of a "world" implementation.
/// @see World.
class WorldImpl {
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

    /// @brief Proxy ID type alias.
    using ProxyId = DynamicTree::Size;

    /// @brief Proxy container type alias.
    using Proxies = std::vector<ProxyId>;

    using FixtureListener = std::function<void(FixtureID)>;
    using JointListener = std::function<void(JointID)>;
    using ContactListener = std::function<void(ContactID)>;
    using ManifoldContactListener = std::function<void(ContactID, const Manifold&)>;
    using ImpulsesContactListener = std::function<void(ContactID, const ContactImpulsesList&, unsigned)>;

    struct ContactUpdateConf;

    /// @name Special Member Functions
    /// Special member functions that are explicitly defined.
    /// @{

    /// @brief Constructs a world implementation for a world.
    /// @param def A customized world configuration or its default value.
    /// @note A lot more configurability can be had via the <code>StepConf</code>
    ///   data that's given to the world's <code>Step</code> method.
    /// @throws InvalidArgument if the given max vertex radius is less than the min.
    /// @see Step.
    explicit WorldImpl(const WorldConf& def = GetDefaultWorldConf());

    /// @brief Copy constructor.
    WorldImpl(const WorldImpl& other) = default;

    WorldImpl& operator=(const WorldImpl& other) = default;

    /// @brief Destructor.
    /// @details All physics entities are destroyed and all dynamically allocated memory
    ///    is released.
    ~WorldImpl() noexcept;

    /// @}

    /// @name Listener Member Functions
    /// @{

    /// @brief Register a destruction listener for fixtures.
    void SetFixtureDestructionListener(FixtureListener listener) noexcept;

    /// @brief Register a destruction listener for joints.
    void SetJointDestructionListener(JointListener listener) noexcept;

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
    /// @post The contents of this world have all been destroyed and this world's internal
    ///   state reset as though it had just been constructed.
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
    /// @see GetBodiesForProxies, GetFixturesForProxies.
    ///
    StepStats Step(const StepConf& conf);

    /// @brief Whether or not "step" is complete.
    /// @details The "step" is completed when there are no more TOI events for the current time step.
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

    /// @brief Gets the dynamic tree leaves queued for finding new contacts.
    /// @see FindNewContacts, AddProxies.
    const Proxies& GetProxies() const noexcept;

    /// @brief Adds the given dynamic tree leaves to the queue for finding new contacts.
    /// @see GetProxies, FindNewContacts.
    void AddProxies(const Proxies& proxies);

    /// @brief Finds new contacts.
    /// @details Processes the proxy queue for finding new contacts and adding them to
    ///   the contacts container.
    /// @note New contacts will all have overlapping AABBs.
    /// @post <code>GetProxies()</code> will return an empty container.
    /// @see GetProxies.
    ContactCounter FindNewContacts();

    /// @}

    /// @name Body Member Functions
    /// Member functions relating to bodies.
    /// @{

    /// @brief Gets the world body range for this constant world.
    /// @details Gets a range enumerating the bodies currently existing within this world.
    ///   These are the bodies that had been created from previous calls to the
    ///   <code>CreateBody(const BodyConf&)</code> method that haven't yet been destroyed.
    /// @return Body range that can be iterated over using its begin and end methods
    ///   or using ranged-based for-loops.
    /// @see CreateBody(const BodyConf&).
    SizedRange<Bodies::const_iterator> GetBodies() const noexcept;

    /// @brief Gets the extent of the currently valid body range.
    /// @note This is one higher than the maxium BodyID that is in range for body related
    ///   functions.
    BodyCounter GetBodyRange() const noexcept;

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
    /// @see CreateBody(const BodyConf&), GetBodies, GetFixturesForProxies.
    /// @see PhysicalEntities.
    void Destroy(BodyID id);

    /// @brief Sets the type of the given body.
    /// @note This may alter the body's mass and velocity.
    /// @throws WrongState if this method is called while the world is locked.
    void SetType(BodyID id, playrho::BodyType type);

    /// @brief Destroys fixtures of the given body.
    /// @details Destroys all of the fixtures previously created for this body by the
    ///   <code>CreateFixture(const Shape&, const FixtureConf&, bool)</code> method.
    /// @note This unconditionally calls the <code>ResetMassData()</code> method.
    /// @post After this call, no fixtures will show up in the fixture enumeration
    ///   returned by the <code>GetFixtures()</code> methods.
    /// @see CreateFixture, GetFixtures, ResetMassData.
    /// @see PhysicalEntities
    void DestroyFixtures(BodyID id);

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
    ///
    /// @post <code>IsEnabled()</code> returns the state given to this function.
    ///
    void SetEnabled(BodyID id, bool flag);

    /// @brief Computes the mass data of the identified body.
    MassData ComputeMassData(BodyID id) const;

    /// @brief Set the mass properties to override the mass properties of the fixtures.
    /// @note This changes the center of mass position.
    /// @note Creating or destroying fixtures can also alter the mass.
    /// @note This function has no effect if the body isn't dynamic.
    /// @param id Body to set mass data for.
    /// @param massData the mass properties.
    void SetMassData(BodyID id, const MassData& massData);

    /// @brief Sets the transformation of the body.
    /// @details This instantly adjusts the body to have the new transformation.
    /// @warning Manipulating a body's transform can cause non-physical behavior!
    /// @warning Behavior is undefined if the value is invalid.
    /// @note Associated contacts may be flagged for updating on the next call to WorldImpl::Step.
    /// @throws WrongState If call would change body's state when world is locked.
    void SetTransformation(BodyID id, Transformation xfm);

    /// @throws std::out_of_range if given an invalid id.
    const Body& GetBody(BodyID id) const;

    /// @throws std::out_of_range if given an invalid id.
    Body& GetBody(BodyID id);

    /// @brief Flags the contacts of the identified body for updating.
    /// @details Calling this function will flag every contact of the identified body
    ///   for updating in the next step.
    void FlagContactsForUpdating(BodyID id);

    /// @brief Gets the contacts associated with the identified body.
    /// @throws std::out_of_range if given an invalid id.
    SizedRange<WorldImpl::Contacts::const_iterator> GetContacts(BodyID id) const;

    /// @throws std::out_of_range if given an invalid id.
    SizedRange<WorldImpl::BodyJoints::const_iterator> GetJoints(BodyID id) const;

    /// @brief Gets the range of all constant fixtures attached to this body.
    SizedRange<WorldImpl::Fixtures::const_iterator> GetFixtures(BodyID id) const;

    /// @}

    /// @name Fixture Member Functions
    /// Member functions relating to fixtures.
    /// @{

    /// @brief Creates a fixture with the given parameters.
    /// @details Creates a fixture for attaching a shape and other characteristics to the
    ///   given body. Fixtures automatically go away when the body is destroyed. Fixtures can
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
    /// @throws InvalidArgument if called for a shape with a vertex radius less than the
    ///    minimum vertex radius.
    /// @throws InvalidArgument if called for a shape with a vertex radius greater than the
    ///    maximum vertex radius.
    ///
    /// @see Destroy, GetFixtures
    /// @see PhysicalEntities
    ///
    FixtureID CreateFixture(const FixtureConf& def = FixtureConf{},
                            bool resetMassData = true);

    /// @brief Destroys a fixture.
    /// @details This removes the fixture from the broad-phase and destroys all contacts
    ///   associated with this fixture.
    ///   All fixtures attached to a body are implicitly destroyed when the body is destroyed.
    /// @warning This function is locked during callbacks.
    /// @note Make sure to explicitly call <code>Body::ResetMassData</code> after fixtures have
    ///   been destroyed.
    /// @param fixture the fixture to be removed.
    /// @param resetMassData Whether or not to reset the mass data of the associated body.
    /// @see Body::ResetMassData.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws std::out_of_range If given an invalid fixture identifier.
    bool Destroy(FixtureID fixture, bool resetMassData = true);

    /// @brief Gets the identified fixture state.
    /// @throws std::out_of_range If given an invalid fixture identifier.
    const FixtureConf& GetFixture(FixtureID id) const;

    /// @brief Sets the identified fixture's state.
    /// @throws std::out_of_range If given an invalid fixture identifier.
    void SetFixture(FixtureID id, const FixtureConf& value);

    /// @brief Gets the fixtures-for-proxies range for this world.
    /// @details Provides insight on what fixtures have been queued for proxy processing
    ///   during the next call to the world step method.
    /// @see Step.
    SizedRange<Fixtures::const_iterator> GetFixturesForProxies() const noexcept;

    /// @brief Gets the proxies for the identified fixture.
    /// @throws std::out_of_range If given an invalid fixture identifier.
    const Proxies& GetProxies(FixtureID id) const;

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
    /// @note No references to the configuration are retained. Its value is copied.
    /// @post The created joint will be present in the range returned from the
    ///   <code>GetJoints()</code> method.
    /// @return Identifier for the newly created joint which can later be destroyed by calling
    ///   the <code>Destroy(JointID)</code> method.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws LengthError if this operation would create more than <code>MaxJoints</code>.
    /// @throws InvalidArgument if the given definition is not allowed.
    /// @see PhysicalEntities.
    /// @see Destroy(JointID), GetJoints.
    JointID CreateJoint(const Joint& def);

    /// @brief Destroys a joint.
    /// @details Destroys a given joint that had previously been created by a call to this
    ///   world's <code>CreateJoint(const JointConf&)</code> method.
    /// @warning This function is locked during callbacks.
    /// @warning Behavior is undefined if the passed joint was not created by this world.
    /// @note This may cause the connected bodies to begin colliding.
    /// @post The destroyed joint will no longer be present in the range returned from the
    ///   <code>GetJoints()</code> method.
    /// @param joint Joint to destroy that had been created by this world.
    /// @throws WrongState if this method is called while the world is locked.
    /// @see CreateJoint(const JointConf&), GetJoints.
    /// @see PhysicalEntities.
    void Destroy(JointID joint);

    const Joint& GetJoint(JointID id) const;
    Joint& GetJoint(JointID id);

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

    const Contact& GetContact(ContactID id) const;
    Contact& GetContact(ContactID id);

    const Manifold& GetManifold(ContactID id) const;
    Manifold& GetManifold(ContactID id);

    /// @}

private:
    /// @brief Flags type data type.
    using FlagsType = std::uint32_t;

    /// @brief Flag enumeration.
    enum Flag: FlagsType
    {
        /// New fixture.
        e_newFixture    = 0x0001,

        /// Locked.
        e_locked        = 0x0002,

        /// Sub-stepping.
        e_substepping   = 0x0020,

        /// Step complete. @details Used for sub-stepping. @see e_substepping.
        e_stepComplete  = 0x0040,
    };

    /// @brief Contact key queue type alias.
    using ContactKeyQueue = std::vector<ContactKey>;

    /// @brief Solves the step.
    /// @details Finds islands, integrates and solves constraints, solves position constraints.
    /// @note This may miss collisions involving fast moving bodies and allow them to tunnel
    ///   through each other.
    RegStepStats SolveReg(const StepConf& conf);

    /// @brief Solves the given island (regularly).
    ///
    /// @details This:
    ///   1. Updates every island-body's <code>sweep.pos0</code> to its <code>sweep.pos1</code>.
    ///   2. Updates every island-body's <code>sweep.pos1</code> to the new normalized "solved"
    ///      position for it.
    ///   3. Updates every island-body's velocity to the new accelerated, dampened, and "solved"
    ///      velocity for it.
    ///   4. Synchronizes every island-body's transform (by updating it to transform one of the
    ///      body's sweep).
    ///   5. Reports to the listener (if non-null).
    ///
    /// @param conf Time step configuration information.
    /// @param island Island of bodies, contacts, and joints to solve for. Must contain at least
    ///   one body, contact, or joint.
    ///
    /// @warning Behavior is undefined if the given island doesn't have at least one body,
    ///   contact, or joint.
    ///
    /// @return Island solver results.
    ///
    IslandStats SolveRegIslandViaGS(const StepConf& conf, const Island& island);
    
    /// @brief Adds to the island based off of a given "seed" body.
    /// @post Contacts are listed in the island in the order that bodies provide those contacts.
    /// @post Joints are listed the island in the order that bodies provide those joints.
    void AddToIsland(Island& island, BodyID seed,
                     BodyCounter& remNumBodies,
                     ContactCounter& remNumContacts,
                     JointCounter& remNumJoints);
    
    /// @brief Body stack.
    using BodyStack = std::stack<BodyID, std::vector<BodyID>>;
    
    /// @brief Adds to the island.
    void AddToIsland(Island& island, BodyStack& stack,
                     BodyCounter& remNumBodies,
                     ContactCounter& remNumContacts,
                     JointCounter& remNumJoints);
    
    /// @brief Adds contacts to the island.
    void AddContactsToIsland(Island& island, BodyStack& stack, const Contacts& contacts,
                             BodyID bodyID);

    /// @brief Adds joints to the island.
    void AddJointsToIsland(Island& island, BodyStack& stack, const BodyJoints& joints);
    
    /// @brief Removes <em>unspeedables</em> from the is <em>is-in-island</em> state.
    static Bodies::size_type RemoveUnspeedablesFromIslanded(const std::vector<BodyID>& bodies,
                                                            const ArrayAllocator<Body>& buffer,
                                                            std::vector<bool>& islanded);
    
    /// @brief Solves the step using successive time of impact (TOI) events.
    /// @details Used for continuous physics.
    /// @note This is intended to detect and prevent the tunneling that the faster Solve method
    ///    may miss.
    /// @param conf Time step configuration to use.
    ToiStepStats SolveToi(const StepConf& conf);

    /// @brief Solves collisions for the given time of impact.
    ///
    /// @param contactID Identifier of contact to solve for.
    /// @param conf Time step configuration to solve for.
    ///
    /// @note Precondition 1: there is no contact having a lower TOI in this time step that has
    ///   not already been solved for.
    /// @note Precondition 2: there is not a lower TOI in the time step for which collisions have
    ///   not already been processed.
    ///
    IslandStats SolveToi(ContactID contactID, const StepConf& conf);

    /// @brief Solves the time of impact for bodies 0 and 1 of the given island.
    ///
    /// @details This:
    ///   1. Updates position 0 of the sweeps of bodies 0 and 1.
    ///   2. Updates position 1 of the sweeps, the transforms, and the velocities of the other
    ///      bodies in this island.
    ///
    /// @pre <code>island.bodies</code> contains at least two bodies, the first two of which
    ///   are bodies 0 and 1.
    /// @pre <code>island.bodies</code> contains appropriate other bodies of the contacts of
    ///   the two bodies.
    /// @pre <code>island.contacts</code> contains the contact that specified the two identified
    ///   bodies.
    /// @pre <code>island.contacts</code> contains appropriate other contacts of the two bodies.
    ///
    /// @param conf Time step configuration information.
    /// @param island Island to do time of impact solving for.
    ///
    /// @return Island solver results.
    ///
    IslandStats SolveToiViaGS(const Island& island, const StepConf& conf);

    /// @brief Updates the given body.
    /// @details Updates the given body's sweep position 1, and its transformation.
    /// @param body Body to update.
    /// @param pos New position to set the given body to.
    /// @return <code>true</code> if body's contacts should be flagged for updating,
    ///   otherwise <code>false</code>.
    static bool UpdateBody(Body& body, const Position& pos);

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
    ///   4. Adds to the island, those other bodies that haven't already been added of the contacts that got added.
    /// @note Precondition: there should be no lower TOI for which contacts have not already been processed.
    /// @param[in,out] id Identifier of the dynamic/accelerable body to process contacts for.
    /// @param[in,out] island Island. On return this may contain additional contacts or bodies.
    /// @param[in] toi Time of impact (TOI). Value between 0 and 1.
    /// @param[in] conf Step configuration data.
    ProcessContactsOutput ProcessContactsForTOI(BodyID id, Island& island, Real toi,
                                                const StepConf& conf);

    /// @brief Removes the given body from this world.
    void Remove(BodyID id) noexcept;

    /// @brief Adds the given fixture to the given body.
    void AddFixture(BodyID id, FixtureID fixture);

    /// @brief Removes the given fixture from the given body.
    bool RemoveFixture(BodyID id, FixtureID fixture);

    /// @brief Updates associated bodies and contacts for specified joint's addition.
    void Add(JointID j, bool flagForFiltering = false);

    /// @brief Updates associated bodies and contacts for specified joint's removal.
    void Remove(JointID id) noexcept;

    /// @brief Sets the step complete state.
    /// @post <code>IsStepComplete()</code> will return the value set.
    /// @see IsStepComplete.
    void SetStepComplete(bool value) noexcept;

    /// @brief Sets the allow sleeping state.
    void SetAllowSleeping() noexcept;

    /// @brief Unsets the allow sleeping state.
    void UnsetAllowSleeping() noexcept;

    /// @brief Update contacts statistics.
    struct UpdateContactsStats
    {
        /// @brief Number of contacts ignored (because both bodies were asleep).
        ContactCounter ignored = 0;

        /// @brief Number of contacts updated.
        ContactCounter updated = 0;

        /// @brief Number of contacts skipped because they weren't marked as needing updating.
        ContactCounter skipped = 0;
    };

    /// @brief Destroy contacts statistics.
    struct DestroyContactsStats
    {
        ContactCounter ignored = 0; ///< Ignored.
        ContactCounter erased = 0; ///< Erased.
    };

    /// @brief Contact TOI data.
    struct ContactToiData
    {
        ContactID contact = InvalidContactID; ///< Contact for which the time of impact is relevant.
        Real toi = std::numeric_limits<Real>::infinity(); ///< Time of impact (TOI) as a fractional value between 0 and 1.
        ContactCounter simultaneous = 0; ///< Count of simultaneous contacts at this TOI.
    };

    /// @brief Update contacts data.
    struct UpdateContactsData
    {
        ContactCounter numAtMaxSubSteps = 0; ///< # at max sub-steps (lower the better).
        ContactCounter numUpdatedTOI = 0; ///< # updated TOIs (made valid).
        ContactCounter numValidTOI = 0; ///< # already valid TOIs.

        /// @brief Distance iterations type alias.
        using dist_iter_type = std::remove_const<decltype(DefaultMaxDistanceIters)>::type;

        /// @brief TOI iterations type alias.
        using toi_iter_type = std::remove_const<decltype(DefaultMaxToiIters)>::type;

        /// @brief Root iterations type alias.
        using root_iter_type = std::remove_const<decltype(DefaultMaxToiRootIters)>::type;

        dist_iter_type maxDistIters = 0; ///< Max distance iterations.
        toi_iter_type maxToiIters = 0; ///< Max TOI iterations.
        root_iter_type maxRootIters = 0; ///< Max root iterations.
    };

    /// @brief Updates the contact times of impact.
    static UpdateContactsData UpdateContactTOIs(ArrayAllocator<Contact>& contactBuffer,
                                                ArrayAllocator<Body>& bodyBuffer,
                                                const ArrayAllocator<FixtureConf>& fixtureBuffer,
                                                const Contacts& contacts, const StepConf& conf);

    /// @brief Gets the soonest contact.
    /// @details This finds the contact with the lowest (soonest) time of impact.
    /// @return Contact with the least time of impact and its time of impact, or null contact.
    ///  A non-null contact will be enabled, not have sensors, be active, and impenetrable.
    static ContactToiData GetSoonestContact(const Contacts& contacts,
                                            const ArrayAllocator<Contact>& buffer) noexcept;
    
    /// @brief Determines whether this world has new fixtures.
    bool HasNewFixtures() const noexcept;
    
    /// @brief Unsets the new fixtures state.
    void UnsetNewFixtures() noexcept;

    /// @brief Processes the narrow phase collision for the contacts collection.
    /// @details
    /// This finds and destroys the contacts that need filtering and no longer should collide or
    /// that no longer have AABB-based overlapping fixtures. Those contacts that persist and
    /// have active bodies (either or both) get their Update methods called with the current
    /// contact listener as its argument.
    /// Essentially this really just purges contacts that are no longer relevant.
    DestroyContactsStats DestroyContacts(Contacts& contacts);
    
    /// @brief Update contacts.
    UpdateContactsStats UpdateContacts(const StepConf& conf);

    /// @brief Destroys the given contact and removes it from its container.
    /// @details This updates the contacts container, returns the memory to the allocator,
    ///   and decrements the contact manager's contact count.
    /// @param contact Contact to destroy.
    /// @param from From body.
    void Destroy(ContactID contact, Body* from);

    /// @brief Adds a contact for the proxies identified by the key if appropriate.
    /// @details Adds a new contact object to represent a contact between proxy A and proxy B
    /// if all of the following are true:
    ///   1. The bodies of the fixtures of the proxies are not the one and the same.
    ///   2. No contact already exists for these two proxies.
    ///   3. The bodies of the proxies should collide (according to <code>ShouldCollide</code>).
    ///   4. The contact filter says the fixtures of the proxies should collide.
    ///   5. There exists a contact-create function for the pair of shapes of the proxies.
    /// @post The size of the <code>contacts</code> collection is one greater-than it was
    ///   before this method is called if it returns <code>true</code>.
    /// @param key ID's of dynamic tree entries identifying the fixture proxies involved.
    /// @return <code>true</code> if a new contact was indeed added (and created),
    ///   else <code>false</code>.
    /// @see bool ShouldCollide(const Body& lhs, const Body& rhs) noexcept.
    bool Add(ContactKey key);

    /// @brief Destroys the given contact.
    void InternalDestroy(ContactID contact, Body* from = nullptr);

    /// @brief Synchronizes the given body.
    /// @details This updates the broad phase dynamic tree data for all of the given fixtures.
    ContactCounter Synchronize(const Fixtures& fixtures,
                               const Transformation& xfm1, const Transformation& xfm2,
                               Real multiplier, Length extension);

    /// @brief Creates and destroys proxies.
    void CreateAndDestroyProxies(Length extension);

    /// @brief Synchronizes proxies of the bodies for proxies.
    PreStepStats::counter_type SynchronizeProxies(const StepConf& conf);

    /// @brief Updates the touching related state and notifies listener (if one given).
    ///
    /// @note Ideally this method is only called when a dependent change has occurred.
    /// @note Touching related state depends on the following data:
    ///   - The fixtures' sensor states.
    ///   - The fixtures bodies' transformations.
    ///   - The <code>maxCirclesRatio</code> per-step configuration state *OR* the
    ///     <code>maxDistanceIters</code> per-step configuration state.
    ///
    /// @param id Identifies the contact to update.
    /// @param conf Per-step configuration information.
    ///
    /// @see GetManifold, IsTouching
    ///
    void Update(ContactID id, const ContactUpdateConf& conf);

    /******** Member variables. ********/

    ArrayAllocator<Body> m_bodyBuffer;
    ArrayAllocator<Contacts> m_bodyContacts; ///< Cache of contacts associated with body.
    ArrayAllocator<BodyJoints> m_bodyJoints; ///< Cache of joints associated with body.

    /// Cache of fixtures associated with body.
    /// @todo Consider eliminating this variable since calling <code>GetFixtures()</code>
    ///   isn't done within the <code>World::Step</code> except by
    ///   <code>World::Synchronize</code> which may be replacable with iterating over the
    ///   entire fixture array.
    ArrayAllocator<Fixtures> m_bodyFixtures;

    ArrayAllocator<FixtureConf> m_fixtureBuffer;
    ArrayAllocator<Proxies> m_fixtureProxies;
    ArrayAllocator<Joint> m_jointBuffer;
    ArrayAllocator<Contact> m_contactBuffer;
    ArrayAllocator<Manifold> m_manifoldBuffer;

    DynamicTree m_tree; ///< Dynamic tree.

    ContactKeyQueue m_proxyKeys; ///< Proxy keys.
    Proxies m_proxies; ///< Proxies queue.
    Fixtures m_fixturesForProxies; ///< Fixtures for proxies queue.
    Bodies m_bodiesForProxies; ///< Bodies for proxies queue.
    
    Bodies m_bodies; ///< Body collection.

    Joints m_joints; ///< Joint collection.
    
    /// @brief Container of contacts.
    /// @note In the <em>add pair</em> stress-test, 401 bodies can have some 31000 contacts
    ///   during a given time step.
    Contacts m_contacts;

    Island m_island; ///< Island buffer.
    std::vector<bool> m_islandedBodies;
    std::vector<bool> m_islandedContacts;
    std::vector<bool> m_islandedJoints;

    FixtureListener m_fixtureDestructionListener;
    JointListener m_jointDestructionListener;
    ContactListener m_beginContactListener;
    ContactListener m_endContactListener;
    ManifoldContactListener m_preSolveContactListener;
    ImpulsesContactListener m_postSolveContactListener;

    FlagsType m_flags = e_stepComplete; ///< Flags.
    
    /// Inverse delta-t from previous step.
    /// @details Used to compute time step ratio to support a variable time step.
    /// @note 4-bytes large.
    /// @see Step.
    Frequency m_inv_dt0 = 0;
    
    /// @brief Minimum vertex radius.
    Positive<Length> m_minVertexRadius;
    
    /// @brief Maximum vertex radius.
    /// @details
    /// This is the maximum shape vertex radius that any bodies' of this world should create
    /// fixtures for. Requests to create fixtures for shapes with vertex radiuses bigger than
    /// this must be rejected. As an upper bound, this value prevents shapes from getting
    /// associated with this world that would otherwise not be able to be simulated due to
    /// numerical issues. It can also be set below this upper bound to constrain the differences
    /// between shape vertex radiuses to possibly more limited visual ranges.
    Positive<Length> m_maxVertexRadius;
};

inline const WorldImpl::Proxies& WorldImpl::GetProxies() const noexcept
{
    return m_proxies;
}

inline void WorldImpl::AddProxies(const Proxies& proxies)
{
    m_proxies.insert(end(m_proxies), begin(proxies), end(proxies));
}

inline SizedRange<WorldImpl::Bodies::const_iterator> WorldImpl::GetBodies() const noexcept
{
    return {begin(m_bodies), end(m_bodies), size(m_bodies)};
}

inline SizedRange<WorldImpl::Bodies::const_iterator> WorldImpl::GetBodiesForProxies() const noexcept
{
    return {cbegin(m_bodiesForProxies), cend(m_bodiesForProxies), size(m_bodiesForProxies)};
}

inline SizedRange<WorldImpl::Fixtures::const_iterator> WorldImpl::GetFixturesForProxies() const noexcept
{
    return {cbegin(m_fixturesForProxies), cend(m_fixturesForProxies), size(m_fixturesForProxies)};
}

inline SizedRange<WorldImpl::Joints::const_iterator> WorldImpl::GetJoints() const noexcept
{
    return {begin(m_joints), end(m_joints), size(m_joints)};
}

inline SizedRange<WorldImpl::Contacts::const_iterator> WorldImpl::GetContacts() const noexcept
{
    return {begin(m_contacts), end(m_contacts), size(m_contacts)};
}

inline bool WorldImpl::IsLocked() const noexcept
{
    return (m_flags & e_locked) == e_locked;
}

inline bool WorldImpl::IsStepComplete() const noexcept
{
    return (m_flags & e_stepComplete) != 0u;
}

inline void WorldImpl::SetStepComplete(bool value) noexcept
{
    if (value)
    {
        m_flags |= e_stepComplete;
    }
    else
    {
        m_flags &= ~e_stepComplete;        
    }
}

inline bool WorldImpl::GetSubStepping() const noexcept
{
    return (m_flags & e_substepping) != 0u;
}

inline void WorldImpl::SetSubStepping(bool flag) noexcept
{
    if (flag)
    {
        m_flags |= e_substepping;
    }
    else
    {
        m_flags &= ~e_substepping;
    }
}

inline bool WorldImpl::HasNewFixtures() const noexcept
{
    return (m_flags & e_newFixture) != 0u;
}

inline void WorldImpl::UnsetNewFixtures() noexcept
{
    m_flags &= ~e_newFixture;
}

inline Length WorldImpl::GetMinVertexRadius() const noexcept
{
    return m_minVertexRadius;
}

inline Length WorldImpl::GetMaxVertexRadius() const noexcept
{
    return m_maxVertexRadius;
}

inline Frequency WorldImpl::GetInvDeltaTime() const noexcept
{
    return m_inv_dt0;
}

inline const DynamicTree& WorldImpl::GetTree() const noexcept
{
    return m_tree;
}

inline void WorldImpl::SetFixtureDestructionListener(FixtureListener listener) noexcept
{
    m_fixtureDestructionListener = std::move(listener);
}

inline void WorldImpl::SetJointDestructionListener(JointListener listener) noexcept
{
    m_jointDestructionListener = std::move(listener);
}

inline void WorldImpl::SetBeginContactListener(ContactListener listener) noexcept
{
    m_beginContactListener = std::move(listener);
}

inline void WorldImpl::SetEndContactListener(ContactListener listener) noexcept
{
    m_endContactListener = std::move(listener);
}

inline void WorldImpl::SetPreSolveContactListener(ManifoldContactListener listener) noexcept
{
    m_preSolveContactListener = std::move(listener);
}

inline void WorldImpl::SetPostSolveContactListener(ImpulsesContactListener listener) noexcept
{
    m_postSolveContactListener = std::move(listener);
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDIMPL_HPP

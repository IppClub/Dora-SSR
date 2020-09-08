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

#ifndef PLAYRHO_DYNAMICS_WORLD_HPP
#define PLAYRHO_DYNAMICS_WORLD_HPP

/// @file
/// Declarations of the World class and associated free functions.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Range.hpp"
#include "PlayRho/Dynamics/WorldConf.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/BodyAtty.hpp"
#include "PlayRho/Dynamics/FixtureConf.hpp"
#include "PlayRho/Dynamics/WorldCallbacks.hpp"
#include "PlayRho/Dynamics/StepStats.hpp"
#include "PlayRho/Collision/DynamicTree.hpp"
#include "PlayRho/Dynamics/Contacts/ContactKey.hpp"
#include "PlayRho/Dynamics/ContactAtty.hpp"
#include "PlayRho/Dynamics/JointAtty.hpp"
#include "PlayRho/Dynamics/IslandStats.hpp"

#include <iterator>
#include <vector>
#include <map>
#include <unordered_set>
#include <memory>
#include <stdexcept>
#include <functional>

namespace playrho {

class StepConf;
enum class BodyType;

namespace d2 {

struct BodyConf;
struct JointConf;
struct FixtureConf;
class Body;
class Contact;
class Fixture;
class Joint;
struct Island;
class Shape;
struct ShapeConf;

/// @defgroup PhysicalEntities Physical Entity Classes
///
/// @brief Classes representing physical entities typically created/destroyed via factory methods.
///
/// @details Classes of creatable and destroyable managed instances that associate
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
/// const auto fixture = body->CreateFixture(Shape{DiskShapeConf{1_m}});
/// @endcode
///
/// @sa World, World::CreateBody, World::CreateJoint, World::Destroy.
/// @sa Body::CreateFixture, Body::Destroy, Body::DestroyFixtures.
/// @sa BodyType, Shape, DiskShapeConf.

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
/// @note World instances are composed of &mdash; i.e. contain and own &mdash; Body, Joint,
///   and Contact instances.
/// @note This data structure is 232-bytes large (with 4-byte Real on at least one 64-bit
///   platform).
/// @attention For example, the following could be used to create a dynamic body having a one meter
///   radius disk shape:
/// @code{.cpp}
/// auto world = World{};
/// const auto body = world.CreateBody(BodyConf{}.UseType(BodyType::Dynamic));
/// const auto fixture = body->CreateFixture(Shape{DiskShapeConf{1_m}});
/// @endcode
///
/// @sa Body, Joint, Contact, PhysicalEntities.
///
class World
{
public:
    /// @brief Bodies container type.
    using Bodies = std::vector<Body*>;

    /// @brief Contacts container type.
    using Contacts = std::vector<KeyedContactPtr>;
    
    /// @brief Joints container type.
    /// @note Cannot be container of Joint instances since joints are polymorphic types.
    using Joints = std::vector<Joint*>;
    
    /// @brief Fixtures container type.
    using Fixtures = std::vector<Fixture*>;

    /// @brief Constructs a world object.
    /// @param def A customized world configuration or its default value.
    /// @note A lot more configurability can be had via the <code>StepConf</code>
    ///   data that's given to the world's <code>Step</code> method.
    /// @throws InvalidArgument if the given max vertex radius is less than the min.
    /// @sa Step.
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
    World& operator= (const World& other);

    /// @brief Destructor.
    /// @details All physics entities are destroyed and all dynamically allocated memory
    ///    is released.
    ~World() noexcept;

    /// @brief Clears this world.
    /// @post The contents of this world have all been destroyed and this world's internal
    ///   state reset as though it had just been constructed.
    /// @throws WrongState if this method is called while the world is locked.
    void Clear();

    /// @brief Register a destruction listener.
    /// @note The listener is owned by you and must remain in scope.
    void SetDestructionListener(DestructionListener* listener) noexcept;

    /// @brief Register a contact event listener.
    /// @note The listener is owned by you and must remain in scope.
    void SetContactListener(ContactListener* listener) noexcept;

    /// @brief Creates a rigid body with the given configuration.
    /// @warning This function should not be used while the world is locked &mdash; as it is
    ///   during callbacks. If it is, it will throw an exception or abort your program.
    /// @note No references to the configuration are retained. Its value is copied.
    /// @post The created body will be present in the range returned from the
    ///   <code>GetBodies()</code> method.
    /// @param def A customized body configuration or its default value.
    /// @return Pointer to newly created body which can later be destroyed by calling the
    ///   <code>Destroy(Body*)</code> method.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws LengthError if this operation would create more than <code>MaxBodies</code>.
    /// @sa Destroy(Body*), GetBodies.
    /// @sa PhysicalEntities.
    Body* CreateBody(const BodyConf& def = GetDefaultBodyConf());

    /// @brief Creates a joint to constrain one or more bodies.
    /// @warning This function is locked during callbacks.
    /// @note No references to the configuration are retained. Its value is copied.
    /// @post The created joint will be present in the range returned from the
    ///   <code>GetJoints()</code> method.
    /// @return Pointer to newly created joint which can later be destroyed by calling the
    ///   <code>Destroy(Joint*)</code> method.
    /// @throws WrongState if this method is called while the world is locked.
    /// @throws LengthError if this operation would create more than <code>MaxJoints</code>.
    /// @throws InvalidArgument if the given definition is not allowed.
    /// @sa PhysicalEntities.
    /// @sa Destroy(Joint*), GetJoints.
    Joint* CreateJoint(const JointConf& def);

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
    /// @param body Body to destroy that had been created by this world.
    /// @throws WrongState if this method is called while the world is locked.
    /// @sa CreateBody(const BodyConf&), GetBodies, GetFixturesForProxies.
    /// @sa PhysicalEntities.
    void Destroy(Body* body);

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
    /// @sa CreateJoint(const JointConf&), GetJoints.
    /// @sa PhysicalEntities.
    void Destroy(Joint* joint);

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
    /// @sa GetBodiesForProxies, GetFixturesForProxies.
    ///
    StepStats Step(const StepConf& conf);

    /// @brief Gets the world body range for this world.
    /// @details Gets a range enumerating the bodies currently existing within this world.
    ///   These are the bodies that had been created from previous calls to the
    ///   <code>CreateBody(const BodyConf&)</code> method that haven't yet been destroyed.
    /// @return Body range that can be iterated over using its begin and end methods
    ///   or using ranged-based for-loops.
    /// @sa CreateBody(const BodyConf&).
    SizedRange<Bodies::iterator> GetBodies() noexcept;

    /// @brief Gets the world body range for this constant world.
    /// @details Gets a range enumerating the bodies currently existing within this world.
    ///   These are the bodies that had been created from previous calls to the
    ///   <code>CreateBody(const BodyConf&)</code> method that haven't yet been destroyed.
    /// @return Body range that can be iterated over using its begin and end methods
    ///   or using ranged-based for-loops.
    /// @sa CreateBody(const BodyConf&).
    SizedRange<Bodies::const_iterator> GetBodies() const noexcept;

    /// @brief Gets the bodies-for-proxies range for this world.
    /// @details Provides insight on what bodies have been queued for proxy processing
    ///   during the next call to the world step method.
    /// @sa Step.
    SizedRange<Bodies::const_iterator> GetBodiesForProxies() const noexcept;

    /// @brief Gets the fixtures-for-proxies range for this world.
    /// @details Provides insight on what fixtures have been queued for proxy processing
    ///   during the next call to the world step method.
    /// @sa Step.
    SizedRange<Fixtures::const_iterator> GetFixturesForProxies() const noexcept;

    /// @brief Gets the world joint range.
    /// @details Gets a range enumerating the joints currently existing within this world.
    ///   These are the joints that had been created from previous calls to the
    ///   <code>CreateJoint(const JointConf&)</code> method that haven't yet been destroyed.
    /// @return World joints sized-range.
    /// @sa CreateJoint(const JointConf&).
    SizedRange<Joints::const_iterator> GetJoints() const noexcept;

    /// @brief Gets the world joint range.
    /// @details Gets a range enumerating the joints currently existing within this world.
    ///   These are the joints that had been created from previous calls to the
    ///   <code>CreateJoint(const JointConf&)</code> method that haven't yet been destroyed.
    /// @return World joints sized-range.
    /// @sa CreateJoint(const JointConf&).
    SizedRange<Joints::iterator> GetJoints() noexcept;

    /// @brief Gets the world contact range.
    /// @warning contacts are created and destroyed in the middle of a time step.
    /// Use <code>ContactListener</code> to avoid missing contacts.
    /// @return World contacts sized-range.
    SizedRange<Contacts::const_iterator> GetContacts() const noexcept;
    
    /// @brief Whether or not "step" is complete.
    /// @details The "step" is completed when there are no more TOI events for the current time step.
    /// @return <code>true</code> unless sub-stepping is enabled and the step method returned
    ///   without finishing all of its sub-steps.
    /// @sa GetSubStepping, SetSubStepping.
    bool IsStepComplete() const noexcept;
    
    /// @brief Gets whether or not sub-stepping is enabled.
    /// @sa SetSubStepping, IsStepComplete.
    bool GetSubStepping() const noexcept;

    /// @brief Enables/disables single stepped continuous physics.
    /// @note This is not normally used. Enabling sub-stepping is meant for testing.
    /// @post The <code>GetSubStepping()</code> method will return the value this method was
    ///   called with.
    /// @sa IsStepComplete, GetSubStepping.
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
    /// @sa Step.
    Frequency GetInvDeltaTime() const noexcept;

private:
    friend class WorldAtty;

    /// @brief Sets the type of the given body.
    /// @note This may alter the body's mass and velocity.
    /// @throws WrongState if this method is called while the world is locked.
    void SetType(Body& body, playrho::BodyType type);

    /// @brief Registers the given fixture for adding to proxy processing.
    /// @post The given fixture will be found in the fixtures-for-proxies range.
    void RegisterForProxies(Fixture& fixture);

    /// @brief Registers the given body for proxy processing.
    /// @post The given body will be found in the bodies-for-proxies range.
    void RegisterForProxies(Body& body);

    /// @brief Unregisters the given body from proxy processing.
    /// @post The given body won't be found in the bodies-for-proxies range.
    void UnregisterForProxies(const Body& body);

    /// @brief Creates a fixture with the given parameters.
    /// @throws InvalidArgument if called without a shape.
    /// @throws InvalidArgument if called for a shape with a vertex radius less than the
    ///    minimum vertex radius.
    /// @throws InvalidArgument if called for a shape with a vertex radius greater than the
    ///    maximum vertex radius.
    /// @throws WrongState if this method is called while the world is locked.
    Fixture* CreateFixture(Body& body, const Shape& shape,
                           const FixtureConf& def = GetDefaultFixtureConf(),
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
    /// @sa Body::ResetMassData.
    /// @throws WrongState if this method is called while the world is locked.
    bool Destroy(Fixture& fixture, bool resetMassData = true);
    
    /// @brief Touches each proxy of the given fixture.
    /// @warning Behavior is undefined if called with a fixture for a body which doesn't
    ///   belong to this world.
    /// @note This sets things up so that pairs may be created for potentially new contacts.
    void TouchProxies(Fixture& fixture) noexcept;
    
    /// @brief Sets new fixtures flag.
    void SetNewFixtures() noexcept;

    /// @brief Flags type data type.
    using FlagsType = std::uint32_t;

    /// @brief Proxy ID type alias.
    using ProxyId = DynamicTree::Size;

    /// @brief Contact key queue type alias.
    using ContactKeyQueue = std::vector<ContactKey>;
    
    /// @brief Proxy queue type alias.
    using ProxyQueue = std::vector<ProxyId>;
    
    /// @brief Flag enumeration.
    enum Flag: FlagsType
    {
        /// New fixture.
        e_newFixture    = 0x0001,

        /// Locked.
        e_locked        = 0x0002,

        /// Sub-stepping.
        e_substepping   = 0x0020,
        
        /// Step complete. @details Used for sub-stepping. @sa e_substepping.
        e_stepComplete  = 0x0040,
    };

    /// @brief Copies bodies.
    void CopyBodies(std::map<const Body*, Body*>& bodyMap,
                    std::map<const Fixture*, Fixture*>& fixtureMap,
                    SizedRange<World::Bodies::const_iterator> range);
    
    /// @brief Copies joints.
    void CopyJoints(const std::map<const Body*, Body*>& bodyMap,
                    SizedRange<World::Joints::const_iterator> range);
    
    /// @brief Copies contacts.
    void CopyContacts(const std::map<const Body*, Body*>& bodyMap,
                      const std::map<const Fixture*, Fixture*>& fixtureMap,
                      SizedRange<World::Contacts::const_iterator> range);
    
    /// @brief Clears this world without checking the world's state.
    void InternalClear() noexcept;

    /// @brief Internal destroy.
    /// @warning Behavior is undefined if passed a null pointer for the joint.
    void InternalDestroy(Joint& joint) noexcept;

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
    IslandStats SolveRegIslandViaGS(const StepConf& conf, Island island);
    
    /// @brief Adds to the island based off of a given "seed" body.
    /// @post Contacts are listed in the island in the order that bodies provide those contacts.
    /// @post Joints are listed the island in the order that bodies provide those joints.
    void AddToIsland(Island& island, Body& seed,
                     Bodies::size_type& remNumBodies,
                     Contacts::size_type& remNumContacts,
                     Joints::size_type& remNumJoints);

    /// @brief Body stack.
    /// @note Using a std::stack<Body*, std::vector<Body*>> would be nice except it doesn't
    ///   support the reserve method.
    using BodyStack = std::vector<Body*>;

    /// @brief Adds to the island.
    void AddToIsland(Island& island, BodyStack& stack,
                     Bodies::size_type& remNumBodies,
                     Contacts::size_type& remNumContacts,
                     Joints::size_type& remNumJoints);
    
    /// @brief Adds contacts to the island.
    void AddContactsToIsland(Island& island, BodyStack& stack, const Body* b);

    /// @brief Adds joints to the island.
    void AddJointsToIsland(Island& island, BodyStack& stack, const Body* b);
    
    /// @brief Removes <em>unspeedables</em> from the is <em>is-in-island</em> state.
    Bodies::size_type RemoveUnspeedablesFromIslanded(const std::vector<Body*>& bodies);

    /// @brief Solves the step using successive time of impact (TOI) events.
    /// @details Used for continuous physics.
    /// @note This is intended to detect and prevent the tunneling that the faster Solve method
    ///    may miss.
    /// @param conf Time step configuration to use.
    ToiStepStats SolveToi(const StepConf& conf);

    /// @brief Solves collisions for the given time of impact.
    ///
    /// @param conf Time step configuration to solve for.
    /// @param contact Contact.
    ///
    /// @note Precondition 1: there is no contact having a lower TOI in this time step that has
    ///   not already been solved for.
    /// @note Precondition 2: there is not a lower TOI in the time step for which collisions have
    ///   not already been processed.
    ///
    IslandStats SolveToi(const StepConf& conf, Contact& contact);
    
    /// @brief Solves the time of impact for bodies 0 and 1 of the given island.
    ///
    /// @details This:
    ///   1. Updates position 0 of the sweeps of bodies 0 and 1.
    ///   2. Updates position 1 of the sweeps, the transforms, and the velocities of the other
    ///      bodies in this island.
    ///
    /// @pre <code>island.m_bodies</code> contains at least two bodies, the first two of which
    ///   are bodies 0 and 1.
    /// @pre <code>island.m_bodies</code> contains appropriate other bodies of the contacts of
    ///   the two bodies.
    /// @pre <code>island.m_contacts</code> contains the contact that specified the two identified
    ///   bodies.
    /// @pre <code>island.m_contacts</code> contains appropriate other contacts of the two bodies.
    ///
    /// @param conf Time step configuration information.
    /// @param island Island to do time of impact solving for.
    ///
    /// @return Island solver results.
    ///
    IslandStats SolveToiViaGS(const StepConf& conf, Island& island);

    /// @brief Updates the given body.
    /// @details Updates the given body's velocity, sweep position 1, and its transformation.
    /// @param body Body to update.
    /// @param pos New position to set the given body to.
    /// @param vel New velocity to set the given body to.
    static void UpdateBody(Body& body, const Position& pos, const Velocity& vel);

    /// @brief Reset bodies for solve TOI.
    void ResetBodiesForSolveTOI() noexcept;

    /// @brief Reset contacts for solve TOI.
    void ResetContactsForSolveTOI() noexcept;
    
    /// @brief Reset contacts for solve TOI.
    void ResetContactsForSolveTOI(Body& body) noexcept;

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
    /// @param[in,out] island Island. On return this may contain additional contacts or bodies.
    /// @param[in,out] body A dynamic/accelerable body.
    /// @param[in] toi Time of impact (TOI). Value between 0 and 1.
    /// @param[in] conf Step configuration data.
    ProcessContactsOutput ProcessContactsForTOI(Island& island, Body& body, Real toi,
                                                const StepConf& conf);

    /// @brief Adds the given joint to this world.
    /// @note This also adds the joint to the bodies of the joint.
    bool Add(Joint* j);

    /// @brief Removes the given body from this world.
    void Remove(const Body& b) noexcept;
 
    /// @brief Removes the given joint from this world.
    void Remove(const Joint& j) noexcept;

    /// @brief Sets the step complete state.
    /// @post <code>IsStepComplete()</code> will return the value set.
    /// @sa IsStepComplete.
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
        Contact* contact = nullptr; ///< Contact for which the time of impact is relevant.
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
    UpdateContactsData UpdateContactTOIs(const StepConf& conf);

    /// @brief Gets the soonest contact.
    /// @details This finds the contact with the lowest (soonest) time of impact.
    /// @return Contact with the least time of impact and its time of impact, or null contact.
    ///  A non-null contact will be enabled, not have sensors, be active, and impenetrable.
    ContactToiData GetSoonestContact() const noexcept;

    /// @brief Determines whether this world has new fixtures.
    bool HasNewFixtures() const noexcept;
    
    /// @brief Unsets the new fixtures state.
    void UnsetNewFixtures() noexcept;
    
    /// @brief Finds new contacts.
    /// @details Finds and adds new valid contacts to the contacts container.
    /// @note The new contacts will all have overlapping AABBs.
    ContactCounter FindNewContacts();
    
    /// @brief Processes the narrow phase collision for the contacts collection.
    /// @details
    /// This finds and destroys the contacts that need filtering and no longer should collide or
    /// that no longer have AABB-based overlapping fixtures. Those contacts that persist and
    /// have active bodies (either or both) get their Update methods called with the current
    /// contact listener as its argument.
    /// Essentially this really just purges contacts that are no longer relevant.
    DestroyContactsStats DestroyContacts(Contacts& contacts);
    
    /// @brief Update contacts.
    UpdateContactsStats UpdateContacts(Contacts& contacts, const StepConf& conf);
    
    /// @brief Destroys the given contact and removes it from its container.
    /// @details This updates the contacts container, returns the memory to the allocator,
    ///   and decrements the contact manager's contact count.
    /// @param contacts Contacts from which to destroy the contact from.
    /// @param contactListener Contact listener or <code>nullptr</code>. Invoked if non-null.
    /// @param contact Contact to destroy.
    /// @param from From body.
    static void Destroy(Contacts& contacts, ContactListener* contactListener, Contact* contact, Body* from);
    
    /// @brief Adds a contact for the proxies identified by the key if appropriate.
    /// @details Adds a new contact object to represent a contact between proxy A and proxy B
    /// if all of the following are true:
    ///   1. The bodies of the fixtures of the proxies are not the one and the same.
    ///   2. No contact already exists for these two proxies.
    ///   3. The bodies of the proxies should collide (according to <code>ShouldCollide</code>).
    ///   4. The contact filter says the fixtures of the proxies should collide.
    ///   5. There exists a contact-create function for the pair of shapes of the proxies.
    /// @post The size of the <code>m_contacts</code> collection is one greater-than it was
    ///   before this method is called if it returns <code>true</code>.
    /// @param key ID's of dynamic tree entries identifying the fixture proxies involved.
    /// @return <code>true</code> if a new contact was indeed added (and created),
    ///   else <code>false</code>.
    /// @sa bool ShouldCollide(const Body& lhs, const Body& rhs) noexcept.
    static bool Add(Contacts& contacts, const DynamicTree& tree, ContactKey key);

    /// @brief Destroys the given contact.
    static void InternalDestroy(ContactListener* contactListener, Contact* contact, Body* from = nullptr);

    /// @brief Creates proxies for every child of the given fixture's shape.
    /// @note This sets the proxy count to the child count of the shape.
    static void CreateProxies(ProxyQueue& proxies, DynamicTree& tree, Fixture& fixture, Length aabbExtension);

    /// @brief Destroys the given fixture's proxies.
    /// @note This resets the proxy count to 0.
    static void DestroyProxies(ProxyQueue& proxies, DynamicTree& tree, Fixture& fixture) noexcept;

    /// @brief Touches each proxy of the given fixture.
    /// @note This sets things up so that pairs may be created for potentially new contacts.
    void InternalTouchProxies(Fixture& fixture) noexcept;
    
    /// @brief Synchronizes the given body.
    /// @details This updates the broad phase dynamic tree data for all of the given
    ///   body's fixtures.
    ContactCounter Synchronize(Body& body,
                               Transformation xfm1, Transformation xfm2,
                               Real multiplier, Length extension);

    /// @brief Synchronizes the given fixture.
    /// @details This updates the broad phase dynamic tree data for all of the given
    ///   fixture shape's children.
    ContactCounter Synchronize(Fixture& fixture,
                               Transformation xfm1, Transformation xfm2,
                               Length2 displacement, Length extension);
    
    /// @brief Creates and destroys proxies.
    void CreateAndDestroyProxies(const StepConf& conf);
    
    /// @brief Synchronizes proxies of the bodies for proxies.
    PreStepStats::counter_type SynchronizeProxies(const StepConf& conf);

    /// @brief Whether the given body is in an island.
    bool IsIslanded(const Body* body) const noexcept;

    /// @brief Whether the given contact is in an island.
    bool IsIslanded(const Contact* contact) const noexcept;

    /// @brief Whether the given joint is in an island.
    bool IsIslanded(const Joint* joint) const noexcept;

    /// @brief Sets the given body to the in an island state.
    void SetIslanded(Body* body) noexcept;

    /// @brief Sets the given contact to the in an island state.
    void SetIslanded(Contact* contact) noexcept;

    /// @brief Sets the given joint to the in an island state.
    void SetIslanded(Joint* joint) noexcept;

    /// @brief Unsets the given body's in island state.
    void UnsetIslanded(Body* body) noexcept;

    /// @brief Unsets the given contact's in island state.
    void UnsetIslanded(Contact* contact) noexcept;
    
    /// @brief Unsets the given joint's in island state.
    void UnsetIslanded(Joint* joint) noexcept;

    /******** Member variables. ********/
    
    DynamicTree m_tree; ///< Dynamic tree.
    
    ContactKeyQueue m_proxyKeys; ///< Proxy keys.
    ProxyQueue m_proxies; ///< Proxies queue.
    Fixtures m_fixturesForProxies; ///< Fixtures for proxies queue.
    Bodies m_bodiesForProxies; ///< Bodies for proxies queue.
    
    Bodies m_bodies; ///< Body collection.

    Joints m_joints; ///< Joint collection.

    /// @brief Container of contacts.
    /// @note In the <em>add pair</em> stress-test, 401 bodies can have some 31000 contacts
    ///   during a given time step.
    Contacts m_contacts;
    
    DestructionListener* m_destructionListener = nullptr; ///< Destruction listener. 8-bytes.
    
    ContactListener* m_contactListener = nullptr; ///< Contact listener. 8-bytes.
    
    FlagsType m_flags = e_stepComplete; ///< Flags.

    /// Inverse delta-t from previous step.
    /// @details Used to compute time step ratio to support a variable time step.
    /// @note 4-bytes large.
    /// @sa Step.
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

/// @example HelloWorld.cpp
/// This is the source file for the <code>HelloWorld</code> application that demonstrates
/// use of the playrho::d2::World class and more.

/// @example World.cpp
/// This is the <code>googletest</code> based unit testing file for the
/// <code>playrho::d2::World</code> class.

inline SizedRange<World::Bodies::iterator> World::GetBodies() noexcept
{
    return {begin(m_bodies), end(m_bodies), size(m_bodies)};
}

inline SizedRange<World::Bodies::const_iterator> World::GetBodies() const noexcept
{
    return {begin(m_bodies), end(m_bodies), size(m_bodies)};
}

inline SizedRange<World::Bodies::const_iterator> World::GetBodiesForProxies() const noexcept
{
    return {cbegin(m_bodiesForProxies), cend(m_bodiesForProxies), size(m_bodiesForProxies)};
}

inline SizedRange<World::Fixtures::const_iterator> World::GetFixturesForProxies() const noexcept
{
    return {cbegin(m_fixturesForProxies), cend(m_fixturesForProxies), size(m_fixturesForProxies)};
}

inline SizedRange<World::Joints::const_iterator> World::GetJoints() const noexcept
{
    return {begin(m_joints), end(m_joints), size(m_joints)};
}

inline SizedRange<World::Joints::iterator> World::GetJoints() noexcept
{
    return {begin(m_joints), end(m_joints), size(m_joints)};
}

inline SizedRange<World::Contacts::const_iterator> World::GetContacts() const noexcept
{
    return {begin(m_contacts), end(m_contacts), size(m_contacts)};
}

inline bool World::IsLocked() const noexcept
{
    return (m_flags & e_locked) == e_locked;
}

inline bool World::IsStepComplete() const noexcept
{
    return (m_flags & e_stepComplete) != 0u;
}

inline void World::SetStepComplete(bool value) noexcept
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

inline bool World::GetSubStepping() const noexcept
{
    return (m_flags & e_substepping) != 0u;
}

inline void World::SetSubStepping(bool flag) noexcept
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

inline bool World::HasNewFixtures() const noexcept
{
    return (m_flags & e_newFixture) != 0u;
}

inline void World::SetNewFixtures() noexcept
{
    m_flags |= e_newFixture;
}

inline void World::UnsetNewFixtures() noexcept
{
    m_flags &= ~e_newFixture;
}

inline Length World::GetMinVertexRadius() const noexcept
{
    return m_minVertexRadius;
}

inline Length World::GetMaxVertexRadius() const noexcept
{
    return m_maxVertexRadius;
}

inline Frequency World::GetInvDeltaTime() const noexcept
{
    return m_inv_dt0;
}

inline const DynamicTree& World::GetTree() const noexcept
{
    return m_tree;
}

inline void World::SetDestructionListener(DestructionListener* listener) noexcept
{
    m_destructionListener = listener;
}

inline void World::SetContactListener(ContactListener* listener) noexcept
{
    m_contactListener = listener;
}

inline bool World::IsIslanded(const Body* body) const noexcept
{
    return BodyAtty::IsIslanded(*body);
}

inline bool World::IsIslanded(const Contact* contact) const noexcept
{
    return ContactAtty::IsIslanded(*contact);
}

inline bool World::IsIslanded(const Joint* joint) const noexcept
{
    return JointAtty::IsIslanded(*joint);
}

inline void World::SetIslanded(Body* body) noexcept
{
    BodyAtty::SetIslanded(*body);
}

inline void World::SetIslanded(Contact* contact) noexcept
{
    ContactAtty::SetIslanded(*contact);
}

inline void World::SetIslanded(Joint* joint) noexcept
{
    JointAtty::SetIslanded(*joint);
}

inline void World::UnsetIslanded(Body* body) noexcept
{
    BodyAtty::UnsetIslanded(*body);
}

inline void World::UnsetIslanded(Contact* contact) noexcept
{
    ContactAtty::UnsetIslanded(*contact);
}

inline void World::UnsetIslanded(Joint* joint) noexcept
{
    JointAtty::UnsetIslanded(*joint);
}

// Free functions.

/// @brief Gets the body count in the given world.
/// @return 0 or higher.
/// @relatedalso World
inline BodyCounter GetBodyCount(const World& world) noexcept
{
    return static_cast<BodyCounter>(size(world.GetBodies()));
}

/// Gets the count of joints in the given world.
/// @return 0 or higher.
/// @relatedalso World
inline JointCounter GetJointCount(const World& world) noexcept
{
    return static_cast<JointCounter>(size(world.GetJoints()));
}

/// @brief Gets the count of contacts in the given world.
/// @note Not all contacts are for shapes that are actually touching. Some contacts are for
///   shapes which merely have overlapping AABBs.
/// @return 0 or higher.
/// @relatedalso World
inline ContactCounter GetContactCount(const World& world) noexcept
{
    return static_cast<ContactCounter>(size(world.GetContacts()));
}

/// @brief Gets the touching count for the given world.
/// @relatedalso World
ContactCounter GetTouchingCount(const World& world) noexcept;

/// @brief Steps the world ahead by a given time amount.
///
/// @details Performs position and velocity updating, sleeping of non-moving bodies, updating
///   of the contacts, and notifying the contact listener of begin-contact, end-contact,
///   pre-solve, and post-solve events.
///   If the given velocity and position iterations are more than zero, this method also
///   respectively performs velocity and position resolution of the contacting bodies.
///
/// @note While body velocities are updated accordingly (per the sum of forces acting on them),
///   body positions (barring any collisions) are updated as if they had moved the entire time
///   step at those resulting velocities. In other words, a body initially at <code>p0</code>
///   going <code>v0</code> fast with a sum acceleration of <code>a</code>, after time
///   <code>t</code> and barring any collisions, will have a new velocity (<code>v1</code>) of
///   <code>v0 + (a * t)</code> and a new position (<code>p1</code>) of <code>p0 + v1 * t</code>.
///
/// @warning Varying the time step may lead to non-physical behaviors.
///
/// @post Static bodies are unmoved.
/// @post Kinetic bodies are moved based on their previous velocities.
/// @post Dynamic bodies are moved based on their previous velocities, gravity,
/// applied forces, applied impulses, masses, damping, and the restitution and friction values
/// of their fixtures when they experience collisions.
///
/// @param world World to step.
/// @param delta Time to simulate as a delta from the current state. This should not vary.
/// @param velocityIterations Number of iterations for the velocity constraint solver.
/// @param positionIterations Number of iterations for the position constraint solver.
///   The position constraint solver resolves the positions of bodies that overlap.
///
/// @relatedalso World
///
StepStats Step(World& world, Time delta,
               TimestepIters velocityIterations = 8,
               TimestepIters positionIterations = 3);

/// @brief Gets the count of fixtures in the given world.
/// @relatedalso World
std::size_t GetFixtureCount(const World& world) noexcept;

/// @brief Gets the count of unique shapes in the given world.
/// @relatedalso World
std::size_t GetShapeCount(const World& world) noexcept;

/// @brief Gets the count of awake bodies in the given world.
/// @relatedalso World
BodyCounter GetAwakeCount(const World& world) noexcept;

/// @brief Awakens all of the bodies in the given world.
/// @details Calls all of the world's bodies' <code>SetAwake</code> method.
/// @return Sum total of calls to bodies' <code>SetAwake</code> method that returned true.
/// @sa Body::SetAwake.
/// @relatedalso World
BodyCounter Awaken(World& world) noexcept;

/// @brief Sets the accelerations of all the world's bodies.
/// @param world World instance to set the acceleration of all contained bodies for.
/// @param fn Function or functor with a signature like:
///   <code>Acceleration (*fn)(const Body& body)</code>.
/// @relatedalso World
template <class F>
void SetAccelerations(World& world, F fn) noexcept
{
    const auto bodies = world.GetBodies();
    std::for_each(begin(bodies), end(bodies), [&](World::Bodies::value_type &b) {
        SetAcceleration(GetRef(b), fn(GetRef(b)));
    });
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
    SetAccelerations(world, Acceleration{
        LinearAcceleration2{0_mps2, 0_mps2}, 0 * RadianPerSquareSecond
    });
}

/// @brief Finds body in given world that's closest to the given location.
/// @relatedalso World
Body* FindClosestBody(const World& world, Length2 location) noexcept;

} // namespace d2

/// @brief Updates the given regular step statistics.
RegStepStats& Update(RegStepStats& lhs, const IslandStats& rhs) noexcept;

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLD_HPP

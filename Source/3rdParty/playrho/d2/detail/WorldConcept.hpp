/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_D2_DETAIL_WORLDCONCEPT_HPP
#define PLAYRHO_D2_DETAIL_WORLDCONCEPT_HPP

/// @file
/// @brief Definition of the internal WorldConcept interface class.

#include <memory> // for std::unique_ptr
#include <optional>
#include <vector>

#include "playrho/BodyID.hpp"
#include "playrho/BodyShapeFunction.hpp"
#include "playrho/Contact.hpp"
#include "playrho/ContactFunction.hpp"
#include "playrho/Interval.hpp"
#include "playrho/KeyedContactID.hpp"
#include "playrho/JointFunction.hpp"
#include "playrho/JointID.hpp"
#include "playrho/LimitState.hpp"
#include "playrho/ShapeFunction.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/StepStats.hpp"
#include "playrho/TypeInfo.hpp" // for GetTypeID & TypeID
#include "playrho/Units.hpp" // for Length, Frequency, etc.

#include "playrho/pmr/StatsResource.hpp"

#include "playrho/d2/Body.hpp"
#include "playrho/d2/ContactImpulsesFunction.hpp"
#include "playrho/d2/ContactManifoldFunction.hpp"
#include "playrho/d2/Joint.hpp"
#include "playrho/d2/Manifold.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Shape.hpp"

namespace playrho::d2 {
class DynamicTree;
}

namespace playrho::d2::detail {

/// @brief World-concept internal pure virtual base interface class.
/// @note This class itself has no invariants. Some of its member functions however
///   do impose some invariant like relationships with others.
struct WorldConcept {
    /// @brief Destructor.
    virtual ~WorldConcept() = default;

    // Listener Member Functions
    // Note: having these as part of the base interface instead of say taking
    //   these settings on construction, allows users to already have access
    //   to the World object so these can be set without making the underlying
    //   type part of the listener callback parameter interface.

    /// @brief Sets the destruction listener for shapes.
    /// @note This listener is called on <code>Clear_()</code> for every shape.
    /// @see Clear_.
    virtual void SetShapeDestructionListener_(ShapeFunction listener) noexcept = 0;

    /// @brief Sets the detach listener for shapes detaching from bodies.
    virtual void SetDetachListener_(BodyShapeFunction listener) noexcept = 0;

    /// @brief Sets a destruction listener for joints.
    /// @note This listener is called on <code>Clear_()</code> for every joint. It's also called
    ///   on <code>Destroy_(BodyID)</code> for every joint associated with the identified body.
    /// @see Clear_, Destroy_(BodyID).
    virtual void SetJointDestructionListener_(JointFunction listener) noexcept = 0;

    /// @brief Sets a begin contact event listener.
    virtual void SetBeginContactListener_(ContactFunction listener) noexcept = 0;

    /// @brief Sets an end contact event listener.
    virtual void SetEndContactListener_(ContactFunction listener) noexcept = 0;

    /// @brief Sets a pre-solve contact event listener.
    virtual void SetPreSolveContactListener_(ContactManifoldFunction listener) noexcept = 0;

    /// @brief Sets a post-solve contact event listener.
    virtual void SetPostSolveContactListener_(ContactImpulsesFunction listener) noexcept = 0;

    // Miscellaneous Member Functions

    /// @brief Clones the instance - making a deep copy.
    virtual std::unique_ptr<WorldConcept> Clone_() const = 0;

    /// @brief Gets the use type information.
    /// @return Type info of the underlying value's type.
    virtual TypeID GetType_() const noexcept = 0;

    /// @brief Gets the data for the underlying configuration.
    virtual const void* GetData_() const noexcept = 0;

    /// @brief Gets the data for the underlying configuration.
    virtual void* GetData_() noexcept = 0;

    /// @brief Equality checking function.
    virtual bool IsEqual_(const WorldConcept& other) const noexcept = 0;

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
    /// @details A "step" is completed when there are no more TOI events for the current time
    ///   step.
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

    /// @brief Gets the vertex radius range that shapes in this world can be within.
    virtual Interval<Positive<Length>> GetVertexRadiusInterval_() const noexcept = 0;

    /// @brief Gets the inverse delta time.
    /// @details Gets the inverse delta time that was set on construction or assignment, and
    ///   updated on every call to the <code>Step_</code> function having a non-zero delta-time.
    /// @see Step_.
    virtual Frequency GetInvDeltaTime_() const noexcept = 0;

    // Body Member Functions.

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
    ///   miss some collisions if you don't use <code>ContactFunction</code>.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see GetBodyRange_.
    virtual std::vector<std::tuple<ContactKey, ContactID>> GetContacts_(BodyID id) const = 0;

    /// @brief Gets the identities of the shapes associated with the identified body.
    /// @throws std::out_of_range If given an invalid body identifier.
    /// @see GetBodyRange_, CreateBody_, SetBody_.
    virtual std::vector<ShapeID> GetShapes_(BodyID id) const = 0;

    // Joint Member Functions

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

    // Shape Member Functions

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

    // Contact Member Functions

    /// @brief Gets the extent of the currently valid contact range.
    /// @note This is one higher than the maxium <code>ContactID</code> that is in range
    ///   for contact related functions.
    virtual ContactCounter GetContactRange_() const noexcept = 0;

    /// @brief Gets the world contact range.
    /// @warning contacts are created and destroyed in the middle of a time step.
    /// Use <code>ContactFunction</code> to avoid missing contacts.
    /// @return World contacts sized-range.
    virtual std::vector<KeyedContactID> GetContacts_() const = 0;

    /// @brief Gets the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see SetContact_, GetContactRange_.
    virtual Contact GetContact_(ContactID id) const = 0;

    /// @brief Sets the identified contact's state.
    /// @param id Identifier of the contact whose state is to be set.
    /// @param value Value the contact is to be set to.
    /// @throws std::out_of_range If given an invalid identifier.
    /// @throws InvalidArgument if the identifier is to a freed contact or if the new state is
    ///   not allowable.
    /// @see GetContact_, GetContactRange_.
    virtual void SetContact_(ContactID id, const Contact& value) = 0;

    /// @brief Gets the collision manifold for the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see SetManifold_, GetContactRange_.
    virtual Manifold GetManifold_(ContactID id) const = 0;

    /// @brief Sets the collision manifold for the identified contact.
    /// @throws std::out_of_range If given an invalid contact identifier.
    /// @see GetManifold_, GetContactRange_.
    virtual void SetManifold_(ContactID id, const Manifold& value) = 0;
};

} // namespace playrho::d2::detail

#endif // PLAYRHO_D2_DETAIL_WORLDCONCEPT_HPP

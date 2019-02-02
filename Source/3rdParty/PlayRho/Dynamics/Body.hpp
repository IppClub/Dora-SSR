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

#ifndef PLAYRHO_DYNAMICS_BODY_HPP
#define PLAYRHO_DYNAMICS_BODY_HPP

/// @file
/// Declarations of the Body class, and free functions associated with it.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Range.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Dynamics/BodyType.hpp"
#include "PlayRho/Dynamics/Fixture.hpp"
#include "PlayRho/Dynamics/Contacts/ContactKey.hpp"
#include "PlayRho/Dynamics/Joints/JointKey.hpp"
#include "PlayRho/Dynamics/MovementConf.hpp"
#include "PlayRho/Collision/MassData.hpp"

#include <vector>
#include <memory>
#include <cassert>
#include <utility>
#include <iterator>

namespace playrho {
namespace d2 {

class World;
struct FixtureConf;
class Shape;
struct BodyConf;

/// @brief Physical entity that exists within a World.
///
/// @details A rigid body entity created or destroyed through a World instance. These have
///   physical properties like: position, velocity, acceleration, and mass.
///
/// @invariant Only bodies that allow sleeping, can be put to sleep.
/// @invariant Only "speedable" bodies can be awake.
/// @invariant Only "speedable" bodies can have non-zero velocities.
/// @invariant Only "accelerable" bodies can have non-zero accelerations.
/// @invariant Only "accelerable" bodies can have non-zero "under-active" times.
///
/// @note Create these using the <code>World::CreateBody</code> method.
/// @note Destroy these using the <code>World::Destroy(Body*)</code> method.
/// @note From a memory management perspective, bodies own Fixture instances.
/// @note On a 64-bit architecture with 4-byte Real, this data structure is at least
///   192-bytes large.
///
/// @ingroup PhysicalEntities
///
/// @sa World, Fixture
///
class Body
{
public:
    
    /// @brief Container type for fixtures.
    using Fixtures = std::vector<Fixture*>;

    /// @brief Keyed joint pointer.
    using KeyedJointPtr = std::pair<Body*, Joint*>;

    /// @brief Container type for joints.
    using Joints = std::vector<KeyedJointPtr>;
    
    /// @brief Container type for contacts.
    using Contacts = std::vector<KeyedContactPtr>;

    /// @brief Invalid island index.
    static PLAYRHO_CONSTEXPR const auto InvalidIslandIndex = static_cast<BodyCounter>(-1);

    /// @brief Flags type.
    /// @note For internal use. Made public to facilitate unit testing.
    using FlagsType = std::uint16_t;
    
    /// @brief Flag enumeration.
    /// @note For internal use. Made public to facilitate unit testing.
    enum Flag: FlagsType
    {
        /// @brief Island flag.
        e_islandFlag = FlagsType(0x0001),

        /// @brief Awake flag.
        e_awakeFlag = FlagsType(0x0002),
        
        /// @brief Auto sleep flag.
        e_autoSleepFlag = FlagsType(0x0004),
        
        /// @brief Impenetrable flag.
        /// @details Indicates whether CCD should be done for this body.
        /// All static and kinematic bodies have this flag enabled.
        e_impenetrableFlag = FlagsType(0x0008),
        
        /// @brief Fixed rotation flag.
        e_fixedRotationFlag = FlagsType(0x0010),
        
        /// @brief Enabled flag.
        e_enabledFlag = FlagsType(0x0020),
        
        /// @brief Velocity flag.
        /// @details Set this to enable changes in position due to velocity.
        /// Bodies with this set are "speedable" - either kinematic or dynamic bodies.
        e_velocityFlag = FlagsType(0x0080),
        
        /// @brief Acceleration flag.
        /// @details Set this to enable changes in velocity due to physical properties (like forces).
        /// Bodies with this set are "accelerable" - dynamic bodies.
        e_accelerationFlag = FlagsType(0x0100),
        
        /// @brief Mass Data Dirty Flag.
        e_massDataDirtyFlag = FlagsType(0x0200),
    };
    
    /// @brief Gets the flags for the given value.
    static FlagsType GetFlags(BodyType type) noexcept;

    /// @brief Gets the flags for the given value.
    static FlagsType GetFlags(const BodyConf& bd) noexcept;
    
    /// @brief Creates a fixture and attaches it to this body.
    /// @details Creates a fixture for attaching a shape and other characteristics to this
    ///   body. Fixtures automatically go away when this body is destroyed. Fixtures can
    ///   also be manually removed and destroyed using the
    ///   <code>Destroy(Fixture*, bool)</code>, or <code>DestroyFixtures()</code> methods.
    ///
    /// @note This function should not be called if the world is locked.
    /// @warning This function is locked during callbacks.
    ///
    /// @post After creating a new fixture, it will show up in the fixture enumeration
    ///   returned by the <code>GetFixtures()</code> methods.
    ///
    /// @param shape Shareable shape definition.
    ///   Its vertex radius must be less than the minimum or more than the maximum allowed by
    ///   the body's world.
    /// @param def Initial fixture settings.
    ///   Friction and density must be >= 0.
    ///   Restitution must be > -infinity and < infinity.
    /// @param resetMassData Whether or not to reset the mass data of the body.
    ///
    /// @return Pointer to the created fixture.
    ///
    /// @throws WrongState if called while the world is "locked".
    /// @throws InvalidArgument if called for a shape with a vertex radius less than the
    ///    minimum vertex radius.
    /// @throws InvalidArgument if called for a shape with a vertex radius greater than the
    ///    maximum vertex radius.
    ///
    /// @sa Destroy, GetFixtures
    /// @sa PhysicalEntities
    ///
    Fixture* CreateFixture(const Shape& shape,
                           const FixtureConf& def = GetDefaultFixtureConf(),
                           bool resetMassData = true);

    /// @brief Destroys a fixture.
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
    ///
    /// @post After destroying a fixture, it will no longer show up in the fixture enumeration
    ///   returned by the <code>GetFixtures()</code> methods.
    ///
    /// @param fixture the fixture to be removed.
    /// @param resetMassData Whether or not to reset the mass data.
    ///
    /// @sa CreateFixture, GetFixtures, ResetMassData.
    /// @sa PhysicalEntities
    ///
    bool Destroy(Fixture* fixture, bool resetMassData = true);
    
    /// @brief Destroys fixtures.
    /// @details Destroys all of the fixtures previously created for this body by the
    ///   <code>CreateFixture(const Shape&, const FixtureConf&, bool)</code> method.
    /// @note This unconditionally calls the <code>ResetMassData()</code> method.
    /// @post After this call, no fixtures will show up in the fixture enumeration
    ///   returned by the <code>GetFixtures()</code> methods.
    /// @sa CreateFixture, GetFixtures, ResetMassData.
    /// @sa PhysicalEntities
    void DestroyFixtures();
    
    /// @brief Sets the position of the body's origin and rotation.
    /// @details This instantly adjusts the body to be at the new position and new orientation.
    /// @warning Manipulating a body's transform can cause non-physical behavior!
    /// @note Contacts are updated on the next call to World::Step.
    /// @param location Valid world location of the body's local origin. Behavior is undefined
    ///   if value is invalid.
    /// @param angle Valid world rotation. Behavior is undefined if value is invalid.
    void SetTransform(Length2 location, Angle angle);

    /// @brief Gets the body transform for the body's origin.
    /// @return the world transform of the body's origin.
    /// @sa GetLocation.
    Transformation GetTransformation() const noexcept;

    /// @brief Gets the world body origin location.
    /// @details This is the location of the body's origin relative to its world.
    /// The location of the body after stepping the world's physics simulations is dependent on
    /// a number of factors:
    ///   1. Location at the last time step.
    ///   2. Forces acting on the body (gravity, applied force, applied impulse).
    ///   3. The mass data of the body.
    ///   4. Damping of the body.
    ///   5. Restitution and friction values of the body's fixtures when they experience collisions.
    /// @return World location of the body's origin.
    /// @sa GetTransformation.
    Length2 GetLocation() const noexcept;

    /// @brief Gets the body's sweep.
    const Sweep& GetSweep() const noexcept;

    /// @brief Get the angle.
    /// @return the current world rotation angle.
    Angle GetAngle() const noexcept;

    /// @brief Get the world position of the center of mass.
    Length2 GetWorldCenter() const noexcept;

    /// @brief Gets the local position of the center of mass.
    Length2 GetLocalCenter() const noexcept;

    /// @brief Gets the velocity.
    Velocity GetVelocity() const noexcept;

    /// @brief Sets the body's velocity (linear and angular velocity).
    /// @note This method does nothing if this body is not speedable.
    /// @note A non-zero velocity will awaken this body.
    /// @sa SetAwake, SetUnderActiveTime.
    void SetVelocity(const Velocity& velocity) noexcept;

    /// @brief Sets the linear and rotational accelerations on this body.
    /// @note This has no effect on non-accelerable bodies.
    /// @note A non-zero acceleration will also awaken the body.
    /// @param linear Linear acceleration.
    /// @param angular Angular acceleration.
    void SetAcceleration(LinearAcceleration2 linear, AngularAcceleration angular) noexcept;

    /// @brief Gets this body's linear acceleration.
    LinearAcceleration2 GetLinearAcceleration() const noexcept;

    /// @brief Gets this body's angular acceleration.
    AngularAcceleration GetAngularAcceleration() const noexcept;

    /// @brief Gets the inverse total mass of the body.
    /// @details This is the cached result of dividing 1 by the body's mass.
    /// Often floating division is much slower than multiplication.
    /// As such, it's likely faster to multiply values by this inverse value than to redivide
    /// them all the time by the mass.
    /// @return Value of zero or more representing the body's inverse mass (in 1/kg).
    /// @sa SetMassData.
    InvMass GetInvMass() const noexcept;

    /// @brief Gets the inverse rotational inertia of the body.
    /// @details This is the cached result of dividing 1 by the body's rotational inertia.
    /// Often floating division is much slower than multiplication.
    /// As such, it's likely faster to multiply values by this inverse value than to redivide
    /// them all the time by the rotational inertia.
    /// @return Inverse rotational inertia (in 1/kg-m^2).
    InvRotInertia GetInvRotInertia() const noexcept;

    /// @brief Set the mass properties to override the mass properties of the fixtures.
    /// @note This changes the center of mass position.
    /// @note Creating or destroying fixtures can also alter the mass.
    /// @note This function has no effect if the body isn't dynamic.
    /// @param massData the mass properties.
    void SetMassData(const MassData& massData);

    /// @brief Resets the mass data properties.
    /// @details This resets the mass data to the sum of the mass properties of the fixtures.
    /// @note This method must be called after calling <code>CreateFixture</code> to update the
    ///   body mass data properties unless <code>SetMassData</code> is used.
    /// @sa SetMassData.
    void ResetMassData();

    /// @brief Gets the linear damping of the body.
    Frequency GetLinearDamping() const noexcept;

    /// @brief Sets the linear damping of the body.
    void SetLinearDamping(NonNegative<Frequency> linearDamping) noexcept;

    /// @brief Gets the angular damping of the body.
    Frequency GetAngularDamping() const noexcept;

    /// @brief Sets the angular damping of the body.
    void SetAngularDamping(NonNegative<Frequency> angularDamping) noexcept;

    /// @brief Sets the type of this body.
    /// @note This may alter the mass and velocity.
    void SetType(BodyType type);

    /// @brief Gets the type of this body.
    BodyType GetType() const noexcept;

    /// @brief Is "speedable".
    /// @details Is this body able to have a non-zero speed associated with it.
    /// Kinematic and Dynamic bodies are speedable. Static bodies are not.
    bool IsSpeedable() const noexcept;

    /// @brief Is "accelerable".
    /// @details Indicates whether this body is accelerable, i.e. whether it is effected by
    ///   forces. Only Dynamic bodies are accelerable.
    /// @return true if the body is accelerable, false otherwise.
    bool IsAccelerable() const noexcept;

    /// @brief Sets the bullet status of this body.
    /// @details Sets whether or not this body should be treated like a bullet for continuous
    ///   collision detection.
    void SetBullet(bool flag) noexcept;

    /// @brief Is this body treated like a bullet for continuous collision detection?
    bool IsImpenetrable() const noexcept;

    /// You can disable sleeping on this body. If you disable sleeping, the
    /// body will be woken.
    void SetSleepingAllowed(bool flag) noexcept;

    /// @brief Gets whether or not this body allowed to sleep
    bool IsSleepingAllowed() const noexcept;

    /// @brief Awakens this body.
    ///
    /// @details Sets this body to awake and resets its under-active time if it's a "speedable"
    ///   body. This method has no effect otherwise.
    ///
    /// @post If this body is a "speedable" body, then this body's <code>IsAwake</code> method
    ///   returns true.
    /// @post If this body is a "speedable" body, then this body's <code>GetUnderActiveTime</code>
    ///   method returns zero.
    ///
    void SetAwake() noexcept;

    /// @brief Sets this body to asleep if sleeping is allowed.
    ///
    /// @details If this body is allowed to sleep, this: sets the sleep state of the body to
    /// asleep, resets this body's under active time, and resets this body's velocity (linear
    /// and angular).
    ///
    /// @post This body's <code>IsAwake</code> method returns false.
    /// @post This body's <code>GetUnderActiveTime</code> method returns zero.
    /// @post This body's <code>GetVelocity</code> method returns zero linear and zero angular
    ///   speed.
    ///
    void UnsetAwake() noexcept;

    /// @brief Gets the awake/asleep state of this body.
    /// @warning Being awake may or may not imply being speedable.
    /// @return true if the body is awake.
    bool IsAwake() const noexcept;

    /// @brief Gets this body's under-active time value.
    /// @return Zero or more time in seconds (of step time) that this body has been
    ///   "under-active" for.
    Time GetUnderActiveTime() const noexcept;

    /// @brief Sets the "under-active" time to the given value.
    ///
    /// @details Sets the "under-active" time to a value of zero or a non-zero value if the
    ///   body is "accelerable". Otherwise it does nothing.
    ///
    /// @warning Behavior is undefined for negative values.
    /// @note A non-zero time is only valid for an "accelerable" body.
    ///
    void SetUnderActiveTime(Time value) noexcept;

    /// @brief Resets the under-active time for this body.
    /// @note This has performance degrading potential and is best not called unless the
    ///   caller is certain that it should be.
    void ResetUnderActiveTime() noexcept;

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
    void SetEnabled(bool flag);

    /// @brief Gets the enabled/disabled state of the body.
    bool IsEnabled() const noexcept;

    /// @brief Sets this body to have fixed rotation.
    /// @note This causes the mass to be reset.
    void SetFixedRotation(bool flag);

    /// @brief Does this body have fixed rotation?
    bool IsFixedRotation() const noexcept;

    /// @brief Gets the range of all constant fixtures attached to this body.
    SizedRange<Fixtures::const_iterator> GetFixtures() const noexcept;

    /// @brief Gets the range of all fixtures attached to this body.
    SizedRange<Fixtures::iterator> GetFixtures() noexcept;
    
    /// @brief Gets the range of all joints attached to this body.
    SizedRange<Joints::const_iterator> GetJoints() const noexcept;
 
    /// @brief Gets the range of all joints attached to this body.
    SizedRange<Joints::iterator> GetJoints() noexcept;
    
    /// @brief Gets the container of all contacts attached to this body.
    /// @warning This collection changes during the time step and you may
    ///   miss some collisions if you don't use <code>ContactListener</code>.
    SizedRange<Contacts::const_iterator> GetContacts() const noexcept;

    /// @brief Gets the user data pointer that was provided in the body definition.
    void* GetUserData() const noexcept;

    /// @brief Sets the user data. Use this to store your application specific data.
    void SetUserData(void* data) noexcept;

    /// @brief Gets the parent world of this body.
    World* GetWorld() const noexcept;

    /// @brief Gets whether the mass data for this body is "dirty".
    bool IsMassDataDirty() const noexcept;
    
private:

    friend class BodyAtty;
    
    Body() = delete;
    
    Body(const Body& other) = delete;

    /// @brief Initializing constructor.
    /// @note This is not meant to be called directly by users of the library API. Call
    ///   a world instance's <code>World::CreateBody</code> method instead.
    Body(World* world, const BodyConf& bd);
    
    ~Body() noexcept;
    
    /// @brief Whether this body is in is-in-island state.
    bool IsIslanded() const noexcept;

    /// @brief Sets this body to the is-in-island state.
    void SetIslandedFlag() noexcept;
    
    /// @brief Unsets this body to the is-in-island state.
    void UnsetIslandedFlag() noexcept;
    
    /// @brief Sets the body's awake flag.
    /// @details This is done unconditionally.
    /// @note This should **not** be called unless the body is "speedable".
    /// @warning Behavior is undefined if called for a body that is not "speedable".
    void SetAwakeFlag() noexcept;

    /// @brief Unsets the body's awake flag.
    void UnsetAwakeFlag() noexcept;

    /// Advances the body by a given time ratio.
    /// @details This method:
    ///    1. advances the body's sweep to the given time ratio;
    ///    2. updates the body's sweep positions (linear and angular) to the advanced ones; and
    ///    3. updates the body's transform to the new sweep one settings.
    /// @param alpha Valid new time factor in [0,1) to advance the sweep to.
    void Advance(Real alpha) noexcept;

    /// @brief Sets this body to have the mass data dirty state.
    void SetMassDataDirty() noexcept;
    
    /// @brief Unsets the body from being in the mass data dirty state.
    void UnsetMassDataDirty() noexcept;

    /// @brief Sets the enabled flag.
    void SetEnabledFlag() noexcept;
    
    /// @brief Unsets the enabled flag.
    void UnsetEnabledFlag() noexcept;

    /// @brief Inserts the given key and contact.
    bool Insert(ContactKey key, Contact* contact);
    
    /// @brief Inserts the given joint into this body's joints list.
    bool Insert(Joint* joint);

    /// @brief Erases the given contact from this body's contacts list.
    bool Erase(const Contact* contact);
    
    /// @brief Erases the given joint from this body's joints list.
    bool Erase(const Joint* joint);

    /// @brief Clears this body's contacts list.
    void ClearContacts();
    
    /// @brief Clears this body's joints list.
    void ClearJoints();

    /// @brief Sets the transformation for this body.
    /// @details If value is different than the current transformation, then this
    ///   method updates the current transformation and flags each associated contact
    ///   for updating.
    /// @warning Behavior is undefined if value is invalid.
    void SetTransformation(Transformation value) noexcept;

    //
    // Member variables. Try to keep total size small.
    //

    /// Transformation for body origin.
    /// @details
    /// This is essentially the cached result of <code>GetTransform1(m_sweep)</code>. 16-bytes.
    Transformation m_xf;

    Sweep m_sweep; ///< Sweep motion for CCD. 36-bytes.

    Velocity m_velocity; ///< Velocity (linear and angular). 12-bytes.
    FlagsType m_flags = 0; ///< Flags. 2-bytes.

    /// @brief Linear acceleration.
    /// @note 8-bytes.
    LinearAcceleration2 m_linearAcceleration = LinearAcceleration2{};

    World* const m_world; ///< World to which this body belongs. 8-bytes.
    void* m_userData; ///< User data. 8-bytes.
    
    Fixtures m_fixtures; ///< Container of fixtures.
    Contacts m_contacts; ///< Container of contacts (owned by world).
    Joints m_joints; ///< Container of joints (owned by world).

    /// @brief Angular acceleration.
    /// @note 4-bytes.
    AngularAcceleration m_angularAcceleration = AngularAcceleration{0};

    /// Inverse mass of the body.
    /// @details A non-negative value.
    /// Can only be zero for non-accelerable bodies.
    /// @note 4-bytes.
    InvMass m_invMass = 0;

    /// Inverse rotational inertia about the center of mass.
    /// @details A non-negative value.
    /// @note 4-bytes.
    InvRotInertia m_invRotI = 0;

    NonNegative<Frequency> m_linearDamping; ///< Linear damping. 4-bytes.
    NonNegative<Frequency> m_angularDamping; ///< Angular damping. 4-bytes.

    /// Under-active time.
    /// @details A body under-active for enough time should have their awake flag unset.
    ///   I.e. if a body is under-active for long enough, it should go to sleep.
    /// @note 4-bytes.
    Time m_underActiveTime = 0;
};

/// @example Body.cpp
/// This is the <code>googletest</code> based unit testing file for the
///   <code>playrho::d2::Body</code> class.

inline Body::FlagsType Body::GetFlags(BodyType type) noexcept
{
    auto flags = FlagsType{0};
    switch (type)
    {
        case BodyType::Dynamic:   flags |= (e_velocityFlag|e_accelerationFlag); break;
        case BodyType::Kinematic: flags |= (e_impenetrableFlag|e_velocityFlag); break;
        case BodyType::Static:    flags |= (e_impenetrableFlag); break;
    }
    return flags;
}

inline BodyType Body::GetType() const noexcept
{
    switch (m_flags & (e_accelerationFlag|e_velocityFlag))
    {
        case e_velocityFlag|e_accelerationFlag: return BodyType::Dynamic;
        case e_velocityFlag: return BodyType::Kinematic;
        default: break; // handle case 0 this way so compiler doesn't warn of no default handling.
    }
    return BodyType::Static;
}

inline Transformation Body::GetTransformation() const noexcept
{
    return m_xf;
}

inline Length2 Body::GetLocation() const noexcept
{
    return GetTransformation().p;
}

inline const Sweep& Body::GetSweep() const noexcept
{
    return m_sweep;
}

inline Angle Body::GetAngle() const noexcept
{
    return GetSweep().pos1.angular;
}

inline Length2 Body::GetWorldCenter() const noexcept
{
    return GetSweep().pos1.linear;
}

inline Length2 Body::GetLocalCenter() const noexcept
{
    return GetSweep().GetLocalCenter();
}

inline Velocity Body::GetVelocity() const noexcept
{
    return m_velocity;
}

inline InvMass Body::GetInvMass() const noexcept
{
    return m_invMass;
}

inline InvRotInertia Body::GetInvRotInertia() const noexcept
{
    return m_invRotI;
}

inline Frequency Body::GetLinearDamping() const noexcept
{
    return m_linearDamping;
}

inline void Body::SetLinearDamping(NonNegative<Frequency> linearDamping) noexcept
{
    m_linearDamping = linearDamping;
}

inline Frequency Body::GetAngularDamping() const noexcept
{
    return m_angularDamping;
}

inline void Body::SetAngularDamping(NonNegative<Frequency> angularDamping) noexcept
{
    m_angularDamping = angularDamping;
}

inline void Body::SetBullet(bool flag) noexcept
{
    if (flag)
    {
        m_flags |= e_impenetrableFlag;
    }
    else
    {
        m_flags &= ~e_impenetrableFlag;
    }
}

inline bool Body::IsImpenetrable() const noexcept
{
    return (m_flags & e_impenetrableFlag) != 0;
}

inline void Body::SetAwakeFlag() noexcept
{
    // Protect the body's invariant that only "speedable" bodies can be awake.
    assert(IsSpeedable());

    m_flags |= e_awakeFlag;
}

inline void Body::UnsetAwakeFlag() noexcept
{
    assert(!IsSpeedable() || IsSleepingAllowed());
    m_flags &= ~e_awakeFlag;
}

inline void Body::SetAwake() noexcept
{
    // Ignore this request unless this body is speedable so as to maintain the body's invariant
    // that only "speedable" bodies can be awake.
    if (IsSpeedable())
    {
    	SetAwakeFlag();
        ResetUnderActiveTime();
    }
}

inline void Body::UnsetAwake() noexcept
{
    if (!IsSpeedable() || IsSleepingAllowed())
    {
        UnsetAwakeFlag();
        m_underActiveTime = 0;
        m_velocity = Velocity{LinearVelocity2{}, 0_rpm};
    }
}

inline bool Body::IsAwake() const noexcept
{
    return (m_flags & e_awakeFlag) != 0;
}

inline Time Body::GetUnderActiveTime() const noexcept
{
    return m_underActiveTime;
}

inline void Body::SetUnderActiveTime(Time value) noexcept
{
    if ((value == 0_s) || IsAccelerable())
    {
        m_underActiveTime = value;
    }
}

inline void Body::ResetUnderActiveTime() noexcept
{
    m_underActiveTime = 0_s;
}

inline bool Body::IsEnabled() const noexcept
{
    return (m_flags & e_enabledFlag) != 0;
}

inline bool Body::IsFixedRotation() const noexcept
{
    return (m_flags & e_fixedRotationFlag) != 0;
}

inline bool Body::IsSpeedable() const noexcept
{
    return (m_flags & e_velocityFlag) != 0;
}

inline bool Body::IsAccelerable() const noexcept
{
    return (m_flags & e_accelerationFlag) != 0;
}

inline void Body::SetSleepingAllowed(bool flag) noexcept
{
    if (flag)
    {
        m_flags |= e_autoSleepFlag;
    }
    else if (IsSpeedable())
    {
        m_flags &= ~e_autoSleepFlag;
        SetAwakeFlag();
        ResetUnderActiveTime();
    }
}

inline bool Body::IsSleepingAllowed() const noexcept
{
    return (m_flags & e_autoSleepFlag) != 0;
}

inline SizedRange<Body::Fixtures::const_iterator> Body::GetFixtures() const noexcept
{
    return {begin(m_fixtures), end(m_fixtures), size(m_fixtures)};
}

inline SizedRange<Body::Fixtures::iterator> Body::GetFixtures() noexcept
{
    return {begin(m_fixtures), end(m_fixtures), size(m_fixtures)};
}

inline SizedRange<Body::Joints::const_iterator> Body::GetJoints() const noexcept
{
    return {begin(m_joints), end(m_joints), size(m_joints)};
}

inline SizedRange<Body::Joints::iterator> Body::GetJoints() noexcept
{
    return {begin(m_joints), end(m_joints), size(m_joints)};
}

inline SizedRange<Body::Contacts::const_iterator> Body::GetContacts() const noexcept
{
    return {begin(m_contacts), end(m_contacts), size(m_contacts)};
}

inline void Body::SetUserData(void* data) noexcept
{
    m_userData = data;
}

inline void* Body::GetUserData() const noexcept
{
    return m_userData;
}

inline LinearAcceleration2 Body::GetLinearAcceleration() const noexcept
{
    return m_linearAcceleration;
}

inline AngularAcceleration Body::GetAngularAcceleration() const noexcept
{
    return m_angularAcceleration;
}

inline void Body::Advance(Real alpha) noexcept
{
    //assert(m_sweep.GetAlpha0() <= alpha);
    assert(IsSpeedable() || m_sweep.pos1 == m_sweep.pos0);

    // Advance to the new safe time. This doesn't sync the broad-phase.
    m_sweep.Advance0(alpha);
    m_sweep.pos1 = m_sweep.pos0;
    SetTransformation(GetTransform1(m_sweep));
}

inline World* Body::GetWorld() const noexcept
{
    return m_world;
}

inline void Body::SetMassDataDirty() noexcept
{
    m_flags |= e_massDataDirtyFlag;
}

inline void Body::UnsetMassDataDirty() noexcept
{
    m_flags &= ~e_massDataDirtyFlag;
}

inline bool Body::IsMassDataDirty() const noexcept
{
    return (m_flags & e_massDataDirtyFlag) != 0;
}

inline void Body::SetEnabledFlag() noexcept
{
    m_flags |= e_enabledFlag;
}

inline void Body::UnsetEnabledFlag() noexcept
{
    m_flags &= ~e_enabledFlag;
}

inline bool Body::IsIslanded() const noexcept
{
    return (m_flags & e_islandFlag) != 0;
}

inline void Body::SetIslandedFlag() noexcept
{
    m_flags |= e_islandFlag;
}

inline void Body::UnsetIslandedFlag() noexcept
{
    m_flags &= ~e_islandFlag;
}

// Free functions...

/// @brief Gets the given body's acceleration.
/// @param body Body whose acceleration should be returned.
/// @relatedalso Body
inline Acceleration GetAcceleration(const Body& body) noexcept
{
    return Acceleration{body.GetLinearAcceleration(), body.GetAngularAcceleration()};
}

/// @brief Sets the accelerations on the given body.
/// @note This has no effect on non-accelerable bodies.
/// @note A non-zero acceleration will also awaken the body.
/// @param body Body whose acceleration should be set.
/// @param value Acceleration value to set.
/// @relatedalso Body
inline void SetAcceleration(Body& body, Acceleration value) noexcept
{
    body.SetAcceleration(value.linear, value.angular);
}

/// @brief Calculates the gravitationally associated acceleration for the given body
///   within its world.
/// @relatedalso Body
/// @return Zero acceleration if given body is has no mass, else the acceleration of
///    the body due to the gravitational attraction to the other bodies.
Acceleration CalcGravitationalAcceleration(const Body& body) noexcept;
    
/// @brief Awakens the body if it's asleep.
/// @relatedalso Body
inline bool Awaken(Body& body) noexcept
{
    if (!body.IsAwake() && body.IsSpeedable())
    {
        body.SetAwake();
        return true;
    }
    return false;
}

/// @brief Puts the body to sleep if it's awake.
/// @relatedalso Body
inline bool Unawaken(Body& body) noexcept
{
    if (body.IsAwake() && body.IsSleepingAllowed())
    {
        body.UnsetAwake();
        return true;
    }
    return false;
}

/// @brief Should collide.
/// @details Determines whether a body should possibly be able to collide with the other body.
/// @relatedalso Body
/// @return true if either body is dynamic and no joint prevents collision, false otherwise.
bool ShouldCollide(const Body& lhs, const Body& rhs) noexcept;

/// @brief Gets the "position 1" Position information for the given body.
/// @relatedalso Body
inline Position GetPosition1(const Body& body) noexcept
{
    return body.GetSweep().pos1;
}

/// @brief Gets the mass of the body.
/// @note This may be the total calculated mass or it may be the set mass of the body.
/// @return Value of zero or more representing the body's mass.
/// @sa GetInvMass, SetMassData
/// @relatedalso Body
inline Mass GetMass(const Body& body) noexcept
{
    const auto invMass = body.GetInvMass();
    return (invMass != InvMass{0})? Mass{Real{1} / invMass}: 0_kg;
}

/// @brief Sets the given linear acceleration of the given body.
/// @relatedalso Body
inline void SetLinearAcceleration(Body& body, LinearAcceleration2 value) noexcept
{
    body.SetAcceleration(value, body.GetAngularAcceleration());
}

/// @brief Sets the given angular acceleration of the given body.
/// @relatedalso Body
inline void SetAngularAcceleration(Body& body, AngularAcceleration value) noexcept
{
    body.SetAcceleration(body.GetLinearAcceleration(), value);
}

/// @brief Applies the given linear acceleration to the given body.
/// @relatedalso Body
inline void ApplyLinearAcceleration(Body& body, LinearAcceleration2 amount)
{
    SetLinearAcceleration(body, body.GetLinearAcceleration() + amount);
}

/// @brief Sets the given amount of force at the given point to the given body.
/// @relatedalso Body
inline void SetForce(Body& body, Force2 force, Length2 point) noexcept
{
    const auto linAccel = LinearAcceleration2{force * body.GetInvMass()};
    const auto invRotI = body.GetInvRotInertia();
    const auto dp = point - body.GetWorldCenter();
    const auto cp = Torque{Cross(dp, force) / Radian};
    const auto angAccel = AngularAcceleration{cp * invRotI};
    body.SetAcceleration(linAccel, angAccel);
}

/// @brief Apply a force at a world point.
/// @note If the force is not applied at the center of mass, it will generate a torque and
///   affect the angular velocity.
/// @note Non-zero forces wakes up the body.
/// @param body Body to apply the force to.
/// @param force World force vector.
/// @param point World position of the point of application.
/// @relatedalso Body
inline void ApplyForce(Body& body, Force2 force, Length2 point) noexcept
{
    // Torque is L^2 M T^-2 QP^-1.
    const auto linAccel = LinearAcceleration2{force * body.GetInvMass()};
    const auto invRotI = body.GetInvRotInertia(); // L^-2 M^-1 QP^2
    const auto dp = Length2{point - body.GetWorldCenter()}; // L
    const auto cp = Torque{Cross(dp, force) / Radian}; // L * M L T^-2 is L^2 M T^-2
    // L^2 M T^-2 QP^-1 * L^-2 M^-1 QP^2 = QP T^-2;
    const auto angAccel = AngularAcceleration{cp * invRotI};
    body.SetAcceleration(body.GetLinearAcceleration() + linAccel,
                         body.GetAngularAcceleration() + angAccel);
}

/// @brief Apply a force to the center of mass.
/// @note Non-zero forces wakes up the body.
/// @param body Body to apply the force to.
/// @param force World force vector.
/// @relatedalso Body
inline void ApplyForceToCenter(Body& body, Force2 force) noexcept
{
    const auto linAccel = body.GetLinearAcceleration() + force * body.GetInvMass();
    const auto angAccel = body.GetAngularAcceleration();
    body.SetAcceleration(linAccel, angAccel);
}

/// @brief Sets the given amount of torque to the given body.
/// @relatedalso Body
inline void SetTorque(Body& body, Torque torque) noexcept
{
    const auto linAccel = body.GetLinearAcceleration();
    const auto invRotI = body.GetInvRotInertia();
    const auto angAccel = torque * invRotI;
    body.SetAcceleration(linAccel, angAccel);
}

/// @brief Applies a torque.
/// @note This affects the angular velocity without affecting the linear velocity of the
///   center of mass.
/// @note Non-zero forces wakes up the body.
/// @param body Body to apply the torque to.
/// @param torque about the z-axis (out of the screen).
/// @relatedalso Body
inline void ApplyTorque(Body& body, Torque torque) noexcept
{
    const auto linAccel = body.GetLinearAcceleration();
    const auto invRotI = body.GetInvRotInertia();
    const auto angAccel = body.GetAngularAcceleration() + torque * invRotI;
    body.SetAcceleration(linAccel, angAccel);
}

/// @brief Applies an impulse at a point.
/// @note This immediately modifies the velocity.
/// @note This also modifies the angular velocity if the point of application
///   is not at the center of mass.
/// @note Non-zero impulses wakes up the body.
/// @param body Body to apply the impulse to.
/// @param impulse the world impulse vector.
/// @param point the world position of the point of application.
/// @relatedalso Body
inline void ApplyLinearImpulse(Body& body, Momentum2 impulse, Length2 point) noexcept
{
    auto velocity = body.GetVelocity();
    velocity.linear += body.GetInvMass() * impulse;
    const auto invRotI = body.GetInvRotInertia();
    const auto dp = point - body.GetWorldCenter();
    velocity.angular += AngularVelocity{invRotI * Cross(dp, impulse) / Radian};
    body.SetVelocity(velocity);
}

/// @brief Applies an angular impulse.
/// @param body Body to apply the angular impulse to.
/// @param impulse Angular impulse to be applied.
/// @relatedalso Body
inline void ApplyAngularImpulse(Body& body, AngularMomentum impulse) noexcept
{
    auto velocity = body.GetVelocity();
    const auto invRotI = body.GetInvRotInertia();
    velocity.angular += AngularVelocity{invRotI * impulse};
    body.SetVelocity(velocity);
}

/// @brief Gets the centripetal force necessary to put the body into an orbit having
///    the given radius.
/// @relatedalso Body
Force2 GetCentripetalForce(const Body& body, Length2 axis);

/// @brief Gets the rotational inertia of the body.
/// @param body Body to get the rotational inertia for.
/// @return the rotational inertia.
/// @relatedalso Body
inline RotInertia GetRotInertia(const Body& body) noexcept
{
    return Real{1} / body.GetInvRotInertia();
}

/// @brief Gets the rotational inertia of the body about the local origin.
/// @return the rotational inertia.
/// @relatedalso Body
inline RotInertia GetLocalRotInertia(const Body& body) noexcept
{
    return GetRotInertia(body)
         + GetMass(body) * GetMagnitudeSquared(body.GetLocalCenter()) / SquareRadian;
}

/// @brief Gets the linear velocity of the center of mass.
/// @param body Body to get the linear velocity for.
/// @return the linear velocity of the center of mass.
/// @relatedalso Body
inline LinearVelocity2 GetLinearVelocity(const Body& body) noexcept
{
    return body.GetVelocity().linear;
}

/// @brief Gets the angular velocity.
/// @param body Body to get the angular velocity for.
/// @return the angular velocity.
/// @relatedalso Body
inline AngularVelocity GetAngularVelocity(const Body& body) noexcept
{
    return body.GetVelocity().angular;
}

/// @brief Sets the linear velocity of the center of mass.
/// @param body Body to set the linear velocity of.
/// @param v the new linear velocity of the center of mass.
/// @relatedalso Body
inline void SetLinearVelocity(Body& body, const LinearVelocity2 v) noexcept
{
    body.SetVelocity(Velocity{v, GetAngularVelocity(body)});
}

/// @brief Sets the angular velocity.
/// @param body Body to set the angular velocity of.
/// @param omega the new angular velocity.
/// @relatedalso Body
inline void SetAngularVelocity(Body& body, AngularVelocity omega) noexcept
{
    body.SetVelocity(Velocity{GetLinearVelocity(body), omega});
}

/// @brief Gets the world coordinates of a point given in coordinates relative to the body's origin.
/// @param body Body that the given point is relative to.
/// @param localPoint a point measured relative the the body's origin.
/// @return the same point expressed in world coordinates.
/// @relatedalso Body
inline Length2 GetWorldPoint(const Body& body, const Length2 localPoint) noexcept
{
    return Transform(localPoint, body.GetTransformation());
}

/// @brief Gets the world coordinates of a vector given the local coordinates.
/// @param body Body that the given vector is relative to.
/// @param localVector a vector fixed in the body.
/// @return the same vector expressed in world coordinates.
/// @relatedalso Body
inline Length2 GetWorldVector(const Body& body, const Length2 localVector) noexcept
{
    return Rotate(localVector, body.GetTransformation().q);
}

/// @brief Gets the world vector for the given local vector from the given body's transformation.
/// @relatedalso Body
inline UnitVec GetWorldVector(const Body& body, const UnitVec localVector) noexcept
{
    return Rotate(localVector, body.GetTransformation().q);
}

/// @brief Gets a local point relative to the body's origin given a world point.
/// @param body Body that the returned point should be relative to.
/// @param worldPoint point in world coordinates.
/// @return the corresponding local point relative to the body's origin.
/// @relatedalso Body
inline Length2 GetLocalPoint(const Body& body, const Length2 worldPoint) noexcept
{
    return InverseTransform(worldPoint, body.GetTransformation());
}

/// @brief Gets a locally oriented unit vector given a world oriented unit vector.
/// @param body Body that the returned vector should be relative to.
/// @param uv Unit vector in world orientation.
/// @return the corresponding local vector.
/// @relatedalso Body
inline UnitVec GetLocalVector(const Body& body, const UnitVec uv) noexcept
{
    return InverseRotate(uv, body.GetTransformation().q);
}

/// @brief Gets the linear velocity from a world point attached to this body.
/// @param body Body to get the linear velocity for.
/// @param worldPoint point in world coordinates.
/// @return the world velocity of a point.
/// @relatedalso Body
inline LinearVelocity2 GetLinearVelocityFromWorldPoint(const Body& body,
                                                        const Length2 worldPoint) noexcept
{
    const auto velocity = body.GetVelocity();
    const auto worldCtr = body.GetWorldCenter();
    const auto dp = Length2{worldPoint - worldCtr};
    const auto rlv = LinearVelocity2{GetRevPerpendicular(dp) * (velocity.angular / Radian)};
    return velocity.linear + rlv;
}

/// @brief Gets the linear velocity from a local point.
/// @param body Body to get the linear velocity for.
/// @param localPoint point in local coordinates.
/// @return the world velocity of a point.
/// @relatedalso Body
inline LinearVelocity2 GetLinearVelocityFromLocalPoint(const Body& body,
                                                        const Length2 localPoint) noexcept
{
    return GetLinearVelocityFromWorldPoint(body, GetWorldPoint(body, localPoint));
}

/// @brief Gets the net force that the given body is currently experiencing.
/// @relatedalso Body
inline Force2 GetForce(const Body& body) noexcept
{
    return body.GetLinearAcceleration() * GetMass(body);
}

/// @brief Gets the net torque that the given body is currently experiencing.
/// @relatedalso Body
inline Torque GetTorque(const Body& body) noexcept
{
    return body.GetAngularAcceleration() * GetRotInertia(body);
}

/// @brief Caps velocity.
/// @details Enforces maximums on the given velocity.
/// @param velocity Velocity to cap. Behavior is undefined if this value is invalid.
/// @param h Time elapsed to get velocity for. Behavior is undefined if this value is invalid.
/// @param conf Movement configuration. This defines caps on linear and angular speeds.
/// @relatedalso Velocity
Velocity Cap(Velocity velocity, Time h, MovementConf conf) noexcept;

/// @brief Gets the velocity of the body after the given time accounting for the body's
///   acceleration and capped by the given configuration.
/// @warning Behavior is undefined if the given elapsed time is an invalid value (like NaN).
/// @param body Body to get the velocity for.
/// @param h Time elapsed to get velocity for. Behavior is undefined if this value is invalid.
/// @relatedalso Body
Velocity GetVelocity(const Body& body, Time h) noexcept;

/// @brief Gets the world index for the given body.
/// @relatedalso Body
BodyCounter GetWorldIndex(const Body* body) noexcept;

/// @brief Gets the fixture count of the given body.
/// @relatedalso Body
std::size_t GetFixtureCount(const Body& body) noexcept;

/// @brief Rotates a body a given amount around a point in world coordinates.
/// @details This changes both the linear and angular positions of the body.
/// @note Manipulating a body's position this way may cause non-physical behavior.
/// @param body Body to rotate.
/// @param amount Amount to rotate body by (in counter-clockwise direction).
/// @param worldPoint Point in world coordinates.
/// @relatedalso Body
void RotateAboutWorldPoint(Body& body, Angle amount, Length2 worldPoint);

/// @brief Rotates a body a given amount around a point in body local coordinates.
/// @details This changes both the linear and angular positions of the body.
/// @note Manipulating a body's position this way may cause non-physical behavior.
/// @note This is a convenience function that translates the local point into world coordinates
///   and then calls the <code>RotateAboutWorldPoint</code> function.
/// @param body Body to rotate.
/// @param amount Amount to rotate body by (in counter-clockwise direction).
/// @param localPoint Point in local coordinates.
/// @relatedalso Body
void RotateAboutLocalPoint(Body& body, Angle amount, Length2 localPoint);

/// @brief Gets the body's origin location.
/// @details This is the location of the body's origin relative to its world.
/// The location of the body after stepping the world's physics simulations is dependent on
/// a number of factors:
///   1. Location at the last time step.
///   2. Forces acting on the body (gravity, applied force, applied impulse).
///   3. The mass data of the body.
///   4. Damping of the body.
///   5. Restitution and friction values of the body's fixtures when they experience collisions.
/// @return World location of the body's origin.
/// @sa GetAngle.
/// @relatedalso Body
inline Length2 GetLocation(const Body& body) noexcept
{
    return body.GetTransformation().p;
}

/// @brief Gets the body's angle.
/// @return Body's angle relative to its World.
/// @relatedalso Body
inline Angle GetAngle(const Body& body) noexcept
{
    return body.GetSweep().pos1.angular;
}

/// @brief Gets the body's transformation.
inline Transformation GetTransformation(const Body& body) noexcept
{
    return body.GetTransformation();
}

/// @brief Sets the body's transformation.
/// @note This operation isn't exact. I.e. don't expect that <code>GetTransformation</code>
///   will return exactly the transformation that had been set.
inline void SetTransformation(Body& body, const Transformation& xfm) noexcept
{
    body.SetTransform(xfm.p, GetAngle(xfm.q));
}

/// @brief Gets the body's position.
inline Position GetPosition(const Body& body) noexcept
{
    return Position{body.GetLocation(), body.GetAngle()};
}

/// @brief Sets the body's location.
/// @details This instantly adjusts the body to be at the new location.
/// @warning Manipulating a body's location this way can cause non-physical behavior!
/// @param body Body to move.
/// @param value Valid world location of the body's local origin. Behavior is undefined
///   if value is invalid.
/// @sa Body::SetTransform
/// @relatedalso Body
inline void SetLocation(Body& body, Length2 value) noexcept
{
    body.SetTransform(value, GetAngle(body));
}

/// @brief Sets the body's angular orientation.
/// @details This instantly adjusts the body to be at the new angular orientation.
/// @warning Manipulating a body's angle this way can cause non-physical behavior!
/// @param body Body to move.
/// @param value Valid world angle of the body's local origin. Behavior is undefined
///   if value is invalid.
/// @sa Body::SetTransform
/// @relatedalso Body
inline void SetAngle(Body& body, Angle value) noexcept
{
    body.SetTransform(GetLocation(body), value);
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_BODY_HPP

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

#ifndef PLAYRHO_DYNAMICS_BODY_HPP
#define PLAYRHO_DYNAMICS_BODY_HPP

/// @file
/// Declarations of the Body class, and free functions associated with it.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Range.hpp"
#include "PlayRho/Dynamics/BodyType.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/MovementConf.hpp"
#include "PlayRho/Collision/MassData.hpp"

#include <cassert>
#include <utility>

namespace playrho {
namespace d2 {

struct FixtureConf;
class Shape;

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
/// @note Destroy these using the <code>World::Destroy(BodyID)</code> method.
/// @note From a memory management perspective, bodies own Fixture instances.
/// @note On a 64-bit architecture with 4-byte Real, this data structure is at least
///   192-bytes large.
///
/// @ingroup PhysicalEntities
///
/// @see World, Fixture
///
class Body
{
public:
    /// @brief Initializing constructor.
    explicit Body(const BodyConf& bd = GetDefaultBodyConf()) noexcept;

    /// @brief Gets the body transform for the body's origin.
    /// @return the world transform of the body's origin.
    /// @see GetLocation, Body::SetTransformation.
    Transformation GetTransformation() const noexcept;

    /// @brief Sets the body's transformation.
    /// @note This sets what <code>Body::GetLocation</code> returns.
    /// @note <code>SetSweep</code> may also need to be called.
    /// @post <code>GetTransformation</code> will return the value set.
    /// @see Body::GetLocation, Body::GetTransformation, SetSweep
    void SetTransformation(Transformation value) noexcept;

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
    /// @see GetTransformation.
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
    /// @see SetAwake, SetUnderActiveTime.
    void SetVelocity(const Velocity& velocity) noexcept;

    /// Sets the body's velocity.
    /// @note This sets what <code>Body::GetVelocity</code> returns.
    /// @see Body::GetVelocity
    void JustSetVelocity(Velocity value) noexcept
    {
        m_linearVelocity = value.linear;
        m_angularVelocity = value.angular;
    }

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
    /// @see SetInvMass.
    InvMass GetInvMass() const noexcept;

    /// @brief Gets the inverse rotational inertia of the body.
    /// @details This is the cached result of dividing 1 by the body's rotational inertia.
    /// Often floating division is much slower than multiplication.
    /// As such, it's likely faster to multiply values by this inverse value than to redivide
    /// them all the time by the rotational inertia.
    /// @return Inverse rotational inertia (in 1/kg-m^2).
    InvRotInertia GetInvRotInertia() const noexcept;

    /// @brief Gets the linear damping of the body.
    Frequency GetLinearDamping() const noexcept;

    /// @brief Sets the linear damping of the body.
    void SetLinearDamping(NonNegative<Frequency> linearDamping) noexcept;

    /// @brief Gets the angular damping of the body.
    Frequency GetAngularDamping() const noexcept;

    /// @brief Sets the angular damping of the body.
    void SetAngularDamping(NonNegative<Frequency> angularDamping) noexcept;

    /// @brief Gets the type of this body.
    /// @see SetType.
    BodyType GetType() const noexcept;

    /// @brief Sets the type of this body.
    /// @see GetType.
    void SetType(BodyType value) noexcept;

    /// @brief Is "speedable".
    /// @details Is this body able to have a non-zero speed associated with it.
    /// Kinematic and Dynamic bodies are speedable. Static bodies are not.
    bool IsSpeedable() const noexcept;

    /// @brief Is "accelerable".
    /// @details Indicates whether this body is accelerable, i.e. whether it is effected by
    ///   forces. Only Dynamic bodies are accelerable.
    /// @return true if the body is accelerable, false otherwise.
    bool IsAccelerable() const noexcept;

    /// @brief Is this body treated like a bullet for continuous collision detection?
    bool IsImpenetrable() const noexcept;

    /// @brief Sets the impenetrable status of this body.
    /// @details Sets whether or not this body should be treated like a bullet for continuous
    ///   collision detection.
    void SetImpenetrable() noexcept;

    /// @brief Unsets the impenetrable status of this body.
    /// @details Sets whether or not this body should be treated like a bullet for continuous
    ///   collision detection.
    void UnsetImpenetrable() noexcept;

    /// @brief Gets whether or not this body allowed to sleep
    bool IsSleepingAllowed() const noexcept;

    /// You can disable sleeping on this body. If you disable sleeping, the
    /// body will be woken.
    void SetSleepingAllowed(bool flag) noexcept;

    /// @brief Gets the awake/asleep state of this body.
    /// @warning Being awake may or may not imply being speedable.
    /// @return true if the body is awake.
    bool IsAwake() const noexcept;

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

    /// @brief Gets the enabled/disabled state of the body.
    /// @see SetEnabled.
    bool IsEnabled() const noexcept;

    /// @brief Does this body have fixed rotation?
    bool IsFixedRotation() const noexcept;

    /// @brief Sets this body to have fixed rotation.
    /// @note This causes the mass to be reset.
    void SetFixedRotation(bool flag);

    /// @brief Gets whether the mass data for this body is "dirty".
    bool IsMassDataDirty() const noexcept;

    /// @brief Sets the body's awake flag.
    /// @details This is done unconditionally.
    /// @note This should **not** be called unless the body is "speedable".
    /// @warning Behavior is undefined if called for a body that is not "speedable".
    void SetAwakeFlag() noexcept;

    /// @brief Unsets the body's awake flag.
    void UnsetAwakeFlag() noexcept;

    /// @brief Sets this body to have the mass data dirty state.
    void SetMassDataDirty() noexcept;

    /// @brief Unsets the body from being in the mass data dirty state.
    void UnsetMassDataDirty() noexcept;

    /// @brief Sets the enabled state.
    void SetEnabled() noexcept;

    /// @brief Unsets the enabled flag.
    void UnsetEnabled() noexcept;

    /// @brief Sets the inverse rotational inertia.
    void SetInvRotI(InvRotInertia v) noexcept
    {
        m_invRotI = v;
    }

    /// @brief Sets the inverse mass.
    /// @see GetInvMass
    void SetInvMass(InvMass v) noexcept
    {
        m_invMass = v;
    }

    /// @brief Sets the "position 0" value of the body to the given position.
    void SetPosition0(const Position value) noexcept
    {
        assert(IsSpeedable() || m_sweep.pos0 == value);
        m_sweep.pos0 = value;
    }

    /// @brief Sets the body sweep's "position 1" value.
    /// @note This sets what <code>Body::GetWorldCenter</code> returns.
    /// @see Body::GetWorldCenter
    void SetPosition1(const Position value) noexcept
    {
        assert(IsSpeedable() || m_sweep.pos1 == value);
        m_sweep.pos1 = value;
    }

    /// @brief Resets the given body's "alpha-0" value.
    void ResetAlpha0() noexcept
    {
        m_sweep.ResetAlpha0();
    }

    /// @brief Sets the sweep value of the given body.
    void SetSweep(const Sweep value) noexcept
    {
        assert(IsSpeedable() || value.pos0 == value.pos1);
        m_sweep = value;
    }

    /// @brief Restores the given body's sweep to the given sweep value.
    void Restore(const Sweep& value) noexcept
    {
        SetSweep(value);
        SetTransformation(GetTransform1(value));
    }

    /// @brief Calls the body sweep's <code>Advance0</code> method to advance to
    ///    the given value.
    void Advance0(Real value) noexcept
    {
        // Note: Static bodies must **never** have different sweep position values.

        // Confirm bodies don't have different sweep positions to begin with...
        assert(IsSpeedable() || m_sweep.pos1 == m_sweep.pos0);

        m_sweep.Advance0(value);

        // Confirm bodies don't have different sweep positions to end with...
        assert(IsSpeedable() || m_sweep.pos1 == m_sweep.pos0);
    }

    /// Advances the body by a given time ratio.
    /// @details This method:
    ///    1. advances the body's sweep to the given time ratio;
    ///    2. updates the body's sweep positions (linear and angular) to the advanced ones; and
    ///    3. updates the body's transform to the new sweep one settings.
    /// @param value Valid new time factor in [0,1) to advance the sweep to.
    void Advance(Real value) noexcept
    {
        //assert(m_sweep.GetAlpha0() <= alpha);
        assert(IsSpeedable() || m_sweep.pos1 == m_sweep.pos0);

        // Advance to the new safe time. This doesn't sync the broad-phase.
        m_sweep.Advance0(value);
        m_sweep.pos1 = m_sweep.pos0;
        m_xf = GetTransform1(m_sweep);
    }

private:
    /// @brief Flags type.
    /// @note For internal use. Made public to facilitate unit testing.
    using FlagsType = std::uint16_t;

    /// @brief Flag enumeration.
    /// @note For internal use. Made public to facilitate unit testing.
    enum Flag: FlagsType
    {
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

    //
    // Member variables. Try to keep total size small.
    //

    /// Transformation for body origin.
    /// @note Also availble from <code>GetTransform1(m_sweep)</code>.
    /// @note 16-bytes.
    Transformation m_xf;

    Sweep m_sweep; ///< Sweep motion for CCD. 36-bytes.

    FlagsType m_flags = 0; ///< Flags. 2-bytes.

    /// @brief Linear velocity.
    /// @note 8-bytes.
    LinearVelocity2 m_linearVelocity = LinearVelocity2{};

    /// @brief Linear acceleration.
    /// @note 8-bytes.
    LinearAcceleration2 m_linearAcceleration = LinearAcceleration2{};

    /// @brief Angular velocity.
    /// @note 4-bytes.
    AngularVelocity m_angularVelocity = AngularVelocity{};

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

    NonNegative<Frequency> m_linearDamping{}; ///< Linear damping. 4-bytes.
    NonNegative<Frequency> m_angularDamping{}; ///< Angular damping. 4-bytes.

    /// Under-active time.
    /// @details A body under-active for enough time should have their awake flag unset.
    ///   I.e. if a body is under-active for long enough, it should go to sleep.
    /// @note 4-bytes.
    Time m_underActiveTime = 0;
};

inline Transformation Body::GetTransformation() const noexcept
{
    return m_xf;
}

inline void Body::SetTransformation(Transformation value) noexcept
{
    m_xf = value;
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
    // Angle could also come from the body's transformation but that requires converting
    // from its unit vector to an angle while that angle is already cached in position 1 of
    // the sweep.
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
    return Velocity{m_linearVelocity, m_angularVelocity};
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

inline bool Body::IsImpenetrable() const noexcept
{
    return (m_flags & e_impenetrableFlag) != 0;
}

inline void Body::SetImpenetrable() noexcept
{
    m_flags |= e_impenetrableFlag;
}

inline void Body::UnsetImpenetrable() noexcept
{
    m_flags &= ~e_impenetrableFlag;
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

inline bool Body::IsSleepingAllowed() const noexcept
{
    return (m_flags & e_autoSleepFlag) != 0;
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

inline LinearAcceleration2 Body::GetLinearAcceleration() const noexcept
{
    return m_linearAcceleration;
}

inline AngularAcceleration Body::GetAngularAcceleration() const noexcept
{
    return m_angularAcceleration;
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

inline void Body::SetEnabled() noexcept
{
    m_flags |= e_enabledFlag;
}

inline void Body::UnsetEnabled() noexcept
{
    m_flags &= ~e_enabledFlag;
}

// Free functions...

/// @brief Gets the type of this body.
/// @see SetType.
/// @relatedalso Body
inline BodyType GetType(const Body& body) noexcept
{
    return body.GetType();
}

/// @brief Sets the type of this body.
/// @relatedalso Body
inline void SetType(Body& body, BodyType value) noexcept
{
    body.SetType(value);
}

/// @brief Is "speedable".
/// @details Is this body able to have a non-zero speed associated with it.
/// Kinematic and Dynamic bodies are speedable. Static bodies are not.
/// @relatedalso Body
inline bool IsSpeedable(const Body& body) noexcept
{
    return body.IsSpeedable();
}

/// @brief Is "accelerable".
/// @details Indicates whether this body is accelerable, i.e. whether it is effected by
///   forces. Only Dynamic bodies are accelerable.
/// @return true if the body is accelerable, false otherwise.
/// @relatedalso Body
inline bool IsAccelerable(const Body& body) noexcept
{
    return body.IsAccelerable();
}

/// @brief Is this body treated like a bullet for continuous collision detection?
/// @relatedalso Body
inline bool IsImpenetrable(const Body& body) noexcept
{
    return body.IsImpenetrable();
}

/// @brief Sets the impenetrable status of this body.
/// @details Sets whether or not this body should be treated like a bullet for continuous
///   collision detection.
/// @relatedalso Body
inline void SetImpenetrable(Body& body) noexcept
{
    body.SetImpenetrable();
}

/// @brief Unsets the impenetrable status of this body.
/// @details Sets whether or not this body should be treated like a bullet for continuous
///   collision detection.
/// @relatedalso Body
inline void UnsetImpenetrable(Body& body) noexcept
{
    body.UnsetImpenetrable();
}

/// @brief Gets whether or not this body allowed to sleep
/// @relatedalso Body
inline bool IsSleepingAllowed(const Body& body) noexcept
{
    return body.IsSleepingAllowed();
}

/// You can disable sleeping on this body. If you disable sleeping, the
/// body will be woken.
/// @relatedalso Body
inline void SetSleepingAllowed(Body& body, bool value) noexcept
{
    body.SetSleepingAllowed(value);
}

/// @brief Gets the enabled/disabled state of the body.
/// @see SetEnabled.
/// @relatedalso Body
inline bool IsEnabled(const Body& body) noexcept
{
    return body.IsEnabled();
}

/// @brief Sets the enabled state.
/// @relatedalso Body
inline void SetEnabled(Body& body) noexcept
{
    body.SetEnabled();
}

/// @brief Unsets the enabled state.
/// @relatedalso Body
inline void UnsetEnabled(Body& body) noexcept
{
    body.UnsetEnabled();
}

/// @brief Sets the enabled state to the given value.
/// @relatedalso Body
inline void SetEnabled(Body& body, bool value) noexcept
{
    if (value)
        body.SetEnabled();
    else
        body.UnsetEnabled();
}

/// @brief Gets the awake/asleep state of this body.
/// @warning Being awake may or may not imply being speedable.
/// @return true if the body is awake.
/// @relatedalso Body
inline bool IsAwake(const Body& body) noexcept
{
    return body.IsAwake();
}

/// @brief Awakens this body.
/// @details Sets this body to awake and resets its under-active time if it's a "speedable"
///   body. This method has no effect otherwise.
/// @post If this body is a "speedable" body, then this body's <code>IsAwake</code> method
///   returns true.
/// @post If this body is a "speedable" body, then this body's <code>GetUnderActiveTime</code>
///   method returns zero.
/// @relatedalso Body
inline void SetAwake(Body& body) noexcept
{
    body.SetAwake();
}

/// @brief Sets this body to asleep if sleeping is allowed.
/// @details If this body is allowed to sleep, this: sets the sleep state of the body to
/// asleep, resets this body's under active time, and resets this body's velocity (linear
/// and angular).
/// @post This body's <code>IsAwake</code> method returns false.
/// @post This body's <code>GetUnderActiveTime</code> method returns zero.
/// @post This body's <code>GetVelocity</code> method returns zero linear and zero angular
///   speed.
/// @relatedalso Body
inline void UnsetAwake(Body& body) noexcept
{
    body.UnsetAwake();
}

/// @brief Does this body have fixed rotation?
/// @relatedalso Body
inline bool IsFixedRotation(const Body& body) noexcept
{
    return body.IsFixedRotation();
}

/// @brief Sets this body to have fixed rotation.
/// @note This causes the mass to be reset.
/// @relatedalso Body
inline void SetFixedRotation(Body& body, bool value)
{
    body.SetFixedRotation(value);
}

/// @brief Gets whether the mass data for this body is "dirty".
/// @relatedalso Body
inline bool IsMassDataDirty(const Body& body) noexcept
{
    return body.IsMassDataDirty();
}

/// @brief Gets the inverse total mass of the body.
/// @details This is the cached result of dividing 1 by the body's mass.
/// Often floating division is much slower than multiplication.
/// As such, it's likely faster to multiply values by this inverse value than to redivide
/// them all the time by the mass.
/// @return Value of zero or more representing the body's inverse mass (in 1/kg).
/// @see SetInvMass.
/// @relatedalso Body
inline InvMass GetInvMass(const Body& body) noexcept
{
    return body.GetInvMass();
}

/// @brief Gets the inverse rotational inertia of the body.
/// @details This is the cached result of dividing 1 by the body's rotational inertia.
/// Often floating division is much slower than multiplication.
/// As such, it's likely faster to multiply values by this inverse value than to redivide
/// them all the time by the rotational inertia.
/// @return Inverse rotational inertia (in 1/kg-m^2).
/// @relatedalso Body
inline InvRotInertia GetInvRotInertia(const Body& body) noexcept
{
    return body.GetInvRotInertia();
}

/// @brief Gets the linear damping of the body.
/// @relatedalso Body
inline Frequency GetLinearDamping(const Body& body) noexcept
{
    return body.GetLinearDamping();
}

/// @brief Sets the linear damping of the body.
/// @relatedalso Body
inline void SetLinearDamping(Body& body, NonNegative<Frequency> value) noexcept
{
    body.SetLinearDamping(value);
}

/// @brief Gets the angular damping of the body.
/// @relatedalso Body
inline Frequency GetAngularDamping(const Body& body) noexcept
{
    return body.GetAngularDamping();
}

/// @brief Sets the angular damping of the body.
/// @relatedalso Body
inline void SetAngularDamping(Body& body, NonNegative<Frequency> value) noexcept
{
    body.SetAngularDamping(value);
}

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

/// @brief Gets this body's linear acceleration.
/// @relatedalso Body
inline LinearAcceleration2 GetLinearAcceleration(const Body& body) noexcept
{
    return body.GetLinearAcceleration();
}

/// @brief Gets this body's angular acceleration.
/// @relatedalso Body
inline AngularAcceleration GetAngularAcceleration(const Body& body) noexcept
{
    return body.GetAngularAcceleration();
}

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

/// @brief Gets the "position 1" Position information for the given body.
/// @relatedalso Body
inline Position GetPosition1(const Body& body) noexcept
{
    return body.GetSweep().pos1;
}

/// @brief Gets the mass of the body.
/// @note This may be the total calculated mass or it may be the set mass of the body.
/// @return Value of zero or more representing the body's mass.
/// @see GetInvMass, SetInvMass
/// @relatedalso Body
inline Mass GetMass(const Body& body) noexcept
{
    const auto invMass = body.GetInvMass();
    return (invMass != InvMass{0})? Mass{Real{1} / invMass}: 0_kg;
}

/// @brief Sets the linear and rotational accelerations on this body.
/// @note This has no effect on non-accelerable bodies.
/// @note A non-zero acceleration will also awaken the body.
/// @param body Body to set the acceleration of.
/// @param linear Linear acceleration.
/// @param angular Angular acceleration.
/// @relatedalso Body
inline void SetAcceleration(Body& body, LinearAcceleration2 linear, AngularAcceleration angular) noexcept
{
    body.SetAcceleration(linear, angular);
}

/// @brief Sets the given linear acceleration of the given body.
/// @relatedalso Body
inline void SetAcceleration(Body& body, LinearAcceleration2 value) noexcept
{
    body.SetAcceleration(value, body.GetAngularAcceleration());
}

/// @brief Sets the given angular acceleration of the given body.
/// @relatedalso Body
inline void SetAcceleration(Body& body, AngularAcceleration value) noexcept
{
    body.SetAcceleration(body.GetLinearAcceleration(), value);
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

/// @brief Gets the velocity.
/// @relatedalso Body
inline Velocity GetVelocity(const Body& body) noexcept
{
    return body.GetVelocity();
}

/// @brief Sets the body's velocity (linear and angular velocity).
/// @note This method does nothing if this body is not speedable.
/// @note A non-zero velocity will awaken this body.
/// @see SetAwake, SetUnderActiveTime.
/// @relatedalso Body
inline void SetVelocity(Body& body, const Velocity& value) noexcept
{
    return body.SetVelocity(value);
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
/// @param value the new linear velocity of the center of mass.
/// @relatedalso Body
inline void SetVelocity(Body& body, LinearVelocity2 value) noexcept
{
    body.SetVelocity(Velocity{value, GetAngularVelocity(body)});
}

/// @brief Sets the angular velocity.
/// @param body Body to set the angular velocity of.
/// @param value the new angular velocity.
/// @relatedalso Body
inline void SetVelocity(Body& body, AngularVelocity value) noexcept
{
    body.SetVelocity(Velocity{GetLinearVelocity(body), value});
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
/// @see GetAngle.
/// @relatedalso Body
inline Length2 GetLocation(const Body& body) noexcept
{
    return GetLocation(body.GetTransformation());
}

/// @brief Gets the body's sweep.
/// @relatedalso Body
inline const Sweep& GetSweep(const Body& body) noexcept
{
    return body.GetSweep();
}

/// @brief Sets the sweep value of the given body.
/// @relatedalso Body
inline void SetSweep(Body& body, const Sweep& value) noexcept
{
    body.SetSweep(value);
}

/// @brief Gets the body's angle.
/// @return Body's angle relative to its World.
/// @relatedalso Body
inline Angle GetAngle(const Body& body) noexcept
{
    return body.GetSweep().pos1.angular;
}

/// @brief Get the world position of the center of mass.
inline Length2 GetWorldCenter(const Body& body) noexcept
{
    return body.GetWorldCenter();
}

/// @brief Gets the local position of the center of mass.
inline Length2 GetLocalCenter(const Body& body) noexcept
{
    return body.GetLocalCenter();
}

/// @brief Gets the body's transformation.
/// @relatedalso Body
inline Transformation GetTransformation(const Body& body) noexcept
{
    return body.GetTransformation();
}

/// Sets the body's transformation.
/// @note This sets what <code>GetLocation</code> returns.
/// @see GetTransformation.
/// @relatedalso Body
inline void SetTransformation(Body& body, Transformation value) noexcept
{
    body.SetTransformation(value);
}

/// @brief Gets the body's position.
/// @relatedalso Body
inline Position GetPosition(const Body& body) noexcept
{
    return Position{body.GetLocation(), body.GetAngle()};
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_BODY_HPP

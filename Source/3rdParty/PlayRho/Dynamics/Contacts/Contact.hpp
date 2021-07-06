/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_DYNAMICS_CONTACTS_CONTACT_HPP
#define PLAYRHO_DYNAMICS_CONTACTS_CONTACT_HPP

#include "PlayRho/Common/Math.hpp"

#include "PlayRho/Collision/Shapes/ShapeID.hpp"

#include "PlayRho/Dynamics/BodyID.hpp"

namespace playrho {

/// @brief Mixes friction.
///
/// @details Friction mixing formula. The idea is to allow either value to drive the
///   resulting friction to zero. For example, anything slides on ice.
///
/// @warning Behavior is undefined if either friction values is less than zero.
///
/// @param friction1 A zero or greater value.
/// @param friction2 A zero or greater value.
///
inline Real MixFriction(Real friction1, Real friction2)
{
    assert(friction1 >= 0 && friction2 >= 0);
    return sqrt(friction1 * friction2);
}

/// @brief Mixes restitution.
///
/// @details Restitution mixing law. The idea is allow for anything to bounce off an inelastic
///   surface. For example, a super ball bounces on anything.
///
inline Real MixRestitution(Real restitution1, Real restitution2) noexcept
{
    return (restitution1 > restitution2) ? restitution1 : restitution2;
}

struct ToiConf;

namespace d2 {

/// @brief A potential contact between the children of two body associated shapes.
///
/// @details The class manages contact between two shapes. A contact exists for each overlapping
///   AABB in the broad-phase (except if filtered). Therefore a contact object may exist
///   that has no actual contact points.
///
/// @ingroup PhysicalEntities
/// @ingroup ConstraintsGroup
///
class Contact
{
public:
    /// @brief Substep type.
    using substep_type = TimestepIters;

    /// @brief Default constructor.
    constexpr Contact() noexcept = default;

    /// @brief Initializing constructor.
    ///
    /// @param bA Identifier of body-A.
    /// @param sA Non-invalid identifier to shape A.
    /// @param iA Child index A.
    /// @param bB Identifier of body-B.
    /// @param sB Non-invalid identifier to shape B.
    /// @param iB Child index B.
    ///
    /// @note This need never be called directly by a user.
    /// @warning Behavior is undefined if <code>fA</code> is null.
    /// @warning Behavior is undefined if <code>fB</code> is null.
    /// @warning Behavior is undefined if <code>fA == fB</code>.
    /// @warning Behavior is undefined if both shape's have the same body.
    ///
    constexpr Contact(BodyID bA, ShapeID sA, ChildCounter iA, // forced-linebreak
                      BodyID bB, ShapeID sB, ChildCounter iB) noexcept;

    /// @brief Is this contact touching?
    /// @details
    /// Touching is defined as either:
    ///   1. This contact's manifold has more than 0 contact points, or
    ///   2. This contact has sensors and the two shapes of this contact are found to be
    ///      overlapping.
    /// @return true if this contact is said to be touching, false otherwise.
    constexpr bool IsTouching() const noexcept;

    /// @brief Sets the touching flag state.
    /// @note This should only be called if either:
    ///   1. The contact's manifold has more than 0 contact points, or
    ///   2. The contact has sensors and the two shapes of this contact are found to be overlapping.
    /// @see IsTouching().
    constexpr void SetTouching() noexcept;

    /// @brief Unsets the touching flag state.
    constexpr void UnsetTouching() noexcept;

    /// @brief Enables or disables this contact.
    /// @note This can be used inside the pre-solve contact listener.
    ///   The contact is only disabled for the current time step (or sub-step in continuous
    ///   collisions).
    [[deprecated]] constexpr void SetEnabled(bool flag) noexcept;

    /// @brief Has this contact been disabled?
    constexpr bool IsEnabled() const noexcept;

    /// @brief Enables this contact.
    constexpr void SetEnabled() noexcept;

    /// @brief Disables this contact.
    constexpr void UnsetEnabled() noexcept;

    /// @brief Gets the body-A identifier.
    constexpr BodyID GetBodyA() const noexcept;

    /// @brief Gets shape A in this contact.
    constexpr ShapeID GetShapeA() const noexcept;

    /// @brief Get the child primitive index for shape A.
    constexpr ChildCounter GetChildIndexA() const noexcept;

    /// @brief Gets the body-B identifier.
    constexpr BodyID GetBodyB() const noexcept;

    /// @brief Gets shape B in this contact.
    constexpr ShapeID GetShapeB() const noexcept;

    /// @brief Get the child primitive index for shape B.
    constexpr ChildCounter GetChildIndexB() const noexcept;

    /// @brief Sets the friction value for this contact.
    /// @details Override the default friction mixture.
    /// @note You can call this in "pre-solve" listeners.
    /// @note This value persists until set or reset.
    /// @warning Behavior is undefined if given a negative friction value.
    /// @param friction Co-efficient of friction value of zero or greater.
    /// @see GetFriction.
    constexpr void SetFriction(Real friction) noexcept;

    /// @brief Gets the coefficient of friction.
    /// @details Gets the combined friction of the two shapes associated with this contact.
    /// @return Value of 0 or higher.
    /// @see SetFriction.
    constexpr Real GetFriction() const noexcept;

    /// @brief Sets the restitution.
    /// @details This override the default restitution mixture.
    /// @note You can call this in "pre-solve" listeners.
    /// @note The value persists until you set or reset.
    constexpr void SetRestitution(Real restitution) noexcept;

    /// @brief Gets the restitution.
    constexpr Real GetRestitution() const noexcept;

    /// @brief Sets the desired tangent speed for a conveyor belt behavior.
    constexpr void SetTangentSpeed(LinearVelocity speed) noexcept;

    /// @brief Gets the desired tangent speed.
    constexpr LinearVelocity GetTangentSpeed() const noexcept;

    /// @brief Gets the time of impact count.
    /// @see SetToiCount.
    constexpr substep_type GetToiCount() const noexcept;

    /// @brief Sets the TOI count to the given value.
    /// @see GetToiCount.
    constexpr void SetToiCount(substep_type value) noexcept;

    /// @brief Increments the TOI count.
    constexpr void IncrementToiCount() noexcept;

    /// @brief Gets whether a TOI is set.
    /// @return true if this object has a TOI set for it, false otherwise.
    constexpr bool HasValidToi() const noexcept;

    /// @brief Gets the time of impact (TOI) as a fraction.
    /// @note This is only valid if a TOI has been set.
    /// @see void SetToi(Real toi).
    /// @return Time of impact fraction in the range of 0 to 1 if set (where 1
    ///   means no actual impact in current time slot), otherwise undefined.
    constexpr Real GetToi() const;

    /// @brief Sets the time of impact (TOI).
    /// @details After returning, this object will have a TOI that is set as indicated by
    /// <code>HasValidToi()</code>.
    /// @note Behavior is undefined if the value assigned is less than 0 or greater than 1.
    /// @see Real GetToi() const.
    /// @see HasValidToi.
    /// @param toi Time of impact as a fraction between 0 and 1 where 1 indicates no actual impact
    /// in the current time slot.
    constexpr void SetToi(Real toi) noexcept;

    /// @brief Unsets the TOI.
    constexpr void UnsetToi() noexcept;

    /// @brief Whether or not the contact needs filtering.
    constexpr bool NeedsFiltering() const noexcept;

    /// @brief Flags the contact for filtering.
    constexpr void FlagForFiltering() noexcept;

    /// @brief Unflags this contact for filtering.
    constexpr void UnflagForFiltering() noexcept;

    /// @brief Whether or not the contact needs updating.
    constexpr bool NeedsUpdating() const noexcept;

    /// @brief Flags the contact for updating.
    constexpr void FlagForUpdating() noexcept;

    /// @brief Unflags this contact for updating.
    constexpr void UnflagForUpdating() noexcept;

    /// @brief Whether or not this contact is a "sensor".
    /// @note This should be true whenever shape A or shape B is a sensor.
    constexpr bool IsSensor() const noexcept;

    /// @brief Sets the sensor state of this contact.
    /// @attention Call this if shape A or shape B is a sensor.
    constexpr void SetSensor() noexcept;

    /// @brief Unsets the sensor state of this contact.
    constexpr void UnsetIsSensor() noexcept;

    /// @brief Whether or not this contact is "impenetrable".
    /// @note This should be true whenever body A or body B are impenetrable.
    constexpr bool IsImpenetrable() const noexcept;

    /// @brief Sets the impenetrability of this contact.
    /// @attention Call this if body A or body B are impenetrable.
    constexpr void SetImpenetrable() noexcept;

    /// @brief Unsets the impenetrability of this contact.
    constexpr void UnsetImpenetrable() noexcept;

    /// @brief Whether or not this contact is "active".
    /// @note This should be true whenever body A or body B are "awake".
    constexpr bool IsActive() const noexcept;

    /// @brief Sets the active state of this contact.
    /// @attention Call this if body A or body B are "awake".
    constexpr void SetIsActive() noexcept;

    /// @brief Unsets the active state of this contact.
    /// @attention Call this if neither body A nor body B are "awake".
    constexpr void UnsetIsActive() noexcept;

    /// Flags type data type.
    using FlagsType = std::uint8_t;

    /// @brief Flags stored in m_flags
    enum : FlagsType {
        // Set when the shapes are touching.
        e_touchingFlag = 0x01,

        // This contact can be disabled (by user)
        e_enabledFlag = 0x02,

        // This contact needs filtering because a shape filter was changed.
        e_filterFlag = 0x04,

        // This contact has a valid TOI in m_toi
        e_toiFlag = 0x08,

        // This contacts needs its touching state updated.
        e_dirtyFlag = 0x10,

        /// Indicates whether the contact is to be treated as a sensor or not.
        e_sensorFlag = 0x20,

        /// Indicates whether the contact is to be treated as active or not.
        e_activeFlag = 0x40,

        /// Indicates whether the contact is to be treated as between impenetrable bodies.
        e_impenetrableFlag = 0x80,
    };

private:
    /// Identifier of body A.
    /// @note Field is 2-bytes.
    /// @warning Should only be body associated with shape A.
    BodyID m_bodyA = InvalidBodyID;

    /// Identifier of body B.
    /// @note Field is 2-bytes.
    /// @warning Should only be body associated with shape B.
    BodyID m_bodyB = InvalidBodyID;

    /// Identifier of shape A.
    /// @note Field is 2-bytes.
    ShapeID m_shapeA = InvalidShapeID;

    /// Identifier of shape B.
    /// @note Field is 2-bytes.
    ShapeID m_shapeB = InvalidShapeID;

    ChildCounter m_indexA = 0; ///< Index A. 4-bytes.

    ChildCounter m_indexB = 0; ///< Index B. 4-bytes.

    // initialized on construction (construction-time depedent)

    /// Mix of frictions of associated shapes.
    /// @note Field is 4-bytes (with 4-byte Real).
    /// @see MixFriction.
    Real m_friction = 0;

    /// Mix of restitutions of associated shapes.
    /// @note Field is 4-bytes (with 4-byte Real).
    /// @see MixRestitution.
    Real m_restitution = 0;

    /// Tangent speed.
    /// @note Field is 4-bytes (with 4-byte Real).
    LinearVelocity m_tangentSpeed = 0;

    /// Time of impact.
    /// @note This is a unit interval of time (a value between 0 and 1).
    /// @note Only valid if <code>m_flags & e_toiFlag</code>.
    Real m_toi = 0;

    // 32-bytes to here.

    /// Count of TOI calculations contact has gone through since last reset.
    substep_type m_toiCount = 0;

    FlagsType m_flags = 0; ///< Flags.
};

constexpr Contact::Contact(BodyID bA, ShapeID sA, ChildCounter iA, // explicit line break
                           BodyID bB, ShapeID sB, ChildCounter iB) noexcept
    : m_bodyA{bA},
      m_bodyB{bB},
      m_shapeA{sA},
      m_shapeB{sB},
      m_indexA{iA},
      m_indexB{iB},
      m_flags{e_enabledFlag | e_dirtyFlag}
{
}

constexpr void Contact::SetEnabled(bool flag) noexcept
{
    if (flag) {
        SetEnabled();
    }
    else {
        UnsetEnabled();
    }
}

constexpr void Contact::SetEnabled() noexcept
{
    m_flags |= e_enabledFlag;
}

constexpr void Contact::UnsetEnabled() noexcept
{
    m_flags &= ~e_enabledFlag;
}

constexpr bool Contact::IsEnabled() const noexcept
{
    return (m_flags & e_enabledFlag) != 0;
}

constexpr bool Contact::IsTouching() const noexcept
{
    // XXX: What to do if needs-updating?
    // assert(!NeedsUpdating());
    return (m_flags & e_touchingFlag) != 0;
}

constexpr void Contact::SetTouching() noexcept
{
    m_flags |= e_touchingFlag;
}

constexpr void Contact::UnsetTouching() noexcept
{
    m_flags &= ~e_touchingFlag;
}

constexpr BodyID Contact::GetBodyA() const noexcept
{
    return m_bodyA;
}

constexpr BodyID Contact::GetBodyB() const noexcept
{
    return m_bodyB;
}

constexpr ShapeID Contact::GetShapeA() const noexcept
{
    return m_shapeA;
}

constexpr ShapeID Contact::GetShapeB() const noexcept
{
    return m_shapeB;
}

constexpr void Contact::FlagForFiltering() noexcept
{
    m_flags |= e_filterFlag;
}

constexpr void Contact::UnflagForFiltering() noexcept
{
    m_flags &= ~e_filterFlag;
}

constexpr bool Contact::NeedsFiltering() const noexcept
{
    return (m_flags & e_filterFlag) != 0;
}

constexpr void Contact::FlagForUpdating() noexcept
{
    m_flags |= e_dirtyFlag;
}

constexpr void Contact::UnflagForUpdating() noexcept
{
    m_flags &= ~e_dirtyFlag;
}

constexpr bool Contact::NeedsUpdating() const noexcept
{
    return (m_flags & e_dirtyFlag) != 0;
}

constexpr void Contact::SetFriction(Real friction) noexcept
{
    assert(friction >= 0);
    m_friction = friction;
}

constexpr Real Contact::GetFriction() const noexcept
{
    return m_friction;
}

constexpr void Contact::SetRestitution(Real restitution) noexcept
{
    m_restitution = restitution;
}

constexpr Real Contact::GetRestitution() const noexcept
{
    return m_restitution;
}

constexpr void Contact::SetTangentSpeed(LinearVelocity speed) noexcept
{
    m_tangentSpeed = speed;
}

constexpr LinearVelocity Contact::GetTangentSpeed() const noexcept
{
    return m_tangentSpeed;
}

constexpr bool Contact::HasValidToi() const noexcept
{
    return (m_flags & Contact::e_toiFlag) != 0;
}

constexpr Real Contact::GetToi() const
{
    assert(HasValidToi());
    return m_toi;
}

constexpr void Contact::SetToi(Real toi) noexcept
{
    assert(toi >= 0 && toi <= 1);
    m_toi = toi;
    m_flags |= Contact::e_toiFlag;
}

constexpr void Contact::UnsetToi() noexcept
{
    m_flags &= ~Contact::e_toiFlag;
}

constexpr void Contact::SetToiCount(substep_type value) noexcept
{
    m_toiCount = value;
}

constexpr Contact::substep_type Contact::GetToiCount() const noexcept
{
    return m_toiCount;
}

constexpr ChildCounter Contact::GetChildIndexA() const noexcept
{
    return m_indexA;
}

constexpr ChildCounter Contact::GetChildIndexB() const noexcept
{
    return m_indexB;
}

constexpr bool Contact::IsSensor() const noexcept
{
    return (m_flags & e_sensorFlag) != 0u;
}

constexpr void Contact::SetSensor() noexcept
{
    m_flags |= e_sensorFlag;
}

constexpr void Contact::UnsetIsSensor() noexcept
{
    m_flags &= ~e_sensorFlag;
}

constexpr bool Contact::IsImpenetrable() const noexcept
{
    return (m_flags & e_impenetrableFlag) != 0u;
}

constexpr void Contact::SetImpenetrable() noexcept
{
    m_flags |= e_impenetrableFlag;
}

constexpr void Contact::UnsetImpenetrable() noexcept
{
    m_flags &= ~e_impenetrableFlag;
}

constexpr bool Contact::IsActive() const noexcept
{
    return (m_flags & e_activeFlag) != 0u;
}

constexpr void Contact::SetIsActive() noexcept
{
    m_flags |= e_activeFlag;
}

constexpr void Contact::UnsetIsActive() noexcept
{
    m_flags &= ~e_activeFlag;
}

constexpr void Contact::IncrementToiCount() noexcept
{
    ++m_toiCount;
}

// Free functions...

/// @brief Operator equals.
/// @relatedalso Contact
constexpr bool operator==(const Contact& lhs, const Contact& rhs) noexcept
{
    return lhs.GetBodyA() == rhs.GetBodyA() && //
           lhs.GetBodyB() == rhs.GetBodyB() && //
           lhs.GetShapeA() == rhs.GetShapeA() && //
           lhs.GetShapeB() == rhs.GetShapeB() && //
           lhs.GetChildIndexA() == rhs.GetChildIndexA() && //
           lhs.GetChildIndexB() == rhs.GetChildIndexB() && //
           lhs.GetFriction() == rhs.GetFriction() && //
           lhs.GetRestitution() == rhs.GetRestitution() && //
           lhs.GetTangentSpeed() == rhs.GetTangentSpeed() && //
           lhs.GetToiCount() == rhs.GetToiCount() && //
           lhs.IsTouching() == rhs.IsTouching() && //
           lhs.IsEnabled() == rhs.IsEnabled() && //
           lhs.NeedsFiltering() == rhs.NeedsFiltering() && //
           lhs.HasValidToi() == rhs.HasValidToi() && //
           lhs.NeedsUpdating() == rhs.NeedsUpdating() && //
           lhs.IsSensor() == rhs.IsSensor() && //
           lhs.IsActive() == rhs.IsActive() && //
           lhs.IsImpenetrable() == rhs.IsImpenetrable() && //
           (!lhs.HasValidToi() || !rhs.HasValidToi() || lhs.GetToi() == rhs.GetToi());
}

/// @brief Operator not-equals.
/// @relatedalso Contact
constexpr bool operator!=(const Contact& lhs, const Contact& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the body A ID of the given contact.
/// @relatedalso Contact
constexpr BodyID GetBodyA(const Contact& contact) noexcept
{
    return contact.GetBodyA();
}

/// @brief Gets the body B ID of the given contact.
/// @relatedalso Contact
constexpr BodyID GetBodyB(const Contact& contact) noexcept
{
    return contact.GetBodyB();
}

/// @brief Gets the shape A associated with the given contact.
/// @relatedalso Contact
constexpr ShapeID GetShapeA(const Contact& contact) noexcept
{
    return contact.GetShapeA();
}

/// @brief Gets the shape B associated with the given contact.
/// @relatedalso Contact
constexpr ShapeID GetShapeB(const Contact& contact) noexcept
{
    return contact.GetShapeB();
}

/// @brief Gets the child index A of the given contact.
/// @relatedalso Contact
constexpr ChildCounter GetChildIndexA(const Contact& contact) noexcept
{
    return contact.GetChildIndexA();
}

/// @brief Gets the child index B of the given contact.
/// @relatedalso Contact
constexpr ChildCounter GetChildIndexB(const Contact& contact) noexcept
{
    return contact.GetChildIndexB();
}

/// @brief Whether the given contact is "impenetrable".
/// @note This should be true whenever body A or body B are impenetrable.
/// @relatedalso Contact
constexpr bool IsImpenetrable(const Contact& contact) noexcept
{
    return contact.IsImpenetrable();
}

/// @brief Sets the impenetrability of the given contact.
/// @attention Call this if body A or body B are impenetrable.
/// @relatedalso Contact
constexpr void SetImpenetrable(Contact& contact) noexcept
{
    contact.SetImpenetrable();
}

/// @brief Unsets the impenetrability of the given contact.
/// @attention Call this if body A or body B are no longer impenetrable.
/// @relatedalso Contact
constexpr void UnsetImpenetrable(Contact& contact) noexcept
{
    contact.UnsetImpenetrable();
}

/// @brief Determines whether the given contact is "active".
/// @relatedalso Contact
constexpr bool IsActive(const Contact& contact) noexcept
{
    return contact.IsActive();
}

/// @brief Sets the active state of the given contact.
/// @attention Call this if body A or body B are "awake".
/// @relatedalso Contact
constexpr void SetIsActive(Contact& contact) noexcept
{
    contact.SetIsActive();
}

/// @brief Unsets the active state of this contact.
/// @attention Call this if neither body A nor body B are "awake".
/// @relatedalso Contact
constexpr void UnsetIsActive(Contact& contact) noexcept
{
    contact.UnsetIsActive();
}

/// @brief Gets whether the given contact is enabled or not.
/// @relatedalso Contact
constexpr bool IsEnabled(const Contact& contact) noexcept
{
    return contact.IsEnabled();
}

/// @brief Enables the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
constexpr void SetEnabled(Contact& contact) noexcept
{
    contact.SetEnabled();
}

/// @brief Disables the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
constexpr void UnsetEnabled(Contact& contact) noexcept
{
    contact.UnsetEnabled();
}

/// @brief Gets whether the given contact is touching or not.
/// @relatedalso Contact
constexpr bool IsTouching(const Contact& contact) noexcept
{
    return contact.IsTouching();
}

/// @brief Gets whether the given contact is for sensors or not.
/// @relatedalso Contact
constexpr bool IsSensor(const Contact& contact) noexcept
{
    return contact.IsSensor();
}

/// @brief Sets the sensor state of the given contact.
/// @attention Call this if shape A or shape B is a sensor.
/// @relatedalso Contact
constexpr void SetSensor(Contact& contact) noexcept
{
    contact.SetSensor();
}

/// @brief Unsets the sensor state of the given contact.
/// @relatedalso Contact
constexpr void UnsetIsSensor(Contact& contact) noexcept
{
    contact.UnsetIsSensor();
}

/// @brief Gets the time of impact count.
/// @see SetToiCount.
/// @relatedalso Contact
constexpr auto GetToiCount(const Contact& contact) noexcept
{
    return contact.GetToiCount();
}

/// @brief Sets the TOI count to the given value.
/// @see GetToiCount.
/// @relatedalso Contact
constexpr void SetToiCount(Contact& contact, Contact::substep_type value) noexcept
{
    contact.SetToiCount(value);
}

/// @brief Whether or not the contact needs filtering.
/// @relatedalso Contact
constexpr auto NeedsFiltering(const Contact& contact) noexcept
{
    return contact.NeedsFiltering();
}

/// @brief Flags the contact for filtering.
/// @relatedalso Contact
constexpr void FlagForFiltering(Contact& contact) noexcept
{
    contact.FlagForFiltering();
}

/// @brief Unflags this contact for filtering.
/// @relatedalso Contact
constexpr void UnflagForFiltering(Contact& contact) noexcept
{
    contact.UnflagForFiltering();
}

/// @brief Whether or not the contact needs updating.
/// @relatedalso Contact
constexpr auto NeedsUpdating(const Contact& contact) noexcept
{
    return contact.NeedsUpdating();
}

/// @brief Flags the contact for updating.
/// @relatedalso Contact
constexpr void FlagForUpdating(Contact& contact) noexcept
{
    contact.FlagForUpdating();
}

/// @brief Unflags this contact for updating.
/// @relatedalso Contact
constexpr void UnflagForUpdating(Contact& contact) noexcept
{
    contact.UnflagForUpdating();
}

/// @brief Gets whether a TOI is set.
/// @see GetToi.
/// @relatedalso Contact
constexpr auto HasValidToi(const Contact& contact) noexcept
{
    return contact.HasValidToi();
}

/// @brief Gets the time of impact (TOI) as a fraction.
/// @note This is only valid if a TOI has been set.
/// @see void SetToi(Real toi).
/// @return Time of impact fraction in the range of 0 to 1 if set (where 1
///   means no actual impact in current time slot), otherwise undefined.
/// @see HasValidToi
/// @relatedalso Contact
constexpr Real GetToi(const Contact& contact) noexcept
{
    return contact.GetToi();
}

/// @brief Sets the time of impact (TOI).
/// @note Behavior is undefined if the value assigned is less than 0 or greater than 1.
/// @see Real GetToi() const.
/// @see HasValidToi.
/// @param contact The contact to update.
/// @param toi Time of impact as a fraction between 0 and 1 where 1 indicates no actual impact
///   in the current time slot.
/// @relatedalso Contact
constexpr void SetToi(Contact& contact, Real toi) noexcept
{
    contact.SetToi(toi);
}

/// @brief Unsets the TOI.
/// @relatedalso Contact
constexpr void UnsetToi(Contact& contact) noexcept
{
    contact.UnsetToi();
}

/// @brief Gets the coefficient of friction.
/// @see SetFriction.
/// @relatedalso Contact
constexpr auto GetFriction(const Contact& contact) noexcept
{
    return contact.GetFriction();
}

/// @brief Sets the friction value for the identified contact.
/// @details Overrides the default friction mixture.
/// @note This value persists until set or reset.
/// @warning Behavior is undefined if given a negative friction value.
/// @param contact The contact whose friction should be set.
/// @param value Co-efficient of friction value of zero or greater.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see GetFriction.
/// @relatedalso Contact
constexpr void SetFriction(Contact& contact, Real value) noexcept
{
    contact.SetFriction(value);
}

/// @brief Gets the coefficient of restitution.
/// @see SetRestitution.
/// @relatedalso Contact
constexpr auto GetRestitution(const Contact& contact) noexcept
{
    return contact.GetRestitution();
}

/// @brief Sets the restitution value for the identified contact.
/// @details This override the default restitution mixture.
/// @note You can call this in "pre-solve" listeners.
/// @note The value persists until you set or reset.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see GetRestitution.
/// @relatedalso Contact
constexpr void SetRestitution(Contact& contact, Real value)
{
    contact.SetRestitution(value);
}

/// @brief Gets the desired tangent speed.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see SetTangentSpeed.
/// @relatedalso Contact
constexpr auto GetTangentSpeed(const Contact& contact) noexcept
{
    return contact.GetTangentSpeed();
}

/// @brief Sets the desired tangent speed for a conveyor belt behavior.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see GetTangentSpeed.
/// @relatedalso Contact
constexpr void SetTangentSpeed(Contact& contact, LinearVelocity value) noexcept
{
    contact.SetTangentSpeed(value);
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTS_CONTACT_HPP

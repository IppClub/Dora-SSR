/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_CONTACT_HPP
#define PLAYRHO_CONTACT_HPP

/// @file
/// @brief Definition of the <code>Contact</code> class and closely related code.

#include <cassert> // for assert
#include <cstdint> // for std::uint8_t
#ifndef NDEBUG
#include <limits> // for std::numeric_limits
#endif
#include <optional>

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/Contactable.hpp"
#include "playrho/Math.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp" // for ChildCounter
#include "playrho/ShapeID.hpp"
#include "playrho/UnitInterval.hpp"
#include "playrho/Units.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Mixes friction.
/// @details Friction mixing formula. The idea is to allow either value to drive
///   the resulting friction to zero. For example, anything slides on ice.
/// @param friction1 A zero or greater value.
/// @param friction2 A zero or greater value.
/// @return Mixed friction result.
inline auto MixFriction(NonNegativeFF<Real> friction1, NonNegativeFF<Real> friction2)
{
    return NonNegativeFF<Real>(sqrt(friction1 * friction2));
}

/// @brief Mixes restitution.
/// @details Restitution mixing law. The idea is allow for anything to bounce off
///   an inelastic surface. For example, a super ball bounces on anything.
/// @return Mixed restitution result.
inline auto MixRestitution(Real restitution1, Real restitution2) noexcept
{
    return (restitution1 > restitution2) ? restitution1 : restitution2;
}

struct ToiConf;

/// @brief A potential contact between the children of two body associated shapes.
/// @details The class manages contact between two shapes. A contact exists for
///   each overlapping AABB in the broad-phase (except if filtered). Therefore a
///   contact object may exist that has no actual contact points.
/// @ingroup PhysicalEntities
/// @ingroup ConstraintsGroup
class Contact
{
public:
    /// @brief Default contactable value.
    static constexpr auto DefaultContactable = Contactable{InvalidBodyID, InvalidShapeID, 0};

    /// @brief Substep type.
    using substep_type = TimestepIters;

    /// @brief Default constructor.
    constexpr Contact() noexcept = default;

    /// @brief Initializing constructor.
    /// @param a The "a" contactable value.
    /// @param b The "b" contactable value.
    /// @post If either @p a or @p b is not the value of @c DefaultContactable then:
    ///   <code>IsEnabled()</code> and <code>NeedsUpdating()</code> return true,
    ///   else they return false.
    constexpr Contact(const Contactable& a, const Contactable& b) noexcept;

    /// @brief Is this contact touching?
    /// @details
    /// Touching is defined as either:
    ///   1. This contact's manifold has more than 0 contact points, or
    ///   2. This contact has sensors and the two shapes of this contact are found
    ///      to be overlapping.
    /// @return true if this contact is said to be touching, false otherwise.
    constexpr bool IsTouching() const noexcept;

    /// @brief Sets the touching flag state.
    /// @note This should only be called if either:
    ///   1. The contact's manifold has more than 0 contact points, or
    ///   2. The contact has sensors and the two shapes of this contact are found
    ///      to be overlapping.
    /// @post <code>IsTouching()</code> returns true.
    /// @see IsTouching().
    constexpr void SetTouching() noexcept;

    /// @brief Unsets the touching flag state.
    /// @post <code>IsTouching()</code> returns false.
    /// @see IsTouching().
    constexpr void UnsetTouching() noexcept;

    /// @brief Has this contact been disabled?
    constexpr bool IsEnabled() const noexcept;

    /// @brief Enables this contact.
    /// @post <code>IsEnabled() </code> returns true.
    /// @see IsEnabled.
    constexpr void SetEnabled() noexcept;

    /// @brief Disables this contact.
    /// @post <code>IsEnabled() </code> returns false.
    /// @see IsEnabled.
    constexpr void UnsetEnabled() noexcept;

    /// @brief Gets contactable A.
    constexpr const Contactable& GetContactableA() const noexcept;

    /// @brief Gets contactable B.
    constexpr const Contactable& GetContactableB() const noexcept;

    /// @brief Sets the friction value for this contact.
    /// @details Override the default friction mixture.
    /// @note You can call this in "pre-solve" listeners.
    /// @note This value persists until set or reset.
    /// @param friction Co-efficient of friction value of zero or greater.
    /// @post <code>GetFriction()</code> returns the value set.
    /// @see GetFriction.
    constexpr void SetFriction(NonNegative<Real> friction) noexcept;

    /// @brief Gets the coefficient of friction.
    /// @details Gets combined friction of two shapes associated with this.
    /// @see SetFriction.
    constexpr NonNegativeFF<Real> GetFriction() const noexcept;

    /// @brief Sets the restitution.
    /// @details This override the default restitution mixture.
    /// @note You can call this in "pre-solve" listeners.
    /// @note The value persists until you set or reset.
    /// @post <code>GetRestitution()</code> returns the value set.
    /// @see GetRestitution.
    constexpr void SetRestitution(Real restitution) noexcept;

    /// @brief Gets the restitution.
    constexpr Real GetRestitution() const noexcept;

    /// @brief Sets the desired tangent speed for a conveyor belt behavior.
    /// @post <code>GetTangentSpeed()</code> returns the value set.
    /// @see GetTangentSpeed.
    constexpr void SetTangentSpeed(LinearVelocity speed) noexcept;

    /// @brief Gets the desired tangent speed.
    constexpr LinearVelocity GetTangentSpeed() const noexcept;

    /// @brief Gets the time of impact count.
    /// @note This is a non-essential part - it doesn't participate in equality.
    /// @see SetToiCount.
    constexpr substep_type GetToiCount() const noexcept;

    /// @brief Sets the TOI count to the given value.
    /// @note This is a non-essential part. So changing this doesn't effect equality!
    /// @post <code>GetToiCount()</code> returns the value set.
    /// @see GetToiCount.
    constexpr void SetToiCount(substep_type value) noexcept;

    /// @brief Increments the TOI count.
    /// @pre <code>GetToiCount()</code> is less than
    ///   <code>numeric_limits<substep_type>::max()</code>.
    /// @post <code>GetToiCount()</code> returns one more than before.
    /// @see GetToiCount, SetToiCount.
    constexpr void IncrementToiCount() noexcept;

    /// @brief Gets whether a TOI is set.
    /// @note This is a non-essential part - it doesn't participate in equality.
    /// @return true if this object has a TOI set for it, false otherwise.
    constexpr bool HasValidToi() const noexcept;

    /// @brief Gets the time of impact (TOI) as a fraction.
    /// @note This is a non-essential part - it doesn't participate in equality.
    /// @return Time of impact fraction in the range of 0 to 1 if set (where 1
    ///   means no actual impact in current time slot), otherwise empty.
    /// @see SetToi(const std::optional<UnitIntervalFF<Real>>&).
    constexpr std::optional<UnitIntervalFF<Real>> GetToi() const noexcept;

    /// @brief Sets the time of impact (TOI).
    /// @note This is a non-essential part. So changing this doesn't effect equality!
    /// @param toi Time of impact as a fraction between 0 and 1 where 1 indicates
    ///   no actual impact in the current time slot, or empty.
    /// @post <code>GetToi()</code> returns the value set and
    ///   <code>HasValidToi()</code> returns <code>toi.has_value()</code>.
    /// @see Real GetToi() const, HasValidToi.
    constexpr void SetToi(const std::optional<UnitIntervalFF<Real>>& toi) noexcept;

    /// @brief Whether or not the contact needs filtering.
    constexpr bool NeedsFiltering() const noexcept;

    /// @brief Flags the contact for filtering.
    /// @post <code>NeedsFiltering()</code> returns true.
    /// @see NeedsFiltering.
    constexpr void FlagForFiltering() noexcept;

    /// @brief Unflags this contact for filtering.
    /// @post <code>NeedsFiltering()</code> returns false.
    /// @see NeedsFiltering.
    constexpr void UnflagForFiltering() noexcept;

    /// @brief Whether or not the contact needs updating.
    constexpr bool NeedsUpdating() const noexcept;

    /// @brief Flags the contact for updating.
    /// @post <code>NeedsUpdating()</code> returns true.
    /// @see NeedsUpdating.
    constexpr void FlagForUpdating() noexcept;

    /// @brief Unflags this contact for updating.
    /// @post <code>NeedsUpdating()</code> returns false.
    /// @see NeedsUpdating.
    constexpr void UnflagForUpdating() noexcept;

    /// @brief Whether or not this contact is a "sensor".
    /// @note This should be true whenever shape A or shape B is a sensor.
    constexpr bool IsSensor() const noexcept;

    /// @brief Sets the sensor state of this contact.
    /// @attention Call this if shape A or shape B is a sensor.
    /// @post <code>IsSensor()</code> returns true.
    /// @see IsSensor().
    constexpr void SetSensor() noexcept;

    /// @brief Unsets the sensor state of this contact.
    /// @post <code>IsSensor()</code> returns false.
    /// @see IsSensor().
    constexpr void UnsetSensor() noexcept;

    /// @brief Whether or not this contact is "impenetrable".
    /// @note This should be true whenever body A or body B are impenetrable.
    constexpr bool IsImpenetrable() const noexcept;

    /// @brief Sets the impenetrability of this contact.
    /// @attention Call this if body A or body B are impenetrable.
    /// @post <code>IsImpenetrable()</code> returns true.
    /// @see IsImpenetrable().
    constexpr void SetImpenetrable() noexcept;

    /// @brief Unsets the impenetrability of this contact.
    /// @post <code>IsImpenetrable()</code> returns false.
    /// @see IsImpenetrable().
    constexpr void UnsetImpenetrable() noexcept;

    /// @brief Whether or not this contact was destroyed.
    /// @see SetDestroyed, UnsetDestroyed.
    constexpr bool IsDestroyed() const noexcept;

    /// @brief Sets the destroyed property of this contact.
    /// @note This is only meaningfully used by the world implementation.
    constexpr void SetDestroyed() noexcept;

    /// @brief Unsets the destroyed property of this contact.
    /// @note This is only meaningfully used by the world implementation.
    constexpr void UnsetDestroyed() noexcept;

private:
    /// Flags type data type.
    using FlagsType = std::uint8_t;

    /// @brief Flags stored in m_flags
    enum : FlagsType {
        // Set when the shapes are touching.
        e_touchingFlag = 0x01,

        // This entity can be disabled (by user)
        e_enabledFlag = 0x02,

        // This entity needs filtering because a shape filter was changed.
        e_filterFlag = 0x04,

        // This entity has a valid TOI in m_toi
        e_toiFlag = 0x08,

        // This entity needs its touching state updated.
        e_dirtyFlag = 0x10,

        /// Indicates whether this entity is to be treated as a sensor or not.
        e_sensorFlag = 0x20,

        /// Whether this entity was destroyed or not.
        e_destroyed = 0x40,

        /// Whether this entity is to be treated as between impenetrable bodies.
        e_impenetrableFlag = 0x80,
    };

    /// @brief Identifying info for the A-side of the 2-bodied contact.
    Contactable m_contactableA = DefaultContactable;

    /// @brief Identifying info for the B-side of the 2-bodied contact.
    Contactable m_contactableB = DefaultContactable;

    // initialized on construction (construction-time depedent)

    /// Mix of frictions of associated shapes.
    /// @see MixFriction.
    NonNegativeFF<Real> m_friction;

    /// Mix of restitutions of associated shapes.
    /// @see MixRestitution.
    Real m_restitution = 0;

    /// Tangent speed.
    LinearVelocity m_tangentSpeed = 0_mps;

    /// Time of impact.
    /// @note This is a unit interval of time (a value between 0 and 1).
    /// @note Only valid if <code>m_flags & e_toiFlag</code>.
    UnitIntervalFF<Real> m_toi;

    /// @brief Count of TOI calculations contact has gone through since last reset.
    /// @note This is a non-essential part - it should not participate in equality.
    substep_type m_toiCount = 0;

    FlagsType m_flags = 0; ///< Flags.
};

constexpr Contact::Contact(const Contactable& a, const Contactable& b) noexcept
    : m_contactableA{a},
      m_contactableB{b},
      m_flags{((a != DefaultContactable) || (b != DefaultContactable))
          ? FlagsType(e_enabledFlag | e_dirtyFlag): FlagsType{}}
{
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

constexpr const Contactable& Contact::GetContactableA() const noexcept
{
    return m_contactableA;
}

constexpr const Contactable& Contact::GetContactableB() const noexcept
{
    return m_contactableB;
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

constexpr void Contact::SetFriction(NonNegative<Real> friction) noexcept
{
    m_friction = friction;
}

constexpr NonNegativeFF<Real> Contact::GetFriction() const noexcept
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

constexpr std::optional<UnitIntervalFF<Real>> Contact::GetToi() const noexcept
{
    return HasValidToi() // force newline
        ? std::optional<UnitIntervalFF<Real>>{m_toi} // force newline
        : std::optional<UnitIntervalFF<Real>>{};
}

constexpr void Contact::SetToi(const std::optional<UnitIntervalFF<Real>>& toi) noexcept
{
    if (toi) {
        m_toi = *toi;
        m_flags |= Contact::e_toiFlag;
    }
    else {
        m_flags &= ~Contact::e_toiFlag;
    }
}

constexpr void Contact::SetToiCount(substep_type value) noexcept
{
    m_toiCount = value;
}

constexpr Contact::substep_type Contact::GetToiCount() const noexcept
{
    return m_toiCount;
}

constexpr bool Contact::IsSensor() const noexcept
{
    return (m_flags & e_sensorFlag) != 0u;
}

constexpr void Contact::SetSensor() noexcept
{
    m_flags |= e_sensorFlag;
}

constexpr void Contact::UnsetSensor() noexcept
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

constexpr bool Contact::IsDestroyed() const noexcept
{
    return (m_flags & e_destroyed) != 0u;
}

constexpr void Contact::SetDestroyed() noexcept
{
    m_flags |= e_destroyed;
}

constexpr void Contact::UnsetDestroyed() noexcept
{
    m_flags &= ~e_destroyed;
}

constexpr void Contact::IncrementToiCount() noexcept
{
    assert(m_toiCount < std::numeric_limits<decltype(m_toiCount)>::max());
    ++m_toiCount;
}

// Free functions...

/// @brief Operator equals.
/// @relatedalso Contact
constexpr bool operator==(const Contact& lhs, const Contact& rhs) noexcept
{
    // Excludes checking the following which are *non-essential parts*:
    //   lhs.GetToiCount() == rhs.GetToiCount()
    //   lhs.GetToi() == rhs.GetToi()
    return lhs.GetContactableA() == rhs.GetContactableA() && //
           lhs.GetContactableB() == rhs.GetContactableB() && //
           lhs.GetFriction() == rhs.GetFriction() && //
           lhs.GetRestitution() == rhs.GetRestitution() && //
           lhs.GetTangentSpeed() == rhs.GetTangentSpeed() && //
           lhs.IsTouching() == rhs.IsTouching() && //
           lhs.IsEnabled() == rhs.IsEnabled() && //
           lhs.NeedsFiltering() == rhs.NeedsFiltering() && //
           lhs.NeedsUpdating() == rhs.NeedsUpdating() && //
           lhs.IsSensor() == rhs.IsSensor() && //
           lhs.IsImpenetrable() == rhs.IsImpenetrable() && //
           lhs.IsDestroyed() == rhs.IsDestroyed();
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
    return contact.GetContactableA().bodyId;
}

/// @brief Gets the body B ID of the given contact.
/// @relatedalso Contact
constexpr BodyID GetBodyB(const Contact& contact) noexcept
{
    return contact.GetContactableB().bodyId;
}

/// @brief Gets the shape A associated with the given contact.
/// @relatedalso Contact
constexpr ShapeID GetShapeA(const Contact& contact) noexcept
{
    return contact.GetContactableA().shapeId;
}

/// @brief Gets the shape B associated with the given contact.
/// @relatedalso Contact
constexpr ShapeID GetShapeB(const Contact& contact) noexcept
{
    return contact.GetContactableB().shapeId;
}

/// @brief Gets the child index A of the given contact.
/// @relatedalso Contact
constexpr ChildCounter GetChildIndexA(const Contact& contact) noexcept
{
    return contact.GetContactableA().childId;
}

/// @brief Gets the child index B of the given contact.
/// @relatedalso Contact
constexpr ChildCounter GetChildIndexB(const Contact& contact) noexcept
{
    return contact.GetContactableB().childId;
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
/// @post <code>IsImpenetrable(contact)</code> returns true.
/// @see IsImpenetrable(const Contact &).
/// @relatedalso Contact
constexpr void SetImpenetrable(Contact& contact) noexcept
{
    contact.SetImpenetrable();
}

/// @brief Unsets the impenetrability of the given contact.
/// @attention Call this if body A or body B are no longer impenetrable.
/// @post <code>IsImpenetrable(contact)</code> returns false.
/// @see IsImpenetrable(const Contact &).
/// @relatedalso Contact
constexpr void UnsetImpenetrable(Contact& contact) noexcept
{
    contact.UnsetImpenetrable();
}

/// @brief Gets whether the given contact is enabled or not.
/// @relatedalso Contact
constexpr bool IsEnabled(const Contact& contact) noexcept
{
    return contact.IsEnabled();
}

/// @brief Enables the contact.
/// @post <code>IsEnabled(contact)</code> returns true.
/// @see IsEnabled(const Contact &).
/// @relatedalso Contact
constexpr void SetEnabled(Contact& contact) noexcept
{
    contact.SetEnabled();
}

/// @brief Disables the identified contact.
/// @post <code>IsEnabled(contact)</code> returns false.
/// @see IsEnabled(const Contact &).
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
/// @post <code>IsSensor(contact)</code> returns true.
/// @see IsSensor(const Contact &).
/// @relatedalso Contact
constexpr void SetSensor(Contact& contact) noexcept
{
    contact.SetSensor();
}

/// @brief Unsets the sensor state of the given contact.
/// @post <code>IsSensor(contact)</code> returns false.
/// @see IsSensor(const Contact &).
/// @relatedalso Contact
constexpr void UnsetSensor(Contact& contact) noexcept
{
    contact.UnsetSensor();
}

/// @brief Gets the time of impact count.
/// @see SetToiCount.
/// @relatedalso Contact
constexpr auto GetToiCount(const Contact& contact) noexcept
{
    return contact.GetToiCount();
}

/// @brief Sets the TOI count to the given value.
/// @post <code>GetToiCount(contact)</code> returns @p value.
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
/// @post <code>NeedsFiltering(contact)</code> returns true.
/// @see NeedsFiltering(const Contact &).
/// @relatedalso Contact
constexpr void FlagForFiltering(Contact& contact) noexcept
{
    contact.FlagForFiltering();
}

/// @brief Unflags this contact for filtering.
/// @post <code>NeedsFiltering(contact)</code> returns false.
/// @see NeedsFiltering(const Contact &).
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
/// @post <code>NeedsUpdating(contact)</code> returns true.
/// @see NeedsUpdating(const Contact &).
/// @relatedalso Contact
constexpr void FlagForUpdating(Contact& contact) noexcept
{
    contact.FlagForUpdating();
}

/// @brief Unflags this contact for updating.
/// @post <code>NeedsUpdating(contact)</code> returns false.
/// @see NeedsUpdating(const Contact &).
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
/// @return Time of impact fraction in the range of 0 to 1 if set (where 1
///   means no actual impact in current time slot), otherwise empty.
/// @see HasValidToi, SetToi(Contact&, const std::optional<UnitIntervalFF<Real>>&).
/// @relatedalso Contact
constexpr auto GetToi(const Contact& contact) noexcept
{
    return contact.GetToi();
}

/// @brief Sets the time of impact (TOI).
/// @param contact The contact to update.
/// @param toi Optional time of impact as a fraction between 0 and 1 where 1 indicates no
///   actual impact in the current time slot.
/// @post <code>HasValidToi(contact)</code> returns <code>toi.has_value()</code>.
/// @post <code>GetToi(const Contact&)</code> returns the value set.
/// @see HasValidToi, GetToi.
/// @relatedalso Contact
constexpr void SetToi(Contact& contact, const std::optional<UnitIntervalFF<Real>>& toi) noexcept
{
    contact.SetToi(toi);
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
/// @param contact The contact whose friction should be set.
/// @param value Co-efficient of friction value of zero or greater.
/// @pre @p friction must be greater-than or equal-to zero.
/// @post <code>GetFriction(contact)</code> returns the value set.
/// @see GetFriction.
/// @relatedalso Contact
constexpr void SetFriction(Contact& contact, NonNegative<Real> value) noexcept
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
/// @post <code>GetRestitution(contact)</code> returns the value set.
/// @see GetRestitution.
/// @relatedalso Contact
constexpr void SetRestitution(Contact& contact, Real value)
{
    contact.SetRestitution(value);
}

/// @brief Gets the desired tangent speed.
/// @see SetTangentSpeed.
/// @relatedalso Contact
constexpr auto GetTangentSpeed(const Contact& contact) noexcept
{
    return contact.GetTangentSpeed();
}

/// @brief Sets the desired tangent speed for a conveyor belt behavior.
/// @post <code>GetTangentSpeed(contact)</code> returns the value set.
/// @see GetTangentSpeed.
/// @relatedalso Contact
constexpr void SetTangentSpeed(Contact& contact, LinearVelocity value) noexcept
{
    contact.SetTangentSpeed(value);
}

/// @brief Is-for convenience function.
/// @return true if contact is for the identified body and shape, else false.
/// @relatedalso Contact
constexpr bool IsFor(const Contact& c, BodyID bodyID, ShapeID shapeID) noexcept
{
    return IsFor(c.GetContactableA(), bodyID, shapeID) // force newline
        || IsFor(c.GetContactableB(), bodyID, shapeID);
}

/// @brief Is-for convenience function.
/// @return true if contact is for the identified shape, else false.
/// @relatedalso Contact
constexpr bool IsFor(const Contact& c, ShapeID shapeID) noexcept
{
    return (GetShapeA(c) == shapeID) || (GetShapeB(c) == shapeID);
}

/// @brief Gets the other body ID for the contact than the one given.
/// @relatedalso Contact
constexpr auto GetOtherBody(const Contact& c, BodyID bodyID) noexcept
{
    return (c.GetContactableA().bodyId != bodyID)
        ? c.GetContactableA().bodyId: c.GetContactableB().bodyId;
}

/// @brief Whether or not the given contact was destroyed.
/// @see SetDestroyed, UnsetDestroyed.
/// @relatedalso Contact
constexpr auto IsDestroyed(const Contact& c) noexcept -> bool
{
    return c.IsDestroyed();
}

/// @brief Sets the destroyed property of the given contact.
/// @note This is only meaningfully used by the world implementation.
/// @relatedalso Contact
constexpr void SetDestroyed(Contact& c) noexcept
{
    c.SetDestroyed();
}

/// @brief Unsets the destroyed property of the given contact.
/// @note This is only meaningfully used by the world implementation.
/// @relatedalso Contact
constexpr void UnsetDestroyed(Contact& c) noexcept
{
    c.UnsetDestroyed();
}

} // namespace playrho

#endif // PLAYRHO_CONTACT_HPP

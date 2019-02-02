/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_DYNAMICS_CONTACTS_CONTACT_HPP
#define PLAYRHO_DYNAMICS_CONTACTS_CONTACT_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Collision/Manifold.hpp"
#include "PlayRho/Collision/Distance.hpp"
#include "PlayRho/Collision/TimeOfImpact.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"

namespace playrho {

/// @brief Mixes friction.
///
/// @details Friction mixing formula. The idea is to allow either fixture to drive the
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
class StepConf;

namespace d2 {

class Body;
class Fixture;
class ContactListener;

/// @brief A potential contact between the children of two Fixture objects.
///
/// @details The class manages contact between two shapes. A contact exists for each overlapping
///   AABB in the broad-phase (except if filtered). Therefore a contact object may exist
///   that has no actual contact points.
///
/// @note These are created by World instances. Users have no need to instantiate these
///   themselves.
/// @note This data structure is 104-bytes large (on at least one 64-bit platform).
///
/// @ingroup PhysicalEntities
/// @ingroup ConstraintsGroup
///
class Contact
{
public:
    
    /// @brief Substep type.
    using substep_type = TimestepIters;

    /// @brief Update configuration.
    struct UpdateConf
    {
        DistanceConf distance; ///< Distance configuration data.
        Manifold::Conf manifold; ///< Manifold configuration data.
    };
    
    /// @brief Gets the update configuration from the given step configuration data.
    static UpdateConf GetUpdateConf(const StepConf& conf) noexcept;
    
    /// @brief Initializing constructor.
    ///
    /// @param fA Non-null pointer to fixture A that must have a shape
    ///   and may not be the same or have the same body as the other fixture.
    /// @param iA Child index A.
    /// @param fB Non-null pointer to fixture B that must have a shape
    ///   and may not be the same or have the same body as the other fixture.
    /// @param iB Child index B.
    ///
    /// @note This need never be called directly by a user.
    /// @warning Behavior is undefined if <code>fA</code> is null.
    /// @warning Behavior is undefined if <code>fB</code> is null.
    /// @warning Behavior is undefined if <code>fA == fB</code>.
    /// @warning Behavior is undefined if both fixture's have the same body.
    ///
    Contact(Fixture* fA, ChildCounter iA, Fixture* fB, ChildCounter iB);
    
    /// @brief Default construction not allowed.
    Contact() = delete;
    
    /// @brief Copy constructor.
    Contact(const Contact& copy) = default;

    /// @brief Gets the contact manifold.
    const Manifold& GetManifold() const noexcept;
    
    /// @brief Is this contact touching?
    /// @details
    /// Touching is defined as either:
    ///   1. This contact's manifold has more than 0 contact points, or
    ///   2. This contact has sensors and the two shapes of this contact are found to be
    ///      overlapping.
    /// @return true if this contact is said to be touching, false otherwise.
    bool IsTouching() const noexcept;

    /// @brief Enables or disables this contact.
    /// @note This can be used inside the pre-solve contact listener.
    ///   The contact is only disabled for the current time step (or sub-step in continuous
    ///   collisions).
    [[deprecated]] void SetEnabled(bool flag) noexcept;

    /// @brief Enables this contact.
    void SetEnabled() noexcept;

    /// @brief Disables this contact.
    void UnsetEnabled() noexcept;

    /// @brief Has this contact been disabled?
    bool IsEnabled() const noexcept;

    /// @brief Gets fixture A in this contact.
    Fixture* GetFixtureA() const noexcept;

    /// @brief Get the child primitive index for fixture A.
    ChildCounter GetChildIndexA() const noexcept;

    /// @brief Gets fixture B in this contact.
    Fixture* GetFixtureB() const noexcept;

    /// @brief Get the child primitive index for fixture B.
    ChildCounter GetChildIndexB() const noexcept;

    /// @brief Sets the friction value for this contact.
    /// @details Override the default friction mixture.
    /// @note You can call this in <code>ContactListener::PreSolve</code>.
    /// @note This value persists until set or reset.
    /// @warning Behavior is undefined if given a negative friction value.
    /// @param friction Co-efficient of friction value of zero or greater.
    void SetFriction(Real friction) noexcept;

    /// @brief Gets the coefficient of friction.
    /// @details Gets the combined friction of the two fixtures associated with this contact.
    /// @return Value of 0 or higher.
    /// @sa MixFriction.
    Real GetFriction() const noexcept;

    /// @brief Sets the restitution.
    /// @details This override the default restitution mixture.
    /// @note You can call this in <code>ContactListener::PreSolve</code>.
    /// @note The value persists until you set or reset.
    void SetRestitution(Real restitution) noexcept;

    /// @brief Gets the restitution.
    Real GetRestitution() const noexcept;

    /// @brief Sets the desired tangent speed for a conveyor belt behavior.
    void SetTangentSpeed(LinearVelocity speed) noexcept;

    /// @brief Gets the desired tangent speed.
    LinearVelocity GetTangentSpeed() const noexcept;

    /// @brief Gets the time of impact count.
    substep_type GetToiCount() const noexcept;

    /// @brief Gets whether a TOI is set.
    /// @return true if this object has a TOI set for it, false otherwise.
    bool HasValidToi() const noexcept;

    /// @brief Gets the time of impact (TOI) as a fraction.
    /// @note This is only valid if a TOI has been set.
    /// @sa void SetToi(Real toi).
    /// @return Time of impact fraction in the range of 0 to 1 if set (where 1
    ///   means no actual impact in current time slot), otherwise undefined.
    Real GetToi() const;

    /// @brief Flags the contact for filtering.
    void FlagForFiltering() noexcept;

    /// @brief Whether or not the contact needs filtering.
    bool NeedsFiltering() const noexcept;

    /// @brief Flags the contact for updating.
    void FlagForUpdating() noexcept;

    /// @brief Whether or not the contact needs updating.
    bool NeedsUpdating() const noexcept;

private:

    friend class ContactAtty;

    /// Flags type data type.
    using FlagsType = std::uint8_t;

    /// @brief Flags stored in m_flags
    enum: FlagsType
    {
        // Used when crawling contact graph when forming islands.
        e_islandFlag = 0x01,
        
        // Set when the shapes are touching.
        e_touchingFlag = 0x02,

        // This contact can be disabled (by user)
        e_enabledFlag = 0x04,

        // This contact needs filtering because a fixture filter was changed.
        e_filterFlag = 0x08,

        // This contact has a valid TOI in m_toi
        e_toiFlag = 0x10,
        
        // This contacts needs its touching state updated.
        e_dirtyFlag = 0x20
    };
    
    /// @brief Flags this contact for filtering.
    /// @note Filtering will occur the next time step.
    void UnflagForFiltering() noexcept;

    /// @brief Unflags this contact for updating.
    void UnflagForUpdating() noexcept;

    /// @brief Updates the touching related state and notifies listener (if one given).
    ///
    /// @note Ideally this method is only called when a dependent change has occurred.
    /// @note Touching related state depends on the following data:
    ///   - The fixtures' sensor states.
    ///   - The fixtures bodies' transformations.
    ///   - The <code>maxCirclesRatio</code> per-step configuration state *OR* the
    ///     <code>maxDistanceIters</code> per-step configuration state.
    ///
    /// @param conf Per-step configuration information.
    /// @param listener Listener that if non-null is called with status information.
    ///
    /// @sa GetManifold, IsTouching
    ///
    void Update(const UpdateConf& conf, ContactListener* listener = nullptr);

    /// @brief Sets the time of impact (TOI).
    /// @details After returning, this object will have a TOI that is set as indicated by <code>HasValidToi()</code>.
    /// @note Behavior is undefined if the value assigned is less than 0 or greater than 1.
    /// @sa Real GetToi() const.
    /// @sa HasValidToi.
    /// @param toi Time of impact as a fraction between 0 and 1 where 1 indicates no actual impact in the current time slot.
    void SetToi(Real toi) noexcept;

    /// @brief Unsets the TOI.
    void UnsetToi() noexcept;

    /// @brief Sets the TOI count to the given value.
    void SetToiCount(substep_type value) noexcept;

    /// @brief Sets the touching flag state.
    /// @note This should only be called if either:
    ///   1. The contact's manifold has more than 0 contact points, or
    ///   2. The contact has sensors and the two shapes of this contact are found to be overlapping.
    /// @sa IsTouching().
    void SetTouching() noexcept;

    /// @brief Unsets the touching flag state.
    void UnsetTouching() noexcept;

    /// @brief Gets the writable manifold.
    /// @note This is intentionally not a public method.
    /// @warning Do not modify the manifold unless you understand the internals of the engine.
    Manifold& GetMutableManifold() noexcept;
    
    /// @brief Whether this contact is in the is-in-island state.
    bool IsIslanded() const noexcept;
    
    /// @brief Sets this contact to the is-in-island state.
    void SetIslanded() noexcept;
    
    /// @brief Unsets the is-in-island state.
    void UnsetIslanded() noexcept;

    // Member variables...

    Manifold mutable m_manifold; ///< Manifold of the contact. 64-bytes. @sa Update.

    // Need to be able to identify two different fixtures, the child shape per fixture,
    // and the two different bodies that each fixture is associated with. This could be
    // done by storing whatever information is needed to lookup this information. For
    // instance, if the dynamic tree's two leaf nodes for this contact contained this
    // info then minimally only those two indexes are needed. That may be sub-optimal
    // however depending the speed of cache and memory access.

    Fixture* const m_fixtureA; ///< Fixture A. @details Non-null pointer to fixture A.
    Fixture* const m_fixtureB; ///< Fixture B. @details Non-null pointer to fixture B.
    ChildCounter const m_indexA; ///< Index A.
    ChildCounter const m_indexB; ///< Index B.
    
    // initialized on construction (construction-time depedent)
    Real m_friction; ///< Mix of frictions of the associated fixtures. @sa MixFriction.
    Real m_restitution; ///< Mix of restitutions of the associated fixtures. @sa MixRestitution.

    LinearVelocity m_tangentSpeed = 0; ///< Tangent speed.
    
    /// Time of impact.
    /// @note This is a unit interval of time (a value between 0 and 1).
    /// @note Only valid if <code>m_flags & e_toiFlag</code>.
    Real m_toi;
    
    substep_type m_toiCount = 0; ///< Count of TOI calculations contact has gone through since last reset.
    
    FlagsType m_flags = e_enabledFlag|e_dirtyFlag; ///< Flags.
};

/// @example Contact.cpp
/// This is the <code>googletest</code> based unit testing file for the
///   <code>playrho::d2::Contact</code> class.

inline const Manifold& Contact::GetManifold() const noexcept
{
    // XXX: What to do if needs-updating?
    //assert(!NeedsUpdating());
    return m_manifold;
}

inline Manifold& Contact::GetMutableManifold() noexcept
{
    return m_manifold;
}

inline void Contact::SetEnabled(bool flag) noexcept
{
    if (flag)
    {
        SetEnabled();
    }
    else
    {
        UnsetEnabled();
    }
}

inline void Contact::SetEnabled() noexcept
{
    m_flags |= Contact::e_enabledFlag;
}

inline void Contact::UnsetEnabled() noexcept
{
    m_flags &= ~Contact::e_enabledFlag;
}

inline bool Contact::IsEnabled() const noexcept
{
    return (m_flags & e_enabledFlag) != 0;
}

inline bool Contact::IsTouching() const noexcept
{
    // XXX: What to do if needs-updating?
    // assert(!NeedsUpdating());
    return (m_flags & e_touchingFlag) != 0;
}

inline void Contact::SetTouching() noexcept
{
    m_flags |= e_touchingFlag;
}

inline void Contact::UnsetTouching() noexcept
{
    m_flags &= ~e_touchingFlag;
}

inline Fixture* Contact::GetFixtureA() const noexcept
{
    return m_fixtureA;
}

inline Fixture* Contact::GetFixtureB() const noexcept
{
    return m_fixtureB;
}

inline void Contact::FlagForFiltering() noexcept
{
    m_flags |= e_filterFlag;
}

inline void Contact::UnflagForFiltering() noexcept
{
    m_flags &= ~Contact::e_filterFlag;
}

inline bool Contact::NeedsFiltering() const noexcept
{
    return (m_flags & Contact::e_filterFlag) != 0;
}

inline void Contact::FlagForUpdating() noexcept
{
    m_flags |= e_dirtyFlag;
}

inline void Contact::UnflagForUpdating() noexcept
{
    m_flags &= ~Contact::e_dirtyFlag;
}

inline bool Contact::NeedsUpdating() const noexcept
{
    return (m_flags & Contact::e_dirtyFlag) != 0;
}

inline void Contact::SetFriction(Real friction) noexcept
{
    assert(friction >= 0);
    m_friction = friction;
}

inline Real Contact::GetFriction() const noexcept
{
    return m_friction;
}

inline void Contact::SetRestitution(Real restitution) noexcept
{
    m_restitution = restitution;
}

inline Real Contact::GetRestitution() const noexcept
{
    return m_restitution;
}

inline void Contact::SetTangentSpeed(LinearVelocity speed) noexcept
{
    m_tangentSpeed = speed;
}

inline LinearVelocity Contact::GetTangentSpeed() const noexcept
{
    return m_tangentSpeed;
}

inline bool Contact::HasValidToi() const noexcept
{
    return (m_flags & Contact::e_toiFlag) != 0;
}

inline Real Contact::GetToi() const
{
    assert(HasValidToi());
    return m_toi;
}

inline void Contact::SetToi(Real toi) noexcept
{
    assert(toi >= 0 && toi <= 1);
    m_toi = toi;
    m_flags |= Contact::e_toiFlag;
}

inline void Contact::UnsetToi() noexcept
{
    m_flags &= ~Contact::e_toiFlag;
}

inline void Contact::SetToiCount(substep_type value) noexcept
{
    m_toiCount = value;
}

inline Contact::substep_type Contact::GetToiCount() const noexcept
{
    return m_toiCount;
}

inline bool Contact::IsIslanded() const noexcept
{
    return (m_flags & e_islandFlag) != 0;
}

inline void Contact::SetIslanded() noexcept
{
    m_flags |= e_islandFlag;
}

inline void Contact::UnsetIslanded() noexcept
{
    m_flags &= ~e_islandFlag;
}

inline ChildCounter Contact::GetChildIndexA() const noexcept
{
    return m_indexA;
}

inline ChildCounter Contact::GetChildIndexB() const noexcept
{
    return m_indexB;
}

// Free functions...

/// @brief Contact pointer type.
using ContactPtr = Contact*;

/// @brief Gets the body A associated with the given contact.
/// @relatedalso Contact
Body* GetBodyA(const Contact& contact) noexcept;

/// @brief Gets the body B associated with the given contact.
/// @relatedalso Contact
Body* GetBodyB(const Contact& contact) noexcept;

/// @brief Gets the fixture A associated with the given contact.
/// @relatedalso Contact
inline Fixture* GetFixtureA(const Contact& contact) noexcept
{
    return contact.GetFixtureA();
}

/// @brief Gets the fixture B associated with the given contact.
/// @relatedalso Contact
inline Fixture* GetFixtureB(const Contact& contact) noexcept
{
    return contact.GetFixtureB();
}

/// @brief Gets the child index A of the given contact.
/// @relatedalso Contact
inline ChildCounter GetChildIndexA(const Contact& contact) noexcept
{
    return contact.GetChildIndexA();
}

/// @brief Gets the child index B of the given contact.
/// @relatedalso Contact
inline ChildCounter GetChildIndexB(const Contact& contact) noexcept
{
    return contact.GetChildIndexB();
}

/// @brief Whether the given contact has a sensor.
/// @relatedalso Contact
bool HasSensor(const Contact& contact) noexcept;

/// @brief Whether the given contact is "impenetrable".
/// @relatedalso Contact
bool IsImpenetrable(const Contact& contact) noexcept;

/// @brief Determines whether the given contact is "active".
/// @relatedalso Contact
bool IsActive(const Contact& contact) noexcept;

/// @brief Sets awake the fixtures of the given contact.
/// @relatedalso Contact
void SetAwake(const Contact& c) noexcept;

/// Resets the friction mixture to the default value.
/// @relatedalso Contact
void ResetFriction(Contact& contact);

/// Reset the restitution to the default value.
/// @relatedalso Contact
void ResetRestitution(Contact& contact) noexcept;

/// @brief Calculates the Time Of Impact for the given contact with the given configuration.
/// @relatedalso Contact
TOIOutput CalcToi(const Contact& contact, ToiConf conf);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTS_CONTACT_HPP

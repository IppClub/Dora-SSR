/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef PLAYRHO_DYNAMICS_WORLDCALLBACKS_HPP
#define PLAYRHO_DYNAMICS_WORLDCALLBACKS_HPP

#include "PlayRho/Common/Settings.hpp"
#include <algorithm>

namespace playrho {
namespace d2 {

class Fixture;
class Joint;
class Contact;
class Manifold;
class ContactImpulsesList;

/// Joints and fixtures are destroyed when their associated
/// body is destroyed. Implement this listener so that you
/// may nullify references to these joints and shapes.
class DestructionListener
{
public:
    virtual ~DestructionListener() noexcept = default;

    /// @brief Called just before destroying a joint.
    /// @details Called when any joint is about to be destroyed due
    ///    to the destruction of one of its attached bodies.
    /// @note Implementations of this method should not throw any exceptions.
    virtual void SayGoodbye(const Joint& joint) noexcept = 0;

    /// @brief Called just before destroying a fixture.
    /// @details Called when any fixture is about to be destroyed due
    ///    to the destruction of its parent body.
    /// @note Implementations of this method should not throw any exceptions.
    virtual void SayGoodbye(const Fixture& fixture) noexcept = 0;
};

/// @brief A pure-virtual interface for "listeners" for contacts.
///
/// @details Implement this class to get contact information. You can use these results
///   for things like sounds and game logic. You can also get contact results by
///   traversing the contact lists after the time step. However, you might miss
///   some contacts because continuous physics leads to sub-stepping.
///   Additionally you may receive multiple callbacks for the same contact in a
///   single time step.
///   You should strive to make your callbacks efficient because there may be
///   many callbacks per time step.
///
/// @warning You cannot create/destroy PlayRho entities inside these callbacks.
///
class ContactListener
{
public:
    
    /// @brief Iteration type.
    using iteration_type = unsigned;

    virtual ~ContactListener() = default;

    /// @brief Called when two fixtures begin to touch.
    virtual void BeginContact(Contact& contact) = 0;

    /// @brief End contact callback.
    ///
    /// @details Called when the contact's "touching" property becomes false, or just before
    ///   the contact is destroyed.
    ///
    /// @note This contact persists until the broad phase determines there's no overlap anymore
    ///   between the two fixtures.
    /// @note If the contact's "touching" property becomes true again, <code>BeginContact</code>
    ///   will be called again for this contact.
    ///
    /// @param contact Contact that's about to be destroyed or whose "touching" property has become
    ///   false.
    ///
    /// @sa Contact::IsTouching().
    ///
    virtual void EndContact(Contact& contact) = 0;
    
    /// @brief Pre-solve callback.
    ///
    /// @details This is called after a contact is updated. This allows you to inspect
    ///   a contact before it goes to the solver. If you are careful, you can modify the
    ///   contact manifold (e.g. disable contact). A copy of the old manifold is provided
    ///   so that you can detect changes.
    ///
    /// @note This is called only for awake bodies.
    /// @note This is called even when the number of contact points is zero.
    /// @note This is not called for sensors.
    /// @note If you set the number of contact points to zero, you will not get an
    ///   <code>EndContact</code> callback. However, you may get a <code>BeginContact</code>
    ///   callback the next step.
    ///
    virtual void PreSolve(Contact& contact, const Manifold& oldManifold) = 0;

    /// @brief Post-solve callback.
    ///
    /// @details This lets you inspect a contact after the solver is finished. This is useful
    ///   for inspecting impulses.
    ///
    /// @note The contact manifold does not include time of impact impulses, which can be
    ///   arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
    ///   in a separate data structure.
    /// @note This is only called for contacts that are touching, solid, and awake.
    ///
    virtual void PostSolve(Contact& contact, const ContactImpulsesList& impulses,
                           iteration_type solved) = 0;
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDCALLBACKS_HPP

/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_WORLDATTY_HPP
#define PLAYRHO_DYNAMICS_WORLDATTY_HPP

/// @file
/// Declaration of the WorldAtty class.

#include "PlayRho/Dynamics/World.hpp"

namespace playrho {
namespace d2 {
    
/// @brief World attorney.
///
/// @details This is the "world attorney" which provides limited privileged access to the
///   World class for the Body and Fixture classes.
///
/// @note This class uses the "attorney-client" idiom to control the granularity of
///   friend-based access to the World class. This is meant to help preserve and enforce
///   the invariants of the World class.
///
/// @sa https://en.wikibooks.org/wiki/More_C++_Idioms/Friendship_and_the_Attorney-Client
///
class WorldAtty
{
private:

    /// @brief Touches each proxy of the given fixture.
    /// @note Fixture must belong to a body that belongs to this world or this method will
    ///   return false.
    /// @note This sets things up so that pairs may be created for potentially new contacts.
    static void TouchProxies(World& world, Fixture& fixture) noexcept
    {
        world.TouchProxies(fixture);
    }

    /// @brief Sets the type of the given body.
    /// @note This may alter the body's mass and velocity.
    /// @throws WrongState if this method is called while the world is locked.
    static void SetType(World& world, Body& body, playrho::BodyType type)
    {
        world.SetType(body, type);
    }
    
    /// @brief Creates a fixture with the given parameters.
    /// @throws InvalidArgument if called for a body that doesn't belong to this world.
    /// @throws InvalidArgument if called without a shape.
    /// @throws InvalidArgument if called for a shape with a vertex radius less than the
    ///    minimum vertex radius.
    /// @throws InvalidArgument if called for a shape with a vertex radius greater than the
    ///    maximum vertex radius.
    /// @throws WrongState if this method is called while the world is locked.
    static Fixture* CreateFixture(World& world, Body& body, const Shape& shape,
                                  const FixtureConf& def, bool resetMassData)
    {
        return world.CreateFixture(body, shape, def, resetMassData);
    }
    
    /// @brief Destroys a fixture.
    ///
    /// @details This removes the fixture from the broad-phase and destroys all contacts
    ///   associated with this fixture.
    ///   All fixtures attached to a body are implicitly destroyed when the body is destroyed.
    ///
    /// @warning This function is locked during callbacks.
    /// @note Make sure to explicitly call <code>ResetMassData</code> after fixtures have been
    ///   destroyed.
    ///
    /// @param world World instance to have destroy the fixture.
    /// @param fixture the fixture to be removed.
    /// @param resetMassData Whether or not to reset the mass data of the associated body.
    ///
    /// @sa ResetMassData.
    ///
    /// @throws WrongState if this method is called while the world is locked.
    ///
    static bool Destroy(World& world, Fixture& fixture, bool resetMassData)
    {
        return world.Destroy(fixture, resetMassData);
    }
    
    /// @brief Register for proxies for the given body.
    static void RegisterForProxies(World& world, Body& body)
    {
        world.RegisterForProxies(body);
    }
    
    /// @brief Register for proxies for the given fixture.
    static void RegisterForProxies(World& world, Fixture& fixture)
    {
        world.RegisterForProxies(fixture);
    }
    
    friend class Body;
    friend class Fixture;
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDATTY_HPP

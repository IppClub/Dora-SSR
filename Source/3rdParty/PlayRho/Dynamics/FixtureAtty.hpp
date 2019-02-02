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

#ifndef PLAYRHO_DYNAMICS_FIXTUREATTY_HPP
#define PLAYRHO_DYNAMICS_FIXTUREATTY_HPP

/// @file
/// Declaration of the FixtureAtty class.

#include "PlayRho/Common/Span.hpp"
#include "PlayRho/Dynamics/Fixture.hpp"
#include <vector>
#include <memory>

namespace playrho {
namespace d2 {

/// @brief Fixture attorney.
///
/// @details This is the "fixture attorney" which provides limited privileged access to the
///   Fixture class for the World class.
///
/// @note This class uses the "attorney-client" idiom to control the granularity of
///   friend-based access to the Fixture class. This is meant to help preserve and enforce
///   the invariants of the Fixture class.
///
/// @sa https://en.wikibooks.org/wiki/More_C++_Idioms/Friendship_and_the_Attorney-Client
///
class FixtureAtty
{
private:
    
    /// @brief Gets the proxies of the given fixture.
    static auto GetProxies(const Fixture& fixture)
    {
        return fixture.GetProxies();
    }
    
    /// @brief Sets the proxies of the given fixture.
    static void SetProxies(Fixture& fixture, std::unique_ptr<FixtureProxy[]> value,
                           std::size_t count)
    {
        fixture.SetProxies(std::move(value), count);
    }
    
    /// @brief Resets the proxies of the given fixture.
    static void ResetProxies(Fixture& fixture) noexcept
    {
        fixture.ResetProxies();
    }
    
    /// @brief Creates a new fixture for the given body and with the given settings.
    static Fixture* Create(Body& body, const FixtureConf& def, Shape shape)
    {
        return new Fixture{&body, def, shape};
    }
    
    /// @brief Deletes a fixture.
    static void Delete(Fixture *fixture)
    {
        delete fixture;
    }
    
    friend class World;
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_FIXTUREATTY_HPP

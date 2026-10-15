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

#ifndef PLAYRHO_RAYCASTOPCODE_HPP
#define PLAYRHO_RAYCASTOPCODE_HPP

/// @file
/// @brief Definition of the @c RayCastOpcode enumeration.

namespace playrho {

/// @brief Ray cast opcode enumeration.
/// @details Instructs some ray casting methods on what to do next.
enum class RayCastOpcode
{
    /// @brief End the ray-cast search for fixtures.
    /// @details Use this to stop searching for fixtures.
    Terminate,

    /// @brief Ignore the current fixture.
    /// @details Use this to continue searching for fixtures along the ray.
    IgnoreFixture,

    /// @brief Clip the ray end to the current point.
    /// @details Use this shorten the ray to the current point and to continue searching
    ///   for fixtures now along the newly shortened ray.
    ClipRay,

    /// @brief Reset the ray end back to the second point.
    /// @details Use this to restore the ray to its full length and to continue searching
    ///    for fixtures now along the restored full length ray.
    ResetRay
};

} // namespace playrho

#endif // PLAYRHO_RAYCASTOPCODE_HPP

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

#ifndef PLAYRHO_POINTSTATE_HPP
#define PLAYRHO_POINTSTATE_HPP

/// @file
/// @brief Definition of the @c PointState enumeration.

namespace playrho {

/// @brief Point state enumeration.
/// @note This is used for determining the state of contact points.
enum class PointState
{
    Null, ///< Point does not exist.
    Add, ///< Point was added in the update.
    Persist, ///< Point persisted across the update.
    Remove ///< Point was removed in the update.
};

} // namespace playrho

#endif // PLAYRHO_POINTSTATE_HPP

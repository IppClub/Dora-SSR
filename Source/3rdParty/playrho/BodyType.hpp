/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_BODYTYPE_HPP
#define PLAYRHO_BODYTYPE_HPP

/// @file
/// @brief Definition of the <code>BodyType</code> enumeration and closely related code.

namespace playrho {

/// @brief Type of body.
/// @note static: zero mass, zero velocity, may be manually moved.
/// @note kinematic: zero mass, non-zero velocity set by user, moved by solver.
/// @note dynamic: positive mass, non-zero velocity determined by forces, moved by solver.
/// @see IsSpeedable(BodyType), IsAccelerable(BodyType).
enum class BodyType {
    /// Static body type.
    /// @details
    /// Static bodies have no mass, have no forces applied to them, and aren't moved by
    /// physical processes. They are impenetrable.
    /// @note Physics applied: none.
    Static = 0,

    /// Kinematic body type.
    /// @details
    /// Kinematic bodies: have no mass, cannot have forces applied to them,
    /// can move at set velocities (they are "speedable"), and are impenetrable.
    /// @note Physics applied: velocity.
    Kinematic,

    /// Dynamic body type.
    /// @details
    /// Dynamic bodies are fully simulated bodies - they are "speedable" and "accelerable".
    /// Dynamic bodies always have a positive non-zero mass.
    /// They may be penetrable.
    /// @note Physics applied: velocity, acceleration.
    Dynamic
};

/// @brief Is "speedable".
/// @details Whether or not the given type value is for a body which can have a non-zero
///   speed associated with it.
/// @return <code>true</code> if the given type value represents a "speedable" type value,
///   <code>false</code> otherwise.
/// @note Would be nice if the Doxygen "relatedalso BodyType" command worked for this but
///   seems that doesn't work for scoped enumeration.
/// @see IsAccelerable(BodyType).
inline bool IsSpeedable(BodyType type)
{
    return type != BodyType::Static;
}

/// @brief Is "accelerable".
/// @details Whether or not the given type value is for a body which can have a non-zero
///   acceleration associated with it.
/// @return <code>true</code> if the given type value represents an "accelerable" type value,
///   <code>false</code> otherwise.
/// @note Would be nice if the Doxygen "relatedalso BodyType" command worked for this but
///   seems that doesn't work for scoped enumeration.
/// @see IsSpeedable(BodyType).
inline bool IsAccelerable(BodyType type)
{
    return type == BodyType::Dynamic;
}

} // namespace playrho

#endif // PLAYRHO_BODYTYPE_HPP

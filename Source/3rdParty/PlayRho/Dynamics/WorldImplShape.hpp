/*
 * Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_WORLDIMPLSHAPE_HPP
#define PLAYRHO_DYNAMICS_WORLDIMPLSHAPE_HPP

/// @file
/// Declarations of free functions of WorldImpl for shapes.

#include "PlayRho/Collision/Shapes/ShapeID.hpp"

namespace playrho {
namespace d2 {

class WorldImpl;
class Shape;

/// @brief Gets the extent of the currently valid shape range.
/// @note This is one higher than the maxium <code>ShapeID</code> that is in range
///   for shape related functions.
/// @relatedalso WorldImpl
ShapeCounter GetShapeRange(const WorldImpl& world) noexcept;

/// @brief Creates a shape within the specified world.
/// @throws WrongState if called while the world is "locked".
/// @relatedalso WorldImpl
ShapeID CreateShape(WorldImpl& world, const Shape& def);

/// @brief Gets the shape associated with the identifier.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso WorldImpl
const Shape& GetShape(const WorldImpl& world, ShapeID id);

/// @brief Sets the identified shape to the new value.
/// @throws std::out_of_range If given an invalid shape identifier.
/// @see CreateShape.
/// @relatedalso WorldImpl
void SetShape(WorldImpl& world, ShapeID id, const Shape& def);

/// @brief Destroys the identified shape.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid identifier.
/// @relatedalso WorldImpl
void Destroy(WorldImpl& world, ShapeID id);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDIMPLSHAPE_HPP

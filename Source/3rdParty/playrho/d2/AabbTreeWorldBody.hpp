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

#ifndef PLAYRHO_D2_AABBTREEWORLDBODY_HPP
#define PLAYRHO_D2_AABBTREEWORLDBODY_HPP

/// @file
/// @brief Declarations of free functions of AabbTreeWorld for bodies.

#include <vector>

#include "playrho/BodyID.hpp"
#include "playrho/ShapeID.hpp"

namespace playrho::d2 {

class AabbTreeWorld;
struct BodyConf;

/// @brief Creates a body within the world that's a copy of the given one.
/// @relatedalso AabbTreeWorld
BodyID CreateBody(AabbTreeWorld& world, const BodyConf& def);

/// @brief Associates a validly identified shape with the validly identified body.
/// @throws std::out_of_range If given an invalid body or shape identifier.
/// @throws WrongState if this function is called while the world is locked.
/// @see GetShapes.
/// @relatedalso AabbTreeWorld
void Attach(AabbTreeWorld& world, BodyID id, ShapeID shapeID);

/// @brief Disassociates a validly identified shape from the validly identified body.
/// @throws std::out_of_range If given an invalid body or shape identifier.
/// @throws WrongState if this function is called while the world is locked.
/// @relatedalso AabbTreeWorld
bool Detach(AabbTreeWorld& world, BodyID id, ShapeID shapeID);

/// @brief Disassociates all of the associated shape from the validly identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @throws WrongState if this function is called while the world is locked.
/// @relatedalso AabbTreeWorld
const std::vector<ShapeID>& GetShapes(const AabbTreeWorld& world, BodyID id);

} // namespace playrho::d2

#endif // PLAYRHO_D2_AABBTREEWORLDBODY_HPP

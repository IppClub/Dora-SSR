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

#include "playrho/d2/Shape.hpp"

namespace playrho {
namespace d2 {

// Confirm that a Shape itself isn't a valid shape type in the sense of preventing what could
// otherwise be an infinitely recursive configuration. Note that this doesn't prevent copy/move
// construction nor copy/move assignment.
static_assert(!detail::IsValidShapeTypeV<Shape>);

bool TestPoint(const Shape& shape, const Length2& point) noexcept
{
    const auto childCount = GetChildCount(shape);
    for (auto i = decltype(childCount){0}; i < childCount; ++i) {
        if (playrho::d2::TestPoint(GetChild(shape, i), point)) {
            return true;
        }
    }
    return false;
}

} // namespace d2
} // namespace playrho

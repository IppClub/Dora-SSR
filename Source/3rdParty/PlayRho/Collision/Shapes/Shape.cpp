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

#include "PlayRho/Collision/Shapes/Shape.hpp"
#include "PlayRho/Collision/Shapes/ShapeConf.hpp"

namespace playrho {
namespace d2 {

int Shape::m_shapeTypeIndex = 0;

namespace {

struct DefaultShapeConf
{
};

ChildCounter GetChildCount(const DefaultShapeConf&) noexcept
{
    return 0;
}

DistanceProxy GetChild(const DefaultShapeConf&, ChildCounter)
{
    throw InvalidArgument("index out of range");
}

MassData GetMassData(const DefaultShapeConf&) noexcept
{
    return MassData{};
}

Real GetFriction(const DefaultShapeConf&) noexcept
{
    return Real{0};
}

Real GetRestitution(const DefaultShapeConf&) noexcept
{
    return Real{0};
}

void Transform(DefaultShapeConf&, const Mat22&) noexcept
{
    // Intentionally empty.
}

NonNegative<AreaDensity> GetDensity(const DefaultShapeConf&) noexcept
{
    return NonNegative<AreaDensity>{0_kgpm2};
}

NonNegative<Length> GetVertexRadius(const DefaultShapeConf&, ChildCounter)
{
    throw InvalidArgument("index out of range");
}

constexpr bool operator== (const DefaultShapeConf&, const DefaultShapeConf&) noexcept
{
    return true;
}

} // annonymous namespace

Shape::Shape(): m_self{std::make_shared<Model<DefaultShapeConf>>(DefaultShapeConf{})}
{
    // Intentionally empty.
}

bool TestPoint(const Shape& shape, Length2 point) noexcept
{
    const auto childCount = GetChildCount(shape);
    for (auto i = decltype(childCount){0}; i < childCount; ++i)
    {
        if (playrho::d2::TestPoint(GetChild(shape, i), point))
        {
            return true;
        }
    }
    return false;
}

} // namespace d2
} // namespace playrho

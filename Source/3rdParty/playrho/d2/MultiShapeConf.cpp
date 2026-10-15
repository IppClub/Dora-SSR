/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include <algorithm>
#include <iterator>

#include "playrho/d2/MultiShapeConf.hpp"
#include "playrho/d2/Shape.hpp"
#include "playrho/d2/VertexSet.hpp"

namespace playrho::d2 {

static_assert(detail::IsValidShapeTypeV<MultiShapeConf>);

/// Computes the mass properties of this shape using its dimensions and density.
/// The inertia tensor is computed about the local origin.
/// @return Mass data for this shape.
MassData GetMassData(const MultiShapeConf& arg)
{
    auto mass = 0_kg;
    const auto origin = Length2{};
    auto weightedCenter = origin * Kilogram;
    auto I = RotInertia{};
    const auto density = arg.density;

    std::for_each(begin(arg.children), end(arg.children), [&](const ConvexHull& ch) {
        const auto dp = ch.GetDistanceProxy();
        const auto md = playrho::d2::GetMassData(
            ch.GetVertexRadius(), density,
            Span<const Length2>(begin(dp.GetVertices()), dp.GetVertexCount()));
        mass += Mass{md.mass};
        weightedCenter += md.center * Mass{md.mass};
        I += RotInertia{md.I};
    });

    const auto center = (mass > 0_kg) ? weightedCenter / mass : origin;
    return MassData{center, mass, I};
}

MultiShapeConf& MultiShapeConf::AddConvexHull(const VertexSet& pointSet,
                                              NonNegative<Length> vertexRadius)
{
    children.emplace_back(ConvexHull::Get(pointSet, vertexRadius));
    return *this;
}

MultiShapeConf& MultiShapeConf::Translate(const Length2& value)
{
    std::for_each(begin(children), end(children),
                  [&value](ConvexHull& child) { child.Translate(value); });
    return *this;
}

MultiShapeConf& MultiShapeConf::Scale(const Vec2& value)
{
    std::for_each(begin(children), end(children),
                  [&value](ConvexHull& child) { child.Scale(value); });
    return *this;
}

MultiShapeConf& MultiShapeConf::Rotate(const UnitVec& value)
{
    std::for_each(begin(children), end(children),
                  [&value](ConvexHull& child) { child.Rotate(value); });
    return *this;
}

} // namespace playrho::d2

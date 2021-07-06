/*
 * Copyright (c) 2021 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Collision/Shapes/MultiShapeConf.hpp"

#include "PlayRho/Collision/Shapes/Shape.hpp"
#include "PlayRho/Common/VertexSet.hpp"

#include <algorithm>
#include <iterator>

namespace playrho {
namespace d2 {

static_assert(IsValidShapeType<MultiShapeConf>::value);

/// Computes the mass properties of this shape using its dimensions and density.
/// The inertia tensor is computed about the local origin.
/// @return Mass data for this shape.
MassData GetMassData(const MultiShapeConf& arg) noexcept
{
    auto mass = 0_kg;
    const auto origin = Length2{};
    auto weightedCenter = origin * Kilogram;
    auto I = RotInertia{0};
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

ConvexHull ConvexHull::Get(const VertexSet& pointSet, NonNegative<Length> vertexRadius)
{
    auto vertices = GetConvexHullAsVector(pointSet);
    assert(!empty(vertices) && size(vertices) < std::numeric_limits<VertexCounter>::max());

    const auto count = static_cast<VertexCounter>(size(vertices));

    auto normals = std::vector<UnitVec>();
    if (count > 1) {
        // Compute normals.
        for (auto i = decltype(count){0}; i < count; ++i) {
            const auto nextIndex = GetModuloNext(i, count);
            const auto edge = vertices[nextIndex] - vertices[i];
            normals.push_back(GetUnitVector(GetFwdPerpendicular(edge)));
        }
    }
    else if (count == 1) {
        normals.push_back(UnitVec{});
    }

    return ConvexHull{vertices, normals, vertexRadius};
}

ConvexHull& ConvexHull::Translate(const Length2& value) noexcept
{
    auto newPoints = VertexSet{};
    for (const auto& v : vertices) {
        newPoints.add(v + value);
    }
    *this = Get(newPoints, vertexRadius);
    return *this;
}

ConvexHull& ConvexHull::Scale(const Vec2& value) noexcept
{
    auto newPoints = VertexSet{};
    for (const auto& v : vertices) {
        newPoints.add(Length2{GetX(v) * GetX(value), GetY(v) * GetY(value)});
    }
    *this = Get(newPoints, vertexRadius);
    return *this;
}

ConvexHull& ConvexHull::Rotate(const UnitVec& value) noexcept
{
    auto newPoints = VertexSet{};
    for (const auto& v : vertices) {
        newPoints.add(::playrho::d2::Rotate(v, value));
    }
    *this = Get(newPoints, vertexRadius);
    return *this;
}

MultiShapeConf& MultiShapeConf::AddConvexHull(const VertexSet& pointSet,
                                              NonNegative<Length> vertexRadius) noexcept
{
    children.emplace_back(ConvexHull::Get(pointSet, vertexRadius));
    return *this;
}

MultiShapeConf& MultiShapeConf::Translate(const Length2& value) noexcept
{
    std::for_each(begin(children), end(children),
                  [&value](ConvexHull& child) { child.Translate(value); });
    return *this;
}

MultiShapeConf& MultiShapeConf::Scale(const Vec2& value) noexcept
{
    std::for_each(begin(children), end(children),
                  [&value](ConvexHull& child) { child.Scale(value); });
    return *this;
}

MultiShapeConf& MultiShapeConf::Rotate(const UnitVec& value) noexcept
{
    std::for_each(begin(children), end(children),
                  [&value](ConvexHull& child) { child.Rotate(value); });
    return *this;
}

} // namespace d2
} // namespace playrho

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

#include "playrho/d2/PolygonShapeConf.hpp"
#include "playrho/d2/Shape.hpp"
#include "playrho/d2/VertexSet.hpp"

namespace playrho::d2 {

static_assert(detail::IsValidShapeTypeV<PolygonShapeConf>);

PolygonShapeConf::PolygonShapeConf() noexcept = default;

PolygonShapeConf::PolygonShapeConf(Length hx, Length hy, const PolygonShapeConf& conf)
    : ShapeBuilder{conf}
{
    SetAsBox(hx, hy);
}

PolygonShapeConf::PolygonShapeConf(Span<const Length2> points,
                                   const PolygonShapeConf& conf)
    : ShapeBuilder{conf}
{
    Set(points);
}

PolygonShapeConf& PolygonShapeConf::SetAsBox(Length hx, Length hy)
{
    // vertices must be counter-clockwise
    auto vertices = std::vector<Length2>{
        {+hx, -hy}, // bottom right
        {+hx, +hy}, // top right}
        {-hx, +hy}, // top left
        {-hx, -hy} // bottom left
    };
    ngon = NgonWithFwdNormals<>{std::move(vertices)};
    return *this;
}

PolygonShapeConf& PolygonShapeConf::UseVertices(const Span<const Length2>& verts)
{
    return Set(verts);
}

PolygonShapeConf& PolygonShapeConf::SetAsBox(Length hx, Length hy, const Length2& center,
                                             Angle angle)
{
    SetAsBox(hx, hy);
    Transform(Transformation{center, UnitVec::Get(angle)});
    return *this;
}

PolygonShapeConf& PolygonShapeConf::Transform(const Transformation& xfm)
{
    auto vertices = ngon.GetVertices();
    for (auto&& vertex: vertices) {
        vertex = playrho::d2::Transform(vertex, xfm);
    }
    ngon = NgonWithFwdNormals<>{std::move(vertices)};
    return *this;
}

PolygonShapeConf& PolygonShapeConf::Transform(const Mat22& m)
{
    auto newPoints = VertexSet{};
    for (const auto& v : ngon.GetVertices()) {
        newPoints.add(m * v);
    }
    return Set(newPoints);
}

PolygonShapeConf& PolygonShapeConf::Translate(const Length2& value)
{
    auto newPoints = VertexSet{};
    for (const auto& v : ngon.GetVertices()) {
        newPoints.add(v + value);
    }
    return Set(newPoints);
}

PolygonShapeConf& PolygonShapeConf::Scale(const Vec2& value)
{
    auto newPoints = VertexSet{};
    for (const auto& v : ngon.GetVertices()) {
        newPoints.add(Length2{GetX(v) * GetX(value), GetY(v) * GetY(value)});
    }
    return Set(newPoints);
}

PolygonShapeConf& PolygonShapeConf::Rotate(const UnitVec& value)
{
    auto newPoints = VertexSet{};
    for (const auto& v : ngon.GetVertices()) {
        newPoints.add(::playrho::d2::Rotate(v, value));
    }
    return Set(newPoints);
}

PolygonShapeConf& PolygonShapeConf::Set(Span<const Length2> points)
{
    // Perform welding and copy vertices into local buffer.
    auto point_set = VertexSet(Square(DefaultLinearSlop));
    for (auto&& p : points) {
        point_set.add(p);
    }
    return Set(point_set);
}

PolygonShapeConf& PolygonShapeConf::Set(const VertexSet& points)
{
    // Provide strong exception guarantee!
    auto vertices = GetConvexHullAsVector(points);
    assert(size(vertices) < std::numeric_limits<VertexCounter>::max());
    ngon = NgonWithFwdNormals<>{std::move(vertices)};
    return *this;
}

bool Validate(const Span<const Length2>& verts)
{
    const auto count = size(verts);
    for (auto i = decltype(count){0}; i < count; ++i) {
        const auto i1 = i;
        const auto i2 = GetModuloNext(i1, count);
        const auto& p = verts[i1];
        const auto e = verts[i2] - p;
        for (auto j = decltype(count){0}; j < count; ++j) {
            if ((j == i1) || (j == i2)) {
                continue;
            }
            const auto v = verts[j] - p;
            const auto c = Cross(e, v);
            if (c < 0_m2) {
                return false;
            }
        }
    }
    return true;
}

} // namespace playrho::d2

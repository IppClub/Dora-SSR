/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include "PlayRho/Collision/Shapes/PolygonShapeConf.hpp"
#include "PlayRho/Common/VertexSet.hpp"

namespace playrho {
namespace d2 {

PolygonShapeConf::PolygonShapeConf() = default;

PolygonShapeConf::PolygonShapeConf(Length hx, Length hy,
                                   const PolygonShapeConf& conf) noexcept:
    ShapeBuilder{conf}
{
    SetAsBox(hx, hy);
}

PolygonShapeConf::PolygonShapeConf(Span<const Length2> points,
                                   const PolygonShapeConf& conf) noexcept:
    ShapeBuilder{conf}
{
    Set(points);
}

PolygonShapeConf& PolygonShapeConf::SetAsBox(Length hx, Length hy) noexcept
{
    m_centroid = Length2{};

    // vertices must be counter-clockwise

    const auto btm_rgt = Length2{+hx, -hy};
    const auto top_rgt = Length2{ hx,  hy};
    const auto top_lft = Length2{-hx, +hy};
    const auto btm_lft = Length2{-hx, -hy};
    
    m_vertices.clear();
    m_vertices.emplace_back(btm_rgt);
    m_vertices.emplace_back(top_rgt);
    m_vertices.emplace_back(top_lft);
    m_vertices.emplace_back(btm_lft);

    m_normals.clear();
    m_normals.emplace_back(UnitVec::GetRight());
    m_normals.emplace_back(UnitVec::GetTop());
    m_normals.emplace_back(UnitVec::GetLeft());
    m_normals.emplace_back(UnitVec::GetBottom());
    
    return *this;
}

/// @brief Uses the given vertices.
PolygonShapeConf& PolygonShapeConf::UseVertices(const std::vector<Length2>& verts) noexcept
{
    return Set(Span<const Length2>(data(verts), size(verts)));
}
    
PolygonShapeConf& PolygonShapeConf::SetAsBox(Length hx, Length hy,
                                                 Length2 center, Angle angle) noexcept
{
    SetAsBox(hx, hy);
    Transform(Transformation{center, UnitVec::Get(angle)});
    return *this;
}

PolygonShapeConf& PolygonShapeConf::Transform(Transformation xfm) noexcept
{
    for (auto i = decltype(GetVertexCount()){0}; i < GetVertexCount(); ++i)
    {
        m_vertices[i] = playrho::d2::Transform(m_vertices[i], xfm);
        m_normals[i] = Rotate(m_normals[i], xfm.q);
    }
    m_centroid = playrho::d2::Transform(m_centroid, xfm);
    return *this;
}

PolygonShapeConf& PolygonShapeConf::Transform(const Mat22& m) noexcept
{
    auto newPoints = VertexSet{};
    // clang++ recommends the following loop variable 'v' be of reference type (instead of value).
    for (const auto& v: m_vertices)
    {
        newPoints.add(m * v);
    }
    return Set(newPoints);
}

PolygonShapeConf& PolygonShapeConf::Set(Span<const Length2> points) noexcept
{
    // Perform welding and copy vertices into local buffer.
    auto point_set = VertexSet(Square(DefaultLinearSlop));
    for (auto&& p: points)
    {
        point_set.add(p);
    }
    return Set(point_set);
}

PolygonShapeConf& PolygonShapeConf::Set(const VertexSet& points) noexcept
{
    m_vertices = GetConvexHullAsVector(points);
    assert(size(m_vertices) < std::numeric_limits<VertexCounter>::max());
    
    const auto count = static_cast<VertexCounter>(size(m_vertices));

    m_normals.clear();
    if (count > 1)
    {
        // Compute normals.
        for (auto i = decltype(count){0}; i < count; ++i)
        {
            const auto edge = GetEdge(*this, i);
            m_normals.emplace_back(GetUnitVector(GetFwdPerpendicular(edge)));
        }
    }
    else if (count == 1)
    {
        m_normals.emplace_back(UnitVec{});
    }

    // Compute the polygon centroid.
    switch (count)
    {
        case 0:
            m_centroid = GetInvalid<Length2>();
            break;
        case 1:
            m_centroid = m_vertices[0];
            break;
        case 2:
            m_centroid = (m_vertices[0] + m_vertices[1]) / Real{2};
            break;
        default:
            m_centroid = ComputeCentroid(GetVertices());
            break;
    }
    
    return *this;
}

Length2 GetEdge(const PolygonShapeConf& shape, VertexCounter index)
{
    assert(shape.GetVertexCount() > 1);

    const auto i0 = index;
    const auto i1 = GetModuloNext(index, shape.GetVertexCount());
    return shape.GetVertex(i1) - shape.GetVertex(i0);
}

bool Validate(Span<const Length2> verts)
{
    const auto count = size(verts);
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        const auto i1 = i;
        const auto i2 = GetModuloNext(i1, count);
        const auto p = verts[i1];
        const auto e = verts[i2] - p;
        for (auto j = decltype(count){0}; j < count; ++j)
        {
            if ((j == i1) || (j == i2))
            {
                continue;
            }
            const auto v = verts[j] - p;
            const auto c = Cross(e, v);
            if (c < 0_m2)
            {
                return false;
            }
        }
    }
    return true;
}

} // namespace d2
} // namespace playrho

/*
 * Original work Copyright (c) 2007-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_SIMPLEXEDGE_HPP
#define PLAYRHO_D2_SIMPLEXEDGE_HPP

/// @file
/// @brief Definition of the @c SimplexEdge class and closely related code.

// IWYU pragma: begin_exports

#include "playrho/d2/IndexPair.hpp"
#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Simplex edge.
/// @details This is the locations (in world coordinates) and indices of a pair of vertices
/// from two shapes (shape A and shape B).
class SimplexEdge
{
public:
    /// @brief Default constructor.
    SimplexEdge() = default;
    
    /// @brief Initializing constructor.
    /// @param pA Point A in world coordinates.
    /// @param iA Index of point A within the shape that it comes from.
    /// @param pB Point B in world coordinates.
    /// @param iB Index of point B within the shape that it comes from.
    constexpr SimplexEdge(const Length2& pA, VertexCounter iA, // force line-break
                          const Length2& pB, VertexCounter iB) noexcept;
    
    /// @brief Gets point A (in world coordinates).
    constexpr auto GetPointA() const noexcept { return m_wA; }
    
    /// @brief Gets point B (in world coordinates).
    constexpr auto GetPointB() const noexcept { return m_wB; }

    /// @brief Gets index A.
    constexpr auto GetIndexA() const noexcept { return std::get<0>(m_indexPair); }
    
    /// @brief Gets index B.
    constexpr auto GetIndexB() const noexcept { return std::get<1>(m_indexPair); }

    /// @brief Gets the index pair.
    constexpr auto GetIndexPair() const noexcept { return m_indexPair; }

private:
    Length2 m_wA{}; ///< Point A in world coordinates. This is the support point in proxy A.
    Length2 m_wB{}; ///< Point B in world coordinates. This is the support point in proxy B.
    IndexPair m_indexPair{}; ///< Index pair. @details Indices of points A and B.
};

constexpr SimplexEdge::SimplexEdge(const Length2& pA, VertexCounter iA, // force line-break
                                   const Length2& pB, VertexCounter iB) noexcept:
    m_wA{pA}, m_wB{pB}, m_indexPair{iA, iB}
{
    // Intentionally empty.
}

/// @brief Gets "w".
/// @return 2-dimensional vector value of the simplex edge's point B minus its point A.
constexpr Length2 GetPointDelta(const SimplexEdge& sv) noexcept
{
    return sv.GetPointB() - sv.GetPointA();
}

/// @brief Equality operator for <code>SimplexEdge</code>.
constexpr bool operator== (const SimplexEdge& lhs, const SimplexEdge& rhs) noexcept
{
    return (lhs.GetPointA() == rhs.GetPointA())
        && (lhs.GetPointB() == rhs.GetPointB())
        && (lhs.GetIndexPair() == rhs.GetIndexPair());
}

/// @brief Inequality operator for <code>SimplexEdge</code>.
constexpr bool operator!= (const SimplexEdge& lhs, const SimplexEdge& rhs) noexcept
{
    return !(lhs == rhs);
}

} // namespace playrho::d2

#endif // PLAYRHO_D2_SIMPLEXEDGE_HPP

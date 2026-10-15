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

#ifndef PLAYRHO_D2_SIMPLEX_HPP
#define PLAYRHO_D2_SIMPLEX_HPP

/// @file
/// @brief Definition of the @c Simplex class and closely related code.

#ifndef NDEBUG
#include <numeric> // for std::accumulate
#endif

#include <cassert> // for assert
#include <type_traits> // for std::remove_const_t

// IWYU pragma: begin_exports

#ifndef NDEBUG
#include "playrho/Math.hpp" // for AlmostEqual
#include "playrho/detail/Templates.hpp"
#endif

#include "playrho/ArrayList.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/d2/IndexPair.hpp"
#include "playrho/d2/SimplexEdge.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Simplex edge collection.
using SimplexEdges =
    ArrayList<SimplexEdge, MaxSimplexEdges, std::remove_const_t<decltype(MaxSimplexEdges)>>;

/// @brief Gets index pairs for the given edges collection.
IndexPair3 GetIndexPairs(const SimplexEdges& collection) noexcept;

/// @brief Calculates the "search direction" for the given simplex edge list.
/// @param simplexEdges A one or two edge list.
/// @warning Behavior is not specified if the given edge list has zero edges.
/// @return "search direction" vector.
Length2 CalcSearchDirection(const SimplexEdges& simplexEdges) noexcept;

/// @brief An encapsulation of a point, line segment, or triangle.
/// @details An encapsulation of a point, line segment, or triangle.
///   These are defined respectively as: a 0-simplex, a 1-simplex, and a 2-simplex.
///   Used in doing G.J.K. (GJK) collision detection.
/// @invariant Vertex's for the same index must have the same point locations.
/// @invariant There may not be more than one entry for the same index pair.
/// @see https://en.wikipedia.org/wiki/Simplex
/// @see https://en.wikipedia.org/wiki/Gilbert%2DJohnson%2DKeerthi_distance_algorithm
class Simplex
{
public:
    /// @brief Size type.
    using size_type = SimplexEdges::size_type;

    /// @brief Coefficients.
    /// @details Collection of coefficient values.
    using Coefficients =
        ArrayList<Real, MaxSimplexEdges, std::remove_const_t<decltype(MaxSimplexEdges)>>;

    /// @brief Simplex cache.
    /// @details Used to warm start Distance. Caches particular information from a simplex:
    ///   a related metric and up-to 3 index pairs.
    struct Cache {
        /// @brief Metric.
        /// @details Metric based on a length or area value of edges.
        Real metric = Invalid<Real>;

        /// @brief Indices.
        /// @details Collection of index-pairs.
        IndexPair3 indices = InvalidIndexPair3;
    };

    /// @brief Gets the cache value for the given edges.
    static Cache GetCache(const SimplexEdges& edges) noexcept;

    /// @brief Gets the given simplex's "metric".
    static Real CalcMetric(const SimplexEdges& simplexEdges);

    /// @brief Gets the Simplex for the given simplex edge.
    static Simplex Get(const SimplexEdge& s0) noexcept;

    /// @brief Gets the simplex for the given 2 edges.
    /// @note The given simplex vertices must have different index pairs or be of the same values.
    /// @warning Behavior is not specified if the given simplex edges index pairs are the same
    ///    and the whole edges values are not also the same.
    /// @param s0 Simplex edge 0.
    /// @param s1 Simplex edge 1.
    /// @result One or two edge simplex.
    static Simplex Get(const SimplexEdge& s0, const SimplexEdge& s1) noexcept;

    /// @brief Gets the simplex for the given 3 edges.
    /// @result One, two, or three edge simplex.
    static Simplex Get(const SimplexEdge& s0, const SimplexEdge& s1,
                       const SimplexEdge& s2) noexcept;

    /// @brief Gets the simplex for the given collection of vertices.
    /// @param edges Collection of zero, one, two, or three simplex edges.
    /// @return Zero, one, two, or three edge simplex.
    static Simplex Get(const SimplexEdges& edges) noexcept;

    Simplex() = default;

    /// @brief Gets the edges.
    constexpr SimplexEdges GetEdges() const noexcept;

    /// @brief Gets the give indexed simplex edge.
    const SimplexEdge& GetSimplexEdge(size_type index) const noexcept;

    /// @brief Gets the coefficient for the given index.
    constexpr Real GetCoefficient(size_type index) const noexcept;

    /// @brief Gets the size in number of simplex edges that this instance is made up of.
    constexpr size_type size() const noexcept;

private:
    /// @brief Initializing constructor.
    /// @pre Sizes of @p simplexEdges and @p normalizedWeights are the same.
    Simplex(const SimplexEdges& simplexEdges, const Coefficients& normalizedWeights) noexcept;

    /// Collection of valid simplex edges.
    SimplexEdges m_simplexEdges;

    /// @brief Normalized weights.
    /// @details Collection of coefficients (ranging from greater than 0 to less than 1).
    /// A.k.a.: barycentric coordinates.
    Coefficients m_normalizedWeights;
};

inline Simplex::Cache Simplex::GetCache(const SimplexEdges& edges) noexcept
{
    return Simplex::Cache{Simplex::CalcMetric(edges), GetIndexPairs(edges)};
}

inline Simplex::Simplex(const SimplexEdges& simplexEdges,
                        const Coefficients& normalizedWeights) noexcept
    : m_simplexEdges{simplexEdges}, m_normalizedWeights{normalizedWeights}
{
    assert(simplexEdges.size() == normalizedWeights.size());
    assert(AlmostEqual(Real{1}, std::accumulate(begin(normalizedWeights),
                                                end(normalizedWeights), Real(0)), 3));
}

constexpr SimplexEdges Simplex::GetEdges() const noexcept
{
    return m_simplexEdges;
}

const inline SimplexEdge& Simplex::GetSimplexEdge(size_type index) const noexcept
{
    return m_simplexEdges[index];
}

constexpr Real Simplex::GetCoefficient(size_type index) const noexcept
{
    return m_normalizedWeights[index];
}

/// @brief Gets the size in number of valid edges of this Simplex.
/// @return Value between 0 and <code>MaxEdges</code> (inclusive).
constexpr Simplex::size_type Simplex::size() const noexcept
{
    return m_simplexEdges.size();
}

/// @brief Gets the scaled delta for the given indexed element of the given simplex.
inline Length2 GetScaledDelta(const Simplex& simplex, Simplex::size_type index)
{
    return GetPointDelta(simplex.GetSimplexEdge(index)) * simplex.GetCoefficient(index);
}

/// @brief Gets the "closest point".
constexpr Length2 GetClosestPoint(const Simplex& simplex)
{
    switch (simplex.size()) {
    case 1:
        return GetScaledDelta(simplex, 0);
    case 2:
        return GetScaledDelta(simplex, 0) + GetScaledDelta(simplex, 1);
    case 3:
        return Length2{0_m, 0_m};
    default:
        return Length2{0_m, 0_m};
    }
}

} // namespace playrho::d2

#endif // PLAYRHO_D2_SIMPLEX_HPP

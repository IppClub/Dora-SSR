/*
 * Original work Copyright (c) 2007-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_COLLISION_SIMPLEX_HPP
#define PLAYRHO_COLLISION_SIMPLEX_HPP

#include "PlayRho/Common/ArrayList.hpp"
#include "PlayRho/Common/Vector.hpp"
#include "PlayRho/Collision/SimplexEdge.hpp"
#include <array>

namespace playrho {
namespace d2 {

    /// @brief Simplex edge collection.
    /// @note This data is 20 * 3 + 4 = 64-bytes large (on at least one 64-bit platform).
    using SimplexEdges = ArrayList<SimplexEdge, MaxSimplexEdges,
        std::remove_const<decltype(MaxSimplexEdges)>::type>;
    
    /// @brief Gets index pairs for the given edges collection.
    IndexPair3 GetIndexPairs(const SimplexEdges& collection) noexcept;
    
    /// @brief Calculates the "search direction" for the given simplex edge list.
    /// @param simplexEdges A one or two edge list.
    /// @warning Behavior is undefined if the given edge list has zero edges.
    /// @return "search direction" vector.
    Length2 CalcSearchDirection(const SimplexEdges& simplexEdges) noexcept;

    /// @brief An encapsulation of a point, line segment, or triangle.
    ///
    /// @details An encapsulation of a point, line segment, or triangle.
    ///   These are defined respectively as: a 0-simplex, a 1-simplex, and a 2-simplex.
    ///   Used in doing G.J.K. collision detection.
    ///
    /// @note This data structure is 104-bytes large.
    ///
    /// @invariant Vertex's for the same index must have the same point locations.
    /// @invariant There may not be more than one entry for the same index pair.
    ///
    /// @sa https://en.wikipedia.org/wiki/Simplex
    /// @sa https://en.wikipedia.org/wiki/Gilbert%2DJohnson%2DKeerthi_distance_algorithm
    ///
    class Simplex
    {
    public:

        /// Size type.
        ///
        /// @note This data type is explicitly set to 1-byte large.
        using size_type = SimplexEdges::size_type;

        /// Coefficients.
        ///
        /// @details Collection of coefficient values.
        ///
        /// @note This data structure is 4 * 3 + 4 = 16-bytes large.
        ///
        using Coefficients = ArrayList<Real, MaxSimplexEdges,
            std::remove_const<decltype(MaxSimplexEdges)>::type>;
        
        /// @brief Simplex cache.
        /// @details Used to warm start Distance. Caches particular information from a simplex:
        ///   a related metric and up-to 3 index pairs.
        /// @note This data structure is 12-bytes large.
        struct Cache
        {
            /// @brief Metric.
            /// @details Metric based on a length or area value of edges.
            Real metric = GetInvalid<Real>();

            /// @brief Indices.
            /// @details Collection of index-pairs.
            IndexPair3 indices = InvalidIndexPair3;
        };
        
        /// @brief Gets the cache value for the given edges.
        static Cache GetCache(const SimplexEdges& edges) noexcept;
        
        /// Gets the given simplex's "metric".
        static Real CalcMetric(const SimplexEdges& simplexEdges);

        /// @brief Gets the Simplex for the given simplex edge.
        static Simplex Get(const SimplexEdge& s0) noexcept;

        /// Gets the simplex for the given 2 edges.
        ///
        /// @note The given simplex vertices must have different index pairs or be of the same values.
        /// @warning Behavior is undefined if the given simplex edges index pairs are the same
        ///    and the whole edges values are not also the same.
        ///
        /// @param s0 Simplex edge 0.
        /// @param s1 Simplex edge 1.
        ///
        /// @result One or two edge simplex.
        ///
        static Simplex Get(const SimplexEdge& s0, const SimplexEdge& s1) noexcept;
        
        /// Gets the simplex for the given 3 edges.
        ///
        /// @result One, two, or three edge simplex.
        ///
        static Simplex Get(const SimplexEdge& s0, const SimplexEdge& s1, const SimplexEdge& s2) noexcept;
        
        /// Gets the simplex for the given collection of vertices.
        /// @param edges Collection of zero, one, two, or three simplex edges.
        /// @warning Behavior is undefined if the given collection has more than 3 edges.
        /// @return Zero, one, two, or three edge simplex.
        static Simplex Get(const SimplexEdges& edges) noexcept;

        Simplex() = default;

        /// @brief Gets the edges.
        PLAYRHO_CONSTEXPR inline SimplexEdges GetEdges() const noexcept;

        /// @brief Gets the give indexed simplex edge.
        const SimplexEdge& GetSimplexEdge(size_type index) const noexcept;

        /// @brief Gets the coefficient for the given index.
        PLAYRHO_CONSTEXPR inline Real GetCoefficient(size_type index) const noexcept;

        /// @brief Gets the size in number of simplex edges that this instance is made up of.
        PLAYRHO_CONSTEXPR inline size_type size() const noexcept;

    private:
        
        /// @brief Initializing constructor.
        Simplex(const SimplexEdges& simplexEdges, const Coefficients& normalizedWeights) noexcept;

        /// Collection of valid simplex edges.
        ///
        /// @note This member variable is 88-bytes.
        ///
        SimplexEdges m_simplexEdges;

        /// Normalized weights.
        ///
        /// @details Collection of coefficients (ranging from greater than 0 to less than 1).
        /// A.k.a.: barycentric coordinates.
        ///
        /// @note This member variable is 16-bytes.
        ///
        Coefficients m_normalizedWeights;
    };

    inline Simplex::Cache Simplex::GetCache(const SimplexEdges& edges) noexcept
    {
        return Simplex::Cache{Simplex::CalcMetric(edges), GetIndexPairs(edges)};
    }

    inline Simplex::Simplex(const SimplexEdges& simplexEdges,
                            const Coefficients& normalizedWeights) noexcept:
        m_simplexEdges{simplexEdges}, m_normalizedWeights{normalizedWeights}
    {
        assert(simplexEdges.size() == normalizedWeights.size());
#ifndef NDEBUG
        const auto sum = std::accumulate(begin(normalizedWeights), end(normalizedWeights),
                                         Real{0});
        assert(AlmostEqual(Real{1}, sum));
#endif
    }

    PLAYRHO_CONSTEXPR inline SimplexEdges Simplex::GetEdges() const noexcept
    {
        return m_simplexEdges;
    }
    
    const inline SimplexEdge& Simplex::GetSimplexEdge(size_type index) const noexcept
    {
        return m_simplexEdges[index];
    }
    
    PLAYRHO_CONSTEXPR inline Real Simplex::GetCoefficient(size_type index) const noexcept
    {
        return m_normalizedWeights[index];
    }
    
    /// @brief Gets the size in number of valid edges of this Simplex.
    /// @return Value between 0 and <code>MaxEdges</code> (inclusive).
    PLAYRHO_CONSTEXPR inline Simplex::size_type Simplex::size() const noexcept
    {
        return m_simplexEdges.size();
    }

    /// @brief Gets the scaled delta for the given indexed element of the given simplex.
    inline Length2 GetScaledDelta(const Simplex& simplex, Simplex::size_type index)
    {
        return GetPointDelta(simplex.GetSimplexEdge(index)) * simplex.GetCoefficient(index);
    }

    /// Gets the "closest point".
    PLAYRHO_CONSTEXPR inline Length2 GetClosestPoint(const Simplex& simplex)
    {
        switch (simplex.size())
        {
            case 1: return GetScaledDelta(simplex, 0);
            case 2: return GetScaledDelta(simplex, 0) + GetScaledDelta(simplex, 1);
            case 3: return Length2{0_m, 0_m};
            default: return Length2{0_m, 0_m};
        }
    }

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SIMPLEX_HPP

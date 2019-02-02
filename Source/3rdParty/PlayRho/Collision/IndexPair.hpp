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

#ifndef PLAYRHO_COLLISION_INDEXPAIR_HPP
#define PLAYRHO_COLLISION_INDEXPAIR_HPP

#include "PlayRho/Common/Settings.hpp"
#include <array>
#include <utility>

namespace playrho {

/// @brief Index pair.
/// @note This data structure is at least 2-bytes large.
/// @note Using <code>std::array</code> would make more sense if it weren't for the
///   fact that <code>std::pair</code>, but not <code>std::array</code>, has
///   <code>constexpr</code> equality and inequality operators.
using IndexPair = std::pair<VertexCounter, VertexCounter>;

/// @brief Invalid index-pair value.
PLAYRHO_CONSTEXPR const auto InvalidIndexPair = IndexPair{
    InvalidVertex, InvalidVertex
};

/// @brief Array of three index-pair elements.
/// @note An element having the <code>InvalidIndexPair</code> value, denotes an
///   unused or invalid elements.
/// @note This data type is 6-bytes large (on at least one 64-bit platform).
using IndexPair3 = std::array<IndexPair, MaxSimplexEdges>;

/// @brief Invalid array of three index-pair elements.
PLAYRHO_CONSTEXPR const auto InvalidIndexPair3 = IndexPair3{{
    InvalidIndexPair, InvalidIndexPair, InvalidIndexPair
}};

static_assert(MaxSimplexEdges == 3, "Invalid assumption about size of MaxSimplexEdges");

/// @brief Gets the number of valid indices in the given collection of index pairs.
/// @note Any element with a value of <code>InvalidIndexPair</code> is interpreted
///   as being invalid in this context.
/// @return Value between 0 and 3 inclusive.
PLAYRHO_CONSTEXPR inline std::size_t GetNumValidIndices(IndexPair3 pairs) noexcept
{
    return std::size_t{3}
    - ((std::get<0>(pairs) == InvalidIndexPair)? 1u: 0u)
    - ((std::get<1>(pairs) == InvalidIndexPair)? 1u: 0u)
    - ((std::get<2>(pairs) == InvalidIndexPair)? 1u: 0u);
}

/// @brief Checks whether the given collection of index pairs is empty.
PLAYRHO_CONSTEXPR inline bool empty(IndexPair3 pairs) noexcept
{
    return GetNumValidIndices(pairs) == 0;
}

/// @brief Gets the dynamic size of the given collection of index pairs.
/// @note This just calls <code>GetNumValidIndices</code>.
/// @sa GetNumValidIndices
PLAYRHO_CONSTEXPR inline auto size(IndexPair3 pairs) -> decltype(GetNumValidIndices(pairs))
{
    return GetNumValidIndices(pairs);
}

/// @brief Gets the maximum size of the given container of index pairs.
/// @return Always returns 3.
PLAYRHO_CONSTEXPR inline auto max_size(IndexPair3 pairs) -> decltype(pairs.max_size())
{
    return pairs.max_size();
}

/// @brief Vertex counter array template alias.
template <std::size_t N>
using VertexCounterArray = std::array<VertexCounter, N>;

/// @brief 2-element vertex counter array.
using VertexCounter2 = VertexCounterArray<2>;

namespace detail {

/// @brief Length and vertex counter array of indices.
template <std::size_t N>
struct LengthIndices
{
    Length distance; ///< Distance.
    VertexCounterArray<N> indices; ///< Array of vertex indices.
};

/// @brief Separation information.
template <std::size_t N>
struct SeparationInfo
{
    Length distance; ///< Distance.
    VertexCounter firstShape; ///< First shape vertex index.
    VertexCounterArray<N> secondShape; ///< Second shape vertex indices.
};

} // namespace detail

/// @brief Gets first shape vertex index.
template <std::size_t N>
VertexCounter GetFirstShapeVertexIdx(const detail::SeparationInfo<N>& info) noexcept
{
    return info.firstShape;
}

/// @brief Gets second shape vertex indices.
template <VertexCounter M, std::size_t N>
VertexCounter GetSecondShapeVertexIdx(const detail::SeparationInfo<N>& info) noexcept
{
    return std::get<M>(info.secondShape);
}

/// @brief A length associated with two vertex counter indices.
/// @details This structure is used to keep track of the best separating axis.
/// @note Any element can be invalid as indicated by the use of the invalid sentinel
///   for the type.
struct LengthIndexPair
{
    Length distance = GetInvalid<Length>(); ///< Separation.
    IndexPair indices = InvalidIndexPair; ///< Index pair.
};

namespace d2 {

/// @brief Length and vertex counter array of indices for 2-D space.
using LengthIndices = detail::LengthIndices<2>;

/// @brief Separation information alias for 2-D space.
using SeparationInfo = detail::SeparationInfo<2>;

} // namespace 2d
} // namespace playrho

#endif // PLAYRHO_COLLISION_INDEXPAIR_HPP

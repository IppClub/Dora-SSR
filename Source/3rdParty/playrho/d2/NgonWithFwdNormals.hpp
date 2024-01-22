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

#ifndef PLAYRHO_D2_NGON_HPP
#define PLAYRHO_D2_NGON_HPP

/// @file
/// @brief Definition of the @c NgonWithFwdNormals class template and closely related code.

#include <array>
#include <cstddef> // for std::size_t
#include <type_traits>
#include <utility> // for std::index_sequence
#include <vector>

// IWYU pragma: begin_exports

#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Gets forward normals for the given vertices.
template <class T, T... ints>
std::array<UnitVec, sizeof...(ints)>
GetFwdNormalsArray(const std::array<Length2, sizeof...(ints)>& vertices,
                   std::integer_sequence<T, ints...> int_seq)
{
    constexpr auto count = int_seq.size();
    return {GetUnitVector(GetFwdPerpendicular(vertices[GetModuloNext(ints, count)] - vertices[ints]))...};
}

/// @brief Gets forward normals for the given vertices.
template <std::size_t N>
std::array<UnitVec, N> GetFwdNormalsArray(const std::array<Length2, N>& vertices)
{
    return GetFwdNormalsArray(vertices, std::make_index_sequence<N>{});
}

/// @brief N-gon of vertices with counter-clockwise "forward" normals.
/// @invariant The normals provided are always the forward normals of the assigned vertices.
template <std::size_t N = static_cast<std::size_t>(-1)>
class NgonWithFwdNormals {
    std::array<Length2, N> m_vertices{}; ///< Vertices
    std::array<UnitVec, N> m_normals{}; ///< Normals.
public:
    /// @brief Default constructor.
    constexpr NgonWithFwdNormals() noexcept = default;

    /// @brief Initializing constructor.
    constexpr NgonWithFwdNormals(const std::array<Length2, N>& vertices)
        : m_vertices{vertices}, m_normals{GetFwdNormalsArray(vertices)}
    {
        // Intentionally empty.
    }

    /// @brief Gets the vertices of this N-gon.
    constexpr auto GetVertices() const noexcept -> decltype((m_vertices))
    {
        return m_vertices;
    }

    /// @brief Gets the normals of this N-gon.
    constexpr auto GetNormals() const noexcept -> decltype((m_normals))
    {
        return m_normals;
    }

    /// @brief Operator equals support.
    friend constexpr auto operator==(const NgonWithFwdNormals& lhs, const NgonWithFwdNormals& rhs) noexcept -> bool
    {
        return lhs.m_vertices == rhs.m_vertices;
    }
};

// Confirms/recognizes return type of NgonWithFwdNormals<1>::GetNormals()...
static_assert(std::is_same_v<
              decltype(std::declval<NgonWithFwdNormals<1>>().GetNormals()),
              const std::array<UnitVec, 1>&>);

/// @brief N-gon of runtime-arbitray vertices with counter-clockwise "forward" normals.
/// @details Specialization of <code>NgonWithFwdNormals</code> for runtime-arbitrary count of vertices.
/// @invariant The normals provided are always the forward normals of the assigned vertices.
template <>
class NgonWithFwdNormals<static_cast<std::size_t>(-1)> {
    std::vector<Length2> m_vertices{}; ///< Vertices
    std::vector<UnitVec> m_normals{}; ///< Normals.
public:
    /// @brief Default constructor.
    NgonWithFwdNormals() noexcept = default;

    /// @brief Initializing constructor.
    NgonWithFwdNormals(std::vector<Length2> vertices)
        : m_vertices{std::move(vertices)}, m_normals{GetFwdNormalsVector(m_vertices)}
    {
        // Intentionally empty.
    }

    /// @brief Gets the vertices of this N-gon.
    auto GetVertices() const noexcept -> decltype((m_vertices))
    {
        return m_vertices;
    }

    /// @brief Gets the normals of this N-gon.
    auto GetNormals() const noexcept -> decltype((m_normals))
    {
        return m_normals;
    }

    /// @brief Operator equals support.
    friend auto operator==(const NgonWithFwdNormals& lhs, const NgonWithFwdNormals& rhs) noexcept -> bool
    {
        return lhs.m_vertices == rhs.m_vertices;
    }
};

// Confirms/recognizes return type of NgonWithFwdNormals<>::GetNormals()...
static_assert(std::is_same_v<
              decltype(std::declval<NgonWithFwdNormals<>>().GetNormals()),
              const std::vector<UnitVec>&>);

} // namespace playrho::d2

#endif // PLAYRHO_D2_NGON_HPP

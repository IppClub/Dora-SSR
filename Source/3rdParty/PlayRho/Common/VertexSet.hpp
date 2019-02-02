/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_VERTEXSET_HPP
#define PLAYRHO_COMMON_VERTEXSET_HPP

#include "PlayRho/Common/Math.hpp"

#include <vector>
#include <algorithm>

namespace playrho {
namespace d2 {

/// @brief Vertex Set.
///
/// @details This is a container that enforces the invariant that no two
/// vertices can be closer together than the minimum separation distance.
///
class VertexSet
{
public:
    
    /// @brief Constant pointer type.
    using const_pointer = const Length2*;

    /// @brief Gets the default minimum separation squared value.
    static Area GetDefaultMinSeparationSquared()
    {
        return sqrt(std::numeric_limits<Vec2::value_type>::min()) * SquareMeter;
    }
    
    /// @brief Initializing constructor.
    explicit VertexSet(Area minSepSquared = GetDefaultMinSeparationSquared()):
        m_minSepSquared{minSepSquared}
    {
        assert(minSepSquared >= 0_m2);
    }

    /// @brief Gets the min separation squared.
    Area GetMinSeparationSquared() const noexcept { return m_minSepSquared; }

    /// @brief Adds the given vertex into the set if allowed.
    bool add(Length2 value)
    {
        if (find(value) != end())
        {
            return false;
        }
        m_elements.push_back(value);
        return true;
    }
    
    /// @brief Clear this set.
    void clear() noexcept
    {
        m_elements.clear();
    }

    /// @brief Gets the current size of this set.
    std::size_t size() const noexcept
    {
        return detail::Size(m_elements);
    }
    
    /// @brief Gets the pointer to the data buffer.
    const_pointer data() const { return detail::Data(m_elements); }
    
    /// @brief Gets the "begin" iterator value.
    const_pointer begin() const { return data(); }
    
    /// @brief Gets the "end" iterator value.
    const_pointer end() const { return data() + size(); }

    /// Finds contained point whose delta with the given point has a squared length less
    /// than or equal to this set's minimum length squared value.
    const_pointer find(Length2 value) const
    {
        // squaring anything smaller than the sqrt(std::numeric_limits<Vec2::data_type>::min())
        // won't be reversible.
        // i.e. won't obey the property that square(sqrt(a)) == a and sqrt(square(a)) == a.
        return std::find_if(begin(), end(), [&](Length2 elem) {
            // length squared must be large enough to have a reasonable enough unit vector.
            return GetMagnitudeSquared(value - elem) <= m_minSepSquared;
        });
    }

    /// @brief Indexed access.
    Length2 operator[](std::size_t index) const noexcept
    {
        return m_elements[index];
    }

private:
    std::vector<Length2> m_elements; ///< Elements.
    const Area m_minSepSquared; ///< Minimum length squared. <code>sizeof(Vec2)/2</code> or 4-bytes.
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COMMON_VERTEXSET_HPP

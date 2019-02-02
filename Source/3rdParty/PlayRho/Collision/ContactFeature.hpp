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

#ifndef PLAYRHO_COLLISION_CONTACTFEATURE_HPP
#define PLAYRHO_COLLISION_CONTACTFEATURE_HPP

#include "PlayRho/Common/Math.hpp"
#include <ostream>

namespace playrho {

/// @brief Contact Feature.
/// @details The features that intersect to form the contact point.
/// @note This structure is designed to be compact and passed-by-value.
/// @note This data structure is 4-bytes large.
/// @note Possible type combinations are:
///   vertex-vertex,
///   vertex-face,
///   face-vertex, or
///   face-face.
struct ContactFeature
{
    using Index = std::uint8_t; ///< Index type.

    /// @brief Type of the associated index value.
    enum Type : std::uint8_t
    {
        e_vertex = 0,
        e_face = 1
    };

    // Fit data into 4-byte large structure...

    Type typeA; ///< The feature type on shape A
    Index indexA; ///< Feature index on shape A
    Type typeB; ///< The feature type on shape B
    Index indexB; ///< Feature index on shape B
};

/// @brief Gets the vertex vertex contact feature for the given indices.
/// @relatedalso ContactFeature
PLAYRHO_CONSTEXPR inline ContactFeature GetVertexVertexContactFeature(ContactFeature::Index a,
                                                       ContactFeature::Index b) noexcept
{
    return ContactFeature{ContactFeature::e_vertex, a, ContactFeature::e_vertex, b};
}

/// @brief Gets the vertex face contact feature for the given indices.
/// @relatedalso ContactFeature
PLAYRHO_CONSTEXPR inline ContactFeature GetVertexFaceContactFeature(ContactFeature::Index a,
                                                     ContactFeature::Index b) noexcept
{
    return ContactFeature{ContactFeature::e_vertex, a, ContactFeature::e_face, b};
}

/// @brief Gets the face vertex contact feature for the given indices.
/// @relatedalso ContactFeature
PLAYRHO_CONSTEXPR inline ContactFeature GetFaceVertexContactFeature(ContactFeature::Index a,
                                                     ContactFeature::Index b) noexcept
{
    return ContactFeature{ContactFeature::e_face, a, ContactFeature::e_vertex, b};
}

/// @brief Gets the face face contact feature for the given indices.
/// @relatedalso ContactFeature
PLAYRHO_CONSTEXPR inline ContactFeature GetFaceFaceContactFeature(ContactFeature::Index a,
                                                   ContactFeature::Index b) noexcept
{
    return ContactFeature{ContactFeature::e_face, a, ContactFeature::e_face, b};
}

/// @brief Flips contact features information.
/// @relatedalso ContactFeature
PLAYRHO_CONSTEXPR inline ContactFeature Flip(ContactFeature val) noexcept
{
    return ContactFeature{val.typeB, val.indexB, val.typeA, val.indexA};
}

/// @brief Determines if the given two contact features are equal.
/// @relatedalso ContactFeature
PLAYRHO_CONSTEXPR inline bool operator==(ContactFeature lhs, ContactFeature rhs) noexcept
{
    return (lhs.typeA == rhs.typeA) && (lhs.indexA == rhs.indexA)
        && (lhs.typeB == rhs.typeB) && (lhs.indexB == rhs.indexB);
}

/// @brief Determines if the given two contact features are not equal.
/// @relatedalso ContactFeature
PLAYRHO_CONSTEXPR inline bool operator!=(ContactFeature lhs, ContactFeature rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the human readable name for the given contact feature type.
inline const char* GetName(ContactFeature::Type type) noexcept
{
    switch (type)
    {
        case ContactFeature::e_face: return "face";
        case ContactFeature::e_vertex: return "vertex";
    }
    return "unknown";
}

/// @brief Stream output operator.
inline ::std::ostream& operator<<(::std::ostream& os, const ContactFeature& value)
{
    os << "{";
    os << GetName(value.typeA);
    os << ",";
    os << unsigned(value.indexA);
    os << ",";
    os << GetName(value.typeB);
    os << ",";
    os << unsigned(value.indexB);
    os << "}";
    return os;
}

}; // namespace playrho

#endif // PLAYRHO_COLLISION_CONTACTFEATURE_HPP

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

#ifndef PLAYRHO_CONTACTFEATURE_HPP
#define PLAYRHO_CONTACTFEATURE_HPP

/// @file
/// @brief Definition of the <code>ContactFeature</code> class and closely related code.

#include <cstdint> // for std::uint8_t
#include <ostream>

#include "playrho/Settings.hpp" // for InvalidVertex

namespace playrho {

/// @brief The contact feature.
/// @details The features that intersect to form the contact point.
/// @note This structure is intended to be compact and passed-by-value.
/// @note Possible type combinations are:
///   vertex-vertex,
///   vertex-face,
///   face-vertex, or
///   face-face.
struct ContactFeature
{
    using Index = std::uint8_t; ///< Index type.

    /// @brief Type of the associated index value.
    enum Type: std::uint16_t
    {
        e_vertex = 0,
        e_face   = 1,
    };

    /// @brief Default constructor.
    /// @post <code>typeA == e_vertex</code>, <code>typeB == e_vertex</code>,
    ///   <code>other == 0</code>, <code>indexA == InvalidVertex</code>,
    ///   <code>indexB == InvalidVertex</code>.
    constexpr ContactFeature() noexcept
        : typeA{e_vertex}, typeB{e_vertex}, other{}, indexA{InvalidVertex}, indexB{InvalidVertex}
    {
        // Intentionally empty.
    }

    /// @brief Initializing constructor.
    /// @post <code>typeA == tA</code>, <code>typeB == tB</code>, <code>other == 0</code>,
    ///   <code>indexA == iA</code>, <code>indexB == iB</code>.
    constexpr ContactFeature(Type tA, Index iA, Type tB, Index iB) noexcept
        : typeA{tA}, typeB{tB}, other{}, indexA{iA}, indexB{iB}
    {
        // Intentionally empty.
    }

    Type typeA: 1; ///< The feature type on shape A
    Type typeB: 1; ///< The feature type on shape B
    Type other: 14; ///< Private for internal use!
    Index indexA; ///< Feature index on shape A
    Index indexB; ///< Feature index on shape B
};

/// @brief Gets the vertex vertex contact feature for the given indices.
/// @relatedalso ContactFeature
constexpr ContactFeature GetVertexVertexContactFeature(ContactFeature::Index a,
                                                       ContactFeature::Index b) noexcept
{
    return ContactFeature{ContactFeature::e_vertex, a, ContactFeature::e_vertex, b};
}

/// @brief Gets the vertex face contact feature for the given indices.
/// @relatedalso ContactFeature
constexpr ContactFeature GetVertexFaceContactFeature(ContactFeature::Index a,
                                                     ContactFeature::Index b) noexcept
{
    return ContactFeature{ContactFeature::e_vertex, a, ContactFeature::e_face, b};
}

/// @brief Gets the face vertex contact feature for the given indices.
/// @relatedalso ContactFeature
constexpr ContactFeature GetFaceVertexContactFeature(ContactFeature::Index a,
                                                     ContactFeature::Index b) noexcept
{
    return ContactFeature{ContactFeature::e_face, a, ContactFeature::e_vertex, b};
}

/// @brief Gets the face face contact feature for the given indices.
/// @relatedalso ContactFeature
constexpr ContactFeature GetFaceFaceContactFeature(ContactFeature::Index a,
                                                   ContactFeature::Index b) noexcept
{
    return ContactFeature{ContactFeature::e_face, a, ContactFeature::e_face, b};
}

/// @brief Flips contact features information.
/// @relatedalso ContactFeature
constexpr ContactFeature Flip(ContactFeature val) noexcept
{
    return ContactFeature{val.typeB, val.indexB, val.typeA, val.indexA};
}

/// @brief Determines if the given two contact features are equal.
/// @relatedalso ContactFeature
constexpr bool operator==(ContactFeature lhs, ContactFeature rhs) noexcept
{
    return (lhs.typeA == rhs.typeA) && (lhs.indexA == rhs.indexA)
        && (lhs.typeB == rhs.typeB) && (lhs.indexB == rhs.indexB);
}

/// @brief Determines if the given two contact features are not equal.
/// @relatedalso ContactFeature
constexpr bool operator!=(ContactFeature lhs, ContactFeature rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the human readable name for the given contact feature type.
constexpr const char* GetName(ContactFeature::Type type) noexcept
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

#endif // PLAYRHO_CONTACTFEATURE_HPP

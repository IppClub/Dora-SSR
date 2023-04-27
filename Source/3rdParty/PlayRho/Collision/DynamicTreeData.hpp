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

#ifndef PLAYRHO_COLLISION_DYNAMICTREEDATA_HPP
#define PLAYRHO_COLLISION_DYNAMICTREEDATA_HPP

#include "PlayRho/Common/Settings.hpp"
#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Collision/Shapes/ShapeID.hpp"

namespace playrho {

/// @brief Unused data of a tree node.
/// @note This exists for symmetry and as placeholder in case this needs to later be used.
struct DynamicTreeUnusedData {
    // Intentionally empty.
};

/// @brief Branch data of a tree node.
struct DynamicTreeBranchData {
    DynamicTreeSize child1; ///< @brief Child 1.
    DynamicTreeSize child2; ///< @brief Child 2.
};

/// @brief Leaf data of a tree node.
/// @details This is the leaf node specific data for a <code>DynamicTree::TreeNode</code>.
///   It's data that only pertains to leaf nodes.
/// @note This class is used in the <code>DynamicTreeVariantData</code> union within a
///   <code>DynamicTree::TreeNode</code>.
///   This has ramifications on this class's data contents and size.
struct DynamicTreeLeafData {
    // In terms of what needs to be in this structure, it minimally needs to have enough
    // information in it to identify the child shape for which the node's AABB represents,
    // and its associated body. A pointer to the fixture and the index of the child in
    // its shape could suffice for this. Meanwhile, a Contact is defined to be the
    // recognition of an overlap between two child shapes having different bodies making
    // the caching of the bodies a potential speed-up opportunity.

    /// @brief Identifier of the associated body.
    /// @note This field serves merely to potentially avoid the lookup of the body through
    ///   the fixture.
    BodyID bodyId;

    /// @brief Identifier of the associated shape.
    ShapeID shapeId;

    /// @brief Child index of related Shape.
    ChildCounter childId;
};

/// @brief Equality operator.
/// @relatedalso DynamicTreeLeafData
constexpr bool operator==(const DynamicTreeLeafData& lhs, const DynamicTreeLeafData& rhs) noexcept
{
    return lhs.bodyId == rhs.bodyId && lhs.shapeId == rhs.shapeId && lhs.childId == rhs.childId;
}

/// @brief Inequality operator.
/// @relatedalso DynamicTreeLeafData
constexpr bool operator!=(const DynamicTreeLeafData& lhs, const DynamicTreeLeafData& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Variant data.
/// @note A union is used intentionally to save space.
union DynamicTreeVariantData {
    /// @brief Unused/free-list specific data.
    DynamicTreeUnusedData unused;

    /// @brief Leaf specific data.
    DynamicTreeLeafData leaf;

    /// @brief Branch specific data.
    DynamicTreeBranchData branch;

    /// @brief Initializing constructor.
    constexpr DynamicTreeVariantData(DynamicTreeUnusedData value) noexcept : unused{value} {}

    /// @brief Initializing constructor.
    constexpr DynamicTreeVariantData(DynamicTreeLeafData value) noexcept : leaf{value} {}

    /// @brief Initializing constructor.
    constexpr DynamicTreeVariantData(DynamicTreeBranchData value) noexcept : branch{value} {}
};

} // namespace playrho

#endif // PLAYRHO_COLLISION_DYNAMICTREEDATA_HPP

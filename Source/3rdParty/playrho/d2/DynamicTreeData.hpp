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

#ifndef PLAYRHO_D2_DYNAMICTREEDATA_HPP
#define PLAYRHO_D2_DYNAMICTREEDATA_HPP

/// @file
/// @brief Definitions of @c DynamicTree related classes.

// IWYU pragma: begin_exports

#include "playrho/Contactable.hpp"
#include "playrho/Settings.hpp"

// IWYU pragma: end_exports

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

/// @brief Variant data.
/// @note A union is used intentionally to save space.
union DynamicTreeVariantData {
    /// @brief Unused/free-list specific data.
    DynamicTreeUnusedData unused;

    /// @brief Leaf specific data.
    Contactable leaf;

    /// @brief Branch specific data.
    DynamicTreeBranchData branch;

    /// @brief Initializing constructor.
    constexpr DynamicTreeVariantData(DynamicTreeUnusedData value) noexcept : unused{value} {}

    /// @brief Initializing constructor.
    constexpr DynamicTreeVariantData(Contactable value) noexcept : leaf{value} {}

    /// @brief Initializing constructor.
    constexpr DynamicTreeVariantData(DynamicTreeBranchData value) noexcept : branch{value} {}
};

} // namespace playrho

#endif // PLAYRHO_D2_DYNAMICTREEDATA_HPP

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

#include "PlayRho/Collision/DynamicTreeData.hpp"

namespace playrho {

static_assert(std::is_nothrow_default_constructible<DynamicTreeLeafData>::value,
              "DynamicTreeLeafData must be nothrow default constructible!");
static_assert(std::is_copy_constructible<DynamicTreeLeafData>::value,
              "DynamicTreeLeafData must be copy constructible!");
static_assert(std::is_nothrow_move_constructible<DynamicTreeLeafData>::value,
              "DynamicTreeLeafData must be nothrow move constructible!");
static_assert(std::is_copy_assignable<DynamicTreeLeafData>::value,
              "DynamicTreeLeafData must be copy assignable!");
static_assert(std::is_nothrow_move_assignable<DynamicTreeLeafData>::value,
              "DynamicTreeLeafData must be move assignable!");

} // namespace playrho

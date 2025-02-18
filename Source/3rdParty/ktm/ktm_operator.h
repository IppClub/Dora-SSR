//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_OPERATOR_H_
#define _KTM_OPERATOR_H_

#include <cmath>
#include <type_traits>
#include "setup.h"

template <typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
KTM_FUNC constexpr T ktm_operator_madd(T x, T y, T z) noexcept
{
    if constexpr (std::is_floating_point_v<T>)
        return std::fma(y, z, x);
    return x + y * z;
}

template <typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
KTM_FUNC constexpr T ktm_operator_smadd(T& x, T y, T z) noexcept
{
    if constexpr (std::is_floating_point_v<T>)
        x = std::fma(y, z, x);
    else
        x += y * z;
    return x;
}

namespace ktm
{

using ::ktm_operator_madd;
using ::ktm_operator_smadd;

} // namespace ktm

#endif
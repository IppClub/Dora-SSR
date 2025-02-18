//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_EXPONENTIAL_INL_
#define _KTM_EXPONENTIAL_INL_

#include <cmath>
#include "exponential_fwd.h"
#include "../../setup.h"
#include "../../type/basic.h"

template <typename T, typename Void>
struct ktm::detail::exponential_implement::sqrt
{
    static KTM_INLINE T call(T x) noexcept { return std::sqrt(x); }
};

template <typename T, typename Void>
struct ktm::detail::exponential_implement::rsqrt
{
    static KTM_INLINE T call(T x) noexcept { return one<T> / std::sqrt(x); }
};

template <typename T, typename Void>
struct ktm::detail::exponential_implement::recip
{
    static KTM_INLINE T call(T x) noexcept { return one<T> / x; }
};

// Quake III Algorithm: u = 0.0450465
template <typename T, typename Void>
struct ktm::detail::exponential_implement::fast_sqrt
{
    static KTM_INLINE T call(T x) noexcept
    {
        using integral_type = std::select_if_t<std::is_same_v<T, float>, unsigned int, unsigned long long>;
        integral_type i = *reinterpret_cast<const integral_type*>(&x);
        if constexpr (std::is_same_v<integral_type, unsigned int>)
            i = 0x1fbd1df5 + (i >> 1);
        else
            i = 0x1ff7a3bea91d9b1b + (i >> 1);
        T ret = *reinterpret_cast<T*>(&i);
        return (ret + x / ret) * static_cast<T>(0.5);
    }
};

template <typename T, typename Void>
struct ktm::detail::exponential_implement::fast_rsqrt
{
    static KTM_INLINE T call(T x) noexcept
    {
        using integral_type = std::select_if_t<std::is_same_v<T, float>, unsigned int, unsigned long long>;
        integral_type i = *reinterpret_cast<const integral_type*>(&x);
        if constexpr (std::is_same_v<integral_type, unsigned int>)
            i = 0x5f3759df - (i >> 1);
        else
            i = 0x5fe6eb3bfb58d152 - (i >> 1);
        T ret = *reinterpret_cast<T*>(&i);
        return ret * (static_cast<T>(1.5) - (static_cast<T>(0.5) * x * ret * ret));
    }
};

template <typename T, typename Void>
struct ktm::detail::exponential_implement::fast_recip
{
    static KTM_INLINE T call(T x) noexcept
    {
        using integral_type = std::select_if_t<std::is_same_v<T, float>, unsigned int, unsigned long long>;
        integral_type i = *reinterpret_cast<const integral_type*>(&x);
        if constexpr (std::is_same_v<integral_type, unsigned int>)
            i = 0x7ef477d5 - i;
        else
            i = 0x7fde8efaa4766c6e - i;
        T ret = *reinterpret_cast<T*>(&i);
        return ret * (static_cast<T>(2) - x * ret);
    }
};

#endif
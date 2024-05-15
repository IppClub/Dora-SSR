//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_EPSILON_H_
#define _KTM_EPSILON_H_

#include "../setup.h"
#include "../type/basic.h"
#include "../traits/type_traits_math.h"
#include "arithmetic.h"
#include "common.h"

namespace ktm
{

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> equal_zero(T x, T e = std::numeric_limits<T>::epsilon()) noexcept
{
    return abs(x) < e;
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> equal(T x, T y, T e = std::numeric_limits<T>::epsilon()) noexcept
{
    return equal_zero(x - y, e);
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> less_zero(T x, T e = std::numeric_limits<T>::epsilon()) noexcept
{
    return x <= -e;
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> less(T x, T y, T e = std::numeric_limits<T>::epsilon()) noexcept
{
    return less_zero(x - y, e);
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> greater_zero(T x, T e = std::numeric_limits<T>::epsilon()) noexcept
{
    return x >= e;
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, bool> greater(T x, T y, T e = std::numeric_limits<T>::epsilon()) noexcept
{
    return greater_zero(x - y, e);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool> equal_zero(const V& x, vec_traits_base_t<V> e = std::numeric_limits<vec_traits_base_t<V>>::epsilon()) noexcept
{
    return reduce_max(abs(x)) < e;
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool> equal(const V& x, const V& y, vec_traits_base_t<V> e = std::numeric_limits<vec_traits_base_t<V>>::epsilon()) noexcept
{
    return equal_zero(x - y, e);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool> less_zero(const V& x, vec_traits_base_t<V> e = std::numeric_limits<vec_traits_base_t<V>>::epsilon()) noexcept
{
    return reduce_max(x) <= -e;
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool> less(const V& x, const V& y, vec_traits_base_t<V> e = std::numeric_limits<vec_traits_base_t<V>>::epsilon()) noexcept
{
    return less_zero(x - y, e);
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool> greater_zero(const V& x, vec_traits_base_t<V> e = std::numeric_limits<vec_traits_base_t<V>>::epsilon()) noexcept
{
    return reduce_min(x) >= e;
}

template<class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, bool> greater(const V& x, const V& y, vec_traits_base_t<V> e = std::numeric_limits<vec_traits_base_t<V>>::epsilon()) noexcept
{
    return greater_zero(x - y, e);
}

}
#endif
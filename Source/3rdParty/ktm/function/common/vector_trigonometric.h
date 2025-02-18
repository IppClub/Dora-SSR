//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_TRIGONOMETRIC_H_
#define _KTM_VECTOR_TRIGONOMETRIC_H_

#include "../../setup.h"
#include "../../type/vec.h"
#include "../../traits/type_traits_math.h"
#include "../../detail/function/vector_trigonometric_fwd.h"

namespace ktm
{

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> acos(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::acos<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> asin(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::asin<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> atan(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::atan<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> atan2(const V& x, const V& y) noexcept
{
    return detail::vector_trigonometric_implement::atan2<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> cos(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::cos<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> sin(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::sin<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> tan(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::tan<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> sinc(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::sinc<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> acosh(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::acosh<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> asinh(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::asinh<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> atanh(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::atanh<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> cosh(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::cosh<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> sinh(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::sinh<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> tanh(const V& x) noexcept
{
    return detail::vector_trigonometric_implement::tanh<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

} // namespace ktm

#include "../../detail/function/vector_trigonometric.inl"

#endif
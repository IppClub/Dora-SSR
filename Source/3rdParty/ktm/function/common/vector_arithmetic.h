//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_ARITHMETIC_H_
#define _KTM_VECTOR_ARITHMETIC_H_

#include "../../setup.h"
#include "../../type/vec.h"
#include "../../traits/type_traits_math.h"
#include "../../detail/function/vector_arithmetic_fwd.h"

namespace ktm
{

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && !is_unsigned_base_v<V>, V> abs(const V& x) noexcept
{
    return detail::vector_arithmetic_implement::abs<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, V> min(const V& x, const V& y) noexcept
{
    return detail::vector_arithmetic_implement::min<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, V> max(const V& x, const V& y) noexcept
{
    return detail::vector_arithmetic_implement::max<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, V> clamp(const V& v, const V& min, const V& max) noexcept
{
    return detail::vector_arithmetic_implement::clamp<vec_traits_len<V>, vec_traits_base_t<V>>::call(v, min, max);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> floor(const V& x) noexcept
{
    return detail::vector_arithmetic_implement::floor<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> ceil(const V& x) noexcept
{
    return detail::vector_arithmetic_implement::ceil<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> round(const V& x) noexcept
{
    return detail::vector_arithmetic_implement::round<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> fract(const V& x) noexcept
{
    return detail::vector_arithmetic_implement::fract<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> mod(const V& x, const V& y) noexcept
{
    return detail::vector_arithmetic_implement::mod<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> lerp(const V& x, const V& y,
                                                                                   vec_traits_base_t<V> t) noexcept
{
    return detail::vector_arithmetic_implement::lerp<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y, t);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> mix(const V& x, const V& y,
                                                                                  const V& t) noexcept
{
    return detail::vector_arithmetic_implement::mix<vec_traits_len<V>, vec_traits_base_t<V>>::call(x, y, t);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> step(const V& edge, const V& x) noexcept
{
    return detail::vector_arithmetic_implement::step<vec_traits_len<V>, vec_traits_base_t<V>>::call(edge, x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V> && is_floating_point_base_v<V>, V> smoothstep(const V& edge0, const V& edge1,
                                                                                         const V& x) noexcept
{
    return detail::vector_arithmetic_implement::smoothstep<vec_traits_len<V>, vec_traits_base_t<V>>::call(edge0, edge1,
                                                                                                          x);
}

} // namespace ktm

#include "../../detail/function/vector_arithmetic.inl"
#include "../../detail/function/vector_arithmetic_simd.inl"

#endif
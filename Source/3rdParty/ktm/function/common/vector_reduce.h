//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_REDUCE_H_
#define _KTM_VECTOR_REDUCE_H_

#include "../../setup.h"
#include "../../type/vec.h"
#include "../../traits/type_traits_math.h"
#include "../../detail/function/vector_reduce_fwd.h"

namespace ktm
{

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, vec_traits_base_t<V>> reduce_add(const V& x) noexcept
{
    return detail::vector_reduce_implement::reduce_add<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, vec_traits_base_t<V>> reduce_min(const V& x) noexcept
{
    return detail::vector_reduce_implement::reduce_min<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

template <class V>
KTM_INLINE std::enable_if_t<is_vector_v<V>, vec_traits_base_t<V>> reduce_max(const V& x) noexcept
{
    return detail::vector_reduce_implement::reduce_max<vec_traits_len<V>, vec_traits_base_t<V>>::call(x);
}

} // namespace ktm

#include "../../detail/function/vector_reduce.inl"
#include "../../detail/function/vector_reduce_simd.inl"

#endif
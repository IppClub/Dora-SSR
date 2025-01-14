//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_REDUCE_INL_
#define _KTM_VECTOR_REDUCE_INL_

#include "vector_reduce_fwd.h"
#include "../loop_util.h"
#include "../../type/vec_fwd.h"
#include "../../function/common/arithmetic.h"

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_reduce_implement::reduce_add
{
    using V = vec<N, T>;

    static KTM_INLINE T call(const V& x) noexcept
    {
        T ret = x[0];
        loop_op<N - 1, void>::call([&ret](const T& x) -> void { ret += x; }, &x[1]);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_reduce_implement::reduce_min
{
    using V = vec<N, T>;

    static KTM_INLINE T call(const V& x) noexcept
    {
        T ret = x[0];
        loop_op<N - 1, void>::call([&ret](const T& x) -> void { ret = ktm::min<T>(ret, x); }, &x[1]);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_reduce_implement::reduce_max
{
    using V = vec<N, T>;

    static KTM_INLINE T call(const V& x) noexcept
    {
        T ret = x[0];
        loop_op<N - 1, void>::call([&ret](const T& x) -> void { ret = ktm::max<T>(ret, x); }, &x[1]);
        return ret;
    }
};

#endif
//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_DATA_INL_
#define _KTM_VEC_DATA_INL_

#include "vec_data_fwd.h"
#include "../../setup.h"
#include "../../type/vec_fwd.h"

template <size_t N, typename T, typename Void>
struct ktm::detail::vec_data_implement::vec_storage
{
private:
    static KTM_INLINE constexpr size_t align() noexcept
    {
        if constexpr (sizeof(T) > 8)
            return alignof(T);
        else if constexpr (N <= 4)
            return (N == 3 ? 4 : N) * sizeof(T);
        else
            return sizeof(T);
    }

public:
    struct alignas(align()) type
    {
        T e[N];
    };
};

template <size_t OSize, size_t ISize, typename T, typename Void>
struct ktm::detail::vec_data_implement::vec_swizzle
{
private:
    template <size_t... E>
    static KTM_INLINE constexpr bool enable_swizzle() noexcept
    {
        return (sizeof...(E) == OSize) && ((E < ISize) && ...);
    }

public:
    using V = vec<ISize, T>;
    using RetV = vec<OSize, T>;

    template <size_t... E>
    static KTM_INLINE std::enable_if_t<enable_swizzle<E...>(), RetV> call(const V& v) noexcept
    {
        return RetV(v[E]...);
    }
};

#endif
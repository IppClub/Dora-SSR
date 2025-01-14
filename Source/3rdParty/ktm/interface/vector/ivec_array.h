//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_VEC_ARRAY_H_
#define _KTM_I_VEC_ARRAY_H_

#include <array>
#include "../../setup.h"
#include "../../type/vec_fwd.h"

namespace ktm
{

template <class Father, class Child>
struct ivec_array;

template <class Father, size_t N, typename T>
struct ivec_array<Father, vec<N, T>> : Father
{
    using Father::Father;
    using array_type = std::array<T, N>;

private:
    template <class F, class C>
    friend struct iarray_util;

    KTM_FUNC array_type& to_array_impl() noexcept { return reinterpret_cast<array_type&>(*this); }

    KTM_FUNC const array_type& to_array_impl() const noexcept { return reinterpret_cast<const array_type&>(*this); }
};

} // namespace ktm

#endif
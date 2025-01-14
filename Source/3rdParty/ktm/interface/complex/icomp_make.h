//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_COMP_MAKE_H_
#define _KTM_I_COMP_MAKE_H_

#include "../../setup.h"
#include "../../type/comp_fwd.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"
#include "../../function/common.h"

namespace ktm
{

template <class Father, class Child>
struct icomp_make;

template <class Father, typename T>
struct icomp_make<Father, comp<T>> : Father
{
    using Father::Father;

    static KTM_INLINE comp<T> identity() noexcept { return comp<T>(zero<T>, one<T>); }

    static KTM_INLINE comp<T> real_imag(T real, T imag) noexcept { return comp<T>(imag, real); }

    static KTM_INLINE comp<T> from_angle(T angle) noexcept { return comp<T>(sin(angle), cos(angle)); }

    static KTM_INLINE comp<T> from_to(const vec<2, T>& from, const vec<2, T>& to) noexcept
    {
        return comp<T>(from[0] * to[1] - from[1] * to[0], dot(from, to));
    }

    static KTM_INLINE comp<T> from_matrix(const mat<2, 2, T>& matrix) noexcept { return comp<T>(matrix[0].yx()); }

    static KTM_INLINE comp<T> from_matrix(const mat<3, 3, T>& matrix) noexcept { return comp<T>(matrix[0].yx()); }
};

} // namespace ktm

#endif
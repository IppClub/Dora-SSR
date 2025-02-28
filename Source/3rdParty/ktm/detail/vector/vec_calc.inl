//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_CALC_INL_
#define _KTM_VEC_CALC_INL_

#include "vec_calc_fwd.h"
#include "../../type/basic.h"
#include "../../type/vec_fwd.h"

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::add(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y) noexcept
{
    out.x = x.x + y.x;
    out.y = x.y + y.y;
    out.z = x.z + y.z;
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::sub(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y) noexcept
{
    out.x = x.x - y.x;
    out.y = x.y - y.y;
    out.z = x.z - y.z;
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::neg(vec<3, T>& out, const vec<3, T>& x) noexcept
{
    out.x = -x.x;
    out.y = -x.y;
    out.z = -x.z;
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::mul(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y) noexcept
{
    out.x = x.x * y.x;
    out.y = x.y * y.y;
    out.z = x.z * y.z;
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::madd(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y,
                                                      const vec<3, T>& z) noexcept
{
    out.x = ktm_op_madd(x.x, y.x, z.x);
    out.y = ktm_op_madd(x.y, y.y, z.y);
    out.z = ktm_op_madd(x.z, y.z, z.z);
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::div(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y) noexcept
{
    out.x = x.x / y.x;
    out.y = x.y / y.y;
    out.z = x.z / y.z;
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::add_scalar(vec<3, T>& out, const vec<3, T>& x, T scalar) noexcept
{
    out.x = x.x + scalar;
    out.y = x.y + scalar;
    out.z = x.z + scalar;
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::sub_scalar(vec<3, T>& out, const vec<3, T>& x, T scalar) noexcept
{
    out.x = x.x - scalar;
    out.y = x.y - scalar;
    out.z = x.z - scalar;
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::mul_scalar(vec<3, T>& out, const vec<3, T>& x, T scalar) noexcept
{
    out.x = x.x * scalar;
    out.y = x.y * scalar;
    out.z = x.z * scalar;
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::div_scalar(vec<3, T>& out, const vec<3, T>& x, T scalar) noexcept
{
    if constexpr (std::is_floating_point_v<T>)
        mul_scalar(out, x, one<T> / scalar);
    else
    {
        out.x = x.x / scalar;
        out.y = x.y / scalar;
        out.z = x.z / scalar;
    }
}

template <typename T>
KTM_INLINE void ktm::detail::vec_calc_implement::madd_scalar(vec<3, T>& out, const vec<3, T>& x, const vec<3, T>& y,
                                                             T scalar) noexcept
{
    out.x = ktm_op_madd(x.x, y.x, scalar);
    out.y = ktm_op_madd(x.y, y.y, scalar);
    out.z = ktm_op_madd(x.z, y.z, scalar);
}

#endif

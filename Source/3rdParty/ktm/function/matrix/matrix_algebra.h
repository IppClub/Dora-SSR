//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_ALGEBRA_H_
#define _KTM_MATRIX_ALGEBRA_H_

#include "../../setup.h"
#include "../../type/mat.h"
#include "../../traits/type_traits_math.h"
#include "../../detail/function/matrix_algebra_fwd.h"

namespace ktm
{

template <class M>
KTM_INLINE std::enable_if_t<is_matrix_v<M>, mat_traits_tp_t<M>> transpose(const M& m) noexcept
{
    return detail::matrix_algebra_implement::transpose<mat_traits_row_v<M>, mat_traits_col_v<M>,
                                                       mat_traits_base_t<M>>::call(m);
}

template <class M>
KTM_INLINE std::enable_if_t<is_square_matrix_v<M>, mat_traits_col_t<M>> diagonal(const M& m)
{
    return detail::matrix_algebra_implement::diagonal<mat_traits_col_v<M>, mat_traits_base_t<M>>::call(m);
}

template <class M>
KTM_INLINE std::enable_if_t<is_square_matrix_v<M>, mat_traits_base_t<M>> trace(const M& m)
{
    return reduce_add(detail::matrix_algebra_implement::diagonal<mat_traits_col_v<M>, mat_traits_base_t<M>>::call(m));
}

template <class M>
KTM_INLINE std::enable_if_t<is_square_matrix_v<M>, mat_traits_base_t<M>> determinant(const M& m)
{
    return detail::matrix_algebra_implement::determinant<mat_traits_col_v<M>, mat_traits_base_t<M>>::call(m);
}

template <class M>
KTM_INLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, M> inverse(const M& m)
{
    return detail::matrix_algebra_implement::inverse<mat_traits_col_v<M>, mat_traits_base_t<M>>::call(m);
}

} // namespace ktm

#include "../../detail/function/matrix_algebra.inl"
#include "../../detail/function/matrix_algebra_simd.inl"

#endif

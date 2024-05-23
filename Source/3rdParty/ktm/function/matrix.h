//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_H_
#define _KTM_MATRIX_H_

#include "../setup.h"
#include "../type/mat.h"
#include "../traits/type_traits_math.h"
#include "../detail/function/matrix_fwd.h"

namespace ktm
{
    
template<class M>
KTM_INLINE std::enable_if_t<is_matrix_v<M>, mat_traits_tp_t<M>> transpose(const M& m) noexcept
{
    return detail::matrix_implement::transpose<mat_traits_row_n<M>, mat_traits_col_n<M>, mat_traits_base_t<M>>::call(m);
} 

template<class M>
KTM_INLINE std::enable_if_t<is_square_matrix_v<M>, mat_traits_base_t<M>> trace(const M& m)
{
    return detail::matrix_implement::trace<mat_traits_col_n<M>, mat_traits_base_t<M>>::call(m);
}

template<class M>
KTM_INLINE std::enable_if_t<is_square_matrix_v<M>, mat_traits_col_t<M>> diagonal(const M& m)
{
    return detail::matrix_implement::diagonal<mat_traits_col_n<M>, mat_traits_base_t<M>>::call(m);
}

template<class M>
KTM_INLINE std::enable_if_t<is_square_matrix_v<M>, mat_traits_base_t<M>> determinant(const M& m)
{
    return detail::matrix_implement::determinant<mat_traits_col_n<M>, mat_traits_base_t<M>>::call(m);
}

template<class M>
KTM_INLINE std::enable_if_t<is_square_matrix_v<M> && is_floating_point_base_v<M>, M> inverse(const M& m)
{
    return detail::matrix_implement::inverse<mat_traits_col_n<M>, mat_traits_base_t<M>>::call(m);
}

}

#include "../detail/function/matrix.inl"
#include "../detail/function/matrix_simd.inl"

#endif

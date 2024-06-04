//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_MAT_CALC_H_
#define _KTM_I_MAT_CALC_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"
#include "../../detail/matrix/mat_calc_fwd.h"

namespace ktm
{

template<class Father, class Child>
struct imat_calc;

template<class Father, size_t Row, size_t Col, typename T>
struct imat_calc<Father, mat<Row, Col, T>> : Father
{
    using Father::Father;

    KTM_INLINE vec<Col, T> operator*(const vec<Row, T>& v) const noexcept
    {
        return detail::mat_opt_implement::mat_mul_vec<Row, Col, T>::call(reinterpret_cast<const mat<Row, Col, T>&>(*this), v); 
    }

    friend KTM_INLINE vec<Row, T> operator*(const vec<Col, T>& v, const mat<Row, Col, T>& m) noexcept
    {
        return detail::mat_opt_implement::vec_mul_mat<Row, Col, T>::call(v, m); 
    }

    template<size_t U>
    KTM_INLINE mat<U, Col, T> operator*(const mat<U, Row, T>& m2) const noexcept
    {
        return detail::mat_opt_implement::mat_mul_mat<Row, Col, T>::template call<U>(reinterpret_cast<const mat<Row, Col, T>&>(*this), m2); 
    }

    KTM_INLINE mat<Row, Col, T> operator+(const mat<Row, Col, T>& m2) const noexcept
    {
        return detail::mat_opt_implement::add<Row, Col, T>::call(reinterpret_cast<const mat<Row, Col, T>&>(*this), m2); 
    }

    KTM_INLINE mat<Row, Col, T> operator-(const mat<Row, Col, T>& m2) const noexcept
    {
        return detail::mat_opt_implement::minus<Row, Col, T>::call(reinterpret_cast<const mat<Row, Col, T>&>(*this), m2); 
    }

    KTM_INLINE mat<Row, Col, T> operator-() const noexcept
    {
        return detail::mat_opt_implement::opposite<Row, Col, T>::call(reinterpret_cast<const mat<Row, Col, T>&>(*this));  
    }
};

}

#endif

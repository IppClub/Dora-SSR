//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_MAT_DATA_H_
#define _KTM_I_MAT_DATA_H_ 

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

namespace ktm
{
template<class Father, class Child>
struct imat_data;

template<class Father, size_t Col, typename T>
struct imat_data<Father, mat<2, Col, T>> : Father
{
    using Father::Father;
    imat_data(const vec<Col, T>& col0, const vec<Col, T>& col1) noexcept : columns{ col0, col1 } { }
private:
    vec<Col, T> columns[2];
};

template<class Father, size_t Col, typename T>
struct imat_data<Father, mat<3, Col, T>> : Father
{
    using Father::Father;
    imat_data(const vec<Col, T>& col0, const vec<Col, T>& col1, const vec<Col, T>& col2) noexcept : columns{ col0, col1, col2 } { }
private:
    vec<Col, T> columns[3];
};

template<class Father, size_t Col, typename T>
struct imat_data<Father, mat<4, Col, T>> : Father
{
    using Father::Father;
    imat_data(const vec<Col, T>& col0, const vec<Col, T>& col1, const vec<Col, T>& col2, const vec<Col, T>& col3) noexcept : columns{ col0, col1, col2, col3 } { }
private:
    vec<Col, T> columns[4];
};

}

#endif
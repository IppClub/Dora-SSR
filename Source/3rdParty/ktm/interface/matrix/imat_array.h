//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_MAT_ARRAY_H_
#define _KTM_I_MAT_ARRAY_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"
#include <array>

namespace ktm
{

template<class Father, class Child>
struct imat_array;

template<class Father, size_t Row, size_t Col, typename T>
struct imat_array<Father, mat<Row, Col, T>> : Father
{
    using Father::Father;
    using array_type = std::array<vec<Col, T>, Row>;
};

}

#endif
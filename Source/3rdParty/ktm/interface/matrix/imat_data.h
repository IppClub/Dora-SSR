//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_MAT_DATA_H_
#define _KTM_I_MAT_DATA_H_ 

#include "../../setup.h"
#include "../../traits/type_traits_ext.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

namespace ktm
{
    
template<class Father, class Child>
struct imat_data;

template<class Father, size_t Row, size_t Col, typename T>
struct imat_data<Father, mat<Row, Col, T>> : Father
{
    using Father::Father;
    template<typename... ColVs, typename = std::enable_if_t<sizeof...(ColVs) == Row &&
                  std::is_same_vs<vec<Col, T>, std::remove_const_t<std::remove_reference_t<ColVs>>...>>>
    explicit imat_data(ColVs&&... cols) noexcept : columns{ std::forward<ColVs>(cols)... } { }
private:
    vec<Col, T> columns[Row];
};

}

#endif
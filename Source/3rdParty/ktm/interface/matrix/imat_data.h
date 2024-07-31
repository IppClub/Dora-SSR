//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_MAT_DATA_H_
#define _KTM_I_MAT_DATA_H_ 

#include <cstring>
#include <initializer_list>
#include <algorithm>
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

    KTM_FUNC constexpr imat_data() noexcept : columns{} { }
    KTM_FUNC imat_data(const imat_data& copy) { std::memcpy(columns, copy.columns, sizeof(columns)); }
    KTM_FUNC imat_data(imat_data&& copy) { std::memcpy(columns, copy.columns, sizeof(columns)); }
    KTM_FUNC imat_data& operator=(const imat_data& copy) { std::memcpy(columns, copy.columns, sizeof(columns)); return *this; };
    KTM_FUNC imat_data& operator=(imat_data&& copy) { std::memcpy(columns, copy.columns, sizeof(columns)); return *this; };
    KTM_FUNC imat_data(std::initializer_list<vec<Col, T>> li) { std::memcpy(columns, li.begin(), li.size() * sizeof(vec<Col, T>)); }
    template<typename... ColVs, typename = std::enable_if_t<sizeof...(ColVs) == Row &&
                  std::is_same_vs<vec<Col, T>, std::extract_type_t<ColVs>...>>>
    KTM_FUNC explicit imat_data(ColVs&&... cols) noexcept : columns{ std::forward<ColVs>(cols)... } { }
private:
    vec<Col, T> columns[Row];
};

}

#endif
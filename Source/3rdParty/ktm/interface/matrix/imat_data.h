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
#include "../../setup.h"
#include "../../traits/type_traits_ext.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

namespace ktm
{

template <class Father, class Child>
struct imat_data;

template <class Father, size_t Row, size_t Col, typename T>
struct imat_data<Father, mat<Row, Col, T>> : Father
{
    using Father::Father;

    KTM_FUNC constexpr imat_data() noexcept : columns {} {};
    imat_data(const imat_data&) = default;
    imat_data(imat_data&&) = default;
    imat_data& operator=(const imat_data&) = default;
    imat_data& operator=(imat_data&&) = default;

    KTM_FUNC constexpr imat_data(std::initializer_list<vec<Col, T>> li) : columns {}
    {
        for (int i = 0; i < li.size() && i < Row; ++i)
            columns[i] = li.begin()[i];
    }

    template <typename... ColVs, typename = std::enable_if_t<sizeof...(ColVs) == Row &&
                                                             std::is_same_vs<vec<Col, T>, std::decay_t<ColVs>...>>>
    KTM_FUNC constexpr imat_data(ColVs&&... cols) noexcept : columns { std::forward<ColVs>(cols)... }
    {
    }

private:
    vec<Col, T> columns[Row];
};

} // namespace ktm

#endif
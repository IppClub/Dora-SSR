//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_DATA_FWD_H_
#define _KTM_VEC_DATA_FWD_H_

#include <cstddef>
#include <type_traits>

namespace ktm
{
namespace detail
{
namespace vec_data_implement
{

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct vec_storage;

template<size_t OUT, size_t IN, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T> && OUT <= IN>>
struct vec_swizzle;

};
}
}

#define KTM_VEC_ST_ENUM_GET(x) ktm::detail::vec_data_implement::KTM_VEC_ST_ENUM_NAME(x)()
#define KTM_VEC_ST_ENUM_PACKAGE(x, y, z, w) KTM_VEC_ST_ENUM_IMPL(x, 0) KTM_VEC_ST_ENUM_IMPL(y, 1) KTM_VEC_ST_ENUM_IMPL(z, 2) KTM_VEC_ST_ENUM_IMPL(w, 3)
#define KTM_VEC_ST_ENUM_IMPL(x, n) namespace ktm::detail::vec_data_implement { KTM_INLINE constexpr size_t KTM_VEC_ST_ENUM_NAME(x)() noexcept { return n; } }
#define KTM_VEC_ST_ENUM_NAME(x) vec_storage_enum_##x

#endif
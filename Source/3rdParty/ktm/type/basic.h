//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_BASIC_H_
#define _KTM_BASIC_H_

#include <type_traits>

namespace ktm
{

template<typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> zero = static_cast<T>(0);

template<typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> one = static_cast<T>(1);

template<typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> ex = static_cast<T>(2.718281828459045);

template<typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> pi = static_cast<T>(3.141592653589793);

template<typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> tow_pi = static_cast<T>(2) * pi<T>;

template<typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> half_pi = static_cast<T>(0.5) * pi<T>;

template<typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> one_over_pi = one<T> / pi<T>;

}

#endif
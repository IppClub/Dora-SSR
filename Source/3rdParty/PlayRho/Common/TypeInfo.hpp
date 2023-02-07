/*
 * Copyright (c) 2021 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef PLAYRHO_COMMON_TYPEID_HPP
#define PLAYRHO_COMMON_TYPEID_HPP

#include "PlayRho/Common/IndexingNamedType.hpp"
#include "PlayRho/Common/Templates.hpp" // for GetInvalid, IsValid

#include <regex>
#include <string>

namespace playrho {
namespace detail {

template <typename T>
std::string TypeNameAsString()
{
    // Ideally return string unique to the type T...
#if defined(_MSC_VER)
    // template <typename T> string Name() { return string{__FUNCSIG__}; }
    // enum class Fruit {APPLE, PEAR};
    // std::cout << Name<Fruit>() << '\n';
    // produces:
    // class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > __cdecl Name<enum Fruit>(void)
    return std::regex_replace(__FUNCSIG__, std::regex(".* __cdecl [^<]+<(.*)>\\(void\\)"), "$1");
#elif defined(__clang__)
    // template <typename T> string Name() { return string{__PRETTY_FUNCTION__}; }
    // enum class Fruit {APPLE, PEAR};
    // std::cout << Name<Fruit>() << '\n';
    // produces: std::string Name() [T = Fruit]
    return std::regex_replace(__PRETTY_FUNCTION__, std::regex(".*T = (.*)\\].*"), "$1");
#elif defined(__GNUC__)
    // template <typename T> string Name() { return string{__PRETTY_FUNCTION__}; }
    // enum class Fruit {APPLE, PEAR};
    // std::cout << Name<Fruit>() << '\n';
    // produces: std::string Name() [with T = Fruit; std::string = std::__cxx11::basic_string<char>]
    return std::regex_replace(__PRETTY_FUNCTION__, std::regex(".*T = (.*);.*"), "$1");
#else
    return {}; // not unique but maybe still helpful at avoiding compiler issues
#endif
}

/// @brief Gets a null-terminated byte string identifying this function.
/// @note Intended for use by <code>TypeInfo</code> to set the value of its
///    <code>name</code> variable to something dependent on the type and avoid issues
///    like <code>TypeInfo::name</code> being a non-unique address like happens on MSVC
///    when whole program is turned on. Such an issue is documented in Issue #370.
/// @see https://github.com/louis-langholtz/PlayRho/issues/370
template <typename T>
static const char* GetNameForTypeInfo()
{
    static const std::string buffer = TypeNameAsString<T>();
    return buffer.c_str();
}

} // namespace detail

/// @brief Type information.
/// @note Users may specialize this to provide an alternative name for a type.
template <typename T>
struct TypeInfo
{
    /// @brief The name of the templated type.
    /// @note This is also a static member providing a unique ID, via its address, for
    ///   the type T without resorting to using C++ run-time type information (RTTI).
    /// @note Setting this to a null-terminated byte string that's unique to at least the
    ///   template's type <code>T</code> prevents issue #370. Credit for this technique
    ///   goes to Li Jin (github user pigpigyyy).
    /// @see https://github.com/louis-langholtz/PlayRho/issues/370
    static inline const char* name = detail::GetNameForTypeInfo<T>();
};

/// @brief Type identifier.
using TypeID = detail::IndexingNamedType<const char * const *, struct TypeIdentifier>;

/// @brief Invalid type ID value.
constexpr auto InvalidTypeID =
    static_cast<TypeID>(static_cast<TypeID::underlying_type>(nullptr));

/// @brief Gets an invalid value for the TypeID type.
template <>
constexpr TypeID GetInvalid() noexcept
{
    return InvalidTypeID;
}

/// @brief Determines if the given value is valid.
template <>
constexpr bool IsValid(const TypeID& value) noexcept
{
    return value != GetInvalid<TypeID>();
}

/// @brief Gets the type ID for the template parameter type.
template <typename T>
constexpr TypeID GetTypeID()
{
    return TypeID{&TypeInfo<std::decay_t<T>>::name};
}

/// @brief Gets the type ID for the function parameter type.
template <typename T>
constexpr TypeID GetTypeID(T)
{
    return TypeID{&TypeInfo<std::decay_t<T>>::name};
}

/// @brief Gets the name associated with the given type ID.
constexpr const char* GetName(TypeID id) noexcept
{
    return *to_underlying(id);
}

/// @brief Gets the name associated with the given template parameter type.
template <typename T>
constexpr const char* GetTypeName() noexcept
{
    return TypeInfo<T>::name;
}

} // namespace playrho

#endif // PLAYRHO_COMMON_TYPEID_HPP

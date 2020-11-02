/*
 * Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Common/StrongType.hpp"
#include "PlayRho/Common/Templates.hpp" // for GetInvalid, IsValid

namespace playrho {

template <typename T>
constexpr const char* UnqiueName()
{
#ifdef __clang__
    return __PRETTY_FUNCTION__;
#elif defined(__GNUC__)
    return __PRETTY_FUNCTION__;
#elif defined(_MSC_VER)
    return __FUNCSIG__;
#endif
}

/// @brief Type information.
/// @note Users may specialize this for their own types.
template <typename T>
struct TypeInfo
{
    /// @brief The name of the templated type.
    /// @note This is also a static member providing a unique ID, via its address, for
    ///   the type T without resorting to using C++ run-time type information (RTTI).
    static constexpr const char* name = UnqiueName<T>();
};

/// @brief Type info specialization for <code>float</code>.
template <>
struct TypeInfo<float>
{
    /// @brief Provides name of the type as a null-terminated string.
    static constexpr const char* name = "float";
};

/// @brief Type info specialization for <code>double</code>.
template <>
struct TypeInfo<double>
{
    /// @brief Provides name of the type as a null-terminated string.
    static constexpr const char* name = "double";
};

/// @brief Type info specialization for <code>long double</code>.
template <>
struct TypeInfo<long double>
{
    /// @brief Provides name of the type as a null-terminated string.
    static constexpr const char* name = "long double";
};

/// @brief Type identifier.
using TypeID = strongtype::IndexingNamedType<const char * const *, struct TypeIdentifier>;

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
    return *id.get();
}

/// @brief Gets the name associated with the given template parameter type.
template <typename T>
constexpr const char* GetTypeName() noexcept
{
    return TypeInfo<T>::name;
}

} // namespace playrho

#endif // PLAYRHO_COMMON_TYPEID_HPP

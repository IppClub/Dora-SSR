/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_TYPEINFO_HPP
#define PLAYRHO_TYPEINFO_HPP

/// @file
/// @brief Definition of @c TypeID class and closely related code.

#include <cstring> // for std::strcmp
#include <type_traits> // for std::decay_t

// IWYU pragma: begin_exports

#include "playrho/detail/TypeInfo.hpp"

// IWYU pragma: end_exports

namespace playrho {

class TypeID;

/// @brief Gets the type ID for the function's template parameter type with its name demangled.
template <typename T>
TypeID GetTypeID() noexcept;

/// @brief Gets the type ID for the function parameter type with its name demangled.
template <typename T>
TypeID GetTypeID(const T&) noexcept;

/// @brief Type identifier.
/// @note This provides value semantics like being copyable, assignable, and equality comparable.
class TypeID
{
public:
    /// @brief Default constructor.
    /// @post A type identifier equivalent to the value returned by <code>GetTypeID<void>()</code>.
    TypeID() noexcept = default;

    /// Gets demangled name of the type this was generated for as a a non-null, null terminated string buffer.
    constexpr const char* GetName() const noexcept
    {
        return *m_name;
    }

    /// @brief Equality operator support via "hidden friend" function.
    inline friend bool operator==(const TypeID& lhs, const TypeID& rhs) noexcept
    {
        return (lhs.m_name == rhs.m_name) || (std::strcmp(*lhs.m_name, *rhs.m_name) == 0);
    }

    /// @brief Inequality operator support via "hidden friend" function.
    inline friend bool operator!=(const TypeID& lhs, const TypeID& rhs) noexcept
    {
        return !(lhs == rhs);
    }

    /// @brief Less-than operator support via "hidden friend" function.
    /// @note The ordering of type IDs is unspecified. This is provided anyway to support things like associative containers.
    inline friend bool operator<(const TypeID& lhs, const TypeID& rhs) noexcept
    {
        return (lhs.m_name != rhs.m_name) && (std::strcmp(*lhs.m_name, *rhs.m_name) < 0);
    }

    /// @brief Less-than-or-equal operator support via "hidden friend" function.
    /// @note The ordering of type IDs is unspecified. This is provided anyway to support things like associative containers.
    inline friend bool operator<=(const TypeID& lhs, const TypeID& rhs) noexcept
    {
        return (lhs.m_name == rhs.m_name) || (std::strcmp(*lhs.m_name, *rhs.m_name) <= 0);
    }

    /// @brief Greater-than operator support via "hidden friend" function.
    /// @note The ordering of type IDs is unspecified. This is provided anyway to support things like associative containers.
    inline friend bool operator>(const TypeID& lhs, const TypeID& rhs) noexcept
    {
        return !(lhs <= rhs);
    }

    /// @brief Greater-than-or-equal operator support via "hidden friend" function.
    /// @note The ordering of type IDs is unspecified. This is provided anyway to support things like associative containers.
    inline friend bool operator>=(const TypeID& lhs, const TypeID& rhs) noexcept
    {
        return !(lhs < rhs);
    }

    template <typename T>
    friend TypeID GetTypeID() noexcept;

    template <typename T>
    friend TypeID GetTypeID(const T&) noexcept;

private:
    /// @brief Initializing constructor.
    explicit TypeID(const char* const * name) noexcept: m_name{name}
    {
        // Intentionally empty.
    }

    /// @brief A unique, non-null, null-terminated string buffer, naming the type.
    const char* const * m_name{&detail::TypeInfo<void>::name};
};

template <typename T>
TypeID GetTypeID() noexcept
{
    return TypeID{&detail::TypeInfo<std::decay_t<T>>::name};
}

template <typename T>
TypeID GetTypeID(const T&) noexcept
{
    return TypeID{&detail::TypeInfo<std::decay_t<T>>::name};
}

/// @brief Gets the name associated with the given type ID.
inline const char* GetName(const TypeID& id) noexcept
{
    return id.GetName();
}

/// @brief Gets the name associated with the given template parameter type.
template <typename T>
constexpr const char* GetTypeName() noexcept
{
    return GetTypeID<std::decay_t<T>>().GetName();
}

} // namespace playrho

#endif // PLAYRHO_TYPEINFO_HPP

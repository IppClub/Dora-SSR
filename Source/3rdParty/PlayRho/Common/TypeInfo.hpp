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

#ifndef PLAYRHO_COMMON_TYPEID_HPP
#define PLAYRHO_COMMON_TYPEID_HPP

#include "PlayRho/Common/Templates.hpp"

#include <cstring> // for std::strcmp
#include <regex>
#include <string>

// Fall back to requiring run-time type information (RTTI) support on some platforms...
#if !defined(__clang__) && !defined(__GNUC__) && !defined(__FUNCSIG__)
#include <typeindex>
#include <typeinfo>
#endif

namespace playrho {
namespace detail {

/// @brief Gets the template type parameter's type name as a non-empty unique string.
/// @note This string is the demangled name on supporting compilers, otherwise the mangled name is used
///   and C++ run-time type information (RTTI) needs to be available.
/// @note This code relies on the compiler being clang or GCC compatible supporting the <code>__clang__</code>
///   or <code>__GNUC__</code> preprocessor macro and the <code>__PRETTY_FUNCTION__</code>
///   identifier, or the compiler supporting the Microsoft Visual C++ style <code>__FUNCSIG__</code> macro.
///   C++20's support for <code>std::source_location::function_name</code> could help make this function more
///   portable, but only slightly since the returned string's format is still implementation defined.
template <typename T>
std::string TypeNameAsString()
{
    // Ideally return string unique to the type T...
#if defined(__clang__)
    // Use __PRETTY_FUNCTION__. **Note that despite its appearance, this is an identifier; it's not a macro**!
    // template <typename T> string Name() { return string{__PRETTY_FUNCTION__}; }
    // enum class Fruit {APPLE, PEAR};
    // std::cout << Name<Fruit>() << '\n';
    // produces: std::string Name() [T = Fruit]
    return std::regex_replace(__PRETTY_FUNCTION__, // NOLINT(cppcoreguidelines-pro-bounds-array-to-pointer-decay)
                              std::regex(".*T = (.*)\\].*"), "$1");
#elif defined(__GNUC__)
    // Use __PRETTY_FUNCTION__. **Note that despite its appearance, this is an identifier; it's not a macro**!
    // template <typename T> string Name() { return string{__PRETTY_FUNCTION__}; }
    // enum class Fruit {APPLE, PEAR};
    // std::cout << Name<Fruit>() << '\n';
    // produces: std::string Name() [with T = Fruit; std::string = std::__cxx11::basic_string<char>]
    return std::regex_replace(__PRETTY_FUNCTION__, // NOLINT(cppcoreguidelines-pro-bounds-array-to-pointer-decay)
                              std::regex(".*T = (.*);.*"), "$1");
#elif defined(__FUNCSIG__)
    // Assume this is Microsoft Visual C++ or compatible compiler and format.
    // enum class Fruit {APPLE, PEAR};
    // std::cout << Name<Fruit>() << '\n';
    // produces:
    // class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > __cdecl Name<enum Fruit>(void)
    return std::regex_replace(__FUNCSIG__, std::regex(".* __cdecl [^<]+<(.*)>\\(void\\)"), "$1");
#else
    return {typeid(T).name()}; // not demangled but still should be unique and non-empty.
#endif
}

/// @brief Gets a null-terminated byte string identifying this function.
/// @note Intended for use by <code>TypeInfo</code> to set the value of its
///    <code>name</code> variable to something dependent on the type and avoid issues
///    like <code>TypeInfo::name</code> being a non-unique address like happens on MSVC
///    when whole program is turned on. Such an issue is documented in Issue #370.
/// @see https://github.com/louis-langholtz/PlayRho/issues/370
template <typename T>
const char* GetNameForTypeInfo()
{
    static const std::string buffer = TypeNameAsString<T>();
    return buffer.c_str();
}

} // namespace detail

/// @brief Type information.
/// @note Users may specialize this to provide an alternative name for a type so long as the provided
///    name is still non-empty and unique for the application otherwise behavior is undefined.
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
    static inline const char* const name = detail::GetNameForTypeInfo<T>();
};

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
    const char* const * m_name{&TypeInfo<void>::name};
};

template <typename T>
TypeID GetTypeID() noexcept
{
    return TypeID{&TypeInfo<std::decay_t<T>>::name};
}

template <typename T>
TypeID GetTypeID(const T&) noexcept
{
    return TypeID{&TypeInfo<std::decay_t<T>>::name};
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

#endif // PLAYRHO_COMMON_TYPEID_HPP

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

#ifndef PLAYRHO_CHECKEDVALUE_HPP
#define PLAYRHO_CHECKEDVALUE_HPP

#include <iostream>
#include <string>
#include <type_traits>
#include <utility> // for std::declval

#include "playrho/InvalidArgument.hpp"
#include "playrho/Templates.hpp"

namespace playrho {

/// @brief No-op value checker.
/// @details Provides functors ensuring values are the value given.
/// @tparam T Value type to check (or pass-through in this case).
/// @note This is meant to be used as a checker with types like <code>CheckedValue</code>.
/// @see CheckedValue.
template <typename T>
struct NoOpChecker
{
    /// @brief Default value supplying functor.
    constexpr auto operator()() noexcept -> decltype(T())
    {
        return T();
    }

    /// @brief Value checking functor.
    constexpr auto operator()(const T&) noexcept -> const char *
    {
        return nullptr;
    }
};

/// @brief Checked value.
/// @tparam ValueType Type of the underlying value that will get checked.
/// @tparam Checker Checker type to check or possibly transform values with.
/// @tparam NoExcept Whether to terminate or just throw on being invalid.
template <typename ValueType, typename Checker = NoOpChecker<ValueType>, bool NoExcept = false>
class CheckedValue
{
public:
    static_assert(HasUnaryFunctor<Checker, bool, ValueType>::value,
                  "Checker type doesn't provide acceptable unary functor!");

    /// @brief Value type.
    using value_type = ValueType;

    /// @brief Remove pointer type.
    using remove_pointer_type = typename std::remove_pointer<ValueType>::type;

    /// @brief Checker type.
    using checker_type = Checker;

    using exception_type = InvalidArgument;

    static constexpr auto ThrowIfInvalid(const value_type& value)
        -> decltype((void)exception_type(Checker{}(value)), std::declval<void>())
    {
        if (const auto error = Checker{}(value)) {
            throw exception_type(error);
        }
    }

    static constexpr auto Validate(const value_type& value) noexcept(NoExcept)
        -> decltype(ThrowIfInvalid(value), value_type{})
    {
        if constexpr (NoExcept) {
#ifndef NDEBUG // Only verify condition in debug builds
            ThrowIfInvalid(value);
#endif
        }
        else {
            ThrowIfInvalid(value);
        }
        return value;
    }

    /// Default constructor available for checker types with acceptable nullary functors.
    template <bool B = HasNullaryFunctor<Checker,ValueType>::value, typename std::enable_if_t<B, int> = 0>
    constexpr CheckedValue() noexcept(NoExcept):
        m_value{Validate(Checker{}())}
    {
        // Intentionally empty.
    }

    /// @brief Initializing constructor.
    /// @todo Consider marking this function "explicit".
    constexpr CheckedValue(value_type value) noexcept(NoExcept):
        m_value{Validate(value)}
    {
        // Intentionally empty.
    }

    template <bool OtherNoExcept>
    constexpr CheckedValue(const CheckedValue<ValueType, Checker, OtherNoExcept>& other) noexcept:
        m_value{other.get()}
    {
        // Intentionally empty.
    }

    /// @brief Gets the underlying value.
    constexpr value_type get() const noexcept
    {
        return m_value;
    }

    /// @brief Gets the underlying value.
    /// @todo Consider marking this function "explicit".
    constexpr operator value_type () const noexcept
    {
        return m_value;
    }

    /// @brief Member of pointer operator available for pointer <code>ValueType</code>.
    template <typename U = ValueType>
    constexpr std::enable_if_t<std::is_pointer<U>::value, U> operator-> () const
    {
        return m_value;
    }

    /// @brief Indirection operator available for pointer <code>ValueType</code>.
    template <typename U = ValueType>
    constexpr std::enable_if_t<std::is_pointer<U>::value, remove_pointer_type>&
    operator* () const
    {
        return *m_value;
    }

private:
    value_type m_value; ///< Underlying value.
};

// Common operations.

/// @brief Constrained value stream output operator for value types which support it.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept>
auto operator<<(::std::ostream& os, const CheckedValue<ValueType, Checker, NoExcept>& value) ->
    decltype(os << ValueType(value))
{
    return os << ValueType(value);
}

/// @brief Constrained value equality operator for value types which support it.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator== (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                           const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
    noexcept(noexcept(std::declval<LhsValueType>() == std::declval<RhsValueType>()))
-> decltype(LhsValueType(lhs) == RhsValueType(rhs))
{
    return LhsValueType(lhs) == RhsValueType(rhs);
}

/// @brief Constrained value inequality operator for value types which support it.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator!= (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                           const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
    noexcept(noexcept(std::declval<LhsValueType>() != std::declval<RhsValueType>()))
-> decltype(LhsValueType(lhs) != RhsValueType(rhs))
{
    return LhsValueType(lhs) != RhsValueType(rhs);
}

/// @brief Constrained value less-than or equal-to operator.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator<= (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                           const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
-> decltype(LhsValueType(lhs) <= RhsValueType(rhs))
{
    return LhsValueType(lhs) <= RhsValueType(rhs);
}

/// @brief Constrained value greater-than or equal-to operator.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator>= (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                           const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
-> decltype(LhsValueType(lhs) >= RhsValueType(rhs))
{
    return LhsValueType(lhs) >= RhsValueType(rhs);
}

/// @brief Constrained value less-than operator.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator< (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                          const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
-> decltype(LhsValueType(lhs) < RhsValueType(rhs))
{
    return LhsValueType(lhs) < RhsValueType(rhs);
}

/// @brief Constrained value greater-than operator.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator> (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                          const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
-> decltype(LhsValueType(lhs) > RhsValueType(rhs))
{
    return LhsValueType(lhs) > RhsValueType(rhs);
}

/// @brief Constrained value multiplication operator.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator* (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                          const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
-> decltype(LhsValueType(lhs) * RhsValueType(rhs))
{
    return LhsValueType(lhs) * RhsValueType(rhs);
}

/// @brief Constrained value division operator.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator/ (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                          const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
-> decltype(LhsValueType(lhs) / RhsValueType(rhs))
{
    return LhsValueType(lhs) / RhsValueType(rhs);
}

/// @brief Constrained value addition operator.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator+ (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                          const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
-> decltype(LhsValueType(lhs) + RhsValueType(rhs))
{
    return LhsValueType(lhs) + RhsValueType(rhs);
}

/// @brief Constrained value subtraction operator.
/// @tparam LhsValueType Type of the value used by the left hand side checked value.
/// @tparam LhsChecker Type of the checker used by the left hand side checked value.
/// @tparam LhsNoExcept Whether the left hand side checked value terminates or just throws on being invalid.
/// @tparam RhsValueType Type of the value used by the right hand side checked value.
/// @tparam RhsChecker Type of the checker used by the right hand side checked value.
/// @tparam RhsNoExcept Whether the right hand side checked value terminates or just throws on being invalid.
/// @relatedalso CheckedValue
template <typename LhsValueType, typename LhsChecker, bool LhsNoExcept, // force newline
          typename RhsValueType, typename RhsChecker, bool RhsNoExcept>
constexpr auto operator- (const CheckedValue<LhsValueType, LhsChecker, LhsNoExcept>& lhs,
                          const CheckedValue<RhsValueType, RhsChecker, RhsNoExcept>& rhs)
-> decltype(LhsValueType(lhs) - RhsValueType(rhs))
{
    return LhsValueType(lhs) - RhsValueType(rhs);
}

/// @brief Constrained value equality operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator== (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                           const Other& rhs)
-> decltype(ValueType(lhs) == rhs)
{
    return ValueType(lhs) == rhs;
}

/// @brief Constrained value equality operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator== (const Other& lhs,
                           const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(lhs == ValueType(rhs))
{
    return lhs == ValueType(rhs);
}

/// @brief Constrained value inequality operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator!= (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                           const Other& rhs)
-> decltype(ValueType(lhs) != rhs)
{
    return ValueType(lhs) != rhs;
}

/// @brief Constrained value inequality operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator!= (const Other& lhs,
                           const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(lhs != ValueType(rhs))
{
    return lhs != ValueType(rhs);
}

/// @brief Constrained value less-than or equal-to operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator<= (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                           const Other& rhs)
-> decltype(ValueType(lhs) <= ValueType(rhs))
{
    return ValueType(lhs) <= ValueType(rhs);
}

/// @brief Constrained value less-than or equal-to operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator<= (const Other& lhs,
                           const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(ValueType(lhs) <= ValueType(rhs))
{
    return ValueType(lhs) <= ValueType(rhs);
}

/// @brief Constrained value greater-than or equal-to operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator>= (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                           const Other& rhs)
-> decltype(ValueType(lhs) >= ValueType(rhs))
{
    return ValueType(lhs) >= ValueType(rhs);
}

/// @brief Constrained value greater-than or equal-to operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator>= (const Other& lhs,
                           const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(ValueType(lhs) >= ValueType(rhs))
{
    return ValueType(lhs) >= ValueType(rhs);
}


/// @brief Constrained value less-than operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator< (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                          const Other& rhs)
-> decltype(ValueType(lhs) < ValueType(rhs))
{
    return ValueType(lhs) < ValueType(rhs);
}

/// @brief Constrained value less-than operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator< (const Other& lhs,
                          const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(ValueType(lhs) < ValueType(rhs))
{
    return ValueType(lhs) < ValueType(rhs);
}

/// @brief Constrained value greater-than operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator> (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                          const Other& rhs)
-> decltype(ValueType(lhs) > ValueType(rhs))
{
    return ValueType(lhs) > ValueType(rhs);
}

/// @brief Constrained value greater-than ooperator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator> (const Other& lhs,
                          const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(ValueType(lhs) > ValueType(rhs))
{
    return ValueType(lhs) > ValueType(rhs);
}

/// @brief Constrained value multiplication operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator* (const CheckedValue<ValueType, Checker, NoExcept>& lhs, const Other& rhs)
-> std::enable_if_t<!IsMultipliable<CheckedValue<ValueType, Checker, NoExcept>, Other>::value,
decltype(ValueType()*Other())>
{
    return ValueType(lhs) * rhs;
}

/// @brief Constrained value multiplication operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator* (const Other& lhs, const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> std::enable_if_t<!IsMultipliable<Other, CheckedValue<ValueType, Checker, NoExcept>>::value,
decltype(Other()*ValueType())>
{
    return lhs * ValueType(rhs);
}

/// @brief Constrained value division operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator/ (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                          const Other& rhs)
-> decltype(ValueType(lhs) / rhs)
{
    return ValueType(lhs) / rhs;
}

/// @brief Constrained value division operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator/ (const Other& lhs,
                          const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(lhs / ValueType(rhs))
{
    return lhs / ValueType(rhs);
}

/// @brief Constrained value addition operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator+ (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                          const Other& rhs)
-> decltype(ValueType(lhs) + rhs)
{
    return ValueType(lhs) + rhs;
}

/// @brief Constrained value addition operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator+ (const Other& lhs,
                          const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(lhs + ValueType(rhs))
{
    return lhs + ValueType(rhs);
}

/// @brief Constrained value subtraction operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator- (const CheckedValue<ValueType, Checker, NoExcept>& lhs,
                          const Other& rhs)
-> decltype(ValueType(lhs) - rhs)
{
    return ValueType(lhs) - rhs;
}

/// @brief Constrained value subtraction operator.
/// @tparam ValueType Type of the value used by the checked value.
/// @tparam Checker Type of the checker used by the checked value.
/// @tparam NoExcept Whether the checked value terminates or just throws on being invalid.
/// @tparam Other Type of the other value that this operation will operator with.
/// @relatedalso CheckedValue
template <typename ValueType, typename Checker, bool NoExcept, typename Other>
constexpr auto operator- (const Other& lhs,
                          const CheckedValue<ValueType, Checker, NoExcept>& rhs)
-> decltype(lhs - ValueType(rhs))
{
    return lhs - ValueType(rhs);
}

/// @defgroup CheckedValues Checked Value Types
/// @brief Types for checked values.
/// @details Type aliases for checked values via on-construction checks that
///   may throw an exception if an attempt is made to construct the checked value
///   type with a value not allowed by the specific alias.
/// @see CheckedValue

/// @ingroup CheckedValues
/// @brief Default checked value type.
/// @details A checked value type using the default checker type.
/// @note This is basically a no-op for base line testing and demonstration purposes.
template <typename T>
using DefaultCheckedValue = CheckedValue<T>;

} // namespace playrho

#endif // PLAYRHO_CHECKEDVALUE_HPP

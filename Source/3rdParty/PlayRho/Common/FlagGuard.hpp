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

#ifndef PLAYRHO_COMMON_FLAGGUARD_HPP
#define PLAYRHO_COMMON_FLAGGUARD_HPP

#include <type_traits>

namespace playrho {
    
    /// @brief Flag guard type.
    template <typename T>
    class FlagGuard
    {
    public:
        static_assert(std::is_unsigned<T>::value, "Unsigned type required");

        /// @brief Initializing constructor.
        /// @details Sets the given flag variable to the bitwise or of it with the
        ///   given value and then unsets those bits on destruction of this instance.
        /// @param flag Flag variable to set until the destruction of this instance.
        /// @param value Bit value to or with the flag variable on construction.
        FlagGuard(T& flag, T value) : m_flag{flag}, m_value{value}
        {
            m_flag |= m_value;
        }
        
        /// @brief Copy constructor is deleted.
        FlagGuard(const FlagGuard<T>& value) = delete;

        /// @brief Move constructor.
        FlagGuard(FlagGuard<T>&& value) noexcept = default;

        /// @brief Copy assignment operator is deleted.
        FlagGuard<T>& operator= (const FlagGuard<T>& value) = delete;

        /// @brief Move assignment operator.
        FlagGuard<T>& operator= (FlagGuard<T>&& value) noexcept = default;

        /// @brief Destructor.
        /// @details Unsets the bits that were set on construction.
        ~FlagGuard() noexcept
        {
            m_flag &= ~m_value;
        }
        
        FlagGuard() = delete;
        
    private:
        T& m_flag; ///< Flag.
        T m_value; ///< Value.
    };

} // namespace playrho

#endif // PLAYRHO_COMMON_FLAGGUARD_HPP

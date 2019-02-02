/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_FIXEDLIMITS_HPP
#define PLAYRHO_COMMON_FIXEDLIMITS_HPP

#include "PlayRho/Common/Fixed.hpp"

namespace std {

    /// @brief Template specialization of numeric limits for Fixed types.
    /// @sa http://en.cppreference.com/w/cpp/types/numeric_limits
    template <typename BT, unsigned int FB>
	class numeric_limits<playrho::Fixed<BT,FB>>
    {
    public:
        static PLAYRHO_CONSTEXPR const bool is_specialized = true; ///< Type is specialized.
        
        /// @brief Gets the min value available for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed<BT,FB> min() noexcept { return playrho::Fixed<BT,FB>::GetMin(); }
        
        /// @brief Gets the max value available for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed<BT,FB> max() noexcept    { return playrho::Fixed<BT,FB>::GetMax(); }
        
        /// @brief Gets the lowest value available for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed<BT,FB> lowest() noexcept { return playrho::Fixed<BT,FB>::GetLowest(); }
        
        /// @brief Number of radix digits that can be represented.
        static PLAYRHO_CONSTEXPR const int digits = playrho::Fixed<BT,FB>::WholeBits - 1;
        
        /// @brief Number of decimal digits that can be represented.
        static PLAYRHO_CONSTEXPR const int digits10 = playrho::Fixed<BT,FB>::WholeBits - 1;
        
        /// @brief Number of decimal digits necessary to differentiate all values.
        static PLAYRHO_CONSTEXPR const int max_digits10 = 5; // TODO(lou): check this
        
        static PLAYRHO_CONSTEXPR const bool is_signed = true; ///< Identifies signed types.
        static PLAYRHO_CONSTEXPR const bool is_integer = false; ///< Identifies integer types.
        static PLAYRHO_CONSTEXPR const bool is_exact = true; ///< Identifies exact type.
        static PLAYRHO_CONSTEXPR const int radix = 0; ///< Radix used by the type.
        
        /// @brief Gets the epsilon value for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed32 epsilon() noexcept { return playrho::Fixed<BT,FB>{0}; } // TODO(lou)
        
        /// @brief Gets the round error value for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed32 round_error() noexcept { return playrho::Fixed<BT,FB>{0}; } // TODO(lou)
        
        /// @brief One more than smallest negative power of the radix that's a valid
        ///    normalized floating-point value.
        static PLAYRHO_CONSTEXPR const int min_exponent = 0;
        
        /// @brief Smallest negative power of ten that's a valid normalized floating-point value.
        static PLAYRHO_CONSTEXPR const int min_exponent10 = 0;
        
        /// @brief One more than largest integer power of radix that's a valid finite
        ///   floating-point value.
        static PLAYRHO_CONSTEXPR const int max_exponent = 0;
        
        /// @brief Largest integer power of 10 that's a valid finite floating-point value.
        static PLAYRHO_CONSTEXPR const int max_exponent10 = 0;
        
        static PLAYRHO_CONSTEXPR const bool has_infinity = true; ///< Whether can represent infinity.
        static PLAYRHO_CONSTEXPR const bool has_quiet_NaN = true; ///< Whether can represent quiet-NaN.
        static PLAYRHO_CONSTEXPR const bool has_signaling_NaN = false; ///< Whether can represent signaling-NaN.
        static PLAYRHO_CONSTEXPR const float_denorm_style has_denorm = denorm_absent; ///< <code>Denorm</code> style used.
        static PLAYRHO_CONSTEXPR const bool has_denorm_loss = false; ///< Has <code>denorm</code> loss amount.
        
        /// @brief Gets the infinite value for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed<BT,FB> infinity() noexcept { return playrho::Fixed<BT,FB>::GetInfinity(); }
        
        /// @brief Gets the quiet NaN value for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed<BT,FB> quiet_NaN() noexcept { return playrho::Fixed<BT,FB>::GetNaN(); }
        
        /// @brief Gets the signaling NaN value for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed<BT,FB> signaling_NaN() noexcept { return playrho::Fixed<BT,FB>{0}; }
        
        /// @brief Gets the <code>denorm</code> value for the type.
        static PLAYRHO_CONSTEXPR inline playrho::Fixed<BT,FB> denorm_min() noexcept { return playrho::Fixed<BT,FB>{0}; }
        
        static PLAYRHO_CONSTEXPR const bool is_iec559 = false; ///< @brief Not an IEEE 754 floating-point type.
        static PLAYRHO_CONSTEXPR const bool is_bounded = true; ///< Type bounded: has limited precision.
        static PLAYRHO_CONSTEXPR const bool is_modulo = false; ///< Doesn't modulo arithmetic overflows.
        
        static PLAYRHO_CONSTEXPR const bool traps = false; ///< Doesn't do traps.
        static PLAYRHO_CONSTEXPR const bool tinyness_before = false; ///< Doesn't detect <code>tinyness</code> before rounding.
        static PLAYRHO_CONSTEXPR const float_round_style round_style = round_toward_zero; ///< Rounds down.
    };
    
} // namespace std

#endif // PLAYRHO_COMMON_FIXEDLIMITS_HPP

/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

/**
 * @file
 * @brief Types and default settings file.
 */

#ifndef PLAYRHO_COMMON_SETTINGS_HPP
#define PLAYRHO_COMMON_SETTINGS_HPP

#include <cstddef>
#include <cassert>
#include <cfloat>
#include <cmath>
#include <cstdint>
#include <algorithm>

#include "PlayRho/Common/Templates.hpp"
#include "PlayRho/Common/RealConstants.hpp"
#include "PlayRho/Common/Units.hpp"
#include "PlayRho/Common/Wider.hpp"

namespace playrho {
namespace detail {

/// @brief Defaults object for real types.
template <typename T>
struct Defaults
{
    /// @brief Gets the linear slop.
    static PLAYRHO_CONSTEXPR inline auto GetLinearSlop() noexcept
    {
        // Return the value used by Box2D 2.3.2 b2_linearSlop define....
        return 0.005_m;
    }
    
    /// @brief Gets the max vertex radius.
    static PLAYRHO_CONSTEXPR inline auto GetMaxVertexRadius() noexcept
    {
        // DefaultLinearSlop * Real{2 * 1024 * 1024};
        // linearSlop * 2550000
        return 255_m;
    }
};

/// @brief Specialization of defaults object for fixed point types.
template <unsigned int FRACTION_BITS>
struct Defaults<Fixed<std::int32_t,FRACTION_BITS>>
{
    /// @brief Gets the linear slop.
    static PLAYRHO_CONSTEXPR inline auto GetLinearSlop() noexcept
    {
        // Needs to be big enough that the step tolerance doesn't go to zero.
        // ex: FRACTION_BITS==10, then divisor==256
        return Length{1_m / Real{(1u << (FRACTION_BITS - 2))}};
    }
    
    /// @brief Gets the max vertex radius.
    static PLAYRHO_CONSTEXPR inline auto GetMaxVertexRadius() noexcept
    {
        // linearSlop * 2550000
        return Length{Real(1u << (28 - FRACTION_BITS)) * 1_m};
    }
};

} // namespace detail

/// @brief Maximum number of supportable edges in a simplex.
PLAYRHO_CONSTEXPR const auto MaxSimplexEdges = std::uint8_t{3};

/// @brief Max child count.
PLAYRHO_CONSTEXPR const auto MaxChildCount = std::numeric_limits<std::uint32_t>::max() >> 6;

/// @brief Child counter type.
/// @details Relating to "children" of shape where each child is a convex shape possibly
///   comprising a concave shape.
/// @note This type must always be able to contain the <code>MaxChildCount</code> value.
using ChildCounter = std::remove_const<decltype(MaxChildCount)>::type;

/// Time step iterations type.
/// @details A type for counting iterations per time-step.
using TimestepIters = std::uint8_t;

/// @brief Maximum float value.
PLAYRHO_CONSTEXPR const auto MaxFloat = std::numeric_limits<Real>::max(); // FLT_MAX

// Collision

/// Maximum manifold points.
/// This is the maximum number of contact points between two convex shapes.
/// Do not change this value.
/// @note For memory efficiency, uses the smallest integral type that can hold the value. 
PLAYRHO_CONSTEXPR const auto MaxManifoldPoints = std::uint8_t{2};

/// @brief Maximum number of vertices for any shape type.
/// @note For memory efficiency, uses the smallest integral type that can hold the value minus
///   one that's left out as a sentinel value.
PLAYRHO_CONSTEXPR const auto MaxShapeVertices = std::uint8_t{254};

/// @brief Vertex count type.
/// @note This type must not support more than 255 vertices as that would conflict
///   with the <code>ContactFeature::Index</code> type.
using VertexCounter = std::remove_const<decltype(MaxShapeVertices)>::type;

/// @brief Invalid vertex index.
PLAYRHO_CONSTEXPR const auto InvalidVertex = static_cast<VertexCounter>(-1);

/// @brief Default linear slop.
/// @details Length used as a collision and constraint tolerance.
///   Usually chosen to be numerically significant, but visually insignificant.
///   Lower or raise to decrease or increase respectively the minimum of space
///   between bodies at rest.
/// @note Smaller values relative to sizes of bodies increases the time it takes
///   for bodies to come to rest.
PLAYRHO_CONSTEXPR const auto DefaultLinearSlop = detail::Defaults<Real>::GetLinearSlop();

/// @brief Default minimum vertex radius.
PLAYRHO_CONSTEXPR const auto DefaultMinVertexRadius = DefaultLinearSlop * Real{2};

/// @brief Default maximum vertex radius.
PLAYRHO_CONSTEXPR const auto DefaultMaxVertexRadius = detail::Defaults<Real>::GetMaxVertexRadius();

/// @brief Default AABB extension amount.
PLAYRHO_CONSTEXPR const auto DefaultAabbExtension = DefaultLinearSlop * Real{20};

/// @brief Default distance multiplier.
PLAYRHO_CONSTEXPR const auto DefaultDistanceMultiplier = Real{2};

/// @brief Default angular slop.
/// @details
/// A small angle used as a collision and constraint tolerance. Usually it is
/// chosen to be numerically significant, but visually insignificant.
PLAYRHO_CONSTEXPR const auto DefaultAngularSlop = (Pi * 2_rad) / Real{180};

/// @brief Default maximum linear correction.
/// @details The maximum linear position correction used when solving constraints.
///   This helps to prevent overshoot.
/// @note This value should be greater than the linear slop value.
PLAYRHO_CONSTEXPR const auto DefaultMaxLinearCorrection = 0.2_m;

/// @brief Default maximum angular correction.
/// @note This value should be greater than the angular slop value.
PLAYRHO_CONSTEXPR const auto DefaultMaxAngularCorrection = Real(8.0f / 180.0f) * Pi * 1_rad;

/// @brief Default maximum translation amount.
PLAYRHO_CONSTEXPR const auto DefaultMaxTranslation = 2_m;

/// @brief Default maximum rotation per world step.
/// @warning This value should be less than Pi * Radian.
/// @note This limit is meant to prevent numerical problems. Adjusting this value isn't advised.
/// @sa StepConf::maxRotation.
PLAYRHO_CONSTEXPR const auto DefaultMaxRotation = Angle{Pi * 1_rad / Real(2)};

/// @brief Default maximum time of impact iterations.
PLAYRHO_CONSTEXPR const auto DefaultMaxToiIters = std::uint8_t{20};

/// Default maximum time of impact root iterator count.
PLAYRHO_CONSTEXPR const auto DefaultMaxToiRootIters = std::uint8_t{30};

/// Default max number of distance iterations.
PLAYRHO_CONSTEXPR const auto DefaultMaxDistanceIters = std::uint8_t{20};

/// Default maximum number of sub steps.
/// @details
/// This is the default maximum number of sub-steps per contact in continuous physics simulation.
/// In other words, this is the default maximum number of times in a world step that a contact will
/// have continuous collision resolution done for it.
/// @note Used in the TOI phase of step processing.
PLAYRHO_CONSTEXPR const auto DefaultMaxSubSteps = std::uint8_t{8};
    
// Dynamics

/// @brief Default velocity threshold.
PLAYRHO_CONSTEXPR const auto DefaultVelocityThreshold = 1_mps;

/// @brief Default regular-phase minimum momentum.
PLAYRHO_CONSTEXPR const auto DefaultRegMinMomentum = Momentum{0_Ns / 100};

/// @brief Default TOI-phase minimum momentum.
PLAYRHO_CONSTEXPR const auto DefaultToiMinMomentum = Momentum{0_Ns / 100};

/// @brief Maximum number of bodies in a world.
/// @note This is 65534 based off <code>std::uint16_t</code> and eliminating one value for invalid.
PLAYRHO_CONSTEXPR const auto MaxBodies = static_cast<std::uint16_t>(std::numeric_limits<std::uint16_t>::max() -
                                                      std::uint16_t{1});

/// @brief Body count type.
/// @note This type must always be able to contain the <code>MaxBodies</code> value.
using BodyCounter = std::remove_const<decltype(MaxBodies)>::type;

/// @brief Contact count type.
/// @note This type must be able to contain the squared value of <code>BodyCounter</code>.
using ContactCounter = Wider<BodyCounter>::type;

/// @brief Invalid contact index.
PLAYRHO_CONSTEXPR const auto InvalidContactIndex = static_cast<ContactCounter>(-1);

/// @brief Maximum number of contacts in a world (2147319811).
/// @details Uses the formula for the maximum number of edges in an unidirectional graph of
///   <code>MaxBodies</code> nodes.
/// This occurs when every possible body is connected to every other body.
PLAYRHO_CONSTEXPR const auto MaxContacts = ContactCounter{MaxBodies} * ContactCounter{MaxBodies - 1} / ContactCounter{2};

/// @brief Maximum number of joints in a world.
/// @note This is 65534 based off <code>std::uint16_t</code> and eliminating one value for invalid.
PLAYRHO_CONSTEXPR const auto MaxJoints = static_cast<std::uint16_t>(std::numeric_limits<std::uint16_t>::max() -
                                                      std::uint16_t{1});

/// @brief Joint count type.
/// @note This type must be able to contain the <code>MaxJoints</code> value.
using JointCounter = std::remove_const<decltype(MaxJoints)>::type;

/// @brief Default step time.
PLAYRHO_CONSTEXPR const auto DefaultStepTime = Time{1_s / 60};

/// @brief Default step frequency.
PLAYRHO_CONSTEXPR const auto DefaultStepFrequency = 60_Hz;

// Sleep

/// Default minimum still time to sleep.
/// @details The default minimum time bodies must be still for bodies to be put to sleep.
PLAYRHO_CONSTEXPR const auto DefaultMinStillTimeToSleep = Time{1_s / 2}; // aka 0.5 secs

/// Default linear sleep tolerance.
/// @details A body cannot sleep if the magnitude of its linear velocity is above this amount.
PLAYRHO_CONSTEXPR const auto DefaultLinearSleepTolerance = 0.01_mps; // aka 0.01

/// Default angular sleep tolerance.
/// @details A body cannot sleep if its angular velocity is above this amount.
PLAYRHO_CONSTEXPR const auto DefaultAngularSleepTolerance = Real{(Pi * 2) / 180} * RadianPerSecond;

/// Default circles ratio.
/// @details Ratio used for switching between rounded-corner collisions and closest-face
///   biased normal collisions.
PLAYRHO_CONSTEXPR const auto DefaultCirclesRatio = Real{10};

} // namespace playrho

#endif // PLAYRHO_COMMON_SETTINGS_HPP

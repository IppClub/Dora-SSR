/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_STEPCONF_HPP
#define PLAYRHO_STEPCONF_HPP

/// @file
/// @brief Declarations of the StepConf class, and free functions associated with it.

#include <type_traits> // for std::is_default_constructible_v

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"
#include "playrho/Positive.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Step configuration.
/// @details
/// Provides the primary means for configuring the per-step world physics simulation. All
/// the values have defaults. These defaults are intended to most likely be the values desired.
/// @note Be sure to confirm that the delta time (the time-per-step i.e. <code>deltaTime</code>)
///   is correct for your use.
/// @see World::Step.
struct StepConf {
    /// @brief Step iterations type.
    /// @details A type for counting iterations per-step.
    /// @note The special value of -1 is reserved for signifying an invalid iteration value.
    using iteration_type = TimestepIters;

    /// @brief Invalid iteration value.
    static constexpr auto InvalidIteration = static_cast<iteration_type>(-1);

    /// @brief Default step time.
    static constexpr auto DefaultStepTime = Time{playrho::DefaultStepTime};

    /// @brief Default delta time ratio.
    static constexpr auto DefaultDtRatio = Real(1);

    /// @brief Default min still time to sleep.
    static constexpr auto DefaultMinStillTimeToSleep = Time{playrho::DefaultMinStillTimeToSleep};

    /// @brief Default linear slop.
    /// @see DefaultTargetDepth, DefaultTolerance.
    static constexpr auto DefaultLinearSlop = Positive<Length>{playrho::DefaultLinearSlop};

    /// @brief Default angular slop.
    static constexpr auto DefaultAngularSlop = Positive<Angle>{playrho::DefaultAngularSlop};

    /// @brief Default regular resolution rate.
    static constexpr auto DefaultRegResolutionRate = Real(2) / 10; // aka 0.2.;

    /// @brief Default regular min separation.
    static constexpr auto DefaultRegMinSeparation = -playrho::DefaultLinearSlop * Real(3);

    /// @brief Default regular min momentum.
    static constexpr auto DefaultRegMinMomentum = Momentum{playrho::DefaultRegMinMomentum};

    /// @brief Default time of impact (TOI) resolution rate.
    static constexpr auto DefaultToiResolutionRate = Real(75) / 100; // aka .75

    /// @brief Default time of impact (TOI) min separation.
    static constexpr auto DefaultToiMinSeparation = -playrho::DefaultLinearSlop * Real(1.5f);

    /// @brief Default time of impact (TOI) min momemtum.
    static constexpr auto DefaultToiMinMomentum = Momentum{playrho::DefaultToiMinMomentum};

    /// @brief Default target depth.
    /// @see DefaultLinearSlop.
    static constexpr auto DefaultTargetDepth = NonNegative<Length>{DefaultLinearSlop * Real(3)};

    /// @brief Default tolerance.
    /// @see DefaultLinearSlop.
    static constexpr auto DefaultTolerance = NonNegative<Length>{DefaultLinearSlop / Real(4)};

    /// @brief Default velocity threshold.
    static constexpr auto DefaultVelocityThreshold = LinearVelocity{playrho::DefaultVelocityThreshold};

    /// @brief Default max translation.
    static constexpr auto DefaultMaxTranslation = Length{playrho::DefaultMaxTranslation};

    /// @brief Default max rotation.
    static constexpr auto DefaultMaxRotation = Angle{playrho::DefaultMaxRotation};

    /// @brief Default max linear correction.
    static constexpr auto DefaultMaxLinearCorrection = Length{playrho::DefaultMaxLinearCorrection};

    /// @brief Default max angular correction.
    static constexpr auto DefaultMaxAngularCorrection = Angle{playrho::DefaultMaxAngularCorrection};

    /// @brief Default linear sleep tolerance.
    static constexpr auto DefaultLinearSleepTolerance = LinearVelocity{playrho::DefaultLinearSleepTolerance};

    /// @brief Default angular sleep tolerance.
    static constexpr auto DefaultAngularSleepTolerance = AngularVelocity{playrho::DefaultAngularSleepTolerance};

    /// @brief Default distance multiplier.
    static constexpr auto DefaultDistanceMultiplier = Real(playrho::DefaultDistanceMultiplier);

    /// @brief Default abstract aligned bounding box (AABB) extension.
    static constexpr auto DefaultAabbExtension = Length{playrho::DefaultAabbExtension};

    /// @brief Default curcles ratio.
    static constexpr auto DefaultCirclesRatio = Real(playrho::DefaultCirclesRatio);

    /// @brief Default regular velocity iterations.
    static constexpr auto DefaultRegVelocityIters = iteration_type{8};

    /// @brief Default regular position iterations.
    static constexpr auto DefaultRegPositionIters = iteration_type{3};

    /// @brief Default time of impact velocity iterations.
    static constexpr auto DefaultToiVelocityIters = iteration_type{8};

    /// @brief Default time of impact position iterations.
    static constexpr auto DefaultToiPositionIters = iteration_type{20};

    /// @brief Default max time of impact root iterations.
    static constexpr auto DefaultMaxToiRootIters = iteration_type{playrho::DefaultMaxToiRootIters};

    /// @brief Default max time of impact iterations.
    static constexpr auto DefaultMaxToiIters = iteration_type{playrho::DefaultMaxToiIters};

    /// @brief Default max distance iterations.
    static constexpr auto DefaultMaxDistanceIters = iteration_type{playrho::DefaultMaxDistanceIters};

    /// @brief Default max sub-steps value.
    static constexpr auto DefaultMaxSubSteps = iteration_type{playrho::DefaultMaxSubSteps};

    /// @brief Default do warm start processing.
    static constexpr auto DefaultDoWarmStart = true;

    /// @brief Default do time of impact (TOI) processing.
    static constexpr auto DefaultDoToi = true;

    /// @brief Default do block-solve processing value .
    static constexpr auto DefaultDoBlocksolve = true;

    /// @brief Delta time.
    /// @details This is the time step in seconds.
    Time deltaTime = DefaultStepTime;

    /// @brief Delta time ratio.
    /// @details This is the delta-time multiplied by the inverse delta time from the previous
    ///    world step. The value of 1 indicates that the time step has not varied.
    /// @note Used in the regular phase processing of the step.
    Real dtRatio = DefaultDtRatio;

    /// @brief Minimum still time to sleep.
    /// @details The time that a body must be still before it will be put to sleep.
    /// @note Set to infinity to disable sleeping.
    /// @note Used in the regular phase processing of the step.
    Time minStillTimeToSleep = DefaultMinStillTimeToSleep;

    /// @brief Linear slop.
    /// @details Linear slop for position resolution.
    /// @note Used in both the regular and TOI phases of step processing.
    Positive<Length> linearSlop = DefaultLinearSlop;

    /// @brief Angular slop.
    /// @note Used in both the regular and TOI phases of step processing.
    Positive<Angle> angularSlop = DefaultAngularSlop;

    /// @brief Regular resolution rate.
    /// @details
    /// This scale factor controls how fast positional overlap is resolved.
    /// Ideally this would be 1 so that overlap is removed in one time step.
    /// However using values close to 1 often lead to overshoot.
    /// @note Must be greater than 0 for any regular-phase positional resolution to get done.
    /// @note Used in the regular phase of step processing.
    Real regResolutionRate = DefaultRegResolutionRate;

    /// @brief Regular minimum separation.
    /// @details
    /// This is the minimum amount of separation there must be between regular-phase interacting
    /// bodies for intra-step position resolution to be considered successful and end before all
    /// of the regular position iterations have been done.
    /// @note Used in the regular phase of step processing.
    /// @see regPositionIterations.
    Length regMinSeparation = DefaultRegMinSeparation;

    /// @brief Regular-phase minimum momentum.
    Momentum regMinMomentum = DefaultRegMinMomentum;

    /// @brief Time of impact resolution rate.
    /// @details
    /// This scale factor controls how fast positional overlap is resolved.
    /// Ideally this would be 1 so that overlap is removed in one time step.
    /// However using values close to 1 often lead to overshoot.
    /// @note Used in the TOI phase of step processing.
    /// @note Must be greater than 0 for any TOI-phase positional resolution to get done.
    Real toiResolutionRate = DefaultToiResolutionRate;

    /// @brief Time of impact minimum separation.
    /// @details
    /// This is the minimum amount of separation there must be between TOI-phase interacting
    /// bodies for intra-step position resolution to be considered successful and end before all
    /// of the TOI position iterations have been done.
    /// @note Used in the TOI phase of step processing.
    /// @see toiPositionIterations.
    Length toiMinSeparation = DefaultToiMinSeparation;

    /// @brief TOI-phase minimum momentum.
    Momentum toiMinMomentum = DefaultToiMinMomentum;

    /// @brief Target depth.
    /// @details Target depth of overlap for calculating the TOI for CCD eligible bodies.
    /// @note Recommend value that's less than twice the world's minimum vertex radius.
    /// @note Used in the TOI phase of step processing.
    NonNegative<Length> targetDepth = DefaultTargetDepth;

    /// @brief Tolerance.
    /// @details The acceptable plus or minus tolerance from the target depth for TOI calculations.
    /// @note Must not be subnormal.
    /// @note Should be less than the target depth (<code>targetDepth</code>).
    /// @note Used in the TOI phase of step processing.
    /// @see targetDepth.
    NonNegative<Length> tolerance = DefaultTolerance;

    /// @brief Velocity threshold.
    /// @details A velocity threshold for elastic collisions. Any collision with a relative linear
    /// velocity below this threshold will be treated as inelastic.
    /// @note Used in both the regular and TOI phases of step processing.
    LinearVelocity velocityThreshold = DefaultVelocityThreshold;

    /// @brief Maximum translation.
    ///
    /// @details The maximum amount a body can translate in a single step. This represents
    ///   an upper bound on the maximum linear velocity of a body of max-translation per time.
    ///
    /// @note If you want or need to support a higher maximum linear speed, then instead
    ///   of changing this value, decrease the step's time value. So for example, rather
    ///   than simulating 1/60th of a second steps, simulating 1/120th of a second steps
    ///   will double the maximum linear speed any body can have.
    /// @note This limit is meant to prevent numerical problems. Adjusting this value
    ///   isn't advised.
    /// @note Used in both the regular and TOI phases of step processing.
    ///
    Length maxTranslation = DefaultMaxTranslation;

    /// @brief Maximum rotation.
    ///
    /// @details The maximum amount a body can rotate in a single step. This represents
    ///   an upper bound on the maximum angular speed of a body of max rotation / time.
    ///
    /// @warning This value should be less than Pi * Radian.
    ///
    /// @note If you want or need to support a higher maximum angular speed, then instead
    ///   of changing this value, decrease the step's time value. So for example, rather
    ///   than simulating 1/60th of a second steps, simulating 1/120th of a second steps
    ///   will double the maximum angular rotation any body can have.
    /// @note This limit is meant to prevent numerical problems. Adjusting this value
    ///   isn't advised.
    /// @note If this value is less than half a turn (less than Pi), then the turning
    ///   direction will be the direction of the smaller change in angular orientation.
    ///   This is an appealing property as it means that a body's angular position
    ///   can be represented by a unit vector rather than an angular quantity. The
    ///   benefit of using a unit vector is potentially two-fold: (a) unit vectors
    ///   have well-defined and understood wrap-around semantics, (b) unit vectors
    ///   can cache sine/cosine calculations thereby reducing their costs in time.
    /// @note Used in both the regular and TOI phases of step processing.
    ///
    Angle maxRotation = DefaultMaxRotation;

    /// @brief Maximum linear correction.
    /// @note Must be greater than 0 for any positional resolution to get done.
    /// @note This value should be greater than the linear slop value.
    /// @note Used in both the regular and TOI phases of step processing.
    Length maxLinearCorrection = DefaultMaxLinearCorrection;

    /// @brief Maximum angular correction.
    /// @note Used in both the regular and TOI phases of step processing.
    Angle maxAngularCorrection = DefaultMaxAngularCorrection;

    /// @brief Linear sleep tolerance.
    /// @note Used in the regular phase of step processing.
    LinearVelocity linearSleepTolerance = DefaultLinearSleepTolerance;

    /// @brief Angular sleep tolerance.
    /// @note Used in the regular phase of step processing.
    AngularVelocity angularSleepTolerance = DefaultAngularSleepTolerance;

    /// @brief Displacement multiplier for directional AABB fattening.
    Real displaceMultiplier = DefaultDistanceMultiplier;

    /// @brief AABB extension.
    /// @details This is the extension that will be applied to Axis Aligned Bounding Box
    ///    objects used in broad phase collision detection. This fattens AABBs in the
    ///    dynamic tree. This allows proxies to move by a small amount without triggering
    ///    a tree adjustment.
    /// @note Should be greater than 0.
    Length aabbExtension = DefaultAabbExtension;

    /// @brief Max. circles ratio.
    /// @details When the ratio of the closest face's length to the vertex radius is
    ///   more than this amount, then face-manifolds are forced, else circles-manifolds
    ///   may be computed for new contact manifolds.
    /// @note This is used in the calculation of new contact manifolds.
    Real maxCirclesRatio = DefaultCirclesRatio;

    /// @brief Regular velocity iterations.
    /// @details The number of iterations of velocity resolution that will be done in the step.
    /// @note Used in the regular phase of step processing.
    iteration_type regVelocityIters = DefaultRegVelocityIters;

    /// @brief Regular position iterations.
    /// @details
    /// This is the maximum number of iterations of position resolution that will
    /// be done before leaving any remaining unsatisfied positions for the next step.
    /// In this context, positions are satisfied when the minimum separation is greater than
    /// or equal to the regular minimum separation amount.
    /// @note Used in the regular phase of step processing.
    /// @see regMinSeparation.
    iteration_type regPositionIters = DefaultRegPositionIters;

    /// @brief TOI velocity iterations.
    /// @details
    /// This is the number of iterations of velocity resolution that will be done in the step.
    /// @note Used in the TOI phase of step processing.
    iteration_type toiVelocityIters = DefaultToiVelocityIters;

    /// @brief TOI position iterations.
    /// @details
    /// This value is the maximum number of iterations of position resolution that will
    /// be done before leaving any remaining unsatisfied positions for the next step.
    /// In this context, positions are satisfied when the minimum separation is greater than
    /// or equal to the TOI minimum separation amount.
    /// @note Used in the TOI phase of step processing.
    /// @see toiMinSeparation.
    iteration_type toiPositionIters = DefaultToiPositionIters;

    /// @brief Max TOI root finder iterations.
    /// @note Used in the TOI phase of step processing.
    iteration_type maxToiRootIters = DefaultMaxToiRootIters;

    /// @brief Max TOI iterations.
    /// @note Used in the TOI phase of step processing.
    iteration_type maxToiIters = DefaultMaxToiIters;

    /// @brief Max distance iterations.
    /// @note Used in the TOI phase of step processing.
    iteration_type maxDistanceIters = DefaultMaxDistanceIters;

    /// @brief Maximum sub steps.
    /// @details
    /// This is the maximum number of sub-steps per contact in continuous physics simulation.
    /// In other words, this is the maximum number of times in a world step that a contact will
    /// have continuous collision resolution done for it.
    /// @note Used in the TOI phase of step processing.
    iteration_type maxSubSteps = DefaultMaxSubSteps;

    /// @brief Do warm start.
    /// @details Whether or not to perform warm starting (in the regular phase).
    /// @note Used in the regular phase of step processing.
    bool doWarmStart = DefaultDoWarmStart;

    /// @brief Do time of impact (TOI) calculations.
    /// @details Whether or not to perform any time of impact (TOI) calculations used for doing
    ///   continuous collision detection. Without this, steps can potentially be computed
    ///   faster but with increased chance of bodies passing unobstructed through other bodies
    ///   (a process called "tunneling") even when they're not supposed to be able to go through
    ///   them.
    /// @note Used in the TOI phase of step processing.
    bool doToi = DefaultDoToi;

    /// @brief Do the block-solve algorithm.
    bool doBlocksolve = DefaultDoBlocksolve;
};

// Basic requirements...
static_assert(std::is_default_constructible_v<StepConf>);
static_assert(std::is_copy_constructible_v<StepConf>);

/// @brief Gets the maximum regular linear correction from the given value.
/// @relatedalso StepConf
inline Length GetMaxRegLinearCorrection(const StepConf& conf) noexcept
{
    return conf.maxLinearCorrection * static_cast<Real>(conf.regPositionIters);
}

/// @brief Determines whether the maximum translation is within tolerance.
/// @relatedalso StepConf
bool IsMaxTranslationWithinTolerance(const StepConf& conf) noexcept;

} // namespace playrho

#endif // PLAYRHO_STEPCONF_HPP

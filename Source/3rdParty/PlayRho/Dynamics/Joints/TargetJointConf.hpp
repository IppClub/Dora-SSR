/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_MOUSEJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_MOUSEJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {
namespace d2 {

class TargetJoint;
class Body;

/// @brief Target joint definition.
/// @details This requires a world target point, tuning parameters, and the time step.
struct TargetJointConf : public JointBuilder<TargetJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<TargetJointConf>;
    
    PLAYRHO_CONSTEXPR inline TargetJointConf() noexcept: super{JointType::Target} {}

    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline TargetJointConf(NonNull<Body*> b) noexcept: super{super{JointType::Target}.UseBodyB(b)}
    {
        // Intentionally empty.
    }
    
    /// @brief Use value for target.
    PLAYRHO_CONSTEXPR inline TargetJointConf& UseTarget(Length2 v) noexcept;

    /// @brief Use value for max force.
    PLAYRHO_CONSTEXPR inline TargetJointConf& UseMaxForce(NonNegative<Force> v) noexcept;

    /// @brief Use value for frequency.
    PLAYRHO_CONSTEXPR inline TargetJointConf& UseFrequency(NonNegative<Frequency> v) noexcept;

    /// @brief Use value for damping ratio.
    PLAYRHO_CONSTEXPR inline TargetJointConf& UseDampingRatio(NonNegative<Real> v) noexcept;

    /// The initial world target point. This is assumed
    /// to coincide with the body anchor initially.
    Length2 target = Length2{};
    
    /// Max force.
    /// @details
    /// The maximum constraint force that can be exerted
    /// to move the candidate body. Usually you will express
    /// as some multiple of the weight (multiplier * mass * gravity).
    /// @note This may not be negative.
    NonNegative<Force> maxForce = NonNegative<Force>{0_N};
    
    /// Frequency.
    /// @details The has to do with the response speed.
    /// @note This value may not be negative.
    NonNegative<Frequency> frequency = NonNegative<Frequency>(5_Hz);
    
    /// The damping ratio. 0 = no damping, 1 = critical damping.
    NonNegative<Real> dampingRatio = NonNegative<Real>(0.7f);
};

PLAYRHO_CONSTEXPR inline TargetJointConf& TargetJointConf::UseTarget(Length2 v) noexcept
{
    target = v;
    return *this;
}

PLAYRHO_CONSTEXPR inline TargetJointConf& TargetJointConf::UseMaxForce(NonNegative<Force> v) noexcept
{
    maxForce = v;
    return *this;
}

PLAYRHO_CONSTEXPR inline TargetJointConf& TargetJointConf::UseFrequency(NonNegative<Frequency> v) noexcept
{
    frequency = v;
    return *this;
}

PLAYRHO_CONSTEXPR inline TargetJointConf& TargetJointConf::UseDampingRatio(NonNegative<Real> v) noexcept
{
    dampingRatio = v;
    return *this;
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso TargetJoint
TargetJointConf GetTargetJointConf(const TargetJoint& joint) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_MOUSEJOINTCONF_HPP

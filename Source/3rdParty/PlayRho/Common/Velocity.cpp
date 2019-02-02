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

#include "PlayRho/Common/Velocity.hpp"
#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Dynamics/Contacts/VelocityConstraint.hpp"

namespace playrho {
namespace d2 {

VelocityPair CalcWarmStartVelocityDeltas(const VelocityConstraint& vc)
{
    auto vp = VelocityPair{
        Velocity{LinearVelocity2{}, 0_rpm},
        Velocity{LinearVelocity2{}, 0_rpm}
    };
    
    const auto normal = vc.GetNormal();
    const auto tangent = vc.GetTangent();
    const auto pointCount = vc.GetPointCount();
    const auto bodyA = vc.GetBodyA();
    const auto bodyB = vc.GetBodyB();

    const auto invMassA = bodyA->GetInvMass();
    const auto invRotInertiaA = bodyA->GetInvRotInertia();
    
    const auto invMassB = bodyB->GetInvMass();
    const auto invRotInertiaB = bodyB->GetInvRotInertia();
    
    for (auto j = decltype(pointCount){0}; j < pointCount; ++j)
    {
        // inverse moment of inertia : L^-2 M^-1 QP^2
        // P is M L T^-2
        // GetPointRelPosA() is Length2
        // Cross(Length2, P) is: M L^2 T^-2
        // L^-2 M^-1 QP^2 M L^2 T^-2 is: QP^2 T^-2
        const auto& vcp = vc.GetPointAt(j);
        const auto P = vcp.normalImpulse * normal + vcp.tangentImpulse * tangent;
        const auto LA = Cross(vcp.relA, P) / Radian;
        const auto LB = Cross(vcp.relB, P) / Radian;
        std::get<0>(vp) -= Velocity{invMassA * P, invRotInertiaA * LA};
        std::get<1>(vp) += Velocity{invMassB * P, invRotInertiaB * LB};
    }
    
    return vp;
}

} // namespace d2
} // namespace playrho

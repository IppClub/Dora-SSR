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

#ifndef PLAYRHO_DYNAMICS_JOINTATTY_HPP
#define PLAYRHO_DYNAMICS_JOINTATTY_HPP

/// @file
/// Declaration of the JointAtty class.

#include "PlayRho/Dynamics/Joints/Joint.hpp"

namespace playrho {
namespace d2 {

/// @brief Joint attorney.
///
/// @details This is the "joint attorney" which provides limited privileged access to the
///   Joint class for the World class.
///
/// @note This class uses the "attorney-client" idiom to control the granularity of
///   friend-based access to the Joint class. This is meant to help preserve and enforce
///   the invariants of the Joint class.
///
/// @sa https://en.wikibooks.org/wiki/More_C++_Idioms/Friendship_and_the_Attorney-Client
///
class JointAtty
{
private:
    /// @brief Creates a new joint based on the given definition.
    /// @throws InvalidArgument if given a joint definition with a type that's not recognized.
    static Joint* Create(const JointConf &def)
    {
        return Joint::Create(def);
    }
    
    /// @brief Destroys the given joint.
    static void Destroy(const Joint* j) noexcept
    {
        Joint::Destroy(j);
    }
    
    /// @brief Initializes the velocity constraints for the given joint with the given data.
    static void InitVelocityConstraints(Joint& j, BodyConstraintsMap &bodies,
                                        const StepConf &step,
                                        const ConstraintSolverConf &conf)
    {
        j.InitVelocityConstraints(bodies, step, conf);
    }
    
    /// @brief Solves the velocity constraints for the given joint with the given data.
    static bool SolveVelocityConstraints(Joint& j, BodyConstraintsMap &bodies,
                                         const StepConf &conf)
    {
        return j.SolveVelocityConstraints(bodies, conf);
    }
    
    /// @brief Solves the position constraints for the given joint with the given data.
    static bool SolvePositionConstraints(Joint& j, BodyConstraintsMap &bodies,
                                         const ConstraintSolverConf &conf)
    {
        return j.SolvePositionConstraints(bodies, conf);
    }
    
    /// @brief Whether the given joint is in the is-in-island state.
    static bool IsIslanded(const Joint& j) noexcept
    {
        return j.IsIslanded();
    }
    
    /// @brief Sets the given joint to being in the is-in-island state.
    static void SetIslanded(Joint& j) noexcept
    {
        j.SetIslanded();
    }
    
    /// @brief Unsets the given joint from being in the is-in-island state.
    static void UnsetIslanded(Joint& j) noexcept
    {
        j.UnsetIslanded();
    }
    
    friend class World;
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTATTY_HPP

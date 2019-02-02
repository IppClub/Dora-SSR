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

#ifndef PLAYRHO_DYNAMICS_JOINTS_FUNCTIONALJOINTVISITOR_HPP
#define PLAYRHO_DYNAMICS_JOINTS_FUNCTIONALJOINTVISITOR_HPP

#include "PlayRho/Dynamics/Joints/JointVisitor.hpp"
#include <functional>
#include <tuple>
#include <utility>

namespace playrho {
namespace d2 {

/// @brief Functional joint visitor class.
/// @note This class is intended to provide an alternate interface for visiting joints
///   via the use of lambdas instead of having to subclass <code>JointVisitor</code>.
class FunctionalJointVisitor: public JointVisitor
{
public:
    /// @brief Procedure alias.
    template <class T>
    using Proc = std::function<void(T)>;
    
    //using Tuple = std::tuple<Proc<Types>...>;
    //FunctionalJointVisitor(const Tuple& v): procs{v} {}
    
    /// @brief Tuple alias.
    using Tuple = std::tuple<
        Proc<const RevoluteJoint&>,
        Proc<      RevoluteJoint&>,
        Proc<const PrismaticJoint&>,
        Proc<      PrismaticJoint&>,
        Proc<const DistanceJoint&>,
        Proc<      DistanceJoint&>,
        Proc<const PulleyJoint&>,
        Proc<      PulleyJoint&>,
        Proc<const TargetJoint&>,
        Proc<      TargetJoint&>,
        Proc<const GearJoint&>,
        Proc<      GearJoint&>,
        Proc<const WheelJoint&>,
        Proc<      WheelJoint&>,
        Proc<const WeldJoint&>,
        Proc<      WeldJoint&>,
        Proc<const FrictionJoint&>,
        Proc<      FrictionJoint&>,
        Proc<const RopeJoint&>,
        Proc<      RopeJoint&>,
        Proc<const MotorJoint&>,
        Proc<      MotorJoint&>
    >;

    Tuple procs; ///< Procedures.

    /// @brief Uses given procedure.
    /// @note Provide a builder pattern mutator method.
    template <class T>
    FunctionalJointVisitor& Use(const Proc<T>& proc) noexcept
    {
        std::get<Proc<T>>(procs) = proc;
        return *this;
    }
    
    // Overrides of all the base class's Visit methods...
    // Uses decltype to ensure the correctly typed invocation of the Handle method.
    void Visit(const RevoluteJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(RevoluteJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const PrismaticJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(PrismaticJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const DistanceJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(DistanceJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const PulleyJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(PulleyJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const TargetJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(TargetJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const GearJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(GearJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const WheelJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(WheelJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const WeldJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(WeldJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const FrictionJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(FrictionJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const RopeJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(RopeJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(const MotorJoint& arg) override { Handle<decltype(arg)>(arg); }
    void Visit(MotorJoint& arg) override { Handle<decltype(arg)>(arg); }

private:

    /// @brief Handles the joint through the established function.
    template <class T>
    inline void Handle(T arg) const
    {
        const auto& proc = std::get<Proc<T>>(procs);
        if (proc)
        {
            proc(arg);
        }
    }
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_FUNCTIONALJOINTVISITOR_HPP


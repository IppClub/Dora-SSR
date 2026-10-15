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

#ifndef PLAYRHO_D2_CODEDUMPER_HPP
#define PLAYRHO_D2_CODEDUMPER_HPP

#ifdef CODE_DUMPER_IS_READY

#include "playrho/Settings.hpp"

namespace playrho {
namespace d2 {

class World;
class Body;
class Joint;
struct DistanceJointConf;
struct FrictionJointConf;
struct GearJointConf;
struct MotorJointConf;
struct TargetJointConf;
struct PrismaticJointConf;
struct PulleyJointConf;
struct RevoluteJointConf;
struct RopeJointConf;
struct WeldJointConf;
struct WheelJointConf;

/// Dump the world into the log file.
/// @warning this should be called outside of a time step.
void Dump(const World& world);

/// Dump body to a log file.
void Dump(const Body& body, std::size_t bodyIndex);

/// Dump joint to the log file.
void Dump(const Joint& joint, std::size_t index, const World& world);

/// Dump joint to log file.
void Dump(const DistanceJointConf& joint, std::size_t index, const World& world);

/// Dump joint to the log file.
void Dump(const FrictionJointConf& joint, std::size_t index, const World& world);

/// @brief Dumps the joint to the log file.
void Dump(const GearJointConf& joint, std::size_t index, const World& world);

/// @brief Dumps the joint to the log file.
void Dump(const MotorJointConf& joint, std::size_t index, const World& world);

/// @brief Dumps the joint to the log file.
void Dump(const TargetJointConf& joint, std::size_t index, const World& world);

/// @brief Dumps the joint to the log file.
void Dump(const PrismaticJointConf& joint, std::size_t index, const World& world);

/// Dump joint to log file.
void Dump(const PulleyJointConf& joint, std::size_t index, const World& world);

/// @brief Dumps the joint to the log file.
void Dump(const RevoluteJointConf& joint, std::size_t index, const World& world);

/// @brief Dumps the joint to the log file.
void Dump(const RopeJointConf& joint, std::size_t index, const World& world);

/// @brief Dumps the joint to the log file.
void Dump(const WeldJointConf& joint, std::size_t index, const World& world);

/// @brief Dumps the joint to the log file.
void Dump(const WheelJointConf& joint, std::size_t index, const World& world);

} // namespace d2
} // namespace playrho

#endif // CODE_DUMPER_IS_READY

#endif // PLAYRHO_D2_CODEDUMPER_HPP

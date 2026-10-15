/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_BASICAPI_HPP
#define PLAYRHO_D2_BASICAPI_HPP

/// @file
/// @brief Basic API include file to pull in at once most headers used.

// IWYU pragma: begin_exports

// For purists, just include this first file.
#include "playrho/d2/World.hpp"

// For pragmatists, add these for free function interfaces to the world and some additional
// functionality. Note that using these free function interfaces, instead of directly using
// world member functions, may help isolate your code from changes to the World class.
#include "playrho/d2/WorldMisc.hpp"
#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/WorldShape.hpp"
#include "playrho/d2/WorldJoint.hpp"
#include "playrho/d2/WorldContact.hpp"

// For any and all shape configurations, add one or more of the following.
#include "playrho/d2/ChainShapeConf.hpp"
#include "playrho/d2/DiskShapeConf.hpp"
#include "playrho/d2/EdgeShapeConf.hpp"
#include "playrho/d2/MultiShapeConf.hpp"
#include "playrho/d2/PolygonShapeConf.hpp"
#include "playrho/d2/Transformation.hpp"
#include "playrho/d2/part/Compositor.hpp"

// For any and all joint configurations, add one or more of the following.
#include "playrho/d2/DistanceJointConf.hpp"
#include "playrho/d2/FrictionJointConf.hpp"
#include "playrho/d2/GearJointConf.hpp"
#include "playrho/d2/MotorJointConf.hpp"
#include "playrho/d2/TargetJointConf.hpp"
#include "playrho/d2/PrismaticJointConf.hpp"
#include "playrho/d2/PulleyJointConf.hpp"
#include "playrho/d2/RevoluteJointConf.hpp"
#include "playrho/d2/RopeJointConf.hpp"
#include "playrho/d2/WeldJointConf.hpp"
#include "playrho/d2/WheelJointConf.hpp"

// IWYU pragma: end_exports

#endif // PLAYRHO_D2_BASICAPI_HPP

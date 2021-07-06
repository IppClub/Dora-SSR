/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_PLAYRHO_HPP
#define PLAYRHO_PLAYRHO_HPP

/**
@mainpage PlayRho API Documentation

@section intro_sec Overview

Hello and welcome to PlayRho's API documentation!

PlayRho is an interactive, real-time oriented, C++ based, physics engine and library
 currently best suited for 2-dimensional games. To view its source code, please
 see: https://github.com/louis-langholtz/PlayRho. For issues,
 visit: https://github.com/louis-langholtz/PlayRho/issues.
 For mathematical insight into how a physics engine works, see:
 <a href="http://box2d.org/files/GDC2009/GDC2009_Catto_Erin_Solver.ppt">Erin Catto's
 2009 Modeling and Solving Constraints slides</a>.

@section coding_sec Getting Started

For coding, purists may want to begin by just including the
 <code>World.hpp</code> header file and making an instance of the
 <a href="classplayrho_1_1d2_1_1World.html"><code>playrho::d2::World</code></a> class.
 Here's what this might look like:
 @code
 #include "PlayRho/Dynamics/World.hpp"

 int main()
 {
     auto world = playrho::d2::World{};
     const auto body = world.CreateBody();
     // do more things with the world instance and body identifier.
     return 0; // world and associated resources go away automatically
 }
 @endcode
Pragmatists may instead want to begin by including this file, <code>PlayRho.hpp</code>,
 which includes headers for most of the entire PlayRho public API.

@section helloworld_sec An Entire Application

For a more elaborate example, that's of an entire application, see
 <a href="HelloWorld_8cpp-example.html"><code>HelloWorld.cpp</code></a>.

 @see playrho::d2::World, PhysicalEntities
*/

// These include files constitute the main PlayRho API

/// @defgroup TestPointGroup Point Containment Test Functions
/// @brief Collection of functions testing for a point's containment within various objects.

/// @defgroup ExceptionsGroup Library Defined Exceptions
/// @brief Exceptions defined and used by the PlayRho library.
/// @details The PlayRho library defines its own exception classes to recognize errors.
///    These classes are all sub-classed from sub-classes of the C++ Standard Library
///    std::exception class.

/// @defgroup ConstraintsGroup Library Defined Constraints
/// @brief Constraints defined and used by the PlayRho library.
/// @details Constraints remove degrees of freedom from bodies.
///   A 2D body has 3 degrees of freedom: two translation coordinates and one rotation
///   coordinate. If we take a body and pin it to the wall (like a pendulum) we have
///   constrained the body to the wall. At this point the body can only rotate about the
///   pin, so the constraint has removed 2 degrees of freedom.

/// @namespace std
/// Name space for specializations of the standard library.

/// @namespace playrho
/// Name space for all PlayRho related names.

/// @namespace playrho::d2
/// Name space for 2-dimensionally related PlayRho names.

/// @namespace playrho::detail
/// Name space for internal/detail related PlayRho names.

// For purists, just include this first file.
#include "PlayRho/Dynamics/World.hpp"

// For pragmatists, add these for free function interfaces to the world and some additional
// functionality. Note that using these free function interfaces, instead of directly using
// world member functions, may help isolate your code from changes to the World class.
#include "PlayRho/Dynamics/WorldMisc.hpp"
#include "PlayRho/Dynamics/WorldBody.hpp"
#include "PlayRho/Dynamics/WorldShape.hpp"
#include "PlayRho/Dynamics/WorldJoint.hpp"
#include "PlayRho/Dynamics/WorldContact.hpp"

// For any and all shape configurations, add one or more of the following.
#include "PlayRho/Collision/Shapes/ChainShapeConf.hpp"
#include "PlayRho/Collision/Shapes/DiskShapeConf.hpp"
#include "PlayRho/Collision/Shapes/EdgeShapeConf.hpp"
#include "PlayRho/Collision/Shapes/MultiShapeConf.hpp"
#include "PlayRho/Collision/Shapes/PolygonShapeConf.hpp"
#include "PlayRho/Collision/Shapes/Compositor.hpp"

// For any and all joint configurations, add one or more of the following.
#include "PlayRho/Dynamics/Joints/DistanceJointConf.hpp"
#include "PlayRho/Dynamics/Joints/FrictionJointConf.hpp"
#include "PlayRho/Dynamics/Joints/GearJointConf.hpp"
#include "PlayRho/Dynamics/Joints/MotorJointConf.hpp"
#include "PlayRho/Dynamics/Joints/TargetJointConf.hpp"
#include "PlayRho/Dynamics/Joints/PrismaticJointConf.hpp"
#include "PlayRho/Dynamics/Joints/PulleyJointConf.hpp"
#include "PlayRho/Dynamics/Joints/RevoluteJointConf.hpp"
#include "PlayRho/Dynamics/Joints/RopeJointConf.hpp"
#include "PlayRho/Dynamics/Joints/WeldJointConf.hpp"
#include "PlayRho/Dynamics/Joints/WheelJointConf.hpp"

#endif // PLAYRHO_PLAYRHO_HPP

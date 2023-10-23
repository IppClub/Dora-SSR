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

#include "playrho/d2/AabbTreeWorld.hpp"
#include "playrho/d2/AabbTreeWorldBody.hpp"
#include "playrho/d2/Body.hpp"
#include "playrho/d2/BodyConf.hpp"

namespace playrho::d2 {

BodyID CreateBody(AabbTreeWorld& world, const BodyConf& def)
{
    return CreateBody(world, Body{def});
}

void Attach(AabbTreeWorld& world, BodyID id, ShapeID shapeID)
{
    auto body = GetBody(world, id);
    body.Attach(shapeID);
    SetBody(world, id, body);
}

bool Detach(AabbTreeWorld& world, BodyID id, ShapeID shapeID)
{
    auto body = GetBody(world, id);
    if (body.Detach(shapeID)) {
        SetBody(world, id, body);
        return true;
    }
    return false;
}

const std::vector<ShapeID>& GetShapes(const AabbTreeWorld& world, BodyID id)
{
    return GetBody(world, id).GetShapes();
}

} // namespace playrho::d2

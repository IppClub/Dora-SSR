/*
 * Original work Copyright (c) 2007-2009 Erin Catto http://www.box2d.org
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

#include "playrho/d2/PointStates.hpp"
#include "playrho/d2/Manifold.hpp"

namespace playrho::d2 {

PointStates GetPointStates(const Manifold& manifold1, const Manifold& manifold2) noexcept
{
    auto retval = PointStates{};

    // Detect persists and removes.
    for (auto i = decltype(manifold1.GetPointCount()){0}; i < manifold1.GetPointCount(); ++i)
    {
        const auto cf = manifold1.GetContactFeature(i);
        retval.state1[i] = PointState::Remove;
        for (auto j = decltype(manifold2.GetPointCount()){0}; j < manifold2.GetPointCount(); ++j)
        {
            if (manifold2.GetContactFeature(j) == cf)
            {
                retval.state1[i] = PointState::Persist;
                break;
            }
        }
    }

    // Detect persists and adds.
    for (auto i = decltype(manifold2.GetPointCount()){0}; i < manifold2.GetPointCount(); ++i)
    {
        const auto cf = manifold2.GetContactFeature(i);
        retval.state2[i] = PointState::Add;
        for (auto j = decltype(manifold1.GetPointCount()){0}; j < manifold1.GetPointCount(); ++j)
        {
            if (manifold1.GetContactFeature(j) == cf)
            {
                retval.state2[i] = PointState::Persist;
                break;
            }
        }
    }
    
    return retval;
}

}

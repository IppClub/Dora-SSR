/*********************************************************************
Matt Marchant 2016 - 2023
http://trederia.blogspot.com

tmxlite - Zlib license.

This software is provided 'as-is', without any express or
implied warranty. In no event will the authors be held
liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute
it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented;
you must not claim that you wrote the original software.
If you use this software in a product, an acknowledgment
in the product documentation would be appreciated but
is not required.

2. Altered source versions must be plainly marked as such,
and must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any
source distribution.
*********************************************************************/

#ifdef USE_EXTLIBS
#include <pugixml.hpp>
#else
#include "detail/pugixml.hpp"
#endif
#include "tmxlite/FreeFuncs.hpp"
#include "tmxlite/ObjectGroup.hpp"
#include "tmxlite/detail/Log.hpp"

using namespace tmx;

ObjectGroup::ObjectGroup()
    : m_colour    (127, 127, 127, 255),
    m_drawOrder (DrawOrder::TopDown)
{

}

//public
void ObjectGroup::parse(const pugi::xml_node& node, Map* map)
{
    assert(map);

    std::string attribString = node.name();
    if (attribString != "objectgroup")
    {
        Logger::log("Node was not an object group, node will be skipped.", Logger::Type::Error);
        return;
    }

    setName(node.attribute("name").as_string());
    setClass(node.attribute("class").as_string());

    attribString = node.attribute("color").as_string();
    if (!attribString.empty())
    {
        m_colour = colourFromString(attribString);
    }

    setOpacity(node.attribute("opacity").as_float(1.f));
    setVisible(node.attribute("visible").as_bool(true));
    setOffset(node.attribute("offsetx").as_int(0), node.attribute("offsety").as_int(0));
    setSize(node.attribute("width").as_uint(0), node.attribute("height").as_uint(0));
    setParallaxFactor(node.attribute("parallaxx").as_float(1.f), node.attribute("parallaxy").as_float(1.f));

    std::string tintColour = node.attribute("tintcolor").as_string();
    if (!tintColour.empty())
    {
        setTintColour(colourFromString(tintColour));
    }

    attribString = node.attribute("draworder").as_string();
    if (attribString == "index")
    {
        m_drawOrder = DrawOrder::Index;
    }

    for (const auto& child : node.children())
    {
        attribString = child.name();
        if (attribString == "properties")
        {
            for (const auto& p : child)
            {
                m_properties.emplace_back();
                m_properties.back().parse(p);
            }
        }
        else if (attribString == "object")
        {
            m_objects.emplace_back();
            m_objects.back().parse(child, map);
        }
    }
}

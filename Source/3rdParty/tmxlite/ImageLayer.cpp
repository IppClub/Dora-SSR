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
#include "tmxlite/ImageLayer.hpp"
#include "tmxlite/FreeFuncs.hpp"
#include "tmxlite/detail/Log.hpp"

using namespace tmx;

ImageLayer::ImageLayer(const std::string& workingDir)
    : m_workingDir      (workingDir),
    m_hasTransparency   (false),
    m_hasRepeatX        (false),
    m_hasRepeatY        (false)
{

}

//public
void ImageLayer::parse(const pugi::xml_node& node, Map*)
{
    std::string attribName = node.name();
    if (attribName != "imagelayer")
    {
        Logger::log("Node not an image layer, node skipped", Logger::Type::Error);
        return;
    }

    //TODO this gets repeated foreach layer type and could all be moved to base class...
    setName(node.attribute("name").as_string());
    setClass(node.attribute("class").as_string());
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

    m_hasRepeatX = node.attribute("repeatx").as_bool(false);
    m_hasRepeatY = node.attribute("repeaty").as_bool(false);

    for (const auto& child : node.children())
    {
        attribName = child.name();
        if (attribName == "image")
        {
            attribName = child.attribute("source").as_string();
            if (attribName.empty())
            {
                Logger::log("Image Layer has missing source property", Logger::Type::Warning);
                return;
            }

            if (child.attribute("width") &&  child.attribute("height"))
            {
                m_imageSize.x = child.attribute("width").as_uint();
                m_imageSize.y = child.attribute("height").as_uint();
            }

            m_filePath = resolveFilePath(attribName, m_workingDir);
            if (child.attribute("trans"))
            {
                attribName = child.attribute("trans").as_string();
                m_transparencyColour = colourFromString(attribName);
                m_hasTransparency = true;
            }
        }
        else if (attribName == "properties")
        {
            for (const auto& p : child.children())
            {
                addProperty(p);
            }
        }
    }
}

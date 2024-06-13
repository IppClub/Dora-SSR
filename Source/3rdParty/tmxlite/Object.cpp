/*********************************************************************
Matt Marchant 2016 - 2021
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
#include "tmxlite/Object.hpp"
#include "tmxlite/FreeFuncs.hpp"
#include "tmxlite/Map.hpp"
#include "tmxlite/Tileset.hpp"
#include "tmxlite/detail/Log.hpp"

#include "Const/Header.h"
#include "Basic/Content.h"
#include "Common/Utils.h"

#include <sstream>

using namespace tmx;

Object::Object()
    : m_UID     (0),
    m_rotation  (0.f),
    m_tileID    (0),
    m_flipFlags (0),
    m_visible   (true),
    m_shape     (Shape::Rectangle)
{

}

//public
void Object::parse(const pugi::xml_node& node, Map* map)
{
    std::string attribString = node.name();
    if (attribString != "object")
    {
        Logger::log("This not an Object node, parsing skipped.", Logger::Type::Error);
        return;
    }

    m_UID = node.attribute("id").as_int();
    m_name = node.attribute("name").as_string();

    m_class = node.attribute("type").as_string();
    if (m_class.empty())
    {
        m_class = node.attribute("class").as_string();
    }
    
    m_position.x = node.attribute("x").as_float();
    m_AABB.left = m_position.x;
    m_position.y = node.attribute("y").as_float();
    m_AABB.top = m_position.y;
    m_AABB.width = node.attribute("width").as_float();
    m_AABB.height = node.attribute("height").as_float();
    m_rotation = node.attribute("rotation").as_float();
    m_visible = node.attribute("visible").as_bool(true);

    m_tileID = node.attribute("gid").as_uint();

    static const std::uint32_t mask = 0xf0000000;
    m_flipFlags = ((m_tileID & mask) >> 28);
    m_tileID = m_tileID & ~mask;

    for (const auto& child : node.children())
    {
        attribString = child.name();
        if (attribString == "properties")
        {
            for (const auto& p : child.children())
            {
                m_properties.emplace_back();
                m_properties.back().parse(p);
            }
        }
        else if (attribString == "ellipse")
        {
            m_shape = Shape::Ellipse;
        }
        else if (attribString == "point")
        {
            m_shape = Shape::Point;
        }
        else if (attribString == "polygon")
        {
            m_shape = Shape::Polygon;
            parsePoints(child);
        }
        else if (attribString == "polyline")
        {
            m_shape = Shape::Polyline;
            parsePoints(child);
        }
        else if (attribString == "text")
        {
            m_shape = Shape::Text;
            parseText(child);
        }
    }

    //parse templates last so we know which properties
    //ought to be overridden
    std::string templateStr = node.attribute("template").as_string();
    if (!templateStr.empty() && map)
    {
        parseTemplate(templateStr, map);
    }
}

//private
void Object::parsePoints(const pugi::xml_node& node)
{
    if (node.attribute("points"))
    {
        std::string pointlist = node.attribute("points").as_string();
        std::stringstream stream(pointlist);
        std::vector<std::string> points;
        std::string pointstring;
        while (std::getline(stream, pointstring, ' '))
        {
            points.push_back(pointstring);
        }

        //parse each pair into sf::vector2f
        for (unsigned int i = 0; i < points.size(); i++)
        {
            std::vector<float> coords;
            std::stringstream coordstream(points[i]);

            float j;
            while (coordstream >> j)
            {
                coords.push_back(j);
                //TODO this should really ignore anything non-numeric
                if (coordstream.peek() == ',')
                {
                    coordstream.ignore();
                }
            }
            m_points.emplace_back(coords[0], coords[1]);
        }
    }
    else
    {
        Logger::log("Points for polygon or polyline object are missing", Logger::Type::Warning);
    }
}

void Object::parseText(const pugi::xml_node& node)
{
    m_textData.bold = node.attribute("bold").as_bool(false);
    m_textData.colour = colourFromString(node.attribute("color").as_string("#FFFFFFFF"));
    m_textData.fontFamily = node.attribute("fontfamily").as_string();
    m_textData.italic = node.attribute("italic").as_bool(false);
    m_textData.kerning = node.attribute("kerning").as_bool(true);
    m_textData.pixelSize = node.attribute("pixelsize").as_uint(16);
    m_textData.strikethough = node.attribute("strikeout").as_bool(false);
    m_textData.underline = node.attribute("underline").as_bool(false);
    m_textData.wrap = node.attribute("wrap").as_bool(false);

    std::string alignment = node.attribute("halign").as_string("left");
    if (alignment == "left")
    {
        m_textData.hAlign = Text::HAlign::Left;
    }
    else if (alignment == "center")
    {
        m_textData.hAlign = Text::HAlign::Centre;
    }
    else if (alignment == "right")
    {
        m_textData.hAlign = Text::HAlign::Right;
    }

    alignment = node.attribute("valign").as_string("top");
    if (alignment == "top")
    {
        m_textData.vAlign = Text::VAlign::Top;
    }
    else if (alignment == "center")
    {
        m_textData.vAlign = Text::VAlign::Centre;
    }
    else if (alignment == "bottom")
    {
        m_textData.vAlign = Text::VAlign::Bottom;
    }

    m_textData.content = node.text().as_string();
}

void Object::parseTemplate(const std::string& path, Map* map)
{
    assert(map);

    auto& templateObjects = map->getTemplateObjects();
    auto& templateTilesets = map->getTemplateTilesets();

    //load the template if not already loaded
    if (templateObjects.count(path) == 0)
    {
        auto templatePath = Dora::Path::concat({map->getWorkingDirectory(), path});

        int64_t size = 0;
        auto data = r_cast<char*>(SharedContent.loadUnsafe(templatePath, size));
        if (!data) {
            Logger::log("Failed reading template file " + path, Logger::Type::Error);
            return;
        }
        pugi::xml_document doc;
        if (!doc.load_buffer(data, size))
        {
            Logger::log("Failed opening template file " + path, Logger::Type::Error);
            return;
        }

        auto templateNode = doc.child("template");
        if (!templateNode)
        {
            Logger::log("Template node missing from " + path, Logger::Type::Error);
            return;
        }

        //if the template has a tileset load that (if not already loaded)
        std::string tilesetName;
        auto tileset = templateNode.child("tileset");
        if (tileset)
        {
            tilesetName = tileset.attribute("source").as_string();
            if (!tilesetName.empty() &&
                templateTilesets.count(tilesetName) == 0)
            {
                templateTilesets.insert(std::make_pair(tilesetName, Tileset(map->getWorkingDirectory())));
                templateTilesets.at(tilesetName).parse(tileset, map);
            }
        }

        //parse the object - don't pass the map pointer here so there's
        //no recursion if someone tried to get clever and put a template in a template
        auto obj = templateNode.child("object");
        if (obj)
        {
            templateObjects.insert(std::make_pair(path, Object()));
            templateObjects[path].parse(obj, nullptr);
            templateObjects[path].m_tilesetName = tilesetName;
        }
    }

    //apply any non-overridden object properties from the template
    if (templateObjects.count(path) != 0)
    {
        const auto& obj = templateObjects[path];
        if (m_AABB.width == 0)
        {
            m_AABB.width = obj.m_AABB.width;
        }

        if (m_AABB.height == 0)
        {
            m_AABB.height = obj.m_AABB.height;
        }
        
        m_tilesetName = obj.m_tilesetName;

        if (m_name.empty())
        {
            m_name = obj.m_name;
        }

        if (m_class.empty())
        {
            m_class = obj.m_class;
        }

        if (m_rotation == 0)
        {
            m_rotation = obj.m_rotation;
        }

        if (m_tileID == 0)
        {
            m_tileID = obj.m_tileID;
        }

        if (m_flipFlags == 0)
        {
            m_flipFlags = obj.m_flipFlags;
        }

        if (m_shape == Shape::Rectangle)
        {
            m_shape = obj.m_shape;
        }

        if (m_points.empty())
        {
            m_points = obj.m_points;
        }

        //compare properties and only copy ones that don't exist
        for (const auto& p : obj.m_properties)
        {
            auto result = std::find_if(m_properties.begin(), m_properties.end(), 
                [&p](const Property& a)
                {
                    return a.getName() == p.getName();
                });

            if (result == m_properties.end())
            {
                m_properties.push_back(p);
            }
        }


        if (m_shape == Shape::Text)
        {
            //check each text property and update as necessary
            //TODO this makes he assumption we prefer the template
            //properties over the default ones - this might not
            //actually be the case....
            const auto& otherText = obj.m_textData;
            if (m_textData.fontFamily.empty())
            {
                m_textData.fontFamily = otherText.fontFamily;
            }

            if (m_textData.pixelSize == 16)
            {
                m_textData.pixelSize = otherText.pixelSize;
            }

            //TODO this isn't actually right if we *want* to be false
            //and the template is set to true...
            if (m_textData.wrap == false)
            {
                m_textData.wrap = otherText.wrap;
            }

            if (m_textData.colour == Colour())
            {
                m_textData.colour = otherText.colour;
            }

            if (m_textData.bold == false)
            {
                m_textData.bold = otherText.bold;
            }

            if (m_textData.italic == false)
            {
                m_textData.italic = otherText.italic;
            }

            if (m_textData.underline == false)
            {
                m_textData.underline = otherText.underline;
            }

            if (m_textData.strikethough == false)
            {
                m_textData.strikethough = otherText.strikethough;
            }

            if (m_textData.kerning == true)
            {
                m_textData.kerning = otherText.kerning;
            }

            if (m_textData.hAlign == Text::HAlign::Left)
            {
                m_textData.hAlign = otherText.hAlign;
            }

            if (m_textData.vAlign == Text::VAlign::Top)
            {
                m_textData.vAlign = otherText.vAlign;
            }

            if (m_textData.content.empty())
            {
                m_textData.content = otherText.content;
            }
        }
    }
}

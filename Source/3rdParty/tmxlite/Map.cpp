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
#include "tmxlite/Map.hpp"
#include "tmxlite/FreeFuncs.hpp"
#include "tmxlite/ObjectGroup.hpp"
#include "tmxlite/ImageLayer.hpp"
#include "tmxlite/TileLayer.hpp"
#include "tmxlite/LayerGroup.hpp"
#include "tmxlite/detail/Log.hpp"
#include "tmxlite/detail/Android.hpp"

#include "Const/Header.h"
#include "Basic/Content.h"
#include "Common/Async.h"

#include <queue>

using namespace tmx;

Map::Map()
    : m_orientation (Orientation::None),
    m_renderOrder   (RenderOrder::None),
    m_infinite      (false),
    m_hexSideLength (0.f),
    m_staggerAxis   (StaggerAxis::None),
    m_staggerIndex  (StaggerIndex::None)
{

}

//public
bool Map::load(const std::string& path)
{
    bool success = false;
    SharedContent.getThread()->runInMainSync([&]() {
        success = loadUnsafe(path);
    });
    return success;
}

bool Map::loadUnsafe(const std::string& path)
{
    reset();

    int64_t size = 0;
    auto data = r_cast<char*>(SharedContent.loadUnsafe(path, size));
    if (!data) {
        Logger::log("Failed reading file " + path, Logger::Type::Error);
        return false;
    }
    //open the doc
    pugi::xml_document doc;
    auto result = doc.load_buffer(data, size);
    if (!result)
    {
        Logger::log("Failed opening " + path, Logger::Type::Error);
        Logger::log("Reason: " + std::string(result.description()), Logger::Type::Error);
        return false;
    }

	m_workingDirectory = getFilePath(path);


    //find the map node and bail if it doesn't exist
    auto mapNode = doc.child("map");
    if (!mapNode)
    {
        Logger::log("Failed opening map: " + path + ", no map node found", Logger::Type::Error);
        return reset();
    }

    return parseMapNode(mapNode);
}

bool Map::loadFromString(const std::string& data, const std::string& workingDir)
{
    bool success = false;
    SharedContent.getThread()->runInMainSync([&]() {
        success = loadFromStringUnsafe(data, workingDir);
    });
    return success;
}

bool Map::loadFromStringUnsafe(const std::string& data, const std::string& workingDir)
{
    reset();

    //open the doc
    pugi::xml_document doc;
    auto result = doc.load_string(data.c_str());
    if (!result)
    {
        Logger::log("Failed opening map", Logger::Type::Error);
        Logger::log("Reason: " + std::string(result.description()), Logger::Type::Error);
        return false;
    }

	m_workingDirectory = getFilePath(workingDir);

    //find the map node and bail if it doesn't exist
    auto mapNode = doc.child("map");
    if (!mapNode)
    {
        Logger::log("Failed opening map: no map node found", Logger::Type::Error);
        return reset();
    }

    return parseMapNode(mapNode);
}

//private
bool Map::parseMapNode(const pugi::xml_node& mapNode)
{
    //parse map attributes
    std::size_t pointPos = 0;
    std::string attribString = mapNode.attribute("version").as_string();
    if (attribString.empty() || (pointPos = attribString.find('.')) == std::string::npos)
    {
        Logger::log("Invalid map version value, map not loaded.", Logger::Type::Error);
        return reset();
    }

    m_version.upper = STOI(attribString.substr(0, pointPos));
    m_version.lower = STOI(attribString.substr(pointPos + 1));

    m_class = mapNode.attribute("class").as_string();

    attribString = mapNode.attribute("orientation").as_string();
    if (attribString.empty())
    {
        Logger::log("Missing map orientation attribute, map not loaded.", Logger::Type::Error);
        return reset();
    }

    if (attribString == "orthogonal")
    {
        m_orientation = Orientation::Orthogonal;
    }
    else if (attribString == "isometric")
    {
        m_orientation = Orientation::Isometric;
    }
    else if (attribString == "staggered")
    {
        m_orientation = Orientation::Staggered;
    }
    else if (attribString == "hexagonal")
    {
        m_orientation = Orientation::Hexagonal;
    }
    else
    {
        Logger::log(attribString + " format maps aren't supported yet, sorry! Map not loaded", Logger::Type::Error);
        return reset();
    }

    attribString = mapNode.attribute("renderorder").as_string();
    //this property is optional for older version of map files
    if (!attribString.empty())
    {
        if (attribString == "right-down")
        {
            m_renderOrder = RenderOrder::RightDown;
        }
        else if (attribString == "right-up")
        {
            m_renderOrder = RenderOrder::RightUp;
        }
        else if (attribString == "left-down")
        {
            m_renderOrder = RenderOrder::LeftDown;
        }
        else if (attribString == "left-up")
        {
            m_renderOrder = RenderOrder::LeftUp;
        }
        else
        {
            Logger::log(attribString + ": invalid render order. Map not loaded.", Logger::Type::Error);
            return reset();
        }
    }

    if (mapNode.attribute("infinite"))
    {
        m_infinite = mapNode.attribute("infinite").as_int() != 0;
    }

    unsigned width = mapNode.attribute("width").as_int();
    unsigned height = mapNode.attribute("height").as_int();
    if (width && height)
    {
        m_tileCount = { width, height };
    }
    else
    {
        Logger::log("Invalid map tile count, map not loaded", Logger::Type::Error);
        return reset();
    }

    width = mapNode.attribute("tilewidth").as_int();
    height = mapNode.attribute("tileheight").as_int();
    if (width && height)
    {
        m_tileSize = { width, height };
    }
    else
    {
        Logger::log("Invalid tile size, map not loaded", Logger::Type::Error);
        return reset();
    }

    m_hexSideLength = mapNode.attribute("hexsidelength").as_float();
    if (m_orientation == Orientation::Hexagonal && m_hexSideLength <= 0)
    {
        Logger::log("Invalid he side length found, map not loaded", Logger::Type::Error);
        return reset();
    }

    attribString = mapNode.attribute("staggeraxis").as_string();
    if (attribString == "x")
    {
        m_staggerAxis = StaggerAxis::X;
    }
    else if (attribString == "y")
    {
        m_staggerAxis = StaggerAxis::Y;
    }
    if ((m_orientation == Orientation::Staggered || m_orientation == Orientation::Hexagonal)
        && m_staggerAxis == StaggerAxis::None)
    {
        Logger::log("Map missing stagger axis property. Map not loaded.", Logger::Type::Error);
        return reset();
    }

    attribString = mapNode.attribute("staggerindex").as_string();
    if (attribString == "odd")
    {
        m_staggerIndex = StaggerIndex::Odd;
    }
    else if (attribString == "even")
    {
        m_staggerIndex = StaggerIndex::Even;
    }
    if ((m_orientation == Orientation::Staggered || m_orientation == Orientation::Hexagonal)
        && m_staggerIndex == StaggerIndex::None)
    {
        Logger::log("Map missing stagger index property. Map not loaded.", Logger::Type::Error);
        return reset();
    }

    m_parallaxOrigin =
    {
        mapNode.attribute("parallaxoriginx").as_float(0.f),
        mapNode.attribute("parallaxoriginy").as_float(0.f)
    };

    //colour property is optional
    attribString = mapNode.attribute("backgroundcolor").as_string();
    if (!attribString.empty())
    {
        m_backgroundColour = colourFromString(attribString);
    }

    //TODO do we need next object ID

    //parse all child nodes
    for (const auto& node : mapNode.children())
    {
        std::string name = node.name();
        if (name == "tileset")
        {
            m_tilesets.emplace_back(m_workingDirectory);
            m_tilesets.back().parse(node, this);
        }
        else if (name == "layer")
        {
            m_layers.emplace_back(std::make_unique<TileLayer>(m_tileCount.x * m_tileCount.y));
            m_layers.back()->parse(node);
        }
        else if (name == "objectgroup")
        {
            m_layers.emplace_back(std::make_unique<ObjectGroup>());
            m_layers.back()->parse(node, this);
        }
        else if (name == "imagelayer")
        {
            m_layers.emplace_back(std::make_unique<ImageLayer>(m_workingDirectory));
            m_layers.back()->parse(node, this);
        }
        else if (name == "properties")
        {
            const auto& children = node.children();
            for (const auto& child : children)
            {
                m_properties.emplace_back();
                m_properties.back().parse(child);
            }
        }
        else if (name == "group")
        {
            m_layers.emplace_back(std::make_unique<LayerGroup>(m_workingDirectory, m_tileCount));
            m_layers.back()->parse(node, this);
        }
        else
        {
            LOG("Unidentified name " + name + ": node skipped", Logger::Type::Warning);
        }
    }
    // fill animated tiles for easier lookup into map
    for(const auto& ts : m_tilesets)
    {
        for(const auto& tile : ts.getTiles())
        {
            if (!tile.animation.frames.empty())
            {
                m_animTiles[tile.ID + ts.getFirstGID()] = tile;
            }
        }
    }

    return true;
}

bool Map::reset()
{
    m_orientation = Orientation::None;
    m_renderOrder = RenderOrder::None;
    m_tileCount = { 0u, 0u };
    m_tileSize = { 0u, 0u };
    m_hexSideLength = 0.f;
    m_staggerAxis = StaggerAxis::None;
    m_staggerIndex = StaggerIndex::None;
    m_backgroundColour = {};
    m_workingDirectory = "";

    m_tilesets.clear();
    m_layers.clear();
    m_properties.clear();

    m_templateObjects.clear();
    m_templateTilesets.clear();

    m_animTiles.clear();

    return false;
}

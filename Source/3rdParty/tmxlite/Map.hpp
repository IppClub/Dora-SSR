/*********************************************************************
Matt Marchant 2016 -2021
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

#pragma once

#include "tmxlite/Tileset.hpp"
#include "tmxlite/Layer.hpp"
#include "tmxlite/Property.hpp"
#include "tmxlite/Types.hpp"
#include "tmxlite/Object.hpp"

#include <string>
#include <vector>
#include <map>
#include <unordered_map>

namespace tmx
{
    /*!
    \brief Holds the xml version of the loaded map
    */
    struct TMXLITE_EXPORT_API Version
    {
        //major/minor are apparently reserved by gcc            
        std::uint16_t upper;
        std::uint16_t lower;
        Version(std::uint16_t maj = 0, std::uint16_t min = 0)
            : upper(maj), lower(min) {}
    };
        
    enum class Orientation
    {
        Orthogonal,
        Isometric,
        Staggered,
        Hexagonal,
        None
    };

    enum class RenderOrder
    {
        RightDown,
        RightUp,
        LeftDown,
        LeftUp,
        None
    };

    enum class StaggerAxis
    {
        X, Y, None
    };

    enum class StaggerIndex
    {
        Even, Odd, None
    };

    /*!
    \brief Parser for TMX format tile maps.
    This class can be used to parse the XML format tile maps created
    with the Tiled map editor, providing an interface to create drawable and
    physics objects. Typical usage would be to create an instance of this
    class before calling load() providing a path to the *.tmx file to be
    loaded. Then layers or objects can be requested from the Map class
    to be interpreted as needed.
    \see https://doc.mapeditor.org/en/stable/reference/tmx-map-format/#map
    */
    class TMXLITE_EXPORT_API Map final
    {
    public:
            
        Map();
        ~Map() = default;
        Map(const Map&) = delete;
        Map& operator  = (const Map&) = delete;
        Map(Map&&) = default;
        Map& operator = (Map&&) = default;

        /*!
        \brief Attempts to parse the tilemap at the given location.
        \param std::string Path to map file to try to parse
        \returns true if map was parsed successfully else returns false.
        In debug mode this will attempt to log any errors to the console.
        */
        bool load(const std::string&);
        bool loadUnsafe(const std::string&);

        /*!
        \brief Loads a map from a document stored in a string
        \param data A std::string containing the map data to load
        \param workingDir A std::string containing the working directory
        in which to find assets such as tile sets or images
        \returns true if successful, else false
        */
        bool loadFromString(const std::string& data, const std::string& workingDir);
        bool loadFromStringUnsafe(const std::string& data, const std::string& workingDir);

        /*!
        \brief Returns the version of the tile map last parsed.
        If no tile map has yet been parsed the version will read 0, 0
        */
        const Version& getVersion() const { return m_version; }

        /*!
        \brief Returns the orientation of the map if one is loaded,
        else returns None
        */
        Orientation getOrientation() const { return m_orientation; }

        /*!
        \brief Returns the RenderOrder of the map if one is loaded,
        else returns None
        */
        RenderOrder getRenderOrder() const { return m_renderOrder; }

        /*!
        \brief Returns the tile count of the map in the X and Y directions
        */
        const Vector2u& getTileCount() const { return m_tileCount; }

        /*!
        \brief Returns the size of the tile grid in this map.
        Actual tile sizes may vary and will be extended / shrunk about
        the bottom left corner of the tile.
        */
        const Vector2u& getTileSize() const { return m_tileSize; }

        /*!
        \brief Returns the bounds of the map
        */
        FloatRect getBounds() const { return FloatRect(0.f, 0.f, static_cast<float>(m_tileCount.x * m_tileSize.x), static_cast<float>(m_tileCount.y * m_tileSize.y)); }

        /*!
        \brief Returns the length of an edge of a tile if a Hexagonal
        map is loaded.
        The length returned is in pixels of the straight edge running
        along the axis returned by getStaggerAxis(). If no map is loaded
        or the loaded map is not of Hexagonal orientation this function
        returns 0.f
        */
        float getHexSideLength() const { return m_hexSideLength; }

        /*!
        \brief Stagger axis of the map.
        If either a Staggered or Hexagonal tile map is loaded this returns
        which axis the map is staggered along, else returns None.
        */
        StaggerAxis getStaggerAxis() const { return m_staggerAxis; }

        /*!
        \brief Stagger Index of the loaded map.
        If a Staggered or Hexagonal map is loaded this returns whether
        the even or odd rows of tiles are staggered, otherwise it returns None.
        */
        StaggerIndex getStaggerIndex() const { return m_staggerIndex; }

        /*!
        \brief Returns the background colour of the map.
        */
        const Colour& getBackgroundColour() const { return m_backgroundColour; }

        /*!
        \brief Returns a reference to the vector of tile sets used by the map
        */
        const std::vector<Tileset>& getTilesets() const { return m_tilesets; }

        /*!
        \brief Returns a reference to the vector containing the layer data.
        Layers are pointer-to-baseclass, the concrete type of which can be
        found via Layer::getType()
        \see Layer
        */
        const std::vector<Layer::Ptr>& getLayers() const { return m_layers; }

        /*!
        \brief Returns the class of the Map, as defined in the editor Tiled 1.9+
        */
        const std::string& getClass() const { return m_class; }

        /*!
        \brief Returns a vector of Property objects loaded by the map
        */
        const std::vector<Property>& getProperties() const { return m_properties; } 

        /*!
        \brief Returns a Hashmap of all animated tiles accessible by TileID
        */
        const std::map<std::uint32_t, Tileset::Tile>& getAnimatedTiles() const { return m_animTiles; }

        /*!
        \brief Returns the current working directory of the map. Images and
        other resources are loaded relative to this.
        */
        const std::string& getWorkingDirectory() const { return m_workingDirectory; }

        /*!
        \brief Returns an unordered_map of template objects indexed by file name
        */
        std::unordered_map<std::string, Object>& getTemplateObjects() { return m_templateObjects; }
        const std::unordered_map<std::string, Object>& getTemplateObjects() const { return m_templateObjects; }

        /*!
        \brief Returns an unordered_map of tilesets used by templated objects.
        If Object::getTilesetName() is not empty it can be used to retreive a tileset
        from this map. Otherwise the object's tileset can be found from in the map's
        global tilesets returned by getTilesets().
        */
        std::unordered_map<std::string, Tileset>& getTemplateTilesets() { return m_templateTilesets; }
        const std::unordered_map<std::string, Tileset>& getTemplateTilesets() const { return m_templateTilesets; }

        /*!
        \brief Returns true if this is in infinite tile map.
        Infinite maps store their tile data in for tile layers in chunks. If
        this is an infinite map use TileLayer::getChunks() to get tile IDs
        rather than TileLayer::getTiles().
        \see TileLayer
        */
        bool isInfinite() const { return m_infinite; }

        /*
        \brief Returns the origin of each layer's parallax offset value
        */
        Vector2f getParallaxOrigin() const { return m_parallaxOrigin; }

    private:
        Version m_version;
        std::string m_class;
        Orientation m_orientation;
        RenderOrder m_renderOrder;
        bool m_infinite;

        Vector2u m_tileCount;
        Vector2u m_tileSize;

        float m_hexSideLength;
        StaggerAxis m_staggerAxis;
        StaggerIndex m_staggerIndex;

        Vector2f m_parallaxOrigin;

        Colour m_backgroundColour;

        std::string m_workingDirectory;

        std::vector<Tileset> m_tilesets;
        std::vector<Layer::Ptr> m_layers;
        std::vector<Property> m_properties;
        std::map<std::uint32_t, Tileset::Tile> m_animTiles;

        std::unordered_map<std::string, Object> m_templateObjects;
        std::unordered_map<std::string, Tileset> m_templateTilesets;

        bool parseMapNode(const pugi::xml_node&);

        //always returns false so we can return this
        //on load failure
        bool reset();
    };
}

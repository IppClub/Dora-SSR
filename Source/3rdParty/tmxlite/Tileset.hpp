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

#pragma once

#include "tmxlite/Config.hpp"
#include "tmxlite/Property.hpp"
#include "tmxlite/ObjectGroup.hpp"

#include <string>
#include <vector>
#include <array>

namespace pugi
{
    class xml_node;
}

namespace tmx
{
    class Map;

    /*!
    \brief Represents a Tileset node as loaded
    from a *.tmx format tile map via the tmx::Map
    class.
    */
    class TMXLITE_EXPORT_API Tileset final
    {
    public:
        explicit Tileset(const std::string& workingDir);

        /*!
        \brief Any tiles within a tile set which have special
        data associated with them such as animation or terrain
        information will have one of these stored in the tile set.
        */
        struct Tile final
        {
            std::uint32_t ID = 0;
            std::array<std::int32_t, 4u> terrainIndices{};
            std::uint32_t probability = 100;

            /*!
            \brief a group of frames which make up an animation
            */
            struct Animation final
            {
                /*!
                \brief A frame within an animation
                */
                struct Frame final
                {
                    std::uint32_t tileID = 0;
                    std::uint32_t duration = 0;

                    bool operator == (const Frame& other) const
                    {
                        return (this == &other) ||
                            (tileID == other.tileID && duration == other.duration);
                    }

                    bool operator != (const Frame& other) const
                    {
                        return !(*this == other);
                    }
                };
                std::vector<Frame> frames;
            }animation;
            std::vector<Property> properties;
            ObjectGroup objectGroup;
            std::string imagePath;
            Vector2u imageSize;
            /*!
            \brief The position of the tile within the image.
            */
            Vector2u imagePosition;
            std::string className;
        };
            
        /*!
        \brief Terrain information with which one
        or more tiles may be associated.
        */
        struct Terrain final
        {
            std::string name;
            std::uint32_t tileID = -1;
            std::vector<Property> properties;
        };

        /*!
        \brief Declares the alignment of tile Objects
        */
        enum class ObjectAlignment
        {
            Unspecified,
            TopLeft,
            Top,
            TopRight,
            Left,
            Center,
            Right,
            BottomLeft,
            Bottom,
            BottomRight
        };

        /*!
        \brief Attempts to parse the given xml node.
        If node parsing fails an error is printed in the console
        and the Tileset remains in an uninitialised state.
        */
        void parse(pugi::xml_node, Map*);

        /*!
        \brief Returns the first GID of this tile set.
        This the ID of the first tile in the tile set, so that
        each tile set guarantees a unique set of IDs
        */
        std::uint32_t getFirstGID() const { return m_firstGID; }

        /*!
        \brief Returns the last GID of this tile set.
        This is the ID of the last tile in the tile set.
        */
        std::uint32_t getLastGID() const;

        /*!
        \brief Returns the name of this tile set.
        */
        const std::string& getName() const { return m_name; }

        /*!
        \brief Returns the class of the Tileset, as defined in the editor Tiled 1.9+
        */
        const std::string& getClass() const { return m_class; }

        /*!
        \brief Returns the width and height of a tile in the
        tile set, in pixels.
        */
        const Vector2u& getTileSize() const { return m_tileSize; }

        /*!
        \brief Returns the spacing, in pixels, between each tile in the set
        */
        std::uint32_t getSpacing() const { return m_spacing; }

        /*!
        \brief Returns the margin, in pixels, around each tile in the set
        */
        std::uint32_t getMargin() const { return m_margin; }

        /*!
        \brief Returns the number of tiles in the tile set
        */
        std::uint32_t getTileCount() const { return m_tileCount; }

        /*!
        \brief Returns the number of columns which make up the tile set.
        This is used when rendering collection of images sets
        */
        std::uint32_t getColumnCount() const { return m_columnCount; }

        /*!
        \brief Returns the alignment of tile objects.
        The default value is ObjectAlignment::Unspecified for compatibility.
        When the alignment is Unspecified tile objects use BottomLeft in
        orthogonal mode and Bottom in isometric mode.
        \see ObjectAlignment
        */
        ObjectAlignment getObjectAlignment() const { return m_objectAlignment; }

        /*!
        \brief Returns the tile offset in pixels.
        Tile will draw tiles offset from the top left using this value.
        */
        const Vector2u& getTileOffset() const { return m_tileOffset; }

        /*!
        \brief Returns a reference to the list of Property objects for this
        tile set
        */
        const std::vector<Property>& getProperties() const { return m_properties; }

        /*!
        \brief Returns the file path to the tile set image, relative to the
        working directory. Use this to load the texture required by whichever
        method you choose to render the map.
        */
        const std::string& getImagePath() const { return m_imagePath; }

        /*!
        \brief Returns the size of the tile set image in pixels.
         */
        const Vector2u& getImageSize() const { return m_imageSize; }

        /*!
        \brief Returns the colour used by the tile map image to represent transparency.
        By default this is a transparent colour (0, 0, 0, 0)
        */
        const Colour& getTransparencyColour() const { return m_transparencyColour; }

        /*!
        \brief Returns true if the image used by this tileset specifically requests
        a colour to use as transparency.
        */
        bool hasTransparency() const { return m_hasTransparency; }

        /*!
        \brief Returns a vector of Terrain types associated with one
        or more tiles within this tile set
        */
        const std::vector<Terrain>& getTerrainTypes() const { return m_terrainTypes; }

        /*!
        \brief Returns a reference to the vector of tile data used by
        tiles which make up this tile set.
        */
        const std::vector<Tile>& getTiles() const { return m_tiles; }

        /*!
         \brief Checks if a tiled ID is in the range of the first ID and the last ID
         \param id Tile ID
         \return 
         */
        bool hasTile(std::uint32_t id) const { return id >= m_firstGID && id <= getLastGID(); };

        /*!
         \brief queries tiles and returns a tile with the given ID. Checks if the TileID is part of the Tileset with `hasTile(id)`
         \param id Tile ID. The Tile ID will be corrected internally.
         \return In case of a success it returns the correct tile. In terms of failure it will return a nullptr.
         */
        const Tile* getTile(std::uint32_t id) const;

    private:

        std::string m_workingDir;

        std::uint32_t m_firstGID;
        std::string m_source;
        std::string m_name;
        std::string m_class;
        Vector2u m_tileSize;
        std::uint32_t m_spacing;
        std::uint32_t m_margin;
        std::uint32_t m_tileCount;
        std::uint32_t m_columnCount;
        ObjectAlignment m_objectAlignment;
        Vector2u m_tileOffset;

        std::vector<Property> m_properties;
        std::string m_imagePath;
        Vector2u m_imageSize;
        Colour m_transparencyColour;
        bool m_hasTransparency;

        std::vector<Terrain> m_terrainTypes;
        std::vector<std::uint32_t> m_tileIndex;
        std::vector<Tile> m_tiles;

        void reset();

        void parseOffsetNode(const pugi::xml_node&);
        void parsePropertyNode(const pugi::xml_node&);
        void parseTerrainNode(const pugi::xml_node&);
        Tile& newTile(std::uint32_t ID);
        void parseTileNode(const pugi::xml_node&, Map*);
        void createMissingTile(std::uint32_t ID);
    };
}

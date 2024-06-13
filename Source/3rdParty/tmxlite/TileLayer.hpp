/*********************************************************************
Matt Marchant 2016 - 2022
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

#include "tmxlite/Layer.hpp"
#include "tmxlite/Types.hpp"

namespace tmx
{
    /*!
    \brief A layer made up from a series of tile sets
    */
    class TMXLITE_EXPORT_API TileLayer final : public Layer
    {
    public:
        /*!
        \brief Tile information for a layer
        */
        struct Tile final
        {
            std::uint32_t ID = 0; //!< Global ID of the tile
            std::uint8_t flipFlags = 0; //!< Flags marking if the tile should be flipped when drawn
        };

        /*!
        \brief Represents a chunk of tile data, if this is an infinite map
        */
        struct Chunk final
        {
            Vector2i position; //<! coordinate in tiles, not pixels
            Vector2i size; //!< size in tiles, not pixels
            std::vector<Tile> tiles;
        };

        /*!
        \brief Flags used to tell if a tile is flipped when drawn
        */
        enum FlipFlag
        {
            Horizontal = 0x8,
            Vertical = 0x4,
            Diagonal = 0x2
        };
            
        explicit TileLayer(std::size_t);

        Type getType() const override { return Layer::Type::Tile; }
        void parse(const pugi::xml_node&, Map*) override;

        /*!
        \brief Returns the list of tiles used to make up the layer
        If this is empty then the map is most likely infinite, in
        which case the tile data is stored in chunks.
        \see getChunks()
        */
        const std::vector<Tile>& getTiles() const { return m_tiles; }

        /*!
        \brief Returns a vector of chunks which make up this layer
        if the map is set to infinite. This will be empty if the map
        is not infinite.
        \see getTiles()
        */
        const std::vector<Chunk>& getChunks() const { return m_chunks; }

    private:
        std::vector<Tile> m_tiles;
        std::vector<Chunk> m_chunks;
        std::size_t m_tileCount;

        void parseBase64(const pugi::xml_node&);
        void parseCSV(const pugi::xml_node&);
        void parseUnencoded(const pugi::xml_node&);

        void createTiles(const std::vector<std::uint32_t>&, std::vector<Tile>& destination);
    };

    template <>
    inline TileLayer& Layer::getLayerAs<TileLayer>()
    {
        assert(getType() == Type::Tile);
        return *static_cast<TileLayer*>(this);
    }

    template <>
    inline const TileLayer& Layer::getLayerAs<TileLayer>() const
    {
        assert(getType() == Type::Tile);
        return *static_cast<const TileLayer*>(this);
    }
}

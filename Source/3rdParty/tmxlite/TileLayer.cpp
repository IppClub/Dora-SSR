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
#include <zstd.h>
#else
#include "detail/pugixml.hpp"
#endif

#ifdef USE_ZSTD
#include <zstd.h>
#endif

#include "tmxlite/FreeFuncs.hpp"
#include "tmxlite/TileLayer.hpp"
#include "tmxlite/detail/Log.hpp"

#include <sstream>

using namespace tmx;

namespace
{
    struct CompressionType final
    {
        enum
        {
            Zlib, GZip, Zstd, None
        };
    };
}

TileLayer::TileLayer(std::size_t tileCount)
    : m_tileCount (tileCount)
{
    m_tiles.reserve(tileCount);
}

//public
void TileLayer::parse(const pugi::xml_node& node, Map*)
{
    std::string attribName = node.name();
    if (attribName != "layer")
    {
        Logger::log("node not a layer node, skipped parsing", Logger::Type::Error);
        return;
    }

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

    for (const auto& child : node.children())
    {
        attribName = child.name();
        if (attribName == "data")
        {
            attribName = child.attribute("encoding").as_string();
            if (attribName == "base64")
            {
                parseBase64(child);
            }
            else if (attribName == "csv")
            {
                parseCSV(child);
            }
            else
            {
                parseUnencoded(child);
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

//private
void TileLayer::parseBase64(const pugi::xml_node& node)
{
    auto processDataString = [](std::string dataString, std::size_t tileCount, std::int32_t compressionType)->std::vector<std::uint32_t>
    {
        std::stringstream ss;
        ss << dataString;
        ss >> dataString;
        dataString = base64_decode(dataString);

        std::size_t expectedSize = tileCount * 4; //4 bytes per tile
        std::vector<unsigned char> byteData;
        byteData.reserve(expectedSize);

        switch (compressionType)
        {
        default:
            byteData.insert(byteData.end(), dataString.begin(), dataString.end());
            break;
        case CompressionType::Zstd:
#if defined USE_ZSTD || defined USE_EXTLIBS
            {
                std::size_t dataSize = dataString.length() * sizeof(unsigned char);
                std::size_t result = ZSTD_decompress(byteData.data(), expectedSize, &dataString[0], dataSize);
                
                if (ZSTD_isError(result))
                {
                    std::string err = ZSTD_getErrorName(result);
                    LOG("Failed to decompress layer data, node skipped.\nError: " + err, Logger::Type::Error);
                }
            }
#else
            Logger::log("Library must be built with USE_EXTLIBS or USE_ZSTD for Zstd compression", Logger::Type::Error);
            return {};
#endif
        case CompressionType::GZip:
#ifndef USE_EXTLIBS
            Logger::log("Library must be built with USE_EXTLIBS for GZip compression", Logger::Type::Error);
            return {};
#endif
            //[[fallthrough]];
        case CompressionType::Zlib:
        {
            //unzip
            std::size_t dataSize = dataString.length() * sizeof(unsigned char);

            if (!decompress(dataString.c_str(), byteData, dataSize, expectedSize))
            {
                LOG("Failed to decompress layer data, node skipped.", Logger::Type::Error);
                return {};
            }
        }
            break;
        }

        //data stream is in bytes so we need to OR into 32 bit values
        std::vector<std::uint32_t> IDs;
        IDs.reserve(tileCount);
        for (auto i = 0u; i < expectedSize - 3u; i += 4u)
        {
            std::uint32_t id = byteData[i] | byteData[i + 1] << 8 | byteData[i + 2] << 16 | byteData[i + 3] << 24;
            IDs.push_back(id);
        }

        return IDs;
    };

    std::int32_t compressionType = CompressionType::None;
    std::string compression = node.attribute("compression").as_string();
    if (compression == "gzip")
    {
        compressionType = CompressionType::GZip;
    }
    else if (compression == "zlib")
    {
        compressionType = CompressionType::Zlib;
    }
    else if (compression == "zstd")
    {
        compressionType = CompressionType::Zstd;
    }

    std::string data = node.text().as_string();
    if (data.empty())
    {
        //check for chunk nodes
        auto dataCount = 0;
        for (const auto& childNode : node.children())
        {
            std::string childName = childNode.name();
            if (childName == "chunk")
            {
                std::string dataString = childNode.text().as_string();
                if (!dataString.empty())
                {
                    Chunk chunk;
                    chunk.position.x = childNode.attribute("x").as_int();
                    chunk.position.y = childNode.attribute("y").as_int();

                    chunk.size.x = childNode.attribute("width").as_int();
                    chunk.size.y = childNode.attribute("height").as_int();

                    auto IDs = processDataString(dataString, (chunk.size.x * chunk.size.y), compressionType);

                    if (!IDs.empty())
                    {
                        createTiles(IDs, chunk.tiles);
                        m_chunks.push_back(chunk);
                        dataCount++;
                    }                    
                }
            }
        }

        if (dataCount == 0)
        {
            Logger::log("Layer " + getName() + " has no layer data. Layer skipped.", Logger::Type::Error);
            return;
        }
    }
    else
    {
        auto IDs = processDataString(data, m_tileCount, compressionType);
        createTiles(IDs, m_tiles);
    }
}

void TileLayer::parseCSV(const pugi::xml_node& node)
{
    auto processDataString = [](const std::string dataString, std::size_t tileCount)->std::vector<std::uint32_t>
    {
        std::vector<std::uint32_t> IDs;
        IDs.reserve(tileCount);

        const char* ptr = dataString.c_str();
        while (true)
        {
            char* end;
            auto res = std::strtoul(ptr, &end, 10);
            if (end == ptr) break;
            ptr = end;
            IDs.push_back(res);
            if (*ptr == ',') ++ptr;
        }

        return IDs;
    };

    std::string data = node.text().as_string();
    if (data.empty())
    {
        //check for chunk nodes
        auto dataCount = 0;
        for (const auto& childNode : node.children())
        {
            std::string childName = childNode.name();
            if (childName == "chunk")
            {
                std::string dataString = childNode.text().as_string();
                if (!dataString.empty())
                {
                    Chunk chunk;
                    chunk.position.x = childNode.attribute("x").as_int();
                    chunk.position.y = childNode.attribute("y").as_int();

                    chunk.size.x = childNode.attribute("width").as_int();
                    chunk.size.y = childNode.attribute("height").as_int();

                    auto IDs = processDataString(dataString, chunk.size.x * chunk.size.y);

                    if (!IDs.empty())
                    {
                        createTiles(IDs, chunk.tiles);
                        m_chunks.push_back(chunk);
                        dataCount++;
                    }
                }
            }
        }

        if (dataCount == 0)
        {
            Logger::log("Layer " + getName() + " has no layer data. Layer skipped.", Logger::Type::Error);
            return;
        }
    }
    else
    {
        createTiles(processDataString(data, m_tileCount), m_tiles);
    }
}

void TileLayer::parseUnencoded(const pugi::xml_node& node)
{
    std::string attribName;
    std::vector<std::uint32_t> IDs;
    IDs.reserve(m_tileCount);

    for (const auto& child : node.children())
    {
        attribName = child.name();
        if (attribName == "tile")
        {
            IDs.push_back(child.attribute("gid").as_uint());
        }
    }

    createTiles(IDs, m_tiles);
}

void TileLayer::createTiles(const std::vector<std::uint32_t>& IDs, std::vector<Tile>& destination)
{
    //LOG(IDs.size() != m_tileCount, "Layer tile count does not match expected size. Found: "
    //    + std::to_string(IDs.size()) + ", expected: " + std::to_string(m_tileCount));
    
    static const std::uint32_t mask = 0xf0000000;
    for (const auto& id : IDs)
    {
        destination.emplace_back();
        destination.back().flipFlags = ((id & mask) >> 28);
        destination.back().ID = id & ~mask;
    }
}

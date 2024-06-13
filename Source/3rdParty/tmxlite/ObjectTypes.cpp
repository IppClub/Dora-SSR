/*********************************************************************
Raphaël Frantz 2021

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
#include "tmxlite/ObjectTypes.hpp"
#include "tmxlite/detail/Log.hpp"

#include "Const/Header.h"
#include "Basic/Content.h"

using namespace tmx;

bool ObjectTypes::load(const std::string &path)
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

    //make sure we have consistent path separators
    m_workingDirectory = path;
    std::replace(m_workingDirectory.begin(), m_workingDirectory.end(), '\\', '/');
    m_workingDirectory = getFilePath(m_workingDirectory);

    if (!m_workingDirectory.empty() &&
        m_workingDirectory.back() == '/')
    {
        m_workingDirectory.pop_back();
    }


    //find the node and bail if it doesn't exist
    auto node = doc.child("objecttypes");
    if (!node)
    {
        Logger::log("Failed opening object types: " + path + ", no objecttype node found", Logger::Type::Error);
        return reset();
    }

    return parseObjectTypesNode(node);
}

bool ObjectTypes::loadFromString(const std::string &data, const std::string &workingDir)
{
    reset();

    //open the doc
    pugi::xml_document doc;
    auto result = doc.load_string(data.c_str());
    if (!result)
    {
        Logger::log("Failed opening object types", Logger::Type::Error);
        Logger::log("Reason: " + std::string(result.description()), Logger::Type::Error);
        return false;
    }

    //make sure we have consistent path separators
    m_workingDirectory = workingDir;
    std::replace(m_workingDirectory.begin(), m_workingDirectory.end(), '\\', '/');
    m_workingDirectory = getFilePath(m_workingDirectory);

    if (!m_workingDirectory.empty() &&
        m_workingDirectory.back() == '/')
    {
        m_workingDirectory.pop_back();
    }


    //find the node and bail if it doesn't exist
    auto node = doc.child("objecttypes");
    if (!node)
    {
        Logger::log("Failed object types: no objecttypes node found", Logger::Type::Error);
        return reset();
    }

    return parseObjectTypesNode(node);
}

bool ObjectTypes::parseObjectTypesNode(const pugi::xml_node &node)
{
    //<objecttypes> <-- node
    //  <objecttype name="Character" color="#1e47ff">
    //    <property>...

    //parse types
    for(const auto& child : node.children())
    {
        std::string attribString = child.name();
        if (attribString == "objecttype")
        {
            Type type;

            //parse the metadata of the type
            type.name = child.attribute("name").as_string();
            type.colour = colourFromString(child.attribute("color").as_string("#FFFFFFFF"));;

            //parse the default properties of the type
            for (const auto& p : child.children())
            {
                Property prop;
                prop.parse(p, true);
                type.properties.push_back(prop);
            }

            m_types.push_back(type);
        }
        else
        {
            LOG("Unidentified name " + attribString + ": node skipped", Logger::Type::Warning);
        }
    }

    return true;
}

bool ObjectTypes::reset()
{
    m_workingDirectory.clear();
    m_types.clear();
    return false;
}

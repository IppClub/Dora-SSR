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

#pragma once

#include "tmxlite/Property.hpp"

#include <string>
#include <vector>

namespace tmx
{
    /*!
    \brief Parser for Tiled object types export format.
    Link to the specification: https://doc.mapeditor.org/fr/latest/manual/custom-properties/#predefining-properties.
    */
    class TMXLITE_EXPORT_API ObjectTypes final
    {
    public:
        /*!
        \brief Types that stores all predefined properties for all objects of this type.
        To take less spaces, they are not exported by default into maps.
        */
        struct Type
        {
            std::string name;
            Colour colour;
            std::vector<Property> properties;
        };

        /*!
        \brief Attempts to parse the object types at the given location.
        \param std::string Path to object types file to try to parse
        \returns true if object types was parsed successfully else returns false.
        In debug mode this will attempt to log any errors to the console.
        */
        bool load(const std::string&);

        /*!
        \brief Loads an object types from a document stored in a string
        \param data A std::string containing the object types to load
        \param workingDir A std::string containing the working directory
        in which to find files.
        \returns true if successful, else false
        */
        bool loadFromString(const std::string& data, const std::string& workingDir);

        /*!
        \brief Returns all predefined types and their default values.
        */
        const std::vector<Type>& getTypes() const { return m_types; }

    private:
        std::string m_workingDirectory;
        std::vector<Type> m_types;

        bool parseObjectTypesNode(const pugi::xml_node&);

        //always returns false so we can return this
        //on load failure
        bool reset();
    };
}

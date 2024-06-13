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

#pragma once

#include "tmxlite/Config.hpp"
#include "tmxlite/Types.hpp"

#include <string>
#include <cassert>
#include <vector>

namespace pugi
{
    class xml_node;
}

namespace tmx
{
    /*!
    \brief Represents a custom property.
    Tiles, objects and layers of a tmx map may have custom
    properties assigned to them. This class represents a 
    single property and provides access to its value, the
    type of which can be determined with getType()
    */
    class TMXLITE_EXPORT_API Property final
    {
    public:
            
        enum class Type
        {
            Boolean,
            Float,
            Int,
            String,
            Colour,
            File,
            Object,
            Class,
            Undef
        };
            
        Property();

        static Property fromBoolean(bool value);
        static Property fromFloat(float value);
        static Property fromInt(int value);
        static Property fromString(const std::string& value);
        static Property fromColour(const Colour& value);
        static Property fromFile(const std::string& value);
        static Property fromObject(int value);

        /*!
        \brief Attempts to parse the given node as a property
        \param isObjectTypes Set to true if the parsing is done from an object types files.
        */
        void parse(const pugi::xml_node&, bool isObjectTypes = false);

        /*!
        \brief Returns the type of data stored in the property.
        This should generally be called first before trying to
        read the proprty value, as reading the incorrect type
        will lead to undefined behaviour.
        */
        Type getType() const { return m_type; }

        /*!
        \brief Returns the name of this property
        */
        const std::string& getName() const { return m_name; }

        /*!
        \brief Returns the property's value as a boolean
        */
        bool getBoolValue() const { assert(m_type == Type::Boolean); return m_boolValue; }

        /*!
        \brief Returns the property's value as a float
        */
        float getFloatValue() const { assert(m_type == Type::Float); return m_floatValue; }

        /*!
        \brief Returns the property's value as an integer
        */
        int getIntValue() const { assert(m_type == Type::Int || m_type == Type::Object); return m_intValue; }

        /*!
        \brief Returns the property's value as a string
        */
        const std::string& getStringValue() const { assert(m_type == Type::String); return m_stringValue; }

        /*!
        \brief Returns the property's value as a Colour struct
        */
        const Colour& getColourValue() const { assert(m_type == Type::Colour); return m_colourValue; }

        /*!
        \brief Returns the file path property as a string, relative to the map file
        */
        const std::string& getFileValue() const { assert(m_type == Type::File); return m_stringValue; }

        /*!
        \brief Returns an array of properties
        */
        const std::vector<Property>& getClassValue() const {assert(m_type == Type::Class); return m_classValue; }

        /*!
        \brief Returns an the propertytype value
        */
        const std::string getPropertyType() const {assert(m_type == Type::Class); return m_propertyType; }
        
        /*!
        \brief Returns the property's value as an integer object handle
        */
        int getObjectValue() const { assert(m_type == Type::Object); return m_intValue; }


    private:
        union
        {
            bool m_boolValue;
            float m_floatValue;
            int m_intValue;
        };
        std::string m_stringValue;
        std::string m_name;
        std::string m_propertyType;
        
        Colour m_colourValue;
        std::vector<Property> m_classValue;

        Type m_type;
    };
}

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
#include "tmxlite/Property.hpp"
#include "tmxlite/detail/Log.hpp"
#include "tmxlite/FreeFuncs.hpp"

using namespace tmx;

Property::Property()
    : m_type(Type::Undef)
{
}

Property Property::fromBoolean(bool value)
{
    Property p;
    p.m_type = Type::Boolean;
    p.m_boolValue = value;
    return p;
}

Property Property::fromFloat(float value)
{
    Property p;
    p.m_type = Type::Float;
    p.m_floatValue = value;
    return p;
}

Property Property::fromInt(int value)
{
    Property p;
    p.m_type = Type::Int;
    p.m_intValue = value;
    return p;
}

Property Property::fromString(const std::string& value)
{
    Property p;
    p.m_type = Type::String;
    p.m_stringValue = value;
    return p;
}

Property Property::fromColour(const Colour& value)
{
    Property p;
    p.m_type = Type::Colour;
    p.m_colourValue = value;
    return p;
}

Property Property::fromFile(const std::string& value)
{
    Property p;
    p.m_type = Type::File;
    p.m_stringValue = value;
    return p;
}

Property Property::fromObject(int value)
{
    Property p;
    p.m_type = Type::Object;
    p.m_intValue = value;
    return p;
}

//public
void Property::parse(const pugi::xml_node& node, bool isObjectTypes)
{
    // The value attribute name is different in object types
    const char *const valueAttribute = isObjectTypes ? "default" : "value";

    std::string attribData = node.name();
    if (attribData != "property")
    {
        Logger::log("Node was not a valid property, node will be skipped", Logger::Type::Error);
        return;
    }

    m_name = node.attribute("name").as_string();

    attribData = node.attribute("type").as_string("string");
    if (attribData == "bool")
    {
        attribData = node.attribute(valueAttribute).as_string("false");
        m_boolValue = (attribData == "true");
        m_type = Type::Boolean;
        return;
    }
    else if (attribData == "int")
    {
        m_intValue = node.attribute(valueAttribute).as_int(0);
        m_type = Type::Int;
        return;
    }
    else if (attribData == "float")
    {
        m_floatValue = node.attribute(valueAttribute).as_float(0.f);
        m_type = Type::Float;
        return;
    }
    else if (attribData == "string")
    {
        m_stringValue = node.attribute(valueAttribute).as_string();

        //if value is empty, try getting the child value instead
        //as this is how multiline string properties are stored.
        if(m_stringValue.empty())
        {
            m_stringValue = node.child_value();
        }

        m_type = Type::String;
        return;
    }
    else if (attribData == "color")
    {
        m_colourValue = colourFromString(node.attribute(valueAttribute).as_string("#FFFFFFFF"));
        m_type = Type::Colour;
        return;
    }
    else if (attribData == "file")
    {
        m_stringValue = node.attribute(valueAttribute).as_string();
        m_type = Type::File;
        return;
    }
    else if (attribData == "object")
    {
        m_intValue = node.attribute(valueAttribute).as_int(0);
        m_type = Type::Object;
        return;
    }
    else if (attribData == "class")
    {
        m_type = Type::Class;
        m_propertyType = node.attribute("propertytype").as_string("null");

        const std::string firstChildName = node.first_child().name();
        if (firstChildName == "properties")
        {
            for(const auto& childProp : node.first_child().children())
            {
                m_classValue.emplace_back();
                m_classValue.back().parse(childProp);
            }
        }
        return;
    }
}

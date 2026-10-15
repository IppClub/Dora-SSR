/*********************************************************************
(c) Matt Marchant 2016 - 2021
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
#include "tmxlite/Types.hpp"

#include <string>
#include <vector>

namespace pugi
{
    class xml_node;
}

namespace tmx
{
    class Map;

    /*!
    \brief Contains the text information stored in a Text object.
    */
    struct TMXLITE_EXPORT_API Text final
    {
        std::string fontFamily;
        std::uint32_t pixelSize = 16; //!< pixels, not points
        bool wrap = false;
        Colour colour;
        bool bold = false;
        bool italic = false;
        bool underline = false;
        bool strikethough = false;
        bool kerning = true;

        enum class HAlign
        {
            Left, Centre, Right
        }hAlign = HAlign::Left;

        enum class VAlign
        {
            Top, Centre, Bottom
        }vAlign = VAlign::Top;

        std::string content; //!< actual string content
    };
    
    /*!
    \brief Objects are stored in ObjectGroup layers.
    Objects may be rectangular, elliptical, polygonal or
    a polyline. Rectangular and elliptical Objects have their
    size determined via the AABB, whereas polygon and polyline
    shapes are defined by a list of points. Objects are 
    rectangular by default. Since version 1.0 Objects also
    support Text nodes.
    */
    class TMXLITE_EXPORT_API Object final
    {
    public:
        enum class Shape
        {
            Rectangle,
            Ellipse,
            Point,
            Polygon,
            Polyline,
            Text
        };

        Object();

        /*!
        \brief Attempts to parse the given xml node and
        read the Object properties if it is valid.
        */
        void parse(const pugi::xml_node&, Map*);

        /*!
        \brief Returns the unique ID of the Object
        */
        std::uint32_t getUID() const { return m_UID; }
        
        /*!
        \brief Returns the name of the Object
        */
        const std::string& getName() const { return m_name; }
        
        /*!
        \brief Returns the type (equal to class) of the Object, as defined in the editor Tiled < 1.9
        */
        const std::string& getType() const { return m_class; }

        /*!
        \brief Returns the class (equal to type) of the Object, as defined in the editor Tiled 1.9+
        */
        const std::string& getClass() const { return m_class; }

        /*!
        \brief Returns the position of the Object in pixels
        */
        const Vector2f& getPosition() const { return m_position; }
        
        /*!
        \brief Returns the global Axis Aligned Bounding Box.
        The AABB is positioned via the left and top properties, and
        define the Object's width and height. This can be used to derive
        the shape of the Object if it is rectangular or elliptical.
        */
        const FloatRect& getAABB() const { return m_AABB; }
        
        /*!
        \brief Returns the rotation of the Object in degrees clockwise
        */
        float getRotation() const { return m_rotation; }
        
        /*!
        \brief Returns the global tile ID associated with the Object
        if there is one. This is used to draw the Object (and therefore
        the Object must be rectangular)
        */
        std::uint32_t getTileID() const { return m_tileID; }
        
        /*!
        \brief Returns the flip flags if the objects uses a TileID to
        draw it.
        Returns 0 otherwise.
        */
        std::uint8_t getFlipFlags() const { return m_flipFlags; }

        /*!
        \brief Returns whether or not the Object is visible
        */
        bool visible() const { return m_visible; }
        
        /*!
        \brief Returns the Shape type of the Object
        */
        Shape getShape() const { return m_shape; }
        
        /*!
        \brief Returns a reference to the vector of points which
        make up the Object. If the Object is rectangular or elliptical
        then the vector will be empty. Point coordinates are in pixels,
        relative to the object position.
        */
        const std::vector<Vector2f>& getPoints() const { return m_points; }
        
        /*!
        \brief Returns a reference to the vector of properties belonging to
        the Object.
        */
        const std::vector<Property>& getProperties() const { return m_properties; }

        /*!
        \brief Returns a Text struct containing information about any text
        this object may have, such as font data and formatting.
        If an object does not contain any text information this struct will
        be populated with default values. Use getShape() to determine
        if this object is in fact a text object.
        */
        const Text& getText() const { return m_textData; }
        Text& getText() { return m_textData; }

        /*!
        \brief Returns the tileset name used by this object if it is derived 
        from a template, else returns an empty string.
        If the string is not empty use it to index the unordered_map returned
        by Map::getTemplateTilesets()
        */
        const std::string& getTilesetName() const { return m_tilesetName; }

    private:
        std::uint32_t m_UID;
        std::string m_name;
        std::string m_class;
        Vector2f m_position;
        FloatRect m_AABB;
        float m_rotation;
        std::uint32_t m_tileID;
        std::uint8_t m_flipFlags;
        bool m_visible;

        Shape m_shape;
        std::vector<Vector2f> m_points;
        std::vector<Property> m_properties;

        Text m_textData;

        std::string m_tilesetName;

        void parsePoints(const pugi::xml_node&);
        void parseText(const pugi::xml_node&);
        void parseTemplate(const std::string&, Map*);
    };
}

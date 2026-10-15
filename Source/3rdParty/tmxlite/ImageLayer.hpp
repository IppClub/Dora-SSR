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

#include "tmxlite/Config.hpp"
#include "tmxlite/Layer.hpp"
#include "tmxlite/Types.hpp"

namespace tmx
{
    /*!
    \brief Image layers contain a single image which make up that
    layer. The parser contains the fully resolved path to the image
    relative to the working directory.
    */
    class TMXLITE_EXPORT_API ImageLayer final : public Layer
    {
    public:
        explicit ImageLayer(const std::string&);

        Type getType() const override { return Layer::Type::Image; }
        void parse(const pugi::xml_node&, Map*) override;

        /*!
        \brief Returns the path, relative to the working directory,
        of the image used by the image layer.
        */
        const std::string& getImagePath() const { return m_filePath; }

        /*!
        \brief Returns the colour used by the image to represent transparent
        pixels. By default this is (0, 0, 0, 0)
        */
        const Colour& getTransparencyColour() const { return m_transparencyColour; }

        /*!
        \brief Returns true if the image used by this layer specifically states a 
        colour to use as transparency
        */
        bool hasTransparency() const { return m_hasTransparency; }

        /*!
        \brief Returns the size of the image of the image layer in pixels.
        */
        const Vector2u& getImageSize() const { return m_imageSize; }

        /*!
        \brief Returns true if the image drawn by this layer is repeated along 
        the X axis.
        */
        bool hasRepeatX() const { return m_hasRepeatX; }

        /*!
        \brief Returns true if the image drawn by this layer is repeated along 
        the Y axis.
        */
        bool hasRepeatY() const { return m_hasRepeatY; }

    private:
        std::string m_workingDir;
        std::string m_filePath;
        Colour m_transparencyColour;
        bool m_hasTransparency;
        Vector2u m_imageSize;
        bool m_hasRepeatX;
        bool m_hasRepeatY;
    };

    template <>
    inline ImageLayer& Layer::getLayerAs<ImageLayer>()
    {
        assert(getType() == Type::Image);
        return *static_cast<ImageLayer*>(this);
    }

    template <>
    inline const ImageLayer& Layer::getLayerAs<ImageLayer>() const
    {
        assert(getType() == Type::Image);
        return *static_cast<const ImageLayer*>(this);
    }
}

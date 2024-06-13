/*********************************************************************
Grant Gangi 2019 - 2022

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

#include <vector>

namespace tmx
{
    /*!
    \brief Layer groups are used to organize the layers of
    the map in a hierarchy. They can contain all other layer
    types including more layer groups to further nest layers.
    */
    class TMXLITE_EXPORT_API LayerGroup final : public Layer
    {
    public:

        LayerGroup(const std::string& workDir, const Vector2u& tileCount);
        ~LayerGroup() = default;
        LayerGroup(const LayerGroup&) = delete;
        const LayerGroup& operator = (const LayerGroup&) = delete;
        LayerGroup(LayerGroup&&) = default;
        LayerGroup& operator = (LayerGroup&&) = default;


        Type getType() const override { return Layer::Type::Group; }
        void parse(const pugi::xml_node&, Map*) override;

        /*!
        \brief Returns a reference to the vector containing the layer data.
        Layers are pointer-to-baseclass, the concrete type of which can be
        found via Layer::getType()
        \see Layer
        */
        const std::vector<Layer::Ptr>& getLayers() const { return m_layers; }

    private:

        std::vector<Layer::Ptr> m_layers;

        std::string m_workingDir;
        Vector2u m_tileCount;
    };

    template <>
    inline LayerGroup& Layer::getLayerAs<LayerGroup>()
    {
        assert(getType() == Type::Group);
        return *static_cast<LayerGroup*>(this);
    }

    template <>
    inline const LayerGroup& Layer::getLayerAs<LayerGroup>() const
    {
        assert(getType() == Type::Group);
        return *static_cast<const LayerGroup*>(this);
    }
}

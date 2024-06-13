/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/TileNode.h"

#include "Basic/Director.h"
#include "Cache/TMXCache.h"
#include "Cache/TextureCache.h"
#include "Effect/Effect.h"

#include "tmxlite/ImageLayer.hpp"
#include "tmxlite/TileLayer.hpp"

NS_DORA_BEGIN

TileNode::TileNode()
	: _effect(SharedSpriteRenderer.getDefaultEffect())
	, _filter(TextureFilter::Anisotropic)
	, _blendFunc(BlendFunc::Default) {
}

void TileNode::setEffect(SpriteEffect* var) {
	_effect = var ? var : SharedSpriteRenderer.getDefaultEffect();
}

SpriteEffect* TileNode::getEffect() const noexcept {
	return _effect;
}

void TileNode::setBlendFunc(const BlendFunc& var) {
	_blendFunc = var;
}

const BlendFunc& TileNode::getBlendFunc() const noexcept {
	return _blendFunc;
}

static bool addTiles(std::list<TileNode::TileQuad>& tileQuads, const tmx::Map& map, const std::vector<tmx::TileLayer::Tile>& tileIDs, const tmx::Vector2u& mapSize, const tmx::Vector2i& offset, int totalRows, const uint32_t vertColor) {
	const auto& tileSets = map.getTilesets();
	const auto mapTileSize = map.getTileSize();
	for (auto i = 0u; i < tileSets.size(); ++i) {
		const auto& ts = tileSets[i];
		const auto tileSetSize = ts.getTileSize();
		auto texture = SharedTextureCache.load(ts.getImagePath());
		if (!texture) {
			return false;
		}

		auto& tileQuad = tileQuads.emplace_back();
		tileQuad.texture = texture;

		const tmx::Vector2u texSize{
			s_cast<unsigned int>(texture->getWidth()),
			s_cast<unsigned int>(texture->getHeight())};

		const auto tileCountX = texSize.x / tileSetSize.x;

		const float uNorm = s_cast<float>(tileSetSize.x) / texSize.x;
		const float vNorm = s_cast<float>(tileSetSize.y) / texSize.y;

		for (auto y = 0u; y < mapSize.y; ++y) {
			for (auto x = 0u; x < mapSize.x; ++x) {
				const auto idx = y * mapSize.x + x;
				if (idx >= tileIDs.size()) break;
				const auto& tile = tileIDs[idx];
				if (tile.ID < ts.getFirstGID() || tileIDs[idx].ID >= (ts.getFirstGID() + ts.getTileCount())) {
					continue;
				}
				auto idIndex = tile.ID - ts.getFirstGID();
				float u = s_cast<float>(idIndex % tileCountX);
				float v = s_cast<float>(idIndex / tileCountX);
				u = u * tileSetSize.x / texSize.x;
				v = v * tileSetSize.y / texSize.y;

				const float tilePosX = s_cast<float>(x) * mapTileSize.x + offset.x;
				const float tilePosY = (totalRows - 1 - s_cast<float>(y)) * mapTileSize.y - offset.y;

				tileQuad.quads.push_back(
					{.rb = {0, 0, 0, 1, u + uNorm, v + vNorm, vertColor},
						.lb = {0, 0, 0, 1, u, v + vNorm, vertColor},
						.lt = {0, 0, 0, 1, u, v, vertColor},
						.rt = {0, 0, 0, 1, u + uNorm, v, vertColor}});

				tileQuad.positions.push_back(
					{.rb = {tilePosX + mapTileSize.x, tilePosY, 0, 1},
						.lb = {tilePosX, tilePosY, 0, 1},
						.lt = {tilePosX, tilePosY + mapTileSize.y, 0, 1},
						.rt = {tilePosX + mapTileSize.x, tilePosY + mapTileSize.y, 0, 1}});
			}
		}
		if (tileQuad.quads.empty()) {
			tileQuads.pop_back();
		}
	}
	return true;
}

static bool addLayer(std::list<TileNode::TileQuad>& tileQuads, const tmx::Map& map, tmx::Layer* target) {
	if (!target) return false;
	if (target->getType() != tmx::Layer::Type::Tile) {
		return false;
	}
	auto& layer = target->getLayerAs<tmx::TileLayer>();
	const auto offset = layer.getOffset();
	const auto mapSize = map.getTileCount();

	const auto tc = target->getTintColour();
	const auto vertColor = Color{tc.r, tc.g, tc.b, tc.a}.toABGR();

	const auto& tileIDs = layer.getTiles();
	if (!tileIDs.empty()) {
		if (!addTiles(tileQuads, map, tileIDs, mapSize, offset, mapSize.y, vertColor)) {
			return false;
		}
	} else {
		const auto mapTileSize = map.getTileSize();
		const auto tileSize = tmx::Vector2i{s_cast<int>(mapTileSize.x), s_cast<int>(mapTileSize.y)};
		for (const auto& chunk : layer.getChunks()) {
			if (!addTiles(tileQuads, map, chunk.tiles, {s_cast<unsigned int>(chunk.size.x), s_cast<unsigned int>(chunk.size.y)}, offset + chunk.position * tileSize, mapSize.y, vertColor)) {
				return false;
			}
		}
	}
	return true;
}

TileNode* TileNode::create(String tmxFile, String layerName) {
	if (auto tmxDef = SharedTMXCache.load(tmxFile)) {
		const auto& map = tmxDef->getMap();
		tmx::Layer* target = nullptr;
		for (const auto& layer : map.getLayers()) {
			if (layerName == layer->getName()) {
				target = layer.get();
				break;
			}
		}
		if (!target) {
			Warn("TMX layer named \"{}\" not found.", layerName.toString());
			return nullptr;
		}
		auto tileNode = Object::createNotNull<TileNode>();
		if (!addLayer(tileNode->_tileQuads, map, target)) {
			Warn("failed to create TMX layer named \"{}\".", layerName.toString());
			tileNode->cleanup();
			return nullptr;
		}
		return tileNode;
	}
	return nullptr;
}

TileNode* TileNode::create(String tmxFile) {
	if (auto tmxDef = SharedTMXCache.load(tmxFile)) {
		const auto& map = tmxDef->getMap();
		auto tileNode = Object::createNotNull<TileNode>();
		for (const auto& layer : map.getLayers()) {
			if (layer->getType() != tmx::Layer::Type::Tile) {
				continue;
			}
			if (!addLayer(tileNode->_tileQuads, map, layer.get())) {
				Warn("failed to create TMX layer named \"{}\".", layer->getName());
				tileNode->cleanup();
				return nullptr;
			}
		}
		return tileNode;
	}
	return nullptr;
}

TileNode* TileNode::create(String tmxFile, const std::vector<std::string>& layerNames) {
	if (auto tmxDef = SharedTMXCache.load(tmxFile)) {
		const auto& map = tmxDef->getMap();
		auto tileNode = Object::createNotNull<TileNode>();
		for (const auto& layerName : layerNames) {
			auto it = std::find_if(map.getLayers().begin(), map.getLayers().end(), [=](const auto& layer) {
				return layer->getName() == layerName;
			});
			if (it == map.getLayers().end()) {
				Warn("TMX layer named \"{}\" not found.", layerName);
				tileNode->cleanup();
				return nullptr;
			}
			if (!addLayer(tileNode->_tileQuads, map, it->get())) {
				Warn("failed to create TMX layer named \"{}\".", layerName);
				tileNode->cleanup();
				return nullptr;
			}
		}
		return tileNode;
	}
	return nullptr;
}

TileNode* TileNode::create(String tmxFile, Slice layerNames[], int count) {
	if (auto tmxDef = SharedTMXCache.load(tmxFile)) {
		const auto& map = tmxDef->getMap();
		auto tileNode = Object::createNotNull<TileNode>();
		for (int i = 0; i < count; ++i) {
			Slice layerName = layerNames[i];
			auto it = std::find_if(map.getLayers().begin(), map.getLayers().end(), [=](const auto& layer) {
				return layer->getName() == layerName;
			});
			if (it == map.getLayers().end()) {
				Warn("TMX layer named \"{}\" not found.", layerName.toString());
				tileNode->cleanup();
				return nullptr;
			}
			if (!addLayer(tileNode->_tileQuads, map, it->get())) {
				Warn("failed to create TMX layer named \"{}\".", layerName.toString());
				tileNode->cleanup();
				return nullptr;
			}
		}
		return tileNode;
	}
	return nullptr;
}

void TileNode::setDepthWrite(bool var) {
	_flags.set(TileNode::DepthWrite, var);
}

bool TileNode::isDepthWrite() const noexcept {
	return _flags.isOn(TileNode::DepthWrite);
}

void TileNode::setFilter(TextureFilter var) {
	_filter = var;
}

TextureFilter TileNode::getFilter() const noexcept {
	return _filter;
}

const Matrix& TileNode::getWorld() {
	if (_flags.isOn(Node::WorldDirty)) {
		_flags.setOn(TileNode::VertexPosDirty);
	}
	return Node::getWorld();
}

void TileNode::render() {
	if (_tileQuads.empty()) {
		Node::render();
		return;
	}

	std::vector<TileQuad*> tileQuads;
	tileQuads.reserve(_tileQuads.size());
	if (SharedDirector.isFrustumCulling()) {
		for (auto& tileQuad : _tileQuads) {
			float minX = tileQuad.positions[0].lb.x;
			float minY = tileQuad.positions[0].lb.y;
			float maxX = tileQuad.positions[0].rt.x;
			float maxY = tileQuad.positions[0].rt.y;
			for (size_t i = 1; i < tileQuad.positions.size(); i++) {
				const SpriteQuad::Position& quadPos = tileQuad.positions[i];
				minX = std::min(minX, quadPos.lb.x);
				minY = std::min(minY, quadPos.lb.y);
				maxX = std::max(maxX, quadPos.rt.x);
				maxY = std::max(maxY, quadPos.rt.y);
			}
			AABB aabb;
			Matrix::mulAABB(aabb, _world, {
											  {minX, minY, 0},
											  {maxX, maxY, 0},
										  });
			if (SharedDirector.isInFrustum(aabb)) {
				tileQuads.push_back(&tileQuad);
			}
		}
	} else {
		for (auto& tileQuad : _tileQuads) {
			tileQuads.push_back(&tileQuad);
		}
	}

	if (tileQuads.empty()) {
		Node::render();
		return;
	}

	if (_flags.isOn(TileNode::VertexPosDirty)) {
		_flags.setOff(TileNode::VertexPosDirty);
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), _world);
		for (auto tileQuad : tileQuads) {
			for (auto i = 0u; i < tileQuad->quads.size(); ++i) {
				auto& quad = tileQuad->quads[i];
				auto& pos = tileQuad->positions[i];
				Matrix::mulVec4(&quad.rb.x, transform, pos.rb);
				Matrix::mulVec4(&quad.lb.x, transform, pos.lb);
				Matrix::mulVec4(&quad.lt.x, transform, pos.lt);
				Matrix::mulVec4(&quad.rt.x, transform, pos.rt);
			}
		}
	}

	uint64_t renderState = (BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_MSAA | _blendFunc.toValue());

	uint32_t flags = BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP;

	switch (_filter) {
		case TextureFilter::Point:
			flags |= (BGFX_SAMPLER_MIN_POINT | BGFX_SAMPLER_MAG_POINT);
			break;
		case TextureFilter::Anisotropic:
			flags |= (BGFX_SAMPLER_MIN_ANISOTROPIC | BGFX_SAMPLER_MAG_ANISOTROPIC);
			break;
		default:
			break;
	}

	if (_flags.isOn(TileNode::DepthWrite)) {
		renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());
	for (const auto tileQuad : tileQuads) {
		SharedSpriteRenderer.push(tileQuad->quads.front(), tileQuad->quads.size() * 4, _effect, tileQuad->texture, renderState, flags);
	}
	Node::render();
}

NS_DORA_END

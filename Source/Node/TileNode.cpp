/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/TileNode.h"

#include "Basic/Director.h"
#include "Cache/TMXCache.h"
#include "Cache/TextureCache.h"
#include "Effect/Effect.h"
#include "Support/Array.h"
#include "Support/Dictionary.h"

#include "tmxlite/ImageLayer.hpp"
#include "tmxlite/LayerGroup.hpp"
#include "tmxlite/ObjectGroup.hpp"
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

static bool addTiles(
	std::list<TileNode::TileQuad>& tileQuads,
	const tmx::Map& map,
	const std::vector<tmx::TileLayer::Tile>& tileIDs,
	const tmx::Vector2u& mapSize,
	const tmx::Vector2i& offset,
	int totalRows,
	const uint32_t vertColor,
	std::vector<TileNode::AnimatedTile>& animatedTiles,
	std::vector<TileNode::Animation>& animations) {
	const auto& tileSets = map.getTilesets();
	const auto mapTileSize = map.getTileSize();
	for (auto i = 0u; i < tileSets.size(); ++i) {
		const auto& ts = tileSets[i];
		auto texture = SharedTextureCache.load(ts.getImagePath());
		if (!texture) {
			return false;
		}
		const auto paddingU = 0.5f / texture->getWidth();
		const auto paddingV = 0.5f / texture->getHeight();

		TileNode::TileQuad* tileQuad = &tileQuads.emplace_back();
		tileQuad->texture = texture;

		for (auto y = 0u; y < mapSize.y; ++y) {
			for (auto x = 0u; x < mapSize.x; ++x) {
				const auto idx = y * mapSize.x + x;
				if (idx >= tileIDs.size()) break;
				const auto& tile = tileIDs[idx];
				const auto* tileInfo = ts.getTile(tile.ID);
				if (!tileInfo) {
					continue;
				}
				if (!tileInfo->imagePath.empty()) {
					Warn("TMX file with embedded image is not supported.");
					return false;
				}
				float u1 = s_cast<float>(tileInfo->imagePosition.x) / texture->getWidth();
				float v1 = s_cast<float>(tileInfo->imagePosition.y) / texture->getHeight();
				float u2 = s_cast<float>(tileInfo->imagePosition.x + tileInfo->imageSize.x) / texture->getWidth();
				float v2 = s_cast<float>(tileInfo->imagePosition.y + tileInfo->imageSize.y) / texture->getHeight();

				const float tilePosX = s_cast<float>(x) * mapTileSize.x + offset.x;
				const float tilePosY = (totalRows - 1 - s_cast<float>(y)) * mapTileSize.y - offset.y;

				const size_t MaxQuadsToSplit = 50;
				if (tileQuad->quads.size() >= MaxQuadsToSplit) {
					tileQuad = &tileQuads.emplace_back();
					tileQuad->texture = texture;
				}

				tileQuad->quads.push_back(
					{.rb = {0, 0, 0, 1, u2 - paddingU, v2 - paddingV, vertColor},
						.lb = {0, 0, 0, 1, u1 + paddingU, v2 - paddingV, vertColor},
						.lt = {0, 0, 0, 1, u1 + paddingU, v1 + paddingV, vertColor},
						.rt = {0, 0, 0, 1, u2 - paddingU, v1 + paddingV, vertColor}});

				if (!tileInfo->animation.frames.empty()) {
					animatedTiles.push_back({.tileQuad = tileQuad,
						.tileIndex = s_cast<int>(tileQuad->quads.size() - 1),
						.flipFlags = tile.flipFlags});
					auto it = std::find_if(animations.begin(), animations.end(), [=](const auto& anim) {
						return anim.tileInfo == tileInfo;
					});
					if (it == animations.end()) {
						animatedTiles.back().animationIndex = s_cast<int>(animations.size());
						float totalTime = std::accumulate(tileInfo->animation.frames.begin(), tileInfo->animation.frames.end(), 0.0f, [](float sum, const auto& frame) {
							return sum + frame.duration / 1000.0f;
						});
						animations.push_back({.duration = 0.0f,
							.totalTime = totalTime,
							.currentTile = r_cast<const void*>(tileInfo),
							.tileInfo = r_cast<const void*>(tileInfo),
							.tileSet = r_cast<const void*>(&ts),
							.texture = MakeRef(texture),
							.u1 = u1,
							.v1 = v1,
							.u2 = u2,
							.v2 = v2,
							.paddingU = paddingU,
							.paddingV = paddingV});
					} else {
						animatedTiles.back().animationIndex = s_cast<int>(std::distance(animations.begin(), it));
					}
				}

				tileQuad->positions.push_back(
					{.rb = {tilePosX + mapTileSize.x, tilePosY, 0, 1},
						.lb = {tilePosX, tilePosY, 0, 1},
						.lt = {tilePosX, tilePosY + mapTileSize.y, 0, 1},
						.rt = {tilePosX + mapTileSize.x, tilePosY + mapTileSize.y, 0, 1}});

				if (tile.flipFlags) {
					auto& quad = tileQuad->quads.back();
					bool dflip = (tile.flipFlags & tmx::TileLayer::Diagonal) != 0;
					if (dflip) {
						std::swap(quad.lb.u, quad.rt.u);
						std::swap(quad.lb.v, quad.rt.v);
					}
					bool hflip = (tile.flipFlags & tmx::TileLayer::Horizontal) != 0;
					if (hflip) {
						std::swap(quad.lb.u, quad.rb.u);
						std::swap(quad.lb.v, quad.rb.v);
						std::swap(quad.lt.u, quad.rt.u);
						std::swap(quad.lt.v, quad.rt.v);
					}
					bool vflip = (tile.flipFlags & tmx::TileLayer::Vertical) != 0;
					if (vflip) {
						std::swap(quad.lb.v, quad.lt.v);
						std::swap(quad.lb.u, quad.lt.u);
						std::swap(quad.rb.v, quad.rt.v);
						std::swap(quad.rb.u, quad.rt.u);
					}
				}
			}
		}
		if (tileQuad->quads.empty()) {
			tileQuads.pop_back();
		}
	}
	return true;
}

static bool addLayer(
	std::list<TileNode::TileQuad>& tileQuads,
	const tmx::Map& map,
	tmx::Layer* target,
	std::vector<TileNode::AnimatedTile>& animatedTiles,
	std::vector<TileNode::Animation>& animations) {
	if (!target) return false;
	switch (target->getType()) {
		case tmx::Layer::Type::Group: {
			auto& layer = target->getLayerAs<tmx::LayerGroup>();
			for (const auto& lyr : layer.getLayers()) {
				if (lyr->getType() != tmx::Layer::Type::Tile && lyr->getType() != tmx::Layer::Type::Group) {
					continue;
				}
				if (!addLayer(tileQuads, map, lyr.get(), animatedTiles, animations)) {
					return false;
				}
			}
			return true;
		}
		case tmx::Layer::Type::Tile:
			break;
		default:
			return false;
	}
	auto& layer = target->getLayerAs<tmx::TileLayer>();
	const auto offset = layer.getOffset();
	const auto mapSize = map.getTileCount();

	const auto tc = target->getTintColour();
	const auto vertColor = Color{tc.r, tc.g, tc.b, tc.a}.toABGR();

	if (map.isInfinite()) {
		const auto mapTileSize = map.getTileSize();
		const auto tileSize = tmx::Vector2i{s_cast<int>(mapTileSize.x), s_cast<int>(mapTileSize.y)};
		for (const auto& chunk : layer.getChunks()) {
			if (!addTiles(
					tileQuads,
					map,
					chunk.tiles,
					{s_cast<unsigned int>(chunk.size.x), s_cast<unsigned int>(chunk.size.y)},
					offset + chunk.position * tileSize,
					mapSize.y,
					vertColor,
					animatedTiles,
					animations)) {
				return false;
			}
		}
	} else {
		const auto& tileIDs = layer.getTiles();
		if (!addTiles(
				tileQuads,
				map,
				tileIDs,
				mapSize,
				offset,
				mapSize.y, vertColor, animatedTiles, animations)) {
			return false;
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
		if (!addLayer(tileNode->_tileQuads, map, target, tileNode->_animatedTiles, tileNode->_animations)) {
			Warn("failed to create TMX layer named \"{}\".", layerName.toString());
			tileNode->cleanup();
			return nullptr;
		}
		tileNode->_tmxDef = tmxDef;
		return tileNode;
	}
	return nullptr;
}

TileNode* TileNode::create(String tmxFile) {
	if (auto tmxDef = SharedTMXCache.load(tmxFile)) {
		const auto& map = tmxDef->getMap();
		auto tileNode = Object::createNotNull<TileNode>();
		for (const auto& layer : map.getLayers()) {
			if (layer->getType() != tmx::Layer::Type::Tile && layer->getType() != tmx::Layer::Type::Group) {
				continue;
			}
			if (!addLayer(tileNode->_tileQuads, map, layer.get(), tileNode->_animatedTiles, tileNode->_animations)) {
				Warn("failed to create TMX layer named \"{}\".", layer->getName());
				tileNode->cleanup();
				return nullptr;
			}
		}
		tileNode->_tmxDef = tmxDef;
		if (!tileNode->_animatedTiles.empty()) {
			tileNode->scheduleUpdate();
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
			if (!addLayer(tileNode->_tileQuads, map, it->get(), tileNode->_animatedTiles, tileNode->_animations)) {
				Warn("failed to create TMX layer named \"{}\".", layerName);
				tileNode->cleanup();
				return nullptr;
			}
		}
		tileNode->_tmxDef = tmxDef;
		if (!tileNode->_animatedTiles.empty()) {
			tileNode->scheduleUpdate();
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
			if (!addLayer(tileNode->_tileQuads, map, it->get(), tileNode->_animatedTiles, tileNode->_animations)) {
				Warn("failed to create TMX layer named \"{}\".", layerName.toString());
				tileNode->cleanup();
				return nullptr;
			}
		}
		tileNode->_tmxDef = tmxDef;
		if (!tileNode->_animatedTiles.empty()) {
			tileNode->scheduleUpdate();
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

	if (_flags.isOn(TileNode::VertexPosDirty)) {
		_flags.setOff(TileNode::VertexPosDirty);
		for (auto& tileQuad : _tileQuads) {
			tileQuad.vertexPosDirty = true;
		}
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
			Matrix::mulAABB(aabb, getWorld(), {
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

	Matrix transform;
	bool transformInit = false;
	for (auto tileQuad : tileQuads) {
		if (tileQuad->vertexPosDirty) {
			tileQuad->vertexPosDirty = false;
			if (!transformInit) {
				transformInit = true;
				Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
			}
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

	uint32_t flags = BGFX_SAMPLER_U_MIRROR | BGFX_SAMPLER_V_MIRROR;

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

bool TileNode::update(double deltaTime) {
	if (isUpdating()) {
		bool tileUpdated = false;
		for (auto& animation : _animations) {
			const auto* ts = r_cast<const tmx::Tileset*>(animation.tileSet);
			animation.duration += deltaTime;
			if (animation.duration > animation.totalTime) {
				animation.duration -= animation.totalTime;
			}
			auto tileInfo = r_cast<const tmx::Tileset::Tile*>(animation.tileInfo);
			float time = 0.0f;
			const tmx::Tileset::Tile* currentTile = nullptr;
			for (const auto& frame : tileInfo->animation.frames) {
				time += frame.duration / 1000.0f;
				if (time >= animation.duration) {
					currentTile = ts->getTile(frame.tileID);
					break;
				}
			}
			if (currentTile && currentTile != animation.currentTile) {
				animation.currentTile = currentTile;
				Texture2D* texture = animation.texture;
				animation.u1 = s_cast<float>(currentTile->imagePosition.x) / texture->getWidth();
				animation.v1 = s_cast<float>(currentTile->imagePosition.y) / texture->getHeight();
				animation.u2 = s_cast<float>(currentTile->imagePosition.x + currentTile->imageSize.x) / texture->getWidth();
				animation.v2 = s_cast<float>(currentTile->imagePosition.y + currentTile->imageSize.y) / texture->getHeight();
				animation.paddingU = 0.5f / texture->getWidth();
				animation.paddingV = 0.5f / texture->getHeight();
				tileUpdated = true;
			}
		}
		if (tileUpdated) {
			for (auto& animTile : _animatedTiles) {
				const auto& animation = _animations[animTile.animationIndex];
				auto& quad = animTile.tileQuad->quads[animTile.tileIndex];
				quad.rb.u = animation.u2 - animation.paddingU;
				quad.rb.v = animation.v2 - animation.paddingV;
				quad.lb.u = animation.u1 + animation.paddingU;
				quad.lb.v = animation.v2 - animation.paddingV;
				quad.lt.u = animation.u1 + animation.paddingU;
				quad.lt.v = animation.v1 + animation.paddingV;
				quad.rt.u = animation.u2 - animation.paddingU;
				quad.rt.v = animation.v1 + animation.paddingV;
				if (animTile.flipFlags) {
					bool dflip = (animTile.flipFlags & tmx::TileLayer::Diagonal) != 0;
					if (dflip) {
						std::swap(quad.lb.u, quad.rt.u);
						std::swap(quad.lb.v, quad.rt.v);
					}
					bool hflip = (animTile.flipFlags & tmx::TileLayer::Horizontal) != 0;
					if (hflip) {
						std::swap(quad.lb.u, quad.rb.u);
						std::swap(quad.lb.v, quad.rb.v);
						std::swap(quad.lt.u, quad.rt.u);
						std::swap(quad.lt.v, quad.rt.v);
					}
					bool vflip = (animTile.flipFlags & tmx::TileLayer::Vertical) != 0;
					if (vflip) {
						std::swap(quad.lb.v, quad.lt.v);
						std::swap(quad.lb.u, quad.lt.u);
						std::swap(quad.rb.v, quad.rt.v);
						std::swap(quad.rb.u, quad.rt.u);
					}
				}
			}
		}
	}
	return Node::update(deltaTime);
}

static Own<Value> getProperties(const std::vector<tmx::Property>& props, const tmx::Map& map) {
	Dictionary* properties = Dictionary::create();
	for (const auto& prop : props) {
		switch (prop.getType()) {
			case tmx::Property::Type::Boolean:
				properties->set(prop.getName(), Value::alloc(prop.getBoolValue()));
				break;
			case tmx::Property::Type::Float:
				properties->set(prop.getName(), Value::alloc(prop.getFloatValue()));
				break;
			case tmx::Property::Type::Int:
				properties->set(prop.getName(), Value::alloc(prop.getIntValue()));
				break;
			case tmx::Property::Type::String:
				properties->set(prop.getName(), Value::alloc(prop.getStringValue()));
				break;
			case tmx::Property::Type::Colour: {
				auto colour = prop.getColourValue();
				properties->set(prop.getName(), Value::alloc(Color{colour.r, colour.g, colour.b, colour.a}.toARGB()));
				break;
			}
			case tmx::Property::Type::File:
				properties->set(prop.getName(), Value::alloc(Path::concat({map.getWorkingDirectory(), prop.getFileValue()})));
				break;
			case tmx::Property::Type::Object:
				properties->set(prop.getName(), Value::alloc(prop.getObjectValue()));
				break;
			case tmx::Property::Type::Class:
				properties->set(prop.getName(), getProperties(prop.getClassValue(), map));
				break;
			case tmx::Property::Type::Undef:
				break;
		}
	}
	return Value::alloc(properties);
}

static Dictionary* getLayerDict(tmx::Layer* target, const tmx::Map& map) {
	Dictionary* data = Dictionary::create();
	data->set("name"sv, Value::alloc(target->getName()));
	data->set("class"sv, Value::alloc(target->getClass()));
	data->set("opacity"sv, Value::alloc(target->getOpacity()));
	data->set("visible"sv, Value::alloc(target->getVisible()));
	{
		auto tc = target->getTintColour();
		data->set("tintColor"sv, Value::alloc(Color{tc.r, tc.g, tc.b, tc.a}.toARGB()));
	}
	data->set("size"sv, Value::alloc(Size{s_cast<float>(target->getSize().x), s_cast<float>(target->getSize().y)}));
	data->set("offset"sv, Value::alloc(Vec2{s_cast<float>(target->getOffset().x), s_cast<float>(target->getOffset().y)}));
	data->set("parallaxFactor"sv, Value::alloc(Vec2{s_cast<float>(target->getParallaxFactor().x), s_cast<float>(target->getParallaxFactor().y)}));
	if (!target->getProperties().empty()) {
		data->set("properties"sv, getProperties(target->getProperties(), map));
	}
	switch (target->getType()) {
		case tmx::Layer::Type::Tile: {
			data->set("type"sv, Value::alloc("Tile"sv));
			const auto& layer = target->getLayerAs<tmx::TileLayer>();
			if (map.isInfinite()) {
				Array* chunks = Array::create();
				for (const auto& c : layer.getChunks()) {
					Dictionary* chunkData = Dictionary::create();
					chunkData->set("size"sv, Value::alloc(Size{s_cast<float>(c.size.x), s_cast<float>(c.size.y)}));
					chunkData->set("position"sv, Value::alloc(Size{s_cast<float>(c.position.x), s_cast<float>(c.position.y)}));
					Array* tiles = Array::create(c.tiles.size());
					for (const auto& t : c.tiles) {
						tiles->add(Value::alloc(t.ID));
					}
					chunkData->set("tiles"sv, Value::alloc(tiles));
					chunks->add(Value::alloc(chunkData));
				}
				data->set("chunks", Value::alloc(chunks));
			} else {
				Array* tiles = Array::create(layer.getTiles().size());
				for (const auto& t : layer.getTiles()) {
					tiles->add(Value::alloc(t.ID));
				}
				data->set("tiles", Value::alloc(tiles));
			}
			break;
		}
		case tmx::Layer::Type::Object: {
			data->set("type"sv, Value::alloc("Object"sv));
			const auto& layer = target->getLayerAs<tmx::ObjectGroup>();
			switch (layer.getDrawOrder()) {
				case tmx::ObjectGroup::DrawOrder::Index:
					data->set("drawOrder", Value::alloc("Index"sv));
					break;
				case tmx::ObjectGroup::DrawOrder::TopDown:
					data->set("drawOrder", Value::alloc("TopDown"sv));
					break;
			}
			auto c = layer.getColour();
			data->set("color"sv, Value::alloc(Color{c.r, c.g, c.b, c.a}.toARGB()));
			Array* objects = Array::create(layer.getObjects().size());
			for (const auto& object : layer.getObjects()) {
				Dictionary* obj = Dictionary::create();
				obj->set("name"sv, Value::alloc(object.getName()));
				obj->set("uid"sv, Value::alloc(object.getUID()));
				obj->set("class"sv, Value::alloc(object.getClass()));
				obj->set("size"sv, Value::alloc(Size{object.getAABB().width, object.getAABB().height}));
				obj->set("position"sv, Value::alloc(Vec2{s_cast<float>(object.getPosition().x), s_cast<float>(object.getPosition().y)}));
				obj->set("rotation"sv, Value::alloc(-object.getRotation()));
				if (object.getTileID() > 0) {
					obj->set("tile"sv, Value::alloc(object.getTileID()));
				}
				if (!object.getTilesetName().empty()) {
					obj->set("tileSet"sv, Value::alloc(object.getTilesetName()));
				}
				if (object.getFlipFlags() > 0) {
					if ((object.getFlipFlags() & tmx::TileLayer::Horizontal) != 0) {
						obj->set("horizontalFlip"sv, Value::alloc(true));
					}
					if ((object.getFlipFlags() & tmx::TileLayer::Vertical) != 0) {
						obj->set("verticalFlip"sv, Value::alloc(true));
					}
					if ((object.getFlipFlags() & tmx::TileLayer::Diagonal) != 0) {
						obj->set("diagonalFlip"sv, Value::alloc(true));
					}
				}
				obj->set("visible"sv, Value::alloc(object.visible()));
				switch (object.getShape()) {
					case tmx::Object::Shape::Rectangle:
						obj->set("shape"sv, Value::alloc("Rectangle"sv));
						break;
					case tmx::Object::Shape::Ellipse:
						obj->set("shape"sv, Value::alloc("Ellipse"sv));
						break;
					case tmx::Object::Shape::Point:
						obj->set("shape"sv, Value::alloc("Point"sv));
						break;
					case tmx::Object::Shape::Polygon:
						obj->set("shape"sv, Value::alloc("Polygon"sv));
						break;
					case tmx::Object::Shape::Polyline:
						obj->set("shape"sv, Value::alloc("Polyline"sv));
						break;
					case tmx::Object::Shape::Text:
						obj->set("shape"sv, Value::alloc("Text"sv));
						obj->set("text"sv, Value::alloc(object.getText().content));
						break;
				}
				if (!object.getPoints().empty()) {
					Array* points = Array::create(object.getPoints().size());
					for (const auto& p : object.getPoints()) {
						points->add(Value::alloc(Vec2{p.x, p.y}));
					}
					obj->set("points"sv, Value::alloc(points));
				}
				if (!object.getProperties().empty()) {
					obj->set("properties"sv, getProperties(object.getProperties(), map));
				}
				objects->add(Value::alloc(obj));
			}
			data->set("objects"sv, Value::alloc(objects));
			break;
		}
		case tmx::Layer::Type::Image: {
			data->set("type"sv, Value::alloc("Image"sv));
			const auto& layer = target->getLayerAs<tmx::ImageLayer>();
			if (layer.hasTransparency()) {
				auto tc = layer.getTransparencyColour();
				data->set("transparencyColor"sv, Value::alloc(Color{tc.r, tc.g, tc.b, tc.a}.toARGB()));
			}
			data->set("imagePath"sv, Value::alloc(Path::concat({map.getWorkingDirectory(), layer.getImagePath()})));
			data->set("imageSize"sv, Value::alloc(Size{s_cast<float>(layer.getImageSize().x), s_cast<float>(layer.getImageSize().y)}));
			if (layer.hasRepeatX()) {
				data->set("repeatX"sv, Value::alloc(true));
			}
			if (layer.hasRepeatY()) {
				data->set("repeatY"sv, Value::alloc(true));
			}
			break;
		}
		case tmx::Layer::Type::Group: {
			data->set("type"sv, Value::alloc("Group"sv));
			const auto& layer = target->getLayerAs<tmx::LayerGroup>();
			if (!layer.getLayers().empty()) {
				Array* layers = Array::create(layer.getLayers().size());
				for (const auto& layer : layer.getLayers()) {
					layers->add(Value::alloc(getLayerDict(layer.get(), map)));
				}
				data->set("layers"sv, Value::alloc(layers));
			}
			break;
		}
	}
	return data;
}

Dictionary* TileNode::getLayer(String layerName) const {
	const auto& map = _tmxDef->getMap();
	tmx::Layer* target = nullptr;
	for (const auto& layer : map.getLayers()) {
		if (layerName == layer->getName()) {
			target = layer.get();
			break;
		}
	}
	if (!target) {
		return nullptr;
	}
	return getLayerDict(target, map);
}

NS_DORA_END

/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Sprite.h"

NS_DORA_BEGIN

class TMXDef;

struct TileInfo {
	std::string textureFile;
	Rect textureRect;
};

class TileNode : public Node {
public:
	struct TileQuad {
		bool vertexPosDirty = true;
		Ref<Texture2D> texture;
		std::vector<SpriteQuad::Position> positions;
		std::vector<SpriteQuad> quads;
	};
	struct AnimatedTile {
		TileQuad* tileQuad;
		int tileIndex;
		uint8_t flipFlags;
		int animationIndex;
	};
	struct Animation {
		float duration;
		float totalTime;
		const void* currentTile;
		const void* tileInfo;
		const void* tileSet;
		Ref<Texture2D> texture;
		float u1, v1, u2, v2, paddingU, paddingV;
	};
	PROPERTY(SpriteEffect*, Effect);
	PROPERTY_CREF(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY(TextureFilter, Filter);
	virtual void render() override;
	virtual bool update(double deltaTime) override;
	virtual void cleanup() override;
	virtual const Matrix& getWorld() override;
	Dictionary* getLayer(String layerName) const;
	static TileNode* create(String tmxFile);
	static TileNode* create(String tmxFile, String layerName);
	static TileNode* create(String tmxFile, const std::vector<std::string>& layerNames);
	static TileNode* create(String tmxFile, Slice layerNames[], int count);

protected:
	TileNode();

private:
	Ref<SpriteEffect> _effect;
	BlendFunc _blendFunc;
	TextureFilter _filter;
	Ref<TMXDef> _tmxDef;
	std::list<TileQuad> _tileQuads;
	enum : Flag::ValueType {
		VertexPosDirty = Node::UserFlag,
		DepthWrite = Node::UserFlag << 1,
	};
	std::vector<AnimatedTile> _animatedTiles;
	std::vector<Animation> _animations;
	friend class Object;
	DORA_TYPE_OVERRIDE(TileNode);
};

NS_DORA_END

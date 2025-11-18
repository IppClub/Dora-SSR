/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "Node/Sprite.h"
#include "Support/Geometry.h"

NS_DORA_BEGIN

class SpriteEffect;
class Font;

enum struct TextAlign {
	Left = 0,
	Center = 1,
	Right = 2
};

class Label : public Node {
public:
	virtual ~Label();
	PROPERTY(TextAlign, Alignment);
	PROPERTY(float, TextWidth);
	PROPERTY(float, Spacing);
	PROPERTY(float, LineGap);
	PROPERTY_STRING(Text);
	PROPERTY(SpriteEffect*, Effect);
	PROPERTY_CREF(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY(float, AlphaRef);
	PROPERTY(Color, OutlineColor);
	PROPERTY(float, OutlineWidth);
	PROPERTY(Vec2, Smooth);
	PROPERTY_BOOL(Batched);
	virtual void setRenderOrder(int var) override;
	Sprite* getCharacter(int index) const;
	int getCharacterCount() const;
	virtual bool init() override;
	virtual void render() override;
	virtual void cleanup() override;
	virtual const Matrix& getWorld() override;
	static const float AutomaticWidth;
	CREATE_FUNC_NULLABLE(Label);

protected:
	Label(String fontStr);
	Label(String fontName, uint32_t fontSize, bool sdf = false);
	void updateCharacters(const std::vector<uint32_t>& chars);
	void updateLabel();
	struct CharItem {
		CharItem()
			: code(0)
			, texture(nullptr)
			, rect{}
			, pos{}
			, startX(0)
			, sprite(nullptr) { }
		uint32_t code;
		Texture2D* texture;
		Rect rect;
		Vec2 pos;
		float startX;
		Sprite* sprite;
	};
	float getLetterPosXLeft(CharItem* item);
	float getLetterPosXRight(CharItem* item);
	void updateVertTexCoord();
	void updateVertPosition();
	void updateVertColor();
	virtual void updateRealColor3() override;
	virtual void updateRealOpacity() override;

private:
	uint8_t _alphaRef;
	float _spacing;
	float _textWidth;
	float _lineGap;
	Color _outlineColor;
	float _outlineWidth;
	Vec2 _smooth;
	Ref<Font> _font;
	Ref<SpriteEffect> _effect;
	BlendFunc _blendFunc;
	TextAlign _alignment;
	std::string _textUTF8;
	std::vector<uint32_t> _text;
	OwnVector<CharItem> _characters;
	std::vector<SpriteQuad::Position> _quadPos;
	std::vector<SpriteQuad> _quads;
	enum : Flag::ValueType {
		DepthWrite = Node::UserFlag,
		TextBatched = Node::UserFlag << 1,
		QuadDirty = Node::UserFlag << 2,
		VertexColorDirty = Node::UserFlag << 3,
		VertexPosDirty = Node::UserFlag << 4,
	};
	DORA_TYPE_OVERRIDE(Label);
};

NS_DORA_END

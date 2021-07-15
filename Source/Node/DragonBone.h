/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Playable.h"
#include "DragonBonesHeaders.h"
#include "Node/Sprite.h"

namespace db = dragonBones;

NS_DOROTHY_BEGIN

class DBSlotNode : public Node
{
public:
	virtual void render() override;
	virtual const Matrix& getWorld() override;
	CREATE_FUNC(DBSlotNode);
protected:
	DBSlotNode();
private:
	Ref<SpriteEffect> _effect;
	BlendFunc _blendFunc = BlendFunc::Default;
	Ref<Texture2D> _texture;
	std::vector<Vec4> _points;
	std::vector<SpriteVertex> _vertices;
	std::vector<SpriteRenderer::IndexType> _indices;
	Matrix _matrix = Matrix::Indentity;
	AffineTransform _transform = AffineTransform::Indentity;
	enum
	{
		TransformDirty = Node::UserFlag,
	};
	friend class DBSlot;
};

class DBSlot : public db::Slot
{
	BIND_CLASS_TYPE_A(DBSlot);
public:
	PROPERTY_READONLY(float, TextureScale);
	virtual void _updateVisible() override;
	virtual void _updateBlendMode() override;
	virtual void _updateColor() override;
protected:
	virtual void _onClear() override;
	virtual void _initDisplay(void* value, bool isRetain) override;
	virtual void _disposeDisplay(void* value, bool isRelease) override;
	virtual void _onUpdateDisplay() override;
	virtual void _addDisplay() override;
	virtual void _replaceDisplay(void* value, bool isArmatureDisplay) override;
	virtual void _removeDisplay() override;
	virtual void _updateZOrder() override;
	virtual void _updateFrame() override;
	virtual void _updateMesh() override;
	virtual void _updateTransform() override;
	virtual void _identityTransform() override;
private:
	float _textureScale;
	Ref<DBSlotNode> _node;
};

class SpriteEffect;
class DrawNode;
class Line;

class DragonBone : public Playable
{
private:
	class DBArmatureProxy : public db::IArmatureProxy
	{
	public:
		PROPERTY_READONLY(DragonBone*, Parent);
		DBArmatureProxy(DragonBone* parent);
		virtual void dbInit(db::Armature* armature) override;
		virtual void dbClear() override;
		virtual void dbUpdate() override;
		virtual void dispose(bool disposeProxy = true) override;
		virtual bool hasDBEventListener(const std::string& type) const override;
		virtual void dispatchDBEvent(const std::string& type, db::EventObject* value) override;
		virtual db::Armature* getArmature() const override;
		virtual db::Animation* getAnimation() const override;
	private:
		DragonBone* _parent;
		db::Armature* _armature;
	};
public:
	PROPERTY_BOOL(DepthWrite);
	PROPERTY_BOOL(HitTestEnabled);
	PROPERTY_BOOL(ShowDebug);
	PROPERTY_READONLY(DBArmatureProxy*, ArmatureProxy);
	virtual void cleanup() override;
	virtual void visit() override;
	virtual void render() override;
	virtual void setSpeed(float var) override;
	virtual void setRecovery(float var) override;
	virtual void setFliped(bool var) override;
	virtual void setLook(String var) override;
	virtual const std::string& getCurrent() const override;
	virtual const std::string& getLastCompleted() const override;
	virtual Vec2 getKeyPoint(String name) const override;
	virtual float play(String name, bool loop = false) override;
	virtual void stop() override;
	std::string containsPoint(float x, float y);
	std::string intersectsSegment(float x1, float y1, float x2, float y2);
	static DragonBone* create(String boneFile, String atlasFile);
	static DragonBone* create(String boneStr);
protected:
	DragonBone();
	static DragonBone* create();
private:
	std::string _currentAnimationName;
	std::string _lastCompletedAnimationName;
	Own<DBArmatureProxy> _armatureProxy;
	Ref<SpriteEffect> _effect;
	Ref<Line> _debugLine;
	enum
	{
		DepthWrite = Node::UserFlag,
		HitTest = Node::UserFlag << 1,
	};
	friend class DragonBoneCache;
	DORA_TYPE_OVERRIDE(DragonBone);
};

NS_DOROTHY_END

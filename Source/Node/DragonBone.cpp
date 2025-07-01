/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/DragonBone.h"

#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Cache/DragonBoneCache.h"
#include "Cache/TextureCache.h"
#include "Effect/Effect.h"
#include "Node/DrawNode.h"
#include "Node/Sprite.h"
#include "Support/Common.h"

NS_DORA_BEGIN

/* DBSlotNode */

DBSlotNode::DBSlotNode()
	: _blendFunc(BlendFunc::Default)
	, _effect(SharedSpriteRenderer.getDefaultEffect())
	, _matrix(Matrix::Indentity)
	, _transform(AffineTransform::Indentity) { }

void DBSlotNode::render() {
	if (!_texture || !_effect || _vertices.empty()) {
		Node::render();
		return;
	}

	if (SharedDirector.isFrustumCulling()) {
		auto [minX, maxX] = std::minmax_element(_points.begin(), _points.end(), [](const auto& a, const auto& b) {
			return a.x < b.x;
		});
		auto [minY, maxY] = std::minmax_element(_points.begin(), _points.end(), [](const auto& a, const auto& b) {
			return a.y < b.y;
		});
		AABB aabb;
		Matrix::mulAABB(aabb, _matrix, {
										   {minX->x, minY->y, 0},
										   {maxX->x, maxY->y, 0},
									   });
		if (!SharedDirector.isInFrustum(aabb)) {
			return;
		}
	}

	Matrix transform;
	Matrix::mulMtx(transform, SharedDirector.getViewProjection(), _matrix);
	for (size_t i = 0; i < _points.size(); i++) {
		Matrix::mulVec4(&_vertices[i].x, transform, _points[i]);
	}

	auto parent = s_cast<DragonBone*>(getParent());
	uint64_t renderState = (BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_MSAA | _blendFunc.toValue());
	if (parent->isDepthWrite()) {
		renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());
	SharedSpriteRenderer.push(
		_vertices.data(), _vertices.size(),
		_indices.data(), _indices.size(),
		_effect, _texture, renderState);

	Node::render();
}

const AffineTransform& DBSlotNode::getDBTransform() const noexcept {
	return _transform;
}

const Matrix& DBSlotNode::getWorld() {
	if (_flags.isOn(DBSlotNode::TransformDirty) || _flags.isOn(Node::WorldDirty)) {
		_flags.setOff(DBSlotNode::TransformDirty);
		Matrix mat;
		_transform.toMatrix(mat);
		Matrix::mulMtx(_matrix, Node::getWorld(), mat);
	}
	return _matrix;
}

/* DBSlot */

float DBSlot::getTextureScale() const noexcept {
	return _textureScale;
}

DBSlotNode* DBSlot::getNode() const noexcept {
	return _node;
}

void DBSlot::_onClear() {
	db::Slot::_onClear();
	_textureScale = 1.0f;
	_node = nullptr;
}

void DBSlot::_initDisplay(void* value, bool isRetain) {
	DORA_UNUSED_PARAM(isRetain);
	_node = s_cast<DBSlotNode*>(value);
	_node->setTag(getName());
}

void DBSlot::_disposeDisplay(void* value, bool isRelease) {
	DORA_UNUSED_PARAM(value);
	DORA_UNUSED_PARAM(isRelease);
	_node = nullptr;
}

void DBSlot::_onUpdateDisplay() {
	_node = s_cast<DBSlotNode*>(_display != nullptr ? _display : _rawDisplay);
}

void DBSlot::_addDisplay() {
	const auto container = s_cast<DragonBone*>(_armature->getDisplay());
	container->addChild(_node);
}

void DBSlot::_replaceDisplay(void* value, bool isArmatureDisplay) {
	const auto container = s_cast<DragonBone*>(_armature->getDisplay());
	const auto prevNode = s_cast<DBSlotNode*>(value);
	container->addChild(_node, prevNode->getOrder());
	container->removeChild(prevNode);
	_textureScale = 1.0f;
}

void DBSlot::_removeDisplay() {
	_node->removeFromParent();
}

void DBSlot::_updateZOrder() {
	if (_node->getOrder() == _zOrder) {
		return;
	}
	_node->setOrder(_zOrder);
}

void DBSlot::_updateFrame() {
	const auto currentVerticesData = (_deformVertices != nullptr && _display == _meshDisplay) ? _deformVertices->verticesData : nullptr;
	const auto currentTextureData = s_cast<DBTextureData*>(_textureData);
	if (_displayIndex >= 0 && _display != nullptr && currentTextureData != nullptr) {
		if (currentVerticesData != nullptr) // Mesh.
		{
			const auto data = currentVerticesData->data;
			const auto intArray = data->intArray;
			const auto floatArray = data->floatArray;
			const unsigned vertexCount = intArray[currentVerticesData->offset + s_cast<unsigned>(db::BinaryOffset::MeshVertexCount)];
			const unsigned triangleCount = intArray[currentVerticesData->offset + s_cast<unsigned>(db::BinaryOffset::MeshTriangleCount)];
			int vertexOffset = intArray[currentVerticesData->offset + s_cast<unsigned>(db::BinaryOffset::MeshFloatOffset)];
			if (vertexOffset < 0) {
				vertexOffset += 65536; // Fixed out of bouds bug.
			}
			const unsigned uvOffset = vertexOffset + vertexCount * 2;
			const auto& region = currentTextureData->region;
			Texture2D* texture = s_cast<DBTextureAtlasData*>(currentTextureData->parent)->getTexture();
			_node->_texture = texture;
			_node->_points.resize(vertexCount);
			_node->_vertices.resize(vertexCount);
			_node->_indices.resize(triangleCount * 3);
			for (std::size_t i = 0, l = vertexCount * 2; i < l; i += 2) {
				const auto iH = i / 2;
				const auto x = floatArray[vertexOffset + i];
				const auto y = floatArray[vertexOffset + i + 1];
				auto u = floatArray[uvOffset + i];
				auto v = floatArray[uvOffset + i + 1];
				_node->_points[iH] = {x, -y, 0.0f, 1.0f};
				SpriteVertex& vertex = _node->_vertices[iH];
				if (currentTextureData->rotated) {
					vertex.u = (region.x + (1.0f - v) * region.width) / texture->getWidth();
					vertex.v = (region.y + u * region.height) / texture->getHeight();
				} else {
					vertex.u = (region.x + u * region.width) / texture->getWidth();
					vertex.v = (region.y + v * region.height) / texture->getHeight();
				}
				vertex.abgr = 0xffffffff;
			}
			for (std::size_t i = 0; i < triangleCount * 3; ++i) {
				_node->_indices[i] = intArray[currentVerticesData->offset + s_cast<unsigned>(db::BinaryOffset::MeshVertexIndices) + i];
			}
			_textureScale = 1.0f;
			const auto isSkinned = currentVerticesData->weight != nullptr;
			if (isSkinned) {
				_identityTransform();
			}
		} else {
			_textureScale = currentTextureData->parent->scale * _armature->_armatureData->scale;
			Texture2D* texture = s_cast<DBTextureAtlasData*>(currentTextureData->parent)->getTexture();
			_node->_texture = texture;
			const auto& region = currentTextureData->region;
			const bgfx::TextureInfo& info = texture->getInfo();
			auto& verts = _node->_vertices;
			if (currentTextureData->rotated) _node->setAngle(90);
			verts.resize(4);
			{
				float left = region.x / info.width;
				float top = region.y / info.height;
				float right = (region.x + region.width) / info.width;
				float bottom = (region.y + region.height) / info.height;
				verts[0].u = right;
				verts[0].v = bottom;
				verts[1].u = left;
				verts[1].v = bottom;
				verts[2].u = left;
				verts[2].v = top;
				verts[3].u = right;
				verts[3].v = top;
				verts[0].abgr = 0xffffffff;
				verts[1].abgr = 0xffffffff;
				verts[2].abgr = 0xffffffff;
				verts[3].abgr = 0xffffffff;
			}
			auto& points = _node->_points;
			points.resize(4);
			{
				float width = region.width;
				float height = region.height;
				float left = 0, right = width, top = height, bottom = 0;
				points[0] = {right, bottom, 0, 1.0f};
				points[1] = {left, bottom, 0, 1.0f};
				points[2] = {left, top, 0, 1.0f};
				points[3] = {right, top, 0, 1.0f};
			}
			_node->_indices = {0, 1, 2, 2, 3, 0};
		}
		_visibleDirty = true;
		_blendModeDirty = true; // Relpace texture will override blendMode and color.
		_colorDirty = true;
		return;
	}
	_textureScale = _armature->_armatureData->scale;
	_node->_vertices.clear();
	_node->_indices.clear();
	_node->_texture = nullptr;
	_node->setPosition(Vec2::zero);
	_node->setVisible(false);
}

void DBSlot::_updateMesh() {
	const auto textureData = s_cast<DBTextureData*>(_textureData);
	if (!textureData) {
		return;
	}
	const auto scale = _armature->_armatureData->scale;
	const auto& deformVertices = _deformVertices->vertices;
	const auto& bones = _deformVertices->bones;
	const auto verticesData = _deformVertices->verticesData;
	const auto weightData = verticesData->weight;
	const auto hasFFD = !deformVertices.empty();
	auto& points = _node->_points;
	if (weightData != nullptr) {
		const auto data = verticesData->data;
		const auto intArray = data->intArray;
		const auto floatArray = data->floatArray;
		const auto vertexCount = (std::size_t)intArray[verticesData->offset + s_cast<unsigned>(db::BinaryOffset::MeshVertexCount)];
		int weightFloatOffset = intArray[weightData->offset + s_cast<unsigned>(db::BinaryOffset::WeigthFloatOffset)];
		if (weightFloatOffset < 0) {
			weightFloatOffset += 65536; // Fixed out of bouds bug.
		}
		for (std::size_t i = 0,
						 iB = weightData->offset + s_cast<unsigned>(db::BinaryOffset::WeigthBoneIndices) + bones.size(),
						 iV = s_cast<std::size_t>(weightFloatOffset),
						 iF = 0;
			i < vertexCount;
			++i) {
			const auto boneCount = s_cast<std::size_t>(intArray[iB++]);
			auto xG = 0.0f, yG = 0.0f;
			for (std::size_t j = 0; j < boneCount; ++j) {
				const auto boneIndex = s_cast<unsigned>(intArray[iB++]);
				const auto bone = bones[boneIndex];
				if (bone != nullptr) {
					const auto& matrix = bone->globalTransformMatrix;
					const auto weight = floatArray[iV++];
					auto xL = floatArray[iV++] * scale;
					auto yL = floatArray[iV++] * scale;
					if (hasFFD) {
						xL += deformVertices[iF++];
						yL += deformVertices[iF++];
					}
					xG += (matrix.a * xL + matrix.c * yL + matrix.tx) * weight;
					yG += (matrix.b * xL + matrix.d * yL + matrix.ty) * weight;
				}
			}
			auto& point = points[i];
			point.x = xG;
			point.y = -yG;
			point.z = 0.0f;
		}
	} else if (hasFFD) {
		const auto data = verticesData->data;
		const auto intArray = data->intArray;
		const auto floatArray = data->floatArray;
		const auto vertexCount = s_cast<std::size_t>(intArray[verticesData->offset + s_cast<unsigned>(db::BinaryOffset::MeshVertexCount)]);
		int vertexOffset = s_cast<int>(intArray[verticesData->offset + s_cast<unsigned>(db::BinaryOffset::MeshFloatOffset)]);
		if (vertexOffset < 0) {
			vertexOffset += 65536; // Fixed out of bouds bug.
		}
		for (std::size_t i = 0, l = vertexCount * 2; i < l; i += 2) {
			const auto iH = i / 2;
			const auto xG = floatArray[vertexOffset + i] * scale + deformVertices[i];
			const auto yG = floatArray[vertexOffset + i + 1] * scale + deformVertices[i + 1];
			auto& point = points[iH];
			point.x = xG;
			point.y = -yG;
			point.z = 0.0f;
		}
	}
	if (weightData != nullptr) {
		_identityTransform();
	}
}

void DBSlot::_updateTransform() {
	AffineTransform& transform = _node->_transform;
	if (_node == _rawDisplay || _node == _meshDisplay) {
		transform = {
			globalTransformMatrix.a,
			globalTransformMatrix.b,
			-globalTransformMatrix.c,
			-globalTransformMatrix.d,
			globalTransformMatrix.tx - (globalTransformMatrix.a * _pivotX - globalTransformMatrix.c * _pivotY),
			globalTransformMatrix.ty - (globalTransformMatrix.b * _pivotX - globalTransformMatrix.d * _pivotY)};
		if (_textureScale != 1.0f) {
			transform.a *= _textureScale;
			transform.b *= _textureScale;
			transform.c *= _textureScale;
			transform.d *= _textureScale;
		}
	} else if (_childArmature) {
		transform = AffineTransform::Indentity;
		transform.tx = globalTransformMatrix.tx;
		transform.ty = globalTransformMatrix.ty;
	}
	_node->_flags.setOn(DBSlotNode::TransformDirty);
}

void DBSlot::_identityTransform() {
	AffineTransform& transform = _node->_transform;
	transform = AffineTransform::Indentity;
	transform.d = -1.0f;
}

void DBSlot::_updateVisible() {
	_node->setVisible(_parent->getVisible());
}

void DBSlot::_updateBlendMode() {
	if (_node) {
		switch (_blendMode) {
			case db::BlendMode::Normal:
				_node->_blendFunc = BlendFunc::Default;
				break;
			case db::BlendMode::Add:
				_node->_blendFunc = {BlendFunc::SrcAlpha, BlendFunc::One};
				break;
			case db::BlendMode::Multiply:
				_node->_blendFunc = {BlendFunc::SrcAlpha, BlendFunc::InvSrcAlpha};
				break;
			case db::BlendMode::Screen:
				_node->_blendFunc = {BlendFunc::SrcAlpha, BlendFunc::One, BlendFunc::InvSrcAlpha, BlendFunc::InvSrcColor};
				break;
			default:
				break;
		}
	} else if (_childArmature != nullptr) {
		for (const auto slot : _childArmature->getSlots()) {
			slot->_blendMode = _blendMode;
			slot->_updateBlendMode();
		}
	}
}

void DBSlot::_updateColor() {
	auto abgr = Color(Vec4{
						  _colorTransform.redMultiplier,
						  _colorTransform.greenMultiplier,
						  _colorTransform.blueMultiplier,
						  _colorTransform.alphaMultiplier})
					.toABGR();
	for (auto& vert : _node->_vertices) {
		vert.abgr = abgr;
	}
}

/* DragonBone */

DragonBone::DBArmatureProxy::DBArmatureProxy(DragonBone* parent)
	: _parent(parent) { }

void DragonBone::DBArmatureProxy::dbInit(db::Armature* armature) {
	_armature = armature;
}

void DragonBone::DBArmatureProxy::dbClear() {
	_parent = nullptr;
}

void DragonBone::DBArmatureProxy::dbUpdate() { }

void DragonBone::DBArmatureProxy::dispose(bool disposeProxy) {
	DORA_UNUSED_PARAM(disposeProxy);
	if (_armature != nullptr) {
		_armature->dispose();
		_armature = nullptr;
	}
}

bool DragonBone::DBArmatureProxy::hasDBEventListener(const std::string& type) const {
	return type == db::EventObject::COMPLETE || type == db::EventObject::LOOP_COMPLETE || type == db::EventObject::FRAME_EVENT;
}

void DragonBone::DBArmatureProxy::dispatchDBEvent(const std::string& type, db::EventObject* value) {
	if (type == db::EventObject::COMPLETE) {
		const std::string& animationName = value->animationState->getName();
		_parent->emit("AnimationEnd"_slice, animationName, s_cast<Playable*>(_parent));
		_parent->_lastCompletedAnimationName = animationName;
		if (_parent->_currentAnimationName == animationName) {
			_parent->_currentAnimationName.clear();
		}
	} else if (type == db::EventObject::LOOP_COMPLETE) {
		auto animationName = value->animationState->getName();
		_parent->emit("AnimationEnd"_slice, animationName, s_cast<Playable*>(_parent));
		_parent->_lastCompletedAnimationName = animationName;
	} else if (type == db::EventObject::FRAME_EVENT) {
		_parent->emit(value->name, s_cast<Playable*>(_parent));
	}
}

db::Armature* DragonBone::DBArmatureProxy::getArmature() const {
	return _armature;
}

db::Animation* DragonBone::DBArmatureProxy::getAnimation() const {
	return _armature->getAnimation();
}

DragonBone* DragonBone::DBArmatureProxy::getParent() const noexcept {
	return _parent;
}

DragonBone::DragonBone()
	: _armatureProxy(New<DBArmatureProxy>(this)) {
	_flags.setOff(Node::TraverseEnabled);
}

void DragonBone::setSpeed(float var) {
	Playable::setSpeed(var);
	_armatureProxy->getAnimation()->timeScale = var;
}

void DragonBone::setRecovery(float var) {
	Playable::setRecovery(var);
}

void DragonBone::setDepthWrite(bool var) {
	_flags.set(DragonBone::DepthWrite, var);
}

bool DragonBone::isDepthWrite() const noexcept {
	return _flags.isOn(DragonBone::DepthWrite);
}

void DragonBone::setHitTestEnabled(bool var) {
	_flags.set(DragonBone::HitTest, var);
}

bool DragonBone::isHitTestEnabled() const noexcept {
	return _flags.isOn(DragonBone::HitTest);
}

void DragonBone::setShowDebug(bool var) {
	if (var) {
		if (!_debugLine) {
			_debugLine = Line::create();
			_debugLine->setOrder(std::numeric_limits<int>::max());
			addChild(_debugLine);
		}
	} else {
		if (_debugLine) {
			_debugLine->removeFromParent();
			_debugLine = nullptr;
		}
	}
	Node::setShowDebug(var);
}

DragonBone::DBArmatureProxy* DragonBone::getArmatureProxy() const noexcept {
	return _armatureProxy.get();
}

void DragonBone::setLook(String name) {
	db::SkinData* skin = _armatureProxy->getArmature()->getArmatureData()->getSkin(name.toString());
	SharedDragonBoneCache.replaceSkin(_armatureProxy->getArmature(), skin);
}

void DragonBone::setFliped(bool var) {
	Playable::setFliped(var);
	_armatureProxy->getArmature()->setFlipX(var);
}

const std::string& DragonBone::getCurrent() const {
	return _currentAnimationName;
}

const std::string& DragonBone::getLastCompleted() const {
	return _lastCompletedAnimationName;
}

Vec2 DragonBone::getKeyPoint(String name) {
	for (db::Slot* slot : _armatureProxy->getArmature()->getSlots()) {
		if (slot->getName() == name) {
			return s_cast<DBSlot*>(slot)->getNode()->getDBTransform().applyPoint(Vec2::zero);
		}
	}
	return Vec2::zero;
}

float DragonBone::play(String name, bool loop) {
	if (_armatureProxy->getAnimation()->isPlaying()) {
		_lastCompletedAnimationName.clear();
	}
	db::AnimationState* state = _armatureProxy->getAnimation()->fadeIn(name.toString(), _recoveryTime, loop ? 0 : 1);
	return (state->getTotalTime() + _recoveryTime) / std::max(_speed, FLT_EPSILON);
}

void DragonBone::stop() {
	_armatureProxy->getAnimation()->stop(Slice::Empty);
}

void DragonBone::setSlot(String name, Node* item) {
	for (db::Slot* slot : _armatureProxy->getArmature()->getSlots()) {
		if (slot->getName() == name) {
			if (auto node = s_cast<DBSlot*>(slot)->getNode()) {
				if (auto child = node->getChildByTag(name)) {
					child->removeFromParent();
				}
				node->addChild(item, 0, name);
			}
		}
	}
}

Node* DragonBone::getSlot(String name) {
	for (db::Slot* slot : _armatureProxy->getArmature()->getSlots()) {
		if (slot->getName() == name) {
			if (auto node = s_cast<DBSlot*>(slot)->getNode()) {
				return node->getChildByTag(name);
			}
		}
	}
	return nullptr;
}

std::string DragonBone::containsPoint(float x, float y) const {
	if (!isHitTestEnabled()) return Slice::Empty;
	for (db::Slot* slot : _armatureProxy->getArmature()->getSlots()) {
		if (slot->containsPoint(x, y)) {
			return slot->getName();
		}
	}
	return Slice::Empty;
}

std::string DragonBone::intersectsSegment(float x1, float y1, float x2, float y2) const {
	if (!isHitTestEnabled()) return Slice::Empty;
	for (db::Slot* slot : _armatureProxy->getArmature()->getSlots()) {
		if (slot->intersectsSegment(x1, y1, x2, y2)) {
			return slot->getName();
		}
	}
	return Slice::Empty;
}

void DragonBone::visit() {
	_armatureProxy->getArmature()->advanceTime(s_cast<float>(getScheduler()->getDeltaTime()));
	Node::visit();
}

void DragonBone::render() {
	if (isShowDebug()) {
		_debugLine->clear();
		for (db::Slot* slot : _armatureProxy->getArmature()->getSlots()) {
			if (auto boxData = slot->getBoundingBoxData()) {
				switch (boxData->type) {
					case db::BoundingBoxType::Polygon: {
						auto polygon = s_cast<db::PolygonBoundingBoxData*>(boxData);
						const auto& verts = *polygon->getVertices();
						int vertSize = s_cast<int>(verts.size()) / 2;
						std::vector<Vec2> vertices(vertSize + 1);
						auto transform = r_cast<AffineTransform*>(&slot->getParent()->globalTransformMatrix);
						float scale = s_cast<DBSlot*>(slot)->getTextureScale();
						for (int i = 0; i < vertSize; i++) {
							float x = verts[i * 2] * scale;
							float y = verts[i * 2 + 1] * scale;
							vertices[i] = transform->applyPoint({x, y});
						}
						vertices[vertSize] = vertices[0];
						_debugLine->add(vertices, Color(0xff00ffff));
						break;
					}
					default:
						break;
				}
			}
		}
	}
	Node::render();
}

void DragonBone::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		if (_armatureProxy) {
			_armatureProxy->dispose();
			_armatureProxy = nullptr;
		}
	}
}

DragonBone* DragonBone::create(String boneFile, String atlasFile) {
	return SharedDragonBoneCache.loadDragonBone(boneFile, atlasFile);
}

DragonBone* DragonBone::create(String boneStr) {
	return SharedDragonBoneCache.loadDragonBone(boneStr);
}

DragonBone* DragonBone::create() {
	return Object::createNotNull<DragonBone>();
}

NS_DORA_END

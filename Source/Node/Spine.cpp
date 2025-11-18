/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Spine.h"

#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Cache/AtlasCache.h"
#include "Cache/SkeletonCache.h"
#include "Cache/TextureCache.h"
#include "Effect/Effect.h"
#include "Node/DrawNode.h"
#include "Node/Sprite.h"
#include "Support/Common.h"
#include "Support/Dictionary.h"

NS_DORA_BEGIN

class SpineExtension : public spine::DefaultSpineExtension {
public:
	virtual ~SpineExtension() { }

	virtual char* _readFile(const spine::String& path, int* length) {
		int64_t size = 0;
		auto data = SharedContent.loadInMainUnsafe({path.buffer(), path.length()}, size);
		*length = s_cast<int>(size);
		return r_cast<char*>(data);
	}
};

Spine::SpineListener::SpineListener(Spine* owner)
	: _owner(owner) { }

void Spine::SpineListener::callback(spine::AnimationState* state, spine::EventType type, spine::TrackEntry* entry, spine::Event* event) {
	spine::String empty;
	const spine::String& name = (entry && entry->getAnimation()) ? entry->getAnimation()->getName() : empty;
	Slice animationName{name.buffer(), name.length()};
	switch (type) {
		case spine::EventType_End:
			if (_owner->_currentAnimationName == animationName) {
				_owner->_currentAnimationName.clear();
			}
			break;
		case spine::EventType_Event: {
			const auto& name = event->getData().getName();
			_owner->emit(Slice{name.buffer(), name.length()}, s_cast<Playable*>(_owner));
			break;
		}
		case spine::EventType_Complete:
			_owner->emit("AnimationEnd"_slice, animationName.toString(), s_cast<Playable*>(_owner));
			_owner->_lastCompletedAnimationName = animationName.toString();
			if (_owner->_currentAnimationName == animationName) {
				_owner->_currentAnimationName.clear();
			}
			break;
		case spine::EventType_Interrupt:
			_owner->_lastCompletedAnimationName.clear();
			if (_owner->_currentAnimationName == animationName) {
				_owner->_currentAnimationName.clear();
			}
			break;
		case spine::EventType_Start:
		case spine::EventType_Dispose:
			break;
	}
}

Spine::Spine(String spineStr)
	: _skeletonData(SharedSkeletonCache.load(spineStr))
	, _effect(SharedSpriteRenderer.getDefaultEffect())
	, _listener(this) { }

Spine::Spine(String skelFile, String atlasFile)
	: _skeletonData(SharedSkeletonCache.load(skelFile, atlasFile))
	, _effect(SharedSpriteRenderer.getDefaultEffect())
	, _listener(this) { }

bool Spine::init() {
	if (!Playable::init()) return false;
	if (!_skeletonData) {
		setAsManaged();
		return false;
	}
	_animationStateData = New<spine::AnimationStateData>(_skeletonData->getSkel());
	_animationState = New<spine::AnimationState>(_animationStateData.get());
	_skeleton = New<spine::Skeleton>(_skeletonData->getSkel());
	_skeleton->updateWorldTransform(spine::Physics_Reset);
	_clipper = New<spine::SkeletonClipping>();
	auto& slots = _skeleton->getSlots();
	for (size_t i = 0; i < slots.size(); i++) {
		spine::Slot* slot = slots[i];
		if (!slot->getBone().isActive()) continue;
		spine::Attachment* attachment = slot->getAttachment();
		if (attachment && !attachment->getRTTI().instanceOf(spine::BoundingBoxAttachment::rtti)) {
			_bounds = New<spine::SkeletonBounds>();
			setHitTestEnabled(true);
			break;
		}
	}
	this->scheduleUpdate();
	return true;
}

void Spine::setSpeed(float var) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	_animationState->setTimeScale(var);
	Playable::setSpeed(var);
}

void Spine::setRecovery(float var) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	_animationStateData->setDefaultMix(var);
	Playable::setRecovery(var);
}

void Spine::setDepthWrite(bool var) {
	_flags.set(Spine::DepthWrite, var);
}

bool Spine::isDepthWrite() const noexcept {
	return _flags.isOn(Spine::DepthWrite);
}

void Spine::setHitTestEnabled(bool var) {
	_flags.set(Spine::HitTest, var);
}

bool Spine::isHitTestEnabled() const noexcept {
	return _flags.isOn(Spine::HitTest);
}

void Spine::setShowDebug(bool var) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	if (var) {
		if (!_debugLine) {
			_debugLine = Line::create();
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

void Spine::setLook(String name) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	if (name.empty()) {
		_skeleton->setSkin(nullptr);
		_skeleton->setSlotsToSetupPose();
		Playable::setLook(name);
	} else {
		Slice skinName = Slice::Empty, skinStr = name;
		auto tokens = name.split(":"_slice);
		if (tokens.size() == 2) {
			skinName = tokens.front();
			skinStr = tokens.back();
		}
		tokens = skinStr.split(";"_slice);
		if (!skinName.empty() || tokens.size() > 1) {
			if (skinName.empty()) {
				skinName = "unnamed"_slice;
			}
			_newSkin = New<spine::Skin>(spine::String{skinName.begin(), skinName.size(), false, false});
			for (const auto& token : tokens) {
				auto skin = _skeletonData->getSkel()->findSkin(spine::String{token.begin(), token.size(), false, false});
				if (skin) {
					_newSkin->addSkin(skin);
				}
			}
			_skeleton->setSkin(_newSkin.get());
			_skeleton->setSlotsToSetupPose();
			Playable::setLook(skinName);
		} else {
			auto skin = _skeletonData->getSkel()->findSkin(spine::String{name.begin(), name.size(), false, false});
			if (skin) {
				_skeleton->setSkin(skin);
				_skeleton->setSlotsToSetupPose();
				Playable::setLook(name);
			}
		}
	}
}

void Spine::setFliped(bool var) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	_skeleton->setScaleX(var ? -1.0f : 1.0f);
	Playable::setFliped(var);
}

const std::string& Spine::getCurrent() const {
	return _currentAnimationName;
}

const std::string& Spine::getLastCompleted() const {
	return _lastCompletedAnimationName;
}

Vec2 Spine::getKeyPoint(String name) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	auto tokens = name.split("/"_slice);
	if (tokens.size() == 1) {
		auto slotName = spine::String{name.begin(), name.size(), false, false};
		auto slot = _skeletonData->getSkel()->findSlot(slotName);
		if (!slot) return Vec2::zero;
		if (auto skin = _skeleton->getSkin()) {
			auto slotIndex = slot->getIndex();
			spine::Vector<spine::Attachment*> attachments;
			skin->findAttachmentsForSlot(slotIndex, attachments);
			for (size_t i = 0; i < attachments.size(); ++i) {
				auto attachment = attachments[i];
				if (attachment->getRTTI().isExactly(spine::PointAttachment::rtti)) {
					spine::PointAttachment* point = s_cast<spine::PointAttachment*>(attachment);
					Vec2 res = Vec2::zero;
					auto& bone = _skeleton->getSlots()[slotIndex]->getBone();
					point->computeWorldPosition(bone, res.x, res.y);
					return res;
				}
			}
		} else if (tokens.size() == 2) {
			auto slotName = spine::String{tokens.front().begin(), tokens.front().size(), false, false};
			int slotIndex = slot->getIndex();
			if (slotIndex < 0) return Vec2::zero;
			auto attachmentName = spine::String{tokens.back().begin(), tokens.back().size(), false, false};
			auto attachment = _skeleton->getAttachment(slotIndex, attachmentName);
			if (attachment->getRTTI().isExactly(spine::PointAttachment::rtti)) {
				spine::PointAttachment* point = s_cast<spine::PointAttachment*>(attachment);
				Vec2 res = Vec2::zero;
				auto& bone = _skeleton->getSlots()[slotIndex]->getBone();
				point->computeWorldPosition(bone, res.x, res.y);
				return res;
			}
		}
	}
	return Vec2::zero;
}

float Spine::play(String name, bool loop) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	auto animation = _skeletonData->getSkel()->findAnimation(spine::String{name.begin(), name.size(), false, false});
	if (!animation) {
		return 0.0f;
	}
	_currentAnimationName = name.toString();
	float recoveryTime = _animationStateData->getDefaultMix();
	if (recoveryTime > 0.0f) {
		_animationState->setEmptyAnimation(0, recoveryTime);
		auto trackEntry = _animationState->addAnimation(0, animation, loop, FLT_EPSILON);
		trackEntry->setListener(&_listener);
		_animationState->apply(*_skeleton);
		_skeleton->updateWorldTransform(spine::Physics_Pose);
		return trackEntry->getAnimationEnd() / std::max(_animationState->getTimeScale(), FLT_EPSILON);
	} else {
		auto trackEntry = _animationState->setAnimation(0, animation, loop);
		trackEntry->setListener(&_listener);
		_animationState->apply(*_skeleton);
		_skeleton->updateWorldTransform(spine::Physics_Pose);
		return trackEntry->getAnimationEnd() / std::max(_animationState->getTimeScale(), FLT_EPSILON);
	}
}

void Spine::stop() {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	_animationState->clearTrack(0);
}

void Spine::setSlot(String name, Node* item) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	if (!_slots) {
		_slots = New<StringMap<Ref<Node>>>();
	}
	auto it = _slots->find(name);
	if (it != _slots->end()) {
		it->second->removeFromParent();
		_slots->erase(it);
	}
	if (item) {
		(*_slots)[name.toString()] = item;
		item->setVisible(false);
		addChild(item);
	}
}

Node* Spine::getSlot(String name) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	if (_slots) {
		auto it = _slots->find(name);
		if (it != _slots->end()) {
			return it->second;
		}
	}
	return nullptr;
}

bool Spine::setBoneRotation(String name, float rotation) {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	if (_skeleton) {
		if (auto bone = _skeleton->findBone(spine::String{name.begin(), name.size(), false, false})) {
			bone->setRotation(rotation);
			return true;
		}
	}
	return false;
}

std::string Spine::containsPoint(float x, float y) const {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	if (!_bounds || !isHitTestEnabled()) return Slice::Empty;
	if (_bounds->aabbcontainsPoint(x, y)) {
		if (auto attachment = _bounds->containsPoint(x, y)) {
			return std::string(
				attachment->getName().buffer(),
				attachment->getName().length());
		}
	}
	return Slice::Empty;
}

std::string Spine::intersectsSegment(float x1, float y1, float x2, float y2) const {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid Spine");
	if (!_bounds || !isHitTestEnabled()) return Slice::Empty;
	if (_bounds->aabbintersectsSegment(x1, y1, x2, y2)) {
		if (auto attachment = _bounds->intersectsSegment(x1, y1, x2, y2)) {
			return std::string(
				attachment->getName().buffer(),
				attachment->getName().length());
		}
	}
	return Slice::Empty;
}

bool Spine::update(double deltaTime) {
	if (isUpdating()) {
		_animationState->update(s_cast<float>(deltaTime));
		_animationState->apply(*_skeleton);
		_skeleton->updateWorldTransform(spine::Physics_Update);
		if (_bounds && isHitTestEnabled()) {
			_bounds->update(*_skeleton, true);
		}
	}
	return Node::update(deltaTime);
}

void Spine::render() {
	Matrix transform;
	Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());

	if (isShowDebug()) {
		_debugLine->clear();
	}

	std::vector<SpriteVertex> vertices;
	for (size_t i = 0, n = _skeleton->getSlots().size(); i < n; ++i) {
		spine::Slot* slot = _skeleton->getDrawOrder()[i];
		if (!slot->getBone().isActive()) {
			_clipper->clipEnd(*slot);
			continue;
		}
		spine::Attachment* attachment = slot->getAttachment();
		if (!attachment) continue;

		BlendFunc blendFunc = BlendFunc::Default;
		switch (slot->getData().getBlendMode()) {
			case spine::BlendMode_Normal:
				blendFunc = BlendFunc::Default;
				break;
			case spine::BlendMode_Additive:
				blendFunc = {BlendFunc::SrcAlpha, BlendFunc::One};
				break;
			case spine::BlendMode_Multiply:
				blendFunc = {BlendFunc::SrcAlpha, BlendFunc::InvSrcAlpha};
				break;
			case spine::BlendMode_Screen:
				blendFunc = {BlendFunc::SrcAlpha, BlendFunc::One, BlendFunc::InvSrcAlpha, BlendFunc::InvSrcColor};
				break;
			default:
				break;
		}

		uint64_t renderState = (BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_MSAA | blendFunc.toValue());
		if (_flags.isOn(Spine::DepthWrite)) {
			renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
		}

		spine::Color skeletonColor = _skeleton->getColor();
		spine::Color slotColor = slot->getColor();
		uint32_t abgr = Color(Vec4{
								  skeletonColor.r * slotColor.r,
								  skeletonColor.g * slotColor.g,
								  skeletonColor.b * slotColor.b,
								  skeletonColor.a * slotColor.a * _realColor.getOpacity()})
							.toABGR();

		Texture2D* texture = nullptr;
		if (attachment->getRTTI().isExactly(spine::RegionAttachment::rtti)) {
			spine::RegionAttachment* region = s_cast<spine::RegionAttachment*>(attachment);
			if (!region->getRegion()) continue;
			texture = r_cast<Texture2D*>(s_cast<spine::AtlasRegion*>(region->getRegion())->page->texture);
			vertices.assign(4, {0, 0, 0, 1});
			region->computeWorldVertices(*slot, &vertices[0].x, 0, sizeof(vertices[0]) / sizeof(float));
			if (_clipper->isClipping()) {
				for (size_t j = 0, l = 0; j < 4; j++, l += 2) {
					SpriteVertex& vertex = vertices[j];
					vertex.u = region->getUVs()[l];
					vertex.v = region->getUVs()[l + 1];
				}
				unsigned short triangles[6]{0, 1, 2, 2, 3, 0};
				_clipper->clipTriangles(&vertices[0].x, triangles, 6, &vertices[0].u, sizeof(vertices[0]) / sizeof(float));
				auto& verts = _clipper->getClippedVertices();
				auto vertSize = verts.size() / 2;
				bool isCulled = verts.size() == 0;
				if (!isCulled && SharedDirector.isFrustumCulling()) {
					float minX = verts[0];
					float minY = verts[1];
					float maxX = verts[0];
					float maxY = verts[1];
					for (size_t j = 1, l = 2; j < vertSize; j++, l += 2) {
						std::tie(minX, maxX) = std::minmax({minX, maxX, verts[l]});
						std::tie(minY, maxY) = std::minmax({minY, maxY, verts[l + 1]});
					}
					AABB aabb;
					Matrix::mulAABB(aabb, getWorld(), {
													  {minX, minY, 0},
													  {maxX, maxY, 0},
												  });
					isCulled = !SharedDirector.isInFrustum(aabb);
				}
				if (!isCulled) {
					auto& uvs = _clipper->getClippedUVs();
					vertices.resize(vertSize);
					for (size_t j = 0, l = 0; j < vertSize; j++, l += 2) {
						Vec4 vec{verts[l], verts[l + 1], 0, 1};
						SpriteVertex& vertex = vertices[j];
						Matrix::mulVec4(&vertex.x, transform, vec);
						vertex.abgr = abgr;
						vertex.u = uvs[l];
						vertex.v = uvs[l + 1];
					}
					auto& clippedIndices = _clipper->getClippedTriangles();
					SharedSpriteRenderer.push(
						vertices.data(), vertices.size(),
						clippedIndices.buffer(), clippedIndices.size(),
						_effect, texture, renderState);
				}
			} else {
				bool isCulled = vertices.empty();
				if (!isCulled && SharedDirector.isFrustumCulling()) {
					auto [minX, maxX] = std::minmax_element(vertices.begin(), vertices.end(), [](const auto& a, const auto& b) {
						return a.x < b.x;
					});
					auto [minY, maxY] = std::minmax_element(vertices.begin(), vertices.end(), [](const auto& a, const auto& b) {
						return a.y < b.y;
					});
					AABB aabb;
					Matrix::mulAABB(aabb, getWorld(), {
													  {minX->x, minY->y, 0},
													  {maxX->x, maxY->y, 0},
												  });
					isCulled = !SharedDirector.isInFrustum(aabb);
				}
				if (!isCulled) {
					for (size_t j = 0, l = 0; j < 4; j++, l += 2) {
						SpriteVertex& vertex = vertices[j];
						Vec4 oldVert{vertex.x, vertex.y, vertex.z, vertex.w};
						Matrix::mulVec4(&vertex.x, transform, oldVert);
						vertex.abgr = abgr;
						vertex.u = region->getUVs()[l];
						vertex.v = region->getUVs()[l + 1];
					}
					SharedSpriteRenderer.push(
						vertices.data(), vertices.size(),
						_effect, texture, renderState);
				}
			}
			vertices.clear();
		} else if (attachment->getRTTI().isExactly(spine::MeshAttachment::rtti)) {
			spine::MeshAttachment* mesh = s_cast<spine::MeshAttachment*>(attachment);
			texture = r_cast<Texture2D*>(s_cast<spine::AtlasRegion*>(mesh->getRegion())->page->texture);
			size_t verticeLength = mesh->getWorldVerticesLength();
			size_t numVertices = verticeLength / 2;
			vertices.assign(numVertices, {0, 0, 0, 1});
			mesh->computeWorldVertices(*slot, 0, verticeLength, &vertices[0].x, 0, sizeof(vertices[0]) / sizeof(float));
			if (_clipper->isClipping()) {
				for (size_t j = 0, l = 0; j < numVertices; j++, l += 2) {
					SpriteVertex& vertex = vertices[j];
					vertex.u = mesh->getUVs()[l];
					vertex.v = mesh->getUVs()[l + 1];
				}
				auto& meshIndices = mesh->getTriangles();
				_clipper->clipTriangles(&vertices[0].x, meshIndices.buffer(), meshIndices.size(), &vertices[0].u, sizeof(vertices[0]) / sizeof(float));
				auto& verts = _clipper->getClippedVertices();
				auto vertSize = _clipper->getClippedVertices().size() / 2;
				bool isCulled = verts.size() == 0;
				if (!isCulled && SharedDirector.isFrustumCulling()) {
					float minX = verts[0];
					float minY = verts[1];
					float maxX = verts[0];
					float maxY = verts[1];
					for (size_t j = 1, l = 2; j < vertSize; j++, l += 2) {
						std::tie(minX, maxX) = std::minmax({minX, maxX, verts[l]});
						std::tie(minY, maxY) = std::minmax({minY, maxY, verts[l + 1]});
					}
					AABB aabb;
					Matrix::mulAABB(aabb, getWorld(), {
													  {minX, minY, 0},
													  {maxX, maxY, 0},
												  });
					isCulled = !SharedDirector.isInFrustum(aabb);
				}
				if (!isCulled) {
					auto& uvs = _clipper->getClippedUVs();
					vertices.resize(vertSize);
					for (size_t j = 0, l = 0; j < vertSize; j++, l += 2) {
						Vec4 vec{verts[l], verts[l + 1], 0, 1};
						SpriteVertex& vertex = vertices[j];
						Matrix::mulVec4(&vertex.x, transform, vec);
						vertex.abgr = abgr;
						vertex.u = uvs[l];
						vertex.v = uvs[l + 1];
					}
					auto& clippedIndices = _clipper->getClippedTriangles();
					SharedSpriteRenderer.push(
						vertices.data(), vertices.size(),
						clippedIndices.buffer(), clippedIndices.size(),
						_effect, texture, renderState);
				}
			} else {
				bool isCulled = false;
				if (SharedDirector.isFrustumCulling()) {
					auto [minX, maxX] = std::minmax_element(vertices.begin(), vertices.end(), [](const auto& a, const auto& b) {
						return a.x < b.x;
					});
					auto [minY, maxY] = std::minmax_element(vertices.begin(), vertices.end(), [](const auto& a, const auto& b) {
						return a.y < b.y;
					});
					AABB aabb;
					Matrix::mulAABB(aabb, getWorld(), {
													  {minX->x, minY->y, 0},
													  {maxX->x, maxY->y, 0},
												  });
					isCulled = !SharedDirector.isInFrustum(aabb);
				}
				if (!isCulled) {
					for (size_t j = 0, l = 0; j < numVertices; j++, l += 2) {
						SpriteVertex& vertex = vertices[j];
						Vec4 oldVert{vertex.x, vertex.y, vertex.z, vertex.w};
						Matrix::mulVec4(&vertex.x, transform, oldVert);
						vertex.abgr = abgr;
						vertex.u = mesh->getUVs()[l];
						vertex.v = mesh->getUVs()[l + 1];
					}
					auto& meshIndices = mesh->getTriangles();
					SharedSpriteRenderer.push(
						vertices.data(), vertices.size(),
						meshIndices.buffer(), meshIndices.size(),
						_effect, texture, renderState);
				}
			}
			vertices.clear();
		} else if (attachment->getRTTI().isExactly(spine::BoundingBoxAttachment::rtti)) {
			_clipper->clipEnd(*slot);
			if (isShowDebug() && isHitTestEnabled()) {
				spine::BoundingBoxAttachment* boundingBox = s_cast<spine::BoundingBoxAttachment*>(attachment);
				auto polygon = _bounds->getPolygon(boundingBox);
				int vertSize = polygon->_count / 2;
				std::vector<Vec2> verts(vertSize + 1);
				for (int i = 0; i < vertSize; i++) {
					float x = polygon->_vertices[i * 2];
					float y = polygon->_vertices[i * 2 + 1];
					verts[i] = {x, y};
				}
				verts[vertSize] = verts[0];
				_debugLine->add(verts, Color(0xff00ffff));
			}
		} else if (attachment->getRTTI().isExactly(spine::ClippingAttachment::rtti)) {
			spine::ClippingAttachment* clippingAttachment = s_cast<spine::ClippingAttachment*>(attachment);
			_clipper->clipStart(*slot, clippingAttachment);
		} else if (attachment->getRTTI().isExactly(spine::PointAttachment::rtti)) {
			_clipper->clipEnd(*slot);
			spine::PointAttachment* pointAttachment = s_cast<spine::PointAttachment*>(attachment);
			const auto& str = pointAttachment->getName();
			Slice name = {str.buffer(), str.length()};
			if (name.left(2) == "s:"_slice) {
				float x = 0, y = 0;
				pointAttachment->computeWorldPosition(slot->getBone(), x, y);
				float angle = -pointAttachment->computeWorldRotation(slot->getBone());
				name.skip(2);
				if (auto node = getSlot(name)) {
					float scaleY = node->getScaleY();
					node->setScaleY(isFliped() ? -scaleY : scaleY);
					node->setPosition({x, y});
					node->setAngle(angle);
					node->setVisible(true);
					node->visit();
					node->render();
					node->setVisible(false);
					node->setScaleY(scaleY);
				}
			}
		} else {
			_clipper->clipEnd(*slot);
		}
	}
	_clipper->clipEnd();

	Node::render();
}

void Spine::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Playable::cleanup();
		_slots = nullptr;
		_effect = nullptr;
		_skeletonData = nullptr;
		_skeleton = nullptr;
		_animationState = nullptr;
		_animationStateData = nullptr;
		_newSkin = nullptr;
		_bounds = nullptr;
		_clipper = nullptr;
	}
}

NS_DORA_END

spine::SpineExtension* spine::getDefaultExtension() {
	return new Dora::SpineExtension();
}

/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Spine.h"
#include "Basic/Content.h"
#include "Cache/AtlasCache.h"
#include "Cache/SkeletonCache.h"
#include "Cache/TextureCache.h"
#include "Basic/Scheduler.h"
#include "Node/Sprite.h"
#include "Effect/Effect.h"
#include "Support/Common.h"
#include "Basic/Director.h"

NS_DOROTHY_BEGIN

class SpineExtension : public spine::SpineExtension
{
public:
	virtual ~SpineExtension() {}

	virtual void* _alloc(size_t size, const char* file, int line)
	{
		DORA_UNUSED_PARAM(file);
		DORA_UNUSED_PARAM(line);
		if (size == 0) return nullptr;
		return r_cast<void*>(new uint8_t[size]);
	}

	virtual void* _calloc(size_t size, const char* file, int line)
	{
		DORA_UNUSED_PARAM(file);
		DORA_UNUSED_PARAM(line);
		if (size == 0) return nullptr;
		return r_cast<void*>(new uint8_t[size]{});
	}

	virtual void* _realloc(void* ptr, size_t size, const char* file, int line)
	{
		DORA_UNUSED_PARAM(file);
		DORA_UNUSED_PARAM(line);
		if (size == 0) return nullptr;
		if (ptr == nullptr)
		{
			return r_cast<void*>(new uint8_t[size]);
		}
		else
		{
			auto newMem = new uint8_t[size];
			std::copy(r_cast<uint8_t*>(ptr), r_cast<uint8_t*>(ptr) + size, newMem);
			return newMem;
		}
	}

	virtual void _free(void* mem, const char* file, int line)
	{
		DORA_UNUSED_PARAM(file);
		DORA_UNUSED_PARAM(line);
		delete [] r_cast<uint8_t*>(mem);
	}

	virtual char* _readFile(const spine::String& path, int* length)
	{
		Sint64 size = 0;
		auto data = SharedContent.loadFileUnsafe({path.buffer(),path.length()}, size);
		*length = s_cast<int>(size);
		return r_cast<char*>(data);
	}
};

Spine::SpineListener::SpineListener(Spine* owner):_owner(owner)
{ }

void Spine::SpineListener::callback(spine::AnimationState* state, spine::EventType type, spine::TrackEntry* entry, spine::Event* event)
{
	spine::String empty;
	const spine::String& name = (entry && entry->getAnimation()) ? entry->getAnimation()->getName() : empty;
	Slice animationName{name.buffer(), name.length()};
	switch (type)
	{
		case spine::EventType_End:
			_owner->_currentAnimationName.clear();
			break;
		case spine::EventType_Event:
			_owner->emit(animationName, s_cast<Playable*>(_owner));
			break;
		case spine::EventType_Complete:
			_owner->emit("AnimationEnd"_slice, animationName, s_cast<Playable*>(_owner));
			break;
		case spine::EventType_Interrupt:
			_owner->_currentAnimationName.clear();
			_owner->emit("AnimationEnd"_slice, animationName, s_cast<Playable*>(_owner));
			break;
		case spine::EventType_Start:
		case spine::EventType_Dispose:
			break;
	}
}

Spine::Spine(String spineStr):
_skeletonData(SharedSkeletonCache.load(spineStr)),
_effect(SharedSpriteRenderer.getDefaultEffect()),
_listener(this)
{ }

Spine::Spine(String skelFile, String atlasFile):
_skeletonData(SharedSkeletonCache.load(skelFile, atlasFile)),
_effect(SharedSpriteRenderer.getDefaultEffect()),
_listener(this)
{ }

bool Spine::init()
{
	if (!Node::init()) return false;
	if (_skeletonData)
	{
		_animationStateData = New<spine::AnimationStateData>(_skeletonData->getSkel());
		_animationState = New<spine::AnimationState>(_animationStateData.get());
		_skeleton = New<spine::Skeleton>(_skeletonData->getSkel());
		this->scheduleUpdate();
		return true;
	}
	return false;
}

void Spine::setSpeed(float var)
{
	_animationState->setTimeScale(var);
	Playable::setSpeed(var);
}

void Spine::setRecovery(float var)
{
	_animationStateData->setDefaultMix(var);
	Playable::setRecovery(var);
}

void Spine::setDepthWrite(bool var)
{
	_flags.set(Spine::DepthWrite, var);
}

bool Spine::isDepthWrite() const
{
	return _flags.isOn(Spine::DepthWrite);
}

void Spine::setLook(String name)
{
	if (name.empty())
	{
		_skeleton->setSkin(nullptr);
	}
	else
	{
		auto skin = _skeletonData->getSkel()->findSkin(spine::String{name.begin(), name.size(), false});
		if (skin)
		{
			_skeleton->setSkin(skin);
			Playable::setLook(name);
		}
	}
}

void Spine::setFaceRight(bool var)
{
	_skeleton->setScaleX(var ? -1.0f : 1.0f);
	Playable::setFaceRight(var);
}

const string& Spine::getCurrentAnimationName() const
{
	return _currentAnimationName;
}

Vec2 Spine::getKeyPoint(String name) const
{
	auto bone = _skeleton->findBone(spine::String{name.begin(),name.size(),false});
	if (bone)
	{
		return Vec2{bone->getWorldX(), bone->getWorldY()};
	}
	return Vec2::zero;
}

float Spine::play(String name, bool loop)
{
	auto animation = _skeletonData->getSkel()->findAnimation(spine::String{name.begin(), name.size(), false});
	if (!animation)
	{
		return 0.0f;
	}
	_currentAnimationName = name;
	float recoveryTime = _animationStateData->getDefaultMix();
	if (recoveryTime > 0.0f)
	{
		_animationState->setEmptyAnimation(0, recoveryTime);
		auto trackEntry = _animationState->addAnimation(0, spine::String(name.begin(), name.size(), false), loop, 0.0f);
		trackEntry->setListener(&_listener);
		return trackEntry->getAnimationEnd() / std::max(_animationState->getTimeScale(), FLT_EPSILON);
	}
	else
	{
		auto trackEntry = _animationState->setAnimation(0, spine::String(name.begin(), name.size(), false), loop);
		trackEntry->setListener(&_listener);
		return trackEntry->getAnimationEnd() / std::max(_animationState->getTimeScale(), FLT_EPSILON);
	}
}

void Spine::stop()
{
	_animationState->setEmptyAnimation(0, _animationStateData->getDefaultMix());
}

void Spine::visit()
{
	_animationState->update(s_cast<float>(getScheduler()->getDeltaTime()));
	_animationState->apply(*_skeleton);
	_skeleton->updateWorldTransform();
	Node::visit();
}

void Spine::render()
{
	Matrix transform;
	bx::mtxMul(transform, _world, SharedDirector.getViewProjection());
	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());

	std::vector<SpriteVertex> vertices;
	for (size_t i = 0, n = _skeleton->getSlots().size(); i < n; ++i)
	{
		spine::Slot* slot = _skeleton->getDrawOrder()[i];
		spine::Attachment* attachment = slot->getAttachment();
		if (!attachment) continue;

		BlendFunc blendFunc = BlendFunc::Default;
		switch (slot->getData().getBlendMode())
		{
			case spine::BlendMode_Normal:
				blendFunc = {BlendFunc::SrcAlpha, BlendFunc::InvSrcAlpha};
				break;
			case spine::BlendMode_Additive:
				blendFunc = {BlendFunc::SrcAlpha, BlendFunc::One};
				break;
			case spine::BlendMode_Multiply:
				blendFunc = {BlendFunc::DstColor, BlendFunc::InvSrcAlpha};
				break;
			case spine::BlendMode_Screen:
				blendFunc = {BlendFunc::One, BlendFunc::InvSrcColor};
				break;
			default:
				break;
		}

		Uint64 renderState = (
			BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A |
			BGFX_STATE_MSAA | blendFunc.toValue());
		if (_flags.isOn(Spine::DepthWrite))
		{
			renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
		}

		spine::Color skeletonColor = _skeleton->getColor();
		spine::Color slotColor = slot->getColor();
		uint32_t abgr = Color(Vec4{
			skeletonColor.r * slotColor.r,
			skeletonColor.g * slotColor.g,
			skeletonColor.b * slotColor.b,
			skeletonColor.a * slotColor.a}).toABGR();

		Texture2D* texture = nullptr;
		if (attachment->getRTTI().isExactly(spine::RegionAttachment::rtti))
		{
			spine::RegionAttachment* regionAttachment = s_cast<spine::RegionAttachment*>(attachment);
			texture = r_cast<Texture2D*>(r_cast<spine::AtlasRegion*>(regionAttachment->getRendererObject())->page->getRendererObject());
			vertices.assign(4, {0, 0, 0, 1});
			regionAttachment->computeWorldVertices(slot->getBone(), &vertices.front().x, 0, sizeof(SpriteVertex) / sizeof(float));

			for (size_t j = 0, l = 0; j < 4; j++, l+=2)
			{
				SpriteVertex& vertex = vertices[j];
				SpriteVertex oldVert = vertex;
				bx::vec4MulMtx(&vertex.x, &oldVert.x, transform);
				vertex.abgr = abgr;
				vertex.u = regionAttachment->getUVs()[l];
				vertex.v = regionAttachment->getUVs()[l + 1];
			}

			SharedSpriteRenderer.push(
				vertices.data(), vertices.size(),
				_effect, texture, renderState);
		}
		else if (attachment->getRTTI().isExactly(spine::MeshAttachment::rtti))
		{
			spine::MeshAttachment* mesh = s_cast<spine::MeshAttachment*>(attachment);
			texture = r_cast<Texture2D*>(r_cast<spine::AtlasRegion*>(mesh->getRendererObject())->page->getRendererObject());
			size_t verticeLength = mesh->getWorldVerticesLength();
			size_t numVertices = verticeLength / 2;
			vertices.assign(numVertices, {0, 0, 0, 1});
			mesh->computeWorldVertices(*slot, 0, verticeLength, &vertices.front().x, 0, sizeof(SpriteVertex) / sizeof(float));

			for (size_t j = 0, l = 0; j < numVertices; j++, l+=2)
			{
				SpriteVertex& vertex = vertices[j];
				SpriteVertex oldVert = vertex;
				bx::vec4MulMtx(&vertex.x, &oldVert.x, transform);
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
		vertices.clear();
	}
}

NS_DOROTHY_END

spine::SpineExtension* spine::getDefaultExtension()
{
	return new Dorothy::SpineExtension();
}

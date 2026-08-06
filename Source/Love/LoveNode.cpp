/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Const/Header.h"

#include "Love/LoveNode.h"

#include <charconv>

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Audio/Audio.h"
#include "Cache/FontCache.h"
#include "Cache/ShaderCache.h"
#include "Cache/TextureCache.h"
#include "Effect/Effect.h"
#include "Event/Event.h"
#include "Input/Controller.h"
#include "Input/Keyboard.h"
#include "Input/TouchDispather.h"
#include "Node/AudioSource.h"
#include "Node/DrawNode.h"
#include "lodepng.h"
#include "Node/Label.h"
#include "Node/Node.h"
#include "Node/Sprite.h"
#include "Physics/Body.h"
#include "Physics/BodyDef.h"
#include "Physics/Joint.h"
#include "Physics/PhysicsWorld.h"
#include "Render/RenderTarget.h"
#include "Render/Renderer.h"
#include "Render/View.h"
#include "Shader/ShaderCompiler.h"
#include "ZipUtils.h"

#include "SDL.h"

#include "bimg/decode.h"
#include "bx/allocator.h"
#include "soloud_wav.h"
#include "soloud_biquadresonantfilter.h"
#include "soloud_echofilter.h"
#include "soloud_eqfilter.h"
#include "soloud_flangerfilter.h"
#include "soloud_freeverbfilter.h"
#include "soloud_robotizefilter.h"
#include "soloud_waveshaperfilter.h"
#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/WorldContact.hpp"
#include "playrho/d2/WorldShape.hpp"
#include "playrho/d2/AABB.hpp"
#include "playrho/d2/ContactImpulsesList.hpp"
#include "playrho/d2/DistanceJointConf.hpp"
#include "playrho/d2/DynamicTree.hpp"
#include "playrho/d2/RayCastOutput.hpp"
#include "playrho/d2/RevoluteJointConf.hpp"
#include "playrho/d2/PrismaticJointConf.hpp"
#include "playrho/d2/WeldJointConf.hpp"
#include "playrho/d2/FrictionJointConf.hpp"
#include "playrho/d2/GearJointConf.hpp"
#include "playrho/d2/RopeJointConf.hpp"
#include "playrho/d2/PulleyJointConf.hpp"
#include "playrho/d2/WheelJointConf.hpp"
#include "playrho/d2/TargetJointConf.hpp"
#include "playrho/d2/MotorJointConf.hpp"
#include "playrho/d2/WorldJoint.hpp"

#include <algorithm>
#include <atomic>
#include <cmath>
#include <cctype>
#include <limits>
#include <mutex>
#include <numbers>
#include <regex>
#include <unordered_map>

NS_DORA_BEGIN

struct LoveRecordingResource
{
	SDL_AudioDeviceID device = 0;
	std::size_t maxBytes = 0;
	int bytesPerFrame = 0;
	mutable std::mutex mutex;
	std::vector<std::uint8_t> pcm;
};

namespace
{
LoveNode *FocusedLoveNode = nullptr;
std::atomic<std::uint64_t> LovePackageSequence = 1;
std::atomic<std::uint64_t> LoveMountSequence = 1;

void SDLCALL loveRecordingCallback(void *userdata, Uint8 *stream, int length)
{
	auto *recording = static_cast<LoveRecordingResource *>(userdata);
	if (!recording || !stream || length <= 0) return;
	std::lock_guard<std::mutex> lock(recording->mutex);
	const std::size_t available = recording->pcm.size() < recording->maxBytes
		? recording->maxBytes - recording->pcm.size() : 0;
	std::size_t count = std::min<std::size_t>(available, static_cast<std::size_t>(length));
	if (recording->bytesPerFrame > 0)
		count -= count % static_cast<std::size_t>(recording->bytesPerFrame);
	recording->pcm.insert(recording->pcm.end(), stream, stream + count);
}

Vec2 transformLovePoint(const Vec2 &point, const Love::GraphicsBackend::Transform2D &transform,
	float surfaceHeight)
{
	const float x = transform.a * point.x + transform.c * point.y + transform.tx;
	const float y = transform.b * point.x + transform.d * point.y + transform.ty;
	return {x, surfaceHeight - y};
}

bool isSafeLovePackagePath(std::string_view path)
{
	if (path.empty() || path.front() == '/' || path.front() == '\\'
		|| path.find('\\') != std::string_view::npos || path.find(':') != std::string_view::npos)
		return false;
	std::size_t start = 0;
	while (start <= path.size())
	{
		const auto separator = path.find('/', start);
		const auto component = path.substr(start,
			separator == std::string_view::npos ? path.size() - start : separator - start);
		if (component.empty() || component == "." || component == "..") return false;
		if (separator == std::string_view::npos) break;
		start = separator + 1;
	}
	return true;
}

class LoveRenderStateNode final : public Node
{
public:
	LoveRenderStateNode(std::optional<RendererManager::ScissorState> scissor,
		uint32_t stencil, uint64_t renderState)
		: _scissor(scissor)
		, _stencil(stencil)
		, _renderState(renderState)
	{ }

	virtual void visit() override
	{
		SharedRendererManager.flush();
		auto visitWithRenderState = [&]() {
			constexpr uint64_t stateMask = BGFX_STATE_WRITE_R | BGFX_STATE_WRITE_G
				| BGFX_STATE_WRITE_B | BGFX_STATE_WRITE_A
					| BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_MASK | BGFX_STATE_CULL_MASK;
			SharedRendererManager.pushStateOverride(stateMask, _renderState, [&]() {
				visitInner();
				SharedRendererManager.flush();
			});
		};
		auto visitWithStencil = [&]() {
			SharedRendererManager.pushStencilState(_stencil, visitWithRenderState);
		};
		if (_scissor)
			SharedRendererManager.pushScissorState(*_scissor, visitWithStencil);
		else
			visitWithStencil();
	}

	CREATE_FUNC_NOT_NULL(LoveRenderStateNode);

private:
	std::optional<RendererManager::ScissorState> _scissor;
	uint32_t _stencil = BGFX_STENCIL_NONE;
	uint64_t _renderState = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A;
};

class LoveWireframeNode final : public Node
{
public:
	virtual void visit() override
	{
		SharedRendererManager.flush();
		SharedRendererManager.pushStateOverride(BGFX_STATE_PT_MASK, BGFX_STATE_PT_LINES, [&]() {
			visitInner();
			SharedRendererManager.flush();
		});
	}

	CREATE_FUNC_NOT_NULL(LoveWireframeNode);
};

class LoveTexturedMeshNode final : public Node
{
public:
	LoveTexturedMeshNode(std::vector<SpriteVertex> vertices, std::vector<uint32_t> indices,
		Texture2D *texture, const BlendFunc &blend, uint32_t samplerFlags, SpriteEffect *effect,
		bool ignoreCull = false, bool wireframe = false)
		: _vertices(std::move(vertices))
		, _source(_vertices)
		, _indices(std::move(indices))
		, _texture(texture)
		, _blend(blend)
		, _samplerFlags(samplerFlags)
		, _effect(effect)
		, _ignoreCull(ignoreCull)
		, _wireframe(wireframe)
	{
		if (_wireframe)
		{
			std::vector<uint32_t> edges;
			edges.reserve((_indices.size() / 3) * 6);
			for (std::size_t index = 0; index + 2 < _indices.size(); index += 3)
			{
				const auto a = _indices[index];
				const auto b = _indices[index + 1];
				const auto c = _indices[index + 2];
				edges.insert(edges.end(), {a, b, b, c, c, a});
			}
			_indices = std::move(edges);
		}
		if (_vertices.size() <= std::numeric_limits<uint16_t>::max()
			&& std::all_of(_indices.begin(), _indices.end(),
				[](uint32_t index) { return index <= std::numeric_limits<uint16_t>::max(); }))
		{
			_indices16.reserve(_indices.size());
			for (const auto index : _indices) _indices16.push_back(static_cast<uint16_t>(index));
		}
	}

	virtual void visit() override
	{
		if (_ignoreCull)
			SharedRendererManager.pushStateOverride(BGFX_STATE_CULL_MASK, BGFX_STATE_NONE,
				[this]() { Node::visit(); });
		else Node::visit();
	}

	virtual void render() override
	{
		if (!_texture || _vertices.empty() || _indices.empty()) return;
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
		for (std::size_t index = 0; index < _vertices.size(); ++index)
			Matrix::mulVec4(&_vertices[index].x, transform, _source[index].toVec4());
		const uint64_t state = SharedRendererManager.applyState(
			BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | _blend.toValue()
				| (_wireframe ? BGFX_STATE_PT_LINES : BGFX_STATE_NONE));
		SpriteEffect *effect = _effect ? _effect.get() : SharedSpriteRenderer.getDefaultEffect();
		if (!_indices16.empty())
		{
			SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());
			SharedSpriteRenderer.push(_vertices.data(), _vertices.size(), _indices16.data(), _indices16.size(),
				effect, _texture, state, _samplerFlags);
		}
		else
		{
			SharedRendererManager.flush();
			bgfx::TransientVertexBuffer vertexBuffer;
			bgfx::TransientIndexBuffer indexBuffer;
			const auto vertexCount = static_cast<uint32_t>(_vertices.size());
			const auto indexCount = static_cast<uint32_t>(_indices.size());
			if (!bgfx::allocTransientBuffers(&vertexBuffer, SpriteVertex::ms_layout, vertexCount,
				&indexBuffer, indexCount, true))
			{
				Warn("not enough transient buffer for Love 32-bit Mesh: {} vertices, {} indices.",
					vertexCount, indexCount);
				return;
			}
			std::memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(_vertices[0]));
			std::memcpy(indexBuffer.data, _indices.data(), _indices.size() * sizeof(_indices[0]));
			const auto stencil = SharedRendererManager.getCurrentStencilState();
			bgfx::setStencil(stencil);
			RendererManager::ScissorState scissor;
			if (SharedRendererManager.getCurrentScissorState(scissor))
				bgfx::setScissor(scissor.x, scissor.y, scissor.width, scissor.height);
			else bgfx::setScissor(UINT16_MAX);
			bgfx::setVertexBuffer(0, &vertexBuffer);
			bgfx::setIndexBuffer(&indexBuffer);
			bgfx::setState(state);
			bgfx::setTexture(0, effect->getSampler(), _texture->getHandle(), _samplerFlags);
			if (effect->getPasses().empty()) effect = SharedSpriteRenderer.getDefaultEffect();
			Pass *lastPass = effect->getPasses().back().get();
			for (Pass *pass : effect->getPasses())
				bgfx::submit(SharedView.getId(), pass->apply(), 0,
					pass == lastPass ? BGFX_DISCARD_ALL : BGFX_DISCARD_NONE);
		}
		Node::render();
	}

	virtual void cleanup() override
	{
		Node::cleanup();
		_texture = nullptr;
		_effect = nullptr;
	}

	CREATE_FUNC_NOT_NULL(LoveTexturedMeshNode);

private:
	std::vector<SpriteVertex> _vertices;
	std::vector<SpriteVertex> _source;
	std::vector<uint32_t> _indices;
	std::vector<uint16_t> _indices16;
	Ref<Texture2D> _texture;
	BlendFunc _blend;
	uint32_t _samplerFlags = UINT32_MAX;
	Ref<SpriteEffect> _effect;
	bool _ignoreCull = false;
	bool _wireframe = false;
};

struct LoveDynamicMeshAttribute
{
	bgfx::Attrib::Enum semantic = bgfx::Attrib::TexCoord1;
	int components = 4;
	std::vector<float> values;
};

struct LoveDynamicMeshInstanceAttribute
{
	int slot = 0;
	int components = 4;
	Vec4 defaultValue{0.0f, 0.0f, 0.0f, 1.0f};
	std::vector<float> values;
};

class LoveDynamicMeshNode final : public Node
{
public:
	LoveDynamicMeshNode(std::vector<Love::GraphicsBackend::MeshVertex> vertices,
		std::vector<uint32_t> indices, std::vector<LoveDynamicMeshAttribute> attributes,
		std::vector<LoveDynamicMeshInstanceAttribute> instanceAttributes,
		int instanceCount, std::array<Vec4, 5> instanceSelectors,
		Texture2D *texture, const BlendFunc &blend, uint32_t samplerFlags,
		SpriteEffect *effect, float coordinateHeight, bool ignoreCull, bool wireframe = false)
		: _vertices(std::move(vertices))
		, _indices(std::move(indices))
		, _attributes(std::move(attributes))
		, _instanceAttributes(std::move(instanceAttributes))
		, _instanceCount(instanceCount)
		, _instanceSelectors(instanceSelectors)
		, _texture(texture)
		, _blend(blend)
		, _samplerFlags(samplerFlags)
		, _effect(effect)
		, _coordinateHeight(coordinateHeight)
		, _ignoreCull(ignoreCull)
		, _wireframe(wireframe)
	{
		if (_wireframe)
		{
			std::vector<uint32_t> edges;
			edges.reserve((_indices.size() / 3) * 6);
			for (std::size_t index = 0; index + 2 < _indices.size(); index += 3)
			{
				const auto a = _indices[index];
				const auto b = _indices[index + 1];
				const auto c = _indices[index + 2];
				edges.insert(edges.end(), {a, b, b, c, c, a});
			}
			_indices = std::move(edges);
		}
		_layout.begin()
			.add(bgfx::Attrib::Position, 4, bgfx::AttribType::Float)
			.add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
			.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true);
		for (const auto &attribute : _attributes)
			_layout.add(attribute.semantic, static_cast<uint8_t>(attribute.components), bgfx::AttribType::Float);
		_layout.end();
	}

	virtual void visit() override
	{
		if (_ignoreCull)
			SharedRendererManager.pushStateOverride(BGFX_STATE_CULL_MASK, BGFX_STATE_NONE,
				[this]() { Node::visit(); });
		else Node::visit();
	}

	virtual void render() override
	{
		if (!_texture || !_effect || _vertices.empty() || _indices.empty()) return;
		SharedRendererManager.flush();
		bgfx::TransientVertexBuffer vertexBuffer;
		bgfx::TransientIndexBuffer indexBuffer;
		bgfx::InstanceDataBuffer instanceBuffer;
		const auto vertexCount = static_cast<uint32_t>(_vertices.size());
		const auto indexCount = static_cast<uint32_t>(_indices.size());
		const bool index32 = _vertices.size() > std::numeric_limits<uint16_t>::max()
			|| std::any_of(_indices.begin(), _indices.end(),
				[](uint32_t index) { return index > std::numeric_limits<uint16_t>::max(); });
		if (!bgfx::allocTransientBuffers(&vertexBuffer, _layout, vertexCount,
			&indexBuffer, indexCount, index32))
		{
			Warn("not enough transient buffer for Love dynamic Mesh: {} vertices, {} indices.",
				vertexCount, indexCount);
			return;
		}
		if (_instanceCount > 1)
		{
			constexpr uint16_t instanceStride = 5 * sizeof(Vec4);
			if (bgfx::getAvailInstanceDataBuffer(static_cast<uint32_t>(_instanceCount), instanceStride)
				< static_cast<uint32_t>(_instanceCount))
			{
				Warn("not enough instance buffer for Love dynamic Mesh: {} instances.", _instanceCount);
				return;
			}
			bgfx::allocInstanceDataBuffer(&instanceBuffer,
				static_cast<uint32_t>(_instanceCount), instanceStride);
			std::memset(instanceBuffer.data, 0,
				static_cast<std::size_t>(_instanceCount) * instanceStride);
			for (const auto &attribute : _instanceAttributes)
			{
				for (int instanceIndex = 0; instanceIndex < _instanceCount; ++instanceIndex)
				{
					float *target = reinterpret_cast<float *>(instanceBuffer.data
						+ static_cast<std::size_t>(instanceIndex) * instanceStride
						+ static_cast<std::size_t>(attribute.slot) * sizeof(Vec4));
					const float *source = attribute.values.data()
						+ static_cast<std::size_t>(instanceIndex) * attribute.components;
					std::copy_n(&attribute.defaultValue.x, 4, target);
					std::copy_n(source, attribute.components, target);
				}
			}
		}
		Matrix loveToDora;
		bx::mtxSRT(loveToDora.m, 1.0f, -1.0f, 1.0f,
			0.0f, 0.0f, 0.0f, 0.0f, _coordinateHeight, 0.0f);
		Matrix world;
		Matrix::mulMtx(world, getWorld(), loveToDora);
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), world);
		for (uint32_t index = 0; index < vertexCount; ++index)
		{
			const auto &vertex = _vertices[index];
			const Vec4 position{vertex.x, vertex.y, vertex.z, vertex.w};
			const float texcoord[4] = {vertex.u, vertex.v, 0.0f, 1.0f};
			const float color[4] = {vertex.red, vertex.green, vertex.blue, vertex.alpha};
			bgfx::vertexPack(&position.x, false, bgfx::Attrib::Position, _layout, vertexBuffer.data, index);
			bgfx::vertexPack(texcoord, false, bgfx::Attrib::TexCoord0, _layout, vertexBuffer.data, index);
			bgfx::vertexPack(color, true, bgfx::Attrib::Color0, _layout, vertexBuffer.data, index);
			for (const auto &attribute : _attributes)
			{
				float value[4] = {0.0f, 0.0f, 0.0f, 1.0f};
				const float *source = attribute.values.data()
					+ static_cast<std::size_t>(index) * static_cast<std::size_t>(attribute.components);
				std::copy_n(source, attribute.components, value);
				bgfx::vertexPack(value, false, attribute.semantic, _layout, vertexBuffer.data, index);
			}
		}
		if (index32)
			std::memcpy(indexBuffer.data, _indices.data(), _indices.size() * sizeof(_indices[0]));
		else
		{
			auto *target = reinterpret_cast<uint16_t *>(indexBuffer.data);
			for (std::size_t index = 0; index < _indices.size(); ++index)
				target[index] = static_cast<uint16_t>(_indices[index]);
		}
		const auto stencil = SharedRendererManager.getCurrentStencilState();
		bgfx::setStencil(stencil);
		RendererManager::ScissorState scissor;
		if (SharedRendererManager.getCurrentScissorState(scissor))
			bgfx::setScissor(scissor.x, scissor.y, scissor.width, scissor.height);
		else bgfx::setScissor(UINT16_MAX);
		bgfx::setVertexBuffer(0, &vertexBuffer);
		bgfx::setIndexBuffer(&indexBuffer);
		if (_instanceCount > 1) bgfx::setInstanceDataBuffer(&instanceBuffer);
		auto state = SharedRendererManager.applyState(
			BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | _blend.toValue()
				| (_wireframe ? BGFX_STATE_PT_LINES : BGFX_STATE_NONE));
		if (_ignoreCull) state &= ~BGFX_STATE_CULL_MASK;
		bgfx::setState(state);
		bgfx::setTexture(0, _effect->getSampler(), _texture->getHandle(), _samplerFlags);
		Pass *lastPass = _effect->getPasses().back().get();
		for (Pass *pass : _effect->getPasses())
		{
			pass->set("u_loveTransform"_slice, transform);
			if (_instanceCount > 1)
				pass->set("u_loveInstanceSelectors"_slice,
					std::span<const Vec4>(_instanceSelectors));
			bgfx::submit(SharedView.getId(), pass->apply(), 0,
				pass == lastPass ? BGFX_DISCARD_ALL : BGFX_DISCARD_NONE);
			pass->set("u_loveTransform"_slice, Matrix::Indentity);
		}
		Node::render();
	}

	virtual void cleanup() override
	{
		Node::cleanup();
		_texture = nullptr;
		_effect = nullptr;
	}

	CREATE_FUNC_NOT_NULL(LoveDynamicMeshNode);

private:
	std::vector<Love::GraphicsBackend::MeshVertex> _vertices;
	std::vector<uint32_t> _indices;
	std::vector<LoveDynamicMeshAttribute> _attributes;
	std::vector<LoveDynamicMeshInstanceAttribute> _instanceAttributes;
	int _instanceCount = 1;
	std::array<Vec4, 5> _instanceSelectors{};
	bgfx::VertexLayout _layout;
	Ref<Texture2D> _texture;
	BlendFunc _blend;
	uint32_t _samplerFlags = UINT32_MAX;
	Ref<SpriteEffect> _effect;
	float _coordinateHeight = 0.0f;
	bool _ignoreCull = false;
	bool _wireframe = false;
};

uint32_t toStencilAction(std::string_view action)
{
	if (action == "increment") return BGFX_STENCIL_OP_PASS_Z_INCRSAT;
	if (action == "decrement") return BGFX_STENCIL_OP_PASS_Z_DECRSAT;
	if (action == "incrementwrap") return BGFX_STENCIL_OP_PASS_Z_INCR;
	if (action == "decrementwrap") return BGFX_STENCIL_OP_PASS_Z_DECR;
	if (action == "invert") return BGFX_STENCIL_OP_PASS_Z_INVERT;
	return BGFX_STENCIL_OP_PASS_Z_REPLACE;
}

uint32_t toStencilTest(std::string_view compare)
{
	// Love compares the stored stencil value against the reference value. GPU APIs
	// express less/greater in the opposite direction, matching upstream's reversal.
	if (compare == "less") return BGFX_STENCIL_TEST_GREATER;
	if (compare == "lequal") return BGFX_STENCIL_TEST_GEQUAL;
	if (compare == "equal") return BGFX_STENCIL_TEST_EQUAL;
	if (compare == "gequal") return BGFX_STENCIL_TEST_LEQUAL;
	if (compare == "greater") return BGFX_STENCIL_TEST_LESS;
	if (compare == "notequal") return BGFX_STENCIL_TEST_NOTEQUAL;
	if (compare == "never") return BGFX_STENCIL_TEST_NEVER;
	return BGFX_STENCIL_NONE;
}

uint64_t toDepthState(std::string_view compare, bool write)
{
	uint64_t state = write ? BGFX_STATE_WRITE_Z : BGFX_STATE_NONE;
	if (compare == "less") state |= BGFX_STATE_DEPTH_TEST_LESS;
	else if (compare == "lequal") state |= BGFX_STATE_DEPTH_TEST_LEQUAL;
	else if (compare == "equal") state |= BGFX_STATE_DEPTH_TEST_EQUAL;
	else if (compare == "gequal") state |= BGFX_STATE_DEPTH_TEST_GEQUAL;
	else if (compare == "greater") state |= BGFX_STATE_DEPTH_TEST_GREATER;
	else if (compare == "notequal") state |= BGFX_STATE_DEPTH_TEST_NOTEQUAL;
	else if (compare == "never") state |= BGFX_STATE_DEPTH_TEST_NEVER;
	else state |= BGFX_STATE_DEPTH_TEST_ALWAYS;
	return state;
}

uint64_t toCullState(std::string_view mode, std::string_view winding)
{
	if (mode == "none") return BGFX_STATE_NONE;
	// Love vertices use a top-left, y-down coordinate system. LoveNode flips y before
	// submitting to Dora's y-up 2D projection. OpenGL render targets use Dora's
	// opposite-y projection as well, cancelling that winding reversal; other backends
	// see the single Love-to-Dora flip.
	const bool cullLoveClockwise = (mode == "back" && winding == "ccw")
		|| (mode == "front" && winding == "cw");
	const auto renderer = bgfx::getCaps()->rendererType;
	const bool glRenderTarget = renderer == bgfx::RendererType::OpenGL
		|| renderer == bgfx::RendererType::OpenGLES;
	if (glRenderTarget)
		return cullLoveClockwise ? BGFX_STATE_CULL_CW : BGFX_STATE_CULL_CCW;
	return cullLoveClockwise ? BGFX_STATE_CULL_CCW : BGFX_STATE_CULL_CW;
}

uint32_t meshSamplerFlags(Texture2D *texture, Love::GraphicsBackend::TextureFilter filter,
	Love::GraphicsBackend::TextureWrap wrapU, Love::GraphicsBackend::TextureWrap wrapV,
	Love::GraphicsBackend::TextureWrap wrapW = Love::GraphicsBackend::TextureWrap::Clamp)
{
	if (!texture) return UINT32_MAX;
	const uint64_t textureFlags = texture->getFlags();
	const uint64_t mask = BGFX_SAMPLER_MIN_MASK | BGFX_SAMPLER_MAG_MASK
		| BGFX_SAMPLER_U_MASK | BGFX_SAMPLER_V_MASK;
	uint64_t requested = 0;
	switch (filter)
	{
		case Love::GraphicsBackend::TextureFilter::Nearest:
			requested |= BGFX_SAMPLER_MIN_POINT | BGFX_SAMPLER_MAG_POINT;
			break;
		case Love::GraphicsBackend::TextureFilter::Anisotropic:
			requested |= BGFX_SAMPLER_MIN_ANISOTROPIC | BGFX_SAMPLER_MAG_ANISOTROPIC;
			break;
		case Love::GraphicsBackend::TextureFilter::Linear: break;
	}
	auto appendWrap = [&](Love::GraphicsBackend::TextureWrap wrap,
		uint64_t mirror, uint64_t clamp, uint64_t border) {
		switch (wrap)
		{
			case Love::GraphicsBackend::TextureWrap::Repeat: break;
			case Love::GraphicsBackend::TextureWrap::MirroredRepeat: requested |= mirror; break;
			case Love::GraphicsBackend::TextureWrap::ClampZero: requested |= border; break;
			case Love::GraphicsBackend::TextureWrap::Clamp: requested |= clamp; break;
		}
	};
	appendWrap(wrapU, BGFX_SAMPLER_U_MIRROR, BGFX_SAMPLER_U_CLAMP, BGFX_SAMPLER_U_BORDER);
	appendWrap(wrapV, BGFX_SAMPLER_V_MIRROR, BGFX_SAMPLER_V_CLAMP, BGFX_SAMPLER_V_BORDER);
	const bool useTextureDefaults = filter == Love::GraphicsBackend::TextureFilter::Linear
		&& wrapU == Love::GraphicsBackend::TextureWrap::Repeat
		&& wrapV == Love::GraphicsBackend::TextureWrap::Repeat;
	uint32_t flags = useTextureDefaults || requested == (textureFlags & mask)
		? UINT32_MAX
		: static_cast<uint32_t>((textureFlags & ~mask) | requested);
	switch (wrapW)
	{
		case Love::GraphicsBackend::TextureWrap::Repeat: break;
		case Love::GraphicsBackend::TextureWrap::MirroredRepeat: flags |= BGFX_SAMPLER_W_MIRROR; break;
		case Love::GraphicsBackend::TextureWrap::ClampZero: flags |= BGFX_SAMPLER_W_BORDER; break;
		case Love::GraphicsBackend::TextureWrap::Clamp: flags |= BGFX_SAMPLER_W_CLAMP; break;
	}
	return flags;
}

struct LoveShaderUniformInfo
{
	std::string gpuName;
	Love::GraphicsBackend::ShaderUniformType type = Love::GraphicsBackend::ShaderUniformType::Float;
	Love::GraphicsBackend::TextureType textureType = Love::GraphicsBackend::TextureType::Texture2D;
	int components = 4;
	int count = 1;
	int samplerSlot = 0;
};

struct LoveShaderAttributeInfo
{
	std::string gpuName;
	bgfx::Attrib::Enum semantic = bgfx::Attrib::TexCoord1;
	int components = 4;
	int selectorIndex = -1;
};

struct LoveShaderVaryingInfo
{
	std::string type;
	std::vector<std::string> gpuNames;
	std::string interpolation;
	int components = 4;
	int columns = 1;
	int streams = 1;
	int count = 1;
	bool array = false;
	bool pixelInput = false;
};

using LoveShaderVaryingMap = std::unordered_map<std::string, LoveShaderVaryingInfo>;

int loveShaderVaryingColumns(std::string_view type)
{
	if (type == "mat2") return 2;
	if (type == "mat3") return 3;
	if (type == "mat4") return 4;
	return 1;
}

int loveShaderVaryingComponents(std::string_view type)
{
	if (type == "float" || type == "int" || type == "uint" || type == "bool") return 1;
	if (type == "vec2" || type == "ivec2" || type == "uvec2" || type == "bvec2"
		|| type == "mat2") return 2;
	if (type == "vec3" || type == "ivec3" || type == "uvec3" || type == "bvec3"
		|| type == "mat3") return 3;
	return 4;
}

bool isLoveShaderSignedVaryingType(std::string_view type)
{
	return type == "int" || type.starts_with("ivec");
}

bool isLoveShaderUnsignedVaryingType(std::string_view type)
{
	return type == "uint" || type.starts_with("uvec");
}

bool isLoveShaderBooleanVaryingType(std::string_view type)
{
	return type == "bool" || type.starts_with("bvec");
}

bool isLoveShaderNonFloatVaryingType(std::string_view type)
{
	return isLoveShaderSignedVaryingType(type)
		|| isLoveShaderUnsignedVaryingType(type)
		|| isLoveShaderBooleanVaryingType(type);
}

int loveShaderVaryingStreams(std::string_view type, int components, int columns)
{
	if (isLoveShaderSignedVaryingType(type)
		|| isLoveShaderUnsignedVaryingType(type))
		return (components * 2 + 3) / 4;
	return columns;
}

std::string loveShaderVaryingStreamValue(std::string_view gpuName, int components)
{
	if (components == 1) return std::string(gpuName) + ".x";
	if (components == 2) return std::string(gpuName) + ".xy";
	if (components == 3) return std::string(gpuName) + ".xyz";
	return std::string(gpuName);
}

std::string loveShaderIntegerVaryingComponent(
	const std::vector<std::string> &gpuNames, std::size_t first,
	int component, bool signedValue)
{
	const int packedComponent = component * 2;
	const std::string high = gpuNames[first + static_cast<std::size_t>(packedComponent / 4)]
		+ "." + std::string(1, "xyzw"[packedComponent % 4]);
	const std::string low = gpuNames[first + static_cast<std::size_t>((packedComponent + 1) / 4)]
		+ "." + std::string(1, "xyzw"[(packedComponent + 1) % 4]);
	const std::string bits = "((uint(" + high + ") << 16u) | uint(" + low + "))";
	return signedValue ? "int(" + bits + ")" : bits;
}

std::string loveShaderVaryingDecodedValue(
	const std::vector<std::string> &gpuNames, std::size_t first,
	std::string_view type, int components, int columns)
{
	if (isLoveShaderSignedVaryingType(type)
		|| isLoveShaderUnsignedVaryingType(type))
	{
		const bool signedValue = isLoveShaderSignedVaryingType(type);
		if (components == 1)
			return loveShaderIntegerVaryingComponent(gpuNames, first, 0, signedValue);
		std::string value = std::string(type) + "(";
		for (int component = 0; component < components; ++component)
		{
			if (component != 0) value += ", ";
			value += loveShaderIntegerVaryingComponent(
				gpuNames, first, component, signedValue);
		}
		value += ")";
		return value;
	}
	const std::string stream = loveShaderVaryingStreamValue(gpuNames[first], components);
	if (isLoveShaderBooleanVaryingType(type))
	{
		if (components == 1) return "(" + stream + " != 0.0)";
		return "notEqual(" + stream + ", vec" + std::to_string(components)
			+ "_splat(0.0))";
	}
	if (columns == 1) return stream;
	std::string value = std::string(type) + "(";
	for (int column = 0; column < columns; ++column)
	{
		if (column != 0) value += ", ";
		value += loveShaderVaryingStreamValue(
			gpuNames[first + static_cast<std::size_t>(column)], components);
	}
	value += ")";
	return value;
}

std::string loveShaderVaryingValue(const LoveShaderVaryingInfo &varying,
	std::size_t first = 0)
{
	return loveShaderVaryingDecodedValue(varying.gpuNames, first,
		varying.type, varying.components, varying.columns);
}

std::string loveShaderBooleanVaryingValue(std::string_view value, int components)
{
	if (components == 1) return "(" + std::string(value) + " ? 1.0 : 0.0)";
	std::string result = "vec" + std::to_string(components) + "(";
	for (int component = 0; component < components; ++component)
	{
		if (component != 0) result += ", ";
		result += "(" + std::string(value) + "." + std::string(1, "xyzw"[component])
			+ " ? 1.0 : 0.0)";
	}
	result += ")";
	return result;
}

std::string loveShaderIntegerVaryingSourceComponent(
	std::string_view value, int components, int component)
{
	if (components == 1) return std::string(value);
	return std::string(value) + "." + std::string(1, "xyzw"[component]);
}

std::string loveShaderVaryingPackedColumn(std::string_view value,
	std::string_view type, int components, int stream = 0)
{
	if (isLoveShaderSignedVaryingType(type)
		|| isLoveShaderUnsignedVaryingType(type))
	{
		std::string encoded = "vec4(";
		for (int packedComponent = 0; packedComponent < 4; ++packedComponent)
		{
			if (packedComponent != 0) encoded += ", ";
			const int sourceComponent = (stream * 4 + packedComponent) / 2;
			if (sourceComponent >= components)
			{
				encoded += packedComponent == 3 ? "1.0" : "0.0";
				continue;
			}
			const std::string bits = "uint("
				+ loveShaderIntegerVaryingSourceComponent(value, components, sourceComponent)
				+ ")";
			if ((stream * 4 + packedComponent) % 2 == 0)
				encoded += "float((" + bits + " >> 16u) & 65535u)";
			else encoded += "float(" + bits + " & 65535u)";
		}
		encoded += ")";
		return encoded;
	}
	std::string encoded(value);
	if (isLoveShaderBooleanVaryingType(type))
		encoded = loveShaderBooleanVaryingValue(value, components);
	if (components == 1) return "vec4(" + encoded + ", 0.0, 0.0, 1.0)";
	if (components == 2) return "vec4(" + encoded + ", 0.0, 1.0)";
	if (components == 3) return "vec4(" + encoded + ", 1.0)";
	return encoded;
}

std::string loveShaderVaryingZeroValue(std::string_view type, int components)
{
	std::string scalar = "0.0";
	if (isLoveShaderSignedVaryingType(type)) scalar = "0";
	else if (isLoveShaderUnsignedVaryingType(type)) scalar = "0u";
	else if (isLoveShaderBooleanVaryingType(type)) scalar = "false";
	if (components == 1) return scalar;
	if (type.starts_with("vec")) return std::string(type) + "_splat(" + scalar + ")";
	if (type.starts_with("mat"))
	{
		std::string result(type);
		result += "(";
		for (int column = 0; column < components; ++column)
		{
			if (column != 0) result += ", ";
			result += "vec" + std::to_string(components) + "_splat(0.0)";
		}
		return result + ")";
	}
	std::string result(type);
	result += "(";
	for (int component = 0; component < components; ++component)
	{
		if (component != 0) result += ", ";
		result += scalar;
	}
	return result + ")";
}

enum class LoveShaderLanguage
{
	GLSL1,
	GLSL3,
};

struct LoveShaderTranslation
{
	std::string source;
	std::string warnings;
	std::vector<std::pair<int, std::string>> diagnosticLines;
	std::unordered_map<std::string, LoveShaderUniformInfo> uniforms;
	std::unordered_map<std::string, LoveShaderAttributeInfo> attributes;
	std::optional<Love::GraphicsBackend::TextureType> mainTextureType;
	int colorOutputs = 1;
	bool usesInstanceID = false;
	bool usesVertexID = false;
	bgfx::Attrib::Enum mainTextureLayerSemantic = bgfx::Attrib::Count;
	bgfx::Attrib::Enum vertexIDSemantic = bgfx::Attrib::Count;
};

std::string regexEscape(std::string_view text)
{
	static const std::regex special(R"([.^$|()\[\]{}*+?\\])");
	return std::regex_replace(std::string(text), special, R"(\$&)");
}

void blankShaderMatchesPreservingLines(std::string &text, const std::regex &pattern)
{
	std::vector<std::pair<std::size_t, std::size_t>> ranges;
	for (std::sregex_iterator it(text.begin(), text.end(), pattern), end; it != end; ++it)
		ranges.emplace_back(static_cast<std::size_t>(it->position()),
			static_cast<std::size_t>(it->length()));
	for (const auto &[start, length] : ranges)
		for (std::size_t index = start; index < start + length; ++index)
			if (text[index] != '\n' && text[index] != '\r') text[index] = ' ';
}

bool parseLoveShaderLanguage(std::string_view source, LoveShaderLanguage &language,
	std::string &body, std::string &error)
{
	language = LoveShaderLanguage::GLSL1;
	body.assign(source);
	if (source.empty()) return true;
	static const std::regex pragmaPattern(
		R"(^[ \t\r\n]*#pragma[ \t]+language[ \t]+([A-Za-z0-9_]+)[ \t]*(?:\r?\n|$))");
	std::smatch match;
	if (std::regex_search(body, match, pragmaPattern))
	{
		const std::string target = match[1].str();
		if (target == "glsl3") language = LoveShaderLanguage::GLSL3;
		else if (target != "glsl1")
		{
			error = "Invalid shader language: " + target;
			return false;
		}
		const std::size_t start = static_cast<std::size_t>(match.position());
		const std::size_t end = start + static_cast<std::size_t>(match.length());
		for (std::size_t index = start; index < end; ++index)
			if (body[index] != '\n' && body[index] != '\r') body[index] = ' ';
	}
	else if (source.find("#pragma language") != std::string_view::npos)
	{
		error = "Love Shader language pragma must be the first non-whitespace line";
		return false;
	}
	error.clear();
	return true;
}

bool isLoveShaderTrivia(std::string_view text)
{
	std::size_t index = 0;
	while (index < text.size())
	{
		if (std::isspace(static_cast<unsigned char>(text[index])))
		{
			++index;
			continue;
		}
		if (index + 1 < text.size() && text[index] == '/' && text[index + 1] == '/')
		{
			index += 2;
			while (index < text.size() && text[index] != '\n') ++index;
			continue;
		}
		if (index + 1 < text.size() && text[index] == '/' && text[index + 1] == '*')
		{
			const std::size_t end = text.find("*/", index + 2);
			if (end == std::string_view::npos) return false;
			index = end + 2;
			continue;
		}
		return false;
	}
	return true;
}

std::string maskLoveShaderComments(std::string_view source)
{
	std::string masked(source);
	for (std::size_t index = 0; index + 1 < masked.size();)
	{
		if (masked[index] == '/' && masked[index + 1] == '/')
		{
			masked[index++] = ' ';
			masked[index++] = ' ';
			while (index < masked.size() && masked[index] != '\n' && masked[index] != '\r')
				masked[index++] = ' ';
		}
		else if (masked[index] == '/' && masked[index + 1] == '*')
		{
			masked[index++] = ' ';
			masked[index++] = ' ';
			while (index < masked.size())
			{
				if (index + 1 < masked.size() && masked[index] == '*' && masked[index + 1] == '/')
				{
					masked[index++] = ' ';
					masked[index++] = ' ';
					break;
				}
				if (masked[index] != '\n' && masked[index] != '\r') masked[index] = ' ';
				++index;
			}
		}
		else ++index;
	}
	return masked;
}

bool normalizeLoveShaderInterpolation(std::string_view qualifiers,
	std::string &normalized, std::string &error)
{
	normalized.clear();
	std::string interpolation;
	bool centroid = false;
	std::size_t start = 0;
	while (start < qualifiers.size())
	{
		while (start < qualifiers.size()
			&& std::isspace(static_cast<unsigned char>(qualifiers[start]))) ++start;
		if (start == qualifiers.size()) break;
		std::size_t end = start;
		while (end < qualifiers.size()
			&& !std::isspace(static_cast<unsigned char>(qualifiers[end]))) ++end;
		const std::string token(qualifiers.substr(start, end - start));
		if (token == "centroid")
		{
			if (centroid)
			{
				error = "Love Shader varying has a duplicate centroid qualifier";
				return false;
			}
			centroid = true;
		}
		else
		{
			if (centroid)
			{
				error = "Love Shader interpolation qualifier must precede centroid";
				return false;
			}
			if (!interpolation.empty())
			{
				error = "Love Shader varying has conflicting interpolation qualifiers";
				return false;
			}
			interpolation = token;
		}
		start = end;
	}
	if (centroid && interpolation == "flat")
	{
		error = "Love Shader flat interpolation cannot be combined with centroid";
		return false;
	}
	normalized = interpolation;
	if (centroid)
	{
		if (!normalized.empty()) normalized += " ";
		normalized += "centroid";
	}
	error.clear();
	return true;
}

struct LoveShaderInterfaceMemberShape
{
	std::string type;
	int blockCount = 1;
	int memberCount = 1;
	bool blockArray = false;
	bool memberArray = false;
	std::vector<int> nestedArrayCounts;
	std::vector<std::string> structTypes;
};

using LoveShaderInterfaceShapeMap = std::unordered_map<std::string,
	LoveShaderInterfaceMemberShape>;

std::string_view trimShaderText(std::string_view text);

std::size_t findLoveShaderMatchingDelimiter(std::string_view text, std::size_t open,
	char opening, char closing)
{
	int depth = 0;
	for (std::size_t index = open; index < text.size(); ++index)
	{
		if (text[index] == opening) ++depth;
		else if (text[index] == closing && --depth == 0) return index;
	}
	return std::string_view::npos;
}

struct LoveShaderInterfacePathSegment
{
	std::string name;
	int count = 1;
	bool array = false;
};

struct LoveShaderStructMember
{
	std::string type;
	std::string name;
	int count = 1;
	bool array = false;
};

struct LoveShaderStructDefinition
{
	std::vector<LoveShaderStructMember> members;
	bool supportedSyntax = true;
};

using LoveShaderStructMap = std::unordered_map<std::string, LoveShaderStructDefinition>;

std::string loveShaderInlineStructName(std::string_view body)
{
	std::uint64_t hash = UINT64_C(14695981039346656037);
	for (const char character : body)
	{
		if (std::isspace(static_cast<unsigned char>(character))) continue;
		hash ^= static_cast<unsigned char>(character);
		hash *= UINT64_C(1099511628211);
	}
	std::array<char, 16> digits{};
	const auto result = std::to_chars(digits.data(), digits.data() + digits.size(), hash, 16);
	return "__dora_love_inline_" + std::string(digits.data(), result.ptr);
}

bool liftLoveShaderInlineStructs(std::string &members,
	std::unordered_map<std::string, std::string> &definitions, std::string &error)
{
	static const std::regex inlinePattern(R"(\bstruct\s*\{([^{}]*)\})");
	while (true)
	{
		std::smatch match;
		if (!std::regex_search(members, match, inlinePattern)) break;
		const std::string body = match[1].str();
		const std::string name = loveShaderInlineStructName(body);
		const auto [found, inserted] = definitions.emplace(name, body);
		if (!inserted)
		{
			std::string canonicalFound;
			std::string canonicalBody;
			for (const char character : found->second)
				if (!std::isspace(static_cast<unsigned char>(character)))
					canonicalFound.push_back(character);
			for (const char character : body)
				if (!std::isspace(static_cast<unsigned char>(character)))
					canonicalBody.push_back(character);
			if (canonicalFound != canonicalBody)
			{
				error = "Love Shader inline struct identity collision";
				return false;
			}
		}
		std::string replacement = name;
		for (const char character : match.str())
			if (character == '\n' || character == '\r') replacement.push_back(character);
		members.replace(static_cast<std::size_t>(match.position()),
			static_cast<std::size_t>(match.length()), replacement);
	}
	error.clear();
	return true;
}

bool isLoveShaderVaryingLeafType(std::string_view type)
{
	return type == "float" || type == "vec2" || type == "vec3" || type == "vec4"
		|| type == "mat2" || type == "mat3" || type == "mat4"
		|| type == "int" || type == "ivec2" || type == "ivec3" || type == "ivec4"
		|| type == "uint" || type == "uvec2" || type == "uvec3" || type == "uvec4"
		|| type == "bool" || type == "bvec2" || type == "bvec3" || type == "bvec4";
}

bool parseLoveShaderStructDefinitions(std::string_view source,
	LoveShaderStructMap &definitions, std::string &error)
{
	definitions.clear();
	const std::string syntax = maskLoveShaderComments(source);
	static const std::regex structPattern(
		R"(\bstruct\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{([\s\S]*?)\}\s*;)"
	);
	static const std::regex memberPattern(
		R"((?:(?:lowp|mediump|highp)\s+)?([A-Za-z_][A-Za-z0-9_]*)\s+((?:[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)*)\s*;)"
	);
	static const std::regex declaratorPattern(
		R"(([A-Za-z_][A-Za-z0-9_]*)(?:\s*\[\s*([0-9]+)\s*\])?)"
	);
	for (std::sregex_iterator it(syntax.begin(), syntax.end(), structPattern), end;
		it != end; ++it)
	{
		const std::string name = (*it)[1].str();
		if (definitions.contains(name))
		{
			error = "duplicate Love Shader struct definition '" + name + "'";
			return false;
		}
		const std::string body = (*it)[2].str();
		LoveShaderStructDefinition definition;
		std::size_t consumed = 0;
		std::unordered_set<std::string> memberNames;
		for (std::sregex_iterator memberIt(body.begin(), body.end(), memberPattern), memberEnd;
			memberIt != memberEnd; ++memberIt)
		{
			const std::size_t position = static_cast<std::size_t>(memberIt->position());
			if (!isLoveShaderTrivia(std::string_view(body).substr(consumed, position - consumed)))
				definition.supportedSyntax = false;
			const std::string type = (*memberIt)[1].str();
			const std::string declarators = (*memberIt)[2].str();
			for (std::sregex_iterator declaratorIt(declarators.begin(), declarators.end(),
					declaratorPattern), declaratorEnd; declaratorIt != declaratorEnd;
				++declaratorIt)
			{
				const std::string member = (*declaratorIt)[1].str();
				if (!memberNames.insert(member).second)
				{
					error = "duplicate Love Shader struct member '" + name + "." + member + "'";
					return false;
				}
				const bool array = (*declaratorIt)[2].matched;
				int count = 1;
				if (array)
				{
					const std::string countText = (*declaratorIt)[2].str();
					const auto parsed = std::from_chars(countText.data(),
						countText.data() + countText.size(), count);
					if (parsed.ec != std::errc{} || count <= 0 || count > 1024)
					{
						error = "Love Shader struct member array '" + name + "." + member
							+ "' must contain 1 to 1024 elements";
						return false;
					}
				}
				definition.members.push_back({type, member, count, array});
			}
			consumed = position + static_cast<std::size_t>(memberIt->length());
		}
		if (definition.members.empty()
			|| !isLoveShaderTrivia(std::string_view(body).substr(consumed)))
			definition.supportedSyntax = false;
		definitions.emplace(name, std::move(definition));
	}
	error.clear();
	return true;
}

bool rewriteLoveShaderInterfaceReferences(std::string &source,
	std::string_view instance, std::string_view blockName,
	std::span<const LoveShaderInterfacePathSegment> path,
	std::string_view flattened, bool blockArray, int blockCount, std::string &error)
{
	if (path.empty()) return true;
	const std::string firstIdentifier = instance.empty() ? path.front().name : std::string(instance);
	const std::regex identifier("\\b" + regexEscape(firstIdentifier) + "\\b");
	std::size_t search = 0;
	while (search < source.size())
	{
		std::match_results<std::string::const_iterator> match;
		const auto begin = source.cbegin() + static_cast<std::ptrdiff_t>(search);
		if (!std::regex_search(begin, source.cend(), match, identifier)) break;
		const std::size_t start = search + static_cast<std::size_t>(match.position());
		std::size_t cursor = start + firstIdentifier.size();
		std::vector<std::pair<std::string, int>> indices;
		auto parseIndex = [&](bool required, int count, std::string_view description) -> bool {
			while (cursor < source.size()
				&& std::isspace(static_cast<unsigned char>(source[cursor]))) ++cursor;
			if (cursor == source.size() || source[cursor] != '[')
			{
				if (required)
				{
					error = "Love Shader " + std::string(description) + " must be indexed";
					return false;
				}
				return true;
			}
			if (!required) return true;
			const std::size_t close = findLoveShaderMatchingDelimiter(source, cursor, '[', ']');
			if (close == std::string::npos)
			{
				error = "Love Shader " + std::string(description) + " has an unterminated index";
				return false;
			}
			const std::string expression(trimShaderText(
				std::string_view(source).substr(cursor + 1, close - cursor - 1)));
			if (expression.empty())
			{
				error = "Love Shader " + std::string(description) + " has an empty index";
				return false;
			}
			indices.emplace_back(expression, count);
			cursor = close + 1;
			return true;
		};
		std::size_t pathIndex = 0;
		if (!instance.empty())
		{
			if (!parseIndex(blockArray, blockCount,
				"interface block array '" + std::string(blockName) + "'")) return false;
		}
		else
		{
			if (blockArray)
			{
				error = "Love Shader anonymous interface blocks cannot be arrays";
				return false;
			}
			if (!parseIndex(path.front().array, path.front().count,
				"interface block member array '" + std::string(blockName) + "."
					+ path.front().name + "'")) return false;
			pathIndex = 1;
		}
		bool matchesPath = true;
		for (; pathIndex < path.size(); ++pathIndex)
		{
			while (cursor < source.size()
				&& std::isspace(static_cast<unsigned char>(source[cursor]))) ++cursor;
			if (cursor == source.size() || source[cursor] != '.')
			{
				matchesPath = false;
				break;
			}
			++cursor;
			while (cursor < source.size()
				&& std::isspace(static_cast<unsigned char>(source[cursor]))) ++cursor;
			const auto &segment = path[pathIndex];
			if (source.compare(cursor, segment.name.size(), segment.name) != 0
				|| (cursor + segment.name.size() < source.size()
					&& (std::isalnum(static_cast<unsigned char>(source[cursor + segment.name.size()]))
						|| source[cursor + segment.name.size()] == '_')))
			{
				matchesPath = false;
				break;
			}
			cursor += segment.name.size();
			std::string qualified = std::string(blockName);
			for (std::size_t nameIndex = 0; nameIndex <= pathIndex; ++nameIndex)
				qualified += "." + path[nameIndex].name;
			if (!parseIndex(segment.array, segment.count,
				"interface block member array '" + qualified + "'")) return false;
		}
		if (!matchesPath)
		{
			search = start + firstIdentifier.size();
			continue;
		}
		std::string replacement(flattened);
		if (!indices.empty())
		{
			std::string linear = "(" + indices.front().first + ")";
			for (std::size_t index = 1; index < indices.size(); ++index)
				linear = "(" + linear + ") * " + std::to_string(indices[index].second)
					+ " + (" + indices[index].first + ")";
			replacement += "[" + linear + "]";
		}
		source.replace(start, cursor - start, replacement);
		search = start + replacement.size();
	}
	return true;
}

bool normalizeLoveShaderInterfaceBlocks(std::string_view source, bool vertex,
	LoveShaderLanguage language, std::string &normalized,
	LoveShaderInterfaceShapeMap &shapes, std::string &error)
{
	normalized.assign(source);
	shapes.clear();
	if (language != LoveShaderLanguage::GLSL3) return true;
	static const std::regex blockPattern(
		R"(\b((?:(?:flat|smooth|noperspective|centroid)\s+)*)(in|out)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{([\s\S]*?)\}\s*([A-Za-z_][A-Za-z0-9_]*)?(?:\s*\[\s*([0-9]+)\s*\])?\s*;)"
	);
	static const std::regex memberPattern(
		R"(((?:(?:flat|smooth|noperspective|centroid)\s+)*)(?:(?:lowp|mediump|highp)\s+)?([A-Za-z_][A-Za-z0-9_]*)\s+((?:[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)*)\s*;)"
	);
	static const std::regex declaratorPattern(
		R"(([A-Za-z_][A-Za-z0-9_]*)(?:\s*\[\s*([0-9]+)\s*\])?)"
	);
	struct MemberReference
	{
		std::string instance;
		std::string blockName;
		std::vector<LoveShaderInterfacePathSegment> path;
		std::string flattened;
		bool blockArray = false;
		int blockCount = 1;
	};
	struct BlockReplacement
	{
		std::size_t position = 0;
		std::size_t length = 0;
		std::string declaration;
	};
	std::vector<MemberReference> references;
	std::vector<BlockReplacement> replacements;
	std::unordered_set<std::string> flattenedNames;
	std::string syntax = maskLoveShaderComments(source);
	struct InlineStructRange
	{
		std::size_t position = 0;
		std::size_t length = 0;
	};
	std::vector<InlineStructRange> inlineStructRanges;
	static const std::regex blockHeaderPattern(
		R"(\b(?:(?:flat|smooth|noperspective|centroid)\s+)*(?:in|out)\s+[A-Za-z_][A-Za-z0-9_]*\s*\{)"
	);
	std::size_t blockSearch = 0;
	while (blockSearch < syntax.size())
	{
		std::match_results<std::string::const_iterator> match;
		const auto begin = syntax.cbegin() + static_cast<std::ptrdiff_t>(blockSearch);
		if (!std::regex_search(begin, syntax.cend(), match, blockHeaderPattern)) break;
		const std::size_t open = blockSearch + static_cast<std::size_t>(match.position())
			+ static_cast<std::size_t>(match.length()) - 1;
		const std::size_t close = findLoveShaderMatchingDelimiter(syntax, open, '{', '}');
		if (close == std::string::npos)
		{
			error = "Love Shader interface block has an unterminated body";
			return false;
		}
		inlineStructRanges.push_back({open + 1, close - open - 1});
		blockSearch = close + 1;
	}
	std::unordered_map<std::string, std::string> inlineStructDefinitions;
	for (auto it = inlineStructRanges.rbegin(); it != inlineStructRanges.rend(); ++it)
	{
		std::string members = syntax.substr(it->position, it->length);
		if (!liftLoveShaderInlineStructs(members, inlineStructDefinitions, error)) return false;
		syntax.replace(it->position, it->length, members);
		normalized.replace(it->position, it->length, members);
	}
	LoveShaderStructMap structDefinitions;
	std::string structSource = syntax;
	for (const auto &[name, body] : inlineStructDefinitions)
		structSource += "\nstruct " + name + " {" + body + "};";
	if (!parseLoveShaderStructDefinitions(structSource, structDefinitions, error)) return false;
	if (std::regex_search(syntax, std::regex(R"(\blayout\s*\()")))
	{
		// Love 11.5's GLSL3 targets are GLSL 330 and ESSL 300. The layout
		// form shared by both for user vertex inputs is an explicit attribute
		// location. Keep it until attribute translation validates the active
		// declarations; other layout forms are not portable across those targets.
		if (!vertex)
		{
			error = "Dora's Love Shader subset supports layout qualifiers only for GLSL3 vertex attributes";
			return false;
		}
		static const std::regex attributeLayoutPattern(
			R"(\blayout\s*\(\s*location\s*=\s*[0-9]+\s*\)\s*(?=(?:attribute|in)\s+(?:(?:lowp|mediump|highp)\s+)?(?:float|vec2|vec3|vec4)\s+[A-Za-z_][A-Za-z0-9_]*\s*;))"
		);
		std::string unsupportedLayouts = syntax;
		for (std::sregex_iterator it(syntax.begin(), syntax.end(), attributeLayoutPattern), end;
			it != end; ++it)
		{
			for (std::size_t index = static_cast<std::size_t>(it->position());
				index < static_cast<std::size_t>(it->position() + it->length()); ++index)
				if (unsupportedLayouts[index] != '\n' && unsupportedLayouts[index] != '\r')
					unsupportedLayouts[index] = ' ';
		}
		if (std::regex_search(unsupportedLayouts, std::regex(R"(\blayout\s*\()")))
		{
			error = "Dora's Love Shader subset supports only layout(location=N) on GLSL3 vertex attributes";
			return false;
		}
	}
	for (std::sregex_iterator it(syntax.begin(), syntax.end(), blockPattern), end; it != end; ++it)
	{
		std::string blockInterpolation;
		if (!normalizeLoveShaderInterpolation((*it)[1].str(), blockInterpolation, error))
			return false;
		const std::string storage = (*it)[2].str();
		const std::string blockName = (*it)[3].str();
		const std::string members = (*it)[4].str();
		const std::string instance = (*it)[5].str();
		const bool blockArray = (*it)[6].matched;
		int blockCount = 1;
		if (blockArray)
		{
			if (instance.empty())
			{
				error = "Love Shader interface block array '" + blockName
					+ "' requires an instance name";
				return false;
			}
			const std::string countText = (*it)[6].str();
			const auto parsed = std::from_chars(countText.data(),
				countText.data() + countText.size(), blockCount);
			if (parsed.ec != std::errc{} || blockCount <= 0 || blockCount > 1024)
			{
				error = "Love Shader interface block array '" + blockName
					+ "' must contain 1 to 1024 instances";
				return false;
			}
		}
		const std::string expectedStorage = vertex ? "out" : "in";
		if (storage != expectedStorage)
		{
			error = "Dora's Love Shader subset supports interface blocks only as vertex out / pixel in varyings";
			return false;
		}
		std::string declarations;
		std::size_t consumed = 0;
		int memberCount = 0;
		auto expandMember = [&](const std::string &type, const std::string &member,
			int count, bool memberArray, const std::string &interpolation) -> bool {
			std::vector<LoveShaderInterfacePathSegment> path{{member, count, memberArray}};
			std::vector<int> nestedArrayCounts;
			std::vector<std::string> structTypes;
			std::vector<std::string> recursionStack;
			std::function<bool(const std::string &)> expandType;
			expandType = [&](const std::string &currentType) -> bool {
				if (isLoveShaderVaryingLeafType(currentType))
				{
					std::string identity = blockName;
					std::string flattened = "loveBlock_" + blockName;
					for (const auto &segment : path)
					{
						identity += "." + segment.name;
						flattened += "_" + std::to_string(segment.name.size()) + "_" + segment.name;
					}
					if (!flattenedNames.insert(flattened).second || shapes.contains(identity))
					{
						error = "duplicate Love Shader interface block member '" + identity + "'";
						return false;
					}
					std::uint64_t flattenedCount = static_cast<std::uint64_t>(blockCount)
						* static_cast<std::uint64_t>(count);
					for (const int nestedCount : nestedArrayCounts)
						flattenedCount *= static_cast<std::uint64_t>(nestedCount);
					if (flattenedCount > 1024)
					{
						error = "Love Shader uses more custom varying semantic slots than Dora/bgfx can link";
						return false;
					}
					if (!interpolation.empty()) declarations += interpolation + " ";
					declarations += storage + " " + currentType + " " + flattened;
					if (blockArray || memberArray || !nestedArrayCounts.empty())
						declarations += "[" + std::to_string(flattenedCount) + "]";
					declarations += ";";
					shapes.emplace(identity, LoveShaderInterfaceMemberShape{
						currentType, blockCount, count, blockArray, memberArray,
						nestedArrayCounts, structTypes});
					references.push_back({instance, blockName, path,
						flattened, blockArray, blockCount});
					return true;
				}
				const auto definition = structDefinitions.find(currentType);
				if (definition == structDefinitions.end())
				{
					if (path.size() == 1)
						error = "Love Shader interface block '" + blockName
							+ "' contains an unsupported member declaration";
					else
					{
						std::string qualified = blockName;
						for (const auto &segment : path) qualified += "." + segment.name;
						error = "Love Shader nested struct member '" + qualified
							+ "' has unsupported type '" + currentType + "'";
					}
					return false;
				}
				if (!definition->second.supportedSyntax)
				{
					error = "Love Shader struct '" + currentType
						+ "' contains an unsupported member declaration";
					return false;
				}
				if (std::find(recursionStack.begin(), recursionStack.end(), currentType)
					!= recursionStack.end())
				{
					error = "Love Shader interface block contains recursive struct type '"
						+ currentType + "'";
					return false;
				}
				recursionStack.push_back(currentType);
				structTypes.push_back(currentType.starts_with("__dora_love_inline_")
					? "<anonymous>" : currentType);
				for (const auto &nested : definition->second.members)
				{
					path.push_back({nested.name, nested.count, nested.array});
					if (nested.array) nestedArrayCounts.push_back(nested.count);
					if (!expandType(nested.type)) return false;
					if (nested.array) nestedArrayCounts.pop_back();
					path.pop_back();
				}
				structTypes.pop_back();
				recursionStack.pop_back();
				return true;
			};
			if (!expandType(type)) return false;
			++memberCount;
			return true;
		};
		for (std::sregex_iterator memberIt(members.begin(), members.end(), memberPattern),
			memberEnd; memberIt != memberEnd; ++memberIt)
		{
			const std::size_t position = static_cast<std::size_t>(memberIt->position());
			if (!isLoveShaderTrivia(std::string_view(members).substr(consumed, position - consumed)))
			{
				error = "Love Shader interface block '" + blockName
					+ "' contains an unsupported member declaration";
				return false;
			}
			std::string memberInterpolation;
			if (!normalizeLoveShaderInterpolation((*memberIt)[1].str(),
					memberInterpolation, error)) return false;
			if (!blockInterpolation.empty() && !memberInterpolation.empty())
			{
				error = "Love Shader interface block '" + blockName
					+ "' cannot specify interpolation on both the block and a member";
				return false;
			}
			const std::string interpolation = memberInterpolation.empty()
				? blockInterpolation : memberInterpolation;
			const std::string type = (*memberIt)[2].str();
			const std::string declarators = (*memberIt)[3].str();
			for (std::sregex_iterator declaratorIt(declarators.begin(), declarators.end(),
					declaratorPattern), declaratorEnd; declaratorIt != declaratorEnd;
				++declaratorIt)
			{
				const std::string member = (*declaratorIt)[1].str();
				const bool memberArray = (*declaratorIt)[2].matched;
				int count = 1;
				if (memberArray)
				{
					const std::string countText = (*declaratorIt)[2].str();
					const auto parsed = std::from_chars(countText.data(),
						countText.data() + countText.size(), count);
					if (parsed.ec != std::errc{} || count <= 0 || count > 1024)
					{
						error = "Love Shader interface block member array '" + blockName + "."
							+ member + "' must contain 1 to 1024 elements";
						return false;
					}
				}
				if (!expandMember(type, member, count, memberArray, interpolation)) return false;
			}
			consumed = position + static_cast<std::size_t>(memberIt->length());
		}
		if (memberCount == 0 || !isLoveShaderTrivia(std::string_view(members).substr(consumed)))
		{
			error = "Love Shader interface block '" + blockName
				+ "' must contain supported varying or fixed struct members";
			return false;
		}
		for (char character : it->str())
			if (character == '\n' || character == '\r') declarations.push_back(character);
		replacements.push_back({static_cast<std::size_t>(it->position()),
			static_cast<std::size_t>(it->length()), std::move(declarations)});
	}
	std::string unmatchedSyntax = syntax;
	for (const auto &replacement : replacements)
		for (std::size_t index = replacement.position;
			index < replacement.position + replacement.length; ++index)
			if (unmatchedSyntax[index] != '\n' && unmatchedSyntax[index] != '\r')
				unmatchedSyntax[index] = ' ';
	if (std::regex_search(unmatchedSyntax,
			std::regex(R"(\b(?:in|out)\s+[A-Za-z_][A-Za-z0-9_]*\s*\{)")))
	{
		error = "Dora's Love Shader subset does not support this GLSL interface block form";
		return false;
	}
	for (auto it = replacements.rbegin(); it != replacements.rend(); ++it)
		normalized.replace(it->position, it->length, it->declaration);
	for (const auto &[instance, blockName, path, flattened,
		blockArray, blockCount] : references)
	{
		if (!rewriteLoveShaderInterfaceReferences(normalized, instance, blockName,
			path, flattened, blockArray, blockCount, error)) return false;
	}
	error.clear();
	return true;
}

bool parseLoveShaderVaryings(std::string_view vertexSource, std::string_view pixelSource,
	LoveShaderLanguage language,
	LoveShaderVaryingMap &varyings, std::string &error)
{
	const std::regex vertexVaryingPattern(language == LoveShaderLanguage::GLSL3
		? R"(\b((?:(?:flat|smooth|noperspective|centroid)\s+)*)(?:varying|out)\s+(?:(?:lowp|mediump|highp)\s+)?(float|vec2|vec3|vec4|mat2|mat3|mat4|int|ivec2|ivec3|ivec4|uint|uvec2|uvec3|uvec4|bool|bvec2|bvec3|bvec4)\s+((?:[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)*)\s*;)"
		: R"(\bvarying\s+(?:(?:lowp|mediump|highp)\s+)?(float|vec2|vec3|vec4|mat2|mat3|mat4)\s+((?:[A-Za-z_][A-Za-z0-9_]*)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*)\s*;)");
	const std::regex pixelVaryingPattern(language == LoveShaderLanguage::GLSL3
		? R"(\b((?:(?:flat|smooth|noperspective|centroid)\s+)*)(?:varying|in)\s+(?:(?:lowp|mediump|highp)\s+)?(float|vec2|vec3|vec4|mat2|mat3|mat4|int|ivec2|ivec3|ivec4|uint|uvec2|uvec3|uvec4|bool|bvec2|bvec3|bvec4)\s+((?:[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)*)\s*;)"
		: R"(\bvarying\s+(?:(?:lowp|mediump|highp)\s+)?(float|vec2|vec3|vec4|mat2|mat3|mat4)\s+((?:[A-Za-z_][A-Za-z0-9_]*)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*)\s*;)");
	const std::regex declaratorPattern(language == LoveShaderLanguage::GLSL3
		? R"(([A-Za-z_][A-Za-z0-9_]*)(?:\s*\[\s*([0-9]+)\s*\])?)"
		: R"(([A-Za-z_][A-Za-z0-9_]*))");
	struct ParsedVarying
	{
		std::string name;
		std::string type;
		std::string interpolation;
		int count = 1;
		bool array = false;
	};
	auto parse = [&](std::string_view source, std::vector<ParsedVarying> &result,
		std::string_view stage, const std::regex &pattern) {
		std::unordered_set<std::string> names;
		const std::string text(source);
		for (std::sregex_iterator it(text.begin(), text.end(), pattern), end; it != end; ++it)
		{
			std::string interpolation;
			if (language == LoveShaderLanguage::GLSL3
				&& !normalizeLoveShaderInterpolation((*it)[1].str(), interpolation, error))
				return false;
			const std::string type = (*it)[language == LoveShaderLanguage::GLSL3 ? 2 : 1].str();
			if (language == LoveShaderLanguage::GLSL3
				&& isLoveShaderNonFloatVaryingType(type) && interpolation != "flat")
			{
				error = "Love Shader integer and boolean varying type '" + type
					+ "' requires flat interpolation";
				return false;
			}
			const std::string declarators = (*it)[language == LoveShaderLanguage::GLSL3 ? 3 : 2].str();
			for (std::sregex_iterator declaratorIt(declarators.begin(), declarators.end(),
					declaratorPattern), declaratorEnd; declaratorIt != declaratorEnd;
				++declaratorIt)
			{
				const std::string name = (*declaratorIt)[1].str();
				int count = 1;
				const bool array = language == LoveShaderLanguage::GLSL3
					&& (*declaratorIt)[2].matched;
				if (array)
				{
					const std::string countText = (*declaratorIt)[2].str();
					const auto parsed = std::from_chars(countText.data(),
						countText.data() + countText.size(), count);
					if (parsed.ec != std::errc{} || count <= 0 || count > 1024)
					{
						error = "Love Shader varying array '" + name
							+ "' must contain 1 to 1024 elements";
						return false;
					}
				}
				if (name == "VaryingColor" || name == "VaryingTexCoord")
				{
					error = "Love Shader cannot redeclare built-in varying '" + name + "'";
					return false;
				}
				if (!names.insert(name).second)
				{
					error = "duplicate Love " + std::string(stage) + " Shader varying '" + name + "'";
					return false;
				}
				result.push_back({name, type, interpolation, count, array});
			}
		}
		return true;
	};
	std::vector<ParsedVarying> vertexVaryings;
	std::vector<ParsedVarying> pixelVaryings;
	if (!parse(vertexSource, vertexVaryings, "vertex", vertexVaryingPattern)
		|| !parse(pixelSource, pixelVaryings, "pixel", pixelVaryingPattern)) return false;
	std::unordered_map<std::string, ParsedVarying> vertexDeclarations;
	for (const auto &varying : vertexVaryings) vertexDeclarations.emplace(varying.name, varying);
	std::unordered_set<std::string> pixelInputs;
	for (const auto &[name, type, interpolation, count, array] : pixelVaryings)
	{
		pixelInputs.insert(name);
		const auto found = vertexDeclarations.find(name);
		if (found == vertexDeclarations.end())
		{
			error = "Love pixel Shader varying '" + name + "' has no matching vertex Shader output";
			return false;
		}
		if (found->second.type != type)
		{
			error = "Love Shader varying '" + name + "' has mismatched vertex/pixel types";
			return false;
		}
		if (found->second.count != count || found->second.array != array)
		{
			error = "Love Shader varying '" + name
				+ "' has mismatched vertex/pixel array sizes";
			return false;
		}
		const std::string vertexInterpolation = found->second.interpolation.empty()
			? "smooth" : found->second.interpolation;
		const std::string pixelInterpolation = interpolation.empty() ? "smooth" : interpolation;
		if (vertexInterpolation != pixelInterpolation)
		{
			error = "Love Shader varying '" + name
				+ "' has mismatched vertex/pixel interpolation qualifiers";
			return false;
		}
	}
	static constexpr std::array<std::string_view, 10> semantics = {
		"v_texcoord1", "v_texcoord2", "v_texcoord3", "v_texcoord4", "v_texcoord5",
		"v_texcoord6", "v_texcoord7", "v_color1", "v_color2", "v_color3",
	};
	std::size_t requiredSemantics = 0;
	for (const auto &[name, type, interpolation, count, array] : vertexVaryings)
	{
		DORA_UNUSED_PARAM(interpolation);
		DORA_UNUSED_PARAM(array);
		if (pixelInputs.contains(name))
		{
			const int components = loveShaderVaryingComponents(type);
			const int columns = loveShaderVaryingColumns(type);
			requiredSemantics += static_cast<std::size_t>(
				loveShaderVaryingStreams(type, components, columns) * count);
		}
	}
	if (requiredSemantics > semantics.size())
	{
		error = "Love Shader uses more custom varying semantic slots than Dora/bgfx can link";
		return false;
	}
	varyings.clear();
	std::size_t nextSemantic = 0;
	for (const auto &[name, type, interpolation, count, array] : vertexVaryings)
	{
		const int components = loveShaderVaryingComponents(type);
		const int columns = loveShaderVaryingColumns(type);
		const int streams = loveShaderVaryingStreams(type, components, columns);
		const bool pixelInput = pixelInputs.contains(name);
		std::vector<std::string> gpuNames;
		if (pixelInput)
		{
			gpuNames.reserve(static_cast<std::size_t>(streams * count));
			for (int element = 0; element < count; ++element)
				for (int stream = 0; stream < streams; ++stream)
					gpuNames.emplace_back(semantics[nextSemantic++]);
		}
		varyings.emplace(name, LoveShaderVaryingInfo{
			type, std::move(gpuNames), interpolation, components, columns,
			streams, count, array, pixelInput});
	}
	error.clear();
	return true;
}

Love::GraphicsBackend::ShaderUniformType shaderUniformType(std::string_view type)
{
	if (type == "mat2" || type == "mat3" || type == "mat4")
		return Love::GraphicsBackend::ShaderUniformType::Matrix;
	if (type == "int" || type.starts_with("ivec")) return Love::GraphicsBackend::ShaderUniformType::Int;
	if (type == "uint" || type.starts_with("uvec")) return Love::GraphicsBackend::ShaderUniformType::UInt;
	if (type == "bool" || type.starts_with("bvec")) return Love::GraphicsBackend::ShaderUniformType::Bool;
	if (type == "Image" || type == "ArrayImage" || type == "CubeImage" || type == "VolumeImage")
		return Love::GraphicsBackend::ShaderUniformType::Sampler;
	return Love::GraphicsBackend::ShaderUniformType::Float;
}

Love::GraphicsBackend::TextureType shaderTextureType(std::string_view type)
{
	if (type == "ArrayImage") return Love::GraphicsBackend::TextureType::Array;
	if (type == "CubeImage") return Love::GraphicsBackend::TextureType::Cube;
	if (type == "VolumeImage") return Love::GraphicsBackend::TextureType::Volume;
	return Love::GraphicsBackend::TextureType::Texture2D;
}

int shaderUniformComponents(std::string_view type)
{
	if (type == "mat2") return 4;
	if (type == "mat3") return 9;
	if (type == "mat4") return 16;
	if (type == "Image" || type == "ArrayImage" || type == "CubeImage" || type == "VolumeImage") return 0;
	if (type.ends_with("vec4") || type == "vec4") return 4;
	if (type.ends_with("vec3") || type == "vec3") return 3;
	if (type.ends_with("vec2") || type == "vec2") return 2;
	return 1;
}

std::string shaderMatrixValue(std::string_view gpuName, int components,
	std::string_view index = {})
{
	if (components == 4)
	{
		const std::string storage = index.empty() ? std::string(gpuName)
			: std::string(gpuName) + "[" + std::string(index) + "]";
		return "mat2(" + storage + ".xy, " + storage + ".zw)";
	}
	if (components == 9)
	{
		const std::string logical = index.empty() ? "0" : std::string(index);
		const std::string base = "(" + logical + ") * 3";
		return "mat3(" + std::string(gpuName) + "[" + base + "].xyz, "
			+ std::string(gpuName) + "[" + base + " + 1].xyz, "
			+ std::string(gpuName) + "[" + base + " + 2].xyz)";
	}
	const std::string storage = index.empty() ? std::string(gpuName)
		: std::string(gpuName) + "[" + std::string(index) + "]";
	const auto renderer = bgfx::getRendererType();
	return renderer == bgfx::RendererType::Direct3D11
		|| renderer == bgfx::RendererType::Direct3D12
		? "transpose(" + storage + ")" : storage;
}

std::string shaderUniformValue(std::string_view gpuName,
	Love::GraphicsBackend::ShaderUniformType type, int components)
{
	std::string value(gpuName);
	if (components == 1) value += ".x";
	else if (components == 2) value += ".xy";
	else if (components == 3) value += ".xyz";
	switch (type)
	{
		case Love::GraphicsBackend::ShaderUniformType::Int:
			return "floatBitsToInt(" + value + ")";
		case Love::GraphicsBackend::ShaderUniformType::UInt:
			return "floatBitsToUint(" + value + ")";
		case Love::GraphicsBackend::ShaderUniformType::Bool:
			if (components == 1) return "(" + value + " != 0.0)";
			return "notEqual(" + value + ", vec" + std::to_string(components)
				+ "_splat(0.0))";
		default: return value;
	}
}

std::string_view trimShaderText(std::string_view text)
{
	while (!text.empty() && std::isspace(static_cast<unsigned char>(text.front()))) text.remove_prefix(1);
	while (!text.empty() && std::isspace(static_cast<unsigned char>(text.back()))) text.remove_suffix(1);
	return text;
}

bool rewriteSamplerArrayCalls(std::string &body, std::string_view name,
	std::string_view helper, std::string &error)
{
	static constexpr std::array<std::string_view, 6> callNames = {
		"texture2DArray", "textureCube", "texture3D", "texture2D", "texture", "Texel"};
	std::size_t search = 0;
	while (search < body.size())
	{
		std::size_t call = std::string::npos;
		std::string_view callName;
		for (const auto candidate : callNames)
		{
			const auto found = body.find(candidate, search);
			if (found < call)
			{
				call = found;
				callName = candidate;
			}
		}
		if (call == std::string::npos) break;
		const std::size_t tokenSize = callName.size();
		if ((call > 0 && (std::isalnum(static_cast<unsigned char>(body[call - 1])) || body[call - 1] == '_'))
			|| (call + tokenSize < body.size()
				&& (std::isalnum(static_cast<unsigned char>(body[call + tokenSize])) || body[call + tokenSize] == '_')))
		{
			search = call + tokenSize;
			continue;
		}
		std::size_t open = call + tokenSize;
		while (open < body.size() && std::isspace(static_cast<unsigned char>(body[open]))) ++open;
		if (open == body.size() || body[open] != '(')
		{
			search = open;
			continue;
		}
		int round = 0;
		int square = 0;
		int curly = 0;
		std::size_t comma = std::string::npos;
		std::size_t close = std::string::npos;
		for (std::size_t cursor = open + 1; cursor < body.size(); ++cursor)
		{
			switch (body[cursor])
			{
				case '(': ++round; break;
				case ')':
					if (round == 0 && square == 0 && curly == 0) close = cursor;
					else --round;
					break;
				case '[': ++square; break;
				case ']': --square; break;
				case '{': ++curly; break;
				case '}': --curly; break;
				case ',':
					if (round == 0 && square == 0 && curly == 0 && comma == std::string::npos) comma = cursor;
					break;
			}
			if (close != std::string::npos) break;
		}
		if (close == std::string::npos)
		{
			error = "unterminated Texel call while translating Image array '" + std::string(name) + "'";
			return false;
		}
		if (comma == std::string::npos)
		{
			search = close + 1;
			continue;
		}
		const auto first = trimShaderText(std::string_view(body).substr(open + 1, comma - open - 1));
		const std::regex indexed("^" + regexEscape(name) + R"(\s*\[\s*(.+)\s*\]$)");
			std::match_results<std::string_view::const_iterator> match;
		if (!std::regex_match(first.begin(), first.end(), match, indexed))
		{
			search = close + 1;
			continue;
		}
		const auto coordinate = trimShaderText(std::string_view(body).substr(comma + 1, close - comma - 1));
		if (coordinate.empty())
		{
			error = "Texel call for Image array '" + std::string(name) + "' has no texture coordinate";
			return false;
		}
		const std::string replacement = std::string(helper) + "(" + match[1].str() + ", "
			+ std::string(coordinate) + ")";
		body.replace(call, close - call + 1, replacement);
		search = call + replacement.size();
	}
	if (std::regex_search(body, std::regex("\\b" + regexEscape(name) + "\\b")))
	{
		error = "Image array '" + std::string(name)
			+ "' is currently supported only as Texel(array[index], coordinates)";
		return false;
	}
	return true;
}

void rewriteLoveSingleArgumentConstructors(std::string &text,
	std::set<std::string> &constructors)
{
	static const std::set<std::string_view> supported = {
		"vec2", "vec3", "vec4", "ivec2", "ivec3", "ivec4",
		"uvec2", "uvec3", "uvec4", "bvec2", "bvec3", "bvec4",
		"mat2", "mat3", "mat4"};
	std::size_t cursor = 0;
	while (cursor < text.size())
	{
		if (!(std::isalpha(static_cast<unsigned char>(text[cursor])) || text[cursor] == '_'))
		{
			++cursor;
			continue;
		}
		const std::size_t tokenStart = cursor++;
		while (cursor < text.size()
			&& (std::isalnum(static_cast<unsigned char>(text[cursor])) || text[cursor] == '_'))
			++cursor;
		const std::string type = text.substr(tokenStart, cursor - tokenStart);
		if (!supported.contains(type)) continue;
		std::size_t open = cursor;
		while (open < text.size() && std::isspace(static_cast<unsigned char>(text[open]))) ++open;
		if (open == text.size() || text[open] != '(') continue;
		int depth = 0;
		bool multipleArguments = false;
		std::size_t close = std::string::npos;
		for (std::size_t index = open + 1; index < text.size(); ++index)
		{
			if (text[index] == '(') ++depth;
			else if (text[index] == ')')
			{
				if (depth == 0) { close = index; break; }
				--depth;
			}
			else if (text[index] == ',' && depth == 0) multipleArguments = true;
		}
		if (close == std::string::npos || multipleArguments) continue;
		if (type.starts_with("mat"))
		{
			const std::string argument(trimShaderText(std::string_view(text).substr(
				open + 1, close - open - 1)));
			static const std::regex scalarLiteral(
				R"(^[+-]?(?:(?:[0-9]+(?:\.[0-9]*)?)|(?:\.[0-9]+))(?:[eE][+-]?[0-9]+)?[fF]?$)");
			if (!std::regex_match(argument, scalarLiteral)) continue;
			const int dimensions = type.back() - '0';
			std::string replacement = type + "(";
			for (int column = 0; column < dimensions; ++column)
			{
				if (column != 0) replacement += ", ";
				replacement += "vec" + std::to_string(dimensions) + "(";
				for (int row = 0; row < dimensions; ++row)
				{
					if (row != 0) replacement += ", ";
					replacement += row == column ? argument : "0.0";
				}
				replacement += ")";
			}
			replacement += ")";
			text.replace(tokenStart, close - tokenStart + 1, replacement);
			cursor = tokenStart + replacement.size();
			continue;
		}
		constructors.insert(type);
		const std::string helper = "love_" + type + "_ctor";
		text.replace(tokenStart, type.size(), helper);
		cursor = tokenStart + helper.size();
	}
}

std::string loveSingleArgumentConstructorHelpers(const std::set<std::string> &constructors)
{
	std::string helpers;
	for (const auto &type : constructors)
	{
		const bool matrix = type.starts_with("mat");
		const int dimensions = type.back() - '0';
		if (matrix)
		{
			helpers += type + " love_" + type + "_ctor(float value) { return " + type + "(";
			for (int column = 0; column < dimensions; ++column)
			{
				for (int row = 0; row < dimensions; ++row)
				{
					if (column != 0 || row != 0) helpers += ", ";
					helpers += row == column ? "value" : "0.0";
				}
			}
			helpers += "); }\n";
			helpers += type + " love_" + type + "_ctor(" + type
				+ " value) { return value; }\n";
			continue;
		}
		const std::string scalar = type.starts_with("ivec") ? "int"
			: type.starts_with("uvec") ? "uint"
			: type.starts_with("bvec") ? "bool" : "float";
		helpers += type + " love_" + type + "_ctor(" + scalar + " value) { return "
			+ type + "(";
		for (int component = 0; component < dimensions; ++component)
		{
			if (component != 0) helpers += ", ";
			helpers += "value";
		}
		helpers += "); }\n";
		for (int sourceDimensions = dimensions; sourceDimensions <= 4; ++sourceDimensions)
		{
			const std::string sourceType = type.substr(0, type.size() - 1)
				+ std::to_string(sourceDimensions);
			helpers += type + " love_" + type + "_ctor(" + sourceType
				+ " value) { return ";
			if (sourceDimensions == dimensions) helpers += "value";
			else helpers += "value." + std::string("xyzw", static_cast<std::size_t>(dimensions));
			helpers += "; }\n";
		}
	}
	return helpers;
}

bool translateLoveShaderStage(std::string_view source, bool vertex,
	LoveShaderLanguage language, const LoveShaderVaryingMap &varyingMap,
	LoveShaderTranslation &translated, std::string &error, bool instanced = false,
	std::optional<Love::GraphicsBackend::TextureType> mainTextureType = std::nullopt)
{
	std::string body(source);
	if (vertex && language != LoveShaderLanguage::GLSL3
		&& (body.find("love_VertexID") != std::string::npos
			|| body.find("love_InstanceID") != std::string::npos))
	{
		error = "love_VertexID and love_InstanceID require #pragma language glsl3";
		return false;
	}
	// `texture` is a legal and very common Love effect parameter name, but it is
	// a reserved token in the HLSL emitted by bgfx shaderc. Rename the identifier
	// before cross-compilation while preserving texture2D and other longer names.
	if (!vertex)
		body = std::regex_replace(body, std::regex(R"(\btexture\b(?!\s*\())"), "loveTexture");
	translated.uniforms.clear();
	translated.attributes.clear();
	translated.warnings.clear();
	translated.diagnosticLines.clear();
	translated.colorOutputs = 1;
	translated.usesInstanceID = vertex
		&& body.find("love_InstanceID") != std::string::npos;
	translated.usesVertexID = vertex
		&& body.find("love_VertexID") != std::string::npos;
	translated.mainTextureType = vertex ? mainTextureType : std::nullopt;
	translated.mainTextureLayerSemantic = bgfx::Attrib::Count;
	if (translated.usesInstanceID)
		body = std::regex_replace(body, std::regex(R"(\blove_InstanceID\b)"), "loveInstanceID");
	if (translated.usesVertexID)
		body = std::regex_replace(body, std::regex(R"(\blove_VertexID\b)"), "loveVertexID");
	const std::regex varyingPattern(language == LoveShaderLanguage::GLSL3
		? (vertex
			? R"(\b((?:(?:flat|smooth|noperspective|centroid)\s+)*)(?:varying|out)\s+(?:(?:lowp|mediump|highp)\s+)?(float|vec2|vec3|vec4|mat2|mat3|mat4|int|ivec2|ivec3|ivec4|uint|uvec2|uvec3|uvec4|bool|bvec2|bvec3|bvec4)\s+((?:[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)*)\s*;)"
			: R"(\b((?:(?:flat|smooth|noperspective|centroid)\s+)*)(?:varying|in)\s+(?:(?:lowp|mediump|highp)\s+)?(float|vec2|vec3|vec4|mat2|mat3|mat4|int|ivec2|ivec3|ivec4|uint|uvec2|uvec3|uvec4|bool|bvec2|bvec3|bvec4)\s+((?:[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*(?:\s*\[\s*[0-9]+\s*\])?)*)\s*;)")
		: R"(\bvarying\s+(?:(?:lowp|mediump|highp)\s+)?(float|vec2|vec3|vec4|mat2|mat3|mat4)\s+((?:[A-Za-z_][A-Za-z0-9_]*)(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*)\s*;)");
	const std::regex varyingDeclaratorPattern(language == LoveShaderLanguage::GLSL3
		? R"(([A-Za-z_][A-Za-z0-9_]*)(?:\s*\[\s*([0-9]+)\s*\])?)"
		: R"(([A-Za-z_][A-Za-z0-9_]*))");
	std::vector<std::string> localVaryings;
	std::unordered_set<std::string> localVaryingNames;
	for (std::sregex_iterator it(body.begin(), body.end(), varyingPattern), end; it != end; ++it)
	{
		const std::string declarators = (*it)[language == LoveShaderLanguage::GLSL3 ? 3 : 2].str();
		for (std::sregex_iterator declaratorIt(declarators.begin(), declarators.end(),
				varyingDeclaratorPattern), declaratorEnd; declaratorIt != declaratorEnd;
			++declaratorIt)
		{
			const std::string name = (*declaratorIt)[1].str();
			localVaryings.push_back(name);
			localVaryingNames.insert(name);
		}
	}
	blankShaderMatchesPreservingLines(body, varyingPattern);
	std::string customInputs;
	std::string customPositionParameters;
	std::string customPositionArguments;
	std::string customVaryingStreams;
	std::string customVaryingParameters;
	std::string customVaryingArguments;
	std::string customVaryingLocals;
	std::string customVaryingStores;
	std::string vertexIDArgument;
	if (vertex)
	{
		const std::regex attributePattern(language == LoveShaderLanguage::GLSL3
			? R"((?:\blayout\s*\(\s*location\s*=\s*([0-9]+)\s*\)\s*)?\b(?:attribute|in)\s+(?:(?:lowp|mediump|highp)\s+)?(float|vec2|vec3|vec4)\s+([A-Za-z_][A-Za-z0-9_]*)\s*;)"
			: R"(\battribute\s+(float|vec2|vec3|vec4)\s+([A-Za-z_][A-Za-z0-9_]*)\s*;)");
		struct ParsedAttribute
		{
			std::string type;
			std::string name;
			int location = -1;
		};
		std::vector<ParsedAttribute> parsedAttributes;
		std::unordered_set<std::string> declaredNames;
		for (std::sregex_iterator it(body.begin(), body.end(), attributePattern), end; it != end; ++it)
		{
			const std::size_t typeGroup = language == LoveShaderLanguage::GLSL3 ? 2 : 1;
			const std::size_t nameGroup = language == LoveShaderLanguage::GLSL3 ? 3 : 2;
			const std::string name = (*it)[nameGroup].str();
			if (!declaredNames.insert(name).second)
			{
				error = "duplicate Love Shader vertex attribute '" + name + "'";
				return false;
			}
			int location = -1;
			if (language == LoveShaderLanguage::GLSL3 && (*it)[1].matched)
			{
				const std::string locationText = (*it)[1].str();
				const auto result = std::from_chars(locationText.data(),
					locationText.data() + locationText.size(), location);
				if (result.ec != std::errc{})
				{
					error = "invalid Love Shader vertex attribute layout location";
					return false;
				}
			}
			parsedAttributes.push_back({(*it)[typeGroup].str(), name, location});
		}
		blankShaderMatchesPreservingLines(body, attributePattern);
		static constexpr std::array<std::pair<bgfx::Attrib::Enum, std::string_view>, 15> semantics = {{
			{bgfx::Attrib::TexCoord1, "a_texcoord1"}, {bgfx::Attrib::TexCoord2, "a_texcoord2"},
			{bgfx::Attrib::TexCoord3, "a_texcoord3"}, {bgfx::Attrib::TexCoord4, "a_texcoord4"},
			{bgfx::Attrib::TexCoord5, "a_texcoord5"}, {bgfx::Attrib::TexCoord6, "a_texcoord6"},
			{bgfx::Attrib::TexCoord7, "a_texcoord7"}, {bgfx::Attrib::Color1, "a_color1"},
			{bgfx::Attrib::Color2, "a_color2"}, {bgfx::Attrib::Color3, "a_color3"},
			{bgfx::Attrib::Normal, "a_normal"}, {bgfx::Attrib::Tangent, "a_tangent"},
			{bgfx::Attrib::Bitangent, "a_bitangent"}, {bgfx::Attrib::Indices, "a_indices"},
			{bgfx::Attrib::Weight, "a_weight"},
		}};
		static constexpr std::array<std::pair<bgfx::Attrib::Enum, std::string_view>, 10>
			instancedSemantics = {{
				{bgfx::Attrib::TexCoord1, "a_texcoord1"}, {bgfx::Attrib::TexCoord2, "a_texcoord2"},
				{bgfx::Attrib::Color1, "a_color1"}, {bgfx::Attrib::Color2, "a_color2"},
				{bgfx::Attrib::Color3, "a_color3"}, {bgfx::Attrib::Normal, "a_normal"},
				{bgfx::Attrib::Tangent, "a_tangent"}, {bgfx::Attrib::Bitangent, "a_bitangent"},
				{bgfx::Attrib::Indices, "a_indices"}, {bgfx::Attrib::Weight, "a_weight"},
		}};
		std::size_t nextSemantic = 0;
		std::unordered_map<int, std::string> activeLayoutLocations;
		if (mainTextureType == Love::GraphicsBackend::TextureType::Array)
		{
			const auto [semantic, gpuName] = instanced
				? instancedSemantics[nextSemantic++] : semantics[nextSemantic++];
			translated.mainTextureLayerSemantic = semantic;
			customInputs += ", " + std::string(gpuName);
		}
		int nextSelectorIndex = 3;
		for (const auto &[type, name, location] : parsedAttributes)
		{
			if (name == "VertexPosition" || name == "VertexTexCoord"
				|| name == "VertexColor" || name == "ConstantColor")
			{
				if (location >= 0)
				{
					error = "Love Shader cannot apply layout(location) to a built-in vertex attribute";
					return false;
				}
				continue;
			}
			if (localVaryingNames.contains(name))
			{
				error = "Love vertex Shader name '" + name
					+ "' is used by both an attribute and a varying";
				return false;
			}
			const std::regex identifier("\\b" + regexEscape(name) + "\\b");
			if (!std::regex_search(body, identifier))
			{
				translated.warnings += "unused Love vertex Shader attribute '" + name
					+ "' was omitted by the Dora translator\n";
				continue;
			}
			if (location >= 0)
			{
				if (location < 4 || location > 15)
				{
					error = "Love Shader vertex attribute '" + name
						+ "' layout location must be between 4 and 15";
					return false;
				}
				const auto [found, inserted] = activeLayoutLocations.emplace(location, name);
				if (!inserted)
				{
					error = "Love Shader vertex attributes '" + found->second + "' and '"
						+ name + "' use the same active layout location";
					return false;
				}
			}
			const std::size_t semanticCount = instanced ? instancedSemantics.size() : semantics.size();
			if (nextSemantic >= semanticCount)
			{
				error = "Love Shader uses more custom vertex attributes than Dora/bgfx can bind";
				return false;
			}
			const int components = type == "float" ? 1
				: type == "vec2" ? 2 : type == "vec3" ? 3 : 4;
			const auto [semantic, gpuNameView] = instanced
				? instancedSemantics[nextSemantic++] : semantics[nextSemantic++];
			const std::string gpuName(gpuNameView);
			const int selectorIndex = nextSelectorIndex++;
			const std::string selector = "u_loveInstanceSelectors["
				+ std::to_string(selectorIndex / 4) + "]."
				+ std::string(1, "xyzw"[selectorIndex % 4]);
			const std::string selected = instanced
				? "loveInstanceAttribute(" + gpuName + ", " + selector
					+ ", i_data0, i_data1, i_data2, i_data3, i_data4)" : gpuName;
			const std::string expression = components == 1 ? selected + ".x"
				: components == 2 ? selected + ".xy" : components == 3 ? selected + ".xyz" : selected;
			translated.attributes.emplace(name,
				LoveShaderAttributeInfo{gpuName, semantic, components, selectorIndex});
			customInputs += ", " + gpuName;
			customPositionParameters += ", " + type + " " + name;
			customPositionArguments += ", " + expression;
		}
		if (translated.usesVertexID)
		{
			const std::size_t semanticCount = instanced ? instancedSemantics.size() : semantics.size();
			if (nextSemantic >= semanticCount)
			{
				error = "Love Shader has no remaining vertex attribute semantic for love_VertexID";
				return false;
			}
			const auto [semantic, gpuNameView] = instanced
				? instancedSemantics[nextSemantic++] : semantics[nextSemantic++];
			translated.vertexIDSemantic = semantic;
			const std::string gpuName(gpuNameView);
			customInputs += ", " + gpuName;
			vertexIDArgument = "int(" + gpuName + ".x)";
		}
		if (instanced) customInputs += ", i_data0, i_data1, i_data2, i_data3, i_data4";
	}
	static const std::regex uniformPattern(
		R"(\b(?:extern|uniform)\s+(number|float|vec2|vec3|vec4|mat2|mat3|mat4|int|ivec2|ivec3|ivec4|uint|uvec2|uvec3|uvec4|bool|bvec2|bvec3|bvec4|Image|ArrayImage|CubeImage|VolumeImage)\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s*\[\s*([0-9]+)\s*\])?\s*;)");
	struct ParsedUniform
	{
		std::string sourceType;
		std::string name;
		std::string gpuName;
		Love::GraphicsBackend::ShaderUniformType type;
		Love::GraphicsBackend::TextureType textureType;
		int components = 1;
		int count = 1;
	};
	std::vector<ParsedUniform> uniforms;
	for (std::sregex_iterator it(body.begin(), body.end(), uniformPattern), end; it != end; ++it)
	{
		const std::string sourceType = (*it)[1].str();
		const std::string name = (*it)[2].str();
		int count = 1;
		if ((*it)[3].matched)
		{
			const std::string countText = (*it)[3].str();
			const auto result = std::from_chars(countText.data(), countText.data() + countText.size(), count);
			if (result.ec != std::errc{} || count <= 0 || count > 1024)
			{
				error = "Love Shader uniform array '" + name + "' must contain 1 to 1024 elements";
				return false;
			}
		}
		const std::string gpuName = "u_love_" + name;
		uniforms.push_back({sourceType, name, gpuName, shaderUniformType(sourceType), shaderTextureType(sourceType),
			shaderUniformComponents(sourceType), count});
	}
	blankShaderMatchesPreservingLines(body, uniformPattern);
	for (const std::string &name : localVaryings)
	{
		const auto found = varyingMap.find(name);
		if (found == varyingMap.end())
		{
			error = "internal Love Shader varying mapping is missing '" + name + "'";
			return false;
		}
		const auto &varying = found->second;
		const std::string parameter = "loveVarying_" + name;
		body = std::regex_replace(body, std::regex("\\b" + regexEscape(name) + "\\b"), parameter);
		customVaryingParameters += ", " + std::string(vertex ? "inout " : "")
			+ varying.type + " " + parameter;
		if (varying.array)
			customVaryingParameters += "[" + std::to_string(varying.count) + "]";
		if (varying.pixelInput)
		{
			for (const std::string &gpuName : varying.gpuNames)
				customVaryingStreams += ", " + gpuName;
			if (varying.array)
			{
				const std::string local = "loveVaryingLocal_" + name;
				customVaryingLocals += varying.type + " " + local + "["
					+ std::to_string(varying.count) + "]; ";
				for (int element = 0; element < varying.count; ++element)
				{
					const std::size_t first = static_cast<std::size_t>(element * varying.streams);
					if (vertex)
					{
						customVaryingLocals += local + "[" + std::to_string(element) + "] = "
							+ loveShaderVaryingZeroValue(varying.type, varying.components) + "; ";
					}
					else
					{
						customVaryingLocals += local + "[" + std::to_string(element) + "] = "
							+ loveShaderVaryingValue(varying, first) + "; ";
					}
					if (vertex)
					{
						for (int stream = 0; stream < varying.streams; ++stream)
						{
							const std::size_t gpuStream = first + static_cast<std::size_t>(stream);
							const std::string value = varying.columns == 1
								|| isLoveShaderNonFloatVaryingType(varying.type)
								? local + "[" + std::to_string(element) + "]"
								: local + "[" + std::to_string(element) + "][" + std::to_string(stream) + "]";
							customVaryingStores += varying.gpuNames[gpuStream] + " = "
								+ loveShaderVaryingPackedColumn(value,
									varying.type, varying.components, stream) + "; ";
						}
					}
				}
				customVaryingArguments += ", " + local;
			}
			else if (vertex && (varying.columns > 1
				|| isLoveShaderNonFloatVaryingType(varying.type)))
			{
				const std::string local = "loveVaryingLocal_" + name;
				customVaryingLocals += varying.type + " " + local + " = "
					+ loveShaderVaryingZeroValue(varying.type, varying.components) + "; ";
				customVaryingArguments += ", " + local;
				for (int stream = 0; stream < varying.streams; ++stream)
				{
					const std::string value = varying.columns == 1
						|| isLoveShaderNonFloatVaryingType(varying.type) ? local
						: local + "[" + std::to_string(stream) + "]";
					customVaryingStores += varying.gpuNames[static_cast<std::size_t>(stream)] + " = "
						+ loveShaderVaryingPackedColumn(value,
							varying.type, varying.components, stream) + "; ";
				}
			}
			else customVaryingArguments += ", " + loveShaderVaryingValue(varying);
		}
		else if (vertex)
		{
			const std::string local = "loveVaryingLocal_" + name;
			customVaryingLocals += varying.type + " " + local;
			if (varying.array)
			{
				customVaryingLocals += "[" + std::to_string(varying.count) + "]; ";
				for (int element = 0; element < varying.count; ++element)
					customVaryingLocals += local + "[" + std::to_string(element) + "] = "
						+ loveShaderVaryingZeroValue(varying.type, varying.components) + "; ";
			}
			else customVaryingLocals += " = "
				+ loveShaderVaryingZeroValue(varying.type, varying.components) + "; ";
			customVaryingArguments += ", " + local;
		}
	}
	std::string declarations;
	int nextSamplerSlot = 1;
	for (const auto &uniform : uniforms)
	{
		const auto &[sourceType, name, gpuName, type, textureType, components, count] = uniform;
		if (translated.attributes.contains(name))
		{
			error = "Love Shader name '" + name + "' is used by both a vertex attribute and a uniform";
			return false;
		}
		if (localVaryingNames.contains(name))
		{
			error = "Love Shader name '" + name + "' is used by both a varying and a uniform";
			return false;
		}
		const std::regex identifier("\\b" + regexEscape(name) + "\\b");
		if (!std::regex_search(body, identifier))
		{
			translated.warnings += "unused Love " + std::string(vertex ? "vertex" : "pixel")
				+ " Shader uniform '" + name + "' was omitted by the Dora translator\n";
			continue;
		}
		if (type == Love::GraphicsBackend::ShaderUniformType::Sampler && vertex)
		{
			error = "Dora's current Love Shader subset supports Image uniforms only in pixel effects";
			return false;
		}
		const bool mainTexture = !vertex && name == "MainTex";
		if (mainTexture)
		{
			if (type != Love::GraphicsBackend::ShaderUniformType::Sampler || count != 1)
			{
				error = "Love Shader MainTex must be one Image, ArrayImage, CubeImage, or VolumeImage";
				return false;
			}
			if (textureType != Love::GraphicsBackend::TextureType::Texture2D
				&& textureType != Love::GraphicsBackend::TextureType::Array)
			{
				error = "Dora's current Love Shader main drawable supports Image or ArrayImage MainTex";
				return false;
			}
			if (translated.mainTextureType)
			{
				error = "duplicate Love Shader MainTex declaration";
				return false;
			}
			translated.mainTextureType = textureType;
			const std::string sampleFunction = textureType == Love::GraphicsBackend::TextureType::Array
				? "texture2DArray" : textureType == Love::GraphicsBackend::TextureType::Cube
				? "textureCube" : textureType == Love::GraphicsBackend::TextureType::Volume
				? "texture3D" : "texture2D";
			const std::regex lodCall("\\btextureLod\\s*\\(\\s*" + regexEscape(name) + "\\b");
			body = std::regex_replace(body, lodCall, sampleFunction + "Lod(" + name);
			const std::regex call("\\b(?:Texel|texture)\\s*\\(\\s*" + regexEscape(name) + "\\b");
			body = std::regex_replace(body, call, sampleFunction + "(" + name);
			body = std::regex_replace(body, identifier, "s_texColor");
			translated.uniforms.emplace(name, LoveShaderUniformInfo{
				"s_texColor", type, textureType, components, 1, 0});
			continue;
		}
		const int samplerSlot = type == Love::GraphicsBackend::ShaderUniformType::Sampler ? nextSamplerSlot : 0;
		if (type == Love::GraphicsBackend::ShaderUniformType::Sampler) nextSamplerSlot += count;
		if (samplerSlot != 0 && samplerSlot + count > 16)
		{
			error = "Love Shader uses more than 15 additional Image uniforms";
			return false;
		}
		if (!translated.uniforms.emplace(name, LoveShaderUniformInfo{gpuName, type, textureType, components, count, samplerSlot}).second)
		{
			error = "duplicate Love Shader uniform '" + name + "'";
			return false;
		}
		if (type == Love::GraphicsBackend::ShaderUniformType::Sampler)
		{
			const std::string sampleFunction = textureType == Love::GraphicsBackend::TextureType::Array
				? "texture2DArray" : textureType == Love::GraphicsBackend::TextureType::Cube
				? "textureCube" : textureType == Love::GraphicsBackend::TextureType::Volume
				? "texture3D" : "texture2D";
			if (count > 1)
			{
				const std::string helper = "love_texel_" + name;
				if (!rewriteSamplerArrayCalls(body, name, helper, error)) return false;
				const std::string coordinateType
					= textureType == Love::GraphicsBackend::TextureType::Texture2D ? "vec2" : "vec3";
				declarations += "vec4 " + helper + "(int index, " + coordinateType
					+ " coordinates) {\n";
				for (int index = 0; index < count - 1; ++index)
					declarations += "\tif (index == " + std::to_string(index) + ") return "
						+ sampleFunction + "(" + gpuName + "_" + std::to_string(index)
						+ ", coordinates);\n";
				declarations += "\treturn " + sampleFunction + "(" + gpuName + "_"
					+ std::to_string(count - 1) + ", coordinates);\n}\n";
			}
			else
			{
				const std::regex lodCall("\\btextureLod\\s*\\(\\s*" + regexEscape(name) + "\\b");
				body = std::regex_replace(body, lodCall, sampleFunction + "Lod(" + gpuName);
				const std::regex call("\\b(?:Texel|texture)\\s*\\(\\s*" + regexEscape(name) + "\\b");
				body = std::regex_replace(body, call, sampleFunction + "(" + gpuName);
			}
		}
		else if (count > 1)
		{
			const std::string helper = "love_get_" + name;
			const std::regex access("\\b" + regexEscape(name) + R"(\s*\[\s*([^\[\]]+)\s*\])");
			body = std::regex_replace(body, access, helper + "($1)");
			std::string returnType = sourceType == "number" ? "float" : sourceType;
			declarations += returnType + " " + helper + "(int index) { return "
				+ (type == Love::GraphicsBackend::ShaderUniformType::Matrix
					? shaderMatrixValue(gpuName, components, "index")
					: shaderUniformValue(gpuName + "[index]", type, components)) + "; }\n";
		}
		else body = std::regex_replace(body, identifier,
			type == Love::GraphicsBackend::ShaderUniformType::Matrix
				? shaderMatrixValue(gpuName, components)
				: shaderUniformValue(gpuName, type, components));
		std::string uniformDeclaration;
		if (type == Love::GraphicsBackend::ShaderUniformType::Sampler)
		{
			for (int index = 0; index < count; ++index)
				uniformDeclaration += (textureType == Love::GraphicsBackend::TextureType::Array ? "SAMPLER2DARRAY("
					: textureType == Love::GraphicsBackend::TextureType::Cube ? "SAMPLERCUBE("
					: textureType == Love::GraphicsBackend::TextureType::Volume ? "SAMPLER3D(" : "SAMPLER2D(") + gpuName
					+ (count > 1 ? "_" + std::to_string(index) : "") + ", "
					+ std::to_string(samplerSlot + index) + ");\n";
		}
		else if (type == Love::GraphicsBackend::ShaderUniformType::Matrix && components == 16)
			uniformDeclaration = "uniform mat4 " + gpuName
				+ (count > 1 ? "[" + std::to_string(count) + "]" : "") + ";\n";
		else if (type == Love::GraphicsBackend::ShaderUniformType::Matrix && components == 9)
			uniformDeclaration = "uniform vec4 " + gpuName + "["
				+ std::to_string(count * 3) + "];\n";
		else uniformDeclaration = "uniform vec4 " + gpuName
			+ (count > 1 ? "[" + std::to_string(count) + "]" : "") + ";\n";
		declarations = uniformDeclaration
			+ declarations;
	}
	if (language == LoveShaderLanguage::GLSL3 && !vertex)
		body = std::regex_replace(body, std::regex(R"(\btexture\s*\()"), "texture2D(");
	std::set<std::string> singleArgumentConstructors;
	rewriteLoveSingleArgumentConstructors(body, singleArgumentConstructors);
	rewriteLoveSingleArgumentConstructors(declarations, singleArgumentConstructors);
	rewriteLoveSingleArgumentConstructors(customVaryingLocals, singleArgumentConstructors);
	rewriteLoveSingleArgumentConstructors(customVaryingStores, singleArgumentConstructors);
	const std::string constructorHelpers
		= loveSingleArgumentConstructorHelpers(singleArgumentConstructors);
	static constexpr std::string_view common = R"sc(
#include <bgfx_shader.sh>
#define number float
#define Image sampler2D
#define ArrayImage sampler2DArray
#define CubeImage samplerCube
#define VolumeImage sampler3D
#define Texel texture2D
#define VaryingColor v_color0
)sc";
	const std::string varyingTexCoordMacro
		= translated.mainTextureType == Love::GraphicsBackend::TextureType::Array
		? "#define VaryingTexCoord vec4(v_texcoord0, v_texcoord1.x, 1.0)\n"
		: "#define VaryingTexCoord vec4(v_texcoord0, 0.0, 1.0)\n";
	if (vertex)
	{
		if (!source.empty() && source.find("position") == std::string_view::npos)
		{
			error = "Love vertex Shader is missing its position function";
			return false;
		}
		if (body.empty())
			body = "vec4 position(mat4 transform, vec4 vertex) { return transform * vertex; }";
		static const std::regex positionDeclaration(R"((\bvec4\s+position\s*\()([^\)]*)(\)))");
		std::smatch positionMatch;
		if (!std::regex_search(body, positionMatch, positionDeclaration))
		{
			error = "Love vertex Shader position function has an unsupported declaration";
			return false;
		}
		static const std::regex positionBaseParameters(
			R"(^\s*mat4\s+([A-Za-z_][A-Za-z0-9_]*)\s*,\s*vec4\s+([A-Za-z_][A-Za-z0-9_]*)\s*$)");
		std::smatch parameterMatch;
		const std::string baseParameters = positionMatch[2].str();
		if (!std::regex_match(baseParameters, parameterMatch, positionBaseParameters))
		{
			error = "Love vertex Shader position function must accept mat4 and vec4 parameters";
			return false;
		}
		const std::string transformName = parameterMatch[1].str();
		const std::string vertexName = parameterMatch[2].str();
		body = std::regex_replace(body, std::regex("\\b" + regexEscape(transformName)
			+ "\\s*\\*\\s*" + regexEscape(vertexName) + "\\b"),
			"mul(" + transformName + ", " + vertexName + ")");
		body = std::regex_replace(body, positionDeclaration,
			"$1$2, vec4 loveVertexPosition, vec4 loveVertexTexCoord, vec4 loveVertexColor"
				+ customPositionParameters + customVaryingParameters
				+ (translated.usesVertexID ? ", int loveVertexID" : "")
				+ (translated.usesInstanceID ? ", int loveInstanceID" : "") + "$3",
			std::regex_constants::format_first_only);
		const std::string instanceSupport = instanced ? R"sc(
uniform vec4 u_loveInstanceSelectors[5];
vec4 loveInstanceAttribute(vec4 vertexValue, float selector,
	vec4 data0, vec4 data1, vec4 data2, vec4 data3, vec4 data4) {
	if (selector < 0.5) return vertexValue;
	if (selector < 1.5) return data0;
	if (selector < 2.5) return data1;
	if (selector < 3.5) return data2;
	if (selector < 4.5) return data3;
	return data4;
}
)sc" : "";
		const std::string positionValue = instanced
			? "loveInstanceAttribute(a_position, u_loveInstanceSelectors[0].x, i_data0, i_data1, i_data2, i_data3, i_data4)" : "a_position";
		const std::string baseTexcoordValue = instanced
			? "loveInstanceAttribute(vec4(a_texcoord0, 0.0, 1.0), u_loveInstanceSelectors[0].y, i_data0, i_data1, i_data2, i_data3, i_data4)"
			: "vec4(a_texcoord0, 0.0, 1.0)";
		const std::string texcoordValue = mainTextureType == Love::GraphicsBackend::TextureType::Array
			? "vec4(" + baseTexcoordValue + ".xy, a_texcoord1.x, 1.0)" : baseTexcoordValue;
		const std::string colorValue = instanced
			? "loveInstanceAttribute(a_color0, u_loveInstanceSelectors[0].z, i_data0, i_data1, i_data2, i_data3, i_data4)" : "a_color0";
		const std::string varyingTexCoord = texcoordValue + ".xy";
		const std::string arrayLayerOutput = mainTextureType == Love::GraphicsBackend::TextureType::Array
			? " v_texcoord1 = vec4(a_texcoord1.x, 0.0, 0.0, 1.0);" : "";
		translated.source = "$input a_position, a_texcoord0, a_color0" + customInputs + "\n"
			"$output v_color0, v_texcoord0"
			+ (mainTextureType == Love::GraphicsBackend::TextureType::Array ? ", v_texcoord1" : "")
			+ customVaryingStreams + "\n" + std::string(common)
			+ varyingTexCoordMacro
			+ "uniform mat4 u_loveTransform;\n" + instanceSupport + declarations
			+ constructorHelpers
			+ "#define VertexPosition loveVertexPosition\n#define VertexTexCoord loveVertexTexCoord\n"
			  "#define VertexColor loveVertexColor\n#define ConstantColor vec4_splat(1.0)\n"
			+ "#line 1\n" + body
			+ "\n#line 100000\nvoid main() { " + customVaryingLocals
			  + "v_color0 = " + colorValue + "; v_texcoord0 = " + varyingTexCoord + ";"
			  + arrayLayerOutput + " "
			  "gl_Position = position(u_loveTransform, " + positionValue + ", " + positionValue + ", "
			  + texcoordValue + ", " + colorValue + customPositionArguments
			  + customVaryingArguments
			  + (translated.usesVertexID ? ", " + vertexIDArgument : "")
			  + (translated.usesInstanceID ? (instanced ? ", gl_InstanceID" : ", 0") : "")
			  + "); " + customVaryingStores + "}\n";
	}
	else
	{
		static const std::regex standardEffect(R"((\bvec4\s+effect\s*\()([^\)]*)(\)))");
		static const std::regex customEffect(R"(\bvoid\s+effect\s*\(\s*\))");
		const bool custom = !source.empty() && std::regex_search(body, customEffect);
		if (!custom && !translated.mainTextureType)
			translated.mainTextureType = Love::GraphicsBackend::TextureType::Texture2D;
		if (!source.empty() && !custom && !std::regex_search(body, standardEffect))
		{
			error = "Dora supports either the standard vec4 Love pixel effect or a void effect() using love_Canvases";
			return false;
		}
		if (body.empty())
			body = "vec4 effect(vec4 color, Image loveTexture, vec2 uv, vec2 screen) { return Texel(loveTexture, uv) * color; }";
		if (!custom && !customVaryingParameters.empty())
			body = std::regex_replace(body, standardEffect,
				"$1$2" + customVaryingParameters + "$3", std::regex_constants::format_first_only);
		if (custom)
		{
			static const std::regex canvasAccess(R"(\blove_Canvases\s*\[\s*([^\]]+)\s*\])");
			bool foundOutput = false;
			for (std::sregex_iterator it(body.begin(), body.end(), canvasAccess), end; it != end; ++it)
			{
				const std::string indexText = std::string(trimShaderText((*it)[1].str()));
				int index = -1;
				const auto parsed = std::from_chars(indexText.data(), indexText.data() + indexText.size(), index);
				if (parsed.ec != std::errc{} || parsed.ptr != indexText.data() + indexText.size() || index < 0)
				{
					error = "love_Canvases currently requires a non-negative constant output index";
					return false;
				}
				if (index >= 8)
				{
					error = "love_Canvases output index exceeds Dora/bgfx's maximum of 7";
					return false;
				}
				translated.colorOutputs = std::max(translated.colorOutputs, index + 1);
				foundOutput = true;
			}
			if (!foundOutput && !std::regex_search(body, std::regex(R"(\blove_PixelColor\b)")))
			{
				error = "void Love pixel effect() must write love_PixelColor or at least one love_Canvases output";
				return false;
			}
			for (int index = 0; index < translated.colorOutputs; ++index)
			{
				const std::regex outputAccess("\\blove_Canvases\\s*\\[\\s*"
					+ std::to_string(index) + "\\s*\\]");
				body = std::regex_replace(body, outputAccess,
					"love_CanvasOutput" + std::to_string(index));
			}
			std::string outputParameters;
			for (int index = 0; index < translated.colorOutputs; ++index)
			{
				if (index != 0) outputParameters += ", ";
				outputParameters += "inout vec4 love_CanvasOutput" + std::to_string(index);
			}
			outputParameters += ", vec4 v_color0, vec2 v_texcoord0";
			if (translated.mainTextureType == Love::GraphicsBackend::TextureType::Array)
				outputParameters += ", vec4 v_texcoord1";
			body = std::regex_replace(body, customEffect,
				"void effect(" + outputParameters
					+ customVaryingParameters + ")");
		}
		else if (std::regex_search(body, std::regex(R"(\blove_Canvases\b)")))
		{
			error = "love_Canvases requires the custom void effect() pixel entry point";
			return false;
		}
		const std::string pixelCommon = custom
			? "#define love_PixelColor love_CanvasOutput0\n"
			: "#define love_PixelColor gl_FragColor\n";
		std::string customMain = "\nvoid main() { " + customVaryingLocals;
		if (custom)
		{
			for (int index = 0; index < translated.colorOutputs; ++index)
			{
				const std::string output = "love_CanvasOutput" + std::to_string(index);
				// bgfx shader syntax maps vec4 to float4 for Direct3D, whose
				// constructor does not accept a single scalar. vec4_splat is the
				// portable helper used by shaderc for GLSL, Metal and HLSL.
				customMain += "vec4 " + output + " = vec4_splat(0.0); ";
			}
			customMain += "effect(";
			for (int index = 0; index < translated.colorOutputs; ++index)
			{
				if (index != 0) customMain += ", ";
				customMain += "love_CanvasOutput" + std::to_string(index);
			}
			customMain += ", v_color0, v_texcoord0";
			if (translated.mainTextureType == Love::GraphicsBackend::TextureType::Array)
				customMain += ", v_texcoord1";
			customMain += customVaryingArguments + "); ";
			for (int index = 0; index < translated.colorOutputs; ++index)
				customMain += "gl_FragData[" + std::to_string(index) + "] = love_CanvasOutput"
					+ std::to_string(index) + "; ";
			customMain += "}\n";
		}
		const std::string mainSamplerDeclaration = !translated.mainTextureType ? ""
			: *translated.mainTextureType == Love::GraphicsBackend::TextureType::Array
			? "SAMPLER2DARRAY(s_texColor, 0);\n"
			: *translated.mainTextureType == Love::GraphicsBackend::TextureType::Cube
			? "SAMPLERCUBE(s_texColor, 0);\n"
			: *translated.mainTextureType == Love::GraphicsBackend::TextureType::Volume
			? "SAMPLER3D(s_texColor, 0);\n" : "SAMPLER2D(s_texColor, 0);\n";
		translated.source = std::string("$input v_color0, v_texcoord0")
			+ (translated.mainTextureType == Love::GraphicsBackend::TextureType::Array ? ", v_texcoord1" : "")
			+ customVaryingStreams + "\n" + std::string(common)
			+ varyingTexCoordMacro + pixelCommon + mainSamplerDeclaration + declarations
			+ constructorHelpers
			+ "#line 1\n" + body
			+ (custom
				? "\n#line 100000\n" + customMain
				: "\n#line 100000\nvoid main() { " + customVaryingLocals
					+ "gl_FragColor = effect(v_color0, s_texColor, v_texcoord0, gl_FragCoord.xy"
					+ customVaryingArguments + "); }\n");
	}
	if (!source.empty())
	{
		std::size_t start = 0;
		int line = 1;
		while (start <= body.size())
		{
			const std::size_t end = body.find('\n', start);
			const std::string_view text = trimShaderText(std::string_view(body).substr(start,
				end == std::string::npos ? body.size() - start : end - start));
			if (!text.empty()) translated.diagnosticLines.emplace_back(line, std::string(text));
			if (end == std::string::npos) break;
			start = end + 1;
			++line;
		}
	}
	error.clear();
	return true;
}

void annotateLoveShaderDiagnostic(std::string_view stage,
	const LoveShaderTranslation &translation, std::string &message)
{
	static const std::regex codeLine(R"(>>>[ \t]*[0-9]+:[ \t]*([^\r\n]+))");
	std::smatch match;
	if (!std::regex_search(message, match, codeLine)) return;
	const std::string matchedLine = match[1].str();
	const std::string_view snippet = trimShaderText(matchedLine);
	if (snippet.empty()) return;
	int sourceLine = 0;
	int matches = 0;
	for (const auto &[line, text] : translation.diagnosticLines)
	{
		if (snippet != trimShaderText(text)) continue;
		sourceLine = line;
		++matches;
	}
	// Do not claim a source location when the generated diagnostic is ambiguous.
	if (matches != 1) return;
	message = "Love " + std::string(stage) + " Shader source line "
		+ std::to_string(sourceLine) + ":\n" + message;
}

bool buildLoveShaderVaryingDefinition(const LoveShaderVaryingMap &varyings,
	std::string &path, std::string &definition, std::string &error)
{
	path = SharedContent.getFullPath("Shader/Love/varying.def.sc"_slice);
	if (path.empty())
	{
		error = "Dora Content could not resolve Shader/Love/varying.def.sc";
		return false;
	}
	auto [bytes, size] = SharedContent.load(path);
	if (!bytes || size == 0)
	{
		error = "Dora Content could not load Shader/Love/varying.def.sc";
		return false;
	}
	definition.assign(reinterpret_cast<const char *>(bytes.get()), size);
	for (const auto &[name, varying] : varyings)
	{
		DORA_UNUSED_PARAM(name);
		if (!varying.pixelInput || varying.interpolation.empty()) continue;
		std::string gpuInterpolation = varying.interpolation;
		// GLSL ES 3.00 has no noperspective interpolation qualifier, and bgfx's
		// GLES shader path cannot reliably preserve centroid ordering in its final
		// driver source. LÖVE accepts both in GLSL3 sources, so retain flat (which
		// GLES 3.00 supports) and use default smooth interpolation for the others.
		if (bgfx::getCaps()->rendererType == bgfx::RendererType::OpenGLES)
		{
			if (gpuInterpolation != "flat") gpuInterpolation.clear();
		}
		if (gpuInterpolation.empty()) continue;
		for (const std::string &gpuName : varying.gpuNames)
		{
			const std::string declaration = "vec4 " + gpuName + " :";
			const std::size_t position = definition.find(declaration);
			if (position == std::string::npos)
			{
				error = "internal Love Shader varying definition is missing '" + gpuName + "'";
				return false;
			}
			definition.insert(position, gpuInterpolation + " ");
		}
	}
	error.clear();
	return true;
}

Shader *compileLoveShader(const LoveShaderTranslation &translation, ShaderStage stage,
	std::string_view stageName, String varyingPath, String varyingDefinition,
	std::string &warnings, std::string &error)
{
	const std::string virtualSource = Path::concat({Path::getPath(varyingPath),
		stage == ShaderStage::Vertex ? "runtime-vs.sc"_slice : "runtime-fs.sc"_slice});
	const std::string bytecode = SharedShaderCompiler.compile(translation.source, stage, false, error,
		virtualSource, &warnings, varyingDefinition);
	if (!error.empty() || bytecode.empty())
	{
		annotateLoveShaderDiagnostic(stageName, translation, error);
		return nullptr;
	}
	const char expectedStage = stage == ShaderStage::Vertex ? 'V' : 'F';
	if (bytecode.size() < 4 || bytecode[0] != expectedStage
		|| bytecode[1] != 'S' || bytecode[2] != 'H')
	{
		error = "Dora Shader compiler returned invalid ";
		error += stageName;
		error += " bytecode (expected ";
		error.push_back(expectedStage);
		error += "SH header, got ";
		if (bytecode.size() >= 3)
		{
			error.append(bytecode.data(), 3);
		}
		else
		{
			error += "truncated data";
		}
		error += ")";
		return nullptr;
	}
	if (bgfx::getCaps()->rendererType == bgfx::RendererType::OpenGLES
		&& 0 == (bgfx::getCaps()->supported & BGFX_CAPS_COMPUTE))
	{
		const std::size_t version = bytecode.find("#version 310");
		if (version != std::string::npos)
		{
			error = "Dora Shader compiler emitted unsupported GLSL ES 3.10 for ";
			error += stageName;
			error += ": ";
			error.append(bytecode, version, std::min<std::size_t>(240, bytecode.size() - version));
			return nullptr;
		}
	}
	const bgfx::Memory *memory = bgfx::copy(bytecode.data(), static_cast<uint32_t>(bytecode.size()));
	const bgfx::ShaderHandle handle = bgfx::createShader(memory);
	if (!bgfx::isValid(handle))
	{
		error = "bgfx rejected the compiled Love Shader stage";
		return nullptr;
	}
	error.clear();
	return Shader::create(handle);
}

std::string toLoveKeyName(String name)
{
	static const std::unordered_map<std::string, std::string> mapped = {
		{"BackSpace", "backspace"}, {"CapsLock", "capslock"}, {"Delete", "delete"},
		{"Down", "down"}, {"End", "end"}, {"Escape", "escape"}, {"Home", "home"},
		{"Insert", "insert"}, {"LAlt", "lalt"}, {"LCtrl", "lctrl"}, {"LGui", "lgui"},
		{"LShift", "lshift"}, {"Left", "left"}, {"PageDown", "pagedown"},
		{"PageUp", "pageup"}, {"RAlt", "ralt"}, {"RCtrl", "rctrl"}, {"Return", "return"},
		{"RGui", "rgui"}, {"Right", "right"}, {"RShift", "rshift"}, {"Space", "space"},
		{"Tab", "tab"}, {"Up", "up"},
		{"Left Alt", "lalt"}, {"Left Ctrl", "lctrl"}, {"Left GUI", "lgui"},
		{"Left Shift", "lshift"}, {"Right Alt", "ralt"}, {"Right Ctrl", "rctrl"},
		{"Right GUI", "rgui"}, {"Right Shift", "rshift"}, {"NumLockClear", "numlock"},
		{"Numlock", "numlock"},
	};
	std::string key = name.toString();
	if (const auto found = mapped.find(key); found != mapped.end())
		return found->second;
	if (key.starts_with("Keypad "))
	{
		key = "kp" + key.substr(7);
		std::transform(key.begin(), key.end(), key.begin(), [](unsigned char value) {
			return static_cast<char>(std::tolower(value));
		});
		return key;
	}
	if (key.size() == 1 && key[0] >= 'A' && key[0] <= 'Z')
		key[0] = static_cast<char>(key[0] - 'A' + 'a');
	else if (key.size() > 1 && key[0] == 'F')
		key[0] = 'f';
	return key;
}

std::string normalizeLoveScancodeName(std::string_view name)
{
	std::string normalized;
	normalized.reserve(name.size());
	for (const unsigned char value : name)
	{
		if (value == ' ' || value == '-' || value == '_') continue;
		normalized.push_back(static_cast<char>(std::tolower(value)));
	}
	if (normalized.starts_with("keypad"))
		normalized.replace(0, 6, "kp");
	else if (normalized == "leftctrl") normalized = "lctrl";
	else if (normalized == "leftshift") normalized = "lshift";
	else if (normalized == "leftalt") normalized = "lalt";
	else if (normalized == "leftgui") normalized = "lgui";
	else if (normalized == "rightctrl") normalized = "rctrl";
	else if (normalized == "rightshift") normalized = "rshift";
	else if (normalized == "rightalt") normalized = "ralt";
	else if (normalized == "rightgui") normalized = "rgui";
	return normalized.empty() ? "unknown" : normalized;
}

std::string loveKeySDLName(std::string_view key)
{
	static const std::unordered_map<std::string_view, std::string_view> mapped = {
		{"lctrl", "Left Ctrl"}, {"lshift", "Left Shift"}, {"lalt", "Left Alt"},
		{"lgui", "Left GUI"}, {"rctrl", "Right Ctrl"}, {"rshift", "Right Shift"},
		{"ralt", "Right Alt"}, {"rgui", "Right GUI"}, {"numlock", "Numlock"},
		{"backspace", "Backspace"},
	};
	if (const auto found = mapped.find(key); found != mapped.end())
		return std::string(found->second);
	if (key.starts_with("kp"))
		return "Keypad " + std::string(key.substr(2));
	return std::string(key);
}

BlendFunc toDoraBlendFunc(std::string_view mode, std::string_view alphaMode)
{
	const bool premultiplied = alphaMode == "premultiplied";
	if (mode == "alpha")
		return premultiplied
			? BlendFunc{BlendFunc::One, BlendFunc::InvSrcAlpha, BlendFunc::One, BlendFunc::InvSrcAlpha}
			: BlendFunc::Default;
	if (mode == "add")
		return premultiplied
			? BlendFunc{BlendFunc::One, BlendFunc::One, BlendFunc::Zero, BlendFunc::One}
			: BlendFunc{BlendFunc::SrcAlpha, BlendFunc::One, BlendFunc::Zero, BlendFunc::One};
	if (mode == "subtract")
	{
		const BlendFunc factors = premultiplied
			? BlendFunc{BlendFunc::One, BlendFunc::One, BlendFunc::Zero, BlendFunc::One}
			: BlendFunc{BlendFunc::SrcAlpha, BlendFunc::One, BlendFunc::Zero, BlendFunc::One};
		return BlendFunc{factors.toValue()
			| BGFX_STATE_BLEND_EQUATION(BGFX_STATE_BLEND_EQUATION_REVSUB)};
	}
	if (mode == "multiply")
		return {BlendFunc::DstColor, BlendFunc::Zero, BlendFunc::DstColor, BlendFunc::Zero};
	if (mode == "screen")
		return premultiplied
			? BlendFunc{BlendFunc::One, BlendFunc::InvSrcColor, BlendFunc::One, BlendFunc::InvSrcColor}
			: BlendFunc{BlendFunc::SrcAlpha, BlendFunc::InvSrcColor, BlendFunc::One, BlendFunc::InvSrcColor};
	return premultiplied
		? BlendFunc{BlendFunc::One, BlendFunc::Zero, BlendFunc::One, BlendFunc::Zero}
		: BlendFunc{BlendFunc::SrcAlpha, BlendFunc::Zero, BlendFunc::One, BlendFunc::Zero};
}

struct Utf8Unit
{
	std::uint32_t codepoint = 0;
	std::size_t begin = 0;
	std::size_t end = 0;
};

bool decodeUtf8Units(std::string_view text, std::vector<Utf8Unit> &units)
{
	units.clear();
	for (std::size_t offset = 0; offset < text.size();)
	{
		const std::size_t begin = offset;
		const auto first = static_cast<std::uint8_t>(text[offset]);
		std::size_t length = 0;
		std::uint32_t codepoint = 0;
		if (first < 0x80) { length = 1; codepoint = first; }
		else if ((first & 0xe0) == 0xc0) { length = 2; codepoint = first & 0x1f; }
		else if ((first & 0xf0) == 0xe0) { length = 3; codepoint = first & 0x0f; }
		else if ((first & 0xf8) == 0xf0) { length = 4; codepoint = first & 0x07; }
		else return false;
		if (offset + length > text.size()) return false;
		for (std::size_t index = 1; index < length; ++index)
		{
			const auto byte = static_cast<std::uint8_t>(text[offset + index]);
			if ((byte & 0xc0) != 0x80) return false;
			codepoint = (codepoint << 6) | (byte & 0x3f);
		}
		const std::uint32_t minimum = length == 1 ? 0 : length == 2 ? 0x80 : length == 3 ? 0x800 : 0x10000;
		if (codepoint < minimum || codepoint > 0x10ffff
			|| (codepoint >= 0xd800 && codepoint <= 0xdfff)) return false;
		offset += length;
		units.push_back({codepoint, begin, offset});
	}
	return true;
}

std::optional<bgfx::TextureFormat::Enum> toCanvasTextureFormat(std::string_view format)
{
	static const std::unordered_map<std::string_view, bgfx::TextureFormat::Enum> formats = {
		{"r8", bgfx::TextureFormat::R8}, {"rg8", bgfx::TextureFormat::RG8},
		{"rgba8", bgfx::TextureFormat::RGBA8}, {"srgba8", bgfx::TextureFormat::RGBA8},
		{"r16", bgfx::TextureFormat::R16}, {"rg16", bgfx::TextureFormat::RG16},
		{"rgba16", bgfx::TextureFormat::RGBA16}, {"r16f", bgfx::TextureFormat::R16F},
		{"rg16f", bgfx::TextureFormat::RG16F}, {"rgba16f", bgfx::TextureFormat::RGBA16F},
		{"r32f", bgfx::TextureFormat::R32F}, {"rg32f", bgfx::TextureFormat::RG32F},
		{"rgba32f", bgfx::TextureFormat::RGBA32F}, {"rgba4", bgfx::TextureFormat::RGBA4},
		{"rgb5a1", bgfx::TextureFormat::RGB5A1}, {"rgb565", bgfx::TextureFormat::R5G6B5},
		{"rgb10a2", bgfx::TextureFormat::RGB10A2}, {"rg11b10f", bgfx::TextureFormat::RG11B10F},
		{"stencil8", bgfx::TextureFormat::D24S8}, {"depth16", bgfx::TextureFormat::D16},
		{"depth24", bgfx::TextureFormat::D24}, {"depth32f", bgfx::TextureFormat::D32F},
		{"depth24stencil8", bgfx::TextureFormat::D24S8},
	};
	if (const auto found = formats.find(format); found != formats.end())
		return found->second;
	return std::nullopt;
}

std::optional<bgfx::TextureFormat::Enum> toImageTextureFormat(std::string_view format)
{
	if (const auto uncompressed = toCanvasTextureFormat(format))
		return uncompressed;
	if (format == "DXT1") return bgfx::TextureFormat::BC1;
	if (format == "DXT3") return bgfx::TextureFormat::BC2;
	if (format == "DXT5") return bgfx::TextureFormat::BC3;
	if (format == "BC4") return bgfx::TextureFormat::BC4;
	if (format == "BC5") return bgfx::TextureFormat::BC5;
	if (format == "BC6h") return bgfx::TextureFormat::BC6H;
	if (format == "BC7") return bgfx::TextureFormat::BC7;
	if (format == "ETC1") return bgfx::TextureFormat::ETC1;
	if (format == "ETC2rgb") return bgfx::TextureFormat::ETC2;
	if (format == "ETC2rgba") return bgfx::TextureFormat::ETC2A;
	if (format == "ETC2rgba1") return bgfx::TextureFormat::ETC2A1;
	if (format == "EACr") return bgfx::TextureFormat::EACR;
	if (format == "EACrs") return bgfx::TextureFormat::EACRS;
	if (format == "EACrg") return bgfx::TextureFormat::EACRG;
	if (format == "EACrgs") return bgfx::TextureFormat::EACRGS;
	if (format == "PVR1rgb2") return bgfx::TextureFormat::PTC12;
	if (format == "PVR1rgb4") return bgfx::TextureFormat::PTC14;
	if (format == "PVR1rgba2") return bgfx::TextureFormat::PTC12A;
	if (format == "PVR1rgba4") return bgfx::TextureFormat::PTC14A;
	if (format == "ASTC4x4") return bgfx::TextureFormat::ASTC4x4;
	if (format == "ASTC5x4") return bgfx::TextureFormat::ASTC5x4;
	if (format == "ASTC5x5") return bgfx::TextureFormat::ASTC5x5;
	if (format == "ASTC6x5") return bgfx::TextureFormat::ASTC6x5;
	if (format == "ASTC6x6") return bgfx::TextureFormat::ASTC6x6;
	if (format == "ASTC8x5") return bgfx::TextureFormat::ASTC8x5;
	if (format == "ASTC8x6") return bgfx::TextureFormat::ASTC8x6;
	if (format == "ASTC8x8") return bgfx::TextureFormat::ASTC8x8;
	if (format == "ASTC10x5") return bgfx::TextureFormat::ASTC10x5;
	if (format == "ASTC10x6") return bgfx::TextureFormat::ASTC10x6;
	if (format == "ASTC10x8") return bgfx::TextureFormat::ASTC10x8;
	if (format == "ASTC10x10") return bgfx::TextureFormat::ASTC10x10;
	if (format == "ASTC12x10") return bgfx::TextureFormat::ASTC12x10;
	if (format == "ASTC12x12") return bgfx::TextureFormat::ASTC12x12;
	return std::nullopt;
}

bool isLoveCompressedTextureValid(std::uint16_t depth, bool cube, std::uint16_t layers,
	bgfx::TextureFormat::Enum format)
{
	if (!bgfx::isTextureValid(depth, cube, layers, format, BGFX_TEXTURE_NONE)) return false;
	const auto formatCaps = bgfx::getCaps()->formats[format];
	// bgfx lists PVRTC1 2bpp among its emulated compressed formats, but the
	// vendored bimg decoder deliberately leaves PTC12/PTC12A unimplemented.
	// Never advertise an emulated path which can only upload an opaque-black
	// fallback; a renderer with native 2D support may still use the format.
	if ((format == bgfx::TextureFormat::PTC12
			|| format == bgfx::TextureFormat::PTC12A)
		&& (formatCaps & BGFX_CAPS_FORMAT_TEXTURE_2D) == 0
		&& (formatCaps & BGFX_CAPS_FORMAT_TEXTURE_2D_EMULATED) != 0)
		return false;
	// The macOS Metal backend advertises PVRTC1 2bpp and accepts resource
	// creation, but valid Xcode TextureConverter payloads sample as opaque black.
	// bimg has no 2bpp decoder fallback, so reject the false-positive capability
	// consistently in getImageFormats and compressed Image creation.
#if BX_PLATFORM_OSX
	if (bgfx::getRendererType() == bgfx::RendererType::Metal
		&& (format == bgfx::TextureFormat::PTC12
			|| format == bgfx::TextureFormat::PTC12A))
		return false;
#endif
	// bgfx advertises ETC2A1 as emulated on renderers without native support,
	// but the vendored bimg decoder explicitly does not implement ETC2A1.
	// Let native renderers use it and reject the otherwise silent black-texture
	// conversion before resource creation.
	if (format == bgfx::TextureFormat::ETC2A1
		&& (formatCaps & BGFX_CAPS_FORMAT_TEXTURE_2D) == 0
		&& (formatCaps & BGFX_CAPS_FORMAT_TEXTURE_2D_EMULATED) != 0)
		return false;
	return true;
}

std::string hexadecimalId(std::uint16_t value)
{
	char digits[4];
	const auto result = std::to_chars(std::begin(digits), std::end(digits), value, 16);
	return "0x" + std::string(digits, result.ptr);
}

std::optional<std::size_t> canvasFormatBytes(std::string_view format)
{
	if (format == "r8") return 1;
	if (format == "rg8" || format == "r16" || format == "r16f"
		|| format == "rgba4" || format == "rgb5a1" || format == "rgb565") return 2;
	if (format == "rgba8" || format == "srgba8" || format == "rg16"
		|| format == "rg16f" || format == "r32f" || format == "rgb10a2"
		|| format == "rg11b10f") return 4;
	if (format == "rgba16" || format == "rgba16f" || format == "rg32f") return 8;
	if (format == "rgba32f") return 16;
	return std::nullopt;
}

uint64_t toCanvasMSAAFlags(int msaa)
{
	switch (msaa)
	{
		case 2: return BGFX_TEXTURE_RT_MSAA_X2;
		case 4: return BGFX_TEXTURE_RT_MSAA_X4;
		case 8: return BGFX_TEXTURE_RT_MSAA_X8;
		case 16: return BGFX_TEXTURE_RT_MSAA_X16;
		default: return 0;
	}
}

bool isCanvasFormatSafeForRenderer(std::string_view format)
{
	// bgfx currently advertises these packed formats as framebuffer-capable on
	// Metal, but implements their channel order with a texture swizzle. Metal
	// forbids a non-identity swizzle on a render-target texture and aborts in
	// descriptor validation, so reject them before any GPU command is queued.
	if (bgfx::getCaps()->rendererType == bgfx::RendererType::Metal)
		return format != "rgba4" && format != "rgb5a1" && format != "rgb565";
	return true;
}

bool isCanvasDepthStencilFormat(std::string_view format)
{
	return format == "stencil8" || format == "depth16" || format == "depth24"
		|| format == "depth32f" || format == "depth24stencil8"
		|| format == "depth32fstencil8";
}

bool isCanvasMSAASafeForRenderer(int msaa)
{
	// bgfx silently substitutes the nearest lower Metal sample count when the
	// device rejects 8x/16x. That would make Canvas:getMSAA report a value the
	// texture does not use, so keep the current Metal contract at the 4x level
	// which is exposed and verified by Dora. Other renderers retain bgfx's
	// capability-driven validation and are covered by their platform gates.
	return bgfx::getCaps()->rendererType != bgfx::RendererType::Metal || msaa <= 4;
}
} // namespace

LoveNode::LoveNode(String bootFile)
	: _bootFile(bootFile.toString())
{
}

LoveNode::~LoveNode()
{
	if (_runtime)
	{
		_runtime->close();
		_runtime = nullptr;
	}
	for (const auto &root : _mountedArchiveRoots)
		if (SharedContent.exist(root)) SharedContent.remove(root);
	_mountedArchiveRoots.clear();
	clearLovePackage();
}

bool LoveNode::init()
{
	if (!Sprite::init())
		return false;
	_frameRoot = Node::create();
	_frameRoot->setAsManaged();
	if (!loadBoot())
		return false;
	setupInputHandlers();
	if (FocusedLoveNode == nullptr)
		focusInput();
	scheduleUpdate();
	return true;
}

bool LoveNode::loadBoot()
{
	++_runtimeGeneration;
	_lastError.clear();
	_audioBus = nullptr;
	clearLovePackage();
	if (_bootFile.empty() || !SharedContent.exist(_bootFile))
		return reportError("boot", "file does not exist");

	std::string error;
	std::string effectiveBootFile = _bootFile;
	std::string fullPath;
	const bool package = Path::getExt(_bootFile) == "love";
	if (package)
	{
		if (!extractLovePackage(effectiveBootFile, error))
			return reportError(".love package", error);
		fullPath = effectiveBootFile;
		_sourceRoot = _packageRoot;
	}
	else
	{
		fullPath = SharedContent.getFullPath(_bootFile);
		_sourceRoot = Path::getPath(fullPath.empty() ? _bootFile : fullPath);
	}
	_audioBus = SharedAudio.getSoLoud() ? AudioBus::create() : nullptr;

	_runtime = New<Love::LoveRuntime>();
	_runtime->setGraphicsBackend(this);
	_runtime->setImageBackend(this);
	_runtime->setSoundBackend(this);
	_runtime->setFilesystemBackend(this);
	_runtime->setAudioBackend(this);
	_runtime->setKeyboardBackend(this);
	_runtime->setMouseBackend(this);
	_runtime->setJoystickBackend(this);
	_runtime->setSystemBackend(this);
	_runtime->setPhysicsBackend(this);
	const std::string defaultFont = Path::concat({SharedContent.getAssetPath(),
		"Font/sarasa-mono-sc-regular.ttf"_slice});
	if (SharedContent.exist(defaultFont))
		_runtime->setDefaultFontData(SharedContent.loadStr(defaultFont));
	if (!_runtime->open(error))
		return reportError("open", error);
	const std::string lualibBundle = Path::concat({SharedContent.getAssetPath(),
		"Script/Lib/lualib_bundle.lua"_slice});
	if (!SharedContent.exist(lualibBundle)
		|| !_runtime->setPreloadModule("lualib_bundle", SharedContent.loadStr(lualibBundle), error))
		return reportError("lualib_bundle", error.empty() ? "built-in module is missing" : error);
	for (const int controllerId : SharedController.getControllerIds())
		_runtime->addJoystick(controllerId, SharedController.getControllerName(controllerId).toString());
	if (!_runtime->setSourceRoot(_sourceRoot, error))
		return reportError("source root", error);
	if (!_runtime->setSaveBaseRoot(Path::concat({SharedContent.getWritablePath(), "Love"_slice}), error))
		return reportError("save root", error);

	const std::string confFile = Path::concat({_sourceRoot, "conf.lua"_slice});
	if (SharedContent.exist(confFile))
	{
		if (!_runtime->execute(SharedContent.loadStr(confFile), "@" + confFile, error))
			return reportError("conf.lua", error);
	}
	if (!_runtime->configure(error))
		return reportError("love.conf", error);
	if (!setupSurface(_runtime->getConfiguredWidth(), _runtime->getConfiguredHeight()))
		return false;

	const std::string bootChunk = package ? "@" + _bootFile + "!/main.lua" : "@" + _bootFile;
	if (!_runtime->execute(SharedContent.loadStr(effectiveBootFile), bootChunk, error))
		return reportError("boot", error);

	const std::string mainFile = Path::concat({_sourceRoot, "main.lua"_slice});
	if (mainFile != fullPath && SharedContent.exist(mainFile))
	{
		if (!_runtime->execute(SharedContent.loadStr(mainFile), "@" + mainFile, error))
			return reportError("main.lua", error);
	}

	if (!_runtime->start(error))
		return reportError("love.load", error);
	return true;
}

bool LoveNode::extractLovePackage(std::string &mainFile, std::string &error)
{
	constexpr std::size_t MaximumPackageFiles = 4096;
	constexpr std::size_t MaximumPackageFileSize = 256u * 1024u * 1024u;
	constexpr std::size_t MaximumPackageExpandedSize = 512u * 1024u * 1024u;
	auto archiveData = SharedContent.load(_bootFile);
	if (!archiveData.first || archiveData.second == 0)
	{
		error = "Dora Content failed to read package '" + _bootFile + "'";
		return false;
	}
	ZipFile archive(std::move(archiveData));
	if (!archive.isOK())
	{
		error = "Dora Zip failed to open package '" + _bootFile + "' from Content memory";
		return false;
	}
	const auto files = archive.getAllFiles();
	if (files.empty() || files.size() > MaximumPackageFiles)
	{
		error = "Love package must contain between 1 and "
			+ std::to_string(MaximumPackageFiles) + " files";
		return false;
	}
	if (!archive.fileExists("main.lua") || archive.isFolder("main.lua"))
	{
		error = "Love package must contain main.lua at its root";
		return false;
	}
	std::size_t expandedSize = 0;
	for (const auto &file : files)
	{
		if (!isSafeLovePackagePath(file))
		{
			error = "Love package contains an unsafe path: '" + file + "'";
			return false;
		}
		const auto size = archive.getFileSize(file);
		if (!size || *size > MaximumPackageFileSize
			|| expandedSize > MaximumPackageExpandedSize - *size)
		{
			error = "Love package entry exceeds extraction limits: '" + file + "'";
			return false;
		}
		expandedSize += *size;
	}

	const auto sequence = LovePackageSequence.fetch_add(1, std::memory_order_relaxed);
	const std::string rootName = std::to_string(sequence) + "-" + std::to_string(_runtimeGeneration);
	_packageRoot = Path::concat({SharedContent.getWritablePath(), "LovePackages"_slice, rootName});
	if (!SharedContent.exist(_packageRoot) && !SharedContent.createFolder(_packageRoot))
	{
		error = "Dora Content failed to create Love package staging root '" + _packageRoot + "'";
		_packageRoot.clear();
		return false;
	}
	for (const auto &file : files)
	{
		const auto expectedSize = archive.getFileSize(file).value_or(0);
		auto data = archive.getFileData(file);
		if ((!data.first && expectedSize != 0) || data.second != expectedSize)
		{
			error = "Dora Zip failed to extract Love package entry '" + file + "'";
			clearLovePackage();
			return false;
		}
		const std::string target = Path::concat({_packageRoot, file});
		const std::string parent = Path::getPath(target);
		if ((!SharedContent.exist(parent) && !SharedContent.createFolder(parent))
			|| !SharedContent.save(target, data.first.get(), static_cast<std::int64_t>(data.second)))
		{
			error = "Dora Content failed to stage Love package entry '" + file + "'";
			clearLovePackage();
			return false;
		}
	}
	mainFile = Path::concat({_packageRoot, "main.lua"_slice});
	error.clear();
	return true;
}

void LoveNode::clearLovePackage()
{
	if (_packageRoot.empty()) return;
	if (SharedContent.exist(_packageRoot)) SharedContent.remove(_packageRoot);
	_packageRoot.clear();
}

bool LoveNode::setupSurface(int width, int height)
{
	_renderTarget = RenderTarget::create(width, height);
	if (!_renderTarget)
		return reportError("graphics", "failed to create the " + std::to_string(width)
			+ "x" + std::to_string(height) + " main render target");
	setTexture(_renderTarget->getTexture());
	setTextureRect({0.0f, 0.0f, static_cast<float>(width), static_cast<float>(height)});
	setSize({static_cast<float>(width), static_cast<float>(height)});
	return true;
}

bool LoveNode::reportError(String phase, const std::string &error)
{
	_lastError = phase.toString() + ": " + error;
	Error("LoveNode [{}] {} failed: {}", _bootFile, phase.toString(), error);
	return false;
}

bool LoveNode::update(double deltaTime)
{
	if (!_runtime || _runtime->getStatus() != Love::LoveRuntime::Status::Running)
		return true;

	std::string error;
	if (!_runtime->update(deltaTime, error))
	{
		reportError("update", error);
		return true;
	}
	if (_runtime->getStatus() == Love::LoveRuntime::Status::RestartRequested)
	{
		if (!restartInstance(false))
		{
			unscheduleUpdate();
			return true;
		}
		return Sprite::update(deltaTime);
	}
	if (_runtime->getStatus() == Love::LoveRuntime::Status::Stopped)
	{
		closeStoppedInstance();
		return true;
	}
	return Sprite::update(deltaTime);
}

void LoveNode::render()
{
	if (_runtime && _runtime->getStatus() == Love::LoveRuntime::Status::Running)
	{
		std::string error;
		if (!_runtime->draw(error))
			reportError("draw", error);
	}
	Sprite::render();
}

bool LoveNode::restart()
{
	return restartInstance(true);
}

bool LoveNode::restartInstance(bool manageUpdateSchedule)
{
	const bool wasFocused = FocusedLoveNode == this;
	if (wasFocused) resetHostMouseSettings();
	if (manageUpdateSchedule)
		unscheduleUpdate();
	_textInputRequested = true;
	_screenKeyboardRequested = false;
	_hasTextInputRectangle = false;
	_hostPressedKeys.clear();
	_hostPressedControllerButtons.clear();
	_hostActiveControllerAxes.clear();
	_hostPressedJoystickButtons.clear();
	_hostActiveJoystickAxes.clear();
	_hostActiveJoystickHats.clear();
	_pendingScreenshotRequests.clear();
	if (_runtime)
	{
		_runtime->close();
		_runtime = nullptr;
	}
	clearInstanceResources();
	if (!loadBoot())
	{
		if (_runtime)
		{
			_runtime->close();
			_runtime = nullptr;
		}
		clearInstanceResources();
		if (wasFocused)
		{
			detachIME();
			setKeyboardEnabled(false);
			resetHostMouseSettings();
			FocusedLoveNode = nullptr;
		}
		setTouchEnabled(false);
		setControllerEnabled(false);
		return false;
	}
	setTouchEnabled(true);
	setControllerEnabled(true);
	if (FocusedLoveNode == nullptr)
		focusInput();
	else if (wasFocused)
		applyMouseSettings();
	if (manageUpdateSchedule)
		scheduleUpdate();
	return true;
}

void LoveNode::cleanup()
{
	if (_flags.isOn(Node::Cleanup))
		return;
	if (FocusedLoveNode == this)
	{
		detachIME();
		resetHostMouseSettings();
		FocusedLoveNode = nullptr;
	}
	_hostPressedKeys.clear();
	_hostPressedControllerButtons.clear();
	_hostActiveControllerAxes.clear();
	_hostPressedJoystickButtons.clear();
	_hostActiveJoystickAxes.clear();
	_hostActiveJoystickHats.clear();
	++_runtimeGeneration;
	_pendingScreenshotRequests.clear();
	setControllerEnabled(false);
	if (_runtime)
	{
		std::string error;
		if (_runtime->getStatus() == Love::LoveRuntime::Status::Running && !_runtime->stop(error))
			reportError("quit", error);
		_runtime->close();
		_runtime = nullptr;
	}
	clearInstanceResources();
	Sprite::cleanup();
}

void LoveNode::setupInputHandlers()
{
	setTouchEnabled(true);
	setSwallowTouches(true);
	setSwallowMouseWheel(true);
	setControllerEnabled(true);
	slot("KeyDown"_slice, [this](Event *event) { handleKeyboardEvent(event); });
	slot("KeyRepeat"_slice, [this](Event *event) { handleKeyboardEvent(event); });
	slot("KeyUp"_slice, [this](Event *event) { handleKeyboardEvent(event); });
	slot("TextInput"_slice, [this](Event *event) { handleKeyboardEvent(event); });
	slot("TextEditing"_slice, [this](Event *event) { handleKeyboardEvent(event); });
	slot("TapBegan"_slice, [this](Event *event) { handlePointerEvent(event); });
	slot("TapMoved"_slice, [this](Event *event) { handlePointerEvent(event); });
	slot("TapEnded"_slice, [this](Event *event) { handlePointerEvent(event); });
	slot("MouseMove"_slice, [this](Event *event) { handlePointerEvent(event); });
	slot("MouseWheel"_slice, [this](Event *event) { handlePointerEvent(event); });
	slot("ControllerAdded"_slice, [this](Event *event) { handleControllerEvent(event); });
	slot("ControllerRemoved"_slice, [this](Event *event) { handleControllerEvent(event); });
	slot("ButtonDown"_slice, [this](Event *event) { handleControllerEvent(event); });
	slot("ButtonUp"_slice, [this](Event *event) { handleControllerEvent(event); });
	slot("Axis"_slice, [this](Event *event) { handleControllerEvent(event); });
	slot("JoystickButtonDown"_slice, [this](Event *event) { handleControllerEvent(event); });
	slot("JoystickButtonUp"_slice, [this](Event *event) { handleControllerEvent(event); });
	slot("JoystickAxis"_slice, [this](Event *event) { handleControllerEvent(event); });
	slot("JoystickHat"_slice, [this](Event *event) { handleControllerEvent(event); });
}

void LoveNode::closeStoppedInstance()
{
	if (!_runtime || _runtime->getStatus() != Love::LoveRuntime::Status::Stopped)
		return;
	if (FocusedLoveNode == this)
	{
		detachIME();
		resetHostMouseSettings();
		FocusedLoveNode = nullptr;
	}
	_hostPressedKeys.clear();
	_hostPressedControllerButtons.clear();
	_hostActiveControllerAxes.clear();
	_hostPressedJoystickButtons.clear();
	_hostActiveJoystickAxes.clear();
	_hostActiveJoystickHats.clear();
	++_runtimeGeneration;
	_pendingScreenshotRequests.clear();
	setKeyboardEnabled(false);
	setControllerEnabled(false);
	setTouchEnabled(false);
	unscheduleUpdate();
	_runtime->close();
	_runtime = nullptr;
	clearInstanceResources();
}

void LoveNode::clearInstanceResources()
{
	setTexture(nullptr);
	_drawNode = nullptr;
	_commandRoot = nullptr;
	// A Love frame can contain several Canvas and main-surface render passes.
	// Their command roots may outlive the owning vector through Dora's
	// autorelease/unmanaged-node queues, so explicitly clean every root before
	// dropping it. This mirrors Sprite::cleanup and releases render-command
	// textures and Effects immediately when the Love instance stops.
	for (auto &pass : _renderPasses)
		if (pass.root) pass.root->cleanup();
	_frameRoot = nullptr;
	_images.clear();
	_whiteTexture = nullptr;
	for (auto &[shaderHandle, shader] : _shaders)
	{
		DORA_UNUSED_PARAM(shaderHandle);
		clearShaderSamplerBindings(shader);
	}
	for (auto &shader : _retiredShaders)
		clearShaderSamplerBindings(shader);
	_shaders.clear();
	_retiredShaders.clear();
	_activeShader = 0;
	_arrayTextureShader = 0;
	_canvases.clear();
	_canvasTargets.clear();
	_pendingCanvasMipmaps.clear();
	_renderPasses.clear();
	_activeCanvases.clear();
	_activeCanvasTargets.clear();
	_activeCanvasDepthStencil = 0;
	_activeCanvas = 0;
	_activeCanvasTarget = nullptr;
	_activeCanvasDepth = false;
	_activeCanvasStencil = false;
	_stencilWriting = false;
	_stencilAction = "replace";
	_stencilWriteValue = 1;
	_stencilCompare = "always";
	_stencilTestValue = 0;
	_clearColor = Color(0x000000ff);
	_blendMode = "alpha";
	_blendAlphaMode = "alphamultiply";
	_scissorEnabled = false;
	_scissor = Rect();
	std::fill(std::begin(_colorMask), std::end(_colorMask), true);
	_depthCompare = "always";
	_depthWrite = false;
	_meshCullMode = "none";
	_frontFaceWinding = "ccw";
	_wireframe = false;
	_graphicsFrameActive = false;
	_fonts.clear();
	for (const auto &[handle, cursor] : _mouseCursors)
	{
		DORA_UNUSED_PARAM(handle);
		SDL_FreeCursor(static_cast<SDL_Cursor *>(cursor));
	}
	_mouseCursors.clear();
	while (!_audioRecordings.empty())
		stopRecording(_audioRecordings.begin()->first);
	for (auto &entry : _audioSources)
	{
		auto &resource = entry.second;
		if (resource.node)
		{
			resource.node->stop();
			resource.node->removeFromParent(true);
		}
	}
	_audioSources.clear();
	_audioEffects.clear();
	_audioBus = nullptr;
	_physicsContacts.clear();
	_physicsJoints.clear();
	_physicsFixtures.clear();
	_physicsBodies.clear();
	_physicsShapes.clear();
	_physicsWorlds.clear();
	_pendingPhysicsJointDestroy.clear();
	_pendingPhysicsFixtureDestroy.clear();
	_pendingPhysicsBodyDestroy.clear();
	_pendingPhysicsWorldDestroy.clear();
	_physicsMeter = 30.0f;
	_renderTarget = nullptr;
	for (const auto &root : _mountedArchiveRoots)
		if (SharedContent.exist(root)) SharedContent.remove(root);
	_mountedArchiveRoots.clear();
	clearLovePackage();
}

void LoveNode::focusInput()
{
	if (FocusedLoveNode == this)
		return;
	if (FocusedLoveNode)
		FocusedLoveNode->releaseInputFocus();
	FocusedLoveNode = this;
	setKeyboardEnabled(true);
	applyMouseSettings();
	if (_textInputRequested)
	{
		attachIME(_screenKeyboardRequested);
		if (_hasTextInputRectangle)
			setTextInput(true, true, _textInputRectangle.origin.x, _textInputRectangle.origin.y,
				_textInputRectangle.size.width, _textInputRectangle.size.height);
	}
}

void LoveNode::setTextInput(bool enabled, bool hasRectangle,
	float x, float y, float width, float height)
{
	const bool wasScreenKeyboardRequested = _screenKeyboardRequested;
	_textInputRequested = enabled;
	_screenKeyboardRequested = enabled;
	_hasTextInputRectangle = hasRectangle;
	if (hasRectangle)
		_textInputRectangle = {{x, y}, {width, height}};
	if (FocusedLoveNode != this)
		return;
	if (!enabled)
	{
		detachIME();
		return;
	}
	if (!SharedKeyboard.isIMEAttached() || !wasScreenKeyboardRequested)
	{
		if (SharedKeyboard.isIMEAttached())
			detachIME();
		attachIME(true);
	}
	if (!hasRectangle)
		return;
	WRef<LoveNode> self(this);
	convertToWindowSpace({x, static_cast<float>(getPixelHeight()) - y}, [self](const Vec2 &position) {
		if (self && FocusedLoveNode == self.get())
			SharedKeyboard.updateIMEPosHint(position);
	});
}

std::string LoveNode::getScancodeFromKey(std::string_view key) const
{
	const std::string sdlName = loveKeySDLName(key);
	const SDL_Keycode keycode = SDL_GetKeyFromName(sdlName.c_str());
	if (keycode == SDLK_UNKNOWN) return "unknown";
	const SDL_Scancode scancode = SDL_GetScancodeFromKey(keycode);
	if (scancode == SDL_SCANCODE_UNKNOWN) return "unknown";
	return normalizeLoveScancodeName(SDL_GetScancodeName(scancode));
}

std::string LoveNode::getKeyFromScancode(std::string_view scancode) const
{
	SDL_Scancode sdlScancode = SDL_SCANCODE_UNKNOWN;
	for (int value = 0; value < SDL_NUM_SCANCODES; ++value)
	{
		const auto candidate = static_cast<SDL_Scancode>(value);
		if (normalizeLoveScancodeName(SDL_GetScancodeName(candidate)) == scancode)
		{
			sdlScancode = candidate;
			break;
		}
	}
	if (sdlScancode == SDL_SCANCODE_UNKNOWN) return "unknown";
	const SDL_Keycode keycode = SDL_GetKeyFromScancode(sdlScancode);
	if (keycode == SDLK_UNKNOWN) return "unknown";
	return toLoveKeyName(SDL_GetKeyName(keycode));
}

bool LoveNode::hasScreenKeyboard() const
{
	return SDL_HasScreenKeyboardSupport() == SDL_TRUE;
}

void LoveNode::setMousePosition(float x, float y)
{
	if (FocusedLoveNode != this) return;
	WRef<LoveNode> self(this);
	convertToWindowSpace({x, static_cast<float>(getPixelHeight()) - y}, [self](const Vec2 &position) {
		if (!self || FocusedLoveNode != self.get()) return;
		if (auto *window = SharedApplication.getSDLWindow())
			SDL_WarpMouseInWindow(window, static_cast<int>(std::lround(position.x)),
				static_cast<int>(std::lround(position.y)));
	});
}

void LoveNode::setMouseVisible(bool visible)
{
	if (FocusedLoveNode == this)
		SDL_ShowCursor(visible ? SDL_ENABLE : SDL_DISABLE);
}

void LoveNode::setMouseGrabbed(bool grabbed)
{
	if (FocusedLoveNode != this) return;
	if (auto *window = SharedApplication.getSDLWindow())
		SDL_SetWindowGrab(window, grabbed ? SDL_TRUE : SDL_FALSE);
}

bool LoveNode::setMouseRelativeMode(bool relative)
{
	if (FocusedLoveNode != this) return true;
	return SDL_SetRelativeMouseMode(relative ? SDL_TRUE : SDL_FALSE) == 0;
}

Love::MouseBackend::CursorHandle LoveNode::createImageCursor(int width, int height,
	std::span<const std::uint8_t> rgba8, int hotX, int hotY, std::string &error)
{
	if (width <= 0 || height <= 0 || rgba8.size() != static_cast<std::size_t>(width) * height * 4)
	{
		error = "invalid RGBA8 cursor image";
		return 0;
	}
	Uint32 redMask, greenMask, blueMask, alphaMask;
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
	redMask = 0xff000000; greenMask = 0x00ff0000; blueMask = 0x0000ff00; alphaMask = 0x000000ff;
#else
	redMask = 0x000000ff; greenMask = 0x0000ff00; blueMask = 0x00ff0000; alphaMask = 0xff000000;
#endif
	auto *surface = SDL_CreateRGBSurfaceFrom(const_cast<std::uint8_t *>(rgba8.data()),
		width, height, 32, width * 4, redMask, greenMask, blueMask, alphaMask);
	if (!surface)
	{
		error = SDL_GetError();
		return 0;
	}
	auto *cursor = SDL_CreateColorCursor(surface, hotX, hotY);
	SDL_FreeSurface(surface);
	if (!cursor)
	{
		error = SDL_GetError();
		return 0;
	}
	const auto handle = _nextMouseCursorHandle++;
	_mouseCursors.emplace(handle, cursor);
	error.clear();
	return handle;
}

Love::MouseBackend::CursorHandle LoveNode::createSystemCursor(
	std::string_view type, std::string &error)
{
	static const std::unordered_map<std::string_view, SDL_SystemCursor> SystemCursors = {
		{"arrow", SDL_SYSTEM_CURSOR_ARROW}, {"ibeam", SDL_SYSTEM_CURSOR_IBEAM},
		{"wait", SDL_SYSTEM_CURSOR_WAIT}, {"crosshair", SDL_SYSTEM_CURSOR_CROSSHAIR},
		{"waitarrow", SDL_SYSTEM_CURSOR_WAITARROW}, {"sizenwse", SDL_SYSTEM_CURSOR_SIZENWSE},
		{"sizenesw", SDL_SYSTEM_CURSOR_SIZENESW}, {"sizewe", SDL_SYSTEM_CURSOR_SIZEWE},
		{"sizens", SDL_SYSTEM_CURSOR_SIZENS}, {"sizeall", SDL_SYSTEM_CURSOR_SIZEALL},
		{"no", SDL_SYSTEM_CURSOR_NO}, {"hand", SDL_SYSTEM_CURSOR_HAND},
	};
	const auto found = SystemCursors.find(type);
	if (found == SystemCursors.end())
	{
		error = "invalid system cursor type";
		return 0;
	}
	auto *cursor = SDL_CreateSystemCursor(found->second);
	if (!cursor)
	{
		error = SDL_GetError();
		return 0;
	}
	const auto handle = _nextMouseCursorHandle++;
	_mouseCursors.emplace(handle, cursor);
	error.clear();
	return handle;
}

void LoveNode::releaseCursor(Love::MouseBackend::CursorHandle handle)
{
	const auto found = _mouseCursors.find(handle);
	if (found == _mouseCursors.end()) return;
	if (FocusedLoveNode == this && _runtime && _runtime->getMouseCursorRequested() == handle)
		SDL_SetCursor(SDL_GetDefaultCursor());
	SDL_FreeCursor(static_cast<SDL_Cursor *>(found->second));
	_mouseCursors.erase(found);
}

void LoveNode::setMouseCursor(Love::MouseBackend::CursorHandle handle)
{
	if (FocusedLoveNode != this) return;
	if (handle == 0)
	{
		SDL_SetCursor(SDL_GetDefaultCursor());
		return;
	}
	if (const auto found = _mouseCursors.find(handle); found != _mouseCursors.end())
		SDL_SetCursor(static_cast<SDL_Cursor *>(found->second));
}

bool LoveNode::isMouseCursorSupported() const
{
	return SDL_GetDefaultCursor() != nullptr;
}

void LoveNode::applyMouseSettings()
{
	if (!_runtime || FocusedLoveNode != this) return;
	setMouseVisible(_runtime->isMouseVisibleRequested());
	setMouseGrabbed(_runtime->isMouseGrabbedRequested());
	setMouseRelativeMode(_runtime->isMouseRelativeModeRequested());
	setMouseCursor(_runtime->getMouseCursorRequested());
}

void LoveNode::resetHostMouseSettings()
{
	SDL_SetRelativeMouseMode(SDL_FALSE);
	if (auto *window = SharedApplication.getSDLWindow())
		SDL_SetWindowGrab(window, SDL_FALSE);
	SDL_SetCursor(SDL_GetDefaultCursor());
	SDL_ShowCursor(SDL_ENABLE);
}

Love::JoystickBackend::DeviceInfo LoveNode::getJoystickInfo(int id) const
{
	const auto source = SharedController.getControllerInfo(id);
	return {
		.guid = source.guid,
		.instanceId = source.instanceId,
		.vendorId = source.vendorId,
		.productId = source.productId,
		.productVersion = source.productVersion,
		.axisCount = source.axisCount,
		.buttonCount = source.buttonCount,
		.hatCount = source.hatCount,
		.vibrationSupported = source.vibrationSupported,
	};
}

float LoveNode::getJoystickAxis(int id, int axis) const
{
	return SharedController.getControllerAxis(id, axis);
}

int LoveNode::getJoystickHat(int id, int hat) const
{
	return SharedController.getControllerHat(id, hat);
}

bool LoveNode::isJoystickButtonDown(int id, int button) const
{
	return SharedController.isControllerButtonPressed(id, button);
}

bool LoveNode::setJoystickVibration(int id, float left, float right, double duration)
{
	return SharedController.setControllerVibration(id, left, right, duration);
}

bool LoveNode::setGamepadMapping(std::string_view guid, std::string_view gamepadInput,
	std::string_view inputType, int index, std::string_view hat, std::string &error)
{
	return SharedController.setGamepadMapping(guid, gamepadInput, inputType, index, hat, error);
}

bool LoveNode::loadGamepadMappings(std::string_view mappings, std::string &error)
{
	return SharedController.loadGamepadMappings(mappings, error);
}

std::string LoveNode::saveGamepadMappings() const
{
	return SharedController.saveGamepadMappings();
}

std::string LoveNode::getGamepadMappingString(std::string_view guid) const
{
	return SharedController.getGamepadMappingString(guid);
}

std::optional<Love::JoystickBackend::GamepadMapping> LoveNode::getJoystickGamepadMapping(
	int id, std::string_view gamepadInput) const
{
	const auto mapping = SharedController.getControllerGamepadMapping(id, gamepadInput);
	if (!mapping) return std::nullopt;
	return Love::JoystickBackend::GamepadMapping{
		.inputType = mapping->inputType,
		.index = mapping->index,
		.hat = mapping->hat,
	};
}

std::string LoveNode::getJoystickGamepadMappingString(int id) const
{
	return SharedController.getControllerGamepadMappingString(id);
}

std::string LoveNode::getOS() const
{
	const auto platform = SharedApplication.getPlatform();
	if (platform == "macOS"_slice) return "OS X";
	if (platform == "iOS"_slice) return "iOS";
	if (platform == "Windows"_slice) return "Windows";
	if (platform == "Android"_slice) return "Android";
	if (platform == "Linux"_slice) return "Linux";
	return "Unknown";
}

int LoveNode::getProcessorCount() const
{
	return std::max(1, SDL_GetCPUCount());
}

bool LoveNode::setClipboardText(std::string_view text, std::string &error)
{
	if (text.find('\0') != std::string_view::npos)
	{
		error = "clipboard text must not contain NUL bytes";
		return false;
	}
	const std::string value(text);
	if (SDL_SetClipboardText(value.c_str()) != 0)
	{
		error = std::string("failed to set clipboard text: ") + SDL_GetError();
		return false;
	}
	error.clear();
	return true;
}

bool LoveNode::getClipboardText(std::string &text, std::string &error) const
{
	char *value = SDL_GetClipboardText();
	if (!value)
	{
		error = std::string("failed to get clipboard text: ") + SDL_GetError();
		return false;
	}
	text.assign(value);
	SDL_free(value);
	error.clear();
	return true;
}

Love::SystemBackend::PowerInfo LoveNode::getPowerInfo() const
{
	int seconds = -1;
	int percent = -1;
	const SDL_PowerState state = SDL_GetPowerInfo(&seconds, &percent);
	Love::SystemBackend::PowerInfo info;
	info.percent = percent;
	info.seconds = seconds;
	switch (state)
	{
		case SDL_POWERSTATE_ON_BATTERY: info.state = Love::SystemBackend::PowerState::Battery; break;
		case SDL_POWERSTATE_NO_BATTERY: info.state = Love::SystemBackend::PowerState::NoBattery; break;
		case SDL_POWERSTATE_CHARGING: info.state = Love::SystemBackend::PowerState::Charging; break;
		case SDL_POWERSTATE_CHARGED: info.state = Love::SystemBackend::PowerState::Charged; break;
		case SDL_POWERSTATE_UNKNOWN: info.state = Love::SystemBackend::PowerState::Unknown; break;
	}
	return info;
}

bool LoveNode::openURL(std::string_view url, std::string &error)
{
	if (url.empty() || url.size() > 8192 || url.find('\0') != std::string_view::npos
		|| std::any_of(url.begin(), url.end(), [](char c) {
			return static_cast<unsigned char>(c) < 0x20 || c == 0x7f;
		}))
	{
		error = "URL is empty, too long, or contains control characters";
		return false;
	}
	const auto separator = url.find(':');
	if (separator == std::string_view::npos)
	{
		error = "URL must include a scheme";
		return false;
	}
	std::string scheme(url.substr(0, separator));
	std::transform(scheme.begin(), scheme.end(), scheme.begin(), [](unsigned char c) {
		return static_cast<char>(std::tolower(c));
	});
	if (scheme != "http" && scheme != "https" && scheme != "mailto")
	{
		error = "URL scheme is not allowed by the embedded LoveNode host";
		return false;
	}
	SharedApplication.openURL(std::string(url));
	error.clear();
	return true;
}

void LoveNode::vibrate(double seconds)
{
	SharedApplication.vibrate(seconds);
}

bool LoveNode::hasBackgroundMusic() const
{
	return SharedApplication.hasBackgroundMusic();
}

void LoveNode::releaseInputFocus()
{
	if (_runtime)
	{
		for (const auto &key : _hostPressedKeys)
			_runtime->queueKeyReleased(key, key);
		for (const auto &[controllerId, buttons] : _hostPressedControllerButtons)
		{
			for (const auto &button : buttons)
				_runtime->queueGamepadReleased(controllerId, button);
		}
		for (const auto &[controllerId, axes] : _hostActiveControllerAxes)
		{
			for (const auto &axis : axes)
				_runtime->queueGamepadAxis(controllerId, axis, 0.0f);
		}
		for (const auto &[controllerId, buttons] : _hostPressedJoystickButtons)
		{
			for (const int button : buttons)
				_runtime->queueJoystickReleased(controllerId, button);
		}
		for (const auto &[controllerId, axes] : _hostActiveJoystickAxes)
		{
			for (const int axis : axes)
				_runtime->queueJoystickAxis(controllerId, axis, 0.0f);
		}
		for (const auto &[controllerId, hats] : _hostActiveJoystickHats)
		{
			for (const int hat : hats)
				_runtime->queueJoystickHat(controllerId, hat, "c");
		}
	}
	_hostPressedKeys.clear();
	_hostPressedControllerButtons.clear();
	_hostActiveControllerAxes.clear();
	_hostPressedJoystickButtons.clear();
	_hostActiveJoystickAxes.clear();
	_hostActiveJoystickHats.clear();
	setKeyboardEnabled(false);
	detachIME();
	resetHostMouseSettings();
}

void LoveNode::handleKeyboardEvent(Event *event)
{
	if (!_runtime || FocusedLoveNode != this)
		return;
	Slice doraName;
	if (event->getName() == "TextEditing"_slice)
	{
		int start = 0;
		int length = 0;
		if (event->get(doraName, start, length))
			_runtime->queueTextEdited(doraName.toString(), start, length);
		return;
	}
	if (!event->get(doraName))
		return;
	if (event->getName() == "TextInput"_slice)
	{
		_runtime->queueTextInput(doraName.toString());
		return;
	}
	const std::string loveName = toLoveKeyName(doraName);
	if (event->getName() == "KeyDown"_slice)
	{
		_hostPressedKeys.insert(loveName);
		_runtime->queueKeyPressed(loveName, loveName, false);
	}
	else if (event->getName() == "KeyRepeat"_slice)
	{
		const bool repeat = _hostPressedKeys.contains(loveName);
		_hostPressedKeys.insert(loveName);
		_runtime->queueKeyPressed(loveName, loveName, repeat);
	}
	else
	{
		_hostPressedKeys.erase(loveName);
		_runtime->queueKeyReleased(loveName, loveName);
	}
}

void LoveNode::handleControllerEvent(Event *event)
{
	if (!_runtime)
		return;
	const String eventName = event->getName();
	if (eventName == "ControllerAdded"_slice)
	{
		int controllerId = -1;
		Slice name;
		if (event->get(controllerId, name))
			_runtime->addJoystick(controllerId, name.toString(), true);
		return;
	}
	if (eventName == "ControllerRemoved"_slice)
	{
		int controllerId = -1;
		if (event->get(controllerId))
		{
			_hostPressedControllerButtons.erase(controllerId);
			_hostActiveControllerAxes.erase(controllerId);
			_hostPressedJoystickButtons.erase(controllerId);
			_hostActiveJoystickAxes.erase(controllerId);
			_hostActiveJoystickHats.erase(controllerId);
			_runtime->removeJoystick(controllerId, true);
		}
		return;
	}
	if (FocusedLoveNode != this)
		return;
	if (eventName == "JoystickAxis"_slice)
	{
		int controllerId = -1;
		int axis = -1;
		float value = 0.0f;
		if (event->get(controllerId, axis, value))
		{
			if (std::abs(value) > 0.0001f)
				_hostActiveJoystickAxes[controllerId].insert(axis);
			else if (auto found = _hostActiveJoystickAxes.find(controllerId);
				found != _hostActiveJoystickAxes.end())
			{
				found->second.erase(axis);
				if (found->second.empty()) _hostActiveJoystickAxes.erase(found);
			}
			_runtime->queueJoystickAxis(controllerId, axis, value);
		}
		return;
	}
	if (eventName == "JoystickHat"_slice)
	{
		int controllerId = -1;
		int hat = -1;
		int value = 0;
		if (event->get(controllerId, hat, value))
		{
			const char *direction = "c";
			switch (value)
			{
				case 1: direction = "u"; break;
				case 2: direction = "r"; break;
				case 4: direction = "d"; break;
				case 8: direction = "l"; break;
				case 3: direction = "ru"; break;
				case 6: direction = "rd"; break;
				case 9: direction = "lu"; break;
				case 12: direction = "ld"; break;
				default: break;
			}
			if (value == 0)
			{
				if (auto found = _hostActiveJoystickHats.find(controllerId);
					found != _hostActiveJoystickHats.end())
				{
					found->second.erase(hat);
					if (found->second.empty()) _hostActiveJoystickHats.erase(found);
				}
			}
			else _hostActiveJoystickHats[controllerId].insert(hat);
			_runtime->queueJoystickHat(controllerId, hat, direction);
		}
		return;
	}
	if (eventName == "JoystickButtonDown"_slice || eventName == "JoystickButtonUp"_slice)
	{
		int controllerId = -1;
		int button = -1;
		if (event->get(controllerId, button))
		{
			if (eventName == "JoystickButtonDown"_slice)
			{
				_hostPressedJoystickButtons[controllerId].insert(button);
				_runtime->queueJoystickPressed(controllerId, button);
			}
			else
			{
				if (auto found = _hostPressedJoystickButtons.find(controllerId);
					found != _hostPressedJoystickButtons.end())
				{
					found->second.erase(button);
					if (found->second.empty()) _hostPressedJoystickButtons.erase(found);
				}
				_runtime->queueJoystickReleased(controllerId, button);
			}
		}
		return;
	}
	if (eventName == "Axis"_slice)
	{
		int controllerId = -1;
		Slice axis;
		float value = 0.0f;
		if (event->get(controllerId, axis, value))
		{
			const std::string axisName = axis.toString();
			if (std::abs(value) > 0.0001f)
				_hostActiveControllerAxes[controllerId].insert(axisName);
			else if (auto found = _hostActiveControllerAxes.find(controllerId); found != _hostActiveControllerAxes.end())
			{
				found->second.erase(axisName);
				if (found->second.empty())
					_hostActiveControllerAxes.erase(found);
			}
			_runtime->queueGamepadAxis(controllerId, axisName, value);
		}
		return;
	}
	int controllerId = -1;
	Slice button;
	if (!event->get(controllerId, button))
		return;
	const std::string buttonName = button.toString();
	if (eventName == "ButtonDown"_slice)
	{
		_hostPressedControllerButtons[controllerId].insert(buttonName);
		_runtime->queueGamepadPressed(controllerId, buttonName);
	}
	else if (eventName == "ButtonUp"_slice)
	{
		if (auto found = _hostPressedControllerButtons.find(controllerId); found != _hostPressedControllerButtons.end())
		{
			found->second.erase(buttonName);
			if (found->second.empty())
				_hostPressedControllerButtons.erase(found);
		}
		_runtime->queueGamepadReleased(controllerId, buttonName);
	}
}

void LoveNode::handlePointerEvent(Event *event)
{
	if (!_runtime)
		return;
	const String name = event->getName();
	if (name == "MouseWheel"_slice)
	{
		if (auto *args = DoraAs<EventArgs<Vec2>>(event))
		{
			const Vec2 delta = std::get<0>(args->arguments);
			_runtime->queueWheelMoved(delta.x, delta.y);
		}
		return;
	}
	Touch *touch = nullptr;
	if (!event->get(touch) || !touch)
		return;
	const Vec2 location = touch->getLocation();
	// Touch::getDelta() is expressed in Dora world space. Love mouse/touch
	// coordinates and their deltas must use the same LoveNode-local space,
	// especially when the embedded surface is scaled or rotated by its host.
	const Vec2 delta = location - touch->getPreLocation();
	const float loveY = static_cast<float>(getPixelHeight()) - location.y;
	if (!touch->isFromMouse())
	{
		const std::uintptr_t touchId = static_cast<std::uintptr_t>(touch->getId()) + 1;
		if (name == "TapBegan"_slice)
		{
			focusInput();
			_runtime->queueTouchPressed(touchId, location.x, loveY, delta.x, -delta.y);
		}
		else if (name == "TapEnded"_slice)
			_runtime->queueTouchReleased(touchId, location.x, loveY, delta.x, -delta.y);
		else if (name == "TapMoved"_slice)
			_runtime->queueTouchMoved(touchId, location.x, loveY, delta.x, -delta.y);
		return;
	}
	if (name == "TapBegan"_slice)
	{
		focusInput();
		_runtime->queueMousePressed(location.x, loveY, touch->getMouseButton(), false, touch->getClickCount());
	}
	else if (name == "TapEnded"_slice)
		_runtime->queueMouseReleased(location.x, loveY, touch->getMouseButton(), false, touch->getClickCount());
	else if (name == "MouseMove"_slice)
		_runtime->queueMouseMoved(location.x, loveY, delta.x, -delta.y, false);
}

String LoveNode::getLastError() const noexcept
{
	if (_runtime && !_runtime->getLastError().empty())
		return _runtime->getLastError();
	return _lastError;
}

bool LoveNode::isRunning() const noexcept
{
	return _runtime && _runtime->getStatus() == Love::LoveRuntime::Status::Running;
}

void LoveNode::beginFrame()
{
	_renderPasses.clear();
	_graphicsStats.drawCalls = 0;
	_graphicsStats.drawCallsBatched = 0;
	_graphicsStats.canvasSwitches = 0;
	_graphicsStats.shaderSwitches = 0;
	_graphicsFrameActive = true;
	beginRenderPass(_activeCanvas == 0
		? BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL
		: BGFX_CLEAR_NONE, _clearColor);
	if (!_pendingCanvasMipmaps.empty())
	{
		const auto pending = std::move(_pendingCanvasMipmaps);
		_pendingCanvasMipmaps.clear();
		for (const auto canvas : pending)
		{
			std::string ignored;
			generateCanvasMipmaps(canvas, ignored);
		}
	}
}

void LoveNode::beginRenderPass(uint16_t clearFlags, Color clearColor, uint8_t stencil,
	float depth)
{
	RenderTarget *target = getActiveRenderTarget();
	_frameRoot = Node::create();
	// Render-pass roots are internal command buffers. Mark every newly-created root as
	// managed before the Director can adopt an unparented node into the host scene.
	_frameRoot->setAsManaged();
	RenderPass pass;
	pass.target = target;
	pass.root = _frameRoot;
	pass.clearColor = clearColor;
	pass.clearFlags = clearFlags;
	pass.stencil = stencil;
	pass.depth = depth;
	_renderPasses.push_back(std::move(pass));
	_commandRoot = _frameRoot;
	_drawNode = nullptr;
	beginCommandSegment();
}

void LoveNode::markRenderCommand()
{
	if (!_renderPasses.empty())
		_renderPasses.back().hasCommands = true;
	++_graphicsStats.drawCalls;
	_spriteBatchTexture = nullptr;
	_spriteBatchCommandRoot = nullptr;
}

void LoveNode::markSpriteRenderCommand(Texture2D *texture,
	Love::GraphicsBackend::TextureFilter filter,
	Love::GraphicsBackend::TextureWrap wrapU,
	Love::GraphicsBackend::TextureWrap wrapV)
{
	Node *commandRoot = _commandRoot ? _commandRoot.get() : _frameRoot.get();
	if (_activeShader == 0
		&& _spriteBatchTexture == texture
		&& _spriteBatchCommandRoot == commandRoot
		&& _spriteBatchFilter == filter
		&& _spriteBatchWrapU == wrapU
		&& _spriteBatchWrapV == wrapV
		&& _spriteBatchBlendMode == _blendMode
		&& _spriteBatchBlendAlphaMode == _blendAlphaMode)
	{
		++_graphicsStats.drawCallsBatched;
		return;
	}
	markRenderCommand();
	if (_activeShader == 0)
	{
		_spriteBatchTexture = texture;
		_spriteBatchCommandRoot = commandRoot;
		_spriteBatchFilter = filter;
		_spriteBatchWrapU = wrapU;
		_spriteBatchWrapV = wrapV;
		_spriteBatchBlendMode = _blendMode;
		_spriteBatchBlendAlphaMode = _blendAlphaMode;
	}
}

DrawNode *LoveNode::ensureDrawNode()
{
	if (!_drawNode)
	{
		markRenderCommand();
		_drawNode = DrawNode::create();
		_drawNode->setBlendFunc(toDoraBlendFunc(_blendMode, _blendAlphaMode));
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(_drawNode);
	}
	else ++_graphicsStats.drawCallsBatched;
	return _drawNode;
}

std::optional<RendererManager::ScissorState> LoveNode::getCommandScissor() const
{
	std::optional<RendererManager::ScissorState> scissor;
	if (_scissorEnabled)
	{
		const int targetWidth = getActiveRenderTarget()->getWidth();
		const int targetHeight = getActivePixelHeight();
		const int requestedX = static_cast<int>(_scissor.origin.x);
		const int requestedY = static_cast<int>(_scissor.origin.y);
		const int requestedWidth = static_cast<int>(_scissor.size.width);
		const int requestedHeight = static_cast<int>(_scissor.size.height);
		const int left = std::clamp(requestedX, 0, targetWidth);
		const int top = std::clamp(requestedY, 0, targetHeight);
		const int right = std::clamp(requestedX + requestedWidth, 0, targetWidth);
		const int bottom = std::clamp(requestedY + requestedHeight, 0, targetHeight);
		scissor = RendererManager::ScissorState{
			static_cast<uint16_t>(left), static_cast<uint16_t>(top),
			static_cast<uint16_t>(std::max(0, right - left)),
			static_cast<uint16_t>(std::max(0, bottom - top))};
	}
	return scissor;
}

void LoveNode::beginCommandSegment()
{
	_drawNode = nullptr;
	_spriteBatchTexture = nullptr;
	_spriteBatchCommandRoot = nullptr;
	auto scissor = getCommandScissor();
	uint32_t stencilState = BGFX_STENCIL_NONE;
	if (_stencilWriting)
	{
		stencilState = BGFX_STENCIL_TEST_ALWAYS
			| BGFX_STENCIL_FUNC_REF(static_cast<uint8_t>(_stencilWriteValue))
			| BGFX_STENCIL_FUNC_RMASK(0xff)
			| BGFX_STENCIL_OP_FAIL_S_KEEP | BGFX_STENCIL_OP_FAIL_Z_KEEP
			| toStencilAction(_stencilAction);
	}
	else if (_stencilCompare != "always")
	{
		stencilState = toStencilTest(_stencilCompare)
			| BGFX_STENCIL_FUNC_REF(static_cast<uint8_t>(_stencilTestValue))
			| BGFX_STENCIL_FUNC_RMASK(0xff)
			| BGFX_STENCIL_OP_FAIL_S_KEEP | BGFX_STENCIL_OP_FAIL_Z_KEEP
			| BGFX_STENCIL_OP_PASS_Z_KEEP;
	}
	uint64_t renderState = toDepthState(_depthCompare, _depthWrite)
		| toCullState(_meshCullMode, _frontFaceWinding);
	if (!_stencilWriting)
	{
		if (_colorMask[0]) renderState |= BGFX_STATE_WRITE_R;
		if (_colorMask[1]) renderState |= BGFX_STATE_WRITE_G;
		if (_colorMask[2]) renderState |= BGFX_STATE_WRITE_B;
		if (_colorMask[3]) renderState |= BGFX_STATE_WRITE_A;
	}
	_commandRoot = LoveRenderStateNode::create(scissor, stencilState, renderState);
	_frameRoot->addChild(_commandRoot);
}

bool LoveNode::clear(const Love::GraphicsBackend::ClearRequest &request,
	std::string &error)
{
	using ClearColor = Love::GraphicsBackend::ClearColor;
	struct TargetColor
	{
		RenderTarget *target = nullptr;
		ClearColor color;
	};
	RenderTarget *activeTarget = getActiveRenderTarget();
	if (!activeTarget)
	{
		error = "Love clear target is unavailable";
		return false;
	}
	std::vector<RenderTarget *> colorTargets;
	if (_activeCanvas == 0)
		colorTargets.push_back(activeTarget);
	else
	{
		colorTargets.reserve(_activeCanvasTargets.size());
		for (const auto &canvas : _activeCanvasTargets)
		{
			auto found = _canvases.find(canvas.canvas);
			if (found == _canvases.end() || !found->second.texture)
			{
				error = "Love Canvas clear target is closed";
				return false;
			}
			auto &resource = found->second;
			if (_activeCanvasTargets.size() == 1)
				colorTargets.push_back(activeTarget);
			else if (canvas.slice == 0 && canvas.mipmap == 0 && resource.target)
				colorTargets.push_back(resource.target);
			else
			{
				const auto key = std::pair{canvas.slice, canvas.mipmap};
				auto target = resource.targets.find(key);
				if (target == resource.targets.end())
				{
					const uint8_t resolve = resource.mipmapMode == "auto" && canvas.mipmap == 0
						? BGFX_RESOLVE_AUTO_GEN_MIPS : BGFX_RESOLVE_NONE;
					std::vector<RenderTarget::Attachment> attachments{{resource.texture,
						static_cast<uint16_t>(canvas.slice), static_cast<uint16_t>(canvas.mipmap), resolve}};
					auto *created = RenderTarget::create(std::move(attachments), std::nullopt);
					if (!created)
					{
						error = "Dora/bgfx failed to create a Love Canvas subresource clear target";
						return false;
					}
					target = resource.targets.emplace(key, created).first;
				}
				colorTargets.push_back(target->second);
			}
		}
	}
	std::vector<TargetColor> targetColors;
	if (request.colorsPerAttachment)
	{
		const std::size_t count = std::min(request.colors.size(), colorTargets.size());
		for (std::size_t index = 0; index < count; ++index)
			if (request.colors[index].enabled)
				targetColors.push_back({colorTargets[index], request.colors[index]});
	}
	else if (!request.colors.empty() && request.colors.front().enabled)
	{
		for (auto *target : colorTargets)
			targetColors.push_back({target, request.colors.front()});
	}

	const bool fullColorMask = std::all_of(std::begin(_colorMask), std::end(_colorMask),
		[](bool enabled) { return enabled; });
	const bool anyColorWrite = std::any_of(std::begin(_colorMask), std::end(_colorMask),
		[](bool enabled) { return enabled; });
	if (_activeCanvas == 0 && !_scissorEnabled && !targetColors.empty())
	{
		const auto &value = targetColors.front().color;
		const Color color(Vec4{value.red, value.green, value.blue, value.alpha});
		if (fullColorMask)
			_clearColor = color;
		else
		{
			if (_colorMask[0]) _clearColor.r = color.r;
			if (_colorMask[1]) _clearColor.g = color.g;
			if (_colorMask[2]) _clearColor.b = color.b;
			if (_colorMask[3]) _clearColor.a = color.a;
		}
	}
	if (!_graphicsFrameActive || _renderPasses.empty())
	{
		error.clear();
		return true;
	}

	const bool viewColorClear = !targetColors.empty() && anyColorWrite && fullColorMask
		&& !_scissorEnabled && (!request.colorsPerAttachment || colorTargets.size() == 1);
	uint16_t viewFlags = BGFX_CLEAR_NONE;
	Color viewColor(0x00000000);
	if (viewColorClear)
	{
		viewFlags |= BGFX_CLEAR_COLOR;
		const auto &value = targetColors.front().color;
		viewColor = Color(Vec4{value.red, value.green, value.blue, value.alpha});
	}
	if (!_scissorEnabled && request.clearDepth) viewFlags |= BGFX_CLEAR_DEPTH;
	if (!_scissorEnabled && request.clearStencil) viewFlags |= BGFX_CLEAR_STENCIL;
	if (viewFlags != BGFX_CLEAR_NONE)
	{
		if (_renderPasses.back().hasCommands)
			beginRenderPass(viewFlags, viewColor, static_cast<uint8_t>(request.stencil),
				std::clamp(request.depth, 0.0f, 1.0f));
		else
		{
			_renderPasses.back().clearFlags |= viewFlags;
			if ((viewFlags & BGFX_CLEAR_COLOR) != 0)
				_renderPasses.back().clearColor = viewColor;
			if ((viewFlags & BGFX_CLEAR_STENCIL) != 0)
				_renderPasses.back().stencil = static_cast<uint8_t>(request.stencil);
			if ((viewFlags & BGFX_CLEAR_DEPTH) != 0)
				_renderPasses.back().depth = std::clamp(request.depth, 0.0f, 1.0f);
		}
	}

	const bool drawDepthStencil = _scissorEnabled
		&& (request.clearDepth || request.clearStencil);
	std::vector<TargetColor> drawColors;
	if (!viewColorClear && anyColorWrite)
		drawColors = targetColors;
	if (!drawDepthStencil && drawColors.empty())
	{
		error.clear();
		return true;
	}

	Texture2D *whiteTexture = ensureWhiteTexture(error);
	if (!whiteTexture) return false;
	const auto scissor = getCommandScissor();
	auto appendDrawClear = [&](RenderTarget *target, const ClearColor *color,
		bool clearDepth, bool clearStencil) {
		uint64_t renderState = BGFX_STATE_NONE;
		if (color)
		{
			if (_colorMask[0]) renderState |= BGFX_STATE_WRITE_R;
			if (_colorMask[1]) renderState |= BGFX_STATE_WRITE_G;
			if (_colorMask[2]) renderState |= BGFX_STATE_WRITE_B;
			if (_colorMask[3]) renderState |= BGFX_STATE_WRITE_A;
		}
		if (clearDepth)
			renderState |= BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_ALWAYS;
		uint32_t stencilState = BGFX_STENCIL_NONE;
		if (clearStencil)
		{
			stencilState = BGFX_STENCIL_TEST_ALWAYS
				| BGFX_STENCIL_FUNC_REF(static_cast<uint8_t>(request.stencil))
				| BGFX_STENCIL_FUNC_RMASK(0xff)
				| BGFX_STENCIL_OP_FAIL_S_KEEP
				| BGFX_STENCIL_OP_FAIL_Z_REPLACE
				| BGFX_STENCIL_OP_PASS_Z_REPLACE;
		}
		const float width = static_cast<float>(target->getWidth());
		const float height = static_cast<float>(target->getHeight());
		const float z = clearDepth
			? -1000.0f + 2000.0f * std::clamp(request.depth, 0.0f, 1.0f)
			: 0.0f;
		const uint32_t packedColor = color
			? Color(Vec4{color->red, color->green, color->blue, color->alpha}).toABGR()
			: Color(0xffffffff).toABGR();
		std::vector<SpriteVertex> vertices = {
			{0.0f, height, z, 1.0f, 0.0f, 0.0f, packedColor},
			{width, height, z, 1.0f, 0.0f, 0.0f, packedColor},
			{width, 0.0f, z, 1.0f, 0.0f, 0.0f, packedColor},
			{0.0f, 0.0f, z, 1.0f, 0.0f, 0.0f, packedColor},
		};
		std::vector<uint32_t> indices = {0, 1, 2, 0, 2, 3};
		auto *clearNode = LoveTexturedMeshNode::create(std::move(vertices), std::move(indices),
			whiteTexture, BlendFunc{BlendFunc::One, BlendFunc::Zero,
				BlendFunc::One, BlendFunc::Zero},
			meshSamplerFlags(whiteTexture, Love::GraphicsBackend::TextureFilter::Nearest,
				Love::GraphicsBackend::TextureWrap::Clamp,
				Love::GraphicsBackend::TextureWrap::Clamp), nullptr, true);
		auto *root = Node::create();
		root->setAsManaged();
		auto *stateRoot = LoveRenderStateNode::create(scissor, stencilState, renderState);
		stateRoot->addChild(clearNode);
		root->addChild(stateRoot);
		RenderPass pass;
		pass.target = target;
		pass.root = root;
		pass.hasCommands = true;
		_renderPasses.push_back(std::move(pass));
	};

	if (drawDepthStencil)
		appendDrawClear(activeTarget, nullptr, request.clearDepth, request.clearStencil);
	for (const auto &entry : drawColors)
		appendDrawClear(entry.target, &entry.color, false, false);
	beginRenderPass(BGFX_CLEAR_NONE, Color(0x00000000));
	error.clear();
	return true;
}

bool LoveNode::rectangle(bool fill, float x, float y, float width, float height,
	float lineWidth, Love::GraphicsBackend::LineStyle lineStyle,
	Love::GraphicsBackend::LineJoin lineJoin, float red, float green, float blue,
	float alpha, std::string &error)
{
	const Vec2 vertices[] = {
		{x, y},
		{x + width, y},
		{x + width, y + height},
		{x, y + height},
	};
	const Color color(Vec4{red, green, blue, alpha});
	if (!fill)
		return drawPolyline(vertices, true, lineWidth, lineStyle, lineJoin,
			Love::GraphicsBackend::Transform2D{}, color, error);
	std::array<Vec2, 4> transformed;
	for (std::size_t index = 0; index < transformed.size(); ++index)
		transformed[index] = transformLovePoint(vertices[index], {},
			static_cast<float>(getActivePixelHeight()));
	if (_activeShader != 0 || _wireframe)
		return drawShaderPrimitive(transformed, true, true, lineWidth, color, error);
	ensureDrawNode()->drawPolygon(transformed.data(), 4,
		color, 0.0f, Color(0x00000000));
	error.clear();
	return true;
}

bool LoveNode::circle(bool fill, float x, float y, float radius,
	float lineWidth, Love::GraphicsBackend::LineStyle lineStyle,
	Love::GraphicsBackend::LineJoin lineJoin, float red, float green, float blue,
	float alpha, std::string &error)
{
	const Color color(Vec4{red, green, blue, alpha});
	const Vec2 center{x, y};
	if (fill && _activeShader == 0)
	{
		ensureDrawNode()->drawDot(transformLovePoint(center, {},
			static_cast<float>(getActivePixelHeight())), radius, color);
		error.clear();
		return true;
	}

	constexpr int segments = 48;
	std::vector<Vec2> vertices;
	vertices.reserve(segments);
	for (int i = 0; i < segments; ++i)
	{
		const float angle = static_cast<float>(i) * 2.0f * std::numbers::pi_v<float> / segments;
		vertices.emplace_back(center.x + std::cos(angle) * radius, center.y + std::sin(angle) * radius);
	}
	if (!fill)
		return drawPolyline(vertices, true, lineWidth, lineStyle, lineJoin,
			Love::GraphicsBackend::Transform2D{}, color, error);
	for (auto &vertex : vertices)
		vertex = transformLovePoint(vertex, {}, static_cast<float>(getActivePixelHeight()));
	if (_activeShader != 0 || _wireframe)
		return drawShaderPrimitive(vertices, true, true, lineWidth, color, error);
	ensureDrawNode()->drawPolygon(vertices, color, 0.0f, Color(0x00000000));
	error.clear();
	return true;
}

bool LoveNode::line(const std::vector<float> &points,
	const Love::GraphicsBackend::Transform2D &transform, float lineWidth,
	Love::GraphicsBackend::LineStyle lineStyle, Love::GraphicsBackend::LineJoin lineJoin,
	float red, float green, float blue, float alpha, std::string &error)
{
	const Color color(Vec4{red, green, blue, alpha});
	std::vector<Vec2> vertices;
	vertices.reserve(points.size() / 2);
	for (size_t i = 0; i < points.size(); i += 2)
		vertices.emplace_back(points[i], points[i + 1]);
	const bool closed = vertices.size() > 2 && vertices.front() == vertices.back();
	if (closed) vertices.pop_back();
	return drawPolyline(vertices, closed, lineWidth, lineStyle, lineJoin, transform, color, error);
}

bool LoveNode::polygon(bool fill, const std::vector<float> &points,
	const Love::GraphicsBackend::Transform2D &transform, float lineWidth,
	Love::GraphicsBackend::LineStyle lineStyle, Love::GraphicsBackend::LineJoin lineJoin,
	float red, float green, float blue, float alpha, std::string &error)
{
	std::vector<Vec2> vertices;
	vertices.reserve(points.size() / 2);
	for (size_t i = 0; i < points.size(); i += 2)
		vertices.emplace_back(points[i], points[i + 1]);
	const Color color(Vec4{red, green, blue, alpha});
	if (!fill)
		return drawPolyline(vertices, true, lineWidth, lineStyle, lineJoin, transform, color, error);
	for (auto &vertex : vertices)
		vertex = transformLovePoint(vertex, transform, static_cast<float>(getActivePixelHeight()));
	if (_activeShader != 0 || _wireframe)
		return drawShaderPrimitive(vertices, true, true, lineWidth, color, error);
	ensureDrawNode()->drawPolygon(vertices,
		color, 0.0f, Color(0x00000000));
	error.clear();
	return true;
}

bool LoveNode::points(const std::vector<float> &points, float pointSize,
	float red, float green, float blue, float alpha, std::string &error)
{
	const float height = static_cast<float>(getActivePixelHeight());
	const Color color(Vec4{red, green, blue, alpha});
	if (_activeShader != 0)
	{
		std::vector<Vec2> vertices;
		vertices.reserve(points.size() / 2);
		for (size_t i = 0; i < points.size(); i += 2)
			vertices.emplace_back(points[i] + 0.5f, height - points[i + 1] + 0.5f);
		return drawShaderPoints(vertices, pointSize, color, error);
	}
	for (size_t i = 0; i < points.size(); i += 2)
		// DrawNode rasterizes around pixel boundaries at integer coordinates. Love points use
		// pixel centers, so the half-pixel offset keeps a size-1 point visible and makes odd
		// point sizes cover the requested pixel diameter.
		ensureDrawNode()->drawDot({points[i] + 0.5f, height - points[i + 1] + 0.5f}, pointSize * 0.5f, color);
	error.clear();
	return true;
}

Love::GraphicsBackend::ImageHandle LoveNode::newImage(const std::string &filename, std::string &error)
{
	std::string fullPath;
	if (!_runtime || !_runtime->resolveReadPath(filename, fullPath, error))
		return 0;
	std::string encoded;
	if (!load(fullPath, encoded, error))
		return 0;
	int width = 0;
	int height = 0;
	std::vector<std::uint8_t> rgba8;
	if (!decodeImage(encoded, width, height, rgba8, error))
	{
		error = "Dora Content/bimg failed to decode Image '" + filename
			+ "' (format '" + Path::getExt(filename) + "') in LoveNode '" + _bootFile + "'";
		return 0;
	}
	return newImage(Love::GraphicsBackend::TextureType::Texture2D,
		width, height, 1, rgba8, error);
}

Love::GraphicsBackend::ImageHandle LoveNode::newImage(Love::GraphicsBackend::TextureType type,
	int width, int height, int slices, std::span<const std::uint8_t> rgba8, std::string &error)
{
	Love::GraphicsBackend::ImageLevel level;
	level.width = width;
	level.height = height;
	level.slices = slices;
	level.rgba8.assign(rgba8.begin(), rgba8.end());
	return newImage(type, std::span<const Love::GraphicsBackend::ImageLevel>(&level, 1), error);
}

Love::GraphicsBackend::ImageHandle LoveNode::newImage(Love::GraphicsBackend::TextureType type,
	std::span<const Love::GraphicsBackend::ImageLevel> levels, std::string &error)
{
	if (levels.empty())
	{
		error = "Love Image requires at least one image level";
		return 0;
	}
	const auto &base = levels.front();
	const int width = base.width;
	const int height = base.height;
	const int slices = base.slices;
	int largestDimension = std::max(width, height);
	if (type == Love::GraphicsBackend::TextureType::Volume)
		largestDimension = std::max(largestDimension, slices);
	int expectedMipmaps = 1;
	for (int dimension = largestDimension; dimension > 1; dimension >>= 1)
		++expectedMipmaps;
	if (levels.size() != 1 && static_cast<int>(levels.size()) != expectedMipmaps)
	{
		error = "Love Image requires either only the base level or a complete mipmap chain";
		return 0;
	}
	if (type == Love::GraphicsBackend::TextureType::Cube && (slices != 6 || width != height))
	{
		error = "CubeImage requires six square faces";
		return 0;
	}
	if (width <= 0 || height <= 0 || slices <= 0 || width > UINT16_MAX
		|| height > UINT16_MAX || slices > UINT16_MAX || levels.size() > UINT8_MAX)
	{
		error = "Love Image exceeds Dora/bgfx texture limits";
		return 0;
	}
	for (std::size_t mip = 0; mip < levels.size(); ++mip)
	{
		const auto &level = levels[mip];
		const int expectedWidth = std::max(1, width >> mip);
		const int expectedHeight = std::max(1, height >> mip);
		const int expectedSlices = type == Love::GraphicsBackend::TextureType::Volume
			? std::max(1, slices >> mip) : slices;
		if (level.width != expectedWidth || level.height != expectedHeight
			|| level.slices != expectedSlices
			|| level.rgba8.size() != static_cast<std::size_t>(level.width)
				* level.height * level.slices * 4 || level.rgba8.size() > UINT32_MAX)
		{
			error = "Love Image has an invalid or incomplete RGBA8 mipmap level";
			return 0;
		}
	}
	const bool cube = type == Love::GraphicsBackend::TextureType::Cube;
	const bool hasMipmaps = levels.size() > 1;
	const uint16_t depth = type == Love::GraphicsBackend::TextureType::Volume
		? static_cast<uint16_t>(slices) : 1;
	const uint16_t layers = type == Love::GraphicsBackend::TextureType::Array
		? static_cast<uint16_t>(slices) : 1;
	if (!bgfx::isTextureValid(depth, cube, layers, bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE))
	{
		error = "the active Dora/bgfx renderer does not support this non-2D Love Image";
		return 0;
	}
	bgfx::TextureHandle gpu = BGFX_INVALID_HANDLE;
	switch (type)
	{
		case Love::GraphicsBackend::TextureType::Array:
			gpu = bgfx::createTexture2D(static_cast<uint16_t>(width), static_cast<uint16_t>(height),
				hasMipmaps, layers, bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE);
			break;
		case Love::GraphicsBackend::TextureType::Cube:
			gpu = bgfx::createTextureCube(static_cast<uint16_t>(width), hasMipmaps, 1,
				bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE);
			break;
		case Love::GraphicsBackend::TextureType::Volume:
			gpu = bgfx::createTexture3D(static_cast<uint16_t>(width), static_cast<uint16_t>(height),
				depth, hasMipmaps, bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE);
			break;
		case Love::GraphicsBackend::TextureType::Texture2D:
			gpu = bgfx::createTexture2D(static_cast<uint16_t>(width), static_cast<uint16_t>(height),
				hasMipmaps, 1, bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE);
			break;
	}
	if (!bgfx::isValid(gpu))
	{
		error = "bgfx failed to create the non-2D Love Image";
		return 0;
	}
	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info, static_cast<uint16_t>(width), static_cast<uint16_t>(height),
		depth, cube, hasMipmaps, layers, bgfx::TextureFormat::RGBA8);
	Texture2D *createdTexture = Texture2D::create(gpu, info, BGFX_TEXTURE_NONE);
	if (!createdTexture)
	{
		bgfx::destroy(gpu);
		error = "Dora failed to wrap the non-2D Love Image texture";
		return 0;
	}
	Ref<Texture2D> texture(createdTexture);
	for (std::size_t mip = 0; mip < levels.size(); ++mip)
	{
		const auto &level = levels[mip];
		const std::size_t sliceBytes = static_cast<std::size_t>(level.width) * level.height * 4;
		switch (type)
		{
			case Love::GraphicsBackend::TextureType::Array:
				for (int layer = 0; layer < level.slices; ++layer)
				{
					const auto offset = static_cast<std::size_t>(layer) * sliceBytes;
					bgfx::updateTexture2D(gpu, static_cast<uint16_t>(layer), static_cast<uint8_t>(mip), 0, 0,
						static_cast<uint16_t>(level.width), static_cast<uint16_t>(level.height),
						bgfx::copy(level.rgba8.data() + offset, static_cast<uint32_t>(sliceBytes)));
				}
				break;
			case Love::GraphicsBackend::TextureType::Cube:
				for (int face = 0; face < 6; ++face)
				{
					const auto offset = static_cast<std::size_t>(face) * sliceBytes;
					bgfx::updateTextureCube(gpu, 0, static_cast<uint8_t>(face), static_cast<uint8_t>(mip), 0, 0,
						static_cast<uint16_t>(level.width), static_cast<uint16_t>(level.height),
						bgfx::copy(level.rgba8.data() + offset, static_cast<uint32_t>(sliceBytes)));
				}
				break;
			case Love::GraphicsBackend::TextureType::Volume:
				bgfx::updateTexture3D(gpu, static_cast<uint8_t>(mip), 0, 0, 0,
					static_cast<uint16_t>(level.width), static_cast<uint16_t>(level.height),
					static_cast<uint16_t>(level.slices),
					bgfx::copy(level.rgba8.data(), static_cast<uint32_t>(level.rgba8.size())));
				break;
			case Love::GraphicsBackend::TextureType::Texture2D:
				bgfx::updateTexture2D(gpu, 0, static_cast<uint8_t>(mip), 0, 0,
					static_cast<uint16_t>(level.width), static_cast<uint16_t>(level.height),
					bgfx::copy(level.rgba8.data(), static_cast<uint32_t>(level.rgba8.size())));
				break;
		}
	}
	std::vector<Ref<Texture2D>> layerTextures;
	if (type == Love::GraphicsBackend::TextureType::Array)
	{
		layerTextures.reserve(static_cast<std::size_t>(slices));
		for (int layer = 0; layer < slices; ++layer)
		{
			const auto layerGpu = bgfx::createTexture2D(static_cast<uint16_t>(width),
				static_cast<uint16_t>(height), hasMipmaps, 1, bgfx::TextureFormat::RGBA8,
				BGFX_TEXTURE_NONE);
			if (!bgfx::isValid(layerGpu))
			{
				error = "bgfx failed to create a drawable Love ArrayImage layer";
				return 0;
			}
			bgfx::TextureInfo layerInfo;
			bgfx::calcTextureSize(layerInfo, static_cast<uint16_t>(width),
				static_cast<uint16_t>(height), 1, false, hasMipmaps, 1,
				bgfx::TextureFormat::RGBA8);
			Texture2D *layerTexture = Texture2D::create(layerGpu, layerInfo, BGFX_TEXTURE_NONE);
			if (!layerTexture)
			{
				bgfx::destroy(layerGpu);
				error = "Dora failed to wrap a drawable Love ArrayImage layer";
				return 0;
			}
			for (std::size_t mip = 0; mip < levels.size(); ++mip)
			{
				const auto &level = levels[mip];
				const std::size_t sliceBytes = static_cast<std::size_t>(level.width) * level.height * 4;
				const auto offset = static_cast<std::size_t>(layer) * sliceBytes;
				bgfx::updateTexture2D(layerGpu, 0, static_cast<uint8_t>(mip), 0, 0,
					static_cast<uint16_t>(level.width), static_cast<uint16_t>(level.height),
					bgfx::copy(level.rgba8.data() + offset, static_cast<uint32_t>(sliceBytes)));
			}
			layerTextures.emplace_back(layerTexture);
		}
	}
	const auto handle = _nextImageHandle++;
	_images.emplace(handle, ImageResource{texture, type, slices, std::move(layerTextures)});
	error.clear();
	return handle;
}

Love::GraphicsBackend::ImageHandle LoveNode::newCompressedImage(std::string_view format,
	int width, int height, int mipmapCount, std::span<const std::uint8_t> data,
	std::string &error)
{
	const auto textureFormat = toImageTextureFormat(format);
	if (!textureFormat)
	{
		error = "Love compressed Image format '" + std::string(format)
			+ "' has no Dora/bgfx mapping";
		return 0;
	}
	if (width <= 0 || height <= 0 || width > UINT16_MAX || height > UINT16_MAX
		|| mipmapCount <= 0 || mipmapCount > UINT8_MAX || data.empty()
		|| data.size() > UINT32_MAX)
	{
		error = "Love compressed Image has invalid dimensions, mipmap count, or data size";
		return 0;
	}
	const bool hasMipmaps = mipmapCount > 1;
	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info, static_cast<uint16_t>(width), static_cast<uint16_t>(height),
		1, false, hasMipmaps, 1, *textureFormat);
	if (info.numMips != mipmapCount || info.storageSize != data.size())
	{
		error = "Love compressed Image requires a complete mipmap chain with the exact block size"
			" expected by Dora/bgfx";
		return 0;
	}
	if (!isLoveCompressedTextureValid(1, false, 1, *textureFormat))
	{
		error = "the active Dora/bgfx renderer does not support Love compressed Image format '"
			+ std::string(format) + "'";
		return 0;
	}
	const bgfx::Memory *memory = bgfx::copy(data.data(), static_cast<uint32_t>(data.size()));
	const bgfx::TextureHandle gpu = bgfx::createTexture2D(static_cast<uint16_t>(width),
		static_cast<uint16_t>(height), hasMipmaps, 1, *textureFormat, BGFX_TEXTURE_NONE, memory);
	if (!bgfx::isValid(gpu))
	{
		error = "bgfx failed to create the Love compressed Image";
		return 0;
	}
	Texture2D *createdTexture = Texture2D::create(gpu, info, BGFX_TEXTURE_NONE);
	if (!createdTexture)
	{
		bgfx::destroy(gpu);
		error = "Dora failed to wrap the Love compressed Image texture";
		return 0;
	}
	const auto handle = _nextImageHandle++;
	_images.emplace(handle, ImageResource{Ref<Texture2D>(createdTexture),
		Love::GraphicsBackend::TextureType::Texture2D, 1});
	error.clear();
	return handle;
}

Love::GraphicsBackend::ImageHandle LoveNode::newCompressedImage(
	Love::GraphicsBackend::TextureType type, std::string_view format,
	std::span<const Love::GraphicsBackend::CompressedImageLevel> levels,
	std::string &error)
{
	if (type == Love::GraphicsBackend::TextureType::Texture2D)
	{
		if (levels.empty())
		{
			error = "Love compressed Image requires at least one level";
			return 0;
		}
		std::vector<std::uint8_t> bytes;
		for (const auto &level : levels)
			bytes.insert(bytes.end(), level.bytes.begin(), level.bytes.end());
		return newCompressedImage(format, levels.front().width,
			levels.front().height, static_cast<int>(levels.size()), bytes, error);
	}
	if (bgfx::getRendererType() == bgfx::RendererType::Metal)
	{
		error = "the active Dora/bgfx Metal renderer cannot safely create layered compressed Love Images";
		return 0;
	}
	const auto textureFormat = toImageTextureFormat(format);
	if (!textureFormat || levels.empty())
	{
		error = "Love layered compressed Image has an unsupported format or no levels";
		return 0;
	}
	const auto &base = levels.front();
	const bool cube = type == Love::GraphicsBackend::TextureType::Cube;
	const uint16_t depth = type == Love::GraphicsBackend::TextureType::Volume
		? static_cast<uint16_t>(base.slices) : 1;
	const uint16_t layers = type == Love::GraphicsBackend::TextureType::Array
		? static_cast<uint16_t>(base.slices) : 1;
	if (base.width <= 0 || base.height <= 0 || base.slices <= 0
		|| base.width > UINT16_MAX || base.height > UINT16_MAX || base.slices > UINT16_MAX
		|| (cube && (base.slices != 6 || base.width != base.height))
		|| levels.size() > UINT8_MAX
		|| !isLoveCompressedTextureValid(depth, cube, layers, *textureFormat))
	{
		error = "the active Dora/bgfx renderer does not support this layered compressed Love Image";
		return 0;
	}
	for (std::size_t mip = 0; mip < levels.size(); ++mip)
	{
		const auto &level = levels[mip];
		const int expectedSlices = type == Love::GraphicsBackend::TextureType::Volume
			? std::max(1, base.slices >> mip) : base.slices;
		bgfx::TextureInfo sliceInfo;
		bgfx::calcTextureSize(sliceInfo, static_cast<uint16_t>(level.width),
			static_cast<uint16_t>(level.height), 1, false, false, 1, *textureFormat);
		if (level.width != std::max(1, base.width >> mip)
			|| level.height != std::max(1, base.height >> mip)
			|| level.slices != expectedSlices
			|| level.bytes.size() != static_cast<std::size_t>(sliceInfo.storageSize) * level.slices
			|| level.bytes.size() > UINT32_MAX)
		{
			error = "Love layered compressed Image has an invalid or incomplete mipmap level";
			return 0;
		}
	}
	const bool hasMipmaps = levels.size() > 1;
	std::vector<std::uint8_t> packedBytes;
	if (type == Love::GraphicsBackend::TextureType::Array
		|| type == Love::GraphicsBackend::TextureType::Cube)
	{
		for (int slice = 0; slice < base.slices; ++slice)
			for (const auto &level : levels)
			{
				const std::size_t sliceBytes = level.bytes.size() / level.slices;
				const auto offset = static_cast<std::size_t>(slice) * sliceBytes;
				packedBytes.insert(packedBytes.end(), level.bytes.begin() + offset,
					level.bytes.begin() + offset + sliceBytes);
			}
	}
	else
		for (const auto &level : levels)
			packedBytes.insert(packedBytes.end(), level.bytes.begin(), level.bytes.end());
	if (packedBytes.empty() || packedBytes.size() > UINT32_MAX)
	{
		error = "Love layered compressed Image exceeds Dora/bgfx upload limits";
		return 0;
	}
	const bgfx::Memory *initialMemory = bgfx::copy(packedBytes.data(),
		static_cast<uint32_t>(packedBytes.size()));
	bgfx::TextureHandle gpu = BGFX_INVALID_HANDLE;
	if (type == Love::GraphicsBackend::TextureType::Array)
		gpu = bgfx::createTexture2D(static_cast<uint16_t>(base.width),
			static_cast<uint16_t>(base.height), hasMipmaps, layers, *textureFormat,
			BGFX_TEXTURE_NONE, initialMemory);
	else if (type == Love::GraphicsBackend::TextureType::Cube)
		gpu = bgfx::createTextureCube(static_cast<uint16_t>(base.width), hasMipmaps, 1,
			*textureFormat, BGFX_TEXTURE_NONE, initialMemory);
	else
		gpu = bgfx::createTexture3D(static_cast<uint16_t>(base.width),
			static_cast<uint16_t>(base.height), depth, hasMipmaps, *textureFormat,
			BGFX_TEXTURE_NONE, initialMemory);
	if (!bgfx::isValid(gpu))
	{
		error = "bgfx failed to create the layered compressed Love Image";
		return 0;
	}
	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info, static_cast<uint16_t>(base.width),
		static_cast<uint16_t>(base.height), depth, cube, hasMipmaps, layers, *textureFormat);
	Texture2D *createdTexture = Texture2D::create(gpu, info, BGFX_TEXTURE_NONE);
	if (!createdTexture)
	{
		bgfx::destroy(gpu);
		error = "Dora failed to wrap the layered compressed Love Image texture";
		return 0;
	}
	Ref<Texture2D> texture(createdTexture);
	std::vector<Ref<Texture2D>> layerTextures;
	if (type == Love::GraphicsBackend::TextureType::Array)
	{
		layerTextures.reserve(static_cast<std::size_t>(base.slices));
		for (int layer = 0; layer < base.slices; ++layer)
		{
			std::vector<std::uint8_t> layerBytes;
			for (const auto &level : levels)
			{
				const std::size_t sliceBytes = level.bytes.size() / level.slices;
				const auto offset = static_cast<std::size_t>(layer) * sliceBytes;
				layerBytes.insert(layerBytes.end(), level.bytes.begin() + offset,
					level.bytes.begin() + offset + sliceBytes);
			}
			const auto layerGpu = bgfx::createTexture2D(static_cast<uint16_t>(base.width),
				static_cast<uint16_t>(base.height), hasMipmaps, 1, *textureFormat,
				BGFX_TEXTURE_NONE, bgfx::copy(layerBytes.data(),
					static_cast<uint32_t>(layerBytes.size())));
			if (!bgfx::isValid(layerGpu))
			{
				error = "bgfx failed to create a drawable compressed ArrayImage layer";
				return 0;
			}
			bgfx::TextureInfo layerInfo;
			bgfx::calcTextureSize(layerInfo, static_cast<uint16_t>(base.width),
				static_cast<uint16_t>(base.height), 1, false, hasMipmaps, 1, *textureFormat);
			Texture2D *layerTexture = Texture2D::create(layerGpu, layerInfo, BGFX_TEXTURE_NONE);
			if (!layerTexture)
			{
				bgfx::destroy(layerGpu);
				error = "Dora failed to wrap a drawable compressed ArrayImage layer";
				return 0;
			}
			layerTextures.emplace_back(layerTexture);
		}
	}
	const auto handle = _nextImageHandle++;
	_images.emplace(handle, ImageResource{texture, type, base.slices, std::move(layerTextures)});
	error.clear();
	return handle;
}

void LoveNode::releaseImage(Love::GraphicsBackend::ImageHandle image)
{
	_images.erase(image);
}

bool LoveNode::updateImage(Love::GraphicsBackend::ImageHandle image, int width, int height,
	std::span<const std::uint8_t> rgba8, std::string &error)
{
	const auto it = _images.find(image);
	if (it == _images.end() || it->second.type != Love::GraphicsBackend::TextureType::Texture2D
		|| !it->second.texture || it->second.texture->getWidth() != width
		|| it->second.texture->getHeight() != height
		|| rgba8.size() != static_cast<std::size_t>(width) * height * 4
		|| rgba8.size() > UINT32_MAX)
	{
		error = "Love Video frame does not match its Dora RGBA8 texture";
		return false;
	}
	bgfx::updateTexture2D(it->second.texture->getHandle(), 0, 0, 0, 0,
		static_cast<uint16_t>(width), static_cast<uint16_t>(height),
		bgfx::copy(rgba8.data(), static_cast<uint32_t>(rgba8.size())));
	error.clear();
	return true;
}

bool LoveNode::replaceImagePixels(Love::GraphicsBackend::ImageHandle image, int slice, int mipmap,
	int x, int y, int width, int height,
	std::span<const std::uint8_t> rgba8, std::string &error)
{
	const auto it = _images.find(image);
	if (it == _images.end() || !it->second.texture || slice < 0 || mipmap < 0
		|| x < 0 || y < 0 || width <= 0 || height <= 0
		|| rgba8.size() != static_cast<std::size_t>(width) * height * 4
		|| rgba8.size() > UINT32_MAX || x > UINT16_MAX || y > UINT16_MAX
		|| width > UINT16_MAX || height > UINT16_MAX)
	{
		error = "Love Image replacement has invalid texture, region, or RGBA8 data";
		return false;
	}
	const int mipWidth = std::max(1, it->second.texture->getWidth() >> mipmap);
	const int mipHeight = std::max(1, it->second.texture->getHeight() >> mipmap);
	if (x > mipWidth - width || y > mipHeight - height)
	{
		error = "Love Image replacement region exceeds the target mipmap";
		return false;
	}
	const auto handle = it->second.texture->getHandle();
	switch (it->second.type)
	{
		case Love::GraphicsBackend::TextureType::Texture2D:
			if (slice != 0)
			{
				error = "2D Love Images only have slice 1";
				return false;
			}
			bgfx::updateTexture2D(handle, 0, static_cast<uint8_t>(mipmap),
				static_cast<uint16_t>(x), static_cast<uint16_t>(y),
				static_cast<uint16_t>(width), static_cast<uint16_t>(height),
				bgfx::copy(rgba8.data(), static_cast<uint32_t>(rgba8.size())));
			break;
		case Love::GraphicsBackend::TextureType::Array:
			if (slice >= it->second.slices || static_cast<std::size_t>(slice) >= it->second.layerTextures.size()
				|| !it->second.layerTextures[static_cast<std::size_t>(slice)])
			{
				error = "Love ArrayImage replacement layer is unavailable";
				return false;
			}
			bgfx::updateTexture2D(handle, static_cast<uint16_t>(slice), static_cast<uint8_t>(mipmap),
				static_cast<uint16_t>(x), static_cast<uint16_t>(y),
				static_cast<uint16_t>(width), static_cast<uint16_t>(height),
				bgfx::copy(rgba8.data(), static_cast<uint32_t>(rgba8.size())));
			bgfx::updateTexture2D(it->second.layerTextures[static_cast<std::size_t>(slice)]->getHandle(),
				0, static_cast<uint8_t>(mipmap), static_cast<uint16_t>(x), static_cast<uint16_t>(y),
				static_cast<uint16_t>(width), static_cast<uint16_t>(height),
				bgfx::copy(rgba8.data(), static_cast<uint32_t>(rgba8.size())));
			break;
		case Love::GraphicsBackend::TextureType::Cube:
			if (slice >= 6)
			{
				error = "Love CubeImage replacement face is unavailable";
				return false;
			}
			bgfx::updateTextureCube(handle, 0, static_cast<uint8_t>(slice), static_cast<uint8_t>(mipmap),
				static_cast<uint16_t>(x), static_cast<uint16_t>(y),
				static_cast<uint16_t>(width), static_cast<uint16_t>(height),
				bgfx::copy(rgba8.data(), static_cast<uint32_t>(rgba8.size())));
			break;
		case Love::GraphicsBackend::TextureType::Volume:
			if (slice >= it->second.slices)
			{
				error = "Love VolumeImage replacement slice is unavailable";
				return false;
			}
			bgfx::updateTexture3D(handle, static_cast<uint8_t>(mipmap),
				static_cast<uint16_t>(x), static_cast<uint16_t>(y), static_cast<uint16_t>(slice),
				static_cast<uint16_t>(width), static_cast<uint16_t>(height), 1,
				bgfx::copy(rgba8.data(), static_cast<uint32_t>(rgba8.size())));
			break;
	}
	error.clear();
	return true;
}

int LoveNode::getImageWidth(Love::GraphicsBackend::ImageHandle image) const
{
	const auto it = _images.find(image);
	return it == _images.end() ? 0 : it->second.texture->getWidth();
}

int LoveNode::getImageHeight(Love::GraphicsBackend::ImageHandle image) const
{
	const auto it = _images.find(image);
	return it == _images.end() ? 0 : it->second.texture->getHeight();
}

Love::GraphicsBackend::TextureType LoveNode::getImageTextureType(
	Love::GraphicsBackend::ImageHandle image) const
{
	const auto it = _images.find(image);
	return it == _images.end() ? Love::GraphicsBackend::TextureType::Texture2D : it->second.type;
}

int LoveNode::getImageSliceCount(Love::GraphicsBackend::ImageHandle image) const
{
	const auto it = _images.find(image);
	return it == _images.end() ? 0 : it->second.slices;
}

void LoveNode::drawImage(Love::GraphicsBackend::ImageHandle image,
	float sourceX, float sourceY, float sourceWidth, float sourceHeight,
	float a, float b, float c, float d, float tx, float ty, float originX, float originY,
	float red, float green, float blue, float alpha,
	Love::GraphicsBackend::TextureFilter filter,
	Love::GraphicsBackend::TextureWrap wrapU,
	Love::GraphicsBackend::TextureWrap wrapV)
{
	const auto it = _images.find(image);
	if (it == _images.end())
		return;
	if (it->second.type != Love::GraphicsBackend::TextureType::Texture2D) return;
	drawTexture(it->second.texture, sourceX, sourceY, sourceWidth, sourceHeight,
		a, b, c, d, tx, ty, originX, originY, red, green, blue, alpha,
		filter, wrapU, wrapV);
}

bool LoveNode::drawImageLayer(Love::GraphicsBackend::ImageHandle image, int layer,
	float sourceX, float sourceY, float sourceWidth, float sourceHeight,
	float a, float b, float c, float d, float tx, float ty, float originX, float originY,
	float red, float green, float blue, float alpha,
	Love::GraphicsBackend::TextureFilter filter,
	Love::GraphicsBackend::TextureWrap wrapU,
	Love::GraphicsBackend::TextureWrap wrapV, std::string &error)
{
	const auto it = _images.find(image);
	if (it == _images.end() || it->second.type != Love::GraphicsBackend::TextureType::Array)
	{
		error = "drawLayer can only be used with an open Love ArrayImage";
		return false;
	}
	if (layer < 0 || layer >= static_cast<int>(it->second.layerTextures.size()))
	{
		error = "Love ArrayImage layer is outside the available layer range";
		return false;
	}
	if (_activeShader != 0)
	{
		if (!validateShaderDraw(error, Love::GraphicsBackend::TextureType::Array)) return false;
		const auto &shader = _shaders.at(_activeShader);
		if (!shader.hasMainTexture)
		{
			drawTexture(it->second.layerTextures[static_cast<std::size_t>(layer)],
				sourceX, sourceY, sourceWidth, sourceHeight,
				a, b, c, d, tx, ty, originX, originY, red, green, blue, alpha,
				filter, wrapU, wrapV);
			error.clear();
			return true;
		}
		if (shader.mainTextureLayerSemantic == bgfx::Attrib::Count)
		{
			error = "Love ArrayImage Shader is missing its main texture layer attribute";
			return false;
		}
		const float width = std::abs(sourceWidth);
		const float height = std::abs(sourceHeight);
		const float textureWidth = static_cast<float>(it->second.texture->getWidth());
		const float textureHeight = static_cast<float>(it->second.texture->getHeight());
		const float left = sourceX / textureWidth;
		const float top = sourceY / textureHeight;
		const float right = (sourceX + sourceWidth) / textureWidth;
		const float bottom = (sourceY + sourceHeight) / textureHeight;
		const auto transform = [&](float localX, float localY, float u, float v) {
			const float px = localX - originX;
			const float py = localY - originY;
			return Love::GraphicsBackend::MeshVertex{
				a * px + c * py + tx, b * px + d * py + ty, 0.0f, 1.0f,
				u, v, red, green, blue, alpha};
		};
		std::vector<Love::GraphicsBackend::MeshVertex> vertices{
			transform(0.0f, 0.0f, left, top),
			transform(width, 0.0f, right, top),
			transform(width, height, right, bottom),
			transform(0.0f, height, left, bottom),
		};
		std::vector<uint32_t> indices{0, 1, 2, 0, 2, 3};
		std::vector<LoveDynamicMeshAttribute> attributes;
		attributes.push_back({shader.mainTextureLayerSemantic, 1,
			std::vector<float>(4, static_cast<float>(layer))});
		if (shader.usesVertexID)
			attributes.push_back({shader.vertexIDSemantic, 1, {0.0f, 1.0f, 2.0f, 3.0f}});
		auto *node = LoveDynamicMeshNode::create(std::move(vertices), std::move(indices),
			std::move(attributes), std::vector<LoveDynamicMeshInstanceAttribute>{}, 1,
			std::array<Vec4, 5>{}, it->second.texture,
			toDoraBlendFunc(_blendMode, _blendAlphaMode),
			meshSamplerFlags(it->second.texture, filter, wrapU, wrapV,
				Love::GraphicsBackend::TextureWrap::Clamp), shader.effect.get(),
			static_cast<float>(getActivePixelHeight()), false, _wireframe);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
		markRenderCommand();
		_drawNode = nullptr;
		error.clear();
		return true;
	}
	drawTexture(it->second.layerTextures[static_cast<std::size_t>(layer)],
		sourceX, sourceY, sourceWidth, sourceHeight,
		a, b, c, d, tx, ty, originX, originY, red, green, blue, alpha,
		filter, wrapU, wrapV);
	error.clear();
	return true;
}

Love::GraphicsBackend::CanvasHandle LoveNode::newCanvas(int width, int height,
	const Love::GraphicsBackend::CanvasSettings &settings, std::string &error)
{
	if (width <= 0 || height <= 0 || width > UINT16_MAX || height > UINT16_MAX
		|| settings.slices <= 0 || settings.slices > UINT16_MAX)
	{
		error = "Love Canvas has invalid dimensions or layer count";
		return 0;
	}
	if (settings.type == Love::GraphicsBackend::TextureType::Cube
		&& (width != height || settings.slices != 6))
	{
		error = "Love cube Canvas requires six square faces";
		return 0;
	}
	if (settings.type == Love::GraphicsBackend::TextureType::Texture2D && settings.slices != 1)
	{
		error = "Love 2D Canvas requires exactly one layer";
		return 0;
	}
	const bool hasMipmaps = settings.mipmapMode != "none";
	if (settings.mipmapMode != "none" && settings.mipmapMode != "manual"
		&& settings.mipmapMode != "auto")
	{
		error = "Love Canvas mipmap mode must be 'none', 'manual', or 'auto'";
		return 0;
	}
	const bool advanced = settings.type != Love::GraphicsBackend::TextureType::Texture2D
		|| hasMipmaps;
	if (advanced && settings.msaa > 0)
	{
		error = "layered or mipmapped Love Canvas cannot use MSAA in the Dora/bgfx backend";
		return 0;
	}
	if (!isCanvasFormatSafeForRenderer(settings.format))
	{
		error = "Love Canvas format '" + std::string(settings.format)
			+ "' is unsafe as a render target on the active Dora renderer";
		return 0;
	}
	if (!isCanvasFormatSupported(settings.format, settings.readable))
	{
		error = "Dora renderer does not support Love Canvas format '"
			+ std::string(settings.format) + "'"
			+ (settings.readable ? " with readable=true" : " with readable=false");
		return 0;
	}
	if (!isCanvasMSAASafeForRenderer(settings.msaa))
	{
		error = "the active Dora Metal renderer currently exposes at most 4x MSAA for Love Canvas";
		return 0;
	}
	const auto format = toCanvasTextureFormat(settings.format);
	if (!format)
	{
		error = "Love Canvas format '" + std::string(settings.format) + "' has no Dora/bgfx mapping";
		return 0;
	}
	uint64_t textureFlags = toCanvasMSAAFlags(settings.msaa);
	if (!settings.readable)
		textureFlags |= BGFX_TEXTURE_RT_WRITE_ONLY;
	if (settings.format == "srgba8")
		textureFlags |= BGFX_TEXTURE_SRGB;
	const auto *caps = bgfx::getCaps();
	const uint16_t formatCaps = caps->formats[*format];
	const bool cube = settings.type == Love::GraphicsBackend::TextureType::Cube;
	const uint16_t depth = settings.type == Love::GraphicsBackend::TextureType::Volume
		? static_cast<uint16_t>(settings.slices) : 1;
	const uint16_t layers = settings.type == Love::GraphicsBackend::TextureType::Array
		? static_cast<uint16_t>(settings.slices) : 1;
	if ((formatCaps & BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER) == 0
		|| (settings.msaa > 1 && (formatCaps & BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA) == 0)
		|| !bgfx::isTextureValid(depth, cube, layers, *format, BGFX_TEXTURE_RT | textureFlags))
	{
		error = "Dora renderer does not support Love Canvas format '" + std::string(settings.format)
			+ "' with msaa=" + std::to_string(settings.msaa)
			+ (settings.readable ? " readable=true" : " readable=false");
		return 0;
	}
	const auto handle = _nextCanvasHandle++;
	CanvasResource resource;
	resource.msaa = settings.msaa;
	resource.readable = settings.readable;
	resource.format = settings.format;
	resource.depthStencil = isCanvasDepthStencilFormat(settings.format);
	resource.type = settings.type;
	resource.slices = settings.slices;
	resource.mipmapMode = settings.mipmapMode;
	resource.mipmapCount = hasMipmaps
		? static_cast<int>(std::floor(std::log2(static_cast<double>(std::max({width, height,
			settings.type == Love::GraphicsBackend::TextureType::Volume ? settings.slices : 1}))))) + 1
		: 1;
	if (resource.depthStencil && advanced)
	{
		error = "layered or mipmapped depth/stencil Love Canvas is unavailable in the Dora/bgfx backend";
		return 0;
	}
	if (advanced)
	{
		const uint64_t flags = BGFX_TEXTURE_RT | textureFlags
			| BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP;
		bgfx::TextureHandle textureHandle = BGFX_INVALID_HANDLE;
		switch (settings.type)
		{
			case Love::GraphicsBackend::TextureType::Array:
				textureHandle = bgfx::createTexture2D(static_cast<uint16_t>(width),
					static_cast<uint16_t>(height), hasMipmaps, layers, *format, flags);
				break;
			case Love::GraphicsBackend::TextureType::Cube:
				textureHandle = bgfx::createTextureCube(static_cast<uint16_t>(width),
					hasMipmaps, 1, *format, flags);
				break;
			case Love::GraphicsBackend::TextureType::Volume:
				textureHandle = bgfx::createTexture3D(static_cast<uint16_t>(width),
					static_cast<uint16_t>(height), depth, hasMipmaps, *format, flags);
				break;
			case Love::GraphicsBackend::TextureType::Texture2D:
				textureHandle = bgfx::createTexture2D(static_cast<uint16_t>(width),
					static_cast<uint16_t>(height), hasMipmaps, 1, *format, flags);
				break;
		}
		if (!bgfx::isValid(textureHandle))
		{
			error = "Dora/bgfx failed to create layered or mipmapped Love Canvas texture";
			return 0;
		}
		bgfx::TextureInfo info;
		bgfx::calcTextureSize(info, static_cast<uint16_t>(width), static_cast<uint16_t>(height),
			depth, cube, hasMipmaps, layers, *format);
		resource.texture = Texture2D::create(textureHandle, info, flags);
		if (!resource.texture)
		{
			bgfx::destroy(textureHandle);
			error = "Dora Texture2D failed to retain layered or mipmapped Love Canvas";
			return 0;
		}
	}
	else if (resource.depthStencil)
	{
		const uint64_t flags = BGFX_TEXTURE_RT | textureFlags
			| BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP;
		const auto textureHandle = bgfx::createTexture2D(static_cast<uint16_t>(width),
			static_cast<uint16_t>(height), false, 1, *format, flags);
		if (!bgfx::isValid(textureHandle))
		{
			error = "Dora/bgfx failed to create Love depth/stencil Canvas "
				+ std::to_string(width) + "x" + std::to_string(height) + " format='"
				+ std::string(settings.format) + "' msaa=" + std::to_string(settings.msaa);
			return 0;
		}
		bgfx::TextureInfo info;
		bgfx::calcTextureSize(info, static_cast<uint16_t>(width), static_cast<uint16_t>(height),
			0, false, false, 1, *format);
		resource.texture = Texture2D::create(textureHandle, info, flags);
		if (!resource.texture)
		{
			bgfx::destroy(textureHandle);
			error = "Dora Texture2D failed to retain the Love depth/stencil Canvas";
			return 0;
		}
	}
	else
	{
		const uint64_t depthFlags = BGFX_TEXTURE_RT | BGFX_TEXTURE_RT_WRITE_ONLY
			| (textureFlags & BGFX_TEXTURE_RT_MSAA_MASK);
		if (!bgfx::isTextureValid(0, false, 1, bgfx::TextureFormat::D24S8, depthFlags))
		{
			error = "Dora renderer does not support the matching Love Canvas depth/MSAA attachment";
			return 0;
		}
		resource.target = RenderTarget::create(width, height, *format, textureFlags);
		if (!resource.target)
		{
			error = "Dora RenderTarget failed to create Love Canvas " + std::to_string(width) + "x"
				+ std::to_string(height) + " format='" + std::string(settings.format) + "' msaa="
				+ std::to_string(settings.msaa) + " in LoveNode '" + _bootFile + "'";
			return 0;
		}
		resource.texture = resource.target->getTexture();
	}
	_canvases.emplace(handle, std::move(resource));
	error.clear();
	return handle;
}

bool LoveNode::isCanvasFormatSupported(std::string_view format, bool readable) const
{
	if (format == "normal") format = "rgba8";
	else if (format == "hdr") format = "rgba16f";
	if (!isCanvasFormatSafeForRenderer(format))
		return false;
	const auto textureFormat = toCanvasTextureFormat(format);
	if (!textureFormat)
		return false;
	uint64_t flags = BGFX_TEXTURE_RT;
	if (!readable) flags |= BGFX_TEXTURE_RT_WRITE_ONLY;
	if (format == "srgba8") flags |= BGFX_TEXTURE_SRGB;
	const auto *caps = bgfx::getCaps();
#if BX_PLATFORM_LINUX
	// Dora uses OpenGL ES on Linux ARM64. Its framebuffer capability bits do
	// not describe which native formats glReadPixels can safely return, and
	// bgfx's GLES readback emulation can only guarantee RGBA8-compatible data.
	if (readable && caps->rendererType == bgfx::RendererType::OpenGLES
		&& format != "rgba8" && format != "srgba8")
		return false;
#endif
	return (caps->formats[*textureFormat] & BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER) != 0
		&& bgfx::isTextureValid(0, false, 1, *textureFormat, flags);
}

void LoveNode::releaseCanvas(Love::GraphicsBackend::CanvasHandle canvas)
{
	_pendingCanvasMipmaps.erase(canvas);
	if (std::find(_activeCanvases.begin(), _activeCanvases.end(), canvas) != _activeCanvases.end()
		|| _activeCanvasDepthStencil == canvas)
	{
		_activeCanvases.clear();
		_activeCanvasTargets.clear();
		_activeCanvasDepthStencil = 0;
		_activeCanvas = 0;
		_activeCanvasTarget = nullptr;
		_activeCanvasDepth = false;
		_activeCanvasStencil = false;
	}
	for (auto found = _canvasTargets.begin(); found != _canvasTargets.end();)
	{
		if (std::any_of(found->first.begin(), found->first.end(),
			[canvas](const auto &target) { return target.canvas == canvas; }))
			found = _canvasTargets.erase(found);
		else
			++found;
	}
	_canvases.erase(canvas);
}

int LoveNode::getCanvasWidth(Love::GraphicsBackend::CanvasHandle canvas) const
{
	auto found = _canvases.find(canvas);
	return found == _canvases.end() || !found->second.texture ? 0 : found->second.texture->getWidth();
}

int LoveNode::getCanvasHeight(Love::GraphicsBackend::CanvasHandle canvas) const
{
	const auto found = _canvases.find(canvas);
	return found == _canvases.end() || !found->second.texture ? 0 : found->second.texture->getHeight();
}

bool LoveNode::readCanvas(Love::GraphicsBackend::CanvasHandle canvas, int slice, int mipmap,
	int x, int y,
	int width, int height, std::vector<std::uint8_t> &pixels, std::string &error)
{
	const auto found = _canvases.find(canvas);
	if (found == _canvases.end() || !found->second.texture)
	{
		error = "Love Canvas is closed";
		return false;
	}
	if (found->second.depthStencil)
	{
		error = "Canvas:newImageData cannot represent a depth/stencil Canvas as ImageData";
		return false;
	}
	if (!found->second.readable)
	{
		error = "Canvas:newImageData cannot be called on a non-readable Canvas";
		return false;
	}
	auto &resource = found->second;
	if (mipmap < 0 || mipmap >= resource.mipmapCount)
	{
		error = "Canvas:newImageData received an invalid mipmap level";
		return false;
	}
	const int slices = resource.type == Love::GraphicsBackend::TextureType::Volume
		? std::max(1, resource.slices >> mipmap) : resource.slices;
	if (slice < 0 || slice >= slices)
	{
		error = "Canvas:newImageData received an invalid layer, face, or volume slice";
		return false;
	}
	Ref<RenderTarget> readTarget = resource.target;
	if (!readTarget || slice != 0 || mipmap != 0)
	{
		const auto key = std::pair{slice, mipmap};
		auto target = resource.targets.find(key);
		if (target == resource.targets.end())
		{
			std::vector<RenderTarget::Attachment> attachments{{resource.texture,
				static_cast<uint16_t>(slice), static_cast<uint16_t>(mipmap), BGFX_RESOLVE_NONE}};
			auto *created = RenderTarget::create(std::move(attachments), std::nullopt);
			if (!created)
			{
				error = "Dora/bgfx failed to create the Canvas subresource readback target";
				return false;
			}
			target = resource.targets.emplace(key, created).first;
		}
		readTarget = target->second;
	}
	std::vector<std::uint8_t> raw;
	const auto readResult = readTarget->readPixelsSync(raw,
		static_cast<uint16_t>(slice), static_cast<uint8_t>(mipmap));
	if (readResult != RenderTarget::ReadPixelsResult::Success)
	{
		switch (readResult)
		{
			case RenderTarget::ReadPixelsResult::NoTexture:
			case RenderTarget::ReadPixelsResult::InvalidTexture:
				error = "Dora/bgfx Canvas texture is unavailable";
				break;
			case RenderTarget::ReadPixelsResult::WriteOnly:
				error = "Canvas:newImageData cannot be called on a non-readable Canvas";
				break;
			case RenderTarget::ReadPixelsResult::Unsupported:
				error = "the active Dora renderer does not support Canvas texture readback";
				break;
			case RenderTarget::ReadPixelsResult::ActiveView:
				error = "Dora/bgfx synchronous Canvas readback is unavailable while host view '"
					+ SharedView.getName() + "' is active";
				break;
			case RenderTarget::ReadPixelsResult::StagingTextureFailed:
				error = "Dora/bgfx failed to create the Canvas readback staging texture";
				break;
			case RenderTarget::ReadPixelsResult::TimedOut:
				error = "Dora/bgfx timed out while waiting for synchronous Canvas readback";
				break;
			case RenderTarget::ReadPixelsResult::Success:
				break;
		}
		return false;
	}
	const int canvasWidth = std::max(1, resource.texture->getWidth() >> mipmap);
	const int canvasHeight = std::max(1, resource.texture->getHeight() >> mipmap);
	const auto pixelBytes = canvasFormatBytes(found->second.format);
	if (!pixelBytes)
	{
		error = "Love Canvas format has no ImageData byte layout";
		return false;
	}
	const std::size_t expected = static_cast<std::size_t>(canvasWidth)
		* static_cast<std::size_t>(canvasHeight) * *pixelBytes;
	if (raw.size() != expected)
	{
		error = "Dora/bgfx returned an invalid byte count for Love Canvas format '"
			+ found->second.format + "'";
		return false;
	}
	pixels.resize(static_cast<std::size_t>(width) * static_cast<std::size_t>(height) * *pixelBytes);
	const std::size_t sourceStride = static_cast<std::size_t>(canvasWidth) * *pixelBytes;
	const std::size_t targetStride = static_cast<std::size_t>(width) * *pixelBytes;
	for (int row = 0; row < height; ++row)
		std::copy_n(raw.data() + static_cast<std::size_t>(y + row) * sourceStride
			+ static_cast<std::size_t>(x) * *pixelBytes, targetStride,
			pixels.data() + static_cast<std::size_t>(row) * targetStride);
	error.clear();
	return true;
}

bool LoveNode::generateCanvasMipmaps(Love::GraphicsBackend::CanvasHandle canvas,
	std::string &error)
{
	auto found = _canvases.find(canvas);
	if (found == _canvases.end() || !found->second.texture)
	{
		error = "Love Canvas is closed";
		return false;
	}
	auto &resource = found->second;
	if (resource.depthStencil)
	{
		error = "generateMipmaps cannot be called on a depth/stencil Canvas";
		return false;
	}
	if (resource.mipmapMode == "none" || resource.mipmapCount <= 1)
	{
		error = "generateMipmaps can only be called on a Canvas created with mipmaps enabled";
		return false;
	}
	if (!_graphicsFrameActive)
	{
		_pendingCanvasMipmaps.insert(canvas);
		error.clear();
		return true;
	}
	if (!resource.mipmapTarget)
	{
		std::vector<RenderTarget::Attachment> attachments{
			{resource.texture, 0, 0, BGFX_RESOLVE_AUTO_GEN_MIPS}};
		resource.mipmapTarget = RenderTarget::create(std::move(attachments), std::nullopt);
		if (!resource.mipmapTarget)
		{
			error = "Dora/bgfx failed to create the Canvas mipmap resolve target";
			return false;
		}
	}
	auto *root = Node::create();
	root->setAsManaged();
	RenderPass pass;
	pass.target = resource.mipmapTarget;
	pass.root = root;
	// RenderTarget::render touches this otherwise-empty pass. Switching away from
	// its AUTO_GEN_MIPS attachment makes bgfx resolve the complete texture chain.
	pass.hasCommands = true;
	_renderPasses.push_back(std::move(pass));
	beginRenderPass(BGFX_CLEAR_NONE, Color(0x00000000));
	error.clear();
	return true;
}

bool LoveNode::setCanvases(std::span<const Love::GraphicsBackend::CanvasHandle> canvases,
	Love::GraphicsBackend::CanvasHandle depthStencil, bool depth, bool stencil,
	std::string &error)
{
	std::vector<Love::GraphicsBackend::CanvasTarget> targets;
	targets.reserve(canvases.size());
	for (const auto canvas : canvases) targets.push_back({canvas, 0, 0});
	const Love::GraphicsBackend::CanvasTarget depthTarget{depthStencil, 0, 0};
	return setCanvasTargets(targets, depthStencil != 0 ? &depthTarget : nullptr,
		depth, stencil, error);
}

bool LoveNode::setCanvasTargets(
	std::span<const Love::GraphicsBackend::CanvasTarget> canvases,
	const Love::GraphicsBackend::CanvasTarget *depthStencil, bool depth, bool stencil,
	std::string &error)
{
	const auto* caps = bgfx::getCaps();
	if (canvases.size() + (depthStencil != nullptr || depth || stencil ? 1 : 0)
		> caps->limits.maxFBAttachments)
	{
		error = "Love Canvas attachment count exceeds the renderer framebuffer attachment limit";
		return false;
	}
	std::vector<Love::GraphicsBackend::CanvasTarget> next(canvases.begin(), canvases.end());
	auto validateTarget = [&](const Love::GraphicsBackend::CanvasTarget &target,
		bool requireDepth, int &targetWidth, int &targetHeight, int &targetMSAA) {
		const auto found = _canvases.find(target.canvas);
		if (found == _canvases.end() || !found->second.texture
			|| found->second.depthStencil != requireDepth)
		{
			error = requireDepth
				? "Love depthstencil Canvas is closed, color-only, or belongs to another LoveNode"
				: "Love color Canvas is closed, depth/stencil-only, or belongs to another LoveNode";
			return false;
		}
		const auto &resource = found->second;
		if (target.mipmap < 0 || target.mipmap >= resource.mipmapCount)
		{
			error = "Love Canvas target has an invalid mipmap level";
			return false;
		}
		int slices = resource.type == Love::GraphicsBackend::TextureType::Volume
			? std::max(1, resource.slices >> target.mipmap) : resource.slices;
		if (target.slice < 0 || target.slice >= slices)
		{
			error = "Love Canvas target has an invalid layer, face, or volume slice";
			return false;
		}
		const int width = std::max(1, resource.texture->getWidth() >> target.mipmap);
		const int height = std::max(1, resource.texture->getHeight() >> target.mipmap);
		if (targetWidth == 0)
		{
			targetWidth = width;
			targetHeight = height;
			targetMSAA = resource.msaa;
		}
		else if (width != targetWidth || height != targetHeight)
		{
			error = "simultaneous Love Canvas targets must have identical mip dimensions";
			return false;
		}
		else if (resource.msaa != targetMSAA)
		{
			error = "Love Canvas targets must use identical MSAA sample counts";
			return false;
		}
		return true;
	};
	int width = 0;
	int height = 0;
	int msaa = -1;
	for (const auto &canvas : next)
	{
		if (!validateTarget(canvas, false, width, height, msaa)) return false;
	}
	const CanvasResource *depthResource = nullptr;
	if (depthStencil != nullptr)
	{
		if (!validateTarget(*depthStencil, true, width, height, msaa)) return false;
		const auto found = _canvases.find(depthStencil->canvas);
		depthResource = &found->second;
	}
	else if ((depth || stencil) && next.empty())
	{
		error = "temporary Love Canvas depth/stencil requires a color Canvas";
		return false;
	}
	if (_activeShader != 0)
	{
		for (const auto &[name, sampledCanvas] : _shaders.at(_activeShader).samplerCanvases)
		{
			if (std::any_of(next.begin(), next.end(), [sampledCanvas](const auto &target) {
				return target.canvas == sampledCanvas;
			}) || (depthStencil && sampledCanvas == depthStencil->canvas))
			{
				error = "Canvas cannot become an active render target while sampled by Shader uniform '"
					+ name + "'";
				return false;
			}
		}
	}
	if (next == _activeCanvasTargets
		&& (depthStencil ? depthStencil->canvas : 0) == _activeCanvasDepthStencil
		&& depth == _activeCanvasDepth && stencil == _activeCanvasStencil)
	{
		error.clear();
		return true;
	}
	Ref<RenderTarget> target;
	if (next.empty() && depthStencil == nullptr)
		target = nullptr;
	else if (next.size() == 1 && depthStencil == nullptr && !depth && !stencil
		&& next.front().slice == 0 && next.front().mipmap == 0
		&& _canvases.at(next.front().canvas).target)
		target = _canvases.at(next.front().canvas).target;
	else
	{
		std::vector<Love::GraphicsBackend::CanvasTarget> key(next);
		key.push_back({0, depth ? 1 : 0, stencil ? 1 : 0});
		if (depthStencil) key.push_back(*depthStencil);
		if (const auto cached = _canvasTargets.find(key); cached != _canvasTargets.end())
			target = cached->second;
		else
		{
		std::vector<RenderTarget::Attachment> colorAttachments;
		colorAttachments.reserve(next.size());
		for (const auto &canvas : next)
		{
			const auto &resource = _canvases.at(canvas.canvas);
			const uint8_t resolve = resource.mipmapMode == "auto" && canvas.mipmap == 0
				? BGFX_RESOLVE_AUTO_GEN_MIPS : BGFX_RESOLVE_NONE;
			colorAttachments.push_back({resource.texture, static_cast<uint16_t>(canvas.slice),
				static_cast<uint16_t>(canvas.mipmap), resolve});
		}
		std::optional<RenderTarget::Attachment> depthAttachment;
		Ref<Texture2D> temporaryDepth;
		if (depthResource && depthStencil)
			depthAttachment = RenderTarget::Attachment{depthResource->texture,
				static_cast<uint16_t>(depthStencil->slice),
				static_cast<uint16_t>(depthStencil->mipmap), BGFX_RESOLVE_NONE};
		else if (depth || stencil)
		{
			const uint64_t flags = BGFX_TEXTURE_RT | BGFX_TEXTURE_RT_WRITE_ONLY
				| toCanvasMSAAFlags(msaa);
			const auto gpu = bgfx::createTexture2D(static_cast<uint16_t>(width),
				static_cast<uint16_t>(height), false, 1, bgfx::TextureFormat::D24S8, flags);
			if (!bgfx::isValid(gpu))
			{
				error = "Dora/bgfx failed to create temporary Love Canvas depth/stencil attachment";
				return false;
			}
			bgfx::TextureInfo info;
			bgfx::calcTextureSize(info, static_cast<uint16_t>(width), static_cast<uint16_t>(height),
				1, false, false, 1, bgfx::TextureFormat::D24S8);
			temporaryDepth = Texture2D::create(gpu, info, flags);
			if (!temporaryDepth)
			{
				bgfx::destroy(gpu);
				error = "Dora failed to retain temporary Love Canvas depth/stencil attachment";
				return false;
			}
			depthAttachment = RenderTarget::Attachment{temporaryDepth, 0, 0, BGFX_RESOLVE_NONE};
		}
		auto *combined = RenderTarget::create(std::move(colorAttachments), depthAttachment);
		if (!combined)
		{
			error = "Dora/bgfx failed to create a framebuffer for the requested Love Canvas attachments";
			return false;
		}
		target = combined;
		_canvasTargets.emplace(std::move(key), combined);
		}
	}
	++_graphicsStats.canvasSwitches;
	_activeCanvasTargets = next;
	_activeCanvases.clear();
	_activeCanvases.reserve(next.size());
	for (const auto &canvas : next) _activeCanvases.push_back(canvas.canvas);
	_activeCanvasDepthStencil = depthStencil ? depthStencil->canvas : 0;
	_activeCanvas = !_activeCanvases.empty() ? _activeCanvases.front() : _activeCanvasDepthStencil;
	_activeCanvasTarget = target;
	_activeCanvasDepth = _activeCanvas != 0 && depth;
	_activeCanvasStencil = _activeCanvas != 0 && stencil;
	if (_graphicsFrameActive)
		beginRenderPass(BGFX_CLEAR_NONE, Color(0x00000000));
	error.clear();
	return true;
}

void LoveNode::drawCanvas(Love::GraphicsBackend::CanvasHandle canvas,
	float sourceX, float sourceY, float sourceWidth, float sourceHeight,
	float a, float b, float c, float d, float tx, float ty, float originX, float originY,
	float red, float green, float blue, float alpha,
	Love::GraphicsBackend::TextureFilter filter,
	Love::GraphicsBackend::TextureWrap wrapU,
	Love::GraphicsBackend::TextureWrap wrapV)
{
	const auto found = _canvases.find(canvas);
	if (found == _canvases.end() || !found->second.texture)
		return;
	drawTexture(found->second.texture, sourceX, sourceY, sourceWidth, sourceHeight,
		a, b, c, d, tx, ty, originX, originY, red, green, blue, alpha,
		filter, wrapU, wrapV);
}

bool LoveNode::drawCanvasLayer(Love::GraphicsBackend::CanvasHandle canvas, int layer,
	float sourceX, float sourceY, float sourceWidth, float sourceHeight,
	float a, float b, float c, float d, float tx, float ty, float originX, float originY,
	float red, float green, float blue, float alpha,
	Love::GraphicsBackend::TextureFilter filter,
	Love::GraphicsBackend::TextureWrap wrapU,
	Love::GraphicsBackend::TextureWrap wrapV, std::string &error)
{
	const auto found = _canvases.find(canvas);
	if (found == _canvases.end() || !found->second.texture
		|| found->second.type != Love::GraphicsBackend::TextureType::Array)
	{
		error = "drawLayer can only be used with an open Love array Canvas";
		return false;
	}
	if (layer < 0 || layer >= found->second.slices)
	{
		error = "Love array Canvas layer is outside the available range";
		return false;
	}
	auto shaderHandle = _activeShader;
	if (shaderHandle == 0)
	{
		shaderHandle = ensureArrayTextureShader(error);
		if (shaderHandle == 0) return false;
	}
	if (!validateShaderDraw(error, Love::GraphicsBackend::TextureType::Array)) return false;
	const auto &shader = _shaders.at(shaderHandle);
	if (shader.hasMainTexture && shader.mainTextureLayerSemantic == bgfx::Attrib::Count)
	{
		error = "Love array Canvas Shader is missing its main texture layer attribute";
		return false;
	}
	const float width = std::abs(sourceWidth);
	const float height = std::abs(sourceHeight);
	const float textureWidth = static_cast<float>(found->second.texture->getWidth());
	const float textureHeight = static_cast<float>(found->second.texture->getHeight());
	const float left = sourceX / textureWidth;
	const float top = sourceY / textureHeight;
	const float right = (sourceX + sourceWidth) / textureWidth;
	const float bottom = (sourceY + sourceHeight) / textureHeight;
	const auto transform = [&](float localX, float localY, float u, float v) {
		const float px = localX - originX;
		const float py = localY - originY;
		return Love::GraphicsBackend::MeshVertex{
			a * px + c * py + tx, b * px + d * py + ty, 0.0f, 1.0f,
			u, v, red, green, blue, alpha};
	};
	std::vector<Love::GraphicsBackend::MeshVertex> vertices{
		transform(0.0f, 0.0f, left, top), transform(width, 0.0f, right, top),
		transform(width, height, right, bottom), transform(0.0f, height, left, bottom)};
	std::vector<uint32_t> indices{0, 1, 2, 0, 2, 3};
	std::vector<LoveDynamicMeshAttribute> attributes;
	if (shader.hasMainTexture)
		attributes.push_back({shader.mainTextureLayerSemantic, 1,
			std::vector<float>(4, static_cast<float>(layer))});
	if (shader.usesVertexID)
		attributes.push_back({shader.vertexIDSemantic, 1, {0.0f, 1.0f, 2.0f, 3.0f}});
	auto *node = LoveDynamicMeshNode::create(std::move(vertices), std::move(indices),
		std::move(attributes), std::vector<LoveDynamicMeshInstanceAttribute>{}, 1,
		std::array<Vec4, 5>{}, found->second.texture,
		toDoraBlendFunc(_blendMode, _blendAlphaMode),
		meshSamplerFlags(found->second.texture, filter, wrapU, wrapV,
			Love::GraphicsBackend::TextureWrap::Clamp), shader.effect.get(),
		static_cast<float>(getActivePixelHeight()), false, _wireframe);
	(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
	markRenderCommand();
	_drawNode = nullptr;
	error.clear();
	return true;
}

Texture2D* LoveNode::ensureWhiteTexture(std::string &error)
{
	if (_whiteTexture)
	{
		error.clear();
		return _whiteTexture;
	}
	static constexpr std::array<std::uint8_t, 4> pixel = {255, 255, 255, 255};
	const auto handle = bgfx::createTexture2D(1, 1, false, 1, bgfx::TextureFormat::RGBA8,
		BGFX_TEXTURE_NONE, bgfx::copy(pixel.data(), static_cast<uint32_t>(pixel.size())));
	if (!bgfx::isValid(handle))
	{
		error = "Dora/bgfx failed to create Love's default white Shader texture";
		return nullptr;
	}
	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info, 1, 1, 1, false, false, 1, bgfx::TextureFormat::RGBA8);
	_whiteTexture = Texture2D::create(handle, info, BGFX_TEXTURE_NONE);
	error.clear();
	return _whiteTexture;
}

Love::GraphicsBackend::ShaderHandle LoveNode::ensureArrayTextureShader(std::string &error)
{
	if (_arrayTextureShader != 0 && _shaders.contains(_arrayTextureShader))
	{
		error.clear();
		return _arrayTextureShader;
	}
	static constexpr std::string_view source = R"(
extern ArrayImage MainTex;
void effect() {
	love_PixelColor = Texel(MainTex, VaryingTexCoord.xyz) * VaryingColor;
}
)";
	std::string warnings;
	_arrayTextureShader = newShader({}, source, warnings, error);
	return _arrayTextureShader;
}

bool LoveNode::drawShaderPrimitive(std::span<const Vec2> vertices, bool fill, bool closed,
	float lineWidth, Color color, std::string &error)
{
	std::vector<SpriteVertex> primitiveVertices;
	std::vector<uint32_t> primitiveIndices;
	const uint32_t packedColor = color.toABGR();
	if (fill)
	{
		if (vertices.size() < 3)
		{
			error.clear();
			return true;
		}
		if (vertices.size() > std::numeric_limits<uint32_t>::max())
		{
			error = "Shader graphics primitive exceeds Dora/bgfx's 32-bit vertex limit";
			return false;
		}
		primitiveVertices.reserve(vertices.size());
		for (const auto &vertex : vertices)
			primitiveVertices.push_back({vertex.x, vertex.y, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
		primitiveIndices.reserve((vertices.size() - 2) * 3);
		for (std::size_t index = 1; index + 1 < vertices.size(); ++index)
		{
			primitiveIndices.push_back(0);
			primitiveIndices.push_back(static_cast<uint32_t>(index));
			primitiveIndices.push_back(static_cast<uint32_t>(index + 1));
		}
	}
	else
	{
		if (vertices.size() < 2 || lineWidth <= 0.0f)
		{
			error.clear();
			return true;
		}
		const std::size_t segmentCount = closed ? vertices.size() : vertices.size() - 1;
		if (segmentCount > std::numeric_limits<uint32_t>::max() / 4)
		{
			error = "Shader graphics line exceeds Dora/bgfx's 32-bit expanded vertex limit";
			return false;
		}
		primitiveVertices.reserve(segmentCount * 4);
		primitiveIndices.reserve(segmentCount * 6);
		const float halfWidth = lineWidth * 0.5f;
		for (std::size_t index = 0; index < segmentCount; ++index)
		{
			const Vec2 &from = vertices[index];
			const Vec2 &to = vertices[(index + 1) % vertices.size()];
			const float dx = to.x - from.x;
			const float dy = to.y - from.y;
			const float length = std::hypot(dx, dy);
			if (length <= std::numeric_limits<float>::epsilon())
				continue;
			const float nx = -dy / length * halfWidth;
			const float ny = dx / length * halfWidth;
			const auto base = static_cast<uint32_t>(primitiveVertices.size());
			primitiveVertices.push_back({from.x + nx, from.y + ny, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
			primitiveVertices.push_back({to.x + nx, to.y + ny, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
			primitiveVertices.push_back({to.x - nx, to.y - ny, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
			primitiveVertices.push_back({from.x - nx, from.y - ny, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
			primitiveIndices.insert(primitiveIndices.end(), {base, base + 1,
				base + 2, base, base + 2, base + 3});
		}
	}
	if (primitiveVertices.empty() || primitiveIndices.empty())
	{
		error.clear();
		return true;
	}
	Texture2D *texture = ensureWhiteTexture(error);
	if (!texture) return false;
	const auto shaderFound = _shaders.find(_activeShader);
	if (shaderFound != _shaders.end() && shaderFound->second.usesVertexID)
	{
		const auto &shader = shaderFound->second;
		const Vec4 rgba = color.toVec4();
		const float coordinateHeight = static_cast<float>(getActivePixelHeight());
		std::vector<Love::GraphicsBackend::MeshVertex> dynamicVertices;
		dynamicVertices.reserve(primitiveVertices.size());
		std::vector<float> vertexIDs;
		vertexIDs.reserve(primitiveVertices.size());
		for (std::size_t index = 0; index < primitiveVertices.size(); ++index)
		{
			const auto &vertex = primitiveVertices[index];
			dynamicVertices.push_back({vertex.x, coordinateHeight - vertex.y,
				vertex.z, vertex.w, vertex.u, vertex.v, rgba.x, rgba.y, rgba.z, rgba.w});
			vertexIDs.push_back(static_cast<float>(index));
		}
		std::vector<LoveDynamicMeshAttribute> attributes{{
			shader.vertexIDSemantic, 1, std::move(vertexIDs)}};
		auto *node = LoveDynamicMeshNode::create(std::move(dynamicVertices),
			std::move(primitiveIndices), std::move(attributes),
			std::vector<LoveDynamicMeshInstanceAttribute>{}, 1, std::array<Vec4, 5>{},
			texture, toDoraBlendFunc(_blendMode, _blendAlphaMode),
			meshSamplerFlags(texture, Love::GraphicsBackend::TextureFilter::Nearest,
				Love::GraphicsBackend::TextureWrap::Clamp, Love::GraphicsBackend::TextureWrap::Clamp),
			shader.effect.get(), coordinateHeight, true, _wireframe);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
		markRenderCommand();
		_drawNode = nullptr;
		error.clear();
		return true;
	}
	auto *node = LoveTexturedMeshNode::create(std::move(primitiveVertices), std::move(primitiveIndices),
		texture, toDoraBlendFunc(_blendMode, _blendAlphaMode),
		meshSamplerFlags(texture, Love::GraphicsBackend::TextureFilter::Nearest,
			Love::GraphicsBackend::TextureWrap::Clamp, Love::GraphicsBackend::TextureWrap::Clamp),
		shaderFound == _shaders.end() ? nullptr : shaderFound->second.effect.get(), true, _wireframe);
	(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
	markRenderCommand();
	_drawNode = nullptr;
	error.clear();
	return true;
}

bool LoveNode::drawPolyline(std::span<const Vec2> input, bool closed, float lineWidth,
	Love::GraphicsBackend::LineStyle lineStyle, Love::GraphicsBackend::LineJoin lineJoin,
	const Love::GraphicsBackend::Transform2D &transform, Color color, std::string &error)
{
	if (lineWidth <= 0.0f || input.size() < 2)
	{
		error.clear();
		return true;
	}
	std::vector<Vec2> points;
	points.reserve(input.size());
	for (const auto &point : input)
	{
		if (points.empty() || point != points.back()) points.push_back(point);
	}
	if (closed && points.size() > 1 && points.front() == points.back()) points.pop_back();
	if (points.size() < 2 || (closed && points.size() < 3))
	{
		error.clear();
		return true;
	}

	std::vector<Vec2> positions;
	std::vector<float> opacity;
	std::vector<uint32_t> indices;
	auto appendQuad = [&](const Vec2 &a, const Vec2 &b, const Vec2 &c, const Vec2 &d,
		float aa, float ab, float ac, float ad) {
		const auto base = static_cast<uint32_t>(positions.size());
		positions.insert(positions.end(), {a, b, c, d});
		opacity.insert(opacity.end(), {aa, ab, ac, ad});
		indices.insert(indices.end(), {base, base + 1, base + 2,
			base + 2, base + 1, base + 3});
	};
	auto appendStrip = [&](std::span<const Vec2> strip, std::span<const float> alpha) {
		const auto base = static_cast<uint32_t>(positions.size());
		positions.insert(positions.end(), strip.begin(), strip.end());
		opacity.insert(opacity.end(), alpha.begin(), alpha.end());
		for (uint32_t index = 0; index + 2 < strip.size(); ++index)
			indices.insert(indices.end(), {base + index, base + index + 1, base + index + 2});
	};
	auto normalized = [](const Vec2 &value, float length) {
		const float magnitude = std::hypot(value.x, value.y);
		return magnitude > std::numeric_limits<float>::epsilon()
			? Vec2{value.x * length / magnitude, value.y * length / magnitude}
			: Vec2{};
	};
	auto perpendicular = [&](const Vec2 &segment, float length) {
		return normalized(Vec2{-segment.y, segment.x}, length);
	};
	const bool smooth = lineStyle == Love::GraphicsBackend::LineStyle::Smooth;
	const float pixelScale = std::max(transform.pixelScale, 0.000001f);
	const float pixelSize = 1.0f / pixelScale;
	const float coreHalfWidth = smooth ? std::max(0.0f, lineWidth * 0.5f - pixelSize * 0.3f)
		: lineWidth * 0.5f;

	if (lineJoin == Love::GraphicsBackend::LineJoin::None)
	{
		const std::size_t segmentCount = closed ? points.size() : points.size() - 1;
		for (std::size_t index = 0; index < segmentCount; ++index)
		{
			const Vec2 a = points[index];
			const Vec2 b = points[(index + 1) % points.size()];
			const Vec2 direction = normalized(b - a, 1.0f);
			if (direction == Vec2{}) continue;
			const Vec2 normal{-direction.y * coreHalfWidth, direction.x * coreHalfWidth};
			const Vec2 aTop = a + normal;
			const Vec2 bTop = b + normal;
			const Vec2 aBottom = a - normal;
			const Vec2 bBottom = b - normal;
			appendQuad(aTop, bTop, aBottom, bBottom, 1, 1, 1, 1);
			if (smooth)
			{
				const Vec2 outerNormal{-direction.y * (coreHalfWidth + pixelSize),
					direction.x * (coreHalfWidth + pixelSize)};
				const Vec2 cap = direction * pixelSize;
				const Vec2 outerATop = a - cap + outerNormal;
				const Vec2 outerBTop = b + cap + outerNormal;
				const Vec2 outerABottom = a - cap - outerNormal;
				const Vec2 outerBBottom = b + cap - outerNormal;
				appendQuad(aTop, bTop, outerATop, outerBTop, 1, 1, 0, 0);
				appendQuad(bBottom, aBottom, outerBBottom, outerABottom, 1, 1, 0, 0);
				appendQuad(aBottom, aTop, outerABottom, outerATop, 1, 1, 0, 0);
				appendQuad(bTop, bBottom, outerBTop, outerBBottom, 1, 1, 0, 0);
			}
		}
	}
	else
	{
		constexpr float parallelEpsilon = 0.05f;
		std::vector<Vec2> coords = points;
		if (closed) coords.push_back(points.front());
		std::vector<Vec2> anchors;
		std::vector<Vec2> normals;
		anchors.reserve(lineJoin == Love::GraphicsBackend::LineJoin::Bevel
			? coords.size() * 4 : coords.size() * 2);
		normals.reserve(anchors.capacity());
		Vec2 segment = closed ? coords.front() - coords[coords.size() - 2]
			: coords[1] - coords[0];
		float segmentLength = std::hypot(segment.x, segment.y);
		Vec2 segmentNormal = perpendicular(segment, coreHalfWidth);
		auto appendMiter = [&](const Vec2 &pointA, const Vec2 &pointB) {
			const Vec2 next = pointB - pointA;
			const float nextLength = std::hypot(next.x, next.y);
			if (nextLength <= std::numeric_limits<float>::epsilon()) return;
			const Vec2 nextNormal = perpendicular(next, coreHalfWidth);
			anchors.insert(anchors.end(), {pointA, pointA});
			const float determinant = segment.x * next.y - segment.y * next.x;
			if (segmentLength <= std::numeric_limits<float>::epsilon()
				|| std::abs(determinant) / (segmentLength * nextLength) < parallelEpsilon)
			{
				normals.insert(normals.end(), {segmentNormal, -segmentNormal});
				if (segment.x * next.x + segment.y * next.y < 0.0f)
				{
					anchors.insert(anchors.end(), {pointA, pointA});
					normals.insert(normals.end(), {-segmentNormal, segmentNormal});
				}
			}
			else
			{
				const Vec2 delta = nextNormal - segmentNormal;
				const float lambda = (delta.x * next.y - delta.y * next.x) / determinant;
				const Vec2 miter = segmentNormal + segment * lambda;
				normals.insert(normals.end(), {miter, -miter});
			}
			segment = next;
			segmentLength = nextLength;
			segmentNormal = nextNormal;
		};
		auto appendBevel = [&](const Vec2 &pointA, const Vec2 &pointB) {
			const Vec2 next = pointB - pointA;
			const float nextLength = std::hypot(next.x, next.y);
			if (nextLength <= std::numeric_limits<float>::epsilon()) return;
			const Vec2 nextNormal = perpendicular(next, coreHalfWidth);
			const float determinant = segment.x * next.y - segment.y * next.x;
			if (segmentLength <= std::numeric_limits<float>::epsilon()
				|| std::abs(determinant) / (segmentLength * nextLength) < parallelEpsilon)
			{
				anchors.insert(anchors.end(), {pointA, pointA});
				normals.insert(normals.end(), {segmentNormal, -segmentNormal});
				if (segment.x * next.x + segment.y * next.y < 0.0f)
				{
					anchors.insert(anchors.end(), {pointA, pointA});
					normals.insert(normals.end(), {-segmentNormal, segmentNormal});
				}
			}
			else
			{
				const Vec2 delta = nextNormal - segmentNormal;
				const float lambda = (delta.x * next.y - delta.y * next.x) / determinant;
				const Vec2 miter = segmentNormal + segment * lambda;
				anchors.insert(anchors.end(), {pointA, pointA, pointA, pointA});
				if (determinant > 0.0f)
					normals.insert(normals.end(), {miter, -segmentNormal, miter, -nextNormal});
				else
					normals.insert(normals.end(), {segmentNormal, -miter, nextNormal, -miter});
			}
			segment = next;
			segmentLength = nextLength;
			segmentNormal = nextNormal;
		};
		for (std::size_t index = 0; index + 1 < coords.size(); ++index)
		{
			if (lineJoin == Love::GraphicsBackend::LineJoin::Miter)
				appendMiter(coords[index], coords[index + 1]);
			else appendBevel(coords[index], coords[index + 1]);
		}
		const Vec2 finalA = coords.back();
		const Vec2 finalB = closed ? coords[1] : finalA + segment;
		if (lineJoin == Love::GraphicsBackend::LineJoin::Miter)
			appendMiter(finalA, finalB);
		else appendBevel(finalA, finalB);

		std::vector<Vec2> core;
		core.reserve(normals.size());
		for (std::size_t index = 0; index < normals.size(); ++index)
			core.push_back(anchors[index] + normals[index]);
		std::vector<float> coreAlpha(core.size(), 1.0f);
		appendStrip(core, coreAlpha);
		if (smooth && core.size() >= 4)
		{
			std::vector<Vec2> fringe(2 * core.size() + (closed ? 0 : 2));
			std::vector<float> fringeAlpha(fringe.size(), 0.0f);
			for (std::size_t index = 0; index + 1 < core.size(); index += 2)
			{
				fringe[index] = core[index];
				fringe[index + 1] = core[index] + normalized(normals[index], pixelSize);
				fringeAlpha[index] = 1.0f;
				const auto reverse = core.size() - index - 1;
				fringe[core.size() + index] = core[reverse];
				fringe[core.size() + index + 1] = core[reverse]
					+ normalized(normals[reverse], pixelSize);
				fringeAlpha[core.size() + index] = 1.0f;
			}
			if (!closed)
			{
				Vec2 spacer = normalized(fringe[1] - fringe[3], pixelSize);
				fringe[1] += spacer;
				fringe[fringe.size() - 3] += spacer;
				spacer = normalized(fringe[core.size() - 1] - fringe[core.size() - 3], pixelSize);
				fringe[core.size() - 1] += spacer;
				fringe[core.size() + 1] += spacer;
				fringe[fringe.size() - 2] = fringe[0];
				fringe[fringe.size() - 1] = fringe[1];
				fringeAlpha[fringe.size() - 2] = 1.0f;
			}
			appendStrip(fringe, fringeAlpha);
		}
	}

	if (positions.empty() || indices.empty())
	{
		error.clear();
		return true;
	}
	const float surfaceHeight = static_cast<float>(getActivePixelHeight());
	for (auto &position : positions)
		position = transformLovePoint(position, transform, surfaceHeight);
	Texture2D *texture = ensureWhiteTexture(error);
	if (!texture) return false;
	const Vec4 rgba = color.toVec4();
	std::vector<SpriteVertex> meshVertices;
	meshVertices.reserve(positions.size());
	for (std::size_t index = 0; index < positions.size(); ++index)
	{
		const Color vertexColor(Vec4{rgba.x, rgba.y, rgba.z, rgba.w * opacity[index]});
		meshVertices.push_back({positions[index].x, positions[index].y,
			0.0f, 1.0f, 0.0f, 0.0f, vertexColor.toABGR()});
	}
	const auto sampler = meshSamplerFlags(texture,
		Love::GraphicsBackend::TextureFilter::Nearest,
		Love::GraphicsBackend::TextureWrap::Clamp,
		Love::GraphicsBackend::TextureWrap::Clamp);
	if (_activeShader != 0 && _shaders.at(_activeShader).usesVertexID)
	{
		const auto &shader = _shaders.at(_activeShader);
		const float coordinateHeight = static_cast<float>(getActivePixelHeight());
		std::vector<Love::GraphicsBackend::MeshVertex> dynamicVertices;
		dynamicVertices.reserve(positions.size());
		std::vector<float> vertexIDs;
		vertexIDs.reserve(positions.size());
		for (std::size_t index = 0; index < positions.size(); ++index)
		{
			dynamicVertices.push_back({positions[index].x, coordinateHeight - positions[index].y,
				0.0f, 1.0f, 0.0f, 0.0f, rgba.x, rgba.y, rgba.z, rgba.w * opacity[index]});
			vertexIDs.push_back(static_cast<float>(index));
		}
		std::vector<LoveDynamicMeshAttribute> attributes{{
			shader.vertexIDSemantic, 1, std::move(vertexIDs)}};
		auto *node = LoveDynamicMeshNode::create(std::move(dynamicVertices), std::move(indices),
			std::move(attributes), std::vector<LoveDynamicMeshInstanceAttribute>{}, 1,
			std::array<Vec4, 5>{}, texture, toDoraBlendFunc(_blendMode, _blendAlphaMode),
			sampler, shader.effect.get(), coordinateHeight, true, _wireframe);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
	}
	else
	{
		SpriteEffect *effect = _activeShader == 0 ? nullptr : _shaders.at(_activeShader).effect.get();
		auto *node = LoveTexturedMeshNode::create(std::move(meshVertices), std::move(indices),
			texture, toDoraBlendFunc(_blendMode, _blendAlphaMode), sampler, effect, true, _wireframe);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
	}
	markRenderCommand();
	_drawNode = nullptr;
	error.clear();
	return true;
}

bool LoveNode::drawShaderPoints(std::span<const Vec2> points, float pointSize,
	Color color, std::string &error)
{
	if (points.size() > std::numeric_limits<uint32_t>::max() / 4)
	{
		error = "Shader graphics points exceed Dora/bgfx's 32-bit expanded vertex limit";
		return false;
	}
	std::vector<SpriteVertex> pointVertices;
	std::vector<uint32_t> pointIndices;
	pointVertices.reserve(points.size() * 4);
	pointIndices.reserve(points.size() * 6);
	const float halfSize = pointSize * 0.5f;
	const uint32_t packedColor = color.toABGR();
	for (const auto &point : points)
	{
		const auto base = static_cast<uint32_t>(pointVertices.size());
		pointVertices.push_back({point.x - halfSize, point.y - halfSize, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
		pointVertices.push_back({point.x + halfSize, point.y - halfSize, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
		pointVertices.push_back({point.x + halfSize, point.y + halfSize, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
		pointVertices.push_back({point.x - halfSize, point.y + halfSize, 0.0f, 1.0f, 0.0f, 0.0f, packedColor});
		pointIndices.insert(pointIndices.end(), {base, base + 1,
			base + 2, base, base + 2, base + 3});
	}
	if (pointVertices.empty())
	{
		error.clear();
		return true;
	}
	Texture2D *texture = ensureWhiteTexture(error);
	if (!texture) return false;
	const auto &shader = _shaders.at(_activeShader);
	if (shader.usesVertexID)
	{
		const Vec4 rgba = color.toVec4();
		const float coordinateHeight = static_cast<float>(getActivePixelHeight());
		std::vector<Love::GraphicsBackend::MeshVertex> dynamicVertices;
		dynamicVertices.reserve(pointVertices.size());
		std::vector<float> vertexIDs;
		vertexIDs.reserve(pointVertices.size());
		for (std::size_t index = 0; index < pointVertices.size(); ++index)
		{
			const auto &vertex = pointVertices[index];
			dynamicVertices.push_back({vertex.x, coordinateHeight - vertex.y,
				vertex.z, vertex.w, vertex.u, vertex.v, rgba.x, rgba.y, rgba.z, rgba.w});
			vertexIDs.push_back(static_cast<float>(index));
		}
		std::vector<LoveDynamicMeshAttribute> attributes{{
			shader.vertexIDSemantic, 1, std::move(vertexIDs)}};
		auto *node = LoveDynamicMeshNode::create(std::move(dynamicVertices),
			std::move(pointIndices), std::move(attributes),
			std::vector<LoveDynamicMeshInstanceAttribute>{}, 1, std::array<Vec4, 5>{},
			texture, toDoraBlendFunc(_blendMode, _blendAlphaMode),
			meshSamplerFlags(texture, Love::GraphicsBackend::TextureFilter::Nearest,
				Love::GraphicsBackend::TextureWrap::Clamp, Love::GraphicsBackend::TextureWrap::Clamp),
			shader.effect.get(), coordinateHeight, true);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
		markRenderCommand();
		_drawNode = nullptr;
		error.clear();
		return true;
	}
	auto *node = LoveTexturedMeshNode::create(std::move(pointVertices), std::move(pointIndices), texture,
		toDoraBlendFunc(_blendMode, _blendAlphaMode),
		meshSamplerFlags(texture, Love::GraphicsBackend::TextureFilter::Nearest,
			Love::GraphicsBackend::TextureWrap::Clamp, Love::GraphicsBackend::TextureWrap::Clamp),
		_shaders.at(_activeShader).effect.get(), true);
	(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
	markRenderCommand();
	_drawNode = nullptr;
	error.clear();
	return true;
}

bool LoveNode::drawMesh(std::span<const Love::GraphicsBackend::MeshVertex> vertices,
	std::span<const Love::GraphicsBackend::MeshAttributeData> attributes,
	std::span<const std::uint32_t> indices, std::string_view drawMode,
	Love::GraphicsBackend::ImageHandle image, Love::GraphicsBackend::CanvasHandle canvas,
	float pointSize, Love::GraphicsBackend::TextureFilter filter,
	Love::GraphicsBackend::TextureWrap wrapU, Love::GraphicsBackend::TextureWrap wrapV,
	std::string &error, int instanceCount)
{
	if (instanceCount <= 0)
	{
		error.clear();
		return true;
	}
	const bool hardwareInstanced = instanceCount > 1;
	if (hardwareInstanced && _activeShader == 0)
	{
		error = "hardware-instanced Love Mesh drawing currently requires an active Shader";
		return false;
	}
	if (hardwareInstanced && (bgfx::getCaps()->supported & BGFX_CAPS_INSTANCING) == 0)
	{
		error = "Love Mesh instancing is not supported by the active renderer";
		return false;
	}
	if (hardwareInstanced)
	{
		const auto shader = _shaders.find(_activeShader);
		if (shader == _shaders.end() || !shader->second.instancedEffect)
		{
			error = "the active Love Shader has no hardware-instanced variant";
			return false;
		}
	}
	if (vertices.size() > std::numeric_limits<uint32_t>::max())
	{
		error = "Love Mesh exceeds Dora/bgfx's 32-bit vertex limit";
		return false;
	}
	bool requiresIndex32 = vertices.size() > std::numeric_limits<uint16_t>::max();
	for (const auto index : indices)
	{
		if (index >= vertices.size())
		{
			error = "Mesh vertex map contains an index outside its vertex data";
			return false;
		}
		requiresIndex32 = requiresIndex32 || index > std::numeric_limits<uint16_t>::max();
	}
	if (requiresIndex32 && (bgfx::getCaps()->supported & BGFX_CAPS_INDEX32) == 0)
	{
		error = "32-bit Love Mesh indices are not supported by the active renderer";
		return false;
	}
	Texture2D *texture = nullptr;
	bool arrayTexture = false;
	if (image != 0)
	{
		const auto found = _images.find(image);
		if (found == _images.end())
		{
			error = "Mesh Image texture is closed";
			return false;
		}
		if (found->second.type != Love::GraphicsBackend::TextureType::Texture2D
			&& found->second.type != Love::GraphicsBackend::TextureType::Array)
		{
			error = "direct Mesh drawing currently requires a 2D Image or layered SpriteBatch texture";
			return false;
		}
		arrayTexture = found->second.type == Love::GraphicsBackend::TextureType::Array;
		if (arrayTexture)
		{
			for (const auto &vertex : vertices)
			{
				if (!std::isfinite(vertex.textureLayer)
					|| vertex.textureLayer < 0.0f
					|| vertex.textureLayer >= static_cast<float>(found->second.slices))
				{
					error = "ArrayImage Mesh vertices require valid SpriteBatch layer coordinates";
					return false;
				}
			}
		}
		texture = found->second.texture;
	}
	else if (canvas != 0)
	{
		const auto found = _canvases.find(canvas);
		if (found == _canvases.end() || !found->second.texture)
		{
			error = "Mesh Canvas texture is closed";
			return false;
		}
		texture = found->second.texture;
	}
	auto drawShaderHandle = _activeShader;
	if (arrayTexture && drawShaderHandle == 0)
	{
		drawShaderHandle = ensureArrayTextureShader(error);
		if (drawShaderHandle == 0) return false;
	}
	std::vector<LoveDynamicMeshAttribute> dynamicAttributes;
	std::vector<LoveDynamicMeshInstanceAttribute> instanceAttributes;
	std::array<Vec4, 5> instanceSelectors{};
	if (drawShaderHandle != 0)
	{
		const auto addInstanceAttribute = [&](const Love::GraphicsBackend::MeshAttributeData &attribute,
			int selectorIndex, const Vec4 &defaultValue) -> bool {
			if (attribute.values.size() != static_cast<std::size_t>(instanceCount)
				* static_cast<std::size_t>(attribute.components))
			{
				error = "Mesh per-instance attribute '" + attribute.name + "' has an invalid value count";
				return false;
			}
			if (instanceAttributes.size() >= 5)
			{
				error = "Dora/bgfx supports at most 5 active per-instance Mesh attributes";
				return false;
			}
			const int slot = static_cast<int>(instanceAttributes.size());
			(&instanceSelectors[static_cast<std::size_t>(selectorIndex / 4)].x)[selectorIndex % 4]
				= static_cast<float>(slot + 1);
			instanceAttributes.push_back({slot, attribute.components, defaultValue, attribute.values});
			return true;
		};
		const auto &shaderResource = _shaders.at(drawShaderHandle);
		const auto &shaderAttributes = hardwareInstanced
			? shaderResource.instancedAttributes : shaderResource.attributes;
		dynamicAttributes.reserve(shaderAttributes.size());
		for (const auto &[name, shaderAttribute] : shaderAttributes)
		{
			const auto found = std::find_if(attributes.begin(), attributes.end(),
				[&](const auto &attribute) { return attribute.name == name; });
			if (found == attributes.end())
			{
				error = "active Love Shader requires enabled Mesh vertex attribute '" + name + "'";
				return false;
			}
			if (found->components != shaderAttribute.components)
			{
				error = "Mesh vertex attribute '" + name + "' has "
					+ std::to_string(found->components) + " components, but the active Shader expects "
					+ std::to_string(shaderAttribute.components);
				return false;
			}
			if (found->perInstance)
			{
				if (!addInstanceAttribute(*found, shaderAttribute.selectorIndex,
					Vec4{0.0f, 0.0f, 0.0f, 1.0f})) return false;
				dynamicAttributes.push_back({shaderAttribute.semantic, shaderAttribute.components,
					std::vector<float>(vertices.size()
						* static_cast<std::size_t>(found->components), 0.0f)});
			}
			else
			{
				if (found->values.size() != vertices.size() * static_cast<std::size_t>(found->components))
				{
					error = "Mesh vertex attribute '" + name + "' has an invalid value count";
					return false;
				}
				dynamicAttributes.push_back({shaderAttribute.semantic, shaderAttribute.components, found->values});
			}
		}
		if (shaderResource.usesVertexID)
		{
			const auto found = std::find_if(attributes.begin(), attributes.end(),
				[](const auto &attribute) { return attribute.name == "__DoraLoveVertexID"; });
			if (found == attributes.end() || found->components != 1
				|| found->values.size() != vertices.size())
			{
				error = "Love Mesh is missing its internal love_VertexID stream";
				return false;
			}
			const auto semantic = hardwareInstanced
				? shaderResource.instancedVertexIDSemantic : shaderResource.vertexIDSemantic;
			if (semantic == bgfx::Attrib::Count)
			{
				error = "active Love Shader has no usable love_VertexID attribute semantic";
				return false;
			}
			dynamicAttributes.push_back({semantic, 1, found->values});
		}
		if (hardwareInstanced)
		{
			for (const auto &[name, selectorIndex, defaultValue] : {
				std::tuple<std::string_view, int, Vec4>{"VertexPosition", 0, {0.0f, 0.0f, 0.0f, 1.0f}},
				std::tuple<std::string_view, int, Vec4>{"VertexTexCoord", 1, {0.0f, 0.0f, 0.0f, 1.0f}},
				std::tuple<std::string_view, int, Vec4>{"VertexColor", 2, {1.0f, 1.0f, 1.0f, 1.0f}},
			})
			{
				const auto found = std::find_if(attributes.begin(), attributes.end(),
					[&](const auto &attribute) { return attribute.name == name && attribute.perInstance; });
				if (found != attributes.end() && !addInstanceAttribute(*found, selectorIndex, defaultValue))
					return false;
			}
		}
		if (arrayTexture)
		{
			if (shaderResource.mainTextureLayerSemantic == bgfx::Attrib::Count)
			{
				error = "active ArrayImage Shader has no usable layer attribute semantic";
				return false;
			}
			std::vector<float> layers;
			layers.reserve(vertices.size());
			for (const auto &vertex : vertices) layers.push_back(vertex.textureLayer);
			dynamicAttributes.push_back({shaderResource.mainTextureLayerSemantic, 1, std::move(layers)});
		}
	}

	const float height = static_cast<float>(getActivePixelHeight());
	if (drawMode == "points")
	{
		if (!texture && drawShaderHandle == 0)
		{
			for (const auto index : indices)
			{
				const auto &vertex = vertices[index];
				ensureDrawNode()->drawDot({vertex.x + 0.5f, height - vertex.y + 0.5f},
					pointSize * 0.5f, Color(Vec4{vertex.red, vertex.green, vertex.blue, vertex.alpha}));
			}
			error.clear();
			return true;
		}
		if (indices.size() > std::numeric_limits<uint32_t>::max() / 4)
		{
			error = "Shader or textured Mesh points exceed Dora/bgfx's 32-bit expanded vertex limit";
			return false;
		}
		if (!texture)
		{
			texture = ensureWhiteTexture(error);
			if (!texture) return false;
			filter = Love::GraphicsBackend::TextureFilter::Nearest;
			wrapU = Love::GraphicsBackend::TextureWrap::Clamp;
			wrapV = Love::GraphicsBackend::TextureWrap::Clamp;
		}
		if (!dynamicAttributes.empty() || hardwareInstanced)
		{
			std::vector<Love::GraphicsBackend::MeshVertex> pointVertices;
			std::vector<uint32_t> pointIndices;
			std::vector<LoveDynamicMeshAttribute> pointAttributes;
			pointVertices.reserve(indices.size() * 4);
			pointIndices.reserve(indices.size() * 6);
			pointAttributes.reserve(dynamicAttributes.size());
			for (const auto &attribute : dynamicAttributes)
			{
				LoveDynamicMeshAttribute expanded{attribute.semantic, attribute.components, {}};
				expanded.values.reserve(indices.size() * 4 * static_cast<std::size_t>(attribute.components));
				pointAttributes.push_back(std::move(expanded));
			}
			const float halfSize = pointSize * 0.5f;
			for (const auto index : indices)
			{
				auto vertex = vertices[index];
				const float centerX = vertex.x + 0.5f;
				const float centerY = vertex.y + 0.5f;
				const auto base = static_cast<uint32_t>(pointVertices.size());
				vertex.x = centerX - halfSize; vertex.y = centerY - halfSize; pointVertices.push_back(vertex);
				vertex.x = centerX + halfSize; vertex.y = centerY - halfSize; pointVertices.push_back(vertex);
				vertex.x = centerX + halfSize; vertex.y = centerY + halfSize; pointVertices.push_back(vertex);
				vertex.x = centerX - halfSize; vertex.y = centerY + halfSize; pointVertices.push_back(vertex);
				pointIndices.insert(pointIndices.end(), {base, base + 1,
					base + 2, base, base + 2, base + 3});
				for (std::size_t attributeIndex = 0; attributeIndex < dynamicAttributes.size(); ++attributeIndex)
				{
					const auto &source = dynamicAttributes[attributeIndex];
					auto &target = pointAttributes[attributeIndex].values;
					const float *value = source.values.data()
						+ static_cast<std::size_t>(index) * static_cast<std::size_t>(source.components);
					for (int copy = 0; copy < 4; ++copy)
						target.insert(target.end(), value, value + source.components);
				}
			}
			auto *node = LoveDynamicMeshNode::create(std::move(pointVertices), std::move(pointIndices),
				std::move(pointAttributes), std::move(instanceAttributes), instanceCount,
				instanceSelectors, texture, toDoraBlendFunc(_blendMode, _blendAlphaMode),
				meshSamplerFlags(texture, filter, wrapU, wrapV),
				(hardwareInstanced ? _shaders.at(drawShaderHandle).instancedEffect
					: _shaders.at(drawShaderHandle).effect).get(), height, true);
			(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
			markRenderCommand();
			_drawNode = nullptr;
			error.clear();
			return true;
		}
		std::vector<SpriteVertex> pointVertices;
		std::vector<uint32_t> pointIndices;
		pointVertices.reserve(indices.size() * 4);
		pointIndices.reserve(indices.size() * 6);
		const float halfSize = pointSize * 0.5f;
		for (const auto index : indices)
		{
			const auto &vertex = vertices[index];
			const float centerX = vertex.x + 0.5f;
			const float centerY = height - vertex.y + 0.5f;
			const uint32_t color = Color(Vec4{vertex.red, vertex.green, vertex.blue, vertex.alpha}).toABGR();
			const auto base = static_cast<uint32_t>(pointVertices.size());
			pointVertices.push_back({centerX - halfSize, centerY - halfSize, vertex.z, vertex.w,
				vertex.u, vertex.v, color});
			pointVertices.push_back({centerX + halfSize, centerY - halfSize, vertex.z, vertex.w,
				vertex.u, vertex.v, color});
			pointVertices.push_back({centerX + halfSize, centerY + halfSize, vertex.z, vertex.w,
				vertex.u, vertex.v, color});
			pointVertices.push_back({centerX - halfSize, centerY + halfSize, vertex.z, vertex.w,
				vertex.u, vertex.v, color});
			pointIndices.insert(pointIndices.end(), {base, base + 1,
				base + 2, base, base + 2, base + 3});
		}
		auto *node = LoveTexturedMeshNode::create(std::move(pointVertices), std::move(pointIndices), texture,
			toDoraBlendFunc(_blendMode, _blendAlphaMode), meshSamplerFlags(texture, filter, wrapU, wrapV),
			drawShaderHandle != 0 ? _shaders.at(drawShaderHandle).effect.get() : nullptr, true);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
		markRenderCommand();
		_drawNode = nullptr;
		error.clear();
		return true;
	}
	if (_activeShader != 0 && !texture)
	{
		texture = ensureWhiteTexture(error);
		if (!texture) return false;
		filter = Love::GraphicsBackend::TextureFilter::Nearest;
		wrapU = Love::GraphicsBackend::TextureWrap::Clamp;
		wrapV = Love::GraphicsBackend::TextureWrap::Clamp;
	}

	std::vector<uint32_t> triangles;
	if (drawMode == "triangles")
	{
		const std::size_t count = indices.size() - indices.size() % 3;
		triangles.reserve(count);
		for (std::size_t index = 0; index < count; ++index)
			triangles.push_back(indices[index]);
	}
	else if (drawMode == "fan")
	{
		if (indices.size() >= 3)
		{
			triangles.reserve((indices.size() - 2) * 3);
			for (std::size_t index = 1; index + 1 < indices.size(); ++index)
			{
				triangles.push_back(indices[0]);
				triangles.push_back(indices[index]);
				triangles.push_back(indices[index + 1]);
			}
		}
	}
	else if (drawMode == "strip")
	{
		if (indices.size() >= 3)
		{
			triangles.reserve((indices.size() - 2) * 3);
			for (std::size_t index = 0; index + 2 < indices.size(); ++index)
			{
				if ((index & 1) == 0)
				{
					triangles.push_back(indices[index]);
					triangles.push_back(indices[index + 1]);
				}
				else
				{
					triangles.push_back(indices[index + 1]);
					triangles.push_back(indices[index]);
				}
				triangles.push_back(indices[index + 2]);
			}
		}
	}
	else
	{
		error = "unsupported Mesh draw mode";
		return false;
	}
	if (triangles.empty())
	{
		error.clear();
		return true;
	}

	if (!dynamicAttributes.empty() || hardwareInstanced)
	{
		std::vector<Love::GraphicsBackend::MeshVertex> meshVertices(vertices.begin(), vertices.end());
		auto *node = LoveDynamicMeshNode::create(std::move(meshVertices), std::move(triangles),
			std::move(dynamicAttributes), std::move(instanceAttributes), instanceCount,
			instanceSelectors, texture, toDoraBlendFunc(_blendMode, _blendAlphaMode),
			meshSamplerFlags(texture, filter, wrapU, wrapV),
			(hardwareInstanced ? _shaders.at(drawShaderHandle).instancedEffect
				: _shaders.at(drawShaderHandle).effect).get(), height, true, _wireframe);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
	}
	else if (_wireframe || texture || vertices.size() > std::numeric_limits<uint16_t>::max()
		|| std::any_of(triangles.begin(), triangles.end(),
			[](uint32_t index) { return index > std::numeric_limits<uint16_t>::max(); }))
	{
		if (!texture)
		{
			texture = ensureWhiteTexture(error);
			if (!texture) return false;
			filter = Love::GraphicsBackend::TextureFilter::Nearest;
			wrapU = Love::GraphicsBackend::TextureWrap::Clamp;
			wrapV = Love::GraphicsBackend::TextureWrap::Clamp;
		}
		std::vector<SpriteVertex> meshVertices;
		meshVertices.reserve(vertices.size());
		for (const auto &vertex : vertices)
		{
			meshVertices.push_back({vertex.x, height - vertex.y, vertex.z, vertex.w,
				vertex.u, vertex.v, Color(Vec4{vertex.red, vertex.green, vertex.blue, vertex.alpha}).toABGR()});
		}
		auto *node = LoveTexturedMeshNode::create(std::move(meshVertices), std::move(triangles), texture,
			toDoraBlendFunc(_blendMode, _blendAlphaMode), meshSamplerFlags(texture, filter, wrapU, wrapV),
			drawShaderHandle != 0 ? _shaders.at(drawShaderHandle).effect.get() : nullptr,
			false, _wireframe);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
	}
	else
	{
		std::vector<uint16_t> drawIndices;
		drawIndices.reserve(triangles.size());
		for (const auto index : triangles) drawIndices.push_back(static_cast<uint16_t>(index));
		std::vector<DrawVertexInput> meshVertices;
		meshVertices.reserve(vertices.size());
		for (const auto &vertex : vertices)
		{
			meshVertices.push_back({
				{vertex.x, height - vertex.y, vertex.z, vertex.w},
				{vertex.red, vertex.green, vertex.blue, vertex.alpha},
				{vertex.u, vertex.v}});
		}
		auto *node = DrawNode::create();
		node->setBlendFunc(toDoraBlendFunc(_blendMode, _blendAlphaMode));
		node->drawIndexedVertices(meshVertices, drawIndices);
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
	}
	markRenderCommand();
	_drawNode = nullptr;
	error.clear();
	return true;
}

Love::GraphicsBackend::ShaderHandle LoveNode::newShader(std::string_view vertexSource,
	std::string_view pixelSource, std::string &warnings, std::string &error)
{
	warnings.clear();
	LoveShaderLanguage vertexLanguage;
	LoveShaderLanguage pixelLanguage;
	std::string vertexBody;
	std::string pixelBody;
	if (!parseLoveShaderLanguage(vertexSource, vertexLanguage, vertexBody, error)
		|| !parseLoveShaderLanguage(pixelSource, pixelLanguage, pixelBody, error)) return 0;
	if (!vertexSource.empty() && !pixelSource.empty() && vertexLanguage != pixelLanguage)
	{
		error = "vertex and pixel shader languages must match";
		return 0;
	}
	const LoveShaderLanguage language = !vertexSource.empty() ? vertexLanguage : pixelLanguage;
	std::string normalizedVertexBody;
	std::string normalizedPixelBody;
	LoveShaderInterfaceShapeMap vertexInterfaceShapes;
	LoveShaderInterfaceShapeMap pixelInterfaceShapes;
	if (!normalizeLoveShaderInterfaceBlocks(vertexBody, true, language,
			normalizedVertexBody, vertexInterfaceShapes, error)
		|| !normalizeLoveShaderInterfaceBlocks(pixelBody, false, language,
			normalizedPixelBody, pixelInterfaceShapes, error)) return 0;
	for (const auto &[identity, pixelShape] : pixelInterfaceShapes)
	{
		const auto found = vertexInterfaceShapes.find(identity);
		if (found == vertexInterfaceShapes.end()) continue;
		const auto &vertexShape = found->second;
		const std::size_t separator = identity.find('.');
		const std::string blockName = identity.substr(0, separator);
		if (vertexShape.blockCount != pixelShape.blockCount
			|| vertexShape.blockArray != pixelShape.blockArray)
		{
			error = "Love Shader interface block '" + blockName
				+ "' has mismatched vertex/pixel instance array sizes";
			return 0;
		}
		if (vertexShape.memberCount != pixelShape.memberCount
			|| vertexShape.memberArray != pixelShape.memberArray)
		{
			error = "Love Shader interface block member '" + identity
				+ "' has mismatched vertex/pixel array sizes";
			return 0;
		}
		if (vertexShape.nestedArrayCounts != pixelShape.nestedArrayCounts)
		{
			error = "Love Shader nested interface member '" + identity
				+ "' has mismatched vertex/pixel array shapes";
			return 0;
		}
		if (vertexShape.structTypes != pixelShape.structTypes)
		{
			error = "Love Shader nested interface member '" + identity
				+ "' has mismatched vertex/pixel struct types";
			return 0;
		}
	}
	vertexBody = std::move(normalizedVertexBody);
	pixelBody = std::move(normalizedPixelBody);
	LoveShaderVaryingMap varyingMap;
	if (!parseLoveShaderVaryings(vertexBody, pixelBody, language, varyingMap, error)) return 0;
	std::string varyingPath;
	std::string varyingDefinition;
	if (!buildLoveShaderVaryingDefinition(varyingMap, varyingPath, varyingDefinition, error)) return 0;
	LoveShaderTranslation vertexTranslation;
	LoveShaderTranslation instancedVertexTranslation;
	LoveShaderTranslation pixelTranslation;
	if (!translateLoveShaderStage(pixelBody, false, language, varyingMap, pixelTranslation, error)
		|| !translateLoveShaderStage(vertexBody, true, language, varyingMap, vertexTranslation,
			error, false, pixelTranslation.mainTextureType))
		return 0;
	if (pixelTranslation.colorOutputs + 1 > static_cast<int>(bgfx::getCaps()->limits.maxFBAttachments))
	{
		error = "Love Shader color output count exceeds the renderer framebuffer attachment limit";
		return 0;
	}
	std::string vertexWarnings;
	std::string fragmentWarnings;
	Ref<Shader> vertex(compileLoveShader(vertexTranslation, ShaderStage::Vertex,
		"vertex", varyingPath, varyingDefinition, vertexWarnings, error));
	if (!vertex) return 0;
	Ref<Shader> fragment(compileLoveShader(pixelTranslation, ShaderStage::Fragment,
		"pixel", varyingPath, varyingDefinition, fragmentWarnings, error));
	if (!fragment) return 0;
	auto appendWarnings = [&](std::string_view source, const std::string &message) {
		if (message.empty()) return;
		if (!warnings.empty() && warnings.back() != '\n') warnings.push_back('\n');
		warnings += "Dora ";
		warnings += source;
		warnings += ":\n";
		warnings += message;
	};
	appendWarnings("vertex Shader translator", vertexTranslation.warnings);
	appendWarnings("pixel Shader translator", pixelTranslation.warnings);
	appendWarnings("vertex Shader compiler", vertexWarnings);
	appendWarnings("pixel Shader compiler", fragmentWarnings);
	Ref<SpriteEffect> effect(SpriteEffect::create(vertex.get(), fragment.get()));
	if (!effect || effect->getPasses().empty())
	{
		error = "bgfx could not link the translated Love vertex and pixel Shader stages";
		return 0;
	}
	Ref<Shader> instancedVertex;
	Ref<SpriteEffect> instancedEffect;
	std::string instancingError;
	if (translateLoveShaderStage(vertexBody, true, language, varyingMap,
		instancedVertexTranslation, instancingError, true, pixelTranslation.mainTextureType))
	{
		std::string instancedWarnings;
		instancedVertex = compileLoveShader(instancedVertexTranslation, ShaderStage::Vertex,
			"instanced vertex", varyingPath, varyingDefinition, instancedWarnings, instancingError);
		if (instancedVertex)
		{
			appendWarnings("instanced vertex Shader compiler", instancedWarnings);
			Ref<SpriteEffect> candidate(SpriteEffect::create(instancedVertex.get(), fragment.get()));
			if (candidate && !candidate->getPasses().empty()) instancedEffect = candidate;
		}
	}
	for (Pass *pass : effect->getPasses())
		pass->set("u_loveTransform"_slice, Matrix::Indentity);
	if (instancedEffect) for (Pass *pass : instancedEffect->getPasses())
	{
		pass->set("u_loveTransform"_slice, Matrix::Indentity);
		const std::array<Vec4, 5> selectors{};
		pass->set("u_loveInstanceSelectors"_slice, std::span<const Vec4>(selectors));
	}
	ShaderResource resource;
	resource.vertex = vertex;
	resource.fragment = fragment;
	resource.effect = effect;
	resource.instancedVertex = instancedVertex;
	resource.instancedEffect = instancedEffect;
	resource.colorOutputs = pixelTranslation.colorOutputs;
	resource.hasMainTexture = pixelTranslation.mainTextureType.has_value();
	if (pixelTranslation.mainTextureType)
		resource.mainTextureType = *pixelTranslation.mainTextureType;
	resource.mainTextureLayerSemantic = vertexTranslation.mainTextureLayerSemantic;
	resource.usesInstanceID = vertexTranslation.usesInstanceID;
	resource.usesVertexID = vertexTranslation.usesVertexID;
	resource.vertexIDSemantic = vertexTranslation.vertexIDSemantic;
	resource.instancedVertexIDSemantic = instancedVertexTranslation.vertexIDSemantic;
	for (const auto &[name, attribute] : vertexTranslation.attributes)
		resource.attributes.emplace(name, ShaderResource::Attribute{
			attribute.semantic, attribute.components, attribute.selectorIndex});
	if (instancedEffect)
		for (const auto &[name, attribute] : instancedVertexTranslation.attributes)
			resource.instancedAttributes.emplace(name, ShaderResource::Attribute{
				attribute.semantic, attribute.components, attribute.selectorIndex});
	auto makeUniform = [](const LoveShaderUniformInfo &info) {
		ShaderUniform uniform;
		uniform.gpuName = info.gpuName;
		uniform.type = info.type;
		uniform.textureType = info.textureType;
		uniform.components = info.components;
		uniform.count = info.count;
		uniform.samplerSlot = info.samplerSlot;
		if (info.type == Love::GraphicsBackend::ShaderUniformType::Matrix && info.components == 16)
			uniform.matrixValues.resize(static_cast<std::size_t>(info.count));
		else if (info.type != Love::GraphicsBackend::ShaderUniformType::Sampler)
			uniform.vectorValues.resize(static_cast<std::size_t>(info.count)
				* (info.type == Love::GraphicsBackend::ShaderUniformType::Matrix
					&& info.components == 9 ? 3 : 1));
		return uniform;
	};
	const auto maxTextureSamplers = bgfx::getCaps()->limits.maxTextureSamplers;
	for (const auto &[name, info] : vertexTranslation.uniforms)
	{
		if (info.samplerSlot != 0 && info.samplerSlot + info.count > maxTextureSamplers)
		{
			error = "Love Shader Image uniform count exceeds the renderer sampler limit";
			return 0;
		}
		resource.uniforms.emplace(name, makeUniform(info));
	}
	for (const auto &[name, info] : pixelTranslation.uniforms)
	{
		if (info.samplerSlot != 0 && info.samplerSlot + info.count > maxTextureSamplers)
		{
			error = "Love Shader Image uniform count exceeds the renderer sampler limit";
			return 0;
		}
		if (const auto found = resource.uniforms.find(name); found != resource.uniforms.end())
		{
			if (found->second.type != info.type || found->second.textureType != info.textureType
				|| found->second.components != info.components
				|| found->second.count != info.count
				|| found->second.samplerSlot != info.samplerSlot)
			{
				error = "Love Shader uniform '" + name + "' has different stage types";
				return 0;
			}
		}
		else resource.uniforms.emplace(name, makeUniform(info));
	}
	const auto handle = _nextShaderHandle++;
	_shaders.emplace(handle, std::move(resource));
	error.clear();
	return handle;
}

void LoveNode::clearShaderSamplerBindings(ShaderResource &shader)
{
	for (const auto &[name, uniform] : shader.uniforms)
	{
		DORA_UNUSED_PARAM(name);
		if (uniform.type != Love::GraphicsBackend::ShaderUniformType::Sampler)
			continue;
		for (int index = 0; index < uniform.count; ++index)
		{
			const std::string gpuName = uniform.count == 1 ? uniform.gpuName
				: uniform.gpuName + "_" + std::to_string(index);
			for (SpriteEffect *effect : {shader.effect.get(), shader.instancedEffect.get()})
				if (effect) effect->get(0)->remove(gpuName);
		}
	}
	shader.samplerCanvases.clear();
}

void LoveNode::releaseShader(Love::GraphicsBackend::ShaderHandle shader)
{
	if (_activeShader == shader) _activeShader = 0;
	if (_arrayTextureShader == shader) _arrayTextureShader = 0;
	const auto found = _shaders.find(shader);
	if (found == _shaders.end()) return;
	if (_graphicsFrameActive)
		_retiredShaders.push_back(std::move(found->second));
	else clearShaderSamplerBindings(found->second);
	_shaders.erase(found);
}

bool LoveNode::hasShaderUniform(Love::GraphicsBackend::ShaderHandle shader,
	std::string_view name) const
{
	const auto found = _shaders.find(shader);
	return found != _shaders.end() && found->second.uniforms.contains(std::string(name));
}

bool LoveNode::getShaderUniformInfo(Love::GraphicsBackend::ShaderHandle shader,
	std::string_view name, Love::GraphicsBackend::ShaderUniformInfo &info) const
{
	const auto found = _shaders.find(shader);
	if (found == _shaders.end()) return false;
	const auto uniform = found->second.uniforms.find(std::string(name));
	if (uniform == found->second.uniforms.end()) return false;
	info = {uniform->second.type, uniform->second.textureType,
		uniform->second.components, uniform->second.count};
	return true;
}

bool LoveNode::sendShaderFloats(Love::GraphicsBackend::ShaderHandle shader,
	std::string_view name, std::span<const float> values, bool, std::string &error)
{
	const auto found = _shaders.find(shader);
	if (found == _shaders.end())
	{
		error = "Love Shader is closed";
		return false;
	}
	const auto uniform = found->second.uniforms.find(std::string(name));
	if (uniform == found->second.uniforms.end())
	{
		error = "Shader uniform '" + std::string(name) + "' does not exist or is not active";
		return false;
	}
	if (uniform->second.type == Love::GraphicsBackend::ShaderUniformType::Sampler)
	{
		error = "Shader uniform '" + std::string(name) + "' is an Image sampler";
		return false;
	}
	const std::size_t components = static_cast<std::size_t>(uniform->second.components);
	if (values.empty() || values.size() % components != 0
		|| values.size() / components > static_cast<std::size_t>(uniform->second.count))
	{
		error = "Shader uniform '" + std::string(name) + "' expects up to "
			+ std::to_string(uniform->second.count) + " value(s) with "
			+ std::to_string(uniform->second.components) + " component(s) each";
		return false;
	}
	const auto setBothEffects = [&](const auto &setter) {
		setter(found->second.effect->get(0));
		if (found->second.instancedEffect)
			setter(found->second.instancedEffect->get(0));
	};
	const std::size_t sentCount = values.size() / components;
	if (uniform->second.type == Love::GraphicsBackend::ShaderUniformType::Matrix
		&& uniform->second.components == 16)
	{
		const bool transposeForRenderer = bgfx::getRendererType() == bgfx::RendererType::Metal;
		for (std::size_t index = 0; index < sentCount; ++index)
		{
			// Love stores Shader matrices column-major, matching GLSL indexing.
			// Metal exposes a Dora-native Mat4 with the opposite logical indexing,
			// while OpenGL ES consumes Love's column-major values directly. Direct3D
			// corrects its HLSL matrix indexing in shaderMatrixValue instead, avoiding
			// renderer-side matrix-array upload ambiguity. mat2/mat3 are reconstructed
			// explicitly from vec4 columns below.
			auto &target = uniform->second.matrixValues[index];
			for (std::size_t column = 0; column < 4; ++column)
				for (std::size_t row = 0; row < 4; ++row)
				{
					const std::size_t targetIndex = transposeForRenderer
						? row * 4 + column : column * 4 + row;
					target.m[targetIndex] = values[index * components + column * 4 + row];
				}
		}
		setBothEffects([&](Pass *pass) { pass->set(uniform->second.gpuName,
			std::span<const Matrix>(uniform->second.matrixValues)); });
	}
	else if (uniform->second.type == Love::GraphicsBackend::ShaderUniformType::Matrix
		&& uniform->second.components == 9)
	{
		for (std::size_t index = 0; index < sentCount; ++index)
			for (std::size_t column = 0; column < 3; ++column)
			{
				auto &target = uniform->second.vectorValues[index * 3 + column];
				for (std::size_t row = 0; row < 3; ++row)
					(&target.x)[row] = values[index * components + column * 3 + row];
				target.w = 0.0f;
			}
		setBothEffects([&](Pass *pass) { pass->set(uniform->second.gpuName,
			std::span<const Vec4>(uniform->second.vectorValues)); });
	}
	else
	{
		for (std::size_t index = 0; index < sentCount; ++index)
			for (std::size_t component = 0; component < components; ++component)
				(&uniform->second.vectorValues[index].x)[component] = values[index * components + component];
		setBothEffects([&](Pass *pass) { pass->set(uniform->second.gpuName,
			std::span<const Vec4>(uniform->second.vectorValues)); });
	}
	error.clear();
	return true;
}

bool LoveNode::sendShaderTextures(Love::GraphicsBackend::ShaderHandle shader,
	std::string_view name, std::span<const Love::GraphicsBackend::ShaderTexture> textures,
	std::string &error)
{
	const auto found = _shaders.find(shader);
	if (found == _shaders.end())
	{
		error = "Love Shader is closed";
		return false;
	}
	const auto uniform = found->second.uniforms.find(std::string(name));
	if (uniform == found->second.uniforms.end())
	{
		error = "Shader uniform '" + std::string(name) + "' does not exist or is not active";
		return false;
	}
	if (uniform->second.type != Love::GraphicsBackend::ShaderUniformType::Sampler)
	{
		error = "Shader uniform '" + std::string(name) + "' is numeric";
		return false;
	}
	if (textures.empty() || textures.size() > static_cast<std::size_t>(uniform->second.count))
	{
		error = "Shader Image uniform '" + std::string(name) + "' expects up to "
			+ std::to_string(uniform->second.count) + " texture value(s)";
		return false;
	}
	struct PendingTexture
	{
		Texture2D *texture = nullptr;
		Love::GraphicsBackend::CanvasHandle canvas = 0;
		uint32_t flags = 0;
	};
	std::vector<PendingTexture> pending;
	pending.reserve(textures.size());
	for (std::size_t index = 0; index < textures.size(); ++index)
	{
		const auto &binding = textures[index];
		if ((binding.image == 0) == (binding.canvas == 0))
		{
			error = "Shader Image uniform requires exactly one Image or Canvas at index "
				+ std::to_string(index + 1);
			return false;
		}
		Texture2D *texture = nullptr;
		if (binding.image != 0)
		{
			const auto source = _images.find(binding.image);
			if (source == _images.end())
			{
				error = "Shader Image is closed or belongs to another LoveNode";
				return false;
			}
			if (source->second.type != uniform->second.textureType)
			{
				error = "Shader texture type does not match the declared Image sampler";
				return false;
			}
			texture = source->second.texture;
		}
		else
		{
			if (uniform->second.textureType != Love::GraphicsBackend::TextureType::Texture2D)
			{
				error = "Canvas can only be sent to a 2D Image sampler";
				return false;
			}
			const auto source = _canvases.find(binding.canvas);
			if (source == _canvases.end() || !source->second.texture)
			{
				error = "Shader Canvas is closed or belongs to another LoveNode";
				return false;
			}
			if (!source->second.readable)
			{
				error = "Shader Canvas must be readable";
				return false;
			}
			if (std::find(_activeCanvases.begin(), _activeCanvases.end(), binding.canvas)
				!= _activeCanvases.end() || binding.canvas == _activeCanvasDepthStencil)
			{
				error = "a Canvas cannot be sampled while it is an active render target";
				return false;
			}
			texture = source->second.texture;
		}
		pending.push_back({texture, binding.canvas,
			meshSamplerFlags(texture, binding.filter, binding.wrapU, binding.wrapV, binding.wrapW)});
	}
	for (std::size_t index = 0; index < pending.size(); ++index)
	{
		const std::string elementName = uniform->second.count == 1 ? std::string(name)
			: std::string(name) + "[" + std::to_string(index + 1) + "]";
		const std::string gpuName = uniform->second.count == 1 ? uniform->second.gpuName
			: uniform->second.gpuName + "_" + std::to_string(index);
		if (pending[index].canvas == 0)
			found->second.samplerCanvases.erase(elementName);
		else found->second.samplerCanvases[elementName] = pending[index].canvas;
		for (SpriteEffect *effect : {found->second.effect.get(), found->second.instancedEffect.get()})
			if (effect) effect->get(0)->set(gpuName, pending[index].texture,
				static_cast<uint8_t>(uniform->second.samplerSlot + index), pending[index].flags);
	}
	error.clear();
	return true;
}

bool LoveNode::setShader(Love::GraphicsBackend::ShaderHandle shader, std::string &error)
{
	if (shader != 0 && !_shaders.contains(shader))
	{
		error = "Love Shader is closed";
		return false;
	}
	if (shader != 0)
	{
		for (const auto &[name, canvas] : _shaders.at(shader).samplerCanvases)
		{
			if (std::find(_activeCanvases.begin(), _activeCanvases.end(), canvas) != _activeCanvases.end()
				|| canvas == _activeCanvasDepthStencil)
			{
				error = "Shader Canvas uniform '" + name
					+ "' cannot sample an active render target";
				return false;
			}
		}
	}
	if (_activeShader != shader)
	{
		_activeShader = shader;
		++_graphicsStats.shaderSwitches;
	}
	error.clear();
	return true;
}

bool LoveNode::validateShaderDraw(std::string &error,
	Love::GraphicsBackend::TextureType mainTextureType) const
{
	if (_activeShader == 0)
	{
		error.clear();
		return true;
	}
	const auto found = _shaders.find(_activeShader);
	if (found == _shaders.end())
	{
		error = "Love Shader is closed";
		return false;
	}
	const int availableOutputs = _activeCanvases.empty()
		? 1 : static_cast<int>(_activeCanvases.size());
	if (found->second.colorOutputs > availableOutputs)
	{
		error = "Love Shader writes " + std::to_string(found->second.colorOutputs)
			+ " color outputs, but the current render target provides only "
			+ std::to_string(availableOutputs);
		return false;
	}
	if (found->second.hasMainTexture && found->second.mainTextureType != mainTextureType)
	{
		auto textureTypeName = [](Love::GraphicsBackend::TextureType type) {
			switch (type)
			{
				case Love::GraphicsBackend::TextureType::Array: return "array";
				case Love::GraphicsBackend::TextureType::Cube: return "cube";
				case Love::GraphicsBackend::TextureType::Volume: return "volume";
				case Love::GraphicsBackend::TextureType::Texture2D: return "2d";
			}
			return "unknown";
		};
		error = "Texture's type (" + std::string(textureTypeName(mainTextureType))
			+ ") must match the type of the shader's main texture type ("
			+ textureTypeName(found->second.mainTextureType) + ")";
		return false;
	}
	error.clear();
	return true;
}

bool LoveNode::supportsMeshInstancing(Love::GraphicsBackend::ShaderHandle shader,
	std::size_t perInstanceAttributeCount) const
{
	if (shader == 0 || perInstanceAttributeCount > 5
		|| (bgfx::getCaps()->supported & BGFX_CAPS_INSTANCING) == 0)
		return false;
	const auto found = _shaders.find(shader);
	return found != _shaders.end() && found->second.instancedEffect;
}

bool LoveNode::requiresMeshInstancing(Love::GraphicsBackend::ShaderHandle shader) const
{
	const auto found = _shaders.find(shader);
	return found != _shaders.end() && found->second.usesInstanceID;
}

bool LoveNode::requiresMeshVertexID(Love::GraphicsBackend::ShaderHandle shader) const
{
	const auto found = _shaders.find(shader);
	return found != _shaders.end() && found->second.usesVertexID;
}

void LoveNode::drawTexture(Texture2D *texture,
	float sourceX, float sourceY, float sourceWidth, float sourceHeight,
	float a, float b, float c, float d, float tx, float ty, float originX, float originY,
	float red, float green, float blue, float alpha,
	Love::GraphicsBackend::TextureFilter filter,
	Love::GraphicsBackend::TextureWrap wrapU,
	Love::GraphicsBackend::TextureWrap wrapV)
{
	if (!texture)
		return;
	if (_wireframe || (_activeShader != 0 && _shaders.at(_activeShader).usesVertexID))
	{
		const float width = std::abs(sourceWidth);
		const float height = std::abs(sourceHeight);
		const float textureWidth = static_cast<float>(texture->getWidth());
		const float textureHeight = static_cast<float>(texture->getHeight());
		const float left = sourceX / textureWidth;
		const float top = sourceY / textureHeight;
		const float right = (sourceX + sourceWidth) / textureWidth;
		const float bottom = (sourceY + sourceHeight) / textureHeight;
		const auto transform = [&](float localX, float localY, float u, float v) {
			const float px = localX - originX;
			const float py = localY - originY;
			return Love::GraphicsBackend::MeshVertex{
				a * px + c * py + tx, b * px + d * py + ty, 0.0f, 1.0f,
				u, v, red, green, blue, alpha};
		};
		std::vector<Love::GraphicsBackend::MeshVertex> vertices{
			transform(0.0f, 0.0f, left, top),
			transform(width, 0.0f, right, top),
			transform(width, height, right, bottom),
			transform(0.0f, height, left, bottom),
		};
		std::vector<uint32_t> indices{0, 1, 2, 0, 2, 3};
		Node *node = nullptr;
		if (_activeShader != 0 && _shaders.at(_activeShader).usesVertexID)
		{
			const auto &shader = _shaders.at(_activeShader);
			std::vector<LoveDynamicMeshAttribute> attributes{{
				shader.vertexIDSemantic, 1, {0.0f, 1.0f, 2.0f, 3.0f}}};
			node = LoveDynamicMeshNode::create(std::move(vertices), std::move(indices),
				std::move(attributes), std::vector<LoveDynamicMeshInstanceAttribute>{}, 1,
				std::array<Vec4, 5>{}, texture, toDoraBlendFunc(_blendMode, _blendAlphaMode),
				meshSamplerFlags(texture, filter, wrapU, wrapV), shader.effect.get(),
				static_cast<float>(getActivePixelHeight()), false, _wireframe);
		}
		else
		{
			const float coordinateHeight = static_cast<float>(getActivePixelHeight());
			std::vector<SpriteVertex> spriteVertices;
			spriteVertices.reserve(vertices.size());
			for (const auto &vertex : vertices)
				spriteVertices.push_back({vertex.x, coordinateHeight - vertex.y,
					vertex.z, vertex.w, vertex.u, vertex.v,
					Color(Vec4{vertex.red, vertex.green, vertex.blue, vertex.alpha}).toABGR()});
			node = LoveTexturedMeshNode::create(std::move(spriteVertices), std::move(indices),
				texture, toDoraBlendFunc(_blendMode, _blendAlphaMode),
				meshSamplerFlags(texture, filter, wrapU, wrapV),
				_activeShader == 0 ? nullptr : _shaders.at(_activeShader).effect.get(), false, true);
		}
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
		markRenderCommand();
		_drawNode = nullptr;
		return;
	}
	Sprite *sprite = Sprite::create(texture);
	if (_activeShader != 0)
		sprite->setEffect(_shaders.at(_activeShader).effect);
	switch (filter)
	{
		case Love::GraphicsBackend::TextureFilter::Nearest: sprite->setFilter(::Dora::TextureFilter::Point); break;
		case Love::GraphicsBackend::TextureFilter::Anisotropic: sprite->setFilter(::Dora::TextureFilter::Anisotropic); break;
		case Love::GraphicsBackend::TextureFilter::Linear: sprite->setFilter(::Dora::TextureFilter::None); break;
	}
	auto toDoraWrap = [](Love::GraphicsBackend::TextureWrap wrap) -> ::Dora::TextureWrap {
		switch (wrap)
		{
			case Love::GraphicsBackend::TextureWrap::Repeat: return ::Dora::TextureWrap::None;
			case Love::GraphicsBackend::TextureWrap::MirroredRepeat: return ::Dora::TextureWrap::Mirror;
			case Love::GraphicsBackend::TextureWrap::ClampZero: return ::Dora::TextureWrap::Border;
			case Love::GraphicsBackend::TextureWrap::Clamp: return ::Dora::TextureWrap::Clamp;
		}
		return ::Dora::TextureWrap::Clamp;
	};
	sprite->setUWrap(toDoraWrap(wrapU));
	sprite->setVWrap(toDoraWrap(wrapV));
	sprite->setTextureRect({sourceX, sourceY, sourceWidth, sourceHeight});
	const float width = std::abs(sourceWidth);
	const float height = std::abs(sourceHeight);
	sprite->setSize({width, height});
	sprite->setAnchor({width > 0.0f ? originX / width : 0.0f, height > 0.0f ? 1.0f - originY / height : 1.0f});
	sprite->setPosition({tx, static_cast<float>(getActivePixelHeight()) - ty});
	const float scaleX = std::hypot(a, b);
	const float determinant = a * d - b * c;
	sprite->setScaleX(scaleX);
	sprite->setScaleY(scaleX > 0.0f ? determinant / scaleX : 0.0f);
	sprite->setAngle(std::atan2(b, a) * 180.0f / std::numbers::pi_v<float>);
	sprite->setColor(Color(Vec4{red, green, blue, alpha}));
	sprite->setBlendFunc(toDoraBlendFunc(_blendMode, _blendAlphaMode));
	(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(sprite);
	markSpriteRenderCommand(texture, filter, wrapU, wrapV);
	_drawNode = nullptr;
}

Love::GraphicsBackend::FontHandle LoveNode::newFont(const std::string &filename, int size, std::string &error)
{
	const std::string fontName = filename.empty() ? "sarasa-mono-sc-regular" : filename;
	Font *font = SharedFontCache.load(fontName, static_cast<uint32_t>(size), true);
	if (!font)
	{
		error = "Dora Content/FontCache failed to load Font '" + fontName
			+ "' (format '" + Path::getExt(fontName) + "', size " + std::to_string(size)
			+ ") in LoveNode '" + _bootFile + "'";
		return 0;
	}
	const auto handle = _nextFontHandle++;
	_fonts.emplace(handle, FontResource{fontName, size, Ref<Font>(font)});
	error.clear();
	return handle;
}

Love::GraphicsBackend::FontHandle LoveNode::newImageFont(int width, int height,
	std::span<const std::uint8_t> rgba8,
	std::span<const Love::GraphicsBackend::ImageFontGlyph> glyphs, float dpiScale,
	Love::GraphicsBackend::TextureFilter filter, std::string &error)
{
	if (width <= 0 || height <= 0 || width > UINT16_MAX || height > UINT16_MAX
		|| rgba8.size() != static_cast<std::size_t>(width) * height * 4
		|| !std::isfinite(dpiScale) || dpiScale <= 0.0f || rgba8.size() > UINT32_MAX)
	{
		error = "Love ImageFont has invalid RGBA8 atlas dimensions or DPI scale";
		return 0;
	}
	const auto gpu = bgfx::createTexture2D(static_cast<uint16_t>(width), static_cast<uint16_t>(height),
		false, 1, bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE,
		bgfx::copy(rgba8.data(), static_cast<uint32_t>(rgba8.size())));
	if (!bgfx::isValid(gpu))
	{
		error = "Dora/bgfx failed to create the Love ImageFont atlas";
		return 0;
	}
	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info, static_cast<uint16_t>(width), static_cast<uint16_t>(height),
		1, false, false, 1, bgfx::TextureFormat::RGBA8);
	Ref<Texture2D> texture(Texture2D::create(gpu, info, BGFX_TEXTURE_NONE));
	if (!texture)
	{
		bgfx::destroy(gpu);
		error = "Dora failed to wrap the Love ImageFont atlas texture";
		return 0;
	}
	FontResource resource;
	resource.size = height;
	resource.imageTexture = texture;
	resource.dpiScale = dpiScale;
	resource.imageFilter = filter;
	for (const auto &glyph : glyphs)
	{
		if (glyph.x < 0 || glyph.width <= 0 || glyph.x + glyph.width > width)
		{
			error = "Love ImageFont glyph rectangle is outside its atlas";
			return 0;
		}
		resource.imageGlyphs[glyph.codepoint] = {glyph.x, glyph.width, glyph.advance};
	}
	const auto handle = _nextFontHandle++;
	_fonts.emplace(handle, std::move(resource));
	error.clear();
	return handle;
}

void LoveNode::releaseFont(Love::GraphicsBackend::FontHandle font)
{
	_fonts.erase(font);
}

float LoveNode::getFontWidth(Love::GraphicsBackend::FontHandle font, std::string_view text) const
{
	const auto it = _fonts.find(font);
	if (it == _fonts.end())
		return 0.0f;
	if (it->second.imageTexture)
	{
		std::vector<Utf8Unit> units;
		if (!decodeUtf8Units(text, units)) return 0.0f;
		auto selectGlyph = [this, &it](std::uint32_t codepoint)
			-> std::pair<const FontResource *, const FontResource::ImageGlyph *> {
			auto findGlyph = [this, codepoint](Love::GraphicsBackend::FontHandle handle)
				-> std::pair<const FontResource *, const FontResource::ImageGlyph *> {
				const auto resource = _fonts.find(handle);
				if (resource == _fonts.end() || !resource->second.imageTexture) return {nullptr, nullptr};
				const auto glyph = resource->second.imageGlyphs.find(codepoint);
				return glyph == resource->second.imageGlyphs.end()
					? std::pair<const FontResource *, const FontResource::ImageGlyph *>{nullptr, nullptr}
					: std::pair<const FontResource *, const FontResource::ImageGlyph *>{
						&resource->second, &glyph->second};
			};
			if (auto selected = findGlyph(it->first); selected.first) return selected;
			for (const auto fallback : it->second.fallbacks)
				if (auto selected = findGlyph(fallback); selected.first) return selected;
			return {nullptr, nullptr};
		};
		float width = 0.0f, maximum = 0.0f;
		for (const auto &unit : units)
		{
			if (unit.codepoint == '\n')
			{
				maximum = std::max(maximum, width);
				width = 0.0f;
				continue;
			}
			if (unit.codepoint == '\r') continue;
			const auto [resource, glyph] = selectGlyph(unit.codepoint);
			if (resource && glyph)
				width += std::floor(static_cast<float>(glyph->advance)
					/ resource->dpiScale + 0.5f);
		}
		return std::max(maximum, width);
	}
	if (!it->second.fallbacks.empty())
	{
			std::vector<Utf8Unit> units;
			if (decodeUtf8Units(text, units))
			{
				auto selectFont = [this, &it](std::uint32_t codepoint) {
					if (it->second.font
						&& SharedFontManager.hasGlyph(it->second.font->getHandle(), codepoint))
						return it->first;
					for (const auto handle : it->second.fallbacks)
				{
					const auto fallback = _fonts.find(handle);
					if (fallback != _fonts.end() && fallback->second.font
						&& SharedFontManager.hasGlyph(fallback->second.font->getHandle(), codepoint))
						return handle;
				}
				return it->first;
			};
			float lineWidth = 0.0f;
			float maximumWidth = 0.0f;
			for (std::size_t index = 0; index < units.size();)
			{
				if (units[index].codepoint == '\n')
				{
					maximumWidth = std::max(maximumWidth, lineWidth);
					lineWidth = 0.0f;
					++index;
					continue;
				}
				const auto selected = selectFont(units[index].codepoint);
				const std::size_t begin = units[index].begin;
				std::size_t end = units[index].end;
				++index;
				while (index < units.size() && units[index].codepoint != '\n'
					&& selectFont(units[index].codepoint) == selected)
				{
					end = units[index].end;
					++index;
				}
				const auto resource = _fonts.find(selected);
				if (resource == _fonts.end()) continue;
				auto *label = Label::create(resource->second.filename,
					static_cast<std::uint32_t>(resource->second.size), true);
				if (!label) continue;
				label->setText({text.data() + begin, end - begin});
				lineWidth += label->getSize().width;
			}
			return std::max(maximumWidth, lineWidth);
		}
	}
	auto *label = Label::create(it->second.filename, static_cast<uint32_t>(it->second.size), true);
	if (!label)
		return 0.0f;
	label->setText({text.data(), text.size()});
	return label->getSize().width;
}

float LoveNode::getFontHeight(Love::GraphicsBackend::FontHandle font) const
{
	const auto it = _fonts.find(font);
	if (it == _fonts.end())
		return 0.0f;
	if (it->second.imageTexture)
		return std::floor(static_cast<float>(it->second.size) / it->second.dpiScale + 0.5f);
	if (!it->second.font) return 0.0f;
	const auto &info = it->second.font->getInfo();
	const float scale = static_cast<float>(it->second.size) / static_cast<float>(DORA_SDF_FONT_BASE_SIZE);
	return static_cast<float>(info.ascender - info.descender) * scale;
}

float LoveNode::getFontBaseline(Love::GraphicsBackend::FontHandle font) const
{
	const auto it = _fonts.find(font);
	if (it == _fonts.end() || it->second.imageTexture || !it->second.font)
		return 0.0f;
	const float scale = static_cast<float>(it->second.size) / static_cast<float>(DORA_SDF_FONT_BASE_SIZE);
	return static_cast<float>(it->second.font->getInfo().ascender) * scale;
}

float LoveNode::getFontAscent(Love::GraphicsBackend::FontHandle font) const
{
	return getFontBaseline(font);
}

float LoveNode::getFontDescent(Love::GraphicsBackend::FontHandle font) const
{
	const auto it = _fonts.find(font);
	if (it == _fonts.end() || it->second.imageTexture || !it->second.font)
		return 0.0f;
	const float scale = static_cast<float>(it->second.size) / static_cast<float>(DORA_SDF_FONT_BASE_SIZE);
	return static_cast<float>(it->second.font->getInfo().descender) * scale;
}

bool LoveNode::hasFontGlyph(Love::GraphicsBackend::FontHandle font, std::uint32_t codepoint) const
{
	const auto primary = _fonts.find(font);
	if (primary == _fonts.end())
		return false;
	if (primary->second.imageTexture && primary->second.imageGlyphs.contains(codepoint)) return true;
	if (primary->second.font
		&& SharedFontManager.hasGlyph(primary->second.font->getHandle(), codepoint))
		return true;
	for (const auto handle : primary->second.fallbacks)
	{
		const auto fallback = _fonts.find(handle);
		if (fallback == _fonts.end()) continue;
		if (fallback->second.imageTexture && fallback->second.imageGlyphs.contains(codepoint)) return true;
		if (fallback->second.font
			&& SharedFontManager.hasGlyph(fallback->second.font->getHandle(), codepoint)) return true;
	}
	return false;
}

float LoveNode::getFontKerning(Love::GraphicsBackend::FontHandle font,
	std::uint32_t left, std::uint32_t right) const
{
	const auto primary = _fonts.find(font);
	if (primary == _fonts.end()) return 0.0f;
	if (primary->second.imageTexture) return 0.0f;
	std::vector<Love::GraphicsBackend::FontHandle> candidates{font};
	candidates.insert(candidates.end(), primary->second.fallbacks.begin(), primary->second.fallbacks.end());
	for (const auto handle : candidates)
	{
		const auto resource = _fonts.find(handle);
		if (resource == _fonts.end() || !resource->second.font) continue;
		auto *doraFont = resource->second.font.get();
		if (SharedFontManager.hasGlyph(doraFont->getHandle(), left)
			&& SharedFontManager.hasGlyph(doraFont->getHandle(), right))
		{
			const float scale = static_cast<float>(resource->second.size)
				/ static_cast<float>(DORA_SDF_FONT_BASE_SIZE);
			return SharedFontManager.getKerning(doraFont->getHandle(), left, right) * scale;
		}
	}
	return 0.0f;
}

bool LoveNode::setFontFallbacks(Love::GraphicsBackend::FontHandle font,
	std::span<const Love::GraphicsBackend::FontHandle> fallbacks, std::string &error)
{
	auto primary = _fonts.find(font);
	if (primary == _fonts.end())
	{
		error = "Dora Font fallback primary handle is closed";
		return false;
	}
	const bool imageFont = primary->second.imageTexture != nullptr;
	for (const auto fallback : fallbacks)
	{
		const auto resource = _fonts.find(fallback);
		if (resource == _fonts.end())
		{
			error = "Dora Font fallback handle is closed";
			return false;
		}
		if ((resource->second.imageTexture != nullptr) != imageFont)
		{
			error = "Love Font fallbacks must use the same rasterizer data type";
			return false;
		}
	}
	primary->second.fallbacks.assign(fallbacks.begin(), fallbacks.end());
	error.clear();
	return true;
}

void LoveNode::setFontLineHeight(Love::GraphicsBackend::FontHandle font, float lineHeight)
{
	if (auto found = _fonts.find(font); found != _fonts.end())
		found->second.lineHeight = lineHeight;
}

float LoveNode::getFontLineHeight(Love::GraphicsBackend::FontHandle font) const
{
	if (const auto found = _fonts.find(font); found != _fonts.end())
		return found->second.lineHeight;
	return 1.0f;
}

float LoveNode::getFontWrap(Love::GraphicsBackend::FontHandle font, std::string_view text, float limit,
	std::vector<std::string> &lines) const
{
	auto nextCharacter = [](std::string_view value, std::size_t offset) {
		const unsigned char first = static_cast<unsigned char>(value[offset]);
		std::size_t length = first < 0x80 ? 1 : first < 0xe0 ? 2 : first < 0xf0 ? 3 : 4;
		return std::min(value.size(), offset + length);
	};
	auto trimRightSpaces = [](std::string value) {
		while (!value.empty() && (value.back() == ' ' || value.back() == '\t'))
			value.pop_back();
		return value;
	};
	lines.clear();
	float maximumWidth = 0.0f;
	std::size_t paragraphStart = 0;
	while (paragraphStart <= text.size())
	{
		const std::size_t newline = text.find('\n', paragraphStart);
		const std::size_t paragraphEnd = newline == std::string_view::npos ? text.size() : newline;
		const std::string_view paragraph = text.substr(paragraphStart, paragraphEnd - paragraphStart);
		if (paragraph.empty())
			lines.emplace_back();
		else
		{
			std::size_t start = 0;
			while (start < paragraph.size())
			{
				while (start < paragraph.size() && (paragraph[start] == ' ' || paragraph[start] == '\t'))
					++start;
				if (start >= paragraph.size())
					break;
				std::size_t end = start;
				std::size_t previousEnd = start;
				std::size_t lastBreak = start;
				while (end < paragraph.size())
				{
					previousEnd = end;
					end = nextCharacter(paragraph, end);
					if (paragraph[end - 1] == ' ' || paragraph[end - 1] == '\t')
						lastBreak = end;
					if (getFontWidth(font, paragraph.substr(start, end - start)) > limit)
					{
						if (previousEnd == start)
							previousEnd = end;
						end = lastBreak > start ? lastBreak : previousEnd;
						break;
					}
				}
				if (end <= start)
					end = nextCharacter(paragraph, start);
				std::string line = trimRightSpaces(std::string(paragraph.substr(start, end - start)));
				maximumWidth = std::max(maximumWidth, getFontWidth(font, line));
				lines.push_back(std::move(line));
				start = end;
			}
		}
		if (newline == std::string_view::npos)
			break;
		paragraphStart = newline + 1;
	}
	return maximumWidth;
}

void LoveNode::drawText(Love::GraphicsBackend::FontHandle font, std::string_view text,
	float wrapLimit, std::string_view align,
	float a, float b, float c, float d, float tx, float ty, float originX, float originY,
	float red, float green, float blue, float alpha)
{
	const auto it = _fonts.find(font);
	if (it == _fonts.end())
		return;
	if (it->second.imageTexture)
	{
		std::vector<std::string> lines;
		if (wrapLimit >= 0.0f) getFontWrap(font, text, wrapLimit, lines);
		else
		{
			std::size_t start = 0;
			while (start <= text.size())
			{
				const auto newline = text.find('\n', start);
				const auto end = newline == std::string_view::npos ? text.size() : newline;
				lines.emplace_back(text.substr(start, end - start));
				if (newline == std::string_view::npos) break;
				start = newline + 1;
			}
		}
		struct ImageTextBatch
		{
			const FontResource *resource = nullptr;
			std::vector<SpriteVertex> vertices;
			std::vector<uint32_t> indices;
		};
		std::vector<ImageTextBatch> batches;
		const uint32_t color = Color(Vec4{red, green, blue, alpha}).toABGR();
		const float glyphHeight = getFontHeight(font);
		const float lineAdvance = glyphHeight * it->second.lineHeight;
		const float pixelHeight = static_cast<float>(getActivePixelHeight());
		auto appendVertex = [&](ImageTextBatch &batch, float localX, float localY, float u, float v) {
			const float loveX = a * (localX - originX) + c * (localY - originY) + tx;
			const float loveY = b * (localX - originX) + d * (localY - originY) + ty;
			batch.vertices.push_back({loveX, pixelHeight - loveY, 0.0f, 1.0f, u, v, color});
		};
		auto selectResource = [this, &it](std::uint32_t codepoint) -> const FontResource * {
			auto contains = [this, codepoint](Love::GraphicsBackend::FontHandle handle)
				-> const FontResource * {
				const auto resource = _fonts.find(handle);
				if (resource == _fonts.end() || !resource->second.imageTexture
					|| !resource->second.imageGlyphs.contains(codepoint)) return nullptr;
				return &resource->second;
			};
			if (const auto *resource = contains(it->first)) return resource;
			for (const auto fallback : it->second.fallbacks)
				if (const auto *resource = contains(fallback)) return resource;
			return nullptr;
		};
		for (std::size_t lineIndex = 0; lineIndex < lines.size(); ++lineIndex)
		{
			const float lineWidth = getFontWidth(font, lines[lineIndex]);
			float cursor = align == "center"
				? ((wrapLimit >= 0.0f ? wrapLimit : lineWidth) - lineWidth) * 0.5f
				: align == "right" ? (wrapLimit >= 0.0f ? wrapLimit : lineWidth) - lineWidth : 0.0f;
			const std::size_t spaces = align == "justify"
				? static_cast<std::size_t>(std::count(lines[lineIndex].begin(), lines[lineIndex].end(), ' ')) : 0;
			const float justify = spaces > 0 && wrapLimit >= 0.0f && lineWidth < wrapLimit
				? (wrapLimit - lineWidth) / static_cast<float>(spaces) : 0.0f;
			std::vector<Utf8Unit> units;
			if (!decodeUtf8Units(lines[lineIndex], units)) continue;
			for (const auto &unit : units)
			{
				const FontResource *resource = selectResource(unit.codepoint);
				if (resource)
				{
					const auto glyph = resource->imageGlyphs.find(unit.codepoint);
					if (batches.empty() || batches.back().resource != resource)
						batches.push_back({resource});
					auto &batch = batches.back();
					const float textureWidth = static_cast<float>(resource->imageTexture->getWidth());
					const float width = static_cast<float>(glyph->second.width) / resource->dpiScale;
					const float height = std::floor(static_cast<float>(resource->size)
						/ resource->dpiScale + 0.5f);
					const float left = static_cast<float>(glyph->second.x) / textureWidth;
					const float right = static_cast<float>(glyph->second.x + glyph->second.width) / textureWidth;
					const float top = static_cast<float>(lineIndex) * lineAdvance;
					const auto base = static_cast<uint32_t>(batch.vertices.size());
					appendVertex(batch, cursor, top, left, 0.0f);
					appendVertex(batch, cursor + width, top, right, 0.0f);
					appendVertex(batch, cursor + width, top + height, right, 1.0f);
					appendVertex(batch, cursor, top + height, left, 1.0f);
					batch.indices.insert(batch.indices.end(),
						{base, base + 1, base + 2, base, base + 2, base + 3});
					cursor += std::floor(static_cast<float>(glyph->second.advance)
						/ resource->dpiScale + 0.5f);
				}
				if (align == "justify" && unit.codepoint == ' ') cursor += justify;
			}
		}
		if (batches.empty()) return;
		for (auto &batch : batches)
		{
			if (_activeShader != 0 && _shaders.at(_activeShader).usesVertexID)
			{
				const auto &shader = _shaders.at(_activeShader);
				std::vector<Love::GraphicsBackend::MeshVertex> dynamicVertices;
				dynamicVertices.reserve(batch.vertices.size());
				std::vector<float> vertexIDs;
				vertexIDs.reserve(batch.vertices.size());
				for (std::size_t index = 0; index < batch.vertices.size(); ++index)
				{
					const auto &vertex = batch.vertices[index];
					dynamicVertices.push_back({vertex.x, pixelHeight - vertex.y,
						vertex.z, vertex.w, vertex.u, vertex.v, red, green, blue, alpha});
					vertexIDs.push_back(static_cast<float>(index));
				}
				std::vector<LoveDynamicMeshAttribute> attributes{{
					shader.vertexIDSemantic, 1, std::move(vertexIDs)}};
				auto *node = LoveDynamicMeshNode::create(std::move(dynamicVertices),
					std::move(batch.indices), std::move(attributes),
					std::vector<LoveDynamicMeshInstanceAttribute>{}, 1, std::array<Vec4, 5>{},
					batch.resource->imageTexture,
					toDoraBlendFunc(_blendMode, _blendAlphaMode),
					meshSamplerFlags(batch.resource->imageTexture, batch.resource->imageFilter,
					Love::GraphicsBackend::TextureWrap::Clamp, Love::GraphicsBackend::TextureWrap::Clamp),
					shader.effect.get(), pixelHeight, false, _wireframe);
				(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
				markRenderCommand();
				continue;
			}
			SpriteEffect *effect = _activeShader == 0 ? nullptr : _shaders.at(_activeShader).effect.get();
			auto *node = LoveTexturedMeshNode::create(std::move(batch.vertices),
				std::move(batch.indices), batch.resource->imageTexture,
				toDoraBlendFunc(_blendMode, _blendAlphaMode),
				meshSamplerFlags(batch.resource->imageTexture, batch.resource->imageFilter,
					Love::GraphicsBackend::TextureWrap::Clamp, Love::GraphicsBackend::TextureWrap::Clamp),
				effect, true, _wireframe);
			(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(node);
			markRenderCommand();
		}
		_drawNode = nullptr;
		return;
	}
	if (!it->second.fallbacks.empty() || it->second.lineHeight != 1.0f || align == "justify")
	{
		std::vector<std::string> lines;
		if (wrapLimit >= 0.0f)
			getFontWrap(font, text, wrapLimit, lines);
		else
		{
			std::size_t start = 0;
			while (start <= text.size())
			{
				const std::size_t newline = text.find('\n', start);
				const std::size_t end = newline == std::string_view::npos ? text.size() : newline;
				lines.emplace_back(text.substr(start, end - start));
				if (newline == std::string_view::npos) break;
				start = newline + 1;
			}
		}
		auto *container = Node::create();
		container->setPosition({tx, static_cast<float>(getActivePixelHeight()) - ty});
		const float scaleX = std::hypot(a, b);
		const float determinant = a * d - b * c;
		container->setScaleX(scaleX);
		container->setScaleY(scaleX > 0.0f ? determinant / scaleX : 0.0f);
		container->setAngle(std::atan2(b, a) * 180.0f / std::numbers::pi_v<float>);
		const float lineAdvance = getFontHeight(font) * it->second.lineHeight;
		for (std::size_t lineIndex = 0; lineIndex < lines.size(); ++lineIndex)
		{
			const std::string &line = lines[lineIndex];
			const float lineWidth = getFontWidth(font, line);
			float cursor = align == "center" ? std::floor(((wrapLimit >= 0.0f ? wrapLimit : lineWidth) - lineWidth) * 0.5f)
				: align == "right" ? std::floor((wrapLimit >= 0.0f ? wrapLimit : lineWidth) - lineWidth) : 0.0f;
			const std::size_t spaces = align == "justify"
				? static_cast<std::size_t>(std::count(line.begin(), line.end(), ' ')) : 0;
			const float extraSpacing = spaces > 0 && wrapLimit >= 0.0f && lineWidth < wrapLimit
				? (wrapLimit - lineWidth) / static_cast<float>(spaces) : 0.0f;
			std::vector<Utf8Unit> units;
			if (!decodeUtf8Units(line, units)) continue;
			auto selectFont = [this, &it](std::uint32_t codepoint) {
				if (it->second.font
					&& SharedFontManager.hasGlyph(it->second.font->getHandle(), codepoint))
					return it->first;
				for (const auto handle : it->second.fallbacks)
				{
					const auto fallback = _fonts.find(handle);
					if (fallback != _fonts.end() && fallback->second.font
						&& SharedFontManager.hasGlyph(fallback->second.font->getHandle(), codepoint))
						return handle;
				}
				return it->first;
			};
			for (std::size_t index = 0; index < units.size();)
			{
				const auto selected = selectFont(units[index].codepoint);
				const std::size_t begin = units[index].begin;
				std::size_t end = units[index].end;
				++index;
				while (index < units.size()
					&& !(align == "justify" && units[index - 1].codepoint == ' ')
					&& selectFont(units[index].codepoint) == selected)
				{
					end = units[index].end;
					++index;
				}
				const auto resource = _fonts.find(selected);
				if (resource == _fonts.end()) continue;
				auto *label = Label::create(resource->second.filename,
					static_cast<std::uint32_t>(resource->second.size), true);
				if (!label) continue;
				label->setText({line.data() + begin, end - begin});
				const float runWidth = label->getSize().width;
				label->setAnchor({0.0f, 1.0f});
				label->setPosition({cursor - originX,
					originY - static_cast<float>(lineIndex) * lineAdvance});
				label->setColor(Color(Vec4{red, green, blue, alpha}));
				label->setBlendFunc(toDoraBlendFunc(_blendMode, _blendAlphaMode));
				container->addChild(label);
				cursor += runWidth;
				if (align == "justify" && units[index - 1].codepoint == ' ')
					cursor += extraSpacing;
			}
		}
		Node *output = container;
		if (_wireframe)
		{
			auto *wireframe = LoveWireframeNode::create();
			wireframe->addChild(container);
			output = wireframe;
		}
		(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(output);
		markRenderCommand();
		_drawNode = nullptr;
		return;
	}
	auto *label = Label::create(it->second.filename, static_cast<uint32_t>(it->second.size), true);
	if (!label)
		return;
	if (wrapLimit >= 0.0f)
		label->setTextWidth(wrapLimit);
	label->setAlignment(align == "center" ? TextAlign::Center : align == "right" ? TextAlign::Right : TextAlign::Left);
	label->setText({text.data(), text.size()});
	const Size labelSize = label->getSize();
	label->setAnchor({labelSize.width > 0.0f ? originX / labelSize.width : 0.0f,
		labelSize.height > 0.0f ? 1.0f - originY / labelSize.height : 1.0f});
	label->setPosition({tx, static_cast<float>(getActivePixelHeight()) - ty});
	const float scaleX = std::hypot(a, b);
	const float determinant = a * d - b * c;
	label->setScaleX(scaleX);
	label->setScaleY(scaleX > 0.0f ? determinant / scaleX : 0.0f);
	label->setAngle(std::atan2(b, a) * 180.0f / std::numbers::pi_v<float>);
	label->setColor(Color(Vec4{red, green, blue, alpha}));
	label->setBlendFunc(toDoraBlendFunc(_blendMode, _blendAlphaMode));
	Node *output = label;
	if (_wireframe)
	{
		auto *wireframe = LoveWireframeNode::create();
		wireframe->addChild(label);
		output = wireframe;
	}
	(_commandRoot ? _commandRoot.get() : _frameRoot.get())->addChild(output);
	markRenderCommand();
	_drawNode = nullptr;
}

bool LoveNode::setBlendMode(std::string_view mode, std::string_view alphaMode, std::string &error)
{
	if (mode == "multiply" && alphaMode != "premultiplied")
	{
		error = "the 'multiply' blend mode must be used with premultiplied alpha";
		return false;
	}
	_blendMode.assign(mode);
	_blendAlphaMode.assign(alphaMode);
	_drawNode = nullptr;
	error.clear();
	return true;
}

void LoveNode::setScissor(bool enabled, float x, float y, float width, float height)
{
	_scissorEnabled = enabled;
	_scissor.set(x, y, width, height);
	if (_graphicsFrameActive && _frameRoot)
		beginCommandSegment();
}

void LoveNode::setColorMask(bool red, bool green, bool blue, bool alpha)
{
	_colorMask[0] = red;
	_colorMask[1] = green;
	_colorMask[2] = blue;
	_colorMask[3] = alpha;
	if (_graphicsFrameActive && _frameRoot)
		beginCommandSegment();
}

void LoveNode::setDepthMode(std::string_view compare, bool write)
{
	_depthCompare = compare;
	_depthWrite = write;
	if (_graphicsFrameActive && _frameRoot)
		beginCommandSegment();
}

void LoveNode::setMeshCullMode(std::string_view mode, std::string_view winding)
{
	_meshCullMode = mode;
	_frontFaceWinding = winding;
	if (_graphicsFrameActive && _frameRoot)
		beginCommandSegment();
}

void LoveNode::setWireframe(bool enabled)
{
	if (_wireframe == enabled) return;
	_wireframe = enabled;
	if (_graphicsFrameActive && _frameRoot)
		beginCommandSegment();
}

bool LoveNode::clearStencil(int value, std::string &error)
{
	if (_activeCanvas != 0 && !_activeCanvasStencil)
	{
		error = "drawing to a Love Canvas stencil requires setCanvas({canvas, stencil=true})";
		return false;
	}
	if (!_graphicsFrameActive || _renderPasses.empty())
	{
		error = "love.graphics.stencil is only available during the Dora-driven love.draw frame";
		return false;
	}
	beginRenderPass(BGFX_CLEAR_STENCIL, Color(0x00000000), static_cast<uint8_t>(value));
	error.clear();
	return true;
}

bool LoveNode::beginStencilWrite(std::string_view action, int value, std::string &error)
{
	if (_activeCanvas != 0 && !_activeCanvasStencil)
	{
		error = "drawing to a Love Canvas stencil requires setCanvas({canvas, stencil=true})";
		return false;
	}
	if (!_graphicsFrameActive || !_frameRoot)
	{
		error = "love.graphics.stencil is only available during the Dora-driven love.draw frame";
		return false;
	}
	_stencilWriting = true;
	_stencilAction.assign(action);
	_stencilWriteValue = value;
	beginCommandSegment();
	error.clear();
	return true;
}

void LoveNode::endStencilWrite()
{
	if (!_stencilWriting) return;
	_stencilWriting = false;
	if (_graphicsFrameActive && _frameRoot)
		beginCommandSegment();
}

void LoveNode::setStencilTest(std::string_view compare, int value)
{
	_stencilCompare.assign(compare);
	_stencilTestValue = value;
	if (_graphicsFrameActive && _frameRoot && !_stencilWriting)
		beginCommandSegment();
}

bool LoveNode::setMode(int width, int height, std::string &error)
{
	if (!setupSurface(width, height))
	{
		error = "failed to resize the Love instance surface";
		return false;
	}
	error.clear();
	return true;
}

bool LoveNode::hasWindowFocus() const
{
	return FocusedLoveNode == this;
}

bool LoveNode::hasWindowMouseFocus() const
{
	// LoveNode pointer focus and keyboard/controller focus intentionally share
	// the same Dora routing owner. A pointer press transfers this owner before
	// the Love callback is queued.
	return FocusedLoveNode == this;
}

bool LoveNode::isWindowVisible() const
{
	return isVisible();
}

void LoveNode::endFrame()
{
	_graphicsFrameActive = false;
	// RenderTarget inserts its view at the front of Dora's view order. Submitting the
	// recorded Love passes in reverse therefore preserves their logical order, including
	// Canvas -> main-surface dependencies in a single host frame.
	for (auto pass = _renderPasses.rbegin(); pass != _renderPasses.rend(); ++pass)
	{
		if (!pass->target || (pass->clearFlags == BGFX_CLEAR_NONE && !pass->hasCommands))
			continue;
		if (pass->clearFlags != BGFX_CLEAR_NONE)
			pass->target->renderWithClearFlags(pass->root, pass->clearFlags,
				pass->clearColor, pass->depth, pass->stencil);
		else
			pass->target->render(pass->root);
	}
	// Shader userdata can be collected after commands were queued in love.draw.
	// Retain the Effect through submission, then drop its sampler references so
	// retired Shaders cannot keep Canvas textures alive across stop/restart.
	for (auto &shader : _retiredShaders)
		clearShaderSamplerBindings(shader);
	_retiredShaders.clear();
	_graphicsStats.drawCalls = 0;
	_graphicsStats.drawCallsBatched = 0;
	_graphicsStats.canvasSwitches = 0;
	_graphicsStats.shaderSwitches = 0;
	if (_pendingScreenshotRequests.empty() || !_renderTarget || !_runtime)
		return;
	const auto requests = std::move(_pendingScreenshotRequests);
	_pendingScreenshotRequests.clear();
	const std::uint64_t generation = _runtimeGeneration;
	for (const std::uint64_t requestId : requests)
	{
		WRef<LoveNode> self(this);
		if (!_renderTarget->readPixelsAsync([self, generation, requestId](uint16_t width, uint16_t height,
			std::vector<uint8_t> pixels) mutable {
			if (!self || self->_runtimeGeneration != generation || !self->_runtime)
				return;
			std::string error;
			if (!self->_runtime->completeScreenshot(requestId, width, height, std::move(pixels), error))
				self->reportError("screenshot"_slice, error);
		}))
		{
			std::string error;
			_runtime->completeScreenshot(requestId, 0, 0, {}, error);
			reportError("screenshot"_slice, error);
		}
	}
}

int LoveNode::getPixelWidth() const
{
	return _renderTarget ? _renderTarget->getWidth() : 0;
}

int LoveNode::getPixelHeight() const
{
	return _renderTarget ? _renderTarget->getHeight() : 0;
}

Love::GraphicsBackend::Capabilities LoveNode::getCapabilities() const
{
	const auto *caps = bgfx::getCaps();
	Love::GraphicsBackend::Capabilities features;
	int framebufferFormats = 0;
	static constexpr std::string_view formats[] = {
		"r8", "rg8", "rgba8", "r16", "rg16", "rgba16", "r16f", "rg16f",
		"rgba16f", "r32f", "rg32f", "rgba32f", "rgba4", "rgb5a1", "rgb565",
		"rgb10a2", "rg11b10f",
	};
	for (const auto format : formats)
		if (isCanvasFormatSupported(format, true)) ++framebufferFormats;
	features.multiCanvasFormats = caps->limits.maxFBAttachments > 1 && framebufferFormats > 1;
	features.clampZero = true;
	// Love's lighten/darken mode needs min/max blend equations, which Dora's
	// current BlendFunc abstraction does not expose.
	features.lighten = false;
	features.fullNPOT = true;
	features.pixelShaderHighp = true;
	features.shaderDerivatives = true;
	features.glsl3 = true;
	features.instancing = (caps->supported & BGFX_CAPS_INSTANCING) != 0;
	return features;
}

Love::GraphicsBackend::TextureTypes LoveNode::getTextureTypes() const
{
	const auto *caps = bgfx::getCaps();
	Love::GraphicsBackend::TextureTypes types;
	types.texture2D = bgfx::isTextureValid(0, false, 1,
		bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE);
	types.array = (caps->supported & BGFX_CAPS_TEXTURE_2D_ARRAY) != 0
		&& bgfx::isTextureValid(0, false, 2, bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE);
	types.cube = bgfx::isTextureValid(0, true, 1,
		bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE);
	types.volume = (caps->supported & BGFX_CAPS_TEXTURE_3D) != 0
		&& bgfx::isTextureValid(2, false, 1, bgfx::TextureFormat::RGBA8, BGFX_TEXTURE_NONE);
	return types;
}

bool LoveNode::isImageFormatSupported(std::string_view format) const
{
	// Embedded ImageData is converted through its real format codec to RGBA8
	// before upload, so every implemented Love 11.5 ImageData format is usable
	// even when the native renderer cannot sample that storage format directly.
	static constexpr std::string_view imageDataFormats[] = {
		"r8", "rg8", "rgba8", "r16", "rg16", "rgba16", "r16f", "rg16f",
		"rgba16f", "r32f", "rg32f", "rgba32f", "rgba4", "rgb5a1", "rgb565",
		"rgb10a2", "rg11b10f",
	};
	if (std::find(std::begin(imageDataFormats), std::end(imageDataFormats), format)
		!= std::end(imageDataFormats)) return true;
	const auto textureFormat = toImageTextureFormat(format);
	if (!textureFormat) return false;
	// bgfx::isTextureValid includes both native sampling and the renderer's
	// advertised TEXTURE_2D_EMULATED conversion path. newCompressedImage uses
	// the same validation before createTexture2D, so the capability query must
	// not reject a format that creation can safely emulate (for example ASTC
	// on macOS Metal).
	return isLoveCompressedTextureValid(0, false, 1, *textureFormat);
}

Love::GraphicsBackend::RendererInfo LoveNode::getRendererInfo() const
{
	const auto *caps = bgfx::getCaps();
	const auto vendorName = [&]() -> std::string_view {
		switch (caps->vendorId)
		{
			case BGFX_PCI_ID_AMD: return "AMD";
			case BGFX_PCI_ID_APPLE: return "Apple";
			case BGFX_PCI_ID_INTEL: return "Intel";
			case BGFX_PCI_ID_NVIDIA: return "NVIDIA";
			case BGFX_PCI_ID_MICROSOFT: return "Microsoft";
			case BGFX_PCI_ID_ARM: return "ARM";
			case BGFX_PCI_ID_SOFTWARE_RASTERIZER: return "Software Rasterizer";
			default: return "Unknown";
		}
	}();
	return {
		bgfx::getRendererName(caps->rendererType),
		"bgfx API " + std::to_string(BGFX_API_VERSION),
		std::string(vendorName) + " (" + hexadecimalId(caps->vendorId) + ")",
		"PCI device " + hexadecimalId(caps->deviceId),
	};
}

Love::GraphicsBackend::SystemLimits LoveNode::getSystemLimits() const
{
	const auto *caps = bgfx::getCaps();
	Love::GraphicsBackend::SystemLimits limits;
	limits.textureSize = caps->limits.maxTextureSize;
	limits.volumeTextureSize = (caps->supported & BGFX_CAPS_TEXTURE_3D) != 0
		? caps->limits.maxTextureSize : 0.0;
	limits.cubeTextureSize = caps->limits.maxTextureSize;
	limits.textureLayers = (caps->supported & BGFX_CAPS_TEXTURE_2D_ARRAY) != 0
		? caps->limits.maxTextureLayers : 0.0;
	limits.multiCanvas = caps->limits.maxFBAttachments;
	limits.canvasMSAA = (caps->formats[bgfx::TextureFormat::RGBA8]
		& BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA) == 0
		? 1.0 : caps->rendererType == bgfx::RendererType::Metal ? 4.0 : 16.0;
	return limits;
}

Love::GraphicsBackend::Stats LoveNode::getStats() const
{
	auto stats = _graphicsStats;
	stats.canvases = _canvases.size();
	stats.images = _images.size();
	stats.fonts = _fonts.size();
	auto addTexture = [&](Texture2D *texture) {
		if (texture) stats.textureMemory += texture->getInfo().storageSize;
	};
	for (const auto &[handle, image] : _images)
	{
		DORA_UNUSED_PARAM(handle);
		addTexture(image.texture);
		for (const auto &layer : image.layerTextures) addTexture(layer);
	}
	for (const auto &[handle, canvas] : _canvases)
	{
		DORA_UNUSED_PARAM(handle);
		addTexture(canvas.texture);
	}
	for (const auto &[handle, font] : _fonts)
	{
		DORA_UNUSED_PARAM(handle);
		addTexture(font.imageTexture);
	}
	return stats;
}

bool LoveNode::requestScreenshot(std::uint64_t requestId, std::string &error)
{
	if (!_renderTarget)
	{
		error = "LoveNode main render target is unavailable";
		return false;
	}
	if ((bgfx::getCaps()->supported & BGFX_CAPS_TEXTURE_READ_BACK) == 0)
	{
		error = "Dora renderer does not support texture readback";
		return false;
	}
	_pendingScreenshotRequests.push_back(requestId);
	error.clear();
	return true;
}

int LoveNode::getActivePixelHeight() const
{
	if (_activeCanvas != 0)
	{
		const auto found = _canvases.find(_activeCanvas);
		if (found != _canvases.end() && found->second.texture)
			return found->second.texture->getHeight();
	}
	return getPixelHeight();
}

RenderTarget* LoveNode::getActiveRenderTarget() const
{
	return _activeCanvas != 0 ? _activeCanvasTarget.get() : _renderTarget.get();
}

bool LoveNode::exist(const std::string &path) const
{
	return SharedContent.exist(path);
}

bool LoveNode::isFolder(const std::string &path) const
{
	return SharedContent.isFolder(path);
}

std::string LoveNode::getExecutablePath() const
{
	return SharedApplication.getExecutablePath();
}

bool LoveNode::load(const std::string &path, std::string &data, std::string &error) const
{
	if (!SharedContent.exist(path) || SharedContent.isFolder(path))
	{
		error = "Love filesystem file does not exist: " + path;
		return false;
	}
	auto [bytes, size] = SharedContent.load(path);
	if (!bytes && size != 0)
	{
		error = "Dora Content failed to load Love filesystem file: " + path;
		return false;
	}
	if (size == 0)
		data.clear();
	else
		data.assign(reinterpret_cast<const char *>(bytes.get()), size);
	error.clear();
	return true;
}

bool LoveNode::decodeImage(std::string_view encoded, int &width, int &height,
	std::vector<std::uint8_t> &rgba8, std::string &error)
{
	if (encoded.empty())
	{
		error = "Dora bimg decoder received empty ImageData";
		return false;
	}
	bx::DefaultAllocator allocator;
	bimg::ImageContainer *image = bimg::imageParse(&allocator, encoded.data(),
		static_cast<std::uint32_t>(encoded.size()), bimg::TextureFormat::RGBA8);
	if (!image)
	{
		error = "Dora Content/bimg failed to decode ImageData";
		return false;
	}
	const std::size_t byteCount = static_cast<std::size_t>(image->m_width)
		* static_cast<std::size_t>(image->m_height) * 4;
	const bool valid = image->m_format == bimg::TextureFormat::RGBA8
		&& image->m_width > 0 && image->m_height > 0
		&& image->m_depth == 1 && image->m_numLayers == 1
		&& image->m_data != nullptr && image->m_size >= byteCount;
	if (valid)
	{
		width = static_cast<int>(image->m_width);
		height = static_cast<int>(image->m_height);
		const auto *pixels = static_cast<const std::uint8_t *>(image->m_data);
		rgba8.assign(pixels, pixels + byteCount);
	}
	bimg::imageFree(image);
	if (!valid)
	{
		error = "Dora bimg returned unsupported or invalid 2D rgba8 ImageData";
		return false;
	}
	error.clear();
	return true;
}

bool LoveNode::decodeCompressedImage(std::string_view encoded,
	Love::ImageBackend::CompressedImage &output, std::string &error)
{
	if (encoded.empty() || encoded.size() > std::numeric_limits<std::uint32_t>::max())
	{
		error = "Dora bimg parser received empty or oversized compressed image data";
		return false;
	}
	bx::DefaultAllocator allocator;
	bimg::ImageContainer *image = bimg::imageParse(&allocator, encoded.data(),
		static_cast<std::uint32_t>(encoded.size()));
	if (!image)
	{
		error = "Dora Content/bimg could not parse a compressed texture container";
		return false;
	}

	auto loveFormat = [](bimg::TextureFormat::Enum format) -> const char * {
		switch (format)
		{
			case bimg::TextureFormat::BC1: return "DXT1";
			case bimg::TextureFormat::BC2: return "DXT3";
			case bimg::TextureFormat::BC3: return "DXT5";
			case bimg::TextureFormat::BC4: return "BC4";
			case bimg::TextureFormat::BC5: return "BC5";
			case bimg::TextureFormat::BC6H: return "BC6h";
			case bimg::TextureFormat::BC7: return "BC7";
			case bimg::TextureFormat::ETC1: return "ETC1";
			case bimg::TextureFormat::ETC2: return "ETC2rgb";
			case bimg::TextureFormat::ETC2A: return "ETC2rgba";
			case bimg::TextureFormat::ETC2A1: return "ETC2rgba1";
			case bimg::TextureFormat::EACR: return "EACr";
			case bimg::TextureFormat::EACRS: return "EACrs";
			case bimg::TextureFormat::EACRG: return "EACrg";
			case bimg::TextureFormat::EACRGS: return "EACrgs";
			case bimg::TextureFormat::PTC12: return "PVR1rgb2";
			case bimg::TextureFormat::PTC14: return "PVR1rgb4";
			case bimg::TextureFormat::PTC12A: return "PVR1rgba2";
			case bimg::TextureFormat::PTC14A: return "PVR1rgba4";
			case bimg::TextureFormat::ASTC4x4: return "ASTC4x4";
			case bimg::TextureFormat::ASTC5x4: return "ASTC5x4";
			case bimg::TextureFormat::ASTC5x5: return "ASTC5x5";
			case bimg::TextureFormat::ASTC6x5: return "ASTC6x5";
			case bimg::TextureFormat::ASTC6x6: return "ASTC6x6";
			case bimg::TextureFormat::ASTC8x5: return "ASTC8x5";
			case bimg::TextureFormat::ASTC8x6: return "ASTC8x6";
			case bimg::TextureFormat::ASTC8x8: return "ASTC8x8";
			case bimg::TextureFormat::ASTC10x5: return "ASTC10x5";
			case bimg::TextureFormat::ASTC10x6: return "ASTC10x6";
			case bimg::TextureFormat::ASTC10x8: return "ASTC10x8";
			case bimg::TextureFormat::ASTC10x10: return "ASTC10x10";
			case bimg::TextureFormat::ASTC12x10: return "ASTC12x10";
			case bimg::TextureFormat::ASTC12x12: return "ASTC12x12";
			default: return nullptr;
		}
	};

	const char *format = loveFormat(image->m_format);
	const bool validShape = image->m_width > 0 && image->m_height > 0
		&& image->m_depth == 1 && image->m_numLayers == 1 && !image->m_cubeMap
		&& image->m_numMips > 0 && image->m_data != nullptr;
	if (!format || !bimg::isCompressed(image->m_format) || !validShape)
	{
		bimg::imageFree(image);
		error = "Dora bimg returned an unsupported compressed image format or texture shape";
		return false;
	}

	Love::ImageBackend::CompressedImage parsed;
	parsed.format = format;
	parsed.levels.reserve(image->m_numMips);
	for (std::uint8_t level = 0; level < image->m_numMips; ++level)
	{
		bimg::ImageMip mip{};
		if (!bimg::imageGetRawData(*image, 0, level, image->m_data, image->m_size, mip)
			|| mip.m_width == 0 || mip.m_height == 0 || mip.m_data == nullptr || mip.m_size == 0)
		{
			bimg::imageFree(image);
			error = "Dora bimg returned an invalid compressed mipmap level";
			return false;
		}
		Love::ImageBackend::CompressedImageLevel parsedLevel;
		// bimg reports block-aligned storage dimensions for compressed mipmaps
		// (for example every BC1 level below 4x4 is reported as 4x4). Love exposes
		// logical mip dimensions, while retaining the padded block payload.
		parsedLevel.width = std::max(1, static_cast<int>(image->m_width) >> level);
		parsedLevel.height = std::max(1, static_cast<int>(image->m_height) >> level);
		parsedLevel.bytes.assign(mip.m_data, mip.m_data + mip.m_size);
		parsed.levels.push_back(std::move(parsedLevel));
	}
	bimg::imageFree(image);
	output = std::move(parsed);
	error.clear();
	return true;
}

bool LoveNode::encodeImage(std::string_view format, int width, int height,
	std::span<const std::uint8_t> rgba8, std::vector<std::uint8_t> &encoded,
	std::string &error)
{
	const std::size_t expected = static_cast<std::size_t>(width)
		* static_cast<std::size_t>(height) * 4;
	if (width <= 0 || height <= 0 || rgba8.size() != expected)
	{
		error = "Dora ImageData encoder received invalid rgba8 dimensions";
		return false;
	}
	if (format == "tga")
	{
		// Love 11.5's STBHandler writes an uncompressed, top-left-origin 32-bit
		// TGA and swaps RGBA to the file format's BGRA channel order.
		constexpr std::size_t headerSize = 18;
		encoded.assign(headerSize + expected, 0);
		encoded[2] = 2;
		encoded[7] = 32;
		encoded[12] = static_cast<std::uint8_t>(width & 0xff);
		encoded[13] = static_cast<std::uint8_t>((width >> 8) & 0xff);
		encoded[14] = static_cast<std::uint8_t>(height & 0xff);
		encoded[15] = static_cast<std::uint8_t>((height >> 8) & 0xff);
		encoded[16] = 32;
		encoded[17] = 0x20;
		for (std::size_t offset = 0; offset < expected; offset += 4)
		{
			encoded[headerSize + offset] = rgba8[offset + 2];
			encoded[headerSize + offset + 1] = rgba8[offset + 1];
			encoded[headerSize + offset + 2] = rgba8[offset];
			encoded[headerSize + offset + 3] = rgba8[offset + 3];
		}
		error.clear();
		return true;
	}
	if (format != "png")
	{
		error = "Dora ImageData encoder supports only PNG and TGA";
		return false;
	}
	unsigned char *output = nullptr;
	std::size_t outputSize = 0;
	const unsigned result = lodepnglib::lodepng_encode32(&output, &outputSize, rgba8.data(),
		static_cast<unsigned>(width), static_cast<unsigned>(height));
	if (result != 0 || output == nullptr || outputSize == 0)
	{
		if (output) std::free(output);
		error = "Dora lodepng failed to encode ImageData (error "
			+ std::to_string(result) + ")";
		return false;
	}
	encoded.assign(output, output + outputSize);
	std::free(output);
	error.clear();
	return true;
}

bool LoveNode::decodeSound(std::string_view encoded, int &sampleRate, int &channels,
	std::vector<float> &samples, std::string &error)
{
	if (encoded.empty() || encoded.size() > std::numeric_limits<unsigned int>::max())
	{
		error = "Dora SoLoud decoder received empty or oversized SoundData";
		return false;
	}
	SoLoud::Wav wav;
	const SoLoud::result result = wav.loadMem(
		reinterpret_cast<const unsigned char *>(encoded.data()),
		static_cast<unsigned int>(encoded.size()), true, false);
	if (result != SoLoud::SO_NO_ERROR || !wav.mData || wav.mSampleCount == 0
		|| wav.mChannels == 0 || wav.mBaseSamplerate <= 0.0f)
	{
		error = "Dora Content/SoLoud failed to decode SoundData";
		return false;
	}
	sampleRate = static_cast<int>(std::lround(wav.mBaseSamplerate));
	channels = static_cast<int>(wav.mChannels);
	samples.resize(static_cast<std::size_t>(wav.mSampleCount) * wav.mChannels);
	for (unsigned int frame = 0; frame < wav.mSampleCount; ++frame)
	{
		for (unsigned int channel = 0; channel < wav.mChannels; ++channel)
			samples[static_cast<std::size_t>(frame) * wav.mChannels + channel]
				= wav.mData[static_cast<std::size_t>(channel) * wav.mSampleCount + frame];
	}
	error.clear();
	return true;
}

bool LoveNode::save(const std::string &path, std::string_view data, std::string &error)
{
	if (!SharedContent.save(path, reinterpret_cast<const uint8_t *>(data.data()), static_cast<int64_t>(data.size())))
	{
		error = "Dora Content failed to save Love filesystem file: " + path;
		return false;
	}
	error.clear();
	return true;
}

bool LoveNode::createFolder(const std::string &path, std::string &error)
{
	if (SharedContent.isFolder(path) || SharedContent.createFolder(path))
	{
		error.clear();
		return true;
	}
	error = "Dora Content failed to create Love filesystem directory: " + path;
	return false;
}

bool LoveNode::remove(const std::string &path, std::string &error)
{
	if (SharedContent.remove(path))
	{
		error.clear();
		return true;
	}
	error = "Dora Content failed to remove Love filesystem entry: " + path;
	return false;
}

std::optional<std::uint64_t> LoveNode::getFileSize(const std::string &path) const
{
	const auto attr = SharedContent.getAttr(path);
	return attr ? std::optional<std::uint64_t>(static_cast<std::uint64_t>(attr->size)) : std::nullopt;
}

std::vector<std::string> LoveNode::getDirectoryItems(const std::string &path) const
{
	std::vector<std::string> items;
	for (const auto &directory : SharedContent.getDirs(path))
		items.push_back(directory);
	for (const auto &file : SharedContent.getFiles(path))
		items.push_back(file);
	return items;
}

bool LoveNode::mountArchive(std::string_view archiveName, std::string_view data,
	std::string &mountedRoot, std::string &error)
{
	constexpr std::size_t MaximumFiles = 4096;
	constexpr std::size_t MaximumFileSize = 256u * 1024u * 1024u;
	constexpr std::size_t MaximumExpandedSize = 512u * 1024u * 1024u;
	if (data.empty())
	{
		error = "Love mount archive is empty: '" + std::string(archiveName) + "'";
		return false;
	}
	auto bytes = NewArray<std::uint8_t>(data.size());
	std::memcpy(bytes.get(), data.data(), data.size());
	ZipFile archive({std::move(bytes), data.size()});
	if (!archive.isOK())
	{
		error = "Dora Zip failed to open Love mount archive from Content memory";
		return false;
	}
	const auto files = archive.getAllFiles();
	if (files.empty() || files.size() > MaximumFiles)
	{
		error = "Love mount archive must contain between 1 and " + std::to_string(MaximumFiles) + " files";
		return false;
	}
	std::size_t expandedSize = 0;
	for (const auto &file : files)
	{
		const auto size = archive.getFileSize(file);
		if (!isSafeLovePackagePath(file) || !size || *size > MaximumFileSize
			|| expandedSize > MaximumExpandedSize - *size)
		{
			error = "Love mount archive contains an unsafe or oversized entry: '" + file + "'";
			return false;
		}
		expandedSize += *size;
	}
	const auto sequence = LoveMountSequence.fetch_add(1, std::memory_order_relaxed);
	mountedRoot = Path::concat({SharedContent.getWritablePath(), "LoveMounts"_slice,
		std::to_string(sequence) + "-" + std::to_string(_runtimeGeneration)});
	if (!SharedContent.createFolder(mountedRoot))
	{
		error = "Dora Content failed to create Love mount staging root";
		mountedRoot.clear();
		return false;
	}
	_mountedArchiveRoots.insert(mountedRoot);
	for (const auto &file : files)
	{
		const auto expectedSize = archive.getFileSize(file).value_or(0);
		auto entry = archive.getFileData(file);
		const std::string target = Path::concat({mountedRoot, file});
		const std::string parent = Path::getPath(target);
		if ((!entry.first && expectedSize != 0) || entry.second != expectedSize
			|| (!SharedContent.exist(parent) && !SharedContent.createFolder(parent))
			|| !SharedContent.save(target, entry.first.get(), static_cast<std::int64_t>(entry.second)))
		{
			error = "Dora Content failed to stage Love mount entry '" + file + "'";
			unmountArchive(mountedRoot);
			mountedRoot.clear();
			return false;
		}
	}
	error.clear();
	return true;
}

void LoveNode::unmountArchive(const std::string &mountedRoot)
{
	if (_mountedArchiveRoots.erase(mountedRoot) != 0 && SharedContent.exist(mountedRoot))
		SharedContent.remove(mountedRoot);
}

Love::AudioBackend::SourceHandle LoveNode::newSource(const std::string &filename,
	std::string_view sourceType, std::string &error)
{
	auto data = SharedContent.load(filename);
	if (!data.first || data.second <= 0)
	{
		error = "Dora Content failed to load Love audio Source '" + filename + "' (type '"
			+ std::string(sourceType) + "', format '" + Path::getExt(filename)
			+ "') in LoveNode '" + _bootFile + "'";
		return 0;
	}
	AudioFile *audioFile = sourceType == "stream"
		? static_cast<AudioFile *>(WavStream::create(std::move(data.first), static_cast<std::size_t>(data.second)))
		: static_cast<AudioFile *>(WavFile::create(std::move(data.first), static_cast<std::size_t>(data.second)));
	if (!audioFile)
	{
		error = "Dora SoLoud failed to decode Love audio Source '" + filename + "' (type '"
			+ std::string(sourceType) + "', format '" + Path::getExt(filename)
			+ "') in LoveNode '" + _bootFile + "'";
		return 0;
	}
	AudioBus *effectsBus = _audioBus ? AudioBus::create(_audioBus) : nullptr;
	AudioSource *audioNode = AudioSource::create(audioFile, false, effectsBus);
	if (!audioNode)
	{
		error = "failed to create Dora AudioSource node for Love audio Source '" + filename
			+ "' (type '" + std::string(sourceType) + "') in LoveNode '" + _bootFile + "'";
		return 0;
	}
	addChild(audioNode);
	const auto handle = _nextAudioSourceHandle++;
	AudioResource resource;
	resource.node = audioNode;
	resource.file = audioFile;
	resource.effectsBus = effectsBus;
	audioNode->setVolumeLimits(resource.minVolume, resource.maxVolume);
	audioNode->set3DPosition(0.0f, 0.0f, 0.0f);
	audioNode->setMinMaxDistance(resource.referenceDistance, resource.maxDistance);
	audioNode->setAttenuation(AudioSource::AttenuationModel::ApplicationDistance, resource.rolloff);
	_audioSources.emplace(handle, std::move(resource));
	error.clear();
	return handle;
}

Love::AudioBackend::SourceHandle LoveNode::newSourceFromSoundData(std::string_view pcm,
	int sampleRate, int bitDepth, int channels, std::string &error)
{
	if (pcm.empty() || pcm.size() > std::numeric_limits<std::uint32_t>::max() - 44
		|| sampleRate <= 0 || (bitDepth != 8 && bitDepth != 16) || channels <= 0)
	{
		error = "invalid Love SoundData PCM metadata for Dora SoLoud";
		return 0;
	}
	const std::size_t waveSize = 44 + pcm.size();
	auto waveData = NewArray<std::uint8_t>(waveSize);
	auto write16 = [&](std::size_t offset, std::uint16_t value) {
		waveData.get()[offset] = static_cast<std::uint8_t>(value & 0xff);
		waveData.get()[offset + 1] = static_cast<std::uint8_t>(value >> 8);
	};
	auto write32 = [&](std::size_t offset, std::uint32_t value) {
		for (int byte = 0; byte < 4; ++byte)
			waveData.get()[offset + static_cast<std::size_t>(byte)] = static_cast<std::uint8_t>(value >> (byte * 8));
	};
	std::copy_n(reinterpret_cast<const std::uint8_t *>("RIFF"), 4, waveData.get());
	write32(4, static_cast<std::uint32_t>(pcm.size() + 36));
	std::copy_n(reinterpret_cast<const std::uint8_t *>("WAVEfmt "), 8, waveData.get() + 8);
	write32(16, 16);
	write16(20, 1);
	write16(22, static_cast<std::uint16_t>(channels));
	write32(24, static_cast<std::uint32_t>(sampleRate));
	const std::uint32_t blockAlign = static_cast<std::uint32_t>(channels * bitDepth / 8);
	write32(28, static_cast<std::uint32_t>(sampleRate) * blockAlign);
	write16(32, static_cast<std::uint16_t>(blockAlign));
	write16(34, static_cast<std::uint16_t>(bitDepth));
	std::copy_n(reinterpret_cast<const std::uint8_t *>("data"), 4, waveData.get() + 36);
	write32(40, static_cast<std::uint32_t>(pcm.size()));
	std::copy_n(reinterpret_cast<const std::uint8_t *>(pcm.data()), pcm.size(), waveData.get() + 44);

	AudioFile *audioFile = WavFile::create(std::move(waveData), waveSize);
	if (!audioFile)
	{
		error = "Dora SoLoud failed to create Love audio Source from SoundData in LoveNode '" + _bootFile + "'";
		return 0;
	}
	AudioBus *effectsBus = _audioBus ? AudioBus::create(_audioBus) : nullptr;
	AudioSource *audioNode = AudioSource::create(audioFile, false, effectsBus);
	if (!audioNode)
	{
		error = "failed to create Dora AudioSource node from Love SoundData in LoveNode '" + _bootFile + "'";
		return 0;
	}
	addChild(audioNode);
	const auto handle = _nextAudioSourceHandle++;
	AudioResource resource;
	resource.node = audioNode;
	resource.file = audioFile;
	resource.effectsBus = effectsBus;
	audioNode->setVolumeLimits(resource.minVolume, resource.maxVolume);
	audioNode->set3DPosition(0.0f, 0.0f, 0.0f);
	audioNode->setMinMaxDistance(resource.referenceDistance, resource.maxDistance);
	audioNode->setAttenuation(AudioSource::AttenuationModel::ApplicationDistance, resource.rolloff);
	_audioSources.emplace(handle, std::move(resource));
	error.clear();
	return handle;
}

Love::AudioBackend::SourceHandle LoveNode::newQueueableSource(int sampleRate,
	int bitDepth, int channels, int buffers, std::string &error)
{
	if (sampleRate <= 0 || (bitDepth != 8 && bitDepth != 16)
		|| (channels != 1 && channels != 2))
	{
		error = "unsupported Love queueable Source format; expected positive sample rate, 8/16-bit, mono/stereo";
		return 0;
	}
	const int bufferCount = buffers < 1 ? 8 : std::min(buffers, 64);
	auto *audioFile = PCMQueueFile::create(static_cast<uint32_t>(sampleRate),
		static_cast<uint32_t>(bitDepth), static_cast<uint32_t>(channels),
		static_cast<uint32_t>(bufferCount));
	if (!audioFile)
	{
		error = "Dora SoLoud failed to create Love queueable Source in LoveNode '" + _bootFile + "'";
		return 0;
	}
	auto *effectsBus = _audioBus ? AudioBus::create(_audioBus) : nullptr;
	auto *audioNode = AudioSource::create(audioFile, false, effectsBus);
	if (!audioNode)
	{
		error = "failed to create Dora AudioSource node for Love queueable Source in LoveNode '"
			+ _bootFile + "'";
		return 0;
	}
	addChild(audioNode);
	const auto handle = _nextAudioSourceHandle++;
	AudioResource resource;
	resource.node = audioNode;
	resource.file = audioFile;
	resource.effectsBus = effectsBus;
	resource.queueable = true;
	audioNode->setVolumeLimits(resource.minVolume, resource.maxVolume);
	audioNode->set3DPosition(0.0f, 0.0f, 0.0f);
	audioNode->setMinMaxDistance(resource.referenceDistance, resource.maxDistance);
	audioNode->setAttenuation(AudioSource::AttenuationModel::ApplicationDistance,
		resource.rolloff);
	_audioSources.emplace(handle, std::move(resource));
	error.clear();
	return handle;
}

bool LoveNode::queueSource(Love::AudioBackend::SourceHandle source, std::string_view pcm,
	int sampleRate, int bitDepth, int channels, std::string &error)
{
	const auto found = _audioSources.find(source);
	auto *queue = found == _audioSources.end() || !found->second.queueable
		? nullptr : DoraAs<PCMQueueFile>(found->second.file.get());
	if (!queue)
	{
		error = "only queueable Love Sources can accept queued SoundData";
		return false;
	}
	if (sampleRate != static_cast<int>(queue->getSampleRate())
		|| bitDepth != static_cast<int>(queue->getBitDepth())
		|| channels != static_cast<int>(queue->getChannelCount()))
	{
		error = "queued SoundData must have the same sample rate, bit depth, and channel count as the Source";
		return false;
	}
	if (pcm.size() % static_cast<size_t>(channels * bitDepth / 8) != 0)
	{
		error = "queued SoundData byte length must be a multiple of the PCM frame size";
		return false;
	}
	if (!queue->queue(std::span<const uint8_t>(
		reinterpret_cast<const uint8_t *>(pcm.data()), pcm.size())))
	{
		error.clear();
		return false;
	}
	error.clear();
	return true;
}

int LoveNode::getSourceFreeBufferCount(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	auto *queue = found == _audioSources.end() || !found->second.queueable
		? nullptr : DoraAs<PCMQueueFile>(found->second.file.get());
	return queue ? static_cast<int>(queue->getFreeBufferCount()) : 0;
}

Love::AudioBackend::SourceHandle LoveNode::cloneSource(
	Love::AudioBackend::SourceHandle source, std::string &error)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end() || !found->second.node || !found->second.file)
	{
		error = "cannot clone a closed Love audio Source";
		return 0;
	}
	AudioFile *audioFile = found->second.file;
	if (found->second.queueable)
	{
		auto *queue = DoraAs<PCMQueueFile>(found->second.file.get());
		if (!queue)
		{
			error = "invalid Dora PCM queue while cloning a Love queueable Source";
			return 0;
		}
		audioFile = PCMQueueFile::create(static_cast<uint32_t>(queue->getSampleRate()),
			queue->getBitDepth(), queue->getChannelCount(), queue->getBufferCount());
		if (!audioFile)
		{
			error = "failed to clone the Dora PCM queue for a Love queueable Source";
			return 0;
		}
	}
	AudioBus *effectsBus = _audioBus ? AudioBus::create(_audioBus) : nullptr;
	AudioSource *audioNode = AudioSource::create(audioFile, false, effectsBus);
	if (!audioNode)
	{
		error = "failed to create Dora AudioSource node while cloning a Love audio Source in LoveNode '"
			+ _bootFile + "'";
		return 0;
	}
	audioNode->setVolume(found->second.node->getVolume());
	audioNode->setPlaySpeed(found->second.node->getPlaySpeed());
	audioNode->setLooping(found->second.node->isLooping());
	addChild(audioNode);
	const auto handle = _nextAudioSourceHandle++;
	AudioResource resource = found->second;
	resource.node = audioNode;
	resource.file = audioFile;
	resource.effectsBus = effectsBus;
	resource.position = 0.0;
	audioNode->set3DPosition(resource.spatialPosition[0], resource.spatialPosition[1],
		resource.spatialPosition[2]);
	audioNode->setVelocity(resource.velocity[0], resource.velocity[1], resource.velocity[2]);
	audioNode->set3DDirection(resource.direction[0], resource.direction[1], resource.direction[2]);
	audioNode->set3DCone(resource.coneInnerAngle, resource.coneOuterAngle,
		resource.coneOuterVolume, resource.coneOuterHighGain);
	audioNode->setAirAbsorptionFactor(resource.airAbsorptionFactor);
	audioNode->setVolumeLimits(resource.minVolume, resource.maxVolume);
	audioNode->setListenerRelative(resource.relative);
	audioNode->setMinMaxDistance(resource.referenceDistance, resource.maxDistance);
	audioNode->setAttenuation(AudioSource::AttenuationModel::ApplicationDistance, resource.rolloff);
	if (resource.effectsBus && !refreshAudioFilters(resource, error))
	{
		audioNode->removeFromParent(true);
		return 0;
	}
	_audioSources.emplace(handle, std::move(resource));
	error.clear();
	return handle;
}

void LoveNode::releaseSource(Love::AudioBackend::SourceHandle source)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end())
		return;
	if (found->second.node)
	{
		found->second.node->stop();
		found->second.node->removeFromParent(true);
	}
	_audioSources.erase(found);
}

bool LoveNode::playSource(Love::AudioBackend::SourceHandle source)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end() || !found->second.node)
		return false;
	auto &resource = found->second;
	if (resource.node->isPlaying())
	{
		if (resource.node->isPaused())
		{
			resource.node->setPaused(false);
			return true;
		}
		return false;
	}
	const bool spatial = resource.file && resource.file->getChannelCount() == 1;
	if (!(spatial ? resource.node->play3D() : resource.node->play()))
		return false;
	if (resource.position > 0.0)
		resource.node->seek(resource.position);
	return true;
}

void LoveNode::pauseSource(Love::AudioBackend::SourceHandle source, bool paused)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end() || !found->second.node)
		return;
	found->second.node->setPaused(paused);
}

void LoveNode::stopSource(Love::AudioBackend::SourceHandle source)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end())
		return;
	if (found->second.node)
		found->second.node->stop();
	if (found->second.queueable)
	{
		if (auto *queue = DoraAs<PCMQueueFile>(found->second.file.get()))
			queue->clear();
	}
	found->second.position = 0.0;
}

bool LoveNode::isSourcePlaying(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() && found->second.node
		&& found->second.node->isPlaying() && !found->second.node->isPaused();
}

bool LoveNode::isSourcePaused(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() && found->second.node && found->second.node->isPaused();
}

void LoveNode::setSourceLooping(Love::AudioBackend::SourceHandle source, bool looping)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end())
		return;
	if (found->second.node)
		found->second.node->setLooping(looping);
}

bool LoveNode::isSourceLooping(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() && found->second.node && found->second.node->isLooping();
}

void LoveNode::setSourceVolume(Love::AudioBackend::SourceHandle source, float volume)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end())
		return;
	if (found->second.node)
		found->second.node->setVolume(volume);
}

float LoveNode::getSourceVolume(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found == _audioSources.end() || !found->second.node ? 0.0f : found->second.node->getVolume();
}

void LoveNode::setSourcePitch(Love::AudioBackend::SourceHandle source, float pitch)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end())
		return;
	if (found->second.node)
		found->second.node->setPlaySpeed(pitch);
}

float LoveNode::getSourcePitch(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found == _audioSources.end() || !found->second.node ? 0.0f : found->second.node->getPlaySpeed();
}

void LoveNode::seekSource(Love::AudioBackend::SourceHandle source, double seconds)
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end())
		return;
	found->second.position = seconds;
	if (found->second.node && found->second.node->isPlaying())
		found->second.node->seek(seconds);
}

double LoveNode::tellSource(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	if (found == _audioSources.end())
		return 0.0;
	if (found->second.node && found->second.node->isPlaying())
		return found->second.node->getCurrentTime();
	return found->second.position;
}

double LoveNode::getSourceDuration(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() && found->second.file
		? found->second.file->getDuration() : 0.0;
}

double LoveNode::getSourceSampleRate(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() && found->second.file
		? found->second.file->getSampleRate() : 0.0;
}

double LoveNode::getSourceSampleCount(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() && found->second.file
		? static_cast<double>(found->second.file->getSampleCount()) : 0.0;
}

int LoveNode::getSourceChannelCount(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() && found->second.file
		? static_cast<int>(found->second.file->getChannelCount()) : 0;
}

void LoveNode::setSourcePosition(Love::AudioBackend::SourceHandle source,
	float x, float y, float z)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.spatialPosition = {x, y, z};
		if (found->second.node) found->second.node->set3DPosition(x, y, z);
	}
}

void LoveNode::getSourcePosition(Love::AudioBackend::SourceHandle source,
	float &x, float &y, float &z) const
{
	if (const auto found = _audioSources.find(source); found != _audioSources.end())
	{
		x = found->second.spatialPosition[0];
		y = found->second.spatialPosition[1];
		z = found->second.spatialPosition[2];
	}
	else x = y = z = 0.0f;
}

void LoveNode::setSourceVelocity(Love::AudioBackend::SourceHandle source,
	float x, float y, float z)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.velocity = {x, y, z};
		if (found->second.node) found->second.node->setVelocity(x, y, z);
	}
}

void LoveNode::getSourceVelocity(Love::AudioBackend::SourceHandle source,
	float &x, float &y, float &z) const
{
	if (const auto found = _audioSources.find(source); found != _audioSources.end())
	{
		x = found->second.velocity[0];
		y = found->second.velocity[1];
		z = found->second.velocity[2];
	}
	else x = y = z = 0.0f;
}

void LoveNode::setSourceDirection(Love::AudioBackend::SourceHandle source,
	float x, float y, float z)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.direction = {x, y, z};
		if (found->second.node) found->second.node->set3DDirection(x, y, z);
	}
}

void LoveNode::getSourceDirection(Love::AudioBackend::SourceHandle source,
	float &x, float &y, float &z) const
{
	if (const auto found = _audioSources.find(source); found != _audioSources.end())
	{
		x = found->second.direction[0];
		y = found->second.direction[1];
		z = found->second.direction[2];
	}
	else x = y = z = 0.0f;
}

void LoveNode::setSourceCone(Love::AudioBackend::SourceHandle source,
	float innerAngle, float outerAngle, float outerVolume, float outerHighGain)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.coneInnerAngle = innerAngle;
		found->second.coneOuterAngle = outerAngle;
		found->second.coneOuterVolume = outerVolume;
		found->second.coneOuterHighGain = outerHighGain;
		if (found->second.node)
			found->second.node->set3DCone(innerAngle, outerAngle, outerVolume, outerHighGain);
	}
}

void LoveNode::getSourceCone(Love::AudioBackend::SourceHandle source,
	float &innerAngle, float &outerAngle, float &outerVolume,
	float &outerHighGain) const
{
	if (const auto found = _audioSources.find(source); found != _audioSources.end())
	{
		innerAngle = found->second.coneInnerAngle;
		outerAngle = found->second.coneOuterAngle;
		outerVolume = found->second.coneOuterVolume;
		outerHighGain = found->second.coneOuterHighGain;
	}
	else
	{
		innerAngle = outerAngle = 6.28318530717958647692f;
		outerVolume = 0.0f;
		outerHighGain = 1.0f;
	}
}

void LoveNode::setSourceAirAbsorption(Love::AudioBackend::SourceHandle source, float factor)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.airAbsorptionFactor = factor;
		if (found->second.node) found->second.node->setAirAbsorptionFactor(factor);
	}
}

float LoveNode::getSourceAirAbsorption(Love::AudioBackend::SourceHandle source) const
{
	if (const auto found = _audioSources.find(source); found != _audioSources.end())
		return found->second.airAbsorptionFactor;
	return 0.0f;
}

void LoveNode::setSourceVolumeLimits(Love::AudioBackend::SourceHandle source,
	float minVolume, float maxVolume)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.minVolume = minVolume;
		found->second.maxVolume = maxVolume;
		if (found->second.node) found->second.node->setVolumeLimits(minVolume, maxVolume);
	}
}

void LoveNode::getSourceVolumeLimits(Love::AudioBackend::SourceHandle source,
	float &minVolume, float &maxVolume) const
{
	if (const auto found = _audioSources.find(source); found != _audioSources.end())
	{
		minVolume = found->second.minVolume;
		maxVolume = found->second.maxVolume;
	}
	else
	{
		minVolume = 0.0f;
		maxVolume = 1.0f;
	}
}

void LoveNode::setSourceRelative(Love::AudioBackend::SourceHandle source, bool relative)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.relative = relative;
		if (found->second.node) found->second.node->setListenerRelative(relative);
	}
}

bool LoveNode::isSourceRelative(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() && found->second.relative;
}

void LoveNode::setSourceAttenuationDistances(Love::AudioBackend::SourceHandle source,
	float referenceDistance, float maxDistance)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.referenceDistance = referenceDistance;
		found->second.maxDistance = std::min(maxDistance, 1000000.0f);
		if (found->second.node)
			found->second.node->setMinMaxDistance(found->second.referenceDistance,
				found->second.maxDistance);
	}
}

void LoveNode::getSourceAttenuationDistances(Love::AudioBackend::SourceHandle source,
	float &referenceDistance, float &maxDistance) const
{
	if (const auto found = _audioSources.find(source); found != _audioSources.end())
	{
		referenceDistance = found->second.referenceDistance;
		maxDistance = found->second.maxDistance;
	}
	else
	{
		referenceDistance = 1.0f;
		maxDistance = 1000000.0f;
	}
}

void LoveNode::setSourceRolloff(Love::AudioBackend::SourceHandle source, float rolloff)
{
	if (auto found = _audioSources.find(source); found != _audioSources.end())
	{
		found->second.rolloff = rolloff;
		if (found->second.node)
			found->second.node->setAttenuation(AudioSource::AttenuationModel::ApplicationDistance,
				rolloff);
	}
}

float LoveNode::getSourceRolloff(Love::AudioBackend::SourceHandle source) const
{
	const auto found = _audioSources.find(source);
	return found != _audioSources.end() ? found->second.rolloff : 1.0f;
}

void LoveNode::setInstanceVolume(float volume)
{
	if (_audioBus)
		_audioBus->setVolume(volume);
}

bool LoveNode::setMixWithSystem(bool mix)
{
	return SharedApplication.setAudioMixWithSystem(mix);
}

void LoveNode::setListenerPosition(float x, float y, float z)
{
	SharedAudio.setListener(nullptr);
	SharedAudio.setListenerPosition(x, y, z);
}

void LoveNode::getListenerPosition(float &x, float &y, float &z) const
{
	SharedAudio.getListenerPosition(x, y, z);
}

void LoveNode::setListenerOrientation(float forwardX, float forwardY, float forwardZ,
	float upX, float upY, float upZ)
{
	SharedAudio.setListener(nullptr);
	SharedAudio.setListenerAt(forwardX, forwardY, forwardZ);
	SharedAudio.setListenerUp(upX, upY, upZ);
}

void LoveNode::getListenerOrientation(float &forwardX, float &forwardY, float &forwardZ,
	float &upX, float &upY, float &upZ) const
{
	SharedAudio.getListenerAt(forwardX, forwardY, forwardZ);
	SharedAudio.getListenerUp(upX, upY, upZ);
}

void LoveNode::setListenerVelocity(float x, float y, float z)
{
	SharedAudio.setListener(nullptr);
	SharedAudio.setListenerVelocity(x, y, z);
}

void LoveNode::getListenerVelocity(float &x, float &y, float &z) const
{
	SharedAudio.getListenerVelocity(x, y, z);
}

void LoveNode::setDopplerScale(float scale)
{
	SharedAudio.setDopplerScale(scale);
}

float LoveNode::getDopplerScale() const
{
	return SharedAudio.getDopplerScale();
}

void LoveNode::setDistanceModel(std::string_view model)
{
	Audio::DistanceModel value = Audio::DistanceModel::InverseClamped;
	if (model == "none") value = Audio::DistanceModel::None;
	else if (model == "inverse") value = Audio::DistanceModel::Inverse;
	else if (model == "inverseclamped") value = Audio::DistanceModel::InverseClamped;
	else if (model == "linear") value = Audio::DistanceModel::Linear;
	else if (model == "linearclamped") value = Audio::DistanceModel::LinearClamped;
	else if (model == "exponent") value = Audio::DistanceModel::Exponent;
	else if (model == "exponentclamped") value = Audio::DistanceModel::ExponentClamped;
	SharedAudio.setDistanceModel(value);
}

std::string LoveNode::getDistanceModel() const
{
	switch (SharedAudio.getDistanceModel())
	{
		case Audio::DistanceModel::None: return "none";
		case Audio::DistanceModel::Inverse: return "inverse";
		case Audio::DistanceModel::Linear: return "linear";
		case Audio::DistanceModel::LinearClamped: return "linearclamped";
		case Audio::DistanceModel::Exponent: return "exponent";
		case Audio::DistanceModel::ExponentClamped: return "exponentclamped";
		case Audio::DistanceModel::InverseClamped:
		default: return "inverseclamped";
	}
}

bool LoveNode::isEffectsSupported() const
{
	return _audioBus != nullptr;
}

int LoveNode::getMaxSceneEffects() const
{
	return isEffectsSupported() ? 64 : 0;
}

int LoveNode::getMaxSourceEffects() const
{
	// SoLoud exposes four serial filter slots per stream. Slot zero is reserved
	// for Source:setFilter, leaving three slots for named Love effects.
	return isEffectsSupported() ? 3 : 0;
}

bool LoveNode::refreshAudioFilters(AudioResource &resource, std::string &error)
{
	if (!resource.effectsBus)
	{
		error = "Dora SoLoud effects are unavailable for this Love Source";
		return false;
	}
	auto parameter = [](const auto &settings, std::string_view name, float fallback) {
		const auto found = settings.parameters.find(std::string(name));
		return found == settings.parameters.end() ? fallback : found->second;
	};
	auto unit = [](float value) { return std::clamp(value, 0.0f, 1.0f); };
	for (uint32_t slot = 0; slot < 4; ++slot) resource.effectsBus->setFilter(slot, ""_slice);
	resource.effectsBus->setVolume(1.0f);
	if (resource.filter)
	{
		const auto &filter = *resource.filter;
		resource.effectsBus->setVolume(unit(parameter(filter, "volume", 1.0f)));
		resource.effectsBus->setFilter(0, "BiquadResonant"_slice);
		int type = SoLoud::BiquadResonantFilter::LOWPASS;
		float frequency = 8000.0f;
		if (filter.type == "highpass")
		{
			type = SoLoud::BiquadResonantFilter::HIGHPASS;
			frequency = 10.0f + 7990.0f * (1.0f - unit(parameter(filter, "lowgain", 1.0f)));
		}
		else if (filter.type == "bandpass")
		{
			type = SoLoud::BiquadResonantFilter::BANDPASS;
			const float low = unit(parameter(filter, "lowgain", 1.0f));
			const float high = unit(parameter(filter, "highgain", 1.0f));
			frequency = 10.0f + 7990.0f * unit((1.0f - low + high) * 0.5f);
		}
		else
		{
			frequency = 10.0f + 7990.0f * unit(parameter(filter, "highgain", 1.0f));
		}
		resource.effectsBus->setFilterParameter(0, SoLoud::BiquadResonantFilter::WET, 1.0f);
		resource.effectsBus->setFilterParameter(0, SoLoud::BiquadResonantFilter::TYPE,
			static_cast<float>(type));
		resource.effectsBus->setFilterParameter(0, SoLoud::BiquadResonantFilter::FREQUENCY, frequency);
		resource.effectsBus->setFilterParameter(0, SoLoud::BiquadResonantFilter::RESONANCE, 1.0f);
	}

	uint32_t slot = 1;
	for (const auto &[name, sendFilter] : resource.effects)
	{
		const auto definition = _audioEffects.find(name);
		if (definition == _audioEffects.end()) continue;
		if (slot >= 4)
		{
			error = "a Love Source can use at most three effects in Dora's SoLoud adapter";
			return false;
		}
		const auto &effect = definition->second;
		float wet = unit(parameter(effect, "volume", 1.0f));
		if (sendFilter) wet *= unit(parameter(*sendFilter, "volume", 1.0f));
		if (effect.type == "reverb")
		{
			resource.effectsBus->setFilter(slot, "FreeVerb"_slice);
			resource.effectsBus->setFilterParameter(slot, SoLoud::FreeverbFilter::WET, wet);
			resource.effectsBus->setFilterParameter(slot, SoLoud::FreeverbFilter::FREEZE, 0.0f);
			resource.effectsBus->setFilterParameter(slot, SoLoud::FreeverbFilter::ROOMSIZE,
				unit(parameter(effect, "decaytime", 1.0f) / 20.0f));
			resource.effectsBus->setFilterParameter(slot, SoLoud::FreeverbFilter::DAMP,
				1.0f - unit(parameter(effect, "highgain", 1.0f)));
			resource.effectsBus->setFilterParameter(slot, SoLoud::FreeverbFilter::WIDTH,
				unit(parameter(effect, "diffusion", 1.0f)));
		}
		else if (effect.type == "chorus" || effect.type == "flanger")
		{
			resource.effectsBus->setFilter(slot, "Flanger"_slice);
			resource.effectsBus->setFilterParameter(slot, SoLoud::FlangerFilter::WET, wet);
			resource.effectsBus->setFilterParameter(slot, SoLoud::FlangerFilter::DELAY,
				std::clamp(parameter(effect, "delay", effect.type == "chorus" ? 0.04f : 0.004f), 0.001f, 0.1f));
			resource.effectsBus->setFilterParameter(slot, SoLoud::FlangerFilter::FREQ,
				std::clamp(parameter(effect, "rate", 1.0f), 0.001f, 100.0f));
		}
		else if (effect.type == "echo")
		{
			resource.effectsBus->setFilter(slot, "Echo"_slice);
			resource.effectsBus->setFilterParameter(slot, SoLoud::EchoFilter::WET, wet);
			resource.effectsBus->setFilterParameter(slot, SoLoud::EchoFilter::DELAY,
				std::max(parameter(effect, "delay", 0.1f), 0.001f));
			resource.effectsBus->setFilterParameter(slot, SoLoud::EchoFilter::DECAY,
				unit(parameter(effect, "feedback", 0.5f)));
			resource.effectsBus->setFilterParameter(slot, SoLoud::EchoFilter::FILTER,
				unit(parameter(effect, "damping", 0.5f)));
		}
		else if (effect.type == "ringmodulator")
		{
			resource.effectsBus->setFilter(slot, "Robotize"_slice);
			resource.effectsBus->setFilterParameter(slot, SoLoud::RobotizeFilter::WET, wet);
			resource.effectsBus->setFilterParameter(slot, SoLoud::RobotizeFilter::FREQ,
				std::clamp(parameter(effect, "frequency", 440.0f), 0.1f, 100.0f));
			resource.effectsBus->setFilterParameter(slot, SoLoud::RobotizeFilter::WAVE,
				std::clamp(parameter(effect, "waveform", 0.0f), 0.0f, 6.0f));
		}
		else if (effect.type == "equalizer")
		{
			resource.effectsBus->setFilter(slot, "Eq"_slice);
			resource.effectsBus->setFilterParameter(slot, SoLoud::EqFilter::WET, wet);
			const std::array<std::string_view, 8> gains = {"lowgain", "lowgain", "lowmidgain",
				"lowmidgain", "highmidgain", "highmidgain", "highgain", "highgain"};
			for (uint32_t band = 0; band < gains.size(); ++band)
				resource.effectsBus->setFilterParameter(slot, SoLoud::EqFilter::BAND1 + band,
					std::clamp(parameter(effect, gains[band], 1.0f), 0.0f, 4.0f));
		}
		else
		{
			// Distortion and compressor are represented with SoLoud's waveshaper.
			resource.effectsBus->setFilter(slot, "WaveShaper"_slice);
			resource.effectsBus->setFilterParameter(slot, SoLoud::WaveShaperFilter::WET, wet);
			const float amount = effect.type == "compressor" ? 0.25f
				: unit(parameter(effect, "edge", parameter(effect, "gain", 0.5f)));
			resource.effectsBus->setFilterParameter(slot, SoLoud::WaveShaperFilter::AMOUNT, amount);
		}
		++slot;
	}
	error.clear();
	return true;
}

bool LoveNode::setEffect(std::string_view name,
	const Love::AudioBackend::EffectSettings *effect, std::string &error)
{
	if (!isEffectsSupported()) { error.clear(); return false; }
	const std::string key(name);
	if (!effect)
	{
		_audioEffects.erase(key);
		for (auto &[_, source] : _audioSources)
		{
			source.effects.erase(key);
			if (source.effectsBus && !refreshAudioFilters(source, error)) return false;
		}
		error.clear();
		return true;
	}
	if (!_audioEffects.contains(key) && _audioEffects.size() >= 64)
	{
		error = "LoveNode reached Dora's limit of 64 named audio effects";
		return false;
	}
	_audioEffects[key] = *effect;
	for (auto &[_, source] : _audioSources)
		if (source.effects.contains(key) && !refreshAudioFilters(source, error)) return false;
	error.clear();
	return true;
}

bool LoveNode::setSourceFilter(Love::AudioBackend::SourceHandle source,
	const Love::AudioBackend::FilterSettings *filter, std::string &error)
{
	auto found = _audioSources.find(source);
	if (found == _audioSources.end()) { error = "Love audio Source is closed"; return false; }
	if (!found->second.effectsBus) { error.clear(); return false; }
	found->second.filter = filter ? std::optional<Love::AudioBackend::FilterSettings>(*filter) : std::nullopt;
	return refreshAudioFilters(found->second, error);
}

bool LoveNode::setSourceEffect(Love::AudioBackend::SourceHandle source, std::string_view name,
	const Love::AudioBackend::FilterSettings *filter, bool enabled, std::string &error)
{
	auto found = _audioSources.find(source);
	if (found == _audioSources.end()) { error = "Love audio Source is closed"; return false; }
	if (!found->second.effectsBus) { error.clear(); return false; }
	const std::string key(name);
	if (!enabled)
	{
		found->second.effects.erase(key);
		return refreshAudioFilters(found->second, error);
	}
	if (!_audioEffects.contains(key)) { error = "Love audio effect '" + key + "' does not exist"; return false; }
	if (!found->second.effects.contains(key) && found->second.effects.size() >= 3)
	{
		error = "a Love Source can use at most three effects in Dora's SoLoud adapter";
		return false;
	}
	found->second.effects[key] = filter
		? std::optional<Love::AudioBackend::FilterSettings>(*filter) : std::nullopt;
	return refreshAudioFilters(found->second, error);
}

std::vector<std::string> LoveNode::getRecordingDeviceNames() const
{
	std::vector<std::string> names;
	const int count = SDL_GetNumAudioDevices(1);
	if (count <= 0) return names;
	names.reserve(static_cast<std::size_t>(count));
	for (int index = 0; index < count; ++index)
	{
		if (const char *name = SDL_GetAudioDeviceName(index, 1); name && *name)
			names.emplace_back(name);
	}
	return names;
}

Love::AudioBackend::RecordingHandle LoveNode::startRecording(std::string_view deviceName,
	int maxSamples, int sampleRate, int bitDepth, int channels, std::string &error)
{
	if (maxSamples <= 0 || sampleRate <= 0 || (bitDepth != 8 && bitDepth != 16)
		|| (channels != 1 && channels != 2))
	{
		error = "invalid Love audio recording format";
		return 0;
	}
	const int bytesPerFrame = bitDepth / 8 * channels;
	if (static_cast<std::size_t>(maxSamples)
		> std::numeric_limits<std::size_t>::max() / static_cast<std::size_t>(bytesPerFrame))
	{
		error = "Love audio recording buffer size overflows this platform";
		return 0;
	}

	auto recording = std::make_unique<LoveRecordingResource>();
	recording->maxBytes = static_cast<std::size_t>(maxSamples)
		* static_cast<std::size_t>(bytesPerFrame);
	recording->bytesPerFrame = bytesPerFrame;
	recording->pcm.reserve(recording->maxBytes);

	SDL_AudioSpec desired{};
	desired.freq = sampleRate;
	desired.format = bitDepth == 8 ? AUDIO_U8 : AUDIO_S16SYS;
	desired.channels = static_cast<Uint8>(channels);
	desired.samples = static_cast<Uint16>(std::clamp(maxSamples, 256, 4096));
	desired.callback = loveRecordingCallback;
	desired.userdata = recording.get();
	SDL_AudioSpec obtained{};
	const std::string name(deviceName);
	const SDL_AudioDeviceID device = SDL_OpenAudioDevice(name.empty() ? nullptr : name.c_str(),
		1, &desired, &obtained, 0);
	if (device == 0)
	{
		// Love reports device-open failure as start() == false. Permission denial,
		// an unplugged device, and exclusive ownership all use this path.
		error.clear();
		return 0;
	}
	recording->device = device;
	const auto handle = _nextAudioRecordingHandle++;
	_audioRecordings.emplace(handle, std::move(recording));
	SDL_PauseAudioDevice(device, 0);
	error.clear();
	return handle;
}

void LoveNode::stopRecording(Love::AudioBackend::RecordingHandle recording)
{
	const auto found = _audioRecordings.find(recording);
	if (found == _audioRecordings.end()) return;
	const SDL_AudioDeviceID device = found->second->device;
	if (device != 0)
	{
		SDL_PauseAudioDevice(device, 1);
		SDL_CloseAudioDevice(device);
	}
	_audioRecordings.erase(found);
}

int LoveNode::getRecordingSampleCount(
	Love::AudioBackend::RecordingHandle recording) const
{
	const auto found = _audioRecordings.find(recording);
	if (found == _audioRecordings.end()) return 0;
	const auto &resource = *found->second;
	std::lock_guard<std::mutex> lock(resource.mutex);
	return resource.bytesPerFrame > 0
		? static_cast<int>(resource.pcm.size() / static_cast<std::size_t>(resource.bytesPerFrame)) : 0;
}

bool LoveNode::getRecordingData(Love::AudioBackend::RecordingHandle recording,
	std::vector<std::uint8_t> &pcm, std::string &error)
{
	const auto found = _audioRecordings.find(recording);
	if (found == _audioRecordings.end())
	{
		error = "Love RecordingDevice is not recording";
		return false;
	}
	auto &resource = *found->second;
	{
		std::lock_guard<std::mutex> lock(resource.mutex);
		pcm.swap(resource.pcm);
		resource.pcm.clear();
		resource.pcm.reserve(resource.maxBytes);
	}
	error.clear();
	return true;
}

void LoveNode::setMeter(float meter)
{
	_physicsMeter = meter;
}

Love::PhysicsBackend::WorldHandle LoveNode::newWorld(float gravityX, float gravityY,
	bool sleep, std::string &error)
{
	PhysicsWorld *world = PhysicsWorld::create();
	if (!world)
	{
		error = "failed to create an isolated Dora PhysicsWorld for LoveNode '" + _bootFile + "'";
		return 0;
	}
	const auto handle = _nextPhysicsWorldHandle++;
	_physicsWorlds.emplace(handle, PhysicsWorldResource{Ref<PhysicsWorld>(world), gravityX, gravityY, sleep});
	if (!setWorldContactCallback(handle, {}, error))
	{
		_physicsWorlds.erase(handle);
		return 0;
	}
	error.clear();
	return handle;
}

void LoveNode::releaseWorld(Love::PhysicsBackend::WorldHandle world)
{
	const auto worldFound = _physicsWorlds.find(world);
	if (worldFound != _physicsWorlds.end() && worldFound->second.world
		&& worldFound->second.world->getPrWorld()
		&& pd::IsLocked(*worldFound->second.world->getPrWorld()))
	{
		_pendingPhysicsWorldDestroy.insert(world);
		return;
	}
	_pendingPhysicsWorldDestroy.erase(world);
	std::vector<Love::PhysicsBackend::JointHandle> joints;
	std::vector<Love::PhysicsBackend::FixtureHandle> fixtures;
	std::vector<Love::PhysicsBackend::BodyHandle> bodies;
	for (const auto &[handle, resource] : _physicsJoints)
		if (resource.world == world) joints.push_back(handle);
	for (const auto &[handle, resource] : _physicsFixtures)
		if (resource.world == world) fixtures.push_back(handle);
	for (const auto &[handle, resource] : _physicsBodies)
		if (resource.world == world) bodies.push_back(handle);
	for (const auto handle : joints) releaseJoint(handle);
	for (const auto handle : fixtures) releaseFixture(handle);
	for (const auto handle : bodies) releaseBody(handle);
	for (auto contact = _physicsContacts.begin(); contact != _physicsContacts.end();)
	{
		if (contact->second.world == world) contact = _physicsContacts.erase(contact);
		else ++contact;
	}
	_physicsWorlds.erase(world);
}

bool LoveNode::isWorldValid(Love::PhysicsBackend::WorldHandle world) const
{
	return _physicsWorlds.find(world) != _physicsWorlds.end();
}

bool LoveNode::updateWorld(Love::PhysicsBackend::WorldHandle world, float deltaTime,
	int velocityIterations, int positionIterations, std::string &error)
{
	const auto found = _physicsWorlds.find(world);
	if (found == _physicsWorlds.end() || !found->second.world)
	{
		error = "cannot update a closed Love physics World";
		return false;
	}
	found->second.world->setIterations(velocityIterations, positionIterations);
	found->second.contactError.clear();
	found->second.world->doUpdate(deltaTime);
	if (auto *prWorld = found->second.world->getPrWorld())
	{
		for (const auto &[_, resource] : _physicsBodies)
		{
			if (resource.world == world && resource.body && pr::IsValid(resource.body->getPrBody()))
				pd::SetAcceleration(*prWorld, resource.body->getPrBody(),
					pr::LinearAcceleration2{found->second.gravityX * resource.gravityScale / _physicsMeter,
						found->second.gravityY * resource.gravityScale / _physicsMeter}, pr::AngularAcceleration{});
		}
	}
	std::string contactError = found->second.contactError;
	found->second.contactError.clear();
	if (_pendingPhysicsWorldDestroy.erase(world) != 0)
	{
		releaseWorld(world);
	}
	else
	{
		std::vector<Love::PhysicsBackend::JointHandle> joints;
		std::vector<Love::PhysicsBackend::FixtureHandle> fixtures;
		std::vector<Love::PhysicsBackend::BodyHandle> bodies;
		for (const auto handle : _pendingPhysicsJointDestroy)
		{
			const auto resource = _physicsJoints.find(handle);
			if (resource == _physicsJoints.end() || resource->second.world == world)
				joints.push_back(handle);
		}
		for (const auto handle : _pendingPhysicsFixtureDestroy)
		{
			const auto resource = _physicsFixtures.find(handle);
			if (resource == _physicsFixtures.end() || resource->second.world == world)
				fixtures.push_back(handle);
		}
		for (const auto handle : _pendingPhysicsBodyDestroy)
		{
			const auto resource = _physicsBodies.find(handle);
			if (resource == _physicsBodies.end() || resource->second.world == world)
				bodies.push_back(handle);
		}
		for (const auto handle : joints) { _pendingPhysicsJointDestroy.erase(handle); releaseJoint(handle); }
		for (const auto handle : fixtures) { _pendingPhysicsFixtureDestroy.erase(handle); releaseFixture(handle); }
		for (const auto handle : bodies) { _pendingPhysicsBodyDestroy.erase(handle); releaseBody(handle); }
	}
	if (!contactError.empty())
	{
		error = std::move(contactError);
		return false;
	}
	error.clear();
	return true;
}

bool LoveNode::setWorldGravity(Love::PhysicsBackend::WorldHandle world,
	float x, float y, std::string &error)
{
	const auto found = _physicsWorlds.find(world);
	if (found == _physicsWorlds.end() || !found->second.world || !found->second.world->getPrWorld())
	{
		error = "cannot change gravity on a closed Love physics World";
		return false;
	}
	const float oldX = found->second.gravityX;
	const float oldY = found->second.gravityY;
	auto &prWorld = *found->second.world->getPrWorld();
	for (const auto &[_, resource] : _physicsBodies)
	{
		if (resource.world == world && resource.body && pr::IsValid(resource.body->getPrBody()))
		{
			const auto current = pd::GetAcceleration(prWorld, resource.body->getPrBody());
			const auto gravityDelta = pr::LinearAcceleration2{
				(x - oldX) * resource.gravityScale / _physicsMeter,
				(y - oldY) * resource.gravityScale / _physicsMeter};
			pd::SetAcceleration(prWorld, resource.body->getPrBody(),
				current.linear + gravityDelta, current.angular);
		}
	}
	found->second.gravityX = x;
	found->second.gravityY = y;
	error.clear();
	return true;
}

bool LoveNode::getWorldGravity(Love::PhysicsBackend::WorldHandle world,
	float &x, float &y, std::string &error) const
{
	const auto found = _physicsWorlds.find(world);
	if (found == _physicsWorlds.end())
	{
		error = "cannot query a closed Love physics World";
		return false;
	}
	x = found->second.gravityX;
	y = found->second.gravityY;
	error.clear();
	return true;
}

bool LoveNode::setWorldSleepingAllowed(Love::PhysicsBackend::WorldHandle world,
	bool value, std::string &error)
{
	const auto found = _physicsWorlds.find(world);
	if (found == _physicsWorlds.end() || !found->second.world || !found->second.world->getPrWorld())
	{ error = "cannot change a closed Love physics World"; return false; }
	found->second.sleep = value;
	auto &prWorld = *found->second.world->getPrWorld();
	for (const auto &[_, resource] : _physicsBodies)
		if (resource.world == world && resource.body && pr::IsValid(resource.body->getPrBody()))
			pd::SetSleepingAllowed(prWorld, resource.body->getPrBody(), value);
	error.clear(); return true;
}

bool LoveNode::isWorldSleepingAllowed(Love::PhysicsBackend::WorldHandle world,
	bool &value, std::string &error) const
{
	const auto found = _physicsWorlds.find(world);
	if (found == _physicsWorlds.end()) { error = "cannot query a closed Love physics World"; return false; }
	value = found->second.sleep; error.clear(); return true;
}

bool LoveNode::queryWorld(Love::PhysicsBackend::WorldHandle world,
	float x1, float y1, float x2, float y2,
	std::vector<Love::PhysicsBackend::FixtureHandle> &fixtures,
	std::string &error) const
{
	const auto found = _physicsWorlds.find(world);
	if (found == _physicsWorlds.end() || !found->second.world || !found->second.world->getPrWorld())
	{
		error = "cannot query a closed Love physics World";
		return false;
	}
	auto &prWorld = *found->second.world->getPrWorld();
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	const float left = std::min(x1, x2) * scale;
	const float right = std::max(x1, x2) * scale;
	const float bottom = std::min(y1, y2) * scale;
	const float top = std::max(y1, y2) * scale;
	pd::AABB aabb{
		pd::AABB::Location{PhysicsWorld::prVal(left), PhysicsWorld::prVal(bottom)},
		pd::AABB::Location{PhysicsWorld::prVal(right), PhysicsWorld::prVal(top)}};
	std::unordered_set<Love::PhysicsBackend::FixtureHandle> seen;
	pd::Query(pd::GetTree(prWorld), aabb,
		[&](pr::BodyID, pr::ShapeID shapeId, const pr::ChildCounter) {
			for (const auto &[handle, resource] : _physicsFixtures)
			{
				if (resource.world == world && resource.shape == shapeId.get() && seen.insert(handle).second)
					fixtures.push_back(handle);
			}
			return true;
		});
	error.clear();
	return true;
}

bool LoveNode::raycastWorld(Love::PhysicsBackend::WorldHandle world,
	float x1, float y1, float x2, float y2,
	std::vector<Love::PhysicsBackend::RayHit> &hits,
	std::string &error) const
{
	const auto found = _physicsWorlds.find(world);
	if (found == _physicsWorlds.end() || !found->second.world || !found->second.world->getPrWorld())
	{
		error = "cannot raycast a closed Love physics World";
		return false;
	}
	auto &prWorld = *found->second.world->getPrWorld();
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	const Vec2 start{x1 * scale, y1 * scale};
	const Vec2 end{x2 * scale, y2 * scale};
	const Vec2 delta = end - start;
	const float lengthSquared = delta.lengthSquared();
	pd::RayCastInput input{PhysicsWorld::prVal(start), PhysicsWorld::prVal(end), pr::Real{1}};
	pd::RayCast(prWorld, input,
		[&](pr::BodyID, pr::ShapeID shapeId, pr::ChildCounter, pr::Length2 point, pd::UnitVec normal) {
			const Vec2 hitPoint = PhysicsWorld::Val(pr::Vec2{point[0], point[1]});
			const float fraction = lengthSquared > 0.0f
				? std::clamp((hitPoint - start).dot(delta) / lengthSquared, 0.0f, 1.0f) : 0.0f;
			for (const auto &[handle, resource] : _physicsFixtures)
			{
				if (resource.world == world && resource.shape == shapeId.get())
				{
					hits.push_back({handle, hitPoint.x / scale, hitPoint.y / scale,
						normal[0], normal[1], fraction});
					break;
				}
			}
			return pr::RayCastOpcode::ResetRay;
		});
	std::sort(hits.begin(), hits.end(), [](const auto &a, const auto &b) { return a.fraction < b.fraction; });
	error.clear();
	return true;
}

bool LoveNode::setWorldContactCallback(Love::PhysicsBackend::WorldHandle world,
	Love::PhysicsBackend::ContactCallback callback, std::string &error)
{
	const auto found = _physicsWorlds.find(world);
	if (found == _physicsWorlds.end() || !found->second.world || !found->second.world->getPrWorld())
	{
		error = "cannot set callbacks on a closed Love physics World";
		return false;
	}
	found->second.contactCallback = std::move(callback);
	found->second.contactError.clear();
	auto &prWorld = *found->second.world->getPrWorld();
	auto shouldCollide = [this, world](pr::ContactID contactId) {
		const auto worldFound = _physicsWorlds.find(world);
		if (worldFound == _physicsWorlds.end() || !worldFound->second.world
			|| !worldFound->second.world->getPrWorld()) return false;
		const auto &nativeWorld = *worldFound->second.world->getPrWorld();
		const auto shapeA = pd::GetShapeA(nativeWorld, contactId).get();
		const auto shapeB = pd::GetShapeB(nativeWorld, contactId).get();
		const PhysicsFixtureResource *fixtureA = nullptr;
		const PhysicsFixtureResource *fixtureB = nullptr;
		for (const auto &[_, fixture] : _physicsFixtures)
		{
			if (fixture.world != world) continue;
			if (fixture.shape == shapeA) fixtureA = &fixture;
			if (fixture.shape == shapeB) fixtureB = &fixture;
		}
		return fixtureA && fixtureB
			&& Love::shouldPhysicsFiltersCollide(fixtureA->filter, fixtureB->filter);
	};
	auto dispatch = [this, world](Love::PhysicsBackend::ContactPhase phase,
		pr::ContactID contactId, std::vector<float> impulses = {}) {
		auto worldFound = _physicsWorlds.find(world);
		if (worldFound == _physicsWorlds.end() || !worldFound->second.world
			|| !worldFound->second.world->getPrWorld()) return;
		auto &resource = worldFound->second;
		auto &nativeWorld = *resource.world->getPrWorld();
		const auto nativeId = static_cast<std::uint16_t>(contactId.get());
		auto contactFound = resource.contacts.find(nativeId);
		if (phase == Love::PhysicsBackend::ContactPhase::End
			&& contactFound == resource.contacts.end()) return;
		Love::PhysicsBackend::ContactHandle contactHandle = 0;
		if (contactFound == resource.contacts.end())
		{
			contactHandle = _nextPhysicsContactHandle++;
			resource.contacts.emplace(nativeId, contactHandle);
			_physicsContacts.emplace(contactHandle, PhysicsContactResource{world, nativeId});
		}
		else contactHandle = contactFound->second;

		Love::PhysicsBackend::FixtureHandle fixtureA = 0;
		Love::PhysicsBackend::FixtureHandle fixtureB = 0;
		const auto shapeA = pd::GetShapeA(nativeWorld, contactId).get();
		const auto shapeB = pd::GetShapeB(nativeWorld, contactId).get();
		for (const auto &[handle, fixture] : _physicsFixtures)
		{
			if (fixture.world != world) continue;
			if (fixture.shape == shapeA) fixtureA = handle;
			if (fixture.shape == shapeB) fixtureB = handle;
		}
		if (fixtureA && fixtureB && resource.contactCallback && resource.contactError.empty())
		{
			Love::PhysicsBackend::ContactEvent event{
				phase, contactHandle, fixtureA, fixtureB, std::move(impulses)};
			const auto nativeContact = pd::GetContact(nativeWorld, contactId);
			event.childA = static_cast<int>(pr::GetChildIndexA(nativeContact));
			event.childB = static_cast<int>(pr::GetChildIndexB(nativeContact));
			std::string callbackError;
			if (!resource.contactCallback(event, callbackError))
				resource.contactError = callbackError.empty()
					? "Love physics contact callback failed" : std::move(callbackError);
		}
		if (phase == Love::PhysicsBackend::ContactPhase::End)
		{
			_physicsContacts.erase(contactHandle);
			resource.contacts.erase(nativeId);
		}
	};
	pd::SetBeginContactListener(prWorld, [dispatch, shouldCollide, nativeWorld = &prWorld](pr::ContactID contact) {
		if (!shouldCollide(contact))
		{
			pd::UnsetEnabled(*nativeWorld, contact);
			return;
		}
		pd::SetEnabled(*nativeWorld, contact);
		dispatch(Love::PhysicsBackend::ContactPhase::Begin, contact);
	});
	pd::SetEndContactListener(prWorld, [dispatch](pr::ContactID contact) {
		dispatch(Love::PhysicsBackend::ContactPhase::End, contact);
	});
	pd::SetPreSolveContactListener(prWorld,
		[dispatch, shouldCollide, nativeWorld = &prWorld](pr::ContactID contact, const pd::Manifold &) {
			if (!shouldCollide(contact))
			{
				pd::UnsetEnabled(*nativeWorld, contact);
				return;
			}
			pd::SetEnabled(*nativeWorld, contact);
			dispatch(Love::PhysicsBackend::ContactPhase::PreSolve, contact);
		});
	pd::SetPostSolveContactListener(prWorld,
		[dispatch, this](pr::ContactID contact, const pd::ContactImpulsesList &values, unsigned) {
			std::vector<float> impulses;
			impulses.reserve(static_cast<std::size_t>(values.GetCount()) * 2);
			for (auto index = decltype(values.GetCount()){0}; index < values.GetCount(); ++index)
			{
				impulses.push_back(static_cast<float>(pr::StripUnit(values.GetEntryNormal(index))) * _physicsMeter);
				impulses.push_back(static_cast<float>(pr::StripUnit(values.GetEntryTanget(index))) * _physicsMeter);
			}
			dispatch(Love::PhysicsBackend::ContactPhase::PostSolve, contact, std::move(impulses));
		});
	error.clear();
	return true;
}

bool LoveNode::isContactValid(Love::PhysicsBackend::ContactHandle contact) const
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) return false;
	const auto world = _physicsWorlds.find(found->second.world);
	return world != _physicsWorlds.end() && world->second.world
		&& world->second.world->getPrWorld();
}

bool LoveNode::getContactPositions(Love::PhysicsBackend::ContactHandle contact,
	std::vector<float> &positions, std::string &error) const
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	const auto manifold = pd::GetWorldManifold(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact});
	const float scale = _physicsMeter / PhysicsWorld::scaleFactor;
	for (auto index = decltype(manifold.GetPointCount()){0}; index < manifold.GetPointCount(); ++index)
	{
		const auto point = PhysicsWorld::Val(pr::Vec2{manifold.GetPoint(index)[0], manifold.GetPoint(index)[1]});
		positions.push_back(point.x * scale);
		positions.push_back(point.y * scale);
	}
	error.clear(); return true;
}

bool LoveNode::getContactNormal(Love::PhysicsBackend::ContactHandle contact,
	float &x, float &y, std::string &error) const
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	const auto normal = pd::GetWorldManifold(*world->second.world->getPrWorld(),
		pr::ContactID{found->second.contact}).GetNormal();
	x = normal[0]; y = normal[1]; error.clear(); return true;
}

bool LoveNode::getContactFriction(Love::PhysicsBackend::ContactHandle contact,
	float &friction, std::string &error) const
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	friction = pd::GetFriction(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact});
	error.clear(); return true;
}

bool LoveNode::setContactFriction(Love::PhysicsBackend::ContactHandle contact,
	float friction, std::string &error)
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	pd::SetFriction(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact}, friction);
	error.clear(); return true;
}

bool LoveNode::resetContactFriction(Love::PhysicsBackend::ContactHandle contact, std::string &error)
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	pd::ResetFriction(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact});
	error.clear(); return true;
}

bool LoveNode::getContactRestitution(Love::PhysicsBackend::ContactHandle contact,
	float &restitution, std::string &error) const
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	restitution = pd::GetRestitution(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact});
	error.clear(); return true;
}

bool LoveNode::setContactRestitution(Love::PhysicsBackend::ContactHandle contact,
	float restitution, std::string &error)
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	pd::SetRestitution(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact}, restitution);
	error.clear(); return true;
}

bool LoveNode::resetContactRestitution(Love::PhysicsBackend::ContactHandle contact, std::string &error)
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	pd::ResetRestitution(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact});
	error.clear(); return true;
}

bool LoveNode::isContactEnabled(Love::PhysicsBackend::ContactHandle contact,
	bool &enabled, std::string &error) const
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	enabled = pd::IsEnabled(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact});
	error.clear(); return true;
}

bool LoveNode::setContactEnabled(Love::PhysicsBackend::ContactHandle contact,
	bool enabled, std::string &error)
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	pd::SetEnabled(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact}, enabled);
	error.clear(); return true;
}

bool LoveNode::isContactTouching(Love::PhysicsBackend::ContactHandle contact,
	bool &touching, std::string &error) const
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	touching = pd::IsTouching(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact});
	error.clear(); return true;
}

bool LoveNode::getContactTangentSpeed(Love::PhysicsBackend::ContactHandle contact,
	float &speed, std::string &error) const
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	speed = static_cast<float>(pr::StripUnit(pd::GetTangentSpeed(
		*world->second.world->getPrWorld(), pr::ContactID{found->second.contact}))) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setContactTangentSpeed(Love::PhysicsBackend::ContactHandle contact,
	float speed, std::string &error)
{
	const auto found = _physicsContacts.find(contact);
	if (found == _physicsContacts.end()) { error = "Contact is invalid"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Contact World is closed"; return false; }
	pd::SetTangentSpeed(*world->second.world->getPrWorld(), pr::ContactID{found->second.contact},
		(speed / _physicsMeter) * pr::MeterPerSecond);
	error.clear(); return true;
}

Love::PhysicsBackend::ShapeHandle LoveNode::newCircleShape(float x, float y,
	float radius, std::string &error)
{
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	FixtureDef *fixture = BodyDef::disk(Vec2{x * scale, y * scale}, radius * scale, 1.0f);
	if (!fixture)
	{
		error = "failed to create a Dora disk fixture for Love CircleShape";
		return 0;
	}
	const auto handle = _nextPhysicsShapeHandle++;
	_physicsShapes.emplace(handle, PhysicsShapeResource{Ref<FixtureDef>(fixture), "circle"});
	error.clear();
	return handle;
}

Love::PhysicsBackend::ShapeHandle LoveNode::newRectangleShape(float x, float y,
	float width, float height, float angle, std::string &error)
{
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	FixtureDef *fixture = BodyDef::polygon(Vec2{x * scale, y * scale},
		width * scale, height * scale, -angle * 180.0f / std::numbers::pi_v<float>, 1.0f);
	if (!fixture)
	{
		error = "failed to create a Dora polygon fixture for Love PolygonShape";
		return 0;
	}
	const auto handle = _nextPhysicsShapeHandle++;
	_physicsShapes.emplace(handle, PhysicsShapeResource{Ref<FixtureDef>(fixture), "polygon"});
	error.clear();
	return handle;
}

Love::PhysicsBackend::ShapeHandle LoveNode::newPolygonShape(
	std::vector<float> &points, std::string &error)
{
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	std::vector<Vec2> vertices;
	vertices.reserve(points.size() / 2);
	for (std::size_t index = 0; index < points.size(); index += 2)
		vertices.emplace_back(points[index] * scale, points[index + 1] * scale);
	FixtureDef *fixture = nullptr;
	try { fixture = BodyDef::polygon(vertices, 1.0f); }
	catch (const std::exception &exception)
	{
		error = std::string("failed to create Love PolygonShape: ") + exception.what();
		return 0;
	}
	if (!fixture) { error = "failed to create a Dora fixture for Love PolygonShape"; return 0; }
	const auto proxy = pd::GetChild(fixture->shape, 0);
	points.clear();
	points.reserve(static_cast<std::size_t>(proxy.GetVertexCount()) * 2);
	for (const auto &vertex : proxy.GetVertices())
	{
		points.push_back(static_cast<float>(pr::StripUnit(vertex[0])) * _physicsMeter);
		points.push_back(static_cast<float>(pr::StripUnit(vertex[1])) * _physicsMeter);
	}
	const auto handle = _nextPhysicsShapeHandle++;
	_physicsShapes.emplace(handle, PhysicsShapeResource{Ref<FixtureDef>(fixture), "polygon"});
	error.clear(); return handle;
}

Love::PhysicsBackend::ShapeHandle LoveNode::newEdgeShape(float x1, float y1,
	float x2, float y2, std::string &error)
{
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	auto conf = pd::EdgeShapeConf{
		PhysicsWorld::prVal(Vec2{x1 * scale, y1 * scale}),
		PhysicsWorld::prVal(Vec2{x2 * scale, y2 * scale})};
	FixtureDef *fixture = FixtureDef::create(pd::Shape{conf});
	if (!fixture) { error = "failed to create a Dora fixture for Love EdgeShape"; return 0; }
	const auto handle = _nextPhysicsShapeHandle++;
	_physicsShapes.emplace(handle, PhysicsShapeResource{Ref<FixtureDef>(fixture), "edge"});
	error.clear(); return handle;
}

Love::PhysicsBackend::ShapeHandle LoveNode::newChainShape(bool loop,
	const std::vector<float> &points, std::string &error)
{
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	std::vector<Vec2> vertices;
	vertices.reserve(points.size() / 2 + (loop ? 1 : 0));
	for (std::size_t index = 0; index < points.size(); index += 2)
		vertices.emplace_back(points[index] * scale, points[index + 1] * scale);
	if (loop) vertices.push_back(vertices.front());
	FixtureDef *fixture = nullptr;
	try { fixture = BodyDef::chain(vertices); }
	catch (const std::exception &exception)
	{
		error = std::string("failed to create Love ChainShape: ") + exception.what();
		return 0;
	}
	if (!fixture) { error = "failed to create a Dora fixture for Love ChainShape"; return 0; }
	const auto handle = _nextPhysicsShapeHandle++;
	_physicsShapes.emplace(handle, PhysicsShapeResource{Ref<FixtureDef>(fixture),
		points.size() == 4 ? "edge" : "chain"});
	error.clear(); return handle;
}

bool LoveNode::setShapePreviousVertex(Love::PhysicsBackend::ShapeHandle shape,
	bool hasVertex, float x, float y, std::string &error)
{
	const auto found = _physicsShapes.find(shape);
	if (found == _physicsShapes.end() || !found->second.fixture)
	{ error = "cannot modify a closed Love physics Shape"; return false; }
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	const auto value = PhysicsWorld::prVal(Vec2{x * scale, y * scale});
	auto &nativeShape = found->second.fixture->shape;
	if (const auto *edge = pd::TypeCast<pd::EdgeShapeConf>(&nativeShape))
	{
		auto conf = *edge;
		if (hasVertex) conf.UsePreviousVertex(value); else conf.ClearPreviousVertex();
		nativeShape = pd::Shape{std::move(conf)};
	}
	else if (const auto *chain = pd::TypeCast<pd::ChainShapeConf>(&nativeShape))
	{
		auto conf = *chain;
		if (hasVertex) conf.UsePreviousVertex(value); else conf.ClearPreviousVertex();
		nativeShape = pd::Shape{std::move(conf)};
	}
	else { error = "expected Love EdgeShape or ChainShape"; return false; }
	error.clear(); return true;
}

bool LoveNode::setShapeNextVertex(Love::PhysicsBackend::ShapeHandle shape,
	bool hasVertex, float x, float y, std::string &error)
{
	const auto found = _physicsShapes.find(shape);
	if (found == _physicsShapes.end() || !found->second.fixture)
	{ error = "cannot modify a closed Love physics Shape"; return false; }
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	const auto value = PhysicsWorld::prVal(Vec2{x * scale, y * scale});
	auto &nativeShape = found->second.fixture->shape;
	if (const auto *edge = pd::TypeCast<pd::EdgeShapeConf>(&nativeShape))
	{
		auto conf = *edge;
		if (hasVertex) conf.UseNextVertex(value); else conf.ClearNextVertex();
		nativeShape = pd::Shape{std::move(conf)};
	}
	else if (const auto *chain = pd::TypeCast<pd::ChainShapeConf>(&nativeShape))
	{
		auto conf = *chain;
		if (hasVertex) conf.UseNextVertex(value); else conf.ClearNextVertex();
		nativeShape = pd::Shape{std::move(conf)};
	}
	else { error = "expected Love EdgeShape or ChainShape"; return false; }
	error.clear(); return true;
}

void LoveNode::releaseShape(Love::PhysicsBackend::ShapeHandle shape)
{
	_physicsShapes.erase(shape);
}

Love::PhysicsBackend::BodyHandle LoveNode::newBody(Love::PhysicsBackend::WorldHandle world,
	float x, float y, std::string_view type, std::string &error)
{
	const auto worldFound = _physicsWorlds.find(world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world)
	{
		error = "cannot create a Love Body in a closed World";
		return 0;
	}
	BodyDef *definition = BodyDef::create();
	if (!definition)
	{
		error = "failed to create a Dora BodyDef for Love Body";
		return 0;
	}
	definition->setType(type == "dynamic" ? pr::BodyType::Dynamic
		: type == "kinematic" ? pr::BodyType::Kinematic : pr::BodyType::Static);
	definition->setLinearAcceleration(Vec2{worldFound->second.gravityX / _physicsMeter,
		worldFound->second.gravityY / _physicsMeter});
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	Body *body = Body::create(definition, worldFound->second.world.get(), Vec2{x * scale, y * scale}, 0.0f);
	if (!body)
	{
		error = "failed to create a Dora Body for Love physics";
		return 0;
	}
	if (worldFound->second.world->getPrWorld() && pr::IsValid(body->getPrBody()))
	{
		pd::SetEnabled(*worldFound->second.world->getPrWorld(), body->getPrBody(), true);
		pd::SetSleepingAllowed(*worldFound->second.world->getPrWorld(), body->getPrBody(),
			worldFound->second.sleep);
	}
	const auto handle = _nextPhysicsBodyHandle++;
	_physicsBodies.emplace(handle, PhysicsBodyResource{Ref<Body>(body), world, 1.0f});
	error.clear();
	return handle;
}

void LoveNode::releaseBody(Love::PhysicsBackend::BodyHandle body)
{
	const auto bodyFound = _physicsBodies.find(body);
	if (bodyFound != _physicsBodies.end() && bodyFound->second.body
		&& bodyFound->second.body->getPhysicsWorld()
		&& bodyFound->second.body->getPhysicsWorld()->getPrWorld()
		&& pd::IsLocked(*bodyFound->second.body->getPhysicsWorld()->getPrWorld()))
	{
		_pendingPhysicsBodyDestroy.insert(body);
		return;
	}
	_pendingPhysicsBodyDestroy.erase(body);
	std::vector<Love::PhysicsBackend::JointHandle> joints;
	std::vector<Love::PhysicsBackend::FixtureHandle> fixtures;
	for (const auto &[handle, resource] : _physicsJoints)
		if (resource.bodyA == body || resource.bodyB == body) joints.push_back(handle);
	for (const auto &[handle, resource] : _physicsFixtures)
		if (resource.body == body) fixtures.push_back(handle);
	for (const auto handle : joints) releaseJoint(handle);
	for (const auto handle : fixtures) releaseFixture(handle);
	const auto found = _physicsBodies.find(body);
	if (found != _physicsBodies.end() && found->second.body)
		found->second.body->cleanup();
	_physicsBodies.erase(body);
}

bool LoveNode::isBodyValid(Love::PhysicsBackend::BodyHandle body) const
{
	return _physicsBodies.find(body) != _physicsBodies.end();
}

bool LoveNode::getBodyPosition(Love::PhysicsBackend::BodyHandle body,
	float &x, float &y, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{
		error = "cannot query a closed Love physics Body";
		return false;
	}
	const auto value = pd::GetLocation(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody());
	x = static_cast<float>(pr::Real{value[0] / pr::Meter}) * _physicsMeter;
	y = static_cast<float>(pr::Real{value[1] / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setBodyPosition(Love::PhysicsBackend::BodyHandle body,
	float x, float y, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot move a closed Love physics Body"; return false; }
	auto &world = *found->second.body->getPhysicsWorld()->getPrWorld();
	pd::SetTransform(world, found->second.body->getPrBody(),
		pr::Length2{x / _physicsMeter * pr::Meter, y / _physicsMeter * pr::Meter},
		pd::GetAngle(world, found->second.body->getPrBody()));
	error.clear(); return true;
}

bool LoveNode::getBodyAngle(Love::PhysicsBackend::BodyHandle body,
	float &angle, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	angle = static_cast<float>(pr::Real{pd::GetAngle(
		*found->second.body->getPhysicsWorld()->getPrWorld(), found->second.body->getPrBody()) / pr::Radian});
	error.clear(); return true;
}

bool LoveNode::setBodyAngle(Love::PhysicsBackend::BodyHandle body,
	float angle, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot rotate a closed Love physics Body"; return false; }
	auto &world = *found->second.body->getPhysicsWorld()->getPrWorld();
	pd::SetTransform(world, found->second.body->getPrBody(),
		pd::GetLocation(world, found->second.body->getPrBody()), angle * pr::Radian);
	error.clear(); return true;
}

bool LoveNode::getBodyLinearVelocity(Love::PhysicsBackend::BodyHandle body,
	float &x, float &y, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body) { error = "cannot query a closed Love physics Body"; return false; }
	const float scale = _physicsMeter / PhysicsWorld::scaleFactor; const Vec2 value = found->second.body->getVelocity();
	x = value.x * scale; y = value.y * scale; error.clear(); return true;
}

bool LoveNode::setBodyLinearVelocity(Love::PhysicsBackend::BodyHandle body,
	float x, float y, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body) { error = "cannot set velocity on a closed Love physics Body"; return false; }
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	found->second.body->setVelocity(x * scale, y * scale); error.clear(); return true;
}

bool LoveNode::getBodyAngularVelocity(Love::PhysicsBackend::BodyHandle body,
	float &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body)
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = -found->second.body->getAngularRate() * std::numbers::pi_v<float> / 180.0f;
	error.clear(); return true;
}

bool LoveNode::setBodyAngularVelocity(Love::PhysicsBackend::BodyHandle body,
	float value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body)
	{ error = "cannot set angular velocity on a closed Love physics Body"; return false; }
	found->second.body->setAngularRate(-value * 180.0f / std::numbers::pi_v<float>);
	error.clear(); return true;
}

bool LoveNode::getBodyLinearDamping(Love::PhysicsBackend::BodyHandle body,
	float &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body)
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = found->second.body->getLinearDamping(); error.clear(); return true;
}

bool LoveNode::setBodyLinearDamping(Love::PhysicsBackend::BodyHandle body,
	float value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body)
	{ error = "cannot set damping on a closed Love physics Body"; return false; }
	found->second.body->setLinearDamping(value); error.clear(); return true;
}

bool LoveNode::getBodyAngularDamping(Love::PhysicsBackend::BodyHandle body,
	float &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body)
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = found->second.body->getAngularDamping(); error.clear(); return true;
}

bool LoveNode::setBodyAngularDamping(Love::PhysicsBackend::BodyHandle body,
	float value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body)
	{ error = "cannot set damping on a closed Love physics Body"; return false; }
	found->second.body->setAngularDamping(value); error.clear(); return true;
}

bool LoveNode::getBodyMass(Love::PhysicsBackend::BodyHandle body,
	float &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = static_cast<float>(pr::Real{pd::GetMass(
		*found->second.body->getPhysicsWorld()->getPrWorld(), found->second.body->getPrBody()) / pr::Kilogram});
	error.clear(); return true;
}

bool LoveNode::getBodyInertia(Love::PhysicsBackend::BodyHandle body,
	float &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	const auto inertia = pd::GetLocalRotInertia(
		*found->second.body->getPhysicsWorld()->getPrWorld(), found->second.body->getPrBody());
	value = static_cast<float>(pr::Real{inertia /
		(pr::Kilogram * pr::SquareMeter / pr::SquareRadian)}) * _physicsMeter * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getBodyMassData(Love::PhysicsBackend::BodyHandle body,
	float &x, float &y, float &mass, float &inertia, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	const auto data = pd::GetMassData(
		*found->second.body->getPhysicsWorld()->getPrWorld(), found->second.body->getPrBody());
	x = static_cast<float>(pr::Real{pr::GetX(data.center) / pr::Meter}) * _physicsMeter;
	y = static_cast<float>(pr::Real{pr::GetY(data.center) / pr::Meter}) * _physicsMeter;
	mass = static_cast<float>(pr::Real{data.mass / pr::Kilogram});
	inertia = static_cast<float>(pr::Real{data.I /
		(pr::Kilogram * pr::SquareMeter / pr::SquareRadian)}) * _physicsMeter * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setBodyMassData(Love::PhysicsBackend::BodyHandle body,
	float x, float y, float mass, float inertia, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change mass data on a closed Love physics Body"; return false; }
	const float effectiveMass = mass > 0.0f ? mass : 1.0f;
	const float minimumInertia = effectiveMass * (x * x + y * y);
	if (inertia > 0.0f && inertia <= minimumInertia
		&& !pd::IsFixedRotation(*found->second.body->getPhysicsWorld()->getPrWorld(),
			found->second.body->getPrBody()))
	{
		error = "Body inertia must exceed mass times the squared local-center distance";
		return false;
	}
	auto &world = *found->second.body->getPhysicsWorld()->getPrWorld();
	pd::SetMassData(world, found->second.body->getPrBody(), pd::MassData{
		pr::Length2{x / _physicsMeter * pr::Meter, y / _physicsMeter * pr::Meter},
		pr::NonNegative<pr::Mass>{std::max(mass, 0.0f) * pr::Kilogram},
		pr::NonNegative<pr::RotInertia>{std::max(inertia, 0.0f) /
			(_physicsMeter * _physicsMeter) * pr::Kilogram * pr::SquareMeter / pr::SquareRadian}});
	error.clear(); return true;
}

bool LoveNode::resetBodyMassData(Love::PhysicsBackend::BodyHandle body, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot reset mass data on a closed Love physics Body"; return false; }
	pd::ResetMassData(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody());
	error.clear(); return true;
}

bool LoveNode::setBodyMass(Love::PhysicsBackend::BodyHandle body,
	float mass, std::string &error)
{
	float x = 0.0f, y = 0.0f, oldMass = 0.0f, inertia = 0.0f;
	if (!getBodyMassData(body, x, y, oldMass, inertia, error)) return false;
	return setBodyMassData(body, x, y, mass, inertia, error);
}

bool LoveNode::setBodyInertia(Love::PhysicsBackend::BodyHandle body,
	float inertia, std::string &error)
{
	float x = 0.0f, y = 0.0f, mass = 0.0f, oldInertia = 0.0f;
	if (!getBodyMassData(body, x, y, mass, oldInertia, error)) return false;
	return setBodyMassData(body, x, y, mass, inertia, error);
}

bool LoveNode::getBodyGravityScale(Love::PhysicsBackend::BodyHandle body,
	float &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end())
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = found->second.gravityScale;
	error.clear(); return true;
}

bool LoveNode::setBodyGravityScale(Love::PhysicsBackend::BodyHandle body,
	float value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change gravity scale on a closed Love physics Body"; return false; }
	const auto worldFound = _physicsWorlds.find(found->second.world);
	if (worldFound == _physicsWorlds.end())
	{ error = "Love physics Body World is closed"; return false; }
	auto &world = *found->second.body->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetAcceleration(world, found->second.body->getPrBody());
	const float delta = value - found->second.gravityScale;
	const auto gravityDelta = pr::LinearAcceleration2{
		worldFound->second.gravityX * delta / _physicsMeter,
		worldFound->second.gravityY * delta / _physicsMeter};
	pd::SetAcceleration(world, found->second.body->getPrBody(),
		current.linear + gravityDelta, current.angular);
	found->second.gravityScale = value;
	error.clear(); return true;
}

bool LoveNode::getBodyCenter(Love::PhysicsBackend::BodyHandle body, bool world,
	float &x, float &y, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	const auto &prWorld = *found->second.body->getPhysicsWorld()->getPrWorld();
	const auto center = world ? pd::GetWorldCenter(prWorld, found->second.body->getPrBody())
		: pd::GetLocalCenter(prWorld, found->second.body->getPrBody());
	x = static_cast<float>(pr::Real{pr::GetX(center) / pr::Meter}) * _physicsMeter;
	y = static_cast<float>(pr::Real{pr::GetY(center) / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::isBodyFixedRotation(Love::PhysicsBackend::BodyHandle body,
	bool &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = pd::IsFixedRotation(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody()); error.clear(); return true;
}

bool LoveNode::setBodyFixedRotation(Love::PhysicsBackend::BodyHandle body,
	bool value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love physics Body"; return false; }
	pd::SetFixedRotation(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody(), value); error.clear(); return true;
}

bool LoveNode::isBodyAwake(Love::PhysicsBackend::BodyHandle body,
	bool &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = pd::IsAwake(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody()); error.clear(); return true;
}

bool LoveNode::setBodyAwake(Love::PhysicsBackend::BodyHandle body,
	bool value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love physics Body"; return false; }
	auto &world = *found->second.body->getPhysicsWorld()->getPrWorld();
	if (value) pd::SetAwake(world, found->second.body->getPrBody());
	else pd::UnsetAwake(world, found->second.body->getPrBody());
	error.clear(); return true;
}

bool LoveNode::isBodySleepingAllowed(Love::PhysicsBackend::BodyHandle body,
	bool &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = pd::IsSleepingAllowed(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody()); error.clear(); return true;
}

bool LoveNode::setBodySleepingAllowed(Love::PhysicsBackend::BodyHandle body,
	bool value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love physics Body"; return false; }
	pd::SetSleepingAllowed(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody(), value); error.clear(); return true;
}

bool LoveNode::isBodyActive(Love::PhysicsBackend::BodyHandle body,
	bool &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = pd::IsEnabled(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody()); error.clear(); return true;
}

bool LoveNode::setBodyActive(Love::PhysicsBackend::BodyHandle body,
	bool value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love physics Body"; return false; }
	pd::SetEnabled(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody(), value); error.clear(); return true;
}

bool LoveNode::isBodyBullet(Love::PhysicsBackend::BodyHandle body,
	bool &value, std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	value = pd::IsImpenetrable(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody()); error.clear(); return true;
}

bool LoveNode::setBodyBullet(Love::PhysicsBackend::BodyHandle body,
	bool value, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love physics Body"; return false; }
	pd::SetImpenetrable(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody(), value); error.clear(); return true;
}

bool LoveNode::setBodyType(Love::PhysicsBackend::BodyHandle body,
	std::string_view type, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love physics Body"; return false; }
	const auto value = type == "dynamic" ? pr::BodyType::Dynamic
		: type == "kinematic" ? pr::BodyType::Kinematic : pr::BodyType::Static;
	pd::SetType(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody(), value); error.clear(); return true;
}

bool LoveNode::transformBodyPoint(Love::PhysicsBackend::BodyHandle body,
	bool toWorld, bool vector, float x, float y, float &outX, float &outY,
	std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot transform with a closed Love physics Body"; return false; }
	const auto &prWorld = *found->second.body->getPhysicsWorld()->getPrWorld();
	const auto transform = pd::GetTransformation(prWorld, found->second.body->getPrBody());
	if (vector)
	{
		const pr::Vec2 input{x, y};
		const auto output = toWorld ? pd::Rotate(input, transform.q) : pd::InverseRotate(input, transform.q);
		outX = static_cast<float>(output[0]); outY = static_cast<float>(output[1]);
	}
	else
	{
		const pr::Length2 input{x / _physicsMeter * pr::Meter, y / _physicsMeter * pr::Meter};
		const auto output = toWorld ? pd::Transform(input, transform) : pd::InverseTransform(input, transform);
		outX = static_cast<float>(pr::Real{output[0] / pr::Meter}) * _physicsMeter;
		outY = static_cast<float>(pr::Real{output[1] / pr::Meter}) * _physicsMeter;
	}
	error.clear(); return true;
}

bool LoveNode::getBodyPointVelocity(Love::PhysicsBackend::BodyHandle body,
	bool local, float x, float y, float &outX, float &outY,
	std::string &error) const
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Body"; return false; }
	const auto &prWorld = *found->second.body->getPhysicsWorld()->getPrWorld();
	const auto &prBody = pd::GetBody(prWorld, found->second.body->getPrBody());
	const pr::Length2 point{x / _physicsMeter * pr::Meter, y / _physicsMeter * pr::Meter};
	const auto velocity = local ? pd::GetLinearVelocityFromLocalPoint(prBody, point)
		: pd::GetLinearVelocityFromWorldPoint(prBody, point);
	outX = static_cast<float>(pr::Real{velocity[0] / pr::MeterPerSecond}) * _physicsMeter;
	outY = static_cast<float>(pr::Real{velocity[1] / pr::MeterPerSecond}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::applyBodyLinearImpulse(Love::PhysicsBackend::BodyHandle body,
	float impulseX, float impulseY, float pointX, float pointY, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body) { error = "cannot apply impulse to a closed Love physics Body"; return false; }
	const float scale = PhysicsWorld::scaleFactor / _physicsMeter;
	found->second.body->applyLinearImpulse(Vec2{impulseX * scale, impulseY * scale},
		Vec2{pointX * scale, pointY * scale}); error.clear(); return true;
}

bool LoveNode::applyBodyAngularImpulse(Love::PhysicsBackend::BodyHandle body,
	float impulse, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot apply impulse to a closed Love physics Body"; return false; }
	pd::ApplyAngularImpulse(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody(), impulse / (_physicsMeter * _physicsMeter)
			* pr::NewtonMeterSecond);
	error.clear(); return true;
}

bool LoveNode::applyBodyForce(Love::PhysicsBackend::BodyHandle body,
	float forceX, float forceY, float pointX, float pointY, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot apply force to a closed Love physics Body"; return false; }
	pd::ApplyForce(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody(),
		pr::Force2{forceX / _physicsMeter * pr::Newton, forceY / _physicsMeter * pr::Newton},
		pr::Length2{pointX / _physicsMeter * pr::Meter, pointY / _physicsMeter * pr::Meter});
	error.clear(); return true;
}

bool LoveNode::applyBodyTorque(Love::PhysicsBackend::BodyHandle body,
	float torque, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body
		|| !found->second.body->getPhysicsWorld()
		|| !found->second.body->getPhysicsWorld()->getPrWorld())
	{ error = "cannot apply torque to a closed Love physics Body"; return false; }
	pd::ApplyTorque(*found->second.body->getPhysicsWorld()->getPrWorld(),
		found->second.body->getPrBody(), torque / (_physicsMeter * _physicsMeter)
			* pr::NewtonMeter);
	error.clear(); return true;
}

Love::PhysicsBackend::FixtureHandle LoveNode::newFixture(Love::PhysicsBackend::BodyHandle body,
	Love::PhysicsBackend::ShapeHandle shape, float density, std::string &error)
{
	const auto bodyFound = _physicsBodies.find(body); const auto shapeFound = _physicsShapes.find(shape);
	if (bodyFound == _physicsBodies.end() || shapeFound == _physicsShapes.end()
		|| !bodyFound->second.body || !shapeFound->second.fixture)
	{ error = "cannot create Love Fixture from a closed Body or Shape"; return 0; }
	FixtureDef *fixture = FixtureDef::create(shapeFound->second.fixture->shape);
	pd::SetDensity(fixture->shape, density);
	// PlayRho keeps its original category/mask-only filtering behavior. The
	// default Love filter maps directly; non-zero Love groups add a private
	// candidate bit when setFixtureFilterData is called below.
	pd::SetFilter(fixture->shape, pr::Filter{1u, 0xffffu, 0});
	const pr::ShapeID fixtureId = bodyFound->second.body->attach(fixture);
	if (!pr::IsValid(fixtureId)) { error = "Dora PlayRho failed to attach Love Fixture"; return 0; }
	const auto handle = _nextPhysicsFixtureHandle++;
	_physicsFixtures.emplace(handle, PhysicsFixtureResource{
		bodyFound->second.world, body, fixtureId.get(), Love::PhysicsFilter{}});
	error.clear(); return handle;
}

void LoveNode::releaseFixture(Love::PhysicsBackend::FixtureHandle fixture)
{
	const auto found = _physicsFixtures.find(fixture);
	if (found == _physicsFixtures.end()) return;
	const auto world = _physicsWorlds.find(found->second.world);
	if (world != _physicsWorlds.end() && world->second.world && world->second.world->getPrWorld()
		&& pd::IsLocked(*world->second.world->getPrWorld()))
	{
		_pendingPhysicsFixtureDestroy.insert(fixture);
		return;
	}
	_pendingPhysicsFixtureDestroy.erase(fixture);
	if (world != _physicsWorlds.end() && world->second.world && world->second.world->getPrWorld())
	{
		const pr::ShapeID id{found->second.shape};
		if (pr::IsValid(id)) pd::Destroy(*world->second.world->getPrWorld(), id);
	}
	_physicsFixtures.erase(found);
}

bool LoveNode::isFixtureValid(Love::PhysicsBackend::FixtureHandle fixture) const
{
	return _physicsFixtures.find(fixture) != _physicsFixtures.end();
}

bool LoveNode::setFixtureFriction(Love::PhysicsBackend::FixtureHandle fixture,
	float friction, std::string &error)
{
	const auto found = _physicsFixtures.find(fixture); if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto world = _physicsWorlds.find(found->second.world); if (world == _physicsWorlds.end() || !world->second.world) { error = "Fixture World is closed"; return false; }
	pd::SetFriction(*world->second.world->getPrWorld(), pr::ShapeID{found->second.shape}, friction); error.clear(); return true;
}

bool LoveNode::setFixtureRestitution(Love::PhysicsBackend::FixtureHandle fixture,
	float restitution, std::string &error)
{
	const auto found = _physicsFixtures.find(fixture); if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto world = _physicsWorlds.find(found->second.world); if (world == _physicsWorlds.end() || !world->second.world) { error = "Fixture World is closed"; return false; }
	pd::SetRestitution(*world->second.world->getPrWorld(), pr::ShapeID{found->second.shape}, restitution); error.clear(); return true;
}

bool LoveNode::setFixtureSensor(Love::PhysicsBackend::FixtureHandle fixture,
	bool sensor, std::string &error)
{
	const auto found = _physicsFixtures.find(fixture); if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto world = _physicsWorlds.find(found->second.world); if (world == _physicsWorlds.end() || !world->second.world) { error = "Fixture World is closed"; return false; }
	pd::SetSensor(*world->second.world->getPrWorld(), pr::ShapeID{found->second.shape}, sensor); error.clear(); return true;
}

bool LoveNode::setFixtureDensity(Love::PhysicsBackend::FixtureHandle fixture,
	float density, std::string &error)
{
	const auto found = _physicsFixtures.find(fixture);
	if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Fixture World is closed"; return false; }
	pd::SetDensity(*world->second.world->getPrWorld(), pr::ShapeID{found->second.shape},
		pr::NonNegative<pr::AreaDensity>{density * pr::KilogramPerSquareMeter});
	error.clear(); return true;
}

bool LoveNode::testFixturePoint(Love::PhysicsBackend::FixtureHandle fixture,
	float x, float y, bool &value, std::string &error) const
{
	const auto found = _physicsFixtures.find(fixture);
	if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto worldFound = _physicsWorlds.find(found->second.world);
	const auto bodyFound = _physicsBodies.find(found->second.body);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld() || bodyFound == _physicsBodies.end()
		|| !bodyFound->second.body)
	{ error = "Fixture World or Body is closed"; return false; }
	const auto &world = *worldFound->second.world->getPrWorld();
	value = pd::TestPoint(world, bodyFound->second.body->getPrBody(),
		pr::ShapeID{found->second.shape},
		pr::Length2{x / _physicsMeter * pr::Meter, y / _physicsMeter * pr::Meter});
	error.clear(); return true;
}

bool LoveNode::rayCastFixture(Love::PhysicsBackend::FixtureHandle fixture,
	float x1, float y1, float x2, float y2, float maxFraction,
	std::uint16_t childIndex, bool &hit, float &normalX, float &normalY,
	float &fraction, std::string &error) const
{
	const auto found = _physicsFixtures.find(fixture);
	if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto worldFound = _physicsWorlds.find(found->second.world);
	const auto bodyFound = _physicsBodies.find(found->second.body);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld() || bodyFound == _physicsBodies.end()
		|| !bodyFound->second.body)
	{ error = "Fixture World or Body is closed"; return false; }
	const auto &world = *worldFound->second.world->getPrWorld();
	const auto shape = pd::GetShape(world, pr::ShapeID{found->second.shape});
	if (childIndex >= pd::GetChildCount(shape))
	{ error = "Fixture child index is out of range"; return false; }
	const pd::RayCastInput input{
		pr::Length2{x1 / _physicsMeter * pr::Meter, y1 / _physicsMeter * pr::Meter},
		pr::Length2{x2 / _physicsMeter * pr::Meter, y2 / _physicsMeter * pr::Meter},
		pr::UnitInterval<pr::Real>{maxFraction}};
	const auto result = pd::RayCast(shape, static_cast<pr::ChildCounter>(childIndex),
		input, pd::GetTransformation(world, bodyFound->second.body->getPrBody()));
	hit = result.has_value();
	if (hit)
	{
		normalX = static_cast<float>(pr::Real{result->normal.GetX()});
		normalY = static_cast<float>(pr::Real{result->normal.GetY()});
		fraction = static_cast<float>(pr::Real{result->fraction});
	}
	error.clear(); return true;
}

bool LoveNode::getFixtureFilterData(Love::PhysicsBackend::FixtureHandle fixture,
	std::uint16_t &categoryBits, std::uint16_t &maskBits,
	std::int16_t &groupIndex, std::string &error) const
{
	const auto found = _physicsFixtures.find(fixture);
	if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Fixture World is closed"; return false; }
	categoryBits = found->second.filter.categoryBits;
	maskBits = found->second.filter.maskBits;
	groupIndex = found->second.filter.groupIndex;
	error.clear(); return true;
}

bool LoveNode::setFixtureFilterData(Love::PhysicsBackend::FixtureHandle fixture,
	std::uint16_t categoryBits, std::uint16_t maskBits,
	std::int16_t groupIndex, std::string &error)
{
	const auto found = _physicsFixtures.find(fixture);
	if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Fixture World is closed"; return false; }
	if (groupIndex < std::numeric_limits<pr::Filter::index_type>::min()
		|| groupIndex > std::numeric_limits<pr::Filter::index_type>::max())
	{ error = "Fixture group index must be in signed 16-bit range"; return false; }
	found->second.filter = Love::PhysicsFilter{categoryBits, maskBits, groupIndex};
	// Bit 16 is outside Love's public 16 category bits. It makes every pair of
	// non-zero-group Love fixtures a PlayRho candidate so the listener can apply
	// exact same-group positive/negative override semantics. Group-zero pairs
	// and mixed pairs keep native category/mask broad-phase pruning.
	constexpr pr::Filter::bits_type LoveGroupCandidateBit = 1u << 16;
	const auto candidateBit = groupIndex == 0 ? 0u : LoveGroupCandidateBit;
	pd::SetFilterData(*world->second.world->getPrWorld(), pr::ShapeID{found->second.shape},
		pr::Filter{static_cast<pr::Filter::bits_type>(categoryBits) | candidateBit,
			static_cast<pr::Filter::bits_type>(maskBits) | candidateBit,
			static_cast<pr::Filter::index_type>(groupIndex)});
	error.clear(); return true;
}

bool LoveNode::getFixtureBoundingBox(Love::PhysicsBackend::FixtureHandle fixture,
	std::uint16_t childIndex, float &x1, float &y1, float &x2, float &y2,
	std::string &error) const
{
	const auto found = _physicsFixtures.find(fixture);
	if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto worldFound = _physicsWorlds.find(found->second.world);
	const auto bodyFound = _physicsBodies.find(found->second.body);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld() || bodyFound == _physicsBodies.end()
		|| !bodyFound->second.body)
	{ error = "Fixture World or Body is closed"; return false; }
	const auto &world = *worldFound->second.world->getPrWorld();
	const auto shape = pd::GetShape(world, pr::ShapeID{found->second.shape});
	if (childIndex >= pd::GetChildCount(shape))
	{ error = "Fixture child index is out of range"; return false; }
	const auto box = pd::ComputeAABB(pd::GetChild(shape,
		static_cast<pr::ChildCounter>(childIndex)),
		pd::GetTransformation(world, bodyFound->second.body->getPrBody()));
	x1 = static_cast<float>(pr::Real{box.ranges[0].GetMin() / pr::Meter}) * _physicsMeter;
	y1 = static_cast<float>(pr::Real{box.ranges[1].GetMin() / pr::Meter}) * _physicsMeter;
	x2 = static_cast<float>(pr::Real{box.ranges[0].GetMax() / pr::Meter}) * _physicsMeter;
	y2 = static_cast<float>(pr::Real{box.ranges[1].GetMax() / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getFixtureMassData(Love::PhysicsBackend::FixtureHandle fixture,
	float &x, float &y, float &mass, float &inertia, std::string &error) const
{
	const auto found = _physicsFixtures.find(fixture);
	if (found == _physicsFixtures.end()) { error = "Fixture is closed"; return false; }
	const auto world = _physicsWorlds.find(found->second.world);
	if (world == _physicsWorlds.end() || !world->second.world || !world->second.world->getPrWorld())
	{ error = "Fixture World is closed"; return false; }
	const auto data = pd::GetMassData(*world->second.world->getPrWorld(),
		pr::ShapeID{found->second.shape});
	x = static_cast<float>(pr::Real{pr::GetX(data.center) / pr::Meter}) * _physicsMeter;
	y = static_cast<float>(pr::Real{pr::GetY(data.center) / pr::Meter}) * _physicsMeter;
	mass = static_cast<float>(pr::Real{data.mass / pr::Kilogram});
	// Love 11.5 scales Fixture centers but returns the Box2D fixture inertia in kg*m^2.
	inertia = static_cast<float>(pr::Real{data.I /
		(pr::Kilogram * pr::SquareMeter / pr::SquareRadian)});
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newDistanceJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float x1, float y1, float x2, float y2, bool collideConnected, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love DistanceJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world || !worldFound->second.world->getPrWorld())
	{ error = "Love DistanceJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const pr::Vec2 worldA = PhysicsWorld::prVal(Vec2{x1 * PhysicsWorld::scaleFactor / _physicsMeter,
		y1 * PhysicsWorld::scaleFactor / _physicsMeter});
	const pr::Vec2 worldB = PhysicsWorld::prVal(Vec2{x2 * PhysicsWorld::scaleFactor / _physicsMeter,
		y2 * PhysicsWorld::scaleFactor / _physicsMeter});
	const Vec2 localA = PhysicsWorld::Val(pd::GetLocalPoint(world, a->second.body->getPrBody(), worldA));
	const Vec2 localB = PhysicsWorld::Val(pd::GetLocalPoint(world, b->second.body->getPrBody(), worldB));
	Joint *joint = Joint::distance(collideConnected, a->second.body, b->second.body, localA, localB);
	if (!joint) { error = "Dora PlayRho failed to create Love DistanceJoint"; return 0; }
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB}); error.clear(); return handle;
}

void LoveNode::releaseJoint(Love::PhysicsBackend::JointHandle joint)
{
	const auto found = _physicsJoints.find(joint);
	if (found != _physicsJoints.end())
	{
		const auto world = _physicsWorlds.find(found->second.world);
		if (world != _physicsWorlds.end() && world->second.world && world->second.world->getPrWorld()
			&& pd::IsLocked(*world->second.world->getPrWorld()))
		{
			_pendingPhysicsJointDestroy.insert(joint);
			return;
		}
	}
	_pendingPhysicsJointDestroy.erase(joint);
	std::vector<Love::PhysicsBackend::JointHandle> dependents;
	for (const auto &[handle, resource] : _physicsJoints)
		if (handle != joint && (resource.sourceJointA == joint || resource.sourceJointB == joint))
			dependents.push_back(handle);
	for (const auto handle : dependents) releaseJoint(handle);
	if (found != _physicsJoints.end() && found->second.joint) found->second.joint->destroy();
	_physicsJoints.erase(joint);
}

bool LoveNode::isJointValid(Love::PhysicsBackend::JointHandle joint) const
{
	return _physicsJoints.find(joint) != _physicsJoints.end();
}

bool LoveNode::getJointAnchors(Love::PhysicsBackend::JointHandle joint,
	float &x1, float &y1, float &x2, float &y2, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Joint"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto anchorA = pd::GetAnchorA(world, found->second.joint->getPrJoint());
	const auto anchorB = pd::GetAnchorB(world, found->second.joint->getPrJoint());
	x1 = static_cast<float>(pr::Real{pr::GetX(anchorA) / pr::Meter}) * _physicsMeter;
	y1 = static_cast<float>(pr::Real{pr::GetY(anchorA) / pr::Meter}) * _physicsMeter;
	x2 = static_cast<float>(pr::Real{pr::GetX(anchorB) / pr::Meter}) * _physicsMeter;
	y2 = static_cast<float>(pr::Real{pr::GetY(anchorB) / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getJointReactionForce(Love::PhysicsBackend::JointHandle joint,
	float inverseDeltaTime, float &x, float &y, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Joint"; return false; }
	const auto reaction = pd::GetLinearReaction(
		*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint());
	x = static_cast<float>(pr::Real{pr::GetX(reaction) / pr::NewtonSecond})
		* inverseDeltaTime * _physicsMeter;
	y = static_cast<float>(pr::Real{pr::GetY(reaction) / pr::NewtonSecond})
		* inverseDeltaTime * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getJointReactionTorque(Love::PhysicsBackend::JointHandle joint,
	float inverseDeltaTime, float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Joint"; return false; }
	const auto reaction = pd::GetAngularReaction(
		*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint());
	value = static_cast<float>(pr::Real{reaction / pr::NewtonMeterSecond})
		* inverseDeltaTime * _physicsMeter * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getJointCollideConnected(Love::PhysicsBackend::JointHandle joint,
	bool &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love physics Joint"; return false; }
	value = pd::GetCollideConnected(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	error.clear(); return true;
}

bool LoveNode::getDistanceJointLength(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love DistanceJoint"; return false; }
	value = static_cast<float>(pr::Real{pd::GetLength(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setDistanceJointLength(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love DistanceJoint"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::DistanceJointConf>(&current);
	if (!source) { error = "Love Joint is not a DistanceJoint"; return false; }
	auto conf = *source;
	conf.UseLength(value / _physicsMeter * pr::Meter);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

bool LoveNode::getDistanceJointFrequency(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love DistanceJoint"; return false; }
	value = static_cast<float>(pr::Real{pd::GetFrequency(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::Hertz});
	error.clear(); return true;
}

bool LoveNode::setDistanceJointFrequency(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love DistanceJoint"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	pd::SetFrequency(world, found->second.joint->getPrJoint(), value * pr::Hertz);
	error.clear(); return true;
}

bool LoveNode::getDistanceJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot query a closed Love DistanceJoint"; return false; }
	value = static_cast<float>(pd::GetDampingRatio(
		*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint()));
	error.clear(); return true;
}

bool LoveNode::setDistanceJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "cannot change a closed Love DistanceJoint"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::DistanceJointConf>(&current);
	if (!source) { error = "Love Joint is not a DistanceJoint"; return false; }
	auto conf = *source;
	conf.UseDampingRatio(value);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newRevoluteJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float x1, float y1, float x2, float y2, bool collideConnected,
	bool hasReferenceAngle, float referenceAngle, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love RevoluteJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love RevoluteJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto bodyAId = a->second.body->getPrBody();
	const auto bodyBId = b->second.body->getPrBody();
	const pr::Length2 worldA{x1 / _physicsMeter * pr::Meter, y1 / _physicsMeter * pr::Meter};
	const pr::Length2 worldB{x2 / _physicsMeter * pr::Meter, y2 / _physicsMeter * pr::Meter};
	const auto localA = pd::GetLocalPoint(world, bodyAId, worldA);
	const auto localB = pd::GetLocalPoint(world, bodyBId, worldB);
	const auto reference = hasReferenceAngle ? referenceAngle * pr::Radian
		: pd::GetAngle(world, bodyBId) - pd::GetAngle(world, bodyAId);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world,
		pd::RevoluteJointConf{bodyAId, bodyBId, localA, localB, reference}
			.UseCollideConnected(collideConnected));
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love RevoluteJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB});
	error.clear(); return handle;
}

bool LoveNode::getRevoluteJointAngle(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	value = static_cast<float>(pr::Real{pd::GetAngle(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::Radian});
	error.clear(); return true;
}

bool LoveNode::getRevoluteJointSpeed(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	value = static_cast<float>(pr::Real{pd::GetAngularVelocity(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::RadianPerSecond});
	error.clear(); return true;
}

bool LoveNode::isRevoluteJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
	bool &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	value = pd::IsMotorEnabled(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()); error.clear(); return true;
}

bool LoveNode::setRevoluteJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
	bool value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	pd::EnableMotor(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), value); error.clear(); return true;
}

bool LoveNode::getRevoluteJointMaxMotorTorque(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	const auto torque = pd::GetMaxMotorTorque(
		*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint());
	value = static_cast<float>(pr::Real{torque / pr::NewtonMeter})
		* _physicsMeter * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setRevoluteJointMaxMotorTorque(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	pd::SetMaxMotorTorque(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), value / (_physicsMeter * _physicsMeter) * pr::NewtonMeter);
	error.clear(); return true;
}

bool LoveNode::getRevoluteJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	value = static_cast<float>(pr::Real{pd::GetMotorSpeed(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::RadianPerSecond});
	error.clear(); return true;
}

bool LoveNode::setRevoluteJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	pd::SetMotorSpeed(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), value * pr::RadianPerSecond);
	error.clear(); return true;
}

bool LoveNode::getRevoluteJointMotorTorque(Love::PhysicsBackend::JointHandle joint,
	float inverseDeltaTime, float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	const auto torque = pd::GetMotorTorque(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), inverseDeltaTime * pr::Hertz);
	value = static_cast<float>(pr::Real{torque / pr::NewtonMeter})
		* _physicsMeter * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::areRevoluteJointLimitsEnabled(Love::PhysicsBackend::JointHandle joint,
	bool &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	value = pd::IsLimitEnabled(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()); error.clear(); return true;
}

bool LoveNode::setRevoluteJointLimitsEnabled(Love::PhysicsBackend::JointHandle joint,
	bool value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	pd::EnableLimit(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), value); error.clear(); return true;
}

bool LoveNode::getRevoluteJointLimits(Love::PhysicsBackend::JointHandle joint,
	float &lower, float &upper, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	lower = static_cast<float>(pr::Real{pd::GetAngularLowerLimit(
		world, found->second.joint->getPrJoint()) / pr::Radian});
	upper = static_cast<float>(pr::Real{pd::GetAngularUpperLimit(
		world, found->second.joint->getPrJoint()) / pr::Radian});
	error.clear(); return true;
}

bool LoveNode::setRevoluteJointLimits(Love::PhysicsBackend::JointHandle joint,
	float lower, float upper, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	pd::SetAngularLimits(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), lower * pr::Radian, upper * pr::Radian);
	error.clear(); return true;
}

bool LoveNode::getRevoluteJointReferenceAngle(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RevoluteJoint is closed"; return false; }
	value = static_cast<float>(pr::Real{pd::GetReferenceAngle(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::Radian});
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newPrismaticJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float x1, float y1, float x2, float y2, float axisX, float axisY,
	bool collideConnected, bool hasReferenceAngle, float referenceAngle, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love PrismaticJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love PrismaticJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto bodyAId = a->second.body->getPrBody();
	const auto bodyBId = b->second.body->getPrBody();
	const pr::Length2 worldA{x1 / _physicsMeter * pr::Meter, y1 / _physicsMeter * pr::Meter};
	const pr::Length2 worldB{x2 / _physicsMeter * pr::Meter, y2 / _physicsMeter * pr::Meter};
	const auto localA = pd::GetLocalPoint(world, bodyAId, worldA);
	const auto localB = pd::GetLocalPoint(world, bodyBId, worldB);
	const auto worldAxis = pd::UnitVec::Get(axisX, axisY, pd::UnitVec::GetRight()).first;
	const auto localAxis = pd::GetLocalVector(world, bodyAId, worldAxis);
	const auto reference = hasReferenceAngle ? referenceAngle * pr::Radian
		: pd::GetAngle(world, bodyBId) - pd::GetAngle(world, bodyAId);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world,
		pd::PrismaticJointConf{bodyAId, bodyBId, localA, localB, localAxis, reference}
			.UseEnableLimit(true).UseLowerLength(0.0f * pr::Meter)
			.UseUpperLength(100.0f * pr::Meter)
			.UseCollideConnected(collideConnected));
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love PrismaticJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB});
	error.clear(); return handle;
}

bool LoveNode::getPrismaticJointTranslation(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	value = static_cast<float>(pr::Real{pd::GetJointTranslation(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getPrismaticJointSpeed(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::PrismaticJointConf>(&current);
	if (!conf) { error = "Love Joint is not a PrismaticJoint"; return false; }
	value = static_cast<float>(pr::Real{pd::GetLinearVelocity(world, *conf)
		/ pr::MeterPerSecond}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::isPrismaticJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
	bool &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	value = pd::IsMotorEnabled(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()); error.clear(); return true;
}

bool LoveNode::setPrismaticJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
	bool value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	pd::EnableMotor(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), value); error.clear(); return true;
}

bool LoveNode::getPrismaticJointMaxMotorForce(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	value = static_cast<float>(pr::Real{pd::GetMaxMotorForce(current) / pr::Newton})
		* _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setPrismaticJointMaxMotorForce(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	pd::SetMaxMotorForce(current, value / _physicsMeter * pr::Newton);
	pd::SetJoint(world, found->second.joint->getPrJoint(), current);
	error.clear(); return true;
}

bool LoveNode::getPrismaticJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	value = static_cast<float>(pr::Real{pd::GetMotorSpeed(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::RadianPerSecond}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setPrismaticJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	pd::SetMotorSpeed(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), value / _physicsMeter * pr::RadianPerSecond);
	error.clear(); return true;
}

bool LoveNode::getPrismaticJointMotorForce(Love::PhysicsBackend::JointHandle joint,
	float inverseDeltaTime, float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	const auto force = pd::GetMotorForce(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), inverseDeltaTime * pr::Hertz);
	value = static_cast<float>(pr::Real{force / pr::Newton}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::arePrismaticJointLimitsEnabled(Love::PhysicsBackend::JointHandle joint,
	bool &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	value = pd::IsLimitEnabled(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()); error.clear(); return true;
}

bool LoveNode::setPrismaticJointLimitsEnabled(Love::PhysicsBackend::JointHandle joint,
	bool value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	pd::EnableLimit(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint(), value); error.clear(); return true;
}

bool LoveNode::getPrismaticJointLimits(Love::PhysicsBackend::JointHandle joint,
	float &lower, float &upper, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	lower = static_cast<float>(pr::Real{pd::GetLinearLowerLimit(current) / pr::Meter})
		* _physicsMeter;
	upper = static_cast<float>(pr::Real{pd::GetLinearUpperLimit(current) / pr::Meter})
		* _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setPrismaticJointLimits(Love::PhysicsBackend::JointHandle joint,
	float lower, float upper, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	pd::SetLinearLimits(current, lower / _physicsMeter * pr::Meter,
		upper / _physicsMeter * pr::Meter);
	pd::SetJoint(world, found->second.joint->getPrJoint(), current);
	error.clear(); return true;
}

bool LoveNode::getPrismaticJointAxis(Love::PhysicsBackend::JointHandle joint,
	float &x, float &y, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto id = found->second.joint->getPrJoint();
	const auto worldAxis = pd::GetWorldVector(world, pd::GetBodyA(world, id),
		pd::GetLocalXAxisA(world, id));
	x = static_cast<float>(worldAxis[0]); y = static_cast<float>(worldAxis[1]);
	error.clear(); return true;
}

bool LoveNode::getPrismaticJointReferenceAngle(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PrismaticJoint is closed"; return false; }
	value = static_cast<float>(pr::Real{pd::GetReferenceAngle(
		*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint()) / pr::Radian});
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newWeldJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float x1, float y1, float x2, float y2, bool collideConnected,
	bool hasReferenceAngle, float referenceAngle, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love WeldJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love WeldJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto bodyAId = a->second.body->getPrBody();
	const auto bodyBId = b->second.body->getPrBody();
	const pr::Length2 worldA{x1 / _physicsMeter * pr::Meter, y1 / _physicsMeter * pr::Meter};
	const pr::Length2 worldB{x2 / _physicsMeter * pr::Meter, y2 / _physicsMeter * pr::Meter};
	const auto localA = pd::GetLocalPoint(world, bodyAId, worldA);
	const auto localB = pd::GetLocalPoint(world, bodyBId, worldB);
	const auto reference = hasReferenceAngle ? referenceAngle * pr::Radian
		: pd::GetAngle(world, bodyBId) - pd::GetAngle(world, bodyAId);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world,
		pd::WeldJointConf{bodyAId, bodyBId, localA, localB, reference}
			.UseCollideConnected(collideConnected));
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love WeldJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB});
	error.clear(); return handle;
}

bool LoveNode::getWeldJointFrequency(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "WeldJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	if (!pd::TypeCast<pd::WeldJointConf>(&current))
	{ error = "Love Joint is not a WeldJoint"; return false; }
	value = static_cast<float>(pr::Real{pd::GetFrequency(current) / pr::Hertz});
	error.clear(); return true;
}

bool LoveNode::setWeldJointFrequency(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "WeldJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	if (!pd::TypeCast<pd::WeldJointConf>(&current))
	{ error = "Love Joint is not a WeldJoint"; return false; }
	pd::SetFrequency(world, found->second.joint->getPrJoint(), value * pr::Hertz);
	error.clear(); return true;
}

bool LoveNode::getWeldJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "WeldJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::WeldJointConf>(&current);
	if (!conf) { error = "Love Joint is not a WeldJoint"; return false; }
	value = static_cast<float>(conf->dampingRatio);
	error.clear(); return true;
}

bool LoveNode::setWeldJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "WeldJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::WeldJointConf>(&current);
	if (!source) { error = "Love Joint is not a WeldJoint"; return false; }
	auto conf = *source; conf.UseDampingRatio(value);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

bool LoveNode::getWeldJointReferenceAngle(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "WeldJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::WeldJointConf>(&current);
	if (!conf) { error = "Love Joint is not a WeldJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->referenceAngle / pr::Radian});
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newFrictionJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float x1, float y1, float x2, float y2, bool collideConnected, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love FrictionJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love FrictionJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto bodyAId = a->second.body->getPrBody();
	const auto bodyBId = b->second.body->getPrBody();
	const pr::Length2 worldA{x1 / _physicsMeter * pr::Meter, y1 / _physicsMeter * pr::Meter};
	const pr::Length2 worldB{x2 / _physicsMeter * pr::Meter, y2 / _physicsMeter * pr::Meter};
	const auto localA = pd::GetLocalPoint(world, bodyAId, worldA);
	const auto localB = pd::GetLocalPoint(world, bodyBId, worldB);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world,
		pd::FrictionJointConf{bodyAId, bodyBId, localA, localB}
			.UseCollideConnected(collideConnected));
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love FrictionJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB});
	error.clear(); return handle;
}

bool LoveNode::getFrictionJointMaxForce(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "FrictionJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::FrictionJointConf>(&current);
	if (!conf) { error = "Love Joint is not a FrictionJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->maxForce / pr::Newton}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setFrictionJointMaxForce(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "FrictionJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::FrictionJointConf>(&current);
	if (!source) { error = "Love Joint is not a FrictionJoint"; return false; }
	auto conf = *source; conf.UseMaxForce(value / _physicsMeter * pr::Newton);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

bool LoveNode::getFrictionJointMaxTorque(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "FrictionJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::FrictionJointConf>(&current);
	if (!conf) { error = "Love Joint is not a FrictionJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->maxTorque / pr::NewtonMeter})
		* _physicsMeter * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setFrictionJointMaxTorque(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "FrictionJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::FrictionJointConf>(&current);
	if (!source) { error = "Love Joint is not a FrictionJoint"; return false; }
	auto conf = *source;
	conf.UseMaxTorque(value / (_physicsMeter * _physicsMeter) * pr::NewtonMeter);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newRopeJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float x1, float y1, float x2, float y2, float maxLength,
	bool collideConnected, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love RopeJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love RopeJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto bodyAId = a->second.body->getPrBody();
	const auto bodyBId = b->second.body->getPrBody();
	const pr::Length2 worldA{x1 / _physicsMeter * pr::Meter, y1 / _physicsMeter * pr::Meter};
	const pr::Length2 worldB{x2 / _physicsMeter * pr::Meter, y2 / _physicsMeter * pr::Meter};
	auto conf = pd::RopeJointConf{bodyAId, bodyBId};
	conf.localAnchorA = pd::GetLocalPoint(world, bodyAId, worldA);
	conf.localAnchorB = pd::GetLocalPoint(world, bodyBId, worldB);
	conf.UseMaxLength(maxLength / _physicsMeter * pr::Meter)
		.UseCollideConnected(collideConnected);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world, conf);
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love RopeJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB});
	error.clear(); return handle;
}

bool LoveNode::getRopeJointMaxLength(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RopeJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::RopeJointConf>(&current);
	if (!conf) { error = "Love Joint is not a RopeJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->maxLength / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setRopeJointMaxLength(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "RopeJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::RopeJointConf>(&current);
	if (!source) { error = "Love Joint is not a RopeJoint"; return false; }
	auto conf = *source;
	conf.UseMaxLength(value / _physicsMeter * pr::Meter);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newPulleyJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float groundX1, float groundY1, float groundX2, float groundY2,
	float x1, float y1, float x2, float y2, float ratio,
	bool collideConnected, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love PulleyJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love PulleyJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto bodyAId = a->second.body->getPrBody();
	const auto bodyBId = b->second.body->getPrBody();
	const auto toLength2 = [this](float x, float y) {
		return pr::Length2{x / _physicsMeter * pr::Meter, y / _physicsMeter * pr::Meter};
	};
	auto conf = pd::GetPulleyJointConf(world, bodyAId, bodyBId,
		toLength2(groundX1, groundY1), toLength2(groundX2, groundY2),
		toLength2(x1, y1), toLength2(x2, y2));
	conf.UseRatio(ratio).UseCollideConnected(collideConnected);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world, conf);
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love PulleyJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB});
	error.clear(); return handle;
}

bool LoveNode::getPulleyJointGroundAnchors(Love::PhysicsBackend::JointHandle joint,
	float &x1, float &y1, float &x2, float &y2, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PulleyJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::PulleyJointConf>(&current);
	if (!conf) { error = "Love Joint is not a PulleyJoint"; return false; }
	x1 = static_cast<float>(pr::Real{conf->groundAnchorA[0] / pr::Meter}) * _physicsMeter;
	y1 = static_cast<float>(pr::Real{conf->groundAnchorA[1] / pr::Meter}) * _physicsMeter;
	x2 = static_cast<float>(pr::Real{conf->groundAnchorB[0] / pr::Meter}) * _physicsMeter;
	y2 = static_cast<float>(pr::Real{conf->groundAnchorB[1] / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getPulleyJointLengthA(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PulleyJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::PulleyJointConf>(&current);
	if (!conf) { error = "Love Joint is not a PulleyJoint"; return false; }
	value = static_cast<float>(pr::Real{pr::GetMagnitude(
		pd::GetWorldPoint(world, conf->bodyA, conf->localAnchorA) - conf->groundAnchorA) / pr::Meter})
		* _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getPulleyJointLengthB(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PulleyJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::PulleyJointConf>(&current);
	if (!conf) { error = "Love Joint is not a PulleyJoint"; return false; }
	value = static_cast<float>(pr::Real{pr::GetMagnitude(
		pd::GetWorldPoint(world, conf->bodyB, conf->localAnchorB) - conf->groundAnchorB) / pr::Meter})
		* _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getPulleyJointRatio(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "PulleyJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::PulleyJointConf>(&current);
	if (!conf) { error = "Love Joint is not a PulleyJoint"; return false; }
	value = static_cast<float>(conf->ratio);
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newWheelJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float x1, float y1, float x2, float y2, float axisX, float axisY,
	bool collideConnected, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love WheelJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love WheelJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto bodyAId = a->second.body->getPrBody();
	const auto bodyBId = b->second.body->getPrBody();
	const pr::Length2 worldA{x1 / _physicsMeter * pr::Meter, y1 / _physicsMeter * pr::Meter};
	const pr::Length2 worldB{x2 / _physicsMeter * pr::Meter, y2 / _physicsMeter * pr::Meter};
	const auto worldAxis = pd::UnitVec::Get(axisX, axisY, pd::UnitVec::GetRight()).first;
	auto conf = pd::GetWheelJointConf(world, bodyAId, bodyBId, worldA, worldAxis);
	conf.localAnchorB = pd::GetLocalPoint(world, bodyBId, worldB);
	conf.UseCollideConnected(collideConnected);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world, conf);
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love WheelJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB});
	error.clear(); return handle;
}

bool LoveNode::getWheelJointTranslation(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "WheelJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	if (!pd::TypeCast<pd::WheelJointConf>(&current))
	{ error = "Love Joint is not a WheelJoint"; return false; }
	value = static_cast<float>(pr::Real{pd::GetJointTranslation(
		world, found->second.joint->getPrJoint()) / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::getWheelJointSpeed(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "WheelJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::WheelJointConf>(&current);
	if (!conf) { error = "Love Joint is not a WheelJoint"; return false; }
	// Love 11.5 scales b2WheelJoint's relative angular speed through scaleUp.
	value = static_cast<float>(pr::Real{pd::GetAngularVelocity(world, *conf)
		/ pr::RadianPerSecond}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::isWheelJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
	bool &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint());
	if (!pd::TypeCast<pd::WheelJointConf>(&current)) { error = "Love Joint is not a WheelJoint"; return false; }
	value = pd::IsMotorEnabled(current); error.clear(); return true;
}

bool LoveNode::setWheelJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
	bool value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld(); auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	if (!pd::TypeCast<pd::WheelJointConf>(&current)) { error = "Love Joint is not a WheelJoint"; return false; }
	pd::EnableMotor(current, value); pd::SetJoint(world, found->second.joint->getPrJoint(), current); error.clear(); return true;
}

bool LoveNode::getWheelJointMotorSpeed(Love::PhysicsBackend::JointHandle joint, float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint()); const auto *conf = pd::TypeCast<pd::WheelJointConf>(&current); if (!conf) { error = "Love Joint is not a WheelJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->motorSpeed / pr::RadianPerSecond}); error.clear(); return true;
}

bool LoveNode::setWheelJointMotorSpeed(Love::PhysicsBackend::JointHandle joint, float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld(); auto current = pd::GetJoint(world, found->second.joint->getPrJoint()); if (!pd::TypeCast<pd::WheelJointConf>(&current)) { error = "Love Joint is not a WheelJoint"; return false; }
	pd::SetMotorSpeed(current, value * pr::RadianPerSecond); pd::SetJoint(world, found->second.joint->getPrJoint(), current); error.clear(); return true;
}

bool LoveNode::getWheelJointMaxMotorTorque(Love::PhysicsBackend::JointHandle joint, float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint()); const auto *conf = pd::TypeCast<pd::WheelJointConf>(&current); if (!conf) { error = "Love Joint is not a WheelJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->maxMotorTorque / pr::NewtonMeter}) * _physicsMeter * _physicsMeter; error.clear(); return true;
}

bool LoveNode::setWheelJointMaxMotorTorque(Love::PhysicsBackend::JointHandle joint, float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld(); auto current = pd::GetJoint(world, found->second.joint->getPrJoint()); if (!pd::TypeCast<pd::WheelJointConf>(&current)) { error = "Love Joint is not a WheelJoint"; return false; }
	pd::SetMaxMotorTorque(current, value / (_physicsMeter * _physicsMeter) * pr::NewtonMeter); pd::SetJoint(world, found->second.joint->getPrJoint(), current); error.clear(); return true;
}

bool LoveNode::getWheelJointMotorTorque(Love::PhysicsBackend::JointHandle joint, float inverseDeltaTime, float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld(); const auto current = pd::GetJoint(world, found->second.joint->getPrJoint()); if (!pd::TypeCast<pd::WheelJointConf>(&current)) { error = "Love Joint is not a WheelJoint"; return false; }
	value = static_cast<float>(pr::Real{pd::GetMotorTorque(world, found->second.joint->getPrJoint(), inverseDeltaTime * pr::Hertz) / pr::NewtonMeter}) * _physicsMeter * _physicsMeter; error.clear(); return true;
}

bool LoveNode::getWheelJointSpringFrequency(Love::PhysicsBackend::JointHandle joint, float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint()); const auto *conf = pd::TypeCast<pd::WheelJointConf>(&current); if (!conf) { error = "Love Joint is not a WheelJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->frequency / pr::Hertz}); error.clear(); return true;
}

bool LoveNode::setWheelJointSpringFrequency(Love::PhysicsBackend::JointHandle joint, float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld(); auto current = pd::GetJoint(world, found->second.joint->getPrJoint()); if (!pd::TypeCast<pd::WheelJointConf>(&current)) { error = "Love Joint is not a WheelJoint"; return false; }
	pd::SetFrequency(current, value * pr::Hertz); pd::SetJoint(world, found->second.joint->getPrJoint(), current); error.clear(); return true;
}

bool LoveNode::getWheelJointSpringDampingRatio(Love::PhysicsBackend::JointHandle joint, float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(), found->second.joint->getPrJoint()); const auto *conf = pd::TypeCast<pd::WheelJointConf>(&current); if (!conf) { error = "Love Joint is not a WheelJoint"; return false; }
	value = static_cast<float>(conf->dampingRatio); error.clear(); return true;
}

bool LoveNode::setWheelJointSpringDampingRatio(Love::PhysicsBackend::JointHandle joint, float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld(); const auto current = pd::GetJoint(world, found->second.joint->getPrJoint()); const auto *source = pd::TypeCast<pd::WheelJointConf>(&current); if (!source) { error = "Love Joint is not a WheelJoint"; return false; }
	auto conf = *source; conf.UseDampingRatio(value); pd::SetJoint(world, found->second.joint->getPrJoint(), conf); error.clear(); return true;
}

bool LoveNode::getWheelJointAxis(Love::PhysicsBackend::JointHandle joint, float &x, float &y, std::string &error) const
{
	const auto found = _physicsJoints.find(joint); if (found == _physicsJoints.end() || !found->second.joint || !found->second.joint->getPhysicsWorld() || !found->second.joint->getPhysicsWorld()->getPrWorld()) { error = "WheelJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld(); const auto current = pd::GetJoint(world, found->second.joint->getPrJoint()); const auto *conf = pd::TypeCast<pd::WheelJointConf>(&current); if (!conf) { error = "Love Joint is not a WheelJoint"; return false; }
	const auto axis = pd::GetWorldVector(world, conf->bodyA, conf->localXAxisA); x = static_cast<float>(axis[0]); y = static_cast<float>(axis[1]); error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newMouseJoint(
	Love::PhysicsBackend::BodyHandle body, float x, float y, std::string &error)
{
	const auto found = _physicsBodies.find(body);
	if (found == _physicsBodies.end() || !found->second.body)
	{ error = "Love MouseJoint Body is closed"; return 0; }
	const auto worldFound = _physicsWorlds.find(found->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love MouseJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto bodyId = found->second.body->getPrBody();
	if (pd::GetType(world, bodyId) == pr::BodyType::Kinematic)
	{ error = "Cannot create a MouseJoint for a kinematic Body"; return 0; }
	const pr::Length2 target{x / _physicsMeter * pr::Meter, y / _physicsMeter * pr::Meter};
	const auto mass = pd::GetMass(world, bodyId);
	auto conf = pd::TargetJointConf{bodyId}
		.UseTarget(target)
		.UseAnchor(pd::GetLocalPoint(world, bodyId, target))
		.UseMaxForce(static_cast<pr::Real>(1000) * mass * pr::MeterPerSquareSecond
			/ _physicsMeter);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world, conf);
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love MouseJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	// Love exposes the dragged body as bodyA even though TargetJoint stores it as bodyB.
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), found->second.world, body, 0});
	error.clear(); return handle;
}

bool LoveNode::getMouseJointTarget(Love::PhysicsBackend::JointHandle joint,
	float &x, float &y, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MouseJoint is closed"; return false; }
	const auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::TargetJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MouseJoint"; return false; }
	x = static_cast<float>(pr::Real{pr::GetX(conf->target) / pr::Meter}) * _physicsMeter;
	y = static_cast<float>(pr::Real{pr::GetY(conf->target) / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setMouseJointTarget(Love::PhysicsBackend::JointHandle joint,
	float x, float y, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MouseJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	if (!pd::TypeCast<pd::TargetJointConf>(&current))
	{ error = "Love Joint is not a MouseJoint"; return false; }
	pd::SetTarget(current, pr::Length2{x / _physicsMeter * pr::Meter,
		y / _physicsMeter * pr::Meter});
	pd::SetJoint(world, found->second.joint->getPrJoint(), current);
	error.clear(); return true;
}

bool LoveNode::getMouseJointMaxForce(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MouseJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::TargetJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MouseJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->maxForce / pr::Newton}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setMouseJointMaxForce(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MouseJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::TargetJointConf>(&current);
	if (!source) { error = "Love Joint is not a MouseJoint"; return false; }
	auto conf = *source; conf.UseMaxForce(value / _physicsMeter * pr::Newton);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

bool LoveNode::getMouseJointFrequency(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MouseJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::TargetJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MouseJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->frequency / pr::Hertz});
	error.clear(); return true;
}

bool LoveNode::setMouseJointFrequency(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MouseJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	if (!pd::TypeCast<pd::TargetJointConf>(&current))
	{ error = "Love Joint is not a MouseJoint"; return false; }
	pd::SetFrequency(current, value * pr::Hertz);
	pd::SetJoint(world, found->second.joint->getPrJoint(), current);
	error.clear(); return true;
}

bool LoveNode::getMouseJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MouseJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::TargetJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MouseJoint"; return false; }
	value = static_cast<float>(conf->dampingRatio);
	error.clear(); return true;
}

bool LoveNode::setMouseJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MouseJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::TargetJointConf>(&current);
	if (!source) { error = "Love Joint is not a MouseJoint"; return false; }
	auto conf = *source; conf.UseDampingRatio(value);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newMotorJoint(
	Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
	float correctionFactor, bool collideConnected, std::string &error)
{
	const auto a = _physicsBodies.find(bodyA); const auto b = _physicsBodies.find(bodyB);
	if (a == _physicsBodies.end() || b == _physicsBodies.end() || !a->second.body || !b->second.body
		|| a->second.world != b->second.world)
	{ error = "Love MotorJoint Bodies must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love MotorJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	auto conf = pd::GetMotorJointConf(world, a->second.body->getPrBody(), b->second.body->getPrBody());
	conf.UseCorrectionFactor(correctionFactor).UseCollideConnected(collideConnected);
	Joint *joint = Joint::create();
	joint->_world = worldFound->second.world;
	joint->_joint = pd::CreateJoint(world, conf);
	if (!pr::IsValid(joint->_joint))
	{ error = "Dora PlayRho failed to create Love MotorJoint"; return 0; }
	worldFound->second.world->setJointData(joint->_joint, joint);
	const auto handle = _nextPhysicsJointHandle++;
	_physicsJoints.emplace(handle, PhysicsJointResource{
		Ref<Joint>(joint), a->second.world, bodyA, bodyB});
	error.clear(); return handle;
}

bool LoveNode::getMotorJointLinearOffset(Love::PhysicsBackend::JointHandle joint,
	float &x, float &y, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MotorJoint"; return false; }
	x = static_cast<float>(pr::Real{pr::GetX(conf->linearOffset) / pr::Meter}) * _physicsMeter;
	y = static_cast<float>(pr::Real{pr::GetY(conf->linearOffset) / pr::Meter}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setMotorJointLinearOffset(Love::PhysicsBackend::JointHandle joint,
	float x, float y, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!source) { error = "Love Joint is not a MotorJoint"; return false; }
	auto conf = *source;
	conf.UseLinearOffset(pr::Length2{x / _physicsMeter * pr::Meter,
		y / _physicsMeter * pr::Meter});
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

bool LoveNode::getMotorJointAngularOffset(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MotorJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->angularOffset / pr::Radian});
	error.clear(); return true;
}

bool LoveNode::setMotorJointAngularOffset(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!source) { error = "Love Joint is not a MotorJoint"; return false; }
	auto conf = *source; conf.UseAngularOffset(value * pr::Radian);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

bool LoveNode::getMotorJointMaxForce(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MotorJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->maxForce / pr::Newton}) * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setMotorJointMaxForce(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!source) { error = "Love Joint is not a MotorJoint"; return false; }
	auto conf = *source; conf.UseMaxForce(value / _physicsMeter * pr::Newton);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

bool LoveNode::getMotorJointMaxTorque(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MotorJoint"; return false; }
	value = static_cast<float>(pr::Real{conf->maxTorque / pr::NewtonMeter})
		* _physicsMeter * _physicsMeter;
	error.clear(); return true;
}

bool LoveNode::setMotorJointMaxTorque(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!source) { error = "Love Joint is not a MotorJoint"; return false; }
	auto conf = *source;
	conf.UseMaxTorque(value / (_physicsMeter * _physicsMeter) * pr::NewtonMeter);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

bool LoveNode::getMotorJointCorrectionFactor(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!conf) { error = "Love Joint is not a MotorJoint"; return false; }
	value = static_cast<float>(conf->correctionFactor);
	error.clear(); return true;
}

bool LoveNode::setMotorJointCorrectionFactor(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "MotorJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::MotorJointConf>(&current);
	if (!source) { error = "Love Joint is not a MotorJoint"; return false; }
	auto conf = *source; conf.UseCorrectionFactor(value);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

Love::PhysicsBackend::JointHandle LoveNode::newGearJoint(
	Love::PhysicsBackend::JointHandle jointA, Love::PhysicsBackend::JointHandle jointB,
	float ratio, bool collideConnected, std::string &error)
{
	const auto a = _physicsJoints.find(jointA); const auto b = _physicsJoints.find(jointB);
	if (a == _physicsJoints.end() || b == _physicsJoints.end() || !a->second.joint
		|| !b->second.joint || a->second.world != b->second.world)
	{ error = "Love GearJoint source Joints must be live and share one World"; return 0; }
	const auto worldFound = _physicsWorlds.find(a->second.world);
	if (worldFound == _physicsWorlds.end() || !worldFound->second.world
		|| !worldFound->second.world->getPrWorld())
	{ error = "Love GearJoint World is closed"; return 0; }
	auto &world = *worldFound->second.world->getPrWorld();
	const auto sourceA = pd::GetJoint(world, a->second.joint->getPrJoint());
	const auto sourceB = pd::GetJoint(world, b->second.joint->getPrJoint());
	const bool validA = pd::TypeCast<pd::RevoluteJointConf>(&sourceA)
		|| pd::TypeCast<pd::PrismaticJointConf>(&sourceA);
	const bool validB = pd::TypeCast<pd::RevoluteJointConf>(&sourceB)
		|| pd::TypeCast<pd::PrismaticJointConf>(&sourceB);
	if (!validA || !validB)
	{ error = "GearJoint source Joints must be RevoluteJoint or PrismaticJoint"; return 0; }
	try
	{
		auto conf = pd::GetGearJointConf(world, a->second.joint->getPrJoint(),
			b->second.joint->getPrJoint(), ratio);
		conf.UseCollideConnected(collideConnected);
		Joint *joint = Joint::create();
		joint->_world = worldFound->second.world;
		joint->_joint = pd::CreateJoint(world, conf);
		if (!pr::IsValid(joint->_joint))
		{ error = "Dora PlayRho failed to create Love GearJoint"; return 0; }
		worldFound->second.world->setJointData(joint->_joint, joint);
		const auto handle = _nextPhysicsJointHandle++;
		_physicsJoints.emplace(handle, PhysicsJointResource{Ref<Joint>(joint), a->second.world,
			a->second.bodyB, b->second.bodyB, jointA, jointB});
		error.clear(); return handle;
	}
	catch (const std::exception &exception)
	{
		error = std::string{"failed to create Love GearJoint: "} + exception.what();
		return 0;
	}
}

bool LoveNode::getGearJointRatio(Love::PhysicsBackend::JointHandle joint,
	float &value, std::string &error) const
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "GearJoint is closed"; return false; }
	const auto current = pd::GetJoint(*found->second.joint->getPhysicsWorld()->getPrWorld(),
		found->second.joint->getPrJoint());
	const auto *conf = pd::TypeCast<pd::GearJointConf>(&current);
	if (!conf) { error = "Love Joint is not a GearJoint"; return false; }
	value = static_cast<float>(pd::GetRatio(*conf)); error.clear(); return true;
}

bool LoveNode::setGearJointRatio(Love::PhysicsBackend::JointHandle joint,
	float value, std::string &error)
{
	const auto found = _physicsJoints.find(joint);
	if (found == _physicsJoints.end() || !found->second.joint
		|| !found->second.joint->getPhysicsWorld()
		|| !found->second.joint->getPhysicsWorld()->getPrWorld())
	{ error = "GearJoint is closed"; return false; }
	auto &world = *found->second.joint->getPhysicsWorld()->getPrWorld();
	const auto current = pd::GetJoint(world, found->second.joint->getPrJoint());
	const auto *source = pd::TypeCast<pd::GearJointConf>(&current);
	if (!source) { error = "Love Joint is not a GearJoint"; return false; }
	auto conf = *source; pd::SetRatio(conf, value);
	pd::SetJoint(world, found->second.joint->getPrJoint(), conf);
	error.clear(); return true;
}

NS_DORA_END

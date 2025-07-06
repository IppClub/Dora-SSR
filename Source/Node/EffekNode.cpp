/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/EffekNode.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Cache/TextureCache.h"
#include "Common/Async.h"
#include "Render/Camera.h"
#include "Render/RenderTarget.h"
#include "Render/Renderer.h"
#include "Render/View.h"
#include "Basic/Scheduler.h"
#include "Shader/Builtin.h"

#include "bgfxrenderer.h"

#include <sstream>

#define MAX_PATH 2048

NS_DORA_BEGIN

class EffekEff : public Object {
public:
	Effekseer::EffectRef effect;
	CREATE_FUNC_NOT_NULL(EffekEff);

protected:
	EffekEff() { }
};

EffekNode::RunningEff::RunningEff(int handle, const Vec3& position, EffekEff* eff)
	: handle(handle)
	, position(position)
	, eff(eff) { }

class DoraFileReader : public Effekseer::FileReader {
public:
	DoraFileReader() = default;

	virtual ~DoraFileReader() override = default;

	virtual size_t Read(void* buffer, size_t size) override {
		stream.read(r_cast<char*>(buffer), size);
		_position = stream.tellp();
		return size;
	}

	virtual void Seek(int position) override {
		stream.seekp(position);
		_position = position;
	}

	virtual int GetPosition() const override {
		return _position;
	}

	virtual size_t GetLength() const override {
		return length;
	}

	std::stringstream stream;
	size_t length = 0;

private:
	int _position = 0;
};

class DoraFileInterface : public Effekseer::FileInterface {
public:
	DoraFileInterface() = default;
	virtual ~DoraFileInterface() override = default;

	virtual Effekseer::FileReaderRef OpenRead(const char16_t* path) override {
		char path8[MAX_PATH];
		Effekseer::ConvertUtf16ToUtf8(path8, MAX_PATH, path);
		auto buffer = SharedContent.load(path8);
		if (buffer.second > 0) {
			auto file = Effekseer::MakeRefPtr<DoraFileReader>();
			file->stream << std::string_view{r_cast<char*>(buffer.first.get()), s_cast<size_t>(buffer.second)};
			file->length = s_cast<size_t>(buffer.second);
			return file;
		}
		return nullptr;
	}

	virtual Effekseer::FileWriterRef OpenWrite(const char16_t* path) override {
		DORA_UNUSED_PARAM(path);
		return nullptr;
	}
};

class EffekInstance {
public:
	EffekseerRenderer::RendererRef efkRenderer = nullptr;
	Effekseer::ManagerRef efkManager = nullptr;
};

void EffekManager::EffekInstanceDeleter::operator()(EffekInstance* ptr) const { delete ptr; }

/* EffekNode */

static void MtoM44(const Matrix& m, Effekseer::Matrix44& m44) {
	for (int i = 0; i < 4; ++i) {
		std::memcpy(m44.Values[i], &m.m[i * 4], sizeof(m.m[0]) * 4);
	}
}

static void MtoM43(const Matrix& m, Effekseer::Matrix43& m43) {
	for (int i = 0; i < 4; ++i) {
		std::memcpy(m43.Value[i], &m.m[i * 4], sizeof(m.m[0]) * 3);
	}
}

bool EffekNode::init() {
	if (!Node::init()) return false;
	scheduleUpdate();
	return true;
}

bool EffekNode::update(double deltaTime) {
	if (!_effeks.empty()) {
		auto instance = SharedEffekManager.instance->efkManager.Get();
		auto it = std::remove_if(_effeks.begin(), _effeks.end(), [&](const Own<RunningEff>& effek) {
			return !instance->Exists(effek->handle);
		});
		if (it != _effeks.end()) {
			for (auto tmpIt = it; tmpIt != _effeks.end(); ++tmpIt) {
				EventArgs<int> event("EffekEnd"_slice, tmpIt->get()->handle);
				emit(&event);
			}
			_effeks.erase(it, _effeks.end());
		}
	}
	return Node::update(deltaTime);
}

void EffekNode::render() {
	if (_effeks.empty()) {
		Node::render();
		return;
	}

	SharedRendererManager.flush();

	auto instance = SharedEffekManager.instance.get();
	auto manager = instance->efkManager.Get();
	auto renderer = instance->efkRenderer.Get();
	EffekseerRendererBGFX::SetViewId(instance->efkRenderer, SharedView.getId());

	Effekseer::Matrix44 matrix;
	if (SharedDirector.getCurrentCamera()->hasProjection()) {
		renderer->SetProjectionMatrix(matrix.Indentity());
	} else {
		switch (bgfx::getCaps()->rendererType) {
			case bgfx::RendererType::OpenGL:
			case bgfx::RendererType::OpenGLES: {
				Matrix tempProj;
				Matrix revertY;
				bx::mtxScale(revertY.m, 1.0f, -1.0f, 1.0f);
				Matrix::mulMtx(tempProj, revertY, SharedView.getProjection());
				MtoM44(tempProj, matrix);
				break;
			}
			default:
				MtoM44(SharedView.getProjection(), matrix);
				break;
		}
		renderer->SetProjectionMatrix(matrix);
	}
	MtoM44(SharedDirector.getCurrentCamera()->getView(), matrix);
	renderer->SetCameraMatrix(matrix);

	Effekseer::Matrix43 mat43;
	MtoM43(getWorld(), mat43);

	Effekseer::Manager::DrawParameter drawParameter;
	drawParameter.ZNear = SharedView.getNearPlaneDistance();
	drawParameter.ZFar = SharedView.getFarPlaneDistance();
	drawParameter.ViewProjectionMatrix = renderer->GetCameraProjectionMatrix();

	renderer->BeginRendering();

	for (const auto& effek : _effeks) {
		auto handle = effek->handle;
		if (manager->Exists(handle)) {
			auto pos = effek->position;
			if (!SharedDirector.isFrustumCulling() || !manager->GetIsCulled(handle, drawParameter)) {
				manager->SetMatrix(handle, mat43);
				manager->AddLocation(handle, {pos.x, pos.y, pos.z});
				manager->DrawHandle(handle, drawParameter);
			}
		}
	}

	renderer->EndRendering();

	Node::render();
}

void EffekNode::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		auto manager = SharedEffekManager.instance->efkManager.Get();
		for (auto& effek : _effeks) {
			manager->StopEffect(effek->handle);
		}
		_effeks.clear();
		Node::cleanup();
	}
}

EffekNode::~EffekNode() {
	auto manager = SharedEffekManager.instance->efkManager.Get();
	for (const auto& effek : _effeks) {
		manager->StopEffect(effek->handle);
	}
}

int EffekNode::_runningNodes = 0;

int EffekNode::getRunningNodes() {
	return _runningNodes;
}

void EffekNode::onEnter() {
	_runningNodes++;
	Node::onEnter();
}

void EffekNode::onExit() {
	_runningNodes--;
	Node::onExit();
}

int EffekNode::play(String filename, const Vec2& pos, float z) {
	if (auto effect = SharedEffekManager.load(filename)) {
		int handle = SharedEffekManager.instance->efkManager->Play(effect->effect, pos.x, pos.y, z);
		_effeks.emplace_back(New<RunningEff>(handle, Vec3{pos.x, pos.y, z}, effect));
		return handle;
	}
	return -1;
}

void EffekNode::stop(int handle) {
	SharedEffekManager.instance->efkManager->StopEffect(handle);
}

/* EffekManager */

static const char* findShaderFile(const char* name, const char* type) {
#define CHECK_SHADER(_SHADERNAME, _VS, _FS) \
	if (strcmp(name, _SHADERNAME) == 0) { \
		if (strcmp(type, "vs") == 0) { \
			return _VS; \
		} \
		assert(strcmp(type, "fs") == 0); \
		return _FS; \
	}
	CHECK_SHADER("sprite_unlit",
		"sprite_unlit_vs",
		"model_unlit_ps");
	CHECK_SHADER("sprite_lit",
		"sprite_lit_vs",
		"model_lit_ps");
	CHECK_SHADER("sprite_distortion",
		"sprite_distortion_vs",
		"model_distortion_ps");
	CHECK_SHADER("sprite_adv_unlit",
		"ad_sprite_unlit_vs",
		"ad_model_unlit_ps");
	CHECK_SHADER("sprite_adv_lit",
		"ad_sprite_lit_vs",
		"ad_model_lit_ps");
	CHECK_SHADER("sprite_adv_distortion",
		"ad_sprite_distortion_vs",
		"ad_model_distortion_ps");

	CHECK_SHADER("model_unlit",
		"model_unlit_vs",
		"model_unlit_ps");
	CHECK_SHADER("model_lit",
		"model_lit_vs",
		"model_lit_ps");
	CHECK_SHADER("model_distortion",
		"model_distortion_vs",
		"model_distortion_ps");
	CHECK_SHADER("model_adv_unlit",
		"ad_model_unlit_vs",
		"ad_model_unlit_ps");
	CHECK_SHADER("model_adv_lit",
		"ad_model_lit_vs",
		"ad_model_lit_ps");
	CHECK_SHADER("model_adv_distortion",
		"ad_model_distortion_vs",
		"ad_model_distortion_ps");

	Issue("invalid shader name and type name");
	return nullptr;
}

static bgfx_shader_handle_t shaderLoad(const char* mat, const char* name, const char* type, void* ud) {
	AssertIf(mat, "Effekseer shader loading with user defined material \"{}\" is unsupported", mat);
	const char* shaderName = findShaderFile(name, type);
	bgfx::RendererType::Enum rendererType = bgfx::getRendererType();
	bgfx::ShaderHandle handle = bgfx::createEmbeddedShader(DoraShaders, rendererType, shaderName);
	bgfx::setName(handle, shaderName);
	return bgfx_shader_handle_t{handle.idx};
}

static bgfx_texture_handle_t textureGet(int texture_type, void* parm, void* ud) {
	if (auto renderTarget = RenderTarget::getCurrent()) {
		if (texture_type == TEXTURE_BACKGROUND) {
			return {renderTarget->getTexture()->getHandle().idx};
		}
		if (texture_type == TEXTURE_DEPTH) {
			return {renderTarget->getDepthTexture()->getHandle().idx};
		}
	}
	return BGFX_INVALID_HANDLE;
}

static int textureLoad(const char* name, int srgb, void* ud) {
	DORA_UNUSED_PARAM(srgb);
	Texture2D* texture = SharedTextureCache.load(name);
	if (texture) {
		bgfx::setName(texture->getHandle(), name);
		int texId = s_cast<int>(texture->getHandle().idx);
		auto manager = r_cast<EffekManager*>(ud);
		manager->addTexture(texId, texture);
		return texId;
	}
	return -1;
}

static void textureUnload(int texId, void* ud) {
	auto manager = r_cast<EffekManager*>(ud);
	manager->removeTexture(texId);
}

static bgfx_texture_handle_t textureHandle(int texId, void* ud) {
	DORA_UNUSED_PARAM(ud);
	return {uint16_t(s_cast<uint32_t>(texId) & 0xffff)};
}

EffekManager::EffekManager() {
	instance = New<EffekInstance, EffekInstanceDeleter>();
	auto inter = bgfx_get_interface(BGFX_API_VERSION);
	const bool invertZ = false;
	EffekseerRendererBGFX::InitArgs efkArgs{
		2048,
		0,
		inter,
		shaderLoad,
		textureGet,
		textureLoad,
		textureUnload,
		textureHandle,
		this,
		invertZ,
	};
	instance->efkRenderer = EffekseerRendererBGFX::CreateRenderer(&efkArgs);
	instance->efkManager = Effekseer::Manager::Create(8000);
	instance->efkManager->GetSetting()->SetCoordinateSystem(Effekseer::CoordinateSystem::LH);
	auto fileInterface = Effekseer::MakeRefPtr<DoraFileInterface>();
	instance->efkManager->SetModelRenderer(CreateModelRenderer(instance->efkRenderer, &efkArgs));
	instance->efkManager->SetSpriteRenderer(instance->efkRenderer->CreateSpriteRenderer());
	instance->efkManager->SetRibbonRenderer(instance->efkRenderer->CreateRibbonRenderer());
	instance->efkManager->SetRingRenderer(instance->efkRenderer->CreateRingRenderer());
	instance->efkManager->SetTrackRenderer(instance->efkRenderer->CreateTrackRenderer());
	instance->efkManager->SetTextureLoader(instance->efkRenderer->CreateTextureLoader());
	instance->efkManager->SetModelLoader(instance->efkRenderer->CreateModelLoader(fileInterface));
	instance->efkManager->SetMaterialLoader(instance->efkRenderer->CreateMaterialLoader(fileInterface));
	instance->efkManager->SetCurveLoader(Effekseer::MakeRefPtr<Effekseer::CurveLoader>(fileInterface));
	instance->efkManager->SetEffectLoader(Effekseer::Effect::CreateEffectLoader(fileInterface));

	SharedDirector.getSystemScheduler()->schedule([](double) {
		if (Singleton<EffekManager>::isInitialized()) {
			SharedEffekManager.update();
		}
		return false;
	});
}

EffekManager::~EffekManager() {
	_effects.clear();
	instance = nullptr;
}

void EffekManager::addTexture(int texId, Texture2D* tex) {
	_textureRefs[texId] = tex;
}

void EffekManager::removeTexture(int texId) {
	_textureRefs.erase(texId);
}

EffekEff* EffekManager::load(String filename) {
	auto filenameStr = SharedContent.getFullPath(filename);
	auto it = _effects.find(filenameStr);
	if (it != _effects.end()) {
		return it->second;
	}
	if (!SharedContent.exist(filenameStr)) {
		Warn("failed to find Effekseer file \"{}\"", filename.toString());
		return nullptr;
	}
	char16_t path16[MAX_PATH];
	Effekseer::ConvertUtf8ToUtf16(path16, MAX_PATH, filenameStr.c_str());
	auto eff = Effekseer::Effect::Create(instance->efkManager, path16);
	auto effekEff = EffekEff::create();
	effekEff->effect = eff;
	_effects[filenameStr] = effekEff;
	return effekEff;
}

bool EffekManager::unload() {
	if (_effects.empty()) {
		return false;
	}
	_effects.clear();
	return true;
}

void EffekManager::unloadUnused() {
	std::vector<StringMap<Ref<EffekEff>>::iterator> targets;
	for (auto it = _effects.begin(); it != _effects.end(); ++it) {
		if (it->second->isSingleReferenced()) {
			targets.push_back(it);
		}
	}
	for (const auto& it : targets) {
		_effects.erase(it);
	}
}

void EffekManager::update() {
	instance->efkManager->Update();
}

NS_DORA_END

/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Director.h"

#include "Audio/Audio.h"
#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Scheduler.h"
#include "Cache/FontCache.h"
#include "Effect/Effect.h"
#include "Entity/Entity.h"
#include "Event/Listener.h"
#include "GUI/ImGuiDora.h"
#include "Http/HttpServer.h"
#include "Input/Controller.h"
#include "Input/Keyboard.h"
#include "Input/TouchDispather.h"
#include "Node/Node.h"
#include "Render/Camera.h"
#include "Render/Renderer.h"
#include "Render/VGRender.h"
#include "Render/View.h"

#include "bx/timer.h"

#include "SDL.h"

#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"

#ifndef DORA_NO_RUST
extern "C" int32_t dora_rust_init();
#endif // DORA_NO_RUST

NS_DORA_BEGIN

Director::Director()
	: _systemScheduler(Scheduler::create())
	, _scheduler(Scheduler::create())
	, _postScheduler(Scheduler::create())
	, _camStack(Array::create())
	, _clearColor(0xff1a1a1a)
	, _nvgDirty(false)
	, _paused(false)
	, _stoped(false)
	, _frustumCulling(true)
	, _nvgContext(nullptr) { }

Director::~Director() {
	cleanup();
}

void Director::setScheduler(Scheduler* scheduler) {
	_scheduler = scheduler ? scheduler : Scheduler::create();
}

Scheduler* Director::getScheduler() const noexcept {
	return _scheduler;
}

Node* Director::getUI() {
	if (!_ui) {
		_ui = Node::create(false);
		_ui->onEnter();
		_uiCamera = CameraUI::create("UI"_slice);
	}
	return _ui;
}

Node* Director::getUI3D() {
	if (!_ui3D) {
		_ui3D = Node::create(false);
		_ui3D->onEnter();
		_ui3DCamera = CameraUI3D::create("UI3D"_slice);
	}
	return _ui3D;
}

Node* Director::getEntry() {
	if (!_entry) {
		_root = Node::create(false);
		_root->setAnchor(Vec2::zero);
		_root->onEnter();
		_entry = Node::create(false);
		_root->addChild(_entry);
		markDirty();
	}
	return _entry;
}

Node* Director::getPostNode() {
	if (!_postNode) {
		_postNode = Node::create(false);
		_postNode->onEnter();
	}
	return _postNode;
}

UITouchHandler* Director::getUITouchHandler() {
	if (!_uiTouchHandler) {
		_uiTouchHandler = New<UITouchHandler>();
	}
	return _uiTouchHandler.get();
}

void Director::setClearColor(Color var) {
	_clearColor = var;
}

Color Director::getClearColor() const noexcept {
	return _clearColor;
}

Scheduler* Director::getSystemScheduler() const noexcept {
	return _systemScheduler;
}

Scheduler* Director::getPostScheduler() const noexcept {
	return _postScheduler;
}

void Director::pushCamera(NotNull<Camera, 1> var) {
	Camera* lastCamera = getCurrentCamera();
	lastCamera->Updated -= std::make_pair(this, &Director::markDirty);
	var->Updated += std::make_pair(this, &Director::markDirty);
	_camStack->add(Value::alloc(var.get()));
	markDirty();
}

void Director::popCamera() {
	Camera* lastCamera = getCurrentCamera();
	lastCamera->Updated -= std::make_pair(this, &Director::markDirty);
	_camStack->removeLast();
	if (_camStack->isEmpty()) {
		_camStack->add(Value::alloc(Camera2D::create("Default"_slice)));
	}
	getCurrentCamera()->Updated += std::make_pair(this, &Director::markDirty);
	markDirty();
}

bool Director::removeCamera(NotNull<Camera, 1> camera) {
	Camera* lastCamera = getCurrentCamera();
	if (camera == lastCamera) {
		popCamera();
		return true;
	} else {
		auto cam = Value::alloc(camera.get());
		return _camStack->remove(cam.get());
	}
}

void Director::clearCamera() {
	Camera* lastCamera = getCurrentCamera();
	lastCamera->Updated -= std::make_pair(this, &Director::markDirty);
	_camStack->clear();
	markDirty();
}

Camera* Director::getCurrentCamera() {
	if (_camStack->isEmpty()) {
		Camera* defaultCamera = Camera2D::create("Default"_slice);
		defaultCamera->Updated += std::make_pair(this, &Director::markDirty);
		_camStack->add(Value::alloc(defaultCamera));
	}
	return _camStack->getLast()->to<Camera>();
}

const Matrix& Director::getCurrentViewProjection() {
	Camera* camera = getCurrentCamera();
	if (camera->hasProjection()) {
		_currentViewProj = camera->getView();
	} else {
		Matrix::mulMtx(_currentViewProj, SharedView.getProjection(), camera->getView());
	}
	return _currentViewProj;
}

const Matrix& Director::getViewProjection() {
	if (_viewProjs.empty()) {
		return getCurrentViewProjection();
	}
	return _viewProjs.top()->matrix;
}

static bool registerTouchHandler(Node* target) {
	if (target && SharedTouchDispatcher.hasEvents()) {
		target->traverseVisible([](Node* node) {
			if (node->isTouchEnabled()) {
				SharedTouchDispatcher.add(node->getTouchHandler()->ref());
			}
			return false;
		});
		return true;
	}
	return false;
}

bool Director::init() {
	_profilerInfo.init();
	SharedView.reset();
	if (!SharedImGui.init()) {
		Error("failed to initialize ImGui.");
		return false;
	}
	if (!SharedKeyboard.init()) {
		Error("failed to initialize Keyboard.");
		return false;
	}
	if (!SharedAudio.init()) {
		Warn("audio function is not available.");
	}
#ifndef DORA_NO_RUST
	if (!dora_rust_init()) {
		Error("failed to initialize Rust runtime.");
		return false;
	}
#endif // DORA_NO_RUST
	if (!SharedContent.visitDir(SharedContent.getAssetPath(), [](String file, String path) {
			switch (Switch::hash(file.toLower())) {
				case "init.yue"_hash:
				case "init.tl"_hash:
				case "init.lua"_hash:
				case "init.wasm"_hash:
					SharedLuaEngine.executeModule(Path::concat({path, Path::getName(file.toString())}));
					return true;
			}
			return false;
		})) {
		Info("Dora SSR started without script entry.");
	}
	return true;
}

void Director::handleTouchEvents() {
	/* handle ImGui touch */
	SharedTouchDispatcher.add(SharedImGui.getTarget()->getTouchHandler()->ref());
	SharedTouchDispatcher.dispatch();

	/* handle ui touch */
	if (registerTouchHandler(_ui)) {
		pushViewProjection(_uiCamera->getView(), []() {
			SharedTouchDispatcher.dispatch();
		});
	}

	/* handle ui3D touch */
	if (registerTouchHandler(_ui3D)) {
		pushViewProjection(_ui3DCamera->getView(), []() {
			SharedTouchDispatcher.dispatch();
		});
	}

	/* handle post node touch */
	if (registerTouchHandler(_postNode)) {
		SharedTouchDispatcher.dispatch();
	}

	/* handle scene tree touch */
	if (registerTouchHandler(_entry)) {
		SharedTouchDispatcher.dispatch();
	}

	SharedTouchDispatcher.clearEvents();
}

void Director::handleUnmanagedNodes() {
	if (!_unmanagedNodes.empty()) {
		RefVector<Node> nodes;
		for (Node* node : _unmanagedNodes) {
			if (node->isUnManaged()) {
				nodes.push_back(node);
			}
		}
		_unmanagedNodes.clear();
		for (Node* node : nodes) {
			getEntry()->addChild(node);
		}
	}
}

void Director::doLogic() {
	if (_stoped) return;

	double deltaTime = SharedApplication.getDeltaTime();

	_profilerInfo.update(deltaTime);

	/* update system logic */
	_systemScheduler->update(deltaTime);

	if (_paused) return;

	/* update game logic */
	SharedImGui.begin();

	handleTouchEvents();

	_scheduler->update(deltaTime);
	_postScheduler->update(deltaTime);

	handleUnmanagedNodes();
	Event::handlePostEvents();

	SharedKeyboard.clearChanges();
	SharedController.clearChanges();

	SharedImGui.end();
}

void Director::doRender() {
	if (_paused || _stoped) return;

	/* push default view projection */
	const auto& defaultViewProj = getCurrentViewProjection();

	/* push default view projection */
	pushViewProjection(defaultViewProj, [&]() {
		/* do render */
		if (SharedView.isPostProcessNeeded()) {
			/* initialize RT */
			if (_root) {
				auto grabber = _root->grab(1, 1);
				grabber->setBlendFunc({BlendFunc::One, BlendFunc::Zero});
				grabber->setEffect(SharedView.getPostEffect());
				grabber->setCamera(getCurrentCamera());
				grabber->setClearColor(_clearColor);
				Size viewSize = SharedView.getSize();
				float w = viewSize.width / 2.0f;
				float h = viewSize.height / 2.0f;
				grabber->setPos(0, 0, {-w, h});
				grabber->setPos(1, 0, {w, h});
				grabber->setPos(0, 1, {-w, -h});
				grabber->setPos(1, 1, {w, -h});
			}

			/* render RT, post node and ui node */
			SharedView.pushBack("Main"_slice, [&]() {
				bgfx::ViewId viewId = SharedView.getId();
				/* RT */
				if (_root) {
					bgfx::setViewClear(viewId, BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL);
					Size viewSize = SharedView.getSize();
					Matrix ortho;
					bx::mtxOrtho(ortho.m,
						0, viewSize.width, 0, viewSize.height,
						-1000.0f, 1000.0f, 0,
						bgfx::getCaps()->homogeneousDepth);
					pushViewProjection(ortho, [&]() {
						bgfx::setViewTransform(viewId, nullptr, getViewProjection().m);
						_root->visit();
						SharedRendererManager.flush();
					});
				} else {
					bgfx::setViewClear(viewId,
						BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
						_clearColor.toRGBA());
				}
				/* post node */
				if (_postNode) {
					bgfx::setViewTransform(viewId, nullptr, getViewProjection().m);
					_postNode->visit();
					SharedRendererManager.flush();
				}
				/* ui 3D node */
				if (_ui3D) {
					pushViewProjection(_ui3DCamera->getView(), [&]() {
						bgfx::setViewTransform(viewId, nullptr, getViewProjection().m);
						_ui3D->visit();
						SharedRendererManager.flush();
					});
				}
				/* ui node */
				if (_ui) {
					pushViewProjection(_uiCamera->getView(), [&]() {
						bgfx::setViewTransform(viewId, nullptr, getViewProjection().m);
						_ui->visit();
						SharedRendererManager.flush();
					});
				}
			});
		} else {
			/* release unused RT */
			if (_root) _root->grab(false);

			/* render scene tree and post node */
			SharedView.pushBack("Main"_slice, [&]() {
				bgfx::ViewId viewId = SharedView.getId();
				bgfx::setViewClear(viewId,
					BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
					_clearColor.toRGBA());
				bgfx::setViewTransform(viewId, nullptr, getViewProjection().m);
				/* scene tree */
				if (_root) _root->visit();
				/* post node */
				if (_postNode) _postNode->visit();
				SharedRendererManager.flush();
			});
			/* ui 3D node */
			if (_ui3D) {
				SharedView.pushBack("UI3D"_slice, [&]() {
					bgfx::ViewId viewId = SharedView.getId();
					pushViewProjection(_ui3DCamera->getView(), [&]() {
						bgfx::setViewTransform(viewId, nullptr, getViewProjection().m);
						_ui3D->visit();
						SharedRendererManager.flush();
					});
				});
			}
			/* render ui node */
			if (_ui) {
				SharedView.pushBack("UI"_slice, [&]() {
					bgfx::ViewId viewId = SharedView.getId();
					/* ui node */
					if (_ui) {
						pushViewProjection(_uiCamera->getView(), [&]() {
							bgfx::setViewTransform(viewId, nullptr, getViewProjection().m);
							_ui->visit();
							SharedRendererManager.flush();
						});
					}
				});
			}
		}

		/* render NanoVG */
		if (_nvgContext && _nvgDirty) {
			_nvgDirty = false;
			SharedView.pushBack("NanoVG"_slice, [&]() {
				nvgSetViewId(_nvgContext, SharedView.getId());
				nvgEndFrame(_nvgContext);
			});
		}

		/* render imgui */
		SharedImGui.render();

		/* remap view orders */
		auto [remap, num] = SharedView.getOrders();
		bgfx::setViewOrder(0, num, remap);
		SharedView.clear();

		if (_uiTouchHandler) {
			_uiTouchHandler->clear();
		}
	});
}

void Director::pushViewProjection(const Matrix& viewProj) {
	auto viewProject = New<ViewProject>();
	viewProject->matrix = viewProj;
	Matrix::toFrustum(viewProject->frustum, viewProj);
	_viewProjs.push(std::move(viewProject));
}

void Director::popViewProjection() {
	_viewProjs.pop();
}

void Director::cleanup() {
	if (!_unmanagedNodes.empty()) {
		for (Node* node : _unmanagedNodes) {
			node->cleanup();
		}
	}
	_unmanagedNodes.clear();
	if (!_waitingList.empty()) {
		for (Node* node : _waitingList) {
			if (node) {
				node->cleanup();
			}
		}
	}
	_waitingList.clear();
	if (_ui3D) {
		_ui3D->removeAllChildren();
		_ui3D->onExit();
		_ui3D->cleanup();
		_ui3D = nullptr;
		_ui3DCamera = nullptr;
	}
	if (_ui) {
		_ui->removeAllChildren();
		_ui->onExit();
		_ui->cleanup();
		_ui = nullptr;
		_uiCamera = nullptr;
	}
	if (_root) {
		_root->removeAllChildren();
		_root->onExit();
		_root->cleanup();
		_root = nullptr;
		_entry = nullptr;
	}
	if (_postNode) {
		_postNode->removeAllChildren();
		_postNode->onExit();
		_postNode->cleanup();
		_postNode = nullptr;
	}
	Event::handlePostEvents();
	if (_nvgContext) {
		nvgDelete(_nvgContext);
		_nvgContext = nullptr;
	}
	_camStack->clear();
}

void Director::addUnManagedNode(Node* node) {
	_unmanagedNodes.push_back(node);
}

void Director::addToWaitingList(Node* node) {
	WRef<Node> wref(node);
	_waitingList.push_back(wref);
}

void Director::removeFromWaitingList(Node* node) {
	_waitingList.erase(std::remove_if(_waitingList.begin(), _waitingList.end(), [node](const auto& wref) {
		return wref == node;
	}),
		_waitingList.end());
}

bool Director::isInFrustum(const AABB& aabb) const {
	if (_viewProjs.empty()) return false;
	return _viewProjs.top()->frustum.intersect(aabb);
}

bool Director::isFrustumCulling() const noexcept {
	return _frustumCulling;
}

void Director::setFrustumCulling(bool var) {
	_frustumCulling = var;
}

void Director::markDirty() {
	if (_ui) _ui->markDirty();
	if (_entry) {
		auto viewSize = SharedView.getSize();
		_root->setSize(viewSize);
	}
	if (_postNode) _postNode->markDirty();
}

NVGcontext* Director::markNVGDirty() {
	if (!_nvgContext) {
		_nvgContext = nvgCreate(1, 0);
		AssertUnless(_nvgContext, "failed to init NanoVG context!");
	}
	if (!_nvgDirty) {
		_nvgDirty = true;
		Size visualSize = SharedApplication.getVisualSize();
		float devicePixelRatio = SharedApplication.getDevicePixelRatio();
		nvgBeginFrame(_nvgContext, visualSize.width, visualSize.height, devicePixelRatio);
	}
	return _nvgContext;
}

void Director::handleSDLEvent(const SDL_Event& event) {
	switch (event.type) {
		// User-requested quit
		case SDL_QUIT:
			_stoped = true;
			Event::send("AppEvent"_slice, "Quit"s);
			cleanup();
			if (Singleton<HttpServer>::isInitialized()) {
				SharedHttpServer.stop();
			}
			if (Singleton<HttpClient>::isInitialized()) {
				SharedHttpClient.stop();
			}
			if (Singleton<AsyncThread>::isInitialized()) {
				SharedAsyncThread.cancel();
			}
			if (Singleton<WasmRuntime>::isInitialized()) {
				SharedWasmRuntime.clear();
			}
			break;
		// The application is being terminated by the OS.
		case SDL_APP_TERMINATING:
			Event::send("AppEvent"_slice, "Quit"s);
			break;
		// The application is low on memory, free memory if possible.
		case SDL_APP_LOWMEMORY:
			Event::send("AppEvent"_slice, "LowMemory"s);
			break;
		// The application is about to enter the background.
		case SDL_APP_WILLENTERBACKGROUND:
			_paused = true;
			Event::send("AppEvent"_slice, "WillEnterBackground"s);
			break;
		case SDL_APP_DIDENTERBACKGROUND:
			bgfx::reset(0, 0);
			Event::send("AppEvent"_slice, "DidEnterBackground"s);
			break;
		case SDL_APP_WILLENTERFOREGROUND:
			Event::send("AppEvent"_slice, "WillEnterForeground"s);
			break;
		case SDL_APP_DIDENTERFOREGROUND:
			_paused = false;
			SharedView.reset();
			Event::send("AppEvent"_slice, "DidEnterForeground"s);
			Event::send("AppChange"_slice, "Size"s);
			break;
		case SDL_WINDOWEVENT: {
			switch (event.window.event) {
				case SDL_WINDOWEVENT_HIDDEN:
					_paused = true;
					break;
				case SDL_WINDOWEVENT_SHOWN:
					_paused = false;
					break;
				case SDL_WINDOWEVENT_RESIZED:
				case SDL_WINDOWEVENT_SIZE_CHANGED:
					SharedView.reset();
					Event::send("AppChange"_slice, "Size"s);
					break;
				case SDL_WINDOWEVENT_MOVED:
					Event::send("AppChange"_slice, "Position"s);
					break;
			}
			break;
		}
		case SDL_MOUSEBUTTONDOWN:
		case SDL_FINGERDOWN:
			SharedKeyboard.handleEvent(event);
			[[fallthrough]];
		case SDL_MOUSEMOTION:
		case SDL_MOUSEBUTTONUP:
		case SDL_FINGERUP:
		case SDL_FINGERMOTION:
			SharedTouchDispatcher.add(event);
			break;
		case SDL_MOUSEWHEEL:
			SharedTouchDispatcher.add(event);
			break;
		case SDL_MULTIGESTURE:
			SharedTouchDispatcher.add(event);
			break;
		case SDL_KEYDOWN:
		case SDL_KEYUP:
		case SDL_TEXTINPUT:
		case SDL_TEXTEDITING:
			SharedKeyboard.handleEvent(event);
			break;
		default:
			break;
	}
}

Director::ProfilerInfo* Director::getProfilerInfo() {
	return &_profilerInfo;
}

void Director::ProfilerInfo::init() {
	loaderCostListener = Listener::create(Profiler::EventName, [&](Event* e) {
		std::string name;
		if (e->getArgsCount() == 1) {
			if (e->get(name) && name == "ClearLoader"sv) {
				loaderCosts.clear();
				loaderTotalTime = 0;
				return;
			}
		}
		std::string msg;
		int level = 0;
		double cost = 0;
		if (!e->get(name, msg, level, cost)) {
			return;
		}
		if (name == "Loader"_slice) {
			const auto& assetPath = SharedContent.getAssetPath();
			auto relative = Path::getRelative(msg, assetPath);
			if (!relative.empty() && !relative.starts_with(".."sv)) {
				msg = Path::concat({"assets"_slice, relative});
			} else {
				const auto& writablePath = SharedContent.getWritablePath();
				auto relative = Path::getRelative(msg, writablePath);
				if (!relative.empty() && !relative.starts_with(".."sv)) {
					msg = relative;
				}
			}
			if (level == 0) loaderTotalTime += cost;
			loaderCosts.push_front({s_cast<int>(loaderCosts.size()),
				level,
				msg + '\t',
				cost,
				std::string(level, ' ') + std::to_string(level),
				fmt::format("{:.2f} ms", cost * 1000.0)});
			loaderCostDirty = true;
		}
		if (level == 0 && !timeCosts.insert({name, cost}).second) {
			timeCosts[name] += cost;
		}
	});
	const char* rendererNames[] = {
		"Noop", //!< No rendering.
		"Agc", //!< AGC
		"Direct3D11", //!< Direct3D 11.0
		"Direct3D12", //!< Direct3D 12.0
		"Gnm", //!< GNM
		"Metal", //!< Metal
		"Nvn", //!< NVN
		"OpenGLES", //!< OpenGL ES 2.0+
		"OpenGL", //!< OpenGL 2.1+
		"Vulkan", //!< Vulkan
	};
	renderer = rendererNames[bgfx::getCaps()->rendererType];
	multiThreaded = (bgfx::getCaps()->supported & BGFX_CAPS_RENDERER_MULTITHREADED) != 0;
}

void Director::ProfilerInfo::update(double deltaTime) {
	if (skipOneFrame) {
		skipOneFrame = false;
		return;
	}

	frames++;
	elapsedTime += deltaTime;

	cpuTime += SharedApplication.getCPUTime();
	gpuTime += SharedApplication.getGPUTime();

	maxCppObjects = std::max(maxCppObjects, Object::getCount());
	maxLuaObjects = std::max(maxLuaObjects, Object::getLuaRefCount());
	maxCallbacks = std::max(maxCallbacks, Object::getLuaCallbackCount());

	memPoolSize = std::max(MemoryPool::getTotalCapacity(), memPoolSize);
	memLua = std::max(SharedLuaEngine.getRuntimeMemory(), memLua);
	memTeal = std::max(SharedLuaEngine.getTealMemory(), memTeal);
	if (Singleton<WasmRuntime>::isInitialized()) {
		memWASM = std::max(s_cast<int>(SharedWasmRuntime.getMemorySize()), memWASM);
	}

	maxCPU = std::max(maxCPU, SharedApplication.getCPUTime());
	maxGPU = std::max(maxGPU, SharedApplication.getGPUTime());
	maxDelta = std::max(maxDelta, deltaTime);
	targetTime = 1000.0 / std::max(SharedApplication.getTargetFPS(), 1u);
	logicTime += SharedApplication.getLogicTime();
	renderTime += SharedApplication.getRenderTime();

	if (elapsedTime >= 1.0) {
		lastAvgCPUTime = 1000.0 * cpuTime / frames;
		lastAvgGPUTime = 1000.0 * gpuTime / frames;
		lastAvgDeltaTime = 1000.0 * elapsedTime / frames;
		cpuTime = gpuTime = 0.0;

		lastMaxCppObjects = maxCppObjects;
		lastMaxLuaObjects = maxLuaObjects;
		lastMaxCallbacks = maxCallbacks;
		maxCppObjects = maxLuaObjects = maxCallbacks = 0;

		lastMemPoolSize = memPoolSize;
		lastMemLua = memLua;
		lastMemTeal = memTeal;
		lastMemWASM = memWASM;
		memPoolSize = memLua = memTeal = memWASM = 0;

		cpuValues.push_back(maxCPU * 1000.0);
		gpuValues.push_back(maxGPU * 1000.0);
		dtValues.push_back(maxDelta * 1000.0);
		maxCPU = maxGPU = maxDelta = 0;

		if (cpuValues.size() > PlotCount + 1) cpuValues.erase(cpuValues.begin());
		if (gpuValues.size() > PlotCount + 1) gpuValues.erase(gpuValues.begin());
		if (dtValues.size() > PlotCount + 1) {
			dtValues.erase(dtValues.begin());
		} else {
			seconds.push_back(dtValues.size() - 1);
		}
		yLimit = 0;
		for (auto v : cpuValues) {
			if (v > yLimit) yLimit = v;
		}
		for (auto v : gpuValues) {
			if (v > yLimit) yLimit = v;
		}
		for (auto v : dtValues) {
			if (v > yLimit) yLimit = v;
		}
		updateCosts.clear();

		double time = 0;
		for (const auto& item : timeCosts) {
			time += item.second;
			double mx = std::max(0.0, item.second * 1000.0 / frames);
			updateCosts[item.first] = mx;
		}
		timeCosts.clear();
		double mx = std::max(0.0, (logicTime - time) * 1000.0 / frames);
		updateCosts["Logic"s] = mx;
		mx = std::max(0.0, renderTime * 1000.0 / frames);
		updateCosts["Render"s] = mx;
		logicTime = renderTime = 0;

		elapsedTime = 0.0;
		frames = 0;

		if (profilerSending && Event::hasListener("AppWS"sv)) {
			rapidjson::StringBuffer buf;
			rapidjson::Writer<rapidjson::StringBuffer> writer(buf);
			writer.SetMaxDecimalPlaces(2);
			writer.StartObject();
			writer.Key("name");
			writer.String("Profiler");
			writer.Key("info");
			writer.StartObject();
			writer.Key("renderer");
			writer.String(renderer);
			writer.Key("multiThreaded");
			writer.Bool(multiThreaded);
			{
				auto size = SharedView.getSize();
				writer.Key("backBufferX");
				writer.Int(s_cast<int>(size.width));
				writer.Key("backBufferY");
				writer.Int(s_cast<int>(size.height));
			}
			writer.Key("drawCall");
			writer.Int(s_cast<int>(bgfx::getStats()->numDraw));
			writer.Key("tri");
			writer.Int(s_cast<int>(bgfx::getStats()->numPrims[bgfx::Topology::TriStrip] + bgfx::getStats()->numPrims[bgfx::Topology::TriList]));
			writer.Key("line");
			writer.Int(s_cast<int>(bgfx::getStats()->numPrims[bgfx::Topology::LineStrip] + bgfx::getStats()->numPrims[bgfx::Topology::LineList]));
			{
				auto size = SharedApplication.getVisualSize();
				writer.Key("visualSizeX");
				writer.Int(s_cast<int>(size.width));
				writer.Key("visualSizeY");
				writer.Int(s_cast<int>(size.height));
			}
			writer.Key("vSync");
			writer.Bool(SharedView.isVSync());
			writer.Key("fpsLimited");
			writer.Bool(SharedApplication.isFPSLimited());
			writer.Key("targetFPS");
			writer.Int(SharedApplication.getTargetFPS());
			writer.Key("maxTargetFPS");
			writer.Int(SharedApplication.getMaxFPS());
			writer.Key("fixedFPS");
			writer.Int(SharedDirector.getScheduler()->getFixedFPS());
			writer.Key("currentFPS");
			writer.Double(lastAvgDeltaTime > 0 ? 1000.0 / lastAvgDeltaTime : 0);
			writer.Key("avgCPU");
			writer.Double(lastAvgCPUTime);
			writer.Key("avgGPU");
			writer.Double(lastAvgGPUTime);
			writer.Key("plotCount");
			writer.Int(PlotCount);
			writer.Key("cpuTimePeeks");
			writer.StartArray();
			for (auto v : cpuValues) {
				writer.Double(v);
			}
			writer.EndArray();
			writer.Key("gpuTimePeeks");
			writer.StartArray();
			for (auto v : gpuValues) {
				writer.Double(v);
			}
			writer.EndArray();
			writer.Key("deltaTimePeeks");
			writer.StartArray();
			for (auto v : dtValues) {
				writer.Double(v);
			}
			writer.EndArray();
			writer.Key("updateCosts");
			writer.StartArray();
			for (const auto& v : updateCosts) {
				writer.StartObject();
				writer.Key("name");
				writer.String(v.first.c_str(), v.first.size());
				writer.Key("value");
				writer.Double(v.second);
				writer.EndObject();
			}
			writer.EndArray();
			writer.Key("cppObject");
			writer.Int(lastMaxCppObjects);
			writer.Key("luaObject");
			writer.Int(lastMaxLuaObjects);
			writer.Key("luaCallback");
			writer.Int(lastMaxCallbacks);
			writer.Key("textures");
			writer.Int(Texture2D::getCount());
			writer.Key("fonts");
			writer.Int(TrueTypeFile::getCount());
			writer.Key("audios");
			writer.Int(AudioFile::getCount());

			writer.Key("memoryPool");
			writer.Int(lastMemPoolSize);
			writer.Key("luaMemory");
			writer.Int(lastMemLua);
			writer.Key("tealMemory");
			writer.Int(lastMemTeal);
			writer.Key("wasmMemory");
			writer.Int(lastMemWASM);
			writer.Key("textureMemory");
			writer.Int(Texture2D::getStorageSize());
			writer.Key("fontMemory");
			writer.Int(TrueTypeFile::getStorageSize());
			writer.Key("audioMemory");
			writer.Int(AudioFile::getStorageSize());

			if (loaderCostDirty) {
				loaderCostDirty = false;
				writer.Key("loaderCosts");
				writer.StartArray();
				for (const auto& item : loaderCosts) {
					writer.StartObject();
					writer.Key("order");
					writer.Int(item.order);
					writer.Key("time");
					writer.Double(item.time * 1000);
					writer.Key("depth");
					writer.Int(item.depth);
					writer.Key("moduleName");
					writer.String(item.moduleName.c_str(), item.moduleName.size());
					writer.EndObject();
				}
				writer.EndArray();
			}
			writer.EndObject();
			writer.EndObject();
			Event::send("AppWS"sv, "Send"s, std::string{buf.GetString(), buf.GetLength()});
		}
	}
}

void Director::ProfilerInfo::clearLoaderInfo() {
	loaderCosts.clear();
	loaderTotalTime = 0;
}

void Director::setProfilerSending(bool var) {
	_profilerInfo.profilerSending = var;
}

bool Director::isProfilerSending() const noexcept {
	return _profilerInfo.profilerSending;
}

NS_DORA_END

/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Director.h"

#include "Audio/Sound.h"
#include "Basic/Application.h"
#include "Basic/Camera.h"
#include "Basic/Content.h"
#include "Basic/RenderTarget.h"
#include "Basic/Renderer.h"
#include "Basic/Scheduler.h"
#include "Basic/VGRender.h"
#include "Basic/View.h"
#include "Effect/Effect.h"
#include "Entity/Entity.h"
#include "GUI/ImGuiDora.h"
#include "Http/HttpServer.h"
#include "Input/Controller.h"
#include "Input/Keyboard.h"
#include "Input/TouchDispather.h"
#include "Node/Node.h"
#include "Node/Sprite.h"

#include "bx/timer.h"

#include "SDL.h"

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
	, _nvgContext(nullptr) { }

Director::~Director() {
	cleanup();
}

void Director::setScheduler(Scheduler* scheduler) {
	_scheduler = scheduler ? scheduler : Scheduler::create();
}

Scheduler* Director::getScheduler() const {
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

Color Director::getClearColor() const {
	return _clearColor;
}

Scheduler* Director::getSystemScheduler() const {
	return _systemScheduler;
}

Scheduler* Director::getPostScheduler() const {
	return _postScheduler;
}

void Director::pushCamera(Camera* var) {
	Camera* lastCamera = getCurrentCamera();
	lastCamera->Updated -= std::make_pair(this, &Director::markDirty);
	var->Updated += std::make_pair(this, &Director::markDirty);
	_camStack->add(Value::alloc(var));
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

bool Director::removeCamera(Camera* camera) {
	Camera* lastCamera = getCurrentCamera();
	if (camera == lastCamera) {
		popCamera();
		return true;
	} else {
		auto cam = Value::alloc(camera);
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

const Matrix& Director::getViewProjection() const {
	return *_viewProjs.top();
}

static void registerTouchHandler(Node* target) {
	target->traverseVisible([](Node* node) {
		if (node->isTouchEnabled()) {
			SharedTouchDispatcher.add(node->getTouchHandler()->ref());
		}
		return false;
	});
}

bool Director::init() {
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

void Director::doLogic() {
	if (_stoped) return;

	if (!_unManagedNodes.empty()) {
		RefVector<Node> nodes;
		for (Node* node : _unManagedNodes) {
			if (node->isUnManaged()) {
				nodes.push_back(node);
			}
		}
		_unManagedNodes.clear();
		for (Node* node : nodes) {
			getEntry()->addChild(node);
		}
	}

	double deltaTime = SharedApplication.getDeltaTime();

	/* update system logic */
	_systemScheduler->update(deltaTime);

	if (_paused) return;

	/* push default view projection */
	Camera* camera = getCurrentCamera();
	if (camera->hasProjection()) {
		_defaultViewProj = camera->getView();
	} else {
		bx::mtxMul(_defaultViewProj, camera->getView(), SharedView.getProjection());
	}
	pushViewProjection(_defaultViewProj, [&]() {
		/* update game logic */
		SharedImGui.begin();
		_scheduler->update(deltaTime);
		_postScheduler->update(deltaTime);
		SharedImGui.end();

		SharedKeyboard.clearChanges();
		SharedController.clearChanges();

		/* handle ImGui touch */
		SharedTouchDispatcher.add(SharedImGui.getTarget()->getTouchHandler()->ref());
		SharedTouchDispatcher.dispatch();

		/* handle ui3D touch */
		if (_ui3D) {
			registerTouchHandler(_ui3D);
			pushViewProjection(_ui3DCamera->getView(), []() {
				SharedTouchDispatcher.dispatch();
			});
		}

		/* handle ui touch */
		if (_ui) {
			registerTouchHandler(_ui);
			pushViewProjection(_uiCamera->getView(), []() {
				SharedTouchDispatcher.dispatch();
			});
		}

		/* handle post node touch */
		if (_postNode) {
			registerTouchHandler(_postNode);
			SharedTouchDispatcher.dispatch();
		}

		/* handle scene tree touch */
		if (_entry) {
			registerTouchHandler(_entry);
			SharedTouchDispatcher.dispatch();
		}

		SharedTouchDispatcher.clearEvents();
	});
}

void Director::doRender() {
	if (_paused || _stoped) return;

	/* push default view projection */
	pushViewProjection(_defaultViewProj, [&]() {
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
					bx::mtxOrtho(ortho,
						0, viewSize.width, 0, viewSize.height,
						-1000.0f, 1000.0f, 0,
						bgfx::getCaps()->homogeneousDepth);
					pushViewProjection(ortho, [&]() {
						bgfx::setViewTransform(viewId, nullptr, getViewProjection());
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
					bgfx::setViewTransform(viewId, nullptr, getViewProjection());
					_postNode->visit();
					SharedRendererManager.flush();
				}
				/* ui 3D node */
				if (_ui3D) {
					pushViewProjection(_ui3DCamera->getView(), [&]() {
						bgfx::setViewTransform(viewId, nullptr, getViewProjection());
						_ui3D->visit();
						SharedRendererManager.flush();
					});
				}
				/* ui node */
				if (_ui) {
					pushViewProjection(_uiCamera->getView(), [&]() {
						bgfx::setViewTransform(viewId, nullptr, getViewProjection());
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
				bgfx::setViewTransform(viewId, nullptr, getViewProjection());
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
						bgfx::setViewTransform(viewId, nullptr, getViewProjection());
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
							bgfx::setViewTransform(viewId, nullptr, getViewProjection());
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
	_viewProjs.push(New<Matrix>(viewProj));
}

void Director::popViewProjection() {
	_viewProjs.pop();
}

void Director::cleanup() {
	if (!_unManagedNodes.empty()) {
		for (Node* node : _unManagedNodes) {
			node->cleanup();
		}
	}
	_unManagedNodes.clear();
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
	if (_nvgContext) {
		nvgDelete(_nvgContext);
		_nvgContext = nullptr;
	}
	_camStack->clear();
}

void Director::addUnManagedNode(Node* node) {
	_unManagedNodes.push_back(node);
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
			Event::send("AppQuit"_slice);
			cleanup();
			if (Singleton<HttpServer>::isInitialized()) {
				SharedHttpServer.stop();
			}
			if (Singleton<HttpClient>::isInitialized()) {
				SharedHttpClient.stop();
			}
			break;
		// The application is being terminated by the OS.
		case SDL_APP_TERMINATING:
			Event::send("AppQuit"_slice);
			break;
		// The application is low on memory, free memory if possible.
		case SDL_APP_LOWMEMORY:
			Event::send("AppLowMemory"_slice);
			break;
		// The application is about to enter the background.
		case SDL_APP_WILLENTERBACKGROUND:
			_paused = true;
			Event::send("AppWillEnterBackground"_slice);
			break;
		case SDL_APP_DIDENTERBACKGROUND:
			bgfx::reset(0, 0);
			Event::send("AppDidEnterBackground"_slice);
			break;
		case SDL_APP_WILLENTERFOREGROUND:
			Event::send("AppWillEnterForeground"_slice);
			break;
		case SDL_APP_DIDENTERFOREGROUND:
			_paused = false;
			SharedView.reset();
			Event::send("AppDidEnterForeground"_slice);
			Event::send("AppSizeChanged"_slice);
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
					Event::send("AppSizeChanged"_slice);
					break;
				case SDL_WINDOWEVENT_MOVED:
					Event::send("AppMoved"_slice);
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

NS_DORA_END

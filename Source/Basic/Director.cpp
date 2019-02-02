/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Director.h"
#include "Basic/Camera.h"
#include "Basic/Scheduler.h"
#include "Node/Node.h"
#include "Node/Sprite.h"
#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Renderer.h"
#include "Input/TouchDispather.h"
#include "Basic/View.h"
#include "GUI/ImGuiDora.h"
#include "Audio/Sound.h"
#include "Node/RenderTarget.h"
#include "Input/Keyboard.h"
#include "bx/timer.h"
#include "Common/Utils.h"
#include "nanovg/nanovg.h"
#include "nanovg/nanovg_bgfx.h"
#include "Entity/Entity.h"
#include "Basic/VGRender.h"

NS_DOROTHY_BEGIN

Director::Director():
_systemScheduler(Scheduler::create()),
_scheduler(Scheduler::create()),
_postScheduler(Scheduler::create()),
_postSystemScheduler(Scheduler::create()),
_camStack(Array::create()),
_clearColor(0xff000000),
_displayStats(false),
_nvgDirty(false),
_stoped(false),
_nvgContext(nullptr)
{
	Camera* defaultCamera = Camera2D::create("Default"_slice);
	defaultCamera->Updated += std::make_pair(this, &Director::markDirty);
	_camStack->add(defaultCamera);
}

Director::~Director()
{
	clear();
}

void Director::setScheduler(Scheduler* scheduler)
{
	_scheduler = scheduler ? scheduler : Scheduler::create();
}

Scheduler* Director::getScheduler() const
{
	return _scheduler;
}

Node* Director::getUI()
{
	if (!_ui)
	{
		_ui = Node::create();
		_ui->onEnter();
	}
	return _ui;
}

Node* Director::getEntry()
{
	if (!_entry)
	{
		_entry = Node::create();
		_entry->onEnter();
	}
	return _entry;
}

Node* Director::getPostNode()
{
	if (!_postNode)
	{
		_postNode = Node::create();
		_postNode->onEnter();
	}
	return _postNode;
}

UITouchHandler* Director::getUITouchHandler()
{
	if (!_uiTouchHandler)
	{
		_uiTouchHandler = New<UITouchHandler>();
	}
	return _uiTouchHandler;
}

void Director::setClearColor(Color var)
{
	_clearColor = var;
}

Color Director::getClearColor() const
{
	return _clearColor;
}

void Director::setDisplayStats(bool var)
{
	_displayStats = var;
}

bool Director::isDisplayStats() const
{
	return _displayStats;
}

Scheduler* Director::getSystemScheduler() const
{
	return _systemScheduler;
}

Scheduler* Director::getPostScheduler() const
{
	return _postScheduler;
}

Scheduler* Director::getPostSystemScheduler() const
{
	return _postSystemScheduler;
}

double Director::getDeltaTime() const
{
	// only accept frames drop to min FPS
	return std::min(SharedApplication.getDeltaTime(), 1.0/SharedApplication.getMinFPS());
}

void Director::pushCamera(Camera* var)
{
	Camera* lastCamera = getCurrentCamera();
	lastCamera->Updated -= std::make_pair(this, &Director::markDirty);
	var->Updated += std::make_pair(this, &Director::markDirty);
	_camStack->add(var);
	markDirty();
}

void Director::popCamera()
{
	Camera* lastCamera = getCurrentCamera();
	lastCamera->Updated -= std::make_pair(this, &Director::markDirty);
	_camStack->removeLast();
	if (_camStack->isEmpty())
	{
		_camStack->add(Camera2D::create("Default"_slice));
	}
	getCurrentCamera()->Updated += std::make_pair(this, &Director::markDirty);
	markDirty();
}

bool Director::removeCamera(Camera* camera)
{
	Camera* lastCamera = getCurrentCamera();
	if (camera == lastCamera)
	{
		popCamera();
		return true;
	}
	else
	{
		return _camStack->remove(camera);
	}
}

void Director::clearCamera()
{
	Camera* lastCamera = getCurrentCamera();
	lastCamera->Updated -= std::make_pair(this, &Director::markDirty);
	_camStack->clear();
	Camera2D* defaultCamera = Camera2D::create("Default"_slice);
	defaultCamera->Updated += std::make_pair(this, &Director::markDirty);
	_camStack->add(defaultCamera);
	markDirty();
}

Camera* Director::getCurrentCamera() const
{
	return _camStack->getLast().to<Camera>();
}

const Matrix& Director::getViewProjection() const
{
	return *_viewProjs.top();
}

static void registerTouchHandler(Node* target)
{
	target->traverseVisible([](Node* node)
	{
		if (node->isTouchEnabled())
		{
			SharedTouchDispatcher.add(node->getTouchHandler());
		}
		return false;
	});
}

bool Director::init()
{
	SharedView.reset();
	if (!SharedImGui.init())
	{
		return false;
	}
	if (!SharedKeyboard.init())
	{
		return false;
	}
	if (!SharedAudio.init())
	{
		return false;
	}
	SharedContent.visitDir(SharedContent.getAssetPath(), [](String file, String path)
	{
		if (file.toLower() == "main.lua"_slice)
		{
			SharedLuaEngine.executeScriptFile(path + file);
			return true;
		}
		return false;
	});
	_nvgContext = nvgCreate(1, 0);
	if (!_nvgContext)
	{
		Error("fail to init NanoVG context!");
		return false;
	}
	return true;
}

void Director::mainLoop()
{
	if (_stoped) return;

	/* push default view projection */
	Matrix viewProj;
	Camera* camera = getCurrentCamera();
	if (camera->isOtho())
	{
		viewProj = camera->getView();
	}
	else
	{
		bx::mtxMul(viewProj, camera->getView(), SharedView.getProjection());
	}
	pushViewProjection(viewProj, [&]()
	{
		/* update system logic */
		_systemScheduler->update(getDeltaTime());
		/* update game logic */
		SharedImGui.begin();
		_scheduler->update(getDeltaTime());
		_postScheduler->update(getDeltaTime());
		SharedKeyboard.update();
		SharedImGui.end();

		_postSystemScheduler->update(getDeltaTime());

		/* handle ImGui touch */
		SharedTouchDispatcher.add(SharedImGui.getTarget());
		SharedTouchDispatcher.dispatch();

		Size viewSize = SharedView.getSize();
		Matrix ortho;
		bx::mtxOrtho(ortho, 0, viewSize.width, 0, viewSize.height, -1000.0f, 1000.0f, 0,
			bgfx::getCaps()->homogeneousDepth);

		/* handle ui touch */
		if (_ui)
		{
			registerTouchHandler(_ui);
			pushViewProjection(ortho, []()
			{
				SharedTouchDispatcher.dispatch();
			});
		}

		/* handle post node touch */
		if (_postNode)
		{
			registerTouchHandler(_postNode);
			SharedTouchDispatcher.dispatch();
		}

		/* handle scene tree touch */
		if (_entry)
		{
			registerTouchHandler(_entry);
			SharedTouchDispatcher.dispatch();
			SharedTouchDispatcher.clearEvents();
		}

		/* do render */
		if (SharedView.isPostProcessNeeded())
		{
			/* initialize RT */
			if (!_renderTarget ||
				_renderTarget->getWidth() != viewSize.width ||
				_renderTarget->getHeight() != viewSize.height)
			{
				_renderTarget = RenderTarget::create(
					s_cast<Uint16>(viewSize.width),
					s_cast<Uint16>(viewSize.height));
				_renderTarget->getSurface()->setBlendFunc({BlendFunc::One, BlendFunc::Zero});
			}
			SpriteEffect* postEffect = SharedView.getPostEffect();
			if (postEffect && postEffect != _renderTarget->getSurface()->getEffect())
			{
				_renderTarget->getSurface()->setEffect(postEffect);
			}

			/* render scene tree to RT */
			_renderTarget->setCamera(getCurrentCamera());
			_renderTarget->renderWithClear(_entry, _clearColor);

			/* render RT, post node and ui node */
			SharedView.pushName("Main"_slice, [&]()
			{
				bgfx::ViewId viewId = SharedView.getId();
				/* RT */
				pushViewProjection(ortho, [&]()
				{
					bgfx::setViewTransform(viewId, nullptr, getViewProjection());
					_renderTarget->setPosition({viewSize.width/2.0f, viewSize.height/2.0f});
					_renderTarget->visit();
					SharedRendererManager.flush();
				});
				/* post node */
				if (_postNode)
				{
					bgfx::setViewTransform(viewId, nullptr, getViewProjection());
					_postNode->visit();
					SharedRendererManager.flush();
				}
				/* ui node */
				if (_ui)
				{
					pushViewProjection(ortho, [&]()
					{
						bgfx::setViewTransform(viewId, nullptr, getViewProjection());
						_ui->visit();
						SharedRendererManager.flush();
					});
				}
				/* profile info */
				if (_displayStats)
				{
					displayStats();
				}
			});
		}
		else
		{
			/* release unused RT */
			if (_renderTarget)
			{
				_renderTarget = nullptr;
			}

			/* render scene tree and post node */
			SharedView.pushName("Main"_slice, [&]()
			{
				bgfx::ViewId viewId = SharedView.getId();
				bgfx::setViewClear(viewId,
					BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
					_clearColor.toRGBA());
				bgfx::setViewTransform(viewId, nullptr, getViewProjection());
				/* scene tree */
				if (_entry) _entry->visit();
				/* post node */
				if (_postNode) _postNode->visit();
				SharedRendererManager.flush();
			});

			/* render ui node */
			if (_ui || _displayStats)
			{
				SharedView.pushName("UI"_slice, [&]()
				{
					bgfx::ViewId viewId = SharedView.getId();
					/* ui node */
					if (_ui)
					{
						pushViewProjection(ortho, [&]()
						{
							bgfx::setViewTransform(viewId, nullptr, getViewProjection());
							_ui->visit();
							SharedRendererManager.flush();
						});
					}
					/* profile info */
					if (_displayStats)
					{
						displayStats();
					}
				});
			}
		}

		/* render NanoVG */
		if (_nvgContext && _nvgDirty)
		{
			_nvgDirty = false;
			SharedView.pushName("NanoVG"_slice, [&]()
			{
				nvgSetViewId(_nvgContext, SharedView.getId());
				nvgEndFrame(_nvgContext);
			});
		}

		/* render imgui */
		SharedImGui.render();
		SharedView.clear();
		if (_uiTouchHandler)
		{
			_uiTouchHandler->clear();
		}
	});
}

void Director::displayStats()
{
	/* print debug text */
	bgfx::setDebug(BGFX_DEBUG_TEXT);
	bgfx::dbgTextClear();
	const bgfx::Stats* stats = bgfx::getStats();
	const char* rendererNames[] = {
		"Noop", //!< No rendering.
		"Direct3D9", //!< Direct3D 9.0
		"Direct3D11", //!< Direct3D 11.0
		"Direct3D12", //!< Direct3D 12.0
		"Gnm", //!< GNM
		"Metal", //!< Metal
		"OpenGLES", //!< OpenGL ES 2.0+
		"OpenGL", //!< OpenGL 2.1+
		"Vulkan", //!< Vulkan
	};
	bgfx::ViewId dbgViewId = SharedView.getId();
	int row = 0;
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mRenderer: \x1b[15;m%s", rendererNames[bgfx::getCaps()->rendererType]);
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mMultithreaded: \x1b[15;m%s", (bgfx::getCaps()->supported & BGFX_CAPS_RENDERER_MULTITHREADED) ? "true" : "false");
	Size size = SharedView.getSize();
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mBackbuffer: \x1b[15;m%d x %d", s_cast<int>(size.width), s_cast<int>(size.height));
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mDraw call: \x1b[15;m%d", stats->numDraw);
	static int frames = 0;
	static double cpuTime = 0, gpuTime = 0, deltaTime = 0;
	cpuTime += SharedApplication.getCPUTime();
	gpuTime += std::abs(double(stats->gpuTimeEnd) - double(stats->gpuTimeBegin)) / double(stats->gpuTimerFreq);
	deltaTime += SharedApplication.getDeltaTime();
	frames++;
	static double lastCpuTime = 0, lastGpuTime = 0, lastDeltaTime = 1000.0 / SharedApplication.getMaxFPS();
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mCPU time: \x1b[15;m%.1f ms", lastCpuTime);
	if (lastGpuTime > 0.0)
	{
		bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mGPU time: \x1b[15;m%.1f ms", lastGpuTime);
	}
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mDelta time: \x1b[15;m%.1f ms", lastDeltaTime);
	if (frames == SharedApplication.getMaxFPS())
	{
		lastCpuTime = 1000.0 * cpuTime / frames;
		lastGpuTime = 1000.0 * gpuTime / frames;
		lastDeltaTime = 1000.0 * deltaTime / frames;
		frames = 0;
		cpuTime = gpuTime = deltaTime = 0.0;
	}
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mC++ Object: \x1b[15;m%d", Object::getCount());
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mLua Object: \x1b[15;m%d", Object::getLuaRefCount());
	bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mLua Callback: \x1b[15;m%d", Object::getLuaCallbackCount());
	// bgfx::dbgTextPrintf(dbgViewId, ++row, 0x0f, "\x1b[11;mMemory Pool: \x1b[15;m%d kb", MemoryPool::getCapacity()/1024);
}

void Director::pushViewProjection(const Matrix& viewProj)
{
	_viewProjs.push(New<Matrix>(viewProj));
}

void Director::popViewProjection()
{
	_viewProjs.pop();
}

void Director::clear()
{
	if (_ui)
	{
		_ui->onExit();
		_ui->cleanup();
		_ui = nullptr;
	}
	if (_entry)
	{
		_entry->onExit();
		_entry->cleanup();
		_entry = nullptr;
	}
	if (_postNode)
	{
		_postNode->onExit();
		_postNode->cleanup();
		_postNode = nullptr;
	}
	if (_nvgContext)
	{
		nvgDelete(_nvgContext);
		_nvgContext = nullptr;
	}
}

void Director::markDirty()
{
	if (_ui) _ui->markDirty();
	if (_entry) _entry->markDirty();
	if (_postNode) _postNode->markDirty();
}

NVGcontext* Director::markNVGDirty()
{
	if (!_nvgDirty && _nvgContext)
	{
		_nvgDirty = true;
		Size visualSize = SharedApplication.getVisualSize();
		float deviceRatio = SharedApplication.getDeviceRatio();
		nvgBeginFrame(_nvgContext, s_cast<int>(visualSize.width), s_cast<int>(visualSize.height), deviceRatio);
	}
	return _nvgContext;
}

void Director::handleSDLEvent(const SDL_Event& event)
{
	switch (event.type)
	{
		// User-requested quit
		case SDL_QUIT:
			Event::send("AppQuit"_slice);
			_stoped = true;
			clear();
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
			Event::send("AppWillEnterBackground"_slice);
			break;
		case SDL_APP_DIDENTERBACKGROUND:
			Event::send("AppDidEnterBackground"_slice);
			break;
		case SDL_APP_WILLENTERFOREGROUND:
			Event::send("AppWillEnterForeground"_slice);
			break;
		case SDL_APP_DIDENTERFOREGROUND:
			Event::send("AppDidEnterForeground"_slice);
			break;
		case SDL_WINDOWEVENT:
			{
				switch (event.window.event)
				{
					case SDL_WINDOWEVENT_RESIZED:
					case SDL_WINDOWEVENT_SIZE_CHANGED:
					{
						SharedView.reset();
						markDirty();
						Event::send("AppSizeChanged"_slice);
						break;
					}
				}
			}
			break;
		case SDL_MOUSEMOTION:
		case SDL_MOUSEBUTTONDOWN:
		case SDL_MOUSEBUTTONUP:
		case SDL_FINGERDOWN:
		case SDL_FINGERUP:
		case SDL_FINGERMOTION:
			SharedTouchDispatcher.add(event);
			break;
		case SDL_SYSWMEVENT:
			break;
		case SDL_KEYDOWN:
			break;
		case SDL_KEYUP:
			break;
		case SDL_TEXTEDITING:
			break;
		case SDL_TEXTINPUT:
			break;
		case SDL_KEYMAPCHANGED:
			break;
		case SDL_MOUSEWHEEL:
			SharedTouchDispatcher.add(event);
			break;
		case SDL_JOYAXISMOTION:
			break;
		case SDL_JOYBALLMOTION:
			break;
		case SDL_JOYHATMOTION:
			break;
		case SDL_JOYBUTTONDOWN:
			break;
		case SDL_JOYBUTTONUP:
			break;
		case SDL_JOYDEVICEADDED:
			break;
		case SDL_JOYDEVICEREMOVED:
			break;
		case SDL_CONTROLLERAXISMOTION:
			break;
		case SDL_CONTROLLERBUTTONDOWN:
			break;
		case SDL_CONTROLLERBUTTONUP:
			break;
		case SDL_CONTROLLERDEVICEADDED:
			break;
		case SDL_CONTROLLERDEVICEREMOVED:
			break;
		case SDL_CONTROLLERDEVICEREMAPPED:
			break;
		case SDL_DOLLARGESTURE:
			break;
		case SDL_DOLLARRECORD:
			break;
		case SDL_MULTIGESTURE:
			SharedTouchDispatcher.add(event);
			break;
		case SDL_CLIPBOARDUPDATE:
			break;
		case SDL_DROPFILE:
			break;
		case SDL_DROPTEXT:
			break;
		case SDL_DROPBEGIN:
			break;
		case SDL_DROPCOMPLETE:
			break;
		case SDL_AUDIODEVICEADDED:
			break;
		case SDL_AUDIODEVICEREMOVED:
			break;
		default:
			break;
	}
}

NS_DOROTHY_END

/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

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

NS_DOROTHY_BEGIN

Director::Director():
_scheduler(Scheduler::create()),
_systemScheduler(Scheduler::create()),
_postScheduler(Scheduler::create()),
_entryStack(Array::create()),
_camera(Camera2D::create("Default"_slice)),
_clearColor(0xff1a1a1a),
_displayStats(false)
{
	_camera->Updated += std::make_pair(this, &Director::markDirty);
}

Director::~Director()
{
	clearEntry();
}

void Director::setScheduler(Scheduler* scheduler)
{
	_scheduler = scheduler ? scheduler : Scheduler::create();
}

Scheduler* Director::getScheduler() const
{
	return _scheduler;
}

void Director::setUI(Node* var)
{
	if (_ui)
	{
		_ui->onExit();
		_ui->cleanup();
	}
	_ui = var;
	if (_ui)
	{
		_ui->onEnter();
	}
}

Node* Director::getUI() const
{
	return _ui;
}

void Director::setPostNode(Node* var)
{
	if (_postNode)
	{
		_postNode->onExit();
		_postNode->cleanup();
	}
	_postNode = var;
	if (_postNode)
	{
		_postNode->onEnter();
	}
}

Node* Director::getPostNode() const
{
	return _postNode;
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

double Director::getDeltaTime() const
{
	// only accept frames drop to min FPS
	return std::min(SharedApplication.getDeltaTime(), 1.0/SharedApplication.getMinFPS());
}

void Director::setCamera(Camera* var)
{
	if (_camera)
	{
		_camera->Updated -= std::make_pair(this, &Director::markDirty);
	}
	_camera = var ? var : Camera2D::create("Default"_slice);
	_camera->Updated += std::make_pair(this, &Director::markDirty);
}

Camera* Director::getCamera() const
{
	return _camera;
}

Array* Director::getEntries() const
{
	return _entryStack;
}

Node* Director::getCurrentEntry() const
{
	return _entryStack->isEmpty() ? nullptr : _entryStack->getLast().to<Node>();
}

const Matrix& Director::getViewProjection() const
{
	return *_viewProjs.top();
}

void registerTouchHandler(Node* target)
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
	if (!SharedAudio.init())
	{
		return false;
	}
	if (!SharedKeyboard.init())
	{
		return false;
	}
	if (SharedContent.isExist("Script/main.lua"_slice))
	{
		SharedLueEngine.executeScriptFile("Script/main.lua"_slice);
	}
	return true;
}

void Director::mainLoop()
{
	/* push default view projection */
	Matrix viewProj;
	bx::mtxMul(viewProj, getCamera()->getView(), SharedView.getProjection());
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

		/* handle ImGui touch */
		SharedTouchDispatcher.add(SharedImGui.getTarget());
		SharedTouchDispatcher.dispatch();
		/* handle ui touch */
		Matrix ortho;
		Size viewSize = SharedView.getSize();
		bx::mtxOrtho(ortho, 0, viewSize.width, 0, viewSize.height, -1000.0f, 1000.0f, 0, bgfx::getCaps()->homogeneousDepth);
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
		Node* currentEntry = nullptr;
		if (!_entryStack->isEmpty())
		{
			currentEntry = _entryStack->getLast().to<Node>();
			registerTouchHandler(currentEntry);
			SharedTouchDispatcher.dispatch();
		}
		SharedTouchDispatcher.clearEvents();

		/* do render */
		if (SharedView.isPostProcessNeeded())
		{
			/* initialize RT */
			if (!_renderTarget ||
				_renderTarget->getWidth() != viewSize.width ||
				_renderTarget->getHeight() != viewSize.height)
			{
				_renderTarget = RenderTarget::create(
					s_cast<uint16>(viewSize.width),
					s_cast<uint16>(viewSize.height));
			}
			SpriteEffect* postEffect = SharedView.getPostEffect();
			if (postEffect && postEffect != _renderTarget->getSurface()->getEffect())
			{
				_renderTarget->getSurface()->setEffect(postEffect);
			}

			/* render scene tree to RT */
			if (currentEntry)
			{
				_renderTarget->setCamera(getCamera());
				_renderTarget->renderWithClear(currentEntry, _clearColor);
			}

			/* render RT, post node and ui node */
			SharedView.pushName("Main"_slice, [&]()
			{
				Uint8 viewId = SharedView.getId();
				/* RT */
				pushViewProjection(ortho, [&]()
				{
					bgfx::setViewTransform(viewId, nullptr, getViewProjection());
					_renderTarget->setPosition({viewSize.width/2.0f, viewSize.height/2.0f});
					_renderTarget->visit();
					SharedRendererManager.flush();
				});
				/* post node */
				bgfx::setViewTransform(viewId, nullptr, getViewProjection());
				if (_postNode)
				{
					_postNode->visit();
					SharedRendererManager.flush();
				}
				/* ui node */
				pushViewProjection(ortho, [&]()
				{
					bgfx::setViewTransform(viewId, nullptr, getViewProjection());
					if (_ui)
					{
						_ui->visit();
						SharedRendererManager.flush();
					}
				});
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
				Uint8 viewId = SharedView.getId();
				bgfx::setViewClear(viewId,
					BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
					_clearColor.toRGBA());
				bgfx::setViewTransform(viewId, nullptr, getViewProjection());
				/* scene tree */
				if (currentEntry)
				{
					currentEntry->visit();
				}
				/* post node */
				if (_postNode)
				{
					_postNode->visit();
				}
				SharedRendererManager.flush();
			});

			/* render ui node */
			SharedView.pushName("UI"_slice, [&]()
			{
				Uint8 viewId = SharedView.getId();
				/* ui node */
				pushViewProjection(ortho, [&]()
				{
					bgfx::setViewTransform(viewId, nullptr, getViewProjection());
					if (_ui)
					{
						_ui->visit();
					}
					SharedRendererManager.flush();
				});
				/* profile info */
				if (_displayStats)
				{
					displayStats();
				}
			});
		}

		/* render imgui */
		SharedImGui.render();
		SharedView.clear();
	});
}

void Director::displayStats()
{
	/* print debug text */
	bgfx::dbgTextClear();
	bgfx::setDebug(BGFX_DEBUG_TEXT);
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
	Uint8 dbgViewId = SharedView.getId();
	bgfx::dbgTextPrintf(dbgViewId, 1, 0x0f, "\x1b[14;mRenderer: \x1b[15;m%s", rendererNames[bgfx::getCaps()->rendererType]);
	bgfx::dbgTextPrintf(dbgViewId, 2, 0x0f, "\x1b[14;mMultithreaded: \x1b[15;m%s", (bgfx::getCaps()->supported & BGFX_CAPS_RENDERER_MULTITHREADED) ? "true" : "false");
	bgfx::dbgTextPrintf(dbgViewId, 3, 0x0f, "\x1b[14;mBackbuffer: \x1b[15;m%d x %d", stats->width, stats->height);
	bgfx::dbgTextPrintf(dbgViewId, 4, 0x0f, "\x1b[14;mDraw call: \x1b[15;m%d", stats->numDraw);
	static int frames = 0;
	static double cpuTime = 0, gpuTime = 0, deltaTime = 0;
	cpuTime += SharedApplication.getCPUTime();
	gpuTime += std::abs(double(stats->gpuTimeEnd) - double(stats->gpuTimeBegin)) / double(stats->gpuTimerFreq);
	deltaTime += SharedApplication.getDeltaTime();
	frames++;
	static double lastCpuTime = 0, lastGpuTime = 0, lastDeltaTime = 1000.0 / SharedApplication.getMaxFPS();
	bgfx::dbgTextPrintf(dbgViewId, 5, 0x0f, "\x1b[14;mCPU time: \x1b[15;m%.1f ms", lastCpuTime);
	bgfx::dbgTextPrintf(dbgViewId, 6, 0x0f, "\x1b[14;mGPU time: \x1b[15;m%.1f ms", lastGpuTime);
	bgfx::dbgTextPrintf(dbgViewId, 7, 0x0f, "\x1b[14;mDelta time: \x1b[15;m%.1f ms", lastDeltaTime);
	if (frames == SharedApplication.getMaxFPS())
	{
		lastCpuTime = 1000.0 * cpuTime / frames;
		lastGpuTime = 1000.0 * gpuTime / frames;
		lastDeltaTime = 1000.0 * deltaTime / frames;
		frames = 0;
		cpuTime = gpuTime = deltaTime = 0.0;
	}
	bgfx::dbgTextPrintf(dbgViewId, 8, 0x0f, "\x1b[14;mC++ Object: \x1b[15;m%d", Object::getObjectCount());
	bgfx::dbgTextPrintf(dbgViewId, 9, 0x0f, "\x1b[14;mLua Object: \x1b[15;m%d", Object::getLuaRefCount());
	bgfx::dbgTextPrintf(dbgViewId, 10, 0x0f, "\x1b[14;mCallback: \x1b[15;m%d", Object::getLuaCallbackCount());
}

void Director::pushViewProjection(const Matrix& viewProj)
{
	Matrix* matrix = new Matrix(viewProj);
	_viewProjs.push(MakeOwn(matrix));
}

void Director::popViewProjection()
{
	_viewProjs.pop();
}

void Director::setEntry(Node* entry)
{
	_entryStack->removeIf([entry](const Ref<>& item)
	{
		return item == entry;
	});
	pushEntry(entry);
}

void Director::pushEntry(Node* entry)
{
	if (!_entryStack->isEmpty())
	{
		if (entry == _entryStack->getLast())
		{
			Log("target entry pushed is already running!");
			return;
		}
		Node* last = _entryStack->getLast().to<Node>();
		last->onExit();
	}
	_entryStack->add(entry);
	entry->onEnter();
}

Node* Director::popEntry()
{
	if (_entryStack->isEmpty())
	{
		Log("pop from an empty entry stack.");
		return Ref<Node>();
	}
	Ref<Node> last(_entryStack->removeLast().to<Node>());
	last->onExit();
	if (!_entryStack->contains(last))
	{
		last->cleanup();
	}
	if (!_entryStack->isEmpty())
	{
		Node* current = _entryStack->getLast().to<Node>();
		current->onEnter();
	}
	return last;
}

void Director::popToEntry(Node* entry)
{
	if (_entryStack->isEmpty())
	{
		Log("pop from an empty entry stack.");
		return;
	}
	if (_entryStack->contains(entry))
	{
		while (_entryStack->getLast() != entry)
		{
			popEntry();
		}
		return;
	}
	Log("entry to pop is not in entry stack.");
}

void Director::popToRootEntry()
{
	if (_entryStack->isEmpty())
	{
		Log("pop from an empty entry stack.");
		return;
	}
	popToEntry(_entryStack->getFirst().to<Node>());
}

void Director::swapEntry(Node* entryA, Node* entryB)
{
	AssertUnless(_entryStack->contains(entryA) && _entryStack->contains(entryB), "entry to swap is not in entry stack.");
	Node* currentEntry = getCurrentEntry();
	Node* entryToEnter = nullptr;
	Node* entryToExit = nullptr;
	if (entryA == currentEntry)
	{
		entryToEnter = entryB;
		entryToExit = entryA;
	}
	if (entryB == currentEntry)
	{
		entryToEnter = entryA;
		entryToExit = entryB;
	}
	_entryStack->swap(entryA, entryB);
	if (entryToExit) entryToExit->onExit();
	if (entryToEnter) entryToEnter->onEnter();
}

void Director::clearEntry()
{
	while (!_entryStack->isEmpty())
	{
		popEntry();
	}
}

void Director::markDirty()
{
	Node* entry = getCurrentEntry();
	if (entry)
	{
		entry->markDirty();
	}
	if (_ui)
	{
		_ui->markDirty();
	}
	if (_postNode)
	{
		_postNode->markDirty();
	}
}

void Director::handleSDLEvent(const SDL_Event& event)
{
	switch (event.type)
	{
		// User-requested quit
		case SDL_QUIT:
			Event::send("AppQuit"_slice);
			clearEntry();
			setUI(nullptr);
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

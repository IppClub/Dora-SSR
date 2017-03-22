/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Director.h"
#include "Basic/Camera.h"
#include "Basic/Scheduler.h"
#include "Node/Node.h"
#include "Basic/Application.h"
#include "Input/TouchDispather.h"
#include "Basic/View.h"
#include "GUI/ImGUIDora.h"
#include "bx/timer.h"
#include "imgui.h"
#include "Dorothy.h"
#include "Other/rapidxml_sax3.hpp"
#include "Const/XmlTag.h"

class xml_sax2_handler_impl : public rapidxml::xml_sax2_handler
{
    virtual void xmlSAX2StartElement(const char *name, size_t len, const vector<AttrSlice>& attrs)
    {
		Dorothy::LogPrint("start %s\n", Slice(name, len));
		for (const auto& attr : attrs)
		{
			Dorothy::LogPrint("attr %s\n", Slice(attr.first, attr.second));
		}
    }
    virtual void xmlSAX2EndElement(const char *name, size_t len)
    {
		Dorothy::LogPrint("end %s\n", Slice(name, len));
    }
    virtual void xmlSAX2Text(const char *s, size_t len)
    {
		Dorothy::LogPrint("text %s\n", Slice(s, len));
    }
};

NS_DOROTHY_BEGIN

Director::Director():
_scheduler(Scheduler::create()),
_systemScheduler(Scheduler::create()),
_entryStack(Array::create()),
_camera(Camera2D::create("Default"_slice)),
_clearColor(0xff1a1a1a)
{ }

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

void Director::setClearColor(Color var)
{
	_clearColor = var;
}

Color Director::getClearColor() const
{
	return _clearColor;
}

Scheduler* Director::getSystemScheduler() const
{
	return _systemScheduler;
}

double Director::getDeltaTime() const
{
	// only accept frames drop to 30 FPS
	return std::min(SharedApplication.getDeltaTime(), 1.0/30);
}

void Director::setCamera(Camera* var)
{
	_camera = var ? var : Camera2D::create("Default"_slice);
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

const float* Director::getViewProjection() const
{
	return *_viewProjs.top();
}

void registerTouchHandler(Node* target)
{
	target->traverse([](Node* node)
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
	SharedLueEngine.executeScriptFile("Script/main.lua");

	if (!SharedImGUI.init())
	{
		return false;
	}

	ModelDef* modelDef = SharedModelCache.load("Model/jixienv.model");
	Model* model = Model::create(modelDef);

	xml_sax2_handler_impl handler;
	rapidxml::xml_sax3_parser<> parser(&handler);
	char xml[] = "<Dorothy><Node X=\"0\" Y=\"998\"/></Dorothy>";
	try
	{
		parser.parse<>(xml, s_cast<int>(sizeof(xml)));
	}
	catch (rapidxml::parse_error error)
	{
		Log("xml parse error: %s, at: %d", error.what(), error.where<char>() - xml);
	}

	Label* label = Label::create("NotoSansHans-Regular", 18);
	label->setTextWidth(600);
	label->setLineGap(5);
	label->setAlignment(TextAlignment::Left);
	label->setText(u8"tolua++中定义一个C++对象进入Lua系统后，便被转换为一个包含原C++对象指针的Lua Userdata，然后给这个Userdata设置上一个包含所有C++对象可以调用方法的metatable。\n\n使得该Userdata可以调用原C++对象的成员和方法。从而在Lua中提供操作一个C++对象的方法。 <br />&emsp;&emsp;此外tolua++中除了设置好和C++类型继承一致的metatable链，还提供了每个metatable对应的叫做tolua_super的表，里面会记录自己的父类链上的所有父类，用于查询一个Lua中的类型是否是另一个类型的子类。为什么需要这个东西呢？因为一个C++对象可能会被多次在Lua通过不同的接口获取，同一个对象从不同的接口中获取时，可能会显示为不同的类型，如获取Cocos2d-x中一个CCNode的子节点，用getChildByTag获取的是类型为CCNode的子节点，但是从getChildren接口获取的子节点类型为CCObject，而这个子节点在最初创建使用的时候可能其实是一个CCSprite的类型。就是说同一个对象在不同的地方可能会被识别为不同的类型。但是我们为了不重复创建对象而让同一个C++对象只会对应一个Lua Userdata，那么这个Userdata的metatable应该设置为上述的哪一个类型呢？实际上只能是继承链靠后的类型，在CCObject &lt;= CCNode &lt;= CCSprite的继承链中应为CCSprite，因为只有CCSprite类型能满足所有调用该C++对象的场景。所以每次C++对象被Lua获取的时候需要检查类型的继承关系，将Lua中的C++对象升级成更靠后的子类，所以设计了这个tolua_super表来完成这项功能。");
/*
	ParticleDef* def = ParticleDef::fire();
	//def->duration = 2;
	ParticleNode* node = ParticleNode::create(def);
	label->setTouchEnabled(true);
	label->slot("TapMoved"_slice, [node](Event* e)
	{
		Touch* touch;
		e->get(touch);
		node->setPosition(node->getPosition() + touch->getDelta());
	});
	label->slot("Tapped"_slice, [node](Event* e)
	{
		node->start();
	});
	node->slot("Finished"_slice, [](Event* e)
	{
		Log("Finished!");
	});
	node->start();
	label->addChild(node);
*/
	RenderTarget* target = RenderTarget::create(512, 512);
	label->setPosition(Vec2{256,256});
	label->setBlendFunc({BlendFunc::One, BlendFunc::Zero});
	target->renderWithClear(label, 0x0);
	label->setBlendFunc(BlendFunc::Default);
	label->setPosition(Vec2{0,0});
	target->render(label);
	/*target->saveAsync(SharedContent.getWritablePath() + "image.png", []()
	{
		Log("Save done!");
	});
	*/

	Sprite* sp = Sprite::create("Image/logo.png");
	//sp->setAngle(60.0f);
	ClipNode* cn = ClipNode::create(sp);
	//sp->setAngle(45.0f);
	sp->schedule([sp](double)
	{
		//sp->setAngle(sp->getAngle()+1);
		return false;
	});
	//cn->setInverted(true);
	cn->addChild(target);
	
	Sprite* sp1 = Sprite::create("Image/logo.png");
	Sprite* sp2 = Sprite::create("Image/logo.png");
	ClipNode* cn1 = ClipNode::create(sp1);
	//sp1->setAngle(45.0f);
	//cn->setInverted(true);
	cn1->addChild(cn);
	sp2->setPosition(Vec2{-20,-20});
	cn1->addChild(sp2);

	cn1->setAlphaThreshold(0.0f);
	DrawNode* dn = DrawNode::create();
	dn->drawPolygon({{0,0},{0,200},{200,200},{200,0}}, 0x6600ffff, 0.5f, 0xff00ffff);
	dn->drawDot(Vec2::zero, 50, 0xff00ffff);
	dn->drawSegment(Vec2::zero, {100,100}, 10, 0xffff0088);
	dn->setSkewX(45.0f);
	sp2->addChild(dn);
	DrawNode* dn1 = DrawNode::create();
	dn1->drawDot(Vec2::zero, 200, 0x88ffffff);
	dn->addChild(dn1);

	vector<Vec2> verts{{0,0}, {0, 200}, {50, 50}};
	Line* line = Line::create(verts, 0xff00ffff);
	line->add({{-50,-50},{-100,-200}}, 0xffff0080);
	Line* l2 = Line::create(verts, 0xff80ff00);
	l2->setAngle(45.0f);
	line->addChild(l2);
	sp2->addChild(line);

	Action* action;
	action = Sequence::create({
		PropertyAction::alloc(0, 1.0f, 1.0f, Property::Opacity),
		//Hide::alloc(),
		Delay::alloc(1),
		Call::alloc([](){ Log("Blink"); }),
		PropertyAction::alloc(3, 0.0f, 200.0f, Property::X, Ease::OutBounce),
		PropertyAction::alloc(3, 0.0f, 200.0f, Property::Y, Ease::OutBounce),
		PropertyAction::alloc(4, 1.0f, 0.0f, Property::Opacity),
		Call::alloc([](){ Log("Ended"); }),
		Call::alloc([](){ Log("Ended1"); }),
		Call::alloc([](){ Log("Ended2"); }),
		Show::alloc(),
		//Hide::alloc(),
		Call::alloc([cn1]()
		{
			cn1->runAction(s_cast<Action*>(cn1->getUserData()));
		})
	});
	cn1->setUserData(action);
	action->setSpeed(2.0f);
	//action->setReversed(true);
	cn1->runAction(action);
	cn1->slot("ActionEnd"_slice, [](Event* e)
	{
		Action* action;
		Node* target;
		e->get(action, target);
		Log("action is running: %s", action->isRunning() ? "true" : "false");
		Log("running action count: %d", target->getActionCount());
		//action->setReversed(!action->isReversed());
		//target->runAction(action);
	});
	model->setLook("happy");
	model->setLoop(true);
	model->setReversed(true);
	model->play("die");
	model->handlers["die"] += [](Model* model)
	{
		model->setRecovery(1.0f);
		model->play("walk");
	};
	//model->setOpacity(0.05f);
	World* world = World::create();
	world->setShowDebug(true);
	world->setShouldContact(0, 0, true);

	BodyDef* terrainDef = BodyDef::create();
	terrainDef->attachPolygon(400.0f, 50.0f, 1.0f, 0.4f, 0.4f);
	terrainDef->type = b2_staticBody;
	Body* terrain = Body::create(terrainDef, world, Vec2{0,-150.0f});

	BodyDef* bodyDef = BodyDef::create();
	//bodyDef->angularVelocity = -bx::pi;
	bodyDef->attachCircle(100.0f, 1.0f, 0.4f, 0.4f);
	bodyDef->type = b2_dynamicBody;
	Body* body = Body::create(bodyDef, world, Vec2{0,300.0f});
	body->addChild(model);

	world->addChild(body);
	world->addChild(terrain);
	//world->setOpacity(0.02f);
	pushEntry(world);

	return true;
}

void Director::mainLoop()
{
	/* push default view projection */
	auto viewProj = New<Matrix>();
	bx::mtxMul(*viewProj, getCamera()->getView(), SharedView.getProjection());
	pushViewProjection(*viewProj, [&]()
	{
		/* update logic */
		_systemScheduler->update(getDeltaTime());

		SharedImGUI.begin();
		//ImGui::ShowTestWindow();
		_scheduler->update(getDeltaTime());
		SharedImGUI.end();

		/* handle touches */
		SharedTouchDispatcher.add(SharedImGUI.getTarget());
		SharedTouchDispatcher.dispatch();
		Matrix ortho;
		bx::mtxOrtho(ortho, 0, s_cast<float>(SharedApplication.getWidth()),
			0, s_cast<float>(SharedApplication.getHeight()), -1000.0f, 1000.0f);
		if (_ui)
		{
			registerTouchHandler(_ui);
			pushViewProjection(ortho, []()
			{
				SharedTouchDispatcher.dispatch();
			});
		}
		Node* currentEntry = nullptr;
		if (!_entryStack->isEmpty())
		{
			currentEntry = _entryStack->getLast().to<Node>();
			registerTouchHandler(currentEntry);
			SharedTouchDispatcher.dispatch();
		}
		SharedTouchDispatcher.clearEvents();

		/* render scene tree */
		SharedView.pushName("Main"_slice, [&]()
		{
			Uint8 viewId = SharedView.getId();
			bgfx::setViewClear(viewId,
				BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
				_clearColor.toRGBA());
			if (currentEntry)
			{
				bgfx::setViewTransform(viewId, nullptr, getViewProjection());
				currentEntry->visit();
				SharedRendererManager.flush();
			}
		});
		
		/* render ui nodes */
		SharedView.pushName("UI"_slice, [&]()
		{
			Uint8 viewId = SharedView.getId();
			pushViewProjection(ortho, [&]()
			{
				if (_ui)
				{
					bgfx::setViewTransform(viewId, nullptr, getViewProjection());
					_ui->visit();
					SharedRendererManager.flush();
				}
				displayStat();
			});
		});

		/* render imgui */
		SharedImGUI.render();
		SharedView.clear();
	});
}

void Director::displayStat()
{
	/* print debug text */
	bgfx::dbgTextClear();
	bgfx::setDebug(BGFX_DEBUG_TEXT);
	const bgfx::Stats* stats = bgfx::getStats();
	const char* rendererNames[] = {
		"Noop",         //!< No rendering.
		"Direct3D9",    //!< Direct3D 9.0
		"Direct3D11",   //!< Direct3D 11.0
		"Direct3D12",   //!< Direct3D 12.0
		"Gnm",          //!< GNM
		"Metal",        //!< Metal
		"OpenGLES",     //!< OpenGL ES 2.0+
		"OpenGL",       //!< OpenGL 2.1+
		"Vulkan",       //!< Vulkan
	};
	Uint8 dbgViewId = SharedView.getId();
	bgfx::dbgTextPrintf(dbgViewId, 1, 0x0f, "Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters."
			, stats->width
			, stats->height
			, stats->textWidth
			, stats->textHeight);
	bgfx::dbgTextPrintf(dbgViewId, 3, 0x0f, "Compute %d, Draw %d, CPU Time %.3f/%.3f, GPU Time %.3f, MultiThreaded %s, Renderer %s"
			, stats->numCompute
			, stats->numDraw
			, SharedApplication.getCPUTime()
			, SharedApplication.getDeltaTime()
			, (std::max(stats->gpuTimeEnd, stats->gpuTimeBegin) - std::min(stats->gpuTimeEnd, stats->gpuTimeBegin)) / double(stats->gpuTimerFreq)
			, (bgfx::getCaps()->supported & BGFX_CAPS_RENDERER_MULTITHREADED) ? "true" : "false"
			, rendererNames[bgfx::getCaps()->rendererType]);
}

void Director::pushViewProjection(const float* viewProj)
{
	Matrix* matrix = new Matrix(*r_cast<const Matrix*>(viewProj));
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

Ref<Node> Director::popEntry()
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
						Node* entry = getCurrentEntry();
						if (entry)
						{
							entry->markDirty();
						}
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

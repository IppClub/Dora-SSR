/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Array.h"
#include "Support/Geometry.h"
#include "Support/Common.h"

NS_DOROTHY_BEGIN

class Scheduler;
class Node;
class Camera;
class RenderTarget;

class Director
{
public:
	virtual ~Director();
	PROPERTY(Scheduler*, Scheduler);
	PROPERTY(Node*, PostNode);
	PROPERTY(Node*, UI);
	PROPERTY(Camera*, Camera);
	PROPERTY(Color, ClearColor);
	PROPERTY_BOOL(DisplayStats);
	PROPERTY_READONLY(Scheduler*, SystemScheduler);
	PROPERTY_READONLY(Scheduler*, PostScheduler);
	PROPERTY_READONLY(double, DeltaTime);
	PROPERTY_READONLY(Array*, Entries);
	PROPERTY_READONLY(Node*, CurrentEntry);
	PROPERTY_READONLY(const Matrix&, ViewProjection);
	bool init();
	void mainLoop();
	void handleSDLEvent(const SDL_Event& event);

	void setEntry(Node* entry);
	void pushEntry(Node* entry);
	Node* popEntry();
	void popToEntry(Node* entry);
	void popToRootEntry();
	void swapEntry(Node* entryA, Node* entryB);
	void clearEntry();

	void markDirty();

	template <typename Func>
	void pushViewProjection(const Matrix& viewProj, const Func& workHere)
	{
		pushViewProjection(viewProj);
		workHere();
		popViewProjection();
	}
protected:
	Director();
	void displayStats();
	void pushViewProjection(const Matrix& viewProj);
	void popViewProjection();
private:
	bool _displayStats;
	Color _clearColor;
	Ref<Node> _ui;
	Ref<Node> _postNode;
	Ref<Array> _entryStack;
	Ref<Node> _currentScene;
	Ref<Scheduler> _scheduler;
	Ref<Scheduler> _systemScheduler;
	Ref<Scheduler> _postScheduler;
	Ref<Camera> _camera;
	Ref<RenderTarget> _renderTarget;
	stack<Own<Matrix>> _viewProjs;
	SINGLETON_REF(Director, FontManager, BGFXDora, Application);
};

#define SharedDirector \
	Dorothy::Singleton<Dorothy::Director>::shared()

NS_DOROTHY_END

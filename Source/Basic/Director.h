/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Array.h"

NS_DOROTHY_BEGIN

class Scheduler;
class Node;
class Camera;

class Director : public Object
{
public:
	PROPERTY(Scheduler*, Scheduler);
	PROPERTY(Camera*, Camera);
	PROPERTY_READONLY(Scheduler*, SystemScheduler);
	PROPERTY_READONLY(double, DeltaTime);
	PROPERTY_READONLY(Array*, Entries);
	PROPERTY_READONLY(Node*, CurrentEntry);
	bool init() override;
	void mainLoop();
	void handleSDLEvent(const SDL_Event& event);

	void setEntry(Node* entry);
	void pushEntry(Node* entry);
	Ref<Node> popEntry();
	void popToEntry(Node* entry);
	void popToRootEntry();
	void swapEntry(Node* entryA, Node* entryB);
	void clearEntry();
protected:
	Director();
private:
	Ref<Array> _entryStack;
	Ref<Node> _currentScene;
	Ref<Scheduler> _scheduler;
	Ref<Scheduler> _systemScheduler;
	Ref<Camera> _camera;
};

#define SharedDirector \
	silly::Singleton<Director, SingletonIndex::Director>::shared()

NS_DOROTHY_END

/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DORA_BEGIN

class Playable : public Node {
public:
	Playable();
	PROPERTY_VIRTUAL(float, Speed);
	PROPERTY_VIRTUAL(float, Recovery);
	PROPERTY_VIRTUAL_STRING(Look);
	PROPERTY_VIRTUAL_BOOL(Fliped);
	virtual const std::string& getCurrent() const = 0;
	virtual const std::string& getLastCompleted() const = 0;
	virtual Vec2 getKeyPoint(String name) = 0;
	virtual float play(String name, bool loop = false) = 0;
	virtual void stop() = 0;
	virtual void setSlot(String name, Node* item) = 0;
	virtual Node* getSlot(String name) = 0;
	static Playable* create(String filename);

protected:
	bool _fliped;
	float _speed;
	float _recoveryTime;
	std::string _lookName;
	DORA_TYPE_OVERRIDE(Playable);
};

NS_DORA_END

/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "playrho/d2/BasicAPI.hpp"

NS_DORA_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class Sensor;
class Array;

typedef Acf::Delegate<void(Body*, int)> SensorEventHandler;

class Sensor : public Object {
public:
	virtual ~Sensor();
	/**
	 Set sensor enable to false to stop detection.
	 */
	PROPERTY(int, Group);
	PROPERTY_BOOL(Enabled);
	PROPERTY_READONLY(int, Tag);
	PROPERTY_READONLY(Body*, Owner);
	PROPERTY_READONLY(pr::ShapeID, Fixture);
	PROPERTY_READONLY(Array*, SensedBodies);
	PROPERTY_READONLY_BOOL(Sensed);

	bool contains(Body* body);
	/**
	 Set the callback function which is called every time
	 there is a detectable body that entered the sensor`s area.
	 */
	SensorEventHandler bodyEnter;
	/**
	 Set the callback function which is called every time
	 there is a detectable body that left the sensor`s area.
	 */
	SensorEventHandler bodyLeave;

	CREATE_FUNC_NOT_NULL(Sensor);

protected:
	Sensor(NotNull<Body, 1> owner, int tag, pr::ShapeID fixture);
	int _tag;
	WRef<Body> _owner;
	pr::ShapeID _fixture;

private:
	void executeEnterHandler();
	void executeLeaveHandler();
	void add(Body* body);
	void remove(Body* body);
	void clear();
	bool _enabled;
	Ref<Array> _sensedBodies;
	std::unordered_set<Body*> _uniqueBodies;
	friend class PhysicsWorld;
	DORA_TYPE_OVERRIDE(Sensor);
};

NS_DORA_END

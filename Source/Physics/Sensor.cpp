/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/Sensor.h"
#include "Physics/Body.h"
#include "Physics/PhysicsWorld.h"
#include "Support/Array.h"

NS_DOROTHY_BEGIN

Sensor::Sensor(Body* owner, int tag, pd::Fixture* fixture):
_owner(owner),
_tag(tag),
_fixture(fixture),
_enabled(true),
_sensedBodies(Array::create())
{ }

Sensor::~Sensor()
{
	Sensor::clear();
	_fixture = nullptr;
}

void Sensor::add(Body* body)
{
	_sensedBodies->add(body);
	if (bodyEnter)
	{
		bodyEnter(this, body);
	}
}

void Sensor::remove(Body* body)
{
	if (_sensedBodies->fastRemove(body) && bodyLeave)
	{
		bodyLeave(this, body);
	}
}

bool Sensor::contains(Body* body)
{
	ARRAY_START(Body, item, _sensedBodies)
	{
		if (item == body)
		{
			return true;
		}
	}
	ARRAY_END
	return false;
}

void Sensor::clear()
{
	_sensedBodies->clear();
}

Array* Sensor::getSensedBodies() const
{
	return _sensedBodies;
}

void Sensor::setEnabled(bool enable)
{
	_enabled = enable;
	if (!enable)
	{
		Sensor::clear();
	}
}

bool Sensor::isEnabled() const
{
	return _enabled;
}

int Sensor::getTag() const
{
	return _tag;
}

void Sensor::setGroup(int var)
{
	_fixture->SetFilterData(_owner->getWorld()->getFilter(var));
}

int Sensor::getGroup() const
{
	return _fixture->GetFilterData().groupIndex;
}

Body* Sensor::getOwner() const
{
	return _owner;
}

pd::Fixture* Sensor::getFixture() const
{
	return _fixture;
}

bool Sensor::isSensed() const
{
	return _sensedBodies->getCount() > 0;
}

NS_DOROTHY_END

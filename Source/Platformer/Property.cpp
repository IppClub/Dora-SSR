/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Platformer/Unit.h"
#include "Platformer/Property.h"

NS_DOROTHY_PLATFORMER_BEGIN

Property::Property(Unit* owner, float data):
_owner(owner),
_data(data)
{ }

void Property::reset(float value)
{
	_data = value;
}

void Property::operator=(float value)
{
	if (_data != value)
	{
		float oldValue = _data;
		_data = value;
		if (changed)
		{
			changed(_owner, oldValue, value);
		}
	}
}

void Property::operator+=(float value)
{
	float oldValue = _data;
	_data += value;
	if (changed)
	{
		changed(_owner, oldValue, _data);
	}
}

void Property::operator-=(float value)
{
	float oldValue = _data;
	_data -= value;
 	if (changed)
	{
		changed(_owner, oldValue, _data);
	}
}

Property::operator float() const
{
	return _data;
}

Node* Property::getOwner() const
{
	return _owner;
}

Property::Property(const Property& prop)
{
	_data = prop._data;
}

void Property::operator=(const Property& prop)
{
	//Self assign is not a problem here.
	*this = prop._data;
}

void Property::operator+=(const Property& prop)
{
	*this += prop._data;
}

void Property::operator-=(const Property& prop)
{
	*this -= prop._data;
}

bool Property::operator==(const Property& prop)
{
	return _data == prop._data;
}

bool Property::operator!=(const Property& prop)
{
	return _data != prop._data;
}

NS_DOROTHY_PLATFORMER_END

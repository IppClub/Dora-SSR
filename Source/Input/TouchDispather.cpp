/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Input/TouchDispather.h"

NS_DOROTHY_BEGIN

/* Touch */

Touch::Touch(int id):
_flags(Touch::Enabled),
_id(id)
{ }

void Touch::setEnabled(bool var)
{
	_flags.setFlag(Touch::Enabled, var);
}

bool Touch::isEnabled() const
{
	return _flags.isOn(Touch::Enabled);
}

int Touch::getId() const
{
	return _id;
}

Vec2 Touch::getDelta() const
{
	return _location - _preLocation;
}

const Vec2& Touch::getLocation() const
{
	return _location;
}

const Vec2& Touch::getPreLocation() const
{
	return _preLocation;
}

/* TouchHandler */

TouchHandler::TouchHandler(Node* target):_target(target)
{ }

Touch* TouchHandler::alloc(SDL_FingerID fingerId)
{
	auto it  = _touchMap.find(fingerId);
	if (it != _touchMap.end())
	{
		return it->second;
	}
	if (_availableTouchIds.empty())
	{
		Touch* touch = Touch::create(s_cast<int>(_touchMap.size()));
		_touchMap[fingerId] = touch;
		return touch;
	}
	else
	{
		int touchId = _availableTouchIds.top();
		Touch* touch = Touch::create(touchId);
		_touchMap[fingerId] = touch;
		_availableTouchIds.pop();
		return touch;
	}
}

Touch* TouchHandler::get(SDL_FingerID fingerId)
{
	auto it  = _touchMap.find(fingerId);
	if (it != _touchMap.end())
	{
		return it->second;
	}
	return nullptr;
}

void TouchHandler::collect(SDL_FingerID fingerId)
{
	auto it  = _touchMap.find(fingerId);
	if (it != _touchMap.end())
	{
		_availableTouchIds.push(it->second->_id);
		_touchMap.erase(it);
	}
}

Vec2 TouchHandler::getPos(const SDL_TouchFingerEvent& event)
{
	Vec2 ratio(event.x - 0.5f, 0.5f - event.y);
	Vec3 pos{ratio.x * SharedApplication.getWidth(), ratio.y * SharedApplication.getHeight(), 0.0f};
	Vec3 result;
	float invWorld[16];
	bx::mtxInverse(invWorld, _target->getWorld());
	bx::vec3MulMtx(result, pos, invWorld);
	return pos;
}

void TouchHandler::touchDown(const SDL_TouchFingerEvent& event)
{
	Vec2 pos = getPos(event);
	if (Rect(Vec2::zero, _target->getSize()).containsPoint(pos))
	{
		Touch* touch = alloc(event.fingerId);
		touch->_preLocation = touch->_location = pos;
		touch->_flags.setOn(Touch::Selected);
		_target->emit("TapBegan"_slice, touch);
	}
}

void TouchHandler::touchUp(const SDL_TouchFingerEvent& event)
{
	Touch* touch = get(event.fingerId);
	if (touch)
	{
		Vec2 pos = getPos(event);
		touch->_preLocation = touch->_location;
		touch->_location = pos;
		if (touch->_flags.isOn(Touch::Selected))
		{
			_target->emit("TapEnded"_slice, touch);
			_target->emit("Tapped"_slice, touch);
		}
		collect(event.fingerId);
	}
}

void TouchHandler::touchMove(const SDL_TouchFingerEvent& event)
{
	Touch* touch = get(event.fingerId);
	if (touch)
	{
		Vec2 pos = getPos(event);
		touch->_preLocation = touch->_location;
		touch->_location = pos;
		_target->emit("TapMoved", touch);
		if (_target->getSize() != Size::zero)
		{
			bool inBound = Rect(Vec2::zero, _target->getSize()).containsPoint(pos);
			if (touch->_flags.isOn(Touch::Selected) != inBound)
			{
				touch->_flags.toggle(Touch::Selected);
				if (touch->_flags.isOn(Touch::Selected))
				{
					_target->emit("TapBegan"_slice, touch);
				}
				else
				{
					_target->emit("TapEnded"_slice, touch);
				}
			}
		}
	}
}

NS_DOROTHY_END

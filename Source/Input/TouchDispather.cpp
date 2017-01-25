/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Input/TouchDispather.h"

NS_DOROTHY_BEGIN

/* Touch */

Uint32 Touch::source =
#if BX_PLATFORM_OSX
	Touch::FromMouse;
#else
	Touch::FromMouseAndTouch;
#endif

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

TouchHandler::TouchHandler(Node* target):
_target(target)
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

Vec2 TouchHandler::getPos(const SDL_Event& event)
{
	switch (event.type)
	{
		case SDL_MOUSEBUTTONUP:
		case SDL_MOUSEBUTTONDOWN:
		{
			Vec2 pos = Vec2(event.button.x - SharedApplication.getWidth() * 0.5f,
				SharedApplication.getHeight() * 0.5f - event.button.y);
			return _target->convertToNodeSpace(pos);
		}
		case SDL_MOUSEMOTION:
		{
			Vec2 pos = Vec2(event.motion.x - SharedApplication.getWidth() * 0.5f,
				SharedApplication.getHeight() * 0.5f - event.motion.y);
			return _target->convertToNodeSpace(pos);
		}
		case SDL_FINGERUP:
		{
			Vec2 ratio(event.tfinger.x - 0.5f, 0.5f - event.tfinger.y);
			Vec3 pos{ratio.x * SharedApplication.getWidth(), ratio.y * SharedApplication.getHeight(), 0.0f};
			return _target->convertToNodeSpace(pos);
		}
		default:
		{
			return Vec2::zero;
		}
	}
}

void TouchHandler::down(const SDL_Event& event)
{
	Sint64 id = 0;
	switch (event.type)
	{
		case SDL_MOUSEBUTTONDOWN:
			if ((Touch::source & Touch::FromMouse) == 0) return;
			id = INT64_MAX;
			break;
		case SDL_FINGERDOWN:
			if ((Touch::source & Touch::FromTouch) == 0) return;
			id = event.tfinger.fingerId;
			break;
		default:
			return;
	}
	Vec2 pos = getPos(event);
	Touch* touch = alloc(id);
	if (Rect(Vec2::zero, _target->getSize()).containsPoint(pos))
	{
		touch->_preLocation = touch->_location = pos;
		touch->_flags.setOn(Touch::Selected);
		_target->emit("TapBegan"_slice, touch);
	}
	else
	{
		touch->setEnabled(false);
	}
}

void TouchHandler::up(const SDL_Event& event)
{
	Sint64 id = 0;
	switch (event.type)
	{
		case SDL_MOUSEBUTTONUP:
			if ((Touch::source & Touch::FromMouse) == 0) return;
			id = INT64_MAX;
			break;
		case SDL_FINGERUP:
			if ((Touch::source & Touch::FromTouch) == 0) return;
			id = event.tfinger.fingerId;
			break;
		default:
			return;
	}
	Touch*  touch = get(id);
	if (touch && touch->isEnabled())
	{
		Vec2 pos = getPos(event);
		touch->_preLocation = touch->_location;
		touch->_location = pos;
		if (touch->_flags.isOn(Touch::Selected))
		{
			_target->emit("TapEnded"_slice, touch);
			_target->emit("Tapped"_slice, touch);
		}
		collect(id);
	}
}

void TouchHandler::move(const SDL_Event& event)
{
	Touch* touch = nullptr;
	switch (event.type)
	{
		case SDL_MOUSEMOTION:
			if ((Touch::source & Touch::FromMouse) == 0) return;
			touch = get(INT64_MAX);
			break;
		case SDL_FINGERMOTION:
			if ((Touch::source & Touch::FromTouch) == 0) return;
			touch = get(event.tfinger.fingerId);
			break;
		default:
			return;
	}
	if (touch && touch->isEnabled())
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

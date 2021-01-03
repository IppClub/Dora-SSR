/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Input/TouchDispather.h"
#include "Basic/Application.h"
#include "Node/Node.h"
#include "Basic/Director.h"
#include "Basic/View.h"

NS_DOROTHY_BEGIN

/* Touch */

Uint32 Touch::_source =
#if BX_PLATFORM_OSX
	Touch::FromMouse;
#elif BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
	Touch::FromTouch;
#elif BX_PLATFORM_WINDOWS
	Touch::FromMouse;
#endif

Touch::Touch(int id):
_worldLocation(Vec2::zero),
_flags(Touch::Enabled),
_id(id)
{ }

void Touch::setEnabled(bool var)
{
	_flags.set(Touch::Enabled, var);
}

bool Touch::isEnabled() const
{
	return _flags.isOn(Touch::Enabled);
}

bool Touch::isMouse() const
{
	return _flags.isOn(Touch::IsMouse);
}

int Touch::getId() const
{
	return _id;
}

Vec2 Touch::getDelta() const
{
	return _worldLocation - _worldPreLocation;
}

const Vec2& Touch::getLocation() const
{
	return _location;
}

const Vec2& Touch::getPreLocation() const
{
	return _preLocation;
}

const Vec2& Touch::getWorldLocation() const
{
	return _worldLocation;
}

const Vec2& Touch::getWorldPreLocation() const
{
	return _worldPreLocation;
}

Uint32 Touch::getSource()
{
	return _source;
}

/* TouchHandler */

TouchHandler::TouchHandler():
_swallowTouches(true),
_swallowMouseWheel(false)
{ }

TouchHandler::~TouchHandler()
{ }

void TouchHandler::setSwallowTouches(bool var)
{
	_swallowTouches = var;
}

bool TouchHandler::isSwallowTouches() const
{
	return _swallowTouches;
}

void TouchHandler::setSwallowMouseWheel(bool var)
{
	_swallowMouseWheel = var;
}

bool TouchHandler::isSwallowMouseWheel() const
{
	return _swallowMouseWheel;
}

/* NodeTouchHandler */

NodeTouchHandler::NodeTouchHandler(Node* target):
_target(target)
{ }

bool NodeTouchHandler::handle(const SDL_Event& event)
{
	switch (event.type)
	{
	case SDL_MOUSEBUTTONUP:
	case SDL_FINGERUP:
		return up(event) && isSwallowTouches();
	case SDL_MOUSEBUTTONDOWN:
	case SDL_FINGERDOWN:
		return down(event) && isSwallowTouches();
	case SDL_MOUSEMOTION:
	case SDL_FINGERMOTION:
		return move(event) && isSwallowTouches();
	case SDL_MOUSEWHEEL:
		return wheel(event) && isSwallowMouseWheel();
	case SDL_MULTIGESTURE:
		return gesture(event) && isSwallowTouches();
	}
	return false;
}

Touch* NodeTouchHandler::alloc(SDL_FingerID fingerId)
{
	auto it  = _touchMap.find(fingerId);
	if (it != _touchMap.end())
	{
		return it->second;
	}
	if (_availableTouchIds.empty())
	{
		Touch* touch = Touch::create(s_cast<int>(_touchMap.size()));
		if (fingerId == INT64_MAX)
		{
			touch->_flags.setOn(Touch::IsMouse);
		}
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

Touch* NodeTouchHandler::get(SDL_FingerID fingerId)
{
	auto it  = _touchMap.find(fingerId);
	if (it != _touchMap.end())
	{
		return it->second;
	}
	return nullptr;
}

void NodeTouchHandler::collect(SDL_FingerID fingerId)
{
	auto it  = _touchMap.find(fingerId);
	if (it != _touchMap.end())
	{
		_availableTouchIds.push(it->second->_id);
		_touchMap.erase(it);
	}
}

static int unProject(float winx, float winy, float winz, const float* invTransform, const float* viewport, float* objectCoordinate)
{
	float in[4], out[4];
	//Transformation of normalized coordinates between -1 and 1  
	in[0] = (winx - viewport[0]) / viewport[2] * 2.0f - 1.0f;
	in[1] = (winy - viewport[1]) / viewport[3] * 2.0f - 1.0f;
	in[2] = 2.0f * winz - 1.0f;
	in[3] = 1.0f;
	//Objects coordinates
	bx::vec4MulMtx(out, in, invTransform);
	if(out[3] == 0.0f)
	{
		return 0;
	}
	out[3] = 1.0f / out[3];
	objectCoordinate[0] = out[0] * out[3];
	objectCoordinate[1] = out[1] * out[3];
	objectCoordinate[2] = out[2] * out[3];
	return 1;
}

Vec2 NodeTouchHandler::getPos(const Vec3& winPos)
{
	Vec3 pos = winPos;
	Size viewSize = SharedView.getSize();
	
	Matrix invMVP;
	{
		Matrix MVP;
		bx::mtxMul(MVP, _target->getWorld(), SharedDirector.getViewProjection());
		bx::mtxInverse(invMVP, MVP);
	}
	bx::Plane plane;
	bx::calcPlane(plane, bx::Vec3{0,0,0}, bx::Vec3{1,0,0}, bx::Vec3{0,1,0});

	Vec3 posTarget{pos[0], pos[1], 1.0f};
	float viewPort[4]{0, 0, viewSize.width, viewSize.height};

	Vec3 origin, target;
	unProject(pos[0], pos[1], pos[2], invMVP, viewPort, origin);
	unProject(posTarget[0], posTarget[1], posTarget[2], invMVP, viewPort, target);

	bx::Vec3 dir = bx::sub(target, origin);
	bx::Vec3 dirNorm = bx::normalize(dir);
	float denom = bx::dot(dirNorm, plane.normal);
	if (std::abs(denom) >= FLT_EPSILON)
	{
		float nom = bx::dot(origin, plane.normal) + plane.dist;
		float t = -(nom/denom);
		if (t >= 0)
		{
			bx::Vec3 offset = bx::mul(dirNorm, t);
			bx::Vec3 result = bx::add(origin, offset);
			return Vec2{result.x, result.y};
		}
	}
	return Vec2{-1.0f, -1.0f};
}

Vec2 NodeTouchHandler::getPos(const SDL_Event& event)
{
	Vec3 pos{-1.0f, -1.0f, 0.0f};
	switch (event.type)
	{
		case SDL_MOUSEBUTTONUP:
		case SDL_MOUSEBUTTONDOWN:
		{
			Size size = SharedApplication.getWinSize();
			Vec2 ratio = {s_cast<float>(event.button.x) / size.width, 1.0f - s_cast<float>(event.button.y) / size.height};
			Vec2 winPos = ratio * SharedView.getSize();
			pos = {winPos.x, winPos.y, 0.0f};
			break;
		}
		case SDL_MOUSEMOTION:
		{
			Size size = SharedApplication.getWinSize();
			Vec2 ratio = {s_cast<float>(event.motion.x) / size.width, 1.0f - s_cast<float>(event.motion.y) / size.height};
			Vec2 winPos = ratio * SharedView.getSize();
			pos = {winPos.x, winPos.y, 0.0f};
			break;
		}
		case SDL_FINGERUP:
		case SDL_FINGERDOWN:
		case SDL_FINGERMOTION:
		{
			Size size = SharedView.getSize();
			Vec2 ratio{event.tfinger.x, 1.0f - event.tfinger.y};
			pos = {ratio.x * size.width, ratio.y * size.height, 0.0f};
			break;
		}
	}
	return getPos(pos);
}

bool NodeTouchHandler::down(const SDL_Event& event)
{
	if (!_target->isTouchEnabled()) return false;
	Sint64 id = 0;
	switch (event.type)
	{
		case SDL_MOUSEBUTTONDOWN:
			if ((Touch::getSource() & Touch::FromMouseAndTouch) && event.button.which == SDL_TOUCH_MOUSEID) return false;
			if ((Touch::getSource() & Touch::FromMouse) == 0) return false;
			id = INT64_MAX;
			break;
		case SDL_FINGERDOWN:
			if ((Touch::getSource() & Touch::FromTouch) == 0) return false;
			id = event.tfinger.fingerId;
			break;
		default:
			return false;
	}
	Vec2 pos = getPos(event);
	Touch* touch = alloc(id);
	if (_target->getSize() == Size::zero || Rect(Vec2::zero, _target->getSize()).containsPoint(pos))
	{
		touch->_preLocation = touch->_location = pos;
		touch->_worldPreLocation = touch->_worldLocation = _target->convertToWorldSpace(pos);
		touch->_flags.setOn(Touch::Selected);
		_target->emit("TapFilter"_slice, touch);
		if (touch->isEnabled())
		{
			_target->emit("TapBegan"_slice, touch);
		}
		return touch->isEnabled();
	}
	else
	{
		touch->setEnabled(false);
		return false;
	}
}

bool NodeTouchHandler::up(const SDL_Event& event)
{
	if (!_target->isTouchEnabled()) return false;
	Sint64 id = 0;
	switch (event.type)
	{
		case SDL_MOUSEBUTTONUP:
			if ((Touch::getSource() & Touch::FromMouseAndTouch) && event.button.which == SDL_TOUCH_MOUSEID) return false;
			if ((Touch::getSource() & Touch::FromMouse) == 0) return false;
			id = INT64_MAX;
			break;
		case SDL_FINGERUP:
			if ((Touch::getSource() & Touch::FromTouch) == 0) return false;
			id = event.tfinger.fingerId;
			break;
		default:
			return false;
	}
	Touch* touch = get(id);
	if (touch)
	{
		if (touch->isEnabled())
		{
			Vec2 pos = getPos(event);
			touch->_preLocation = touch->_location;
			touch->_location = pos;
			touch->_worldPreLocation = touch->_worldLocation;
			touch->_worldLocation = _target->convertToWorldSpace(pos);
			if (touch->_flags.isOn(Touch::Selected))
			{
				_target->emit("TapEnded"_slice, touch);
				_target->emit("Tapped"_slice, touch);
			}
			collect(id);
			return true;
		}
		collect(id);
	}
	return false;
}

bool NodeTouchHandler::move(const SDL_Event& event)
{
	if (!_target->isTouchEnabled()) return false;
	Touch* touch = nullptr;
	switch (event.type)
	{
		case SDL_MOUSEMOTION:
			if ((Touch::getSource() & Touch::FromMouseAndTouch) && event.button.which == SDL_TOUCH_MOUSEID) return false;
			if ((Touch::getSource() & Touch::FromMouse) == 0) return false;
			touch = get(INT64_MAX);
			break;
		case SDL_FINGERMOTION:
			if ((Touch::getSource() & Touch::FromTouch) == 0) return false;
			touch = get(event.tfinger.fingerId);
			break;
		default:
			return false;
	}
	if (touch && touch->isEnabled())
	{
		Vec2 pos = getPos(event);
		touch->_preLocation = touch->_location;
		touch->_location = pos;
		touch->_worldPreLocation = touch->_worldLocation;
		touch->_worldLocation = _target->convertToWorldSpace(pos);
		_target->emit("TapMoved"_slice, touch);
		if (_target->getSize() != Size::zero)
		{
			bool inBound = Rect(Vec2::zero, _target->getSize()).containsPoint(pos);
			if (touch->_flags.isOn(Touch::Selected) != inBound)
			{
				touch->_flags.toggle(Touch::Selected);
				if (touch->_flags.isOn(Touch::Selected))
				{
					if (touch->isEnabled())
					{
						_target->emit("TapBegan"_slice, touch);
					}
				}
				else
				{
					_target->emit("TapEnded"_slice, touch);
				}
			}
		}
		return true;
	}
	return false;
}

bool NodeTouchHandler::wheel(const SDL_Event& event)
{
	int x, y;
	SDL_GetMouseState(&x, &y);
	Size size = SharedApplication.getWinSize();
	Vec2 ratio = {s_cast<float>(x) / size.width, 1.0f - s_cast<float>(y) / size.height};
	Vec2 winPos = ratio * SharedView.getSize();
	Vec2 pos = getPos({winPos.x, winPos.y, 0.0f});
	if (_target->getSize() != Size::zero && Rect(Vec2::zero, _target->getSize()).containsPoint(pos))
	{
		_target->emit("MouseWheel"_slice, Vec2{s_cast<float>(event.wheel.x), s_cast<float>(event.wheel.y)});
		return true;
	}
	return false;
}

bool NodeTouchHandler::gesture(const SDL_Event& event)
{
	Vec2 ratio{event.mgesture.x, 1.0f - event.mgesture.y};
	Vec2 pos = ratio * SharedView.getSize();
	pos = getPos({pos.x, pos.y, 0.0f});
	if (_target->getSize() == Size::zero || Rect(Vec2::zero, _target->getSize()).containsPoint(pos))
	{
		_target->emit("Gesture"_slice, pos, event.mgesture.numFingers, event.mgesture.dDist, bx::toDeg(event.mgesture.dTheta));
		return true;
	}
	return false;
}

/* UITouchHandler */

UITouchHandler::UITouchHandler():
_mousePos{-1.0f,-1.0f},
_mouseWheel(0.0f),
_touchSwallowed(false),
_wheelSwallowed(false),
_leftButtonPressed(false),
_middleButtonPressed(false),
_rightButtonPressed(false)
{
	setSwallowMouseWheel(true);
	SharedApplication.eventHandler += std::make_pair(this, &UITouchHandler::handleEvent);
}

UITouchHandler::~UITouchHandler()
{
	SharedApplication.eventHandler -= std::make_pair(this, &UITouchHandler::handleEvent);
}

bool UITouchHandler::isTouchSwallowed() const
{
	return _touchSwallowed;
}

void UITouchHandler::setTouchSwallowed(bool value)
{
	_touchSwallowed = value;
}

bool UITouchHandler::isWheelSwallowed() const
{
	return _wheelSwallowed;
}

void UITouchHandler::setWheelSwallowed(bool value)
{
	_wheelSwallowed = value;
}

const Vec2& UITouchHandler::getMousePos() const
{
	return _mousePos;
}

float UITouchHandler::getMouseWheel() const
{
	return _mouseWheel;
}

bool UITouchHandler::isLeftButtonPressed() const
{
	return _leftButtonPressed;
}

bool UITouchHandler::isRightButtonPressed() const
{
	return _rightButtonPressed;
}

bool UITouchHandler::isMiddleButtonPressed() const
{
	return _middleButtonPressed;
}

void UITouchHandler::clear()
{
	_mouseWheel = 0.0f;
	_touchSwallowed = false;
	_wheelSwallowed = false;
}

bool UITouchHandler::handle(const SDL_Event& event)
{
	switch (event.type)
	{
	case SDL_MOUSEBUTTONDOWN:
	case SDL_FINGERDOWN:
		return _touchSwallowed;
	case SDL_MOUSEWHEEL:
		return _wheelSwallowed;
	}
	return false;
}

void UITouchHandler::handleEvent(const SDL_Event& event)
{
	switch (event.type)
	{
		case SDL_MOUSEWHEEL:
		{
			if (event.wheel.y > 0) _mouseWheel = 1.0f;
			else if (event.wheel.y < 0) _mouseWheel = -1.0f;
			break;
		}
		case SDL_MOUSEBUTTONDOWN:
		{
			if (event.button.button == SDL_BUTTON_LEFT) _leftButtonPressed = true;
			if (event.button.button == SDL_BUTTON_RIGHT) _rightButtonPressed = true;
			if (event.button.button == SDL_BUTTON_MIDDLE) _middleButtonPressed = true;
			break;
		}
		case SDL_MOUSEBUTTONUP:
		{
			if (event.button.button == SDL_BUTTON_LEFT) _leftButtonPressed = false;
			if (event.button.button == SDL_BUTTON_RIGHT) _rightButtonPressed = false;
			if (event.button.button == SDL_BUTTON_MIDDLE) _middleButtonPressed = false;
			break;
		}
		case SDL_MOUSEMOTION:
		{
			Size visualSize = SharedApplication.getVisualSize();
			Size winSize = SharedApplication.getWinSize();
			_mousePos = {
				s_cast<float>(event.motion.x) * visualSize.width / winSize.width,
				s_cast<float>(event.motion.y) * visualSize.height / winSize.height
			};
			break;
		}
	}
}

/* TouchDispatcher */

void TouchDispatcher::add(const SDL_Event& event)
{
	_events.push_back(event);
}

void TouchDispatcher::add(TouchHandler* handler)
{
	_handlers.push_back(handler);
}

void TouchDispatcher::dispatch()
{
	if (!_events.empty() && !_handlers.empty())
	{
		for (auto it  = _handlers.rbegin(); it != _handlers.rend(); ++it)
		{
			TouchHandler* handler = *it;
			for (auto eit = _events.begin(); eit != _events.end();)
			{
				if (handler->handle(*eit))
				{
					eit = _events.erase(eit);
				}
				else
				{
					++eit;
				}
			}
			if (_events.empty())
			{
				break;
			}
		}
	}
	clearHandlers();
}

void TouchDispatcher::clearHandlers()
{
	_handlers.clear();
}

void TouchDispatcher::clearEvents()
{
	_events.clear();
}

NS_DOROTHY_END

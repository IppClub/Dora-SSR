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

int glhUnProjectf(float winx, float winy, float winz, const float *modelview, const float *projection, int *viewport, float *objectCoordinate)
  {  
      //Transformation matrices  
      float m[16], A[16];  
      float in[4], out[4];  
      //Calculation for inverting a matrix, compute projection x modelview  
      //and store in A[16]  
      bx::mtxMul(A, projection, modelview);
      //Now compute the inverse of matrix A
	  bx::mtxInverse(m, A);
      //Transformation of normalized coordinates between -1 and 1  
      in[0]=(winx-(float)viewport[0])/(float)viewport[2]*2.0-1.0;  
      in[1]=(winy-(float)viewport[1])/(float)viewport[3]*2.0-1.0;  
      in[2]=2.0*winz-1.0;  
      in[3]=1.0;  
      //Objects coordinates  
      bx::vec4MulMtx(out, in, m);
      if(out[3]==0.0)  
         return 0;  
      out[3]=1.0/out[3];  
      objectCoordinate[0]=out[0]*out[3];  
      objectCoordinate[1]=out[1]*out[3];  
      objectCoordinate[2]=out[2]*out[3];  
      return 1;  
  }

Vec2 TouchHandler::getPos(const SDL_Event& event)
{
	switch (event.type)
	{
		case SDL_MOUSEBUTTONUP:
		case SDL_MOUSEBUTTONDOWN:
		{
			float modelView[16];
			bx::mtxMul(modelView, _target->getWorld(), SharedDirector.getCamera()->getView());
			float invWorld[16];
			bx::mtxInverse(invWorld, _target->getWorld());
			Vec3 planeVec[3];
			bx::vec3MulMtx(planeVec[0], Vec3{0,0,0}, _target->getWorld());
			bx::vec3MulMtx(planeVec[1], Vec3{1,0,0}, _target->getWorld());
			bx::vec3MulMtx(planeVec[2], Vec3{0,1,0}, _target->getWorld());
			float plane[4];
			bx::calcPlane(plane, Vec3{0,0,0}, Vec3{1,0,0}, Vec3{0,1,0});
			Vec3 pos{event.button.x - SharedApplication.getWidth() * 0.5f,
				SharedApplication.getHeight() * 0.5f - event.button.y, 0};
			Vec3 posTarget{pos[0], pos[1], pos[2] + 1.0f};

			Vec3 origin, target;
			int viewPort[4]{0,0,SharedApplication.getWidth(),SharedApplication.getHeight()};
			glhUnProjectf(pos[0], pos[1], pos[2], modelView, SharedView.getProjection(), viewPort, origin);
			glhUnProjectf(posTarget[0], posTarget[1], posTarget[2], modelView, SharedView.getProjection(), viewPort, target);

			Vec3 dir, dirNorm;
			bx::vec3Sub(dir, target, origin);
			bx::vec3Norm(dirNorm, dir);
			float denom = bx::vec3Dot(dirNorm, plane);
			if (std::abs(denom) >= std::numeric_limits<float>::epsilon())
			{
				float nom = bx::vec3Dot(origin, plane) + plane[3];
				float t = -(nom/denom);
				if (t >= 0)
				{
					Vec3 offset;
					bx::vec3Mul(offset, dirNorm, t);
					Vec3 result;
					bx::vec3Add(result, origin, offset);
					return result;
				}
			}
			return Vec2(-1.0f, -1.0f);
		}
		case SDL_MOUSEMOTION:
		{
			Vec2 pos = Vec2(event.motion.x - SharedApplication.getWidth() * 0.5f,
				SharedApplication.getHeight() * 0.5f - event.motion.y);
			return _target->convertToNodeSpace(pos);
		}
		case SDL_FINGERUP:
		case SDL_FINGERDOWN:
		case SDL_FINGERMOTION:
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

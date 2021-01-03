/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/Soft/Particle.h"
#include "Physics/Soft/World.h"

NS_DOROTHY_BEGIN
NS_BEGIN(Soft)

Material Particle::defaultMaterial;

const Vec2& Particle::getPosition() const
{
	return _position;
}

Material* Particle::getMaterial() const
{
	return _material;
}

void Particle::setMaterial(Material* material)
{
	_material = material;
}

Particle::Particle(World* world, float x, float y, Material* material):
_world(world),
_position{x, y},
_previous{x, y},
_material(material ? material : &defaultMaterial)
{ }

void Particle::Simulate(float deltaTime)
{
	if (_material->mass <= 0) return;
	_velocity = _position * 2.0f - _previous;
	_previous = _position;
	_position = _velocity + _acceleration * (deltaTime * deltaTime);
	_velocity = _position - _previous;
	_acceleration = Vec2::zero;
}

void Particle::Accelerate(const Vec2& rate)
{
	_acceleration += rate;
}

void Particle::ApplyForce(const Vec2& force)
{
	if (_material->mass > 0)
	{
		_acceleration += (force / _material->mass);
	}
}

void Particle::ApplyImpulse(const Vec2& impulse)
{
	if (_material->mass > 0)
	{
		_position += (impulse / _material->mass);
	}
}

void Particle::ResetForces()
{
	_acceleration = Vec2::zero;
}

void Particle::Restrain()
{
	// screen boundries
	if (_position.x < 0.0)
	{
		Vec2 distance = _position - _previous;
		_position.x = -_position.x;
		_previous.x = _position.x + _material->bounce * distance.y;

		float j = distance.y;
		float k = distance.x * _material->friction;
		float t = j;
		float d = std::abs(j);
		if (j != 0)
		{
			t /= d;
		}
		if (d <= std::abs(k))
		{
			if (j * t > 0)
			{
				_position.y -= 2.0f * j;
			}
		}
		else
		{
			if (k * t > 0)
			{
				_position.y -= k;
			}
		}
	}
	else if (_position.x > _world->getSize().x)
	{
		Vec2 distance = _position - _previous;
		_position.x = 2.0f * _world->getSize().x - _position.x;
		_previous.x = _position.x + _material->bounce * distance.y;

		float j = distance.y;
		float k = distance.x * _material->friction;
		float t = j;
		float d = std::abs(j);
		if (j != 0)
		{
			t /= d;
		}
		if (d <= std::abs(k))
		{
			if (j * t > 0)
			{
				_position.y -= 2.0f * j;
			}
		}
		else
		{
			if (k * t > 0)
			{
				_position.y -= k;
			}
		}
	}
	if (_position.y < 0)
	{
		Vec2 distance = _position - _previous;
		_position.y = -_position.y;
		_previous.y = _position.y + _material->bounce * distance.y;

		float j = distance.x;
		float k = distance.y * _material->friction;
		float t = j;
		float d = std::abs(j);
		if (j != 0)
		{
			t /= d;
		}
		if (d <= std::abs(k))
		{
			if (j * t > 0)
			{
				_position.x -= 2.0 * j;
			}
		}
		else
		{
			if (k * t > 0)
			{
				_position.x -= k;
			}
		}
	}
	else if (_position.y > _world->getSize().y)
	{
		Vec2 distance = _position - _previous;
		_position.y = 2.0f * _world->getSize().y - _position.y;
		_previous.y = _position.y + _material->bounce * distance.y;

		float j = distance.x;
		float k = distance.y * _material->friction;
		float t = j;
		float d = std::abs(j);
		if (j != 0)
		{
			t /= d;
		}
		if (d <= std::abs(k))
		{
			if (j * t > 0)
			{
				_position.x -= 2.0f * j;
			}
		}
		else
		{
			if (k * t > 0)
			{
				_position.x -= k;
			}
		}
	}
	_position.x = Math::clamp(_position.x, 0.0f, _world->getSize().x);
	_position.y = Math::clamp(_position.y, 0.0f, _world->getSize().y);
}

NS_END(Soft)
NS_DOROTHY_END


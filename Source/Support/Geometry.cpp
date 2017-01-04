/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Support/Geometry.h"

NS_DOROTHY_BEGIN

MEMORY_POOL(Vec2);
const Vec2 Vec2::zero;

Vec2::Vec2():
x(0.0f),
y(0.0f)
{ }

Vec2::Vec2(float x, float y):
x(x),
y(y)
{ }

Vec2::Vec2(const Vec2& vec):
x(vec.x),
y(vec.y)
{ }

/*Vec2::Vec2(const b2Vec2& v):
x(v.x),
y(v.y)
{ }*/

void Vec2::set(float x, float y)
{
	x = x;
	y = y;
}

Vec2 Vec2::operator+(const Vec2& vec) const
{
	return Vec2(x + vec.x, y + vec.y);
}

Vec2& Vec2::operator+=(const Vec2& vec)
{
	x += vec.x;
	y += vec.y;
	return *this;
}

Vec2 Vec2::operator-(const Vec2& vec) const
{
	return Vec2(x - vec.x, y - vec.y);
}

Vec2& Vec2::operator-=(const Vec2& vec)
{
	x -= vec.x;
	y -= vec.y;
	return *this;
}

Vec2 Vec2::operator*(float value) const
{
	return Vec2(x * value, y * value);
}

Vec2& Vec2::operator*=(float value)
{
	x *= value;
	y *= value;
	return *this;
}

Vec2 Vec2::operator*(const Vec2& vec) const
{
	return Vec2(x * vec.x, y * vec.y);
}

Vec2& Vec2::operator*=(const Vec2& vec)
{
	x *= vec.x;
	y *= vec.y;
	return *this;
}

Vec2 Vec2::operator/(float value) const
{
	return Vec2(x / value, y / value);
}

Vec2& Vec2::operator/=(float value)
{
	x /= value;
	y /= value;
	return *this;
}

bool Vec2::operator==(const Vec2& vec) const
{
	return x == vec.x && y == vec.y;
}

bool Vec2::operator!=(const Vec2& vec) const
{
	return x != vec.x || y != vec.y;
}

float Vec2::distance(const Vec2& vec) const
{
	float dx = x - vec.x;
	float dy = y - vec.y;
	return sqrtf(dx * dx + dy * dy);
}

float Vec2::distanceSquared(const Vec2& vec) const
{
	float dx = x - vec.x;
	float dy = y - vec.y;
	return dx * dx + dy * dy;
}

float Vec2::length() const
{
	return sqrtf(x * x + y * y);
}

float Vec2::lengthSquared() const
{
	return x * x + y * y;
}

float Vec2::angle() const
{
	return atan2f(y, x);
}

void Vec2::normalize()
{
	float length = Vec2::length();
	x /= length;
	y /= length;
}

void Vec2::clamp(const Vec2& from, const Vec2& to)
{
	x = Clamp(x, from.x, to.x);
	y = Clamp(y, from.y, to.y);
}

// Size
const Size Size::zero;

Size::Size():
width(0.0f),
height(0.0f)
{ }

Size::Size(float width, float height):
width(width),
height(height)
{ }

Size::Size(const Size& other)
: width(other.width)
, height(other.height)
{ }

Size& Size::operator=(const Size& other)
{
    set(other.width, other.height);
    return *this;
}

void Size::set(float width, float height)
{
    this->width = width;
    this->height = height;
}

bool Size::operator==(const Size& target) const
{
    return width == target.width && height == target.height;
}

bool Size::operator!=(const Size& target) const
{
	return width != target.width || height != target.height;
}

// Rect
const Rect Rect::zero;

Rect::Rect()
{ }

Rect::Rect(const Vec2& origin, const Size& size):
origin(origin),
size(size)
{ }

Rect::Rect(float x, float y, float width, float height):
origin(x,y),
size(width,height)
{ }

Rect::Rect(const Rect& other):
origin(other.origin),
size(other.size)
{ }

Rect& Rect::operator=(const Rect& other)
{
    Rect::set(other.origin.x, other.origin.y, other.size.width, other.size.height);
    return *this;
}

void Rect::set(float x, float y, float width, float height)
{
    origin.x = x;
    origin.y = y;
    size.width = width;
    size.height = height;
}

float Rect::getX() const
{
	return origin.x;
}

void Rect::setX(float x)
{
	origin.x = x;
}

float Rect::getY() const
{
	return origin.y;
}

void Rect::setY(float y)
{
	origin.y = y;
}

float Rect::getWidth() const
{
	return size.width;
}

void Rect::setWidth(float width)
{
	size.width = width;
}

float Rect::getHeight() const
{
	return size.height;
}

void Rect::setHeight(float height)
{
	size.height = height;
}

bool Rect::operator==(const Rect& rect) const
{
    return origin == rect.origin && size == rect.size;
}

bool Rect::operator!=(const Rect& rect) const
{
	return origin != rect.origin || size != rect.size;
}

float Rect::getRight() const
{
    return origin.x + size.width;
}

void Rect::setRight(float right)
{
	size.width = right - getLeft();
}

float Rect::getCenterX() const
{
	return origin.x + size.width * 0.5f;
}

void Rect::setCenterX(float centerX)
{
	origin.x = centerX - size.width * 0.5f;
}

float Rect::getLeft() const
{
    return origin.x;
}

void Rect::setLeft(float left)
{
	float right = getRight();
	origin.x = left;
	size.width = right - left;
}

float Rect::getTop() const
{
    return origin.y + size.height;
}

void Rect::setTop(float top)
{
	size.height = top - getBottom();
}

float Rect::getCenterY() const
{
	return origin.y + size.height * 0.5f;
}

void Rect::setCenterY(float centerY)
{
	origin.y = centerY - size.height*0.5f;
}

float Rect::getBottom() const
{
	return origin.y;
}

void Rect::setBottom(float bottom)
{
	float top = getTop();
	origin.y = bottom;
	size.height = top - bottom;
}

Vec2 Rect::getLowerBound() const
{
	return Vec2(getLeft(), getBottom());
}

void Rect::setLowerBound(const Vec2& point)
{
	setLeft(point.x);
	setBottom(point.y);
}

Vec2 Rect::getUpperBound() const
{
	return Vec2(getRight(), getTop());
}

void Rect::setUpperBound(const Vec2& point)
{
	setRight(point.x);
	setTop(point.y);
}

bool Rect::containsPoint(const Vec2& point) const
{
    return (point.x >= getLeft() && point.x <= getRight()
        && point.y >= getBottom() && point.y <= getTop());
}

bool Rect::intersectsRect(const Rect& rect) const
{
    return !(getRight() < rect.getLeft() ||
			rect.getRight() < getLeft() ||
			getTop() < rect.getBottom() ||
			rect.getTop() < getBottom());
}

NS_DOROTHY_END

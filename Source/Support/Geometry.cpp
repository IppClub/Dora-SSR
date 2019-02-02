/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Support/Geometry.h"

NS_DOROTHY_BEGIN

MEMORY_POOL(Vec2);
const Vec2 Vec2::zero{0.0f, 0.0f};

void Vec2::set(float x, float y)
{
	Vec2::x = x;
	Vec2::y = y;
}

Vec2 Vec2::operator+(const Vec2& vec) const
{
	return {x + vec.x, y + vec.y};
}

Vec2& Vec2::operator+=(const Vec2& vec)
{
	x += vec.x;
	y += vec.y;
	return *this;
}

Vec2 Vec2::operator-(const Vec2& vec) const
{
	return {x - vec.x, y - vec.y};
}

Vec2 Vec2::operator-() const
{
	return {-x, -y};
}

Vec2& Vec2::operator-=(const Vec2& vec)
{
	x -= vec.x;
	y -= vec.y;
	return *this;
}

Vec2 Vec2::operator*(float value) const
{
	return {x * value, y * value};
}

Vec2& Vec2::operator*=(float value)
{
	x *= value;
	y *= value;
	return *this;
}

Vec2 Vec2::operator*(const Vec2& vec) const
{
	return {x * vec.x, y * vec.y};
}

Vec2& Vec2::operator*=(const Vec2& vec)
{
	x *= vec.x;
	y *= vec.y;
	return *this;
}

Vec2 Vec2::operator/(float value) const
{
	return {x / value, y / value};
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

Vec2 Vec2::operator*(const Size& size) const
{
	return {x * size.width, y * size.height};
}

float Vec2::distance(const Vec2& vec) const
{
	float dx = x - vec.x;
	float dy = y - vec.y;
	return std::sqrt(dx * dx + dy * dy);
}

float Vec2::distanceSquared(const Vec2& vec) const
{
	float dx = x - vec.x;
	float dy = y - vec.y;
	return dx * dx + dy * dy;
}

float Vec2::length() const
{
	return std::sqrt(x * x + y * y);
}

float Vec2::lengthSquared() const
{
	return x * x + y * y;
}

float Vec2::angle() const
{
	return std::atan2(y, x);
}

void Vec2::normalize()
{
	float length = Vec2::length();
	x /= length;
	y /= length;
}

void Vec2::perp()
{
	*this = {-y, x};
}

void Vec2::clamp(const Vec2& from, const Vec2& to)
{
	x = Math::clamp(x, from.x, to.x);
	y = Math::clamp(y, from.y, to.y);
}

float Vec2::dot(const Vec2& vec) const
{
	return x * vec.x + y * vec.y;
}

Vec2 Vec2::normalize(const Vec2& vec)
{
	float length = vec.length();
	return {vec.x / length, vec.y / length};
}

Vec2 Vec2::perp(const Vec2& vec)
{
	return {-vec.y, vec.x};
}

Vec2 Vec2::from(const pr::Vec2& vec)
{
	return Vec2{vec[0], vec[0]};
}

// Size
const Size Size::zero{0.0f, 0.0f};

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

Size Size::operator*(const Vec2& vec) const
{
	return Size{width * vec.x, height * vec.y};
}

// Rect
const Rect Rect::zero;

Rect::Rect():
origin{},
size{}
{ }

Rect::Rect(const Vec2& origin, const Size& size):
origin(origin),
size(size)
{ }

Rect::Rect(float x, float y, float width, float height):
origin{x, y},
size{width, height}
{ }

Rect::Rect(const Rect& other):
origin(other.origin),
size(other.size)
{ }

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
	return Vec2{getLeft(), getBottom()};
}

void Rect::setLowerBound(const Vec2& point)
{
	setLeft(point.x);
	setBottom(point.y);
}

Vec2 Rect::getUpperBound() const
{
	return Vec2{getRight(), getTop()};
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

// AffineTransform
AffineTransform AffineTransform::Indentity = {1.0, 0.0, 0.0, 1.0, 0.0, 0.0};

Vec2 AffineTransform::applyPoint(const AffineTransform& t, const Vec2& point)
{
	return Vec2{
		t.a * point.x + t.c * point.y + t.tx,
		t.b * point.x + t.d * point.y + t.ty};
}

Size AffineTransform::applySize(const AffineTransform& t, const Size& size)
{
	return Size{
		t.a * size.width + t.c * size.height,
		t.b * size.width + t.d * size.height};
}

Rect AffineTransform::applyRect(const AffineTransform& t, const Rect& rect)
{
	float bottom = rect.getBottom();
	float left = rect.getLeft();
	float right = rect.getRight();
	float top = rect.getTop();

	Vec2 topLeft = applyPoint(t, Vec2{left, top});
	Vec2 topRight = applyPoint(t, Vec2{right, top});
	Vec2 bottomLeft = applyPoint(t, Vec2{left, bottom});
	Vec2 bottomRight = applyPoint(t, Vec2{right, bottom});

	float minX = std::min({topLeft.x, topRight.x, bottomLeft.x, bottomRight.x});
	float maxX = std::max({topLeft.x, topRight.x, bottomLeft.x, bottomRight.x});
	float minY = std::min({topLeft.y, topRight.y, bottomLeft.y, bottomRight.y});
	float maxY = std::max({topLeft.y, topRight.y, bottomLeft.y, bottomRight.y});

    return Rect(minX, minY, (maxX - minX), (maxY - minY));
}

AffineTransform AffineTransform::translate(const AffineTransform& t, float tx, float ty)
{
	return {t.a, t.b, t.c, t.d, t.tx + t.a * tx + t.c * ty, t.ty + t.b * tx + t.d * ty};
}

AffineTransform AffineTransform::rotate(const AffineTransform& t, float angle)
{
	float fSin = std::sin(angle);
	float fCos = std::cos(angle);
	return {
		t.a * fCos + t.c * fSin,
		t.b * fCos + t.d * fSin,
		t.c * fCos - t.a * fSin,
		t.d * fCos - t.b * fSin,
		t.tx,
		t.ty
	};
}

AffineTransform AffineTransform::scale(const AffineTransform& t, float sx, float sy)
{
	return {t.a * sx, t.b * sx, t.c * sy, t.d * sy, t.tx, t.ty};
}

AffineTransform AffineTransform::concat(const AffineTransform& t1, const AffineTransform& t2)
{
	return {
		t1.a * t2.a + t1.b * t2.c,
		t1.a * t2.b + t1.b * t2.d,
		t1.c * t2.a + t1.d * t2.c,
		t1.c * t2.b + t1.d * t2.d,
		t1.tx * t2.a + t1.ty * t2.c + t2.tx,
		t1.tx * t2.b + t1.ty * t2.d + t2.ty
	};
}

AffineTransform AffineTransform::invert(const AffineTransform& t)
{
	float determinant = 1.0f / (t.a * t.d - t.b * t.c);
    return {
		determinant * t.d,
		-determinant * t.b,
		-determinant * t.c,
		determinant * t.a,
		determinant * (t.c * t.ty - t.d * t.tx),
		determinant * (t.b * t.tx - t.a * t.ty)
	};
}

void AffineTransform::toMatrix(const AffineTransform& t, float* m)
{
    // | m[0] m[4] m[8]   m[12] |       | m11 m21 m31 m41 |       | a c 0 tx |
    // | m[1] m[5] m[9]   m[13] |       | m12 m22 m32 m42 |       | b d 0 ty |
    // | m[2] m[6] m[10] m[14] | => | m13 m23 m33 m43 | => | 0 0 1  0 |
    // | m[3] m[7] m[11] m[15] |       | m14 m24 m34 m44 |       | 0 0 0  1 |
    m[2] = m[3] = m[6] = m[7] = m[8] = m[9] = m[11] = m[14] = 0.0f;
    m[10] = m[15] = 1.0f;
    m[0] = t.a; m[4] = t.c; m[12] = t.tx;
    m[1] = t.b; m[5] = t.d; m[13] = t.ty;
}

const Matrix Matrix::Indentity = {
	1, 0, 0, 0,
	0, 1, 0, 0,
	0, 0, 1, 0,
	0, 0, 0, 1
};

NS_DOROTHY_END

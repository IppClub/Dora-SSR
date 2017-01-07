/* Copyright (c) 2013 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

struct Size;

struct Vec2
{
	float x;
	float y;
	Vec2();
	Vec2(float x, float y);
	Vec2(const Vec2& vec);
	//Vec2(const b2Vec2& v);
	//inline operator b2Vec2() const { return *(b2Vec2*)this; }
	void set(float x, float y);
	Vec2 operator+(const Vec2& vec) const;
	Vec2& operator+=(const Vec2& vec);
	Vec2 operator-(const Vec2& vec) const;
	Vec2& operator-=(const Vec2& vec);
	Vec2 operator*(float value) const;
	Vec2& operator*=(float value);
	Vec2 operator*(const Vec2& vec) const;
	Vec2& operator*=(const Vec2& vec);
	Vec2 operator/(float value) const;
	Vec2& operator/=(float value);
	bool operator==(const Vec2& vec) const;
	bool operator!=(const Vec2& vec) const;
	Vec2 operator*(const Size& size) const;
	float distance(const Vec2& vec) const;
	float distanceSquared(const Vec2& vec) const;
	float length() const;
	float lengthSquared() const;
	float angle() const;
	void normalize();
	void clamp(const Vec2& from, const Vec2& to);
	static const Vec2 zero;
	USE_MEMORY_POOL(Vec2);
	DORA_TYPE(Vec2);
};

struct Size
{
    float width;
    float height;
    Size();
    Size(float width, float height);
    Size(const Size& other);
	void set(float width, float height);
	Size& operator=(const Size& other);
	bool operator==(const Size& other) const;
	bool operator!=(const Size& other) const;
	Size operator*(const Vec2& vec) const;
	static const Size zero;
	DORA_TYPE(Size);
};

struct Rect
{
    Vec2 origin;
    Size size;
	PROPERTY(float, X);
	PROPERTY(float, Y);
	PROPERTY(float, Width);
	PROPERTY(float, Height);
	PROPERTY(float, Left);
	PROPERTY(float, Right);
	PROPERTY(float, CenterX);
	PROPERTY(float, CenterY);
	PROPERTY(float, Bottom);
	PROPERTY(float, Top);
	Rect();
	Rect(const Vec2& origin, const Size& size);
	Rect(float x, float y, float width, float height);
	Rect(const Rect& other);
	Rect& operator=(const Rect& other);
	bool operator==(const Rect& other) const;
	bool operator!=(const Rect& other) const;
	void setLowerBound(const Vec2& lowerBound);
	Vec2 getLowerBound() const;
	void setUpperBound(const Vec2& upperBound);
	Vec2 getUpperBound() const;
	void set(float x, float y, float width, float height);
    bool containsPoint(const Vec2& point) const;
	bool intersectsRect(const Rect& rect) const;
	static const Rect zero;
	DORA_TYPE(Rect);
};

struct AffineTransform
{
	float a, b, c, d;
	float tx, ty;
	static Vec2 applyPoint(const AffineTransform& t, const Vec2& point);
	static Size applySize(const AffineTransform& t, const Size& size);
	static Rect applyRect(const AffineTransform& t, const Rect& size);
	static AffineTransform translate(const AffineTransform& t, float tx, float ty);
	static AffineTransform rotate(const AffineTransform& t, float angle);
	static AffineTransform scale(const AffineTransform& t, float sx, float sy);
	static AffineTransform concat(const AffineTransform& t1, const AffineTransform& t2);
	static AffineTransform invert(const AffineTransform& t);
	static void toMatrix(const AffineTransform& t, float* matrix);
	static AffineTransform Indentity;
};

NS_DOROTHY_END

/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

namespace pr = playrho;

struct Size;

struct Vec2
{
	float x;
	float y;
	inline operator pr::Vec2() { return pr::Vec2{x, y}; }
	inline operator const pr::Vec2() const { return pr::Vec2{x, y}; }
	void set(float x, float y);
	Vec2 operator+(const Vec2& vec) const;
	Vec2& operator+=(const Vec2& vec);
	Vec2 operator-(const Vec2& vec) const;
	Vec2 operator-() const;
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
	void perp();
	void clamp(const Vec2& from, const Vec2& to);
	float dot(const Vec2& vec) const;
	static const Vec2 zero;
	static Vec2 normalize(const Vec2& vec);
	static Vec2 perp(const Vec2& vec);
	static Vec2 from(const pr::Vec2& vec);
	USE_MEMORY_POOL(Vec2);
};

struct Size
{
	float width;
	float height;
	void set(float width, float height);
	bool operator==(const Size& other) const;
	bool operator!=(const Size& other) const;
	Size operator*(const Vec2& vec) const;
	static const Size zero;
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

struct Vec3
{
	float x;
	float y;
	float z;
	inline operator const bx::Vec3() const
	{
		return *r_cast<const bx::Vec3*>(&x);
	}
	inline operator bx::Vec3()
	{
		return *r_cast<bx::Vec3*>(&x);
	}
	inline operator float*()
	{
		return &x;
	}
	inline operator const float*() const
	{
		return &x;
	}
	inline Vec2 toVec2() const
	{
		return Vec2{x, y};
	}
	inline operator Vec2() const
	{
		return Vec2{x, y};
	}
	static inline Vec3 from(const bx::Vec3& vec3)
	{
		return {vec3.x, vec3.y, vec3.z};
	}
};

struct Vec4
{
	float x;
	float y;
	float z;
	float w;
	inline operator float*()
	{
		return &x;
	}
	inline operator const float*() const
	{
		return &x;
	}
	inline Vec3 toVec3() const
	{
		return Vec3{x, y, z};
	}
	static Vec4 from(const Vec3& vec3, float w)
	{
		return {vec3.x, vec3.y, vec3.z, w};
	}
};

struct Matrix
{
	float m[16];
	inline operator float*()
	{
		return r_cast<float*>(this);
	}
	inline operator const float*() const
	{
		return r_cast<const float*>(this);
	}
	static const Matrix Indentity;
};

NS_DOROTHY_END

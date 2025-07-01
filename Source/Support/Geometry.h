/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "bx/math.h"
#include "playrho/d2/BasicAPI.hpp"

NS_DORA_BEGIN

namespace pr = playrho;

struct Size;

struct Vec2 {
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
	Vec2 operator/(const Vec2& vec) const;
	Vec2& operator/=(const Vec2& vec);
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
	static Vec2 clamp(const Vec2& vec, const Vec2& from, const Vec2& to);
	static float dot(const Vec2& vecA, const Vec2& vecB);
	static Vec2 from(const pr::Vec2& vec);
};

struct Size {
	float width;
	float height;
	void set(float width, float height);
	bool operator==(const Size& other) const;
	bool operator!=(const Size& other) const;
	Size operator*(const Vec2& vec) const;
	static const Size zero;
};

struct Rect {
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

struct Matrix;

struct alignas(16) AffineTransform {
	float a, b, c, d;
	float tx, ty;
	Vec2 applyPoint(const Vec2& point) const;
	Size applySize(const Size& size) const;
	Rect applyRect(const Rect& size) const;
	AffineTransform& translate(float tx, float ty);
	AffineTransform& rotate(float angle);
	AffineTransform& scale(float sx, float sy);
	AffineTransform& concat(const AffineTransform& t2);
	AffineTransform& invert();
	void toMatrix(Matrix& matrix) const;
	static AffineTransform Indentity;
};

struct alignas(16) Vec3 {
	float x;
	float y;
	float z;
	bool operator==(const Vec3& other) const = default;
	inline operator const bx::Vec3() const {
		return *r_cast<const bx::Vec3*>(&x);
	}
	inline operator bx::Vec3() {
		return *r_cast<bx::Vec3*>(&x);
	}
	inline Vec2 toVec2() const {
		return Vec2{x, y};
	}
	inline operator Vec2() const {
		return Vec2{x, y};
	}
	static inline Vec3 from(const bx::Vec3& vec3) {
		return {vec3.x, vec3.y, vec3.z};
	}
};

struct alignas(16) Vec4 {
	float x;
	float y;
	float z;
	float w;
	bool operator==(const Vec4& other) const = default;
	inline Vec3 toVec3() const {
		return Vec3{x, y, z};
	}
	static Vec4 from(const Vec3& vec3, float w) {
		return {vec3.x, vec3.y, vec3.z, w};
	}
};

struct AABB {
	Vec3 min;
	Vec3 max;
};

struct Plane {
	Vec3 normal;
	float distance;
};

struct Frustum {
	Plane planes[6];
	bool intersect(const AABB& aabb) const;
};

struct alignas(32) Matrix {
	float m[16];
	bool operator==(const Matrix& other) const = default;
	static void mulVec4(float* result, const Matrix& matrix, const Vec4& vec4);
	static void mulVec4(Vec4& result, const Matrix& matrix, const Vec4& vec4);
	static void mulMtx(Matrix& result, const Matrix& left, const Matrix& right);
	static void mulAABB(AABB& result, const Matrix& matrix, const AABB& right);
	static void mulAABB(AABB& result, const Matrix& matrix, float spriteWidth, float spriteHeight);
	static void toFrustum(Frustum& result, const Matrix& matrix);
	static void transpose(Matrix& result, const Matrix& matrix);
	static const Matrix Indentity;
};

NS_DORA_END

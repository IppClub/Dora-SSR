/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Support/Geometry.h"

#include "ktm/ktm.h"

NS_DORA_BEGIN

const Vec2 Vec2::zero{0.0f, 0.0f};

void Vec2::set(float x, float y) {
	Vec2::x = x;
	Vec2::y = y;
}

Vec2 Vec2::operator+(const Vec2& vec) const {
	return {x + vec.x, y + vec.y};
}

Vec2& Vec2::operator+=(const Vec2& vec) {
	x += vec.x;
	y += vec.y;
	return *this;
}

Vec2 Vec2::operator-(const Vec2& vec) const {
	return {x - vec.x, y - vec.y};
}

Vec2 Vec2::operator-() const {
	return {-x, -y};
}

Vec2& Vec2::operator-=(const Vec2& vec) {
	x -= vec.x;
	y -= vec.y;
	return *this;
}

Vec2 Vec2::operator*(float value) const {
	return {x * value, y * value};
}

Vec2& Vec2::operator*=(float value) {
	x *= value;
	y *= value;
	return *this;
}

Vec2 Vec2::operator*(const Vec2& vec) const {
	return {x * vec.x, y * vec.y};
}

Vec2& Vec2::operator*=(const Vec2& vec) {
	x *= vec.x;
	y *= vec.y;
	return *this;
}

Vec2 Vec2::operator/(float value) const {
	return {x / value, y / value};
}

Vec2& Vec2::operator/=(float value) {
	x /= value;
	y /= value;
	return *this;
}

Vec2 Vec2::operator/(const Vec2& vec) const {
	return {x / vec.x, y / vec.y};
}

Vec2& Vec2::operator/=(const Vec2& vec) {
	x /= vec.x;
	y /= vec.y;
	return *this;
}

bool Vec2::operator==(const Vec2& vec) const {
	return x == vec.x && y == vec.y;
}

bool Vec2::operator!=(const Vec2& vec) const {
	return x != vec.x || y != vec.y;
}

Vec2 Vec2::operator*(const Size& size) const {
	return {x * size.width, y * size.height};
}

float Vec2::distance(const Vec2& vec) const {
	float dx = x - vec.x;
	float dy = y - vec.y;
	return bx::sqrt(dx * dx + dy * dy);
}

float Vec2::distanceSquared(const Vec2& vec) const {
	float dx = x - vec.x;
	float dy = y - vec.y;
	return dx * dx + dy * dy;
}

float Vec2::length() const {
	return bx::sqrt(x * x + y * y);
}

float Vec2::lengthSquared() const {
	return x * x + y * y;
}

float Vec2::angle() const {
	return bx::toDeg(bx::atan2(y, x));
}

void Vec2::normalize() {
	float length = Vec2::length();
	if (length > 0) {
		x /= length;
		y /= length;
	}
}

void Vec2::perp() {
	*this = {-y, x};
}

void Vec2::clamp(const Vec2& from, const Vec2& to) {
	x = Math::clamp(x, from.x, to.x);
	y = Math::clamp(y, from.y, to.y);
}

float Vec2::dot(const Vec2& vec) const {
	return x * vec.x + y * vec.y;
}

Vec2 Vec2::normalize(const Vec2& vec) {
	float length = vec.length();
	if (length > 0) {
		return {vec.x / length, vec.y / length};
	}
	return {vec.x, vec.y};
}

Vec2 Vec2::perp(const Vec2& vec) {
	return {-vec.y, vec.x};
}

Vec2 Vec2::clamp(const Vec2& vec, const Vec2& from, const Vec2& to) {
	return {
		Math::clamp(vec.x, from.x, to.x),
		Math::clamp(vec.y, from.y, to.y)};
}

float Vec2::dot(const Vec2& vecA, const Vec2& vecB) {
	return vecA.dot(vecB);
}

Vec2 Vec2::from(const pr::Vec2& vec) {
	return Vec2{vec[0], vec[0]};
}

// Size
const Size Size::zero{0.0f, 0.0f};

void Size::set(float width, float height) {
	this->width = width;
	this->height = height;
}

bool Size::operator==(const Size& target) const {
	return width == target.width && height == target.height;
}

bool Size::operator!=(const Size& target) const {
	return width != target.width || height != target.height;
}

Size Size::operator*(const Vec2& vec) const {
	return Size{width * vec.x, height * vec.y};
}

// Rect
const Rect Rect::zero;

Rect::Rect()
	: origin{}
	, size{} { }

Rect::Rect(const Vec2& origin, const Size& size)
	: origin(origin)
	, size(size) { }

Rect::Rect(float x, float y, float width, float height)
	: origin{x, y}
	, size{width, height} { }

Rect::Rect(const Rect& other)
	: origin(other.origin)
	, size(other.size) { }

void Rect::set(float x, float y, float width, float height) {
	origin.x = x;
	origin.y = y;
	size.width = width;
	size.height = height;
}

float Rect::getX() const noexcept {
	return origin.x;
}

void Rect::setX(float x) {
	origin.x = x;
}

float Rect::getY() const noexcept {
	return origin.y;
}

void Rect::setY(float y) {
	origin.y = y;
}

float Rect::getWidth() const noexcept {
	return size.width;
}

void Rect::setWidth(float width) {
	size.width = width;
}

float Rect::getHeight() const noexcept {
	return size.height;
}

void Rect::setHeight(float height) {
	size.height = height;
}

bool Rect::operator==(const Rect& rect) const {
	return origin == rect.origin && size == rect.size;
}

bool Rect::operator!=(const Rect& rect) const {
	return origin != rect.origin || size != rect.size;
}

float Rect::getRight() const noexcept {
	return origin.x + size.width;
}

void Rect::setRight(float right) {
	size.width = right - getLeft();
}

float Rect::getCenterX() const noexcept {
	return origin.x + size.width * 0.5f;
}

void Rect::setCenterX(float centerX) {
	origin.x = centerX - size.width * 0.5f;
}

float Rect::getLeft() const noexcept {
	return origin.x;
}

void Rect::setLeft(float left) {
	float right = getRight();
	origin.x = left;
	size.width = right - left;
}

float Rect::getTop() const noexcept {
	return origin.y + size.height;
}

void Rect::setTop(float top) {
	size.height = top - getBottom();
}

float Rect::getCenterY() const noexcept {
	return origin.y + size.height * 0.5f;
}

void Rect::setCenterY(float centerY) {
	origin.y = centerY - size.height * 0.5f;
}

float Rect::getBottom() const noexcept {
	return origin.y;
}

void Rect::setBottom(float bottom) {
	float top = getTop();
	origin.y = bottom;
	size.height = top - bottom;
}

Vec2 Rect::getLowerBound() const {
	return Vec2{getLeft(), getBottom()};
}

void Rect::setLowerBound(const Vec2& point) {
	setLeft(point.x);
	setBottom(point.y);
}

Vec2 Rect::getUpperBound() const {
	return Vec2{getRight(), getTop()};
}

void Rect::setUpperBound(const Vec2& point) {
	setRight(point.x);
	setTop(point.y);
}

bool Rect::containsPoint(const Vec2& point) const {
	return (point.x >= getLeft() && point.x <= getRight()
			&& point.y >= getBottom() && point.y <= getTop());
}

bool Rect::intersectsRect(const Rect& rect) const {
	return !(getRight() < rect.getLeft() || rect.getRight() < getLeft() || getTop() < rect.getBottom() || rect.getTop() < getBottom());
}

// AffineTransform

static_assert(alignof(AffineTransform) >= alignof(ktm::faffine2d), "alignof(AffineTransform) should be greater equal than alignof(ktm::faffine2d).");

AffineTransform AffineTransform::Indentity = {1.0, 0.0, 0.0, 1.0, 0.0, 0.0};

Vec2 AffineTransform::applyPoint(const Vec2& point) const {
	const ktm::faffine2d& ktm_affine = *r_cast<const ktm::faffine2d*>(this);
	ktm::fvec2 ret = r_cast<const ktm::fmat2x2&>(ktm_affine.m) * r_cast<const ktm::fvec2&>(point) + ktm_affine.m[2];
	return r_cast<Vec2&>(ret);
}

Size AffineTransform::applySize(const Size& size) const {
	ktm::fvec2 ret = *r_cast<const ktm::fmat2x2*>(this) * r_cast<const ktm::fvec2&>(size);
	return r_cast<Size&>(ret);
}

Rect AffineTransform::applyRect(const Rect& rect) const {
	float bottom = rect.getBottom();
	float left = rect.getLeft();
	float right = rect.getRight();
	float top = rect.getTop();

	Vec2 topLeft = applyPoint({left, top});
	Vec2 topRight = applyPoint({right, top});
	Vec2 bottomLeft = applyPoint({left, bottom});
	Vec2 bottomRight = applyPoint({right, bottom});

	float minX = ktm::reduce_min(ktm::fvec4{topLeft.x, topRight.x, bottomLeft.x, bottomRight.x});
	float maxX = ktm::reduce_max(ktm::fvec4{topLeft.x, topRight.x, bottomLeft.x, bottomRight.x});
	float minY = ktm::reduce_min(ktm::fvec4{topLeft.y, topRight.y, bottomLeft.y, bottomRight.y});
	float maxY = ktm::reduce_max(ktm::fvec4{topLeft.y, topRight.y, bottomLeft.y, bottomRight.y});

	return Rect(minX, minY, (maxX - minX), (maxY - minY));
}

AffineTransform& AffineTransform::translate(float tx, float ty) {
	r_cast<ktm::faffine2d*>(this)->translate(tx, ty);
	return *this;
}

AffineTransform& AffineTransform::rotate(float angle) {
	r_cast<ktm::faffine2d*>(this)->rotate(angle);
	return *this;
}

AffineTransform& AffineTransform::scale(float sx, float sy) {
	r_cast<ktm::faffine2d*>(this)->scale(sx, sy);
	return *this;
}

AffineTransform& AffineTransform::concat(const AffineTransform& t2) {
	r_cast<ktm::faffine2d*>(this)->concat(r_cast<const ktm::faffine2d&>(t2));
	return *this;
}

AffineTransform& AffineTransform::invert() {
	r_cast<ktm::faffine2d*>(this)->invert();
	return *this;
}

void AffineTransform::toMatrix(Matrix& m) const {
	// | m[0] m[4] m[8]   m[12] |       | m11 m21 m31 m41 |       | a c 0 tx |
	// | m[1] m[5] m[9]   m[13] |       | m12 m22 m32 m42 |       | b d 0 ty |
	// | m[2] m[6] m[10]  m[14] | =>    | m13 m23 m33 m43 | =>    | 0 0 1  0 |
	// | m[3] m[7] m[11]  m[15] |       | m14 m24 m34 m44 |       | 0 0 0  1 |
	ktm::fmat4x4& mat = r_cast<ktm::fmat4x4&>(m);
	*r_cast<const ktm::faffine2d*>(this) >> mat;
}

static_assert(alignof(Matrix) >= alignof(ktm::fmat4x4), "alignof(Matrix) should be greater equal than alignof(ktm::fmat4x4).");

static_assert(alignof(Vec4) >= alignof(ktm::fvec4), "alignof(Vec4) should be greater equal than alignof(ktm::fvec4).");

static_assert(alignof(Vec3) >= alignof(ktm::fvec3), "alignof(Vec3) should be greater equal than alignof(ktm::fvec3).");

const Matrix Matrix::Indentity = {
	1, 0, 0, 0,
	0, 1, 0, 0,
	0, 0, 1, 0,
	0, 0, 0, 1};

void Matrix::mulVec4(float* result, const Matrix& matrix, const Vec4& vec4) {
	auto mat = r_cast<const ktm::fmat4x4&>(matrix);
	auto v4 = r_cast<const ktm::fvec4&>(vec4);
	ktm::fvec4 output = mat * v4;
	std::memcpy(result, &output.x, sizeof(float) * 4);
}

void Matrix::mulVec4(Vec4& result, const Matrix& matrix, const Vec4& vec4) {
	auto mat = r_cast<const ktm::fmat4x4&>(matrix);
	auto v4 = r_cast<const ktm::fvec4&>(vec4);
	ktm::fvec4& output = r_cast<ktm::fvec4&>(result);
	output = mat * v4;
}

void Matrix::mulMtx(Matrix& result, const Matrix& left, const Matrix& right) {
	auto lMat = r_cast<const ktm::fmat4x4&>(left);
	auto rMat = r_cast<const ktm::fmat4x4&>(right);
	ktm::fmat4x4& output = r_cast<ktm::fmat4x4&>(result);
	output = lMat * rMat;
}

void Matrix::mulAABB(AABB& result, const Matrix& matrix, const AABB& right) {
	auto mat = r_cast<const ktm::fmat4x4&>(matrix);

	ktm::fvec4 corners[8] = {
		{right.min.x, right.min.y, right.min.z, 1.0f},
		{right.min.x, right.min.y, right.max.z, 1.0f},
		{right.min.x, right.max.y, right.min.z, 1.0f},
		{right.min.x, right.max.y, right.max.z, 1.0f},
		{right.max.x, right.min.y, right.min.z, 1.0f},
		{right.max.x, right.min.y, right.max.z, 1.0f},
		{right.max.x, right.max.y, right.min.z, 1.0f},
		{right.max.x, right.max.y, right.max.z, 1.0f}};

	auto corner = mat * corners[0];
	result.min = result.max = *r_cast<Vec3*>(&corner);

	for (int i = 1; i < 8; ++i) {
		auto corner = mat * corners[i];
		auto [minX, maxX] = std::minmax({result.min.x, result.max.x, corner.x});
		auto [minY, maxY] = std::minmax({result.min.y, result.max.y, corner.y});
		auto [minZ, maxZ] = std::minmax({result.min.z, result.max.z, corner.z});
		result.min = {minX, minY, minZ};
		result.max = {maxX, maxY, maxZ};
	}
}

void Matrix::mulAABB(AABB& result, const Matrix& matrix, float spriteWidth, float spriteHeight) {
	auto mat = r_cast<const ktm::fmat4x4&>(matrix);

	ktm::fvec4 corners[4] = {
		{0, 0, 0, 1.0f},
		{0, spriteHeight, 0, 1.0f},
		{spriteWidth, spriteHeight, 0, 1.0f},
		{spriteWidth, 0, 0, 1.0f}};

	auto corner = mat * corners[0];
	result.min = result.max = *r_cast<Vec3*>(&corner);

	for (int i = 1; i < 4; ++i) {
		auto corner = mat * corners[i];
		auto [minX, maxX] = std::minmax({result.min.x, result.max.x, corner.x});
		auto [minY, maxY] = std::minmax({result.min.y, result.max.y, corner.y});
		auto [minZ, maxZ] = std::minmax({result.min.z, result.max.z, corner.z});
		result.min = {minX, minY, minZ};
		result.max = {maxX, maxY, maxZ};
	}
}

void Matrix::toFrustum(Frustum& result, const Matrix& matrix) {
	auto viewProjMatrix = r_cast<const ktm::fmat4x4&>(matrix);

	// Left plane
	result.planes[0].normal.x = viewProjMatrix[0][3] + viewProjMatrix[0][0];
	result.planes[0].normal.y = viewProjMatrix[1][3] + viewProjMatrix[1][0];
	result.planes[0].normal.z = viewProjMatrix[2][3] + viewProjMatrix[2][0];
	result.planes[0].distance = viewProjMatrix[3][3] + viewProjMatrix[3][0];

	// Right plane
	result.planes[1].normal.x = viewProjMatrix[0][3] - viewProjMatrix[0][0];
	result.planes[1].normal.y = viewProjMatrix[1][3] - viewProjMatrix[1][0];
	result.planes[1].normal.z = viewProjMatrix[2][3] - viewProjMatrix[2][0];
	result.planes[1].distance = viewProjMatrix[3][3] - viewProjMatrix[3][0];

	// Bottom plane
	result.planes[2].normal.x = viewProjMatrix[0][3] + viewProjMatrix[0][1];
	result.planes[2].normal.y = viewProjMatrix[1][3] + viewProjMatrix[1][1];
	result.planes[2].normal.z = viewProjMatrix[2][3] + viewProjMatrix[2][1];
	result.planes[2].distance = viewProjMatrix[3][3] + viewProjMatrix[3][1];

	// Top plane
	result.planes[3].normal.x = viewProjMatrix[0][3] - viewProjMatrix[0][1];
	result.planes[3].normal.y = viewProjMatrix[1][3] - viewProjMatrix[1][1];
	result.planes[3].normal.z = viewProjMatrix[2][3] - viewProjMatrix[2][1];
	result.planes[3].distance = viewProjMatrix[3][3] - viewProjMatrix[3][1];

	// Near plane
	result.planes[4].normal.x = viewProjMatrix[0][3] + viewProjMatrix[0][2];
	result.planes[4].normal.y = viewProjMatrix[1][3] + viewProjMatrix[1][2];
	result.planes[4].normal.z = viewProjMatrix[2][3] + viewProjMatrix[2][2];
	result.planes[4].distance = viewProjMatrix[3][3] + viewProjMatrix[3][2];

	// Far plane
	result.planes[5].normal.x = viewProjMatrix[0][3] - viewProjMatrix[0][2];
	result.planes[5].normal.y = viewProjMatrix[1][3] - viewProjMatrix[1][2];
	result.planes[5].normal.z = viewProjMatrix[2][3] - viewProjMatrix[2][2];
	result.planes[5].distance = viewProjMatrix[3][3] - viewProjMatrix[3][2];

	// Normalize the planes
	for (auto& plane : result.planes) {
		float length = ktm::length(*r_cast<ktm::fvec3*>(&plane.normal));
		plane.normal.x /= length;
		plane.normal.y /= length;
		plane.normal.z /= length;
		plane.distance /= length;
	}
}

void Matrix::transpose(Matrix& result, const Matrix& matrix) {
	ktm::fmat4x4& output = r_cast<ktm::fmat4x4&>(result);
	auto mat = r_cast<const ktm::fmat4x4&>(matrix);
	output = ktm::transpose(mat);
}

bool Frustum::intersect(const AABB& aabb) const {
	for (const auto& plane : planes) {
		auto p = aabb.min;
		if (plane.normal.x >= 0) p.x = aabb.max.x;
		if (plane.normal.y >= 0) p.y = aabb.max.y;
		if (plane.normal.z >= 0) p.z = aabb.max.z;
		auto result = ktm::dot(*r_cast<const ktm::fvec3*>(&plane.normal), *r_cast<const ktm::fvec3*>(&p));
		if (result + plane.distance < 0) {
			return false;
		}
	}
	return true;
}

NS_DORA_END

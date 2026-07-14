/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Light3D.h"

#ifndef DORA_NO_RUST
extern "C" {
int32_t dora_3d_directional_light_create(uint64_t node);
void dora_3d_directional_light_set_color(uint64_t node, float r, float g, float b);
void dora_3d_directional_light_get_color(uint64_t node, float* out);
void dora_3d_directional_light_set_intensity(uint64_t node, float intensity);
float dora_3d_directional_light_get_intensity(uint64_t node);
void dora_3d_directional_light_set_cast_shadow(uint64_t node, int32_t enabled);
int32_t dora_3d_directional_light_get_cast_shadow(uint64_t node);
void dora_3d_directional_light_set_shadow_bias(uint64_t node, float bias);
float dora_3d_directional_light_get_shadow_bias(uint64_t node);
void dora_3d_directional_light_set_shadow_normal_bias(uint64_t node, float bias);
float dora_3d_directional_light_get_shadow_normal_bias(uint64_t node);
void dora_3d_directional_light_set_shadow_softness(uint64_t node, float softness);
float dora_3d_directional_light_get_shadow_softness(uint64_t node);
int32_t dora_3d_point_light_create(uint64_t node);
void dora_3d_point_light_set_color(uint64_t node, float r, float g, float b);
void dora_3d_point_light_get_color(uint64_t node, float* out);
void dora_3d_point_light_set_intensity(uint64_t node, float intensity);
float dora_3d_point_light_get_intensity(uint64_t node);
void dora_3d_point_light_set_range(uint64_t node, float range);
float dora_3d_point_light_get_range(uint64_t node);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

bool DirectionalLight3D::init() {
	if (!Node3D::init()) return false;
#ifdef DORA_NO_RUST
	return false;
#else
	return dora_3d_directional_light_create(getHandle()) != 0;
#endif
}

void DirectionalLight3D::setColor(Color3 color) {
#ifndef DORA_NO_RUST
	auto value = color.toVec3();
	dora_3d_directional_light_set_color(getHandle(), value.x, value.y, value.z);
#endif
}

Color3 DirectionalLight3D::getColor() const noexcept {
#ifndef DORA_NO_RUST
	float value[3] = {};
	dora_3d_directional_light_get_color(getHandle(), value);
	return Color3{Vec3{value[0], value[1], value[2]}};
#else
	return Color3{};
#endif
}

void DirectionalLight3D::setIntensity(float intensity) {
#ifndef DORA_NO_RUST
	dora_3d_directional_light_set_intensity(getHandle(), intensity);
#endif
}

float DirectionalLight3D::getIntensity() const noexcept {
#ifndef DORA_NO_RUST
	return dora_3d_directional_light_get_intensity(getHandle());
#else
	return 0.0f;
#endif
}

void DirectionalLight3D::setCastShadow(bool enabled) {
#ifndef DORA_NO_RUST
	dora_3d_directional_light_set_cast_shadow(getHandle(), enabled ? 1 : 0);
#endif
}

bool DirectionalLight3D::isCastShadow() const noexcept {
#ifndef DORA_NO_RUST
	return dora_3d_directional_light_get_cast_shadow(getHandle()) != 0;
#else
	return false;
#endif
}

void DirectionalLight3D::setShadowBias(float bias) {
#ifndef DORA_NO_RUST
	dora_3d_directional_light_set_shadow_bias(getHandle(), bias);
#endif
}

float DirectionalLight3D::getShadowBias() const noexcept {
#ifndef DORA_NO_RUST
	return dora_3d_directional_light_get_shadow_bias(getHandle());
#else
	return 0.0f;
#endif
}

void DirectionalLight3D::setShadowNormalBias(float bias) {
#ifndef DORA_NO_RUST
	dora_3d_directional_light_set_shadow_normal_bias(getHandle(), bias);
#endif
}

float DirectionalLight3D::getShadowNormalBias() const noexcept {
#ifndef DORA_NO_RUST
	return dora_3d_directional_light_get_shadow_normal_bias(getHandle());
#else
	return 0.0f;
#endif
}

void DirectionalLight3D::setShadowSoftness(float softness) {
#ifndef DORA_NO_RUST
	dora_3d_directional_light_set_shadow_softness(getHandle(), softness);
#endif
}

float DirectionalLight3D::getShadowSoftness() const noexcept {
#ifndef DORA_NO_RUST
	return dora_3d_directional_light_get_shadow_softness(getHandle());
#else
	return 0.0f;
#endif
}

bool PointLight3D::init() {
	if (!Node3D::init()) return false;
#ifdef DORA_NO_RUST
	return false;
#else
	return dora_3d_point_light_create(getHandle()) != 0;
#endif
}

void PointLight3D::setColor(Color3 color) {
#ifndef DORA_NO_RUST
	auto value = color.toVec3();
	dora_3d_point_light_set_color(getHandle(), value.x, value.y, value.z);
#endif
}

Color3 PointLight3D::getColor() const noexcept {
#ifndef DORA_NO_RUST
	float value[3] = {};
	dora_3d_point_light_get_color(getHandle(), value);
	return Color3{Vec3{value[0], value[1], value[2]}};
#else
	return Color3{};
#endif
}

void PointLight3D::setIntensity(float intensity) {
#ifndef DORA_NO_RUST
	dora_3d_point_light_set_intensity(getHandle(), intensity);
#endif
}

float PointLight3D::getIntensity() const noexcept {
#ifndef DORA_NO_RUST
	return dora_3d_point_light_get_intensity(getHandle());
#else
	return 0.0f;
#endif
}

void PointLight3D::setRange(float range) {
#ifndef DORA_NO_RUST
	dora_3d_point_light_set_range(getHandle(), range);
#endif
}

float PointLight3D::getRange() const noexcept {
#ifndef DORA_NO_RUST
	return dora_3d_point_light_get_range(getHandle());
#else
	return 0.0f;
#endif
}

NS_DORA_END

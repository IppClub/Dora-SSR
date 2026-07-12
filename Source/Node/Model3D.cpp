/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Model3D.h"

#include "Cache/Model3DCache.h"
#include "Cache/TextureCache.h"

#ifndef DORA_NO_RUST
extern "C" {
uint64_t dora_3d_model_instantiate(uint64_t model, uint64_t node);
void dora_3d_model_instance_destroy(uint64_t instance);
uint32_t dora_3d_model_instance_animation_count(uint64_t instance);
uint32_t dora_3d_model_instance_animation_name(uint64_t instance, uint32_t index, char* output, uint32_t capacity);
int32_t dora_3d_model_instance_has_node(uint64_t instance, const char* name);
int32_t dora_3d_model_instance_attach_to_node(uint64_t instance, const char* name, uint64_t child);
int32_t dora_3d_model_instance_bounds(uint64_t instance, int32_t worldSpace, float* min, float* max);
uint32_t dora_3d_model_instance_material_count(uint64_t instance);
int32_t dora_3d_model_instance_material_get_base_color(uint64_t instance, uint32_t index, float* output);
int32_t dora_3d_model_instance_material_set_base_color(uint64_t instance, uint32_t index, float r, float g, float b, float a);
int32_t dora_3d_model_instance_material_get_emissive(uint64_t instance, uint32_t index, float* output);
int32_t dora_3d_model_instance_material_set_emissive(uint64_t instance, uint32_t index, float r, float g, float b);
int32_t dora_3d_model_instance_material_get_pbr(uint64_t instance, uint32_t index, float* metallic, float* roughness);
int32_t dora_3d_model_instance_material_set_pbr(uint64_t instance, uint32_t index, float metallic, float roughness);
int32_t dora_3d_model_instance_material_get_alpha(uint64_t instance, uint32_t index, float* alphaCutoff);
int32_t dora_3d_model_instance_material_set_alpha(uint64_t instance, uint32_t index, uint8_t alphaMode, float alphaCutoff);
int32_t dora_3d_model_instance_material_set_texture(uint64_t instance, uint32_t index, uint8_t slot, uint16_t bgfxTexture);
float dora_3d_model_play(uint64_t instance, const char* name, int32_t looping);
void dora_3d_model_stop(uint64_t instance);
void dora_3d_model_pause(uint64_t instance);
void dora_3d_model_resume(uint64_t instance);
int32_t dora_3d_model_is_paused(uint64_t instance);
void dora_3d_model_set_speed(uint64_t instance, float speed);
float dora_3d_model_get_speed(uint64_t instance);
float dora_3d_model_get_elapsed(uint64_t instance);
float dora_3d_model_get_duration(uint64_t instance);
int32_t dora_3d_model_update(uint64_t instance, float delta_time);
float dora_3d_model_instance_ray_cast(uint64_t instance, float origin_x, float origin_y, float origin_z, float direction_x, float direction_y, float direction_z);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

Material3D::Material3D(NotNull<Model3D, 1> model, uint32_t index)
	: _model(model)
	, _index(index) { }

void Material3D::setBaseColor(Color color) {
#ifndef DORA_NO_RUST
	if (_model && _model->_instance != 0) {
		auto value = color.toVec4();
		dora_3d_model_instance_material_set_base_color(
			_model->_instance, _index, value.x, value.y, value.z, value.w);
	}
#endif // DORA_NO_RUST
}

Color Material3D::getBaseColor() const noexcept {
#ifdef DORA_NO_RUST
	return Color::White;
#else
	Vec4 value{1.0f, 1.0f, 1.0f, 1.0f};
	if (_model && _model->_instance != 0) {
		dora_3d_model_instance_material_get_base_color(_model->_instance, _index, &value.x);
	}
	return Color(value);
#endif // DORA_NO_RUST
}

void Material3D::setEmissive(Color3 color) {
#ifndef DORA_NO_RUST
	if (_model && _model->_instance != 0) {
		auto value = color.toVec3();
		dora_3d_model_instance_material_set_emissive(
			_model->_instance, _index, value.x, value.y, value.z);
	}
#endif // DORA_NO_RUST
}

Color3 Material3D::getEmissive() const noexcept {
#ifdef DORA_NO_RUST
	return Color3{};
#else
	Vec3 value;
	if (_model && _model->_instance != 0) {
		dora_3d_model_instance_material_get_emissive(_model->_instance, _index, &value.x);
	}
	return Color3(value);
#endif // DORA_NO_RUST
}

void Material3D::setMetallic(float metallic) {
#ifndef DORA_NO_RUST
	if (_model && _model->_instance != 0) {
		float currentMetallic = 0.0f;
		float roughness = 1.0f;
		dora_3d_model_instance_material_get_pbr(
			_model->_instance, _index, &currentMetallic, &roughness);
		dora_3d_model_instance_material_set_pbr(
			_model->_instance, _index, metallic, roughness);
	}
#endif // DORA_NO_RUST
}

float Material3D::getMetallic() const noexcept {
#ifdef DORA_NO_RUST
	return 0.0f;
#else
	float metallic = 0.0f;
	float roughness = 1.0f;
	if (_model && _model->_instance != 0) {
		dora_3d_model_instance_material_get_pbr(
			_model->_instance, _index, &metallic, &roughness);
	}
	return metallic;
#endif // DORA_NO_RUST
}

void Material3D::setRoughness(float roughness) {
#ifndef DORA_NO_RUST
	if (_model && _model->_instance != 0) {
		float metallic = 0.0f;
		float currentRoughness = 1.0f;
		dora_3d_model_instance_material_get_pbr(
			_model->_instance, _index, &metallic, &currentRoughness);
		dora_3d_model_instance_material_set_pbr(
			_model->_instance, _index, metallic, roughness);
	}
#endif // DORA_NO_RUST
}

float Material3D::getRoughness() const noexcept {
#ifdef DORA_NO_RUST
	return 1.0f;
#else
	float metallic = 0.0f;
	float roughness = 1.0f;
	if (_model && _model->_instance != 0) {
		dora_3d_model_instance_material_get_pbr(
			_model->_instance, _index, &metallic, &roughness);
	}
	return roughness;
#endif // DORA_NO_RUST
}

void Material3D::setAlphaMode(MaterialAlphaMode3D mode) {
#ifndef DORA_NO_RUST
	if (_model && _model->_instance != 0) {
		float alphaCutoff = 0.5f;
		dora_3d_model_instance_material_get_alpha(_model->_instance, _index, &alphaCutoff);
		dora_3d_model_instance_material_set_alpha(
			_model->_instance, _index, s_cast<uint8_t>(mode), alphaCutoff);
	}
#endif // DORA_NO_RUST
}

MaterialAlphaMode3D Material3D::getAlphaMode() const noexcept {
#ifdef DORA_NO_RUST
	return MaterialAlphaMode3D::Opaque;
#else
	float alphaCutoff = 0.5f;
	if (_model && _model->_instance != 0) {
		auto mode = dora_3d_model_instance_material_get_alpha(
			_model->_instance, _index, &alphaCutoff);
		if (mode >= 0 && mode <= 2) return s_cast<MaterialAlphaMode3D>(mode);
	}
	return MaterialAlphaMode3D::Opaque;
#endif // DORA_NO_RUST
}

void Material3D::setAlphaModeValue(uint8_t mode) {
	AssertIf(mode > s_cast<uint8_t>(MaterialAlphaMode3D::Blend),
		"Invalid MaterialAlphaMode3D value {}.", mode);
	setAlphaMode(s_cast<MaterialAlphaMode3D>(mode));
}

uint8_t Material3D::getAlphaModeValue() const noexcept {
	return s_cast<uint8_t>(getAlphaMode());
}

void Material3D::setAlphaCutoff(float alphaCutoff) {
#ifndef DORA_NO_RUST
	if (_model && _model->_instance != 0) {
		float currentAlphaCutoff = 0.5f;
		auto mode = dora_3d_model_instance_material_get_alpha(
			_model->_instance, _index, &currentAlphaCutoff);
		if (mode >= 0) {
			dora_3d_model_instance_material_set_alpha(
				_model->_instance, _index, s_cast<uint8_t>(mode), alphaCutoff);
		}
	}
#endif // DORA_NO_RUST
}

float Material3D::getAlphaCutoff() const noexcept {
#ifdef DORA_NO_RUST
	return 0.5f;
#else
	float alphaCutoff = 0.5f;
	if (_model && _model->_instance != 0) {
		dora_3d_model_instance_material_get_alpha(_model->_instance, _index, &alphaCutoff);
	}
	return alphaCutoff;
#endif // DORA_NO_RUST
}

void Material3D::setTexture(uint8_t slot, Texture2D* texture) {
	if (slot >= _textures.size()) return;
	_textures[slot] = texture;
#ifndef DORA_NO_RUST
	if (_model && _model->_instance != 0) {
		auto handle = texture ? texture->getHandle().idx : UINT16_MAX;
		dora_3d_model_instance_material_set_texture(_model->_instance, _index, slot, handle);
	}
#endif // DORA_NO_RUST
}

void Material3D::setBaseColorTexture(Texture2D* texture) {
	setTexture(0, texture);
}

void Material3D::clearBaseColorTexture() {
	setTexture(0, nullptr);
}

void Material3D::setMetallicRoughnessTexture(Texture2D* texture) {
	setTexture(1, texture);
}

void Material3D::clearMetallicRoughnessTexture() {
	setTexture(1, nullptr);
}

void Material3D::setNormalTexture(Texture2D* texture) {
	setTexture(2, texture);
}

void Material3D::clearNormalTexture() {
	setTexture(2, nullptr);
}

void Material3D::setEmissiveTexture(Texture2D* texture) {
	setTexture(3, texture);
}

void Material3D::clearEmissiveTexture() {
	setTexture(3, nullptr);
}

void Material3D::setOcclusionTexture(Texture2D* texture) {
	setTexture(4, texture);
}

void Material3D::clearOcclusionTexture() {
	setTexture(4, nullptr);
}

void Material3D::clearModel() {
	_model = nullptr;
	for (auto& texture : _textures) texture = nullptr;
}

void Material3D::cleanup() {
	clearModel();
	Object::cleanup();
}

Model3D::Model3D()
	: _instance(0)
	, _playing(false)
	, _paused(false) { }

Model3D::Model3D(String path)
	: _filename(path.toString())
	, _instance(0)
	, _playing(false)
	, _paused(false) { }

Model3D::~Model3D() {
	stop();
	destroyInstance();
}

void Model3D::destroyInstance() {
#ifndef DORA_NO_RUST
	if (_instance != 0) {
		for (auto& material : _materials) {
			if (material) material->clearModel();
		}
		_materials.clear();
		dora_3d_model_instance_destroy(_instance);
		_instance = 0;
	}
#endif // DORA_NO_RUST
}

float Model3D::rayCast(const Vec3& origin, const Vec3& direction) const {
#ifdef DORA_NO_RUST
	return -1.0f;
#else
	if (_instance == 0) return -1.0f;
	return dora_3d_model_instance_ray_cast(
		_instance,
		origin.x,
		origin.y,
		origin.z,
		direction.x,
		direction.y,
		direction.z);
#endif // DORA_NO_RUST
}

bool Model3D::init() {
	if (!Node3D::init()) return false;
#ifdef DORA_NO_RUST
	return false;
#else
	_modelDef = SharedModel3DCache.load(_filename);
	if (!_modelDef) return false;
	_instance = dora_3d_model_instantiate(_modelDef->getHandle(), getHandle());
	return _instance != 0;
#endif // DORA_NO_RUST
}

bool Model3D::isPlaying() const noexcept {
	return _playing;
}

bool Model3D::isPaused() const noexcept {
	return _paused;
}

uint32_t Model3D::getAnimationCount() const noexcept {
#ifdef DORA_NO_RUST
	return 0;
#else
	return _instance != 0 ? dora_3d_model_instance_animation_count(_instance) : 0;
#endif // DORA_NO_RUST
}

uint32_t Model3D::getMaterialCount() const noexcept {
#ifdef DORA_NO_RUST
	return 0;
#else
	return _instance != 0 ? dora_3d_model_instance_material_count(_instance) : 0;
#endif // DORA_NO_RUST
}

Material3D* Model3D::getMaterial(uint32_t index) {
	if (_instance == 0 || index >= getMaterialCount()) return nullptr;
	if (_materials.size() <= index) _materials.resize(index + 1);
	if (!_materials[index]) {
		_materials[index] = Object::create<Material3D>(this, index);
	}
	return _materials[index].get();
}

std::string Model3D::getAnimationName(uint32_t index) const {
#ifdef DORA_NO_RUST
	return {};
#else
	if (_instance == 0) return {};
	auto size = dora_3d_model_instance_animation_name(_instance, index, nullptr, 0);
	if (size == 0) return {};
	std::string name(size + 1, '\0');
	dora_3d_model_instance_animation_name(_instance, index, name.data(), size + 1);
	name.resize(size);
	return name;
#endif // DORA_NO_RUST
}

bool Model3D::hasNode(String name) const {
#ifdef DORA_NO_RUST
	return false;
#else
	if (_instance == 0) return false;
	auto value = name.toString();
	return dora_3d_model_instance_has_node(_instance, value.c_str()) != 0;
#endif // DORA_NO_RUST
}

bool Model3D::attachToNode(String name, NotNull<Node3D, 2> child) {
#ifdef DORA_NO_RUST
	return false;
#else
	if (_instance == 0) return false;
	auto value = name.toString();
	return dora_3d_model_instance_attach_to_node(
		_instance, value.c_str(), child->getHandle()) != 0;
#endif // DORA_NO_RUST
}

bool Model3D::getBounds(bool worldSpace, Vec3& min, Vec3& max) const {
#ifdef DORA_NO_RUST
	return false;
#else
	if (_instance == 0) return false;
	return dora_3d_model_instance_bounds(
		_instance, worldSpace ? 1 : 0, &min.x, &max.x) != 0;
#endif // DORA_NO_RUST
}

Vec3 Model3D::getLocalBoundsMin() const {
	Vec3 min;
	Vec3 max;
	return getBounds(false, min, max) ? min : Vec3{};
}

Vec3 Model3D::getLocalBoundsMax() const {
	Vec3 min;
	Vec3 max;
	return getBounds(false, min, max) ? max : Vec3{};
}

Vec3 Model3D::getWorldBoundsMin() const {
	Vec3 min;
	Vec3 max;
	return getBounds(true, min, max) ? min : Vec3{};
}

Vec3 Model3D::getWorldBoundsMax() const {
	Vec3 min;
	Vec3 max;
	return getBounds(true, min, max) ? max : Vec3{};
}

void Model3D::setSpeed(float speed) {
#ifndef DORA_NO_RUST
	if (_instance != 0) {
		dora_3d_model_set_speed(_instance, speed);
	}
#endif // DORA_NO_RUST
}

float Model3D::getSpeed() const noexcept {
#ifdef DORA_NO_RUST
	return 1.0f;
#else
	return _instance != 0 ? dora_3d_model_get_speed(_instance) : 1.0f;
#endif // DORA_NO_RUST
}

float Model3D::getDuration() const noexcept {
#ifdef DORA_NO_RUST
	return 0.0f;
#else
	return _instance != 0 ? dora_3d_model_get_duration(_instance) : 0.0f;
#endif // DORA_NO_RUST
}

float Model3D::getElapsed() const noexcept {
#ifdef DORA_NO_RUST
	return 0.0f;
#else
	return _instance != 0 ? dora_3d_model_get_elapsed(_instance) : 0.0f;
#endif // DORA_NO_RUST
}

float Model3D::play(String name, bool loop) {
#ifdef DORA_NO_RUST
	return 0.0f;
#else
	if (_instance == 0) return 0.0f;
	float duration = dora_3d_model_play(_instance, name.toString().c_str(), loop ? 1 : 0);
	if (duration < 0.0f) return 0.0f;
	auto scheduledItem = getScheduledItem();
	if (!scheduledItem->iter) {
		getScheduler()->schedule(scheduledItem);
	}
	_playing = true;
	_paused = false;
	return duration;
#endif // DORA_NO_RUST
}

void Model3D::stop() {
#ifndef DORA_NO_RUST
	if (_instance != 0) {
		dora_3d_model_stop(_instance);
	}
#endif // DORA_NO_RUST
	if (_scheduledItem && _scheduledItem->iter) {
		getScheduler()->unschedule(_scheduledItem.get());
	}
	_playing = false;
	_paused = false;
}

void Model3D::pause() {
#ifndef DORA_NO_RUST
	if (_instance != 0 && _playing && !_paused) {
		dora_3d_model_pause(_instance);
		_paused = dora_3d_model_is_paused(_instance) != 0;
	}
#endif // DORA_NO_RUST
}

void Model3D::resume() {
#ifndef DORA_NO_RUST
	if (_instance != 0 && _playing && _paused) {
		dora_3d_model_resume(_instance);
		_paused = false;
	}
#endif // DORA_NO_RUST
}

void Model3D::cleanup() {
	stop();
	destroyInstance();
	_modelDef = nullptr;
	Node3D::cleanup();
}

bool Model3D::update(double deltaTime) {
#ifndef DORA_NO_RUST
	if (_instance != 0) {
		if (dora_3d_model_update(_instance, s_cast<float>(deltaTime)) == 0) {
			_playing = false;
			_paused = false;
		}
	}
#endif // DORA_NO_RUST
	if (!_playing) {
		return true;
	}
	return false;
}

NS_DORA_END

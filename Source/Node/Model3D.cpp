/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Model3D.h"

#include "Cache/Model3DCache.h"

#ifndef DORA_NO_RUST
extern "C" {
uint64_t dora_3d_model_instantiate(uint64_t model, uint64_t node);
void dora_3d_model_instance_destroy(uint64_t instance);
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
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

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
		dora_3d_model_instance_destroy(_instance);
		_instance = 0;
	}
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

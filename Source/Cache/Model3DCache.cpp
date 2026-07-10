/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/Model3DCache.h"

#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Common/Async.h"

#include <chrono>

#ifndef DORA_NO_RUST
extern "C" {
uint64_t dora_3d_load_gltf(const char* path);
uint64_t dora_3d_parse_gltf(const char* path);
uint64_t dora_3d_begin_upload_gltf(uint64_t prepared);
int32_t dora_3d_step_upload_gltf(uint64_t job, uint64_t* model);
void dora_3d_cancel_upload_gltf(uint64_t job);
void dora_3d_model_destroy(uint64_t model);
int32_t dora_3d_environment_is_cached(const char* path);
uint64_t dora_3d_prepare_environment_equirect_cpu(const char* path);
uint64_t dora_3d_begin_environment_upload(uint64_t prepared);
int32_t dora_3d_step_environment_upload(uint64_t job);
void dora_3d_cancel_environment_upload(uint64_t job);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

Model3DDef::Model3DDef(uint64_t handle)
	: _handle(handle) { }

Model3DDef::~Model3DDef() {
#ifndef DORA_NO_RUST
	if (_handle != 0) {
		dora_3d_model_destroy(_handle);
		_handle = 0;
	}
#endif // DORA_NO_RUST
}

uint64_t Model3DDef::getHandle() const noexcept {
	return _handle;
}

Model3DDef* Model3DCache::load(String filename) {
#ifdef DORA_NO_RUST
	return nullptr;
#else
	std::string file = SharedContent.getFullPath(filename);
	if (file.empty()) return nullptr;
	auto it = _models.find(file);
	if (it != _models.end()) {
		return it->second;
	}
	uint64_t model = dora_3d_load_gltf(file.c_str());
	if (model == 0) return nullptr;
	Model3DDef* def = Model3DDef::create(model);
	_models[file] = def;
	return def;
#endif // DORA_NO_RUST
}

void Model3DCache::loadAsync(String filename, const std::function<void(Model3DDef*)>& handler) {
#ifdef DORA_NO_RUST
	handler(nullptr);
#else
	std::string file = SharedContent.getFullPath(filename);
	if (file.empty()) {
		handler(nullptr);
		return;
	}
	auto model = _models.find(file);
	if (model != _models.end()) {
		handler(model->second);
		return;
	}
	auto pending = _pending.find(file);
	if (pending != _pending.end()) {
		pending->second.push_back(handler);
		return;
	}
	_pending[file].push_back(handler);
	SharedAsyncThread.run(
		[file]() {
			return Values::alloc(dora_3d_parse_gltf(file.c_str()));
		},
		[this, file](Own<Values> result) {
			uint64_t prepared = 0;
			result->get(prepared);
			if (prepared == 0) {
				completeAsync(file, 0);
				return;
			}
			uint64_t job = dora_3d_begin_upload_gltf(prepared);
			if (job == 0) {
				completeAsync(file, 0);
				return;
			}
			enqueueUpload(UploadTask::Type::Model, file, job);
		});
#endif // DORA_NO_RUST
}

void Model3DCache::loadEnvironmentAsync(String filename, const std::function<void(bool)>& handler) {
#ifdef DORA_NO_RUST
	handler(false);
#else
	std::string file = SharedContent.getFullPath(filename);
	if (file.empty()) {
		handler(false);
		return;
	}
	if (dora_3d_environment_is_cached(file.c_str()) != 0) {
		handler(true);
		return;
	}
	auto pending = _pendingEnvironments.find(file);
	if (pending != _pendingEnvironments.end()) {
		pending->second.push_back(handler);
		return;
	}
	_pendingEnvironments[file].push_back(handler);
	SharedAsyncThread.run(
		[file]() {
			return Values::alloc(dora_3d_prepare_environment_equirect_cpu(file.c_str()));
		},
		[this, file](Own<Values> result) {
			uint64_t prepared = 0;
			result->get(prepared);
			if (prepared == 0) {
				completeEnvironmentAsync(file, dora_3d_environment_is_cached(file.c_str()) != 0);
				return;
			}
			uint64_t job = dora_3d_begin_environment_upload(prepared);
			if (job == 0) {
				completeEnvironmentAsync(file, false);
				return;
			}
			enqueueUpload(UploadTask::Type::Environment, file, job);
		});
#endif // DORA_NO_RUST
}

void Model3DCache::enqueueUpload(UploadTask::Type type, const std::string& file, uint64_t job) {
	_uploads.push_back({type, file, job});
	if (_uploadScheduled) return;
	_uploadScheduled = true;
	SharedDirector.getSystemScheduler()->schedule([this](double) {
		return updateUploads();
	});
}

bool Model3DCache::updateUploads() {
	using Clock = std::chrono::steady_clock;
	constexpr auto Budget = std::chrono::microseconds(2000);
	const auto deadline = Clock::now() + Budget;
	do {
		auto task = std::move(_uploads.front());
		_uploads.pop_front();
		uint64_t model = 0;
		int32_t status = task.type == UploadTask::Type::Model
			? dora_3d_step_upload_gltf(task.job, &model)
			: dora_3d_step_environment_upload(task.job);
		if (status == 0) {
			_uploads.push_back(std::move(task));
		} else {
			if (status < 0) {
				if (task.type == UploadTask::Type::Model) {
					dora_3d_cancel_upload_gltf(task.job);
				} else {
					dora_3d_cancel_environment_upload(task.job);
				}
				model = 0;
			}
			if (task.type == UploadTask::Type::Model) {
				completeAsync(task.file, model);
			} else {
				completeEnvironmentAsync(task.file, status > 0);
			}
		}
	} while (!_uploads.empty() && Clock::now() < deadline);
	if (_uploads.empty()) {
		_uploadScheduled = false;
		return true;
	}
	return false;
}

void Model3DCache::completeEnvironmentAsync(const std::string& file, bool success) {
	auto pending = _pendingEnvironments.find(file);
	if (pending == _pendingEnvironments.end()) return;
	auto handlers = std::move(pending->second);
	_pendingEnvironments.erase(pending);
	for (const auto& callback : handlers) {
		callback(success);
	}
}

void Model3DCache::completeAsync(const std::string& file, uint64_t model) {
	Ref<Model3DDef> def;
	if (model != 0) {
		def = Model3DDef::create(model);
		_models[file] = def;
	}
	auto pending = _pending.find(file);
	if (pending == _pending.end()) return;
	auto handlers = std::move(pending->second);
	_pending.erase(pending);
	for (const auto& callback : handlers) {
		callback(def.get());
	}
}

bool Model3DCache::unload(String filename) {
	std::string file = SharedContent.getFullPath(filename);
	return _models.erase(file) > 0;
}

bool Model3DCache::unload() {
	_models.clear();
	return true;
}

void Model3DCache::removeUnused() {
	for (auto it = _models.begin(); it != _models.end();) {
		if (it->second->isSingleReferenced()) {
			it = _models.erase(it);
		} else {
			++it;
		}
	}
}

NS_DORA_END

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
int32_t dora_3d_collect_gltf_dependencies(const char* path, const uint8_t* data, size_t size, void (*visitor)(const char*, void*), void* userData);
uint64_t dora_3d_parse_gltf_data(const char* path, const uint8_t* data, size_t size, int32_t (*loader)(const char*, const uint8_t**, size_t*, void*), void* userData);
uint64_t dora_3d_begin_upload_gltf(uint64_t prepared);
int32_t dora_3d_step_upload_gltf(uint64_t job, uint64_t maxBytes, uint64_t* model, uint64_t* uploadedBytes);
void dora_3d_cancel_upload_gltf(uint64_t job);
void dora_3d_discard_prepared_gltf(uint64_t prepared);
void dora_3d_model_destroy(uint64_t model);
uint64_t dora_3d_model_resident_bytes(uint64_t model);
int32_t dora_3d_environment_is_cached(const char* path);
uint64_t dora_3d_prepare_environment_equirect_cpu(const char* path);
uint64_t dora_3d_begin_environment_upload(uint64_t prepared);
int32_t dora_3d_step_environment_upload(uint64_t job, uint64_t maxBytes, uint64_t* uploadedBytes);
void dora_3d_cancel_environment_upload(uint64_t job);
void dora_3d_discard_prepared_environment(uint64_t prepared);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

struct Model3DImportResource {
	OwnArray<uint8_t> data;
	size_t size;
};

struct Model3DLoadTask {
	std::string file;
	OwnArray<uint8_t> data;
	size_t size = 0;
	std::vector<std::string> dependencies;
	std::unordered_map<std::string, Model3DImportResource> resources;
	size_t remaining = 0;
	bool failed = false;
	bool cancelled = false;
	std::vector<std::function<void(Model3DDef*)>> handlers;
};

struct Model3DEnvironmentTask {
	std::string file;
	bool cancelled = false;
	std::vector<std::function<void(bool)>> handlers;
};

static void collectModel3DDependency(const char* path, void* userData) {
	auto state = r_cast<Model3DLoadTask*>(userData);
	state->dependencies.emplace_back(path);
}

static int32_t loadModel3DResource(const char* path, const uint8_t** data, size_t* size, void* userData) {
	auto state = r_cast<Model3DLoadTask*>(userData);
	auto it = state->resources.find(path);
	if (it == state->resources.end()) return 0;
	*data = it->second.data.get();
	*size = it->second.size;
	return 1;
}

Model3DDef::Model3DDef(uint64_t handle)
	: _handle(handle)
	, _residentBytes(
#ifndef DORA_NO_RUST
		  dora_3d_model_resident_bytes(handle)
#else
		  0
#endif
		  ) { }

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

uint64_t Model3DDef::getResidentBytes() const noexcept {
	return _residentBytes;
}

Model3DDef* Model3DCache::load(String filename) {
#ifdef DORA_NO_RUST
	return nullptr;
#else
	std::string file = SharedContent.getFullPath(filename);
	if (file.empty()) {
		_loadInfo[filename.toString()] = {Model3DLoadState::Failed, "resource not found"};
		return nullptr;
	}
	auto it = _models.find(file);
	if (it != _models.end()) {
		it->second.lastAccess = ++_accessSequence;
		return it->second.model;
	}
	cancelLoad(file);
	_loadInfo[file] = {Model3DLoadState::Loading, {}};
	uint64_t model = dora_3d_load_gltf(file.c_str());
	if (model == 0) {
		_loadInfo[file] = {Model3DLoadState::Failed, "glTF parse or GPU upload failed"};
		return nullptr;
	}
	Model3DDef* def = Model3DDef::create(model);
	CacheEntry entry;
	entry.model = def;
	entry.residentBytes = def->getResidentBytes();
	entry.lastAccess = ++_accessSequence;
	_models[file] = std::move(entry);
	_loadInfo[file] = {Model3DLoadState::Ready, {}};
	trimToBudget();
	return def;
#endif // DORA_NO_RUST
}

void Model3DCache::loadAsync(String filename, const std::function<void(Model3DDef*)>& handler) {
#ifdef DORA_NO_RUST
	handler(nullptr);
#else
	std::string file = SharedContent.getFullPath(filename);
	if (file.empty()) {
		_loadInfo[filename.toString()] = {Model3DLoadState::Failed, "resource not found"};
		handler(nullptr);
		return;
	}
	auto model = _models.find(file);
	if (model != _models.end()) {
		model->second.lastAccess = ++_accessSequence;
		handler(model->second.model);
		return;
	}
	auto pending = _modelTasks.find(file);
	if (pending != _modelTasks.end()) {
		pending->second->handlers.push_back(handler);
		return;
	}
	auto task = std::make_shared<Model3DLoadTask>();
	task->file = file;
	task->handlers.push_back(handler);
	_modelTasks[file] = task;
	_loadInfo[file] = {Model3DLoadState::Loading, {}};
	SharedContent.loadAsyncData(file, [this, task](OwnArray<uint8_t>&& data, size_t size) {
		if (!isCurrent(task)) return;
		if (!data || size == 0) {
			completeAsync(task, 0, "failed to read model through Content");
			return;
		}
		task->data = std::move(data);
		task->size = size;
		collectDependenciesAsync(task);
	});
#endif // DORA_NO_RUST
}

void Model3DCache::collectDependenciesAsync(const std::shared_ptr<Model3DLoadTask>& task) {
#ifndef DORA_NO_RUST
	SharedAsyncThread.run(
		[task]() {
			bool success = dora_3d_collect_gltf_dependencies(
				task->file.c_str(),
				task->data.get(),
				task->size,
				collectModel3DDependency,
				task.get()) != 0;
			return Values::alloc(success);
		},
		[this, task](Own<Values> result) {
			if (!isCurrent(task)) return;
			bool success = false;
			result->get(success);
			if (!success) {
				completeAsync(task, 0, "failed to scan glTF dependencies");
				return;
			}
			loadDependenciesAsync(task);
		});
#endif // DORA_NO_RUST
}

void Model3DCache::loadDependenciesAsync(const std::shared_ptr<Model3DLoadTask>& task) {
#ifndef DORA_NO_RUST
	if (task->dependencies.empty()) {
		parseDataAsync(task);
		return;
	}
	task->remaining = task->dependencies.size();
	for (const auto& dependency : task->dependencies) {
		SharedContent.loadAsyncData(dependency, [this, task, dependency](OwnArray<uint8_t>&& data, size_t size) {
			if (!isCurrent(task)) return;
			if (!data || size == 0) {
				task->failed = true;
			} else {
				task->resources.emplace(dependency, Model3DImportResource {std::move(data), size});
			}
			if (--task->remaining == 0) {
				if (task->failed) {
					completeAsync(task, 0, "failed to read one or more glTF dependencies");
				} else {
					parseDataAsync(task);
				}
			}
		});
	}
#endif // DORA_NO_RUST
}

void Model3DCache::parseDataAsync(const std::shared_ptr<Model3DLoadTask>& task) {
#ifndef DORA_NO_RUST
	SharedAsyncThread.run(
		[task]() {
			return Values::alloc(dora_3d_parse_gltf_data(
				task->file.c_str(),
				task->data.get(),
				task->size,
				loadModel3DResource,
				task.get()));
		},
		[this, task](Own<Values> result) {
			uint64_t prepared = 0;
			result->get(prepared);
			if (!isCurrent(task)) {
				if (prepared != 0) dora_3d_discard_prepared_gltf(prepared);
				return;
			}
			if (prepared == 0) {
				completeAsync(task, 0, "failed to parse or prepare glTF data");
				return;
			}
			uint64_t job = dora_3d_begin_upload_gltf(prepared);
			if (job == 0) {
				completeAsync(task, 0, "failed to create GPU upload job");
				return;
			}
			enqueueUpload(task, job);
		});
#endif // DORA_NO_RUST
}

void Model3DCache::loadEnvironmentAsync(String filename, const std::function<void(bool)>& handler) {
#ifdef DORA_NO_RUST
	handler(false);
#else
	std::string file = SharedContent.getFullPath(filename);
	if (file.empty()) {
		_loadInfo[filename.toString()] = {Model3DLoadState::Failed, "environment resource not found"};
		handler(false);
		return;
	}
	if (dora_3d_environment_is_cached(file.c_str()) != 0) {
		_loadInfo[file] = {Model3DLoadState::Ready, {}};
		handler(true);
		return;
	}
	auto pending = _environmentTasks.find(file);
	if (pending != _environmentTasks.end()) {
		pending->second->handlers.push_back(handler);
		return;
	}
	auto task = std::make_shared<Model3DEnvironmentTask>();
	task->file = file;
	task->handlers.push_back(handler);
	_environmentTasks[file] = task;
	_loadInfo[file] = {Model3DLoadState::Loading, {}};
	SharedAsyncThread.run(
		[task]() {
			return Values::alloc(dora_3d_prepare_environment_equirect_cpu(task->file.c_str()));
		},
		[this, task](Own<Values> result) {
			uint64_t prepared = 0;
			result->get(prepared);
			if (!isCurrent(task)) {
				if (prepared != 0) dora_3d_discard_prepared_environment(prepared);
				return;
			}
			if (prepared == 0) {
				bool cached = dora_3d_environment_is_cached(task->file.c_str()) != 0;
				completeEnvironmentAsync(task, cached, cached ? std::string {} : "failed to prepare environment map");
				return;
			}
			uint64_t job = dora_3d_begin_environment_upload(prepared);
			if (job == 0) {
				completeEnvironmentAsync(task, false, "failed to create environment GPU upload job");
				return;
			}
			enqueueUpload(task, job);
		});
#endif // DORA_NO_RUST
}

std::string Model3DCache::resolveKey(String filename) const {
	std::string file = SharedContent.getFullPath(filename);
	return file.empty() ? filename.toString() : file;
}

bool Model3DCache::isCurrent(const std::shared_ptr<Model3DLoadTask>& task) const {
	auto it = _modelTasks.find(task->file);
	return !task->cancelled && it != _modelTasks.end() && it->second == task;
}

bool Model3DCache::isCurrent(const std::shared_ptr<Model3DEnvironmentTask>& task) const {
	auto it = _environmentTasks.find(task->file);
	return !task->cancelled && it != _environmentTasks.end() && it->second == task;
}

void Model3DCache::enqueueUpload(const std::shared_ptr<Model3DLoadTask>& task, uint64_t job) {
	_uploads.push_back({UploadTask::Type::Model, job, task, nullptr});
	if (_uploadScheduled) return;
	_uploadScheduled = true;
	SharedDirector.getSystemScheduler()->schedule([this](double) {
		return updateUploads();
	});
}

void Model3DCache::enqueueUpload(const std::shared_ptr<Model3DEnvironmentTask>& task, uint64_t job) {
	_uploads.push_back({UploadTask::Type::Environment, job, nullptr, task});
	if (_uploadScheduled) return;
	_uploadScheduled = true;
	SharedDirector.getSystemScheduler()->schedule([this](double) {
		return updateUploads();
	});
}

bool Model3DCache::updateUploads() {
	if (_uploads.empty()) {
		_uploadScheduled = false;
		return true;
	}
	using Clock = std::chrono::steady_clock;
	constexpr auto TimeBudget = std::chrono::microseconds(2000);
	constexpr uint64_t ByteBudget = 512 * 1024;
	constexpr uint64_t MinimumChunkBudget = 256;
	constexpr uint32_t MaximumSteps = 256;
	const auto deadline = Clock::now() + TimeBudget;
	uint64_t remainingBytes = ByteBudget;
	uint32_t steps = 0;
	do {
		auto task = std::move(_uploads.front());
		_uploads.pop_front();
		bool current = task.type == UploadTask::Type::Model
			? isCurrent(task.modelTask)
			: isCurrent(task.environmentTask);
		if (!current) {
			if (task.type == UploadTask::Type::Model) {
				dora_3d_cancel_upload_gltf(task.job);
			} else {
				dora_3d_cancel_environment_upload(task.job);
			}
			continue;
		}
		uint64_t model = 0;
		uint64_t uploadedBytes = 0;
		int32_t status = task.type == UploadTask::Type::Model
			? dora_3d_step_upload_gltf(task.job, remainingBytes, &model, &uploadedBytes)
			: dora_3d_step_environment_upload(task.job, remainingBytes, &uploadedBytes);
		remainingBytes = uploadedBytes < remainingBytes ? remainingBytes - uploadedBytes : 0;
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
				completeAsync(task.modelTask, model, status > 0 ? std::string {} : "GPU upload failed");
			} else {
				completeEnvironmentAsync(task.environmentTask, status > 0, status > 0 ? std::string {} : "environment GPU upload failed");
			}
		}
		++steps;
	} while (!_uploads.empty()
		&& remainingBytes >= MinimumChunkBudget
		&& steps < MaximumSteps
		&& Clock::now() < deadline);
	if (_uploads.empty()) {
		_uploadScheduled = false;
		return true;
	}
	return false;
}

void Model3DCache::completeEnvironmentAsync(const std::shared_ptr<Model3DEnvironmentTask>& task, bool success, std::string error) {
	if (!isCurrent(task)) return;
	_environmentTasks.erase(task->file);
	_loadInfo[task->file] = {success ? Model3DLoadState::Ready : Model3DLoadState::Failed, std::move(error)};
	auto handlers = std::move(task->handlers);
	for (const auto& callback : handlers) {
		callback(success);
	}
}

void Model3DCache::completeAsync(const std::shared_ptr<Model3DLoadTask>& task, uint64_t model, std::string error) {
	if (!isCurrent(task)) {
		if (model != 0) dora_3d_model_destroy(model);
		return;
	}
	_modelTasks.erase(task->file);
	Ref<Model3DDef> def;
	if (model != 0) {
		def = Model3DDef::create(model);
		CacheEntry entry;
		entry.model = def;
		entry.residentBytes = def->getResidentBytes();
		entry.lastAccess = ++_accessSequence;
		_models[task->file] = std::move(entry);
		_loadInfo[task->file] = {Model3DLoadState::Ready, {}};
		trimToBudget();
	} else {
		_loadInfo[task->file] = {Model3DLoadState::Failed, std::move(error)};
	}
	auto handlers = std::move(task->handlers);
	for (const auto& callback : handlers) {
		callback(def.get());
	}
}

Model3DLoadState Model3DCache::getLoadState(String filename) const {
	auto it = _loadInfo.find(resolveKey(filename));
	return it == _loadInfo.end() ? Model3DLoadState::None : it->second.state;
}

String Model3DCache::getLoadError(String filename) const {
	auto it = _loadInfo.find(resolveKey(filename));
	return it == _loadInfo.end() ? String {} : String {it->second.error};
}

bool Model3DCache::cancelLoad(String filename) {
	std::string file = resolveKey(filename);
	bool cancelled = false;
	auto modelTask = _modelTasks.find(file);
	if (modelTask != _modelTasks.end()) {
		auto task = modelTask->second;
		task->cancelled = true;
		_modelTasks.erase(modelTask);
		for (auto it = _uploads.begin(); it != _uploads.end();) {
			if (it->modelTask == task) {
				dora_3d_cancel_upload_gltf(it->job);
				it = _uploads.erase(it);
			} else {
				++it;
			}
		}
		auto handlers = std::move(task->handlers);
		for (const auto& callback : handlers) callback(nullptr);
		cancelled = true;
	}
	auto environmentTask = _environmentTasks.find(file);
	if (environmentTask != _environmentTasks.end()) {
		auto task = environmentTask->second;
		task->cancelled = true;
		_environmentTasks.erase(environmentTask);
		for (auto it = _uploads.begin(); it != _uploads.end();) {
			if (it->environmentTask == task) {
				dora_3d_cancel_environment_upload(it->job);
				it = _uploads.erase(it);
			} else {
				++it;
			}
		}
		auto handlers = std::move(task->handlers);
		for (const auto& callback : handlers) callback(false);
		cancelled = true;
	}
	if (cancelled) {
		_loadInfo[file] = {Model3DLoadState::Cancelled, "load cancelled"};
	}
	return cancelled;
}

void Model3DCache::setBudget(uint64_t bytes) {
	_budget = bytes;
	trimToBudget();
}

uint64_t Model3DCache::getBudget() const noexcept {
	return _budget;
}

uint64_t Model3DCache::getUsage() const noexcept {
	uint64_t usage = 0;
	for (const auto& item : _models) usage += item.second.residentBytes;
	return usage;
}

uint32_t Model3DCache::getCount() const noexcept {
	return s_cast<uint32_t>(_models.size());
}

void Model3DCache::trimToBudget(bool retryNextFrame) {
	if (_budget == 0) {
		_overBudget = false;
		return;
	}
	uint64_t usage = getUsage();
	while (usage > _budget) {
		auto victim = _models.end();
		for (auto it = _models.begin(); it != _models.end(); ++it) {
			if (!it->second.model->isSingleReferenced()) continue;
			if (victim == _models.end() || it->second.lastAccess < victim->second.lastAccess) victim = it;
		}
		if (victim == _models.end()) break;
		usage -= victim->second.residentBytes;
		_models.erase(victim);
	}
	bool overBudget = usage > _budget;
	if (overBudget && !_overBudget) {
		Warn("Model3D cache is over budget: {} bytes resident, {} bytes budget; referenced models were retained.", usage, _budget);
	}
	_overBudget = overBudget;
	if (overBudget && retryNextFrame && !_trimScheduled) {
		_trimScheduled = true;
		SharedDirector.getSystemScheduler()->schedule([this](double) {
			_trimScheduled = false;
			trimToBudget(false);
			return true;
		});
	}
}

bool Model3DCache::unload(String filename) {
	std::string file = resolveKey(filename);
	bool cancelled = cancelLoad(file);
	bool removed = _models.erase(file) > 0;
	_loadInfo.erase(file);
	return cancelled || removed;
}

bool Model3DCache::unload() {
	std::vector<std::string> tasks;
	for (const auto& item : _modelTasks) tasks.push_back(item.first);
	for (const auto& item : _environmentTasks) tasks.push_back(item.first);
	for (const auto& file : tasks) cancelLoad(file);
	_models.clear();
	_loadInfo.clear();
	_overBudget = false;
	return true;
}

void Model3DCache::removeUnused() {
	for (auto it = _models.begin(); it != _models.end();) {
		if (it->second.model->isSingleReferenced()) {
			it = _models.erase(it);
		} else {
			++it;
		}
	}
	trimToBudget();
}

NS_DORA_END

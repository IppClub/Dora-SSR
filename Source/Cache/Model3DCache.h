/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Common/Singleton.h"

#include <deque>
#include <memory>

NS_DORA_BEGIN

class Model3DDef : public Object {
public:
	PROPERTY_READONLY(uint64_t, Handle);
	PROPERTY_READONLY(uint64_t, ResidentBytes);
	virtual ~Model3DDef();
	CREATE_FUNC_NOT_NULL(Model3DDef);

protected:
	Model3DDef(uint64_t handle);

private:
	uint64_t _handle;
	uint64_t _residentBytes;
	DORA_TYPE_OVERRIDE(Model3DDef);
};

enum class Model3DLoadState {
	None,
	Loading,
	Ready,
	Failed,
	Cancelled,
};

struct Model3DLoadTask;
struct Model3DEnvironmentTask;

class Model3DCache : public NonCopyable {
public:
	Model3DDef* load(String filename);
	void loadAsync(String filename, const std::function<void(Model3DDef*)>& handler);
	void loadEnvironmentAsync(String filename, const std::function<void(bool)>& handler);
	Model3DLoadState getLoadState(String filename) const;
	String getLoadError(String filename) const;
	bool cancelLoad(String filename);
	void setBudget(uint64_t bytes);
	uint64_t getBudget() const noexcept;
	uint64_t getUsage() const noexcept;
	uint32_t getCount() const noexcept;
	bool unload(String filename);
	bool unload();
	void removeUnused();

protected:
	Model3DCache() { }

private:
	struct UploadTask {
		enum class Type {
			Model,
			Environment,
		};
		Type type;
		uint64_t job;
		std::shared_ptr<Model3DLoadTask> modelTask;
		std::shared_ptr<Model3DEnvironmentTask> environmentTask;
	};
	struct CacheEntry {
		Ref<Model3DDef> model;
		uint64_t residentBytes = 0;
		uint64_t lastAccess = 0;
	};
	struct LoadInfo {
		Model3DLoadState state = Model3DLoadState::None;
		std::string error;
	};
	std::string resolveKey(String filename) const;
	bool isCurrent(const std::shared_ptr<Model3DLoadTask>& task) const;
	bool isCurrent(const std::shared_ptr<Model3DEnvironmentTask>& task) const;
	void enqueueUpload(const std::shared_ptr<Model3DLoadTask>& task, uint64_t job);
	void enqueueUpload(const std::shared_ptr<Model3DEnvironmentTask>& task, uint64_t job);
	void collectDependenciesAsync(const std::shared_ptr<Model3DLoadTask>& task);
	void loadDependenciesAsync(const std::shared_ptr<Model3DLoadTask>& task);
	void parseDataAsync(const std::shared_ptr<Model3DLoadTask>& task);
	bool updateUploads();
	void completeAsync(const std::shared_ptr<Model3DLoadTask>& task, uint64_t model, std::string error = {});
	void completeEnvironmentAsync(const std::shared_ptr<Model3DEnvironmentTask>& task, bool success, std::string error = {});
	void trimToBudget(bool retryNextFrame = true);
	StringMap<CacheEntry> _models;
	StringMap<LoadInfo> _loadInfo;
	StringMap<std::shared_ptr<Model3DLoadTask>> _modelTasks;
	StringMap<std::shared_ptr<Model3DEnvironmentTask>> _environmentTasks;
	std::deque<UploadTask> _uploads;
	uint64_t _budget = 0;
	uint64_t _accessSequence = 0;
	bool _overBudget = false;
	bool _trimScheduled = false;
	bool _uploadScheduled = false;
	SINGLETON_REF(Model3DCache, Director);
};

#define SharedModel3DCache \
	Dora::Singleton<Dora::Model3DCache>::shared()

NS_DORA_END

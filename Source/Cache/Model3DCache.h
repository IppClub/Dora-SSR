/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Common/Singleton.h"

#include <deque>

NS_DORA_BEGIN

class Model3DDef : public Object {
public:
	PROPERTY_READONLY(uint64_t, Handle);
	virtual ~Model3DDef();
	CREATE_FUNC_NOT_NULL(Model3DDef);

protected:
	Model3DDef(uint64_t handle);

private:
	uint64_t _handle;
	DORA_TYPE_OVERRIDE(Model3DDef);
};

class Model3DCache : public NonCopyable {
public:
	Model3DDef* load(String filename);
	void loadAsync(String filename, const std::function<void(Model3DDef*)>& handler);
	void loadEnvironmentAsync(String filename, const std::function<void(bool)>& handler);
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
		std::string file;
		uint64_t job;
	};
	void enqueueUpload(UploadTask::Type type, const std::string& file, uint64_t job);
	bool updateUploads();
	void completeAsync(const std::string& file, uint64_t model);
	void completeEnvironmentAsync(const std::string& file, bool success);
	StringMap<Ref<Model3DDef>> _models;
	StringMap<std::vector<std::function<void(Model3DDef*)>>> _pending;
	StringMap<std::vector<std::function<void(bool)>>> _pendingEnvironments;
	std::deque<UploadTask> _uploads;
	bool _uploadScheduled = false;
	SINGLETON_REF(Model3DCache, Director);
};

#define SharedModel3DCache \
	Dora::Singleton<Dora::Model3DCache>::shared()

NS_DORA_END

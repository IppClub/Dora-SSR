/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/Model3DCache.h"

#include "Basic/Content.h"

#ifndef DORA_NO_RUST
extern "C" {
uint64_t dora_3d_load_gltf(const char* path);
void dora_3d_model_destroy(uint64_t model);
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

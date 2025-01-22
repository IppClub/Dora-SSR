/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/TMXCache.h"

#include "Cache/TextureCache.h"

NS_DORA_BEGIN

/* TMXDef */

bool TMXDef::load(String filename) {
	return _map.load(filename.toString());
}

void TMXDef::loadAsync(String filename, const std::function<void(bool)>& callback) {
	this->retain();
	auto file = filename.toString();
	SharedContent.getThread()->run([file, this]() {
		return Values::alloc(this->_map.loadUnsafe(file));
	},
		[callback, this](Own<Values> values) {
			bool done = false;
			values->get(done);
			if (!done) {
				callback(false);
				return;
			}
			std::unordered_set<std::string> images;
			for (const auto& tileset : this->_map.getTilesets()) {
				images.insert(tileset.getImagePath());
			}
			auto imageCopies = std::make_shared<std::unordered_set<std::string>>(images);
			for (const auto& image : images) {
				SharedTextureCache.loadAsync(image, [image, imageCopies, callback](Texture2D* tex) {
					if (imageCopies->empty()) {
						return;
					}
					if (tex) {
						imageCopies->erase(image);
					} else {
						imageCopies->clear();
						callback(false);
						return;
					}
					if (imageCopies->empty()) {
						callback(true);
					}
				});
			}
			this->release();
		});
}

/* TMXCache */

const tmx::Map& TMXDef::getMap() const noexcept {
	return _map;
}

TMXDef* TMXCache::load(String filename) {
	auto fullPath = SharedContent.getFullPath(filename);
	if (auto it = _maps.find(fullPath); it != _maps.end()) {
		return it->second;
	}
	auto def = TMXDef::create();
	if (def->load(fullPath)) {
		_maps[fullPath] = def;
		return def;
	}
	Error("failed to load tmx file: \"{}\".", filename.toString());
	return nullptr;
}

void TMXCache::loadAsync(String filename, const std::function<void(TMXDef*)>& callback) {
	auto fullPath = SharedContent.getFullPath(filename);
	if (auto it = _maps.find(fullPath); it != _maps.end()) {
		callback(it->second);
		return;
	}
	auto def = TMXDef::create();
	def->retain();
	def->loadAsync(filename, [fullPath, callback, def, this](bool done) {
		if (done) {
			_maps[fullPath] = def;
			callback(def);
		} else {
			callback(nullptr);
		}
		def->release();
	});
}

void TMXCache::removeUnused() {
	std::vector<std::string> targets;
	for (const auto& pair : _maps) {
		if (pair.second->isSingleReferenced()) {
			targets.push_back(pair.first);
		}
	}
	for (const auto& target : targets) {
		_maps.erase(target);
	}
}

bool TMXCache::unload(String filename) {
	std::string fullPath = SharedContent.getFullPath(filename);
	auto it = _maps.find(fullPath);
	if (it != _maps.end()) {
		_maps.erase(it);
		return true;
	}
	return false;
}

bool TMXCache::unload() {
	if (_maps.empty()) {
		return false;
	}
	_maps.clear();
	return true;
}

NS_DORA_END

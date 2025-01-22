/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/DragonBoneCache.h"

#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Cache/TextureCache.h"
#include "Common/Async.h"
#include "Node/DragonBone.h"

NS_DORA_BEGIN

void DBTextureAtlasData::_onClear() {
	db::TextureAtlasData::_onClear();
	_texture = nullptr;
}

DBTextureData* DBTextureAtlasData::createTexture() const {
	return db::BaseObject::borrowObject<DBTextureData>();
}

void DBTextureAtlasData::setTexture(Texture2D* var) {
	_texture = var;
}

Texture2D* DBTextureAtlasData::getTexture() const noexcept {
	return _texture;
}

db::TextureAtlasData* DragonBoneCache::_buildTextureAtlasData(db::TextureAtlasData* textureAtlasData, void* textureAtlas) const {
	if (textureAtlasData == nullptr) {
		textureAtlasData = db::BaseObject::borrowObject<DBTextureAtlasData>();
	}
	return textureAtlasData;
}

db::Armature* DragonBoneCache::_buildArmature(const db::BuildArmaturePackage& dataPackage) const {
	const auto armature = db::BaseObject::borrowObject<db::Armature>();
	auto dragonBoneNode = DragonBone::create();
	armature->init(
		dataPackage.armature,
		dragonBoneNode->getArmatureProxy(),
		dragonBoneNode,
		_dragonBones);
	return armature;
}

db::Slot* DragonBoneCache::_buildSlot(const db::BuildArmaturePackage& dataPackage, const db::SlotData* slotData, db::Armature* armature) const {
	const auto slot = db::BaseObject::borrowObject<DBSlot>();
	const auto node = DBSlotNode::create();
	node->setOrder(slotData->zOrder);
	slot->init(slotData, armature, node, node);
	return slot;
}

db::DragonBonesData* DragonBoneCache::loadDragonBonesData(String filename) {
	auto fullPath = SharedContent.getFullPath(filename);
	auto existedData = db::BaseFactory::getDragonBonesData(fullPath);
	if (existedData) return existedData;
	auto data = SharedContent.load(filename);
	if (!data.first) {
		Error("failed to load bone \"{}\".", filename.toString());
		return nullptr;
	}
	auto str = Slice(r_cast<char*>(data.first.get()), data.second).toString();
	_boneRefs[fullPath] = 0;
	return db::BaseFactory::parseDragonBonesData(str.c_str(), fullPath);
}

DBTextureAtlasData* DragonBoneCache::loadTextureAtlasData(String filename) {
	auto fullPath = SharedContent.getFullPath(filename);
	auto atlasData = db::BaseFactory::getTextureAtlasData(fullPath);
	if (atlasData) return s_cast<DBTextureAtlasData*>(atlasData->front());
	auto data = SharedContent.load(filename);
	if (!data.first) {
		Error("failed to load atlas \"{}\".", filename.toString());
		return nullptr;
	}
	auto str = Slice(r_cast<char*>(data.first.get()), data.second).toString();
	_atlasRefs[fullPath] = 0;
	return s_cast<DBTextureAtlasData*>(db::BaseFactory::parseTextureAtlasData(str.c_str(), nullptr, fullPath));
}

DragonBone* DragonBoneCache::buildDragonBoneNode(String boneFile, String atlasFile, String armatureName) {
	auto fullBonePath = SharedContent.getFullPath(boneFile);
	auto fullAtlasFile = SharedContent.getFullPath(atlasFile);
	const auto armature = buildArmature(armatureName.toString(), fullBonePath, Slice::Empty, fullAtlasFile);
	if (armature != nullptr) {
		_atlasRefs[fullAtlasFile] += 1;
		_boneRefs[fullBonePath] += 1;
		auto dragonBoneNode = s_cast<DragonBone*>(armature->getDisplay());
		for (db::Slot* slot : armature->getSlots()) {
			if (slot->getBoundingBoxData()) {
				dragonBoneNode->setHitTestEnabled(true);
				break;
			}
		}
		dragonBoneNode->slot("Cleanup", [this, fullAtlasFile, fullBonePath](Event*) {
			if (!Singleton<DragonBoneCache>::isDisposed()) {
				_atlasRefs[fullAtlasFile] -= 1;
				_boneRefs[fullBonePath] -= 1;
			}
		});
		return dragonBoneNode;
	} else {
		Error("failed to build DragonBone from \"{}\" and \"{}\" with armature \"{}\".", boneFile.toString(), atlasFile.toString(), armatureName.toString());
	}
	return nullptr;
}

DragonBoneCache::DragonBoneCache()
	: _asyncLoadCount(0)
	, _dragonBoneInstance(New<db::DragonBones>(&_eventManager)) {
	_dragonBones = _dragonBoneInstance.get();
	_dragonBoneInstance->yDown = false;
	SharedDirector.getPostScheduler()->schedule([this](double deltaTime) {
		_dragonBoneInstance->advanceTime(s_cast<float>(deltaTime));
		return false;
	});
}

bool DragonBoneCache::EventManager::hasDBEventListener(const std::string& type) const {
	return type == db::EventObject::SOUND_EVENT;
}

void DragonBoneCache::EventManager::dispatchDBEvent(const std::string& type, db::EventObject* value) {
	Event::send("DragonBoneSound"_slice, value->name, s_cast<DragonBone*>(value->armature->getDisplay()));
}

std::tuple<std::string, std::string, std::string> DragonBoneCache::getFileFromStr(String boneStr) {
	std::string armatureName;
	auto tokens = boneStr.split(";"_slice);
	if (tokens.size() == 2) {
		armatureName = tokens.back().toString();
	} else if (tokens.size() != 1) {
		Error("invalid boneStr for \"{}\".", boneStr.toString());
		return {};
	}
	std::string boneFilename, atlasFilename;
	tokens = tokens.front().split("|"_slice);
	if (tokens.size() == 2) {
		if (tokens.front().right(9).toLower() == "_tex.json"sv) {
			atlasFilename = tokens.front().toString();
			if (tokens.back().right(9).toLower() == "_ske.json"sv) {
				boneFilename = tokens.back().toString();
			} else {
				Error("invalid boneStr for \"{}\".", boneStr.toString());
				return {};
			}
		} else if (tokens.front().right(9).toLower() == "_ske.json"sv) {
			boneFilename = tokens.front().toString();
			if (tokens.back().right(9).toLower() == "_tex.json"sv) {
				atlasFilename = tokens.back().toString();
			} else {
				Error("invalid boneStr for \"{}\".", boneStr.toString());
				return {};
			}
		} else {
			boneFilename = tokens.front().toString();
			if (Path::getExt(boneFilename) != "json"_slice) {
				boneFilename += ".json"s;
			}
			atlasFilename = tokens.back().toString();
			if (Path::getExt(atlasFilename) != "json"_slice) {
				atlasFilename += ".json"s;
			}
		}
	} else if (tokens.size() == 1) {
		boneFilename = tokens.front().toString() + "_ske.json"s;
		atlasFilename = tokens.front().toString() + "_tex.json"s;
	} else {
		Error("invalid boneStr for \"{}\".", boneStr.toString());
	}
	return {boneFilename, atlasFilename, armatureName};
}

std::pair<db::DragonBonesData*, std::string> DragonBoneCache::load(String boneStr) {
	if (_asyncLoadCount > 0) {
		Error("can not get DragonBone data from \"{}\" during async loading.", boneStr.toString());
		return {nullptr, Slice::Empty};
	}
	std::string boneFile, atlasFile, armatureName;
	std::tie(boneFile, atlasFile, armatureName) = getFileFromStr(boneStr);
	if (boneFile.empty() || atlasFile.empty()) return {nullptr, Slice::Empty};
	if (armatureName.empty()) {
		return load(boneFile, atlasFile);
	}
	return {load(boneFile, atlasFile).first, armatureName};
}

std::pair<db::DragonBonesData*, std::string> DragonBoneCache::load(String boneFile, String atlasFile) {
	if (_asyncLoadCount > 0) {
		Error("can not get DragonBone data from \"{}\" and \"{}\" during async loading.", boneFile.toString(), atlasFile.toString());
		return {nullptr, Slice::Empty};
	}
	auto boneFilename = boneFile.toString();
	if (Path::getExt(boneFilename) != "json"_slice) {
		boneFilename += ".json"s;
	}
	auto atlasFilename = atlasFile.toString();
	if (Path::getExt(boneFilename) != "json"_slice) {
		atlasFilename += ".json"s;
	}
	auto boneData = loadDragonBonesData(boneFilename);
	auto atlasData = loadTextureAtlasData(atlasFilename);
	if (boneData && atlasData) {
		auto imagePath = Path::concat({Path::getPath(atlasFilename), atlasData->imagePath});
		Texture2D* texture = SharedTextureCache.load(imagePath);
		atlasData->setTexture(texture);
		return {boneData, boneData->getArmatureNames().front()};
	}
	return {nullptr, Slice::Empty};
}

void DragonBoneCache::loadAsync(String boneStr, const std::function<void(bool)>& handler) {
	std::string boneFile, atlasFile, armatureName;
	std::tie(boneFile, atlasFile, armatureName) = getFileFromStr(boneStr);
	if (boneFile.empty() || atlasFile.empty()) {
		handler(false);
	}
	loadAsync(boneFile, atlasFile, handler);
}

void DragonBoneCache::loadAsync(String boneFilename, String atlasFilename, const std::function<void(bool)>& handler) {
	std::string boneFile = SharedContent.getFullPath(boneFilename);
	db::DragonBonesData* boneData = db::BaseFactory::getDragonBonesData(boneFile);
	std::string atlasFile = SharedContent.getFullPath(atlasFilename);
	db::TextureAtlasData* atlasData = nullptr;
	auto atlas = db::BaseFactory::getTextureAtlasData(atlasFile);
	if (atlas) atlasData = atlas->front();
	if (boneData && atlasData) {
		handler(true);
		return;
	}
	auto result = std::make_shared<std::pair<
		std::optional<db::DragonBonesData*>,
		std::optional<db::TextureAtlasData*>>>();
	auto loaded = std::make_shared<std::pair<
		std::optional<std::string>,
		std::optional<std::string>>>();
	if (boneData) {
		result->first = boneData;
		loaded->first = Slice::Empty;
	}
	if (atlasData) {
		result->second = atlasData;
		loaded->second = Slice::Empty;
	}
	_asyncLoadCount++;
	auto parseData = [loaded, result, boneFile, atlasFile, handler, this]() {
		// force parsing works run in the same thread
		SharedAsyncThread.getProcess(0).run(
			[=, this]() {
				if (loaded->first && !loaded->first->empty()) {
					result->first = this->parseDragonBonesData(loaded->first->c_str(), boneFile);
				}
				if (loaded->second && !loaded->second->empty()) {
					result->second = this->parseTextureAtlasData(loaded->second->c_str(), nullptr, atlasFile);
				}
				return nullptr;
			},
			[=, this](Own<Values>) {
				if (result->first.value()) {
					_boneRefs[boneFile] = 0;
				}
				if (result->second.value()) {
					_atlasRefs[atlasFile] = 0;
				}
				handler(result->first.value() && result->second.value());
				this->_asyncLoadCount--;
			});
	};
	if (!boneData) {
		SharedContent.loadAsync(boneFile, [loaded, boneFile, parseData](String data) {
			if (!data.empty()) {
				loaded->first = data.toString();
				if (loaded->second) {
					parseData();
				}
			} else {
				Error("failed to load bone \"{}\".", boneFile);
			}
		});
	}
	if (!atlasData) {
		SharedContent.loadAsync(atlasFile, [loaded, atlasFile, parseData](String data) {
			if (!data.empty()) {
				loaded->second = data.toString();
				if (loaded->first) {
					parseData();
				}
			} else {
				Error("failed to load atlas \"{}\".", atlasFile);
			}
		});
	}
}

DragonBone* DragonBoneCache::loadDragonBone(String boneStr) {
	std::string boneFile, atlasFile, armatureName;
	std::tie(boneFile, atlasFile, armatureName) = getFileFromStr(boneStr);
	if (boneFile.empty() || atlasFile.empty()) return nullptr;
	auto result = load(boneFile, atlasFile);
	if (!result.first) {
		Error("failed to load DragonBone from \"{}\".", boneStr.toString());
		return nullptr;
	}
	if (armatureName.empty()) {
		armatureName = result.second;
	}
	return buildDragonBoneNode(boneFile, atlasFile, armatureName);
}

DragonBone* DragonBoneCache::loadDragonBone(String boneFile, String atlasFile) {
	auto result = load(boneFile, atlasFile);
	if (!result.first) {
		Error("failed to load DragonBone from \"{}\" and \"{}\".", boneFile.toString(), atlasFile.toString());
		return nullptr;
	}
	return buildDragonBoneNode(boneFile, atlasFile, result.second);
}

bool DragonBoneCache::removeUnusedBone(String boneFile) {
	auto fullPath = SharedContent.getFullPath(boneFile);
	auto it = _boneRefs.find(fullPath);
	if (it != _boneRefs.end()) {
		if (it->second == 0) {
			this->removeDragonBonesData(fullPath);
			return true;
		}
	}
	return false;
}

bool DragonBoneCache::removeUnusedAtlas(String atlasFile) {
	auto fullPath = SharedContent.getFullPath(atlasFile);
	auto it = _atlasRefs.find(fullPath);
	if (it != _atlasRefs.end()) {
		if (it->second == 0) {
			this->removeTextureAtlasData(fullPath);
			return true;
		}
	}
	return false;
}

void DragonBoneCache::removeUnused() {
	for (const auto& ref : _atlasRefs) {
		if (ref.second == 0) {
			this->removeTextureAtlasData(ref.first);
		}
	}
	for (const auto& ref : _boneRefs) {
		if (ref.second == 0) {
			this->removeDragonBonesData(ref.first);
		}
	}
}

NS_DORA_END

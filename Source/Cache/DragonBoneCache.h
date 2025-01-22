/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Common/Singleton.h"
#include "dragonBones/DragonBonesHeaders.h"

namespace db = dragonBones;

NS_DORA_BEGIN

class Texture2D;
class DragonBone;

class DBTextureData : public db::TextureData {
	BIND_CLASS_TYPE_B(DBTextureData);

public:
	DBTextureData() { }
	virtual ~DBTextureData() { _onClear(); }
};

class DBTextureAtlasData : public db::TextureAtlasData {
	BIND_CLASS_TYPE_B(DBTextureAtlasData);

public:
	PROPERTY(Texture2D*, Texture);
	DBTextureAtlasData() { }
	virtual ~DBTextureAtlasData() { _onClear(); }
	virtual DBTextureData* createTexture() const override;

protected:
	virtual void _onClear() override;

private:
	Ref<Texture2D> _texture;
};

class DragonBoneCache : public db::BaseFactory, public NonCopyable {
public:
	std::pair<db::DragonBonesData*, std::string> load(String boneStr);
	std::pair<db::DragonBonesData*, std::string> load(String boneFile, String atlasFile);
	void loadAsync(String boneStr, const std::function<void(bool)>& handler);
	void loadAsync(String boneFile, String atlasFile, const std::function<void(bool)>& handler);
	DragonBone* loadDragonBone(String boneStr);
	DragonBone* loadDragonBone(String boneFile, String atlasFile);
	bool removeUnusedBone(String boneFile);
	bool removeUnusedAtlas(String atlasFile);
	void removeUnused();

protected:
	db::DragonBonesData* loadDragonBonesData(String filePath);
	DBTextureAtlasData* loadTextureAtlasData(String filePath);
	DragonBone* buildDragonBoneNode(String boneFile, String atlasFile, String armatureName);

protected:
	DragonBoneCache();
	virtual db::TextureAtlasData* _buildTextureAtlasData(db::TextureAtlasData* textureAtlasData, void* textureAtlas) const override;
	virtual db::Armature* _buildArmature(const db::BuildArmaturePackage& dataPackage) const override;
	virtual db::Slot* _buildSlot(const db::BuildArmaturePackage& dataPackage, const db::SlotData* slotData, db::Armature* armature) const override;

private:
	class EventManager : public db::IEventDispatcher {
		virtual bool hasDBEventListener(const std::string& type) const override;
		virtual void dispatchDBEvent(const std::string& type, db::EventObject* value) override;
	} _eventManager;
	int _asyncLoadCount;
	Own<db::DragonBones> _dragonBoneInstance;
	std::tuple<std::string, std::string, std::string> getFileFromStr(String boneStr);
	StringMap<int> _atlasRefs;
	StringMap<int> _boneRefs;
	SINGLETON_REF(DragonBoneCache, Director, AsyncThread);
};

#define SharedDragonBoneCache \
	Dora::Singleton<Dora::DragonBoneCache>::shared()

NS_DORA_END

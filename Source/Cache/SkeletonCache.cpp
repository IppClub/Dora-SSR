/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/SkeletonCache.h"
#include "Basic/Content.h"
#include "Cache/AtlasCache.h"
#include "Common/Async.h"

NS_DOROTHY_BEGIN

SkeletonData::SkeletonData(spine::SkeletonData* skeletonData, Atlas* atlas):
_atlas(atlas),
_skeletonData(skeletonData)
{}

spine::SkeletonData* SkeletonData::getSkel() const
{
	return _skeletonData.get();
}

Atlas* SkeletonData::getAtlas() const
{
	return _atlas;
}

std::pair<string, string> SkeletonCache::getFileFromStr(String spineStr)
{
	auto items = spineStr.split("|"_slice);
	if (items.size() == 2)
	{
		Slice skelFile, atlasFile;
		for (auto item : items)
		{
			switch (Switch::hash(Path::getExt(item)))
			{
				case "skel"_hash:
				case "json"_hash:
					skelFile = item;
					break;
				case "atlas"_hash:
					atlasFile = item;
					break;
			}
		}
		return {skelFile, atlasFile};
	}
	auto str = spineStr.toString();
	string skelFile = str + ".skel"_slice;
	if (!SharedContent.isExist(str + ".skel"_slice))
	{
		skelFile = str + ".json"_slice;
	}
	return {skelFile, str + ".atlas"_slice};
}

SkeletonData* SkeletonCache::load(String spineStr)
{
	string skelFile, atlasFile;
	std::tie(skelFile, atlasFile) = getFileFromStr(spineStr);
	return load(skelFile, atlasFile);
}

SkeletonData* SkeletonCache::load(String skelFile, String atlasFile)
{
	string skelPath = SharedContent.getFullPath(skelFile);
	string atlasPath = SharedContent.getFullPath(atlasFile);
	string cacheKey = skelPath + atlasPath;
	auto it = _skeletons.find(cacheKey);
	if (it != _skeletons.end())
	{
		return it->second;
	}
	auto atlas = SharedAtlasCache.load(atlasFile);
	if (!atlas)
	{
		Warn("fail to load atlas \"{}\"", atlasFile);
		return nullptr;
	}
	SkeletonData* skeletonData = nullptr;
	auto ext = Path::getExt(skelPath);
	switch (Switch::hash(ext))
	{
		case "skel"_hash:
		{
			spine::SkeletonBinary bin(atlas->get());
			skeletonData = SkeletonData::create(bin.readSkeletonDataFile(skelPath.c_str()), atlas);
			break;
		}
		case "json"_hash:
		{
			spine::SkeletonJson json(atlas->get());
			skeletonData = SkeletonData::create(json.readSkeletonDataFile(skelPath.c_str()), atlas);
			break;
		}
		default:
			Warn("can not load skeleton format of \"{}\"", ext);
			return nullptr;
	}
	if (skeletonData && skeletonData->getSkel())
	{
		_skeletons[cacheKey] = skeletonData;
		return skeletonData;
	}
	Warn("fail to load skeleton data \"{}\".", skelFile);
	return nullptr;
}

void SkeletonCache::loadAsync(String spineStr, const function<void(SkeletonData*)>& handler)
{
	string skelFile, atlasFile;
	std::tie(skelFile, atlasFile) = getFileFromStr(spineStr);
	loadAsync(skelFile, atlasFile, handler);
}

void SkeletonCache::loadAsync(String skelFile, String atlasFile, const function<void(SkeletonData*)>& handler)
{
	string skelPath = SharedContent.getFullPath(skelFile);
	string atlasPath = SharedContent.getFullPath(atlasFile);
	string file = skelFile.toString();
	SharedAtlasCache.loadAsync(atlasFile, [file, handler, this](Atlas* atlas)
	{
		if (!atlas)
		{
			Warn("fail to load skeleton data \"{}\".", file);
			handler(nullptr);
			return;
		}
		Ref<Atlas> at(atlas);
		SharedContent.loadFileAsyncData(file, [file, handler, at, this](OwnArray<Uint8>&& data, size_t size)
		{
			if (!data)
			{
				Warn("fail to load skeleton data \"{}\".", file);
				return;
			}
			auto skelData = std::make_shared<std::tuple<string, OwnArray<Uint8>, size_t>>(std::move(file), std::move(data), size);
			SharedAsyncThread.run([skelData, at]()
			{
				string file;
				OwnArray<Uint8> data;
				size_t size = 0;
				std::tie(file, data, size) = std::move(*skelData);
				auto ext = Path::getExt(file);
				spine::SkeletonData* skelData = nullptr;
				switch (Switch::hash(ext))
				{
					case "skel"_hash:
					{
						spine::SkeletonBinary bin(at->get());
						skelData = bin.readSkeletonData(data.get(), s_cast<int>(size));
						break;
					}
					case "json"_hash:
					{
						spine::SkeletonJson json(at->get());
						skelData = json.readSkeletonData(string(r_cast<char*>(data.get()), s_cast<int>(size)).c_str());
						break;
					}
					default:
						Warn("can not load skeleton format of \"{}\" from \"{}\"", ext, file);
						break;
				}
				return Values::create(skelData);
			}, [file, handler, at, this](Own<Values> result)
			{
				spine::SkeletonData* skelData = nullptr;
				result->get(skelData);
				if (skelData)
				{
					SkeletonData* data = SkeletonData::create(skelData, at);
					auto fullPath = SharedContent.getFullPath(file);
					_skeletons[fullPath] = data;
					handler(data);
					return;
				}
				Warn("fail to load skeleton data \"{}\".", file);
				handler(nullptr);
				return;
			});
		});
	});
}

bool SkeletonCache::unload(String filename)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _skeletons.find(fullPath);
	if (it != _skeletons.end())
	{
		_skeletons.erase(it);
		return true;
	}
	return false;
}

bool SkeletonCache::unload(SkeletonData* data)
{
	for (const auto& it : _skeletons)
	{
		if (it.second == data)
		{
			_skeletons.erase(_skeletons.find(it.first));
			return true;
		}
	}
	return false;
}

bool SkeletonCache::unload()
{
	if (_skeletons.empty())
	{
		return false;
	}
	_skeletons.clear();
	return true;
}

void SkeletonCache::removeUnused()
{
	vector<unordered_map<string,Ref<SkeletonData>>::iterator> targets;
	for (auto it = _skeletons.begin(); it != _skeletons.end(); ++it)
	{
		if (it->second->isSingleReferenced())
		{
			targets.push_back(it);
		}
	}
	for (const auto& it : targets)
	{
		_skeletons.erase(it);
	}
}

NS_DOROTHY_END

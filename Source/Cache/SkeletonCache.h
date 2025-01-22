/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Common/Singleton.h"
#include "spine/spine.h"

NS_DORA_BEGIN

class Atlas;

class SkeletonData : public Object {
public:
	PROPERTY_READONLY(spine::SkeletonData*, Skel);
	PROPERTY_READONLY(Atlas*, Atlas);
	CREATE_FUNC_NOT_NULL(SkeletonData);

protected:
	SkeletonData(NotNull<spine::SkeletonData, 1> skeletonData, NotNull<Atlas, 2> atlas);

private:
	Ref<Atlas> _atlas;
	Own<spine::SkeletonData> _skeletonData;
	DORA_TYPE_OVERRIDE(SkeletonData)
};

class SkeletonCache : public NonCopyable {
public:
	SkeletonData* load(String spineStr);
	SkeletonData* load(String skelFile, String atlasFile);
	void loadAsync(String spineStr, const std::function<void(SkeletonData*)>& handler);
	void loadAsync(String skelFile, String atlasFile, const std::function<void(SkeletonData*)>& handler);
	bool unload(String spineStr);
	bool unload(String skelFile, String atlasFile);
	bool unload();
	void removeUnused();

private:
	static std::pair<std::string, std::string> getFileFromStr(String spineStr);
	StringMap<Ref<SkeletonData>> _skeletons;
	SINGLETON_REF(SkeletonCache, Director, AsyncThread);
};

#define SharedSkeletonCache \
	Dora::Singleton<Dora::SkeletonCache>::shared()

NS_DORA_END

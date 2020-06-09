/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/AtlasCache.h"
#include "Basic/Content.h"
#include "Cache/TextureCache.h"

NS_DOROTHY_BEGIN

class SpineTextureLoader : public spine::TextureLoader
{
public:
	virtual ~SpineTextureLoader() {}

	virtual void load(spine::AtlasPage& page, const spine::String& path)
	{
		auto texture = SharedTextureCache.load({path.buffer(), path.length()});
		if (!texture) return;
		texture->retain();
		page.setRendererObject(texture);
		page.width = texture->getWidth();
		page.height = texture->getHeight();
	}

	virtual void unload(void* texture)
	{
		auto tex = r_cast<Texture2D*>(texture);
		SharedTextureCache.unload(tex);
		tex->release();
	}
};

static SpineTextureLoader* getTextureLoader()
{
	static SpineTextureLoader loader;
	return &loader;
}

Atlas::Atlas(spine::Atlas* atlas):
_atlas(atlas)
{}

spine::Atlas* Atlas::get() const
{
	return _atlas.get();
}

Atlas* AtlasCache::load(String filename)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _atlas.find(fullPath);
	if (it != _atlas.end())
	{
		return it->second;
	}
	Atlas* atlas = Atlas::create(new spine::Atlas(fullPath.c_str(), getTextureLoader()));
	if (atlas->get())
	{
		_atlas[fullPath] = atlas;
		return atlas;
	}
	Warn("fail to load atlas \"{}\".", filename);
	return nullptr;
}

void AtlasCache::loadAsync(String filename, const function<void(Atlas*)>& handler)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _atlas.find(fullPath);
	if (it != _atlas.end())
	{
		handler(it->second);
		return;
	}
	auto dir = Path::getPath(fullPath);
	auto file = filename.toString();
	SharedContent.loadFileAsync(fullPath, [file, dir, handler, this](String data)
	{
		if (data.empty())
		{
			Warn("fail to async load atlas \"{}\".", file);
			handler(nullptr);
			return;
		}
		auto atlas = Atlas::create(new spine::Atlas(
			r_cast<const char*>(data.begin()),
			s_cast<int>(data.size()), dir.c_str(),
			getTextureLoader(), false));
		auto& pages = atlas->get()->getPages();
		size_t size = pages.size();
		auto atlasData = std::make_shared<std::tuple<Ref<Atlas>, size_t, size_t, bool>>(atlas, 0, size, false);
		for (size_t i = 0; i < size; i++)
		{
			const auto& path = pages[i]->texturePath;
			string texFile(path.buffer(), path.length());
			SharedTextureCache.loadAsync(file, [texFile, file, atlasData, i, handler, this](Texture2D* texture)
			{
				auto& data = *atlasData.get();
				auto& atlas = std::get<0>(data);
				auto& count = std::get<1>(data);
				auto total = std::get<2>(data);
				auto& failed = std::get<3>(data);
				if (texture)
				{
					auto& page = atlas->get()->getPages()[i];
					page->setRendererObject(texture);
					page->width = texture->getWidth();
					page->height = texture->getHeight();
					texture->retain();
				}
				else
				{
					failed = true;
					Warn("fail to load texture \"{}\" of atlas \"{}\".", texFile, file);
				}
				count++;
				if (count == total)
				{
					if (failed)
					{
						handler(nullptr);
					}
					else
					{
						auto fullPath = SharedContent.getFullPath(file);
						_atlas[fullPath] = atlas;
						handler(atlas);
					}
				}
			});
		}
	});
}

bool AtlasCache::unload(String filename)
{
	string fullPath = SharedContent.getFullPath(filename);
	auto it = _atlas.find(fullPath);
	if (it != _atlas.end())
	{
		_atlas.erase(it);
		return true;
	}
	return false;
}

bool AtlasCache::unload(Atlas* atlas)
{
	for (const auto& it : _atlas)
	{
		if (it.second == atlas)
		{
			_atlas.erase(_atlas.find(it.first));
			return true;
		}
	}
	return false;
}

bool AtlasCache::unload()
{
	if (_atlas.empty())
	{
		return false;
	}
	_atlas.clear();
	return true;
}

void AtlasCache::removeUnused()
{
	vector<unordered_map<string,Ref<Atlas>>::iterator> targets;
	for (auto it = _atlas.begin();it != _atlas.end();++it)
	{
		if (it->second->isSingleReferenced())
		{
			targets.push_back(it);
		}
	}
	for (const auto& it : targets)
	{
		_atlas.erase(it);
	}
}

NS_DOROTHY_END

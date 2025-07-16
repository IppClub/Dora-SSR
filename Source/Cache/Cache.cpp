/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/Cache.h"

#include "Animation/ModelDef.h"
#include "Cache/AtlasCache.h"
#include "Cache/AudioCache.h"
#include "Cache/ClipCache.h"
#include "Cache/DragonBoneCache.h"
#include "Cache/FontCache.h"
#include "Cache/FrameCache.h"
#include "Cache/ModelCache.h"
#include "Cache/ParticleCache.h"
#include "Cache/SVGCache.h"
#include "Cache/ShaderCache.h"
#include "Cache/SkeletonCache.h"
#include "Cache/TMXCache.h"
#include "Cache/TextureCache.h"
#include "Node/Label.h"
#include "Node/Particle.h"

NS_DORA_BEGIN

bool Cache::load(String filename) {
	auto tokens = filename.split(":"_slice);
	if (tokens.size() == 2) {
		switch (Switch::hash(tokens.front())) {
			case "model"_hash:
				return SharedModelCache.load(tokens.back()) != nullptr;
			case "spine"_hash:
				return SharedSkeletonCache.load(tokens.back()) != nullptr;
			case "bone"_hash:
				return SharedDragonBoneCache.load(tokens.back()).first != nullptr;
			case "font"_hash:
				return SharedFontCache.load(tokens.back());
			default:
				break;
		}
	}
	std::string ext = Path::getExt(filename);
	if (!ext.empty()) {
		switch (Switch::hash(ext)) {
			case "atlas"_hash:
				return SharedAtlasCache.load(filename) != nullptr;
			case "clip"_hash:
				return SharedClipCache.load(filename) != nullptr;
			case "frame"_hash:
				return SharedFrameCache.load(filename) != nullptr;
			case "model"_hash:
				return SharedModelCache.load(filename) != nullptr;
			case "par"_hash:
				return SharedParticleCache.load(filename) != nullptr;
			case "jpg"_hash:
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				return SharedTextureCache.load(filename) != nullptr;
			case "svg"_hash:
				return SharedSVGCache.load(filename) != nullptr;
			case "bin"_hash:
				return SharedShaderCache.load(filename) != nullptr;
			case "wav"_hash:
			case "ogg"_hash:
			case "mp3"_hash:
			case "flac"_hash:
				return SharedAudioCache.load(filename) != nullptr;
			case "tmx"_hash:
				return SharedTMXCache.load(filename) != nullptr;
			default: {
				Error("failed to load unsupported resource \"{}\".", filename.toString());
				return false;
			}
		}
	}
	return false;
}

void Cache::loadAsync(String filename, const std::function<void(bool)>& callback) {
	auto tokens = filename.split(":"_slice);
	if (tokens.size() == 2) {
		switch (Switch::hash(tokens.front())) {
			case "model"_hash:
				SharedModelCache.loadAsync(tokens.back(), [callback](ModelDef* res) {
					callback(res != nullptr);
				});
				return;
			case "spine"_hash:
				SharedSkeletonCache.loadAsync(tokens.back(), [callback](SkeletonData* res) {
					callback(res != nullptr);
				});
				return;
			case "bone"_hash:
				SharedDragonBoneCache.loadAsync(tokens.back(), [callback](bool res) {
					callback(res);
				});
				return;
			case "font"_hash:
				SharedFontCache.loadAync(tokens.back(), [callback](Font* res) {
					callback(res != nullptr);
				});
				return;
			default:
				break;
		}
	}
	auto clipTokens = filename.split("|"_slice);
	if (clipTokens.size() == 2) {
		filename = clipTokens.front();
	}
	std::string ext = Path::getExt(filename);
	if (!ext.empty()) {
		switch (Switch::hash(ext)) {
			case "clip"_hash:
				SharedClipCache.loadAsync(filename, [callback](ClipDef* res) {
					callback(res != nullptr);
				});
				break;
			case "frame"_hash:
				SharedFrameCache.loadAsync(filename, [callback](FrameActionDef* res) {
					callback(res != nullptr);
				});
				break;
			case "model"_hash:
				SharedModelCache.loadAsync(filename, [callback](ModelDef* res) {
					callback(res != nullptr);
				});
				break;
			case "par"_hash:
				SharedParticleCache.loadAsync(filename, [callback](ParticleDef* res) {
					callback(res != nullptr);
				});
				break;
			case "jpg"_hash:
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				SharedTextureCache.loadAsync(filename, [callback](Texture2D* res) {
					callback(res != nullptr);
				});
				break;
			case "svg"_hash:
				SharedSVGCache.loadAsync(filename, [callback](SVGDef* res) {
					callback(res != nullptr);
				});
				break;
			case "bin"_hash:
				SharedShaderCache.loadAsync(filename, [callback](Shader* res) {
					callback(res != nullptr);
				});
				break;
			case "wav"_hash:
			case "ogg"_hash:
			case "mp3"_hash:
			case "flac"_hash:
				SharedAudioCache.loadAsync(filename, [callback](AudioFile* res) {
					callback(res != nullptr);
				});
				break;
			case "tmx"_hash:
				return SharedTMXCache.loadAsync(filename, [callback](TMXDef* res) {
					callback(res != nullptr);
				});
				break;
			default:
				Error("resource is not supported: \"{}\".", filename.toString());
				callback(false);
				break;
		}
	}
}

void Cache::update(String filename, String content) {
	std::string ext = Path::getExt(filename);
	if (!ext.empty()) {
		switch (Switch::hash(ext)) {
			case "clip"_hash:
				SharedClipCache.update(filename, content);
				break;
			case "frame"_hash:
				SharedFrameCache.update(filename, content);
				break;
			case "model"_hash:
				SharedModelCache.update(filename, content);
				break;
			case "par"_hash:
				SharedParticleCache.update(filename, content);
				break;
			case "svg"_hash:
				SharedSVGCache.update(filename, content);
				break;
			default:
				Error("failed to update unsupported resource \"{}\".", filename.toString());
				break;
		}
	}
}

void Cache::update(String filename, Texture2D* texture) {
	SharedTextureCache.update(filename, texture);
}

bool Cache::unload(String name) {
	auto tokens = name.split(":"_slice);
	if (tokens.size() == 2) {
		switch (Switch::hash(tokens.front())) {
			case "spine"_hash:
				return SharedSkeletonCache.unload(tokens.back());
		}
	}
	std::string ext = Path::getExt(name);
	if (!ext.empty()) {
		switch (Switch::hash(ext)) {
			case "atlas"_hash:
				return SharedAtlasCache.unload(name);
			case "clip"_hash:
				return SharedClipCache.unload(name);
			case "frame"_hash:
				return SharedFrameCache.unload(name);
			case "model"_hash:
				return SharedModelCache.unload(name);
			case "par"_hash:
				return SharedParticleCache.unload(name);
			case "jpg"_hash:
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				return SharedTextureCache.unload(name);
			case "svg"_hash:
				return SharedSVGCache.unload(name);
			case "bin"_hash:
				return SharedShaderCache.unload(name);
			case "wav"_hash:
			case "ogg"_hash:
			case "mp3"_hash:
			case "flac"_hash:
				return SharedAudioCache.unload(name);
			case "tmx"_hash:
				return SharedTMXCache.unload(name);
			default:
				Warn("failed to unload resource \"{}\".", name.toString());
				break;
		}
	} else {
		switch (Switch::hash(name)) {
			case "Texture"_hash:
				return SharedTextureCache.unload();
			case "SVG"_hash:
				return SharedSVGCache.unload();
			case "Clip"_hash:
				return SharedClipCache.unload();
			case "Frame"_hash:
				return SharedFrameCache.unload();
			case "Model"_hash:
				return SharedModelCache.unload();
			case "Particle"_hash:
				return SharedParticleCache.unload();
			case "Shader"_hash:
				return SharedShaderCache.unload();
			case "Font"_hash:
				return SharedFontCache.unload();
			case "Sound"_hash:
				return SharedAudioCache.unload();
			case "Spine"_hash:
				return SharedAtlasCache.unload() && SharedSkeletonCache.unload();
			case "TMX"_hash:
				return SharedTMXCache.unload();
			default: {
				Warn("failed to unload resources \"{}\".", name.toString());
				break;
			}
		}
	}
	return false;
}

void Cache::unload() {
	SharedShaderCache.unload();
	SharedModelCache.unload();
	SharedFrameCache.unload();
	SharedParticleCache.unload();
	SharedClipCache.unload();
	SharedTextureCache.unload();
	SharedSVGCache.unload();
	SharedFontCache.unload();
	SharedAudioCache.unload();
	SharedSkeletonCache.unload();
	SharedAtlasCache.unload();
	SharedDragonBoneCache.removeUnused();
	SharedTMXCache.unload();
}

void Cache::removeUnused() {
	SharedDragonBoneCache.removeUnused();
	SharedSkeletonCache.removeUnused();
	SharedAtlasCache.removeUnused();
	SharedShaderCache.removeUnused();
	SharedModelCache.removeUnused();
	SharedFrameCache.removeUnused();
	SharedParticleCache.removeUnused();
	SharedClipCache.removeUnused();
	SharedTextureCache.removeUnused();
	SharedSVGCache.removeUnused();
	SharedFontCache.removeUnused();
	SharedAudioCache.removeUnused();
	SharedTMXCache.removeUnused();
}

void Cache::removeUnused(String name) {
	switch (Switch::hash(name)) {
		case "Bone"_hash:
			SharedDragonBoneCache.removeUnused();
			break;
		case "Spine"_hash:
			SharedAtlasCache.removeUnused();
			SharedSkeletonCache.removeUnused();
			break;
		case "Texture"_hash:
			SharedTextureCache.removeUnused();
			break;
		case "SVG"_hash:
			SharedSVGCache.removeUnused();
			break;
		case "Clip"_hash:
			SharedClipCache.removeUnused();
			break;
		case "Frame"_hash:
			SharedFrameCache.removeUnused();
			break;
		case "Model"_hash:
			SharedModelCache.removeUnused();
			break;
		case "Particle"_hash:
			SharedParticleCache.removeUnused();
			break;
		case "Shader"_hash:
			SharedShaderCache.removeUnused();
			break;
		case "Font"_hash:
			SharedFontCache.removeUnused();
			break;
		case "Sound"_hash:
			SharedAudioCache.removeUnused();
			break;
		case "TMX"_hash:
			SharedTMXCache.removeUnused();
			break;
		default:
			Error("failed to remove unused cache type \"{}\".", name.toString());
			break;
	}
}

NS_DORA_END

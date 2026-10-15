/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node3D.h"

NS_DORA_BEGIN

class Model3DDef;
class View3D;
class Texture2D;
class Model3D;

enum class MaterialAlphaMode3D : uint8_t {
	Opaque,
	Mask,
	Blend,
};

class Material3D : public Object {
public:
	static constexpr uint8_t Opaque = s_cast<uint8_t>(MaterialAlphaMode3D::Opaque);
	static constexpr uint8_t Mask = s_cast<uint8_t>(MaterialAlphaMode3D::Mask);
	static constexpr uint8_t Blend = s_cast<uint8_t>(MaterialAlphaMode3D::Blend);
	PROPERTY(Color, BaseColor);
	PROPERTY(Color3, Emissive);
	PROPERTY(float, Metallic);
	PROPERTY(float, Roughness);
	PROPERTY(MaterialAlphaMode3D, AlphaMode);
	void setAlphaModeValue(uint8_t mode);
	uint8_t getAlphaModeValue() const noexcept;
	PROPERTY(float, AlphaCutoff);
	void setBaseColorTexture(Texture2D* texture);
	void clearBaseColorTexture();
	void setMetallicRoughnessTexture(Texture2D* texture);
	void clearMetallicRoughnessTexture();
	void setNormalTexture(Texture2D* texture);
	void clearNormalTexture();
	void setEmissiveTexture(Texture2D* texture);
	void clearEmissiveTexture();
	void setOcclusionTexture(Texture2D* texture);
	void clearOcclusionTexture();
	virtual void cleanup() override;

protected:
	Material3D(NotNull<Model3D, 1> model, uint32_t index);

private:
	void clearModel();
	void setTexture(uint8_t slot, Texture2D* texture);
	WRef<Model3D> _model;
	uint32_t _index;
	std::array<Ref<Texture2D>, 5> _textures;
	friend class Model3D;
	friend class Object;
	DORA_TYPE_OVERRIDE(Material3D);
};

class Model3D : public Node3D {
public:
	PROPERTY(float, Speed);
	PROPERTY_READONLY(float, Duration);
	PROPERTY_READONLY(float, Elapsed);
	PROPERTY_READONLY_BOOL(Playing);
	PROPERTY_READONLY_BOOL(Paused);
	PROPERTY_READONLY(uint32_t, AnimationCount);
	PROPERTY_READONLY(uint32_t, MaterialCount);
	virtual bool init() override;
	std::string getAnimationName(uint32_t index) const;
	bool hasNode(String name) const;
	bool attachToNode(String name, NotNull<Node3D, 2> child);
	Vec3 getLocalBoundsMin() const;
	Vec3 getLocalBoundsMax() const;
	Vec3 getWorldBoundsMin() const;
	Vec3 getWorldBoundsMax() const;
	Material3D* getMaterial(uint32_t index);
	float play(String name = String{}, bool loop = false);
	void stop();
	void pause();
	void resume();
	virtual void cleanup() override;
	bool update(double deltaTime) override;
	CREATE_FUNC_NOT_NULL(Model3D);

protected:
	Model3D(String path);
	Model3D();
	virtual ~Model3D();

private:
	void destroyInstance();
	bool getBounds(bool worldSpace, Vec3& min, Vec3& max) const;
	float rayCast(const Vec3& origin, const Vec3& direction) const;
	std::string _filename;
	Ref<Model3DDef> _modelDef;
	std::vector<Ref<Material3D>> _materials;
	uint64_t _instance;
	bool _playing;
	bool _paused;
	friend class Material3D;
	friend class View3D;
	DORA_TYPE_OVERRIDE(Model3D);
};

NS_DORA_END

/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DORA_BEGIN

class Camera3D;
class Camera;
class Node3D;
class Model3D;

struct RenderStats3D {
	uint32_t sceneNodes = 0;
	uint32_t visibleVisuals = 0;
	uint32_t culledVisuals = 0;
	uint32_t opaqueItems = 0;
	uint32_t transparentItems = 0;
	uint32_t drawCalls = 0;
	uint64_t triangles = 0;
	uint32_t programSwitches = 0;
	uint32_t materialSwitches = 0;
	uint32_t textureSwitches = 0;
	uint32_t meshSwitches = 0;
	uint32_t nodeCount = 0;
	uint32_t visualCount = 0;
	uint32_t modelCount = 0;
	uint32_t modelInstanceCount = 0;
	uint32_t meshCount = 0;
	uint32_t staticMeshCount = 0;
	uint32_t dynamicMeshCount = 0;
	uint32_t materialCount = 0;
	uint32_t textureCount = 0;
	uint32_t animationCount = 0;
	uint32_t environmentCount = 0;
	uint64_t modelResidentBytes = 0;
	uint64_t meshResidentBytes = 0;
	uint64_t textureResidentBytes = 0;
	uint64_t collectMicros = 0;
	uint64_t sortMicros = 0;
	uint64_t submitMicros = 0;
	uint64_t uploadCommands = 0;
	uint64_t uploadBytes = 0;
	uint64_t uploadMicros = 0;
	uint64_t uploadMaxCommandMicros = 0;

	uint32_t getSceneNodes() const noexcept { return sceneNodes; }
	uint32_t getVisibleVisuals() const noexcept { return visibleVisuals; }
	uint32_t getCulledVisuals() const noexcept { return culledVisuals; }
	uint32_t getOpaqueItems() const noexcept { return opaqueItems; }
	uint32_t getTransparentItems() const noexcept { return transparentItems; }
	uint32_t getDrawCalls() const noexcept { return drawCalls; }
	uint64_t getTriangles() const noexcept { return triangles; }
	uint32_t getProgramSwitches() const noexcept { return programSwitches; }
	uint32_t getMaterialSwitches() const noexcept { return materialSwitches; }
	uint32_t getTextureSwitches() const noexcept { return textureSwitches; }
	uint32_t getMeshSwitches() const noexcept { return meshSwitches; }
	uint32_t getNodeCount() const noexcept { return nodeCount; }
	uint32_t getVisualCount() const noexcept { return visualCount; }
	uint32_t getModelCount() const noexcept { return modelCount; }
	uint32_t getModelInstanceCount() const noexcept { return modelInstanceCount; }
	uint32_t getMeshCount() const noexcept { return meshCount; }
	uint32_t getStaticMeshCount() const noexcept { return staticMeshCount; }
	uint32_t getDynamicMeshCount() const noexcept { return dynamicMeshCount; }
	uint32_t getMaterialCount() const noexcept { return materialCount; }
	uint32_t getTextureCount() const noexcept { return textureCount; }
	uint32_t getAnimationCount() const noexcept { return animationCount; }
	uint32_t getEnvironmentCount() const noexcept { return environmentCount; }
	uint64_t getModelResidentBytes() const noexcept { return modelResidentBytes; }
	uint64_t getMeshResidentBytes() const noexcept { return meshResidentBytes; }
	uint64_t getTextureResidentBytes() const noexcept { return textureResidentBytes; }
	uint64_t getCollectMicros() const noexcept { return collectMicros; }
	uint64_t getSortMicros() const noexcept { return sortMicros; }
	uint64_t getSubmitMicros() const noexcept { return submitMicros; }
	uint64_t getUploadCommands() const noexcept { return uploadCommands; }
	uint64_t getUploadBytes() const noexcept { return uploadBytes; }
	uint64_t getUploadMicros() const noexcept { return uploadMicros; }
	uint64_t getUploadMaxCommandMicros() const noexcept { return uploadMaxCommandMicros; }
};

class View3D : public Node {
public:
	PROPERTY_READONLY_CALL(Node3D*, Scene);
	PROPERTY_READONLY_CREF(RenderStats3D, Stats);
	PROPERTY_BOOL(ShowAABB);
	PROPERTY(uint16_t, ShadowMapSize);
	using Node::addChild;
	void addChild(Node3D* child, int order, String tag);
	void addChild(Node3D* child, int order);
	void addChild(Node3D* child);
	Vec3 getRayOrigin(const Vec2& viewPoint) const;
	Vec3 getRayDirection(const Vec2& viewPoint) const;
	Model3D* pick(const Vec2& viewPoint) const;
	bool setEnvironmentMap(String path);
	void setEnvironmentIntensity(float diffuse, float specular, float exposure = 1.0f);
	virtual bool init() override;
	virtual void render() override;
	virtual void cleanup() override;
	CREATE_FUNC_NOT_NULL(View3D);

protected:
	View3D();
	~View3D();

private:
	bool getScreenRay(const Vec2& viewPoint, Vec3& origin, Vec3& direction) const;
	void render3D(bgfx::ViewId viewId);
	std::string _environmentMap;
	uint64_t _environmentGeneration = 0;
	float _environmentDiffuse;
	float _environmentSpecular;
	float _environmentExposure;
	bool _showAABB;
	uint16_t _shadowMapSize;
	mutable RenderStats3D _stats;
	mutable uint16_t _lastViewId;
	Ref<Node3D> _scene;
	DORA_TYPE_OVERRIDE(View3D);
};

NS_DORA_END

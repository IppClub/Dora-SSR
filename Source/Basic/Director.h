/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Array.h"
#include "Support/Common.h"
#include "Support/Geometry.h"

union SDL_Event;
struct NVGcontext;

NS_DORA_BEGIN

class Scheduler;
class Node;
class Sprite;
class Camera;
class RenderTarget;
class UITouchHandler;
class Listener;

class Director : public NonCopyable {
public:
	virtual ~Director();
	struct ProfilerInfo;
	PROPERTY(Scheduler*, Scheduler);
	PROPERTY(Color, ClearColor);
	PROPERTY_READONLY_CALL(Node*, UI);
	PROPERTY_READONLY_CALL(Node*, UI3D);
	PROPERTY_READONLY_CALL(Node*, Entry);
	PROPERTY_READONLY_CALL(Node*, PostNode);
	PROPERTY_READONLY_CALL(UITouchHandler*, UITouchHandler);
	PROPERTY_READONLY_CALL(Camera*, CurrentCamera);
	PROPERTY_READONLY_CALL(ProfilerInfo*, ProfilerInfo);
	PROPERTY_READONLY(Camera*, PrevCamera);
	PROPERTY_READONLY(Scheduler*, SystemScheduler);
	PROPERTY_READONLY(Scheduler*, PostScheduler);
	PROPERTY_READONLY_CALL(const Matrix&, ViewProjection);
	PROPERTY_BOOL(FrustumCulling);
	PROPERTY_BOOL(ProfilerSending);
	bool init();
	void doLogic();
	void doRender();
	void handleSDLEvent(const SDL_Event& event);

	void pushCamera(NotNull<Camera, 1> camera);
	void popCamera();
	bool removeCamera(NotNull<Camera, 1> camera);
	void clearCamera();

	void markDirty();
	NVGcontext* markNVGDirty();

	void cleanup();

	template <typename Func>
	void pushViewProjection(const Matrix& viewProj, const Func& workHere) {
		pushViewProjection(viewProj);
		workHere();
		popViewProjection();
	}

	bool isInFrustum(const AABB& aabb) const;

	void addUnManagedNode(Node* node);

	void addToWaitingList(Node* node);
	void removeFromWaitingList(Node* node);

protected:
	Director();
	void pushViewProjection(const Matrix& viewProj);
	void popViewProjection();

	const Matrix& getCurrentViewProjection();

	void handleTouchEvents();
	void handleUnmanagedNodes();

public:
	struct ProfilerInfo {
		const char* renderer = nullptr;
		bool multiThreaded = false;
		uint32_t frames = 0;
		double elapsedTime = 0;

		double cpuTime = 0;
		double gpuTime = 0;
		double lastAvgCPUTime = 0;
		double lastAvgGPUTime = 0;
		double lastAvgDeltaTime = 0;

		double logicTime = 0;
		double renderTime = 0;
		int memPoolSize = 0;
		int memLua = 0;
		int memTeal = 0;
		int memWASM = 0;
		int lastMemPoolSize = 0;
		int lastMemLua = 0;
		int lastMemTeal = 0;
		int lastMemWASM = 0;

		const unsigned PlotCount = 30;
		double maxCPU = 0;
		double maxGPU = 0;
		double maxDelta = 0;
		double yLimit = 0;
		std::vector<double> cpuValues;
		std::vector<double> gpuValues;
		std::vector<double> dtValues;
		std::vector<double> seconds;

		uint32_t maxCppObjects = 0;
		uint32_t maxLuaObjects = 0;
		uint32_t maxCallbacks = 0;
		uint32_t lastMaxCppObjects = 0;
		uint32_t lastMaxLuaObjects = 0;
		uint32_t lastMaxCallbacks = 0;

		double targetTime = 0;

		StringMap<double> timeCosts;
		StringMap<double> updateCosts;
		struct LoaderCost {
			int order;
			int depth;
			std::string moduleName;
			double time;
			std::string depthStr;
			std::string timeStr;
		};
		double loaderTotalTime;
		std::deque<LoaderCost> loaderCosts;
		Ref<Listener> loaderCostListener;
		bool loaderCostDirty = false;
		bool profilerSending = false;
		bool skipOneFrame = true;

		void init();
		void update(double deltaTime);
		void clearLoaderInfo();
	};

private:
	bool _nvgDirty;
	bool _paused;
	bool _stoped;
	bool _frustumCulling;
	Color _clearColor;
	Ref<Node> _ui;
	Ref<Node> _ui3D;
	Ref<Camera> _uiCamera;
	Ref<Camera> _ui3DCamera;
	Ref<Node> _postNode;
	Ref<Node> _entry;
	Ref<Node> _root;
	Ref<Array> _camStack;
	Ref<Scheduler> _systemScheduler;
	Ref<Scheduler> _scheduler;
	Ref<Scheduler> _postScheduler;
	RefVector<Node> _unmanagedNodes;
	ProfilerInfo _profilerInfo;
	std::vector<WRef<Node>> _waitingList;
	Own<UITouchHandler> _uiTouchHandler;
	struct ViewProject {
		Matrix matrix;
		Frustum frustum;
	};
	std::stack<Own<ViewProject>> _viewProjs;
	NVGcontext* _nvgContext;
	Matrix _currentViewProj;
	SINGLETON_REF(Director, EffekManager, FontManager, LuaEngine, BGFXDora, Application);
};

#define SharedDirector \
	Dora::Singleton<Dora::Director>::shared()

NS_DORA_END

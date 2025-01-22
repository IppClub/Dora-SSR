/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DORA_BEGIN

class EffekEff;

class EffekNode : public Node {
public:
	PROPERTY_CLASS(int, RunningNodes);
	virtual ~EffekNode();
	virtual bool init() override;
	virtual void onEnter() override;
	virtual void onExit() override;
	virtual bool update(double deltaTime) override;
	virtual void render() override;
	virtual void cleanup() override;
	int play(String filename, const Vec2& pos = Vec2::zero, float z = 0.0f);
	void stop(int handle);
	CREATE_FUNC_NOT_NULL(EffekNode);

protected:
	EffekNode() { }
	static int _runningNodes;

private:
	struct RunningEff {
		RunningEff(int handle, const Vec3& position, EffekEff* eff);
		int handle;
		Vec3 position;
		Ref<EffekEff> eff;
	};
	std::vector<Own<RunningEff>> _effeks;
	DORA_TYPE_OVERRIDE(EffekNode);
};

class Texture2D;
class EffekInstance;

class EffekManager : public NonCopyable {
public:
	EffekManager();
	virtual ~EffekManager();
	EffekEff* load(String filename);
	bool unload();
	void unloadUnused();
	void addTexture(int texId, Texture2D* tex);
	void removeTexture(int texId);
	void update();

	struct EffekInstanceDeleter {
		void operator()(EffekInstance* ptr) const;
	};
	Own<EffekInstance, EffekInstanceDeleter> instance;

private:
	std::unordered_map<int, Ref<Texture2D>> _textureRefs;
	StringMap<Ref<EffekEff>> _effects;
	SINGLETON_REF(EffekManager, BGFXDora);
};

#define SharedEffekManager \
	Dora::Singleton<Dora::EffekManager>::shared()

NS_DORA_END

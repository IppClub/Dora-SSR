/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Physics/PhysicsWorld.h"
#include "Node/Node.h"

NS_DOROTHY_PLATFORMER_BEGIN

class PlatformCamera;

class PlatformWorld : public PhysicsWorld
{
public:
	PROPERTY_READONLY(PlatformCamera*, Camera);
	virtual bool init() override;
	virtual void addChild(Node* child, int order, String tag) override;
	virtual void removeChild(Node* child, bool cleanup = true) override;
	virtual void onEnter() override;
	virtual void onExit() override;
	void moveChild(Node* child, int newOrder);
	Node* getLayer(int order);
	void setLayerRatio(int order, const Vec2& ratio);
	const Vec2& getLayerRatio(int order);
	void setLayerOffset(int order, const Vec2& offset);
	const Vec2& getLayerOffset(int order);
	void swapLayer(int orderA, int orderB);
	void removeLayer(int order);
	void removeAllLayers();
	void onCameraMoved(float deltaX, float deltaY);
	CREATE_FUNC(PlatformWorld);
protected:
	virtual void sortAllChildren() override;
	class Layer : public Node
	{
	public:
		Vec2 ratio;
		PROPERTY_CREF(Vec2, Offset);
		PROPERTY(int, Index);
		CREATE_FUNC(Layer);
	protected:
		Layer():_offset{},ratio{} { }
		virtual void sortAllChildren() override;
	private:
		int _index;
		Vec2 _offset;
		friend class PlatformWorld;
	};
private:
	Ref<PlatformCamera> _camera;
	std::unordered_map<int, WRef<Layer>> _layers;
	DORA_TYPE_OVERRIDE(PlatformWorld);
};

NS_DOROTHY_PLATFORMER_END

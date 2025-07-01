/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Event/Event.h"
#include "Support/Array.h"
#include "Support/Common.h"
#include "Support/Geometry.h"

NS_DORA_BEGIN

class Event;
class Listener;
class Signal;
class Slot;
class ScheduledItem;
class FixedScheduledItem;
class Scheduler;
class TouchHandler;
class NodeTouchHandler;
class Action;
class Dictionary;
class RenderTarget;
class SpriteEffect;
class Sprite;
class Camera;
class Grid;

typedef Acf::Delegate<void(Event* event)> NodeEventHandler;

class Node : public Object {
public:
	PROPERTY(int, Order);
	PROPERTY_VIRTUAL(float, Angle);
	PROPERTY(float, AngleX);
	PROPERTY(float, AngleY);
	PROPERTY(float, ScaleX);
	PROPERTY(float, ScaleY);
	PROPERTY(float, ScaleZ);
	PROPERTY(float, X);
	PROPERTY(float, Y);
	PROPERTY(float, Z);
	PROPERTY_VIRTUAL(Vec2, Position);
	PROPERTY(float, SkewX);
	PROPERTY(float, SkewY);
	PROPERTY_VIRTUAL_BOOL(ShowDebug);
	PROPERTY_BOOL(Visible);
	PROPERTY_BOOL(SelfVisible);
	PROPERTY_BOOL(ChildrenVisible);
	PROPERTY(Vec2, Anchor);
	PROPERTY_READONLY(Vec2, AnchorPoint);
	PROPERTY(float, Width);
	PROPERTY(float, Height);
	PROPERTY(Size, Size);
	PROPERTY_STRING(Tag);
	PROPERTY(float, Opacity);
	PROPERTY_READONLY(float, RealOpacity);
	PROPERTY(Color, Color);
	PROPERTY(Color3, Color3);
	PROPERTY_READONLY(Color, RealColor);
	PROPERTY_BOOL(PassOpacity);
	PROPERTY_BOOL(PassColor3);
	PROPERTY(Node*, TransformTarget);
	PROPERTY(Scheduler*, Scheduler);
	PROPERTY_READONLY_CALL(Dictionary*, UserData);
	PROPERTY_READONLY(Node*, Parent);
	PROPERTY_READONLY(Node*, TargetParent);
	PROPERTY_READONLY_CALL(Array*, Children);
	PROPERTY_READONLY_HAS(Children);
	PROPERTY_READONLY_BOOL(Running);
	PROPERTY_READONLY_BOOL(Updating);
	PROPERTY_READONLY_BOOL(FixedUpdating);
	PROPERTY_READONLY_BOOL(Scheduled);
	PROPERTY_READONLY_BOOL(UnManaged);
	PROPERTY_BOOL(TouchEnabled);
	PROPERTY_BOOL(SwallowTouches);
	PROPERTY_BOOL(SwallowMouseWheel);
	PROPERTY_READONLY(TouchHandler*, TouchHandler);
	PROPERTY_BOOL(KeyboardEnabled);
	PROPERTY_BOOL(ControllerEnabled);
	PROPERTY_VIRTUAL(int, RenderOrder);
	PROPERTY_BOOL(RenderGroup);
	PROPERTY_READONLY(uint32_t, NodeCount);

	virtual void addChild(Node* child, int order, String tag);
	void addChild(Node* child, int order);
	void addChild(Node* child);

	virtual Node* addTo(Node* parent, int order, String tag);
	Node* addTo(Node* parent, int order);
	Node* addTo(Node* parent);

	virtual void removeChild(Node* child, bool cleanup = true);
	void removeChildByTag(String tag, bool cleanup = true);
	void removeAllChildren(bool cleanup = true);
	void removeFromParent(bool cleanup = true);

	void moveToParent(Node* parent);

	virtual void onEnter();
	virtual void onExit();
	virtual void cleanup() override;

	Node* getChildByTag(String tag);

	void schedule(const std::function<bool(double)>& func);
	void unschedule();

	void onUpdate(const std::function<bool(double)>& func);
	void onRender(const std::function<bool(double)>& func);

	Vec2 convertToNodeSpace(const Vec2& worldPoint);
	Vec2 convertToWorldSpace(const Vec2& nodePoint);

	Vec2 convertToNodeSpace(const Vec2& worldPoint, float& zInOut);
	Vec2 convertToWorldSpace(const Vec2& nodePoint, float& zInOut);

	Vec3 convertToNodeSpace3(const Vec3& worldPoint);
	Vec3 convertToWorldSpace3(const Vec3& nodePoint);

	void convertToWindowSpace(const Vec2& nodePoint, const std::function<void(const Vec2&)>& callback);

	void scheduleUpdate();
	void scheduleFixedUpdate();
	void unscheduleUpdate();
	void unscheduleFixedUpdate();

	void visitInner();

	virtual void visit();
	virtual void render();
	virtual bool fixedUpdate(double deltaTime);
	virtual bool update(double deltaTime);

	const AffineTransform& getLocalTransform();

	void getLocalWorld(Matrix& localWorld);
	virtual const Matrix& getWorld();

	void markDirty() noexcept;
	virtual void markReorder() noexcept;

	void emit(Event* event);

	Slot* slot(String name);
	template <class Functor>
	Slot* slot(String name, const Functor& handler);
	void slot(String name, std::nullptr_t);

	Listener* gslot(String name, const EventHandler& handler);
	void gslot(String name, std::nullptr_t);
	void gslot(Listener* listener, std::nullptr_t);
	RefVector<Listener> gslot(String name);

	void setAsManaged();

	CREATE_FUNC_NOT_NULL(Node);

public:
	template <class... Args>
	void emit(String name, Args... args) {
		if (_signal) {
			EventArgs<Args...> event(name, args...);
			emit(&event);
		}
	}

	/** @brief traverse children, return true to stop. */
	template <class Func>
	bool eachChild(const Func& func) {
		if (_children && !_children->isEmpty()) {
			sortAllChildren();
			return _children->each([&](Value* value) {
				return value ? func(value->to<Node>()) : false;
			});
		}
		return false;
	}

	/** @brief traverse available node tree, return true to stop. */
	template <class Func>
	bool traverse(const Func& func) {
		if (func(this)) return true;
		if (_children && _flags.isOn(Node::TraverseEnabled)) {
			sortAllChildren();
			for (const auto& child : _children->data()) {
				if (child->to<Node>()->traverse(func)) {
					return true;
				}
			}
		}
		return false;
	}

	/** @brief traverse all node tree, return true to stop. */
	template <class Func>
	bool traverseAll(const Func& func) {
		if (func(this)) return true;
		if (_children) {
			sortAllChildren();
			for (const auto& child : _children->data()) {
				if (child->to<Node>()->traverseAll(func)) {
					return true;
				}
			}
		}
		return false;
	}

	/** @brief traverse node tree, return true to stop. */
	template <class Func>
	void traverseVisible(const Func& func) {
		if (isVisible()) {
			func(this);
			if (_children && _flags.isOn(Node::TraverseEnabled)) {
				sortAllChildren();
				for (const auto& child : _children->data()) {
					child->to<Node>()->traverseVisible(func);
				}
			}
		}
	}

	PROPERTY_READONLY(int, ActionCount);
	float runAction(Action* action, bool loop = false);
	bool hasAction(Action* action);
	void stopAllActions();
	float perform(Action* action, bool loop = false);
	void removeAction(Action* action);
	void stopAction(Action* action);

	Size alignItemsVertically(float padding = 10.0f);
	Size alignItemsVertically(const Size& size, float padding = 10.0f);
	Size alignItemsHorizontally(float padding = 10.0f);
	Size alignItemsHorizontally(const Size& size, float padding = 10.0f);
	Size alignItems(float padding = 10.0f);
	Size alignItems(const Size& size, float padding = 10.0f);
	void moveAndCullItems(const Vec2& delta);

	void attachIME();
	void detachIME();

public:
	class Grabber : public Object {
	public:
		PROPERTY(Color, ClearColor);
		PROPERTY(Camera*, Camera);
		PROPERTY(SpriteEffect*, Effect);
		PROPERTY_CREF(BlendFunc, BlendFunc);
		PROPERTY_READONLY(uint32_t, GridX);
		PROPERTY_READONLY(uint32_t, GridY);
		void setPos(int x, int y, Vec2 pos, float z = 0.0f);
		Vec2 getPos(int x, int y, float* z = nullptr) const;
		Color getColor(int x, int y) const;
		void setColor(int x, int y, Color color);
		void moveUV(int x, int y, Vec2 offset);

	protected:
		Grabber(const Size& size, uint32_t gridX, uint32_t gridY);
		void grab(Node* target);
		void visit();
		virtual void cleanup() override;
		CREATE_FUNC_NOT_NULL(Grabber);

	private:
		struct RenderPair {
			Ref<RenderTarget> rt;
			Ref<Sprite> surface;
		};
		RenderPair newRenderPair(float width, float height);
		Color _clearColor;
		Ref<Camera> _camera;
		Ref<SpriteEffect> _effect;
		std::vector<RenderPair> _renderTargets;
		Ref<Grid> _grid;
		BlendFunc _blendFunc;
		DORA_TYPE_OVERRIDE(Grabber);
		friend class Node;
	};
	Grabber* grab(bool enabled = true);
	Grabber* grab(uint32_t gridX, uint32_t gridY);

protected:
	Node(bool unManaged = true);
	virtual ~Node();
	virtual void updateRealColor3();
	virtual void updateRealOpacity();
	virtual void sortAllChildren();
	void markParentReorder();
	void pauseActionInList(Action* action);
	void resumeActionInList(Action* action);
	void stopActionInList(Action* action);
	void handleKeyboardAndController(Event* event);

protected:
	Flag _flags;
	int _order;
	int _renderOrder;
	Color _color;
	Color _realColor;
	struct NodeTransform {
		float x;
		float y;
		float z;
		float angle;
		float angleX;
		float angleY;
		float scaleX;
		float scaleY;
		float scaleZ;
		float skewX;
		float skewY;
		float anchorX;
		float anchorY;
		float anchorPointX;
		float anchorPointY;
		float width;
		float height;
		Matrix world;
		AffineTransform transform;
		WRef<Node> transformTarget;
		NodeTransform();
		static NodeTransform Default;
	};
	Own<NodeTransform> _transform;
	NodeTransform& getTransform();
	Node* _parent;
	Ref<Dictionary> _userData;
	Ref<Array> _children;
	Ref<Scheduler> _scheduler;
	Ref<Action> _action;
	Ref<Grabber> _grabber;
	Own<Signal> _signal;
	std::optional<std::string> _tag;
	std::shared_ptr<NodeTouchHandler> _touchHandler;
	struct UpdateItem {
		Own<std::list<std::function<bool(double)>>> renderFuncs;
		Own<std::function<bool(double)>> scheduledMainFunc;
		std::list<std::function<bool(double)>> scheduledThreadFuncs;
		Own<ScheduledItem> scheduledItem;
		Own<FixedScheduledItem> fixedScheduledItem;
		bool hasFunc() const;
		bool fixedScheduled() const;
		bool scheduled() const;
	};
	Own<UpdateItem> _updateItem;
	UpdateItem* getUpdateItem();
	FixedScheduledItem* getFixedScheduledItem();
	void post(String name);
	enum : Flag::ValueType {
		Visible = 1,
		SelfVisible = 1 << 1,
		ChildrenVisible = 1 << 2,
		TransformDirty = 1 << 3,
		WorldDirty = 1 << 4,
		Running = 1 << 5,
		PassOpacity = 1 << 6,
		PassColor3 = 1 << 7,
		Reorder = 1 << 8,
		Cleanup = 1 << 9,
		TouchEnabled = 1 << 10,
		SwallowTouches = 1 << 11,
		SwallowMouseWheel = 1 << 12,
		KeyboardEnabled = 1 << 13,
		ControllerEnabled = 1 << 14,
		TraverseEnabled = 1 << 15,
		RenderGrouped = 1 << 16,
		IgnoreLocalTransform = 1 << 17,
		Updating = 1 << 18,
		FixedUpdating = 1 << 19,
		UnManaged = 1 << 20,
		InWaitingList = 1 << 21,
		ShowDebug = 1 << 22,
		UserFlag = 1 << 23,
	};
	DORA_TYPE_OVERRIDE(Node);
};

class Slot {
public:
	PROPERTY_READONLY_CREF(NodeEventHandler, Handler);
	void clear();
	void handle(Event* event);
	static Own<Slot> alloc();

	template <class Functor>
	static Own<Slot> alloc(const Functor& handler) {
		auto slot = alloc();
		slot->add(handler);
		return slot;
	}
	template <class Functor>
	void add(const Functor& handler) {
		_handler += handler;
	}
	template <class Functor>
	void set(const Functor& handler) {
		_handler = handler;
	}
	template <class Functor>
	void remove(const Functor& handler) {
		_handler -= handler;
	}

protected:
	Slot();

private:
	NodeEventHandler _handler;
	DORA_TYPE(Slot);
};

template <class Functor>
Slot* Node::slot(String name, const Functor& handler) {
	auto slt = slot(name);
	slt->add(handler);
	return slt;
}

class Signal {
public:
	~Signal();
	Slot* addSlot(String name);
	Listener* addGSlot(String name, const EventHandler& handler);
	void removeGSlot(Listener* gslot);
	void removeSlots(String name);
	void removeGSlots(String name);
	Slot* getSlot(String name);
	RefVector<Listener> getGSlots(String name) const;
	void emit(Event* event);
	static const size_t MaxSlotArraySize;

private:
	using SlotMap = StringMap<Own<Slot>>;
	using SlotArray = std::vector<std::pair<std::string, Own<Slot>>>;
	std::variant<std::nullopt_t, Own<SlotMap>, Own<SlotArray>> _slots = std::nullopt;
	RefVector<Listener> _gslots;
};

NS_DORA_END

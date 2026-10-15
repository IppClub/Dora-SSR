local Entity = require("Entity").Type

-- 游戏ECS系统实体更改观察器的类。
local record Observer

	-- 监控观察器观察的实体上的组件变化，在发生变更时调用处理函数。
	-- @param func (function) 当发生组件变更时要调用的处理函数，当该处理函数返回 true 时，停止监听组件变化。
	-- @return (Observer) 当前的观察器，用于方法级连调用。
	watch: function(self: Observer, func: function(Entity): boolean): Observer
end

-- 用于创建观察器对象的类。
local record ObserverClass
	type Type = Observer

	-- 观察器可以观察的实体变更事件类型。
	enum EntityEvent

		-- 添加新实体。
		"Add"

		-- 修改现有实体上的组件。
		"Change"

		-- 添加或修改实体。
		"AddOrChange"

		-- 删除现有实体。
		"Remove"
	end

	-- 用于创建监控具有特定组件的实体变化的新观察器。
	-- @param event (EntityEvent) 要监控的实体变化类型。
	-- @param components ({string}) 监控的实体包含的组件的清单。
	-- @return (Observer) 新的观察器对象。
	metamethod __call: function(self: ObserverClass, event: EntityEvent, components: {string}): Observer
end

local observerClass: ObserverClass
return observerClass

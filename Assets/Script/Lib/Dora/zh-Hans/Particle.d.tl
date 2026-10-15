local Node = require("Node").Type

-- 用于发射动画粒子的粒子系统场景节点类。
local record Particle

	-- 继承自`Node`。
	embed Node

	-- 粒子系统是否处于活动状态。
	const active: boolean

	-- 开始发射粒子。
	start: function(self: Particle)

	-- 停止发射粒子，并等待所有活动粒子结束它们的生命周期。
	stop: function(self: Particle)

	-- 注册粒子系统结束时的回调函数。
	-- 当粒子系统节点在启动之后又停止发射粒子，并等待所有已发射的粒子结束它们的生命周期时触发。
	-- @param callback (function) 粒子系统结束时的回调函数。
	onFinished: function(self: Particle, callback: function())
end

-- 可连接到粒子系统节点对象上可以监听的事件。
-- 这只是一个事件定义的展示，定义事件名称和回调。
-- @usage
-- -- 可以使用以下形式的代码来注册监听这些事件：
-- local particle = Particle("effect.par")
-- particle:start()
-- particle:slot("Finished", function()
-- 	print("粒子系统已结束")
-- end)
local record __SLOT__

	-- 当粒子系统节点在启动之后又停止发射粒子，并等待所有已发射的粒子结束它们的生命周期时触发。
	["Finished"]: function()
end

-- 可创建新的粒子系统节点对象的类。
local record ParticleClass
	type Type = Particle

	-- 从粒子系统定义文件创建一个新的粒子系统节点对象。
	-- @param filename (string) 粒子系统定义文件的文件路径。
	-- @return (Particle) 新的粒子系统节点对象。
	metamethod __call: function(self: ParticleClass, filename: string): Particle
end

local particleClass: ParticleClass
return particleClass

local PhysicsWorld = require("PhysicsWorld").Type
local Node = require("Node").Type
local Vec2 = require("Vec2").Type
local PlatformCamera = require("Platformer.PlatformCamera").Type

-- 带有物理模拟的2D平台游戏世界的类。
local record PlatformWorld

	-- 继承自`PhysicsWorld`.
	embed PhysicsWorld

	-- 用于控制游戏世界可见区域的相机。
	const camera: PlatformCamera

	-- 移动一个子节点到另一个游戏场景层。
	-- @param child (Node) 要移动的子节点。
	-- @param newOrder (integer) 要移动到的游戏场景层的顺序编号。
	moveChild: function(self: PlatformWorld, child: Node, newOrder: integer)

	-- 获取特定顺序编号的游戏场景层。
	-- @param order (integer) 要获取的场景层的顺序编号。
	-- @return (Node) 目标的游戏场景层节点。
	getLayer: function(self: PlatformWorld, order: integer): Node

	-- 设置特定游戏场景层的平移比率，用于模拟3D投影效果。
	-- @param order (integer) 要设置的场景层的顺序编号。
	-- @param ratio (Vec2) 场景层的新平移比率。
	setLayerRatio: function(self: PlatformWorld, order: integer, ratio: Vec2)

	-- 获取特定游戏场景层的平移比率，用于模拟3D投影效果。
	-- @param order (integer) 要设置的场景层的顺序编号。
	-- @return (Vec2) 场景层的平移比率.
	getLayerRatio: function(self: PlatformWorld, order: integer): Vec2

	-- 设置特定游戏场景层的位置偏移量。
	-- @param order (integer) 要设置偏移量的场景层的顺序编号。
	-- @param offset (Vec2) 场景层的位置偏移量。
	setLayerOffset: function(self: PlatformWorld, order: integer, offset: Vec2)

	-- Gets the position offset for a given layer.
	-- @param order (integer) The order of the layer to get the offset for.
	-- @return (Vec2) The position offset for the layer.
	getLayerOffset: function(self: PlatformWorld, order: integer): Vec2

	-- 交换两个游戏场景层的顺序。
	-- @param orderA (integer) 要交换的第一个场景层的顺序编号。
	-- @param orderB (integer) 要交换的第二个场景层的顺序编号。
	swapLayer: function(self: PlatformWorld, orderA: integer, orderB: integer)

	-- 从游戏世界中删除一个场景层。
	-- @param order (integer) 要删除的场景层的位置。
	removeLayer: function(self: PlatformWorld, order: integer)

	-- 删除游戏世界中的所有场景层。
	removeAllLayers: function(self: PlatformWorld)
end

-- 用于创建PlatformWorld实例的类。
-- @usage
-- local PlatformWorld = require("PlatformWorld")
-- local world = PlatformWorld()
-- world:addTo(entry)
local record PlatformWorldClass
	type Type = PlatformWorld

	-- 创建PlatformWorld的新实例的元方法。
	-- @return (PlatformWorld) PlatformWorld的新实例
	metamethod __call: function(self: PlatformWorldClass): PlatformWorld
end

local platformWorldClass: PlatformWorldClass
return platformWorldClass

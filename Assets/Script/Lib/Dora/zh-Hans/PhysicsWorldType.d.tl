local Node = require("Node").Type
local Rect = require("Rect").Type
local Vec2 = require("Vec2").Type
local type Body = require("BodyType")

-- 表示游戏中的物理世界的类。
local record PhysicsWorld

	-- 继承自`Node`。
	embed Node

	-- 查询与指定矩形区域相交的所有物理体。
	-- @param rect (Rect) 要查询的矩形区域。
	-- @param handler (function) 对于查询中找到的每个物理体调用的函数。
	-- 	@param body (Body) 查询中找到的物理体。
	-- 	@return (boolean) 是否继续查询更多物理体，返回 false 继续，true 停止。
	-- @return (boolean) 查询是否被中断，true 表示已中断，false 表示未中断。
	query: function(self: PhysicsWorld, rect: Rect, handler: function(Body): boolean): boolean

	-- 从起点发射一条射线穿过物理世界并找到与射线相交的物理体。
	-- @param start (Vec2) 射线的起点。
	-- @param stop (Vec2) 射线的终点。
	-- @param closest (boolean) 是否在与射线相交的最近物理体上停止射线投射。
	-- 将 closest 设置为 true 可以获得更快的射线投射搜索效率。
	-- @param handler (function) 对于射线投射中找到的每个物理体调用的函数。
	-- 	@param body (Body) 射线投射中找到的物理体。
	-- 	@param point (Vec2) 射线与物理体相交的点。
	-- 	@param normal (Vec2) 相交点处的法线向量。
	-- 	@return (boolean) 是否继续投射射线以获得更多物理体，返回 true 停止，false 继续。
	-- @return (boolean) 射线投射是否被中断，true 表示已中断，false 表示未中断。
	raycast: function(self: PhysicsWorld, start: Vec2, stop: Vec2, closest: boolean, handler: function(Body, point: Vec2, normal: Vec2): boolean): boolean

	-- 设置物理世界做物理模拟计算的速度迭代和位置迭代次数。
	-- @param velocityIter (integer) 要执行的速度迭代次数。
	-- @param positionIter (integer) 要执行的位置迭代次数。
	setIterations: function(self: PhysicsWorld, velocityIter: integer, positionIter: integer)

	-- 设置两个物理组是否会彼此碰撞。
	-- @param groupA (integer) 第一个物理对象分组。
	-- @param groupB (integer) 第二个物理对象分组。
	-- @param contact (boolean) 两个组是否应该彼此碰撞。
	setShouldContact: function(self: PhysicsWorld, groupA: integer, groupB: integer, contact: boolean)

	-- 获取两个物理组是否会彼此碰撞。
	-- @param groupA (integer) 第一个物理对象分组。
	-- @param groupB (integer) 第二个物理对象分组。
	-- @return (boolean) 两个组是否会彼此碰撞。
	getShouldContact: function(self: PhysicsWorld, groupA: integer, groupB: integer): boolean
end

return PhysicsWorld

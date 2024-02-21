local type Vec2 = require("Vec2Type")
local type Size = require("SizeType")

-- 用于创建二维向量对象的类。
local record Vec2Class
	type Type = Vec2

	-- 从现有的二维向量对象创建一个新的二维向量对象的元方法。
	-- @param other (Vec2) 要从中创建新对象的现有二维向量对象。
	-- @return (Vec2) 新的二维向量对象。
	-- @usage local newVec = Vec2(existingVec)
	metamethod __call: function(self: Vec2Class, other: Vec2): Vec2

	-- 使用给定的 x 和 y 组件创建一个新的二维向量对象的元方法。
	-- @param x (number) 新向量的 x 分量。
	-- @param y (number) 新向量的 y 分量。
	-- @return (Vec2) 新的二维向量对象。
	-- @usage local newVec = Vec2(10, 20)
	metamethod __call: function(
		self: Vec2Class,
		x: number,
		y: number
	): Vec2

	-- 从一个尺寸对象创建一个新的二维向量对象的元方法。
	-- @param size (Size) 要从中创建新向量的尺寸对象。
	-- @return (Vec2) 新的二维向量对象。
	-- @usage local newVec = Vec2Class(Size(10, 20))
	metamethod __call: function(self: Vec2Class, size: Size): Vec2

	-- 获取属性为0的二维向量对象。
	const zero: Vec2
end

local vec2Class: Vec2Class
return vec2Class

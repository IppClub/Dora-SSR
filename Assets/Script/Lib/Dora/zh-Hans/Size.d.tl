local type Size = require("SizeType")
local type Vec2 = require("Vec2Type")

-- 用于创建尺寸对象的类。
local record SizeClass
	type Type = Size

	-- 使用给定的宽度和高度创建一个新的尺寸对象。
	-- @param width (number) [可选] 新尺寸的宽度（默认为0）。
	-- @param height (number) [可选] 新尺寸的高度（默认为0）。
	-- @return (Size) 新的尺寸对象。
	-- @usage local size = Size(10, 20)
	metamethod __call: function(
		self: SizeClass,
		width?: number --[[0]],
		height?: number --[[0]]
	): Size

	-- 从现有的尺寸对象创建一个新的尺寸对象。
	-- @param other (Size) 要从中创建新对象的现有尺寸对象。
	-- @return (Size) 新的尺寸对象。
	-- @usage local newSize = Size(existingSize)
	metamethod __call: function(self: SizeClass, other: Size): Size

	-- 从二维向量对象创建一个新的尺寸对象。
	-- @param vec (Vec2) 要从中创建新尺寸的向量，由二维向量对象表示。
	-- @return (Size) 新的尺寸对象。
	-- @usage local size = Size(Vec2(10, 20))
	metamethod __call: function(self: SizeClass, vec: Vec2): Size

	-- 获得一个属性都为0的尺寸对象。
	const zero: Size
end

local sizeClass: SizeClass
return sizeClass

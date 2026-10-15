local ContainerItem = require("ContainerItemType")

-- 具有给定宽度和高度的尺寸对象类。
local record Size

	-- 继承自`Object`。
	embed ContainerItem

	-- 尺寸对象的宽度。
	width: number

	-- 尺寸对象的高度。
	height: number

	-- 设置尺寸对象的宽度和高度。
	-- @param width (number) 尺寸对象的新宽度。
	-- @param height (number) 尺寸对象的新高度。
	set: function(self: Size, width: number, height: number)

	-- 检查两个尺寸对象是否相等。
	-- @param other (Size) 要比较的另一个尺寸对象。
	-- @return (boolean) 两个尺寸对象是否相等。
	equals: function(self: Size, other: Size): boolean

	-- 将尺寸对象乘以向量。
	-- @param vec (Vec2) 要乘以的向量，用一个Vec2对象表示。
	-- @return (Size) 将尺寸对象乘以向量的结果。
	mul: function(self: Size, vec: Dora.Vec2.Type): Size

	-- 检查两个尺寸对象是否相等。
	-- @param other (Size) 要比较的另一个尺寸对象。
	-- @return (boolean) 两个尺寸对象是否相等。
	-- @usage sizeA == sizeB or sizeC ~= sizeD
	metamethod __eq: function(self: Size, other: Size): boolean

	-- 将尺寸对象乘以向量。
	-- @param vec (Vec2) 要乘以的向量，用一个Vec2对象表示。
	-- @return (Size) 将尺寸对象乘以向量的结果。
	-- @usage local halfSize = size * Vec2(0.5, 0.5)
	metamethod __mul: function(self: Size, vec: Dora.Vec2.Type): Size
end

return Size

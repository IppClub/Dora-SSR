local ContainerItem = require("ContainerItemType")

-- 表示具有 x 轴和 y 轴坐标的二维向量类。
local record Vec2

	-- 继承自`ContainerItem`。
	embed ContainerItem

	-- 向量的 x 坐标。
	const x: number

	-- 向量的 y 坐标。
	const y: number

	-- 向量的长度。
	const length: number

	-- 向量的长度平方值。
	const lengthSquared: number

	-- 向量和 x 轴之间的角度。
	const angle: number

	-- 计算两个向量之间的距离。
	-- @param vec (Vec2) 另一个要计算距离的向量。
	-- @return (number) 两个向量之间的距离。
	distance: function(self: Vec2, vec: Vec2): number

	-- 计算两个向量之间的平方距离。
	-- @param vec (Vec2) 另一个要计算平方距离的向量。
	-- @return (number) 两个向量之间的距离平方值。
	distanceSquared: function(self: Vec2, vec: Vec2): number

	-- 将向量做归一化。
	-- @return (Vec2) 归一化的向量。
	normalize: function(self: Vec2): Vec2

	-- 获取此向量的垂直向量。
	-- @return (Vec2) 垂直向量。
	perp: function(self: Vec2): Vec2

	-- 将向量限定在两个其他向量之间的范围内。
	-- @param from (Vec2) 表示范围下限的向量对象。
	-- @param to (Vec2) 表示范围上限的向量对象。
	-- @return (Vec2) 限定在范围内的向量。
	clamp: function(self: Vec2, from: Vec2, to: Vec2): Vec2

	-- 获取两个向量的点积。
	-- @param other (Vec2) 要计算点积的另一个向量。
	-- @return (number) 两个向量的点积。
	dot: function(self: Vec2, other: Vec2): number

	-- 将两个向量相加的元方法。
	-- @param other (Vec2) 要相加的另一个向量。
	-- @return (Vec2) 两个向量之和。
	add: function(self: Vec2, other: Vec2): Vec2

	-- 从一个向量中减去另一个向量的元方法。
	-- @param other (Vec2) 要减去的向量。
	-- @return (Vec2) 两个向量之间的差。
	sub: function(self: Vec2, other: Vec2): Vec2

	-- 逐分量相乘两个向量的元方法。
	-- @param other (Vec2) 要相乘的另一个向量。
	-- @return (Vec2) 逐分量相乘两个向量的结果。
	mul: function(self: Vec2, other: Vec2): Vec2

	-- 将向量乘以标量的元方法。
	-- @param other (number) 要乘以的标量，用数字表示。
	mul: function(self: Vec2, other: number): Vec2

	-- 将向量乘以尺寸对象的元方法。
	-- @param other (Size) 要乘以的尺寸对象。
	-- @return (Vec2) 将向量乘以尺寸对象的结果。
	-- @usage local halfVec = vec * Size(0.5, 0.5)
	mul: function(self: Vec2, other: Dora.Size.Type): Vec2

	-- 将向量除以标量的元方法。
	-- @param other (number) 要除以的标量。
	-- @return (Vec2) 将向量除以标量的结果。
	div: function(self: Vec2, other: number): Vec2

	-- 比较两个向量是否相等的元方法。
	-- @param other (Vec2) 要进行比较的另一个向量。
	-- @return (boolean) 两个向量是否相等。
	equals: function(self: Vec2, other: Vec2): boolean

	-- 将两个向量相加的元方法。
	-- @param other (Vec2) 要相加的另一个向量。
	-- @return (Vec2) 两个向量之和。
	metamethod __add: function(self: Vec2, other: Vec2): Vec2

	-- 从一个向量中减去另一个向量的元方法。
	-- @param other (Vec2) 要减去的向量。
	-- @return (Vec2) 两个向量之间的差。
	metamethod __sub: function(self: Vec2, other: Vec2): Vec2

	-- 逐分量相乘两个向量的元方法。
	-- @param other (Vec2) 要相乘的另一个向量。
	-- @return (Vec2) 逐分量相乘两个向量的结果。
	metamethod __mul: function(self: Vec2, other: Vec2): Vec2

	-- 将向量乘以标量的元方法。
	-- @param other (number) 要乘以的标量，用数字表示。
	metamethod __mul: function(self: Vec2, other: number): Vec2

	-- 将向量乘以尺寸对象的元方法。
	-- @param other (Size) 要乘以的尺寸对象。
	-- @return (Vec2) 将向量乘以尺寸对象的结果。
	-- @usage local halfVec = vec * Size(0.5, 0.5)
	metamethod __mul: function(self: Vec2, other: Dora.Size.Type): Vec2

	-- 将向量除以标量的元方法。
	-- @param other (number) 要除以的标量。
	-- @return (Vec2) 将向量除以标量的结果。
	metamethod __div: function(self: Vec2, other: number): Vec2

	-- 比较两个向量是否相等的元方法。
	-- @param other (Vec2) 要进行比较的另一个向量。
	-- @return (boolean) 两个向量是否相等。
	metamethod __eq: function(self: Vec2, other: Vec2): boolean
end

return Vec2

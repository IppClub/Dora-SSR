local type Vec3 = require("Vec3Type")

-- 用于创建 Vec3 对象的类。
local record Vec3Class
	type Type = Vec3

	-- 使用给定的 x、y 和 z 分量创建一个新的 3D 向量对象。
	-- @param x (number) 新向量的 x 分量。
	-- @param y (number) 新向量的 y 分量。
	-- @param z (number) 新向量的 z 分量。
	-- @return (Vec3) 新的 Vec3 对象。
	-- @usage local newVec = Vec3(10, 20, 30)
	metamethod __call: function(
		self: Vec3Class,
		x: number,
		y: number,
		z: number
	): Vec3
end

local vec3Class: Vec3Class
return vec3Class

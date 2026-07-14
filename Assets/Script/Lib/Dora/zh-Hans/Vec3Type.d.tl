local ContainerItem = require("ContainerItemType")

-- 表示具有 x、y 和 z 分量的 3D 向量记录。
local record Vec3

	-- 继承自 `ContainerItem`。
	embed ContainerItem

	-- 向量的 x 分量。
	x: number

	-- 向量的 y 分量。
	y: number

	-- 向量的 z 分量。
	z: number
end

return Vec3

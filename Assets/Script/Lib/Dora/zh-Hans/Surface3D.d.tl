local Node3D = require("Node3D").Type
local Node = require("Node").Type
local Size = require("Size").Type

-- 在 View3D 场景中显示 2D Node 子树。
-- 引擎会自动选择可共享 3D 深度缓冲的直接渲染，或独立的渲染目标。
local record Surface3D
	embed Node3D
	-- Surface3D 使用的 Billboard 模式。
	enum Billboard
		"None"
		"Screen"
		"YAxis"
	end
	content: Node
	-- 3D 世界中的物理宽高。
	size: Size
	-- 当子树需要独立渲染目标时使用的光栅尺寸。
	pixelSize: Size
	-- Billboard 模式，默认为 `Billboard.None`。
	billboard: Billboard
	-- 当前帧是否选择了独立渲染目标路径。
	const usingTexture: boolean
end

local record Surface3DClass
	type Type = Surface3D
	metamethod __call: function(self: Surface3DClass, content: Node, size: Size, pixelSize?: Size --[[Size.zero]]): Surface3D | nil
end

local surface3DClass: Surface3DClass
return surface3DClass

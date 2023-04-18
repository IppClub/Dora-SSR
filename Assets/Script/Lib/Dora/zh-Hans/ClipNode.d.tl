local Node = require("Node").Type

-- 用于给渲染场景设置裁剪蒙版的场景节点类。
local record ClipNode

	-- 继承自`Node`。
	embed Node

	-- 定义裁剪形状的蒙版节点。
	stencil: Node

	-- 生效的用于裁剪的蒙版像素的alpha阈值。取值范围为0到1。
	alphaThreshold: number

	-- 是否翻转裁剪区域。
	inverted: boolean
end

-- 用于创建裁剪节点对象的类。
local record ClipNodeClass
	type Type = ClipNode

	-- 创建一个新的裁剪节点对象。
	-- @param stencil (Node) 定义裁剪形状的蒙版节点。默认值为nil。
	-- @return (ClipNode) 新的裁剪节点对象。
	metamethod __call: function(
		self: ClipNodeClass,
		stencil?: Node --[[nil]]
	): ClipNode
end

local clipNodeClass: ClipNodeClass
return clipNodeClass

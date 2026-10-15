local Node = require("Node").Type
local Sprite = require("Sprite").Type

-- 用于渲染矢量图形的节点。
local record VGNode

	-- 继承自 `Node`。
	embed Node

	-- 用于显示包含矢量图形的帧缓冲纹理的图元表面。
	-- 你可以通过调用 `vgNode.surface.texture` 来获取表面的纹理。
	const surface: Sprite

	-- 用于渲染矢量图形的函数。
	-- @param func (function) 用于渲染矢量图形的闭包函数。
	-- 你可以在这个闭包函数中执行渲染操作。
	-- @usage
	-- vgNode:render(function()
	-- 	nvg.BeginPath()
	-- 	nvg.Rect(0, 0, 100, 100)
	-- 	nvg.ClosePath()
	-- 	nvg.FillColor(Color(255, 0, 0, 255))
	-- 	nvg.Fill()
	-- end)
	render: function(self: VGNode, func: function())
end

-- 用于创建 VGNode 实例的类。
local record VGNodeClass
	type Type = VGNode

	-- 创建一个新的 VGNode 实例。
	-- @param width (number) 节点包含的帧缓冲纹理的宽度。
	-- @param height (number) 节点包含的帧缓冲纹理的高度。
	-- @param scale (number) 节点的缩放比例。默认为 1.0。
	-- @param edgeAA (integer) 边缘抗锯齿系数。默认为 1。
	metamethod __call: function(
		self: VGNodeClass,
		width: number,
		height: number,
		scale?: number --[[1.0]],
		edgeAA?: integer --[[1]]
	): VGNode
end

local vgNodeClass: VGNodeClass
return vgNodeClass

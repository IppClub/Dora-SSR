local Node = require("Node").Type
local Sprite = require("Sprite").Type

-- A node for rendering vector graphics.
local record VGNode

	-- Inherits from `Node`.
	embed Node

	-- The surface of the node for displaying frame buffer texture that contains vector graphics.
	-- You can get the texture of the surface by calling `vgNode.surface.texture`.
	const surface: Sprite

	-- The function for rendering vector graphics.
	-- @param func (function) The closure function for rendering vector graphics.
	-- You can do the rendering operations inside this closure.
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

-- The class for creating VGNode instances.
local record VGNodeClass
	type Type = VGNode

	-- The constructor function for creating a VGNode instance.
	-- @param width (number) The width of the node's frame buffer texture.
	-- @param height (number) The height of the node's frame buffer texture.
	-- @param scale (number) The scale of the node. Default is 1.0.
	-- @param edgeAA (integer) The edge anti-aliasing factor. Default is 1.
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

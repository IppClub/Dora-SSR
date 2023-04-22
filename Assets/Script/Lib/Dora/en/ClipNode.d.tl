local Node = require("Node").Type

-- A Node that can clip its children based on the alpha values of its stencil.
local record ClipNode

	-- Inherit from the `Node`.
	embed Node

	-- The stencil Node that defines the clipping shape.
	stencil: Node

	-- The minimum alpha threshold for a pixel to be visible. Value ranges from 0 to 1.
	alphaThreshold: number

	-- Whether to invert the clipping area.
	inverted: boolean
end

-- A class for creating ClipNode objects.
local record ClipNodeClass
	type Type = ClipNode

	-- Creates a new ClipNode object.
	-- @param stencil (Node) The stencil Node that defines the clipping shape. Defaults to nil.
	-- @return (ClipNode) A new ClipNode object.
	metamethod __call: function(
		self: ClipNodeClass,
		stencil?: Node --[[nil]]
	): ClipNode
end

local clipNodeClass: ClipNodeClass
return clipNodeClass

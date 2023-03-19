local Node = require("Node").Type
local record ClipNode
	embed Node
	stencil: Node
	alphaThreshold: number
	inverted: boolean
end
local record ClipNodeClass
	type Type = ClipNode
	metamethod __call: function(
		self: ClipNodeClass,
		stencil?: Node --[[nil]]
	): ClipNode
end
local clipNodeClass: ClipNodeClass
return clipNodeClass

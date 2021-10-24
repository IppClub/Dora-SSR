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
		cls: ClipNodeClass,
		stencil?: Node --[[nil]]
	): ClipNode
end
print(ClipNode.stencil)
local clipNodeClass: ClipNodeClass
return clipNodeClass

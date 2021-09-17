local Node = require("Node").Type
local record Visual
	embed Node
	const playing: boolean
	start: function(self: Visual)
	stop: function(self: Visual)
	autoRemove: function(self: Visual): Visual
end
local record VisualClass
	type Type = Visual
	metamethod __call: function(cls: VisualClass, name: string): Visual
end
local visualClass: VisualClass
return visualClass

local Vec2 = require("Vec2").Type
local Node = require("Node").Type
local record Param
	enum HAlignMode
		"Left"
		"Center"
		"Right"
	end
	enum VAlignMode
		"Bottom"
		"Center"
		"Top"
	end
	isRoot: boolean
	inUI: boolean
	hAlign: HAlignMode
	vAlign: VAlignMode
	alignOffset: Vec2
	alignWidth: string
	alignHeight: string
end
local record AlignNode
	embed Node
	alignLayout: function(self: AlignNode)
end
local record AlignNodeClass
	type Type = AlignNode
	metamethod __call: function(self: AlignNodeClass, param?: Param): AlignNode
end
local alignNodeClass: AlignNodeClass
return alignNodeClass

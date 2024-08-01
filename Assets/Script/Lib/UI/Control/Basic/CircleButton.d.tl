local Node = require("Node").Type
local record Param
	text: string -- required
	x: number
	y: number
	radius: number -- required
	fontName: string
	fontSize: number
end
local record CircleButton
	embed Node
	text: string
end
local record CircleButtonClass
	type Type = CircleButton
	metamethod __call: function(self: CircleButtonClass, param: Param): CircleButton
end
local circleButtonClass: CircleButtonClass
return circleButtonClass

local Node = require("Node").Type
local record Param
	text: string -- required
	x: number
	y: number
	width: number -- required
	height: number -- required
	fontName: string
	fontSize: number
end
local record Button
	embed Node
	text: string
end
local record ButtonClass
	type Type = Button
	metamethod __call: function(self: ButtonClass, param: Param): Button
end
local buttonClass: ButtonClass
return buttonClass

local Node = require("Node").Type
local record Param
	text: string
	x: number
	y: number
	width: number
	height: number
	fontName: string
	fontSize: number
end
local record Button
	embed Node
	text: string
end
local record ButtonClass
	type Type = Button
	metamethod __call: function(cls: ButtonClass, param: Param): Button
end
local buttonClass: ButtonClass
return buttonClass

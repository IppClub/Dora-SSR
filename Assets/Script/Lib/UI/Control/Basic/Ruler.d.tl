local Node = require("Node").Type
local record Param
	x: number
	y: number
	width: number -- required
	height: number -- required
	fontName: string
	fontSize: number
	fixed: boolean
end
local record Ruler
	embed Node
	value: number
	show: function(self: Ruler, defaultValue: number, min: number, max: number, indent: number, callback: function(value: number))
	hide: function(self: Ruler)
end
local record RulerClass
	type Type = Ruler
	metamethod __call: function(self: RulerClass, param: Param): Ruler
end
local rulerClass: RulerClass
return rulerClass

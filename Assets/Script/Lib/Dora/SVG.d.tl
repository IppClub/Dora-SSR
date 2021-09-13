local Object = require("Object").Type
local record SVG
	embed Object
	const width: number
	const height: number
	render: function(self: SVG)
end
local record SVGClass
	type Type = SVG
	metamethod __call: function(cls: SVGClass, filename: string): SVG
end
local svgClass: SVGClass
return svgClass

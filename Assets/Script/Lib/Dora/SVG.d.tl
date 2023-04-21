local Object = require("Object").Type

-- A record used for Scalable Vector Graphics rendering.
local record SVG

	-- Inherits from `Object`.
	embed Object

	-- The width of the SVG object.
	const width: number

	-- The height of the SVG object.
	const height: number

	-- Renders the SVG object, should be called every frame for the render result to appear.
	render: function(self: SVG)
end

-- A class for creating SVG objects.
local record SVGClass
	type Type = SVG

	-- Creates a new SVG object from the specified SVG file.
	-- @param filename (string) The path to the SVG format file.
	-- @return (SVG) The created SVG object.
	metamethod __call: function(self: SVGClass, filename: string): SVG
end

local svgClass: SVGClass
return svgClass

local Object = require("Object").Type

-- 用于渲染可缩放矢量图形的类。
local record SVG

	-- 继承自`Object`。
	embed Object

	-- SVG对象的宽度。
	const width: number

	-- SVG对象的高度。
	const height: number

	-- 渲染SVG对象，需要在每一帧调用以持续显示渲染结果。
	render: function(self: SVG)
end

-- 用于创建SVG对象的类。
local record SVGClass
	type Type = SVG

	-- 从指定的SVG文件创建一个新的SVG对象。
	-- @param filename (string) SVG格式文件的路径。
	-- @return (SVG) 创建的SVG对象。
	metamethod __call: function(self: SVGClass, filename: string): SVG
end

local svgClass: SVGClass
return svgClass

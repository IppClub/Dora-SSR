local Size = require("Size").Type
local Node = require("Node").Type
local Menu = require("Menu").Type
local record Param
	x: number
	y: number
	width: number
	height: number
	viewWidth: number
	viewHeight: number
	paddingX: number
	paddingY: number
	visible: boolean
	scrollBar: boolean
	scrollBarColor3: number
	clipping: boolean
end
local record ScrollArea
	embed Node
	enum AlignMode
		"Auto"
		"Vertical"
		"Horizontal"
	end
	const area: Node
	const view: Menu
	scrollToPosY: function(self: ScrollArea, posY: number, time?: number --[[0.3]])
	adjustSizeWithAlign: function(self: ScrollArea, alignMode?: AlignMode, padding?: number--[[10]], size?: Size, viewSize?: Size)
end
local record ScrollAreaClass
	type Type = ScrollArea
	metamethod __call: function(self: ScrollAreaClass, param: Param): ScrollArea
end
local scrollAreaClass: ScrollAreaClass
return scrollAreaClass

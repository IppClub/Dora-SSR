local Size = require("Size").Type
local Node = require("Node").Type
local record Param
	x: number
	y: number
	width: number
	height: number
	viewWidth: number
	viewHeight: number
	visible: boolean
	scrollBar: boolean
	scrollBarColor3: boolean
	clipping: boolean
end
local record ScrollArea
	embed Node
	enum AlignMode
		"Auto"
		"Vertical"
		"Horizontal"
	end
	scrollToPosY: function(posY: number, time?: number --[[0.3]])
	adjustSizeWithAlign: function(alignMode?: AlignMode, padding?: number--[[10]], size?: Size, viewSize?: Size)
end
local record ScrollAreaClass
	type Type = ScrollArea
	metamethod __call: function(self: ScrollAreaClass, param: Param): ScrollArea
end
local scrollAreaClass: ScrollAreaClass
return scrollAreaClass

local Node = require("Node").Type

-- AlignNode is a layout node that aligns its children.
local record AlignNode

	-- Inherits from `Node`.
	embed Node

	-- Sets the layout style of the node.
	-- @param style (string) The layout style.
	-- The following properties can be set through a CSS style string:
	-- ## Layout direction and alignment
	-- * direction: Sets the direction (ltr, rtl, inherit).
	-- * align-items, align-self, align-content: Sets the alignment of different items (flex-start, center, stretch, flex-end, auto).
	-- * flex-direction: Sets the layout direction (column, row, column-reverse, row-reverse).
	-- * justify-content: Sets the arrangement of child items (flex-start, center, flex-end, space-between, space-around, space-evenly).
	-- ## Flex properties
	-- * flex: Sets the overall size of the flex container.
	-- * flex-grow: Sets the flex growth value.
	-- * flex-shrink: Sets the flex shrink value.
	-- * flex-wrap: Sets whether to wrap (nowrap, wrap, wrap-reverse).
	-- * flex-basis: Sets the flex basis value or percentage.
	-- ## Margins and dimensions
	-- * margin: Can be set by a single value or multiple values separated by commas, percentages or auto for each side.
	-- * margin-top, margin-right, margin-bottom, margin-left, margin-inline-start, margin-inline-end, margin-inline: Sets the margin values, percentages or auto.
	-- * padding: Can be set by a single value or multiple values separated by commas or percentages for each side.
	-- * padding-top, padding-right, padding-bottom, padding-left: Sets the padding values or percentages.
	-- * border: Can be set by a single value or multiple values separated by commas for each side.
	-- * width, height, min-width, min-height, max-width, max-height: Sets the dimension values or percentage properties.
	-- ## Positioning
	-- * top, right, bottom, left, start, end, horizontal, vertical: Sets the positioning property values or percentages.
	-- ## Other properties
	-- * position: Sets the positioning type (absolute, relative, static).
	-- * overflow: Sets the overflow property (visible, hidden, scroll).
	-- * display: Controls whether to display (flex, none, contents).
	-- * box-sizing: Sets the box sizing type (border-box, content-box).
	-- @usage
	-- alignNode:css("flex-direction: column; justify-content: center; align-items: center;")
	css: function(self: AlignNode, style: string)

	-- Registers a callback function for when the layout is updated.
	-- @param callback (function) The callback function for when the layout is updated.
	-- 	@param width (number) The width of the node after the update.
	-- 	@param height (number) The height of the node after the update.
	onAlignLayout: function(self: AlignNode, callback: function(width: number, height: number))
end

-- A class for creating AlignNode objects.
local record AlignNodeClass
	type Type = AlignNode

	-- Creates a new AlignNode.
	-- @param isWindowRoot (boolean) [optional] Whether the node is a window root node. A window root node will automatically listen for window size change events and update the layout accordingly.
	-- @return (AlignNode) The created AlignNode object.
	metamethod __call: function(self: AlignNodeClass, isWindowRoot?: boolean): AlignNode
end

-- This is just a demonstration record showing some signal slot events that are used. And they are meant to be used for layout updates of the AlignNode.
-- @usage
-- -- you can register for these events using codes
-- alignNode:addTo(parentNode)
-- alignNode:slot("AlignLayout", function(width: number, height: number)
-- 	print("The layout of the AlignNode is updated", width, height)
-- end)
local record __SLOT__

	-- Triggers when the layout of the `AlignNode` is updated.
	-- @param width (number) The width of the node.
	-- @param height (number) The height of the node.
	["AlignLayout"]: function(width: number, height: number)
end

local alignNodeClass: AlignNodeClass
return alignNodeClass

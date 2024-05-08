local Node = require("Node").Type

-- AlignNode is a layout node that aligns its children.
local record AlignNode

	-- Inherits from `Node`.
	embed Node

	-- Sets the layout style of the node.
	-- @param style (string) The layout style.
	-- The following properties can be set through a CSS style string:
	--
	-- ## Layout direction and alignment
	-- * direction: Sets the direction (ltr, rtl, inherit).
	-- * align-items, align-self, align-content: Sets the alignment of different items (flex-start, center, stretch, flex-end, auto).
	-- * flex-direction: Sets the layout direction (column, row, column-reverse, row-reverse).
	-- * justify-content: Sets the arrangement of child items (flex-start, center, flex-end, space-between, space-around, space-evenly).
	--
	-- ## Flex properties
	-- * flex: Sets the overall size of the flex container.
	-- * flex-grow: Sets the flex growth value.
	-- * flex-shrink: Sets the flex shrink value.
	-- * flex-wrap: Sets whether to wrap (nowrap, wrap, wrap-reverse).
	-- * flex-basis: Sets the flex basis value or percentage.
	--
	-- ## Margins and dimensions
	-- * margin: Can be set by a single value or multiple values separated by commas, percentages or auto for each side.
	-- * margin-top, margin-right, margin-bottom, margin-left, margin-start, margin-end: Sets the margin values, percentages or auto.
	-- * padding: Can be set by a single value or multiple values separated by commas or percentages for each side.
	-- * padding-top, padding-right, padding-bottom, padding-left: Sets the padding values or percentages.
	-- * border: Can be set by a single value or multiple values separated by commas for each side.
	-- * width, height, min-width, min-height, max-width, max-height: Sets the dimension values or percentage properties.
	--
	-- ## Positioning
	-- * top, right, bottom, left, start, end, horizontal, vertical: Sets the positioning property values or percentages.
	--
	-- ## Other properties
	-- * position: Sets the positioning type (absolute, relative, static).
	-- * overflow: Sets the overflow property (visible, hidden, scroll).
	-- * display: Controls whether to display (flex, none).
	--
	-- @usage
	-- alignNode:css("flex-direction: column; justify-content: center; align-items: center;")
	css: function(self: AlignNode, style: string)
end

-- A class for creating AlignNode objects.
local record AlignNodeClass
	type Type = AlignNode

	-- Creates a new AlignNode.
	-- @param isWindowRoot (boolean) [optional] Whether the node is a window root node. A window root node will automatically listen for window size change events and update the layout accordingly.
	-- @return (AlignNode) The created AlignNode object.
	metamethod __call: function(self: AlignNodeClass, isWindowRoot?: boolean): AlignNode
end

local alignNodeClass: AlignNodeClass
return alignNodeClass

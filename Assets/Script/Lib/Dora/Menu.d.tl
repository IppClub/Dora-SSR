local Node = require("Node").Type

-- This record is used for managing touch events for children nodes in a given area.
-- Menu will swallow touches that is hitting children nodes.
-- Only one child node can receive the first touch event, multi-touches comes later for other children node will be ignored.
local record Menu

	-- Inherits from `Node`.
	embed Node

	-- Whether the menu is currently enabled or disabled.
	enabled: boolean
end

-- A class for creating Menu objects.
local record MenuClass
	type Type = Menu

	-- Creates a new instance of `Menu` with the specified width and height.
	---@param width (number) The width of Menu node.
	---@param height (number) The height of Menu node.
	---@return (Menu) A new Menu node object.
	metamethod __call: function(self: MenuClass, width: number, height: number): Menu

	-- Creates a new instance of `Menu` with 0 width and 0 height.
	-- A menu with zero size will handle full screen touches for children nodes.
	-- @return (Menu) A new Menu node object.
	metamethod __call: function(self: MenuClass): Menu
end

local menu: MenuClass
return menu

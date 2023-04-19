local Node = require("Node").Type

-- 用于管理一个矩形区域内子节点的触摸事件的场景节点类。
-- 会中断子节点触摸事件的向上传播。
-- 只有第一个触摸事件可以被一个子节点接收到，后来触发的多点触摸事件将被忽略。
local record Menu

	-- 继承自`Node`。
	embed Node

	-- 菜单当前是否启用或禁用。
	enabled: boolean
end

-- 用于创建菜单节点对象的类。
local record MenuClass
	type Type = Menu

	-- 使用指定的宽度和高度创建菜单节点的新实例。
	---@param width (number) 菜单节点宽度。
	---@param height (number) 菜单节点高度。
	---@return (Menu) 新的菜单节点对象。
	metamethod __call: function(self: MenuClass, width: number, height: number): Menu

	-- 使用 0 宽度和 0 高度创建菜单节点的新实例。
	-- 大小为零的菜单将处理全屏范围内子节点的触摸事件。
	-- @return (Menu) 新的菜单节点对象。
	metamethod __call: function(self: MenuClass): Menu
end

local menu: MenuClass
return menu

local Node = require("Node").Type

-- 用于对齐子节点的布局节点。
local record AlignNode

	-- 继承自“Node”。
	embed Node

	-- 设置节点的布局样式。
	-- @param style (string) 节点的布局样式。
	-- 可通过 CSS 样式字符串设置以下属性：
	-- ## 布局方向和对齐
	-- * direction：设置方向（ltr、rtl、inherit）。
	-- * align-items、align-self、align-content：设置不同项目对齐方式（flex-start、center、stretch、flex-end、auto）。
	-- * flex-direction：设定布局方向（column、row、column-reverse、row-reverse）。
	-- * justify-content：设定子项排列方式（flex-start、center、flex-end、space-between、space-around、space-evenly）。
	-- ## Flex 属性
	-- * flex：设定弹性容器的整体大小。
	-- * flex-grow：设定弹性增长值。
	-- * flex-shrink：设定弹性收缩值。
	-- * flex-wrap：设定是否换行（nowrap、wrap、wrap-reverse）。
	-- * flex-basis：设定弹性基础数值或百分比。
	-- ## 边缘和尺寸
	-- * margin：可以通过单一值或逗号分隔的多个数值、百分比或是auto来设定各个边。
	-- * margin-top、margin-right、margin-bottom、margin-left、margin-inline-start、margin-inline-end、margin-inline：设定各个边的数值、百分比或为auto。
	-- * padding：可以通过单一值或逗号分隔的多个数值或是百分比来设定各个边。
	-- * padding-top、padding-right、padding-bottom、padding-left：设定各个边的数值或百分比。
	-- * border：可以通过单一值或逗号分隔的多个数值来设定各个边。
	-- * width、height、min-width、min-height、max-width、max-height：设定尺寸数值或百分比属性。
	-- ## 定位
	-- * top、right、bottom、left、start、end、horizontal、vertical：设定定位属性数值或是百分比。
	-- ## 其他属性
	-- * position：设定定位类型（absolute、relative、static）。
	-- * overflow：设定溢出属性（visible、hidden、scroll）。
	-- * display：控制是否显示（flex、none、contents）。
	-- * box-sizing：设定盒模型类型（border-box、content-box）。
	-- @usage
	-- alignNode:css("flex-direction: column; justify-content: center; align-items: center;")
	css: function(self: AlignNode, style: string)

	-- 注册一个布局更新时的回调函数。
	-- @param callback (function) 布局更新时的回调函数。
	-- 	@param width (number) 节点更新后的宽度。
	-- 	@param height (number) 节点更新后的高度。
	onAlignLayout: function(self: AlignNode, callback: function(width: number, height: number))
end

-- 用于创建 AlignNode 对象的类。
local record AlignNodeClass
	type Type = AlignNode

	-- 创建一个新的 AlignNode 对象。
	-- @param isWindowRoot (boolean) [可选] 是否为窗口根节点。窗口根节点会自动监听窗口大小变化事件自动更新布局。
	-- @return (AlignNode) 新创建的 AlignNode 对象。
	metamethod __call: function(self: AlignNodeClass, isWindowRoot?: boolean): AlignNode
end

-- 用于对齐节点的布局更新时触发的信号槽定义。
-- @usage
-- -- 可以使用以下形式的代码来注册监听这些事件：
-- alignNode:addTo(parentNode)
-- alignNode:slot("AlignLayout", function(width: number, height: number)
-- 	print("对齐节点的布局已更新", width, height)
-- end)
local record __SLOT__

	-- 当`AlignNode`节点的布局更新时触发。
	-- @param width (number) 节点的宽度。
	-- @param height (number) 节点的高度。
	["AlignLayout"]: function(width: number, height: number)
end

local alignNodeClass: AlignNodeClass
return alignNodeClass

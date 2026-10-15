# 编写 UI 模块

&emsp;&emsp;在这篇教程中，我们将介绍如何使用Dora SSR游戏引擎创建游戏的UI模块。我们将使用两种方式创建UI：一种是使用基于游戏场景节点编写的UI功能组件，一种是使用ImGui框架的接口。然而，需要注意的是，ImGui在实际开发中并不推荐直接用于创建游戏UI，而是建议主要用于开发一些游戏辅助的调试UI。

&emsp;&emsp;首先，我们需要引入所需的模块和库：

```tl title="Script/UI.tl"
local Platformer <const> = require("Platformer")
local ImGui <const> = require("ImGui")
local Vec2 <const> = require("Vec2")
local Director <const> = require("Director")
local AlignNode <const> = require("UI.Control.Basic.AlignNode")
local CircleButton <const> = require("UI.Control.Basic.CircleButton")
local App <const> = require("App")
local Group <const> = require("Group")
local Menu <const> = require("Menu")
local AlignNode <const> = require("AlignNode")
local Keyboard <const> = require("Keyboard")
local Loader <const> = require("Script.Loader")
local Sprite <const> = require("Sprite")
local Spawn <const> = require("Spawn")
local Opacity <const> = require("Opacity")
local Y <const> = require("Y")
local type Entity = require("Entity")
local type UnitType = Platformer.Unit.Type
```

&emsp;&emsp;接下来，我们定义了一个函数`updatePlayerControl`，用于更新玩家的控制状态。这个函数接收一个键名和一个布尔值，表示是否按下了这个键。如果按下了这个键，那么玩家的这个键的状态就会被设置为`true`，否则就会被设置为`false`。

```tl title="Script/UI.tl"
local keyboardEnabled = true

local playerGroup = Group{"player"}
local function updatePlayerControl(key: string, flag: boolean, vpad: boolean)
	-- 如果按下屏幕虚拟按键就不再检测键盘按键
	if keyboardEnabled and vpad then
		keyboardEnabled = false
	end
	-- 把按键状态数据分发到玩家数据实体上等待处理
	playerGroup:each(function(self: Entity.Type): boolean
		self[key] = flag
	end)
end
```

&emsp;&emsp;然后，我们创建了一个UI的根节点`ui`，并将其添加到[Director.ui](/docs/api/Class/Director#ui)中。这个节点是所有其他UI节点的父节点。

```tl title="Script/UI.tl"
-- 创建一个使用 Flex 布局的布局根节点
local ui = AlignNode(true)
ui:css('flex-direction: column-reverse')
ui:addTo(Director.ui)

-- 创建虚拟按键区域的布局节点
local bottomAlign = AlignNode()
bottomAlign:css([[
	height: 80;
	justify-content: space-between;
	padding: 0, 20, 20;
	flex-direction: row
]]);
bottomAlign:addTo(ui)
```

&emsp;&emsp;接着，我们创建了一个左对齐的节点`leftAlign`，并将其添加到`bottomAlign`中。然后，我们在`leftAlign`中创建了一个菜单`leftMenu`，用于放置屏幕左边的操作按钮。然后同样创建一个右对齐的菜单用于放置屏幕右边的操作按钮。

```tl title="Script/UI.tl"
-- 创建左对齐的菜单
local leftAlign = AlignNode()
leftAlign:css('width: 130; height: 60')
leftAlign:addTo(bottomAlign)

local leftMenu = Menu()
leftMenu.size = Size(250, 120)
leftMenu.anchor = Vec2.zero
leftMenu.scaleX = 0.5
leftMenu.scaleY = 0.5
leftMenu:addTo(leftAlign)

-- 创建右对齐的菜单
local rightAlign = AlignNode()
rightAlign:css('width: 60; height: 60')
rightAlign:addTo(bottomAlign)

local rightMenu = Menu()
rightMenu.size = Size(120, 120)
rightMenu.anchor = Vec2.zero
rightMenu.scaleX = 0.5
rightMenu.scaleY = 0.5
rightMenu:addTo(rightAlign)
```

&emsp;&emsp;在`leftMenu`中，我们创建了三个圆形按钮：`leftButton`、`rightButton`和`jumpButton`。这三个按钮分别用于控制玩家的左移、右移和跳跃操作。每个按钮都有一个[TapBegan](/docs/api/Node%20Event/Node#tapbegan)事件和一个[TapEnded](/docs/api/Node%20Event/Node#tapended)事件，分别在按钮被按下和按钮被释放时触发。

```tl title="Script/UI.tl"
-- 创建左移按钮
local leftButton = CircleButton {
	text = "左(a)",
	radius = 60,
	fontSize = 36
}
leftButton.anchor = Vec2.zero
leftButton:slot("TapBegan", function()
	updatePlayerControl("keyLeft", true, true)
end)
leftButton:slot("TapEnded", function()
	updatePlayerControl("keyLeft", false, true)
end)
leftButton:addTo(leftMenu)

-- 创建右移按钮
local rightButton = CircleButton {
	text = "右(d)",
	x = 130,
	radius = 60,
	fontSize = 36
}
rightButton.anchor = Vec2.zero
rightButton:slot("TapBegan", function()
	updatePlayerControl("keyRight", true, true)
end)
rightButton:slot("TapEnded", function()
	updatePlayerControl("keyRight", false, true)
end)
rightButton:addTo(leftMenu)

-- 创建跳跃按钮
local jumpButton = CircleButton {
	text = "跳(j)",
	radius = 60,
	fontSize = 36
}
jumpButton.anchor = Vec2.zero
jumpButton:slot("TapBegan", function()
	updatePlayerControl("keyJump", true, true)
end)
jumpButton:slot("TapEnded", function()
	updatePlayerControl("keyJump", false, true)
end)
jumpButton:addTo(rightMenu)
```

&emsp;&emsp;接下来，我们使用ImGui创建了一个背包窗口。在这个窗口中，我们可以看到玩家的背包中的所有物品，以及每个物品的数量和描述。当玩家点击一个物品时，这个物品的数量就会减少1，同时在玩家的角色上生成一个对应的精灵。

```tl title="Script/UI.tl"
local pickedItemGroup = Group{"picked"}
local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
local themeColor = App.themeColor
Director.ui:schedule(function(): boolean
	local size = App.visualSize
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(size.width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(100, 300), "FirstUseEver")
	ImGui.Begin("BackPack", windowFlags, function()
		if ImGui.Button("重新加载Excel") then
			Loader.loadExcel()
		end
		ImGui.Separator()
		ImGui.Dummy(Vec2(100, 10))
		ImGui.Text("背包")
		ImGui.Separator()
		ImGui.Columns(3, false)

		-- 遍历有被标记拾取状态picked组件的道具实体
		pickedItemGroup:each(function(e: Entity.Type): boolean
			local item = e as Loader.ItemEntity
			if item.num > 0 then
				-- 当按下道具按钮时进行处理
				if ImGui.ImageButton("item" .. tostring(item.no), item.icon, Vec2(50, 50)) then
					item.num = item.num - 1
					local sprite = Sprite(item.icon)
					if not sprite is nil then
						sprite.scaleX = 0.5
						sprite.scaleY = 0.5
						sprite:perform(Spawn(
							Opacity(1, 1, 0),
							Y(1, 150, 250)
						))
						local player = playerGroup:find(function(): boolean return true end)
						local unit = player.unit as UnitType
						unit:addChild(sprite)
					end
				end

				-- 当指针在道具按钮上悬浮时进行处理
				if ImGui.IsItemHovered() then
					ImGui.BeginTooltip(function()
						ImGui.Text(item.name)
						ImGui.TextColored(themeColor, "数量：")
						ImGui.SameLine()
						ImGui.Text(tostring(item.num))
						ImGui.TextColored(themeColor, "描述：")
						ImGui.SameLine()
						ImGui.Text(tostring(item.desc))
					end)
				end
				ImGui.NextColumn()
			end
		end)
	end)
	return false
end)
```

&emsp;&emsp;以上就是我们的UI模块的全部内容，UI功能的程序开发往往会比较繁杂，但其实都是一些重复性比较高但不困难的代码。的在这个模块中，我们创建了一个基于游戏场景节点的UI，用于控制玩家的移动和跳跃操作，以及一个基于ImGui的UI，用于显示玩家的背包内容。到这里我们的教程已经接近尾声了，加油，通过下一篇教程我们就能把完整的游戏跑起来啦。
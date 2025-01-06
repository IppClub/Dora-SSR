# 编写 Excel 配置文件加载模块

&emsp;&emsp;欢迎来到Dora SSR游戏引擎横版2D游戏开发教程的第八篇！在这篇教程中，我们将介绍如何加载Excel格式的配置文件。这个模块主要做一件事：加载Excel表格为Lua的table，然后经过处理后创建在ECS系统中对应的游戏道具实体对象，并交给之前的教程提到的ECS系统进行逻辑处理。

&emsp;&emsp;首先，我们需要引入一些必要的模块：

```tl title="Script/Loader.tl"
local Content <const> = require("Content")
local Group <const> = require("Group")
local Entity <const> = require("Entity")
local Utils <const> = require("Utils")
local Struct <const> = Utils.Struct
```

&emsp;&emsp;接下来，我们将加载名为"Data/items.xlsx"的Excel文件，这个文件包含一个名为"items"的表格。这个表格的内容如下：

| 结构名称 | 序号 | 道具名称 | 道具X坐标 | 道具数量 | 道具图标                   | 道具描述 |
| -------- | ---- | -------- | --------- | -------- | -------------------------- | -------- |
| Struct   | No   | Name     | X         | Num      | Icon                       | Desc     |
| Item     | 1    | 道具1    | 0         | 1        | Model/patreon.clip\|whale  | 描述1    |
| Item     | 2    | 道具2    | 300       | 2        | Model/patreon.clip\|cow    | 描述2    |
| Item     | 3    | 道具3    | 600       | 3        | Model/patreon.clip\|sloth  | 描述3    |
| Item     | 4    | 道具4    | 900       | 4        | Model/patreon.clip\|panda  | 描述4    |
| Item     | 5    | 道具5    | -300      | 5        | Model/patreon.clip\|rabbit | 描述5    |

&emsp;&emsp;在使用Teal语言的时候，我们可以先定义一个当加载Excel数据后要转换为的Lua对象的结构。

```tl title="Script/Loader.tl"
local record ItemEntity
	name: string
	no: number
	x: number
	icon: string
	num: number
	desc: string
	item: boolean
end
```

&emsp;&emsp;然后我们就可以开始编写Excel文件加载的处理函数，执行加载主要是使用[Content:loadExcel()](/docs/api/Class/Content#loadexcel)函数。

```tl title="Script/Loader.tl"
function loadExcel()
	local xlsx = Content:loadExcel("Data/items.xlsx", {"items"})
	if not xlsx is nil then
		local its = xlsx["items"]
		-- 从第二行数据获取到程序访问的字段名称数组
		local names = its[2] as {string}
		-- 从字段名称数组中删除不包含字段名称的第一列数据
		table.remove(names, 1)
		-- 创建名称为Item的Struct数据对象定义
		if not Struct:has("Item") then
			Struct.Item(names)
		end
		-- 从ECS系统中删除所有包含item组件的实体
		Group{"item"}:each(function(e: Entity.Type): boolean
			e:destroy()
		end)
		-- 从第三行开始遍历Excel数据
		for i = 3, #its do
			local st = Struct:load(its[i])
			local item <total>: ItemEntity = {
				name = st.Name as string,
				no = st.No as number,
				x = st.X as number,
				num = st.Num as number,
				icon = st.Icon as string,
				desc = st.Desc as string,
				item = true
			}
			Entity(item)
		end
	end
end
```

&emsp;&emsp;最后我们定义一个Loader对象作为模块返回的结果，供其它模块访问调用。

```tl title="Script/Loader.tl"
local record Loader
	type ItemEntity = ItemEntity
	loadExcel: function()
end
Loader.loadExcel = loadExcel
return Loader
```

&emsp;&emsp;在上述代码中，我们首先加载了Excel文件，并获得了直接包含文件数据的Lua的table对象。然后，我们从table中获取了表头，并将其用于创建一个名为"Item"的Struct数据对象的定义。接着，我们遍历了ECS系统中所有现有的带有"item"组件的道具实体，并将它们销毁。最后，我们遍历了Excel表格中的每一行数据，将每一行的数据转换为一个Struct对象，并用这个对象访问各种数据字段创建的新的游戏道具实体，并触发后续在ECS系统中执行的游戏实体的处理逻辑。

&emsp;&emsp;至此，我们的Excel配置文件加载模块就编写完成了。在接下来的教程中，我们将使用这些加载的数据来创建游戏角色和实现游戏逻辑。希望你能跟上我们的步伐，一起学习Dora SSR游戏引擎的使用方法！
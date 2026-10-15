local Body = require("Body").Type
local Playable = require("Playable").Type
local Sensor = require("Sensor").Type
local Dictionary = require("Dictionary").Type
local Entity = require("Entity").Type
local Size = require("Size").Type
local type UnitAction = require("Platformer.UnitActionType")

-- 代表游戏场景中游戏角色或其它游戏交互物件的节点类。
local record Unit

	-- 继承自`Body`.
	embed Body

	-- 管理的动画模型播放状态的对象。
	playable: Playable

	-- 游戏单位可以检测其它单位或物理体的最大距离。
	detectDistance: number

	-- 游戏单位攻击范围的大小。
	attackRange: Size

	-- 游戏单位是否面向右侧。
	faceRight: boolean

	-- 是否接收决策树的执行信息用于调试。
	receivingDecisionTrace: boolean

	-- 游戏单位使用的AI决策树的名称。
	-- AI决策树名称将用于在`Data.store`单例中获取AI节点对象。
	decisionTree: string

	-- 是否“站”在地面或物理体表面上。
	const onSurface: boolean

	-- 用于检测地面或物理体表面的感应器对象。
	const groundSensor: Sensor

	-- 用于检测游戏世界中其它游戏单位或物理体的感应器对象。
	const detectSensor: Sensor

	-- 用于在攻击区域内检测其它游戏单位或物理体的感应器对象。
	const attackSensor: Sensor

	-- 定义游戏单位的属性和行为的字典对象。
	const unitDef: Dictionary

	-- 游戏单位正在执行的当前动作。
	const currentAction: UnitAction

	-- 游戏单位的宽度。
	const width: number

	-- 游戏单位的高度。
	const height: number

	-- 游戏单位所关联的ECS实体对象。
	const entity: Entity

	-- 给游戏单位添加一个新的单位动作，并返回新创建的单位动作对象。
	-- @param name (string) 新的单位动作的名称。
	-- @return (UnitAction) 新创建的单位动作对象。
	attachAction: function(self: Unit, name: string): UnitAction

	-- 从游戏单位上删除一个单位动作。
	-- @param name (string) 要删除的单位动作的名称。
	removeAction: function(self: Unit, name: string)

	-- 删除所有的游戏单位动作。
	removeAllActions: function(self: Unit)

	-- 查找游戏单位上特定名称的动作，如果不存在，则返回nil。
	-- @param name (string) 要查找的游戏单位动作名称。
	-- @return (UnitAction或nil) 指定名称的游戏单位动作，或nil。
	getAction: function(self: Unit, name: string): UnitAction

	-- 遍历游戏单位上的所有动作对象，并调用处理函数。
	-- @param func (function) 对每个游戏单位动作调用的函数。
	eachAction: function(self: Unit, func: function(UnitAction))

	-- 执行指定名称的游戏单位动作。
	-- @param name (string) 要启动的游戏单位动作的名称。
	-- @return (boolean) 如果成功启动游戏单位动作，则返回true，否则返回false。
	start: function(self: Unit, name: string): boolean

	-- 停止当前正在执行的游戏单位动作。
	stop: function(self: Unit)

	-- 如果游戏单位当前在执行指定的动作，则返回true，否则返回false。
	-- @param name (string) 要检查的游戏单位动作。
	-- @return (boolean) 如果游戏单位当前在执行指定的动作，则返回true，否则返回false。
	isDoing: function(self: Unit, name: string): boolean
end

return Unit

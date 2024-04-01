local Dictionary = require("Dictionary").Type
local Entity = require("Entity").Type
local PhysicsWorld = require("PhysicsWorld").Type
local Vec2 = require("Vec2").Type
local type UnitAction = require("Platformer.UnitActionType")
local type Unit = require("Platformer.UnitType")

-- 用于创建游戏单位实例的类。
local record UnitClass
	type Type = Unit

	-- 在每个游戏单位上附加的地面感应器的标签。
	const GroundSensorTag: integer

	-- 在每个游戏单位上附加的探测感应器的标签。
	const DetectSensorTag: integer

	-- 在每个游戏单位上附加的攻击感应器的标签。
	const AttackSensorTag: integer

	-- 用于创建新的游戏单位对象的元方法。
	-- @param unitDef (Dictionary) 定义游戏单位属性和行为的字典对象。
	-- @param physicsWorld (PhysicsWorld) 游戏单位所属的物理世界的对象。
	-- @param entity (Entity) 游戏单位所关联ECS系统的实体对象。
	-- @param pos (Vec2) 所创建游戏单位的初始位置。
	-- @param rot (number) [可选] 一个可选数字，游戏单位的初始旋转角度（默认为0.0）。
	-- @return (Unit) 新创建的游戏单位对象。
	metamethod __call: function(
		self: UnitClass,
		unitDef: Dictionary,
		physicsWorld: PhysicsWorld,
		entity: Entity,
		pos: Vec2,
		rot?: number --[[0.0]]
	): Unit

	-- 用于创建新的游戏单位对象的元方法。
	-- @param unitDefName (string) 定义游戏单位属性和行为的名称，用于从 Data.store 字典中获取。
	-- @param physicsWorldName (string) 游戏单位所属的物理世界的对象的名称，用于从 Data.store 字典中获取。
	-- @param entity (Entity) 游戏单位所关联ECS系统的实体对象。
	-- @param pos (Vec2) 所创建游戏单位的初始位置。
	-- @param rot (number) [可选] 游戏单位的初始旋转角度（默认为0.0）。
	-- @return (Unit) 新创建的游戏单位对象。
	metamethod __call: function(
		self: UnitClass,
		unitDefName: string,
		physicsWorldName: string,
		entity: Entity,
		pos: Vec2,
		rot?: number --[[0.0]]
	): Unit
end

local _: UnitAction
print(Unit:getAction(nil))
print(Unit:attachAction(nil))
print(Unit.currentAction)

local unitClass: UnitClass
return unitClass

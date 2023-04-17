local Dictionary = require("Dictionary").Type
local Entity = require("Entity").Type
local PhysicsWorld = require("PhysicsWorld").Type
local Vec2 = require("Vec2").Type
local type UnitAction = require("Platformer.UnitActionType")
local type Unit = require("Platformer.UnitType")

-- A class for creating instances of Unit.
local record UnitClass
	type Type = Unit

	-- The tag for the "GroundSensor" attached to each "Unit".
	const GroundSensorTag: integer

	-- The tag for the "DetectSensor" attached to each "Unit".
	const DetectSensorTag: integer

	-- The tag for the "AttackSensor" attached to each "Unit".
	const AttackSensorTag: integer

	-- A metamethod that creates a new "Unit" object.
	-- @param unitDef (Dictionary) A "Dictionary" object that defines the properties and behavior of the "Unit".
	-- @param physicsworld (PhysicsWorld) A "PhysicsWorld" object that represents the physics simulation world.
	-- @param entity (Entity) An "Entity" object that represents the "Unit" in ECS system.
	-- @param pos (Vec2) A "Vec2" object that specifies the initial position of the "Unit".
	-- @param rot (number) [optional] An optional number that specifies the initial rotation of the "Unit" (default is 0.0).
	-- @return (Unit) The newly created "Unit" object.
	metamethod __call: function(
		self: UnitClass,
		unitDef: Dictionary,
		physicsworld: PhysicsWorld,
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

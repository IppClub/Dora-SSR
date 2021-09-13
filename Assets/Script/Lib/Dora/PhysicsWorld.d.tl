local PhysicsWorldBase = require("PhysicsWorldBase")
local Rect = require("Rect").Type
local Vec2 = require("Vec2").Type
local Body = require("Body").Type
local record PhysicsWorld
	embed PhysicsWorldBase
	showDebug: boolean
	query: function(self: PhysicsWorld, rect: Rect, handler: function(Body): boolean): boolean
	raycast: function(self: PhysicsWorld, start: Vec2, stop: Vec2, closest: boolean, handler: function(Body): boolean): boolean
	setIterations: function(self: PhysicsWorld, velocityIter: integer, positionIter: integer)
	setShouldContact: function(self: PhysicsWorld, groupA: integer, groupB: integer, contact: boolean)
	getShouldContact: function(self: PhysicsWorld, groupA: integer, groupB: integer): boolean
end
local record PhysicsWorldClass
	type Type = PhysicsWorld
	b2Factor: number
	metamethod __call: function(cls: PhysicsWorldClass): PhysicsWorld
end
local physicsWorldClass: PhysicsWorldClass
return physicsWorldClass

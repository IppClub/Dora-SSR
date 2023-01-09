local Node = require("Node").Type
local Rect = require("Rect").Type
local Vec2 = require("Vec2").Type
local type Body = require("BodyType")
local record PhysicsWorld
	embed Node
	showDebug: boolean
	query: function(self: PhysicsWorld, rect: Rect, handler: function(Body): boolean): boolean
	raycast: function(self: PhysicsWorld, start: Vec2, stop: Vec2, closest: boolean, handler: function(Body, point: Vec2, normal: Vec2): boolean): boolean
	setIterations: function(self: PhysicsWorld, velocityIter: integer, positionIter: integer)
	setShouldContact: function(self: PhysicsWorld, groupA: integer, groupB: integer, contact: boolean)
	getShouldContact: function(self: PhysicsWorld, groupA: integer, groupB: integer): boolean
end
return PhysicsWorld

local Node = require("Node").Type
local Rect = require("Rect").Type
local Vec2 = require("Vec2").Type
local type Body = require("BodyType")

-- A record that represents a physics world in the game.
local record PhysicsWorld

	-- Inherits from `Node`.
	embed Node

	-- Queries the physics world for all bodies that intersect with the specified rectangle.
	-- @param rect (Rect) The rectangle to query for bodies.
	-- @param handler (function) A function that is called for each body found in the query.
	-- 	@param body (Body) The body found in the query.
	-- 	@return (boolean) Whether to continue querying for more bodies, false to continue, true to stop.
	-- @return (boolean) Whether the query was interrupted, true means interrupted, false otherwise.
	query: function(self: PhysicsWorld, rect: Rect, handler: function(Body): boolean): boolean

	-- Casts a ray through the physics world and finds the first body that intersects with the ray.
	-- @param start (Vec2) The starting point of the ray.
	-- @param stop (Vec2) The ending point of the ray.
	-- @param closest (boolean) Whether to stop ray casting upon the closest body that intersects with the ray.
	-- Set closest to true to get a faster ray casting search.
	-- @param handler (function) A function that is called for each body found in the raycast.
	-- 	@param body (Body) The body found in the raycast.
	-- 	@param point (Vec2) The point where the ray intersects with the body.
	-- 	@param normal (Vec2) The normal vector at the point of intersection.
	-- 	@return (boolean) Whether to continue casting the ray for more bodies, returns true to stop, false otherwise.
	-- @return (boolean) Whether the raycast was interrupted, true means interrupted, false otherwise.
	raycast: function(self: PhysicsWorld, start: Vec2, stop: Vec2, closest: boolean, handler: function(Body, point: Vec2, normal: Vec2): boolean): boolean

	-- Sets the number of velocity and position iterations to perform in the physics world.
	-- @param velocityIter (integer) The number of velocity iterations to perform.
	-- @param positionIter (integer) The number of position iterations to perform.
	setIterations: function(self: PhysicsWorld, velocityIter: integer, positionIter: integer)

	-- Sets whether two physics groups should make contact with each other or not.
	-- @param groupA (integer) The first physics group.
	-- @param groupB (integer) The second physics group.
	-- @param contact (boolean) Whether the two groups should make contact with each other.
	setShouldContact: function(self: PhysicsWorld, groupA: integer, groupB: integer, contact: boolean)

	-- Gets whether two physics groups should make contact with each other or not.
	-- @param groupA (integer) The first physics group.
	-- @param groupB (integer) The second physics group.
	-- @return (boolean) Whether the two groups should make contact with each other.
	getShouldContact: function(self: PhysicsWorld, groupA: integer, groupB: integer): boolean
end

return PhysicsWorld

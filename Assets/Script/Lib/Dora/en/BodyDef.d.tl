local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local FixtureDef = require("FixtureDef").Type

-- A record to describe the properties of a physics body.
local record BodyDef

	-- Inherits from `Object`.
	embed Object

	-- An enumeration for the different types of bodies.
	enum BodyType

		-- A body that does not move.
		"Static"

		-- A body that can move and be affected by forces.
		"Dynamic"

		-- A body that can move but is not affected by forces.
		"Kinematic"
	end

	-- Define for the type of the body.
	type: BodyType

	-- Define for the position of the body.
	position: Vec2

	-- Define for the angle of the body.
	angle: number

	-- Define for the face image or other items accepted by creating `Face` for the body.
	face: string

	-- Define for the face position of the body.
	facePos: Vec2

	-- Define for linear damping of the body.
	linearDamping: number

	-- Define for angular damping of the body.
	angularDamping: number

	-- Define for initial linear acceleration of the body.
	linearAcceleration: Vec2

	-- Whether the body's rotation is fixed or not.
	fixedRotation: boolean

	-- Whether the body is a bullet or not.
	-- Set to true to add extra bullet movement check for the body.
	bullet: boolean

	-- Attaches a polygon fixture definition to the body.
	-- @param center (Vec2) The center point of the polygon.
	-- @param width (number) The width of the polygon.
	-- @param height (number) The height of the polygon.
	-- @param angle (number) [optional] The angle of the polygon (default is 0.0).
	-- @param density (number) [optional] The density of the polygon (default is 0.0).
	-- @param friction (number) [optional] The friction of the polygon (default is 0.4, should be 0 to 1.0).
	-- @param restitution (number) [optional] The restitution of the polygon (default is 0.0, should be 0 to 1.0).
	attachPolygon: function(self: BodyDef,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]],
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- Attaches a polygon fixture definition to the body.
	-- @param width (number) The width of the polygon.
	-- @param height (number) The height of the polygon.
	-- @param density (number) [optional] The density of the polygon (default is 0.0).
	-- @param friction (number) [optional] The friction of the polygon (default is 0.4, should be 0 to 1.0).
	-- @param restitution (number) [optional] The restitution of the polygon (default is 0.0, should be 0 to 1.0).
	attachPolygon: function(self: BodyDef,
		width: number,
		height: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- Attaches a polygon fixture definition to the body.
	-- @param vertices ({Vec2}) The vertices of the polygon.
	-- @param density (number) [optional] The density of the polygon (default is 0.0).
	-- @param friction (number) [optional] The friction of the polygon (default is 0.4, should be 0 to 1.0).
	-- @param restitution (number) [optional] The restitution of the polygon (default is 0.0, should be 0 to 1.0).
	attachPolygon: function(self: BodyDef,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- Attaches a concave shape definition made of multiple convex shapes to the body.
	-- @param vertices ({Vec2}) A table containing the vertices of each convex shape that makes up the concave shape.
	-- Each convex shape in the vertices table should ends with a Vec2(0.0, 0.0) as seperator.
	-- @param density (number) [optional] The density of the concave shape (default is 0.0).
	-- @param friction (number) [optional] The friction of the concave shape (default is 0.4, should be 0 to 1.0).
	-- @param restitution (number) [optional] The restitution of the concave shape (default is 0.0, should be 0 to 1.0).
	attachMulti: function(self: BodyDef,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- Attaches a disk fixture definition to the body.
	-- @param center (Vec2) The center point of the disk.
	-- @param radius (number) The radius of the disk.
	-- @param density (number) [optional] The density of the disk (default is 0.0).
	-- @param friction (number) [optional] The friction of the disk (default is 0.4, should be 0 to 1.0).
	-- @param restitution (number) [optional] The restitution of the disk (default is 0.0, should be 0 to 1.0).
	attachDisk: function(self: BodyDef,
		center: Vec2,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- Attaches a disk fixture to the body.
	-- @param radius (number) The radius of the disk.
	-- @param density (number) [optional] The density of the disk (default is 0.0).
	-- @param friction (number) [optional] The friction of the disk (default is 0.4).
	-- @param restitution (number) [optional] The restitution of the disk (default is 0.0).
	attachDisk: function(self: BodyDef,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- Attaches a chain fixture definition to the body. The Chain fixture is a free form sequence of line segments that has two-sided collision.
	-- @param vertices ({Vec2}) The vertices of the chain.
	-- @param friction (number) [optional] The friction of the chain (default is 0.4).
	-- @param restitution (number) [optional] The restitution of the chain (default is 0.0).
	attachChain: function(self: BodyDef,
		vertices: {Vec2},
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- Attaches a polygon sensor fixture definition to the body.
	-- @param tag (number) An integer tag for the sensor.
	-- @param width (number) The width of the polygon.
	-- @param height (number) The height of the polygon.
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		width: number,
		height: number)

	-- Attaches a polygon sensor fixture definition to the body.
	-- @param tag (number) An integer tag for the sensor.
	-- @param center (Vec2) The center point of the polygon.
	-- @param width (number) The width of the polygon.
	-- @param height (number) The height of the polygon.
	-- @param angle (number) [optional] The angle of the polygon (default is 0.0).
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]])

	-- Attaches a polygon sensor fixture definition to the body.
	-- @param tag (number) An integer tag for the sensor.
	-- @param vertices ({Vec2}) A table containing the vertices of the polygon.
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		vertices: {Vec2})

	-- Attaches a disk sensor fixture definition to the body.
	-- @param tag (number) An integer tag for the sensor.
	-- @param center (Vec2) The center of the disk.
	-- @param radius (number) The radius of the disk.
	attachDiskSensor: function(self: BodyDef,
		tag: integer,
		center: Vec2,
		radius: number)

	-- Attaches a disk sensor fixture to the body.
	-- @param tag (number) An integer tag for the sensor.
	-- @param radius (number) The radius of the disk.
	attachDiskSensor: function(self: BodyDef,
		tag: integer,
		radius: number)
end

-- A class for creating BodyDef and FixtureDef.
local record BodyDefClass
	type Type = BodyDef

	-- Creates a polygon fixture definition with the specified dimensions.
	-- @param width (number) The width of the polygon.
	-- @param height (number) The height of the polygon.
	-- @param density (number) [optional] The density of the polygon (default is 0.0).
	-- @param friction (number) [optional] The friction of the polygon (default is 0.4, should be 0.0 to 1.0).
	-- @param restitution (number) [optional] The restitution of the polygon (default is 0.0, should be  0.0 to 1.0).
	-- @return (FixtureDef) A FixtureDef object for the created polygon fixture.
	polygon: function(self: BodyDefClass,
		width: number,
		height: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- Creates a polygon fixture definition with the specified dimensions and center position.
	-- @param center (Vec2) The center position of the polygon.
	-- @param width (number) The width of the polygon.
	-- @param height (number) The height of the polygon.
	-- @param angle (number) [optional] The angle of the polygon in radians (default is 0.0).
	-- @param density (number) [optional] The density of the polygon (default is 0.0).
	-- @param friction (number) [optional] The friction of the polygon (default is 0.4, should be 0.0 to 1.0).
	-- @param restitution (number) [optional] The restitution of the polygon (default is 0.0, should be 0.0 to 1.0).
	-- @return (FixtureDef) A FixtureDef object for the created polygon fixture.
	polygon: function(self: BodyDefClass,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]],
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- Creates a polygon fixture definition with the specified vertices.
	-- @param vertices ({Vec2}) A table containing the vertices of the polygon.
	-- @param density (number) [optional] The density of the polygon (default is 0.0).
	-- @param friction (number) [optional] The friction of the polygon (default is 0.4, should be 0.0 to 1.0).
	-- @param restitution (number) [optional] The restitution of the polygon (default is 0.0, should be 0.0 to 1.0).
	-- @return (FixtureDef) A FixtureDef object for the created polygon fixture.
	polygon: function(self: BodyDefClass,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- Create a concave shape definition made of multiple convex shapes.
	-- @param vertices ({Vec2}) A table containing the vertices of each convex shape that makes up the concave shape.
	-- Each convex shape in the vertices table should ends with a Vec2(0.0, 0.0) as seperator.
	-- @param density (number) The density of the shape (optional, default 0.0).
	-- @param friction (number) The friction coefficient of the shape (optional, default 0.4, should be 0.0 to 1.0).
	-- @param restitution (number) The restitution (elasticity) of the shape (optional, default 0.0, should be 0.0 to 1.0).
	-- @return (FixtureDef) The resulting fixture definition.
	multi: function(self: BodyDefClass,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- Create a Disk-shape fixture definition.
	-- @param center (Vec2) The center of the circle.
	-- @param radius (number) The radius of the circle.
	-- @param density (number) The density of the circle (optional, default 0.0).
	-- @param friction (number) The friction coefficient of the circle (optional, default 0.4, should be 0.0 to 1.0).
	-- @param restitution (number) The restitution (elasticity) of the circle (optional, default 0.0, should be 0.0 to 1.0).
	-- @return (FixtureDef) The resulting fixture definition.
	disk: function(self: BodyDefClass,
		center: Vec2,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- Create a Disk-shape fixture definition with center at origin.
	-- @param radius (number) The radius of the circle.
	-- @param density (number) The density of the circle (optional, default 0.0).
	-- @param friction (number) The friction coefficient of the circle (optional, default 0.4, should be 0.0 to 1.0).
	-- @param restitution (number) The restitution (elasticity) of the circle (optional, default 0.0, should be 0.0 to 1.0).
	-- @return (FixtureDef) The resulting fixture definition.
	disk: function(self: BodyDefClass,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- Create a Chain-shape fixture definition. This fixture is a free form sequence of line segments that has two-sided collision.
	-- @param vertices ({Vec2}) The vertices of the chain.
	-- @param friction (number) The friction coefficient of the chain (optional, default 0.4, should be 0.0 to 1.0).
	-- @param restitution (number) The restitution (elasticity) of the chain (optional, default 0.0, should be 0.0 to 1.0).
	-- @return (FixtureDef) The resulting fixture definition.
	chain: function(self: BodyDefClass,
		vertices: {Vec2},
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- Create a new instance of BodyDef class.
	-- @return (BodyDef) a new BodyDef object.
	metamethod __call: function(self: BodyDefClass): BodyDef
end

local bodyDefClass: BodyDefClass
return bodyDefClass

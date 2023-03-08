local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local FixtureDef = require("FixtureDef").Type
local record BodyDef
	embed Object
	enum BodyType
		"Static"
		"Dynamic"
		"Kinematic"
	end
	type: BodyType
	position: Vec2
	angle: number
	face: string
	facePos: Vec2
	linearDamping: number
	angularDamping: number
	linearAcceleration: Vec2
	fixedRotation: boolean
	bullet: boolean
	polygon: function(cls: BodyDef,
		width: number,
		height: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef
	attachPolygon: function(self: BodyDef,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]],
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])
	attachPolygon: function(self: BodyDef,
		width: number,
		height: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])
	attachPolygon: function(self: BodyDef,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])
	attachMulti: function(self: BodyDef,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])
	attachDisk: function(self: BodyDef,
		center: Vec2,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])
	attachDisk: function(self: BodyDef,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])
	attachChain: function(self: BodyDef,
		vertices: {Vec2},
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		width: number,
		height: number)
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]])
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		vertices: {Vec2})
	attachDiskSensor: function(self: BodyDef,
		tag: integer,
		center: Vec2,
		radius: number)
	attachDiskSensor: function(self: BodyDef,
		tag: integer,
		radius: number)
end
local record BodyDefClass
	type Type = BodyDef
	polygon: function(cls: BodyDefClass,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]],
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef
	polygon: function(cls: BodyDefClass,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef
	multi: function(cls: BodyDefClass,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef
	disk: function(cls: BodyDefClass,
		center: Vec2,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef
	disk: function(cls: BodyDefClass,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef
	chain: function(cls: BodyDefClass,
		vertices: {Vec2},
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef
	metamethod __call: function(cls: BodyDefClass): BodyDef
end
local bodyDefClass: BodyDefClass
return bodyDefClass

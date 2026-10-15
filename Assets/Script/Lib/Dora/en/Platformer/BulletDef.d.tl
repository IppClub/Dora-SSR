local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local Face = require("Platformer.Face").Type
local BodyDef = require("BodyDef").Type

-- A record type that specifies the properties and behaviors of a bullet object in the game.
local record BulletDef

	-- Inherits from `Object`.
	embed Object

	-- The tag for the bullet object.
	tag: string

	-- The effect that occurs when the bullet object ends its life.
	endEffect: string

	-- The amount of time in seconds that the bullet object remains active.
	lifeTime: number

	-- The radius of the bullet object's damage area.
	damageRadius: number

	-- Whether the bullet object should be fixed for high speeds.
	highSpeedFix: boolean

	-- The gravity vector that applies to the bullet object.
	gravity: Vec2

	-- The visual item of the bullet object.
	face: Face

	-- The physics body definition for the bullet object.
	const bodyDef: BodyDef

	-- The velocity vector of the bullet object.
	const velocity: Vec2

	-- Sets the bullet object's physics body as a circle.
	-- @param radius (number) The radius of the circle.
	setAsCircle: function(self: BulletDef, radius: number)

	-- Sets the velocity of the bullet object.
	-- @param angle (number) The angle of the velocity in degree.
	-- @param speed (number) The speed of the velocity.
	setVelocity: function(self: BulletDef, angle: number, speed: number)
end

-- @usage
-- local BulletDef = require("BulletDef")
-- local bulletDef = BulletDef()
local record BulletDefClass
	type Type = BulletDef
	metamethod __call: function(self: BulletDefClass): BulletDef
end

local bulletDefClass: BulletDefClass
return bulletDefClass

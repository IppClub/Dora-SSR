local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local Face = require("Platformer.Face").Type
local BodyDef = require("BodyDef").Type
local record BulletDef
	embed Object
	tag: string
	endEffect: string
	lifeTime: number
	damageRadius: number
	highSpeedFix: boolean
	gravity: Vec2
	face: Face
	const bodyDef: BodyDef
	const velocity: Vec2
	setAsCircle: function(self: BulletDef, radius: number)
	setVelocity: function(self: BulletDef, angle: number, speed: number)
end
local record BulletDefClass
	type Type = BulletDef
	metamethod __call: function(cls: BulletDefClass): BulletDef
end
local bulletDefClass: BulletDefClass
return bulletDefClass

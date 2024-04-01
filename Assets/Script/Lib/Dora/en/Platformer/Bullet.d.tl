local Body = require("Body").Type
local Unit = require("Platformer.Unit").Type
local Node = require("Node").Type
local BulletDef = require("Platformer.BulletDef").Type

-- A record that defines the properties and behavior of a bullet object instance in the game.
local record Bullet

	-- Inherits from `Body`.
	embed Body

	-- The value from a `Platformer.TargetAllow` object for the bullet object.
	targetAllow: integer

	-- Whether the bullet object is facing right.
	const faceRight: boolean

	-- Whether the bullet object should stop on impact.
	hitStop: boolean

	-- The `Unit` object that fired the bullet.
	const emitter: Unit

	-- The `BulletDef` object that defines the bullet's properties and behavior.
	const bulletDef: BulletDef

	-- The `Node` object that appears as the bullet's visual item.
	face: Node

	-- Destroys the bullet object instance.
	destroy: function(self: Bullet)
end

-- A record type that creates new `Bullet` object instances.
local record BulletClass
	type Type = Bullet

	-- A metamethod that creates a new `Bullet` object instance with the specified `BulletDef` and `Unit` objects.
	-- @param def (BulletDef) The `BulletDef` object that defines the bullet's properties and behavior.
	-- @param owner (Unit) The `Unit` object that fired the bullet.
	-- @return (Bullet) The new `Bullet` object instance.
	metamethod __call: function(
		self: BulletClass,
		def: BulletDef,
		owner: Unit
	): Bullet
end

local bulletClass: BulletClass
return bulletClass

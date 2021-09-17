local Body = require("Body").Type
local Unit = require("Platformer.Unit").Type
local Node = require("Node").Type
local TargetAllow = require("Platformer.TargetAllow").Type
local BulletDef = require("Platformer.BulletDef").Type
local record Bullet
	embed Body
	targetAllow: TargetAllow
	const faceRight: boolean
	hitStop: boolean
	const owner: Unit
	const bulletDef: BulletDef
	face: Node
	destroy: function(self: Bullet)
end
local record BulletClass
	type Type = Bullet
	metamethod __call: function(
		cls: BulletClass,
		def: BulletDef,
		owner: Unit
	): Bullet
end
local bulletClass: BulletClass
return bulletClass

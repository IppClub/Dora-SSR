local Body = require("Body").Type
local Unit = require("Platformer.Unit").Type
local Node = require("Node").Type
local BulletDef = require("Platformer.BulletDef").Type

-- 包含游戏中的子弹对象的属性和行为的类。
local record Bullet

	-- 继承自`Body`。
	embed Body

	-- 子弹的允许碰撞对象的定义信息。通过`Platformer.TargetAllow`对象获取。
	targetAllow: integer

	-- 子弹对象是否面向右边。
	const faceRight: boolean

	-- 子弹对象是否在碰撞后停止运动。
	hitStop: boolean

	-- 发射子弹的单位对象。
	const emitter: Unit

	-- 定义子弹属性和行为的对象。
	const bulletDef: BulletDef

	-- 子弹上挂载的视觉元素的对象。
	face: Node

	-- 主动销毁子弹对象实例。
	destroy: function(self: Bullet)
end

-- 用于创建新`Bullet`对象实例的类。
local record BulletClass
	type Type = Bullet

	-- 使用特定的子弹定义和发射子弹的游戏单位对象，创建新的子弹对象实例的元方法。
	-- @param def (BulletDef) 子弹属性和行为的定义对象。
	-- @param owner (Unit) 发射子弹的游戏单位对象。
	-- @return (Bullet) 新的子弹对象实例。
	metamethod __call: function(
		self: BulletClass,
		def: BulletDef,
		owner: Unit
	): Bullet
end

local bulletClass: BulletClass
return bulletClass

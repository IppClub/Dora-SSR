local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local Face = require("Platformer.Face").Type
local BodyDef = require("BodyDef").Type

-- 用于定义游戏中子弹对象的属性和行为的类。
local record BulletDef

	-- 继承自`Object`。
	embed Object

	-- 子弹对象的标签。
	tag: string

	-- 当子弹对象生命周期结束时播放的特效。
	endEffect: string

	-- 子弹对象保持活动的时间（以秒为单位）。
	lifeTime: number

	-- 子弹对象伤害区域的半径。
	damageRadius: number

	-- 是否应该增加高速度子弹类型的碰撞检测处理。
	highSpeedFix: boolean

	-- 应用于子弹对象的重力向量。
	gravity: Vec2

	-- 子弹对象上挂载的可视化元素的定义。
	face: Face

	-- 子弹对象的物理体定义。
	const bodyDef: BodyDef

	-- 子弹对象的速度向量。
	const velocity: Vec2

	-- 将子弹对象的物理体设置为圆形。
	-- @param radius (number) 圆的半径。
	setAsCircle: function(self: BulletDef, radius: number)

	-- 设置子弹对象的速度。
	-- @param angle (number) 速度的角度，以度为单位。
	-- @param speed (number) 速度的大小。
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

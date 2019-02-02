Dorothy builtin.Platformer
Rectangle = require "UI.View.Shape.Rectangle"
Star = require "UI.View.Shape.Star"
{store:Store} = Data

Store["Arrow"] = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 1
	.damageRadius = 0
	.highSpeedFix = false
	.gravity = Vec2 0,-10
	.face = Face "Image/misc.clip|arrow",Vec2(-20,0),2
	\setAsCircle 10
	\setVelocity 15,1200

Store["Bubble"] = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 3.0
	.damageRadius = 0
	.highSpeedFix = false
	.gravity = Vec2 0,4
	.face = Face "Image/misc.clip|heartbullet",Vec2.zero,2
	\setAsCircle 15
	\setVelocity 0,400

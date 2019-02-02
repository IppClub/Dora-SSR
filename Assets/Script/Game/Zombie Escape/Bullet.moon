Dorothy builtin.Platformer
Rectangle = require "UI.View.Shape.Rectangle"
Star = require "UI.View.Shape.Star"
{store:Store} = Data

Store["Bullet_KidM"] = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 1
	.damageRadius = 0
	.highSpeedFix = false
	.gravity = Vec2.zero
	.face = Face -> Rectangle {
		width: 6
		height: 6
		borderColor: 0xffff0088
		fillColor: 0x66ff0088
		fillOrder: 1
		lineOrder: 2
	}
	\setAsCircle 6
	\setVelocity 0,600

Store["Bullet_KidW"] = with BulletDef!
	.tag = ""
	.endEffect = ""
	.lifeTime = 5
	.damageRadius = 0
	.highSpeedFix = false
	.gravity = Vec2 0,-10
	.face = Face -> Star {
		size: 15
		borderColor: 0xffff0088
		fillColor: 0x66ff0088
		fillOrder: 1
		lineOrder: 2
	}
	\setAsCircle 10
	\setVelocity 60,600

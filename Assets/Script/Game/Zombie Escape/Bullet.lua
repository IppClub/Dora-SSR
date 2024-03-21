-- [yue]: Script/Game/Zombie Escape/Bullet.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local BulletDef = _module_0.BulletDef -- 1
local Vec2 = dora.Vec2 -- 1
local Face = _module_0.Face -- 1
local Rectangle = require("UI.View.Shape.Rectangle") -- 2
local Star = require("UI.View.Shape.Star") -- 3
local Store = Data.store -- 5
do -- 7
	local _with_0 = BulletDef() -- 7
	_with_0.tag = "" -- 8
	_with_0.endEffect = "" -- 9
	_with_0.lifeTime = 1 -- 10
	_with_0.damageRadius = 0 -- 11
	_with_0.highSpeedFix = false -- 12
	_with_0.gravity = Vec2.zero -- 13
	_with_0.face = Face(function() -- 14
		return Rectangle({ -- 15
			width = 6, -- 15
			height = 6, -- 16
			borderColor = 0xffff0088, -- 17
			fillColor = 0x66ff0088, -- 18
			fillOrder = 1, -- 19
			lineOrder = 2 -- 20
		}) -- 21
	end) -- 14
	_with_0:setAsCircle(6) -- 22
	_with_0:setVelocity(0, 600) -- 23
	Store["Bullet_KidM"] = _with_0 -- 7
end -- 7
local _with_0 = BulletDef() -- 25
_with_0.tag = "" -- 26
_with_0.endEffect = "" -- 27
_with_0.lifeTime = 5 -- 28
_with_0.damageRadius = 0 -- 29
_with_0.highSpeedFix = false -- 30
_with_0.gravity = Vec2(0, -10) -- 31
_with_0.face = Face(function() -- 32
	return Star({ -- 33
		size = 15, -- 33
		borderColor = 0xffff0088, -- 34
		fillColor = 0x66ff0088, -- 35
		fillOrder = 1, -- 36
		lineOrder = 2 -- 37
	}) -- 38
end) -- 32
_with_0:setAsCircle(10) -- 39
_with_0:setVelocity(60, 600) -- 40
Store["Bullet_KidW"] = _with_0 -- 25

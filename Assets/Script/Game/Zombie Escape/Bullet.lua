-- [yue]: Script/Game/Zombie Escape/Bullet.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local BulletDef = _module_0.BulletDef -- 1
local Vec2 = dora.Vec2 -- 1
local Face = _module_0.Face -- 1
local Rectangle = require("UI.View.Shape.Rectangle") -- 10
local Star = require("UI.View.Shape.Star") -- 11
local Store = Data.store -- 13
do -- 15
	local _with_0 = BulletDef() -- 15
	_with_0.tag = "" -- 16
	_with_0.endEffect = "" -- 17
	_with_0.lifeTime = 1 -- 18
	_with_0.damageRadius = 0 -- 19
	_with_0.highSpeedFix = false -- 20
	_with_0.gravity = Vec2.zero -- 21
	_with_0.face = Face(function() -- 22
		return Rectangle({ -- 23
			width = 6, -- 23
			height = 6, -- 24
			borderColor = 0xffff0088, -- 25
			fillColor = 0x66ff0088, -- 26
			fillOrder = 1, -- 27
			lineOrder = 2 -- 28
		}) -- 29
	end) -- 22
	_with_0:setAsCircle(6) -- 30
	_with_0:setVelocity(0, 600) -- 31
	Store["Bullet_KidM"] = _with_0 -- 15
end -- 15
local _with_0 = BulletDef() -- 33
_with_0.tag = "" -- 34
_with_0.endEffect = "" -- 35
_with_0.lifeTime = 5 -- 36
_with_0.damageRadius = 0 -- 37
_with_0.highSpeedFix = false -- 38
_with_0.gravity = Vec2(0, -10) -- 39
_with_0.face = Face(function() -- 40
	return Star({ -- 41
		size = 15, -- 41
		borderColor = 0xffff0088, -- 42
		fillColor = 0x66ff0088, -- 43
		fillOrder = 1, -- 44
		lineOrder = 2 -- 45
	}) -- 46
end) -- 40
_with_0:setAsCircle(10) -- 47
_with_0:setVelocity(60, 600) -- 48
Store["Bullet_KidW"] = _with_0 -- 33

-- [yue]: Script/Game/Loli War/Bullet.yue
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
	_with_0.gravity = Vec2(0, -10) -- 13
	_with_0.face = Face("Model/misc.clip|arrow", Vec2(-20, 0), 2) -- 14
	_with_0:setAsCircle(10) -- 15
	_with_0:setVelocity(15, 1200) -- 16
	Store["Arrow"] = _with_0 -- 7
end -- 7
do -- 18
	local _with_0 = BulletDef() -- 18
	_with_0.tag = "" -- 19
	_with_0.endEffect = "" -- 20
	_with_0.lifeTime = 3.0 -- 21
	_with_0.damageRadius = 0 -- 22
	_with_0.highSpeedFix = false -- 23
	_with_0.gravity = Vec2(0, 4) -- 24
	_with_0.face = Face("Model/misc.clip|heartbullet", Vec2.zero, 2) -- 25
	_with_0:setAsCircle(15) -- 26
	_with_0:setVelocity(0, 400) -- 27
	Store["Bubble"] = _with_0 -- 18
end -- 18

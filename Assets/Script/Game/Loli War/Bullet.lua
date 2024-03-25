-- [yue]: Script/Game/Loli War/Bullet.yue
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
	_with_0.gravity = Vec2(0, -10) -- 21
	_with_0.face = Face("Model/misc.clip|arrow", Vec2(-20, 0), 2) -- 22
	_with_0:setAsCircle(10) -- 23
	_with_0:setVelocity(15, 1200) -- 24
	Store["Arrow"] = _with_0 -- 15
end -- 15
local _with_0 = BulletDef() -- 26
_with_0.tag = "" -- 27
_with_0.endEffect = "" -- 28
_with_0.lifeTime = 3.0 -- 29
_with_0.damageRadius = 0 -- 30
_with_0.highSpeedFix = false -- 31
_with_0.gravity = Vec2(0, 4) -- 32
_with_0.face = Face("Model/misc.clip|heartbullet", Vec2.zero, 2) -- 33
_with_0:setAsCircle(15) -- 34
_with_0:setVelocity(0, 400) -- 35
Store["Bubble"] = _with_0 -- 26

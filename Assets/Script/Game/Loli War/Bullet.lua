-- [yue]: Bullet.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local BulletDef = _module_0.BulletDef -- 1
local Vec2 = Dora.Vec2 -- 1
local Face = _module_0.Face -- 1
local Store = Data.store -- 11
do -- 13
	local _with_0 = BulletDef() -- 13
	_with_0.tag = "" -- 14
	_with_0.endEffect = "" -- 15
	_with_0.lifeTime = 1 -- 16
	_with_0.damageRadius = 0 -- 17
	_with_0.highSpeedFix = false -- 18
	_with_0.gravity = Vec2(0, -10) -- 19
	_with_0.face = Face("Model/misc.clip|arrow", Vec2(-20, 0), 2) -- 20
	_with_0:setAsCircle(10) -- 21
	_with_0:setVelocity(15, 1200) -- 22
	Store["Arrow"] = _with_0 -- 13
end -- 13
local _with_0 = BulletDef() -- 24
_with_0.tag = "" -- 25
_with_0.endEffect = "" -- 26
_with_0.lifeTime = 3.0 -- 27
_with_0.damageRadius = 0 -- 28
_with_0.highSpeedFix = false -- 29
_with_0.gravity = Vec2(0, 4) -- 30
_with_0.face = Face("Model/misc.clip|heartbullet", Vec2.zero, 2) -- 31
_with_0:setAsCircle(15) -- 32
_with_0:setVelocity(0, 400) -- 33
Store["Bubble"] = _with_0 -- 24

local Behavior = require("Platformer.Behavior")
local Decision = require("Platformer.Decision")
local Data = require("Platformer.Data")
local PlatformCamera = require("Platformer.PlatformCamera")
local PlatformWorld = require("Platformer.PlatformWorld")
local TargetAllow = require("Platformer.TargetAllow")
local UnitAction = require("Platformer.UnitAction")
local Unit = require("Platformer.Unit")
local BulletDef = require("Platformer.BulletDef")
local Bullet = require("Platformer.Bullet")
local Face = require("Platformer.Face")
local Visual = require("Platformer.Visual")

-- 包含2D平台游戏的模块。
local Platformer = {
	Behavior = Behavior,
	Decision = Decision,
	Data = Data,
	PlatformCamera = PlatformCamera,
	PlatformWorld = PlatformWorld,
	TargetAllow = TargetAllow,
	UnitAction = UnitAction,
	Unit = Unit,
	BulletDef = BulletDef,
	Bullet = Bullet,
	Face = Face,
	Visual = Visual
}

return Platformer

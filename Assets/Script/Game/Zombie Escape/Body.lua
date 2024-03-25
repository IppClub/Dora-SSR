-- [yue]: Script/Game/Zombie Escape/Body.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local BodyDef = dora.BodyDef -- 1
local Vec2 = dora.Vec2 -- 1
local Store = Data.store -- 11
do -- 13
	local _with_0 = BodyDef() -- 13
	_with_0.type = "Static" -- 14
	_with_0:attachPolygon(100, 60, 1, 1, 0) -- 15
	Store["Body_ObstacleS"] = _with_0 -- 13
end -- 13
do -- 17
	local _with_0 = BodyDef() -- 17
	_with_0.type = "Static" -- 18
	_with_0:attachPolygon(260, 60, 1, 1, 0) -- 19
	Store["Body_ObstacleM"] = _with_0 -- 17
end -- 17
local _with_0 = BodyDef() -- 21
_with_0.type = "Dynamic" -- 22
_with_0.linearAcceleration = Vec2(0, -10) -- 23
_with_0:attachDisk(40, 1, 0.6, 0.4) -- 24
Store["Body_ObstacleC"] = _with_0 -- 21

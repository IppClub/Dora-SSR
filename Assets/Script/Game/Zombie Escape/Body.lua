-- [yue]: Script/Game/Zombie Escape/Body.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local BodyDef = dora.BodyDef -- 1
local Vec2 = dora.Vec2 -- 1
local Store = Data.store -- 3
do -- 5
	local _with_0 = BodyDef() -- 5
	_with_0.type = "Static" -- 6
	_with_0:attachPolygon(100, 60, 1, 1, 0) -- 7
	Store["Body_ObstacleS"] = _with_0 -- 5
end -- 5
do -- 9
	local _with_0 = BodyDef() -- 9
	_with_0.type = "Static" -- 10
	_with_0:attachPolygon(260, 60, 1, 1, 0) -- 11
	Store["Body_ObstacleM"] = _with_0 -- 9
end -- 9
do -- 13
	local _with_0 = BodyDef() -- 13
	_with_0.type = "Dynamic" -- 14
	_with_0.linearAcceleration = Vec2(0, -10) -- 15
	_with_0:attachDisk(40, 1, 0.6, 0.4) -- 16
	Store["Body_ObstacleC"] = _with_0 -- 13
end -- 13

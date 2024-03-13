-- [yue]: Script/Game/Zombie Escape/Constant.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local _with_0 = Data.store -- 3
_with_0.PlayerLayer = 2 -- 4
_with_0.ZombieLayer = 1 -- 5
_with_0.TerrainLayer = 0 -- 6
_with_0.PlayerGroup = 1 -- 8
_with_0.ZombieGroup = 2 -- 9
Data:setRelation(_with_0.PlayerGroup, _with_0.ZombieGroup, "Enemy") -- 11
_with_0.MaxZombies = 50 -- 13
_with_0.ZombieWaveDelay = 0 -- 14
return _with_0 -- 3

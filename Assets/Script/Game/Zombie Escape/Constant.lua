-- [yue]: Script/Game/Zombie Escape/Constant.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local _with_0 = Data.store -- 11
_with_0.PlayerLayer = 2 -- 12
_with_0.ZombieLayer = 1 -- 13
_with_0.TerrainLayer = 0 -- 14
_with_0.PlayerGroup = 1 -- 16
_with_0.ZombieGroup = 2 -- 17
Data:setRelation(_with_0.PlayerGroup, _with_0.ZombieGroup, "Enemy") -- 19
_with_0.MaxZombies = 50 -- 21
_with_0.ZombieWaveDelay = 0 -- 22
return _with_0 -- 11

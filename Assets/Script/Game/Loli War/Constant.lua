-- [yue]: Script/Game/Loli War/Constant.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local _with_0 = Data.store -- 3
_with_0.GroupPlayer = 1 -- 4
_with_0.GroupPlayerBlock = 2 -- 5
_with_0.GroupPlayerPoke = 3 -- 6
_with_0.GroupEnemy = 4 -- 7
_with_0.GroupEnemyBlock = 5 -- 8
_with_0.GroupEnemyPoke = 6 -- 9
_with_0.GroupDisplay = 7 -- 10
_with_0.GroupTerrain = Data.groupTerrain -- 11
_with_0.GroupHide = Data.groupHide -- 12
_with_0.LayerBackground = 0 -- 14
_with_0.LayerBlock = 1 -- 15
_with_0.LayerSwitch = 2 -- 16
_with_0.LayerBunny = 3 -- 17
_with_0.LayerEnemyHero = 4 -- 18
_with_0.LayerPlayerHero = 5 -- 19
_with_0.LayerForeground = 6 -- 20
_with_0.LayerReadMe = 7 -- 21
_with_0.MaxBunnies = 6 -- 23
_with_0.MaxEP = 8.0 -- 24
_with_0.MaxHP = 8.0 -- 25
Data:setShouldContact(_with_0.GroupPlayerBlock, _with_0.GroupPlayerBlock, true) -- 27
Data:setShouldContact(_with_0.GroupEnemyBlock, _with_0.GroupEnemyBlock, true) -- 28
Data:setShouldContact(_with_0.GroupPlayerBlock, _with_0.GroupEnemyBlock, true) -- 29
Data:setShouldContact(_with_0.GroupEnemy, _with_0.GroupPlayerBlock, true) -- 31
Data:setShouldContact(_with_0.GroupPlayer, _with_0.GroupEnemyBlock, true) -- 32
Data:setShouldContact(_with_0.GroupPlayerPoke, _with_0.GroupEnemy, true) -- 34
Data:setShouldContact(_with_0.GroupPlayerPoke, _with_0.GroupEnemyBlock, true) -- 35
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayer, true) -- 37
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayerBlock, true) -- 38
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayerPoke, true) -- 39
Data:setShouldContact(_with_0.GroupDisplay, _with_0.GroupDisplay, true) -- 41
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupPlayerBlock, "Friend") -- 43
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupPlayerPoke, "Friend") -- 44
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupEnemyBlock, "Friend") -- 45
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupEnemyPoke, "Friend") -- 46
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemy, "Enemy") -- 48
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemyBlock, "Enemy") -- 49
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemyPoke, "Enemy") -- 50
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupPlayerBlock, "Enemy") -- 51
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupPlayerPoke, "Enemy") -- 52
Data:setRelation(_with_0.GroupPlayerPoke, _with_0.GroupEnemyBlock, "Enemy") -- 54
Data:setRelation(_with_0.GroupEnemyPoke, _with_0.GroupPlayerBlock, "Enemy") -- 55
return _with_0 -- 3

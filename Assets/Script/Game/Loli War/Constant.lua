-- [yue]: Script/Game/Loli War/Constant.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local _with_0 = Data.store -- 11
_with_0.GroupPlayer = 1 -- 12
_with_0.GroupPlayerBlock = 2 -- 13
_with_0.GroupPlayerPoke = 3 -- 14
_with_0.GroupEnemy = 4 -- 15
_with_0.GroupEnemyBlock = 5 -- 16
_with_0.GroupEnemyPoke = 6 -- 17
_with_0.GroupDisplay = 7 -- 18
_with_0.GroupTerrain = Data.groupTerrain -- 19
_with_0.GroupHide = Data.groupHide -- 20
_with_0.LayerBackground = 0 -- 22
_with_0.LayerBlock = 1 -- 23
_with_0.LayerSwitch = 2 -- 24
_with_0.LayerBunny = 3 -- 25
_with_0.LayerEnemyHero = 4 -- 26
_with_0.LayerPlayerHero = 5 -- 27
_with_0.LayerForeground = 6 -- 28
_with_0.LayerReadMe = 7 -- 29
_with_0.MaxBunnies = 6 -- 31
_with_0.MaxEP = 8.0 -- 32
_with_0.MaxHP = 8.0 -- 33
Data:setShouldContact(_with_0.GroupPlayerBlock, _with_0.GroupPlayerBlock, true) -- 35
Data:setShouldContact(_with_0.GroupEnemyBlock, _with_0.GroupEnemyBlock, true) -- 36
Data:setShouldContact(_with_0.GroupPlayerBlock, _with_0.GroupEnemyBlock, true) -- 37
Data:setShouldContact(_with_0.GroupEnemy, _with_0.GroupPlayerBlock, true) -- 39
Data:setShouldContact(_with_0.GroupPlayer, _with_0.GroupEnemyBlock, true) -- 40
Data:setShouldContact(_with_0.GroupPlayerPoke, _with_0.GroupEnemy, true) -- 42
Data:setShouldContact(_with_0.GroupPlayerPoke, _with_0.GroupEnemyBlock, true) -- 43
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayer, true) -- 45
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayerBlock, true) -- 46
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayerPoke, true) -- 47
Data:setShouldContact(_with_0.GroupDisplay, _with_0.GroupDisplay, true) -- 49
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupPlayerBlock, "Friend") -- 51
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupPlayerPoke, "Friend") -- 52
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupEnemyBlock, "Friend") -- 53
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupEnemyPoke, "Friend") -- 54
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemy, "Enemy") -- 56
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemyBlock, "Enemy") -- 57
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemyPoke, "Enemy") -- 58
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupPlayerBlock, "Enemy") -- 59
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupPlayerPoke, "Enemy") -- 60
Data:setRelation(_with_0.GroupPlayerPoke, _with_0.GroupEnemyBlock, "Enemy") -- 62
Data:setRelation(_with_0.GroupEnemyPoke, _with_0.GroupPlayerBlock, "Enemy") -- 63
return _with_0 -- 11

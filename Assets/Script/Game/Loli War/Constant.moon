_ENV = Dorothy builtin.Platformer

with Data.store
	.GroupPlayer = 1
	.GroupPlayerBlock = 2
	.GroupPlayerPoke = 3
	.GroupEnemy = 4
	.GroupEnemyBlock = 5
	.GroupEnemyPoke = 6
	.GroupDisplay = 7
	.GroupTerrain = Data.groupTerrain
	.GroupHide = Data.groupHide

	.LayerBackground = 0
	.LayerBlock = 1
	.LayerSwitch = 2
	.LayerBunny = 3
	.LayerEnemyHero = 4
	.LayerPlayerHero = 5
	.LayerForeground = 6
	.LayerReadMe = 7

	.MaxBunnies = 6
	.MaxEP = 8
	.MaxHP = 8

	Data\setShouldContact .GroupPlayerBlock, .GroupPlayerBlock, true
	Data\setShouldContact .GroupEnemyBlock, .GroupEnemyBlock, true
	Data\setShouldContact .GroupPlayerBlock, .GroupEnemyBlock, true

	Data\setShouldContact .GroupEnemy, .GroupPlayerBlock, true
	Data\setShouldContact .GroupPlayer, .GroupEnemyBlock, true

	Data\setShouldContact .GroupPlayerPoke, .GroupEnemy, true
	Data\setShouldContact .GroupPlayerPoke, .GroupEnemyBlock, true

	Data\setShouldContact .GroupEnemyPoke, .GroupPlayer, true
	Data\setShouldContact .GroupEnemyPoke, .GroupPlayerBlock, true
	Data\setShouldContact .GroupEnemyPoke, .GroupPlayerPoke, true

	Data\setShouldContact .GroupDisplay, .GroupDisplay, true

	Data\setRelation .GroupPlayer, .GroupPlayerBlock, Relation.Friend
	Data\setRelation .GroupPlayer, .GroupPlayerPoke, Relation.Friend
	Data\setRelation .GroupEnemy, .GroupEnemyBlock, Relation.Friend
	Data\setRelation .GroupEnemy, .GroupEnemyPoke, Relation.Friend

	Data\setRelation .GroupPlayer, .GroupEnemy, Relation.Enemy
	Data\setRelation .GroupPlayer, .GroupEnemyBlock, Relation.Enemy
	Data\setRelation .GroupPlayer, .GroupEnemyPoke, Relation.Enemy
	Data\setRelation .GroupEnemy, .GroupPlayerBlock, Relation.Enemy
	Data\setRelation .GroupEnemy, .GroupPlayerPoke, Relation.Enemy

	Data\setRelation .GroupPlayerPoke, .GroupEnemyBlock, Relation.Enemy
	Data\setRelation .GroupEnemyPoke, .GroupPlayerBlock, Relation.Enemy

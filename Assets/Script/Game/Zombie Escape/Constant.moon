_ENV = Dorothy builtin.Platformer

with Data.store
	.PlayerLayer = 2
	.ZombieLayer = 1
	.TerrainLayer = 0

	.PlayerGroup = 1
	.ZombieGroup = 2

	Data\setRelation .PlayerGroup,.ZombieGroup,Relation.Enemy

	.MaxZombies = 50

local Dictionary = require("Dictionary").Type
local Body = require("Body").Type

-- A singleton object that provides a centralized location for storing and accessing game-related data.
local record Data
	userdata

	-- An enum representing the possible relations between two groups.
	enum Relation
		"Enemy"
		"Friend"
		"Neutral"
		"Unknown"
		"Any"
	end

	-- A group key representing the first index for a player group.
	const groupFirstPlayer: integer

	-- A group key representing the last index for a player group.
	const groupLastPlayer: integer

	-- A group key that won't have any contact with other groups by default.
	const groupHide: integer

	-- A group key that will have contacts with player groups by default.
	const groupDetectPlayer: integer

	-- A group key representing terrain that will have contacts with other groups by default.
	const groupTerrain: integer

	-- A group key that will have contacts with other groups by default.
	const groupDetection: integer

	-- A dictionary that can be used to store arbitrary data associated with string keys and various values globally.
	const store: Dictionary

	-- A function that can be used to set a boolean value indicating whether two groups should be in contact or not.
	-- @param groupA (integer) An integer representing the first group.
	-- @param groupB (integer) An integer representing the second group.
	-- @param contact (boolean) A boolean indicating whether the two groups should be in contact.
	setShouldContact: function(self: Data, groupA: integer, groupB: integer, contact: boolean)

	-- A function that can be used to get a boolean value indicating whether two groups should be in contact or not.
	-- @param groupA (integer) An integer representing the first group.
	-- @param groupB (integer) An integer representing the second group.
	-- @return (boolean) Whether the two groups should be in contact.
	getShouldContact: function(self: Data, groupA: integer, groupB: integer): boolean

	-- A function that can be used to set the relation between two groups.
	-- @param groupA (integer) An integer representing the first group.
	-- @param groupB (integer) An integer representing the second group.
	-- @param relation (Relation) The relation between the two groups.
	setRelation: function(self: Data, groupA: integer, groupB: integer, relation: Relation)

	-- A function that can be used to get the relation between two groups.
	-- @param groupA (integer) An integer representing the first group.
	-- @param groupB (integer) An integer representing the second group.
	-- @return (Relation) The relation between the two groups.
	getRelation: function(self: Data, groupA: integer, groupB: integer): Relation

	-- A function that can be used to get the relation between two bodies.
	-- @param bodyA (Body) The first body.
	-- @param bodyB (Body) The second body.
	-- @return (Relation) The relation between the two bodies.
	getRelation: function(self: Data, bodyA: Body, bodyB: Body): Relation

	-- A function that returns whether two groups have an "Enemy" relation.
	-- @param groupA (integer) An integer representing the first group.
	-- @param groupB (integer) An integer representing the second group.
	-- @return (boolean) Whether the two groups have an "Enemy" relation.
	isEnemy: function(self: Data, groupA: integer, groupB: integer): boolean

	-- A function that returns whether two bodies have an "Enemy" relation.
	-- @param bodyA (Body) The first body.
	-- @param bodyB (Body) The second body.
	-- @return (boolean) Whether the two bodies have an "Enemy" relation.
	isEnemy: function(self: Data, bodyA: Body, bodyB: Body): boolean

	-- A function that returns whether two groups have a "Friend" relation.
	-- @param groupA (integer) An integer representing the first group.
	-- @param groupB (integer) An integer representing the second group.
	-- @return (boolean) Whether the two groups have a "Friend" relation.
	isFriend: function(self: Data, groupA: integer, groupB: integer): boolean

	-- A function that returns whether two bodies have a "Friend" relation.
	-- @param bodyA (Body) The first body.
	-- @param bodyB (Body) The second body.
	-- @return (boolean) Whether the two bodies have a "Friend" relation.
	isFriend: function(self: Data, bodyA: Body, bodyB: Body): boolean

	-- A function that returns whether two groups have a "Neutral" relation.
	-- @param groupA (integer) An integer representing the first group.
	-- @param groupB (integer) An integer representing the second group.
	-- @return (boolean) Whether the two groups have a "Neutral" relation.
	isNeutral: function(self: Data, groupA: integer, groupB: integer): boolean

	-- A function that returns whether two bodies have a "Neutral" relation.
	-- @param bodyA (Body) The first body.
	-- @param bodyB (Body) The second body.
	-- @return (boolean) Whether the two bodies have a "Neutral" relation.
	isNeutral: function(self: Data, bodyA: Body, bodyB: Body): boolean

	-- A function that sets the bonus factor for a particular type of damage against a particular type of defence. The builtin "MeleeAttack" and "RangeAttack" actions are using simple formular of `finalDamage = damage * bonus`.
	-- @param damageType (integer) An integer representing the type of damage.
	-- @param defenceType (integer) An integer representing the type of defence.
	-- @param bonus (number) A number representing the bonus.
	setDamageFactor: function(self: Data, damageType: integer, defenceType: integer, bounus: number)

	-- A function that gets the bonus factor for a particular type of damage against a particular type of defence.
	-- @param damageType (integer) An integer representing the type of damage.
	-- @param defenceType (integer) An integer representing the type of defence.
	-- @return (number) A number representing the bonus factor.
	getDamageFactor: function(self: Data, damageType: integer, defenceType: integer): number

	-- A function that returns whether a body is a player or not.
	-- This works the same as `Data.groupFirstPlayer <= body.group and body.group <= Data.groupLastPlayer`.
	-- @param body (Body) The body to check.
	-- @return (boolean) Whether the body is a player.
	isPlayer: function(self: Data, body: Body): boolean

	-- A function that returns whether a body is terrain or not.
	-- This works the same as `body.group == Data.groupTerrain`.
	-- @param body (Body) The body to check.
	-- @return (boolean) Whether the body is terrain.
	isTerrain: function(self: Data, body: Body): boolean

	-- A function that clears all data stored in the "Data" object, including user data in Data.store field.
	-- And reset some data to default values.
	clear: function(self: Data)
end

local data: Data
return data

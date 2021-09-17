local Dictionary = require("Dictionary").Type
local Body = require("Body").Type
local record Data
	userdata
	enum Relation
		"Enemy"
		"Friend"
		"Neutral"
		"Unknown"
		"Any"
	end
	const groupHide: integer
	const groupDetectPlayer: integer
	const groupTerrain: integer
	const groupDetection: integer
	const store: Dictionary
	setShouldContact: function(self: Data, groupA: integer, groupB: integer, contact: boolean)
	getShouldContact: function(self: Data, groupA: integer, groupB: integer): boolean
	setRelation: function(self: Data, groupA: integer, groupB: integer, relation: Relation)
	getRelation: function(self: Data, groupA: integer, groupB: integer): Relation
	getRelation: function(self: Data, bodyA: Body, bodyB: Body): Relation
	isEnemy: function(self: Data, groupA: integer, groupB: integer): boolean
	isEnemy: function(self: Data, bodyA: Body, bodyB: Body): boolean
	isFriend: function(self: Data, groupA: integer, groupB: integer): boolean
	isFriend: function(self: Data, bodyA: Body, bodyB: Body): boolean
	isNeutral: function(self: Data, groupA: integer, groupB: integer): boolean
	isNeutral: function(self: Data, bodyA: Body, bodyB: Body): boolean
	setDamageFactor: function(self: Data, damageType: integer, defenceType: integer, bounus: number)
	getDamageFactor: function(self: Data, damageType: integer, defenceType: integer): number
	isPlayer: function(self: Data, body: Body): boolean
	isTerrain: function(self: Data, body: Body): boolean
	clear: function(self: Data)
end
local data: Data
return data

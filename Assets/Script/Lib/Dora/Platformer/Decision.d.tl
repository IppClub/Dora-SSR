local Object = require("Object").Type
local Array = require("Array").Type
local Unit = require("Platformer.Unit").Type
local Behavior = require("Platformer.Behavior")
local Relation = require("Platformer.Data").Relation
local record AI
	userdata
	getUnitsByRelation: function(self: AI, relation: Relation): Array
	getDetectedUnits: function(self: AI): Array
	getDetectedBodies: function(self: AI): Array
	getNearestUnit: function(self: AI, relation: Relation): Unit
	getNearestUnitDistance: function(self: AI, relation: Relation): number
	getUnitsInAttackRange: function(self: AI): Array
	getBodiesInAttackRange: function(self: AI): Array
end
local record Decision
	record Leaf
		embed Object
	end
	Sel: function(nodes: {Leaf}): Leaf
	Seq: function(nodes: {Leaf}): Leaf
	Con: function(name: string, handler: function(self: Unit)): Leaf
	Act: function(action: string): Leaf
	Act: function(handler: function(self: Unit): string): Leaf
	Accept: function(): Leaf
	Reject: function(): Leaf
	Behave: function(name: string, root: Behavior.Leaf): Leaf
	AI: AI
end
local decision: Decision
return decision

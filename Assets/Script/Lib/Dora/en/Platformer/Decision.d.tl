local Object = require("Object").Type
local Array = require("Array").Type
local Unit = require("Platformer.Unit").Type
local Behavior = require("Platformer.Behavior")
local Relation = require("Platformer.Data").Relation

-- The singleton record to retrieve information when executing the decision tree.
local record AI
	userdata

	-- Gets an array of units in detection range that have the specified relation to current AI agent.
	-- @param relation (Relation) The relation to filter the units by.
	-- @return (Array) An array of units with the specified relation.
	getUnitsByRelation: function(self: AI, relation: Relation): Array

	-- Gets an array of units that the AI has detected.
	-- @return (Array) An array of detected units.
	getDetectedUnits: function(self: AI): Array

	-- Gets an array of bodies that the AI has detected.
	-- @return (Array) An array of detected bodies.
	getDetectedBodies: function(self: AI): Array

	-- Gets the nearest unit that has the specified relation to the AI.
	-- @param relation (Relation) The relation to filter the units by.
	-- @return (Unit) The nearest unit with the specified relation.
	getNearestUnit: function(self: AI, relation: Relation): Unit

	-- Gets the distance to the nearest unit that has the specified relation to the AI agent.
	-- @param relation (Relation) The relation to filter the units by.
	-- @return (number) The distance to the nearest unit with the specified relation.
	getNearestUnitDistance: function(self: AI, relation: Relation): number

	-- Gets an array of units that are within attack range.
	-- @return (Array) An array of units in attack range.
	getUnitsInAttackRange: function(self: AI): Array

	-- Gets an array of bodies that are within attack range.
	-- @return (Array) An array of bodies in attack range.
	getBodiesInAttackRange: function(self: AI): Array
end

-- A decision tree framework for creating game AI structures.
local record Decision

	-- A leaf node in a decision tree.
	record Leaf
		embed Object
	end

	-- Creates a selector node with the specified child nodes.
	-- A selector node will go through the child nodes until one succeeds.
	-- @param nodes ({Leaf}) An array of `Leaf` nodes.
	-- @return (Leaf) A `Leaf` node that represents a selector.
	Sel: function(nodes: {Leaf}): Leaf

	-- Creates a sequence node with the specified child nodes.
	-- A sequence node will go through the child nodes until all node succeeds.
	-- @param nodes ({Leaf}) An array of `Leaf` nodes.
	-- @return (Leaf) A `Leaf` node that represents a sequence.
	Seq: function(nodes: {Leaf}): Leaf

	-- Creates a condition node with the specified name and handler function.
	-- @param name (string) The name of the condition.
	-- @param check (function) The check function that takes a `Unit` parameter and returns a boolean result.
	-- @return (Leaf) A `Leaf` node that represents a condition check.
	Con: function(name: string, check: function(self: Unit): boolean): Leaf

	-- Creates an action node with the specified action name.
	-- @param actionName (string) The name of the action to perform.
	-- @return (Leaf) A `Leaf` node that represents an action.
	Act: function(actionName: string): Leaf

	-- Creates an action node with the specified handler function.
	-- @param handler (function) The handler function that takes a `Unit` parameter which is the running AI agent and returns an action.
	-- @return (Leaf) A `Leaf` node that represents an action.
	Act: function(handler: function(self: Unit): string): Leaf

	-- Creates a leaf node that represents accepting the current behavior tree.
	-- Always get success result from this node.
	-- @return (Leaf) A `Leaf` node.
	Accept: function(): Leaf

	-- Creates a leaf node that represents rejecting the current behavior tree.
	-- Always get failure result from this node.
	-- @return (Leaf) A `Leaf` node.
	Reject: function(): Leaf

	-- Creates a leaf node with the specified behavior tree as its root.
	-- It is possible to include a Behavior Tree as a node in a Decision Tree by using the Behave() function. This allows the AI to use a combination of decision-making and behavior execution to achieve its goals.
	-- @param name (string) The name of the behavior tree.
	-- @param root (Behavior.Leaf) The root node of the behavior tree.
	-- @return (Leaf) A `Leaf` node.
	Behave: function(name: string, root: Behavior.Leaf): Leaf

	-- The singleton instance to retrieve information while executing the decision tree.
	AI: AI
end

local decision: Decision
return decision

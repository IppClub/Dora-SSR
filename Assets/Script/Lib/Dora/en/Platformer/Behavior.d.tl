local Unit = require("Platformer.Unit").Type
local Object = require("Object").Type
local Item = require("Array").Item

-- A behavior tree framework for creating game AI structures.
local record Behavior

	-- A blackboard object that can be used to store data for behavior tree nodes.
	record Blackboard

		-- The time since the last frame update in seconds.
		const deltaTime: number

		-- The unit that the AI agent belongs to.
		const owner: Unit

		-- A metamethod to index the blackboard properties.
		-- @param key (string) The key to index.
		-- @return (Item) The value associated with the key.
		metamethod __index: function(self: Blackboard, key: string): Item

		-- A metamethod to assign values to the blackboard properties.
		-- @param key (string) The key to assign.
		-- @param item (Item) The value to assign to the key.
		metamethod __newindex: function(self: Blackboard, key: string, item: Item)
	end

	-- A leaf node in a behavior tree.
	record Leaf
		embed Object
	end

	-- Creates a new sequence node that executes an array of child nodes in order.
	-- @param nodes ({Leaf}) An array of child nodes.
	-- @return (Leaf) A new sequence node.
	Seq: function(nodes: {Leaf}): Leaf

	-- Creates a new selector node that selects and executes one of its child nodes that will succeed.
	-- @param nodes ({Leaf}) An array of child nodes.
	-- @return (Leaf) A new selector node.
	Sel: function(nodes: {Leaf}): Leaf

	-- Creates a new condition node that executes a check handler function when executed.
	-- @param name (string) The name of the condition.
	-- @param check (function) A function that takes a blackboard object and returns a boolean value.
	-- @return (Leaf) A new condition node.
	Con: function(name: string, check: function(board: Blackboard): boolean): Leaf

	-- Creates a new action node that executes an action when executed.
	-- This node will block the execution until the action finishes.
	-- @param actionName (string) The name of the action to execute.
	-- @return (Leaf) A new action node.
	Act: function(actionName: string): Leaf

	-- Creates a new command node that executes a command when executed.
	-- This node will return right after the action starts.
	-- @param actionName (string) The name of the command to execute.
	-- @return (Leaf) A new command node.
	Command: function(actionName: string): Leaf

	-- Creates a new wait node that waits for a specified duration when executed.
	-- @param duration (number) The duration to wait in seconds.
	-- @return (Leaf) A new wait node.
	Wait: function(duration: number): Leaf

	-- Creates a new countdown node that executes a child node continuously until a timer runs out.
	-- @param time (number) The time limit in seconds.
	-- @param node (Leaf) The child node to execute.
	-- @return (Leaf) A new countdown node.
	Countdown: function(time: number, node: Leaf): Leaf

	-- Creates a new timeout node that executes a child node until a timer runs out.
	-- @param time (number) The time limit in seconds.
	-- @param node (Leaf) The child node to execute.
	-- @return (Leaf) A new timeout node.
	Timeout: function(time: number, node: Leaf): Leaf

	-- Creates a new repeat node that executes a child node a specified number of times.
	-- @param times (integer) The number of times to execute the child node.
	-- @param node (Leaf) The child node to execute.
	-- @return (Leaf) A new repeat node.
	Repeat: function(times: integer, node: Leaf): Leaf

	-- Creates a new repeat node that executes a child node repeatedly.
	-- @param node (Leaf) The child node to execute.
	-- @return (Leaf) A new repeat node.
	Repeat: function(node: Leaf): Leaf

	-- Creates a new retry node that executes a child node repeatedly until it succeeds or a maximum number of retries is reached.
	-- @param times (integer) The maximum number of retries.
	-- @param node (Leaf) The child node to execute.
	-- @return (Leaf) A new retry node.
	Retry: function(times: integer, node: Leaf): Leaf

	-- Creates a new retry node that executes a child node repeatedly until it succeeds.
	-- @param node (Leaf) The child node to execute.
	-- @return (Leaf) A new retry node.
	Retry: function(node: Leaf): Leaf
end

local behavior: Behavior
return behavior

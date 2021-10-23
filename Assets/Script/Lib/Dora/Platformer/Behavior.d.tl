local Unit = require("Platformer.Unit").Type
local Object = require("Object").Type
local Item = require("ItemBase")
local record Behavior
	record Blackboard
		const deltaTime: number
		const owner: Unit
		metamethod __index: function(self: Blackboard, key: string): Item
		metamethod __newindex: function(self: Blackboard, key: string, item: Item)
	end
	record Leaf
		embed Object
	end
	Seq: function(nodes: {Leaf}): Leaf
	Sel: function(nodes: {Leaf}): Leaf
	Con: function(name: string, handler: function(board: Blackboard): boolean): Leaf
	Act: function(action: string): Leaf
	Command: function(action: string): Leaf
	Wait: function(duration: number): Leaf
	Countdown: function(time: number, node: Leaf): Leaf
	Timeout: function(time: number, node: Leaf): Leaf
	Repeat: function(times: integer, node: Leaf): Leaf
	Repeat: function(node: Leaf): Leaf
	Retry: function(times: integer, node: Leaf): Leaf
	Retry: function(node: Leaf): Leaf
end
local behavior: Behavior
return behavior

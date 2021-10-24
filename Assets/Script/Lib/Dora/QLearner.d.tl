local Object = require("Object").Type
local record QLearner
	embed Object
	const matrix: {{integer, integer, number}}
	update: function(self: QLearner, state: integer, action: integer, reward: number)
	getBestAction: function(self: QLearner, state: integer): integer
	load: function(self: QLearner, values: {{integer, integer, number}})
end
local record QLearnerClass
	type Type = QLearner
	pack: function(cls: QLearnerClass, hints: {integer}, values: {integer}): integer
	unpack: function(cls: QLearnerClass, hints: {integer}, state: integer): {integer}
	metamethod __call: function(
		cls: QLearnerClass,
		gamma?: number --[[0.5]],
		alpha?: number --[[0.5]],
		maxQ?: number --[[100.0]]
	): QLearner
end
local qLearnerClass: QLearnerClass
return qLearnerClass

local Object = require("Object").Type

-- A simple reinforcement learning framework that can be used to learn optimal policies for Markov decision processes using Q-learning. Q-learning is a model-free reinforcement learning algorithm that learns an optimal action-value function from experience by repeatedly updating estimates of the Q-value of state-action pairs.
local record QLearner

	-- Inherits from `Object`.
	embed Object

	-- The matrix that stores state, action, and Q-value.
	const matrix: {{
		--[[state]] integer,
		--[[action]] integer,
		--[[Q-value]] number
	}}

	-- Update Q-value for a state-action pair based on received reward.
	-- @param state (integer) Representing the state.
	-- @param action (integer) Representing the action. Must be greater than 0.
	-- @param reward (number) Representing the reward received for the action in the state.
	update: function(self: QLearner, state: integer, action: integer, reward: number)

	-- Returns the best action for a given state based on the current Q-values.
	-- @param state (integer) The current state.
	-- @return (integer) The action with the highest Q-value for the given state. Returns 0 if no action is available.
	getBestAction: function(self: QLearner, state: integer): integer

	-- Load Q-values from a matrix of state-action pairs.
	-- @param values ({{integer - The state, integer The action, number - The Q-value for the given state-action pair}}) The matrix of state-action pairs to load.
	load: function(self: QLearner, values: {{
			--[[state]] integer,
			--[[action]] integer,
			--[[Q-value]] number
		}})
end

-- A class for creating QLearner objects.
-- @usage
-- local ML = require("ML")
-- local qLearner = ML.QLearner()
local record QLearnerClass
	type Type = QLearner

	-- Construct a state from given hints and condition values.
	-- @param hints ({integer}) Representing the max number of possible hints. For example, if there are two conditions, and each condition has 3 possible values (0, 1, 2), then the hints array is {3, 3}.
	-- @param values ({integer}) The condition values as discrete values.
	-- @return (integer) The packed state value.
	pack: function(self: QLearnerClass, hints: {integer}, values: {integer}): --[[state]] integer

	-- Deconstruct a state from given hints to get condition values.
	-- @param hints ({integer}) Representing the max number of possible hints. For example, if there are two conditions, and each condition has 3 possible values (0, 1, 2), then the hints array is {3, 3}.
	-- @param state (integer) The state integer to unpack.
	-- @return ({integer}) The condition values as discrete values.
	unpack: function(self: QLearnerClass, hints: {integer}, state: integer): {integer}

	-- Create a new QLearner object with optional parameters for gamma, alpha, and maxQ.
	-- @param gamma (number) The discount factor for future rewards. Defaults to 0.5.
	-- @param alpha (number) The learning rate for updating Q-values. Defaults to 0.5.
	-- @param maxQ (number) The maximum Q-value. Defaults to 100.0.
	-- @return (QLearner) The newly created QLearner object.
	metamethod __call: function(
		self: QLearnerClass,
		gamma?: number --[[0.5]],
		alpha?: number --[[0.5]],
		maxQ?: number --[[100.0]]
	): QLearner
end

-- A record for machine learning algorithms.
local record ML

	-- Enumeration for comparison operators
	enum Operator
		"return"
		"<="
		">"
		"=="
	end

	-- A function that takes CSV data as input and applies the C4.5 machine learning algorithm to build a decision tree model asynchronously.
	-- C4.5 is a decision tree algorithm that uses information gain to select the best attribute to split the data at each node of the tree. The resulting decision tree can be used to make predictions on new data.
	-- @param csvData (string) The CSV training data for building the decision tree using delimiter `,`.
	-- @param maxDepth (integer) The maximum depth of the generated decision tree.
	-- Set to 0 to prevent limiting the generated tree depth.
	-- @param handler (function) The callback function to be called for each node of the generated decision tree.
	-- 	@param depth (integer) The depth of the current node in the decision tree.
	-- 	@param name (string) The name of the attribute used for splitting the data at the current node.
	-- 	@param op (Operator) The comparison operator used for splitting the data at the current node.
	-- 	@param value (string) The value used for splitting the data at the current node.
	-- @return (number｜nil) The accuracy of the decision tree on the training data.
	-- @return (string) An error message if an error occurred during building of the decision tree.
	BuildDecisionTreeAsync: function(
		csvData: string,
		maxDepth: integer,
		handler: function(depth: integer, name: string, op: Operator, value: string)
	): --[[accuracy]] number, --[[error]] string

	-- A field for accessing QLearner class.
	QLearner: QLearnerClass
end

local ml: ML
return ml

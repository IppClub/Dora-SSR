local Object = require("Object").Type

-- 一个简单的强化学习框架，可用于使用Q-learning算法学习马尔可夫决策过程的最优策略。
-- Q-learning是一种无模型强化学习算法，通过反复更新一对状态和动作下计算的Q值，获得最优动作评估值的函数。
local record QLearner

	-- 继承自`Object`。
	embed Object

	-- 存储状态、动作和Q值的矩阵。
	const matrix: {{
		--[[state]] integer,
		--[[action]] integer,
		--[[Q-value]] number
	}}

	-- 根据收到的奖励值更新一对状态和动作下的Q值。
	-- @param state (integer) 表示状态的整数。
	-- @param action (integer) 表示动作的整数。必须为大于0的整数。
	-- @param reward (number) 表示在状态中采取行动获得的奖励值。
	update: function(self: QLearner, state: integer, action: integer, reward: number)

	-- 基于当前Q值返回给定状态的最佳动作。
	-- @param state (integer) 当前状态。
	-- @return (integer) 给定状态下具有最高Q值的动作。返回0表示没有动作。
	getBestAction: function(self: QLearner, state: integer): integer

	-- 从状态-动作对的矩阵中加载Q值。
	-- @param values ({{integer 状态, integer 动作, number 状态-动作对的Q值}}) 要加载的状态-动作对的矩阵。
	load: function(self: QLearner, values: {{
			--[[state]] integer,
			--[[action]] integer,
			--[[Q-value]] number
		}})
end

-- 用于创建QLearner对象的类。
-- @usage
-- local ML = require("ML")
-- local qLearner = ML.QLearner()
local record QLearnerClass
	type Type = QLearner

	-- 根据给定的离散条件有多少种可能的提示和当前的条件数值构造状态值。
	-- @param hints ({integer}) 表示离散条件有多少种可能的提示。假设有两组条件，取值范围均为0, 1, 2，则提示数组为{3, 3}。
	-- @param values ({integer}) 离散值形式的条件值。
	-- @return (integer) 生成的状态值。
	pack: function(self: QLearnerClass, hints: {integer}, values: {integer}): --[[state]] integer

	-- 通过给定的离散条件有多少种可能的提示，解析状态值以获取条件值。
	-- @param hints ({integer}) 表示离散条件有多少种可能的提示。假设有两组条件，取值范围均为0, 1, 2，则提示数组为{3, 3}。
	-- @param state (integer) 要解析的状态整数。
	-- @return ({integer}) 包含离散值形式的条件值列表。
	unpack: function(self: QLearnerClass, hints: {integer}, state: integer): {integer}

	-- 创建一个新的QLearner对象，并设定好gamma、alpha和maxQ参数。
	-- @param gamma (number) 计算奖励的调节因子。默认为0.5。
	-- @param alpha (number) 更新Q值的学习速率。默认为0.5。
	-- @param maxQ (number) 最大Q值。默认为100.0。
	-- @return (QLearner) 新创建的QLearner对象。
	metamethod __call: function(
		self: QLearnerClass,
		gamma?: number --[[0.5]],
		alpha?: number --[[0.5]],
		maxQ?: number --[[100.0]]
	): QLearner
end

-- 包含一些常用机器学习算法的模块。
local record ML

	-- 比较运算符的枚举。
	enum Operator
		"return"
		"<="
		">"
		"=="
	end

	-- 输入CSV数据，然后异步执行C4.5机器学习算法构建决策树模型。
	-- C4.5是一种决策树算法，它使用信息增益来选择最佳属性，在树的每个节点上拆分数据。生成的决策树可以用于对新数据进行预测。
	-- @param csvData (string) 使用`,`分隔符的CSV格式训练数据。
	-- @param maxDepth (integer) 生成的决策树的最大深度。
	-- 将其设置为0则不再限制生成树的深度。
	-- @param handler (function) 用于遍历访问生成决策树节点的回调函数。
	-- 	@param depth (integer) 决策树中当前节点的深度。
	-- 	@param name (string) 在当前节点处拆分数据的属性的名称。
	-- 	@param op (Operator) 在当前节点处拆分数据使用的比较运算符。
	-- 	@param value (string) 在当前节点处拆分数据的值。
	-- @return (number｜nil) 决策树在训练数据上的准确度。
	-- @return (string) 如果在构建决策树期间发生错误，则返回此错误消息。
	BuildDecisionTreeAsync: function(
		csvData: string,
		maxDepth: integer,
		handler: function(depth: integer, name: string, op: Operator, value: string)
	): --[[accuracy]] number, --[[error]] string

	-- 用于访问QLearner类的字段。
	QLearner: QLearnerClass
end

local ml: ML
return ml

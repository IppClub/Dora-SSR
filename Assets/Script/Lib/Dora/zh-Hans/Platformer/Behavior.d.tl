local Unit = require("Platformer.Unit").Type
local Object = require("Object").Type
local Item = require("Array").Item

-- 用于创建游戏AI的行为树框架。
local record Behavior

	-- 黑板对象，可用于为行为树节点存储状态数据。
	record Blackboard

		-- 上一帧更新以来的时间，以秒为单位。
		const deltaTime: number

		-- 当前AI所属的单位。
		const owner: Unit

		-- 用于索引黑板对象的元方法。
		-- @param key (string) 要索引的键。
		-- @return (Item) 与键相关联的值。
		metamethod __index: function(self: Blackboard, key: string): Item

		-- 用于为黑板设置属性的元方法。
		-- @param key (string) 要设置的键。
		-- @param item (Item) 要设置给键的值。
		metamethod __newindex: function(self: Blackboard, key: string, item: Item)
	end

	-- 行为树中的节点。
	record Leaf
		embed Object
	end

	-- 创建一个新的序列节点，并按顺序执行列表中的子节点。
	-- @param nodes ({Leaf}) 子节点的列表。
	-- @return (Leaf) 新的序列AI节点。
	Seq: function(nodes: {Leaf}): Leaf

	-- 创建一个新的选择器节点，按顺序遍历寻找可以执行成功的子节点。
	-- @param nodes ({Leaf}) 子节点的列表。
	-- @return (Leaf) 新的选择器AI节点。
	Sel: function(nodes: {Leaf}): Leaf

	-- 创建一个新的条件节点，在执行时调用检查处理的函数程序。
	-- @param name (string) 条件的名称。
	-- @param handler (function) 检查函数，接收一个黑板对象并返回布尔值。
	-- @return (Leaf) 新的条件AI节点。
	Con: function(name: string, handler: function(board: Blackboard): boolean): Leaf

	-- 创建一个新的操作节点，在执行时启动一个特定的单位动作。
	-- 此节点将阻塞当前AI树的执行，直到该单位动作执行完成。
	-- @param actionName (string) 要执行的单位动作的名称。
	-- @return (Leaf) 新的动作AI节点。
	Act: function(actionName: string): Leaf

	-- 创建一个新的命令节点，在执行时启动一个特定的单位动作。
	-- 此节点将在动作开始后立即返回。
	-- @param actionName (string) 要执行的单位动作的名称。
	-- @return (Leaf) 新的命令AI节点。
	Command: function(actionName: string): Leaf

	-- 创建一个新的等待节点，在执行时等待指定的时间。
	-- @param duration (number) 等待的时间，以秒为单位。
	-- @return (Leaf) 新的等待AI节点。
	Wait: function(duration: number): Leaf

	-- 创建一个新的倒计时节点，只在计时器计时时间内持续执行子节点。
	-- @param time (number) 时间限制，以秒为单位。
	-- @param node (Leaf) 要执行的子节点。
	-- @return (Leaf) 新的倒计时AI节点。
	Countdown: function(time: number, node: Leaf): Leaf

	-- 创建一个新的超时节点，在计时器运行结束前执行子节点，计时器结束时中止子节点的运行。
	-- @param time (number) 计时时间，以秒为单位。
	-- @param node (Leaf) 要执行的子节点。
	-- @return (Leaf) 新的超时AI节点。
	Timeout: function(time: number, node: Leaf): Leaf

	-- 创建一个新的重复节点，执行指定次数的子节点。
	-- @param times (integer) 要重复执行子节点的次数。
	-- @param node (Leaf) 要执行的子节点。
	-- @return (Leaf) 新的重复AI节点。
	Repeat: function(times: integer, node: Leaf): Leaf

	-- 创建一个新的重复节点，反复执行子节点（无限次数）。
	-- @param node (Leaf) 要执行的子节点。
	-- @return (Leaf) 新的重复AI节点。
	Repeat: function(node: Leaf): Leaf

	-- 创建一个新的重试节点，重复执行子节点直到成功或达到最大重试次数。
	-- @param times (integer) 最大重试次数。
	-- @param node (Leaf) 要执行的子节点。
	-- @return (Leaf) 新的重试AI节点。
	Retry: function(times: integer, node: Leaf): Leaf

	-- 创建一个新的重试节点，重复执行子节点直到成功为止。
	-- @param node (Leaf) 要执行的子节点。
	-- @return (Leaf) 新的重试AI节点。
	Retry: function(node: Leaf): Leaf
end

local behavior: Behavior
return behavior

local Object = require("Object").Type
local Array = require("Array").Type
local Unit = require("Platformer.Unit").Type
local Behavior = require("Platformer.Behavior")
local Relation = require("Platformer.Data").Relation

-- 用于在执行决策树AI时获取信息的单例类。
local record AI
	userdata

	-- 获取游戏单位的检测范围内具有指定关系的单位。
	-- @param relation (Relation) 游戏单位的关系。
	-- @return (Array) 具有指定关系的游戏单位列表。
	getUnitsByRelation: function(self: AI, relation: Relation): Array

	-- 获取AI已检测到的游戏单位。
	-- @return (Array) 被检测到的游戏单位列表。
	getDetectedUnits: function(self: AI): Array

	-- 获取AI已检测到的游戏物理体。
	-- @return (Array) 被检测到的游戏物理体列表。
	getDetectedBodies: function(self: AI): Array

	-- 获取距离AI单位最近的具有指定关系的游戏单位。
	-- @param relation (Relation) 游戏单位的关系。
	-- @return (Unit) 具有指定关系的最近的游戏单位。
	getNearestUnit: function(self: AI, relation: Relation): Unit

	-- 获取距离AI最近的具有指定关系的游戏单位的距离。
	-- @param relation (Relation) 游戏单位的关系。
	-- @return (number) 距离最近的游戏单位的距离。
	getNearestUnitDistance: function(self: AI, relation: Relation): number

	-- 获取攻击范围内的游戏单位。
	-- @return (Array) 攻击范围内的游戏单位列表。
	getUnitsInAttackRange: function(self: AI): Array

	-- 获取攻击范围内的游戏物理体。
	-- @return (Array) 攻击范围内的游戏物理体列表。
	getBodiesInAttackRange: function(self: AI): Array
end

-- 用于创建游戏AI的决策树框架。
local record Decision

	-- 决策树中的节点。
	record Leaf
		embed Object
	end

	-- 创建一个选择器节点。
	-- 选择器节点将遍历子节点直到任意节点执行成功。
	-- @param nodes ({Leaf}) 子节点的列表。
	-- @return (Leaf) 新的决策树选择器节点。
	Sel: function(nodes: {Leaf}): Leaf

	-- 创建一个新的序列节点。
	-- 序列节点将遍历执行子节点直到所有节点都成功。
	-- @param nodes ({Leaf}) 子节点的列表。
	-- @return (Leaf) 新的决策树序列节点。
	Seq: function(nodes: {Leaf}): Leaf

	-- 创建具有指定名称和检查函数的条件节点。
	-- @param name (string) 条件节点名称。
	-- @param handler (function) 接收`Unit`并返回`Leaf`节点的处理程序函数。
	-- @return (Leaf) 新的决策树条件检查节点。
	Con: function(name: string, handler: function(self: Unit): boolean): Leaf

	-- 创建具有执行特定单位动作的动作节点。
	-- @param actionName (string) 要执行的单位动作的名称。
	-- @return (Leaf) 新的决策树动作节点.
	Act: function(actionName: string): Leaf

	-- 创建一个动态的动作节点，执行一个函数返回要执行的单位动作名称。
	-- @param handler (function) 接收`Unit`并返回要执行的单位动作名称。
	-- @return (Leaf) 新的决策树动作节点.
	Act: function(handler: function(self: Unit): string): Leaf

	-- 创建一个立即返回成功的决策树节点。
	-- @return (Leaf) 新的决策树接受节点.
	Accept: function(): Leaf

	-- 创建一个立即返回失败的决策树节点。
	-- @return (Leaf) 新的决策树拒绝节点.
	Reject: function(): Leaf

	-- 创建一个决策树节点，会执行一个作为子节点行为树并返回执行结果。
	-- 可以将行为树作为一个节点包含在决策树中，使AI能够使用决策和行为执行的组合来实现复杂的结构。
	-- @param name (string) 子行为树的名称。
	-- @param root (Behavior.Leaf) 子行为树的根节点。
	-- @return (Leaf) 新的决策树“行为”节点。
	Behave: function(name: string, root: Behavior.Leaf): Leaf

	-- 获得决策树执行相关信息的单例对象。
	AI: AI
end

local decision: Decision
return decision

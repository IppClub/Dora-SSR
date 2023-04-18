local Dictionary = require("Dictionary").Type
local Body = require("Body").Type

-- 单例对象，提供了存储和访问游戏全局定义数据的统一位置。
local record Data
	userdata

	-- 枚举类型，表示两个游戏单位组之间的可能关系。
	enum Relation
		"Enemy"
		"Friend"
		"Neutral"
		"Unknown"
		"Any"
	end

	-- 第一个玩家单位组可用的编号。
	const groupFirstPlayer: integer

	-- 最后一个玩家单位组可用的编号。
	const groupLastPlayer: integer

	-- 隐藏的单位组的编号，默认不会与其它编号的单位组发生碰撞。
	const groupHide: integer

	-- 用于检测其它玩家单位组的单位组编号，默认会与所有玩家单位组发生碰撞。
	const groupDetectPlayer: integer

	-- 代表场景地形的单位组的编号，默认会与其它单位组发生碰撞。
	const groupTerrain: integer

	-- 用于检测其它单位组的单位组编号，默认会与其他任何单位组发生碰撞。
	const groupDetection: integer

	-- 用于全局存储任意游戏定义数据的字典对象。
	const store: Dictionary

	-- 设置两个单位组是否应该发生碰撞。
	-- @param groupA (integer) 第一个单位组的编号。
	-- @param groupB (integer) 第二个单位组的编号。
	-- @param contact (boolean) 两个单位组是否会发生碰撞。
	setShouldContact: function(self: Data, groupA: integer, groupB: integer, contact: boolean)

	-- 获取两个单位组是否应该发生碰撞。
	-- @param groupA (integer) 第一个单位组的编号。
	-- @param groupB (integer) 第二个单位组的编号。
	-- @return (boolean) 两个单位组是否会发生碰撞。
	getShouldContact: function(self: Data, groupA: integer, groupB: integer): boolean

	-- 设置两个单位组之间的关系。
	-- @param groupA (integer) 第一个单位组的编号。
	-- @param groupB (integer) 第二个单位组的编号。
	-- @param relation (Relation) 两个单位组之间的关系。
	setRelation: function(self: Data, groupA: integer, groupB: integer, relation: Relation)

	-- 获取两个单位组之间的关系。
	-- @param groupA (integer) 第一个单位组的编号。
	-- @param groupB (integer) 第二个单位组的编号。
	-- @return (Relation) 两个单位组之间的关系.
	getRelation: function(self: Data, groupA: integer, groupB: integer): Relation

	-- 获取两个物理体之间的关系。
	-- @param bodyA (Body) 第一个物理体。
	-- @param bodyB (Body) 第二个物理体。
	-- @return (Relation) 两个物理体之间的关系。
	getRelation: function(self: Data, bodyA: Body, bodyB: Body): Relation

	-- 两个单位组是否为"敌人"关系。
	-- @param groupA (integer) 第一个单位组的编号。
	-- @param groupB (integer) 第二个单位组的编号。
	-- @return (boolean) 两个单位组是否为"敌人"关系。
	isEnemy: function(self: Data, groupA: integer, groupB: integer): boolean

	-- 两个物理体是否为"敌人"关系。
	-- @param bodyA (Body) 第一个物理体。
	-- @param bodyB (Body) 第二个物理体。
	-- @return (boolean) 两个物理体是否为"敌人"关系。
	isEnemy: function(self: Data, bodyA: Body, bodyB: Body): boolean

	-- 两个单位组是否为"友方"关系。
	-- @param groupA (integer) 第一个单位组的编号。
	-- @param groupB (integer) 第二个单位组的编号。
	-- @return (boolean) 两个单位组是否为"友方"关系。
	isFriend: function(self: Data, groupA: integer, groupB: integer): boolean

	-- 两个物理体是否为"友方"关系。
	-- @param bodyA (Body) 第一个物理体。
	-- @param bodyB (Body) 第二个物理体。
	-- @return (boolean) 两个物理体是否为"友方"关系。
	isFriend: function(self: Data, bodyA: Body, bodyB: Body): boolean

	-- 两个单位组是否为"中立"关系。
	-- @param groupA (integer) 第一个单位组的编号。
	-- @param groupB (integer) 第二个单位组的编号。
	-- @return (boolean) 两个单位组是否为"中立"关系。
	isNeutral: function(self: Data, groupA: integer, groupB: integer): boolean

	-- 两个物理体是否为"中立"关系。
	-- @param bodyA (Body) 第一个物理体。
	-- @param bodyB (Body) 第二个物理体。
	-- @return (boolean) 两个物理体是否为"中立"关系。
	isNeutral: function(self: Data, bodyA: Body, bodyB: Body): boolean

	-- 设置特定伤害类型对特定防御类型的加成系数，内置的"MeleeAttack"和"RangeAttack"的单位动作使用简单的计算式`finalDamage = damage * bonus`来计算攻击产生的伤害。
	-- @param damageType (integer) 伤害类型的编号。
	-- @param defenceType (integer) 防御类型的编号。
	-- @param bonus (number) 伤害系数.
	setDamageFactor: function(self: Data, damageType: integer, defenceType: integer, bounus: number)

	-- 获得特定伤害类型对特定防御类型的加成系数。
	-- @param damageType (integer) 伤害类型的编号。
	-- @param defenceType (integer) 防御类型的编号。
	-- @return (number) 伤害系数.
	getDamageFactor: function(self: Data, damageType: integer, defenceType: integer): number

	-- 检查一个物理体是否为玩家单位。
	-- 等同于代码 `Data.groupFirstPlayer <= body.group and body.group <= Data.groupLastPlayer`。
	-- @param body (Body) 要检查的物理体。
	-- @return (boolean) 是否为玩家单位。
	isPlayer: function(self: Data, body: Body): boolean

	-- 检查一个物理体是否为地形单位。
	-- 等同于代码 `body.group == Data.groupTerrain`.
	-- @param body (Body) 要检查的物理体。
	-- @return (boolean) 是否为地形单位。
	isTerrain: function(self: Data, body: Body): boolean

	-- 清除存储在"Data"对象中的所有数据，包括Data.store字段中的用户自定义数据。
	-- 并将一些内置定义数据重置为默认值。
	clear: function(self: Data)
end

local data: Data
return data

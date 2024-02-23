local ContainerItem = require("ContainerItemType")
local Data = require("Platformer.Data")

-- A class to specifies how a bullet object should interact with other game objects or units based on their relationship.
local record TargetAllow

	-- Inherits from `ContainerItem`.
	embed ContainerItem

	-- Whether the bullet object can collide with terrain.
	terrainAllowed: boolean

	-- A function that allows or disallows the bullet object to interact with a game object or unit, based on their relationship.
	-- @param relation (Data.Relation) The relationship between the bullet object and the other game object or unit.
	-- @param allow (boolean) Whether the bullet object should be allowed to interact.
	allow: function(self: TargetAllow, relation: Data.Relation, allow: boolean)

	-- A function that determines whether the bullet object is allowed to interact with a game object or unit, based on their relationship.
	-- @param relation (Data.Relation) The relationship between the bullet object and the other game object or unit.
	-- @return (boolean) Whether the bullet object is allowed to interact.
	isAllow: function(self: TargetAllow, relation: Data.Relation): boolean

	-- Converts the object to a value that can be used for interaction settings.
	-- @return (integer) The value that can be used for interaction settings.
	toValue: function(): integer
end

-- @usage
-- local TargetAllow = require("TargetAllow")
-- local targetAllow = TargetAllow()
-- targetAllow.terrainAllowed = true
-- targetAllow:allow("Enemy", true)
local record TargetAllowClass
	type Type = TargetAllow
	metamethod __call: function(self: TargetAllowClass): TargetAllow
end

local targetAllowClass: TargetAllowClass
return targetAllowClass

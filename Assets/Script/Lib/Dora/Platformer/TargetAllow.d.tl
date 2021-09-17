local ContainerItem = require("ContainerItemBase")
local Data = require("Platformer.Data")
local record TargetAllow
	embed ContainerItem
	terrainAllowed: boolean
	allow: function(self: TargetAllow, relation: Data.Relation, allow: boolean)
	isAllow: function(self: TargetAllow, relation: Data.Relation): boolean
end
local record TargetAllowClass
	type Type = TargetAllow
	metamethod __call: function(cls: TargetAllowClass): TargetAllow
end
local targetAllowClass: TargetAllowClass
return targetAllowClass

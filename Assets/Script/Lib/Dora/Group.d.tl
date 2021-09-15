local Object = require("Object").Type
local Entity = require("Entity").Type
local record Group
	embed Object
	const count: integer
	each: function(self: Group, func: function(Entity): boolean): boolean
	find: function(self: Group, func: function(Entity): boolean): Entity
	every: function(self: Group, func: function(Entity)): Group
end
local record GroupClass
	type Type = Group
	metamethod __call: function(cls: GroupClass, componemts: {string}): Group
end
print(Group:find())
print(Group:every())
local groupClass: GroupClass
return groupClass

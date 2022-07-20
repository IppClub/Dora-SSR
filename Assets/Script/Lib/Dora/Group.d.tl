local Object = require("Object").Type
local Entity = require("Entity").Type
local record Group
	embed Object
	const count: integer
	each: function(self: Group, func: function(Entity): boolean): boolean
	find: function(self: Group, func: function(Entity): boolean): Entity
	watch: function(self: Group, func: function(Entity)): Group
end
local record GroupClass
	type Type = Group
	metamethod __call: function(cls: GroupClass, componemts: {string}): Group
end
print(Group:find(nil))
print(Group:watch(nil))
local groupClass: GroupClass
return groupClass

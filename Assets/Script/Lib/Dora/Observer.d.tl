local Entity = require("Entity").Type
local record Observer
	watch: function(self: Observer, func: function(Entity)): Observer
end
local record ObserverClass
	type Type = Observer
	enum Action
		"Add"
		"Change"
		"AddOrChange"
		"Remove"
	end
	metamethod __call: function(self: ObserverClass, action: Action, components: {string}): Observer
end
local observerClass: ObserverClass
return observerClass

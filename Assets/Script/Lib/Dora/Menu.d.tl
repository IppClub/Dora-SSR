local Node = require("Node").Type
local record Menu
	embed Node
	enabled: boolean
end
local record MenuClass
	type Type = Menu
	metamethod __call: function(cls: MenuClass, width: number, height: number): Menu
	metamethod __call: function(cls: MenuClass): Menu
end
local menu: MenuClass
return menu

local Object = require("Object")
local record tolua
	type: function(item: any): string
	cast: function(name: string, item: Object.Type): Object.Type | nil
	class: function(className: string): table | nil
	setpeer: function(obj: Object.Type, data: table)
	getpeer: function(obj: Object.Type): table
end
local tolua_: tolua
return tolua_

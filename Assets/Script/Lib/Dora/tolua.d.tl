local ContainerItem = require("ContainerItemBase")
local Object = require("Object").Type
local record tolua
	type: function(item: any): string
	cast: function<T>(item: ContainerItem, name: string): T | nil
	class: function(className: string): table | nil
	setpeer: function(obj: Object, data: table)
	getpeer: function(obj: Object): table
end
local _tolua: tolua
return _tolua

local Node = require("Node").Type

local record xml
	dostring: function(xmlCodes: string): Node
	tolua: function(xmlCodes: string): string | nil, string | nil
	complete: function(xmlCodes: string): {{--[[label]] string, --[[insertText]] string}}
	check: function(xmlCodes: string): --[[success]] boolean, --[[Lua codes]] string | {{--[[line]] integer, --[[message]] string}}
end

return xml

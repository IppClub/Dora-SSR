local ActionDef = require("Action").Def
return function(...: ActionDef): ActionDef
	print(...)
	return {}
end

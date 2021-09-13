local ActionDef = require("ActionDefBase")
return function(...: ActionDef): ActionDef
	print(...)
	return {}
end

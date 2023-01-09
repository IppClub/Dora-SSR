local ActionDef = require("Action").Def
return function(duration: number): ActionDef
	print(duration)
	return {}
end

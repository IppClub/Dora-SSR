local ActionDef = require("ActionDefBase")
return function(duration: number): ActionDef
	print(duration)
	return {}
end

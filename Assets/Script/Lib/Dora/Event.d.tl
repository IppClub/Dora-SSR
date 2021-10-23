local ActionDef = require("ActionDefBase")
return function(
		name: string,
		param?: string --[[""]]
	): ActionDef
	print(name, param)
	return {}
end

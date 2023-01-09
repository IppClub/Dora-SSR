local ActionDef = require("Action").Def
return function(
		name: string,
		param?: string --[[""]]
	): ActionDef
	print(name, param)
	return {}
end

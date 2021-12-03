local Node = require("Node").Type
local record Param
	x: number
	y: number
	radius: number
	fillColor: integer
	borderColor: integer
	fillOrder: integer
	lineOrder: integer
end
return function(param: Param): Node
	print(param)
	return nil
end
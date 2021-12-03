local Node = require("Node").Type
local record Param
	x: number
	y: number
	width: number
	height: number
	fillColor: integer
	borderColor: integer
	fillOrder: integer
	lineOrder: integer
end
return function(param: Param): Node
	print(param)
	return nil
end
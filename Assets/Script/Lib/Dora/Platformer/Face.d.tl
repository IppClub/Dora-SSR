local Object = require("Object").Type
local Node = require("Node").Type
local Vec2 = require("Vec2").Type
local record Face
	embed Object
	addChild: function(self: Face, face: Face)
	toNode: function(self: Face): Node
end
local record FaceClass
	type Type = Face
	metamethod __call: function(
		cls: FaceClass,
		faceStr: string,
		point: Vec2 --[[Vec2.zero]],
		scale: number --[[1.0]],
		angle: number --[[0.0]]
	): Face
	metamethod __call: function(
		cls: FaceClass,
		createFunc: function(): (Node),
		point: Vec2 --[[Vec2.zero]],
		scale: number --[[1.0]],
		angle: number --[[0.0]]
	): Face
end
local faceClass: FaceClass
return faceClass

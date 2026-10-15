local Object = require("Object").Type
local Node = require("Node").Type
local Vec2 = require("Vec2").Type

-- Represents a definition for a visual component of a game bullet or other visual item.
local record Face

	-- Inherits from `Object`.
	embed Object

	-- Adds a child `Face` definition to it.
	-- @param face (Face) The child `Face` to add.
	addChild: function(self: Face, face: Face)

	-- Returns a node that can be added to a scene tree for rendering.
	-- @return (Node) The `Node` representing this `Face`.
	toNode: function(self: Face): Node
end

-- A record provides functions of creating instances of the `Face` component with different configurations.
-- @usage
-- local Face = require("Face")
-- local faceA = Face("Image/file.png")
-- local faceB = Face(function()
-- 	return Sprite("Image/file.png")
-- end)
-- faceA:toNode():addTo(entry)
-- faceB:toNode():addTo(entry)
local record FaceClass
	type Type = Face

	-- Creates a new `Face` definition using the specified attributes.
	-- @param faceStr (string) A string for creating the `Face` component.
	-- Could be 'Image/file.png' and 'Image/items.clip|itemA'.
	-- @param point (Vec2) [optional] The position of the `Face` component, default is `Vec2.zero`.
	-- @param scale (number) [optional] The scale of the `Face` component, default is 1.0.
	-- @param angle (number) [optional] The angle of the `Face` component, default is 0.0.
	-- @return (Face) The new `Face` component.
	metamethod __call: function(
		self: FaceClass,
		faceStr: string,
		point?: Vec2 --[[Vec2.zero]],
		scale?: number --[[1.0]],
		angle?: number --[[0.0]]
	): Face

	-- Creates a new `Face` definition using the specified attributes.
	-- @param createFunc (function) A function that returns a `Node` representing the `Face` component.
	-- @param point (Vec2) [optional] The position of the `Face` component, default is `Vec2.zero`.
	-- @param scale (number) [optional] The scale of the `Face` component, default is 1.0.
	-- @param angle (number) [optional] The angle of the `Face` component, default is 0.0.
	-- @return (Face) The new `Face` component.
	metamethod __call: function(
		self: FaceClass,
		createFunc: function(): (Node),
		point?: Vec2 --[[Vec2.zero]],
		scale?: number --[[1.0]],
		angle?: number --[[0.0]]
	): Face
end

local faceClass: FaceClass
return faceClass

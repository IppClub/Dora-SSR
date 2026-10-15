local Playable = require("Playable").Type

-- An implementation of the 'Playable' record using the DragonBones animation system.
local record DragonBone

	-- Inherit from the `Playable`.
	embed Playable

	-- Whether hit testing is enabled.
	hitTestEnabled: boolean

	-- Checks if a point is inside the boundaries of the instance and returns the name of the bone or slot at that point, or nil if no bone or slot is found.
	-- @param x (number) The x-coordinate of the point to check.
	-- @param y (number) The y-coordinate of the point to check.
	-- @return (string|nil) The name of the bone or slot at the point, or nil if no bone or slot is found.
	containsPoint: function(self: DragonBone, x: number, y: number): string | nil

	-- Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or nil if no bone or slot is found.
	-- @param x1 (number) The x-coordinate of the start point of the line segment.
	-- @param y1 (number) The y-coordinate of the start point of the line segment.
	-- @param x2 (number) The x-coordinate of the end point of the line segment.
	-- @param y2 (number) The y-coordinate of the end point of the line segment.
	-- @return (string|nil) The name of the bone or slot at the intersection point, or nil if no bone or slot is found.
	intersectsSegment: function(self: DragonBone, x1: number, y1: number, x2: number, y2: number): string | nil
end

-- A class for creating instances of the 'DragonBone' record.
local record DragonBoneClass
	type Type = DragonBone

	-- Returns a list of available looks for the specified DragonBone file string.
	-- @param boneStr (string) The DragonBone file string to get the looks for.
	-- @return ({string}) A table of strings representing the available looks.
	getLooks: function(self: DragonBoneClass, boneStr: string): {string}

	-- Returns a list of available animations for the specified DragonBone file string.
	-- @param boneStr (string) The DragonBone file string to get the animations for.
	-- @return ({string}) A table of strings representing the available animations.
	getAnimations: function(self: DragonBoneClass, boneStr: string): {string}

	-- Creates a new instance of 'DragonBone' using the specified bone string.
	-- @param boneStr (string) The DragonBone file string for the new instance.
	-- A DragonBone file string can be a file path with the target file extention like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json".
	-- And the an armature name can be added following a seperator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature"
	-- @return (DragonBone) A new instance of 'DragonBone'. Returns nil if the bone file or atlas file is not found.
	metamethod __call: function(self: DragonBoneClass, boneStr: string): DragonBone | nil

	-- Creates a new instance of 'DragonBone' using the specified bone file and atlas file. This function only loads the first armature.
	-- @param boneFile (string) the filename of the bone file to load.
	-- @param atlasFile (string) the filename of the atlas file to load.
	-- @return (DragonBone) a new instance of 'DragonBone' with the specified bone file and atlas file. Returns nil if the bone file or atlas file is not found.
	metamethod __call: function(self: DragonBoneClass, boneFile: string, atlasFile: string): DragonBone | nil
end

local dragonBoneClass: DragonBoneClass
return dragonBoneClass

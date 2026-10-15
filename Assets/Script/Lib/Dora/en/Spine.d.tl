local Playable = require("Playable").Type

-- An implementation of an animation system using the Spine engine.
local record Spine

	-- Inherits from `Playable`.
	embed Playable

	-- Whether hit testing is enabled.
	hitTestEnabled: boolean

	-- Sets the rotation of a bone in the Spine skeleton.
	-- @param name (string) The name of the bone to rotate.
	-- @param rotation (number) The amount to rotate the bone, in degrees.
	-- @return (boolean) Whether the rotation was successfully set or not.
	setBoneRotation: function(self: Spine, name: string, rotation: number): boolean

	-- Checks if a point in space is inside the boundaries of the Spine skeleton.
	-- @param x (number) The x-coordinate of the point to check.
	-- @param y (number) The y-coordinate of the point to check.
	-- @return (string|nil) The name of the bone at the point, or nil if there is no bone at the point.
	containsPoint: function(self: Spine, x: number, y: number): string | nil

	-- Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or nil if no bone or slot is found.
	-- @param x1 (number) The x-coordinate of the start point of the line segment.
	-- @param y1 (number) The y-coordinate of the start point of the line segment.
	-- @param x2 (number) The x-coordinate of the end point of the line segment.
	-- @param y2 (number) The y-coordinate of the end point of the line segment.
	-- @return (string|nil) The name of the bone or slot at the intersection point, or nil if no bone or slot is found.
	intersectsSegment: function(self: Spine, x1: number, y1: number, x2: number, y2: number): string | nil
end

-- A class for creating instances of the 'Spine' record.
local record SpineClass
	type Type = Spine

	-- Returns a list of available looks for the specified Spine2D file string.
	-- @param spineStr (string) The Spine2D file string to get the looks for.
	-- @return (table) A table of strings representing the available looks.
	getLooks: function(self: SpineClass, spineStr: string): {string}

	-- Returns a list of available animations for the specified Spine2D file string.
	-- @param spineStr (string) The Spine2D file string to get the animations for.
	-- @return (table) A table of strings representing the available animations.
	getAnimations: function(self: SpineClass, spineStr: string): {string}

	-- Creates a new instance of 'Spine' using the specified Spine string.
	-- @param spineStr (string) The Spine file string for the new instance.
	-- A Spine file string can be a file path with the target file extention like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".
	-- @return (Spine) A new instance of 'Spine'. Returns nil if the Spine file could not be loaded.
	metamethod __call: function(self: SpineClass, spineStr: string): Spine | nil

	-- Creates a new instance of 'Spine' using the specified skeleton file and atlas file.
	-- @param skelFile (string) the filename of the skeleton file to load.
	-- @param atlasFile (string) the filename of the atlas file to load.
	-- @return (Spine) a new instance of 'Spine' with the specified skeleton file and atlas file. Returns nil if the skeleton file or atlas file could not be loaded.
	metamethod __call: function(self: SpineClass, skelFile: string, atlasFile: string): Spine | nil
end

local spineClass: SpineClass
return spineClass

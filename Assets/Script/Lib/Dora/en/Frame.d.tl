local ActionDef = require("Action").Def

-- Create a frame animation with frames count for each frame. Can only be performed on a Sprite node.
-- @param clipStr (string) The string containing format for loading a texture file.
-- Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
-- @param duration (number) The total duration of the animation.
-- @param frames ({integer}) [optional] The number of frames for each frame. The number of frames should match the number of frames in the clip.
-- @return (ActionDef) Returns a new action definition.
local frame: function(clipStr: string, duration: number, frames?: {integer}): ActionDef

return frame

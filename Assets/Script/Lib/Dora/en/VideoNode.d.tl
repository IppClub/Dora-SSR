local Sprite = require("Sprite").Type

-- A class that represents a video node.
local record VideoNode

	-- Inherits from `Sprite`.
	embed Sprite

	-- Pauses the video playback.
	pause: function(self: VideoNode)

	-- Resumes the video playback.
	resume: function(self: VideoNode)

	-- Whether the video is currently paused.
	readonly paused: boolean
end

-- A class for creating VideoNode objects.
local record VideoNodeClass
	type Type = VideoNode

	-- The constructor function for creating a VideoNode instance.
	-- @param filename (string) The path to an Ogg (`.ogv`) file containing a Theora video stream. VideoNode reads it through Dora Content, renders video only, supports Theora 4:2:0/4:2:2/4:4:4, and decodes in software; play audio separately.
	-- @param looped (boolean) [optional] Whether the video should loop. Default is false.
	-- @return (VideoNode | nil) The created VideoNode instance. If creation fails, returns nil.
	metamethod __call: function(
		self: VideoNodeClass,
		filename: string,
		looped?: boolean --[[false]]
	): VideoNode | nil
end

local videoNodeClass: VideoNodeClass
return videoNodeClass

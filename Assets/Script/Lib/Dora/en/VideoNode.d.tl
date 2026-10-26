local Sprite = require("Sprite").Type

-- A class that represents a video node.
local record VideoNode

	-- Inherits from `Sprite`.
	embed Sprite

	-- Pauses the video and embedded audio playback.
	pause: function(self: VideoNode)

	-- Resumes both tracks; restarts from zero after the end.
	resume: function(self: VideoNode)

	-- Whether the video is currently paused.
	readonly paused: boolean

	-- Starts or resumes both tracks; restarts from zero after the end.
	play: function(self: VideoNode)

	-- Seeks both tracks in seconds, clamped to [0, duration]. Preserves pause and updates the paused image asynchronously. Non-finite values are ignored.
	seek: function(self: VideoNode, seconds: number)

	-- Seeks to zero while preserving the paused state.
	rewind: function(self: VideoNode)

	-- Current playback position in seconds.
	readonly currentTime: number

	-- Total playback duration in seconds, the longer of the audio and video tracks.
	readonly duration: number

	-- Whether playback is requested in the running scene and has not paused or ended. Includes buffering.
	readonly playing: boolean
end

-- A class for creating VideoNode objects.
local record VideoNodeClass
	type Type = VideoNode

	-- The constructor function for creating a VideoNode instance.
	-- @param filename (string) The path to an Ogg (`.ogv`) file containing a Theora video stream. VideoNode reads it through Dora Content, decodes Theora 4:2:0/4:2:2/4:4:4 in software, and automatically plays an embedded Vorbis track with synchronized pause, resume, and looping.
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

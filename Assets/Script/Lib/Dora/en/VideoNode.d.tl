local Sprite = require("Sprite").Type

-- A class that represents a video node.
local record VideoNode

	-- Inherits from `Sprite`.
	embed Sprite
end

-- A class for creating VideoNode objects.
local record VideoNodeClass
	type Type = VideoNode

	-- The constructor function for creating a VideoNode instance.
	-- @param filename (string) The path to the video file. It should be a valid video file path with `.h264` suffix.
	--     H.264 format requirements:
	--     - Video codec: H.264 / AVC only (no H.265/HEVC, VP9, AV1, etc.).
	--     - Bitstream format: Annex-B byte stream is required (NAL units separated by 0x000001 / 0x00000001 start codes).
	--       MP4/FLV-style AVCC (length-prefixed NAL units) is NOT supported unless converted to Annex-B beforehand.
	--     - Stream type: video-only elementary stream is recommended. Audio tracks (if any) are ignored.
	--     - Profile/level constraints (recommended for maximum compatibility and performance):
	--         * Baseline / Constrained Baseline profile is recommended.
	--         * Progressive frames only (no interlaced/field-coded content).
	--         * No B-frames is recommended (e.g., baseline) to avoid output reordering costs.
	--     - Color format: YUV 4:2:0 (8-bit) is recommended; other chroma formats may be unsupported.
	--     - Frame rate: Constant frame rate (CFR) is recommended. Variable frame rate streams may play with unstable timing.
	--     - Resolution/performance notes:
	--         * 4K and high-bitrate streams may be CPU intensive for software decoding.
	--         * For smooth playback on mid-range devices, 720p/1080p and moderate bitrates are recommended.
	--     - It is recommended to use the `ffmpeg` tool to convert the video file to H.264 format before using it.
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

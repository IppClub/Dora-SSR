local Sprite = require("Sprite").Type

-- 用于表示视频节点的类。
local record VideoNode

	-- 继承自 `Sprite`。
	embed Sprite

	-- 暂停视频播放。
	pause: function(self: VideoNode)

	-- 继续视频播放。
	resume: function(self: VideoNode)

	-- 视频当前是否暂停。
	readonly paused: boolean
end

-- 用于创建 VideoNode 实例的类。
local record VideoNodeClass
	type Type = VideoNode

	-- 构造函数，用于创建一个 VideoNode 实例。
	-- @param filename (string) 视频文件路径，应为包含 Theora 视频流的 Ogg（`.ogv`）文件。VideoNode 通过 Dora Content 读取，仅渲染视频，支持 Theora 4:2:0/4:2:2/4:4:4 并使用软件解码；音频需单独播放。
	-- @param looped (boolean) [可选] 是否循环播放，默认为 false。
	-- @return (VideoNode | nil) 新创建的 VideoNode 实例。如果创建失败，则返回 nil。
	metamethod __call: function(
		self: VideoNodeClass,
		filename: string,
		looped?: boolean --[[false]]
	): VideoNode | nil
end

local videoNodeClass: VideoNodeClass
return videoNodeClass

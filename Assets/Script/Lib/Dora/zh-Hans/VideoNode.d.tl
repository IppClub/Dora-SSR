local Sprite = require("Sprite").Type

-- 用于表示视频节点的类。
local record VideoNode

	-- 继承自 `Sprite`。
	embed Sprite

	-- 同时暂停视频和内嵌音轨。
	pause: function(self: VideoNode)

	-- 继续音画播放，已结束时从头播放。
	resume: function(self: VideoNode)

	-- 视频当前是否暂停。
	readonly paused: boolean

	-- 开始或继续音画播放；已结束时从头播放。
	play: function(self: VideoNode)

	-- 以秒为单位同步跳转音画，限制在 [0, duration]。保持暂停状态，暂停画面会异步更新；忽略非有限数值。
	seek: function(self: VideoNode, seconds: number)

	-- 跳转到开头，保持暂停状态。
	rewind: function(self: VideoNode)

	-- 当前播放位置，单位为秒。
	readonly currentTime: number

	-- 总播放时长，单位为秒，取音画两条轨道中的较长时长。
	readonly duration: number

	-- 节点在运行场景中请求播放且未暂停、未结束，包括缓冲过程。
	readonly playing: boolean
end

-- 用于创建 VideoNode 实例的类。
local record VideoNodeClass
	type Type = VideoNode

	-- 构造函数，用于创建一个 VideoNode 实例。
	-- @param filename (string) 视频文件路径，应为包含 Theora 视频流的 Ogg（`.ogv`）文件。VideoNode 通过 Dora Content 读取，支持 Theora 4:2:0/4:2:2/4:4:4 软件解码，并自动播放内嵌 Vorbis 音轨；暂停、恢复和循环播放会同步控制音画。
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

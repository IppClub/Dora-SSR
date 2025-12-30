local Sprite = require("Sprite").Type

-- 用于表示视频节点的类。
local record VideoNode

	-- 继承自 `Sprite`。
	embed Sprite
end

-- 用于创建 VideoNode 实例的类。
local record VideoNodeClass
	type Type = VideoNode

	-- 构造函数，用于创建一个 VideoNode 实例。
	-- @param filename (string) 视频文件路径。应为 `.h264` 后缀及格式有效的视频文件路径。
	--     H.264 格式要求：
	--     - 视频编码：仅支持 H.264 / AVC（不支持 H.265/HEVC，VP9，AV1 等）。
	--     - 比特流格式：需为 Annex-B 字节流（NAL 单元之间以 0x000001 / 0x00000001 起始码分隔）。
	--       MP4/FLV 格式的 AVCC（长度前缀 NAL 单元）不支持，除非预先转换为 Annex-B。
	--     - 流类型：推荐仅包含视频的流。音频轨道（如有）会被忽略。
	--     - 配置文件/级别建议（为最大兼容性和性能）：
	--         * 推荐 Baseline / Constrained Baseline profile。
	--         * 仅支持逐行扫描（progressive）帧（不支持隔行/场编码内容）。
	--         * 推荐不含 B 帧（如 baseline），以避免输出重排序开销。
	--     - 色彩格式：推荐 YUV 4:2:0（8 位）；其他色度格式可能不被支持。
	--     - 帧率：推荐恒定帧率（CFR），可变帧率可能导致播放时序不稳定。
	--     - 分辨率/性能说明：
	--         * 4K 与高码率流在纯软件解码时可能会有较高的 CPU 占用。
	--         * 中等性能设备建议使用 720p/1080p 及适中码率以保证流畅播放。
	--     - 建议使用 `ffmpeg` 工具将视频文件转换为 H.264 格式后再使用。
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

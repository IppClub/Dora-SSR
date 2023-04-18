-- 音频播放管理单例类。
local record Audio
	userdata

	-- 播放音效并返回音频句柄。
	-- @param filename (string) 音效文件的路径（必须为 WAV 文件）。
	-- @param loop (boolean) [可选] 是否循环播放音效（默认为 false）。
	-- @return (integer) 音频句柄，可用于停止音效。
	play: function(
		self: Audio,
		filename: string,
		loop?: boolean --[[false]]
	): integer

	-- 停止当前正在播放的音效。
	-- @param handler (integer) `Audio:play()` 函数返回的音频句柄。
	stop: function(self: Audio, handler: integer)

	-- 以流媒体方式播放音频文件。
	-- @param filename (string) 流媒体音频文件的路径（可以是 OGG、WAV、MP3 或 FLAC格式）。
	-- @param loop (boolean) [可选] 是否循环播放流媒体音频（默认为 false）。
	-- @param crossFadeTime (number) [可选] 在上一个流媒体音频和新的流媒体音频之间交叉淡入淡出的时间（默认为 0.0）。
	playStream: function(
		self: Audio,
		filename: string,
		loop?: boolean --[[false]],
		crossFadeTime?: number --[[0.0]]
	)

	-- 停止当前正在播放的流媒体音频文件。
	-- @param fadeTime (number) [可选] 淡出流媒体音频的时间（默认为 0.0）。
	stopStream: function(
		self: Audio,
		fadeTime?: number --[[0.0]]
	)
end

local audio: Audio
return audio

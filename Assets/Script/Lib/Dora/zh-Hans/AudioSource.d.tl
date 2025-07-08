local AudioBus = require("AudioBus").Type
local Node = require("Node").Type

-- 用于表示音频源节点的记录。
local record AudioSource

	-- 继承自 `Node`。
	embed Node

	-- 3D 音频源的衰减模型。
	enum AttenuationModel
		"NoAttenuation"
		"InverseDistance"
		"LinearDistance"
		"ExponentialDistance"
	end

	-- 音频源的音量。取值范围为 0.0 到 1.0。
	volume: number

	-- 音频源的声相。取值范围为 -1.0 到 1.0。
	pan: number

	-- 音频源是否循环播放。
	looping: boolean

	-- 音频源是否正在播放。
	playing: boolean

	-- 跳转到音频源的指定时间。
	-- @param startTime (number) 跳转时间。
	seek: function(self: AudioSource, startTime: number)

	-- 调度音频源在指定时间停止。
	-- @param timeToStop (number) 停止时间。
	scheduleStop: function(self: AudioSource, timeToStop: number)

	-- 停止音频源。
	-- @param fadeTime (number) [可选] 淡出时间，默认为 0 秒。
	stop: function(self: AudioSource, fadeTime?: number)

	-- 播放音频源。
	-- @param delayTime (number) [可选] 延迟时间，默认为 0 秒。
	-- @return (boolean) 是否播放成功。
	play: function(self: AudioSource, delayTime?: number): boolean

	-- 播放音频源作为背景音频。
	-- @return (boolean) 是否播放成功。
	playBackground: function(self: AudioSource): boolean

	-- 播放音频源作为 3D 音频。
	-- @param delayTime (number) 延迟时间。
	-- @return (boolean) 是否播放成功。
	play3D: function(self: AudioSource, delayTime?: number): boolean

	-- 设置音频源的保护状态。如果音频源被保护，当没有可用声音时，它不会被停止。
	-- @param var (boolean) 保护状态。
	setProtected: function(self: AudioSource, var: boolean)

	-- 设置音频源的循环点。音频源将从指定时间开始循环播放到音频结束。
	-- @param loopStartTime (number) 循环开始时间。
	setLoopPoint: function(self: AudioSource, loopStartTime: number)

	-- 设置 3D 音频源的速度。
	-- @param vx (number) x 轴速度。
	-- @param vy (number) y 轴速度。
	-- @param vz (number) z 轴速度。
	setVelocity: function(self: AudioSource, vx: number, vy: number, vz: number)

	-- 设置 3D 音频源的最小和最大距离。
	-- @param min (number) 最小距离。
	-- @param max (number) 最大距离。
	setMinMaxDistance: function(self: AudioSource, min: number, max: number)

	-- 设置 3D 音频源的衰减模型。
	-- @param model (AttenuationModel) 衰减模型。
	-- @param factor (number) 衰减因子。
	setAttenuation: function(self: AudioSource, model: AttenuationModel, factor: number)

	-- 设置 3D 音频源的多普勒因子。
	-- @param factor (number) 多普勒因子。
	setDopplerFactor: function(self: AudioSource, factor: number)
end

-- 用于创建 `AudioSource` 节点的记录。
local record AudioSourceClass
	type Type = AudioSource

	-- 创建一个新的 `AudioSource` 节点。
	-- @param filename (string) 音频文件路径。
	-- @param autoRemove (boolean) [可选] 是否在停止时自动删除音频源。默认为 `true`。
	-- @param bus (AudioBus) [可选] 播放音频源的音频总线。默认为 `nil`。
	-- @return (AudioSource | nil) 创建的 `AudioSource` 节点。如果文件加载失败则返回nil。
	metamethod __call: function(self: AudioSourceClass, filename: string, autoRemove?: boolean, bus?: AudioBus): AudioSource | nil
end

return AudioSourceClass

local Object = require("Object").Type

-- 用来控制音频的播放和混音的音频总线。
local record AudioBus

	-- 继承自 `Object`。
	embed Object

	-- 音频总线可以应用的滤波器类型。
	enum Filter

		-- 无滤波器。
		""

		-- 低音增强滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: BOOST, float, min: 0, max: 10
		"BassBoost"

		-- 二阶谐振滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: TYPE, int, values: 0 - LOWPASS, 1 - HIGHPASS, 2 - BANDPASS
		-- param2: FREQUENCY, float, min: 10, max: 8000
		-- param3: RESONANCE, float, min: 0.1, max: 20
		"BiquadResonant"

		-- 直流去除滤波器。
		-- param0: WET, float, min: 0, max: 1
		"DCRemoval"

		-- 回声滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: DELAY, float, min: 0, max: 1
		-- param2: DECAY, float, min: 0, max: 1
		-- param3: FILTER, float, min: 0, max: 1
		"Echo"

		-- 均衡器滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: BAND0, float, min: 0, max: 4
		-- param2: BAND1, float, min: 0, max: 4
		-- param3: BAND2, float, min: 0, max: 4
		-- param4: BAND3, float, min: 0, max: 4
		-- param5: BAND4, float, min: 0, max: 4
		-- param6: BAND5, float, min: 0, max: 4
		-- param7: BAND6, float, min: 0, max: 4
		-- param8: BAND7, float, min: 0, max: 4
		"Eq"

		-- FFT 滤波器。
		-- param0: WET, float, min: 0, max: 1
		"FFT"

		-- 颤音滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: DELAY, float, min: 0.001, max: 0.1
		-- param2: FREQ, float, min: 0.001, max: 100
		"Flanger"

		-- 混响滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: FREEZE, float, min: 0, max: 1
		-- param2: ROOMSIZE, float, min: 0, max: 1
		-- param3: DAMP, float, min: 0, max: 1
		-- param4: WIDTH, float, min: 0, max: 1
		"FreeVerb"

		-- 低音质滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: SAMPLE_RATE, float, min: 100, max: 22000
		-- param2: BITDEPTH, float, min: 0.5, max: 16
		"Lofi"

		-- 机器人化滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: FREQ, float, min: 0.1, max: 100
		-- param2: WAVE, float, min: 0, max: 6
		"Robotize"

		-- 波形整形滤波器。
		-- param0: WET, float, min: 0, max: 1
		-- param1: AMOUNT, float, min: -1, max: 1
		"WaveShaper"
	end

	-- 音频总线的音量。取值范围为 0.0 到 1.0。
	volume: number

	-- 音频总线的声相。取值范围为 -1.0 到 1.0。
	pan: number

	-- 音频总线的播放速度。取值为 1.0 时为正常速度，0.5 为半速，2.0 为双速。
	playSpeed: number

	-- 淡入淡出音频总线的音量到指定值。
	-- @param time (number) 淡入淡出时间（秒）。
	-- @param toVolume (number) 目标音量。
	fadeVolume: function(self: AudioBus, time: number, toVolume: number)

	-- 淡入淡出音频总线的声相到指定值。
	-- @param time (number) 淡入淡出时间（秒）。
	-- @param toPan (number) 目标声相。
	fadePan: function(self: AudioBus, time: number, toPan: number)

	-- 设置音频总线的滤波器。
	-- @param index (integer) 滤波器索引。
	-- @param name (Filter) 滤波器类型。
	setFilter: function(self: AudioBus, index: integer, name: Filter)

	-- 设置音频总线滤波器的参数。
	-- @param index (integer) 滤波器索引。
	-- @param attrId (integer) 滤波器属性 ID。
	-- @param value (number) 参数值。
	setFilterParameter: function(self: AudioBus, index: integer, attrId: integer, value: number)

	-- 获取音频总线滤波器的参数。
	-- @param index (integer) 滤波器索引。
	-- @param attrId (integer) 滤波器属性 ID。
	-- @return (number) 参数值。
	getFilterParameter: function(self: AudioBus, index: integer, attrId: integer): number

	-- 淡入淡出音频总线滤波器的参数到指定值。
	-- @param index (integer) 滤波器索引。
	-- @param attrId (integer) 滤波器属性 ID。
	-- @param to (number) 目标值。
	-- @param time (number) 淡入淡出时间（秒）。
	fadeFilterParameter: function(self: AudioBus, index: integer, attrId: integer, to: number, time: number)
end

-- 用于创建 `AudioBus` 对象的类。
local record AudioBusClass
	type Type = AudioBus

	-- 创建一个新的 `AudioBus` 对象。
	-- @return (AudioBus) 创建的 `AudioBus` 对象。
	metamethod __call: function(self: AudioBusClass): AudioBus
end

return AudioBusClass

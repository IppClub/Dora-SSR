local Object = require("Object").Type

-- A record that represents an audio bus.
local record AudioBus

	-- Inherits from `Object`.
	embed Object

	-- The type of the filter that can be applied to the audio bus.
	enum Filter

		-- No filter.
		""

		-- The bass boost filter.
		-- param0: WET, float, min: 0, max: 1
		-- param1: BOOST, float, min: 0, max: 10
		"BassBoost"

		-- The biquad resonant filter.
		-- param0: WET, float, min: 0, max: 1
		-- param1: TYPE, int, values: 0 - LOWPASS, 1 - HIGHPASS, 2 - BANDPASS
		-- param2: FREQUENCY, float, min: 10, max: 8000
		-- param3: RESONANCE, float, min: 0.1, max: 20
		"BiquadResonant"

		-- The DC removal filter.
		-- param0: WET, float, min: 0, max: 1
		"DCRemoval"

		-- The echo filter.
		-- param0: WET, float, min: 0, max: 1
		-- param1: DELAY, float, min: 0, max: 1
		-- param2: DECAY, float, min: 0, max: 1
		-- param3: FILTER, float, min: 0, max: 1
		"Echo"

		-- The equalizer filter.
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

		-- The FFT filter.
		-- param0: WET, float, min: 0, max: 1
		"FFT"

		-- The flanger filter.
		-- param0: WET, float, min: 0, max: 1
		-- param1: DELAY, float, min: 0.001, max: 0.1
		-- param2: FREQ, float, min: 0.001, max: 100
		"Flanger"

		-- The freeverb filter.
		-- param0: WET, float, min: 0, max: 1
		-- param1: FREEZE, float, min: 0, max: 1
		-- param2: ROOMSIZE, float, min: 0, max: 1
		-- param3: DAMP, float, min: 0, max: 1
		-- param4: WIDTH, float, min: 0, max: 1
		"FreeVerb"

		-- The lofi filter.
		-- param0: WET, float, min: 0, max: 1
		-- param1: SAMPLE_RATE, float, min: 100, max: 22000
		-- param2: BITDEPTH, float, min: 0.5, max: 16
		"Lofi"

		-- The robotize filter.
		-- param0: WET, float, min: 0, max: 1
		-- param1: FREQ, float, min: 0.1, max: 100
		-- param2: WAVE, float, min: 0, max: 6
		"Robotize"

		-- The wave shaper filter.
		-- param0: WET, float, min: 0, max: 1
		-- param1: AMOUNT, float, min: -1, max: 1
		"WaveShaper"
	end

	-- The volume of the audio bus. The value is between 0.0 and 1.0.
	volume: number

	-- The pan of the audio bus. The value is between -1.0 and 1.0.
	pan: number

	-- The play speed of the audio bus. The value 1.0 is the normal speed. 0.5 is half speed. 2.0 is double speed.
	playSpeed: number

	-- Fades the volume of the audio bus to the specified value over the specified time.
	-- @param time (number) The time in seconds to fade the volume.
	-- @param toVolume (number) The volume to fade to.
	fadeVolume: function(self: AudioBus, time: number, toVolume: number)

	-- Fades the pan of the audio bus to the specified value over the specified time.
	-- @param time (number) The time in seconds to fade the pan.
	-- @param toPan (number) The pan to fade to.
	fadePan: function(self: AudioBus, time: number, toPan: number)

	-- Fades the play speed of the audio bus to the specified value over the specified time.
	-- @param time (number) The time in seconds to fade the play speed.
	-- @param toPlaySpeed (number) The play speed to fade to.
	fadePlaySpeed: function(self: AudioBus, time: number, toPlaySpeed: number)

	-- Sets the filter of the audio bus.
	-- @param index (integer) The index of the filter.
	-- @param name (Filter) The type of the filter.
	setFilter: function(self: AudioBus, index: integer, name: Filter)

	-- Sets the parameter of the filter of the audio bus.
	-- @param index (integer) The index of the filter.
	-- @param attrId (integer) The attribute ID of the filter.
	-- @param value (number) The value of the parameter.
	setFilterParameter: function(self: AudioBus, index: integer, attrId: integer, value: number)

	-- Gets the parameter of the filter of the audio bus.
	-- @param index (integer) The index of the filter.
	-- @param attrId (integer) The attribute ID of the filter.
	-- @return (number) The value of the parameter.
	getFilterParameter: function(self: AudioBus, index: integer, attrId: integer): number

	-- Fades the parameter of the filter of the audio bus to the specified value over the specified time.
	-- @param index (integer) The index of the filter.
	-- @param attrId (integer) The attribute ID of the filter.
	-- @param to (number) The value to fade to.
	-- @param time (number) The time in seconds to fade the parameter.
	fadeFilterParameter: function(self: AudioBus, index: integer, attrId: integer, to: number, time: number)
end

-- A record for creating `AudioBus` objects.
local record AudioBusClass
	type Type = AudioBus

	-- Creates a new `AudioBus` object.
	-- @return (AudioBus) The created `AudioBus` object.
	metamethod __call: function(self: AudioBusClass): AudioBus
end

return AudioBusClass

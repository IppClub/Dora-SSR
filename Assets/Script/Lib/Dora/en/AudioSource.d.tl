local AudioBus = require("AudioBus").Type
local Node = require("Node").Type

-- A record that represents an audio source.
local record AudioSource

	-- Inherits from `Node`.
	embed Node

	-- The model of the attenuation.
	enum AttenuationModel
		"NoAttenuation"
		"InverseDistance"
		"LinearDistance"
		"ExponentialDistance"
	end

	-- The volume of the audio source. The value is between 0.0 and 1.0.
	volume: number

	-- The pan of the audio source. The value is between -1.0 and 1.0.
	pan: number

	-- Whether the audio source is looped.
	looping: boolean

	-- Whether the audio source is playing.
	playing: boolean

	-- Seeks to the specified time in the audio source.
	-- @param startTime (number) The time to seek to.
	seek: function(self: AudioSource, startTime: number)

	-- Schedules the stop of the audio source.
	-- @param timeToStop (number) The time to stop the audio source.
	scheduleStop: function(self: AudioSource, timeToStop: number)

	-- Stops the audio source.
	-- @param fadeTime (number) The time to fade the audio source. Default is 0 seconds.
	stop: function(self: AudioSource, fadeTime?: number)

	-- Plays the audio source.
	-- @param delayTime (number) [optional] The time to delay before playing the audio source. Default is 0 seconds.
	-- @return (boolean) Whether the audio source was played successfully.
	play: function(self: AudioSource, delayTime?: number): boolean

	-- Plays the audio source as a background audio.
	-- @return (boolean) Whether the audio source was played successfully.
	playBackground: function(self: AudioSource): boolean

	-- Plays the audio source as a 3D audio.
	-- @param delayTime (number) [optional] The time to delay before playing the audio source. Default is 0 seconds.
	-- @return (boolean) Whether the audio source was played successfully.
	play3D: function(self: AudioSource, delayTime?: number): boolean

	-- Sets the protected state of the audio source. If the audio source is protected, it won't get stopped if we run out of voices.
	-- @param var (boolean) The protected state to set.
	setProtected: function(self: AudioSource, var: boolean)

	-- Sets the loop point of the audio source. The audio source will loop from the specified time to the end of the audio.
	-- @param loopStartTime (number) The time to loop the audio source.
	setLoopPoint: function(self: AudioSource, loopStartTime: number)

	-- Sets the velocity of the 3D audio source.
	-- @param vx (number) The x-axis velocity.
	-- @param vy (number) The y-axis velocity.
	-- @param vz (number) The z-axis velocity.
	setVelocity: function(self: AudioSource, vx: number, vy: number, vz: number)

	-- Sets the minimum and maximum distance of the 3D audio source.
	-- @param min (number) The minimum distance.
	-- @param max (number) The maximum distance.
	setMinMaxDistance: function(self: AudioSource, min: number, max: number)

	-- Sets the attenuation model of the 3D audio source.
	-- @param model (AttenuationModel) The model of the attenuation.
	-- @param factor (number) The factor of the attenuation.
	setAttenuation: function(self: AudioSource, model: AttenuationModel, factor: number)

	-- Sets the Doppler factor of the 3D audio source.
	-- @param factor (number) The factor of the Doppler effect.
	setDopplerFactor: function(self: AudioSource, factor: number)
end

-- A record for creating `AudioSource` nodes.
local record AudioSourceClass
	type Type = AudioSource

	-- Creates a new `AudioSource` node.
	-- @param filename (string) The path to the audio file.
	-- @param autoRemove (boolean) [optional] Whether the audio source should be removed when it's stopped. Default is `true`.
	-- @param bus (AudioBus) [optional] The bus to play the audio source on. Default is `nil`.
	-- @return (AudioSource | nil) The created `AudioSource` node. If the audio file is not loaded, it will return nil.
	metamethod __call: function(self: AudioSourceClass, filename: string, autoRemove?: boolean, bus?: AudioBus): AudioSource | nil
end

return AudioSourceClass

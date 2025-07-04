local Node = require("Node").Type

-- A record of an audio player singleton object.
local record Audio
	userdata

	-- The speed of the sound.
	soundSpeed: number

	-- The global volume.
	globalVolume: number

	-- The listener node of the 3D sound source.
	listener: Node

	-- Plays a sound effect and returns a handler for the audio.
	-- @param filename (string) The path to the sound effect file (must be a WAV file).
	-- @param loop (boolean) [optional] Whether to loop the sound effect (default is false).
	-- @return (integer) A handler for the audio that can be used to stop the sound effect.
	play: function(
		self: Audio,
		filename: string,
		loop?: boolean --[[false]]
	): integer

	-- Stops a sound effect that is currently playing.
	-- @param handler (integer) The handler for the audio that is returned by the `play` function.
	stop: function(self: Audio, handler: integer)

	-- Plays a streaming audio file.
	-- @param filename (string) The path to the streaming audio file (can be OGG, WAV, MP3, or FLAC).
	-- @param loop (boolean) [optional] Whether to loop the streaming audio (default is false).
	-- @param crossFadeTime (number) [optional] The time (in seconds) to crossfade between the previous and new streaming audio (default is 0.0).
	playStream: function(
		self: Audio,
		filename: string,
		loop?: boolean --[[false]],
		crossFadeTime?: number --[[0.0]]
	)

	-- Stops a streaming audio file that is currently playing.
	-- @param fadeTime (number) [optional] The time (in seconds) to fade out the streaming audio (default is 0.0).
	stopStream: function(
		self: Audio,
		fadeTime?: number --[[0.0]]
	)

	-- Pauses all currently playing audio.
	-- @param pause (boolean) The pause state.
	setPauseAllCurrent: function(self: Audio, pause: boolean)

	-- Sets the position of the listener.
	-- @param atX (number) The x-axis position.
	-- @param atY (number) The y-axis position.
	-- @param atZ (number) The z-axis position.
	setListenerAt: function(self: Audio, atX: number, atY: number, atZ: number)

	-- Sets the up direction of the listener.
	-- @param upX (number) The x-axis up direction.
	-- @param upY (number) The y-axis up direction.
	-- @param upZ (number) The z-axis up direction.
	setListenerUp: function(self: Audio, upX: number, upY: number, upZ: number)

	-- Sets the velocity of the listener.
	-- @param velocityX (number) The x-axis velocity.
	-- @param velocityY (number) The y-axis velocity.
	-- @param velocityZ (number) The z-axis velocity.
	setListenerVelocity: function(self: Audio, velocityX: number, velocityY: number, velocityZ: number)
end

local audio: Audio
return audio

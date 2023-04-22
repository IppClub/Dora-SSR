-- A record of an audio player singleton object.
local record Audio
	userdata

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
end

local audio: Audio
return audio

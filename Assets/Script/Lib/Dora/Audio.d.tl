local record Audio
	play: function(self: Audio, filename: string, loop: boolean --[[false]]): integer
	stop: function(self: Audio, handler: integer)
	playStream: function(self: Audio, filename: string, loop: boolean --[[false]], crossFadeTime: number --[[0]])
	stopStream: function(self: Audio, fadeTime: number --[[0]])
end
local audio: Audio
return audio

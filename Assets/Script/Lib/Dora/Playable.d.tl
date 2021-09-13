local Node = require("Node").Type
local Vec2 = require("Vec2").Type
local record Playable
	embed Node
	look: string
	speed: number
	recovery: number
	fliped: boolean
	const current: string
	const lastCompleted: string
	getKey: function(self: Playable, name: string): Vec2
	play: function(self: Playable, name: string, loop: boolean --[[false]]): number
	stop: function(self: Playable)
end
local record PlayableClass
	type Type = Playable
	metamethod __call: function(cls: PlayableClass, filename: string): Playable
end
local playableClass: PlayableClass
return playableClass

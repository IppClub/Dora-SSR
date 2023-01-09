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
	play: function(
		self: Playable,
		name: string,
		loop?: boolean --[[false]]
	): number
	stop: function(self: Playable)
	setSlot: function(self: Playable, name: string, item: Node)
	getSlot: function(self: Playable, name: string): Node | nil
end
local record __SLOT__
	-- Playable:play
	["AnimationEnd"]: function(animationName: string, target: Playable)
end
local record PlayableClass
	type Type = Playable
	metamethod __call: function(cls: PlayableClass, filename: string): Playable
end
print(Playable:getKey(nil))
local playableClass: PlayableClass
return playableClass

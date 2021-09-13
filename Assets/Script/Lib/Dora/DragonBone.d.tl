local Playable = require("Playable").Type
local record DragonBone
	embed Playable
	showDebug: boolean
	hitTestEnabled: boolean
	containsPoint: function(self: DragonBone, x: number, y: number): string | nil
	intersectsSegment: function(self: DragonBone, x1: number, y1: number, x2: number, y2: number): string | nil
end
local record DragonBoneClass
	type Type = DragonBone
	getLooks: function(cls: DragonBone, boneStr: string): {string}
	getAnimations: function(cls: DragonBone, boneStr: string): {string}
	metamethod __call: function(cls: DragonBone, boneStr: string): DragonBone
	metamethod __call: function(cls: DragonBone, boneFile: string, atlasFile: string): DragonBone
end
local dragonBoneClass: DragonBoneClass
return dragonBoneClass

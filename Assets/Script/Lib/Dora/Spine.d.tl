local Playable = require("Playable").Type
local record Spine
	embed Playable
	showDebug: boolean
	hitTestEnabled: boolean
	setBoneRotation: function(self: Spine, name: string, rotation: number): boolean
	containsPoint: function(self: Spine, x: number, y: number): string | nil
	intersectsSegment: function(self: Spine, x1: number, y1: number, x2: number, y2: number): string | nil
end
local record SpineClass
	type Type = Spine
	getLooks: function(self: SpineClass, spineStr: string): {string}
	getAnimations: function(self: SpineClass, spineStr: string): {string}
	metamethod __call: function(self: SpineClass, spineStr: string): Spine
	metamethod __call: function(self: SpineClass, skelFile: string, atlasFile: string): Spine
end
local spineClass: SpineClass
return spineClass

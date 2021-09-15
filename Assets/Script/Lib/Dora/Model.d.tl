local Playable = require("Playable").Type
local Node = require("Node").Type
local record Model
	embed Playable
	const duration: number
	reversed: boolean
	const playing: boolean
	const paused: boolean
	hasAnimation: function(self: Model, name: string): boolean
	pause: function(self: Model)
	resume: function(self: Model)
	resume: function(self: Model, name: string, loop: boolean --[[false]])
	reset: function(self: Model)
	updateTo: function(self: Model, eclapsed: number, reversed: boolean --[[false]])
	getNodeByName: function(self: Model, name: string): Node
	eachNode: function(self: Model, func: function(Node): boolean): boolean
end
local record ModelClass
	type Type = Model
	dummy: function(cls: ModelClass): Model
	getClipFile: function(cls: ModelClass, filename: string): string
	getLooks: function(cls: ModelClass, filename: string): {string}
	getAnimations: function(cls: ModelClass, filename: string): {string}
	metamethod __call: function(cls: ModelClass, filename: string): Model
end
print(Model:getNodeByName())
local modelClass: ModelClass
return modelClass

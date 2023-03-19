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
	resume: function(
		self: Model,
		name?: string,
		loop?: boolean --[[false]]
	)
	reset: function(self: Model)
	updateTo: function(
		self: Model,
		eclapsed: number,
		reversed?: boolean --[[false]]
	)
	getNodeByName: function(self: Model, name: string): Node
	eachNode: function(self: Model, func: function(Node): boolean): boolean
end
local record ModelClass
	type Type = Model
	dummy: function(self: ModelClass): Model
	getClipFile: function(self: ModelClass, filename: string): string
	getLooks: function(self: ModelClass, filename: string): {string}
	getAnimations: function(self: ModelClass, filename: string): {string}
	metamethod __call: function(self: ModelClass, filename: string): Model
end
local modelClass: ModelClass
return modelClass

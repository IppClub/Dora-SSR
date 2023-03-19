local PhysicsWorld = require("PhysicsWorld").Type
local Node = require("Node").Type
local Vec2 = require("Vec2").Type
local PlatformCamera = require("Platformer.PlatformCamera").Type
local record PlatformWorld
	embed PhysicsWorld
	const camera: PlatformCamera
	moveChild: function(self: PlatformWorld, child: Node, newOrder: integer)
	getLayer: function(self: PlatformWorld, order: integer): Node
	setLayerRatio: function(self: PlatformWorld, order: integer, ratio: Vec2)
	getLayerRatio: function(self: PlatformWorld, order: integer): Vec2
	setLayerOffset: function(self: PlatformWorld, order: integer, offset: Vec2)
	getLayerOffset: function(self: PlatformWorld, order: integer): Vec2
	swapLayer: function(self: PlatformWorld, orderA: integer, orderB: integer)
	removeLayer: function(self: PlatformWorld, order: integer)
	removeAllLayers: function(self: PlatformWorld)
end
local record PlatformWorldClass
	type Type = PlatformWorld
	metamethod __call: function(self: PlatformWorldClass): PlatformWorld
end
local platformWorldClass: PlatformWorldClass
return platformWorldClass

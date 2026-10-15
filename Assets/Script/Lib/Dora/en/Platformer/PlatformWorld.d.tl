local PhysicsWorld = require("PhysicsWorld").Type
local Node = require("Node").Type
local Vec2 = require("Vec2").Type
local PlatformCamera = require("Platformer.PlatformCamera").Type

-- A class representing a 2D platformer game world with physics simulations.
local record PlatformWorld

	-- Inherits from `PhysicsWorld`.
	embed PhysicsWorld

	-- The camera used to control the view of the game world.
	const camera: PlatformCamera

	-- Moves a child node to a new order for a different layer.
	-- @param child (Node) The child node to be moved.
	-- @param newOrder (integer) The new order of the child node.
	moveChild: function(self: PlatformWorld, child: Node, newOrder: integer)

	-- Gets the layer node at a given order.
	-- @param order (integer) The order of the layer node to get.
	-- @return (Node) The layer node at the given order.
	getLayer: function(self: PlatformWorld, order: integer): Node

	-- Sets the parallax moving ratio for a given layer to simulate 3D projection effect.
	-- @param order (integer) The order of the layer to set the ratio for.
	-- @param ratio (Vec2) The new parallax ratio for the layer.
	setLayerRatio: function(self: PlatformWorld, order: integer, ratio: Vec2)

	-- Gets the parallax moving ratio for a given layer.
	-- @param order (integer) The order of the layer to get the ratio for.
	-- @return (Vec2) The parallax ratio for the layer.
	getLayerRatio: function(self: PlatformWorld, order: integer): Vec2

	-- Sets the position offset for a given layer.
	-- @param order (integer) The order of the layer to set the offset for.
	-- @param offset (Vec2) The new position offset for the layer.
	setLayerOffset: function(self: PlatformWorld, order: integer, offset: Vec2)

	-- Gets the position offset for a given layer.
	-- @param order (integer) The order of the layer to get the offset for.
	-- @return (Vec2) The position offset for the layer.
	getLayerOffset: function(self: PlatformWorld, order: integer): Vec2

	-- Swaps the positions of two layers.
	-- @param orderA (integer) The order of the first layer to swap.
	-- @param orderB (integer) The order of the second layer to swap.
	swapLayer: function(self: PlatformWorld, orderA: integer, orderB: integer)

	-- Removes a layer from the game world.
	-- @param order (integer) The order of the layer to remove.
	removeLayer: function(self: PlatformWorld, order: integer)

	-- Removes all layers from the game world.
	removeAllLayers: function(self: PlatformWorld)
end

-- A class for instantiating instances of PlatformWorld.
-- @usage
-- local PlatformWorld = require("PlatformWorld")
-- local world = PlatformWorld()
-- world:addTo(entry)
local record PlatformWorldClass
	type Type = PlatformWorld

	-- The metamethod to create a new instance of PlatformWorld.
	-- @return (PlatformWorld) A new instance of PlatformWorld.
	metamethod __call: function(self: PlatformWorldClass): PlatformWorld
end

local platformWorldClass: PlatformWorldClass
return platformWorldClass

local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type
local TextureFilter = require("Sprite").TextureFilter
local Dictionary = require("Dictionary").Type

-- The TileNode class to render Tilemaps from TMX file in game scene tree hierarchy.
local record TileNode

	-- Inherits from `Node`.
	embed Node

	-- Whether the depth buffer should be written to when rendering the tilemap (default is false).
	depthWrite: boolean

	-- The blend function for the tilemap.
	blendFunc: BlendFunc

	-- The tilemap shader effect.
	effect: SpriteEffect

	-- The texture filtering mode for the tilemap.
	filter: TextureFilter

	-- Get the layer data by name from the tilemap.
	-- @param layerName (string) The name of the layer to get from the tilemap.
	-- @return (Dictionary) The layer data as a dictionary. If the layer is not found, it will return nil.
	getLayer: function(self: TileNode, layerName: string): Dictionary | nil
end

-- A class used for creating `TileNode` object.
-- @usage
-- local TileNode = require("TileNode")
-- local tileNode = TileNode("TMX/platform.tmx")
local record TileNodeClass
	type Type = TileNode

	-- A metamethod for creating TileNode object that will render the tile layers.
	-- @param tmxFile (string) The TMX file for the tilemap.
	-- Can be files created with Tiled Map Editor (http://www.mapeditor.org).
	-- And the TMX file should be in the format of XML.
	-- @return (TileNode) A new instance of the TileNode class. If the tilemap file is not found, it will return nil.
	metamethod __call: function(self: TileNodeClass, tmxFile: string): TileNode | nil

	-- A metamethod for creating TileNode object that will render the tile layers.
	-- @param tmxFile (string) The TMX file for the tilemap.
	-- @param layerName (string) The name of the layer to load from the tilemap file.
	-- Can be files created with Tiled Map Editor (http://www.mapeditor.org).
	-- And the TMX file should be in the format of XML.
	-- @return (TileNode) A new instance of the TileNode class. If the tilemap file is not found, it will return nil.
	metamethod __call: function(self: TileNodeClass, tmxFile: string, layerName: string): TileNode | nil

	-- A metamethod for creating TileNode object that will render the tile layers.
	-- @param tmxFile (string) The TMX file for the tilemap.
	-- @param layerNames ({string}) The names of the layers to load from the tilemap file.
	-- Can be files created with Tiled Map Editor (http://www.mapeditor.org).
	-- And the TMX file should be in the format of XML.
	-- @return (TileNode) A new instance of the TileNode class. If the tilemap file is not found, it will return nil.
	metamethod __call: function(self: TileNodeClass, tmxFile: string, layerNames: {string}): TileNode | nil
end

local tileNodeClass: TileNodeClass
return tileNodeClass

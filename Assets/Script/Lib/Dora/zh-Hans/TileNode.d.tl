local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type
local TextureFilter = require("Sprite").TextureFilter
local Dictionary = require("Dictionary").Type

-- TileNode 类用于在游戏场景树层次结构中渲染瓦片地图。
local record TileNode

	-- 继承自 `Node`。
	embed Node

	-- 渲染瓦片地图时是否应向深度缓冲区写入（默认为 false）。
	depthWrite: boolean

	-- 瓦片地图的渲染混合函数。
	blendFunc: BlendFunc

	-- 瓦片地图的着色器效果。
	effect: SpriteEffect

	-- 瓦片地图的纹理过滤模式。
	filter: TextureFilter

	-- 从瓦片地图中按名称获取图层数据。
	-- @param layerName (string) 要从瓦片地图中获取的图层的名称。
	-- @return (Dictionary) 作为字典的图层数据。如果未找到图层，则返回 nil。
	getLayer: function(self: TileNode, layerName: string): Dictionary | nil
end

-- 用于创建 `TileNode` 对象的类。
-- @usage
-- local TileNode = require("TileNode")
-- local tileNode = TileNode("TMX/platform.tmx")
local record TileNodeClass
	type Type = TileNode

	-- 用于创建瓦片地图渲染对象 TileNode 的方法。
	-- @param tmxFile (string) 瓦片地图的 TMX 文件。
	-- 可以是使用 Tiled Map Editor (http://www.mapeditor.org) 创建的文件。
	-- 进行加载的 TMX 文件必须是 XML 格式。
	-- @return (TileNode) 返回 TileNode 类的一个新实例。如果加载瓦片地图文件失败，将返回 nil。
	metamethod __call: function(self: TileNodeClass, tmxFile: string): TileNode | nil

	-- 用于创建瓦片地图渲染对象 TileNode 的方法。
	-- @param tmxFile (string) 瓦片地图的 TMX 文件。
	-- 可以是使用 Tiled Map Editor (http://www.mapeditor.org) 创建的文件。
	-- 进行加载的 TMX 文件必须是 XML 格式。
	-- @param layerName (string) TMX 文件中的地图层的名称。
	-- @return (TileNode) 返回 TileNode 类的一个新实例。如果加载瓦片地图文件失败，将返回 nil。
	metamethod __call: function(self: TileNodeClass, tmxFile: string, layerName: string): TileNode | nil

	-- 用于创建瓦片地图渲染对象 TileNode 的方法。
	-- @param tmxFile (string) 瓦片地图的 TMX 文件。
	-- 可以是使用 Tiled Map Editor (http://www.mapeditor.org) 创建的文件。
	-- 进行加载的 TMX 文件必须是 XML 格式。
	-- @param layerNames ({string}) TMX 文件中的地图层的名称数组。
	-- @return (TileNode) 返回 TileNode 类的一个新实例。如果加载瓦片地图文件失败，将返回 nil。
	metamethod __call: function(self: TileNodeClass, tmxFile: string, layerNames: {string}): TileNode | nil
end

local tileNodeClass: TileNodeClass
return tileNodeClass
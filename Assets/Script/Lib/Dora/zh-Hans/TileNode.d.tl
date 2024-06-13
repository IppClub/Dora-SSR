local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type

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
	-- @param layerName (string) TMX 文件中的地图层的名称。
	-- 可以是使用 Tiled Map Editor (http://www.mapeditor.org) 创建的文件。
	-- 进行加载的 TMX 文件必须是 XML 格式。
	-- @return (TileNode) 返回 TileNode 类的一个新实例。如果加载瓦片地图文件失败，将返回 nil。
	metamethod __call: function(self: TileNodeClass, tmxFile: string, layerName: string): TileNode | nil

	-- 用于创建瓦片地图渲染对象 TileNode 的方法。
	-- @param tmxFile (string) 瓦片地图的 TMX 文件。
	-- @param layerNames ({string}) TMX 文件中的地图层的名称数组。
	-- 可以是使用 Tiled Map Editor (http://www.mapeditor.org) 创建的文件。
	-- 进行加载的 TMX 文件必须是 XML 格式。
	-- @return (TileNode) 返回 TileNode 类的一个新实例。如果加载瓦片地图文件失败，将返回 nil。
	metamethod __call: function(self: TileNodeClass, tmxFile: string, layerNames: {string}): TileNode | nil
end

local tileNodeClass: TileNodeClass
return tileNodeClass
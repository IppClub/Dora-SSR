local Rect = require("Rect").Type
local Vec2 = require("Vec2").Type
local Color = require("Color").Type
local Texture2D = require("Texture2D").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type

-- 用于将一张纹理渲染为一组网格状的图元的场景节点类，网格中每个图元可以被重新定位、着色和操纵其UV坐标。
local record Grid

	-- 继承自`Node`。
	embed Node

	-- 网格中的列数。水平方向有 `gridX + 1` 个顶点用于渲染。
	const gridX: integer

	-- 网格中的行数。垂直方向有 `gridY + 1` 个顶点用于渲染。
	const gridY: integer

	-- 是否启用深度缓冲写入（默认为false）。
	depthWrite: boolean

	-- 用于网格渲染的纹理。
	texture: Texture2D

	-- 在纹理中用于渲染网格的矩形区域。
	textureRect: Rect

	-- 用于渲染网格的混合函数。
	blendFunc: BlendFunc

	-- 应用于网格渲染的图元着色器效果。
	-- 默认值为`SpriteEffect("builtin:vs_sprite", "builtin:fs_sprite")`。
	effect: SpriteEffect

	-- 设置网格中顶点的位置。
	-- @param x (integer) 网格中顶点的x坐标。
	-- @param y (integer) 网格中顶点的y坐标。
	-- @param pos (Vec2) 顶点的新位置。
	-- @param z (number) [可选] 顶点的新z坐标（默认为0）。
	setPos: function(self: Grid, x: integer, y: integer, pos: Vec2, z?: number)

	-- 获取网格中顶点的位置。
	-- @param x (integer) 网格中顶点的x坐标。
	-- @param y (integer) 网格中顶点的y坐标。
	-- @return (Vec2) 顶点的当前位置。
	getPos: function(self: Grid, x: integer, y: integer): Vec2

	-- 获取网格中顶点的颜色。
	-- @param x (integer) 网格中顶点的x坐标。
	-- @param y (integer) 网格中顶点的y坐标。
	-- @return (Color) 顶点的当前颜色。
	getColor: function(self: Grid, x: integer, y: integer): Color

	-- 设置网格中顶点的颜色。
	-- @param x (integer) 网格中顶点的x坐标。
	-- @param y (integer) 网格中顶点的y坐标。
	-- @param color (Color) 顶点的新颜色。
	setColor: function(self: Grid, x: integer, y: integer, color: Color)

	-- 移动网格中顶点的UV坐标。
	-- @param x (integer) 网格中顶点的x坐标。
	-- @param y (integer) 网格中顶点的y坐标。
	-- @param offset (Vec2) 移动UV坐标的偏移量。
	moveUV: function(self: Grid, x: integer, y: integer, offset: Vec2)
end

-- 用于创建网格对象的类。
local record GridClass
	type Type = Grid

	-- 创建具有指定纹理矩形和网格大小的新网格。
	-- @param width (number) 网格的宽度。
	-- @param height (number) 网格的高度。
	-- @param gridX (integer) 网格中列的数量。
	-- @param gridY (integer) 网格中行的数量。
	-- @return (Grid) 新网格实例。
	metamethod __call: function(self: GridClass, width: number, height: number, gridX: integer, gridY: integer): Grid

	-- 创建具有指定纹理、纹理矩形和网格大小的新网格。
	-- @param texture (Texture2D) 用于网格的纹理。
	-- @param textureRect (Rect) 用于网格的纹理内的矩形。
	-- @param gridX (integer) 网格中列的数量。
	-- @param gridY (integer) 网格中行的数量。
	-- @return (Grid) 新网格实例。
	metamethod __call: function(self: GridClass, texture: Texture2D, textureRect: Rect, gridX: integer, gridY: integer): Grid

	-- 创建具有指定纹理和网格大小的新网格。
	-- @param texture (Texture2D) 用于网格的纹理。
	-- @param gridX (integer) 网格中列的数量。
	-- @param gridY (integer) 网格中行的数量。
	-- @return (Grid) 新网格实例。
	metamethod __call: function(self: GridClass, texture: Texture2D, gridX: integer, gridY: integer): Grid

	-- 创建具有指定图片切片字符串和网格大小的新网格。
	-- @param clipStr (string) 用于网格渲染的图片切片字符串。
	-- 可以是 "Image/file.png" 或者 "Image/items.clip|itemA"。
	-- @param gridX (integer) 网格中列的数量。
	-- @param gridY (integer) 网格中行的数量。
	-- @return (Grid) 新网格实例。
	metamethod __call: function(self: GridClass, clipStr: string, gridX: integer, gridY: integer): Grid
end

local gridClass: GridClass
return gridClass

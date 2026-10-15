local Rect = require("Rect").Type
local Texture2D = require("Texture2D").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Node = require("Node").Type

-- 用于渲染图片纹理的游戏场景树节点类，也叫做游戏图元（精灵）。
local record Sprite

	-- 继承自`Node`。
	embed Node

	-- 纹理绘制环绕模式的枚举。
	enum TextureWrap
		"None"
		"Mirror"
		"Clamp"
		"Border"
	end

	-- 纹理过滤模式的枚举。
	enum TextureFilter
		"None"
		"Point"
		"Anisotropic"
	end

	-- 是否在渲染时写入深度缓冲区（默认为false）。
	depthWrite: boolean

	-- 用于alpha测试的alpha参考值。alpha值小于或等于该值的像素将被丢弃。
	-- 仅生效于`sprite.effect = SpriteEffect("builtin:vs_sprite”，“builtin:fs_spritealphatest"）`。
	alphaRef: number

	-- 渲染纹理使用的纹理矩形区域。
	textureRect: Rect

	-- 用于渲染纹理的混合函数。
	blendFunc: BlendFunc

	-- 用于渲染纹理的着色器特效对象。
	effect: SpriteEffect

	-- 要渲染的纹理对象.
	const texture: Texture2D

	-- 渲染使用的 U（水平）轴的纹理环绕模式。
	uwrap: TextureWrap

	-- 渲染使用的 V（垂直）轴的纹理环绕模式。
	vwrap: TextureWrap

	-- 渲染使用的纹理过滤模式。
	filter: TextureFilter
end

-- 用于创建新的图元对象的类。
-- @usage
-- local Sprite = require("Sprite")
-- local sprite = Sprite("Image/file.png")
local record SpriteClass
	type Type = Sprite
	type TextureFilter = Sprite.TextureFilter

	-- 从图集切片文件中获取切片名称和矩形区域。
	-- @param clipFile (string) 要加载的图集切片文件，文件后缀名必须是".clip"。
	-- @return ({string: Rect} | nil) 包含切片名称和矩形区域的表。
	getClips: function(self: SpriteClass, clipFile: string): {string: Rect} | nil

	-- 用于创建新的图元对象的元方法。
	-- @param clipStr (string) 包含要加载的纹理文件名的字符串。
	-- 可以是"Image/file.png"或"Image/items.clip|itemA"。支持的图片文件格式包括：jpg，png，dds，pvr，ktx。
	-- @return (Sprite | nil) 新的图元对象。如果文件加载失败则返回nil。
	metamethod __call: function(self: SpriteClass, clipStr: string): Sprite | nil

	-- 用于创建新的图元对象的元方法。
	-- @return (Sprite) 新的图元对象。
	metamethod __call: function(self: SpriteClass): Sprite

	-- 用于创建新的图元对象的元方法。
	-- @param texture (Texture2D) 要渲染的纹理。
	-- @param textureRect (Rect) [可选] 用于渲染的纹理矩形区域，没有提供则设置为渲染所有纹理区域。
	-- @return (Sprite) 新的图元对象。
	metamethod __call: function(self: SpriteClass, texture: Texture2D, textureRect?: Rect): Sprite
end

local spriteClass: SpriteClass
return spriteClass

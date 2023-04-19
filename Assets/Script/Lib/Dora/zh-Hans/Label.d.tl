local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local SpriteEffect = require("SpriteEffect").Type
local Sprite = require("Sprite").Type

-- 使用TrueType字体渲染文本的场景节点类。
local record Label

	-- 继承自`Node`。
	embed Node

	-- 用于文本对齐设置的枚举。
	enum TextAlign
		"Left"
		"Center"
		"Right"
	end

	-- Alpha阈值值。Alpha值低于此值的像素将不会被绘制。
	-- 仅适用于 `label.effect = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritealphatest")`。
	alphaRef: number

	-- 用于文本换行的文本宽度。
	-- 设置为 `Label.AutomaticWidth` 以禁用换行。
	-- 默认值为 `Label.AutomaticWidth`。
	textWidth: number

	-- 文本行之间的像素间隔。
	lineGap: number

	-- 要渲染的文本。
	text: string

	-- 用于渲染文本的混合函数。
	blendFunc: BlendFunc

	-- 是否启用深度写入。默认为false。
	depthWrite: boolean

	-- 标签是否使用批量渲染模式。默认为true。
	-- 使用批量渲染可以获得更好的渲染性能，但是`label:getCharacter()`函数将无法使用。
	batched: boolean

	-- 用于渲染文本的图元着色器特效。
	effect: SpriteEffect

	-- 文本对齐设置。
	alignment: TextAlign

	-- 文本中字符的数量。
	const characterCount: integer

	-- 返回指定索引处字符的精灵。
	-- @param index (integer) 要检索的字符图元的索引。
	-- @return (Sprite|nil) 字符的图元，如果超出索引范围则返回 `nil`。
	getCharacter: function(self: Label, index: integer): Sprite | nil
end

-- 用于创建文本标签对象的类。
local record LabelClass
	type Type = Label

	-- 用于自动计算宽度的设置常量。
	const AutomaticWidth: number

	-- 使用指定的字体名称和字体大小创建新的文本标签对象。
	-- @param fontName (string) 用于标签的字体名称。
	-- 可以是带有或是不带文件扩展名的字体文件路径。
	-- @param fontSize (integer) 用于标签的字体大小。
	-- @return (Label) 新的文本标签对象。
	metamethod __call: function(self: LabelClass, fontName: string, fontSize: integer): Label
end

local labelClass: LabelClass
return labelClass

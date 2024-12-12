local Node = require("Node").Type
local BlendFunc = require("BlendFunc").Type
local SpriteEffect = require("SpriteEffect").Type
local Sprite = require("Sprite").Type
local Color = require("Color").Type
local Vec2 = require("Vec2").Type

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

	-- 文本行之间的像素间隔。
	spacing: number

	-- 描边颜色，仅适用于SDF标签。
	outlineColor: Color

	-- 描边宽度，仅适用于SDF标签。
	outlineWidth: number

	-- 文本的平滑值，仅适用于SDF标签，默认是 (0.7, 0.7)。
	smooth: Vec2

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

	-- 使用指定的字体字符串创建新的文本标签对象。
	-- @param fontStr (string) 用于标签的字体字符串。应该以 "fontName;fontSize;sdf" 的格式表示，其中 `sdf` 应该是 "true" 或 "false"，并且可以省略，默认是 false。
	-- @return (Label | nil) 新的文本标签对象，如果创建失败则返回 `nil`。
	metamethod __call: function(self: LabelClass, fontStr: string): Label | nil

	-- 使用指定的字体名称和字体大小创建新的文本标签对象。
	-- @param fontName (string) 用于标签的字体名称。
	-- 可以是带有或是不带文件扩展名的字体文件路径。
	-- @param fontSize (integer) 用于标签的字体大小。
	-- @param sdf (boolean) [optional] 是否启用SDF渲染。启用SDF渲染后，描边功能将生效。(默认是false)
	-- @return (Label | nil) 新的文本标签对象，如果创建失败则返回 `nil`。
	metamethod __call: function(self: LabelClass, fontName: string, fontSize: integer, sdf?: boolean): Label | nil
end

local labelClass: LabelClass
return labelClass

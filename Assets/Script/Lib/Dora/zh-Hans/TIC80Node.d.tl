local Sprite = require("Sprite").Type

-- 用于表示 TIC-80 虚拟机节点的类。
local record TIC80Node

	-- 继承自 `Sprite`。
	embed Sprite
end

-- 用于创建 TIC80Node 实例的类。
local record TIC80NodeClass
	type Type = TIC80Node

	-- 构造函数，用于创建一个 TIC80Node 实例。
	-- @param cartFile (string) TIC-80 卡带文件路径。应为有效的 TIC-80 卡带文件（`.tic` 或 `.png` 格式）。
	--     TIC-80 卡带文件包含将在 TIC-80 虚拟机中运行的完整游戏或程序。
	--     支持的功能：
	--     - 完整的 TIC-80 API 支持（绘制、声音、输入等）。
	--     - 键盘、手柄和触摸输入处理。
	--     - 通过 TIC-80 声音引擎进行音频播放。
	--     - 以 TIC-80 原生分辨率运行（240x136 像素）。
	--     - 固定帧率，匹配 TIC-80 规范（60 FPS）。
	-- @return (TIC80Node | nil) 新创建的 TIC80Node 实例。如果创建失败，则返回 nil。
	metamethod __call: function(
		self: TIC80NodeClass,
		cartFile: string
	): TIC80Node | nil
end

local tic80NodeClass: TIC80NodeClass
return tic80NodeClass

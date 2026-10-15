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

	-- 构造函数，用于创建一个 TIC80Node 实例，从代码文件加载代码，从卡带文件加载美术和音频资源。
	-- @param resourceCartFile (string) 包含美术和音频资源的 TIC-80 卡带文件路径（`.tic` 或 `.png` 格式）。
	-- @param codeFile (string) 代码文件路径（例如：`.lua`、`.yue`）。
	-- @return (TIC80Node | nil) 新创建的 TIC80Node 实例。如果创建失败，则返回 nil。
	metamethod __call: function(
		self: TIC80NodeClass,
		resourceCartFile: string,
		codeFile: string
	): TIC80Node | nil

	-- 从 TIC-80 卡带文件中提取代码文本。
	-- @param cartFile (string) TIC-80 卡带文件路径（`.tic` 或 `.png` 格式）。
	-- @return (string) 提取的代码文本，如果失败则返回空字符串。
	codeFromCart: function(self: TIC80NodeClass, cartFile: string): string

	-- 合并资源卡带和代码文件为 .tic 卡带文件。
	-- @param outputFile (string) 保存合并后的 .tic 卡带文件的路径。
	-- @param resourceCartFile (string) 资源卡带文件路径。
	-- @param codeFile (string) 代码文件路径。
	-- @return (boolean) 成功返回 true，否则返回 false。
	mergeTic: function(self: TIC80NodeClass, outputFile: string, resourceCartFile: string, codeFile: string): boolean

	-- 合并 PNG 封面、资源卡带和可选的代码文件为 .png 卡带文件。
	-- @param outputFile (string) 保存合并后的 .png 卡带文件的路径。
	-- @param coverPngFile (string) 封面 PNG 图片文件路径。
	-- @param resourceCartFile (string) 资源卡带文件路径。
	-- @param codeFile (string) [可选] 代码文件路径。如果为空，则使用资源卡带中的代码。
	-- @return (boolean) 成功返回 true，否则返回 false。
	mergePng: function(self: TIC80NodeClass, outputFile: string, coverPngFile: string, resourceCartFile: string, codeFile?: string): boolean
end

local tic80NodeClass: TIC80NodeClass
return tic80NodeClass
